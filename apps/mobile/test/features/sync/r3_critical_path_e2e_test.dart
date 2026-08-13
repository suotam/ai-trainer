import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/application/activity_providers.dart';
import 'package:ai_trainer_mobile/features/activity/domain/manual_activity.dart';
import 'package:ai_trainer_mobile/features/auth/application/auth_providers.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_results.dart';
import 'package:ai_trainer_mobile/features/availability/application/availability_providers.dart';
import 'package:ai_trainer_mobile/features/device/application/device_registrar.dart';
import 'package:ai_trainer_mobile/features/goals/application/goals_providers.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/plan/domain/calendar_operations.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sports/application/sports_profile_providers.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/sync/application/local_sync_providers.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_auth_boundaries.dart';
import '../../support/fake_device_profile_boundaries.dart';
import '../../support/workout_test_scope.dart';

/// R3-08 – kritický end-to-end důkaz hlavní hodnoty R3 (VSP R3 §11/§13).
///
/// Jeden deterministický scénář nad skutečnou SQLite (reálné repository,
/// attach, engine; fake jen síť/storage/clock):
/// 1. anonymní strukturovaný profil (sport, cíl, dostupnost, vybavení,
///    omezení),
/// 2. ruční plán → workout s cvikem na dnešek,
/// 3. interní kalendář = Today read model → celý R1 flow (start → zápis
///    → completion → historie),
/// 4. kalendářní operace: přesun + zrušení s append-only evidencí,
/// 5. ruční aktivita → deterministické statistiky (bez dvojího započtení),
/// 6. registrace → attach všech R3 dat k účtu,
/// 7. push: R1 i R3 typy pod client-generated ID → SYNCED → replay no-op.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 17);

  test('kritická R3 cesta: profil → plán → R1 flow → operace → aktivita → '
      'statistiky → attach → push → replay', () async {
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
          FakeInstallationIdentity('installation-r3-e2e'),
        ),
        syncApiClientProvider.overrideWithValue(syncApi),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    final today = formatLocalDate(fixedNow);
    var seq = 0;
    String nextId() => 'e2e-${seq++}';

    // ---- 1. Anonymní strukturovaný profil (R3-01..03). ----
    await container
        .read(userSportRepositoryProvider)
        .saveSport(
          const UserSportInput(
            sportCode: 'CLIMBING',
            role: 'PRIMARY',
            priority: 'HIGH',
            experienceLevel: 'INTERMEDIATE',
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
    final availability = container.read(availabilityProfileRepositoryProvider);
    await availability.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      budgetMinutes: 90,
      newId: 'av1',
      now: fixedNow,
    );
    await availability.addEquipment(
      equipmentCode: 'BARBELL',
      newId: 'eq1',
      now: fixedNow,
    );
    await availability.addConstraint(
      title: 'Bolavé rameno — bez tlaků nad hlavu',
      newId: 'c1',
      now: fixedNow,
    );

    // ---- 2. Ruční plán a workouty (R3-04). ----
    final plans = container.read(trainingPlanRepositoryProvider);
    await plans.createPlan(title: 'Můj plán', newId: 'p1', now: fixedNow);
    Future<String> addWorkout(String title, String date) async =>
        ((await plans.addWorkout(
                  'p1',
                  PlannedWorkoutInput(
                    title: title,
                    workoutType: 'STRENGTH',
                    scheduledLocalDate: date,
                    exercises: const [
                      PlannedExerciseInput(
                        title: 'Dřep',
                        sets: 2,
                        repetitions: 5,
                        weightKg: 80,
                      ),
                    ],
                  ),
                  newId: nextId,
                  now: fixedNow,
                ))
                as PlanWriteSaved)
            .id;
    final todayWorkout = await addWorkout('Dnešní silový', today);
    final moveWorkout = await addWorkout('K přesunu', '2026-08-20');
    final cancelWorkout = await addWorkout('Ke zrušení', '2026-08-21');

    // ---- 3. Interní kalendář = R1 read model → celý R1 flow (MPC-006). ----
    final inToday = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(today);
    expect(inToday.map((w) => w.id), contains(todayWorkout));
    final started = await container
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: todayWorkout,
          newSessionId: 'ses-e2e-1',
          now: fixedNow,
        );
    expect(started, isA<SessionCreated>());
    // Přímá inicializace performance vrstvy (bez sessionTrackerProvider,
    // který by spustil bootstrap demo seedu — R3 E2E běží bez seedu).
    final performance = container.read(workoutPerformanceRepositoryProvider);
    await performance.initializePerformances(
      sessionId: 'ses-e2e-1',
      now: fixedNow,
    );
    final tracker = await performance.loadTracker('ses-e2e-1');
    await performance.recordSetActuals(
      setPerformanceId: tracker!.exercises.single.sets.first.setPerformanceId,
      actualRepetitions: 5,
      actualWeightKg: 82.5,
      now: fixedNow,
    );
    expect(
      await container.read(completeWorkoutProvider)(sessionId: 'ses-e2e-1'),
      isA<WorkoutCompleted>(),
    );
    final history = await container
        .read(workoutHistoryRepositoryProvider)
        .completedWorkouts();
    expect(history.single.title, 'Dnešní silový');

    // ---- 4. Kalendářní operace s evidencí (R3-05). ----
    final ops = container.read(calendarOperationsRepositoryProvider);
    expect(
      await ops.moveWorkout(
        moveWorkout,
        '2026-08-22',
        changeId: nextId(),
        now: fixedNow,
      ),
      isA<CalendarOpSaved>(),
    );
    expect(
      await ops.cancelWorkout(cancelWorkout, changeId: nextId(), now: fixedNow),
      isA<CalendarOpSaved>(),
    );
    expect(
      (await ops.changesForInstance(moveWorkout)).single.toLocalDate,
      '2026-08-22',
    );
    // Dokončený workout je fakt — operace typovaně odmítnuta (CAL-002).
    expect(
      await ops.cancelWorkout(todayWorkout, changeId: nextId(), now: fixedNow),
      isA<CalendarOpNotAllowed>(),
    );

    // ---- 5. Ruční aktivita a statistiky (R3-06). ----
    final activities = container.read(activityRepositoryProvider);
    await activities.saveActivity(
      const ManualActivityInput(
        title: 'Večerní běh',
        localDate: '2026-08-14',
        durationMinutes: 40,
        userSportId: 'us1',
      ),
      newId: 'a1',
      now: fixedNow,
    );
    // Vázaná aktivita se nepočítá vedle summary (PST-006).
    await activities.saveActivity(
      ManualActivityInput(
        title: 'Dokumentace tréninku',
        localDate: today,
        durationMinutes: 50,
        workoutInstanceId: todayWorkout,
      ),
      newId: 'a2',
      now: fixedNow,
    );
    final stats = await activities.statisticsForPeriod(
      fromLocalDate: '2026-08-14',
      toLocalDate: '2026-08-22',
    );
    expect(stats.plannedCount, 2); // dnešní + přesunutý; zrušený není plán
    expect(stats.completedCount, 1);
    expect(stats.manualActivityCount, 1);
    expect(stats.manualMinutes, 40);

    // ---- 6. Registrace → attach všech R3 dat (C15 + R3 rozšíření). ----
    await container.read(authSessionManagerProvider.future);
    expect(
      await container
          .read(authSessionManagerProvider.notifier)
          .registerAccount(email: 'r3@example.com', password: 'password-123'),
      isA<AuthFlowSuccess>(),
    );
    Future<String?> ownerOf(String table, String id) async =>
        (await database
                    .customSelect(
                      'SELECT owner_id FROM $table WHERE id = ?',
                      variables: [Variable.withString(id)],
                    )
                    .getSingle())
                .data['owner_id']
            as String?;
    for (final probe in [
      ('local_user_sports', 'us1'),
      ('local_goals', 'g1'),
      ('local_availability_rules', 'av1'),
      ('local_equipment_items', 'eq1'),
      ('local_constraints', 'c1'),
      ('local_training_plans', 'p1'),
      ('local_activities', 'a1'),
      ('local_workout_instances', moveWorkout),
    ]) {
      expect(
        await ownerOf(probe.$1, probe.$2),
        'account-1',
        reason: '${probe.$1}/${probe.$2} má být připojeno k účtu',
      );
    }

    // ---- 7. Push R1 + R3 typů → SYNCED → replay no-op (C24). ----
    final push = await container.read(syncEngineProvider).pushPending();
    expect(push, isA<SyncRunCompleted>());
    expect((push as SyncRunCompleted).conflicts + push.rejected, 0);
    final types = syncApi.pushedBatches.single
        .map((op) => op.entityType)
        .toSet();
    expect(
      types,
      containsAll([
        'WORKOUT_INSTANCE',
        'WORKOUT_SESSION',
        'ACTIVITY_SUMMARY',
        'USER_SPORT',
        'GOAL',
        'AVAILABILITY_RULE',
        'EQUIPMENT_ITEM',
        'CONSTRAINT_ITEM',
        'TRAINING_PLAN',
        'CALENDAR_CHANGE',
        'MANUAL_ACTIVITY',
      ]),
    );
    final replay = await container.read(syncEngineProvider).pushPending();
    expect((replay as SyncRunCompleted).synced, 0);
    expect(syncApi.pushedBatches, hasLength(1));
  });
}
