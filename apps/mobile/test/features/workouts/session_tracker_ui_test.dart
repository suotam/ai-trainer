import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/record_performance_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/session_tracker_view.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  Widget harness({
    required FakeWorkoutPerformanceRepository perf,
    required SessionTracker tracker,
  }) => ProviderScope(
    overrides: [
      r1SeedRepositoryProvider.overrideWithValue(
        FakeSeedRepository([SeedResult.applied]),
      ),
      workoutSessionRepositoryProvider.overrideWithValue(
        FakeWorkoutSessionRepository(
          sessionsById: {
            'ses-1': buildSessionSnapshot(
              id: 'ses-1',
              workoutInstanceId: 'wi1',
            ),
          },
        ),
      ),
      workoutInstanceRepositoryProvider.overrideWithValue(
        FakeWorkoutInstanceRepository(
          detailsById: {'wi1': buildDetail(id: 'wi1')},
        ),
      ),
      workoutPerformanceRepositoryProvider.overrideWithValue(perf),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ActiveSessionScreen(sessionId: 'ses-1'),
    ),
  );

  const setId = 'setp-1';

  SessionTracker trackerWith({
    int? actualReps,
    double? actualWeight,
    SetPerformanceStatus status = SetPerformanceStatus.planned,
  }) => buildTracker(
    sets: [
      TrackerSet(
        setPerformanceId: setId,
        position: 0,
        status: status,
        plannedRepetitions: 8,
        plannedWeightKg: 16,
        actualRepetitions: actualReps,
        actualWeightKg: actualWeight,
      ),
    ],
  );

  testWidgets('tracker zobrazí planned i actual a inputy', (tester) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(
          tracker: trackerWith(actualReps: 9),
        ),
        tracker: trackerWith(actualReps: 9),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SessionTrackerView.trackerKey), findsOneWidget);
    expect(find.textContaining('Planned'), findsOneWidget);
    // Actual seed hodnota se zobrazí v poli (recovery/rebuild).
    expect(
      tester
          .widget<TextField>(find.byKey(SessionTrackerView.repsFieldKey(setId)))
          .controller!
          .text,
      '9',
    );
  });

  testWidgets('zápis validních hodnot → saved indikátor', (tester) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(
          tracker: trackerWith(),
          recordScript: const [PerformanceSaved()],
        ),
        tracker: trackerWith(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SessionTrackerView.repsFieldKey(setId)),
      '10',
    );
    await tester.tap(find.byKey(SessionTrackerView.saveButtonKey(setId)));
    await tester.pumpAndSettle();

    expect(find.byKey(SessionTrackerView.savedKey(setId)), findsOneWidget);
  });

  testWidgets('záporná hodnota → validation error (skutečná validace)', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(tracker: trackerWith()),
        tracker: trackerWith(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SessionTrackerView.repsFieldKey(setId)),
      '-2',
    );
    await tester.tap(find.byKey(SessionTrackerView.saveButtonKey(setId)));
    await tester.pumpAndSettle();

    expect(
      find.byKey(SessionTrackerView.validationErrorKey(setId)),
      findsOneWidget,
    );
  });

  testWidgets('inactive session → error bez raw detailu', (tester) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(
          tracker: trackerWith(),
          recordScript: const [PerformanceSessionNotActive()],
        ),
        tracker: trackerWith(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SessionTrackerView.repsFieldKey(setId)),
      '8',
    );
    await tester.tap(find.byKey(SessionTrackerView.saveButtonKey(setId)));
    await tester.pumpAndSettle();

    expect(find.byKey(SessionTrackerView.saveErrorKey(setId)), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('SQL'), findsNothing);
  });

  testWidgets('dokončený set je vizuálně a sémanticky rozpoznatelný', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(
          tracker: trackerWith(status: SetPerformanceStatus.completed),
        ),
        tracker: trackerWith(status: SetPerformanceStatus.completed),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(SessionTrackerView.completedMarkKey(setId)),
      findsOneWidget,
    );
  });

  testWidgets('rebuild zobrazí uložené actual hodnoty (recovery)', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        perf: FakeWorkoutPerformanceRepository(
          tracker: trackerWith(actualReps: 7, actualWeight: 18),
        ),
        tracker: trackerWith(actualReps: 7, actualWeight: 18),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(find.byKey(SessionTrackerView.repsFieldKey(setId)))
          .controller!
          .text,
      '7',
    );
    expect(
      tester
          .widget<TextField>(
            find.byKey(SessionTrackerView.weightFieldKey(setId)),
          )
          .controller!
          .text,
      '18',
    );
  });
}
