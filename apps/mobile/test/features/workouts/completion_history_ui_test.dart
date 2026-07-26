import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/completed_workout_detail_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/session_tracker_view.dart';
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
    FakeWorkoutPerformanceRepository? performance,
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
        performance ??
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
                    actualWeightKg: 17.5,
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

  testWidgets('active tracker zobrazí Complete workout', (tester) async {
    await tester.pumpWidget(
      appWith(completion: FakeWorkoutCompletionRepository()),
    );
    await openSession(tester);

    expect(find.byKey(ActiveSessionScreen.completeButtonKey), findsOneWidget);
  });

  testWidgets('Complete → confirm dialog; Cancel nezapíše', (tester) async {
    final completion = FakeWorkoutCompletionRepository();
    await tester.pumpWidget(appWith(completion: completion));
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActiveSessionScreen.completeDialogKey), findsOneWidget);

    await tester.tap(find.byKey(ActiveSessionScreen.completeCancelKey));
    await tester.pumpAndSettle();

    // Dialog zavřen, žádný zápis, stále na session.
    expect(find.byKey(ActiveSessionScreen.completeDialogKey), findsNothing);
    expect(completion.completeCallCount, 0);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
  });

  testWidgets('Complete → confirm → dokončí a naviguje do historie', (
    tester,
  ) async {
    final completion = FakeWorkoutCompletionRepository(
      script: const [WorkoutCompleted('sum-1')],
    );
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
    await tester.tap(find.byKey(ActiveSessionScreen.completeConfirmKey));
    await tester.pumpAndSettle();

    expect(completion.completeCallCount, 1);
    expect(find.byKey(HistoryScreen.screenKey), findsOneWidget);
    expect(find.byKey(HistoryScreen.listKey), findsOneWidget);
  });

  testWidgets('completion chyba → bezpečný error, žádná navigace', (
    tester,
  ) async {
    final completion = FakeWorkoutCompletionRepository(
      script: const [CompletionInconsistentState()],
    );
    await tester.pumpWidget(appWith(completion: completion));
    await openSession(tester);

    await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ActiveSessionScreen.completeConfirmKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ActiveSessionScreen.completeErrorKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
    expect(find.byKey(HistoryScreen.screenKey), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
  });

  testWidgets('History empty stav', (tester) async {
    await tester.pumpWidget(
      appWith(
        completion: FakeWorkoutCompletionRepository(),
        history: FakeWorkoutHistoryRepository(entries: const []),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.historyPath);
    await tester.pumpAndSettle();

    expect(find.byKey(HistoryScreen.emptyKey), findsOneWidget);
  });

  testWidgets('History nav z Today → data → read-only completed detail', (
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

    // Vstup do historie z Today.
    await tester.tap(find.byKey(TodayScreen.historyActionKey));
    await tester.pumpAndSettle();
    expect(find.byKey(HistoryScreen.listKey), findsOneWidget);

    // Otevři dokončený detail.
    await tester.tap(find.byKey(HistoryScreen.entryKey('ses-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(CompletedWorkoutDetailScreen.contentKey), findsOneWidget);
    expect(
      find.byKey(CompletedWorkoutDetailScreen.completedLabelKey),
      findsOneWidget,
    );
    // Read-only: žádné aktivní tracker akce ani Complete button.
    expect(find.byKey(ActiveSessionScreen.completeButtonKey), findsNothing);
    expect(
      find.byKey(SessionTrackerView.saveButtonKey('setp-1')),
      findsNothing,
    );
    // Uložená actual hodnota se zobrazí.
    expect(find.textContaining('9'), findsWidgets);
  });
}
