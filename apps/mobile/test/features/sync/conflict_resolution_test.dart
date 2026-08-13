import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sync/application/conflict_resolution_service.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// Conflict/rejection resolution testy (R2-06, C12) nad skutečnou SQLite:
/// USE_LOCAL → potvrzený re-push s novým klíčem a verzí z konfliktu;
/// CANCEL → LOCAL_ONLY bez dotyku dat; restart-safe stavy.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 12);

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
          FakeInstallationIdentity('installation-conflict'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<String> signInSeedAndStart(ProviderContainer container) async {
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'res@example.com', password: 'password-123');
    await container.read(workoutBootstrapCompletedProvider.future);
    final instances = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(formatLocalDate(fixedNow));
    final target = instances.first;
    await container
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: target.id,
          newSessionId: 'session-res-1',
          now: fixedNow,
        );
    return target.id;
  }

  Future<String?> instanceSyncState(AppDatabase db, String id) async =>
      (await db
                  .customSelect(
                    'SELECT sync_state FROM local_workout_instances WHERE id = ?',
                    variables: [Variable.withString(id)],
                  )
                  .getSingle())
              .data['sync_state']
          as String?;

  test('USE_LOCAL: potvrzený re-push s novým klíčem a verzí z konfliktu → '
      'SYNCED (CRC-004/005)', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final syncApi = FakeSyncApiClient();
    final container = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    final instanceId = await signInSeedAndStart(container);
    syncApi.scriptedResults[instanceId] = 'VERSION_CONFLICT';
    syncApi.serverVersions[instanceId] = 7;

    final first = await container.read(syncEngineProvider).pushPending();
    expect((first as SyncRunCompleted).conflicts, equals(1));
    expect(await instanceSyncState(database, instanceId), equals('CONFLICT'));

    final items = await container.read(unresolvedSyncItemsProvider.future);
    final conflictItem = items.singleWhere((i) => i.entityId == instanceId);
    expect(conflictItem.isConflict, isTrue);
    // Lidský popis, ne technické ID (CRC-011).
    expect(conflictItem.title, isNot(equals(instanceId)));

    await container
        .read(conflictResolutionServiceProvider)
        .useLocal(conflictItem);
    expect(await instanceSyncState(database, instanceId), equals('DIRTY'));

    // Server po rozhodnutí přijme (konflikt už není skriptovaný).
    syncApi.scriptedResults.remove(instanceId);
    final second = await container.read(syncEngineProvider).pushPending();

    expect((second as SyncRunCompleted).conflicts, equals(0));
    expect(await instanceSyncState(database, instanceId), equals('SYNCED'));
    // Nová operace měla nový idempotency key (resolution-salt, CRC-005)
    // a expectedServerVersion = verze uložená z konfliktu.
    final retriedOp = syncApi.pushedBatches.last.singleWhere(
      (op) => op.entityId == instanceId,
    );
    expect(retriedOp.idempotencyKey, contains('-r1'));
    expect(retriedOp.expectedServerVersion, equals(7));
    expect(retriedOp.operationType, equals('UPDATE_ENTITY'));
    // Položka je uzavřená.
    container.invalidate(unresolvedSyncItemsProvider);
    expect(await container.read(unresolvedSyncItemsProvider.future), isEmpty);
  });

  test('CANCEL_LOCAL_CHANGE: entita je LOCAL_ONLY, data nedotčená, položka '
      'uzavřená (CRC-006/007)', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final syncApi = FakeSyncApiClient();
    final container = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    final instanceId = await signInSeedAndStart(container);
    syncApi.scriptedResults[instanceId] = 'VERSION_CONFLICT';
    syncApi.serverVersions[instanceId] = 3;
    await container.read(syncEngineProvider).pushPending();

    final titleBefore =
        (await database
                .customSelect(
                  'SELECT title, row_version FROM local_workout_instances '
                  'WHERE id = ?',
                  variables: [Variable.withString(instanceId)],
                )
                .getSingle())
            .data;

    final items = await container.read(unresolvedSyncItemsProvider.future);
    await container
        .read(conflictResolutionServiceProvider)
        .cancel(items.singleWhere((i) => i.entityId == instanceId));

    // Přiznaný rozdíl: LOCAL_ONLY, ne SYNCED (CRC-007).
    expect(await instanceSyncState(database, instanceId), equals('LOCAL_ONLY'));
    // Lokální data byte-po-bytu nedotčená (CRC-006).
    final after =
        (await database
                .customSelect(
                  'SELECT title, row_version FROM local_workout_instances '
                  'WHERE id = ?',
                  variables: [Variable.withString(instanceId)],
                )
                .getSingle())
            .data;
    expect(after, equals(titleBefore));
    container.invalidate(unresolvedSyncItemsProvider);
    expect(await container.read(unresolvedSyncItemsProvider.future), isEmpty);
  });

  test('rejection (BLOCKED) není konflikt — bez USE_LOCAL příznaku '
      '(CRC-008) a přežívá restart (CRC-013)', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final syncApi = FakeSyncApiClient();
    final first = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    final instanceId = await signInSeedAndStart(first);
    syncApi.scriptedResults[instanceId] = 'PERMISSION_DENIED';
    await first.read(syncEngineProvider).pushPending();

    // „Restart": nový container nad touž DB.
    final second = createContainer(
      storage: storage,
      syncApi: syncApi,
      database: database,
    );
    final items = await second.read(unresolvedSyncItemsProvider.future);
    final rejected = items.singleWhere((i) => i.entityId == instanceId);
    expect(rejected.isConflict, isFalse);

    await second.read(conflictResolutionServiceProvider).cancel(rejected);
    second.invalidate(unresolvedSyncItemsProvider);
    expect(await second.read(unresolvedSyncItemsProvider.future), isEmpty);
  });
}
