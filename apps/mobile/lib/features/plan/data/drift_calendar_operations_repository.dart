import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/calendar_tables.dart';
import '../../../core/database/tables/plan_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/calendar_operations.dart';
import '../domain/training_plan.dart';
import 'drift_training_plan_repository.dart';

/// Drift implementace kalendářních operací (R3-05, C21).
///
/// Guardy (CAL-001/002) a append-only evidence (CAL-003) v téže transakci;
/// nahrazení komponuje C20 vytvoření (vnořená Drift transakce = savepoint,
/// atomicita zachována — CAL-005).
class DriftCalendarOperationsRepository
    implements CalendarOperationsRepository {
  DriftCalendarOperationsRepository(this._db)
    : _planRepository = DriftTrainingPlanRepository(_db);

  final AppDatabase _db;
  final DriftTrainingPlanRepository _planRepository;

  @override
  Future<CalendarOpResult> moveWorkout(
    String instanceId,
    String targetLocalDate, {
    required String changeId,
    required DateTime now,
  }) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(targetLocalDate)) {
      return Future.value(const CalendarOpValidationFailed());
    }
    return _db.transaction(() async {
      final guarded = await _operableInstance(instanceId);
      if (guarded is! LocalWorkoutInstanceRow) {
        return guarded as CalendarOpResult;
      }
      // Zrušenou instanci nelze přesouvat (C21 §5).
      if (guarded.status == instanceStatusCancelled) {
        return const CalendarOpNotAllowed();
      }
      if (guarded.scheduledLocalDate == targetLocalDate) {
        // Idempotentní no-op bez evidence (CAL-006).
        return CalendarOpSaved(instanceId);
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _bumpInstance(
        guarded,
        LocalWorkoutInstancesCompanion(
          scheduledLocalDate: Value(targetLocalDate),
        ),
        nowMillis,
      );
      await _appendChange(
        changeId: changeId,
        instance: guarded,
        changeType: calendarChangeMoved,
        fromLocalDate: guarded.scheduledLocalDate,
        toLocalDate: targetLocalDate,
        nowMillis: nowMillis,
      );
      return CalendarOpSaved(instanceId);
    });
  }

  @override
  Future<CalendarOpResult> cancelWorkout(
    String instanceId, {
    required String changeId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final guarded = await _operableInstance(instanceId);
      if (guarded is! LocalWorkoutInstanceRow) {
        return guarded as CalendarOpResult;
      }
      if (guarded.status == instanceStatusCancelled) {
        // Idempotentní no-op bez duplicitní evidence (CAL-006).
        return CalendarOpSaved(instanceId);
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _bumpInstance(
        guarded,
        const LocalWorkoutInstancesCompanion(
          status: Value(instanceStatusCancelled),
        ),
        nowMillis,
      );
      await _appendChange(
        changeId: changeId,
        instance: guarded,
        changeType: calendarChangeCancelled,
        nowMillis: nowMillis,
      );
      return CalendarOpSaved(instanceId);
    });
  }

  @override
  Future<CalendarOpResult> replaceWorkout(
    String instanceId,
    PlannedWorkoutInput replacement, {
    required String Function() newId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final guarded = await _operableInstance(instanceId);
      if (guarded is! LocalWorkoutInstanceRow) {
        return guarded as CalendarOpResult;
      }
      if (guarded.status == instanceStatusCancelled) {
        return const CalendarOpNotAllowed();
      }
      final planId = guarded.sourceReference;
      if (planId == null) {
        return const CalendarOpNotAllowed();
      }
      // Náhrada vzniká C20 cestou (CAL-011) — validace vstupu vč. plánu.
      final created = await _planRepository.addWorkout(
        planId,
        replacement,
        newId: newId,
        now: now,
      );
      if (created is! PlanWriteSaved) {
        return const CalendarOpValidationFailed();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _bumpInstance(
        guarded,
        const LocalWorkoutInstancesCompanion(
          status: Value(instanceStatusCancelled),
        ),
        nowMillis,
      );
      await _appendChange(
        changeId: newId(),
        instance: guarded,
        changeType: calendarChangeReplaced,
        replacementInstanceId: created.id,
        nowMillis: nowMillis,
      );
      return CalendarOpSaved(created.id);
    });
  }

  @override
  Future<List<CalendarChangeEntry>> changesForInstance(
    String instanceId,
  ) async {
    final rows =
        await (_db.select(_db.localCalendarChanges)
              ..where((t) => t.workoutInstanceId.equals(instanceId))
              ..orderBy([
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return [
      for (final row in rows)
        CalendarChangeEntry(
          id: row.id,
          workoutInstanceId: row.workoutInstanceId,
          changeType: row.changeType,
          fromLocalDate: row.fromLocalDate,
          toLocalDate: row.toLocalDate,
          replacementInstanceId: row.replacementInstanceId,
        ),
    ];
  }

  /// Guardy C21 §5: vrací instanci, nebo typovaný výsledek selhání.
  Future<Object> _operableInstance(String instanceId) async {
    final ownerRow = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    final owner = ownerRow?.value ?? localAnonymousOwnerId;

    final instance = await (_db.select(
      _db.localWorkoutInstances,
    )..where((t) => t.id.equals(instanceId))).getSingleOrNull();
    if (instance == null || instance.ownerId != owner) {
      return const CalendarOpNotFound();
    }
    // Jen ručně plánované instance (CAL-001) — seed/demo je read-only.
    if (instance.sourceType != userPlanSourceType) {
      return const CalendarOpNotAllowed();
    }
    // Fakta jsou nedotknutelná (CAL-002): žádná session, nedokončená.
    if (instance.startedSessionId != null ||
        instance.status == 'COMPLETED' ||
        instance.status == 'PARTIALLY_COMPLETED') {
      return const CalendarOpNotAllowed();
    }
    final session = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.workoutInstanceId.equals(instanceId))).get();
    if (session.isNotEmpty) {
      return const CalendarOpNotAllowed();
    }
    return instance;
  }

  Future<void> _bumpInstance(
    LocalWorkoutInstanceRow instance,
    LocalWorkoutInstancesCompanion change,
    int nowMillis,
  ) async {
    await (_db.update(
      _db.localWorkoutInstances,
    )..where((t) => t.id.equals(instance.id))).write(
      change.copyWith(
        updatedAt: Value(nowMillis),
        rowVersion: Value(instance.rowVersion + 1),
        syncState: instance.syncState == 'SYNCED'
            ? const Value('DIRTY')
            : Value(instance.syncState),
      ),
    );
  }

  Future<void> _appendChange({
    required String changeId,
    required LocalWorkoutInstanceRow instance,
    required String changeType,
    String? fromLocalDate,
    String? toLocalDate,
    String? replacementInstanceId,
    required int nowMillis,
  }) async {
    await _db
        .into(_db.localCalendarChanges)
        .insert(
          LocalCalendarChangesCompanion.insert(
            id: changeId,
            workoutInstanceId: instance.id,
            changeType: changeType,
            fromLocalDate: Value(fromLocalDate),
            toLocalDate: Value(toLocalDate),
            replacementInstanceId: Value(replacementInstanceId),
            createdAt: nowMillis,
            ownerId: Value(instance.ownerId),
          ),
        );
  }
}
