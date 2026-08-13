import 'package:ai_trainer_mobile/features/sports/data/drift_user_sport_repository.dart';
import 'package:ai_trainer_mobile/features/sports/domain/user_sport.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-01 persistence testy sportovního profilu (C17) nad skutečnou SQLite:
/// owner stamping, invarianty ASP-003/004, current-state editace (ASP-007),
/// lifecycle (C17 §7) a deterministické řazení (ASP-014).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 13, 16);

  UserSportInput input({
    String? code,
    String? customName,
    String role = 'RECREATIONAL',
    String priority = 'MEDIUM',
    String experience = 'UNKNOWN',
  }) => UserSportInput(
    sportCode: code,
    customName: customName,
    customCategory: customName != null ? 'CUSTOM' : null,
    role: role,
    priority: priority,
    experienceLevel: experience,
  );

  test('vytvoření razí anonymního vlastníka, LOCAL_ONLY a verzi 1; '
      'záznam přežije „restart" (nová repository nad touž DB)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftUserSportRepository(db);

    final result = await repo.saveSport(
      input(code: 'CLIMBING', role: 'PRIMARY', experience: 'ADVANCED'),
      newId: 'us1',
      now: now,
    );
    expect(result, isA<UserSportSaved>());

    final row =
        (await db
                .customSelect(
                  "SELECT owner_id, sync_state, row_version, status "
                  "FROM local_user_sports WHERE id = 'us1'",
                )
                .getSingle())
            .data;
    expect(row['owner_id'], 'local-anonymous');
    expect(row['sync_state'], 'LOCAL_ONLY');
    expect(row['row_version'], 1);
    expect(row['status'], 'ACTIVE');

    final restarted = DriftUserSportRepository(db);
    final sports = await restarted.sportsForCurrentOwner();
    expect(sports.single.sportCode, 'CLIMBING');
    expect(sports.single.experienceLevel, 'ADVANCED');
  });

  test('invarianty: duplicitní ne-ENDED katalogový sport (ASP-004) a druhý '
      'ACTIVE PRIMARY (ASP-003) jsou typovaně odmítnuty', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftUserSportRepository(db);

    await repo.saveSport(
      input(code: 'RUNNING', role: 'PRIMARY'),
      newId: 'us1',
      now: now,
    );

    expect(
      await repo.saveSport(
        input(code: 'RUNNING'),
        newId: 'us2',
        now: now,
      ),
      isA<UserSportDuplicate>(),
    );
    expect(
      await repo.saveSport(
        input(code: 'YOGA', role: 'PRIMARY'),
        newId: 'us3',
        now: now,
      ),
      isA<UserSportPrimaryConflict>(),
    );
    // Jiná role na jiném sportu projde.
    expect(
      await repo.saveSport(
        input(code: 'YOGA', role: 'SUPPORTING'),
        newId: 'us4',
        now: now,
      ),
      isA<UserSportSaved>(),
    );
    // Po ukončení RUNNING lze vytvořit nový vztah k témuž kódu (ASP-004
    // platí jen pro ne-ENDED).
    await repo.changeStatus('us1', 'ENDED', now: now);
    expect(
      await repo.saveSport(
        input(code: 'RUNNING'),
        newId: 'us5',
        now: now,
      ),
      isA<UserSportSaved>(),
    );
  });

  test('validace: XOR sport reference, neznámý kód a neznámé kódy hodnot '
      'jsou odmítnuty bez zápisu', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftUserSportRepository(db);

    expect(
      await repo.saveSport(
        input(code: 'RUNNING', customName: 'Moje běhání'),
        newId: 'x1',
        now: now,
      ),
      isA<UserSportValidationFailed>(),
    );
    expect(
      await repo.saveSport(input(), newId: 'x2', now: now),
      isA<UserSportValidationFailed>(),
    );
    expect(
      await repo.saveSport(
        input(code: 'QUIDDITCH'),
        newId: 'x3',
        now: now,
      ),
      isA<UserSportValidationFailed>(),
    );
    expect(
      await repo.saveSport(
        input(code: 'RUNNING', role: 'MAIN'),
        newId: 'x4',
        now: now,
      ),
      isA<UserSportValidationFailed>(),
    );
    expect(await repo.sportsForCurrentOwner(), isEmpty);
  });

  test('editace je current-state (ASP-007): verze +1, SYNCED → DIRTY, '
      'LOCAL_ONLY zůstává', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftUserSportRepository(db);
    await repo.saveSport(
      input(code: 'CYCLING'),
      newId: 'us1',
      now: now,
    );

    // LOCAL_ONLY zůstává po editaci LOCAL_ONLY.
    await repo.saveSport(
      input(code: 'CYCLING', priority: 'HIGH'),
      existingId: 'us1',
      newId: 'unused',
      now: now,
    );
    var row =
        (await db
                .customSelect(
                  "SELECT priority, row_version, sync_state "
                  "FROM local_user_sports WHERE id = 'us1'",
                )
                .getSingle())
            .data;
    expect(row['priority'], 'HIGH');
    expect(row['row_version'], 2);
    expect(row['sync_state'], 'LOCAL_ONLY');

    // SYNCED → DIRTY po další editaci.
    await db.customStatement(
      "UPDATE local_user_sports SET sync_state = 'SYNCED' WHERE id = 'us1'",
    );
    await repo.saveSport(
      input(code: 'CYCLING', priority: 'LOW'),
      existingId: 'us1',
      newId: 'unused',
      now: now,
    );
    row =
        (await db
                .customSelect(
                  "SELECT row_version, sync_state "
                  "FROM local_user_sports WHERE id = 'us1'",
                )
                .getSingle())
            .data;
    expect(row['row_version'], 3);
    expect(row['sync_state'], 'DIRTY');
  });

  test('lifecycle (C17 §7): pause/resume/end; resume PRIMARY kontroluje '
      'ASP-003 a konec je stav, ne mazání (ASP-008)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftUserSportRepository(db);
    await repo.saveSport(
      input(code: 'FLOORBALL', role: 'PRIMARY'),
      newId: 'us1',
      now: now,
    );

    expect(
      await repo.changeStatus('us1', 'PAUSED', now: now),
      isA<UserSportSaved>(),
    );
    // Během pauzy smí vzniknout jiný ACTIVE PRIMARY.
    await repo.saveSport(
      input(code: 'CLIMBING', role: 'PRIMARY'),
      newId: 'us2',
      now: now,
    );
    // Resume prvního PRIMARY je teď konflikt (ASP-003).
    expect(
      await repo.changeStatus('us1', 'ACTIVE', now: now),
      isA<UserSportPrimaryConflict>(),
    );
    // Konec je stav — záznam zůstává čitelný v seznamu (ENDED).
    await repo.changeStatus('us1', 'ENDED', now: now);
    final sports = await repo.sportsForCurrentOwner();
    expect(sports, hasLength(2));
    expect(sports.last.status, 'ENDED');
    // Neexistující/ cizí ID je typovaný not-found.
    expect(
      await repo.changeStatus('missing', 'ENDED', now: now),
      isA<UserSportNotFound>(),
    );
  });

  test(
    'deterministické řazení (ASP-014): status, role, priorita, název',
    () async {
      final db = createTestDatabase();
      addTearDown(db.close);
      final repo = DriftUserSportRepository(db);

      await repo.saveSport(
        input(code: 'YOGA', role: 'SUPPORTING', priority: 'LOW'),
        newId: 'a',
        now: now,
      );
      await repo.saveSport(
        input(code: 'RUNNING', role: 'PRIMARY', priority: 'HIGH'),
        newId: 'b',
        now: now,
      );
      await repo.saveSport(
        input(
          customName: 'Bosu balanc',
          role: 'SECONDARY',
          priority: 'CRITICAL',
        ),
        newId: 'c',
        now: now,
      );
      await repo.saveSport(
        input(code: 'HIKING', role: 'SECONDARY', priority: 'BACKGROUND'),
        newId: 'd',
        now: now,
      );
      await repo.changeStatus('d', 'PAUSED', now: now);

      final ids = (await repo.sportsForCurrentOwner())
          .map((s) => s.id)
          .toList();
      // ACTIVE: PRIMARY(b) → SECONDARY CRITICAL(c) → SUPPORTING(a);
      // pak PAUSED(d).
      expect(ids, ['b', 'c', 'a', 'd']);
    },
  );
}
