import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/workouts/application/quick_complete_workout.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_completion_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

class _Ids implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'qc-id-${_next++}';
}

/// R7-05 testy rychlého dokončení (C50 §3): výhradně C22 operace
/// (CQC-003), žádné vymyšlené metriky (CQC-004), typované výsledky a
/// idempotence (CQC-005), převzetí aktivní session téže instance
/// (CQC-006), blokace cizí session.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 15, 12);

  Future<String> seedWorkout(db, {String title = 'Silový A'}) async {
    final plans = DriftTrainingPlanRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    var seq = 0;
    final added =
        await plans.addWorkout(
              'p1',
              PlannedWorkoutInput(
                title: title,
                workoutType: 'STRENGTH',
                scheduledLocalDate: formatLocalDate(now),
                exercises: const [
                  PlannedExerciseInput(title: 'Dřep', sets: 2, repetitions: 5),
                ],
              ),
              newId: () => '$title-${seq++}',
              now: now,
            )
            as PlanWriteSaved;
    return added.id;
  }

  test('quick-complete: instance COMPLETED, summary bez měřených kroků a '
      'času, žádné performance řádky (CQC-003/004)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final instanceId = await seedWorkout(db);
    final useCase = QuickCompleteWorkout(
      DriftWorkoutSessionRepository(db),
      DriftWorkoutCompletionRepository(db, _Ids()),
    );

    final result = await useCase(instanceId, newSessionId: 'qs-1', now: now);
    expect(result, isA<QuickCompleted>());

    Future<int> count(String sql) async =>
        (await db.customSelect(sql).getSingle()).data.values.first as int;
    final instance = await db
        .customSelect(
          "SELECT status FROM local_workout_instances WHERE id = '$instanceId'",
        )
        .getSingle();
    // C22 poctivě: bez měřených kroků = PARTIALLY_COMPLETED (CQC-004).
    expect(instance.data['status'], 'PARTIALLY_COMPLETED');
    // Poctivá zkrácená evidence: 0 měřených kroků, 0 s, žádné performance.
    final summary = await db
        .customSelect(
          'SELECT completed_step_count, total_step_count, '
          'active_duration_seconds FROM local_activity_summaries',
        )
        .getSingle();
    expect(summary.data['completed_step_count'], 0);
    expect(summary.data['active_duration_seconds'], 0);
    expect(await count('SELECT COUNT(*) AS c FROM local_step_performances'), 0);
    expect(await count('SELECT COUNT(*) AS c FROM local_set_performances'), 0);
    // Historie čte dokončení (CQC-007).
    final history = await DriftWorkoutHistoryRepository(db).completedWorkouts();
    expect(history.single.title, 'Silový A');
  });

  test('aktivní session téže instance se převezme a dokončí — nikdy druhá '
      'session (CQC-006); cizí aktivní session blokuje (typované)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final first = await seedWorkout(db, title: 'A');
    final second = await seedWorkout2(db);
    final sessions = DriftWorkoutSessionRepository(db);
    final useCase = QuickCompleteWorkout(
      sessions,
      DriftWorkoutCompletionRepository(db, _Ids()),
    );

    // Aktivní session instance A.
    await sessions.startSession(
      workoutInstanceId: first,
      newSessionId: 'live-1',
      now: now,
    );
    // Quick-complete jiné instance je blokován (R1 zákon jedné session).
    expect(
      await useCase(second, newSessionId: 'qs-2', now: now),
      isA<QuickBlockedByOtherSession>(),
    );
    // Quick-complete téže instance převezme existující session.
    final taken = await useCase(first, newSessionId: 'qs-3', now: now);
    expect(taken, isA<QuickCompleted>());
    expect((taken as QuickCompleted).sessionId, 'live-1');
    final sessionCount = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
        .getSingle();
    expect(sessionCount.data['c'], 1);

    // Neexistující instance typovaně (CQC-005).
    expect(
      await useCase('missing', newSessionId: 'qs-4', now: now),
      isA<QuickWorkoutNotFound>(),
    );
  });
}

/// Druhý workout v samostatném plánu (jeden ACTIVE plán → přidá do téhož).
Future<String> seedWorkout2(db) async {
  final plans = DriftTrainingPlanRepository(db);
  var seq = 0;
  final added =
      await plans.addWorkout(
            'p1',
            PlannedWorkoutInput(
              title: 'B',
              workoutType: 'MOBILITY',
              scheduledLocalDate: '2026-08-16',
              exercises: const [
                PlannedExerciseInput(title: 'Kočka', sets: 1, repetitions: 8),
              ],
            ),
            newId: () => 'b-${seq++}',
            now: DateTime.utc(2026, 8, 15, 12),
          )
          as PlanWriteSaved;
  return added.id;
}
