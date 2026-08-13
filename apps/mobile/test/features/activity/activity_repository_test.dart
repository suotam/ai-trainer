import 'package:ai_trainer_mobile/features/activity/data/drift_activity_repository.dart';
import 'package:ai_trainer_mobile/features/activity/domain/manual_activity.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-06 testy ručních aktivit (C22) a statistik (C23) nad skutečnou
/// SQLite: fakta bez lifecycle, validace, determinismus, dvojí započtení
/// (PST-006), CANCELLED mimo plán (PST-005), poctivý empty stav (PST-009).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 14);

  var idSequence = 0;
  String nextId() => 'act-${idSequence++}';

  test('aktivita: owner stamping, LOCAL_ONLY, editace current-state '
      '(MAC-005), validace (MAC-002/006/013) a řazení (MAC-010)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftActivityRepository(db);

    expect(
      await repo.saveActivity(
        const ManualActivityInput(
          title: 'Večerní běh',
          localDate: '2026-08-13',
          durationMinutes: 40,
        ),
        newId: 'a1',
        now: now,
      ),
      isA<ActivityWriteSaved>(),
    );
    final row =
        (await db
                .customSelect(
                  'SELECT owner_id, sync_state, row_version, source '
                  "FROM local_activities WHERE id = 'a1'",
                )
                .getSingle())
            .data;
    expect(row['owner_id'], 'local-anonymous');
    expect(row['sync_state'], 'LOCAL_ONLY');
    expect(row['source'], 'MANUAL');

    // Editace current-state: verze +1, SYNCED → DIRTY.
    await db.customStatement(
      "UPDATE local_activities SET sync_state = 'SYNCED' WHERE id = 'a1'",
    );
    await repo.saveActivity(
      const ManualActivityInput(
        title: 'Večerní běh (opraveno)',
        localDate: '2026-08-13',
        durationMinutes: 45,
      ),
      existingId: 'a1',
      newId: 'unused',
      now: now,
    );
    final edited =
        (await db
                .customSelect(
                  'SELECT title, row_version, sync_state '
                  "FROM local_activities WHERE id = 'a1'",
                )
                .getSingle())
            .data;
    expect(edited['title'], 'Večerní běh (opraveno)');
    expect(edited['row_version'], 2);
    expect(edited['sync_state'], 'DIRTY');

    // Validace: prázdný title, nevalidní datum, délka < 1, neexistující
    // reference (MAC-006).
    expect(
      await repo.saveActivity(
        const ManualActivityInput(title: ' ', localDate: '2026-08-13'),
        newId: 'x1',
        now: now,
      ),
      isA<ActivityWriteValidationFailed>(),
    );
    expect(
      await repo.saveActivity(
        const ManualActivityInput(title: 'X', localDate: '13.8.'),
        newId: 'x2',
        now: now,
      ),
      isA<ActivityWriteValidationFailed>(),
    );
    expect(
      await repo.saveActivity(
        const ManualActivityInput(
          title: 'X',
          localDate: '2026-08-13',
          durationMinutes: 0,
        ),
        newId: 'x3',
        now: now,
      ),
      isA<ActivityWriteValidationFailed>(),
    );
    expect(
      await repo.saveActivity(
        const ManualActivityInput(
          title: 'X',
          localDate: '2026-08-13',
          userSportId: 'missing',
        ),
        newId: 'x4',
        now: now,
      ),
      isA<ActivityWriteValidationFailed>(),
    );

    // Řazení: datum sestupně.
    await repo.saveActivity(
      const ManualActivityInput(title: 'Novější', localDate: '2026-08-14'),
      newId: 'a2',
      now: now,
    );
    final activities = await repo.activitiesForCurrentOwner();
    expect(activities.map((a) => a.id), ['a2', 'a1']);
  });

  test('statistiky (C23): determinismus, CANCELLED mimo plán, dvojí '
      'započtení vázané aktivity, poctivý empty stav', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final activities = DriftActivityRepository(db);
    final plans = DriftTrainingPlanRepository(db);

    // Empty stav (PST-009): nuly a completionRate == null.
    final empty = await activities.statisticsForPeriod(
      fromLocalDate: '2026-08-10',
      toLocalDate: '2026-08-16',
    );
    expect(empty.plannedCount, 0);
    expect(empty.completedCount, 0);
    expect(empty.manualActivityCount, 0);
    expect(empty.manualMinutes, 0);
    expect(empty.completionRate, isNull);

    // Plán: 3 workouty v období, jeden zrušený (PST-005).
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    Future<String> workout(String date) async =>
        ((await plans.addWorkout(
                  'p1',
                  PlannedWorkoutInput(
                    title: 'W-$date',
                    workoutType: 'STRENGTH',
                    scheduledLocalDate: date,
                  ),
                  newId: nextId,
                  now: now,
                ))
                as PlanWriteSaved)
            .id;
    final w1 = await workout('2026-08-11');
    await workout('2026-08-12');
    final cancelledId = await workout('2026-08-13');
    await db.customStatement(
      "UPDATE local_workout_instances SET status = 'CANCELLED' "
      "WHERE id = '$cancelledId'",
    );
    // Dokončení w1 = summary (PST-007) — vložíme fakt přímo.
    await db.customStatement(
      'INSERT INTO local_workout_sessions '
      '(id, workout_instance_id, instance_revision_number, status, '
      'started_at, completed_at, elapsed_active_seconds, created_at, '
      'updated_at, row_version) '
      "VALUES ('ses1', '$w1', 1, 'COMPLETED', 10, 20, 0, 1, 1, 1)",
    );
    await db.customStatement(
      'INSERT INTO local_activity_summaries '
      '(id, workout_instance_id, workout_session_id, title_snapshot, '
      'workout_type, started_at, completed_at, active_duration_seconds, '
      'completed_step_count, total_step_count, created_at) '
      "VALUES ('sum1', '$w1', 'ses1', 'W', 'STRENGTH', 10, 20, 0, 1, 1, 1)",
    );

    // Aktivity: 2 volné (30 + bez délky) a 1 vázaná na w1 (PST-006).
    await activities.saveActivity(
      const ManualActivityInput(
        title: 'Běh',
        localDate: '2026-08-12',
        durationMinutes: 30,
      ),
      newId: nextId(),
      now: now,
    );
    await activities.saveActivity(
      const ManualActivityInput(title: 'Procházka', localDate: '2026-08-13'),
      newId: nextId(),
      now: now,
    );
    await activities.saveActivity(
      ManualActivityInput(
        title: 'Dokumentace tréninku',
        localDate: '2026-08-11',
        durationMinutes: 60,
        workoutInstanceId: w1,
      ),
      newId: nextId(),
      now: now,
    );

    final stats = await activities.statisticsForPeriod(
      fromLocalDate: '2026-08-10',
      toLocalDate: '2026-08-16',
    );
    expect(stats.plannedCount, 2); // zrušený není plán (PST-005)
    expect(stats.completedCount, 1);
    expect(stats.completionRate, 0.5);
    expect(stats.manualActivityCount, 2); // vázaná se nepočítá (PST-006)
    expect(stats.manualMinutes, 30); // bez délky se nedopočítává (PST-004)

    // Determinismus (PST-002): stejný vstup → identický výsledek.
    final again = await activities.statisticsForPeriod(
      fromLocalDate: '2026-08-10',
      toLocalDate: '2026-08-16',
    );
    expect(again.plannedCount, stats.plannedCount);
    expect(again.completedCount, stats.completedCount);
    expect(again.manualActivityCount, stats.manualActivityCount);
    expect(again.manualMinutes, stats.manualMinutes);

    // Období mimo data → empty (žádný přesah).
    final outside = await activities.statisticsForPeriod(
      fromLocalDate: '2026-09-01',
      toLocalDate: '2026-09-07',
    );
    expect(outside.plannedCount, 0);
    expect(outside.completionRate, isNull);
  });
}
