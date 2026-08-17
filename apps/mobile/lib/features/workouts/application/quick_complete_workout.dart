import '../domain/complete_workout_result.dart';
import '../domain/start_session_result.dart';
import '../domain/workout_completion_repository.dart';
import '../domain/workout_session_repository.dart';

/// Typovaný výsledek rychlého dokončení (C50 §3, CQC-005).
sealed class QuickCompleteResult {
  const QuickCompleteResult();
}

final class QuickCompleted extends QuickCompleteResult {
  const QuickCompleted(this.sessionId);
  final String sessionId;
}

/// Workout už je dokončený — idempotentní stav (CQC-005).
final class QuickAlreadyCompleted extends QuickCompleteResult {
  const QuickAlreadyCompleted();
}

/// Běží aktivní session jiného workoutu — druhá nevzniká (R1 zákon).
final class QuickBlockedByOtherSession extends QuickCompleteResult {
  const QuickBlockedByOtherSession();
}

final class QuickWorkoutNotFound extends QuickCompleteResult {
  const QuickWorkoutNotFound();
}

final class QuickCompleteFailed extends QuickCompleteResult {
  const QuickCompleteFailed();
}

/// Rychlé dokončení workoutu (C50 §3, CQC-003/004): výhradně existující
/// C22 operace v témže kroku — start session + okamžité dokončení.
/// Nevznikají žádné performance řádky; summary drží měřené hodnoty
/// (0 kroků, 0 s) — faktem je dokončení, nikdy vymyšlené metriky.
class QuickCompleteWorkout {
  const QuickCompleteWorkout(this._sessions, this._completion);

  final WorkoutSessionRepository _sessions;
  final WorkoutCompletionRepository _completion;

  Future<QuickCompleteResult> call(
    String workoutInstanceId, {
    required String newSessionId,
    required DateTime now,
  }) async {
    final started = await _sessions.startSession(
      workoutInstanceId: workoutInstanceId,
      newSessionId: newSessionId,
      now: now,
    );
    final sessionId = switch (started) {
      SessionCreated(:final sessionId) => sessionId,
      // Aktivní session téže instance se poctivě dokončí — nikdy druhá
      // session (CQC-006).
      SessionResumedExisting(:final sessionId) => sessionId,
      ConflictWithAnotherSession() => null,
      WorkoutNotFound() => null,
      WorkoutAlreadyFinished() => null,
    };
    if (sessionId == null) {
      return switch (started) {
        WorkoutNotFound() => const QuickWorkoutNotFound(),
        // Uzavřený workout (nález 9) = už dokončeno, poctivě bez další session.
        WorkoutAlreadyFinished() => const QuickAlreadyCompleted(),
        _ => const QuickBlockedByOtherSession(),
      };
    }
    final completed = await _completion.completeWorkout(
      sessionId: sessionId,
      now: now,
    );
    return switch (completed) {
      WorkoutCompleted() => QuickCompleted(sessionId),
      WorkoutAlreadyCompleted() => const QuickAlreadyCompleted(),
      _ => const QuickCompleteFailed(),
    };
  }
}
