import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/auth_api_client.dart';

/// Sdílené mapování kanonického error envelope (`code`) na typované selhání
/// (C4 §9, C8 §8) pro HTTP klienty chráněných R2 API. Response body se
/// nikdy neloguje.
AuthApiFailure failureForResponse(http.Response response) {
  String? code;
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) {
      final value = decoded['code'];
      if (value is String) {
        code = value;
      }
    }
  } on FormatException {
    // Nevalidní tělo → klasifikace jen podle status kódu níže.
  }
  final kind = switch (code) {
    'INVALID_REQUEST' => AuthApiFailureKind.invalidRequest,
    'INVALID_CREDENTIALS' => AuthApiFailureKind.invalidCredentials,
    'ACCESS_SESSION_EXPIRED' => AuthApiFailureKind.accessSessionExpired,
    'INVALID_REFRESH' => AuthApiFailureKind.invalidRefresh,
    'SESSION_REVOKED' => AuthApiFailureKind.sessionRevoked,
    'ACCOUNT_DISABLED' => AuthApiFailureKind.accountDisabled,
    'ACCOUNT_DELETED' => AuthApiFailureKind.accountDeleted,
    'DUPLICATE_LOGIN_IDENTITY' => AuthApiFailureKind.duplicateLoginIdentity,
    'RATE_LIMITED' => AuthApiFailureKind.rateLimited,
    _ => AuthApiFailureKind.server,
  };
  if (kind == AuthApiFailureKind.rateLimited) {
    final retryAfterSeconds = int.tryParse(
      response.headers['retry-after'] ?? '',
    );
    return AuthApiFailure(
      kind,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
    );
  }
  return AuthApiFailure(kind);
}
