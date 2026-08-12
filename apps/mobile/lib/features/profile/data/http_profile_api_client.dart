import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/http_error_mapping.dart';
import '../../auth/domain/auth_api_client.dart';
import '../domain/profile_api_client.dart';

/// HTTP adapter profile API (R2-04): create + current podle kanonického
/// OpenAPI. Access credential jen v Authorization headeru (AAC-009);
/// bounded timeout, žádný automatický retry.
class HttpProfileApiClient implements ProfileApiClient {
  HttpProfileApiClient({
    required this.baseUrl,
    required this.httpClient,
    this.timeout = const Duration(seconds: 10),
  });

  final Uri baseUrl;
  final http.Client httpClient;
  final Duration timeout;

  Uri _endpoint(String path) => baseUrl.replace(path: '${baseUrl.path}$path');

  @override
  Future<AthleteProfileView> createProfile({
    required String accessToken,
    required String profileId,
    required String displayName,
    String? primarySport,
  }) async {
    final response = await _send(
      () => httpClient.post(
        _endpoint('/api/v1/profiles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'profileId': profileId,
          'displayName': displayName,
          'primarySport': ?primarySport,
        }),
      ),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return _parseProfile(response.body);
    }
    throw failureForResponse(response);
  }

  @override
  Future<AthleteProfileView?> currentProfile(String accessToken) async {
    final response = await _send(
      () => httpClient.get(
        _endpoint('/api/v1/profiles/current'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (response.statusCode == 200) {
      return _parseProfile(response.body);
    }
    if (response.statusCode == 404) {
      // Bez profilu — validní stav, ne chyba.
      return null;
    }
    throw failureForResponse(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } on AuthApiFailure {
      rethrow;
    } catch (_) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
  }

  AthleteProfileView _parseProfile(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) {
        final profileId = decoded['profileId'];
        final displayName = decoded['displayName'];
        if (profileId is String && displayName is String) {
          return AthleteProfileView(
            profileId: profileId,
            displayName: displayName,
            primarySport: decoded['primarySport'] as String?,
            experienceLevel: decoded['experienceLevel'] as String?,
          );
        }
      }
    } on FormatException {
      // spadne do server failure níže
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }
}
