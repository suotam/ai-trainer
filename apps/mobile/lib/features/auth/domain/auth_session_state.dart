import 'package:flutter/foundation.dart';

/// Autentizační stav aplikace odvozený ze session materiálu (C7, C3).
///
/// Anonymní stav je plnohodnotný first-class výsledek (ISC-002) — celý R1
/// offline tok funguje bez přihlášení (R2P-004). „Auth session" je oddělený
/// pojem od WorkoutSession i lokální aplikační session (ISC-011, TSS-014).
@immutable
sealed class AuthSessionState {
  const AuthSessionState();
}

/// Nepřihlášený/anonymní režim — žádný session materiál na zařízení.
final class AnonymousAuthState extends AuthSessionState {
  const AnonymousAuthState();
}

/// Přihlášený stav odvozený z uloženého session materiálu.
///
/// Nese pouze ne-secret technické reference (TSS-012); tokeny žijí výhradně
/// v secure storage boundary a nikdy neprochází UI stavem.
final class AuthenticatedAuthState extends AuthSessionState {
  const AuthenticatedAuthState({
    required this.accountId,
    required this.sessionId,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final String accountId;
  final String sessionId;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  @override
  bool operator ==(Object other) =>
      other is AuthenticatedAuthState &&
      other.accountId == accountId &&
      other.sessionId == sessionId &&
      other.accessExpiresAt == accessExpiresAt &&
      other.refreshExpiresAt == refreshExpiresAt;

  @override
  int get hashCode =>
      Object.hash(accountId, sessionId, accessExpiresAt, refreshExpiresAt);
}
