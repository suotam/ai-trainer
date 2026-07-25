import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/app/startup/recovery_gate_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/session_tracker_view.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_workout_repositories.dart';

/// Startup recovery gate (R1-05) — navigační rozhodnutí a bezpečné UI stavy.
void main() {
  Widget appWith({
    required FakeWorkoutSessionRepository sessions,
    FakeWorkoutPerformanceRepository? performances,
    FakeWorkoutInstanceRepository? workouts,
    R1SeedRepository? seed,
  }) => ProviderScope(
    overrides: [
      r1SeedRepositoryProvider.overrideWithValue(
        seed ?? FakeSeedRepository([SeedResult.applied]),
      ),
      workoutSessionRepositoryProvider.overrideWithValue(sessions),
      workoutPerformanceRepositoryProvider.overrideWithValue(
        performances ?? FakeWorkoutPerformanceRepository(),
      ),
      workoutInstanceRepositoryProvider.overrideWithValue(
        workouts ?? FakeWorkoutInstanceRepository(),
      ),
    ],
    child: const AiTrainerApp(),
  );

  testWidgets('bez aktivní session gate přejde na Today', (tester) async {
    await tester.pumpWidget(appWith(sessions: FakeWorkoutSessionRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.byKey(RecoveryGateScreen.screenKey), findsNothing);
  });

  testWidgets('startup neukáže krátce Today, dokud recovery nedoběhne', (
    tester,
  ) async {
    final hanging = HangingSeedRepository();
    await tester.pumpWidget(
      appWith(sessions: FakeWorkoutSessionRepository(), seed: hanging),
    );
    await tester.pump();

    expect(find.byKey(RecoveryGateScreen.loadingKey), findsOneWidget);
    expect(find.byKey(TodayScreen.screenKey), findsNothing);

    hanging.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
  });

  testWidgets(
    'obnovená aktivní session vede do trackeru s uloženými hodnotami',
    (tester) async {
      final session = buildSessionSnapshot(
        id: 'ses-1',
        workoutInstanceId: 'wi1',
      );
      await tester.pumpWidget(
        appWith(
          sessions: FakeWorkoutSessionRepository(
            activeSessions: [session],
            activePointer: 'ses-1',
            sessionsById: {'ses-1': session},
          ),
          performances: FakeWorkoutPerformanceRepository(
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
          workouts: FakeWorkoutInstanceRepository(
            detailsById: {'wi1': buildDetail(id: 'wi1')},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
      // Uložená actual hodnota se obnoví v trackeru.
      expect(
        tester
            .widget<TextField>(
              find.byKey(SessionTrackerView.repsFieldKey('setp-1')),
            )
            .controller!
            .text,
        '9',
      );
    },
  );

  testWidgets('více aktivních sessions → bezpečný fallback bez raw detailu', (
    tester,
  ) async {
    await tester.pumpWidget(
      appWith(
        sessions: FakeWorkoutSessionRepository(
          activeSessions: [
            buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1'),
            buildSessionSnapshot(id: 'ses-2', workoutInstanceId: 'wi2'),
          ],
          activePointer: 'ses-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(RecoveryGateScreen.fallbackKey), findsOneWidget);
    expect(find.byKey(RecoveryGateScreen.retryButtonKey), findsOneWidget);
    expect(find.byKey(TodayScreen.screenKey), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
  });

  testWidgets(
    'neopravitelný stav → fallback; Retry po pominutí vede na Today',
    (tester) async {
      final sessions = FakeWorkoutSessionRepository(
        throwOnFindActiveSessions: true,
      );
      await tester.pumpWidget(appWith(sessions: sessions));
      await tester.pumpAndSettle();

      expect(find.byKey(RecoveryGateScreen.fallbackKey), findsOneWidget);

      sessions.throwOnFindActiveSessions = false;
      await tester.tap(find.byKey(RecoveryGateScreen.retryButtonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    },
  );

  testWidgets('deep link na aktivní session zůstává funkční', (tester) async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    await tester.pumpWidget(
      appWith(
        sessions: FakeWorkoutSessionRepository(
          sessionsById: {'ses-1': session},
        ),
        performances: FakeWorkoutPerformanceRepository(
          tracker: buildTracker(sessionId: 'ses-1'),
        ),
        workouts: FakeWorkoutInstanceRepository(
          detailsById: {'wi1': buildDetail(id: 'wi1')},
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Gate bez aktivní session → Today; odtud deep link na session route.
    final context = tester.element(find.byKey(TodayScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.activeSessionLocation('ses-1'));
    await tester.pumpAndSettle();

    expect(find.byKey(ActiveSessionScreen.contentKey), findsOneWidget);
  });
}
