import 'dart:convert';

import 'package:ai_trainer_mobile/features/activity/data/drift_activity_repository.dart';
import 'package:ai_trainer_mobile/features/activity/domain/manual_activity.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_context_builder.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/goals/data/drift_goal_repository.dart';
import 'package:ai_trainer_mobile/features/goals/domain/goal.dart';
import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R4-02 testy AIContext builderu (C27): determinismus (bajtové porovnání,
/// ACX-008), zakázaný obsah (ID/owner/poznámky — ACX-003/004/005),
/// stavové filtry (ACX-006), resolvace sport linku a prázdný profil
/// (ACX-009).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 18);

  DriftAiContextBuilder builderFor(db) => DriftAiContextBuilder(
    DriftUserSportRepository(db),
    DriftGoalRepository(db),
    DriftAvailabilityProfileRepository(db),
    DriftActivityRepository(db),
    DriftDailyCheckInRepository(db),
    DriftWorkoutInstanceRepository(db),
  );

  test('kontext je deterministický, by-value bez ID/owner/poznámek a jen '
      'z aktivních dat; sport link resolvován na kód', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final sports = DriftUserSportRepository(db);
    final goals = DriftGoalRepository(db);
    final availability = DriftAvailabilityProfileRepository(db);
    final builder = builderFor(db);

    // Data s markery v zakázaných polích (poznámky) a ENDED/RESOLVED
    // entitami, které se nesmí přenést.
    await sports.saveSport(
      const UserSportInput(
        sportCode: 'CLIMBING',
        role: 'PRIMARY',
        priority: 'HIGH',
        experienceLevel: 'INTERMEDIATE',
        frequencyPerWeek: 3,
        note: 'NOTE-MARKER-SPORT',
      ),
      newId: 'us-marker-1',
      now: now,
    );
    await sports.saveSport(
      const UserSportInput(
        sportCode: 'RUNNING',
        role: 'RECREATIONAL',
        priority: 'LOW',
      ),
      newId: 'us-ended',
      now: now,
    );
    await sports.changeStatus('us-ended', 'ENDED', now: now);
    await goals.saveGoal(
      const GoalInput(
        title: '7a na laně',
        goalType: 'PERFORMANCE',
        priority: 'PRIMARY',
        userSportId: 'us-marker-1',
        note: 'NOTE-MARKER-GOAL',
      ),
      newId: 'g-marker-1',
      now: now,
    );
    await goals.saveGoal(
      const GoalInput(
        title: 'Opuštěný cíl',
        goalType: 'HABIT',
        priority: 'DEFERRED',
      ),
      newId: 'g-abandoned',
      now: now,
    );
    await goals.changeStatus('g-abandoned', 'ABANDONED', now: now);
    await availability.upsertDay(
      dayOfWeek: 'MON',
      level: 'AVAILABLE',
      budgetMinutes: 60,
      note: 'NOTE-MARKER-DAY',
      newId: 'av-marker-1',
      now: now,
    );
    await availability.addEquipment(
      equipmentCode: 'BARBELL',
      note: 'NOTE-MARKER-EQ',
      newId: 'eq-marker-1',
      now: now,
    );
    await availability.addConstraint(
      title: 'Bolavé rameno',
      note: 'NOTE-MARKER-CON',
      newId: 'c-marker-1',
      now: now,
    );

    final context = await builder.buildPlanProposalContext(now: now);
    final json = jsonEncode(context.payload);

    // Determinismus: bajtově identická serializace (ACX-008).
    final again = await builder.buildPlanProposalContext(now: now);
    expect(jsonEncode(again.payload), json);

    // Zakázaný obsah (ACX-003/004/005): poznámky, ID, owner.
    for (final forbidden in [
      'NOTE-MARKER',
      'us-marker-1',
      'g-marker-1',
      'av-marker-1',
      'eq-marker-1',
      'c-marker-1',
      'local-anonymous',
      'owner',
      'rowVersion',
      'syncState',
    ]) {
      expect(
        json.contains(forbidden),
        isFalse,
        reason: 'kontext nese zakázaný obsah: $forbidden',
      );
    }

    // Jen aktivní data (ACX-006).
    expect(json.contains('RUNNING'), isFalse);
    expect(json.contains('Opuštěný cíl'), isFalse);
    // Sport link resolvován na kód, ne ID (ACX-003).
    final goalEntry =
        (context.payload['goals']! as List).single as Map<String, Object?>;
    expect(goalEntry['sport'], 'CLIMBING');
    // Účelová data přítomná.
    expect(json.contains('CLIMBING'), isTrue);
    expect(json.contains('Bolavé rameno'), isTrue);
    expect(json.contains('BARBELL'), isTrue);
    expect(context.payload['requestType'], 'PLAN_PROPOSAL');
  });

  test('prázdný profil je validní kontext s prázdnými sekcemi a nulovými '
      'agregáty (ACX-009)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final context = await builderFor(db).buildPlanProposalContext(now: now);

    expect(context.payload['sports'], isEmpty);
    expect(context.payload['goals'], isEmpty);
    expect(context.payload['typicalWeek'], isEmpty);
    expect(context.payload['equipment'], isEmpty);
    expect(context.payload['constraints'], isEmpty);
    final stats = context.payload['statistics']! as Map<String, Object?>;
    expect(stats['plannedCount'], 0);
    expect(stats['completedCount'], 0);
    expect(stats['manualActivityCount'], 0);
    expect(stats['manualMinutes'], 0);
  });

  test('statistiky v kontextu jsou C23 agregáty za 30 dní — žádný detail '
      'historie (ACX-007)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final activities = DriftActivityRepository(db);
    await activities.saveActivity(
      const ManualActivityInput(
        title: 'HISTORY-DETAIL-MARKER běh',
        localDate: '2026-08-10',
        durationMinutes: 40,
      ),
      newId: 'a1',
      now: now,
    );

    final context = await builderFor(db).buildPlanProposalContext(now: now);
    final json = jsonEncode(context.payload);
    final stats = context.payload['statistics']! as Map<String, Object?>;

    expect(stats['manualActivityCount'], 1);
    expect(stats['manualMinutes'], 40);
    // Název konkrétní aktivity (detail historie) se nepřenáší.
    expect(json.contains('HISTORY-DETAIL-MARKER'), isFalse);
  });
}
