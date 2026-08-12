/// Identita instalace (C9 §4, DRC-001/002): client-generated stabilní ID,
/// které vzniká při prvním použití a přežívá po celou životnost instalace;
/// po kompletní reinstalaci vzniká nové. Je to ne-secret technická
/// reference (DRC-003) — žije v běžném lokálním stavu, ne v secure storage,
/// a samo o sobě nic neautorizuje.
abstract interface class InstallationIdentityRepository {
  /// Vrátí installation ID; při prvním volání jej atomicky vytvoří.
  /// Opakovaná volání vrací stejnou hodnotu.
  Future<String> ensureInstallationId();
}
