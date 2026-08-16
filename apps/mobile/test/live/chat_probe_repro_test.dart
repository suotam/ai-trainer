@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/chat/data/chat_reply_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _EnvKeyStore implements ByokKeyStore {
  @override
  Future<String?> read() async =>
      Platform.environment['AITRAINER_AI_ANTHROPIC_APIKEY'];

  @override
  Future<void> write(String key) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  final live = Platform.environment['AITRAINER_LIVE_SMOKE'] == '1';

  test('repro: bohatý profil s více akcemi', () async {
    final client = AnthropicDirectClient(
      keyStore: _EnvKeyStore(),
      httpClient: http.Client(),
    );
    final raw = await client.chat(
      turns: const [
        (
          role: 'USER',
          content:
              'Lezu na stěně 3-4x týdně (pokročilý), k tomu florbal v úterý, '
              'čtvrtek a neděli večer, ve středu fotbal, v sobotu skála. '
              'Doma mám kruhy a TRX, posilovnu ne. Ráno mám 30-40 minut. '
              'Cíl: zlepšit se v lezení a nezranit prsty. Ulož mi to do '
              'profilu a pak mi sestav plán.',
        ),
      ],
      profileContext: const {
        'requestType': 'PLAN_PROPOSAL',
        'sports': [],
        'goals': [],
        'typicalWeek': [],
        'equipment': [],
        'constraints': [],
        'statistics': {
          'periodDays': 30,
          'plannedCount': 0,
          'completedCount': 0,
          'manualActivityCount': 0,
          'manualMinutes': 0,
        },
      },
    );
    Directory('build/live-smoke').createSync(recursive: true);
    File('build/live-smoke/chat-repro-raw.json').writeAsStringSync(raw);
    final decoded = jsonDecode(raw) as Map<String, Object?>;
    final actions = (decoded['actions'] as List?) ?? const [];
    final buffer = StringBuffer();
    for (final a in actions) {
      final single = jsonEncode({'reply': 'x', 'actions': [a]});
      buffer.writeln(
        '${validateChatReply(single) == null ? 'REJECT' : 'ok    '} '
        '${jsonEncode(a)}',
      );
    }
    File('build/live-smoke/chat-repro-verdict.txt')
        .writeAsStringSync(buffer.toString());
    expect(validateChatReply(raw), isNotNull);
  }, skip: !live ? 'opt-in: AITRAINER_LIVE_SMOKE=1' : null);
}
