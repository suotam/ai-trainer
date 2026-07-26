import '../domain/complete_workout_result.dart';
import '../domain/workout_completion_repository.dart';
import '../domain/workout_feedback.dart';

/// Dokončení workoutu (VSP §17/§18, fyzický model §15.3).
///
/// Application vrstva bez Flutter/Drift/backend závislosti. Deleguje atomický
/// zápis repository (včetně volitelného feedbacku, §15.3 krok 3) a používá
/// injektovaný clock pro completion timestamp. Vrací typovaný výsledek; raw
/// persistence výjimka se nechytá zde — zachytí ji controller a přemapuje na
/// bezpečný UI stav.
class CompleteWorkout {
  const CompleteWorkout({required this.repository, required this.clock});

  final WorkoutCompletionRepository repository;
  final DateTime Function() clock;

  Future<CompleteWorkoutResult> call({
    required String sessionId,
    WorkoutFeedbackInput? feedback,
  }) {
    return repository.completeWorkout(
      sessionId: sessionId,
      now: clock(),
      feedback: feedback,
    );
  }
}
