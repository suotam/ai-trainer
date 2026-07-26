import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/application/recover_active_session.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_completion_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_performance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_recovery_result.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Dokončení workoutu a historie nad skutečnou SQLite (QTR-004, QTR-009,
/// fyzický model §15.3/§13, PDR-006/007). Atomická transakce, idempotence,
/// rollback, reopen, recovery po completion, history dotaz, e2e critical path.
void main() {
  final now = DateTime.utc(2026, 7, 20, 9);
  final later = DateTime.utc(2026, 7, 20, 10);

  DriftWorkoutSessionRepository sessions(AppDatabase db) =>
      DriftWorkoutSessionRepository(db);
  DriftWorkoutPerformanceRepository perf(AppDatabase db) =>
      DriftWorkoutPerformanceRepository(db, SequenceIdGenerator());
  DriftWorkoutCompletionRepository completion(AppDatabase db) =>
      DriftWorkoutCompletionRepository(db, SequenceIdGenerator());
  DriftWorkoutHistoryRepository history(AppDatabase db) =>
      DriftWorkoutHistoryRepository(db);

  Future<void> seedStartInit(AppDatabase db) async {
    await DriftR1SeedRepository(db, now: () => now).applySeed();
    await sessions(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );
    await perf(db).initializePerformances(sessionId: 'ses-1', now: now);
  }

  Future<List<String>> allSetIds(AppDatabase db) async {
    final tracker = await perf(db).loadTracker('ses-1');
    return [
      for (final e in tracker!.exercises)
        for (final s in e.sets) s.setPerformanceId,
    ];
  }

  Future<Map<String, Object?>> sessionRow(AppDatabase db, String id) async {
    final r = await db
        .customSelect(
          "SELECT status, completed_at FROM local_workout_sessions WHERE id = '$id'",
        )
        .getSingle();
    return r.data;
  }

  Future<String?> pointer(AppDatabase db) async {
    final r = await db
        .customSelect(
          "SELECT value FROM local_app_state WHERE key = 'active_session_id'",
        )
        .getSingleOrNull();
    return r?.data['value'] as String?;
  }

  group('in-memory', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() async => db.close());

    test(
      'dokončení přepne session, instanci, vytvoří summary a vyčistí pointer',
      () async {
        await seedStartInit(db);
        // Dokonči jeden set, zapiš actual (částečné dokončení).
        final setIds = await allSetIds(db);
        await perf(db).recordSetActuals(
          setPerformanceId: setIds.first,
          actualRepetitions: 9,
          actualWeightKg: 17.5,
          now: now,
        );
        await perf(db).setSetCompletion(
          setPerformanceId: setIds.first,
          completed: true,
          now: now,
        );

        final result = await completion(
          db,
        ).completeWorkout(sessionId: 'ses-1', now: later);
        expect(result, isA<WorkoutCompleted>());

        final s = await sessionRow(db, 'ses-1');
        expect(s['status'], 'COMPLETED');
        expect(s['completed_at'], later.millisecondsSinceEpoch);

        final inst = await db
            .customSelect(
              "SELECT status, completed_at FROM local_workout_instances WHERE id = 'demo-w1-instance'",
            )
            .getSingle();
        // Ne všechny sety dokončené → částečné dokončení.
        expect(inst.data['status'], 'PARTIALLY_COMPLETED');
        expect(inst.data['completed_at'], later.millisecondsSinceEpoch);

        final summaries = await db
            .customSelect('SELECT COUNT(*) AS c FROM local_activity_summaries')
            .getSingle();
        expect(summaries.data['c'], 1);

        // Pointer vyčištěn.
        expect(await pointer(db), isNull);

        // Performance actual data zachována.
        final tracker = await perf(db).loadTracker('ses-1');
        final firstSet = tracker!.exercises.first.sets.first;
        expect(firstSet.actualRepetitions, 9);
        expect(firstSet.actualWeightKg, 17.5);
        expect(firstSet.isCompleted, isTrue);

        // Planned snapshot nezměněn.
        final plan = await db
            .customSelect(
              "SELECT planned_repetitions FROM local_set_plans WHERE id = 'demo-w1-squat-set0'",
            )
            .getSingle();
        expect(plan.data['planned_repetitions'], 8);

        // FK integrita čistá.
        final violations = await db
            .customSelect('PRAGMA foreign_key_check')
            .get();
        expect(violations, isEmpty);
      },
    );

    test('všechny kroky dokončené → instance COMPLETED', () async {
      await seedStartInit(db);
      for (final id in await allSetIds(db)) {
        await perf(
          db,
        ).setSetCompletion(setPerformanceId: id, completed: true, now: now);
      }

      await completion(db).completeWorkout(sessionId: 'ses-1', now: later);

      final inst = await db
          .customSelect(
            "SELECT status FROM local_workout_instances WHERE id = 'demo-w1-instance'",
          )
          .getSingle();
      expect(inst.data['status'], 'COMPLETED');
    });

    test(
      'opakované dokončení je idempotentní (alreadyCompleted, bez duplicit)',
      () async {
        await seedStartInit(db);
        final first = await completion(
          db,
        ).completeWorkout(sessionId: 'ses-1', now: later);
        expect(first, isA<WorkoutCompleted>());

        final second = await completion(db).completeWorkout(
          sessionId: 'ses-1',
          now: DateTime.utc(2026, 7, 20, 11),
        );
        expect(second, isA<WorkoutAlreadyCompleted>());

        // Původní completed_at nezměněn.
        final s = await sessionRow(db, 'ses-1');
        expect(s['completed_at'], later.millisecondsSinceEpoch);
        // Žádný duplicitní summary.
        final summaries = await db
            .customSelect('SELECT COUNT(*) AS c FROM local_activity_summaries')
            .getSingle();
        expect(summaries.data['c'], 1);
        expect(await pointer(db), isNull);
      },
    );

    test('neexistující session → typovaný not-found', () async {
      await seedStartInit(db);
      final result = await completion(
        db,
      ).completeWorkout(sessionId: 'missing', now: later);
      expect(result, isA<CompletionSessionNotFound>());
    });

    test('nedokončitelná session (ABANDONED) → not-completable', () async {
      await seedStartInit(db);
      await db.customStatement(
        "UPDATE local_workout_sessions SET status = 'ABANDONED' WHERE id = 'ses-1'",
      );
      final result = await completion(
        db,
      ).completeWorkout(sessionId: 'ses-1', now: later);
      expect(result, isA<CompletionSessionNotCompletable>());
    });

    test('selhání během completion → rollback bez částečného stavu', () async {
      await seedStartInit(db);
      // Předvložený summary se stejným session_id způsobí porušení UNIQUE
      // při insertu → celá transakce se vrátí.
      await db.customStatement(
        "INSERT INTO local_activity_summaries "
        "(id, workout_instance_id, workout_session_id, title_snapshot, workout_type, "
        "started_at, completed_at, active_duration_seconds, completed_step_count, "
        "total_step_count, created_at) VALUES "
        "('pre', 'demo-w1-instance', 'ses-1', 'x', 'STRENGTH', 0, 0, 0, 0, 0, 0)",
      );

      await expectLater(
        completion(db).completeWorkout(sessionId: 'ses-1', now: later),
        throwsA(anything),
      );

      // Session i pointer beze změny (rollback).
      final s = await sessionRow(db, 'ses-1');
      expect(s['status'], 'ACTIVE');
      expect(s['completed_at'], isNull);
      expect(await pointer(db), 'ses-1');
      final inst = await db
          .customSelect(
            "SELECT status FROM local_workout_instances WHERE id = 'demo-w1-instance'",
          )
          .getSingle();
      expect(inst.data['status'], 'IN_PROGRESS');
    });

    test('recovery po dokončení vrátí NoActiveSession', () async {
      await seedStartInit(db);
      await completion(db).completeWorkout(sessionId: 'ses-1', now: later);

      final recovery = RecoverActiveSession(
        sessionRepository: sessions(db),
        performanceRepository: perf(db),
        clock: () => later,
      );
      final result = await recovery.call();
      expect(result, isA<NoActiveSessionRecovery>());
    });

    test('history vrátí dokončený workout; ne aktivní ani budoucí', () async {
      await seedStartInit(db);
      await completion(db).completeWorkout(sessionId: 'ses-1', now: later);

      final entries = await history(db).completedWorkouts();
      expect(entries.length, 1);
      expect(entries.first.workoutSessionId, 'ses-1');
      expect(entries.first.title, 'Full Body Strength (Demo)');
      expect(entries.first.completedAt, later);
    });
  });

  test(
    'end-to-end §11.2: seed → start → zápis → restart → recovery → dokončení → historie',
    () async {
      final dir = await Directory.systemTemp.createTemp('r1_06_e2e');
      final path = '${dir.path}/e2e.sqlite';
      addTearDown(() => dir.delete(recursive: true));

      // Fáze 1: seed, start, init, zápis + dokončení jednoho setu.
      final db1 = AppDatabase(NativeDatabase(File(path)));
      await seedStartInit(db1);
      final setIds1 = await allSetIds(db1);
      await perf(db1).recordSetActuals(
        setPerformanceId: setIds1.first,
        actualRepetitions: 10,
        actualWeightKg: 18,
        now: now,
      );
      await perf(db1).setSetCompletion(
        setPerformanceId: setIds1.first,
        completed: true,
        now: now,
      );
      await db1.close();

      // Fáze 2: restart → recovery obnoví aktivní session.
      final db2 = AppDatabase(NativeDatabase(File(path)));
      final recovery = RecoverActiveSession(
        sessionRepository: sessions(db2),
        performanceRepository: perf(db2),
        clock: () => later,
      );
      expect(await recovery.call(), isA<ActiveSessionRecovered>());

      // Uživatel dokončí workout.
      final done = await completion(
        db2,
      ).completeWorkout(sessionId: 'ses-1', now: later);
      expect(done, isA<WorkoutCompleted>());
      await db2.close();

      // Fáze 3: další restart → historie obsahuje dokončený workout se
      // stejnými actual hodnotami; recovery vede na NoActiveSession.
      final db3 = AppDatabase(NativeDatabase(File(path)));
      addTearDown(db3.close);

      final recovery3 = RecoverActiveSession(
        sessionRepository: sessions(db3),
        performanceRepository: perf(db3),
        clock: () => later,
      );
      expect(await recovery3.call(), isA<NoActiveSessionRecovery>());

      final entries = await history(db3).completedWorkouts();
      expect(entries.length, 1);
      final entry = entries.first;
      expect(entry.workoutSessionId, 'ses-1');

      final tracker = await perf(db3).loadTracker('ses-1');
      final firstSet = tracker!.exercises.first.sets.first;
      expect(firstSet.actualRepetitions, 10);
      expect(firstSet.actualWeightKg, 18);
      expect(firstSet.isCompleted, isTrue);

      // Přesně jedna session, žádné duplicitní summary.
      final sessionsCount = await db3
          .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
          .getSingle();
      expect(sessionsCount.data['c'], 1);
      final summaries = await db3
          .customSelect('SELECT COUNT(*) AS c FROM local_activity_summaries')
          .getSingle();
      expect(summaries.data['c'], 1);
    },
  );
}
