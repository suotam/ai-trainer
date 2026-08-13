import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// R2-01 migrace `v1 â†’ v2` od **reĂˇlnĂ©ho v1 stavu** (C1 `MSM-002/005`,
/// evidence gate R2-01). PostavĂ­ skuteÄŤnou v1 databĂˇzi pĹ™esnĂ˝m DDL ze
/// `sqlite_master` (viz `docs/12-data/r1-physical-data-model.md`), naplnĂ­ ji
/// R1 daty vÄŤ. aktivnĂ­ session a potvrzenĂ©ho vĂ˝konu, pak ji otevĹ™e pĹ™es
/// `AppDatabase` (schemaVersion 2 â†’ onUpgrade) a ovÄ›Ĺ™Ă­, Ĺľe se nic neztratilo,
/// novĂˇ owner/sync metadata jsou backfillnutĂˇ a outbox existuje.
void main() {
  // PĹ™esnĂ© v1 CREATE statementy (schema version 1).
  const v1Tables = [
    'CREATE TABLE "local_workout_instances" ("id" TEXT NOT NULL, "title" TEXT NOT NULL, "description" TEXT NULL, "purpose" TEXT NULL, "workout_type" TEXT NOT NULL, "scheduled_local_date" TEXT NOT NULL, "scheduled_start_at" INTEGER NULL, "time_zone_id" TEXT NULL, "planned_duration_seconds" INTEGER NULL, "status" TEXT NOT NULL, "source_type" TEXT NOT NULL, "source_reference" TEXT NULL, "revision_number" INTEGER NOT NULL, "started_session_id" TEXT NULL, "completed_at" INTEGER NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, "row_version" INTEGER NOT NULL, PRIMARY KEY ("id"), CHECK (revision_number >= 1), CHECK (row_version >= 1))',
    'CREATE TABLE "local_workout_sections" ("id" TEXT NOT NULL, "workout_instance_id" TEXT NOT NULL REFERENCES local_workout_instances (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "title" TEXT NOT NULL, "section_type" TEXT NOT NULL, "purpose" TEXT NULL, "priority" TEXT NOT NULL, "is_optional" INTEGER NOT NULL CHECK ("is_optional" IN (0, 1)), "planned_duration_seconds" INTEGER NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), UNIQUE ("workout_instance_id", "position"))',
    'CREATE TABLE "local_workout_steps" ("id" TEXT NOT NULL, "section_id" TEXT NOT NULL REFERENCES local_workout_sections (id) ON DELETE CASCADE, "parent_step_id" TEXT NULL REFERENCES local_workout_steps (id), "position" INTEGER NOT NULL, "step_type" TEXT NOT NULL, "title" TEXT NOT NULL, "instructions" TEXT NULL, "purpose" TEXT NULL, "priority" TEXT NOT NULL, "is_skippable" INTEGER NOT NULL CHECK ("is_skippable" IN (0, 1)), "prescription_type" TEXT NOT NULL, "planned_duration_seconds" INTEGER NULL, "planned_distance_meters" REAL NULL, "planned_repetitions" INTEGER NULL, "planned_weight_kg" REAL NULL, "metadata_json" TEXT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
    'CREATE TABLE "local_set_plans" ("id" TEXT NOT NULL, "workout_step_id" TEXT NOT NULL REFERENCES local_workout_steps (id) ON DELETE CASCADE, "position" INTEGER NOT NULL, "planned_repetitions" INTEGER NULL, "minimum_repetitions" INTEGER NULL, "maximum_repetitions" INTEGER NULL, "planned_weight_kg" REAL NULL, "planned_duration_seconds" INTEGER NULL, "rest_after_seconds" INTEGER NULL, "target_rpe" REAL NULL, PRIMARY KEY ("id"), UNIQUE ("workout_step_id", "position"))',
    'CREATE TABLE "local_workout_sessions" ("id" TEXT NOT NULL, "workout_instance_id" TEXT NOT NULL REFERENCES local_workout_instances (id) ON DELETE RESTRICT, "instance_revision_number" INTEGER NOT NULL, "status" TEXT NOT NULL, "started_at" INTEGER NOT NULL, "last_resumed_at" INTEGER NULL, "paused_at" INTEGER NULL, "completed_at" INTEGER NULL, "active_step_id" TEXT NULL, "elapsed_active_seconds" INTEGER NOT NULL, "notes" TEXT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, "row_version" INTEGER NOT NULL, PRIMARY KEY ("id"), CHECK (elapsed_active_seconds >= 0), CHECK (row_version >= 1), CHECK (status != \'COMPLETED\' OR completed_at IS NOT NULL))',
    'CREATE TABLE "local_step_performances" ("id" TEXT NOT NULL, "workout_session_id" TEXT NOT NULL REFERENCES local_workout_sessions (id) ON DELETE CASCADE, "workout_step_id" TEXT NOT NULL REFERENCES local_workout_steps (id) ON DELETE RESTRICT, "status" TEXT NOT NULL, "started_at" INTEGER NULL, "completed_at" INTEGER NULL, "actual_repetitions" INTEGER NULL, "actual_duration_seconds" INTEGER NULL, "actual_distance_meters" REAL NULL, "actual_weight_kg" REAL NULL, "perceived_exertion" REAL NULL, "notes" TEXT NULL, "updated_at" INTEGER NOT NULL, "row_version" INTEGER NOT NULL, PRIMARY KEY ("id"), UNIQUE ("workout_session_id", "workout_step_id"), CHECK (row_version >= 1))',
    'CREATE TABLE "local_set_performances" ("id" TEXT NOT NULL, "step_performance_id" TEXT NOT NULL REFERENCES local_step_performances (id) ON DELETE CASCADE, "set_plan_id" TEXT NULL REFERENCES local_set_plans (id), "position" INTEGER NOT NULL, "status" TEXT NOT NULL, "actual_repetitions" INTEGER NULL, "actual_weight_kg" REAL NULL, "actual_duration_seconds" INTEGER NULL, "actual_rpe" REAL NULL, "completed_at" INTEGER NULL, "notes" TEXT NULL, "updated_at" INTEGER NOT NULL, "row_version" INTEGER NOT NULL, PRIMARY KEY ("id"), UNIQUE ("step_performance_id", "position"), CHECK (row_version >= 1))',
    'CREATE TABLE "local_workout_feedback" ("id" TEXT NOT NULL, "workout_session_id" TEXT NOT NULL UNIQUE REFERENCES local_workout_sessions (id) ON DELETE CASCADE, "overall_effort" REAL NULL, "feeling" TEXT NULL, "pain_reported" INTEGER NOT NULL CHECK ("pain_reported" IN (0, 1)), "notes" TEXT NULL, "created_at" INTEGER NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
    'CREATE TABLE "local_activity_summaries" ("id" TEXT NOT NULL, "workout_instance_id" TEXT NOT NULL REFERENCES local_workout_instances (id), "workout_session_id" TEXT NOT NULL UNIQUE REFERENCES local_workout_sessions (id), "title_snapshot" TEXT NOT NULL, "workout_type" TEXT NOT NULL, "started_at" INTEGER NOT NULL, "completed_at" INTEGER NOT NULL, "active_duration_seconds" INTEGER NOT NULL, "completed_step_count" INTEGER NOT NULL, "total_step_count" INTEGER NOT NULL, "overall_effort" REAL NULL, "created_at" INTEGER NOT NULL, PRIMARY KEY ("id"))',
    'CREATE TABLE "local_app_state" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("key"))',
  ];

  void seedV1(String path) {
    // ReĂˇlnĂ˝ v1 stav pĹ™es raw sqlite3 (mimo Drift migrace): v1 DDL,
    // user_version=1 a R1 data v poĹ™adĂ­ zĂˇvislostĂ­.
    final raw = sqlite.sqlite3.open(path);
    for (final ddl in v1Tables) {
      raw.execute(ddl);
    }
    raw.execute('PRAGMA user_version = 1');
    raw
      ..execute(
        "INSERT INTO local_workout_instances (id,title,workout_type,scheduled_local_date,status,source_type,revision_number,created_at,updated_at,row_version) "
        "VALUES ('wi1','Demo','STRENGTH','2026-07-20','IN_PROGRESS','SEED',1,1,1,1)",
      )
      ..execute(
        "INSERT INTO local_workout_sections (id,workout_instance_id,position,title,section_type,priority,is_optional,created_at,updated_at) "
        "VALUES ('sec1','wi1',0,'Main','MAIN','REQUIRED',0,1,1)",
      )
      ..execute(
        "INSERT INTO local_workout_steps (id,section_id,position,step_type,title,priority,is_skippable,prescription_type,created_at,updated_at) "
        "VALUES ('st1','sec1',0,'EXERCISE','Squat','REQUIRED',0,'SET_REP',1,1)",
      )
      ..execute(
        "INSERT INTO local_set_plans (id,workout_step_id,position,planned_repetitions) VALUES ('sp1','st1',0,8)",
      )
      // AktivnĂ­ session + potvrzenĂ˝ vĂ˝kon.
      ..execute(
        "INSERT INTO local_workout_sessions (id,workout_instance_id,instance_revision_number,status,started_at,elapsed_active_seconds,created_at,updated_at,row_version) "
        "VALUES ('ses1','wi1',1,'ACTIVE',1000,0,1,1,1)",
      )
      ..execute(
        "INSERT INTO local_step_performances (id,workout_session_id,workout_step_id,status,updated_at,row_version) "
        "VALUES ('spf1','ses1','st1','NOT_STARTED',1,1)",
      )
      ..execute(
        "INSERT INTO local_set_performances (id,step_performance_id,position,status,actual_repetitions,updated_at,row_version) "
        "VALUES ('setp1','spf1',0,'COMPLETED',9,1,1)",
      )
      ..execute(
        "INSERT INTO local_workout_feedback (id,workout_session_id,pain_reported,created_at,updated_at) "
        "VALUES ('fb1','ses1',0,1,1)",
      )
      // DokonÄŤenĂˇ session + activity summary (pro migraci summaries tabulky).
      ..execute(
        "INSERT INTO local_workout_sessions (id,workout_instance_id,instance_revision_number,status,started_at,completed_at,elapsed_active_seconds,created_at,updated_at,row_version) "
        "VALUES ('ses0','wi1',1,'COMPLETED',10,20,0,1,1,1)",
      )
      ..execute(
        "INSERT INTO local_activity_summaries (id,workout_instance_id,workout_session_id,title_snapshot,workout_type,started_at,completed_at,active_duration_seconds,completed_step_count,total_step_count,created_at) "
        "VALUES ('as1','wi1','ses0','Demo','STRENGTH',10,20,0,1,1,1)",
      )
      ..execute(
        "INSERT INTO local_app_state (key,value,updated_at) VALUES ('seed_version','1',1)",
      );
    raw.dispose(); // ignore: deprecated_member_use
  }

  test(
    'v1 â†’ v2 zachovĂˇ vĹˇechna R1 data, aktivnĂ­ session a backfillne metadata',
    () async {
      final dir = await Directory.systemTemp.createTemp('r2_01_migration');
      final path = '${dir.path}/mig.sqlite';
      addTearDown(() => dir.delete(recursive: true));

      // 1. Postav reĂˇlnĂ˝ v1 stav.
      seedV1(path);

      // 2. OtevĹ™i pĹ™es AppDatabase v2 â†’ spustĂ­ onUpgrade(1â†’2).
      final db = AppDatabase(NativeDatabase(File(path)));
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get(); // vynutĂ­ otevĹ™enĂ­ + migraci

      // Schema version je aktuální (v10 od R3-06).
      final ver = await db
          .customSelect('PRAGMA user_version')
          .map((r) => r.data.values.first as int)
          .getSingle();
      expect(ver, 10);

      // 3. ZachovĂˇnĂ­ dat â€” poÄŤty beze zmÄ›ny.
      Future<int> count(String table) async =>
          (await db
                      .customSelect('SELECT COUNT(*) AS c FROM $table')
                      .getSingle())
                  .data['c']
              as int;
      expect(await count('local_workout_instances'), 1);
      expect(await count('local_workout_sessions'), 2);
      expect(await count('local_step_performances'), 1);
      expect(await count('local_set_performances'), 1);
      expect(await count('local_workout_feedback'), 1);
      expect(await count('local_activity_summaries'), 1);

      // AktivnĂ­ session je nedotÄŤenĂˇ.
      final active = await db
          .customSelect(
            "SELECT id, status, started_at FROM local_workout_sessions WHERE status='ACTIVE'",
          )
          .getSingle();
      expect(active.data['id'], 'ses1');
      expect(active.data['started_at'], 1000);

      // PotvrzenĂ˝ vĂ˝kon zachovĂˇn.
      final perf = await db
          .customSelect(
            "SELECT actual_repetitions FROM local_set_performances WHERE id='setp1'",
          )
          .getSingle();
      expect(perf.data['actual_repetitions'], 9);

      // 4. NovĂˇ owner/sync metadata backfillnutĂˇ na default.
      for (final t in [
        'local_workout_instances',
        'local_workout_sessions',
        'local_activity_summaries',
      ]) {
        final rows = await db
            .customSelect('SELECT owner_id, sync_state FROM $t')
            .get();
        expect(rows, isNotEmpty);
        for (final r in rows) {
          expect(r.data['owner_id'], 'local-anonymous');
          expect(r.data['sync_state'], 'LOCAL_ONLY');
        }
      }

      // 5. Outbox tabulka existuje a je prĂˇzdnĂˇ; ID vlastnĂ­ka je zaznamenĂˇno.
      expect(await count('local_outbox'), 0);
      final owner = await db
          .customSelect(
            "SELECT value FROM local_app_state WHERE key='local_owner_id'",
          )
          .getSingle();
      expect(owner.data['value'], 'local-anonymous');
      // Seed version z v1 zĹŻstal.
      final seed = await db
          .customSelect(
            "SELECT value FROM local_app_state WHERE key='seed_version'",
          )
          .getSingle();
      expect(seed.data['value'], '1');

      // 6. R3-01/R3-02/R3-03 (C16 R3M-008/010): migrační řetěz přes reálné
      // předchozí stavy vytvoří prázdné R3 tabulky.
      expect(await count('local_user_sports'), 0);
      expect(await count('local_goals'), 0);
      expect(await count('local_availability_rules'), 0);
      expect(await count('local_equipment_items'), 0);
      expect(await count('local_constraints'), 0);
      expect(await count('local_training_plans'), 0);
      expect(await count('local_calendar_changes'), 0);
      expect(await count('local_activities'), 0);

      // 7. FK integrita ÄŤistĂˇ po migraci (MSM-008).
      final violations = await db
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(violations, isEmpty);
    },
  );
}
