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
}
