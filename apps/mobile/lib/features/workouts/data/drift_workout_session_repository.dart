import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/workout_tables.dart';
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

      // R2-05: start je uživatelská akce — session i instance vlastní
      // aktuální lokální vlastník (po přihlášení účet, C2 §4) a jsou
      // připraveny k push (state-based, C10 §5.3). Anonymní hodnota je
      // no-op vůči defaultům.
      await _db.customStatement(
        'UPDATE local_workout_sessions SET owner_id = '
        "COALESCE((SELECT value FROM local_app_state WHERE key = '$localOwnerStateKey'), '$localAnonymousOwnerId') "
        'WHERE id = ?',
        [newSessionId],
      );
      await _db.customStatement(
        'UPDATE local_workout_instances SET owner_id = '
        "COALESCE((SELECT value FROM local_app_state WHERE key = '$localOwnerStateKey'), '$localAnonymousOwnerId'), "
        "sync_state = CASE WHEN sync_state = 'SYNCED' THEN 'DIRTY' ELSE sync_state END "
        'WHERE id = ?',
        [workoutInstanceId],
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

  @override
  Future<List<WorkoutSessionSnapshot>> findActiveSessions() async {
    final rows =
        await (_db.select(_db.localWorkoutSessions)
              ..where((t) => t.status.isIn(const ['ACTIVE', 'PAUSED']))
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
            .get();
    return rows.map(mapSessionSnapshot).toList(growable: false);
  }

  @override
  Future<String?> readActiveSessionPointer() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(activeSessionKey))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<bool> reconcileActiveSessionPointer({
    required String sessionId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      // Re-derivace zdroje pravdy uvnitř transakce: pointer smí ukazovat jen
      // na jedinou aktuálně aktivní/pozastavenou session (fyzický model §19).
      final active = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.status.isIn(const ['ACTIVE', 'PAUSED']))).get();
      if (active.length != 1 || active.first.id != sessionId) {
        return false;
      }
      await _db
          .into(_db.localAppState)
          .insertOnConflictUpdate(
            LocalAppStateCompanion.insert(
              key: activeSessionKey,
              value: sessionId,
              updatedAt: now.toUtc().millisecondsSinceEpoch,
            ),
          );
      return true;
    });
  }

  @override
  Future<bool> workoutInstanceExists(String instanceId) async {
    final row = await (_db.select(
      _db.localWorkoutInstances,
    )..where((t) => t.id.equals(instanceId))).getSingleOrNull();
    return row != null;
  }
}
