/// Drift tabulky R3 ručního plánování (C16 §5, C20).
///
/// `local_training_plans` je vlastnitelný aggregate root (C16 §6, R3M-004).
/// Ručně plánovaný workout NENÍ nová tabulka — je to existující
/// `local_workout_instances` se `source_type = USER_PLAN` (MPC-001/005).
/// Invariant jednoho ACTIVE plánu (MPC-002) vynucuje repository v transakci
/// — DB unique by kolidoval s C15 attach přepisem vlastníka (C20 §7).
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy stavů plánu (C20 §4).
const String planStatusActive = 'ACTIVE';
const String planStatusArchived = 'ARCHIVED';

/// Stabilní source kód ručně vytvořené instance (C20 §5.1, MPC-005).
const String userPlanSourceType = 'USER_PLAN';

@DataClassName('LocalTrainingPlanRow')
class LocalTrainingPlans extends Table {
  @override
  String get tableName => 'local_training_plans';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant(planStatusActive))();

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
    "CHECK (status IN ('ACTIVE','ARCHIVED'))",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
