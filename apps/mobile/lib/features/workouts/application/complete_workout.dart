import '../domain/complete_workout_result.dart';
import '../domain/workout_completion_repository.dart';

/// Dokončení workoutu (VSP §17, fyzický model §15.3).
///
/// Application vrstva bez Flutter/Drift/backend závislosti. Validuje vstup,
/// deleguje atomický zápis repository a používá injektovaný clock pro
/// completion timestamp. Vrací typovaný výsledek; raw persistence výjimka se
/// nechytá zde — zachytí ji controller a přemapuje na bezpečný UI stav.
class CompleteWorkout {
  const CompleteWorkout({required this.repository, required this.clock});

  final WorkoutCompletionRepository repository;
  final DateTime Function() clock;

  Future<CompleteWorkoutResult> call({required String sessionId}) {
    return repository.completeWorkout(sessionId: sessionId, now: clock());
  }
}
