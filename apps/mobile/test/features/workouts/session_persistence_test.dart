import 'dart:io';

import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Session persistence nad skutečnou SQLite (QTR-004, fyzický model §15.1).
void main() {
  final now = DateTime.utc(2026, 7, 20, 8);

  late AppDatabase db;
  late DriftWorkoutSessionRepository sessions;

  Future<void> seed() => DriftR1SeedRepository(db, now: () => now).applySeed();

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    sessions = DriftWorkoutSessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'start vytvoří session transakčně a nastaví instance IN_PROGRESS',
    () async {
      await seed();

      final result = await sessions.startSession(
        workoutInstanceId: 'demo-w1-instance',
        newSessionId: 'ses-1',
        now: now,
      );

      expect(result, isA<SessionCreated>());
      expect((result as SessionCreated).sessionId, 'ses-1');

      final sessionRow = await (db.select(
        db.localWorkoutSessions,
      )..where((t) => t.id.equals('ses-1'))).getSingle();
      expect(sessionRow.status, 'ACTIVE');
      expect(sessionRow.workoutInstanceId, 'demo-w1-instance');
      expect(sessionRow.startedAt, now.millisecondsSinceEpoch);
      expect(sessionRow.instanceRevisionNumber, 1);

      final instanceRow = await (db.select(
        db.localWorkoutInstances,
      )..where((t) => t.id.equals('demo-w1-instance'))).getSingle();
      expect(instanceRow.status, 'IN_PROGRESS');
      expect(instanceRow.startedSessionId, 'ses-1');

      final pointer =
          await (db.select(db.localAppState)..where(
                (t) => t.key.equals(
                  DriftWorkoutSessionRepository.activeSessionKey,
                ),
              ))
              .getSingle();
      expect(pointer.value, 'ses-1');
    },
  );

  test('opakovaný start stejného workoutu vrátí existující session', () async {
    await seed();
    await sessions.startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );

    final result = await sessions.startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-2',
      now: now,
    );

    expect(result, isA<SessionResumedExisting>());
    expect((result as SessionResumedExisting).sessionId, 'ses-1');
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
        .getSingle();
    expect(count.data['c'], 1);
  });

  test('start jiného workoutu při aktivní session vrátí conflict', () async {
    await seed();
    await sessions.startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );

    final result = await sessions.startSession(
      workoutInstanceId: 'demo-w2-instance',
      newSessionId: 'ses-2',
      now: now,
    );

    expect(result, isA<ConflictWithAnotherSession>());
    final conflict = result as ConflictWithAnotherSession;
    expect(conflict.activeSessionId, 'ses-1');
    expect(conflict.activeWorkoutInstanceId, 'demo-w1-instance');
    final count = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
        .getSingle();
    expect(count.data['c'], 1);
  });

  test('neexistující workout vrátí workout-not-found', () async {
    await seed();
    final result = await sessions.startSession(
      workoutInstanceId: 'missing',
      newSessionId: 'ses-x',
      now: now,
    );
    expect(result, isA<WorkoutNotFound>());
  });

  test(
    'aktivní session se načte po skutečném reopen databáze (recovery)',
    () async {
      // Soubor umožní zavřít a znovu otevřít stejnou databázi = restart.
      final dir = await Directory.systemTemp.createTemp('r1_03_session');
      final path = '${dir.path}/session.sqlite';
      addTearDown(() => dir.delete(recursive: true));

      final firstDb = AppDatabase(NativeDatabase(File(path)));
      await DriftR1SeedRepository(firstDb, now: () => now).applySeed();
      await DriftWorkoutSessionRepository(firstDb).startSession(
        workoutInstanceId: 'demo-w1-instance',
        newSessionId: 'ses-recover',
        now: now,
      );
      await firstDb.close();

      final secondDb = AppDatabase(NativeDatabase(File(path)));
      addTearDown(secondDb.close);
      final active = await DriftWorkoutSessionRepository(
        secondDb,
      ).findActiveSession();

      expect(active, isNotNull);
      expect(active!.id, 'ses-recover');
      expect(active.status, WorkoutSessionStatus.active);
      expect(active.startedAt, now);

      // Nevznikla druhá session.
      final count = await secondDb
          .customSelect('SELECT COUNT(*) AS c FROM local_workout_sessions')
          .getSingle();
      expect(count.data['c'], 1);
    },
  );

  test(
    'partial unique index blokuje druhou aktivní session pro instanci',
    () async {
      await seed();
      Future<void> insertActive(String id) => db
          .into(db.localWorkoutSessions)
          .insert(
            LocalWorkoutSessionsCompanion.insert(
              id: id,
              workoutInstanceId: 'demo-w1-instance',
              instanceRevisionNumber: 1,
              status: 'ACTIVE',
              startedAt: 0,
              elapsedActiveSeconds: 0,
              createdAt: 0,
              updatedAt: 0,
              rowVersion: 1,
            ),
          );
      await insertActive('a1');
      await expectLater(insertActive('a2'), throwsA(isA<SqliteException>()));
    },
  );

  test('seed a R1-01 data zůstanou po startu zachované', () async {
    await seed();
    await sessions.startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );
    final instances = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_instances')
        .getSingle();
    expect(instances.data['c'], 3);
    final violations = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty);
  });
}
