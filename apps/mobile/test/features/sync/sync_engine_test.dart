import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// SyncEngine testy (R2-05, C10/C11) nad skutečnou SQLite: offline-create →
/// later-replay, potvrzení po commitu, explicitní konflikt, restart-safe
/// pending a stabilní idempotency keys napříč běhy.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 12, 12);

  ProviderContainer createContainer({
    required InMemorySecureSessionStorage storage,
    required FakeSyncApiClient syncApi,
    required AppDatabase database,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(FakeAuthApiClient()),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-sync'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Přihlášený stav: uložená session + lokální vlastník vázaný na účet
  /// (reálná Drift vazba přes localOwnerBindingProvider).
  Future<void> signIn(ProviderContainer container) async {
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'sync@example.com', password: 'password-123');
  }

  /// Reálný lokální stav: seed → start session (stamping vlastníka je
  /// součást startSession transakce, R2-05).
  Future<String> seedAndStartWorkout(ProviderContainer container) async {
    await container.read(workoutBootstrapCompletedProvider.future);
    final instances = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(formatLocalDate(fixedNow));
    final target = instances.first;
    final result = await container
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: target.id,
          newSessionId: 'session-sync-1',
          now: fixedNow,
        );
    expect(result, isA<SessionCreated>());
    return target.id;
  }

  test('offline-create → later-replay: data vytvořená po přihlášení se '
      'idempotentně nahrají a potvrdí až po commitu', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final syncApi = FakeSyncApiClient();
    final container = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    await signIn(container);
    final instanceId = await seedAndStartWorkout(container);

    // Offline pokus: vše zůstává pending (SPC-012).
    syncApi.offline = true;
    final offline = await container.read(syncEngineProvider).pushPending();
    expect(offline, isA<SyncRunFailed>());

    // Později online: replay stejných operací.
    syncApi.offline = false;
    final result = await container.read(syncEngineProvider).pushPending();

    expect(result, isA<SyncRunCompleted>());
    final completed = result as SyncRunCompleted;
    expect(completed.synced, greaterThanOrEqualTo(2));
    expect(completed.conflicts + completed.rejected, equals(0));

    // Pořadí dle R1 hierarchie: instance před session (C10 §6).
    final batch = syncApi.pushedBatches.last;
    final instanceIndex = batch.indexWhere(
      (op) => op.entityType == 'WORKOUT_INSTANCE' && op.entityId == instanceId,
    );
    final sessionIndex = batch.indexWhere(
      (op) => op.entityType == 'WORKOUT_SESSION',
    );
    expect(instanceIndex, lessThan(sessionIndex));
    expect(
      batch[sessionIndex].payload['workoutInstanceId'],
      equals(instanceId),
    );

    // Potvrzení po commitu: sync_state = SYNCED, serverová verze uložena.
    final instanceRow = await database
        .customSelect(
          'SELECT sync_state FROM local_workout_instances WHERE id = ?',
          variables: [Variable.withString(instanceId)],
        )
        .getSingle();
    expect(instanceRow.data['sync_state'], equals('SYNCED'));

    // Druhý běh bez lokálních změn nic neposílá (idempotentní no-op).
    final second = await container.read(syncEngineProvider).pushPending();
    expect((second as SyncRunCompleted).synced, equals(0));
  });

  test('idempotency key je stabilní přes „restart" (nový container nad '
      'touž DB) — replay bez duplicit (IDC-001)', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final syncApi = FakeSyncApiClient()..offline = true;
    final first = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    await signIn(first);
    await seedAndStartWorkout(first);
    await first.read(syncEngineProvider).pushPending();
    final keysBefore = (await database.select(database.localOutbox).get())
        .map((row) => row.idempotencyKey)
        .toSet();
    expect(keysBefore, isNotEmpty);

    // „Restart": nový container nad stejnou DB i storage.
    final second = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    syncApi.offline = false;
    final result = await second.read(syncEngineProvider).pushPending();

    expect(result, isA<SyncRunCompleted>());
    final keysAfter = (await database.select(database.localOutbox).get())
        .map((row) => row.idempotencyKey)
        .toSet();
    expect(keysAfter, equals(keysBefore));
  });

  test(
    'VERSION_CONFLICT je explicitní stav — entita není synced (SPC-006)',
    () async {
      final database = createTestDatabase();
      final storage = InMemorySecureSessionStorage();
      final syncApi = FakeSyncApiClient();
      final container = createContainer(
        storage: storage,
        syncApi: syncApi,
        database: database,
      );
      await signIn(container);
      final instanceId = await seedAndStartWorkout(container);
      syncApi.scriptedResults[instanceId] = 'VERSION_CONFLICT';
      syncApi.serverVersions[instanceId] = 5;

      final result = await container.read(syncEngineProvider).pushPending();

      final completed = result as SyncRunCompleted;
      expect(completed.conflicts, equals(1));
      final row = await database
          .customSelect(
            'SELECT sync_state FROM local_workout_instances WHERE id = ?',
            variables: [Variable.withString(instanceId)],
          )
          .getSingle();
      expect(row.data['sync_state'], equals('CONFLICT'));
    },
  );

  test('anonymní stav se nesynchronizuje (SPC-001) a anonymní data '
      'nejsou v batch', () async {
    final database = createTestDatabase();
    final syncApi = FakeSyncApiClient();
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      syncApi: syncApi,
      database: database,
    );
    // Seed bez přihlášení — demo data zůstávají anonymní.
    await container.read(workoutBootstrapCompletedProvider.future);

    final result = await container.read(syncEngineProvider).pushPending();

    expect(result, isA<SyncSkippedAnonymous>());
    expect(syncApi.pushedBatches, isEmpty);
  });
}
