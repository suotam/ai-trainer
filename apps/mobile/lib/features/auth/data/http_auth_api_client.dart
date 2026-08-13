import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/auth_api_client.dart';

/// HTTP adapter R2 auth API (C4, kanonické OpenAPI). Oddělený od widgetů
/// (MAR-003); bounded timeouty, žádný automatický retry. Credentials se
/// přenáší výhradně v hlavičce/body — nikdy v URL (AAC-009) — a nikdy se
/// nelogují (TSS-004); response body se neloguje.
class HttpAuthApiClient implements AuthApiClient {
  HttpAuthApiClient({
    required this.baseUrl,
    required this.httpClient,
    this.timeout = const Duration(seconds: 10),
  });

  final Uri baseUrl;
  final http.Client httpClient;
  final Duration timeout;

  static const _registrationsPath = '/api/v1/auth/registrations';
  static const _sessionsPath = '/api/v1/auth/sessions';
  static const _refreshPath = '/api/v1/auth/sessions/refresh';
  static const _logoutPath = '/api/v1/auth/sessions/current';
  static const _sessionContextPath = '/api/v1/auth/session';

  Uri _endpoint(String path) => baseUrl.replace(path: '${baseUrl.path}$path');

  @override
  Future<GrantedAuthSession> register({
    required String email,
    required String password,
    required String idempotencyKey,
  }) async {
    final response = await _send(
      () => httpClient.post(
        _endpoint(_registrationsPath),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Idempotency-Key': idempotencyKey,
        },
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    if (response.statusCode == 201) {
      return _parseSession(response.body);
    }
    throw _failureFor(response);
  }

  @override
  Future<GrantedAuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _send(
      () => httpClient.post(
        _endpoint(_sessionsPath),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    if (response.statusCode == 200) {
      return _parseSession(response.body);
    }
    throw _failureFor(response);
  }

  @override
  Future<GrantedAuthSession> refresh(String refreshToken) async {
    // Refresh credential výhradně v request body (AAC-010), nikdy v URL.
    final response = await _send(
      () => httpClient.post(
        _endpoint(_refreshPath),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      ),
    );
    if (response.statusCode == 200) {
      return _parseSession(response.body);
    }
    throw _failureFor(response);
  }

  @override
  Future<void> logout(String accessToken) async {
    final response = await _send(
      () => httpClient.delete(
        _endpoint(_logoutPath),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode == 204) {
      return;
    }
    throw _failureFor(response);
  }

  @override
  Future<void> revokeAllSessions(String accessToken) async {
    final response = await _send(
      () => httpClient.delete(
        _endpoint(_sessionsPath),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode == 204) {
      return;
    }
    throw _failureFor(response);
  }

  @override
  Future<AuthSessionContext> sessionContext(String accessToken) async {
    final response = await _send(
      () => httpClient.get(
        _endpoint(_sessionContextPath),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      final json = _parseJsonObject(response.body);
      return AuthSessionContext(
        accountId: _requireString(json, 'accountId'),
        sessionId: _requireString(json, 'sessionId'),
        accountType: _requireString(json, 'accountType'),
        accountStatus: _requireString(json, 'accountStatus'),
        accessExpiresAt: _requireInstant(json, 'accessExpiresAt'),
      );
    }
    throw _failureFor(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } on AuthApiFailure {
      rethrow;
    } catch (_) {
      // SocketException, ClientException apod. — interní detail se
      // nepropaguje (mobile-architecture §24).
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
  }

  /// Mapuje kanonický error envelope (`code`) na typované selhání (C4 §9).
  AuthApiFailure _failureFor(http.Response response) {
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

  GrantedAuthSession _parseSession(String body) {
    final json = _parseJsonObject(body);
    return GrantedAuthSession(
      accountId: _requireString(json, 'accountId'),
      sessionId: _requireString(json, 'sessionId'),
      accessToken: _requireString(json, 'accessToken'),
      accessExpiresAt: _requireInstant(json, 'accessExpiresAt'),
      refreshToken: _requireString(json, 'refreshToken'),
      refreshExpiresAt: _requireInstant(json, 'refreshExpiresAt'),
    );
  }

  Map<String, Object?> _parseJsonObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } on FormatException {
      // spadne do server failure níže
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }

  String _requireString(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }

  DateTime _requireInstant(Map<String, Object?> json, String field) {
    final parsed = DateTime.tryParse(_requireString(json, field));
    if (parsed == null) {
      throw const AuthApiFailure(AuthApiFailureKind.server);
    }
    return parsed.toUtc();
  }
}
