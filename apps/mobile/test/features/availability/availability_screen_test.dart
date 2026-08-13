import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/availability/presentation/availability_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-03 widget testy dostupnosti: deklarace dne, přidání vybavení,
/// přidání a vyřešení omezení (stavy, ne mazání).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 8);

  Widget app(AppDatabase database) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AvailabilityScreen(),
    ),
  );

  testWidgets('deklarace dne: Monday „Not set" → uložit → level viditelný', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.text('Not set'), findsNWidgets(7));

    await tester.tap(find.byKey(AvailabilityScreen.dayKey('MON')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('day_form_save')));
    await tester.pumpAndSettle();

    expect(find.text('Not set'), findsNWidgets(6));
    expect(find.text('Available'), findsOneWidget);
  });

  testWidgets('vybavení: přidání katalogové položky a archivace jako stav', (
    tester,
  ) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AvailabilityScreen.equipmentAddKey));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('equipment_form_item')), findsOneWidget);
    await tester.tap(find.byKey(const Key('equipment_form_save')));
    await tester.pumpAndSettle();
    expect(find.byKey(AvailabilityScreen.errorBannerKey), findsNothing);
    expect(find.byKey(const Key('equipment_form_item')), findsNothing);

    // Dlaždice je pod viewportem — doscrollovat (lazy ListView).
    await tester.scrollUntilVisible(
      find.text('Gym access'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gym access'), findsOneWidget);

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    // Archivovaná položka zůstává viditelná se stavem (AVC-007).
    expect(find.text('Gym access'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
    expect(find.text('Reactivate'), findsOneWidget);
  });

  testWidgets('omezení: přidání a vyřešení jako stav', (tester) async {
    // Vyšší viewport — sekce omezení je pod týdnem a vybavením.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(AvailabilityScreen.constraintAddKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('constraint_form_title')),
      'Sore knee',
    );
    await tester.tap(find.byKey(const Key('constraint_form_save')));
    await tester.pumpAndSettle();

    final toggle = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('constraint_toggle'),
    );
    expect(find.text('Sore knee'), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text('Sore knee'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
  });
}
