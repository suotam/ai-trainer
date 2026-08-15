import 'dart:convert';

import 'package:ai_trainer_mobile/features/ai/application/ai_providers.dart';
import 'package:ai_trainer_mobile/features/ai/data/anthropic_direct_client.dart';
import 'package:ai_trainer_mobile/features/ai/domain/byok_key_store.dart';
import 'package:ai_trainer_mobile/features/ai/presentation/ai_key_settings_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// R7-01 widget testy správy klíče (C46 §2/§5): uložení + maska (nikdy
/// celý klíč, BYK-002), smazání (BYK-014), explicitní ověření (BYK-012).
class _InMemoryKeyStore implements ByokKeyStore {
  String? key;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;

  @override
  Future<void> clear() async => key = null;
}

void main() {
  Widget app(_InMemoryKeyStore store, {http.Client? httpClient}) =>
      ProviderScope(
        overrides: [
          byokKeyStoreProvider.overrideWithValue(store),
          if (httpClient != null)
            aiApiClientProvider.overrideWithValue(
              AnthropicDirectClient(keyStore: store, httpClient: httpClient),
            ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AiKeySettingsScreen(),
        ),
      );

  testWidgets('uložení klíče zobrazí masku a nikdy celý klíč; smazání vrací '
      'poctivý prázdný stav (BYK-002/014)', (tester) async {
    final store = _InMemoryKeyStore();
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();

    expect(find.text('No key stored - AI features are off.'), findsOneWidget);

    await tester.enterText(
      find.byKey(AiKeySettingsScreen.fieldKey),
      'sk-ant-test-abcd-1234',
    );
    await tester.tap(find.byKey(AiKeySettingsScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(store.key, 'sk-ant-test-abcd-1234');
    expect(find.textContaining('••••1234'), findsOneWidget);
    expect(find.textContaining('sk-ant-test-abcd'), findsNothing);

    await tester.tap(find.byKey(AiKeySettingsScreen.deleteButtonKey));
    await tester.pumpAndSettle();
    expect(store.key, isNull);
    expect(find.text('No key stored - AI features are off.'), findsOneWidget);
  });

  testWidgets('prázdný vstup se neuloží; ověření vrací typovaný výsledek '
      '(BYK-012)', (tester) async {
    final store = _InMemoryKeyStore()..key = 'sk-ant-existing-9999';
    final mock = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'model': 'claude-sonnet-5',
          'content': [
            {'type': 'text', 'text': 'OK'},
          ],
        }),
        200,
      ),
    );
    await tester.pumpWidget(app(store, httpClient: mock));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(AiKeySettingsScreen.fieldKey), '   ');
    await tester.tap(find.byKey(AiKeySettingsScreen.saveButtonKey));
    await tester.pumpAndSettle();
    expect(store.key, 'sk-ant-existing-9999');

    await tester.tap(find.byKey(AiKeySettingsScreen.verifyButtonKey));
    await tester.pumpAndSettle();
    expect(find.text('The key works.'), findsOneWidget);
  });
}
