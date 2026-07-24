import '../../../core/ids/id_generator.dart';
import '../domain/start_session_result.dart';
import '../domain/workout_session_repository.dart';

/// Use case zahájení WorkoutSession (fyzický model §15.1, workout-model §29).
///
/// Bez Flutter a bez backend závislosti. Generuje stabilní session ID,
/// používá injektovaný clock a deleguje atomický start na repository, které
/// vynucuje invariant jedné aktivní session. Vrací typovaný výsledek —
/// nikdy raw persistence výjimku.
class StartWorkoutSession {
  const StartWorkoutSession({
    required this.repository,
    required this.idGenerator,
    required this.clock,
  });

  final WorkoutSessionRepository repository;
  final IdGenerator idGenerator;
  final DateTime Function() clock;

  Future<StartSessionResult> call(String workoutInstanceId) {
    return repository.startSession(
      workoutInstanceId: workoutInstanceId,
      newSessionId: idGenerator.newId(),
      now: clock(),
    );
  }
}
