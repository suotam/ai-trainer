import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_performance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/record_performance_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Performance persistence nad skutečnou SQLite (QTR-004, fyzický model
/// §10/§11/§15.2).
void main() {
  final now = DateTime.utc(2026, 7, 20, 8);

  late AppDatabase db;
  late DriftWorkoutPerformanceRepository perf;

  Future<void> seedAndStart() async {
    await DriftR1SeedRepository(db, now: () => now).applySeed();
    await DriftWorkoutSessionRepository(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );
  }

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    perf = DriftWorkoutPerformanceRepository(db, SequenceIdGenerator());
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> firstSetId() async {
    final tracker = await perf.loadTracker('ses-1');
    return tracker!.exercises.first.sets.first.setPerformanceId;
  }

  test(
    'inicializace vytvoří performance rows podle snapshotu a pořadí',
    () async {
      await seedAndStart();
      await perf.initializePerformances(sessionId: 'ses-1', now: now);

      final tracker = await perf.loadTracker('ses-1');
      expect(tracker, isNotNull);
      // Demo w1 má 2 exercise kroky (squat, press), každý 3 sety.
      expect(tracker!.exercises.map((e) => e.title), [
        'Goblet squat',
        'Dumbbell bench press',
      ]);
      final squat = tracker.exercises.first;
      expect(squat.sets.map((s) => s.position), [0, 1, 2]);
      expect(squat.sets.first.plannedRepetitions, 8);
      expect(squat.sets.first.plannedWeightKg, 16);
      expect(squat.sets.first.actualRepetitions, isNull);
      expect(
        squat.sets.every((s) => s.status == SetPerformanceStatus.planned),
        isTrue,
      );
    },
  );

  test(
    'opakovaná inicializace je idempotentní a nepřepíše actual data',
    () async {
      await seedAndStart();
      await perf.initializePerformances(sessionId: 'ses-1', now: now);
      final setId = await firstSetId();
      await perf.recordSetActuals(
        setPerformanceId: setId,
        actualRepetitions: 7,
        actualWeightKg: 18,
        now: now,
      );

      await perf.initializePerformances(sessionId: 'ses-1', now: now);

      final count = await db
          .customSelect('SELECT COUNT(*) AS c FROM local_set_performances')
          .getSingle();
      expect(count.data['c'], 6); // 2 cviky × 3 sety, žádné duplikáty
      final tracker = await perf.loadTracker('ses-1');
      final set = tracker!.exercises.first.sets.first;
      expect(set.actualRepetitions, 7);
      expect(set.actualWeightKg, 18);
    },
  );

  test('zápis skutečných hodnot nemění planned snapshot', () async {
    await seedAndStart();
    await perf.initializePerformances(sessionId: 'ses-1', now: now);
    final setId = await firstSetId();

    final result = await perf.recordSetActuals(
      setPerformanceId: setId,
      actualRepetitions: 10,
      actualWeightKg: 20,
      now: now,
    );
    expect(result, isA<PerformanceSaved>());

    // Planned zůstává v set_plans nezměněný.
    final plan = await db
        .customSelect(
          "SELECT planned_repetitions, planned_weight_kg FROM local_set_plans "
          "WHERE id = 'demo-w1-squat-set0'",
        )
        .getSingle();
    expect(plan.data['planned_repetitions'], 8);
    expect(plan.data['planned_weight_kg'], 16);
    final tracker = await perf.loadTracker('ses-1');
    final set = tracker!.exercises.first.sets.first;
    expect(set.plannedRepetitions, 8);
    expect(set.actualRepetitions, 10);
  });

  test('completion nastaví status a timestamp; uncomplete vrátí PLANNED', () async {
    await seedAndStart();
    await perf.initializePerformances(sessionId: 'ses-1', now: now);
    final setId = await firstSetId();

    await perf.setSetCompletion(
      setPerformanceId: setId,
      completed: true,
      now: now,
    );
    var row = await db
        .customSelect(
          "SELECT status, completed_at FROM local_set_performances WHERE id = '$setId'",
        )
        .getSingle();
    expect(row.data['status'], 'COMPLETED');
    expect(row.data['completed_at'], now.millisecondsSinceEpoch);

    await perf.setSetCompletion(
      setPerformanceId: setId,
      completed: false,
      now: now,
    );
    row = await db
        .customSelect(
          "SELECT status, completed_at FROM local_set_performances WHERE id = '$setId'",
        )
        .getSingle();
    expect(row.data['status'], 'PLANNED');
    expect(row.data['completed_at'], isNull);
  });

  test('zápis do neexistujícího setu vrátí typovaný not-found', () async {
    await seedAndStart();
    await perf.initializePerformances(sessionId: 'ses-1', now: now);
    final result = await perf.recordSetActuals(
      setPerformanceId: 'missing',
      actualRepetitions: 5,
      actualWeightKg: null,
      now: now,
    );
    expect(result, isA<PerformanceSetNotFound>());
  });

  test('zápis do setu neaktivní session je odmítnut', () async {
    await seedAndStart();
    await perf.initializePerformances(sessionId: 'ses-1', now: now);
    final setId = await firstSetId();
    await db.customStatement(
      "UPDATE local_workout_sessions SET status = 'COMPLETED', completed_at = 1 "
      "WHERE id = 'ses-1'",
    );

    final result = await perf.recordSetActuals(
      setPerformanceId: setId,
      actualRepetitions: 5,
      actualWeightKg: null,
      now: now,
    );
    expect(result, isA<PerformanceSessionNotActive>());
  });

  test(
    'záporná hodnota je odmítnuta DB constraintem (rollback bez zápisu)',
    () async {
      await seedAndStart();
      await perf.initializePerformances(sessionId: 'ses-1', now: now);
      final setId = await firstSetId();

      await expectLater(
        perf.recordSetActuals(
          setPerformanceId: setId,
          actualRepetitions: -3,
          actualWeightKg: null,
          now: now,
        ),
        throwsA(anything),
      );
      // Nezůstala částečná data — set stále bez actual.
      final tracker = await perf.loadTracker('ses-1');
      expect(tracker!.exercises.first.sets.first.actualRepetitions, isNull);
    },
  );

  test(
    'actual hodnoty a completion přežijí skutečný reopen databáze',
    () async {
      final dir = await Directory.systemTemp.createTemp('r1_04_perf');
      final path = '${dir.path}/perf.sqlite';
      addTearDown(() => dir.delete(recursive: true));

      final firstDb = AppDatabase(NativeDatabase(File(path)));
      await DriftR1SeedRepository(firstDb, now: () => now).applySeed();
      await DriftWorkoutSessionRepository(firstDb).startSession(
        workoutInstanceId: 'demo-w1-instance',
        newSessionId: 'ses-1',
        now: now,
      );
      final firstPerf = DriftWorkoutPerformanceRepository(
        firstDb,
        SequenceIdGenerator(),
      );
      await firstPerf.initializePerformances(sessionId: 'ses-1', now: now);
      final tracker1 = await firstPerf.loadTracker('ses-1');
      final setId = tracker1!.exercises.first.sets.first.setPerformanceId;
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
      await firstDb.close();

      final secondDb = AppDatabase(NativeDatabase(File(path)));
      addTearDown(secondDb.close);
      final secondPerf = DriftWorkoutPerformanceRepository(
        secondDb,
        SequenceIdGenerator(),
      );
      // Reopen znovu inicializuje — nesmí vytvořit duplikáty ani ztratit data.
      await secondPerf.initializePerformances(sessionId: 'ses-1', now: now);
      final tracker2 = await secondPerf.loadTracker('ses-1');
      final set = tracker2!.exercises.first.sets.first;
      expect(set.actualRepetitions, 9);
      expect(set.actualWeightKg, 17.5);
      expect(set.isCompleted, isTrue);

      final count = await secondDb
          .customSelect('SELECT COUNT(*) AS c FROM local_set_performances')
          .getSingle();
      expect(count.data['c'], 6);
    },
  );

  test('session zůstává aktivní po zápisu (R1-04 nedokončuje session)', () async {
    await seedAndStart();
    await perf.initializePerformances(sessionId: 'ses-1', now: now);
    final setId = await firstSetId();
    await perf.recordSetActuals(
      setPerformanceId: setId,
      actualRepetitions: 8,
      actualWeightKg: 16,
      now: now,
    );
    await perf.setSetCompletion(
      setPerformanceId: setId,
      completed: true,
      now: now,
    );

    final session = await db
        .customSelect(
          "SELECT status, completed_at FROM local_workout_sessions WHERE id = 'ses-1'",
        )
        .getSingle();
    expect(session.data['status'], 'ACTIVE');
    expect(session.data['completed_at'], isNull);
    // FK integrita čistá.
    final violations = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty);
  });
}
