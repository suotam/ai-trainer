import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/workout_instance_repository.dart';
import '../domain/workout_read_model.dart';
import 'workout_row_mappers.dart';

/// Drift implementace read modelu (fyzický model §16, §21).
class DriftWorkoutInstanceRepository implements WorkoutInstanceRepository {
  DriftWorkoutInstanceRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDate(String localDate) =>
      workoutsForLocalDateRange(localDate, localDate);

  @override
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDateRange(
    String fromLocalDate,
    String toLocalDate,
  ) async {
    final query = _db.select(_db.localWorkoutInstances)
      ..where(
        (t) => t.scheduledLocalDate.isBetweenValues(fromLocalDate, toLocalDate),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.scheduledLocalDate),
        (t) => OrderingTerm.asc(t.scheduledStartAt),
        (t) => OrderingTerm.asc(t.id),
      ]);
    final rows = await query.get();
    return rows.map(mapInstanceSummary).toList(growable: false);
  }

  @override
  Future<WorkoutInstanceDetail?> workoutInstanceById(String id) async {
    final instanceRow = await (_db.select(
      _db.localWorkoutInstances,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (instanceRow == null) {
      return null;
    }

    final sectionRows =
        await (_db.select(_db.localWorkoutSections)
              ..where((t) => t.workoutInstanceId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final sectionIds = sectionRows.map((s) => s.id).toList(growable: false);

    final stepRows = sectionIds.isEmpty
        ? <LocalWorkoutStepRow>[]
        : await (_db.select(_db.localWorkoutSteps)
                ..where((t) => t.sectionId.isIn(sectionIds))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
    final stepIds = stepRows.map((s) => s.id).toList(growable: false);

    final setPlanRows = stepIds.isEmpty
        ? <LocalSetPlanRow>[]
        : await (_db.select(_db.localSetPlans)
                ..where((t) => t.workoutStepId.isIn(stepIds))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();

    final setPlansByStep = <String, List<WorkoutSetPlan>>{};
    for (final row in setPlanRows) {
      setPlansByStep
          .putIfAbsent(row.workoutStepId, () => [])
          .add(mapSetPlan(row));
    }

    // R1 podporuje jednu úroveň vnoření: nejprve child kroky, pak rodiče.
    final childRowsByParent = <String, List<LocalWorkoutStepRow>>{};
    for (final row in stepRows.where((r) => r.parentStepId != null)) {
      childRowsByParent.putIfAbsent(row.parentStepId!, () => []).add(row);
    }

    WorkoutStep buildStep(LocalWorkoutStepRow row, {required bool isChild}) {
      final children = isChild
          ? const <WorkoutStep>[]
          : (childRowsByParent[row.id] ?? const [])
                .map((child) => buildStep(child, isChild: true))
                .toList(growable: false);
      return mapStep(
        row,
        setPlans: setPlansByStep[row.id] ?? const [],
        childSteps: children,
      );
    }

    final stepsBySection = <String, List<WorkoutStep>>{};
    for (final row in stepRows.where((r) => r.parentStepId == null)) {
      stepsBySection
          .putIfAbsent(row.sectionId, () => [])
          .add(buildStep(row, isChild: false));
    }

    final sections = sectionRows
        .map(
          (row) => mapSection(row, steps: stepsBySection[row.id] ?? const []),
        )
        .toList(growable: false);

    return mapInstanceDetail(instanceRow, sections: sections);
  }
}
