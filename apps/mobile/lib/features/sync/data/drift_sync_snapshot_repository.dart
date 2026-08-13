import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables/workout_tables.dart';
import '../domain/local_owner_binding.dart';
import '../domain/sync_push_models.dart';
import '../domain/sync_snapshot_repository.dart';

/// Drift implementace push snapshotu (R2-05). Payload je plný stav řádku
/// (state-based, C10 §5.3) v camelCase polích odpovídajících backend
/// registry parent polí (workoutInstanceId/workoutSessionId/
/// stepPerformanceId). Server payload v P0 nereinterpretuje (C6 §8.4).
class DriftSyncSnapshotRepository implements SyncSnapshotRepository {
  DriftSyncSnapshotRepository(this._db);

  final AppDatabase _db;

  static const _pendingStates = ['LOCAL_ONLY', 'DIRTY'];

  @override
  Future<List<PlannedSyncEntity>> collectPendingEntities(String ownerId) async {
    final planned = <PlannedSyncEntity>[];
    final salts = await _useLocalSalts();

    final instances =
        await (_db.select(_db.localWorkoutInstances)
              ..where(
                (t) =>
                    t.ownerId.equals(ownerId) &
                    t.syncState.isIn(_pendingStates),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    for (final row in instances) {
      planned.add(
        PlannedSyncEntity(
          entityType: 'WORKOUT_INSTANCE',
          entityId: row.id,
          payload: _instancePayload(row),
          localRevision: _withSalt(
            salts,
            'WORKOUT_INSTANCE',
            row.id,
            'v${row.rowVersion}',
          ),
          stateEntityType: 'WORKOUT_INSTANCE',
          stateEntityId: row.id,
        ),
      );
    }

    final sessions =
        await (_db.select(_db.localWorkoutSessions)
              ..where(
                (t) =>
                    t.ownerId.equals(ownerId) &
                    t.syncState.isIn(_pendingStates),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    for (final session in sessions) {
      planned.add(
        PlannedSyncEntity(
          entityType: 'WORKOUT_SESSION',
          entityId: session.id,
          payload: _sessionPayload(session),
          localRevision: _withSalt(
            salts,
            'WORKOUT_SESSION',
            session.id,
            'v${session.rowVersion}',
          ),
          stateEntityType: 'WORKOUT_SESSION',
          stateEntityId: session.id,
        ),
      );
      // Children jsou vlastněny tranzitivně přes session (R2-01) a pushují
      // se spolu s ní v pořadí R1 hierarchie.
      final steps =
          await (_db.select(_db.localStepPerformances)
                ..where((t) => t.workoutSessionId.equals(session.id))
                ..orderBy([(t) => OrderingTerm.asc(t.id)]))
              .get();
      for (final step in steps) {
        planned.add(
          PlannedSyncEntity(
            entityType: 'STEP_PERFORMANCE',
            entityId: step.id,
            payload: _stepPayload(step),
            localRevision: _withSalt(
              salts,
              'STEP_PERFORMANCE',
              step.id,
              'v${step.rowVersion}',
            ),
            stateEntityType: 'WORKOUT_SESSION',
            stateEntityId: session.id,
          ),
        );
        final sets =
            await (_db.select(_db.localSetPerformances)
                  ..where((t) => t.stepPerformanceId.equals(step.id))
                  ..orderBy([(t) => OrderingTerm.asc(t.position)]))
                .get();
        for (final set in sets) {
          planned.add(
            PlannedSyncEntity(
              entityType: 'SET_PERFORMANCE',
              entityId: set.id,
              payload: _setPayload(set),
              localRevision: _withSalt(
                salts,
                'SET_PERFORMANCE',
                set.id,
                'v${set.rowVersion}',
              ),
              stateEntityType: 'WORKOUT_SESSION',
              stateEntityId: session.id,
            ),
          );
        }
      }
      final feedbackRows = await (_db.select(
        _db.localWorkoutFeedback,
      )..where((t) => t.workoutSessionId.equals(session.id))).get();
      for (final feedback in feedbackRows) {
        planned.add(
          PlannedSyncEntity(
            entityType: 'WORKOUT_FEEDBACK',
            entityId: feedback.id,
            payload: _feedbackPayload(feedback),
            localRevision: _withSalt(
              salts,
              'WORKOUT_FEEDBACK',
              feedback.id,
              'u${feedback.updatedAt}',
            ),
            stateEntityType: 'WORKOUT_SESSION',
            stateEntityId: session.id,
          ),
        );
      }
    }

    final summaries =
        await (_db.select(_db.localActivitySummaries)
              ..where(
                (t) =>
                    t.ownerId.equals(ownerId) &
                    t.syncState.isIn(_pendingStates),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    for (final summary in summaries) {
      planned.add(
        PlannedSyncEntity(
          entityType: 'ACTIVITY_SUMMARY',
          entityId: summary.id,
          payload: _summaryPayload(summary),
          localRevision: _withSalt(
            salts,
            'ACTIVITY_SUMMARY',
            summary.id,
            'c${summary.createdAt}',
          ),
          stateEntityType: 'ACTIVITY_SUMMARY',
          stateEntityId: summary.id,
        ),
      );
    }

    return planned;
  }

  @override
  Future<int?> serverVersion(String entityType, String entityId) async {
    final row =
        await (_db.select(_db.localSyncedVersions)..where(
              (t) =>
                  t.entityType.equals(entityType) & t.entityId.equals(entityId),
            ))
            .getSingleOrNull();
    return row?.serverVersion;
  }

  @override
  Future<void> storeServerVersion(
    String entityType,
    String entityId,
    int serverVersion, {
    required DateTime now,
  }) async {
    await _db
        .into(_db.localSyncedVersions)
        .insertOnConflictUpdate(
          LocalSyncedVersionsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            serverVersion: serverVersion,
            updatedAt: now.toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<void> markRootSyncState(
    String entityType,
    String entityId,
    String syncState,
  ) async {
    final table = switch (entityType) {
      'WORKOUT_INSTANCE' => 'local_workout_instances',
      'WORKOUT_SESSION' => 'local_workout_sessions',
      'ACTIVITY_SUMMARY' => 'local_activity_summaries',
      _ => throw ArgumentError('Not an aggregate root: $entityType'),
    };
    await _db.customStatement('UPDATE $table SET sync_state = ? WHERE id = ?', [
      syncState,
      entityId,
    ]);
  }

  @override
  Future<void> markOutboxStatus(String outboxId, String status) async {
    await (_db.update(_db.localOutbox)..where((t) => t.id.equals(outboxId)))
        .write(LocalOutboxCompanion(status: Value(status)));
  }

  @override
  Future<List<UnresolvedSyncItem>> unresolvedItems(String ownerId) async {
    final resolvedIds = (await _db.select(_db.localSyncResolutions).get())
        .map((r) => r.outboxId)
        .toSet();
    final rows =
        await (_db.select(_db.localOutbox)
              ..where(
                (t) =>
                    t.status.isIn(const ['CONFLICT', 'BLOCKED']) &
                    t.ownerId.equals(ownerId),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
            .get();
    final items = <UnresolvedSyncItem>[];
    for (final row in rows.where((r) => !resolvedIds.contains(r.id))) {
      items.add(
        UnresolvedSyncItem(
          outboxId: row.id,
          entityType: row.entityType,
          entityId: row.entityId,
          stateEntityType: _stateTypeFor(row.entityType),
          stateEntityId: await _stateIdFor(row.entityType, row.entityId),
          isConflict: row.status == 'CONFLICT',
          title: await _titleFor(row.entityType, row.entityId),
        ),
      );
    }
    return items;
  }

  @override
  Future<void> recordResolution(
    String outboxId,
    String decision, {
    required DateTime now,
  }) async {
    await _db
        .into(_db.localSyncResolutions)
        .insertOnConflictUpdate(
          LocalSyncResolutionsCompanion.insert(
            outboxId: outboxId,
            decision: decision,
            resolvedAt: now.toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  /// Resolution-salt (CRC-005): počet USE_LOCAL rozhodnutí per entita.
  /// Vstupuje do lokální revize, takže rozhodnutí vytváří novou operaci
  /// s novým idempotency klíčem beze změny doménových dat.
  Future<Map<String, int>> _useLocalSalts() async {
    final rows = await _db
        .customSelect(
          'SELECT o.entity_type AS entity_type, o.entity_id AS entity_id, '
          'COUNT(*) AS cnt '
          'FROM local_sync_resolutions r '
          'JOIN local_outbox o ON o.id = r.outbox_id '
          "WHERE r.decision = 'USE_LOCAL' "
          'GROUP BY o.entity_type, o.entity_id',
        )
        .get();
    return {
      for (final row in rows)
        '${row.data['entity_type']}:${row.data['entity_id']}':
            row.data['cnt'] as int,
    };
  }

  String _withSalt(
    Map<String, int> salts,
    String entityType,
    String entityId,
    String revision,
  ) {
    final salt = salts['$entityType:$entityId'];
    return salt == null ? revision : '$revision-r$salt';
  }

  String _stateTypeFor(String entityType) => switch (entityType) {
    'WORKOUT_INSTANCE' => 'WORKOUT_INSTANCE',
    'ACTIVITY_SUMMARY' => 'ACTIVITY_SUMMARY',
    _ => 'WORKOUT_SESSION',
  };

  Future<String> _stateIdFor(String entityType, String entityId) async {
    switch (entityType) {
      case 'WORKOUT_INSTANCE':
      case 'WORKOUT_SESSION':
      case 'ACTIVITY_SUMMARY':
        return entityId;
      case 'STEP_PERFORMANCE':
        final row = await (_db.select(
          _db.localStepPerformances,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row?.workoutSessionId ?? entityId;
      case 'SET_PERFORMANCE':
        final set = await (_db.select(
          _db.localSetPerformances,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        if (set == null) {
          return entityId;
        }
        final step = await (_db.select(
          _db.localStepPerformances,
        )..where((t) => t.id.equals(set.stepPerformanceId))).getSingleOrNull();
        return step?.workoutSessionId ?? entityId;
      case 'WORKOUT_FEEDBACK':
        final row = await (_db.select(
          _db.localWorkoutFeedback,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return row?.workoutSessionId ?? entityId;
      default:
        return entityId;
    }
  }

  /// Lidský popis entity pro conflict UI (CRC-011): titul workoutu, nikdy
  /// technický diff.
  Future<String> _titleFor(String entityType, String entityId) async {
    Future<String?> instanceTitle(String instanceId) async =>
        (await (_db.select(
          _db.localWorkoutInstances,
        )..where((t) => t.id.equals(instanceId))).getSingleOrNull())?.title;
    switch (entityType) {
      case 'WORKOUT_INSTANCE':
        return await instanceTitle(entityId) ?? entityId;
      case 'ACTIVITY_SUMMARY':
        final summary = await (_db.select(
          _db.localActivitySummaries,
        )..where((t) => t.id.equals(entityId))).getSingleOrNull();
        return summary?.titleSnapshot ?? entityId;
      default:
        final sessionId = await _stateIdFor(entityType, entityId);
        final session = await (_db.select(
          _db.localWorkoutSessions,
        )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
        if (session == null) {
          return entityId;
        }
        return await instanceTitle(session.workoutInstanceId) ?? entityId;
    }
  }

  Map<String, Object?> _instancePayload(LocalWorkoutInstanceRow row) => {
    'id': row.id,
    'title': row.title,
    'description': row.description,
    'purpose': row.purpose,
    'workoutType': row.workoutType,
    'scheduledLocalDate': row.scheduledLocalDate,
    'scheduledStartAt': row.scheduledStartAt,
    'timeZoneId': row.timeZoneId,
    'plannedDurationSeconds': row.plannedDurationSeconds,
    'status': row.status,
    'sourceType': row.sourceType,
    'sourceReference': row.sourceReference,
    'revisionNumber': row.revisionNumber,
    'startedSessionId': row.startedSessionId,
    'completedAt': row.completedAt,
    'createdAt': row.createdAt,
    'updatedAt': row.updatedAt,
    'rowVersion': row.rowVersion,
  };

  Map<String, Object?> _sessionPayload(LocalWorkoutSessionRow row) => {
    'id': row.id,
    'workoutInstanceId': row.workoutInstanceId,
    'instanceRevisionNumber': row.instanceRevisionNumber,
    'status': row.status,
    'startedAt': row.startedAt,
    'lastResumedAt': row.lastResumedAt,
    'pausedAt': row.pausedAt,
    'completedAt': row.completedAt,
    'activeStepId': row.activeStepId,
    'elapsedActiveSeconds': row.elapsedActiveSeconds,
    'notes': row.notes,
    'createdAt': row.createdAt,
    'updatedAt': row.updatedAt,
    'rowVersion': row.rowVersion,
  };

  Map<String, Object?> _stepPayload(LocalStepPerformanceRow row) => {
    'id': row.id,
    'workoutSessionId': row.workoutSessionId,
    'workoutStepId': row.workoutStepId,
    'status': row.status,
    'startedAt': row.startedAt,
    'completedAt': row.completedAt,
    'actualRepetitions': row.actualRepetitions,
    'actualDurationSeconds': row.actualDurationSeconds,
    'actualDistanceMeters': row.actualDistanceMeters,
    'actualWeightKg': row.actualWeightKg,
    'perceivedExertion': row.perceivedExertion,
    'notes': row.notes,
    'updatedAt': row.updatedAt,
    'rowVersion': row.rowVersion,
  };

  Map<String, Object?> _setPayload(LocalSetPerformanceRow row) => {
    'id': row.id,
    'stepPerformanceId': row.stepPerformanceId,
    'setPlanId': row.setPlanId,
    'position': row.position,
    'status': row.status,
    'actualRepetitions': row.actualRepetitions,
    'actualWeightKg': row.actualWeightKg,
    'actualDurationSeconds': row.actualDurationSeconds,
    'actualRpe': row.actualRpe,
    'completedAt': row.completedAt,
    'notes': row.notes,
    'updatedAt': row.updatedAt,
    'rowVersion': row.rowVersion,
  };

  Map<String, Object?> _feedbackPayload(LocalWorkoutFeedbackRow row) => {
    'id': row.id,
    'workoutSessionId': row.workoutSessionId,
    'overallEffort': row.overallEffort,
    'feeling': row.feeling,
    'painReported': row.painReported,
    'notes': row.notes,
    'createdAt': row.createdAt,
    'updatedAt': row.updatedAt,
  };

  Map<String, Object?> _summaryPayload(LocalActivitySummaryRow row) => {
    'id': row.id,
    'workoutInstanceId': row.workoutInstanceId,
    'workoutSessionId': row.workoutSessionId,
    'titleSnapshot': row.titleSnapshot,
    'workoutType': row.workoutType,
    'startedAt': row.startedAt,
    'completedAt': row.completedAt,
    'activeDurationSeconds': row.activeDurationSeconds,
    'completedStepCount': row.completedStepCount,
    'totalStepCount': row.totalStepCount,
    'overallEffort': row.overallEffort,
    'createdAt': row.createdAt,
  };
}

/// Drift implementace vazby lokálního vlastníka (C2 §4): přepíše hodnotu
/// klíče `local_owner_id` v `local_app_state`. Nemění vlastnictví
/// existujících entit (attach vlastní C15).
class DriftLocalOwnerBinding implements LocalOwnerBinding {
  DriftLocalOwnerBinding(this._db, this._now);

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<void> bindAccount(String accountId) => _bind(accountId);

  @override
  Future<void> bindAnonymous() => _bind(localAnonymousOwnerId);

  Future<void> _bind(String ownerId) async {
    await _db
        .into(_db.localAppState)
        .insertOnConflictUpdate(
          LocalAppStateCompanion.insert(
            key: localOwnerStateKey,
            value: ownerId,
            updatedAt: _now().toUtc().millisecondsSinceEpoch,
          ),
        );
  }
}
