import 'complete_workout_result.dart';
import 'workout_feedback.dart';

/// Completion write boundary (fyzický model §15.3, §16).
///
/// Implementace patří do data vrstvy. `completeWorkout` je jedna atomická
/// transakce, která vynucuje idempotenci (opakování → alreadyCompleted,
/// žádný duplicitní ActivitySummary) a nikdy nevrací raw persistence
/// výjimku jako výsledek.
abstract interface class WorkoutCompletionRepository {
  /// Atomicky dokončí session daného ID: validuje stav, **uloží volitelný
  /// feedback (§15.3 krok 3)**, dopočítá dokončení kroků, přepne session i
  /// instanci do dokončeného stavu, vytvoří ActivitySummary (s feedback
  /// snapshotem `overall_effort`) a vyčistí active-session pointer. Zachovává
  /// planned i performance data. `feedback` je volitelný (lze přeskočit).
  /// Vrací typovaný výsledek.
  Future<CompleteWorkoutResult> completeWorkout({
    required String sessionId,
    required DateTime now,
    WorkoutFeedbackInput? feedback,
  });
}
