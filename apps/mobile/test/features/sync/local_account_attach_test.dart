import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_session_state.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_bootstrap.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R2-07 attach testy (C15) nad skutečnou SQLite s reálným Drift attach:
/// anonymní trénink → registrace → automatický attach → push pod týmž ID;
/// seed exclusion, idempotence, byte-po-bytu zachování dat, druhý účet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 14);

  ProviderContainer createContainer({
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient authApi,
    required FakeSyncApiClient syncApi,
    required AppDatabase database,
  }) {
    // Reálné Drift boundary pro owner binding i attach — testuje se
    // skutečné R2-07 chování, ne fake.
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(authApi),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-attach'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Anonymní trénink: seed → start session (bez přihlášení).
  Future<String> anonymousTraining(ProviderContainer container) async {
    await container.read(workoutBootstrapCompletedProvider.future);
    final instances = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(formatLocalDate(fixedNow));
    final target = instances.first;
    await container
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: target.id,
          newSessionId: 'session-anon-1',
          now: fixedNow,
        );
    return target.id;
  }

  Future<Map<String, Object?>> instanceRow(AppDatabase db, String id) async =>
      (await db
              .customSelect(
                'SELECT * FROM local_workout_instances WHERE id = ?',
                variables: [Variable.withString(id)],
              )
              .getSingle())
          .data;

  test('registrace po anonymním tréninku připojí uživatelská data k účtu '
      '(LAM-002/004/008), seed zůstává anonymní (LAM-006)', () async {
    final database = createTestDatabase();
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      syncApi: FakeSyncApiClient(),
      database: database,
    );
    final touchedInstanceId = await anonymousTraining(container);
    final rowBefore = await instanceRow(database, touchedInstanceId);

    // Registrace → binding + automatický attach (C15 §6).
    await container.read(authSessionManagerProvider.future);
    final result = await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'attach@example.com', password: 'password-123');
    expect(result, isA<AuthFlowSuccess>());

    // Dotčená instance + session patří účtu; ostatní seed zůstává anonymní.
    final rowAfter = await instanceRow(database, touchedInstanceId);
    expect(rowAfter['owner_id'], equals('account-1'));
    // Byte-po-bytu: kromě owner_id se nezměnilo nic (LAM-004).
    final before = Map.of(rowBefore)..remove('owner_id');
    final after = Map.of(rowAfter)..remove('owner_id');
    expect(after, equals(before));

    final sessionOwner =
        (await database
                .customSelect(
                  'SELECT owner_id FROM local_workout_sessions WHERE id = ?',
                  variables: [Variable.withString('session-anon-1')],
                )
                .getSingle())
            .data['owner_id'];
    expect(sessionOwner, equals('account-1'));

    // Čistý seed (bez session, bez started_session_id) zůstává anonymní.
    final anonymousSeedCount =
        (await database
                .customSelect(
                  'SELECT COUNT(*) AS cnt FROM local_workout_instances '
                  "WHERE owner_id = 'local-anonymous' "
                  'AND started_session_id IS NULL',
                )
                .getSingle())
            .data['cnt'];
    expect(anonymousSeedCount, greaterThan(0));

    // Idempotence (LAM-002): druhý attach je no-op.
    await container
        .read(localAccountAttachProvider)
        .attachAnonymousData('account-1');
    expect(await instanceRow(database, touchedInstanceId), equals(rowAfter));
  });

  test('připojená data se pushnou pod týmž ID a čistý seed v batchi není '
      '(LAM-012, C15 §7)', () async {
    final database = createTestDatabase();
    final syncApi = FakeSyncApiClient();
    final container = createContainer(
      storage: InMemorySecureSessionStorage(),
      authApi: FakeAuthApiClient(),
      syncApi: syncApi,
      database: database,
    );
    final touchedInstanceId = await anonymousTraining(container);
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'push@example.com', password: 'password-123');

    final result = await container.read(syncEngineProvider).pushPending();

    expect(result, isA<SyncRunCompleted>());
    expect((result as SyncRunCompleted).synced, greaterThanOrEqualTo(2));
    final batch = syncApi.pushedBatches.single;
    // Stejná client-generated ID (LAM-004/SDM-005).
    expect(
      batch.any(
        (op) =>
            op.entityType == 'WORKOUT_INSTANCE' &&
            op.entityId == touchedInstanceId,
      ),
      isTrue,
    );
    expect(
      batch.any(
        (op) =>
            op.entityType == 'WORKOUT_SESSION' &&
            op.entityId == 'session-anon-1',
      ),
      isTrue,
    );
    // Čistý seed se nesynchronizuje (LAM-006): jediná instance v batchi
    // je ta dotčená.
    expect(
      batch.where((op) => op.entityType == 'WORKOUT_INSTANCE').length,
      equals(1),
    );
  });

  test('data účtu A se nepřipojí k účtu B (LAM-007/013)', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final authApi = FakeAuthApiClient();
    final container = createContainer(
      storage: storage,
      authApi: authApi,
      syncApi: FakeSyncApiClient(),
      database: database,
    );
    final touchedInstanceId = await anonymousTraining(container);
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'a@example.com', password: 'password-123');

    // Odhlášení nemění vlastnictví (LAM-013).
    await container.read(authSessionManagerProvider.notifier).signOut();
    expect(
      (await instanceRow(database, touchedInstanceId))['owner_id'],
      equals('account-1'),
    );

    // Účet B: attach nesmí vzít data A.
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'b@example.com', password: 'password-123');
    expect(
      container.read(authSessionManagerProvider).value,
      isA<AuthenticatedAuthState>(),
    );
    expect(
      (await instanceRow(database, touchedInstanceId))['owner_id'],
      equals('account-1'),
    );
    final sessionOwner =
        (await database
                .customSelect(
                  'SELECT owner_id FROM local_workout_sessions WHERE id = ?',
                  variables: [Variable.withString('session-anon-1')],
                )
                .getSingle())
            .data['owner_id'];
    expect(sessionOwner, equals('account-1'));
  });

  test('selhání attach neshodí přihlášení (LAM-011)', () async {
    final storage = InMemorySecureSessionStorage();
    final api = FakeAuthApiClient();
    final failingAttach = FakeLocalAccountAttach()..failAttach = true;
    final container = ProviderContainer(
      overrides: [
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(api),
        localOwnerBindingProvider.overrideWithValue(FakeLocalOwnerBinding()),
        localAccountAttachProvider.overrideWithValue(failingAttach),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authSessionManagerProvider.future);

    final result = await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'safe@example.com', password: 'password-123');

    expect(result, isA<AuthFlowSuccess>());
    expect(
      container.read(authSessionManagerProvider).value,
      isA<AuthenticatedAuthState>(),
    );
    expect(storage.stored, isNotNull);
  });
}
