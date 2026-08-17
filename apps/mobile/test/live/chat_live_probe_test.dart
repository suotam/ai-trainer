@Tags(['live'])
library;

import 'dart:io';

import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/chat/data/chat_reply_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Živá diagnostická sonda chatu (opt-in přes AITRAINER_LIVE_SMOKE=1,
/// BYK-013): týž kód jako v telefonu — reálné volání + validace; raw
/// výstup se uloží do build/live-smoke pro analýzu on-device nálezu.
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

  test(
    'live chat probe: reálná odpověď projde validateChatReply',
    () async {
      final client = AnthropicDirectClient(
        keyStore: _EnvKeyStore(),
        httpClient: http.Client(),
      );
      final raw = await client.chat(
        turns: const [
          (
            role: 'USER',
            content:
                'Hraju 2× týdně florbal, chci zhubnout, čas mám v úterý '
                'večer a mám citlivé koleno.',
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
      File('build/live-smoke/chat-probe-raw.txt').writeAsStringSync(raw);
      final reply = validateChatReply(raw);
      File('build/live-smoke/chat-probe-verdict.txt').writeAsStringSync(
        reply == null
            ? 'INVALID'
            : 'VALID text=${reply.text}\nactions=${reply.actions}',
      );
      expect(reply, isNotNull, reason: 'raw viz build/live-smoke');
    },
    skip: !live ? 'opt-in: AITRAINER_LIVE_SMOKE=1' : null,
  );

  test('live chat probe: neformální pozdrav vrátí validní JSON '
      '(on-device nález 3c)', () async {
    final client = AnthropicDirectClient(
      keyStore: _EnvKeyStore(),
      httpClient: http.Client(),
    );
    final raw = await client.chat(
      turns: const [(role: 'USER', content: 'Ahoj, jsi můj osobní trenér?')],
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
    File('build/live-smoke/chat-probe-casual-raw.txt').writeAsStringSync(raw);
    expect(
      validateChatReply(raw),
      isNotNull,
      reason: 'raw viz build/live-smoke',
    );
  }, skip: !live ? 'opt-in: AITRAINER_LIVE_SMOKE=1' : null);
}
