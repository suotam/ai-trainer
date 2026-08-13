import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/plan_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/training_plan.dart';
import '../domain/training_plan_repository.dart';

/// Drift implementace ručního plánování (R3-04, C20).
///
/// Ruční workout je plnohodnotná R1 struktura v `local_workout_instances`
/// a children tabulkách (MPC-001) — vzniká atomicky v jedné transakci
/// (MPC-004). Owner stamping při zápisu (C16 §6.2).
class DriftTrainingPlanRepository implements TrainingPlanRepository {
  DriftTrainingPlanRepository(this._db);

  final AppDatabase _db;

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<List<TrainingPlan>> plansForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_training_plans WHERE owner_id = ? '
          "ORDER BY CASE status WHEN 'ACTIVE' THEN 0 ELSE 1 END, title, id",
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localTrainingPlans},
        )
        .get();
    return [
      for (final row in rows)
        TrainingPlan(
          id: row.data['id']! as String,
          title: row.data['title']! as String,
          status: row.data['status']! as String,
          note: row.data['note'] as String?,
        ),
    ];
  }

  @override
  Future<PlanWriteResult> createPlan({
    required String title,
    String? note,
    required String newId,
    required DateTime now,
  }) {
    if (title.trim().isEmpty) {
      return Future.value(const PlanWriteValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      if (await _hasActivePlan(owner, excludeId: '')) {
        return const PlanWriteActiveConflict();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.localTrainingPlans)
          .insert(
            LocalTrainingPlansCompanion.insert(
              id: newId,
              title: title.trim(),
              note: Value(note),
              createdAt: nowMillis,
              updatedAt: nowMillis,
              rowVersion: 1,
              ownerId: Value(owner),
            ),
          );
      return PlanWriteSaved(newId);
    });
  }

  @override
  Future<PlanWriteResult> renamePlan(
    String id, {
    required String title,
    String? note,
    required DateTime now,
  }) {
    if (title.trim().isEmpty) {
      return Future.value(const PlanWriteValidationFailed());
    }
    return _db.transaction(() async {
      final existing = await _ownedPlan(id);
      if (existing == null) {
        return const PlanWriteNotFound();
      }
      await (_db.update(
        _db.localTrainingPlans,
      )..where((t) => t.id.equals(id))).write(
        LocalTrainingPlansCompanion(
          title: Value(title.trim()),
          note: Value(note),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return PlanWriteSaved(id);
    });
  }

  @override
  Future<PlanWriteResult> setPlanStatus(
    String id,
    String status, {
    required DateTime now,
  }) {
    if (status != planStatusActive && status != planStatusArchived) {
      return Future.value(const PlanWriteValidationFailed());
    }
    return _db.transaction(() async {
      final existing = await _ownedPlan(id);
      if (existing == null) {
        return const PlanWriteNotFound();
      }
      if (existing.status == status) {
        return PlanWriteSaved(id);
      }
      if (status == planStatusActive &&
          await _hasActivePlan(existing.ownerId, excludeId: id)) {
        return const PlanWriteActiveConflict();
      }
      await (_db.update(
        _db.localTrainingPlans,
      )..where((t) => t.id.equals(id))).write(
        LocalTrainingPlansCompanion(
          status: Value(status),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return PlanWriteSaved(id);
    });
  }

  @override
  Future<PlanWriteResult> addWorkout(
    String planId,
    PlannedWorkoutInput input, {
    required String Function() newId,
    required DateTime now,
  }) {
    if (!_isValidWorkout(input)) {
      return Future.value(const PlanWriteValidationFailed());
    }
    return _db.transaction(() async {
      final plan = await _ownedPlan(planId);
      if (plan == null) {
        return const PlanWriteNotFound();
      }
      // Workout se přidává jen do ACTIVE plánu (archivovaný je uzavřený
      // záměr — MPC-003).
      if (plan.status != planStatusActive) {
        return const PlanWriteValidationFailed();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final instanceId = newId();

      await _db
          .into(_db.localWorkoutInstances)
          .insert(
            LocalWorkoutInstancesCompanion.insert(
              id: instanceId,
              title: input.title.trim(),
              description: Value(input.description),
              workoutType: input.workoutType,
              scheduledLocalDate: input.scheduledLocalDate,
              plannedDurationSeconds: Value(
                input.plannedDurationMinutes == null
                    ? null
                    : input.plannedDurationMinutes! * 60,
              ),
              status: 'READY',
              sourceType: userPlanSourceType,
              sourceReference: Value(planId),
              revisionNumber: 1,
              createdAt: nowMillis,
              updatedAt: nowMillis,
              rowVersion: 1,
              ownerId: Value(plan.ownerId),
              syncState: const Value(syncStateLocalOnly),
            ),
          );

      final sectionId = newId();
      await _db
          .into(_db.localWorkoutSections)
          .insert(
            LocalWorkoutSectionsCompanion.insert(
              id: sectionId,
              workoutInstanceId: instanceId,
              position: 0,
              title: 'Main',
              sectionType: 'MAIN',
              priority: 'REQUIRED',
              isOptional: false,
              createdAt: nowMillis,
              updatedAt: nowMillis,
            ),
          );

      for (var i = 0; i < input.exercises.length; i++) {
        final exercise = input.exercises[i];
        final stepId = newId();
        await _db
            .into(_db.localWorkoutSteps)
            .insert(
              LocalWorkoutStepsCompanion.insert(
                id: stepId,
                sectionId: sectionId,
                position: i,
                stepType: 'EXERCISE',
                title: exercise.title.trim(),
                priority: 'REQUIRED',
                isSkippable: false,
                prescriptionType: 'SET_REP',
                plannedRepetitions: Value(exercise.repetitions),
                plannedWeightKg: Value(exercise.weightKg),
                createdAt: nowMillis,
                updatedAt: nowMillis,
              ),
            );
        for (var setIndex = 0; setIndex < exercise.sets; setIndex++) {
          await _db
              .into(_db.localSetPlans)
              .insert(
                LocalSetPlansCompanion.insert(
                  id: newId(),
                  workoutStepId: stepId,
                  position: setIndex,
                  plannedRepetitions: Value(exercise.repetitions),
                  plannedWeightKg: Value(exercise.weightKg),
                ),
              );
        }
      }
      return PlanWriteSaved(instanceId);
    });
  }

  @override
  Future<List<PlannedWorkoutSummary>> workoutsForPlan(String planId) async {
    final rows = await _db
        .customSelect(
          'SELECT i.id, i.title, i.workout_type, i.scheduled_local_date, '
          'i.status, ('
          '  SELECT COUNT(*) FROM local_workout_steps st '
          '  JOIN local_workout_sections sec ON st.section_id = sec.id '
          "  WHERE sec.workout_instance_id = i.id AND st.step_type = 'EXERCISE'"
          ') AS exercise_count '
          'FROM local_workout_instances i '
          "WHERE i.source_type = '$userPlanSourceType' "
          'AND i.source_reference = ? '
          'ORDER BY i.scheduled_local_date, i.title, i.id',
          variables: [Variable.withString(planId)],
          readsFrom: {_db.localWorkoutInstances, _db.localWorkoutSteps},
        )
        .get();
    return [
      for (final row in rows)
        PlannedWorkoutSummary(
          instanceId: row.data['id']! as String,
          title: row.data['title']! as String,
          workoutType: row.data['workout_type']! as String,
          scheduledLocalDate: row.data['scheduled_local_date']! as String,
          status: row.data['status']! as String,
          exerciseCount: row.data['exercise_count']! as int,
        ),
    ];
  }

  Future<bool> _hasActivePlan(String owner, {required String excludeId}) async {
    final row = await _db
        .customSelect(
          'SELECT 1 FROM local_training_plans WHERE owner_id = ? '
          "AND status = '$planStatusActive' AND id != ? LIMIT 1",
          variables: [
            Variable.withString(owner),
            Variable.withString(excludeId),
          ],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<LocalTrainingPlanRow?> _ownedPlan(String id) async {
    final owner = await _currentOwnerId();
    final row = await (_db.select(
      _db.localTrainingPlans,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null || row.ownerId != owner) {
      return null;
    }
    return row;
  }

  bool _isValidWorkout(PlannedWorkoutInput input) {
    if (input.title.trim().isEmpty ||
        !manualWorkoutTypes.contains(input.workoutType) ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.scheduledLocalDate)) {
      return false;
    }
    if ((input.plannedDurationMinutes ?? 1) < 1) {
      return false;
    }
    for (final exercise in input.exercises) {
      if (exercise.title.trim().isEmpty ||
          exercise.sets < 1 ||
          exercise.repetitions < 1 ||
          (exercise.weightKg ?? 0) < 0) {
        return false;
      }
    }
    return true;
  }
}
