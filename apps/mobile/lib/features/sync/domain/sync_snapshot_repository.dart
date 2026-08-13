import 'sync_push_models.dart';

/// Snapshot lokálních dat k push a aplikace potvrzených výsledků (R2-05).
///
/// Implementace patří do data vrstvy. Čtení je state-based (C10 §5.3);
/// zápis stavů se řídí SPC-005/006: `SYNCED` vzniká výhradně z potvrzené
/// odpovědi, odmítnutí je explicitní stav, nikdy tiché zahození.
abstract interface class SyncSnapshotRepository {
  /// Entity vlastněné [ownerId] se sync_state `LOCAL_ONLY`/`DIRTY`
  /// v deterministickém pořadí R1 hierarchie: instance → session →
  /// step performance → set performance → feedback → summary.
  Future<List<PlannedSyncEntity>> collectPendingEntities(String ownerId);

  /// Poslední potvrzená serverová verze entity (C10 §10); `null` = entita
  /// ještě nebyla na server potvrzena → `CREATE_ENTITY`.
  Future<int?> serverVersion(String entityType, String entityId);

  /// Uloží potvrzenou serverovou verzi (jen po SUCCESS/ALREADY_APPLIED).
  Future<void> storeServerVersion(
    String entityType,
    String entityId,
    int serverVersion, {
    required DateTime now,
  });

  /// Nastaví sync_state aggregate rootu (`SYNCED`/`CONFLICT`/`BLOCKED`).
  Future<void> markRootSyncState(
    String entityType,
    String entityId,
    String syncState,
  );

  /// Nastaví stav outbox položky (`SYNCED`/`CONFLICT`/`BLOCKED`).
  Future<void> markOutboxStatus(String outboxId, String status);

  /// Konfliktní/odmítnuté outbox položky bez uzavřeného rozhodnutí
  /// (C12 §4/§6), s lidským popisem entity pro UI (CRC-011).
  Future<List<UnresolvedSyncItem>> unresolvedItems(String ownerId);

  /// Uzavře rozhodnutí o položce (`USE_LOCAL`/`CANCEL_LOCAL_CHANGE`,
  /// C12 §5) — append-only záznam, žádné mazání dat (CRC-006). USE_LOCAL
  /// rozhodnutí zvyšuje resolution-salt lokální revize entity, takže další
  /// push je nová operace s novým idempotency klíčem (CRC-005) beze změny
  /// doménových dat.
  Future<void> recordResolution(
    String outboxId,
    String decision, {
    required DateTime now,
  });
}
