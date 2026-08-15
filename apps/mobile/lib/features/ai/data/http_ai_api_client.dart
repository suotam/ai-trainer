import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../auth/data/http_error_mapping.dart';
import '../../auth/domain/auth_api_client.dart';

/// Odpověď AI plan proposal API (R4-03, C28): kanonický payload +
/// povinná trojice verzí (PAA-005).
class PlanProposalResponse {
  const PlanProposalResponse({
    required this.proposal,
    required this.promptVersion,
    required this.schemaVersion,
    required this.modelId,
  });

  final Map<String, Object?> proposal;
  final String promptVersion;
  final String schemaVersion;
  final String modelId;
}

/// Typovaná selhání AI volání nad rámec auth chyb. Osobní režim (C46)
/// přidává stavy klíče: chybějící, neplatný, bez kreditu (BYK-008/010).
enum AiApiFailureKind {
  unavailable,
  invalidOutput,
  keyMissing,
  invalidKey,
  noCredit,
}

class AiApiFailure implements Exception {
  const AiApiFailure(this.kind);

  final AiApiFailureKind kind;
}

/// Port AI API klienta (jediná cesta k modelu — AGW-001/BYK-004; typ
/// v requestu dle C37 §2). Credential si opatřuje implementace sama
/// (BYOK klíč, resp. dormantní backend session).
abstract interface class AiApiClient {
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  });
}

/// HTTP adapter backend AI gateway — **dormantní** (ADR-013, C46 §6):
/// kompiluje, ale není zapojen v composition root; reaktivace je
/// samostatné rozhodnutí. Access credential jen v Authorization headeru
/// (AAC-009); bounded timeout, žádný automatický retry (SOV-012).
class HttpAiApiClient implements AiApiClient {
  HttpAiApiClient({
    required this.baseUrl,
    required this.httpClient,
    required this.accessToken,
    this.timeout = const Duration(seconds: 45),
  });

  final Uri baseUrl;
  final http.Client httpClient;

  /// Zdroj access tokenu (dormantní backend režim); `null` = anonymní.
  final Future<String?> Function() accessToken;

  final Duration timeout;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) async {
    final token = await accessToken();
    if (token == null) {
      throw const AiApiFailure(AiApiFailureKind.keyMissing);
    }
    final url = baseUrl.replace(
      path: '${baseUrl.path}/api/v1/ai/plan-proposals',
    );
    final http.Response response;
    try {
      response = await httpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'context': context, 'requestType': requestType}),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    } catch (_) {
      throw const AuthApiFailure(AuthApiFailureKind.network);
    }
    if (response.statusCode == 503) {
      throw const AiApiFailure(AiApiFailureKind.unavailable);
    }
    if (response.statusCode == 502) {
      throw const AiApiFailure(AiApiFailureKind.invalidOutput);
    }
    if (response.statusCode != 200) {
      throw failureForResponse(response);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final proposal = decoded['proposal'];
        final promptVersion = decoded['promptVersion'];
        final schemaVersion = decoded['schemaVersion'];
        final modelId = decoded['modelId'];
        if (proposal is Map<String, Object?> &&
            promptVersion is String &&
            schemaVersion is String &&
            modelId is String) {
          return PlanProposalResponse(
            proposal: proposal,
            promptVersion: promptVersion,
            schemaVersion: schemaVersion,
            modelId: modelId,
          );
        }
      }
    } on FormatException {
      // spadne do server failure níže
    }
    throw const AuthApiFailure(AuthApiFailureKind.server);
  }
}
