import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    String location, {
    required FakeWorkoutInstanceRepository workouts,
    required FakeWorkoutSessionRepository sessions,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          r1SeedRepositoryProvider.overrideWithValue(
            FakeSeedRepository([SeedResult.applied]),
          ),
          workoutInstanceRepositoryProvider.overrideWithValue(workouts),
          workoutSessionRepositoryProvider.overrideWithValue(sessions),
          workoutPerformanceRepositoryProvider.overrideWithValue(
            FakeWorkoutPerformanceRepository(tracker: buildTracker()),
          ),
        ],
        child: const AiTrainerApp(),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(location);
    await tester.pumpAndSettle();
  }

  final detailLocation = AppRoutes.workoutDetailLocation('wi1');

  testWidgets('detail zobrazuje Start workout', (tester) async {
    await pumpAt(
      tester,
      detailLocation,
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(),
    );

    expect(find.byKey(WorkoutDetailScreen.startButtonKey), findsOneWidget);
  });

  testWidgets('úspěšný start naviguje na active session screen', (
    tester,
  ) async {
    await pumpAt(
      tester,
      detailLocation,
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(
        startScript: [const SessionCreated('ses-1')],
        sessionsById: {
          'ses-1': buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1'),
        },
      ),
    );

    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.activeLabelKey), findsOneWidget);
  });

  testWidgets('resumed naviguje na existující session', (tester) async {
    await pumpAt(
      tester,
      detailLocation,
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(
        startScript: [const SessionResumedExisting('ses-existing')],
        sessionsById: {
          'ses-existing': buildSessionSnapshot(
            id: 'ses-existing',
            workoutInstanceId: 'wi1',
          ),
        },
      ),
    );

    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
  });

  testWidgets('conflict zobrazí bezpečný stav a akci pro otevření session', (
    tester,
  ) async {
    await pumpAt(
      tester,
      detailLocation,
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(
        startScript: [
          const ConflictWithAnotherSession(
            activeSessionId: 'ses-other',
            activeWorkoutInstanceId: 'other',
          ),
        ],
        sessionsById: {
          'ses-other': buildSessionSnapshot(
            id: 'ses-other',
            workoutInstanceId: 'other',
          ),
        },
      ),
    );

    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.conflictKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsNothing);

    await tester.tap(find.byKey(WorkoutDetailScreen.conflictOpenKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
  });

  testWidgets('start error neobsahuje raw exception a nenaviguje', (
    tester,
  ) async {
    await pumpAt(
      tester,
      detailLocation,
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(throwOnStart: true),
    );

    await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(WorkoutDetailScreen.startErrorKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('active session screen zobrazí data session', (tester) async {
    await pumpAt(
      tester,
      AppRoutes.activeSessionLocation('ses-1'),
      workouts: FakeWorkoutInstanceRepository(
        detailsById: {'wi1': buildDetail(id: 'wi1')},
      ),
      sessions: FakeWorkoutSessionRepository(
        sessionsById: {
          'ses-1': buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1'),
        },
      ),
    );

    expect(find.byKey(ActiveSessionScreen.contentKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.activeLabelKey), findsOneWidget);
    expect(find.text('Demo workout'), findsOneWidget);
  });

  testWidgets('nevalidní session ID je bezpečně zobrazeno jako not-found', (
    tester,
  ) async {
    await pumpAt(
      tester,
      AppRoutes.activeSessionLocation('missing'),
      workouts: FakeWorkoutInstanceRepository(),
      sessions: FakeWorkoutSessionRepository(),
    );

    expect(find.byKey(ActiveSessionScreen.notFoundKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.contentKey), findsNothing);
  });
}
