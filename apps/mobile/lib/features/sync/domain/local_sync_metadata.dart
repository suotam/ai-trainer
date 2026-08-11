/// Doménové modely lokálních sync metadat a outboxu (R2-01, kontrakty C2
/// `LSM-*` a C1 `MSM-*`). Neobsahují Drift typy (PDR-008). Foundation +
/// scaffolding: reprezentují lokální záměr změny, **nikoli** síťový přenos.
library;

/// Lokální sync stav vlastnitelné entity (C2 §5, `sync-and-offline-model
/// §11`). Neznámý kód je chyba dat, ne tichý default.
enum LocalSyncState {
  localOnly('LOCAL_ONLY'),
  dirty('DIRTY'),
  queued('QUEUED'),
  synced('SYNCED'),
  conflict('CONFLICT'),
  blocked('BLOCKED');

  const LocalSyncState(this.code);
  final String code;

  static LocalSyncState fromCode(String code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw ArgumentError('Neznámý LocalSyncState: $code'),
  );
}

/// Typ záměru změny v outboxu (C2 §6.2). Delete je vždy logický záměr,
/// nikdy tiché fyzické smazání potvrzených dat (LSM-006).
enum OutboxOperationType {
  create('CREATE'),
  update('UPDATE'),
  delete('DELETE');

  const OutboxOperationType(this.code);
  final String code;

  static OutboxOperationType fromCode(String code) => values.firstWhere(
    (t) => t.code == code,
    orElse: () => throw ArgumentError('Neznámý OutboxOperationType: $code'),
  );
}

/// Záměr změny vlastnitelné entity ke zpracování (lokální projekce
/// `OfflineCommand`, C2 §6.1). `idempotencyKey` je stabilní (LSM-008) —
/// stejná logická operace si drží stejný klíč napříč opakováním.
class OutboxOperation {
  const OutboxOperation({
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.idempotencyKey,
  });

  final String entityType;
  final String entityId;
  final OutboxOperationType operationType;
  final String idempotencyKey;
}

/// Perzistovaná outbox položka (restart-safe, C2 §6.3/§7). `sequence` drží
/// deterministické lokální pořadí (LSM-012).
class OutboxEntry {
  const OutboxEntry({
    required this.id,
    required this.ownerId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.idempotencyKey,
    required this.sequence,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String entityType;
  final String entityId;
  final OutboxOperationType operationType;
  final String idempotencyKey;
  final int sequence;
  final String status;
  final DateTime createdAt;
}
