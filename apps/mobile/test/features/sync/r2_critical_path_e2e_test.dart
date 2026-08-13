import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_session_state.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sync/application/conflict_resolution_service.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R2-08 – kritický end-to-end důkaz hlavní hodnoty R2 (VSP §11/§13).
///
/// Jeden deterministický scénář nad skutečnou lokální SQLite (reálné Drift
/// repozitáře, reálný owner binding, reálný attach, reálný SyncEngine;
/// fake jsou jen technické hranice — síť/API, secure storage, clock):
///
/// 1. anonymní R1 trénink (offline, bez účtu),
/// 2. registrace → automatický attach anonymních dat k účtu (C15),
/// 3. offline push → vše zůstává pending (žádný tichý úspěch),
/// 4. „restart" aplikace → session i pending operace přežijí,
/// 5. online push → data odejdou pod týmiž client-generated ID,
///    čistý seed se nesynchronizuje,
/// 6. idempotentní replay → žádná duplicita,
/// 7. další lokální změna → VERSION_CONFLICT jako explicitní stav,
/// 8. USE_LOCAL → potvrzený re-push s novým klíčem → SYNCED,
/// 9. serverová revokace session → bezpečné odhlášení bez ztráty
///    lokálních dat,
/// 10. opětovné přihlášení → data dál patří účtu, nic se neduplikuje.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 15);

  ProviderContainer createAppContainer({
    required AppDatabase database,
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient authApi,
    required FakeSyncApiClient syncApi,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(authApi),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-e2e'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<Map<String, Object?>> row(
    AppDatabase db,
    String sql, [
    List<Variable> variables = const [],
  ]) async =>
      (await db.customSelect(sql, variables: variables).getSingle()).data;

  test('kritická R2 cesta: anonymní trénink → účet/attach → offline pending '
      '→ push → replay bez duplicit → konflikt → USE_LOCAL → revokace bez '
      'ztráty dat → re-login', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final authApi = FakeAuthApiClient();
    final syncApi = FakeSyncApiClient();

    // ---- 1. Anonymní R1 trénink (offline hodnota bez účtu, R2P-004). ----
    var app = createAppContainer(
      database: database,
      storage: storage,
      authApi: authApi,
      syncApi: syncApi,
    );
    await app.read(workoutBootstrapCompletedProvider.future);
    final instances = await app
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(formatLocalDate(fixedNow));
    final instanceId = instances.first.id;
    const sessionId = 'session-e2e-1';
    final started = await app
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: instanceId,
          newSessionId: sessionId,
          now: fixedNow,
        );
    expect(started, isA<SessionCreated>());
    // Zápis výkonu do trackeru (inicializace performance řádků + actuals).
    await app.read(sessionTrackerProvider(sessionId).future);
    final setId =
        (await row(
              database,
              'SELECT id FROM local_set_performances ORDER BY id LIMIT 1',
            ))['id']
            as String;
    await app
        .read(workoutPerformanceRepositoryProvider)
        .recordSetActuals(
          setPerformanceId: setId,
          actualRepetitions: 11,
          actualWeightKg: 42.5,
          now: fixedNow,
        );

    // ---- 2. Registrace → binding + automatický attach (C15 §6). ----
    await app.read(authSessionManagerProvider.future);
    final registered = await app
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'e2e@example.com', password: 'password-123');
    expect(registered, isA<AuthFlowSuccess>());
    expect(
      (await row(
        database,
        'SELECT owner_id FROM local_workout_sessions WHERE id = ?',
        [Variable.withString(sessionId)],
      ))['owner_id'],
      equals('account-1'),
    );

    // ---- 3. Offline push: vše zůstává pending, žádný tichý úspěch. ----
    syncApi.offline = true;
    expect(
      await app.read(syncEngineProvider).pushPending(),
      isA<SyncRunFailed>(),
    );
    final pendingKeys = (await database.select(database.localOutbox).get())
        .map((r) => r.idempotencyKey)
        .toSet();
    expect(pendingKeys, isNotEmpty);

    // ---- 4. „Restart": nový container nad touž DB + storage. ----
    app = createAppContainer(
      database: database,
      storage: storage,
      authApi: authApi,
      syncApi: syncApi,
    );
    final restoredState = await app.read(authSessionManagerProvider.future);
    expect(restoredState, isA<AuthenticatedAuthState>());
    final authSessionId = (restoredState as AuthenticatedAuthState).sessionId;

    // ---- 5. Online push pod týmiž client-generated ID. ----
    syncApi.offline = false;
    final firstPush = await app.read(syncEngineProvider).pushPending();
    expect(firstPush, isA<SyncRunCompleted>());
    expect((firstPush as SyncRunCompleted).conflicts, equals(0));
    expect(firstPush.rejected, equals(0));
    final firstBatch = syncApi.pushedBatches.last;
    expect(
      firstBatch.any(
        (op) =>
            op.entityType == 'WORKOUT_INSTANCE' && op.entityId == instanceId,
      ),
      isTrue,
    );
    expect(
      firstBatch.any(
        (op) => op.entityType == 'WORKOUT_SESSION' && op.entityId == sessionId,
      ),
      isTrue,
    );
    expect(
      firstBatch.any(
        (op) => op.entityType == 'SET_PERFORMANCE' && op.entityId == setId,
      ),
      isTrue,
    );
    // Idempotency klíče jsou tytéž jako před restartem (IDC-001).
    final sentKeys = firstBatch.map((op) => op.idempotencyKey).toSet();
    expect(sentKeys.containsAll(pendingKeys), isTrue);
    // Čistý seed se nesynchronizuje (LAM-006): jediná instance v batchi.
    expect(
      firstBatch.where((op) => op.entityType == 'WORKOUT_INSTANCE').length,
      equals(1),
    );
    expect(
      (await row(
        database,
        'SELECT sync_state FROM local_workout_sessions WHERE id = ?',
        [Variable.withString(sessionId)],
      ))['sync_state'],
      equals('SYNCED'),
    );

    // ---- 6. Idempotentní replay: žádná nová operace, žádná duplicita. ----
    final batchesBefore = syncApi.pushedBatches.length;
    final replay = await app.read(syncEngineProvider).pushPending();
    expect((replay as SyncRunCompleted).synced, equals(0));
    expect(syncApi.pushedBatches.length, equals(batchesBefore));

    // ---- 7. Další lokální změna → explicitní VERSION_CONFLICT. ----
    await app
        .read(workoutPerformanceRepositoryProvider)
        .recordSetActuals(
          setPerformanceId: setId,
          actualRepetitions: 12,
          actualWeightKg: 45,
          now: fixedNow,
        );
    syncApi.scriptedResults[sessionId] = 'VERSION_CONFLICT';
    syncApi.serverVersions[sessionId] = 9;
    final conflictRun = await app.read(syncEngineProvider).pushPending();
    expect((conflictRun as SyncRunCompleted).conflicts, equals(1));
    expect(
      (await row(
        database,
        'SELECT sync_state FROM local_workout_sessions WHERE id = ?',
        [Variable.withString(sessionId)],
      ))['sync_state'],
      equals('CONFLICT'),
    );

    // ---- 8. USE_LOCAL → potvrzený re-push s novým klíčem → SYNCED. ----
    final items = await app.read(unresolvedSyncItemsProvider.future);
    final conflictItem = items.singleWhere((i) => i.entityId == sessionId);
    expect(conflictItem.isConflict, isTrue);
    await app.read(conflictResolutionServiceProvider).useLocal(conflictItem);
    syncApi.scriptedResults.remove(sessionId);
    final resync = await app.read(syncEngineProvider).pushPending();
    expect((resync as SyncRunCompleted).conflicts, equals(0));
    final retried = syncApi.pushedBatches.last.singleWhere(
      (op) => op.entityId == sessionId,
    );
    expect(retried.idempotencyKey, contains('-r1'));
    expect(retried.expectedServerVersion, equals(9));
    expect(
      (await row(
        database,
        'SELECT sync_state FROM local_workout_sessions WHERE id = ?',
        [Variable.withString(sessionId)],
      ))['sync_state'],
      equals('SYNCED'),
    );

    // ---- 9. Serverová revokace → bezpečné odhlášení bez ztráty dat. ----
    authApi.revokeSession(authSessionId);
    expect(
      await app.read(authSessionManagerProvider.notifier).verifySession(),
      equals(SessionVerification.signedOutRevoked),
    );
    expect(
      app.read(authSessionManagerProvider).value,
      isA<AnonymousAuthState>(),
    );
    expect(storage.stored, isNull);
    // Lokální data nedotčená (RVC-008/TSS-010): session, výkon i vlastnictví.
    final survivedSession = await row(
      database,
      'SELECT owner_id, sync_state FROM local_workout_sessions WHERE id = ?',
      [Variable.withString(sessionId)],
    );
    expect(survivedSession['owner_id'], equals('account-1'));
    final survivedSet = await row(
      database,
      'SELECT actual_repetitions, actual_weight_kg '
      'FROM local_set_performances WHERE id = ?',
      [Variable.withString(setId)],
    );
    expect(survivedSet['actual_repetitions'], equals(12));

    // ---- 10. Re-login: data dál patří účtu, nic se neduplikuje. ----
    final reLogin = await app
        .read(authSessionManagerProvider.notifier)
        .signIn(email: 'e2e@example.com', password: 'password-123');
    expect(reLogin, isA<AuthFlowSuccess>());
    expect(authApi.accountCount, equals(1));
    final afterRelogin = await app.read(syncEngineProvider).pushPending();
    expect((afterRelogin as SyncRunCompleted).synced, equals(0));
    expect(
      (await row(
        database,
        'SELECT owner_id FROM local_workout_sessions WHERE id = ?',
        [Variable.withString(sessionId)],
      ))['owner_id'],
      equals('account-1'),
    );
  });
}
