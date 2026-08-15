import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/http_ai_api_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/chat/application/chat_providers.dart';
import 'package:ai_trainer_mobile/features/chat/domain/chat_ai_client.dart';
import 'package:ai_trainer_mobile/features/chat/presentation/chat_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R7-02 widget testy chatu (C47 §3): prázdný stav s poctivou hranicí,
/// odeslání → odpověď, typované selhání s explicitním retry (CHC-005),
/// chybějící klíč jako viditelný stav (CHC-009).
class _ScriptedChatClient implements ChatAiClient {
  _ScriptedChatClient(this._behavior);

  final Future<String> Function() _behavior;
  int calls = 0;

  @override
  Future<String> chat({
    required List<ChatTurn> turns,
    required Map<String, Object?> profileContext,
  }) {
    calls++;
    return _behavior();
  }
}

/// Fake proposal pipeline API (C27–C29 cesta) — skriptovaná odpověď.
class _ScriptedProposalApi implements AiApiClient {
  _ScriptedProposalApi(this._behavior);

  final Future<PlanProposalResponse> Function() _behavior;

  @override
  Future<PlanProposalResponse> requestPlanProposal({
    required Map<String, Object?> context,
    String requestType = 'PLAN_PROPOSAL',
  }) => _behavior();
}

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
  Widget app({
    required db,
    required ChatAiClient client,
    String? storedKey = 'sk-ant-x-1234',
    AiApiClient? proposalApi,
  }) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      chatAiClientProvider.overrideWithValue(client),
      byokKeyStoreProvider.overrideWithValue(_InMemoryKeyStore(storedKey)),
      if (proposalApi != null)
        aiApiClientProvider.overrideWithValue(proposalApi),
    ],
    child: const MaterialApp(
      locale: Locale('cs'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChatScreen(),
    ),
  );

  testWidgets('prázdný stav → odeslání → odpověď asistenta v bublině '
      '(CHC-003)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final client = _ScriptedChatClient(
      () async => '{"reply":"Trénuj zlehka."}',
    );

    await tester.pumpWidget(app(db: db, client: client));
    await tester.pumpAndSettle();
    expect(find.byKey(ChatScreen.emptyKey), findsOneWidget);
    expect(find.byKey(ChatScreen.noKeyBannerKey), findsNothing);

    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Jak na dnešek?');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Jak na dnešek?'), findsOneWidget);
    expect(find.text('Trénuj zlehka.'), findsOneWidget);
    expect(client.calls, 1);
  });

  testWidgets('selhání je typované s explicitním retry; retry dokončí '
      '(CHC-005/010)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    var fail = true;
    final client = _ScriptedChatClient(() async {
      if (fail) {
        throw Exception('síť');
      }
      return '{"reply":"Už to jde."}';
    });

    await tester.pumpWidget(app(db: db, client: client));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Test');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();

    // Typované selhání + zpráva uživatele zůstává (CHC-011).
    expect(find.text('Test'), findsOneWidget);
    expect(find.textContaining('Odpověď se nepovedla'), findsOneWidget);
    final retryButton = find.textContaining('Zkusit znovu');
    expect(retryButton, findsOneWidget);

    fail = false;
    await tester.tap(retryButton);
    await tester.pumpAndSettle();
    expect(find.text('Už to jde.'), findsOneWidget);
    // Retry nad týmž řádkem — žádná duplicitní bublina (CHC-005).
    expect(find.text('Test'), findsOneWidget);
    expect(client.calls, 2);
  });

  testWidgets('akce z chatu: karta → potvrzení provede repos a stav je '
      'trvale viditelný; odmítnutí bez efektu (C48 CHA-001/005/006)', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final client = _ScriptedChatClient(
      () async =>
          '{"reply":"Navrhuji zapsat omezení a dostupnost.","actions":['
          '{"action":"ADD_CONSTRAINT","title":"Citlivé koleno"},'
          '{"action":"SET_AVAILABILITY","dayOfWeek":"TUE","level":"AVAILABLE"}'
          ']}',
    );
    await tester.pumpWidget(app(db: db, client: client));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Bolí mě koleno');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();

    // Karty navržených akcí; před potvrzením žádný efekt (CHA-006).
    expect(find.text('Potvrdit'), findsNWidgets(2));
    Future<int> constraints() async =>
        (await db
                    .customSelect('SELECT COUNT(*) AS c FROM local_constraints')
                    .getSingle())
                .data['c']
            as int;
    expect(await constraints(), 0);

    // Potvrzení první akce (omezení) → provedeno repos (CHA-001).
    await tester.tap(find.text('Potvrdit').first);
    await tester.pumpAndSettle();
    expect(await constraints(), 1);
    expect(find.text('Zapsáno do profilu.'), findsOneWidget);

    // Odmítnutí druhé akce → viditelný trvalý stav, žádný efekt.
    await tester.tap(find.text('Odmítnout'));
    await tester.pumpAndSettle();
    expect(find.text('Odmítnuto.'), findsOneWidget);
    final rules = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_availability_rules')
        .getSingle();
    expect(rules.data['c'], 0);
  });

  testWidgets('REQUEST_PLAN: pipeline → karta návrhu z C29 → potvrzení '
      'provede a plán existuje (C49 CHP-001/004/007)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final chatClient = _ScriptedChatClient(
      () async =>
          '{"reply":"Připravím ti týden — návrh potvrď níže.",'
          '"actions":[{"action":"REQUEST_PLAN"}]}',
    );
    final proposalApi = _ScriptedProposalApi(
      () async => PlanProposalResponse(
        proposal: {
          'summary': 'Lehký startovní týden.',
          'planTitle': 'Chat týden',
          'workouts': [
            {
              'title': 'Full Body A',
              'workoutType': 'STRENGTH',
              'dayOffset': 0,
              'reason': 'Základní stimul.',
            },
          ],
        },
        promptVersion: 'plan-proposal-v2',
        schemaVersion: 'plan-proposal-schema-v1',
        modelId: 'fake-model',
      ),
    );
    await tester.pumpWidget(
      app(db: db, client: chatClient, proposalApi: proposalApi),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Postav mi týden');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();

    // Karta návrhu čte C29 úložiště (CHP-001/009).
    expect(find.text('Chat týden'), findsOneWidget);
    expect(find.textContaining('Full Body A'), findsOneWidget);
    // Před potvrzením žádný plán (CHP-004).
    Future<int> plans() async =>
        (await db
                    .customSelect(
                      'SELECT COUNT(*) AS c FROM local_training_plans',
                    )
                    .getSingle())
                .data['c']
            as int;
    expect(await plans(), 0);

    // Potvrzení v chatu = C29 rozhodnutí + C30 provedení (CHP-007).
    await tester.tap(find.text('Přijmout návrh'));
    await tester.pumpAndSettle();
    expect(await plans(), 1);
    final instances = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_instances')
        .getSingle();
    expect(instances.data['c'], 1);
  });

  testWidgets('REQUEST_PLAN selhání pipeline je typované FAILED s retry '
      '(CHP-005)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final chatClient = _ScriptedChatClient(
      () async => '{"reply":"Zkusím.","actions":[{"action":"REQUEST_PLAN"}]}',
    );
    var fail = true;
    final proposalApi = _ScriptedProposalApi(() async {
      if (fail) {
        throw const AiApiFailure(AiApiFailureKind.unavailable);
      }
      return PlanProposalResponse(
        proposal: {
          'summary': 's',
          'planTitle': 'Po retry',
          'workouts': [
            {
              'title': 'W',
              'workoutType': 'STRENGTH',
              'dayOffset': 0,
              'reason': 'r',
            },
          ],
        },
        promptVersion: 'plan-proposal-v2',
        schemaVersion: 'plan-proposal-schema-v1',
        modelId: 'fake-model',
      );
    });
    await tester.pumpWidget(
      app(db: db, client: chatClient, proposalApi: proposalApi),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(ChatScreen.inputKey), 'Plán prosím');
    await tester.tap(find.byKey(ChatScreen.sendButtonKey));
    await tester.pumpAndSettle();

    // Typované selhání akce s explicitním retry (CHP-005).
    expect(find.text('Změnu se nepodařilo provést.'), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Zkusit znovu'));
    await tester.pumpAndSettle();
    expect(find.text('Po retry'), findsOneWidget);
  });

  testWidgets('bez klíče je viditelný banner s odkazem na správu klíče '
      '(CHC-009)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final client = _ScriptedChatClient(() async => '{"reply":"x"}');

    await tester.pumpWidget(app(db: db, client: client, storedKey: null));
    await tester.pumpAndSettle();

    expect(find.byKey(ChatScreen.noKeyBannerKey), findsOneWidget);
    expect(
      find.text('Chat potřebuje tvůj Anthropic API klíč.'),
      findsOneWidget,
    );
  });
}
