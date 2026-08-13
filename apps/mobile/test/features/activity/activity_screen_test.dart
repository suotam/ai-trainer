import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/presentation/activity_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-06 widget testy: empty stavy, zápis aktivity, statistiky se po
/// zápisu přepočítají (PST-001) a „—" pro nedefinovanou úspěšnost
/// (PST-004).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 15);

  Widget app(AppDatabase database) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ActivityScreen(),
    ),
  );

  testWidgets('empty stav: nuly, „—" úspěšnost a prázdný seznam; zápis '
      'aktivity aktualizuje seznam i statistiky', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.byKey(ActivityScreen.emptyKey), findsOneWidget);
    // Nedefinovaná úspěšnost je „—", ne 0/100 % (PST-004).
    expect(find.textContaining('Completion: —'), findsNWidgets(2));

    await tester.tap(find.byKey(ActivityScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('activity_form_title')),
      'Evening run',
    );
    await tester.tap(find.byKey(const Key('activity_form_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(ActivityScreen.emptyKey), findsNothing);
    expect(find.text('Evening run'), findsOneWidget);
    // Statistiky se přepočítaly (aktivita bez vazby → Activities: 1).
    expect(find.textContaining('Activities: 1'), findsNWidgets(2));
  });

  testWidgets('nevalidní zápis (prázdný title) zobrazí typovanou chybu a '
      'nic nepřidá', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ActivityScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('activity_form_save')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(ActivityScreen.errorBannerKey), findsOneWidget);
    expect(find.byKey(ActivityScreen.emptyKey), findsOneWidget);
  });
}
