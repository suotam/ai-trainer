/// Drift tabulky R3 ručních aktivit (C16 §5, C22).
///
/// `local_activities` je vlastnitelný aggregate root (C16 §6, MAC-001).
/// Ruční aktivita je fakt po skutečnosti bez lifecycle (MAC-004);
/// editovatelná, nemazatelná (MAC-005). Vazby na sport/instanci jsou
/// device-local reference (MAC-006).
library;

import 'package:drift/drift.dart';

import 'sports_tables.dart';
import 'workout_tables.dart';

/// Stabilní P0 zdroj ruční aktivity (C22 §3, MAC-003).
const String activitySourceManual = 'MANUAL';

@DataClassName('LocalActivityRow')
class LocalActivities extends Table {
  @override
  String get tableName => 'local_activities';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get localDate => text()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get userSportId =>
      text().nullable().references(LocalUserSports, #id)();
  TextColumn get workoutInstanceId =>
      text().nullable().references(LocalWorkoutInstances, #id)();
  TextColumn get note => text().nullable()();
  TextColumn get source =>
      text().withDefault(const Constant(activitySourceManual))();

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
    "CHECK (local_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (duration_minutes IS NULL OR duration_minutes >= 1)',
    "CHECK (source IN ('MANUAL'))",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
