import 'dart:convert';

import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/auth/domain/auth_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// R7-01 testy přímého BYOK adapteru (C46 §3): klíč jen v headeru
/// (BYK-003), thinking-block parse (BYK-006), fence extrakce, typovaná
/// selhání (BYK-008/010), trojice verzí (BYK-015), verify (BYK-012).
class _InMemoryKeyStore implements ByokKeyStore {
  _InMemoryKeyStore([this.key]);

  String? key;
  bool corrupted = false;

  @override
  Future<String?> read() async {
    if (corrupted) {
      throw const ByokKeyStoreException();
    }
    return key;
  }

  @override
  Future<void> write(String value) async => key = value;

  @override
  Future<void> clear() async => key = null;
}

void main() {
  const testKey = 'sk-ant-test-key-1234';

  http.Response anthropicOk({
    List<Map<String, Object?>>? content,
    String model = 'claude-sonnet-5',
  }) => http.Response(
    jsonEncode({
      'model': model,
      'content':
          content ??
          [
            {
              'type': 'text',
              'text':
                  '{"summary":"s","planTitle":"p","workouts":'
                  '[{"title":"W","workoutType":"STRENGTH","dayOffset":0,'
                  '"reason":"r"}]}',
            },
          ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );

  AnthropicDirectClient client(
    _InMemoryKeyStore store,
    Future<http.Response> Function(http.Request) handler,
  ) => AnthropicDirectClient(keyStore: store, httpClient: MockClient(handler));

  test('chybějící nebo poškozený klíč = typované keyMissing bez HTTP volání '
      '(BYK-010)', () async {
    var calls = 0;
    final c = client(_InMemoryKeyStore(), (request) async {
      calls++;
      return anthropicOk();
    });
    await expectLater(
      c.requestPlanProposal(context: const {}),
      throwsA(
        isA<AiApiFailure>().having(
          (f) => f.kind,
          'kind',
          AiApiFailureKind.keyMissing,
        ),
      ),
    );
    final corrupted = _InMemoryKeyStore(testKey)..corrupted = true;
    await expectLater(
      client(
        corrupted,
        (request) async => anthropicOk(),
      ).requestPlanProposal(context: const {}),
      throwsA(isA<AiApiFailure>()),
    );
    expect(calls, 0);
  });

  test('klíč jde výhradně do x-api-key headeru; prompt z registru v2; '
      'kontext jako data (BYK-003/005)', () async {
    http.Request? seen;
    final c = client(_InMemoryKeyStore(testKey), (request) async {
      seen = request;
      return anthropicOk();
    });
    final response = await c.requestPlanProposal(
      context: const {'sports': []},
      requestType: 'PLAN_PROPOSAL',
    );

    expect(seen!.headers['x-api-key'], testKey);
    expect(seen!.url.toString(), 'https://api.anthropic.com/v1/messages');
    final body = jsonDecode(seen!.body) as Map<String, Object?>;
    expect(body['model'], 'claude-sonnet-5');
    expect('${body['system']}', contains('training plan assistant'));
    expect('${body['system']}', contains('"planTitle"'));
    // Klíč nikdy v těle requestu (BYK-001/003).
    expect(seen!.body.contains(testKey), isFalse);
    // Plán v2 (C52): prompt v3 + schéma v2 + structured outputs s katalogem
    // + bounded 8192 tokenů (PS2-013).
    expect(response.promptVersion, 'plan-proposal-v3');
    expect(body['max_tokens'], 8192);
    expect(body['thinking'], {'type': 'disabled'});
    final format = ((body['output_config']! as Map)['format']! as Map);
    expect(format['type'], 'json_schema');
    expect(jsonEncode(format['schema']), contains('"HANGBOARD_MAX_HANG"'));
    expect('${body['system']}', contains('"sections"'));
    expect(response.schemaVersion, 'plan-proposal-schema-v2');
    expect(response.modelId, 'claude-sonnet-5');
    expect(response.proposal['planTitle'], 'p');
  });

  test('thinking blok před text blokem se přeskočí; fenced JSON se '
      'extrahuje (BYK-006, smoke nález)', () async {
    final c = client(_InMemoryKeyStore(testKey), (request) async {
      return anthropicOk(
        content: [
          {'type': 'thinking', 'thinking': '...', 'signature': 'sig'},
          {
            'type': 'text',
            'text': '```json\n{"summary":"s","operations":[]}\n```',
          },
        ],
      );
    });
    final response = await c.requestPlanProposal(
      context: const {},
      requestType: 'ADJUSTMENT_PROPOSAL',
    );
    expect(response.promptVersion, 'adjustment-proposal-v3');
    expect(response.schemaVersion, 'adjustment-proposal-schema-v2');
    expect(response.proposal['summary'], 's');
  });

  test('typovaná selhání: 401 invalidKey, 400 credit noCredit, 429 '
      'unavailable, ne-JSON text invalidOutput (BYK-008)', () async {
    Future<void> expectKind(
      http.Response scripted,
      AiApiFailureKind kind,
    ) async {
      final c = client(_InMemoryKeyStore(testKey), (request) async => scripted);
      await expectLater(
        c.requestPlanProposal(context: const {}),
        throwsA(isA<AiApiFailure>().having((f) => f.kind, 'kind', kind)),
      );
    }

    await expectKind(
      http.Response('{"error":"unauthorized"}', 401),
      AiApiFailureKind.invalidKey,
    );
    await expectKind(
      http.Response('{"error":{"message":"credit balance too low"}}', 400),
      AiApiFailureKind.noCredit,
    );
    await expectKind(
      http.Response('{"error":"rate"}', 429),
      AiApiFailureKind.unavailable,
    );
    await expectKind(
      anthropicOk(
        content: [
          {'type': 'text', 'text': 'not json at all'},
        ],
      ),
      AiApiFailureKind.invalidOutput,
    );
    // Odpověď bez text bloku = invalidOutput (BYK-006).
    await expectKind(
      anthropicOk(
        content: [
          {'type': 'thinking', 'thinking': '...'},
        ],
      ),
      AiApiFailureKind.invalidOutput,
    );
  });

  test('síťové selhání je AuthApiFailure network — mapuje se na '
      'ProposalUnavailable (BYK-008)', () async {
    final c = client(
      _InMemoryKeyStore(testKey),
      (request) async => throw Exception('boom'),
    );
    await expectLater(
      c.requestPlanProposal(context: const {}),
      throwsA(isA<AuthApiFailure>()),
    );
  });

  test('verifyKey: typované výsledky s bounded requestem (BYK-012)', () async {
    http.Request? seen;
    final valid = client(_InMemoryKeyStore(testKey), (request) async {
      seen = request;
      return anthropicOk(
        content: [
          {'type': 'text', 'text': 'OK'},
        ],
      );
    });
    expect(await valid.verifyKey(), ByokVerifyResult.valid);
    expect((jsonDecode(seen!.body) as Map)['max_tokens'], 8);

    final invalid = client(
      _InMemoryKeyStore(testKey),
      (request) async => http.Response('{}', 401),
    );
    expect(await invalid.verifyKey(), ByokVerifyResult.invalidKey);

    final missing = client(_InMemoryKeyStore(), (request) async {
      fail('bez klíče se nesmí volat síť');
    });
    expect(await missing.verifyKey(), ByokVerifyResult.invalidKey);

    final offline = client(
      _InMemoryKeyStore(testKey),
      (request) async => throw Exception('offline'),
    );
    expect(await offline.verifyKey(), ByokVerifyResult.network);
  });

  test('maska klíče nikdy neobsahuje celý klíč (BYK-002)', () {
    expect(maskByokKey('sk-ant-abcdef-9876'), '••••9876');
    expect(maskByokKey('sk-ant-abcdef-9876').contains('sk-ant'), isFalse);
    expect(maskByokKey('abc'), '••••abc');
  });
}
