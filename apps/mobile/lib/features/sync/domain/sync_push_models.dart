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

  /// Pull změn od kurzorů per typ (R6-01, C41 §2). Kurzor je neprůhledný
  /// server token (PSP-004); null = od začátku.
  Future<SyncPullResponse> pull({
    required String accessToken,
    required String installationId,
    required Map<String, String?> cursors,
    int? limit,
  });
}

/// PENDING DELETE záměr z outboxu (C44 §3) — řádek už lokálně neexistuje,
/// operace nese jen identitu a stabilní idempotency key.
class PendingDeleteOperation {
  const PendingDeleteOperation({
    required this.outboxId,
    required this.entityType,
    required this.entityId,
    required this.idempotencyKey,
    required this.sequence,
  });

  final String outboxId;
  final String entityType;
  final String entityId;
  final String idempotencyKey;
  final int sequence;
}

/// Jedna stažená změna (C41 §2) — payload jsou přesné sloupcové hodnoty
/// z push strany (PMS-003).
class SyncPullItem {
  const SyncPullItem({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    required this.payload,
    this.deleted = false,
  });

  final String entityType;
  final String entityId;
  final int serverVersion;
  final Map<String, Object?> payload;

  /// Tombstone příznak (C44, PSP-010).
  final bool deleted;
}

class SyncPullResponse {
  const SyncPullResponse({
    required this.items,
    required this.cursors,
    required this.hasMore,
  });

  final List<SyncPullItem> items;
  final Map<String, String?> cursors;
  final bool hasMore;
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

/// Konfliktní nebo odmítnutá položka čekající na uživatelské rozhodnutí
/// (C12 §4). `title` je lidský popis entity pro UI (CRC-011).
class UnresolvedSyncItem {
  const UnresolvedSyncItem({
    required this.outboxId,
    required this.entityType,
    required this.entityId,
    required this.stateEntityType,
    required this.stateEntityId,
    required this.isConflict,
    required this.title,
  });

  final String outboxId;
  final String entityType;
  final String entityId;
  final String stateEntityType;
  final String stateEntityId;

  /// `true` = VERSION_CONFLICT (USE_LOCAL povolen); `false` = rejection
  /// (`BLOCKED` — jen CANCEL, CRC-008).
  final bool isConflict;

  final String title;
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
