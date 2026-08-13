import 'package:flutter/foundation.dart';

/// Typované selhání auth API (C4 §9). Transportní vrstva mapuje stabilní
/// error kódy na tento výčet; raw HTTP/formátové detaily nikdy neprosakují
/// do application/UI vrstvy.
enum AuthApiFailureKind {
  /// 400 INVALID_REQUEST — neplatný vstup nebo idempotency konflikt.
  invalidRequest,

  /// 401 INVALID_CREDENTIALS — generické, bez account enumeration (AAC-008).
  invalidCredentials,

  /// 401 ACCESS_SESSION_EXPIRED.
  accessSessionExpired,

  /// 401 INVALID_REFRESH — neznámá/expirovaná refresh credential.
  invalidRefresh,

  /// 401 SESSION_REVOKED — revokovaná session (ISC-007).
  sessionRevoked,

  /// 403 ACCOUNT_DISABLED.
  accountDisabled,

  /// 403 ACCOUNT_DELETED.
  accountDeleted,

  /// 409 DUPLICATE_LOGIN_IDENTITY (INV-011).
  duplicateLoginIdentity,

  /// 429 RATE_LIMITED (SAR-013).
  rateLimited,

  /// Síť nedostupná / timeout — server nebyl dosažen.
  network,

  /// Neočekávaná serverová odpověď (5xx, nevalidní tvar).
  server,
}

/// Typovaná chyba auth API. Nenese žádný citlivý payload.
class AuthApiFailure implements Exception {
  const AuthApiFailure(this.kind, {this.retryAfter});

  final AuthApiFailureKind kind;

  /// Doporučené zpoždění dalšího pokusu u [AuthApiFailureKind.rateLimited].
  final Duration? retryAfter;

  @override
  String toString() => 'AuthApiFailure($kind)';
}

/// Session vydaná serverem (C4 AuthSessionResponse). Obsahuje SECRET
/// credentials — instance se nesmí logovat; `toString` je redigovaný.
@immutable
final class GrantedAuthSession {
  const GrantedAuthSession({
    required this.accountId,
    required this.sessionId,
    required this.accessToken,
    required this.accessExpiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  final String accountId;
  final String sessionId;
  final String accessToken;
  final DateTime accessExpiresAt;
  final String refreshToken;
  final DateTime refreshExpiresAt;

  @override
  String toString() =>
      'GrantedAuthSession(accountId: $accountId, sessionId: $sessionId, '
      'accessToken: <redacted>, refreshToken: <redacted>)';
}

/// Serverem autoritativní session context (C4 SessionContextResponse,
/// AAC-004) — jen ne-secret technické hodnoty.
@immutable
final class AuthSessionContext {
  const AuthSessionContext({
    required this.accountId,
    required this.sessionId,
    required this.accountType,
    required this.accountStatus,
    required this.accessExpiresAt,
  });

  final String accountId;
  final String sessionId;
  final String accountType;
  final String accountStatus;
  final DateTime accessExpiresAt;
}

/// Klientská hranice R2 auth API (C4). Implementaci vlastní data vrstva;
/// application vrstva závisí jen na tomto rozhraní (MAR-015).
abstract interface class AuthApiClient {
  /// Registrace účtu s povinným idempotency key (AAC-005): retry se stejným
  /// klíčem nevytvoří druhý účet.
  Future<GrantedAuthSession> register({
    required String email,
    required String password,
    required String idempotencyKey,
  });

  Future<GrantedAuthSession> login({
    required String email,
    required String password,
  });

  /// Rotuje refresh credential (AAC-006); refresh se přenáší výhradně
  /// v request body (AAC-010), nikdy v URL.
  Future<GrantedAuthSession> refresh(String refreshToken);

  /// Ukončí aktuální session; opakovaný logout je no-op (C4 §10).
  Future<void> logout(String accessToken);

  /// Globální revokace — „odhlásit všude" (C13 §4, RVC-001): revokuje
  /// všechny session účtu včetně této. Idempotentní.
  Future<void> revokeAllSessions(String accessToken);

  Future<AuthSessionContext> sessionContext(String accessToken);
}
