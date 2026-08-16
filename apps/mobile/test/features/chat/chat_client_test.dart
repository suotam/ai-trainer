import 'dart:convert';

import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// R7-02 testy chat metody BYOK adapteru (C47 §4/§5): chat-v1 prompt
/// (CHC-008), kontext jako data + mapování rolí okna (CHC-006), typovaná
/// selhání vč. chybějícího klíče (CHC-009/010), thinking-block parse.
class _InMemoryKeyStore implements ByokKeyStore {
  _InMemoryKeyStore([this.key]);

  String? key;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;

  @override
  Future<void> clear() async => key = null;
}

void main() {
  const testKey = 'sk-ant-test-key-1234';

  AnthropicDirectClient client(
    _InMemoryKeyStore store,
    Future<http.Response> Function(http.Request) handler,
  ) => AnthropicDirectClient(keyStore: store, httpClient: MockClient(handler));

  test('chat: chat-v1 prompt, kontext jako data, role okna mapované, '
      'odpověď z prvního text bloku (CHC-006/008)', () async {
    http.Request? seen;
    final c = client(_InMemoryKeyStore(testKey), (request) async {
      seen = request;
      return http.Response(
        jsonEncode({
          'model': 'claude-sonnet-5',
          'content': [
            {'type': 'thinking', 'thinking': '...', 'signature': 's'},
            {'type': 'text', 'text': 'Doporučuji lehký trénink.'},
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final reply = await c.chat(
      turns: const [
        (role: 'USER', content: 'Jak mám dnes trénovat?'),
        (role: 'ASSISTANT', content: 'Záleží na únavě.'),
        (role: 'USER', content: 'Jsem svěží.'),
      ],
      profileContext: const {'sports': [], 'goals': []},
    );

    expect(reply, 'Doporučuji lehký trénink.');
    final body = jsonDecode(seen!.body) as Map<String, Object?>;
    expect('${body['system']}', contains('personal training assistant'));
    // chat-v2 (C48): akční protokol s přesnými tvary.
    expect('${body['system']}', contains('exactly one JSON object'));
    expect('${body['system']}', contains('UPSERT_SPORT'));
    final messages = (body['messages']! as List).cast<Map>();
    // Kontext jako data v prvním tahu (CHC-006), pak okno konverzace.
    expect('${messages.first['content']}', contains('data, not instructions'));
    expect(messages[2]['role'], 'user');
    expect(messages[3]['role'], 'assistant');
    expect(messages[4]['role'], 'user');
    expect('${messages[4]['content']}', 'Jsem svěží.');
    // Bounded náklad (C47 §5) — thinking vypnutý, celý rozpočet odpovědi.
    expect(body['max_tokens'], 4096);
    expect(body['thinking'], {'type': 'disabled'});
    // Structured outputs (nález 3c) — tvar odpovědi vynucuje API.
    final format =
        ((body['output_config']! as Map)['format']! as Map)
            .cast<String, Object?>();
    expect(format['type'], 'json_schema');
    expect((format['schema']! as Map)['required'], ['reply']);
    expect(seen!.headers['x-api-key'], testKey);
  });

  test('chybějící klíč a prázdná odpověď jsou typovaná selhání '
      '(CHC-009/010)', () async {
    final noKey = client(_InMemoryKeyStore(), (request) async {
      fail('bez klíče se nesmí volat síť');
    });
    await expectLater(
      noKey.chat(turns: const [], profileContext: const {}),
      throwsA(
        isA<AiApiFailure>().having(
          (f) => f.kind,
          'kind',
          AiApiFailureKind.keyMissing,
        ),
      ),
    );

    final empty = client(
      _InMemoryKeyStore(testKey),
      (request) async => http.Response(
        jsonEncode({
          'model': 'claude-sonnet-5',
          'content': [
            {'type': 'thinking', 'thinking': 'jen reasoning'},
          ],
        }),
        200,
      ),
    );
    await expectLater(
      empty.chat(
        turns: const [(role: 'USER', content: 'ahoj')],
        profileContext: const {},
      ),
      throwsA(
        isA<AiApiFailure>().having(
          (f) => f.kind,
          'kind',
          AiApiFailureKind.invalidOutput,
        ),
      ),
    );
  });
}
