import 'dart:convert';

import 'package:ai_trainer_mobile/features/chat/data/chat_reply_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// R7-03 testy validace `chat-action-schema-v1` (C48 §2/§3, CHA-003/004):
/// tvarová tabulka všech druhů, kanonizace neznámých polí, nevalidní
/// celek bez opravy i částečného přijetí.
void main() {
  test('validní odpověď se všemi druhy akcí se kanonizuje', () {
    final raw = jsonEncode({
      'reply': 'Zapsal jsem si to — potvrď prosím návrhy níže.',
      'actions': [
        {
          'action': 'UPSERT_SPORT',
          'customName': 'Florbal',
          'role': 'SECONDARY',
          'priority': 'HIGH',
          'frequencyPerWeek': 2,
          'confidence': 0.9,
        },
        {
          'action': 'ADD_GOAL',
          'title': 'Zhubnout 5 kg',
          'goalType': 'HABIT',
          'priority': 'PRIMARY',
          'horizon': 'MEDIUM_TERM',
        },
        {
          'action': 'SET_AVAILABILITY',
          'dayOfWeek': 'TUE',
          'level': 'AVAILABLE',
          'budgetMinutes': 90,
          'preferredPartOfDay': 'EVENING',
        },
        {'action': 'ADD_CONSTRAINT', 'title': 'Citlivé koleno'},
      ],
    });

    final reply = validateChatReply(raw)!;
    expect(reply.text, contains('potvrď'));
    expect(reply.actions, hasLength(4));
    // Kanonizace zahazuje neznámá pole (CHA-003).
    expect(reply.actions[0].containsKey('confidence'), isFalse);
    expect(reply.actions[0]['customName'], 'Florbal');
    expect(reply.actions[1]['horizon'], 'MEDIUM_TERM');
    expect(reply.actions[2]['budgetMinutes'], 90);
    expect(reply.actions[3]['title'], 'Citlivé koleno');
  });

  test('fenced JSON a odpověď bez akcí jsou validní', () {
    final fenced = validateChatReply(
      '```json\n{"reply":"Jen rada, žádné změny."}\n```',
    )!;
    expect(fenced.text, 'Jen rada, žádné změny.');
    expect(fenced.actions, isEmpty);
  });

  test('nevalidní celek = null: neznámý druh, špatný enum, XOR sportu, '
      'nadlimit akcí, chybějící reply, plain text (CHA-003/004)', () {
    Map<String, Object?> base(String kind) => {
      'reply': 'r',
      'actions': [
        {'action': kind, 'title': 'x'},
      ],
    };
    // Neznámý druh akce → nevalidní celek.
    expect(validateChatReply(jsonEncode(base('DELETE_EVERYTHING'))), isNull);
    // Špatný enum.
    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': [
            {
              'action': 'SET_AVAILABILITY',
              'dayOfWeek': 'PONDELI',
              'level': 'AVAILABLE',
            },
          ],
        }),
      ),
      isNull,
    );
    // sportCode XOR customName.
    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': [
            {
              'action': 'UPSERT_SPORT',
              'sportCode': 'RUNNING',
              'customName': 'Běh',
              'role': 'PRIMARY',
              'priority': 'HIGH',
            },
          ],
        }),
      ),
      isNull,
    );
    // Nadlimit akcí (CHA-004).
    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': List.generate(
            6,
            (i) => {'action': 'ADD_CONSTRAINT', 'title': 'c$i'},
          ),
        }),
      ),
      isNull,
    );
    // Chybějící/prázdné reply.
    expect(validateChatReply(jsonEncode({'actions': []})), isNull);
    expect(validateChatReply(jsonEncode({'reply': '  '})), isNull);
    // Plain text bez JSON.
    expect(validateChatReply('Jen text bez struktury.'), isNull);
  });

  test('REQUEST akce: validní bez polí, kombinace s profilem OK, dvě '
      'REQUEST = nevalidní celek (C49 CHP-002)', () {
    final valid = validateChatReply(
      jsonEncode({
        'reply': 'Připravím návrh.',
        'actions': [
          {'action': 'ADD_CONSTRAINT', 'title': 'Koleno'},
          {'action': 'REQUEST_PLAN', 'extra': 'ignored'},
        ],
      }),
    )!;
    expect(valid.actions, hasLength(2));
    // Kanonizace: REQUEST bez polí (neznámá pole zahazuje).
    expect(valid.actions[1], {'action': 'REQUEST_PLAN'});

    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': [
            {'action': 'REQUEST_PLAN'},
            {'action': 'REQUEST_ADJUSTMENT'},
          ],
        }),
      ),
      isNull,
    );
  });

  test('hraniční hodnoty: rozsahy intů a datum cíle', () {
    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': [
            {
              'action': 'UPSERT_SPORT',
              'customName': 'Běh',
              'role': 'PRIMARY',
              'priority': 'HIGH',
              'frequencyPerWeek': 22,
            },
          ],
        }),
      ),
      isNull,
    );
    expect(
      validateChatReply(
        jsonEncode({
          'reply': 'r',
          'actions': [
            {
              'action': 'ADD_GOAL',
              'title': 'g',
              'goalType': 'HABIT',
              'priority': 'PRIMARY',
              'targetLocalDate': 'neni-datum',
            },
          ],
        }),
      ),
      isNull,
    );
  });
}
