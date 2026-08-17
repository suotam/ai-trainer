import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/workouts/application/guided_session_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/application/workout_providers.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/guided_session_card.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';
import '../../support/workout_test_scope.dart';

/// R8-03 widget průchod průvodcem nad skutečnou SQLite se seedem R1
/// (C53 §8/§10): krok → Hotovo (sada) → odpočet pauzy → Další sada →
/// přeskočit krok → pauza/pokračovat; obnova = nový ProviderScope nad
/// touž DB ukazuje stejný krok a zbytek odpočtu (GSP-007). Čas řízen
/// injektovaným clockem, ticker vypnutý (GSP-005: časy z uložených značek).
void main() {
  final t0 = DateTime.utc(2026, 8, 16, 9);
  var now = t0;

  Widget app(AppDatabase db) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => now),
      r1SeedRepositoryProvider.overrideWithValue(
        FakeSeedRepository([SeedResult.applied]),
      ),
      guidedTickerProvider.overrideWith((ref) => const Stream<int>.empty()),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ActiveSessionScreen(sessionId: 'ses-1'),
    ),
  );

  Future<AppDatabase> seeded() async {
    final db = createTestDatabase();
    await DriftR1SeedRepository(db, now: () => t0).applySeed();
    await DriftWorkoutSessionRepository(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: t0,
    );
    return db;
  }

  testWidgets('sada → Hotovo → odpočet pauzy → Další sada → přeskočit → '
      'pauza/pokračovat; obnova drží krok i zbytek odpočtu', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    now = t0;
    final db = await seeded();
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();

    // Průvodce začíná prvním nedokončeným sledovaným krokem seedu (Goblet
    // squat: 3 sady, pauza 120 s) — Jumping jacks je DURATION krok bez
    // výkonů (index 0), proto Step 2/4.
    expect(find.byKey(GuidedSessionCard.cardKey), findsOneWidget);
    expect(find.text('Goblet squat'), findsWidgets);
    expect(find.text('Set 1 of 3'), findsOneWidget);
    expect(find.text('Step 2/4 · sets 0/6'), findsOneWidget);
    expect(find.text('rest 120 s'), findsOneWidget);

    // Hotovo → sada dokončena, běží odpočet 120 s.
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey));
    await tester.pumpAndSettle();
    expect(find.text('Rest before the next set'), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
    expect(find.text('Step 2/4 · sets 1/6'), findsOneWidget);

    // Čas běží 50 s → 1:10; obnova (nový scope nad touž DB) drží stav.
    now = t0.add(const Duration(seconds: 50));
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();
    expect(find.text('Rest before the next set'), findsOneWidget);
    expect(find.text('1:10'), findsOneWidget);
    expect(find.text('Step 2/4 · sets 1/6'), findsOneWidget);

    // Pauza zmrazí odpočet i uplynulý čas (GSP-009).
    await tester.tap(find.byKey(GuidedSessionCard.pauseKey));
    await tester.pumpAndSettle();
    expect(find.text('Paused — timers are frozen.'), findsOneWidget);
    now = t0.add(const Duration(seconds: 200));
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();
    expect(find.text('1:10'), findsOneWidget);
    expect(find.text('0:50'), findsOneWidget); // uplynulý čas
    await tester.tap(find.byKey(GuidedSessionCard.pauseKey));
    await tester.pumpAndSettle();
    // Po resume: odpočet pokračuje ze zmrazených 70 s (200 s pauzy se
    // nepočítá) — za 15 s zbývá 0:55; uplynulý aktivní čas 50 + 15 = 1:05.
    now = t0.add(const Duration(seconds: 215));
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();
    expect(find.text('0:55'), findsOneWidget);
    expect(find.text('1:05'), findsOneWidget);

    // Další sada (uživatelské potvrzení, GSP-006).
    await tester.tap(find.byKey(GuidedSessionCard.primaryActionKey));
    await tester.pumpAndSettle();
    expect(find.text('Set 2 of 3'), findsOneWidget);

    // Přeskočit krok → poctivě SKIPPED, průvodce na dalším kroku.
    await tester.tap(find.byKey(GuidedSessionCard.skipKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(GuidedSessionCard.nextKey));
    await tester.pumpAndSettle();
    expect(find.text('Dumbbell bench press'), findsWidgets);
    expect(find.text('Step 3/4 · sets 1/6'), findsOneWidget);
    final skipped = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM local_step_performances WHERE status = 'SKIPPED'",
        )
        .getSingle();
    expect(skipped.data['c'], 1);
    final skippedSets = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM local_set_performances WHERE status = 'SKIPPED'",
        )
        .getSingle();
    expect(skippedSets.data['c'], 2);
    // Plochý zápis pod průvodcem zůstává (C53 §8) i tlačítko dokončení.
    expect(find.text('All sets'), findsOneWidget);
    expect(find.byKey(ActiveSessionScreen.completeButtonKey), findsOneWidget);
  });
}
