import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/goals/presentation/goals_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-02 widget testy cílů: empty stav, přidání cíle přes formulář,
/// lifecycle akce (complete je terminální — bez menu, GLC-004).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 21);

  Widget app(AppDatabase database) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GoalsScreen(),
    ),
  );

  testWidgets('empty stav → přidání cíle → cíl v seznamu', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.byKey(GoalsScreen.emptyKey), findsOneWidget);

    await tester.tap(find.byKey(GoalsScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('goal_form_title')),
      'Run a half marathon',
    );
    await tester.tap(find.byKey(const Key('goal_form_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(GoalsScreen.emptyKey), findsNothing);
    expect(find.text('Run a half marathon'), findsOneWidget);
  });

  testWidgets('prázdný title zobrazí typovanou chybu a cíl se nepřidá', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(GoalsScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('goal_form_save')));
    await tester.pumpAndSettle();

    // Formulář zůstává otevřený — zavřít a ověřit chybu + prázdný seznam.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.byKey(GoalsScreen.errorBannerKey), findsOneWidget);
    expect(find.byKey(GoalsScreen.emptyKey), findsOneWidget);
  });

  testWidgets('complete uzavře cíl: stav Completed a bez lifecycle menu '
      '(terminální, GLC-004)', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(GoalsScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('goal_form_title')), 'Cíl X');
    await tester.tap(find.byKey(const Key('goal_form_save')));
    await tester.pumpAndSettle();

    final menu = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('goals_menu'),
    );
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Completed'), findsOneWidget);
    // Terminální cíl nemá lifecycle menu.
    expect(menu, findsNothing);
    // Záznam zůstává v seznamu (GLC-005).
    expect(find.text('Cíl X'), findsOneWidget);
  });
}
