import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-04 persistence testy ručního plánu (C20) nad skutečnou SQLite:
/// jeden ACTIVE plán (MPC-002), archivace jako stav (MPC-003), atomická
/// R1 struktura workoutu (MPC-004/005) a validace (MPC-011).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 9);

  var idSequence = 0;
  String nextId() => 'id-${idSequence++}';

  test('jeden ACTIVE plán na vlastníka (MPC-002): druhý odmítnut; archivace '
      'je stav a uvolní místo; reaktivace kontroluje znovu', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftTrainingPlanRepository(db);

    expect(
      await repo.createPlan(title: 'Podzim', newId: 'p1', now: now),
      isA<PlanWriteSaved>(),
    );
    expect(
      await repo.createPlan(title: 'Zima', newId: 'p2', now: now),
      isA<PlanWriteActiveConflict>(),
    );
    expect(
      await repo.createPlan(title: '  ', newId: 'p3', now: now),
      isA<PlanWriteValidationFailed>(),
    );

    // Archivace → nový ACTIVE projde; reaktivace archivovaného je konflikt.
    expect(
      await repo.setPlanStatus('p1', 'ARCHIVED', now: now),
      isA<PlanWriteSaved>(),
    );
    expect(
      await repo.createPlan(title: 'Zima', newId: 'p2', now: now),
      isA<PlanWriteSaved>(),
    );
    expect(
      await repo.setPlanStatus('p1', 'ACTIVE', now: now),
      isA<PlanWriteActiveConflict>(),
    );
    // Oba plány existují (žádné mazání, MPC-003); ACTIVE první.
    final plans = await repo.plansForCurrentOwner();
    expect(plans.map((p) => p.id), ['p2', 'p1']);
    expect(plans.first.isActive, isTrue);
  });

  test('addWorkout vytvoří atomicky plnou R1 strukturu (MPC-004/005): '
      'instance READY/USER_PLAN + MAIN sekce + kroky + sety s owner '
      'stampingem', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftTrainingPlanRepository(db);
    await repo.createPlan(title: 'Můj plán', newId: 'p1', now: now);

    final result = await repo.addWorkout(
      'p1',
      const PlannedWorkoutInput(
        title: 'Horní tělo',
        workoutType: 'STRENGTH',
        scheduledLocalDate: '2026-08-20',
        plannedDurationMinutes: 45,
        exercises: [
          PlannedExerciseInput(
            title: 'Bench press',
            sets: 3,
            repetitions: 8,
            weightKg: 60,
          ),
          PlannedExerciseInput(title: 'Přítahy', sets: 4, repetitions: 6),
        ],
      ),
      newId: nextId,
      now: now,
    );
    expect(result, isA<PlanWriteSaved>());
    final instanceId = (result as PlanWriteSaved).id;

    final instance =
        (await db
                .customSelect(
                  'SELECT status, source_type, source_reference, owner_id, '
                  'sync_state, planned_duration_seconds, revision_number '
                  'FROM local_workout_instances WHERE id = ?',
                  variables: [Variable.withString(instanceId)],
                )
                .getSingle())
            .data;
    expect(instance['status'], 'READY');
    expect(instance['source_type'], 'USER_PLAN');
    expect(instance['source_reference'], 'p1');
    expect(instance['owner_id'], 'local-anonymous');
    expect(instance['sync_state'], 'LOCAL_ONLY');
    expect(instance['planned_duration_seconds'], 2700);
    expect(instance['revision_number'], 1);

    Future<int> count(String sql) async =>
        (await db.customSelect(sql).getSingle()).data.values.first as int;
    expect(
      await count(
        'SELECT COUNT(*) FROM local_workout_sections '
        "WHERE workout_instance_id = '$instanceId'",
      ),
      1,
    );
    expect(
      await count(
        'SELECT COUNT(*) FROM local_workout_steps st '
        'JOIN local_workout_sections sec ON st.section_id = sec.id '
        "WHERE sec.workout_instance_id = '$instanceId'",
      ),
      2,
    );
    // 3 + 4 setů dle zadání.
    expect(
      await count(
        'SELECT COUNT(*) FROM local_set_plans sp '
        'JOIN local_workout_steps st ON sp.workout_step_id = st.id '
        'JOIN local_workout_sections sec ON st.section_id = sec.id '
        "WHERE sec.workout_instance_id = '$instanceId'",
      ),
      7,
    );

    // Read model plánu (MPC-013).
    final workouts = await repo.workoutsForPlan('p1');
    expect(workouts.single.title, 'Horní tělo');
    expect(workouts.single.exerciseCount, 2);
  });

  test('validace (MPC-011): nevalidní vstupy odmítnuty bez zápisu; workout '
      'jen do ACTIVE plánu; prázdný workout dovolen', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftTrainingPlanRepository(db);
    await repo.createPlan(title: 'Plán', newId: 'p1', now: now);

    PlannedWorkoutInput input({
      String title = 'W',
      String type = 'STRENGTH',
      String date = '2026-08-20',
      List<PlannedExerciseInput> exercises = const [],
    }) => PlannedWorkoutInput(
      title: title,
      workoutType: type,
      scheduledLocalDate: date,
      exercises: exercises,
    );

    expect(
      await repo.addWorkout(
        'p1',
        input(title: ' '),
        newId: nextId,
        now: now,
      ),
      isA<PlanWriteValidationFailed>(),
    );
    expect(
      await repo.addWorkout(
        'p1',
        input(type: 'CROSSFIT'),
        newId: nextId,
        now: now,
      ),
      isA<PlanWriteValidationFailed>(),
    );
    expect(
      await repo.addWorkout(
        'p1',
        input(date: '20.8.2026'),
        newId: nextId,
        now: now,
      ),
      isA<PlanWriteValidationFailed>(),
    );
    expect(
      await repo.addWorkout(
        'p1',
        input(
          exercises: const [
            PlannedExerciseInput(title: 'Dřep', sets: 0, repetitions: 5),
          ],
        ),
        newId: nextId,
        now: now,
      ),
      isA<PlanWriteValidationFailed>(),
    );
    expect(await repo.workoutsForPlan('p1'), isEmpty);

    // Prázdný workout (bez cviků) je dovolen (MPC-011).
    expect(
      await repo.addWorkout('p1', input(), newId: nextId, now: now),
      isA<PlanWriteSaved>(),
    );

    // Do archivovaného plánu nelze přidávat.
    await repo.setPlanStatus('p1', 'ARCHIVED', now: now);
    expect(
      await repo.addWorkout('p1', input(), newId: nextId, now: now),
      isA<PlanWriteValidationFailed>(),
    );
    expect(
      await repo.addWorkout('missing', input(), newId: nextId, now: now),
      isA<PlanWriteNotFound>(),
    );
  });
}
