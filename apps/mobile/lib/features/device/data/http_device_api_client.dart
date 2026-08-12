import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/http_error_mapping.dart';
import '../../auth/domain/auth_api_client.dart';
import '../domain/device_api_client.dart';

/// HTTP adapter device API (R2-04, C9): idempotentní PUT registrace podle
/// installation ID. Access credential jen v Authorization headeru
/// (AAC-009); bounded timeout, žádný automatický retry (DRC-015).
class HttpDeviceApiClient implements DeviceApiClient {
  HttpDeviceApiClient({
    required this.baseUrl,
    required this.httpClient,
    this.timeout = const Duration(seconds: 10),
  });

  final Uri baseUrl;
  final http.Client httpClient;
  final Duration timeout;

  @override
  Future<RegisteredDevice> registerDevice({
    required String accessToken,
    required String installationId,
    required String platform,
    required String appVersion,
    required String localSchemaVersion,
  }) async {
    final url = baseUrl.replace(
      path:
          '${baseUrl.path}/api/v1/devices/${Uri.encodeComponent(installationId)}',
    );
    final http.Response response;
    try {
      response = await httpClient
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'platform': platform,
              'appVersion': appVersion,
              'localSchemaVersion': localSchemaVersion,
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } catch (_) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, Object?>) {
          final id = decoded['installationId'];
          final status = decoded['status'];
          if (id is String && status is String) {
            return RegisteredDevice(installationId: id, status: status);
          }
        }
      } on FormatException {
        // spadne do server failure níže
      }
      throw const AuthApiFailure(AuthApiFailureKind.server);
    }
    throw failureForResponse(response);
  }
}
