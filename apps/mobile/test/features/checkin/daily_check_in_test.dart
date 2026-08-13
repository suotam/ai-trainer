import 'dart:convert';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/core/database/database_provider.dart';
import 'package:ai_trainer_mobile/core/database/tables/workout_tables.dart';
import 'package:ai_trainer_mobile/core/time/clock.dart';
import 'package:ai_trainer_mobile/features/checkin/data/drift_daily_check_in_repository.dart';
import 'package:ai_trainer_mobile/features/checkin/domain/daily_check_in.dart';
import 'package:ai_trainer_mobile/features/checkin/presentation/checkin_screen.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_local_account_attach.dart';
import 'package:ai_trainer_mobile/features/sync/data/drift_sync_snapshot_repository.dart';
import 'package:ai_trainer_mobile/l10n/generated/app_localizations.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R5-01 testy denního check-inu (C33): denní klíč a editace (DCI-002),
/// škály a strukturovaná bolest (DCI-003/004), attach kolize (DCI-010),
/// sync payload bez lokální poznámky (DCI-006) a widget flow.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 14, 12);

  const input = DailyCheckInInput(
    energyLevel: 4,
    fatigueLevel: 2,
    sleepQuality: 3,
    painLevel: 3,
    painAreaCode: 'SHOULDER',
    note: 'TAJNA-POZNAMKA',
  );

  Future<void> setOwner(AppDatabase db, String owner) => db
      .into(db.localAppState)
      .insertOnConflictUpdate(
        LocalAppStateCompanion.insert(
          key: localOwnerStateKey,
          value: owner,
          updatedAt: 0,
        ),
      );

  test('denní klíč: zápis dne je insert, opakovaný zápis editace téhož '
      'záznamu; škály a bolest validované (DCI-002/003/004/008)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftDailyCheckInRepository(db);

    expect(
      await repo.saveForDate('2026-08-14', input, newId: 'ci1', now: now),
      isA<CheckInSaved>(),
    );
    final saved = (await repo.checkInForDate('2026-08-14'))!;
    expect(saved.id, 'ci1');
    expect(saved.energyLevel, 4);
    expect(saved.painAreaCode, 'SHOULDER');

    // Editace dne: tentýž záznam, žádný druhý (DCI-002).
    final edited = await repo.saveForDate(
      '2026-08-14',
      const DailyCheckInInput(energyLevel: 2, fatigueLevel: 5),
      newId: 'ci-unused',
      now: now,
    );
    expect((edited as CheckInSaved).id, 'ci1');
    final afterEdit = (await repo.checkInForDate('2026-08-14'))!;
    expect(afterEdit.fatigueLevel, 5);
    expect(afterEdit.painLevel, isNull);
    expect(await repo.historyForCurrentOwner(), hasLength(1));

    // Jiný den = nový záznam; historie sestupně (DCI-007).
    await repo.saveForDate(
      '2026-08-13',
      const DailyCheckInInput(energyLevel: 3, fatigueLevel: 3),
      newId: 'ci2',
      now: now,
    );
    final history = await repo.historyForCurrentOwner();
    expect(history.map((c) => c.localDate), ['2026-08-14', '2026-08-13']);

    // Typovaná validace: mimo škálu a bolest bez oblasti.
    const invalidCases = [
      DailyCheckInInput(energyLevel: 6, fatigueLevel: 3),
      DailyCheckInInput(energyLevel: 3, fatigueLevel: 0),
      DailyCheckInInput(energyLevel: 3, fatigueLevel: 3, painLevel: 2),
      DailyCheckInInput(
        energyLevel: 3,
        fatigueLevel: 3,
        painLevel: 2,
        painAreaCode: 'TOENAIL',
      ),
    ];
    for (final invalid in invalidCases) {
      expect(
        await repo.saveForDate('2026-08-12', invalid, newId: 'x', now: now),
        isA<CheckInValidationFailed>(),
      );
    }
    expect(await repo.checkInForDate('2026-08-12'), isNull);

    // Editace po SYNCED značí DIRTY (C16 vzor).
    await db.customStatement(
      "UPDATE local_daily_check_ins SET sync_state = 'SYNCED' WHERE id = 'ci1'",
    );
    await repo.saveForDate(
      '2026-08-14',
      const DailyCheckInInput(energyLevel: 1, fatigueLevel: 1),
      newId: 'unused',
      now: now,
    );
    final state = await db
        .customSelect(
          "SELECT sync_state, row_version FROM local_daily_check_ins "
          "WHERE id = 'ci1'",
        )
        .getSingle();
    expect(state.data['sync_state'], 'DIRTY');
    expect(state.data['row_version'], 3);
  });

  test('attach: kolizní anonymní den zůstává anonymní, ostatní se připojí '
      '(DCI-010); sync payload nikdy nenese poznámku (DCI-006)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftDailyCheckInRepository(db);

    // Anonymní check-iny dvou dnů (s lokální poznámkou).
    await repo.saveForDate('2026-08-13', input, newId: 'anon-a', now: now);
    await repo.saveForDate('2026-08-14', input, newId: 'anon-b', now: now);

    // Účet už má vlastní check-in pro 14. 8. (kolize denního klíče).
    await setOwner(db, 'account-1');
    await repo.saveForDate(
      '2026-08-14',
      const DailyCheckInInput(energyLevel: 5, fatigueLevel: 1),
      newId: 'acc-a',
      now: now,
    );
    await setOwner(db, localAnonymousOwnerId);

    await DriftLocalAccountAttach(db).attachAnonymousData('account-1');

    Future<String> ownerOf(String id) async =>
        (await db
                    .customSelect(
                      'SELECT owner_id FROM local_daily_check_ins WHERE id = ?',
                      variables: [Variable.withString(id)],
                    )
                    .getSingle())
                .data['owner_id']!
            as String;
    // Nekolizní den se připojil; kolizní zůstal anonymní, nic se nemazalo.
    expect(await ownerOf('anon-a'), 'account-1');
    expect(await ownerOf('anon-b'), localAnonymousOwnerId);
    expect(await ownerOf('acc-a'), 'account-1');

    // Sync collection: DAILY_CHECK_IN payload bez note (DCI-006 marker).
    final planned = await DriftSyncSnapshotRepository(
      db,
    ).collectPendingEntities('account-1');
    final checkIns = planned
        .where((e) => e.entityType == 'DAILY_CHECK_IN')
        .toList();
    expect(checkIns, hasLength(2));
    for (final entity in checkIns) {
      final serialized = jsonEncode(entity.payload);
      expect(serialized.contains('TAJNA-POZNAMKA'), isFalse);
      expect(entity.payload.containsKey('note'), isFalse);
      expect(entity.payload['localDate'], isNotNull);
      expect(entity.payload['energyLevel'], isNotNull);
    }
  });

  testWidgets('widget flow: vyplnění → uložení → viditelné hodnoty a '
      'historie; editace dne přes UI (DCI-014)', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = createTestDatabase();
    addTearDown(db.close);
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

    await tester.tap(find.byKey(CheckInScreen.levelKey('energy', 4)));
    await tester.tap(find.byKey(CheckInScreen.levelKey('fatigue', 2)));
    await tester.tap(find.byKey(CheckInScreen.levelKey('pain', 3)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(CheckInScreen.painAreaKey('SHOULDER')),
    );
    await tester.tap(find.byKey(CheckInScreen.painAreaKey('SHOULDER')));
    await tester.ensureVisible(find.byKey(CheckInScreen.noteFieldKey));
    await tester.enterText(
      find.byKey(CheckInScreen.noteFieldKey),
      'Jen lokální poznámka',
    );
    await tester.ensureVisible(find.byKey(CheckInScreen.saveKey));
    await tester.tap(find.byKey(CheckInScreen.saveKey));
    await tester.pumpAndSettle();

    expect(find.byKey(CheckInScreen.savedBannerKey), findsOneWidget);
    expect(find.byKey(const Key('checkin_history_2026-08-14')), findsOneWidget);
    final saved = (await DriftDailyCheckInRepository(
      db,
    ).checkInForDate('2026-08-14'))!;
    expect(saved.energyLevel, 4);
    expect(saved.painAreaCode, 'SHOULDER');
    expect(saved.note, 'Jen lokální poznámka');

    // Editace dne přes UI: tentýž záznam, rowVersion roste (DCI-002).
    await tester.ensureVisible(
      find.byKey(CheckInScreen.levelKey('fatigue', 5)),
    );
    await tester.tap(find.byKey(CheckInScreen.levelKey('fatigue', 5)));
    await tester.ensureVisible(find.byKey(CheckInScreen.saveKey));
    await tester.tap(find.byKey(CheckInScreen.saveKey));
    await tester.pumpAndSettle();
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c, MAX(row_version) AS v '
          'FROM local_daily_check_ins',
        )
        .getSingle();
    expect(row.data['c'], 1);
    expect(row.data['v'], 2);
  });
}
