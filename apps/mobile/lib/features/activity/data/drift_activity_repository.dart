import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/calendar_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/activity_repository.dart';
import '../domain/manual_activity.dart';

/// Drift implementace ručních aktivit a statistik (R3-06, C22/C23).
///
/// Owner stamping při zápisu (C16 §6.2); statistiky jsou čistý read model
/// bez perzistence a vedlejších efektů (PST-001/013), device-local scope
/// (PST-008 — konzistentní s Today/kalendářem).
class DriftActivityRepository implements ActivityRepository {
  DriftActivityRepository(this._db);

  final AppDatabase _db;

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<List<ManualActivity>> activitiesForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows =
        await (_db.select(_db.localActivities)
              ..where((t) => t.ownerId.equals(owner))
              ..orderBy([
                (t) => OrderingTerm.desc(t.localDate),
                (t) => OrderingTerm.asc(t.title),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return [
      for (final row in rows)
        ManualActivity(
          id: row.id,
          title: row.title,
          localDate: row.localDate,
          durationMinutes: row.durationMinutes,
          userSportId: row.userSportId,
          workoutInstanceId: row.workoutInstanceId,
          note: row.note,
        ),
    ];
  }

  @override
  Future<ActivityWriteResult> saveActivity(
    ManualActivityInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      if (!await _isValid(input)) {
        return const ActivityWriteValidationFailed();
      }
      final owner = await _currentOwnerId();
      LocalActivityRow? existing;
      if (existingId != null) {
        existing = await (_db.select(
          _db.localActivities,
        )..where((t) => t.id.equals(existingId))).getSingleOrNull();
        if (existing == null || existing.ownerId != owner) {
          return const ActivityWriteNotFound();
        }
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final companion = LocalActivitiesCompanion(
        title: Value(input.title.trim()),
        localDate: Value(input.localDate),
        durationMinutes: Value(input.durationMinutes),
        userSportId: Value(input.userSportId),
        workoutInstanceId: Value(input.workoutInstanceId),
        note: Value(input.note),
        updatedAt: Value(nowMillis),
      );
      if (existing == null) {
        await _db
            .into(_db.localActivities)
            .insert(
              companion.copyWith(
                id: Value(newId),
                createdAt: Value(nowMillis),
                rowVersion: const Value(1),
                ownerId: Value(owner),
                syncState: const Value(syncStateLocalOnly),
              ),
            );
        return ActivityWriteSaved(newId);
      }
      await (_db.update(
        _db.localActivities,
      )..where((t) => t.id.equals(existing!.id))).write(
        companion.copyWith(
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return ActivityWriteSaved(existing.id);
    });
  }

  @override
  Future<ProgressStatistics> statisticsForPeriod({
    required String fromLocalDate,
    required String toLocalDate,
  }) async {
    Future<int> scalar(String sql, List<Variable> vars) async =>
        (await _db.customSelect(sql, variables: vars).getSingle())
                .data
                .values
                .first
            as int? ??
        0;

    final range = [
      Variable.withString(fromLocalDate),
      Variable.withString(toLocalDate),
    ];
    // Plán: instance v období mimo CANCELLED (PST-005).
    final planned = await scalar(
      'SELECT COUNT(*) FROM local_workout_instances '
      'WHERE scheduled_local_date BETWEEN ? AND ? '
      "AND status != '$instanceStatusCancelled'",
      range,
    );
    // Skutečnost: summaries s dokončením v období (PST-007). Dokončení se
    // mapuje na lokální den přes datum instance (R1 summary nemá lokální
    // datum; scheduled datum je deterministická aproximace P0).
    final completed = await scalar(
      'SELECT COUNT(*) FROM local_activity_summaries s '
      'JOIN local_workout_instances i ON s.workout_instance_id = i.id '
      'WHERE i.scheduled_local_date BETWEEN ? AND ?',
      range,
    );
    // Ruční aktivity bez vazby na instanci (PST-006 — dvojí započtení).
    final manualCount = await scalar(
      'SELECT COUNT(*) FROM local_activities '
      'WHERE local_date BETWEEN ? AND ? AND workout_instance_id IS NULL',
      range,
    );
    final manualMinutes = await scalar(
      'SELECT COALESCE(SUM(duration_minutes), 0) FROM local_activities '
      'WHERE local_date BETWEEN ? AND ? AND workout_instance_id IS NULL '
      'AND duration_minutes IS NOT NULL',
      range,
    );

    return ProgressStatistics(
      fromLocalDate: fromLocalDate,
      toLocalDate: toLocalDate,
      plannedCount: planned,
      completedCount: completed,
      manualActivityCount: manualCount,
      manualMinutes: manualMinutes,
    );
  }

  Future<bool> _isValid(ManualActivityInput input) async {
    if (input.title.trim().isEmpty ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.localDate)) {
      return false;
    }
    if (input.durationMinutes != null && input.durationMinutes! < 1) {
      return false;
    }
    // Device-local reference musí existovat (MAC-006).
    final sportId = input.userSportId;
    if (sportId != null) {
      final sport = await (_db.select(
        _db.localUserSports,
      )..where((t) => t.id.equals(sportId))).getSingleOrNull();
      if (sport == null) {
        return false;
      }
    }
    final instanceId = input.workoutInstanceId;
    if (instanceId != null) {
      final instance = await (_db.select(
        _db.localWorkoutInstances,
      )..where((t) => t.id.equals(instanceId))).getSingleOrNull();
      if (instance == null) {
        return false;
      }
    }
    return true;
  }
}
