import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-04 attach testy (C15 §4 rozšíření, C20 §7): netknutá anonymní
/// USER_PLAN instance se připojí (MPC-009); kolizní ACTIVE plán zůstává
/// anonymní, jeho instance se přesto připojí (MPC-010); seed nadále
/// anonymní.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 11);

  test('attach: USER_PLAN instance bez session se připojí; kolizní ACTIVE '
      'plán zůstává anonymní; seed nedotčen', () async {
    final database = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(
          InMemorySecureSessionStorage(),
        ),
        authApiClientProvider.overrideWithValue(FakeAuthApiClient()),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-plan'),
        ),
        syncApiClientProvider.overrideWithValue(FakeSyncApiClient()),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    final repo = container.read(trainingPlanRepositoryProvider);
    final manager = container.read(authSessionManagerProvider.notifier);
    await container.read(authSessionManagerProvider.future);

    // Účet má ACTIVE plán (pro kolizi).
    await manager.registerAccount(
      email: 'plan@example.com',
      password: 'password-123',
    );
    await repo.createPlan(title: 'Účet plán', newId: 'p-acc', now: fixedNow);
    await manager.signOut();

    // Anonymně: ACTIVE plán + netknutý workout (bez session).
    await repo.createPlan(title: 'Anonym plán', newId: 'p-anon', now: fixedNow);
    var seq = 0;
    final created = await repo.addWorkout(
      'p-anon',
      const PlannedWorkoutInput(
        title: 'Anonymní workout',
        workoutType: 'GENERAL',
        scheduledLocalDate: '2026-08-21',
      ),
      newId: () => 'aw-${seq++}',
      now: fixedNow,
    );
    final instanceId = (created as PlanWriteSaved).id;

    final signIn = await manager.signIn(
      email: 'plan@example.com',
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

    // USER_PLAN instance bez session se připojila (MPC-009).
    expect(await ownerOf('local_workout_instances', instanceId), 'account-1');
    // Kolizní ACTIVE plán zůstal anonymní (MPC-010) — device-local
    // reference instance→plán zůstává čitelná.
    expect(await ownerOf('local_training_plans', 'p-anon'), 'local-anonymous');
    // Účet drží invariant jednoho ACTIVE plánu.
    final plans = await repo.plansForCurrentOwner();
    expect(plans.where((p) => p.isActive), hasLength(1));
    expect(plans.single.id, 'p-acc');
    // Workouty anonymního plánu jsou čitelné přes plán ID (read model
    // nefiltruje vlastníka instance — instance patří účtu).
    final workouts = await repo.workoutsForPlan('p-anon');
    expect(workouts.single.instanceId, instanceId);
  });
}
