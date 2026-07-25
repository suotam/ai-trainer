import '../domain/record_performance_result.dart';
import '../domain/workout_performance_repository.dart';

/// Use case přepnutí dokončení setu (COMPLETED ↔ PLANNED, R1-04).
///
/// Completion jednotlivého setu není completion session (R1-04 session
/// nedokončuje). Používá injektovaný clock pro completion timestamp.
class SetSetCompletion {
  const SetSetCompletion({required this.repository, required this.clock});

  final WorkoutPerformanceRepository repository;
  final DateTime Function() clock;

  Future<RecordPerformanceResult> call({
    required String setPerformanceId,
    required bool completed,
  }) => repository.setSetCompletion(
    setPerformanceId: setPerformanceId,
    completed: completed,
    now: clock(),
  );
}
