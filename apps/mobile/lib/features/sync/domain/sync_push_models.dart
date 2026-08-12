import '../../auth/domain/auth_api_client.dart';

/// Push operace odeslaná na server (C10 §4) — 1:1 k outbox položce.
class SyncPushOperation {
  const SyncPushOperation({
    required this.operationId,
    required this.idempotencyKey,
    required this.sequence,
    required this.operationType,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.expectedServerVersion,
  });

  final String operationId;
  final String idempotencyKey;
  final int sequence;

  /// `CREATE_ENTITY` / `UPDATE_ENTITY` (C10 §5.1).
  final String operationType;
  final String entityType;
  final String entityId;
  final Map<String, Object?> payload;
  final int? expectedServerVersion;
}

/// Per-item výsledek serveru (C10 §7).
class SyncItemOutcome {
  const SyncItemOutcome({
    required this.operationId,
    required this.result,
    required this.serverVersion,
  });

  final String operationId;
  final String result;
  final int? serverVersion;
}

/// Klientská hranice push sync API (C10 §9). Selhání requestu jako celku
/// se mapují na typované [AuthApiFailure]; per-item výsledky jsou v těle.
abstract interface class SyncApiClient {
  Future<List<SyncItemOutcome>> push({
    required String accessToken,
    required String installationId,
    required List<SyncPushOperation> operations,
  });
}

/// Jedna entita připravená k push (state-based, C10 §5.3), v deterministickém
/// pořadí dle R1 hierarchie. `stateEntityType/Id` je aggregate root, jehož
/// `sync_state` výsledek položky reprezentuje (R2-01 — children jsou
/// vlastněny tranzitivně přes session).
class PlannedSyncEntity {
  const PlannedSyncEntity({
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.localRevision,
    required this.stateEntityType,
    required this.stateEntityId,
  });

  final String entityType;
  final String entityId;
  final Map<String, Object?> payload;

  /// Lokální revize pro stabilní idempotency key (LSM-008): stejný stav →
  /// stejný klíč napříč opakováním; nová lokální změna → nový klíč.
  final String localRevision;

  final String stateEntityType;
  final String stateEntityId;
}

/// Výsledek běhu sync engine — typovaný, bez raw HTTP detailu.
sealed class SyncRunResult {
  const SyncRunResult();
}

/// Bez přihlášení se nesynchronizuje (SPC-001); R1 tok běží dál offline.
final class SyncSkippedAnonymous extends SyncRunResult {
  const SyncSkippedAnonymous();
}

/// Server nedosažitelný — vše zůstává pending (SPC-012), žádný retry loop.
final class SyncRunFailed extends SyncRunResult {
  const SyncRunFailed(this.kind);

  final AuthApiFailureKind kind;
}

/// Dokončený běh s poctivými počty (odmítnuté položky nejsou „synced").
final class SyncRunCompleted extends SyncRunResult {
  const SyncRunCompleted({
    required this.synced,
    required this.conflicts,
    required this.rejected,
    required this.pending,
  });

  final int synced;
  final int conflicts;
  final int rejected;
  final int pending;
}
