import 'package:ai_trainer_mobile/features/availability/data/drift_availability_profile_repository.dart';
import 'package:ai_trainer_mobile/features/availability/domain/availability_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/workout_test_scope.dart';

/// R3-03 persistence testy dostupnosti a kontextu (C19) nad skutečnou
/// SQLite: upsert dne (AVC-003), zpětvzetí (AVC-008), equipment dup guard
/// (AVC-006), stavové změny (AVC-007), řazení (AVC-014) a owner stamping.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.utc(2026, 8, 13, 22);

  test('upsert dne: jedna deklarace na den (AVC-003), editace zvyšuje verzi '
      'a SYNCED → DIRTY; zpětvzetí den odstraní (AVC-008)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftAvailabilityProfileRepository(db);

    expect(
      await repo.upsertDay(
        dayOfWeek: 'MON',
        level: 'AVAILABLE',
        budgetMinutes: 60,
        newId: 'av1',
        now: now,
      ),
      isA<AvailabilityWriteSaved>(),
    );
    // Druhý upsert téhož dne edituje existující deklaraci (žádný duplikát).
    await db.customStatement(
      "UPDATE local_availability_rules SET sync_state = 'SYNCED' "
      "WHERE id = 'av1'",
    );
    expect(
      await repo.upsertDay(
        dayOfWeek: 'MON',
        level: 'LIMITED',
        budgetMinutes: 30,
        preferredPartOfDay: 'EVENING',
        newId: 'unused',
        now: now,
      ),
      isA<AvailabilityWriteSaved>(),
    );
    final row =
        (await db
                .customSelect(
                  'SELECT level, budget_minutes, row_version, sync_state, '
                  "owner_id FROM local_availability_rules WHERE id = 'av1'",
                )
                .getSingle())
            .data;
    expect(row['level'], 'LIMITED');
    expect(row['budget_minutes'], 30);
    expect(row['row_version'], 2);
    expect(row['sync_state'], 'DIRTY');
    expect(row['owner_id'], 'local-anonymous');
    expect(await repo.weekForCurrentOwner(), hasLength(1));

    // Zpětvzetí (AVC-008).
    expect(await repo.removeDay('MON'), isA<AvailabilityWriteSaved>());
    expect(await repo.weekForCurrentOwner(), isEmpty);
    expect(await repo.removeDay('MON'), isA<AvailabilityWriteNotFound>());
  });

  test('týden je v pořadí MON..SUN a nevalidní kódy jsou odmítnuty', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftAvailabilityProfileRepository(db);

    await repo.upsertDay(
      dayOfWeek: 'SUN',
      level: 'AVAILABLE',
      newId: 'a1',
      now: now,
    );
    await repo.upsertDay(
      dayOfWeek: 'TUE',
      level: 'UNAVAILABLE',
      newId: 'a2',
      now: now,
    );
    await repo.upsertDay(
      dayOfWeek: 'FRI',
      level: 'LIMITED',
      newId: 'a3',
      now: now,
    );
    final days = (await repo.weekForCurrentOwner())
        .map((r) => r.dayOfWeek)
        .toList();
    expect(days, ['TUE', 'FRI', 'SUN']);

    expect(
      await repo.upsertDay(
        dayOfWeek: 'FUNDAY',
        level: 'AVAILABLE',
        newId: 'x1',
        now: now,
      ),
      isA<AvailabilityWriteValidationFailed>(),
    );
    expect(
      await repo.upsertDay(
        dayOfWeek: 'MON',
        level: 'MAYBE',
        newId: 'x2',
        now: now,
      ),
      isA<AvailabilityWriteValidationFailed>(),
    );
  });

  test('equipment: duplicitní ne-ARCHIVED katalogový kód odmítnut '
      '(AVC-006); archivace je stav a reaktivace znovu kontroluje '
      'duplicitu (AVC-007)', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftAvailabilityProfileRepository(db);

    expect(
      await repo.addEquipment(
        equipmentCode: 'DUMBBELLS',
        newId: 'e1',
        now: now,
      ),
      isA<AvailabilityWriteSaved>(),
    );
    expect(
      await repo.addEquipment(
        equipmentCode: 'DUMBBELLS',
        newId: 'e2',
        now: now,
      ),
      isA<AvailabilityWriteDuplicate>(),
    );
    // XOR validace a neznámý kód.
    expect(
      await repo.addEquipment(newId: 'x1', now: now),
      isA<AvailabilityWriteValidationFailed>(),
    );
    expect(
      await repo.addEquipment(
        equipmentCode: 'TIME_MACHINE',
        newId: 'x2',
        now: now,
      ),
      isA<AvailabilityWriteValidationFailed>(),
    );

    // Archivace → nová položka téhož kódu projde.
    await repo.setEquipmentStatus('e1', 'ARCHIVED', now: now);
    expect(
      await repo.addEquipment(
        equipmentCode: 'DUMBBELLS',
        newId: 'e3',
        now: now,
      ),
      isA<AvailabilityWriteSaved>(),
    );
    // Reaktivace archivované položky je teď duplicitní.
    expect(
      await repo.setEquipmentStatus('e1', 'ACTIVE', now: now),
      isA<AvailabilityWriteDuplicate>(),
    );
    // Archivovaná položka zůstává v seznamu (stav, ne mazání).
    final items = await repo.equipmentForCurrentOwner();
    expect(items, hasLength(2));
    expect(items.last.status, 'ARCHIVED');
  });

  test('omezení: povinný title, vyřešení je stav (AVC-007) a záznam '
      'zůstává', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final repo = DriftAvailabilityProfileRepository(db);

    expect(
      await repo.addConstraint(title: '   ', newId: 'x1', now: now),
      isA<AvailabilityWriteValidationFailed>(),
    );
    expect(
      await repo.addConstraint(
        title: 'Bolavé koleno — bez hlubokých dřepů',
        newId: 'c1',
        now: now,
      ),
      isA<AvailabilityWriteSaved>(),
    );
    await repo.setConstraintStatus('c1', 'RESOLVED', now: now);
    final constraints = await repo.constraintsForCurrentOwner();
    expect(constraints.single.status, 'RESOLVED');
    expect(constraints.single.title, contains('koleno'));
    // Reaktivace je možná.
    await repo.setConstraintStatus('c1', 'ACTIVE', now: now);
    expect((await repo.constraintsForCurrentOwner()).single.status, 'ACTIVE');
  });
}
