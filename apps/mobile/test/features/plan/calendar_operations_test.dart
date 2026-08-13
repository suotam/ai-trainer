import 'package:ai_trainer_mobile/features/plan/data/drift_calendar_operations_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/calendar_operations.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-05 testy kalendářních operací (C21) nad skutečnou SQLite: move/
/// cancel/replace s append-only evidencí (CAL-003), guardy (CAL-001/002),
/// idempotence (CAL-006), CANCELLED mimo kalendářní read modely (CAL-008).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 13);

  var idSequence = 0;
  String nextId() => 'op-${idSequence++}';

  Future<String> createPlannedWorkout(
    DriftTrainingPlanRepository plans, {
    String planId = 'p1',
    String date = '2026-08-20',
    String title = 'Workout',
  }) async {
    final created = await plans.addWorkout(
      planId,
      PlannedWorkoutInput(
        title: title,
        workoutType: 'STRENGTH',
        scheduledLocalDate: date,
        exercises: const [
          PlannedExerciseInput(title: 'Dřep', sets: 2, repetitions: 5),
        ],
      ),
      newId: nextId,
      now: now,
    );
    return (created as PlanWriteSaved).id;
  }

  test('move: datum + evidence MOVED + DIRTY-if-SYNCED; stejné datum je '
      'idempotentní no-op bez evidence (CAL-006)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final plans = DriftTrainingPlanRepository(db);
    final ops = DriftCalendarOperationsRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    final instanceId = await createPlannedWorkout(plans);
    await db.customStatement(
      "UPDATE local_workout_instances SET sync_state = 'SYNCED' "
      "WHERE id = '$instanceId'",
    );

    expect(
      await ops.moveWorkout(
        instanceId,
        '2026-08-22',
        changeId: nextId(),
        now: now,
      ),
      isA<CalendarOpSaved>(),
    );
    final row =
        (await db
                .customSelect(
                  'SELECT scheduled_local_date, sync_state, row_version '
                  "FROM local_workout_instances WHERE id = '$instanceId'",
                )
                .getSingle())
            .data;
    expect(row['scheduled_local_date'], '2026-08-22');
    expect(row['sync_state'], 'DIRTY');
    expect(row['row_version'], 2);

    final changes = await ops.changesForInstance(instanceId);
    expect(changes.single.changeType, 'MOVED');
    expect(changes.single.fromLocalDate, '2026-08-20');
    expect(changes.single.toLocalDate, '2026-08-22');

    // Idempotentní no-op.
    expect(
      await ops.moveWorkout(
        instanceId,
        '2026-08-22',
        changeId: nextId(),
        now: now,
      ),
      isA<CalendarOpSaved>(),
    );
    expect(await ops.changesForInstance(instanceId), hasLength(1));
    // Nevalidní datum.
    expect(
      await ops.moveWorkout(instanceId, '22.8.', changeId: nextId(), now: now),
      isA<CalendarOpValidationFailed>(),
    );
  });

  test('cancel: status CANCELLED + evidence; opakovaně no-op; CANCELLED '
      'mimo Today/range read modely, v editoru plánu viditelný (CAL-008); '
      'zrušený nelze přesunout', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final plans = DriftTrainingPlanRepository(db);
    final ops = DriftCalendarOperationsRepository(db);
    final instances = DriftWorkoutInstanceRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    final instanceId = await createPlannedWorkout(plans, date: '2026-08-25');

    expect(
      await ops.cancelWorkout(instanceId, changeId: nextId(), now: now),
      isA<CalendarOpSaved>(),
    );
    expect(
      (await ops.changesForInstance(instanceId)).single.changeType,
      'CANCELLED',
    );
    // Idempotence bez duplicitní evidence.
    await ops.cancelWorkout(instanceId, changeId: nextId(), now: now);
    expect(await ops.changesForInstance(instanceId), hasLength(1));

    // Kalendářní read modely CANCELLED vylučují (CAL-008).
    expect(await instances.workoutsForLocalDate('2026-08-25'), isEmpty);
    // Editor plánu ho zobrazuje se stavem.
    final planWorkouts = await plans.workoutsForPlan('p1');
    expect(planWorkouts.single.status, 'CANCELLED');
    // Detail podle ID zůstává dostupný.
    expect(await instances.workoutInstanceById(instanceId), isNotNull);

    // Zrušenou instanci nelze přesunout ani nahradit (C21 §5).
    expect(
      await ops.moveWorkout(
        instanceId,
        '2026-08-26',
        changeId: nextId(),
        now: now,
      ),
      isA<CalendarOpNotAllowed>(),
    );
  });

  test('replace: atomicky originál CANCELLED + náhrada plnou C20 cestou + '
      'evidence REPLACED s referencí (CAL-005/011)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final plans = DriftTrainingPlanRepository(db);
    final ops = DriftCalendarOperationsRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    final originalId = await createPlannedWorkout(plans, title: 'Původní');

    final result = await ops.replaceWorkout(
      originalId,
      const PlannedWorkoutInput(
        title: 'Náhradní',
        workoutType: 'MOBILITY',
        scheduledLocalDate: '2026-08-21',
      ),
      newId: nextId,
      now: now,
    );
    expect(result, isA<CalendarOpSaved>());
    final replacementId = (result as CalendarOpSaved).id;

    final original =
        (await db
                .customSelect(
                  'SELECT status FROM local_workout_instances '
                  "WHERE id = '$originalId'",
                )
                .getSingle())
            .data;
    expect(original['status'], 'CANCELLED');

    final change = (await ops.changesForInstance(originalId)).single;
    expect(change.changeType, 'REPLACED');
    expect(change.replacementInstanceId, replacementId);

    // Náhrada je plnohodnotný USER_PLAN workout téhož plánu.
    final workouts = await plans.workoutsForPlan('p1');
    expect(workouts, hasLength(2));
    expect(
      workouts.singleWhere((w) => w.instanceId == replacementId).title,
      'Náhradní',
    );

    // Nevalidní náhrada = žádný částečný stav (CAL-005).
    final second = await createPlannedWorkout(plans, title: 'Druhý');
    expect(
      await ops.replaceWorkout(
        second,
        const PlannedWorkoutInput(
          title: ' ',
          workoutType: 'STRENGTH',
          scheduledLocalDate: '2026-08-21',
        ),
        newId: nextId,
        now: now,
      ),
      isA<CalendarOpValidationFailed>(),
    );
    expect(
      (await db
              .customSelect(
                'SELECT status FROM local_workout_instances '
                "WHERE id = '$second'",
              )
              .getSingle())
          .data['status'],
      'READY',
    );
    expect(await ops.changesForInstance(second), isEmpty);
  });

  test('guardy (CAL-001/002): započatá instance, seed/DEMO a neexistující '
      'jsou typovaně odmítnuty; data byte-po-bytu nedotčená', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final plans = DriftTrainingPlanRepository(db);
    final ops = DriftCalendarOperationsRepository(db);
    final sessions = DriftWorkoutSessionRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    final startedId = await createPlannedWorkout(plans, title: 'Započatý');
    await sessions.startSession(
      workoutInstanceId: startedId,
      newSessionId: 'ses-1',
      now: now,
    );
    final before =
        (await db
                .customSelect(
                  'SELECT * FROM local_workout_instances '
                  "WHERE id = '$startedId'",
                )
                .getSingle())
            .data;

    expect(
      await ops.moveWorkout(
        startedId,
        '2026-08-30',
        changeId: nextId(),
        now: now,
      ),
      isA<CalendarOpNotAllowed>(),
    );
    expect(
      await ops.cancelWorkout(startedId, changeId: nextId(), now: now),
      isA<CalendarOpNotAllowed>(),
    );
    // Byte-po-bytu nedotčená (CAL-002).
    final after =
        (await db
                .customSelect(
                  'SELECT * FROM local_workout_instances '
                  "WHERE id = '$startedId'",
                )
                .getSingle())
            .data;
    expect(after, equals(before));
    expect(await ops.changesForInstance(startedId), isEmpty);

    // Seed/DEMO instance je read-only (CAL-001).
    await db.customStatement(
      'INSERT INTO local_workout_instances '
      '(id, title, workout_type, scheduled_local_date, status, source_type, '
      'revision_number, created_at, updated_at, row_version) '
      "VALUES ('demo-1', 'Demo', 'STRENGTH', '2026-08-20', 'READY', 'DEMO', "
      '1, 1, 1, 1)',
    );
    expect(
      await ops.cancelWorkout('demo-1', changeId: nextId(), now: now),
      isA<CalendarOpNotAllowed>(),
    );
    expect(
      await ops.cancelWorkout('missing', changeId: nextId(), now: now),
      isA<CalendarOpNotFound>(),
    );
  });
}
