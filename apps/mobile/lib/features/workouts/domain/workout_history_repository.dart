import 'workout_feedback.dart';
import 'workout_history.dart';

/// History read boundary (fyzický model §16/§21). Implementace patří do
/// data vrstvy. Bez sítě, bez mutace dat — jen čte dokončené workouty
/// z autoritativních lokálních zdrojů.
abstract interface class WorkoutHistoryRepository {
  /// Dokončené workouty deterministicky seřazené (nejnovější dokončení
  /// první). Bez aktivních ani budoucích workoutů.
  Future<List<WorkoutHistoryEntry>> completedWorkouts();

  /// Historický záznam podle ID dokončené session, nebo `null`.
  Future<WorkoutHistoryEntry?> completedWorkoutBySessionId(String sessionId);

  /// Uložený feedback session (reload do read-only detailu), nebo `null`,
  /// pokud uživatel feedback přeskočil.
  Future<WorkoutFeedbackSnapshot?> feedbackBySessionId(String sessionId);
}
