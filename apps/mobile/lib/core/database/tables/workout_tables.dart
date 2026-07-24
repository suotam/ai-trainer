/// Drift tabulky R1 lokálního schématu.
///
/// Jediný zdroj pravdy struktury je `docs/12-data/r1-physical-data-model.md`
/// (PDR-001 až PDR-015) — názvy tabulek a sloupců mu odpovídají. Časy jsou
/// UTC epoch milliseconds (INTEGER), lokální datum `YYYY-MM-DD`, enumy
/// stabilní textové kódy. Row typy nesmí pronikat mimo data vrstvu
/// (PDR-008).
library;

import 'package:drift/drift.dart';

@DataClassName('LocalWorkoutInstanceRow')
class LocalWorkoutInstances extends Table {
  @override
  String get tableName => 'local_workout_instances';

  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get workoutType => text()();
  TextColumn get scheduledLocalDate => text()();
  IntColumn get scheduledStartAt => integer().nullable()();
  TextColumn get timeZoneId => text().nullable()();
  IntColumn get plannedDurationSeconds => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceReference => text().nullable()();
  IntColumn get revisionNumber => integer()();
  TextColumn get startedSessionId => text().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (scheduled_local_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]')",
    'CHECK (planned_duration_seconds IS NULL OR planned_duration_seconds >= 0)',
    'CHECK (revision_number >= 1)',
    'CHECK (row_version >= 1)',
    "CHECK (completed_at IS NULL OR status IN ('COMPLETED', 'PARTIALLY_COMPLETED'))",
  ];
}

@DataClassName('LocalWorkoutSectionRow')
class LocalWorkoutSections extends Table {
  @override
  String get tableName => 'local_workout_sections';

  TextColumn get id => text()();
  TextColumn get workoutInstanceId => text().references(
    LocalWorkoutInstances,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get position => integer()();
  TextColumn get title => text()();
  TextColumn get sectionType => text()();
  TextColumn get purpose => text().nullable()();
  TextColumn get priority => text()();
  BoolColumn get isOptional => boolean()();
  IntColumn get plannedDurationSeconds => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {workoutInstanceId, position},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (position >= 0)',
    'CHECK (planned_duration_seconds IS NULL OR planned_duration_seconds >= 0)',
  ];
}

@DataClassName('LocalWorkoutStepRow')
class LocalWorkoutSteps extends Table {
  @override
  String get tableName => 'local_workout_steps';

  TextColumn get id => text()();
  TextColumn get sectionId => text().references(
    LocalWorkoutSections,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get parentStepId =>
      text().nullable().references(LocalWorkoutSteps, #id)();
  IntColumn get position => integer()();
  TextColumn get stepType => text()();
  TextColumn get title => text()();
  TextColumn get instructions => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get priority => text()();
  BoolColumn get isSkippable => boolean()();
  TextColumn get prescriptionType => text()();
  IntColumn get plannedDurationSeconds => integer().nullable()();
  RealColumn get plannedDistanceMeters => real().nullable()();
  IntColumn get plannedRepetitions => integer().nullable()();
  RealColumn get plannedWeightKg => real().nullable()();
  TextColumn get metadataJson => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Unikátnost (section_id, parent_step_id, position) se vynucuje
  // expression indexem s COALESCE v AppDatabase.onCreate, protože SQLite
  // UNIQUE považuje NULL hodnoty za různé.
  @override
  List<String> get customConstraints => [
    'CHECK (position >= 0)',
    'CHECK (parent_step_id IS NULL OR parent_step_id != id)',
    'CHECK (planned_duration_seconds IS NULL OR planned_duration_seconds >= 0)',
    'CHECK (planned_distance_meters IS NULL OR planned_distance_meters >= 0)',
    'CHECK (planned_repetitions IS NULL OR planned_repetitions >= 0)',
    'CHECK (planned_weight_kg IS NULL OR planned_weight_kg >= 0)',
  ];
}

@DataClassName('LocalSetPlanRow')
class LocalSetPlans extends Table {
  @override
  String get tableName => 'local_set_plans';

  TextColumn get id => text()();
  TextColumn get workoutStepId =>
      text().references(LocalWorkoutSteps, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get plannedRepetitions => integer().nullable()();
  IntColumn get minimumRepetitions => integer().nullable()();
  IntColumn get maximumRepetitions => integer().nullable()();
  RealColumn get plannedWeightKg => real().nullable()();
  IntColumn get plannedDurationSeconds => integer().nullable()();
  IntColumn get restAfterSeconds => integer().nullable()();
  RealColumn get targetRpe => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {workoutStepId, position},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (position >= 0)',
    'CHECK (planned_repetitions IS NULL OR planned_repetitions >= 0)',
    'CHECK (minimum_repetitions IS NULL OR minimum_repetitions >= 0)',
    'CHECK (maximum_repetitions IS NULL OR maximum_repetitions >= 0)',
    'CHECK (planned_weight_kg IS NULL OR planned_weight_kg >= 0)',
    'CHECK (planned_duration_seconds IS NULL OR planned_duration_seconds >= 0)',
    'CHECK (rest_after_seconds IS NULL OR rest_after_seconds >= 0)',
    'CHECK (target_rpe IS NULL OR (target_rpe >= 0 AND target_rpe <= 10))',
    'CHECK (minimum_repetitions IS NULL OR maximum_repetitions IS NULL '
        'OR minimum_repetitions <= maximum_repetitions)',
  ];
}

@DataClassName('LocalWorkoutSessionRow')
class LocalWorkoutSessions extends Table {
  @override
  String get tableName => 'local_workout_sessions';

  TextColumn get id => text()();
  TextColumn get workoutInstanceId => text().references(
    LocalWorkoutInstances,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get instanceRevisionNumber => integer()();
  TextColumn get status => text()();
  IntColumn get startedAt => integer()();
  IntColumn get lastResumedAt => integer().nullable()();
  IntColumn get pausedAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get activeStepId => text().nullable()();
  IntColumn get elapsedActiveSeconds => integer()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Nejvýše jedna ACTIVE/PAUSED session na instanci vynucuje partial
  // unique index v AppDatabase.onCreate (fyzický model §9).
  @override
  List<String> get customConstraints => [
    'CHECK (elapsed_active_seconds >= 0)',
    'CHECK (row_version >= 1)',
    "CHECK (status != 'COMPLETED' OR completed_at IS NOT NULL)",
  ];
}

@DataClassName('LocalStepPerformanceRow')
class LocalStepPerformances extends Table {
  @override
  String get tableName => 'local_step_performances';

  TextColumn get id => text()();
  TextColumn get workoutSessionId => text().references(
    LocalWorkoutSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get workoutStepId =>
      text().references(LocalWorkoutSteps, #id, onDelete: KeyAction.restrict)();
  TextColumn get status => text()();
  IntColumn get startedAt => integer().nullable()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get actualRepetitions => integer().nullable()();
  IntColumn get actualDurationSeconds => integer().nullable()();
  RealColumn get actualDistanceMeters => real().nullable()();
  RealColumn get actualWeightKg => real().nullable()();
  RealColumn get perceivedExertion => real().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {workoutSessionId, workoutStepId},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (actual_repetitions IS NULL OR actual_repetitions >= 0)',
    'CHECK (actual_duration_seconds IS NULL OR actual_duration_seconds >= 0)',
    'CHECK (actual_distance_meters IS NULL OR actual_distance_meters >= 0)',
    'CHECK (actual_weight_kg IS NULL OR actual_weight_kg >= 0)',
    'CHECK (perceived_exertion IS NULL '
        'OR (perceived_exertion >= 0 AND perceived_exertion <= 10))',
    'CHECK (row_version >= 1)',
  ];
}

@DataClassName('LocalSetPerformanceRow')
class LocalSetPerformances extends Table {
  @override
  String get tableName => 'local_set_performances';

  TextColumn get id => text()();
  TextColumn get stepPerformanceId => text().references(
    LocalStepPerformances,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get setPlanId =>
      text().nullable().references(LocalSetPlans, #id)();
  IntColumn get position => integer()();
  TextColumn get status => text()();
  IntColumn get actualRepetitions => integer().nullable()();
  RealColumn get actualWeightKg => real().nullable()();
  IntColumn get actualDurationSeconds => integer().nullable()();
  RealColumn get actualRpe => real().nullable()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get rowVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {stepPerformanceId, position},
  ];

  @override
  List<String> get customConstraints => [
    'CHECK (position >= 0)',
    'CHECK (actual_repetitions IS NULL OR actual_repetitions >= 0)',
    'CHECK (actual_weight_kg IS NULL OR actual_weight_kg >= 0)',
    'CHECK (actual_duration_seconds IS NULL OR actual_duration_seconds >= 0)',
    'CHECK (actual_rpe IS NULL OR (actual_rpe >= 0 AND actual_rpe <= 10))',
    'CHECK (row_version >= 1)',
  ];
}

@DataClassName('LocalWorkoutFeedbackRow')
class LocalWorkoutFeedback extends Table {
  @override
  String get tableName => 'local_workout_feedback';

  TextColumn get id => text()();
  TextColumn get workoutSessionId => text().unique().references(
    LocalWorkoutSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  RealColumn get overallEffort => real().nullable()();
  TextColumn get feeling => text().nullable()();
  BoolColumn get painReported => boolean()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (overall_effort IS NULL OR (overall_effort >= 0 AND overall_effort <= 10))',
  ];
}

@DataClassName('LocalActivitySummaryRow')
class LocalActivitySummaries extends Table {
  @override
  String get tableName => 'local_activity_summaries';

  TextColumn get id => text()();
  TextColumn get workoutInstanceId =>
      text().references(LocalWorkoutInstances, #id)();
  TextColumn get workoutSessionId =>
      text().unique().references(LocalWorkoutSessions, #id)();
  TextColumn get titleSnapshot => text()();
  TextColumn get workoutType => text()();
  IntColumn get startedAt => integer()();
  IntColumn get completedAt => integer()();
  IntColumn get activeDurationSeconds => integer()();
  IntColumn get completedStepCount => integer()();
  IntColumn get totalStepCount => integer()();
  RealColumn get overallEffort => real().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (active_duration_seconds >= 0)',
    'CHECK (completed_step_count >= 0)',
    'CHECK (total_step_count >= 0)',
  ];
}

@DataClassName('LocalAppStateRow')
class LocalAppState extends Table {
  @override
  String get tableName => 'local_app_state';

  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
