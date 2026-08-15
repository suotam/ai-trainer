import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/app/navigation/app_routes.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/app/startup/recovery_gate_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/session_tracker_view.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_workout_repositories.dart';
import '../../support/workout_test_scope.dart';

/// Startup recovery gate (R1-05) — navigační rozhodnutí a bezpečné UI stavy.
void main() {
  Widget appWith({
    required FakeWorkoutSessionRepository sessions,
    FakeWorkoutPerformanceRepository? performances,
    FakeWorkoutInstanceRepository? workouts,
    R1SeedRepository? seed,
  }) {
    // Chat je domov (R7-05) — jeho persistence běží nad in-memory DB.
    final db = createTestDatabase();
    addTearDown(db.close);
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
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
  }

  testWidgets('bez aktivní session gate přejde na chat (domov, CQC-009)', (
    tester,
  ) async {
    await tester.pumpWidget(appWith(sessions: FakeWorkoutSessionRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
    expect(find.byKey(RecoveryGateScreen.screenKey), findsNothing);
  });

  testWidgets('startup neukáže krátce domov, dokud recovery nedoběhne', (
    tester,
  ) async {
    final hanging = HangingSeedRepository();
    await tester.pumpWidget(
      appWith(sessions: FakeWorkoutSessionRepository(), seed: hanging),
    );
    await tester.pump();

    expect(find.byKey(RecoveryGateScreen.loadingKey), findsOneWidget);
    expect(find.byKey(ChatScreen.screenKey), findsNothing);

    hanging.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
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
    expect(find.byKey(ChatScreen.screenKey), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
  });

  testWidgets('odmítnutá oprava pointeru → fallback, nenaviguje do trackeru', (
    tester,
  ) async {
    final session = buildSessionSnapshot(id: 'ses-1', workoutInstanceId: 'wi1');
    await tester.pumpWidget(
      appWith(
        sessions: FakeWorkoutSessionRepository(
          activeSessions: [session],
          activePointer: null, // vyžaduje opravu
          rejectPointerRepair: true, // transakční revalidace neprojde
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

    expect(find.byKey(RecoveryGateScreen.fallbackKey), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.screenKey), findsNothing);
    expect(find.byKey(ChatScreen.screenKey), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
  });

  testWidgets(
    'neopravitelný stav → fallback; Retry po pominutí vede na domov',
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

      expect(find.byKey(ChatScreen.screenKey), findsOneWidget);
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
    // Gate bez aktivní session → chat (domov); odtud deep link na session route.
    final context = tester.element(find.byKey(ChatScreen.screenKey));
    GoRouter.of(context).go(AppRoutes.activeSessionLocation('ses-1'));
    await tester.pumpAndSettle();

    expect(find.byKey(ActiveSessionScreen.contentKey), findsOneWidget);
  });
}
