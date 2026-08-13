/// Drift tabulky R3 dostupnosti a tréninkového kontextu (C16 §5, C19).
///
/// Tři vlastnitelné aggregate roots — owner/sync metadata od vzniku
/// (C16 §6, R3M-004). DB drží stabilní kódy (AVC-002). Invarianty
/// AVC-003/006 vynucuje repository v transakci — DB unique by kolidoval
/// s C15 attach přepisem vlastníka (C19 §8).
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy stavů vybavení a omezení (C19 §5/§6).
const String equipmentStatusActive = 'ACTIVE';
const String equipmentStatusArchived = 'ARCHIVED';
const String constraintStatusActive = 'ACTIVE';
const String constraintStatusResolved = 'RESOLVED';

@DataClassName('LocalAvailabilityRuleRow')
class LocalAvailabilityRules extends Table {
  @override
  String get tableName => 'local_availability_rules';

  TextColumn get id => text()();
  TextColumn get dayOfWeek => text()();
  TextColumn get level => text()();
  IntColumn get budgetMinutes => integer().nullable()();
  TextColumn get preferredPartOfDay => text().nullable()();
  TextColumn get note => text().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();
  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (day_of_week IN ('MON','TUE','WED','THU','FRI','SAT','SUN'))",
    "CHECK (level IN ('AVAILABLE','LIMITED','UNAVAILABLE'))",
    "CHECK (preferred_part_of_day IS NULL OR preferred_part_of_day IN "
        "('MORNING','AFTERNOON','EVENING'))",
    'CHECK (budget_minutes IS NULL OR budget_minutes >= 0)',
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}

@DataClassName('LocalEquipmentItemRow')
class LocalEquipmentItems extends Table {
  @override
  String get tableName => 'local_equipment_items';

  TextColumn get id => text()();

  // Katalogový kód XOR custom název (C19 §5, vzor C17).
  TextColumn get equipmentCode => text().nullable()();
  TextColumn get customName => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant(equipmentStatusActive))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();
  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((equipment_code IS NULL) != (custom_name IS NULL))',
    "CHECK (status IN ('ACTIVE','ARCHIVED'))",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}

@DataClassName('LocalConstraintRow')
class LocalConstraints extends Table {
  @override
  String get tableName => 'local_constraints';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant(constraintStatusActive))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();
  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (length(trim(title)) > 0)',
    "CHECK (status IN ('ACTIVE','RESOLVED'))",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
