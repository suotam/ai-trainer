import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_calendar_operations_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/calendar_operations.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_pull_applier.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/features/sync/domain/sync_push_models.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R6-03 testy struktury (C43): push payload se strukturou (WSS-001/002/
/// 005), round-trip na druhou DB s byte-ekvivalentní strukturou a R1 flow
/// (WSS-006/009), idempotence (WSS-007), závislé typy po prerekvizitách
/// (WSS-010) a chybějící struktura jako poctivý stav (WSS-008).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  Future<List<Map<String, Object?>>> rowsOf(
    dynamic db,
    String sql,
    String param,
  ) async => [
    for (final row
        in await db
            .customSelect(sql, variables: [Variable.withString(param)])
            .get())
      Map<String, Object?>.from(row.data),
  ];

  test('struktura cestuje v payloadu, round-trip ji rekonstruuje '
      'byte-ekvivalentně a obnovený workout drží R1 flow', () async {
    final deviceA = createTestDatabase();
    final deviceB = createTestDatabase();
    addTearDown(deviceA.close);
    addTearDown(deviceB.close);

    // Zařízení A: ruční workout s cviky (plná C20 struktura) + přesun
    // (kalendářní evidence) + ruční aktivita vázaná na instanci.
    final plans = DriftTrainingPlanRepository(deviceA);
    await plans.createPlan(title: 'Plán A', newId: 'p1', now: now);
    var seq = 0;
    String nextId() => 'a-${seq++}';
    final added =
        await plans.addWorkout(
              'p1',
              PlannedWorkoutInput(
                title: 'Silový A',
                workoutType: 'STRENGTH',
                scheduledLocalDate: formatLocalDate(now),
                plannedDurationMinutes: 60,
                exercises: const [
                  PlannedExerciseInput(
                    title: 'Dřep',
                    sets: 2,
                    repetitions: 5,
                    weightKg: 80,
                  ),
                  PlannedExerciseInput(
                    title: 'Kliky',
                    sets: 1,
                    repetitions: 12,
                  ),
                ],
              ),
              newId: nextId,
              now: now,
            )
            as PlanWriteSaved;
    final instanceId = added.id;
    expect(
      await DriftCalendarOperationsRepository(deviceA).moveWorkout(
        instanceId,
        formatLocalDate(now.add(const Duration(days: 2))),
        changeId: 'change-1',
        now: now,
      ),
      isA<CalendarOpSaved>(),
    );

    // Push strana: instance payload nese strukturu (WSS-001).
    final planned = await DriftSyncSnapshotRepository(
      deviceA,
    ).collectPendingEntities(localAnonymousOwnerId);
    final instanceEntity = planned.singleWhere(
      (e) => e.entityType == 'WORKOUT_INSTANCE' && e.entityId == instanceId,
    );
    final structure =
        instanceEntity.payload['structure']! as Map<String, Object?>;
    final sections = (structure['sections']! as List).cast<Map>();
    expect(sections, hasLength(1));
    final steps = (sections.single['steps']! as List).cast<Map>();
    expect(steps, hasLength(2));
    expect((steps[0]['setPlans']! as List), hasLength(2));
    expect((steps[1]['setPlans']! as List), hasLength(1));
    // Syrové sloupcové mapy (WSS-002): snake_case klíče a zachovaná ID.
    expect(sections.single.containsKey('workout_instance_id'), isTrue);

    // Round-trip: aplikace na zařízení B (WSS-006).
    final applier = DriftPullApplier(deviceB);
    expect(
      await applier.apply(
        'account-1',
        SyncPullItem(
          entityType: 'WORKOUT_INSTANCE',
          entityId: instanceId,
          serverVersion: 1,
          payload: instanceEntity.payload,
        ),
        now: now,
      ),
      PullApplyOutcome.appliedNew,
    );

    // Byte-ekvivalence struktury (WSS-002/005/006).
    for (final probe in [
      (
        'SELECT * FROM local_workout_sections WHERE workout_instance_id = ? '
            'ORDER BY position, id',
        instanceId,
      ),
    ]) {
      expect(
        await rowsOf(deviceB, probe.$1, probe.$2),
        await rowsOf(deviceA, probe.$1, probe.$2),
      );
    }
    final sectionId = '${sections.single['id']}';
    expect(
      await rowsOf(
        deviceB,
        'SELECT * FROM local_workout_steps WHERE section_id = ? '
        'ORDER BY position, id',
        sectionId,
      ),
      await rowsOf(
        deviceA,
        'SELECT * FROM local_workout_steps WHERE section_id = ? '
        'ORDER BY position, id',
        sectionId,
      ),
    );

    // Idempotence (WSS-007): stejná verze = no-op.
    expect(
      await applier.apply(
        'account-1',
        SyncPullItem(
          entityType: 'WORKOUT_INSTANCE',
          entityId: instanceId,
          serverVersion: 1,
          payload: instanceEntity.payload,
        ),
        now: now,
      ),
      PullApplyOutcome.noOp,
    );

    // Závislé typy po prerekvizitě (WSS-010): kalendářní změna se aplikuje.
    final changeEntity = planned.singleWhere(
      (e) => e.entityType == 'CALENDAR_CHANGE',
    );
    expect(
      await applier.apply(
        'account-1',
        SyncPullItem(
          entityType: 'CALENDAR_CHANGE',
          entityId: changeEntity.entityId,
          serverVersion: 1,
          payload: changeEntity.payload,
        ),
        now: now,
      ),
      PullApplyOutcome.appliedNew,
    );
    final change = await deviceB
        .customSelect(
          'SELECT change_type, created_at FROM local_calendar_changes '
          'WHERE id = ?',
          variables: [Variable.withString(changeEntity.entityId)],
        )
        .getSingle();
    expect(change.data['change_type'], 'MOVED');
    expect(change.data['created_at'], changeEntity.payload['createdAt']);

    // R1 flow na obnoveném workoutu (WSS-009): start session + performance
    // vrstva nad rekonstruovanou strukturou.
    expect(
      await DriftWorkoutSessionRepository(deviceB).startSession(
        workoutInstanceId: instanceId,
        newSessionId: 'ses-b-1',
        now: now,
      ),
      isA<SessionCreated>(),
    );
  });

  test(
    'chybějící struktura je poctivý stav — žádné dopočty (WSS-008)',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final applier = DriftPullApplier(db);
      expect(
        await applier.apply(
          'account-1',
          const SyncPullItem(
            entityType: 'WORKOUT_INSTANCE',
            entityId: 'legacy-1',
            serverVersion: 1,
            payload: {
              'title': 'Před C43',
              'workoutType': 'STRENGTH',
              'scheduledLocalDate': '2026-08-10',
              'status': 'READY',
              'sourceType': 'USER_PLAN',
              'revisionNumber': 1,
              'createdAt': 0,
              'updatedAt': 0,
              'rowVersion': 1,
            },
          ),
          now: now,
        ),
        PullApplyOutcome.appliedNew,
      );
      final sections = await db
          .customSelect('SELECT COUNT(*) AS c FROM local_workout_sections')
          .getSingle();
      expect(sections.data['c'], 0);
      final instance = await db
          .customSelect(
            "SELECT title, sync_state FROM local_workout_instances "
            "WHERE id = 'legacy-1'",
          )
          .getSingle();
      expect(instance.data['title'], 'Před C43');
      expect(instance.data['sync_state'], 'SYNCED');
    },
  );
}
