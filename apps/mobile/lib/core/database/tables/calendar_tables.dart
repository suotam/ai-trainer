/// Drift tabulky R3 kalendářních operací (C16 §5, C21).
///
/// `local_calendar_changes` je append-only evidence změn plánovaných
/// workoutů (CAL-003) — nikdy UPDATE/DELETE. Born ownable and syncable
/// (C16 §6, CAL-010); attach bezpodmínečný.
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy typů kalendářních změn (C21 §4).
const String calendarChangeMoved = 'MOVED';
const String calendarChangeCancelled = 'CANCELLED';
const String calendarChangeReplaced = 'REPLACED';

/// Stabilní status zrušené instance (C21 §4.2, scheduling model §6.8).
const String instanceStatusCancelled = 'CANCELLED';

@DataClassName('LocalCalendarChangeRow')
class LocalCalendarChanges extends Table {
  @override
  String get tableName => 'local_calendar_changes';

  TextColumn get id => text()();
  TextColumn get workoutInstanceId =>
      text().references(LocalWorkoutInstances, #id)();
  TextColumn get changeType => text()();
  TextColumn get fromLocalDate => text().nullable()();
  TextColumn get toLocalDate => text().nullable()();
  TextColumn get replacementInstanceId =>
      text().nullable().references(LocalWorkoutInstances, #id)();
  IntColumn get createdAt => integer()();

  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (change_type IN ('MOVED','CANCELLED','REPLACED'))",
    "CHECK (change_type != 'MOVED' OR "
        '(from_local_date IS NOT NULL AND to_local_date IS NOT NULL))',
    "CHECK (change_type != 'REPLACED' OR replacement_instance_id IS NOT NULL)",
    syncStateCheck,
  ];
}
