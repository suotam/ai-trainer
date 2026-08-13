import 'dart:convert';

import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/data/drift_activity_repository.dart';
import 'package:ai_trainer_mobile/features/ai/data/drift_ai_context_builder.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/goals/data/drift_goal_repository.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R5-04 testy adjustment kontextu (C36): zakázaný obsah (ADX-001/006),
/// bajtový determinismus (ADX-002), dayOffset mapování (ADX-003), žádná
/// instance ID (ADX-004), safety průchod (ADX-005), agregáty (ADX-007)
/// a validní prázdný stav (ADX-012).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Poledne UTC: lokální datum stejné pro všechny běžné časové zóny.
  final now = DateTime.utc(2026, 8, 14, 12);

  DriftAiContextBuilder builderFor(db) => DriftAiContextBuilder(
    DriftUserSportRepository(db),
    DriftGoalRepository(db),
    DriftAvailabilityProfileRepository(db),
    DriftActivityRepository(db),
    DriftDailyCheckInRepository(db),
    DriftWorkoutInstanceRepository(db),
  );

  test(
    'adjustment kontext: weekPlan s dayOffset bez ID, check-in bez note, '
    'agregáty místo historie, safety jako fakt; bajtový determinismus',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final builder = builderFor(db);

      // Profil s markery v poznámkách (nesmí se přenést).
      await DriftUserSportRepository(db).saveSport(
        const UserSportInput(
          sportCode: 'CLIMBING',
          role: 'PRIMARY',
          priority: 'HIGH',
          experienceLevel: 'INTERMEDIATE',
          note: 'MARKER-SPORT-NOTE',
        ),
        newId: 'us1',
        now: now,
      );
      final availability = DriftAvailabilityProfileRepository(db);
      await availability.addConstraint(
        title: 'Bolavé rameno',
        newId: 'c1',
        now: now,
      );

      // Týden plánu: dnes + za 2 dny (ruční plán = reálná C20 cesta).
      final plans = DriftTrainingPlanRepository(db);
      await plans.createPlan(title: 'Můj plán', newId: 'p1', now: now);
      var seq = 0;
      String nextId() => 'w-${seq++}';
      Future<void> addWorkout(String title, int offset) async {
        final date = formatLocalDate(now.add(Duration(days: offset)));
        expect(
          await plans.addWorkout(
            'p1',
            PlannedWorkoutInput(
              title: title,
              workoutType: 'STRENGTH',
              scheduledLocalDate: date,
              plannedDurationMinutes: 60,
            ),
            newId: nextId,
            now: now,
          ),
          isA<PlanWriteSaved>(),
        );
      }

      await addWorkout('Dnešní silový', 0);
      await addWorkout('Čtvrteční silový', 2);
      // Workout mimo 7denní okno se nepřenáší.
      await addWorkout('Daleký workout', 10);

      // Check-iny: dnes s bolestí a lokální poznámkou + starší v okně.
      final checkIns = DriftDailyCheckInRepository(db);
      await checkIns.saveForDate(
        formatLocalDate(now.subtract(const Duration(days: 2))),
        const DailyCheckInInput(energyLevel: 4, fatigueLevel: 2),
        newId: 'ci-old',
        now: now,
      );
      await checkIns.saveForDate(
        formatLocalDate(now),
        const DailyCheckInInput(
          energyLevel: 2,
          fatigueLevel: 4,
          painLevel: 2,
          painAreaCode: 'SHOULDER',
          note: 'MARKER-CHECKIN-NOTE',
        ),
        newId: 'ci-today',
        now: now,
      );

      final context = await builder.buildAdjustmentContext(now: now);
      expect(context.requestType.code, 'ADJUSTMENT_PROPOSAL');
      final payload = context.payload;
      final serialized = jsonEncode(payload);

      // Zakázaný obsah (ADX-001/004/006): žádná ID, poznámky, owner ani
      // sync metadata.
      for (final forbidden in [
        'MARKER-SPORT-NOTE',
        'MARKER-CHECKIN-NOTE',
        'us1',
        'p1',
        'w-0',
        'ci-today',
        'local-anonymous',
        'owner',
        'rowVersion',
        'syncState',
      ]) {
        expect(
          serialized.contains(forbidden),
          isFalse,
          reason: 'kontext nese zakázaný obsah: $forbidden',
        );
      }

      // weekPlan: dayOffset místo dat (ADX-003), jen 7denní okno.
      final weekPlan = (payload['weekPlan']! as List)
          .cast<Map<String, Object?>>();
      expect(weekPlan.map((w) => w['title']), [
        'Dnešní silový',
        'Čtvrteční silový',
      ]);
      expect(weekPlan.map((w) => w['dayOffset']), [0, 2]);
      expect(weekPlan.first['plannedDurationMinutes'], 60);
      expect(serialized.contains('scheduledLocalDate'), isFalse);

      // Check-iny: dnešní by-value + agregáty (ADX-007).
      final checkInSection = payload['checkIns']! as Map<String, Object?>;
      final todayEntry = checkInSection['today']! as Map<String, Object?>;
      expect(todayEntry['painAreaCode'], 'SHOULDER');
      expect(todayEntry.containsKey('note'), isFalse);
      final aggregates = checkInSection['aggregates']! as Map<String, Object?>;
      expect(aggregates['checkInCount'], 2);
      expect(aggregates['averageEnergy'], 3.0);
      expect(aggregates['averageFatigue'], 3.0);
      expect(aggregates['painDays'], 1);

      // Safety jako fakt (ADX-005): CAUTION + flags bez titulů omezení.
      final safety = payload['safety']! as Map<String, Object?>;
      expect(safety['state'], 'CAUTION');
      final flagCodes = (safety['flags']! as List)
          .cast<Map<String, Object?>>()
          .map((f) => f['code'])
          .toList();
      expect(
        flagCodes,
        containsAll(['PAIN_REPORTED', 'HIGH_FATIGUE', 'ACTIVE_CONSTRAINT']),
      );

      // Bajtový determinismus (ADX-002).
      final second = await builder.buildAdjustmentContext(now: now);
      expect(jsonEncode(second.payload), serialized);
    },
  );

  test('prázdný stav je validní kontext (ADX-012): prázdný weekPlan, žádný '
      'check-in, safety INSUFFICIENT_INFORMATION', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final context = await builderFor(db).buildAdjustmentContext(now: now);
    final payload = context.payload;
    expect(payload['weekPlan'], isEmpty);
    final checkInSection = payload['checkIns']! as Map<String, Object?>;
    expect(checkInSection.containsKey('today'), isFalse);
    expect(
      (checkInSection['aggregates']! as Map<String, Object?>)['checkInCount'],
      0,
    );
    expect(
      (payload['safety']! as Map<String, Object?>)['state'],
      'INSUFFICIENT_INFORMATION',
    );
  });
}
