import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/goals_tables.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/goal.dart';
import '../domain/goal_repository.dart';

/// Drift implementace cílů (R3-02, C18).
///
/// Owner stamping při zápisu aktuálním lokálním vlastníkem (C16 §6.2);
/// lifecycle guardy (GLC-004/006) v transakci s typovanými výsledky.
class DriftGoalRepository implements GoalRepository {
  DriftGoalRepository(this._db);

  final AppDatabase _db;

  static const _statusOrder =
      "CASE status WHEN 'ACTIVE' THEN 0 WHEN 'PAUSED' THEN 1 "
      "WHEN 'COMPLETED' THEN 2 ELSE 3 END";
  static const _priorityOrder =
      "CASE priority WHEN 'PRIMARY' THEN 0 WHEN 'MAINTENANCE' THEN 1 "
      'ELSE 2 END';

  /// Povolené přechody (C18 §6.1) — terminální stavy jsou konečné.
  static const _allowedTransitions = {
    goalStatusActive: {
      goalStatusPaused,
      goalStatusCompleted,
      goalStatusAbandoned,
    },
    goalStatusPaused: {
      goalStatusActive,
      goalStatusCompleted,
      goalStatusAbandoned,
    },
  };

  Future<String> _currentOwnerId() async {
    final row = await (_db.select(
      _db.localAppState,
    )..where((t) => t.key.equals(localOwnerStateKey))).getSingleOrNull();
    return row?.value ?? localAnonymousOwnerId;
  }

  @override
  Future<List<Goal>> goalsForCurrentOwner() async {
    final owner = await _currentOwnerId();
    final rows = await _db
        .customSelect(
          'SELECT * FROM local_goals WHERE owner_id = ? '
          'ORDER BY $_statusOrder, $_priorityOrder, title, id',
          variables: [Variable.withString(owner)],
          readsFrom: {_db.localGoals},
        )
        .get();
    return [for (final row in rows) _toDomain(row.data)];
  }

  @override
  Future<SaveGoalResult> saveGoal(
    GoalInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      if (!await _isValid(input)) {
        return const GoalValidationFailed();
      }
      final owner = await _currentOwnerId();
      LocalGoalRow? existing;
      if (existingId != null) {
        existing = await (_db.select(
          _db.localGoals,
        )..where((t) => t.id.equals(existingId))).getSingleOrNull();
        if (existing == null || existing.ownerId != owner) {
          return const GoalNotFound();
        }
        // Terminální cíl je immutable záznam (GLC-006).
        if (existing.status == goalStatusCompleted ||
            existing.status == goalStatusAbandoned) {
          return const GoalInvalidTransition();
        }
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final companion = LocalGoalsCompanion(
        title: Value(input.title.trim()),
        goalType: Value(input.goalType),
        priority: Value(input.priority),
        horizon: Value(input.horizon),
        userSportId: Value(input.userSportId),
        targetLocalDate: Value(input.targetLocalDate),
        note: Value(input.note),
        updatedAt: Value(nowMillis),
      );

      if (existing == null) {
        await _db
            .into(_db.localGoals)
            .insert(
              companion.copyWith(
                id: Value(newId),
                status: const Value(goalStatusActive),
                createdAt: Value(nowMillis),
                rowVersion: const Value(1),
                ownerId: Value(owner),
                syncState: const Value(syncStateLocalOnly),
              ),
            );
        return GoalSaved(newId);
      }

      await (_db.update(
        _db.localGoals,
      )..where((t) => t.id.equals(existing!.id))).write(
        companion.copyWith(
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return GoalSaved(existing.id);
    });
  }

  @override
  Future<SaveGoalResult> changeStatus(
    String id,
    String newStatus, {
    required DateTime now,
  }) {
    if (!goalStatuses.contains(newStatus)) {
      return Future.value(const GoalValidationFailed());
    }
    return _db.transaction(() async {
      final owner = await _currentOwnerId();
      final existing = await (_db.select(
        _db.localGoals,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null || existing.ownerId != owner) {
        return const GoalNotFound();
      }
      if (existing.status == newStatus) {
        return GoalSaved(id);
      }
      final allowed = _allowedTransitions[existing.status] ?? const <String>{};
      if (!allowed.contains(newStatus)) {
        return const GoalInvalidTransition();
      }
      await (_db.update(_db.localGoals)..where((t) => t.id.equals(id))).write(
        LocalGoalsCompanion(
          status: Value(newStatus),
          updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
          rowVersion: Value(existing.rowVersion + 1),
          syncState: existing.syncState == 'SYNCED'
              ? const Value('DIRTY')
              : Value(existing.syncState),
        ),
      );
      return GoalSaved(id);
    });
  }

  Future<bool> _isValid(GoalInput input) async {
    if (input.title.trim().isEmpty) {
      return false;
    }
    if (!goalTypes.contains(input.goalType) ||
        !goalPriorities.contains(input.priority) ||
        !goalHorizons.contains(input.horizon)) {
      return false;
    }
    final date = input.targetLocalDate;
    if (date != null && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      return false;
    }
    final sportId = input.userSportId;
    if (sportId != null) {
      // Device-local reference (GLC-008) — resolvuje se bez owner filtru.
      final sport = await (_db.select(
        _db.localUserSports,
      )..where((t) => t.id.equals(sportId))).getSingleOrNull();
      if (sport == null) {
        return false;
      }
    }
    return true;
  }

  Goal _toDomain(Map<String, Object?> row) => Goal(
    id: row['id']! as String,
    title: row['title']! as String,
    goalType: row['goal_type']! as String,
    priority: row['priority']! as String,
    horizon: row['horizon']! as String,
    status: row['status']! as String,
    userSportId: row['user_sport_id'] as String?,
    targetLocalDate: row['target_local_date'] as String?,
    note: row['note'] as String?,
  );
}
