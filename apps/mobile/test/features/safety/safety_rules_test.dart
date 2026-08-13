import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/availability/domain/availability_profile.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/checkin/presentation/checkin_screen.dart';
import 'package:ai_trainer_mobile/features/safety/domain/safety_assessment.dart';
import 'package:ai_trainer_mobile/features/safety/presentation/safety_card.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R5-02 testy safety pravidel (C34): tabulková pravidla a hrany,
/// determinismus, konzervativní chybějící check-in a widget evidence
/// opatrné formulace (SFR-001/002/004/015).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  DailyCheckIn checkIn({
    int energy = 3,
    int fatigue = 3,
    int? sleep,
    int? pain,
    String? area,
  }) => DailyCheckIn(
    id: 'ci',
    localDate: '2026-08-14',
    energyLevel: energy,
    fatigueLevel: fatigue,
    sleepQuality: sleep,
    painLevel: pain,
    painAreaCode: area,
    createdAtMillis: 0,
    updatedAtMillis: 0,
  );

  const constraint = BasicConstraint(
    id: 'c1',
    title: 'Bolavé rameno',
    status: 'ACTIVE',
  );

  test('tabulková pravidla: STOP > CAUTION > SAFE, hrany úrovní (C34 §3)', () {
    final cases = <(DailyCheckIn?, List<BasicConstraint>, SafetyState)>[
      // Bez check-inu = poctivé nevíme, nikdy SAFE (SFR-004).
      (null, const [], SafetyState.insufficientInformation),
      (null, const [constraint], SafetyState.insufficientInformation),
      // Klidný den bez signálů.
      (checkIn(), const [], SafetyState.safeWithCurrentInformation),
      // STOP signály: silná bolest (≥4) a únava 5.
      (
        checkIn(pain: 4, area: 'SHOULDER'),
        const [],
        SafetyState.doNotRecommendActivity,
      ),
      (
        checkIn(pain: 5, area: 'KNEE'),
        const [],
        SafetyState.doNotRecommendActivity,
      ),
      (checkIn(fatigue: 5), const [], SafetyState.doNotRecommendActivity),
      // CAUTION hrany: bolest 1–3, únava 4, energie ≤2, spánek ≤2.
      (checkIn(pain: 3, area: 'BACK'), const [], SafetyState.caution),
      (checkIn(pain: 1, area: 'HIP'), const [], SafetyState.caution),
      (checkIn(fatigue: 4), const [], SafetyState.caution),
      (checkIn(energy: 2), const [], SafetyState.caution),
      (checkIn(sleep: 2), const [], SafetyState.caution),
      // Těsně pod hranou zůstává SAFE.
      (
        checkIn(energy: 3, fatigue: 3, sleep: 3),
        const [],
        SafetyState.safeWithCurrentInformation,
      ),
      // Aktivní omezení drží CAUTION i při klidném check-inu (SFR-006).
      (checkIn(), const [constraint], SafetyState.caution),
      // STOP vyhrává nad CAUTION kombinací.
      (
        checkIn(pain: 5, area: 'NECK', energy: 1, sleep: 1),
        const [constraint],
        SafetyState.doNotRecommendActivity,
      ),
    ];

    for (final (input, constraints, expected) in cases) {
      final result = evaluateSafety(
        todayCheckIn: input,
        activeConstraints: constraints,
      );
      expect(
        result.state,
        expected,
        reason:
            'checkIn=${input?.energyLevel}/${input?.fatigueLevel}'
            '/pain ${input?.painLevel} constraints=${constraints.length}',
      );
    }
  });

  test('flags nesou zdroj a pořadí je deterministické; opakovaný běh je '
      'identický (SFR-001/005/014)', () {
    final input = checkIn(pain: 2, area: 'ELBOW', fatigue: 4, energy: 1);
    final first = evaluateSafety(
      todayCheckIn: input,
      activeConstraints: const [constraint],
    );
    expect(first.state, SafetyState.caution);
    expect(first.flags.map((f) => f.code), [
      SafetyFlagCodes.painReported,
      SafetyFlagCodes.highFatigue,
      SafetyFlagCodes.lowEnergy,
      SafetyFlagCodes.activeConstraint,
    ]);
    final painFlag = first.flags.first;
    expect(painFlag.painAreaCode, 'ELBOW');
    expect(painFlag.painLevel, 2);
    expect(first.flags.last.constraintTitle, 'Bolavé rameno');

    final second = evaluateSafety(
      todayCheckIn: input,
      activeConstraints: const [constraint],
    );
    expect(second.state, first.state);
    expect(
      second.flags.map((f) => f.code).toList(),
      first.flags.map((f) => f.code).toList(),
    );

    // Bez check-inu se omezení stále reportuje (SFR-006).
    final noCheckIn = evaluateSafety(
      todayCheckIn: null,
      activeConstraints: const [constraint],
    );
    expect(noCheckIn.flags.single.code, SafetyFlagCodes.activeConstraint);
  });

  testWidgets('widget evidence: STOP stav po uložení silné bolesti, opatrná '
      'formulace a beta hranice viditelné (SFR-008)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
    final now = DateTime.utc(2026, 8, 14, 12);
    // Aktivní omezení + dnešní check-in se silnou bolestí.
    await DriftAvailabilityProfileRepository(
      db,
    ).addConstraint(title: 'Bolavé rameno', newId: 'c1', now: now);
    await DriftDailyCheckInRepository(db).saveForDate(
      '2026-08-14',
      const DailyCheckInInput(
        energyLevel: 3,
        fatigueLevel: 3,
        painLevel: 4,
        painAreaCode: 'SHOULDER',
      ),
      newId: 'ci1',
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
          home: CheckInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SafetyCard.cardKey), findsOneWidget);
    expect(
      find.byKey(SafetyCard.stateKey('DO_NOT_RECOMMEND_ACTIVITY')),
      findsOneWidget,
    );
    // Zdroj flagů viditelný: bolest s oblastí i aktivní omezení.
    expect(find.textContaining('Shoulder'), findsWidgets);
    expect(find.textContaining('Bolavé rameno'), findsOneWidget);
    // Opatrná formulace bez medicínských tvrzení (SFR-008) — hranice je
    // viditelná na kartě i na formuláři.
    expect(find.textContaining('not medical advice'), findsNWidgets(2));
  });
}
