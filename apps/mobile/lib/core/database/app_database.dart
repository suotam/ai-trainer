import 'package:drift/drift.dart';

import 'tables/workout_tables.dart';

part 'app_database.g.dart';

/// Lokální R1 databáze (ADR-004, `docs/12-data/r1-physical-data-model.md`).
///
/// Počáteční schema version je 1 (fyzický model §18). Každá další verze
/// musí mít explicitní migration step, migration test a musí zachovat
/// aktivní session i potvrzené performance záznamy (PDR-009, PDR-015).
@DriftDatabase(
  tables: [
    LocalWorkoutInstances,
    LocalWorkoutSections,
    LocalWorkoutSteps,
    LocalSetPlans,
    LocalWorkoutSessions,
    LocalStepPerformances,
    LocalSetPerformances,
    LocalWorkoutFeedback,
    LocalActivitySummaries,
    LocalAppState,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Indexy fyzického modelu §5.
      await customStatement(
        'CREATE INDEX idx_instances_local_date_status '
        'ON local_workout_instances (scheduled_local_date, status)',
      );
      await customStatement(
        'CREATE INDEX idx_instances_updated_at '
        'ON local_workout_instances (updated_at)',
      );
      await customStatement(
        'CREATE INDEX idx_instances_started_session '
        'ON local_workout_instances (started_session_id)',
      );
      // Unikátní pořadí kroků: SQLite UNIQUE bere NULL jako různé hodnoty,
      // proto expression index s COALESCE (fyzický model §7).
      await customStatement(
        'CREATE UNIQUE INDEX idx_steps_sibling_position '
        "ON local_workout_steps (section_id, COALESCE(parent_step_id, ''), position)",
      );
      // Nejvýše jedna ACTIVE/PAUSED session na instanci (fyzický model §9,
      // PDR-005, INV-083).
      await customStatement(
        'CREATE UNIQUE INDEX idx_one_active_session_per_instance '
        'ON local_workout_sessions (workout_instance_id) '
        "WHERE status IN ('ACTIVE', 'PAUSED')",
      );
    },
    beforeOpen: (details) async {
      // Foreign keys jsou v SQLite per-connection a musí být aktivní vždy
      // (evidence gate R1-01).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
