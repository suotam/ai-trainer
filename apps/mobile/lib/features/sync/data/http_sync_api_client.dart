import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/http_error_mapping.dart';
import '../../auth/domain/auth_api_client.dart';
import '../domain/sync_push_models.dart';

/// HTTP adapter push sync API (R2-05, C10 §9). Access credential jen
/// v Authorization headeru (AAC-009); bounded timeout, žádný automatický
/// retry (SPC-015); payload se neloguje.
class HttpSyncApiClient implements SyncApiClient {
  HttpSyncApiClient({
    required this.baseUrl,
    required this.httpClient,
    this.timeout = const Duration(seconds: 20),
  });

  final Uri baseUrl;
  final http.Client httpClient;
  final Duration timeout;

  @override
  Future<List<SyncItemOutcome>> push({
    required String accessToken,
    required String installationId,
    required List<SyncPushOperation> operations,
  }) async {
    final url = baseUrl.replace(path: '${baseUrl.path}/api/v1/sync/push');
    final http.Response response;
    try {
      response = await httpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'installationId': installationId,
              'operations': [
                for (final op in operations)
                  {
                    'operationId': op.operationId,
                    'idempotencyKey': op.idempotencyKey,
                    'sequence': op.sequence,
                    'operationType': op.operationType,
                    'entityType': op.entityType,
                    'entityId': op.entityId,
                    'payload': op.payload,
                    'expectedServerVersion': op.expectedServerVersion,
                  },
              ],
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } catch (_) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    if (response.statusCode != 200) {
      throw failureForResponse(response);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final results = decoded['results'];
        if (results is List) {
          return [
            for (final item in results.cast<Map<String, Object?>>())
              SyncItemOutcome(
                operationId: item['operationId']! as String,
                result: item['result']! as String,
                serverVersion: (item['serverVersion'] as num?)?.toInt(),
              ),
          ];
        }
      }
    } on FormatException {
      // spadne do server failure níže
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }

  @override
  Future<SyncPullResponse> pull({
    required String accessToken,
    required String installationId,
    required Map<String, String?> cursors,
    int? limit,
  }) async {
    final url = baseUrl.replace(path: '${baseUrl.path}/api/v1/sync/pull');
    final http.Response response;
    try {
      response = await httpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'installationId': installationId,
              'cursors': [
                for (final entry in cursors.entries)
                  {'entityType': entry.key, 'cursor': entry.value},
              ],
              'limit': ?limit,
            }),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } catch (_) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    if (response.statusCode != 200) {
      throw failureForResponse(response);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final items = decoded['items'];
        final cursorList = decoded['cursors'];
        final hasMore = decoded['hasMore'];
        if (items is List && cursorList is List && hasMore is bool) {
          return SyncPullResponse(
            items: [
              for (final item in items.cast<Map<String, Object?>>())
                SyncPullItem(
                  entityType: item['entityType']! as String,
                  entityId: item['entityId']! as String,
                  serverVersion: (item['serverVersion']! as num).toInt(),
                  payload: (item['payload']! as Map).cast<String, Object?>(),
                ),
            ],
            cursors: {
              for (final cursor in cursorList.cast<Map<String, Object?>>())
                cursor['entityType']! as String: cursor['cursor'] as String?,
            },
            hasMore: hasMore,
          );
        }
      }
    } on FormatException {
      // spadne do server failure níže
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }
}
