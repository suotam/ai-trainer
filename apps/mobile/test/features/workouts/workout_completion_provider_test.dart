import 'package:ai_trainer_mobile/features/workouts/application/session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/session_tracker_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_completion_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Completion controller a history providery (VSP §17). Bez widgetů/sítě.
void main() {
  ProviderContainer container({
    FakeWorkoutCompletionRepository? completion,
    FakeWorkoutHistoryRepository? history,
    FakeWorkoutPerformanceRepository? performance,
  }) {
    final c = ProviderContainer(
      overrides: [
        r1SeedRepositoryProvider.overrideWithValue(
          FakeSeedRepository([SeedResult.applied]),
        ),
        workoutCompletionRepositoryProvider.overrideWithValue(
          completion ?? FakeWorkoutCompletionRepository(),
        ),
        workoutHistoryRepositoryProvider.overrideWithValue(
          history ?? FakeWorkoutHistoryRepository(),
        ),
        workoutPerformanceRepositoryProvider.overrideWithValue(
          performance ?? FakeWorkoutPerformanceRepository(),
        ),
        workoutSessionRepositoryProvider.overrideWithValue(
          FakeWorkoutSessionRepository(),
        ),
        workoutInstanceRepositoryProvider.overrideWithValue(
          FakeWorkoutInstanceRepository(),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('WorkoutCompletionController', () {
    test('idle → completing → completed', () async {
      final repo = FakeWorkoutCompletionRepository(
        script: const [WorkoutCompleted('sum-1')],
      );
      final c = container(completion: repo);
      final notifier = c.read(workoutCompletionControllerProvider.notifier);
      expect(
        c.read(workoutCompletionControllerProvider),
        isA<CompletionIdle>(),
      );

      final future = notifier.complete('ses-1');
      expect(
        c.read(workoutCompletionControllerProvider),
        isA<CompletionInProgress>(),
      );
      await future;

      final state = c.read(workoutCompletionControllerProvider);
      expect(state, isA<CompletionDone>());
      expect((state as CompletionDone).alreadyCompleted, isFalse);
      expect(repo.completeCallCount, 1);
    });

    test('alreadyCompleted → CompletionDone(alreadyCompleted: true)', () async {
      final repo = FakeWorkoutCompletionRepository(
        script: const [WorkoutAlreadyCompleted()],
      );
      final c = container(completion: repo);
      await c.read(workoutCompletionControllerProvider.notifier).complete('s');
      final state = c.read(workoutCompletionControllerProvider);
      expect(state, isA<CompletionDone>());
      expect((state as CompletionDone).alreadyCompleted, isTrue);
    });

    test('typovaná chyba → CompletionError (bez raw úniku)', () async {
      final repo = FakeWorkoutCompletionRepository(
        script: const [CompletionSessionNotCompletable()],
      );
      final c = container(completion: repo);
      await c.read(workoutCompletionControllerProvider.notifier).complete('s');
      expect(
        c.read(workoutCompletionControllerProvider),
        isA<CompletionError>(),
      );
    });

    test('dvojitý trigger spustí jeden completion write', () async {
      final repo = FakeWorkoutCompletionRepository(
        script: const [WorkoutCompleted('a'), WorkoutCompleted('b')],
      );
      final c = container(completion: repo);
      final notifier = c.read(workoutCompletionControllerProvider.notifier);

      final f1 = notifier.complete('ses-1');
      final f2 = notifier.complete('ses-1'); // ignorováno (in-flight)
      await Future.wait([f1, f2]);

      expect(repo.completeCallCount, 1);
    });
  });

  group('history providery', () {
    test('completedWorkoutsProvider vrátí dokončené workouty', () async {
      final c = container(
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
        ),
      );
      final entries = await c.read(completedWorkoutsProvider.future);
      expect(entries.length, 1);
      expect(entries.first.workoutSessionId, 'ses-1');
    });

    test('completedWorkoutDetailProvider spojí entry a tracker', () async {
      final c = container(
        history: FakeWorkoutHistoryRepository(
          entries: [buildHistoryEntry(workoutSessionId: 'ses-1')],
        ),
        performance: FakeWorkoutPerformanceRepository(
          tracker: buildTracker(sessionId: 'ses-1'),
        ),
      );
      final detail = await c.read(
        completedWorkoutDetailProvider('ses-1').future,
      );
      expect(detail, isNotNull);
      expect(detail!.entry.workoutSessionId, 'ses-1');
      expect(detail.tracker.exercises, isNotEmpty);
    });

    test(
      'completedWorkoutDetailProvider vrátí null pro neznámou session',
      () async {
        final c = container(
          history: FakeWorkoutHistoryRepository(entries: const []),
        );
        final detail = await c.read(
          completedWorkoutDetailProvider('ghost').future,
        );
        expect(detail, isNull);
      },
    );
  });
}
