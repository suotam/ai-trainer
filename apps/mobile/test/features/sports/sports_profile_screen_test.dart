import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/sports/presentation/sports_profile_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-01 widget testy sportovního profilu: empty stav, přidání sportu přes
/// formulář, lifecycle akce a typovaná chyba invariantu (ASP-003).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 13, 18);

  Widget app(AppDatabase database) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SportsProfileScreen(),
    ),
  );

  testWidgets('empty stav → přidání katalogového sportu → sport v seznamu', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.byKey(SportsProfileScreen.emptyKey), findsOneWidget);

    await tester.tap(find.byKey(SportsProfileScreen.addButtonKey));
    await tester.pumpAndSettle();
    // Výchozí sport (STRENGTH_TRAINING) + výchozí role — rovnou uložit.
    await tester.tap(find.byKey(const Key('sport_form_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(SportsProfileScreen.emptyKey), findsNothing);
    expect(find.text('Strength training'), findsOneWidget);
  });

  testWidgets('druhý ACTIVE PRIMARY zobrazí typovanou chybu (ASP-003) a '
      'sport se nepřidá', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    Future<void> addPrimary(String sportLabel) async {
      await tester.tap(find.byKey(SportsProfileScreen.addButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sport_form_sport')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(sportLabel).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sport_form_role')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Primary').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sport_form_save')));
      await tester.pumpAndSettle();
    }

    await addPrimary('Running');
    await addPrimary('Yoga');

    // Neúspěšné uložení nechává formulář otevřený — zavřít a ověřit seznam.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(SportsProfileScreen.errorBannerKey), findsOneWidget);
    expect(
      find.text('You already have an active primary sport.'),
      findsOneWidget,
    );
    // Yoga se nepřidala; Running v seznamu je.
    expect(find.text('Yoga'), findsNothing);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('lifecycle akce: pause zobrazí stav Paused, end ponechá '
      'záznam v seznamu (ASP-008)', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SportsProfileScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sport_form_save')));
    await tester.pumpAndSettle();

    final menu = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('sports_profile_menu'),
    );
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Paused'), findsOneWidget);

    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('End'));
    await tester.pumpAndSettle();
    // Ukončený sport zůstává viditelný (konec je stav, ne mazání).
    expect(find.textContaining('Ended'), findsOneWidget);
    expect(find.text('Strength training'), findsOneWidget);
  });
}
