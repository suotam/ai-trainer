import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'backend_health_client.dart';

/// HTTP adapter R0 health kontraktu. Oddělený od widgetů (MAR-003);
/// timeouty jsou bounded, žádný automatický retry (r0-api-contract §9),
/// response body se neloguje.
class HttpBackendHealthClient implements BackendHealthClient {
  HttpBackendHealthClient({
    required this.baseUrl,
    required this.httpClient,
    this.timeout = const Duration(seconds: 5),
  });

  final Uri baseUrl;
  final http.Client httpClient;
  final Duration timeout;

  static const _livenessPath = '/api/v1/health/live';
  static const _readinessPath = '/api/v1/health/ready';
  static const _requestIdHeader = 'x-request-id';

  Uri endpoint(String path) => baseUrl.replace(path: '${baseUrl.path}$path');

  @override
  Future<BackendHealthStatus> checkHealth() async {
    // 1. Liveness: proces odpovídá a vrací kontraktní pole.
    final liveResponse = await _get(endpoint(_livenessPath));
    if (liveResponse.statusCode != 200) {
      throw const BackendHealthException(
        BackendHealthFailureKind.invalidResponse,
      );
    }
    final liveBody = _parseJsonObject(liveResponse.body);
    final service = _requireString(liveBody, 'status') == 'UP'
        ? _requireString(liveBody, 'service')
        : throw const BackendHealthException(
            BackendHealthFailureKind.invalidResponse,
          );
    final version = _requireString(liveBody, 'version');

    // 2. Readiness: 200 = přijímá provoz, 503 = pravdivě not-ready.
    final readyResponse = await _get(endpoint(_readinessPath));
    final requestId =
        readyResponse.headers[_requestIdHeader] ??
        liveResponse.headers[_requestIdHeader];
    final ready = switch (readyResponse.statusCode) {
      200 => true,
      503 => false,
      _ => throw const BackendHealthException(
        BackendHealthFailureKind.invalidResponse,
      ),
    };

    return BackendHealthStatus(
      service: service,
      version: version,
      ready: ready,
      requestId: requestId,
    );
  }

  Future<http.Response> _get(Uri url) async {
    try {
      return await httpClient
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw const BackendHealthException(BackendHealthFailureKind.timeout);
    } on BackendHealthException {
      rethrow;
    } catch (_) {
      // SocketException, ClientException apod. — interní detail se
      // nepropaguje (mobile-architecture §24).
      throw const BackendHealthException(BackendHealthFailureKind.unreachable);
    }
  }

  Map<String, Object?> _parseJsonObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
    } on FormatException {
      // spadne do invalidResponse níže
    }
    throw const BackendHealthException(
      BackendHealthFailureKind.invalidResponse,
    );
  }

  String _requireString(Map<String, Object?> json, String field) {
    final value = json[field];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    throw const BackendHealthException(
      BackendHealthFailureKind.invalidResponse,
    );
  }
}
