/// Selhání secure storage klíče — fail-safe signál (BYK-010 vzor C7),
/// nikdy pád aplikace.
class ByokKeyStoreException implements Exception {
  const ByokKeyStoreException();
}

/// Secure storage boundary pro API klíč vlastníka (C46 §2, BYK-001).
///
/// Jediné místo, kudy klíč vstupuje a opouští zařízení. Implementace
/// používá výhradně platformní secure storage — nikdy Drift/SQLite,
/// preferences ani soubor. V testech se nahrazuje in-memory fake.
abstract interface class ByokKeyStore {
  /// Vrátí uložený klíč, nebo `null` (klíč nezadán). Poškozený obsah
  /// hlásí [ByokKeyStoreException].
  Future<String?> read();

  /// Uloží klíč (přepíše případný předchozí).
  Future<void> write(String key);

  /// Odstraní klíč (BYK-014 — okamžité a úplné).
  Future<void> clear();
}

/// Maska klíče pro UI (BYK-002): nikdy celý klíč, jen poslední 4 znaky.
String maskByokKey(String key) {
  final tail = key.length <= 4 ? key : key.substring(key.length - 4);
  return '••••$tail';
}
