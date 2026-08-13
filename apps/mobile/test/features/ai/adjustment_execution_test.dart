import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_proposal_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_proposal_executor.dart';
import 'package:ai_trainer_mobile/features/ai/domain/ai_proposal.dart';
import 'package:ai_trainer_mobile/features/ai/domain/proposal_executor.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_calendar_operations_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R5-06 testy adjustment execution (C38): happy path všech čtyř operací
/// s evidencí a EXECUTED, deterministická resolvace (AJE-004), rollback
/// bez částečného stavu (AJE-003), safety veto (AJE-005) a terminalita.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  ({
    DriftAiProposalRepository proposals,
    DriftTrainingPlanRepository plans,
    DriftProposalExecutor executor,
    DriftCalendarOperationsRepository calendarOps,
  })
  buildScope(AppDatabase db) {
    final proposals = DriftAiProposalRepository(db);
    final plans = DriftTrainingPlanRepository(db);
    final calendarOps = DriftCalendarOperationsRepository(db);
    return (
      proposals: proposals,
      plans: plans,
      calendarOps: calendarOps,
      executor: DriftProposalExecutor(
        db,
        plans,
        proposals,
        calendarOps,
        DriftWorkoutInstanceRepository(db),
        DriftDailyCheckInRepository(db),
        DriftAvailabilityProfileRepository(db),
      ),
    );
  }

  var seq = 0;
  String nextId() => 'adj-${seq++}';

  Future<void> seedWeek(DriftTrainingPlanRepository plans) async {
    await plans.createPlan(title: 'Můj plán', newId: 'p1', now: now);
    for (final (title, offset) in [
      ('Full Body A', 0),
      ('Intervals', 1),
      ('Heavy Press', 3),
    ]) {
      expect(
        await plans.addWorkout(
          'p1',
          PlannedWorkoutInput(
            title: title,
            workoutType: 'STRENGTH',
            scheduledLocalDate: scheduledDateForOffset(now, offset),
          ),
          newId: nextId,
          now: now,
        ),
        isA<PlanWriteSaved>(),
      );
    }
  }

  Future<String> seedConfirmed(
    DriftAiProposalRepository proposals,
    Map<String, Object?> payload, {
    String id = 'adj-prop',
  }) async {
    await proposals.saveProposed(
      id: id,
      requestType: 'ADJUSTMENT_PROPOSAL',
      canonicalPayload: payload,
      summary: 's',
      promptVersion: 'adjustment-proposal-v1',
      schemaVersion: 'adjustment-proposal-schema-v1',
      modelId: 'fake-model',
      now: now,
    );
    expect(
      await proposals.decide(id, ProposalDecision.confirm, now: now),
      isA<DecisionSaved>(),
    );
    return id;
  }

  test('happy path: MOVE/CANCEL/REPLACE/ADD atomicky C21/C20 cestami, '
      'evidence a EXECUTED (AJE-001/003/007/014)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scope = buildScope(db);
    await seedWeek(scope.plans);
    await seedConfirmed(scope.proposals, {
      'summary': 'Lehčí týden.',
      'operations': [
        {
          'operation': 'MOVE',
          'reason': 'r1',
          'target': {'dayOffset': 0, 'title': 'Full Body A'},
          'toDayOffset': 2,
        },
        {
          'operation': 'CANCEL',
          'reason': 'r2',
          'target': {'dayOffset': 1, 'title': 'Intervals'},
        },
        {
          'operation': 'REPLACE',
          'reason': 'r3',
          'target': {'dayOffset': 3, 'title': 'Heavy Press'},
          'workout': {
            'title': 'Light Mobility',
            'workoutType': 'MOBILITY',
            'plannedDurationMinutes': 30,
          },
        },
        {
          'operation': 'ADD',
          'reason': 'r4',
          'workout': {
            'title': 'Easy Run',
            'workoutType': 'ENDURANCE',
            'dayOffset': 5,
          },
        },
      ],
    });

    final result = await scope.executor.execute(
      'adj-prop',
      newId: nextId,
      now: now,
    );
    expect(result, isA<ExecutionSaved>());
    // Reference = ACTIVE plán (vznikl obsah přes ADD, C38 §5).
    expect((result as ExecutionSaved).planId, 'p1');

    Future<Map<String, Object?>> instance(String title) async =>
        (await db
                .customSelect(
                  'SELECT id, scheduled_local_date, status '
                  'FROM local_workout_instances WHERE title = ?',
                  variables: [Variable(title)],
                )
                .getSingle())
            .data;
    expect(
      (await instance('Full Body A'))['scheduled_local_date'],
      scheduledDateForOffset(now, 2),
    );
    expect((await instance('Intervals'))['status'], 'CANCELLED');
    expect((await instance('Heavy Press'))['status'], 'CANCELLED');
    // Náhrada dědí den targetu (C37 §3).
    final replacement = await instance('Light Mobility');
    expect(replacement['scheduled_local_date'], scheduledDateForOffset(now, 3));
    expect(
      (await instance('Easy Run'))['scheduled_local_date'],
      scheduledDateForOffset(now, 5),
    );

    // Append-only kalendářní evidence (AJE-007).
    final moved = await scope.calendarOps.changesForInstance(
      '${(await instance('Full Body A'))['id']}',
    );
    expect(moved.single.changeType, 'MOVED');
    expect(moved.single.toLocalDate, scheduledDateForOffset(now, 2));

    final executed = (await scope.proposals.proposalById('adj-prop'))!;
    expect(executed.status, 'EXECUTED');
    expect(executed.executedPlanId, 'p1');

    // Terminalita (AJE-009).
    expect(
      await scope.executor.execute('adj-prop', newId: nextId, now: now),
      isA<ExecutionInvalidState>(),
    );
  });

  test('rollback bez částečného stavu: nezvěstný target uprostřed vrátí '
      'i už provedený MOVE (AJE-003/004)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scope = buildScope(db);
    await seedWeek(scope.plans);
    await seedConfirmed(scope.proposals, {
      'summary': 's',
      'operations': [
        {
          'operation': 'MOVE',
          'reason': 'r',
          'target': {'dayOffset': 0, 'title': 'Full Body A'},
          'toDayOffset': 2,
        },
        {
          'operation': 'CANCEL',
          'reason': 'r',
          'target': {'dayOffset': 1, 'title': 'Zmizelý workout'},
        },
      ],
    });

    expect(
      await scope.executor.execute('adj-prop', newId: nextId, now: now),
      isA<ExecutionTargetUnresolved>(),
    );
    // MOVE se odvolal: datum zůstalo den 0, žádná evidence (AJE-003).
    final unmoved = await db
        .customSelect(
          "SELECT scheduled_local_date FROM local_workout_instances "
          "WHERE title = 'Full Body A'",
        )
        .getSingle();
    expect(
      unmoved.data['scheduled_local_date'],
      scheduledDateForOffset(now, 0),
    );
    final changes = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_calendar_changes')
        .getSingle();
    expect(changes.data['c'], 0);
    expect(
      (await scope.proposals.proposalById('adj-prop'))!.status,
      'EXECUTION_FAILED',
    );
  });

  test('safety veto: STOP stav blokuje ADD/REPLACE beze změn; čistý '
      'MOVE/CANCEL projde (AJE-005, konzervativní směr)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scope = buildScope(db);
    await seedWeek(scope.plans);
    // Dnešní STOP stav: silná bolest.
    await DriftDailyCheckInRepository(db).saveForDate(
      scheduledDateForOffset(now, 0),
      const DailyCheckInInput(
        energyLevel: 3,
        fatigueLevel: 3,
        painLevel: 5,
        painAreaCode: 'KNEE',
      ),
      newId: 'ci1',
      now: now,
    );

    await seedConfirmed(scope.proposals, {
      'summary': 's',
      'operations': [
        {
          'operation': 'ADD',
          'reason': 'r',
          'workout': {
            'title': 'Extra Session',
            'workoutType': 'STRENGTH',
            'dayOffset': 4,
          },
        },
      ],
    }, id: 'adj-add');
    expect(
      await scope.executor.execute('adj-add', newId: nextId, now: now),
      isA<ExecutionSafetyConflict>(),
    );
    final count = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM local_workout_instances "
          "WHERE title = 'Extra Session'",
        )
        .getSingle();
    expect(count.data['c'], 0);
    expect(
      (await scope.proposals.proposalById('adj-add'))!.status,
      'EXECUTION_FAILED',
    );

    // Konzervativní směr veto nemá: CANCEL projde i při STOP.
    await seedConfirmed(scope.proposals, {
      'summary': 's',
      'operations': [
        {
          'operation': 'CANCEL',
          'reason': 'r',
          'target': {'dayOffset': 1, 'title': 'Intervals'},
        },
      ],
    }, id: 'adj-cancel');
    expect(
      await scope.executor.execute('adj-cancel', newId: nextId, now: now),
      isA<ExecutionSaved>(),
    );
    expect(
      (await scope.proposals.proposalById('adj-cancel'))!.status,
      'EXECUTED',
    );
    // Bez ADD obsahu je EXECUTED bez plan reference (C38 §5).
    expect(
      (await scope.proposals.proposalById('adj-cancel'))!.executedPlanId,
      isNull,
    );
  });

  test('doménové odmítnutí: CANCEL dokončeného workoutu = typované selhání '
      'celku (AJE-002/008)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final scope = buildScope(db);
    await seedWeek(scope.plans);
    await db.customStatement(
      "UPDATE local_workout_instances SET status = 'COMPLETED' "
      "WHERE title = 'Intervals'",
    );
    await seedConfirmed(scope.proposals, {
      'summary': 's',
      'operations': [
        {
          'operation': 'CANCEL',
          'reason': 'r',
          'target': {'dayOffset': 1, 'title': 'Intervals'},
        },
      ],
    });
    expect(
      await scope.executor.execute('adj-prop', newId: nextId, now: now),
      isA<ExecutionOperationRejected>(),
    );
    expect(
      (await scope.proposals.proposalById('adj-prop'))!.status,
      'EXECUTION_FAILED',
    );
  });
}
