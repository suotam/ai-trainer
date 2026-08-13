import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/recommendation/domain/today_recommendation.dart';
import 'package:ai_trainer_mobile/features/recommendation/presentation/today_recommendation_card.dart';
import 'package:ai_trainer_mobile/features/safety/domain/safety_assessment.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';
import '../../support/workout_test_scope.dart';

/// R5-03 testy doporučení dne (C35): mapovací matice §2, determinismus a
/// widget stavy na Today (výzva s CTA, odpočinek s důvody, trénink dle
/// plánu) — R1 stavy Today nedotčené (TDR-011/015).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SafetyAssessment safety(
    SafetyState state, [
    List<SafetyFlag> flags = const [],
  ]) => SafetyAssessment(state: state, flags: flags);

  test('mapovací matice C35 §2: safety má přednost před plánem (TDR-003), '
      'determinismus (TDR-001)', () {
    final cases = <(SafetyState, int, TodayRecommendationState)>[
      (
        SafetyState.insufficientInformation,
        0,
        TodayRecommendationState.checkInMissing,
      ),
      (
        SafetyState.insufficientInformation,
        2,
        TodayRecommendationState.checkInMissing,
      ),
      (
        SafetyState.doNotRecommendActivity,
        3,
        TodayRecommendationState.considerRest,
      ),
      (
        SafetyState.doNotRecommendActivity,
        0,
        TodayRecommendationState.considerRest,
      ),
      (SafetyState.caution, 1, TodayRecommendationState.considerLighterDay),
      (SafetyState.caution, 0, TodayRecommendationState.considerLighterDay),
      (
        SafetyState.safeWithCurrentInformation,
        1,
        TodayRecommendationState.trainAsPlanned,
      ),
      (
        SafetyState.safeWithCurrentInformation,
        0,
        TodayRecommendationState.nothingPlanned,
      ),
    ];
    for (final (state, planned, expected) in cases) {
      final result = evaluateTodayRecommendation(
        safety: safety(state),
        plannedWorkoutCount: planned,
      );
      expect(result.state, expected, reason: '$state/planned=$planned');
    }

    // Důvody = C34 flags beze změny (TDR-002/006); opakovaný běh identický.
    const flag = SafetyFlag(
      SafetyFlagCodes.painReported,
      painAreaCode: 'KNEE',
      painLevel: 2,
    );
    final first = evaluateTodayRecommendation(
      safety: safety(SafetyState.caution, const [flag]),
      plannedWorkoutCount: 2,
    );
    expect(first.reasons.single, flag);
    expect(first.plannedWorkoutCount, 2);
    final second = evaluateTodayRecommendation(
      safety: safety(SafetyState.caution, const [flag]),
      plannedWorkoutCount: 2,
    );
    expect(second.state, first.state);
    expect(second.reasons, first.reasons);
  });

  Widget todayApp(
    AppDatabase db, {
    List<WorkoutInstanceSummary> today = const [],
  }) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 8, 14, 12)),
      r1SeedRepositoryProvider.overrideWithValue(
        FakeSeedRepository([SeedResult.applied]),
      ),
      workoutInstanceRepositoryProvider.overrideWithValue(
        FakeWorkoutInstanceRepository(today: today),
      ),
      workoutSessionRepositoryProvider.overrideWithValue(
        FakeWorkoutSessionRepository(),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TodayScreen(),
    ),
  );

  testWidgets('bez check-inu: výzva s CTA, žádná implicitní rada (TDR-004); '
      'R1 empty stav nedotčen (TDR-011)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(todayApp(db));
    await tester.pumpAndSettle();

    expect(find.byKey(TodayRecommendationCard.cardKey), findsOneWidget);
    expect(
      find.byKey(TodayRecommendationCard.stateKey('CHECK_IN_MISSING')),
      findsOneWidget,
    );
    expect(find.byKey(TodayRecommendationCard.checkInCtaKey), findsOneWidget);
    expect(find.byKey(TodayScreen.emptyKey), findsOneWidget);
  });

  testWidgets('STOP check-in: zvaž odpočinek s viditelným důvodem i při '
      'naplánovaném workoutu (TDR-003/006)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    await DriftDailyCheckInRepository(db).saveForDate(
      '2026-08-14',
      const DailyCheckInInput(
        energyLevel: 3,
        fatigueLevel: 3,
        painLevel: 5,
        painAreaCode: 'KNEE',
      ),
      newId: 'ci1',
      now: DateTime.utc(2026, 8, 14, 12),
    );
    await tester.pumpWidget(
      todayApp(db, today: [buildSummary(title: 'Full Body Strength')]),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(TodayRecommendationCard.stateKey('CONSIDER_REST')),
      findsOneWidget,
    );
    expect(find.textContaining('Knee'), findsOneWidget);
    // R1 seznam workoutů zůstává — doporučení nejedná (TDR-005/011).
    expect(find.text('Full Body Strength'), findsOneWidget);
  });

  testWidgets('klidný check-in s plánem: trénuj podle plánu (C35 §2)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    await DriftDailyCheckInRepository(db).saveForDate(
      '2026-08-14',
      const DailyCheckInInput(energyLevel: 4, fatigueLevel: 2),
      newId: 'ci1',
      now: DateTime.utc(2026, 8, 14, 12),
    );
    await tester.pumpWidget(
      todayApp(db, today: [buildSummary(title: 'Full Body Strength')]),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(TodayRecommendationCard.stateKey('TRAIN_AS_PLANNED')),
      findsOneWidget,
    );
  });
}
