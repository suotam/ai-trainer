import 'package:ai_trainer_mobile/features/workouts/application/record_set_performance.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/set_set_completion.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/record_performance_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

void main() {
  ProviderContainer container(FakeWorkoutPerformanceRepository perf) {
    final c = ProviderContainer(
      overrides: [
        r1SeedRepositoryProvider.overrideWithValue(
          FakeSeedRepository([SeedResult.applied]),
        ),
        workoutPerformanceRepositoryProvider.overrideWithValue(perf),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('RecordSetPerformance use case', () {
    RecordSetPerformance useCase(FakeWorkoutPerformanceRepository perf) =>
        RecordSetPerformance(
          repository: perf,
          clock: () => DateTime.utc(2026, 7, 20, 9),
        );

    test('validní hodnoty se uloží', () async {
      final perf = FakeWorkoutPerformanceRepository();
      final result = await useCase(perf).call(
        setPerformanceId: 'setp-1',
        actualRepetitions: 8,
        actualWeightKg: 16,
      );
      expect(result, isA<PerformanceSaved>());
      expect(perf.recordCallCount, 1);
    });

    test('záporné reps jsou odmítnuty bez volání repository', () async {
      final perf = FakeWorkoutPerformanceRepository();
      final result = await useCase(perf).call(
        setPerformanceId: 'setp-1',
        actualRepetitions: -1,
        actualWeightKg: null,
      );
      expect(result, isA<PerformanceValidationFailure>());
      expect(
        (result as PerformanceValidationFailure).reason,
        PerformanceValidationReason.negativeReps,
      );
      expect(perf.recordCallCount, 0);
    });

    test('záporná váha je odmítnuta', () async {
      final perf = FakeWorkoutPerformanceRepository();
      final result = await useCase(perf).call(
        setPerformanceId: 'setp-1',
        actualRepetitions: null,
        actualWeightKg: -5,
      );
      expect(result, isA<PerformanceValidationFailure>());
      expect(perf.recordCallCount, 0);
    });
  });

  test('SetSetCompletion deleguje na repository', () async {
    final perf = FakeWorkoutPerformanceRepository();
    final useCase = SetSetCompletion(
      repository: perf,
      clock: () => DateTime.utc(2026, 7, 20, 9),
    );
    final result = await useCase.call(
      setPerformanceId: 'setp-1',
      completed: true,
    );
    expect(result, isA<PerformanceSaved>());
    expect(perf.completeCallCount, 1);
  });

  group('sessionTrackerProvider', () {
    test('inicializuje a načte tracker read model', () async {
      final perf = FakeWorkoutPerformanceRepository(tracker: buildTracker());
      final c = container(perf);

      final tracker = await c.read(sessionTrackerProvider('ses-1').future);
      expect(tracker, isNotNull);
      expect(tracker!.exercises.single.sets.single.plannedRepetitions, 8);
      expect(perf.initCallCount, 1);
    });
  });

  group('TrackerController', () {
    test('idle → saving → saved a invaliduje tracker', () async {
      final perf = FakeWorkoutPerformanceRepository(
        tracker: buildTracker(),
        recordScript: const [PerformanceSaved()],
      );
      final c = container(perf);
      final notifier = c.read(trackerControllerProvider.notifier);
      expect(c.read(trackerControllerProvider), isA<TrackerIdle>());

      final future = notifier.saveActuals(
        sessionId: 'ses-1',
        setPerformanceId: 'setp-1',
        actualRepetitions: 8,
        actualWeightKg: 16,
      );
      expect(c.read(trackerControllerProvider), isA<TrackerSaving>());
      await future;
      expect(c.read(trackerControllerProvider), isA<TrackerSaved>());
    });

    test('validation failure → TrackerValidationError', () async {
      final perf = FakeWorkoutPerformanceRepository(
        recordScript: const [
          PerformanceValidationFailure(
            PerformanceValidationReason.negativeReps,
          ),
        ],
      );
      final c = container(perf);
      await c
          .read(trackerControllerProvider.notifier)
          .saveActuals(
            sessionId: 'ses-1',
            setPerformanceId: 'setp-1',
            actualRepetitions: -1,
            actualWeightKg: null,
          );
      expect(c.read(trackerControllerProvider), isA<TrackerValidationError>());
    });

    test('sessionNotActive → TrackerError (bez raw úniku)', () async {
      final perf = FakeWorkoutPerformanceRepository(
        recordScript: const [PerformanceSessionNotActive()],
      );
      final c = container(perf);
      await c
          .read(trackerControllerProvider.notifier)
          .saveActuals(
            sessionId: 'ses-1',
            setPerformanceId: 'setp-1',
            actualRepetitions: 8,
            actualWeightKg: null,
          );
      expect(c.read(trackerControllerProvider), isA<TrackerError>());
    });

    test('dvojitý save stejného setu nevytvoří dva zápisy', () async {
      final perf = FakeWorkoutPerformanceRepository(
        tracker: buildTracker(),
        recordScript: const [PerformanceSaved(), PerformanceSaved()],
      );
      final c = container(perf);
      final notifier = c.read(trackerControllerProvider.notifier);

      final f1 = notifier.saveActuals(
        sessionId: 'ses-1',
        setPerformanceId: 'setp-1',
        actualRepetitions: 8,
        actualWeightKg: 16,
      );
      final f2 = notifier.saveActuals(
        sessionId: 'ses-1',
        setPerformanceId: 'setp-1',
        actualRepetitions: 9,
        actualWeightKg: 17,
      );
      await Future.wait([f1, f2]);

      expect(perf.recordCallCount, 1);
    });

    test('toggleCompleted volá completion use case', () async {
      final perf = FakeWorkoutPerformanceRepository(
        tracker: buildTracker(),
        completeScript: const [PerformanceSaved()],
      );
      final c = container(perf);
      await c
          .read(trackerControllerProvider.notifier)
          .toggleCompleted(
            sessionId: 'ses-1',
            setPerformanceId: 'setp-1',
            completed: true,
          );
      expect(perf.completeCallCount, 1);
      expect(c.read(trackerControllerProvider), isA<TrackerSaved>());
    });
  });
}
