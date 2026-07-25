import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/application/recover_active_session.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_performance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_recovery_result.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Recovery aktivní session nad skutečnou SQLite (QTR-004, QTR-008,
/// fyzický model §19, PDR-009/012). Zahrnuje reálný reopen databáze,
/// idempotentní opravu pointeru, osiřelý pointer, více aktivních sessions,
/// zachování dat R1-01…R1-04 a end-to-end restart flow bez backendu.
void main() {
  final now = DateTime.utc(2026, 7, 20, 8);

  DriftWorkoutSessionRepository sessions(AppDatabase db) =>
      DriftWorkoutSessionRepository(db);
  DriftWorkoutPerformanceRepository performances(AppDatabase db) =>
      DriftWorkoutPerformanceRepository(db, SequenceIdGenerator());

  RecoverActiveSession recovery(AppDatabase db) => RecoverActiveSession(
    sessionRepository: sessions(db),
    performanceRepository: performances(db),
    clock: () => now,
  );

  Future<void> seedAndStart(AppDatabase db) async {
    await DriftR1SeedRepository(db, now: () => now).applySeed();
    await sessions(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );
  }

  group('in-memory', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });
    tearDown(() async {
      await db.close();
    });

    Future<String?> pointer() async {
      final row = await db
          .customSelect(
            "SELECT value FROM local_app_state WHERE key = 'active_session_id'",
          )
          .getSingleOrNull();
      return row?.data['value'] as String?;
    }

    test(
      'start + recovery obnoví aktivní session (pointer souhlasí)',
      () async {
        await seedAndStart(db);

        final result = await recovery(db).call();

        expect(result, isA<ActiveSessionRecovered>());
        expect((result as ActiveSessionRecovered).session.id, 'ses-1');
        expect(await pointer(), 'ses-1');
      },
    );

    test(
      'chybějící pointer se bezpečně rekonstruuje z jediné aktivní session',
      () async {
        await seedAndStart(db);
        await db.customStatement(
          "DELETE FROM local_app_state WHERE key = 'active_session_id'",
        );
        expect(await pointer(), isNull);

        final result = await recovery(db).call();

        expect(result, isA<ActiveSessionRecoveredAfterRepair>());
        expect(await pointer(), 'ses-1');

        // Idempotence: druhý běh už pointer neopravuje.
        final second = await recovery(db).call();
        expect(second, isA<ActiveSessionRecovered>());
        expect(await pointer(), 'ses-1');
      },
    );

    test('oprava pointeru je no-op při porušení invariantu (rollback)', () async {
      await seedAndStart(db);
      // Druhá aktivní session na jiné instanci obejde per-instance index.
      await db.customStatement(
        "INSERT INTO local_workout_sessions "
        "(id, workout_instance_id, instance_revision_number, status, "
        "started_at, elapsed_active_seconds, created_at, updated_at, row_version) "
        "VALUES ('ses-2', 'demo-w2-instance', 1, 'ACTIVE', "
        "${now.millisecondsSinceEpoch + 1000}, 0, "
        "${now.millisecondsSinceEpoch}, ${now.millisecondsSinceEpoch}, 1)",
      );

      final changed = await sessions(
        db,
      ).reconcileActiveSessionPointer(sessionId: 'ses-1', now: now);
      expect(changed, isFalse);
    });

    test(
      'osiřelý pointer bez aktivní session → inconsistent, nic se nemaže',
      () async {
        await DriftR1SeedRepository(db, now: () => now).applySeed();
        await db.customStatement(
          "INSERT INTO local_app_state (key, value, updated_at) "
          "VALUES ('active_session_id', 'ghost', ${now.millisecondsSinceEpoch})",
        );

        final result = await recovery(db).call();

        expect(result, isA<InconsistentActiveSessionRecovery>());
        expect(
          (result as InconsistentActiveSessionRecovery).reason,
          RecoveryInconsistencyReason.orphanPointer,
        );
        // Pointer ani seed data se nemažou.
        expect(await pointer(), 'ghost');
        final instances = await db
            .customSelect('SELECT COUNT(*) AS c FROM local_workout_instances')
            .getSingle();
        expect(instances.data['c'], greaterThan(0));
      },
    );

    test(
      'více aktivních sessions → MultipleActiveSessions, žádná destrukce',
      () async {
        await seedAndStart(db);
        await db.customStatement(
          "INSERT INTO local_workout_sessions "
          "(id, workout_instance_id, instance_revision_number, status, "
          "started_at, elapsed_active_seconds, created_at, updated_at, row_version) "
          "VALUES ('ses-2', 'demo-w2-instance', 1, 'ACTIVE', "
          "${now.millisecondsSinceEpoch + 1000}, 0, "
          "${now.millisecondsSinceEpoch}, ${now.millisecondsSinceEpoch}, 1)",
        );

        final result = await recovery(db).call();

        expect(result, isA<MultipleActiveSessionsRecovery>());
        expect((result as MultipleActiveSessionsRecovery).count, 2);
        final count = await db
            .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
            .getSingle();
        expect(count.data['c'], 2); // nic se nesmazalo
      },
    );

    test('recovery nedokončuje ani nevytváří druhou session', () async {
      await seedAndStart(db);

      await recovery(db).call();

      final row = await db
          .customSelect(
            "SELECT status, completed_at FROM local_workout_sessions WHERE id = 'ses-1'",
          )
          .getSingle();
      expect(row.data['status'], 'ACTIVE');
      expect(row.data['completed_at'], isNull);
      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
          .getSingle();
      expect(count.data['c'], 1);
    });
  });

  test(
    'end-to-end: start → zápis → dokončení setu → reopen → auto recovery',
    () async {
      final dir = await Directory.systemTemp.createTemp('r1_05_recovery');
      final path = '${dir.path}/recovery.sqlite';
      addTearDown(() => dir.delete(recursive: true));

      // 1. běh: seed, start, zápis actualů, dokončení setu.
      final firstDb = AppDatabase(NativeDatabase(File(path)));
      await seedAndStart(firstDb);
      final firstPerf = performances(firstDb);
      await firstPerf.initializePerformances(sessionId: 'ses-1', now: now);
      final tracker = await firstPerf.loadTracker('ses-1');
      final setId = tracker!.exercises.first.sets.first.setPerformanceId;
      await firstPerf.recordSetActuals(
        setPerformanceId: setId,
        actualRepetitions: 9,
        actualWeightKg: 17.5,
        now: now,
      );
      await firstPerf.setSetCompletion(
        setPerformanceId: setId,
        completed: true,
        now: now,
      );
      final startedAt = (await sessions(
        firstDb,
      ).sessionById('ses-1'))!.startedAt;
      await firstDb.close();

      // 2. běh: reopen a recovery (bez ruční navigace, bez backendu).
      final secondDb = AppDatabase(NativeDatabase(File(path)));
      addTearDown(secondDb.close);

      final result = await recovery(secondDb).call();

      expect(result, isA<ActiveSessionRecovered>());
      final recovered = (result as ActiveSessionRecovered).session;
      expect(recovered.id, 'ses-1');
      expect(recovered.startedAt, startedAt); // stejný start time
      expect(recovered.status.name, 'active'); // stále aktivní

      // Stejné actual hodnoty a completion.
      final recoveredTracker = await performances(
        secondDb,
      ).loadTracker('ses-1');
      final set = recoveredTracker!.exercises.first.sets.first;
      expect(set.actualRepetitions, 9);
      expect(set.actualWeightKg, 17.5);
      expect(set.isCompleted, isTrue);

      // Žádné duplicitní performance řádky (2 cviky × 3 sety).
      final perfCount = await secondDb
          .customSelect('SELECT COUNT(*) AS c FROM local_set_performances')
          .getSingle();
      expect(perfCount.data['c'], 6);

      // Data R1-01 (snapshot) zůstala zachovaná.
      final plans = await secondDb
          .customSelect('SELECT COUNT(*) AS c FROM local_set_plans')
          .getSingle();
      expect(plans.data['c'], greaterThan(0));

      // Pointer odpovídá session; FK integrita čistá.
      final pointerRow = await secondDb
          .customSelect(
            "SELECT value FROM local_app_state WHERE key = 'active_session_id'",
          )
          .getSingle();
      expect(pointerRow.data['value'], 'ses-1');
      final violations = await secondDb
          .customSelect('PRAGMA foreign_key_check')
          .get();
      expect(violations, isEmpty);
    },
  );
}
