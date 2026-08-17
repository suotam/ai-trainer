import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/plan/presentation/plan_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-04 widget testy ručního plánu: vytvoření plánu, přidání workoutu
/// s cvikem, archivace (stav, ne mazání).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fixedNow = DateTime.utc(2026, 8, 14, 12);

  Widget app(AppDatabase database) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      clockProvider.overrideWithValue(() => fixedNow),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PlanScreen(),
    ),
  );

  testWidgets('vytvoření plánu → přidání workoutu s cvikem → workout '
      'v seznamu plánu', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    expect(find.byKey(PlanScreen.emptyKey), findsOneWidget);

    await tester.enterText(
      find.byKey(PlanScreen.createFieldKey),
      'Můj první plán',
    );
    await tester.tap(find.byKey(PlanScreen.createButtonKey));
    await tester.pumpAndSettle();

    // Plán vytvořen — prázdný seznam workoutů.
    expect(find.text('Můj první plán'), findsOneWidget);
    expect(find.byKey(PlanScreen.workoutsEmptyKey), findsOneWidget);

    // Přidat workout s jedním cvikem (datum je předvyplněné dneškem).
    await tester.tap(find.byKey(PlanScreen.addWorkoutKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workout_form_title')),
      'Silový A',
    );
    await tester.tap(find.byKey(const Key('workout_form_add_exercise')));
    await tester.pumpAndSettle();
    // Vlastní cvik bez popisu provedení se neuloží (C51 EXC-008).
    await tester.enterText(find.byKey(const Key('exercise_name_0')), 'Dřep');
    await tester.tap(find.byKey(const Key('workout_form_save')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('workout_form_custom_needs_instructions')),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('exercise_instructions_0')),
      'Nohy na šířku ramen, dřep do paralelu.',
    );
    // Druhý cvik z katalogu: výběr z návrhů nastaví exercise_code (C51 §7).
    await tester.tap(find.byKey(const Key('workout_form_add_exercise')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exercise_name_1')), 'plank');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('exercise_option_PLANK')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workout_form_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(PlanScreen.workoutsEmptyKey), findsNothing);
    expect(find.text('Silový A'), findsOneWidget);
    final steps = await database
        .customSelect(
          'SELECT title, exercise_code, instructions, prescription_type '
          'FROM local_workout_steps ORDER BY position',
        )
        .get();
    expect(steps, hasLength(2));
    expect(steps[0].data['exercise_code'], isNull);
    expect(steps[0].data['instructions'], contains('paralelu'));
    expect(steps[1].data['exercise_code'], 'PLANK');
    // PLANK je DURATION cvik — výchozí předpis katalogu (EXC-010).
    expect(steps[1].data['prescription_type'], 'DURATION');
  });

  testWidgets('zrušení workoutu z menu: stav Cancelled viditelný v plánu '
      '(CAL-004/008)', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(PlanScreen.createFieldKey), 'Plán');
    await tester.tap(find.byKey(PlanScreen.createButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(PlanScreen.addWorkoutKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workout_form_title')),
      'Ke zrušení',
    );
    await tester.tap(find.byKey(const Key('workout_form_save')));
    await tester.pumpAndSettle();

    final menu = find.byWidgetPredicate(
      (w) => w.key != null && w.key.toString().contains('plan_workout_menu'),
    );
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel workout'));
    await tester.pumpAndSettle();

    // Zrušený zůstává v editoru plánu se stavem; menu už nenabízí operace.
    expect(find.text('Ke zrušení'), findsOneWidget);
    expect(find.textContaining('Cancelled'), findsOneWidget);
    expect(menu, findsNothing);
  });

  testWidgets('archivace plánu je stav: obrazovka nabídne vytvoření nového '
      'a archivovaný zůstává viditelný', (tester) async {
    final database = createTestDatabase();
    addTearDown(database.close);
    await tester.pumpWidget(app(database));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(PlanScreen.createFieldKey), 'Starý plán');
    await tester.tap(find.byKey(PlanScreen.createButtonKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('plan_archive_action')));
    await tester.pumpAndSettle();

    // Zpět na create sekci; archivovaný plán je v seznamu (MPC-003).
    expect(find.byKey(PlanScreen.emptyKey), findsOneWidget);
    expect(find.text('Starý plán'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);
  });
}
