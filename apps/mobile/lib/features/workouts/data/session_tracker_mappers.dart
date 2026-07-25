/// Mapping performance Drift řádků na tracker read model (fyzický model
/// §16). Neznámý status je chyba dat, nikoli tichý default (PDR-008).
library;

import '../../../core/database/app_database.dart';
import '../domain/session_tracker.dart';
import '../domain/workout_read_model.dart';

SetPerformanceStatus decodeSetPerformanceStatus(String code) {
  for (final value in SetPerformanceStatus.values) {
    if (value.code == code) {
      return value;
    }
  }
  throw UnsupportedPersistedValue('local_set_performances.status', code);
}

TrackerSet mapTrackerSet(
  LocalSetPerformanceRow row, {
  required LocalSetPlanRow? plan,
}) => TrackerSet(
  setPerformanceId: row.id,
  position: row.position,
  status: decodeSetPerformanceStatus(row.status),
  plannedRepetitions: plan?.plannedRepetitions,
  plannedWeightKg: plan?.plannedWeightKg,
  actualRepetitions: row.actualRepetitions,
  actualWeightKg: row.actualWeightKg,
);

TrackerExercise mapTrackerExercise({
  required LocalStepPerformanceRow stepPerformance,
  required LocalWorkoutStepRow step,
  required String sectionTitle,
  required List<LocalSetPerformanceRow> setRows,
  required Map<String, LocalSetPlanRow> planById,
}) {
  final sets =
      setRows
          .map(
            (row) => mapTrackerSet(
              row,
              plan: row.setPlanId == null ? null : planById[row.setPlanId],
            ),
          )
          .toList(growable: false)
        ..sort((a, b) => a.position.compareTo(b.position));
  return TrackerExercise(
    stepPerformanceId: stepPerformance.id,
    stepId: step.id,
    title: step.title,
    sectionTitle: sectionTitle,
    sets: sets,
  );
}
