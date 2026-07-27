import 'package:ai_trainer_mobile/app/bootstrap/ai_trainer_app.dart';
import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/active_session_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/feedback_confirm_dialog.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/history_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/today_screen.dart';
import 'package:ai_trainer_mobile/features/workouts/presentation/workout_detail_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// R1-08 – Critical End-to-End Evidence (VSP §19, test-strategy §11.2).
///
/// Automatizovaný důkaz hlavní hodnoty R1 na Flutter runtime nad **skutečnou
/// lokální SQLite persistence** (skutečné Drift repozitáře, žádné faky,
/// žádný backend, žádná síť). Deterministický: fixní clock, verzovaný seed,
/// stabilní ID a **bounded pumpy** (fokusovaný TextField má blikající kurzor =
/// nekonečná animace, na kterou by `pumpAndSettle` čekal donekonečna).
///
/// „Restart" je simulován kompletním odmontováním app vrstvy (nový
/// `ProviderScope` → zahození všech widgetů i in-memory session stavu) při
/// zachování stejné lokální databáze. Obnovená app tak musí číst výhradně
/// z persistence. Jediné overrides jsou technické hranice (DB, clock, ID) —
/// samotné repozitáře, bootstrap, recovery a completion jsou skutečné.
///
/// Povinný scénář: 1. start s lokálními demo daty, 2. otevření dnešního
/// workoutu, 3. zahájení session, 4. zápis výkonu, 5. ukončení a znovuspuštění,
/// 6. recovery aktivní session, 7. dokončení, 8. workout v historii,
/// 9. bez backendu a sítě.
void main() {
  final now = DateTime(2026, 7, 20, 8);

  // Deterministický „settle" bez závislosti na animacích (bez cursor-blink
  // hangu) — pumpuje pevný počet snímků, což stačí na seed, recovery, navigaci
  // i lokální DB zápisy skutečné SQLite.
  Future<void> settle(WidgetTester tester, [int times = 40]) async {
    for (var i = 0; i < times; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  testWidgets(
    'R1 critical path: seed → start → zápis → restart → recovery → dokončení → historie',
    (tester) async {
      // Jedna skutečná SQLite databáze sdílená přes „restart" app vrstvy.
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      Widget app() => ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
          idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
        ],
        child: const AiTrainerApp(),
      );

      // ── Fáze A: start s demo daty, otevření workoutu, session, zápis ──
      await tester.pumpWidget(app());
      await settle(tester);

      // 1–2. Startup gate → Today s dnešním demo workoutem (ze seedu).
      expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
      expect(
        find.byKey(TodayScreen.cardKey('demo-w1-instance')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(TodayScreen.cardKey('demo-w1-instance')));
      await settle(tester);
      expect(find.byKey(WorkoutDetailScreen.screenKey), findsOneWidget);

      // 3. Zahájení session → active session tracker.
      await tester.tap(find.byKey(WorkoutDetailScreen.startButtonKey));
      await settle(tester);
      expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);

      // 4. Zápis alespoň jednoho výkonu: reps prvního setu + Save.
      await tester.enterText(find.byType(TextField).first, '10');
      await settle(tester, 6);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Save').first);
      await settle(tester);
      // Uložení potvrzeno v UI (viditelný stav lokálního uložení).
      expect(find.text('Saved'), findsOneWidget);

      // 5. „Ukončení a znovuspuštění": zahodit celou app vrstvu a znovu ji
      //    postavit nad stejnou persistence.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(app());
      await settle(tester);

      // 6. Recovery aktivní session → tracker se stejným uloženým výkonem
      //    (čteno výhradně z persistence).
      expect(find.byKey(ActiveSessionScreen.screenKey), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '10',
      );

      // 7. Dokončení workoutu (feedback přeskočen) → navigace do historie.
      //    Complete button je dole v ListView (líné buildování) — doscrolluj
      //    ručně přes bounded pumpy.
      final list = find.byType(Scrollable).first;
      for (
        var i = 0;
        i < 12 &&
            find
                .byKey(ActiveSessionScreen.completeButtonKey)
                .evaluate()
                .isEmpty;
        i++
      ) {
        await tester.drag(list, const Offset(0, -400));
        await settle(tester, 4);
      }
      await tester.tap(find.byKey(ActiveSessionScreen.completeButtonKey));
      await settle(tester);
      await tester.tap(find.byKey(FeedbackConfirmDialog.confirmKey));
      await settle(tester);

      // 8. Workout se objeví v historii.
      expect(find.byKey(HistoryScreen.screenKey), findsOneWidget);
      expect(find.byKey(HistoryScreen.listKey), findsOneWidget);
      expect(find.textContaining('Full Body Strength (Demo)'), findsOneWidget);

      // Otevři dokončený read-only detail a ověř zachovaný výkon.
      await tester.tap(find.byType(Card).first);
      await settle(tester);
      expect(find.textContaining('Actual: 10 reps'), findsOneWidget);

      // 9. Celý tok proběhl bez backendu a bez sítě (žádný HTTP klient v scope).

      // Dokončený workout přežije i další „restart" app vrstvy → historie.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpWidget(app());
      await settle(tester);
      await tester.tap(find.byKey(TodayScreen.historyActionKey));
      await settle(tester);
      expect(find.textContaining('Full Body Strength (Demo)'), findsOneWidget);
    },
  );
}
