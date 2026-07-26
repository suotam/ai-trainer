import 'complete_workout_result.dart';

/// Completion write boundary (fyzický model §15.3, §16).
///
/// Implementace patří do data vrstvy. `completeWorkout` je jedna atomická
/// transakce, která vynucuje idempotenci (opakování → alreadyCompleted,
/// žádný duplicitní ActivitySummary) a nikdy nevrací raw persistence
/// výjimku jako výsledek.
abstract interface class WorkoutCompletionRepository {
  /// Atomicky dokončí session daného ID: validuje stav, dopočítá dokončení
  /// kroků, přepne session i instanci do dokončeného stavu, vytvoří
  /// ActivitySummary a vyčistí active-session pointer. Zachovává planned i
  /// performance data. Vrací typovaný výsledek.
  Future<CompleteWorkoutResult> completeWorkout({
    required String sessionId,
    required DateTime now,
  });
}
