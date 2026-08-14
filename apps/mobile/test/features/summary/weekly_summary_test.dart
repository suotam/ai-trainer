import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/activity/domain/manual_activity.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/notifications/data/app_state_reminder_boundaries.dart';
import 'package:ai_trainer_mobile/features/notifications/domain/reminder_plan.dart';
import 'package:ai_trainer_mobile/features/plan/data/drift_training_plan_repository.dart';
import 'package:ai_trainer_mobile/features/plan/domain/training_plan.dart';
import 'package:ai_trainer_mobile/features/summary/domain/weekly_summary.dart';
import 'package:ai_trainer_mobile/features/summary/presentation/weekly_summary_screen.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R5-07 testy (C39/C40): mapovací matice vysvětlení a determinismus
/// souhrnu (WKS-003/001), matice reminder plánu (NTF-003/004), persistence
/// opt-in přepínačů (NTF-002/008) a widget obrazovky s poctivými stavy.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  ProgressStatistics stats(int planned, int completed) => ProgressStatistics(
    fromLocalDate: '2026-08-08',
    toLocalDate: '2026-08-14',
    plannedCount: planned,
    completedCount: completed,
    manualActivityCount: 0,
    manualMinutes: 0,
  );

  test('vysvětlení progresu: mapovací matice z faktů (WKS-003) a '
      'deterministické agregáty (WKS-013)', () {
    final cases = <(int, int, ProgressExplanation)>[
      (0, 0, ProgressExplanation.noData),
      (3, 1, ProgressExplanation.improving),
      (2, 2, ProgressExplanation.steady),
      (1, 4, ProgressExplanation.slowing),
    ];
    for (final (current, previous, expected) in cases) {
      final summary = buildWeeklySummary(
        fromLocalDate: '2026-08-08',
        toLocalDate: '2026-08-14',
        current: stats(5, current),
        previous: stats(5, previous),
        weekCheckIns: const [],
      );
      expect(summary.explanation, expected, reason: '$current vs $previous');
    }

    final checkIns = [
      for (final (date, energy, fatigue, pain) in [
        ('2026-08-12', 4, 2, null),
        ('2026-08-13', 3, 3, 2),
        ('2026-08-14', 2, 4, null),
      ])
        DailyCheckIn(
          id: date,
          localDate: date,
          energyLevel: energy,
          fatigueLevel: fatigue,
          painLevel: pain,
          painAreaCode: pain == null ? null : 'KNEE',
          createdAtMillis: 0,
          updatedAtMillis: 0,
        ),
    ];
    final summary = buildWeeklySummary(
      fromLocalDate: '2026-08-08',
      toLocalDate: '2026-08-14',
      current: stats(4, 2),
      previous: stats(4, 2),
      weekCheckIns: checkIns,
    );
    expect(summary.checkIns.checkInCount, 3);
    expect(summary.checkIns.averageEnergy, 3.0);
    expect(summary.checkIns.averageFatigue, 3.0);
    expect(summary.checkIns.painDays, 1);
    // Determinismus (WKS-001): identický opakovaný výpočet.
    final again = buildWeeklySummary(
      fromLocalDate: '2026-08-08',
      toLocalDate: '2026-08-14',
      current: stats(4, 2),
      previous: stats(4, 2),
      weekCheckIns: checkIns,
    );
    expect(again.explanation, summary.explanation);
    expect(again.checkIns.averageEnergy, summary.checkIns.averageEnergy);
  });

  test('reminder plán: opt-in a relevance matice (NTF-002/003/004); '
      'persistence přepínačů (NTF-008)', () async {
    // Matice čisté funkce.
    const enabledBoth = ReminderSettings(
      checkInEnabled: true,
      workoutEnabled: true,
    );
    final cases = <(ReminderSettings, bool, int, List<ReminderType>)>[
      // Default vypnuto = nikdy (NTF-002).
      (const ReminderSettings(), false, 3, []),
      // Check-in připomínka jen bez dnešního check-inu (NTF-004).
      (enabledBoth, true, 0, []),
      (enabledBoth, false, 0, [ReminderType.checkIn]),
      // Workout připomínka jen s neproběhlým workoutem.
      (enabledBoth, false, 2, [ReminderType.checkIn, ReminderType.workout]),
      (enabledBoth, true, 1, [ReminderType.workout]),
    ];
    for (final (settings, hasCheckIn, pending, expected) in cases) {
      final plan = computeDailyReminderPlan(
        settings: settings,
        hasCheckInToday: hasCheckIn,
        pendingWorkoutsToday: pending,
      );
      expect(
        plan.map((r) => r.type).toList(),
        expected,
        reason: 'checkIn=$hasCheckIn pending=$pending',
      );
    }
    // Fixní P0 časy (NTF-011).
    final full = computeDailyReminderPlan(
      settings: enabledBoth,
      hasCheckInToday: false,
      pendingWorkoutsToday: 1,
    );
    expect(full.map((r) => r.localTime), ['08:00', '17:00']);

    // Persistence: default vypnuto → uložení → načtení.
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = AppStateReminderSettingsRepository(db);
    final initial = await repo.load();
    expect(initial.checkInEnabled, isFalse);
    expect(initial.workoutEnabled, isFalse);
    await repo.save(
      const ReminderSettings(checkInEnabled: true, workoutEnabled: false),
    );
    final loaded = await repo.load();
    expect(loaded.checkInEnabled, isTrue);
    expect(loaded.workoutEnabled, isFalse);
  });

  testWidgets('widget: fakta, vysvětlení, poctivý prázdný check-in stav a '
      'opt-in přepínače s persistencí (WKS-004, NTF-002)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    // Dokončený workout v aktuálním okně → IMPROVING vůči prázdné minulé.
    final plans = DriftTrainingPlanRepository(db);
    await plans.createPlan(title: 'Plán', newId: 'p1', now: now);
    await plans.addWorkout(
      'p1',
      PlannedWorkoutInput(
        title: 'Dnešní',
        workoutType: 'STRENGTH',
        scheduledLocalDate: formatLocalDate(now),
      ),
      newId: () => 'w1',
      now: now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WeeklySummaryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(WeeklySummaryScreen.explanationKey), findsOneWidget);
    // Bez dokončených workoutů je vysvětlení poctivé NO_DATA (WKS-004).
    expect(find.textContaining('No completed workouts'), findsOneWidget);
    // Naplánovaný workout v okně je vidět ve faktech (C23 čísla).
    expect(find.byKey(const Key('summary_planned')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    // Poctivý prázdný check-in stav (WKS-004).
    expect(find.text('No check-ins this week.'), findsOneWidget);

    // Opt-in přepínač: zapnutí se persistuje (NTF-002/008).
    await tester.ensureVisible(
      find.byKey(WeeklySummaryScreen.checkInReminderKey),
    );
    await tester.tap(find.byKey(WeeklySummaryScreen.checkInReminderKey));
    await tester.pumpAndSettle();
    final saved = await AppStateReminderSettingsRepository(db).load();
    expect(saved.checkInEnabled, isTrue);

    // Check-in v okně → agregáty viditelné.
    await DriftDailyCheckInRepository(db).saveForDate(
      formatLocalDate(now),
      const DailyCheckInInput(energyLevel: 4, fatigueLevel: 2),
      newId: 'ci1',
      now: now,
    );
  });
}
