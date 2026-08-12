import '../../auth/domain/auth_api_client.dart';
import '../../auth/domain/secure_session_storage.dart';
import '../../device/domain/installation_identity_repository.dart';
import '../domain/local_sync_metadata.dart';
import '../domain/local_sync_metadata_repository.dart';
import '../domain/sync_push_models.dart';
import '../domain/sync_snapshot_repository.dart';

/// Push sync engine (R2-05, C10): state-based replay outboxu s potvrzením
/// výhradně po serverovém commitu (SPC-005). Spouští se explicitně —
/// žádný background loop ani automatický retry (SPC-015). Bez přihlášení
/// se nesynchronizuje (SPC-001); neúspěch nechává vše pending (SPC-012)
/// a odmítnutí je explicitní lokální stav, nikdy „synced" (SPC-006).
class SyncEngine {
  SyncEngine(
    this._storage,
    this._installationIdentity,
    this._metadata,
    this._snapshot,
    this._apiClient,
    this._now,
  );

  final SecureSessionStorage _storage;
  final InstallationIdentityRepository _installationIdentity;
  final LocalSyncMetadataRepository _metadata;
  final SyncSnapshotRepository _snapshot;
  final SyncApiClient _apiClient;
  final DateTime Function() _now;

  static const int _maxBatchSize = 200;

  Future<SyncRunResult> pushPending() async {
    final String accessToken;
    final String accountId;
    try {
      final stored = await _storage.read();
      if (stored == null) {
        return const SyncSkippedAnonymous();
      }
      accessToken = stored.accessToken;
      accountId = stored.accountId;
    } on SecureSessionStorageException {
      return const SyncSkippedAnonymous();
    }
    final installationId = await _installationIdentity.ensureInstallationId();

    final planned = await _snapshot.collectPendingEntities(accountId);
    if (planned.isEmpty) {
      return const SyncRunCompleted(
        synced: 0,
        conflicts: 0,
        rejected: 0,
        pending: 0,
      );
    }

    // Idempotentní enqueue (LSM-008/009): stabilní klíč per entita+revize —
    // opakovaný běh (i po restartu) drží stejné klíče, žádné duplicity.
    final now = _now();
    final entries = <String, OutboxEntry>{};
    final plannedByOperationId = <String, PlannedSyncEntity>{};
    for (final entity in planned) {
      final entry = await _metadata.enqueue(
        OutboxOperation(
          entityType: entity.entityType,
          entityId: entity.entityId,
          operationType:
              await _snapshot.serverVersion(
                    entity.entityType,
                    entity.entityId,
                  ) ==
                  null
              ? OutboxOperationType.create
              : OutboxOperationType.update,
          idempotencyKey:
              '${entity.entityType}:${entity.entityId}:${entity.localRevision}',
        ),
        now: now,
      );
      if (entry.status != 'PENDING') {
        // Tato revize už byla dřív rozhodnuta (SYNCED/CONFLICT/BLOCKED).
        continue;
      }
      entries[entry.id] = entry;
      plannedByOperationId[entry.id] = entity;
    }
    if (entries.isEmpty) {
      return const SyncRunCompleted(
        synced: 0,
        conflicts: 0,
        rejected: 0,
        pending: 0,
      );
    }

    final ordered = entries.values.toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    final toSend = ordered.take(_maxBatchSize).toList();
    final leftBehind = ordered.length - toSend.length;

    final operations = <SyncPushOperation>[];
    for (final entry in toSend) {
      final entity = plannedByOperationId[entry.id]!;
      final serverVersion = await _snapshot.serverVersion(
        entity.entityType,
        entity.entityId,
      );
      operations.add(
        SyncPushOperation(
          operationId: entry.id,
          idempotencyKey: entry.idempotencyKey,
          sequence: entry.sequence,
          operationType: serverVersion == null
              ? 'CREATE_ENTITY'
              : 'UPDATE_ENTITY',
          entityType: entity.entityType,
          entityId: entity.entityId,
          payload: entity.payload,
          expectedServerVersion: serverVersion,
        ),
      );
    }

    final List<SyncItemOutcome> outcomes;
    try {
      outcomes = await _apiClient.push(
        accessToken: accessToken,
        installationId: installationId,
        operations: operations,
      );
    } on AuthApiFailure catch (failure) {
      // Vše zůstává pending — replay je idempotentní (SPC-012).
      return SyncRunFailed(failure.kind);
    }

    var synced = 0;
    var conflicts = 0;
    var rejected = 0;
    var pending = leftBehind;
    // Rozhodnutí o sync_state aggregate rootů: konflikt > blocked > synced.
    final rootStates = <String, String>{};
    for (final outcome in outcomes) {
      final entity = plannedByOperationId[outcome.operationId];
      if (entity == null) {
        continue;
      }
      final rootKey = '${entity.stateEntityType}:${entity.stateEntityId}';
      switch (outcome.result) {
        case 'SUCCESS':
        case 'ALREADY_APPLIED':
          synced += 1;
          await _snapshot.storeServerVersion(
            entity.entityType,
            entity.entityId,
            outcome.serverVersion!,
            now: now,
          );
          await _snapshot.markOutboxStatus(outcome.operationId, 'SYNCED');
          rootStates.putIfAbsent(rootKey, () => 'SYNCED');
        case 'VERSION_CONFLICT':
          conflicts += 1;
          await _snapshot.markOutboxStatus(outcome.operationId, 'CONFLICT');
          rootStates[rootKey] = 'CONFLICT';
        case 'VALIDATION_FAILED':
        case 'PERMISSION_DENIED':
          rejected += 1;
          await _snapshot.markOutboxStatus(outcome.operationId, 'BLOCKED');
          if (rootStates[rootKey] != 'CONFLICT') {
            rootStates[rootKey] = 'BLOCKED';
          }
        default:
          // DEPENDENCY_FAILED a neznámé výsledky zůstávají pending;
          // root se v tomto běhu nepotvrzuje.
          pending += 1;
          if (rootStates[rootKey] == 'SYNCED') {
            rootStates.remove(rootKey);
          }
      }
    }
    for (final entry in rootStates.entries) {
      final separator = entry.key.indexOf(':');
      await _snapshot.markRootSyncState(
        entry.key.substring(0, separator),
        entry.key.substring(separator + 1),
        entry.value,
      );
    }
    return SyncRunCompleted(
      synced: synced,
      conflicts: conflicts,
      rejected: rejected,
      pending: pending,
    );
  }
}
