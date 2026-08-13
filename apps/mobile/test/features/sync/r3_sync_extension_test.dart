import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/application/activity_providers.dart';
import 'package:ai_trainer_mobile/features/activity/domain/manual_activity.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/availability/application/availability_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/goals/application/goals_providers.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-07 mobilní sync rozšíření (C24): engine sbírá a pushuje R3 roots
/// existujícím mechanismem — R3 typy za R1 šesticí (SXC-006), potvrzení
/// po commitu (SXC-007), replay bez duplicit, editace → DIRTY → UPDATE.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 16);

  test('R3 entity se sbírají a pushují: SYNCED po commitu, replay no-op, '
      'editace → DIRTY → další push', () async {
    final database = createTestDatabase();
    final syncApi = FakeSyncApiClient();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
        secureSessionStorageProvider.overrideWithValue(
          InMemorySecureSessionStorage(),
        ),
        authApiClientProvider.overrideWithValue(FakeAuthApiClient()),
        installationIdentityProvider.overrideWithValue(
          FakeInstallationIdentity('installation-r3-sync'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    await container.read(authSessionManagerProvider.future);
    await container
        .read(authSessionManagerProvider.notifier)
        .registerAccount(email: 'r3sync@example.com', password: 'password-123');

    // Data všech R3 oblastí pod účtem.
    await container
        .read(userSportRepositoryProvider)
        .saveSport(
          const UserSportInput(
            sportCode: 'CLIMBING',
            role: 'PRIMARY',
            priority: 'HIGH',
          ),
          newId: 'us1',
          now: fixedNow,
        );
    await container
        .read(goalRepositoryProvider)
        .saveGoal(
          const GoalInput(
            title: '7a na laně',
            goalType: 'PERFORMANCE',
            priority: 'PRIMARY',
            userSportId: 'us1',
          ),
          newId: 'g1',
          now: fixedNow,
        );
    await container
        .read(availabilityProfileRepositoryProvider)
        .upsertDay(
          dayOfWeek: 'MON',
          level: 'AVAILABLE',
          budgetMinutes: 60,
          newId: 'av1',
          now: fixedNow,
        );
    await container
        .read(availabilityProfileRepositoryProvider)
        .addEquipment(equipmentCode: 'BARBELL', newId: 'eq1', now: fixedNow);
    await container
        .read(availabilityProfileRepositoryProvider)
        .addConstraint(title: 'Bolavé rameno', newId: 'c1', now: fixedNow);
    await container
        .read(trainingPlanRepositoryProvider)
        .createPlan(title: 'Plán', newId: 'p1', now: fixedNow);
    await container
        .read(activityRepositoryProvider)
        .saveActivity(
          const ManualActivityInput(title: 'Běh', localDate: '2026-08-14'),
          newId: 'a1',
          now: fixedNow,
        );

    final result = await container.read(syncEngineProvider).pushPending();
    expect(result, isA<SyncRunCompleted>());
    expect((result as SyncRunCompleted).conflicts + result.rejected, 0);

    final batch = syncApi.pushedBatches.single;
    final types = batch.map((op) => op.entityType).toList();
    expect(
      types,
      containsAll([
        'USER_SPORT',
        'GOAL',
        'AVAILABILITY_RULE',
        'EQUIPMENT_ITEM',
        'CONSTRAINT_ITEM',
        'TRAINING_PLAN',
        'MANUAL_ACTIVITY',
      ]),
    );
    // Payload nese device-local referenci (SXC-003).
    final goalOp = batch.singleWhere((op) => op.entityType == 'GOAL');
    expect(goalOp.payload['userSportId'], 'us1');

    // Potvrzení po commitu (SXC-007): roots jsou SYNCED.
    for (final probe in [
      ('local_user_sports', 'us1'),
      ('local_goals', 'g1'),
      ('local_availability_rules', 'av1'),
      ('local_training_plans', 'p1'),
      ('local_activities', 'a1'),
    ]) {
      final row = await database
          .customSelect(
            'SELECT sync_state FROM ${probe.$1} WHERE id = ?',
            variables: [Variable.withString(probe.$2)],
          )
          .getSingle();
      expect(
        row.data['sync_state'],
        'SYNCED',
        reason: '${probe.$1} má být SYNCED',
      );
    }

    // Replay bez lokálních změn nic neposílá (SXC-005).
    final replay = await container.read(syncEngineProvider).pushPending();
    expect((replay as SyncRunCompleted).synced, 0);
    expect(syncApi.pushedBatches, hasLength(1));

    // Editace → DIRTY → UPDATE s uloženou serverovou verzí.
    await container
        .read(goalRepositoryProvider)
        .saveGoal(
          const GoalInput(
            title: '7a+ na laně',
            goalType: 'PERFORMANCE',
            priority: 'PRIMARY',
            userSportId: 'us1',
          ),
          existingId: 'g1',
          newId: 'unused',
          now: fixedNow,
        );
    final third = await container.read(syncEngineProvider).pushPending();
    expect((third as SyncRunCompleted).synced, 1);
    final updateOp = syncApi.pushedBatches.last.single;
    expect(updateOp.entityType, 'GOAL');
    expect(updateOp.operationType, 'UPDATE_ENTITY');
    expect(updateOp.payload['title'], '7a+ na laně');
  });
}
