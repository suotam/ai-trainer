import 'package:drift/drift.dart';

import 'tables/activity_tables.dart';
import 'tables/ai_tables.dart';
import 'tables/availability_tables.dart';
import 'tables/calendar_tables.dart';
import 'tables/chat_tables.dart';
import 'tables/checkin_tables.dart';
import 'tables/goals_tables.dart';
import 'tables/plan_tables.dart';
import 'tables/sports_tables.dart';
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
    LocalOutbox,
    LocalSyncedVersions,
    LocalSyncResolutions,
    LocalUserSports,
    LocalGoals,
    LocalAvailabilityRules,
    LocalEquipmentItems,
    LocalConstraints,
    LocalTrainingPlans,
    LocalCalendarChanges,
    LocalActivities,
    LocalAiProposals,
    LocalDailyCheckIns,
    LocalChatConversations,
    LocalChatMessages,
    LocalChatActions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Schema version 17 (R8-03, C53 §4): stav průvodce na
  /// `local_workout_sessions` (`player_phase`, `player_phase_started_at`,
  /// `active_set_position`). Verze 16 (R8-01, C51 §7): nullable `exercise_code` na
  /// `local_workout_steps` (vazba na katalog cviků). Verze 15 (R7-03,
  /// C48 §4) přidala tabulku `local_chat_actions`
  /// (device-local akce chatu). Verze 14 (R7-02, C47 §2) přidala chat
  /// tabulky `local_chat_conversations` + `local_chat_messages`
  /// (device-local, CHC-001). Verze 13 (R5-01, C33 §3) přidala tabulku
  /// denního check-inu
  /// `local_daily_check_ins`. Verze 12 (R4-05) přidala provenance plánu,
  /// verze 11 (R4-03, C29 §2) tabulku AI návrhů
  /// `local_ai_proposals`. Verze 10 (R3-06) přidala ruční aktivity,
  /// verze 9 (R3-05) evidenci kalendářních změn, verze 8 (R3-04) ruční
  /// plán, verze 7 (R3-03) dostupnost/vybavení/omezení, verze 6 (R3-02)
  /// cíle, verze 5 (R3-01) sportovní profil, verze 4 (R2-06)
  /// conflict/rejection rozhodnutí, verze 3 (R2-05) serverové verze
  /// synced entit; `v1 → v2` (R2-01) zachovává všechna R1 data i aktivní
  /// session (C1 `MSM-005`, PDR-009).
  @override
  int get schemaVersion => 17;

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
      // R2-01: ID lokálního vlastníka (C2 §4). Idempotentní.
      await _ensureLocalOwner();
    },
    onUpgrade: (m, from, to) async {
      // Migrace v1 → v2 (R2-01, C1 §7/§10). Aditivní a nedestruktivní:
      // přidá owner/sync sloupce s bezpečným defaultem (SQLite backfilluje
      // existující řádky na local/anonymous owner a LOCAL_ONLY — MSM-014),
      // vytvoří outbox tabulku a zaznamená ID vlastníka. Žádná R1 data ani
      // aktivní session se neztrácí (MSM-005).
      if (from < 2) {
        await m.addColumn(localWorkoutInstances, localWorkoutInstances.ownerId);
        await m.addColumn(
          localWorkoutInstances,
          localWorkoutInstances.syncState,
        );
        await m.addColumn(localWorkoutSessions, localWorkoutSessions.ownerId);
        await m.addColumn(localWorkoutSessions, localWorkoutSessions.syncState);
        await m.addColumn(
          localActivitySummaries,
          localActivitySummaries.ownerId,
        );
        await m.addColumn(
          localActivitySummaries,
          localActivitySummaries.syncState,
        );
        await m.createTable(localOutbox);
        await _ensureLocalOwner();
      }
      // Migrace v2 → v3 (R2-05, C10 §10): jen nová tabulka serverových
      // verzí — aditivní, žádná existující data se nemění.
      if (from < 3) {
        await m.createTable(localSyncedVersions);
      }
      // Migrace v3 → v4 (R2-06, C12 §5): jen nová tabulka rozhodnutí —
      // aditivní, žádná existující data se nemění.
      if (from < 4) {
        await m.createTable(localSyncResolutions);
      }
      // Migrace v4 → v5 (R3-01, C16 §5): jen nová tabulka sportovního
      // profilu — aditivní, prázdná (R3M-008), žádná existující data se
      // nemění.
      if (from < 5) {
        await m.createTable(localUserSports);
      }
      // Migrace v5 → v6 (R3-02, C16 §5): jen nová tabulka cílů —
      // aditivní, prázdná (R3M-008), žádná existující data se nemění.
      if (from < 6) {
        await m.createTable(localGoals);
      }
      // Migrace v6 → v7 (R3-03, C16 §5): tři nové tabulky dostupnosti,
      // vybavení a omezení — aditivní, prázdné (R3M-008), žádná
      // existující data se nemění.
      if (from < 7) {
        await m.createTable(localAvailabilityRules);
        await m.createTable(localEquipmentItems);
        await m.createTable(localConstraints);
      }
      // Migrace v7 → v8 (R3-04, C16 §5): jen nová tabulka plánu —
      // aditivní, prázdná (R3M-008), žádná existující data se nemění.
      if (from < 8) {
        await m.createTable(localTrainingPlans);
      }
      // Migrace v8 → v9 (R3-05, C16 §5): jen append-only evidence
      // kalendářních změn — aditivní, prázdná (R3M-008).
      if (from < 9) {
        await m.createTable(localCalendarChanges);
      }
      // Migrace v9 → v10 (R3-06, C16 §5): jen tabulka ručních aktivit —
      // aditivní, prázdná (R3M-008).
      if (from < 10) {
        await m.createTable(localActivities);
      }
      // Migrace v10 → v11 (R4-03, C29 §2): jen tabulka AI návrhů —
      // aditivní, prázdná.
      if (from < 11) {
        await m.createTable(localAiProposals);
      }
      // Migrace v11 → v12 (R4-05, C30 CSE-004): provenance plánu —
      // aditivní sloupec s defaultem MANUAL, žádná data se nemění.
      // Migrace z < v8 tabulku právě vytvořila už včetně origin, proto
      // se sloupec přidává jen tam, kde tabulka existovala dřív.
      if (from >= 8 && from < 12) {
        await m.addColumn(localTrainingPlans, localTrainingPlans.origin);
      }
      // Migrace v12 → v13 (R5-01, C33 §3): jen tabulka denního check-inu —
      // aditivní, prázdná.
      if (from < 13) {
        await m.createTable(localDailyCheckIns);
      }
      // Migrace v13 → v14 (R7-02, C47 §2): chat tabulky — aditivní,
      // prázdné, žádná existující data se nemění (CHC-015).
      if (from < 14) {
        await m.createTable(localChatConversations);
        await m.createTable(localChatMessages);
      }
      // Migrace v14 → v15 (R7-03, C48 §4): akce chatu — aditivní, prázdná
      // (CHA-015).
      if (from < 15) {
        await m.createTable(localChatActions);
      }
      // Migrace v15 → v16 (R8-01, C51 §7): nullable vazba kroku na katalog
      // cviků — aditivní, bez backfillu (EXC-004).
      if (from < 16) {
        await m.addColumn(localWorkoutSteps, localWorkoutSteps.exerciseCode);
      }
      // Migrace v16 → v17 (R8-03, C53 §4): stav průvodce na session —
      // aditivní nullable sloupce (GSP-003).
      if (from < 17) {
        await m.addColumn(
          localWorkoutSessions,
          localWorkoutSessions.playerPhase,
        );
        await m.addColumn(
          localWorkoutSessions,
          localWorkoutSessions.playerPhaseStartedAt,
        );
        await m.addColumn(
          localWorkoutSessions,
          localWorkoutSessions.activeSetPosition,
        );
      }
    },
    beforeOpen: (details) async {
      // Foreign keys jsou v SQLite per-connection a musí být aktivní vždy
      // (evidence gate R1-01).
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Zaznamená stabilní ID lokálního/anonymního vlastníka do `local_app_state`
  /// (R2-01, C2 §4). Idempotentní — `INSERT OR IGNORE` na primární klíč.
  Future<void> _ensureLocalOwner() async {
    await customStatement(
      'INSERT OR IGNORE INTO local_app_state (key, value, updated_at) '
      "VALUES ('$localOwnerStateKey', '$localAnonymousOwnerId', 0)",
    );
  }
}
