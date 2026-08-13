import 'package:ai_trainer_mobile/features/goals/data/drift_goal_repository.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-02 persistence testy cílů (C18) nad skutečnou SQLite: owner stamping,
/// lifecycle guardy (GLC-004/006), validace (GLC-003), sport link (GLC-008)
/// a deterministické řazení (GLC-013).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 13, 19);

  GoalInput input({
    String title = 'Cíl',
    String type = 'PERFORMANCE',
    String priority = 'PRIMARY',
    String horizon = 'OPEN_ENDED',
    String? sportId,
    String? targetDate,
  }) => GoalInput(
    title: title,
    goalType: type,
    priority: priority,
    horizon: horizon,
    userSportId: sportId,
    targetLocalDate: targetDate,
  );

  test('vytvoření razí anonymního vlastníka, LOCAL_ONLY, verzi 1 a ACTIVE; '
      'záznam přežije „restart"', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftGoalRepository(db);

    final result = await repo.saveGoal(
      input(title: 'Zhubnout 5 kg', type: 'HABIT'),
      newId: 'g1',
      now: now,
    );
    expect(result, isA<GoalSaved>());

    final row =
        (await db
                .customSelect(
                  'SELECT owner_id, sync_state, row_version, status '
                  "FROM local_goals WHERE id = 'g1'",
                )
                .getSingle())
            .data;
    expect(row['owner_id'], 'local-anonymous');
    expect(row['sync_state'], 'LOCAL_ONLY');
    expect(row['row_version'], 1);
    expect(row['status'], 'ACTIVE');

    final restarted = DriftGoalRepository(db);
    final goals = await restarted.goalsForCurrentOwner();
    expect(goals.single.title, 'Zhubnout 5 kg');
  });

  test('validace (GLC-003): prázdný title, neznámé kódy, nevalidní datum a '
      'neexistující sport link jsou odmítnuty bez zápisu', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftGoalRepository(db);

    expect(
      await repo.saveGoal(
        input(title: '   '),
        newId: 'x1',
        now: now,
      ),
      isA<GoalValidationFailed>(),
    );
    expect(
      await repo.saveGoal(
        input(type: 'WINNING'),
        newId: 'x2',
        now: now,
      ),
      isA<GoalValidationFailed>(),
    );
    expect(
      await repo.saveGoal(
        input(targetDate: '13.8.2026'),
        newId: 'x3',
        now: now,
      ),
      isA<GoalValidationFailed>(),
    );
    expect(
      await repo.saveGoal(
        input(sportId: 'missing'),
        newId: 'x4',
        now: now,
      ),
      isA<GoalValidationFailed>(),
    );
    expect(await repo.goalsForCurrentOwner(), isEmpty);
  });

  test('sport link (GLC-008): validní vazba na UserSport projde a je '
      'čitelná v read modelu', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final sports = DriftUserSportRepository(db);
    final repo = DriftGoalRepository(db);
    await sports.saveSport(
      const UserSportInput(
        sportCode: 'CLIMBING',
        role: 'PRIMARY',
        priority: 'HIGH',
      ),
      newId: 'us1',
      now: now,
    );

    final result = await repo.saveGoal(
      input(title: '7a na laně', sportId: 'us1', targetDate: '2026-12-31'),
      newId: 'g1',
      now: now,
    );
    expect(result, isA<GoalSaved>());
    final goal = (await repo.goalsForCurrentOwner()).single;
    expect(goal.userSportId, 'us1');
    expect(goal.targetLocalDate, '2026-12-31');
  });

  test('lifecycle (C18 §6): pause/resume, terminální complete/abandon; '
      'terminální cíl je immutable a nevalidní přechod odmítnut', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftGoalRepository(db);
    await repo.saveGoal(
      input(title: 'A'),
      newId: 'g1',
      now: now,
    );
    await repo.saveGoal(
      input(title: 'B'),
      newId: 'g2',
      now: now,
    );

    expect(await repo.changeStatus('g1', 'PAUSED', now: now), isA<GoalSaved>());
    expect(await repo.changeStatus('g1', 'ACTIVE', now: now), isA<GoalSaved>());
    expect(
      await repo.changeStatus('g1', 'COMPLETED', now: now),
      isA<GoalSaved>(),
    );
    // Terminální stav je konečný (GLC-004).
    expect(
      await repo.changeStatus('g1', 'ACTIVE', now: now),
      isA<GoalInvalidTransition>(),
    );
    // Terminální cíl je immutable (GLC-006).
    expect(
      await repo.saveGoal(
        input(title: 'Nové jméno'),
        existingId: 'g1',
        newId: 'unused',
        now: now,
      ),
      isA<GoalInvalidTransition>(),
    );
    // Abandon z PAUSED je povolen.
    await repo.changeStatus('g2', 'PAUSED', now: now);
    expect(
      await repo.changeStatus('g2', 'ABANDONED', now: now),
      isA<GoalSaved>(),
    );
    // Žádný cíl se nesmazal (GLC-005).
    expect(await repo.goalsForCurrentOwner(), hasLength(2));
  });

  test(
    'editace je current-state (GLC-006): verze +1, SYNCED → DIRTY',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = DriftGoalRepository(db);
      await repo.saveGoal(
        input(title: 'A'),
        newId: 'g1',
        now: now,
      );
      await db.customStatement(
        "UPDATE local_goals SET sync_state = 'SYNCED' WHERE id = 'g1'",
      );

      await repo.saveGoal(
        input(title: 'A2', priority: 'MAINTENANCE'),
        existingId: 'g1',
        newId: 'unused',
        now: now,
      );

      final row =
          (await db
                  .customSelect(
                    'SELECT title, priority, row_version, sync_state '
                    "FROM local_goals WHERE id = 'g1'",
                  )
                  .getSingle())
              .data;
      expect(row['title'], 'A2');
      expect(row['priority'], 'MAINTENANCE');
      expect(row['row_version'], 2);
      expect(row['sync_state'], 'DIRTY');
    },
  );

  test('deterministické řazení (GLC-013): status, priorita, title', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftGoalRepository(db);

    await repo.saveGoal(
      input(title: 'B aktivní udržovací', priority: 'MAINTENANCE'),
      newId: 'a',
      now: now,
    );
    await repo.saveGoal(
      input(title: 'A aktivní hlavní', priority: 'PRIMARY'),
      newId: 'b',
      now: now,
    );
    await repo.saveGoal(
      input(title: 'C splněný', priority: 'PRIMARY'),
      newId: 'c',
      now: now,
    );
    await repo.changeStatus('c', 'COMPLETED', now: now);
    await repo.saveGoal(
      input(title: 'D pozastavený', priority: 'DEFERRED'),
      newId: 'd',
      now: now,
    );
    await repo.changeStatus('d', 'PAUSED', now: now);

    final ids = (await repo.goalsForCurrentOwner()).map((g) => g.id).toList();
    // ACTIVE (PRIMARY před MAINTENANCE) → PAUSED → COMPLETED.
    expect(ids, ['b', 'a', 'd', 'c']);
  });
}
