/// Drift tabulky R5 denního check-inu (C33 §3).
///
/// `local_daily_check_ins` je vlastnitelný aggregate root (born ownable
/// & syncable, R3M-004). Denní klíč (owner + localDate) vynucuje
/// repository v transakci — DB unique by kolidoval s C15 attach přepisem
/// vlastníka (DCI-002). `note` je výhradně lokální (DCI-006).
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy oblastí bolesti (C33 §2, DCI-004).
const List<String> painAreaCodes = [
  'SHOULDER',
  'KNEE',
  'BACK',
  'ELBOW',
  'WRIST',
  'ANKLE',
  'HIP',
  'NECK',
  'OTHER',
];

@DataClassName('LocalDailyCheckInRow')
class LocalDailyCheckIns extends Table {
  @override
  String get tableName => 'local_daily_check_ins';

  TextColumn get id => text()();
  TextColumn get localDate => text()();
  IntColumn get energyLevel => integer()();
  IntColumn get fatigueLevel => integer()();
  IntColumn get sleepQuality => integer().nullable()();
  IntColumn get painLevel => integer().nullable()();
  TextColumn get painAreaCode => text().nullable()();

  /// Výhradně lokální poznámka — nikdy sync/AI (DCI-006).
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
    "CHECK (local_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (energy_level BETWEEN 1 AND 5)',
    'CHECK (fatigue_level BETWEEN 1 AND 5)',
    'CHECK (sleep_quality IS NULL OR sleep_quality BETWEEN 1 AND 5)',
    'CHECK (pain_level IS NULL OR pain_level BETWEEN 1 AND 5)',
    // Bolest vždy strukturovaně: level a oblast spolu (DCI-004).
    'CHECK ((pain_level IS NULL) = (pain_area_code IS NULL))',
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
