import 'dart:convert';

import 'package:ai_trainer_mobile/app/backend_status/backend_health_client.dart';
import 'package:ai_trainer_mobile/app/backend_status/http_backend_health_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final baseUrl = Uri.parse('http://10.0.2.2:8080');

  const liveBody =
      '{"status":"UP","service":"ai-trainer-backend",'
      '"timestamp":"2026-07-23T10:00:00Z","version":"0.0.1-dev"}';
  const readyBody =
      '{"status":"READY","service":"ai-trainer-backend",'
      '"timestamp":"2026-07-23T10:00:00Z","version":"0.0.1-dev",'
      '"checks":{"application":"UP","database":"UP","migrations":"UP"}}';
  const notReadyBody =
      '{"code":"SERVICE_NOT_READY","message":"Service is not ready to accept '
      'traffic.","requestId":"req-1","timestamp":"2026-07-23T10:00:00Z"}';

  HttpBackendHealthClient clientWith(
    Future<http.Response> Function(http.Request request) handler,
  ) => HttpBackendHealthClient(
    baseUrl: baseUrl,
    httpClient: MockClient(handler),
    timeout: const Duration(milliseconds: 200),
  );

  test('sestavuje spravne URL obou endpointu z base URL', () {
    final client = clientWith((_) async => http.Response('', 500));

    expect(
      client.endpoint('/api/v1/health/live').toString(),
      'http://10.0.2.2:8080/api/v1/health/live',
    );
    expect(
      client.endpoint('/api/v1/health/ready').toString(),
      'http://10.0.2.2:8080/api/v1/health/ready',
    );
  });

  test('validni live a ready odpoved se zparsuje na ready status', () async {
    final requestedPaths = <String>[];
    final client = clientWith((request) async {
      requestedPaths.add(request.url.path);
      return switch (request.url.path) {
        '/api/v1/health/live' => http.Response(
          liveBody,
          200,
          headers: {'x-request-id': 'live-id'},
        ),
        '/api/v1/health/ready' => http.Response(
          readyBody,
          200,
          headers: {'x-request-id': 'ready-id'},
        ),
        _ => http.Response('not found', 404),
      };
    });

    final status = await client.checkHealth();

    expect(status.service, 'ai-trainer-backend');
    expect(status.version, '0.0.1-dev');
    expect(status.ready, isTrue);
    expect(status.requestId, 'ready-id');
    expect(requestedPaths, ['/api/v1/health/live', '/api/v1/health/ready']);
  });

  test('readiness 503 znamena pravdivy not-ready stav, nikoli chybu', () async {
    final client = clientWith(
      (request) async => request.url.path.endsWith('/live')
          ? http.Response(liveBody, 200)
          : http.Response(notReadyBody, 503),
    );

    final status = await client.checkHealth();

    expect(status.ready, isFalse);
    expect(status.service, 'ai-trainer-backend');
  });

  test('nevalidni JSON se odmitne jako invalidResponse', () async {
    final client = clientWith((_) async => http.Response('not-json{', 200));

    await expectLater(
      client.checkHealth(),
      throwsA(
        isA<BackendHealthException>().having(
          (e) => e.kind,
          'kind',
          BackendHealthFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test('chybejici povinne pole se odmitne jako invalidResponse', () async {
    final missingVersion = jsonEncode({
      'status': 'UP',
      'service': 'ai-trainer-backend',
      'timestamp': '2026-07-23T10:00:00Z',
    });
    final client = clientWith((_) async => http.Response(missingVersion, 200));

    await expectLater(
      client.checkHealth(),
      throwsA(
        isA<BackendHealthException>().having(
          (e) => e.kind,
          'kind',
          BackendHealthFailureKind.invalidResponse,
        ),
      ),
    );
  });

  test('timeout se mapuje na timeout kind', () async {
    final client = clientWith(
      (_) => Future.delayed(
        const Duration(seconds: 5),
        () => http.Response(liveBody, 200),
      ),
    );

    await expectLater(
      client.checkHealth(),
      throwsA(
        isA<BackendHealthException>().having(
          (e) => e.kind,
          'kind',
          BackendHealthFailureKind.timeout,
        ),
      ),
    );
  });

  test('sitova chyba se mapuje na unreachable bez internich detailu', () async {
    final client = clientWith(
      (_) async => throw http.ClientException('Connection refused: internal'),
    );

    await expectLater(
      client.checkHealth(),
      throwsA(
        isA<BackendHealthException>()
            .having((e) => e.kind, 'kind', BackendHealthFailureKind.unreachable)
            .having(
              (e) => e.toString(),
              'toString',
              isNot(contains('Connection refused')),
            ),
      ),
    );
  });

  test('neocekavany status code readiness je invalidResponse', () async {
    final client = clientWith(
      (request) async => request.url.path.endsWith('/live')
          ? http.Response(liveBody, 200)
          : http.Response('teapot', 418),
    );

    await expectLater(
      client.checkHealth(),
      throwsA(isA<BackendHealthException>()),
    );
  });
}
