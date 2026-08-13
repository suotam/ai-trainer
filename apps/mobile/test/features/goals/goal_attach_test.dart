import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/goals/application/goals_providers.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-02 attach testy (C16 R3M-006, C18 §8): anonymní cíle se připojují
/// k účtu bezpodmínečně (GLC-010); cíl s vazbou na kolizí-anonymní sport
/// se připojí a vazba zůstává čitelná (GLC-008).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 20);

  ProviderContainer createContainer({
    required AppDatabase database,
    required InMemorySecureSessionStorage storage,
    required FakeAuthApiClient authApi,
  }) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(storage),
        authApiClientProvider.overrideWithValue(authApi),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-goals'),
        ),
        syncApiClientProvider.overrideWithValue(FakeSyncApiClient()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('anonymní cíle se registrací připojí k účtu bezpodmínečně — i cíl '
      's vazbou na kolizí-anonymní sport', () async {
    final database = createTestDatabase();
    final storage = InMemorySecureSessionStorage();
    final authApi = FakeAuthApiClient();
    final container = createContainer(
      database: database,
      storage: storage,
      authApi: authApi,
    );
    final sports = container.read(userSportRepositoryProvider);
    final goals = container.read(goalRepositoryProvider);
    final manager = container.read(authSessionManagerProvider.notifier);
    await container.read(authSessionManagerProvider.future);

    // Účet má FOOTBALL (pro pozdější kolizi anonymního FOOTBALL sportu).
    await manager.registerAccount(
      email: 'goals@example.com',
      password: 'password-123',
    );
    await sports.saveSport(
      const UserSportInput(
        sportCode: 'FOOTBALL',
        role: 'PRIMARY',
        priority: 'HIGH',
      ),
      newId: 'us-acc-football',
      now: fixedNow,
    );
    await manager.signOut();

    // Anonymně: kolizní FOOTBALL sport + cíl na něj navázaný + obecný cíl.
    await sports.saveSport(
      const UserSportInput(
        sportCode: 'FOOTBALL',
        role: 'RECREATIONAL',
        priority: 'LOW',
      ),
      newId: 'us-anon-football',
      now: fixedNow,
    );
    expect(
      await goals.saveGoal(
        const GoalInput(
          title: 'Lepší kondice na fotbal',
          goalType: 'ENDURANCE',
          priority: 'PRIMARY',
          userSportId: 'us-anon-football',
        ),
        newId: 'g-linked',
        now: fixedNow,
      ),
      isA<GoalSaved>(),
    );
    expect(
      await goals.saveGoal(
        const GoalInput(
          title: 'Trénovat 3× týdně',
          goalType: 'HABIT',
          priority: 'MAINTENANCE',
        ),
        newId: 'g-general',
        now: fixedNow,
      ),
      isA<GoalSaved>(),
    );

    // Přihlášení → attach.
    final signIn = await manager.signIn(
      email: 'goals@example.com',
      password: 'password-123',
    );
    expect(signIn, isA<AuthFlowSuccess>());

    Future<String?> ownerOf(String table, String id) async =>
        (await database
                    .customSelect(
                      'SELECT owner_id FROM $table WHERE id = ?',
                      variables: [Variable.withString(id)],
                    )
                    .getSingle())
                .data['owner_id']
            as String?;

    // Cíle se připojily bezpodmínečně (GLC-010).
    expect(await ownerOf('local_goals', 'g-linked'), 'account-1');
    expect(await ownerOf('local_goals', 'g-general'), 'account-1');
    // Kolizní sport zůstal anonymní (C17 §8), ale vazba cíle je čitelná
    // (GLC-008 — device-local reference bez owner filtru).
    expect(
      await ownerOf('local_user_sports', 'us-anon-football'),
      'local-anonymous',
    );
    final accountGoals = await goals.goalsForCurrentOwner();
    expect(accountGoals, hasLength(2));
    expect(
      accountGoals.singleWhere((g) => g.id == 'g-linked').userSportId,
      'us-anon-football',
    );
  });
}
