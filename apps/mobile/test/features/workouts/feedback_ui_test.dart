import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_feedback.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/completed_workout_detail_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/feedback_confirm_dialog.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');

  Widget appWith({
    required FakeWorkoutCompletionRepository completion,
    FakeWorkoutHistoryRepository? history,
  }) => ProviderScope(
    overrides: [
      r1SeedRepositoryProvider.overrideWithValue(
        FakeSeedRepository([SeedResult.applied]),
      ),
      workoutSessionRepositoryProvider.overrideWithValue(
        FakeWorkoutSessionRepository(sessionsById: {'ses-1': session}),
      ),
      workoutInstanceRepositoryProvider.overrideWithValue(
        FakeWorkoutInstanceRepository(
          detailsById: {'wi1': buildDetail(id: 'wi1')},
        ),
      ),
      workoutPerformanceRepositoryProvider.overrideWithValue(
        FakeWorkoutPerformanceRepository(
          tracker: buildTracker(
            sessionId: 'ses-1',
            sets: const [
              TrackerSet(
                setPerformanceId: 'setp-1',
                position: 0,
                status: SetPerformanceStatus.completed,
                plannedRepetitions: 8,
                plannedWeightKg: 16,
                actualRepetitions: 9,
              ),
            ],
          ),
        ),
      ),
      workoutCompletionRepositoryProvider.overrideWithValue(completion),
      workoutHistoryRepositoryProvider.overrideWithValue(
        history ?? FakeWorkoutHistoryRepository(),
      ),
    ],
    child: const AiTrainerApp(),
  );

  Future<void> openSession(WidgetTester tester) async {
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.activeSessionLocation('ses-1'));
    await tester.pumpAndSettle();
  }

  testWidgets('Complete otevře feedback dialog; Cancel nezapíše', (
    tester,
  ) async {
    final completion = FakeWorkoutCompletionRepository();
    await tester.pumpWidget(appWith(completion: completion));
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(FeedbackConfirmDialog.dialogKey), findsOneWidget);

    await tester.tap(find.byKey(FeedbackConfirmDialog.cancelKey));
    await tester.pumpAndSettle();
    expect(completion.completeCallCount, 0);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
  });

  testWidgets('feedback (náročnost + pocit) se předá do completion', (
    tester,
  ) async {
    final completion = FakeWorkoutCompletionRepository();
    await tester.pumpWidget(
      appWith(
        completion: completion,
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
        ),
      ),
    );
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(FeedbackConfirmDialog.effortChipKey(7)));
    await tester.tap(find.byKey(FeedbackConfirmDialog.feelingChipKey('GOOD')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FeedbackConfirmDialog.confirmKey));
    await tester.pumpAndSettle();

    expect(completion.completeCallCount, 1);
    final fb = completion.lastFeedback;
    expect(fb, isNotNull);
    expect(fb!.overallEffort, 7.0);
    expect(fb.feeling, WorkoutFeeling.good);
    // Navigace do historie.
    expect(find.byKey(HistoryScreen.screenKey), findsOneWidget);
  });

  testWidgets('přeskočený feedback → completion s null feedbackem', (
    tester,
  ) async {
    final completion = FakeWorkoutCompletionRepository();
    await tester.pumpWidget(
      appWith(
        completion: completion,
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
        ),
      ),
    );
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    // Nic nevybráno → potvrdit.
    await tester.tap(find.byKey(FeedbackConfirmDialog.confirmKey));
    await tester.pumpAndSettle();

    expect(completion.completeCallCount, 1);
    expect(completion.lastFeedback, isNull); // prázdný feedback se přeskočí
  });

  testWidgets('pain flag zobrazí konzervativní bezpečné upozornění', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(completion: FakeWorkoutCompletionRepository()),
    );
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(FeedbackConfirmDialog.painSwitchKey));
    await tester.tap(find.byKey(FeedbackConfirmDialog.painSwitchKey));
    await tester.pumpAndSettle();

    expect(find.byKey(FeedbackConfirmDialog.painWarningKey), findsOneWidget);
  });

  testWidgets('completed detail zobrazí uložený feedback (reload)', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        completion: FakeWorkoutCompletionRepository(),
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
          feedback: const WorkoutFeedbackSnapshot(
            overallEffort: 8,
            feeling: WorkoutFeeling.tired,
            painReported: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.completedWorkoutLocation('ses-1'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(CompletedWorkoutDetailScreen.feedbackSectionKey),
      findsOneWidget,
    );
    expect(find.textContaining('8/10'), findsOneWidget);
  });

  testWidgets('completed detail bez feedbacku zobrazí bezpečnou informaci', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        completion: FakeWorkoutCompletionRepository(),
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.completedWorkoutLocation('ses-1'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(CompletedWorkoutDetailScreen.feedbackNoneKey),
      findsOneWidget,
    );
  });

  testWidgets('hlavní ovládací prvky mají accessibility význam', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      appWith(completion: FakeWorkoutCompletionRepository()),
    );
    await openSession(tester);

    // Complete workout tlačítko má čitelný sémantický label.
    expect(find.bySemanticsLabel(RegExp('Complete workout')), findsOneWidget);

    // Feedback dialog: náročnost má sémantickou hodnotu.
    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Effort 7 of 10')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('feedback dialog přežije zvětšení textu (text scaling)', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(completion: FakeWorkoutCompletionRepository()),
    );
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();

    // Zvětšený text nesmí shodit build ani skrýt akce.
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byKey(FeedbackConfirmDialog.confirmKey), findsOneWidget);
  });
}
