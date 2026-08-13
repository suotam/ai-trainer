/// Drift tabulky R3 cílů (C16 §5, C18).
///
/// `local_goals` je vlastnitelný aggregate root — owner/sync metadata od
/// vzniku (C16 §6, R3M-004). DB drží stabilní kódy (GLC-002); povinný je
/// jen title (GLC-003). Vazba na sport je device-local reference na
/// `local_user_sports.id` (GLC-008) — UserSport se nikdy hard-nemaže
/// (ASP-008), FK proto nemůže osiřet.
library;

import 'package:drift/drift.dart';

import 'sports_tables.dart';
import 'workout_tables.dart';

/// Stabilní kódy stavů cíle (C18 §5.4).
const String goalStatusActive = 'ACTIVE';
const String goalStatusPaused = 'PAUSED';
const String goalStatusCompleted = 'COMPLETED';
const String goalStatusAbandoned = 'ABANDONED';

@DataClassName('LocalGoalRow')
class LocalGoals extends Table {
  @override
  String get tableName => 'local_goals';

  TextColumn get id => text()();

  TextColumn get title => text()();
  TextColumn get goalType => text()();
  TextColumn get priority => text()();
  TextColumn get horizon => text().withDefault(const Constant('OPEN_ENDED'))();
  TextColumn get status =>
      text().withDefault(const Constant(goalStatusActive))();

  // Volitelná device-local vazba na sport (C18 §7).
  TextColumn get userSportId =>
      text().nullable().references(LocalUserSports, #id)();

  TextColumn get targetLocalDate => text().nullable()();
  TextColumn get note => text().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();

  // Owner/sync metadata od vzniku (C16 §6.1, R3M-004).
  TextColumn get ownerId =>
      text().withDefault(const Constant(localAnonymousOwnerId))();
  TextColumn get syncState =>
      text().withDefault(const Constant(syncStateLocalOnly))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (length(trim(title)) > 0)",
    "CHECK (goal_type IN ('PERFORMANCE','STRENGTH','ENDURANCE','HABIT',"
        "'EVENT_PREPARATION','RETURN_TO_ACTIVITY','MAINTENANCE','QUALITATIVE'))",
    "CHECK (priority IN ('PRIMARY','MAINTENANCE','DEFERRED'))",
    "CHECK (horizon IN ('IMMEDIATE','SHORT_TERM','MEDIUM_TERM','LONG_TERM',"
        "'OPEN_ENDED'))",
    "CHECK (status IN ('ACTIVE','PAUSED','COMPLETED','ABANDONED'))",
    "CHECK (target_local_date IS NULL OR target_local_date "
        "GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
