import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/chat/application/chat_action_executor.dart';
import 'package:ai_trainer_mobile/features/goals/data/drift_goal_repository.dart';
import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R7-03 testy provedení akcí (C48 §3/§4): výhradně existující repos
/// (CHA-001), deterministická resolvace sportu (CHA-009), zachování
/// nepokrytých atributů (CHA-011), typovaná doménová odmítnutí (CHA-007).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 15, 12);

  test('všechny druhy akcí se provedou existujícími repos a jsou vidět '
      'v read modelech (CHA-001/012)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final sports = DriftUserSportRepository(db);
    final goals = DriftGoalRepository(db);
    final availability = DriftAvailabilityProfileRepository(db);
    final executor = ChatActionExecutor(sports, goals, availability);
    var seq = 0;
    String nextId() => 'a-${seq++}';

    expect(
      await executor.apply(
        {
          'action': 'UPSERT_SPORT',
          'customName': 'Florbal',
          'role': 'PRIMARY',
          'priority': 'HIGH',
          'frequencyPerWeek': 2,
        },
        newId: nextId,
        now: now,
      ),
      isA<ChatActionApplied>(),
    );
    expect(
      await executor.apply(
        {
          'action': 'ADD_GOAL',
          'title': 'Zhubnout 5 kg',
          'goalType': 'HABIT',
          'priority': 'PRIMARY',
        },
        newId: nextId,
        now: now,
      ),
      isA<ChatActionApplied>(),
    );
    expect(
      await executor.apply(
        {
          'action': 'SET_AVAILABILITY',
          'dayOfWeek': 'TUE',
          'level': 'AVAILABLE',
          'budgetMinutes': 90,
        },
        newId: nextId,
        now: now,
      ),
      isA<ChatActionApplied>(),
    );
    expect(
      await executor.apply(
        {'action': 'ADD_CONSTRAINT', 'title': 'Citlivé koleno'},
        newId: nextId,
        now: now,
      ),
      isA<ChatActionApplied>(),
    );

    final sport = (await sports.sportsForCurrentOwner()).single;
    expect(sport.customName, 'Florbal');
    expect(sport.frequencyPerWeek, 2);
    expect((await goals.goalsForCurrentOwner()).single.title, 'Zhubnout 5 kg');
    expect((await availability.weekForCurrentOwner()).single.budgetMinutes, 90);
    expect(
      (await availability.constraintsForCurrentOwner()).single.title,
      'Citlivé koleno',
    );
  });

  test('UPSERT_SPORT resolvuje existující sport (case-insensitive název) a '
      'zachovává nepokryté atributy (CHA-009/011)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final sports = DriftUserSportRepository(db);
    final executor = ChatActionExecutor(
      sports,
      DriftGoalRepository(db),
      DriftAvailabilityProfileRepository(db),
    );
    var seq = 0;
    String nextId() => 'a-${seq++}';

    await executor.apply(
      {
        'action': 'UPSERT_SPORT',
        'customName': 'Florbal',
        'role': 'PRIMARY',
        'priority': 'HIGH',
        'typicalDurationMinutes': 60,
      },
      newId: nextId,
      now: now,
    );

    // Update téhož sportu jiným zápisem názvu — žádný duplikát; dřívější
    // typicalDurationMinutes přežívá, role/priority se aktualizují.
    expect(
      await executor.apply(
        {
          'action': 'UPSERT_SPORT',
          'customName': 'florbal',
          'role': 'SECONDARY',
          'priority': 'MEDIUM',
          'frequencyPerWeek': 3,
        },
        newId: nextId,
        now: now,
      ),
      isA<ChatActionApplied>(),
    );

    final all = await sports.sportsForCurrentOwner();
    expect(all, hasLength(1));
    expect(all.single.role, 'SECONDARY');
    expect(all.single.frequencyPerWeek, 3);
    expect(all.single.typicalDurationMinutes, 60);
  });

  test('doménové odmítnutí je typované FAILED, nikdy výjimka (CHA-007) — '
      'druhý ACTIVE PRIMARY sport', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final executor = ChatActionExecutor(
      DriftUserSportRepository(db),
      DriftGoalRepository(db),
      DriftAvailabilityProfileRepository(db),
    );
    var seq = 0;
    String nextId() => 'b-${seq++}';

    await executor.apply(
      {
        'action': 'UPSERT_SPORT',
        'customName': 'Běh',
        'role': 'PRIMARY',
        'priority': 'HIGH',
      },
      newId: nextId,
      now: now,
    );
    final second = await executor.apply(
      {
        'action': 'UPSERT_SPORT',
        'customName': 'Plavání',
        'role': 'PRIMARY',
        'priority': 'HIGH',
      },
      newId: nextId,
      now: now,
    );

    expect(second, isA<ChatActionRejectedByDomain>());
  });
}
