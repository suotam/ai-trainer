/// Typované výsledky auth operací pro UI — nikdy raw výjimka ani
/// interní detail (mobile-architecture §24).
sealed class AuthFlowResult {
  const AuthFlowResult();
}

final class AuthFlowSuccess extends AuthFlowResult {
  const AuthFlowSuccess();
}

enum AuthFlowFailureReason {
  /// Neplatný vstup (prázdný e-mail, krátké heslo) — bez volání sítě.
  invalidInput,

  /// Generické neplatné credentials (AAC-008 — bez rozlišení příčiny).
  invalidCredentials,

  /// Přihlašovací identita už existuje (registrace).
  duplicateIdentity,

  /// Účet je dočasně/trvale nedostupný.
  accountUnavailable,

  /// Příliš mnoho pokusů — respektovat retryAfter.
  rateLimited,

  /// Server nedosažitelný — offline režim zůstává plně funkční (R2P-004).
  network,

  /// Neočekávaná chyba serveru.
  server,
}

final class AuthFlowFailure extends AuthFlowResult {
  const AuthFlowFailure(this.reason, {this.retryAfter});

  final AuthFlowFailureReason reason;
  final Duration? retryAfter;
}

/// Výsledek serverového ověření uložené session (C7 §8 — po obnovení
/// konektivity klient ověří možnost pokračovat).
enum SessionVerification {
  /// Žádná uložená session — anonymní stav.
  anonymous,

  /// Access session je serverem potvrzená.
  verifiedActive,

  /// Access expirovala a byla úspěšně obnovena refresh rotací.
  refreshed,

  /// Session byla revokována / účet nedostupný — materiál odstraněn,
  /// lokální data zůstávají (TSS-009/010).
  signedOutRevoked,

  /// Server nedosažitelný — lokální stav se zachovává; platná lokální
  /// session smí číst dříve synchronizovaná data (security §7.3), ale
  /// serverové oprávnění se offline nepotvrzuje.
  offlineUnverified,
}
