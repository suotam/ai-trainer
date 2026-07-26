import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/workout_history.dart';
import '../domain/workout_history_repository.dart';

/// Drift implementace history read modelu (fyzický model §13/§21).
///
/// Čte dokončené workouty z `local_activity_summaries` — read model
/// rekonstruovatelný z autoritativních dat (DAR-006). Bez mutace, bez sítě.
class DriftWorkoutHistoryRepository implements WorkoutHistoryRepository {
  DriftWorkoutHistoryRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<WorkoutHistoryEntry>> completedWorkouts() async {
    // Deterministické pořadí: nejnovější dokončení první, pak stabilně dle ID.
    final rows =
        await (_db.select(_db.localActivitySummaries)..orderBy([
              (t) => OrderingTerm.desc(t.completedAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    return rows.map(_mapEntry).toList(growable: false);
  }

  @override
  Future<WorkoutHistoryEntry?> completedWorkoutBySessionId(
    String sessionId,
  ) async {
    final row = await (_db.select(
      _db.localActivitySummaries,
    )..where((t) => t.workoutSessionId.equals(sessionId))).getSingleOrNull();
    return row == null ? null : _mapEntry(row);
  }

  WorkoutHistoryEntry _mapEntry(LocalActivitySummaryRow row) =>
      WorkoutHistoryEntry(
        activitySummaryId: row.id,
        workoutSessionId: row.workoutSessionId,
        workoutInstanceId: row.workoutInstanceId,
        title: row.titleSnapshot,
        workoutType: row.workoutType,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          row.startedAt,
          isUtc: true,
        ),
        completedAt: DateTime.fromMillisecondsSinceEpoch(
          row.completedAt,
          isUtc: true,
        ),
        completedStepCount: row.completedStepCount,
        totalStepCount: row.totalStepCount,
      );
}
