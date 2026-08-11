import 'local_sync_metadata.dart';

/// Lokální sync-metadata / outbox boundary (R2-01, C2 §6/§7).
///
/// Implementace patří do data vrstvy. R2-01 poskytuje pouze **restart-safe
/// úložiště a scaffolding** — žádné odesílání ani síť (non-goal R2-01).
/// Transport a replay vlastní pozdější sync protocol (C10) a idempotency
/// (C11).
abstract interface class LocalSyncMetadataRepository {
  /// Stabilní ID lokálního/anonymního vlastníka dat vzniklých před
  /// přihlášením (C2 §4).
  Future<String> localOwnerId();

  /// Zařadí záměr změny do outboxu a vrátí perzistovanou položku. Je
  /// **idempotentní podle `idempotencyKey`** (LSM-008/009): opakování se
  /// stejným klíčem nevytvoří druhou položku, vrátí existující.
  Future<OutboxEntry> enqueue(
    OutboxOperation operation, {
    required DateTime now,
  });

  /// Čekající outbox položky v deterministickém pořadí dle `sequence`
  /// (LSM-012). Přežívají restart aplikace (LSM-007).
  Future<List<OutboxEntry>> pendingOperations();
}
