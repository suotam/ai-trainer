import 'workout_read_model.dart';

/// Read model boundary workout feature (fyzický model §16, §21).
///
/// Jediný podporovaný vstup application/presentation vrstvy k workout datům
/// (MAR-004) — implementace patří do data vrstvy.
abstract interface class WorkoutInstanceRepository {
  /// Workouty naplánované na dané lokální datum (`YYYY-MM-DD`).
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDate(String localDate);

  /// Workouty v uzavřeném rozsahu lokálních dat (týdenní přehled).
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDateRange(
    String fromLocalDate,
    String toLocalDate,
  );

  /// Kompletní stabilní snapshot instance, nebo `null` pokud neexistuje.
  Future<WorkoutInstanceDetail?> workoutInstanceById(String id);
}
