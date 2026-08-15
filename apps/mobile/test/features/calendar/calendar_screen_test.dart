import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/calendar/presentation/calendar_screen.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R7-05 widget testy kalendáře (C50 §2/§3): měsíční mřížka s výběrem dne
/// (CQC-001/002), poctivé stavy, quick-complete s okamžitým propisem
/// (CQC-010), navigace měsíců.
void main() {
  final now = DateTime.utc(2026, 8, 15, 12);

  Widget app(db) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(() => now),
    ],
    child: const MaterialApp(
      locale: Locale('cs'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CalendarScreen(),
    ),
  );

  testWidgets('měsíc zobrazí workout dne, výběr dne ukáže seznam a '
      'quick-complete se ihned propíše (CQC-001/010)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    final plans = DriftTrainingPlanRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    var seq = 0;
    await plans.addWorkout(
      'p1',
      PlannedWorkoutInput(
        title: 'Silový A',
        workoutType: 'STRENGTH',
        scheduledLocalDate: '2026-08-20',
        exercises: const [
          PlannedExerciseInput(title: 'Dřep', sets: 2, repetitions: 5),
        ],
      ),
      newId: () => 'a-${seq++}',
      now: now,
    );

    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();

    // Hlavička fokusovaného měsíce z hodin (CQC-002).
    expect(find.text('2026-08'), findsOneWidget);
    // Výběr dne s workoutem.
    await tester.tap(find.byKey(CalendarScreen.dayKey('2026-08-20')));
    await tester.pumpAndSettle();
    expect(find.text('Silový A'), findsOneWidget);
    expect(find.textContaining('Naplánováno'), findsOneWidget);

    // Quick-complete → poctivá hláška + stav Dokončeno (CQC-004/010).
    await tester.tap(find.text('Splněno'));
    await tester.pumpAndSettle();
    expect(find.byKey(CalendarScreen.resultKey), findsOneWidget);
    expect(find.textContaining('bez měřených kroků'), findsOneWidget);
    expect(find.textContaining('Dokončeno bez měření'), findsOneWidget);
    // Tlačítko zmizí — dokončený workout se neodklikává znovu.
    expect(find.text('Splněno'), findsNothing);
  });

  testWidgets('navigace měsíců je deterministická (CQC-002)', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(app(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(CalendarScreen.prevMonthKey));
    await tester.pumpAndSettle();
    expect(find.text('2026-07'), findsOneWidget);
    await tester.tap(find.byKey(CalendarScreen.nextMonthKey));
    await tester.tap(find.byKey(CalendarScreen.nextMonthKey));
    await tester.pumpAndSettle();
    expect(find.text('2026-09'), findsOneWidget);
  });
}
