import 'stored_auth_session.dart';

/// Selhání secure storage — signál pro fail-safe fallback (TSS-008),
/// nikdy pro pád aplikace ani ztrátu lokálních workout dat.
class SecureSessionStorageException implements Exception {
  const SecureSessionStorageException();
}

/// Secure storage boundary pro session materiál (C7 §5, MAR-015).
///
/// Jediné místo, kudy session materiál vstupuje a opouští zařízení.
/// Implementace používá výhradně platformní secure storage — nikdy
/// Drift/SQLite, preferences ani běžný soubor (TSS-002/003). V testech se
/// nahrazuje in-memory fake; UI ani feature kód na platformní úložiště
/// nesahá přímo (TSS-005).
abstract interface class SecureSessionStorage {
  /// Vrátí uložený session materiál, nebo `null` (anonymní stav, ISC-002).
  /// Poškozený/nečitelný obsah hlásí [SecureSessionStorageException].
  Future<StoredAuthSession?> read();

  /// Atomicky uloží kompletní session materiál (C7 §5 — částečně zapsaný
  /// stav nesmí být čitelný jako platný).
  Future<void> write(StoredAuthSession session);

  /// Odstraní veškerý session materiál (logout/revokace, TSS-009/010).
  Future<void> clear();
}
