/// Drift tabulky R3 sportovního profilu (C16 §5, C17).
///
/// `local_user_sports` je vlastnitelný aggregate root — owner/sync metadata
/// od vzniku (C16 §6, R3M-004). Participation pattern je součást aggregate
/// (C17 §4.2). DB drží stabilní kódy, lokalizace je prezentační (ASP-011).
/// Invarianty ASP-003 (jeden ACTIVE PRIMARY) a ASP-004 (bez duplicit) jsou
/// vynucovány aplikačně v repository transakci — DB partial unique index by
/// kolidoval s C15 attach přepisem vlastníka (C17 §8 attach kolize).
library;

import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Stabilní kódy stavů UserSport (C17 §7.1).
const String userSportStatusActive = 'ACTIVE';
const String userSportStatusPaused = 'PAUSED';
const String userSportStatusEnded = 'ENDED';

@DataClassName('LocalUserSportRow')
class LocalUserSports extends Table {
  @override
  String get tableName => 'local_user_sports';

  TextColumn get id => text()();

  // Sport reference (C17 §5): katalogový kód XOR custom sport.
  TextColumn get sportCode => text().nullable()();
  TextColumn get customName => text().nullable()();
  TextColumn get customCategory => text().nullable()();

  // Vztah ke sportu (C17 §6).
  TextColumn get role => text()();
  TextColumn get priority => text()();
  TextColumn get experienceLevel =>
      text().withDefault(const Constant('UNKNOWN'))();
  TextColumn get lastRegularActivityDate => text().nullable()();
  BoolColumn get returnAfterPause =>
      boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();

  // Participation pattern (C17 §4.2) — vše volitelné (ASP-010).
  IntColumn get frequencyPerWeek => integer().nullable()();
  IntColumn get typicalDurationMinutes => integer().nullable()();
  TextColumn get typicalIntensity => text().nullable()();
  TextColumn get environment => text().nullable()();
  TextColumn get fixedDays => text().nullable()();

  TextColumn get status =>
      text().withDefault(const Constant(userSportStatusActive))();

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
    // Právě jedna forma sport reference (C17 §4.1).
    'CHECK ((sport_code IS NULL) != (custom_name IS NULL))',
    "CHECK (role IN ('PRIMARY','SECONDARY','SUPPORTING','RECREATIONAL',"
        "'OCCASIONAL','SEASONAL'))",
    "CHECK (priority IN ('CRITICAL','HIGH','MEDIUM','LOW','BACKGROUND'))",
    "CHECK (experience_level IN ('BEGINNER','NOVICE','INTERMEDIATE',"
        "'ADVANCED','EXPERT','PROFESSIONAL','UNKNOWN'))",
    "CHECK (status IN ('ACTIVE','PAUSED','ENDED'))",
    "CHECK (typical_intensity IS NULL OR typical_intensity IN "
        "('LOW','MODERATE','HIGH','VERY_HIGH'))",
    "CHECK (environment IS NULL OR environment IN "
        "('INDOOR','OUTDOOR','MIXED'))",
    'CHECK (frequency_per_week IS NULL OR frequency_per_week >= 0)',
    'CHECK (typical_duration_minutes IS NULL OR typical_duration_minutes >= 0)',
    "CHECK (last_regular_activity_date IS NULL OR last_regular_activity_date "
        "GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (row_version >= 1)',
    syncStateCheck,
  ];
}
