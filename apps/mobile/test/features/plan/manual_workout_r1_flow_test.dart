import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/plan/application/plan_providers.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-04 klíčový integrační důkaz (MPC-006, C20 §9.2): ručně vytvořený
/// workout je vidět v Today read modelu (interní kalendář = R1 read
/// modely) a projde beze změny celým R1 flow — start → tracker → zápis
/// výkonu → completion → historie.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 10);

  test('ruční workout → Today read model → start → zápis → completion → '
      'historie', () async {
    final database = createTestDatabase();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => fixedNow),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    final planRepo = container.read(trainingPlanRepositoryProvider);

    // 1. Ruční plán + workout na „dnešek" (bez seedu — čistá DB).
    await planRepo.createPlan(title: 'Můj plán', newId: 'p1', now: fixedNow);
    final today = formatLocalDate(fixedNow);
    var seq = 0;
    final created = await planRepo.addWorkout(
      'p1',
      PlannedWorkoutInput(
        title: 'Ruční silový',
        workoutType: 'STRENGTH',
        scheduledLocalDate: today,
        exercises: const [
          PlannedExerciseInput(
            title: 'Dřep',
            sets: 2,
            repetitions: 5,
            weightKg: 80,
          ),
        ],
      ),
      newId: () => 'mw-${seq++}',
      now: fixedNow,
    );
    final instanceId = (created as PlanWriteSaved).id;

    // 2. Interní kalendář = existující R1 read model (C20 §6).
    final todayWorkouts = await container
        .read(workoutInstanceRepositoryProvider)
        .workoutsForLocalDate(today);
    expect(todayWorkouts.map((w) => w.id), contains(instanceId));

    // 3. R1 start session beze změny (MPC-006).
    final started = await container
        .read(workoutSessionRepositoryProvider)
        .startSession(
          workoutInstanceId: instanceId,
          newSessionId: 'session-manual-1',
          now: fixedNow,
        );
    expect(started, isA<SessionCreated>());

    // 4. Tracker init + zápis výkonu na ručním cviku.
    final tracker = await container.read(
      sessionTrackerProvider('session-manual-1').future,
    );
    expect(tracker, isNotNull);
    expect(tracker!.exercises.single.title, 'Dřep');
    final setId = tracker.exercises.single.sets.first.setPerformanceId;
    await container
        .read(workoutPerformanceRepositoryProvider)
        .recordSetActuals(
          setPerformanceId: setId,
          actualRepetitions: 5,
          actualWeightKg: 82.5,
          now: fixedNow,
        );

    // 5. Completion beze změny.
    final completed = await container.read(completeWorkoutProvider)(
      sessionId: 'session-manual-1',
    );
    expect(completed, isA<WorkoutCompleted>());

    // 6. Historie obsahuje ruční workout.
    final history = await container
        .read(workoutHistoryRepositoryProvider)
        .completedWorkouts();
    expect(history.single.title, 'Ruční silový');
  });
}
