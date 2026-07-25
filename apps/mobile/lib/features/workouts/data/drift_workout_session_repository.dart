import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/start_session_result.dart';
import '../domain/workout_session.dart';
import '../domain/workout_session_repository.dart';
import 'workout_session_row_mappers.dart';

/// Drift implementace session persistence (fyzický model §15.1).
///
/// Start je jedna atomická transakce: ověření instance, kontrola globálně
/// aktivní session, vytvoření session, přepnutí instance na `IN_PROGRESS`
/// a uložení active-session pointeru. Partial unique index
/// `idx_one_active_session_per_instance` je poslední linií ochrany invariantu.
class DriftWorkoutSessionRepository implements WorkoutSessionRepository {
  DriftWorkoutSessionRepository(this._db);

  final AppDatabase _db;

  static const String activeSessionKey = 'active_session_id';

  @override
  Future<StartSessionResult> startSession({
    required String workoutInstanceId,
    required String newSessionId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final instance = await (_db.select(
        _db.localWorkoutInstances,
      )..where((t) => t.id.equals(workoutInstanceId))).getSingleOrNull();
      if (instance == null) {
        return const WorkoutNotFound();
      }

      // Globální invariant: nejvýše jedna aktivní/pozastavená session.
      final active = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.status.isIn(const ['ACTIVE', 'PAUSED']))).get();
      if (active.isNotEmpty) {
        final existing = active.first;
        if (existing.workoutInstanceId == workoutInstanceId) {
          return SessionResumedExisting(existing.id);
        }
        return ConflictWithAnotherSession(
          activeSessionId: existing.id,
          activeWorkoutInstanceId: existing.workoutInstanceId,
        );
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await _db
          .into(_db.localWorkoutSessions)
          .insert(
            LocalWorkoutSessionsCompanion.insert(
              id: newSessionId,
              workoutInstanceId: workoutInstanceId,
              instanceRevisionNumber: instance.revisionNumber,
              status: 'ACTIVE',
              startedAt: nowMillis,
              lastResumedAt: Value(nowMillis),
              elapsedActiveSeconds: 0,
              createdAt: nowMillis,
              updatedAt: nowMillis,
              rowVersion: 1,
            ),
          );

      await (_db.update(
        _db.localWorkoutInstances,
      )..where((t) => t.id.equals(workoutInstanceId))).write(
        LocalWorkoutInstancesCompanion(
          status: const Value('IN_PROGRESS'),
          startedSessionId: Value(newSessionId),
          updatedAt: Value(nowMillis),
          rowVersion: Value(instance.rowVersion + 1),
        ),
      );

      await _db
          .into(_db.localAppState)
          .insertOnConflictUpdate(
            LocalAppStateCompanion.insert(
              key: activeSessionKey,
              value: newSessionId,
              updatedAt: nowMillis,
            ),
          );

      return SessionCreated(newSessionId);
    });
  }

  @override
  Future<WorkoutSessionSnapshot?> findActiveSession() async {
    final rows =
        await (_db.select(_db.localWorkoutSessions)
              ..where((t) => t.status.isIn(const ['ACTIVE', 'PAUSED']))
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)])
              ..limit(1))
            .get();
    if (rows.isEmpty) {
      return null;
    }
    return mapSessionSnapshot(rows.first);
  }

  @override
  Future<WorkoutSessionSnapshot?> sessionById(String id) async {
    final row = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : mapSessionSnapshot(row);
  }
}
