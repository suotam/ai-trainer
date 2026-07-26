import 'package:ai_trainer_mobile/features/workouts/application/complete_workout.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// CompleteWorkout use case (VSP §17) — bez widgetů a bez sítě (QTR-003).
void main() {
  final now = DateTime.utc(2026, 7, 20, 9);

  CompleteWorkout useCase(FakeWorkoutCompletionRepository repo) =>
      CompleteWorkout(repository: repo, clock: () => now);

  test('deleguje na repository s injektovaným clockem', () async {
    final repo = FakeWorkoutCompletionRepository(
      script: const [WorkoutCompleted('sum-9')],
    );

    final result = await useCase(repo).call(sessionId: 'ses-1');

    expect(result, isA<WorkoutCompleted>());
    expect((result as WorkoutCompleted).activitySummaryId, 'sum-9');
    expect(repo.completeCallCount, 1);
    expect(repo.lastSessionId, 'ses-1');
    expect(repo.lastNow, now);
  });

  test('propaguje typovaný alreadyCompleted výsledek', () async {
    final repo = FakeWorkoutCompletionRepository(
      script: const [WorkoutAlreadyCompleted()],
    );

    final result = await useCase(repo).call(sessionId: 'ses-1');

    expect(result, isA<WorkoutAlreadyCompleted>());
  });

  test('propaguje typované chybové výsledky', () async {
    for (final scripted in const <CompleteWorkoutResult>[
      CompletionSessionNotFound(),
      CompletionSessionNotCompletable(),
      CompletionInstanceNotFound(),
      CompletionInconsistentState(),
    ]) {
      final repo = FakeWorkoutCompletionRepository(script: [scripted]);
      final result = await useCase(repo).call(sessionId: 'ses-1');
      expect(result.runtimeType, scripted.runtimeType);
    }
  });
}
