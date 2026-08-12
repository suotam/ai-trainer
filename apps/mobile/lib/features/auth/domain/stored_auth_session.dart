import 'package:flutter/foundation.dart';

/// Session materiál uložený v platformním secure storage (C7 §4).
///
/// Obsahuje SECRET hodnoty (access/refresh credential) — instance nikdy
/// nesmí projít logem, analytikou ani běžnou SQLite (TSS-002/003/004).
/// `toString` je záměrně redigovaný.
@immutable
final class StoredAuthSession {
  const StoredAuthSession({
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

  StoredAuthSession copyWith({
    String? accessToken,
    DateTime? accessExpiresAt,
    String? refreshToken,
    DateTime? refreshExpiresAt,
  }) => StoredAuthSession(
    accountId: accountId,
    sessionId: sessionId,
    accessToken: accessToken ?? this.accessToken,
    accessExpiresAt: accessExpiresAt ?? this.accessExpiresAt,
    refreshToken: refreshToken ?? this.refreshToken,
    refreshExpiresAt: refreshExpiresAt ?? this.refreshExpiresAt,
  );

  @override
  String toString() =>
      'StoredAuthSession(accountId: $accountId, sessionId: $sessionId, '
      'accessToken: <redacted>, refreshToken: <redacted>)';
}
