import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration testy schématu nad skutečnou SQLite (test-strategy §7.1,
/// evidence gate R1-01): databáze od prázdného stavu, aktivní foreign keys
/// a unique constraints.
void main() {
  late AppDatabase db;

  Future<void> insertInstance(
    String id, {
    String date = '2026-07-20',
    String status = 'READY',
  }) => db
      .into(db.localWorkoutInstances)
      .insert(
        LocalWorkoutInstancesCompanion.insert(
          id: id,
          title: 'T',
          workoutType: 'STRENGTH',
          scheduledLocalDate: date,
          status: status,
          sourceType: 'DEMO',
          revisionNumber: 1,
          createdAt: 0,
          updatedAt: 0,
          rowVersion: 1,
        ),
      );

  Future<void> insertSection(String id, String instanceId, int position) => db
      .into(db.localWorkoutSections)
      .insert(
        LocalWorkoutSectionsCompanion.insert(
          id: id,
          workoutInstanceId: instanceId,
          position: position,
          title: 'S',
          sectionType: 'MAIN',
          priority: 'REQUIRED',
          isOptional: false,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

  Future<void> insertSession(
    String id,
    String instanceId, {
    String status = 'ACTIVE',
  }) => db
      .into(db.localWorkoutSessions)
      .insert(
        LocalWorkoutSessionsCompanion.insert(
          id: id,
          workoutInstanceId: instanceId,
          instanceRevisionNumber: 1,
          status: status,
          startedAt: 0,
          elapsedActiveSeconds: 0,
          createdAt: 0,
          updatedAt: 0,
          rowVersion: 1,
          completedAt: status == 'COMPLETED'
              ? const Value(1)
              : const Value.absent(),
        ),
      );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('databaze vznikne od prazdneho stavu se schema verzi 2', () async {
    // R2-01 zvýšil schema na verzi 2 (owner/sync metadata + outbox).
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.first, 2);

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name LIKE 'local_%' ORDER BY name",
        )
        .get();
    expect(tables.map((r) => r.data['name']), [
      'local_activity_summaries',
      'local_app_state',
      'local_outbox',
      'local_set_performances',
      'local_set_plans',
      'local_step_performances',
      'local_workout_feedback',
      'local_workout_instances',
      'local_workout_sections',
      'local_workout_sessions',
      'local_workout_steps',
    ]);
  });

  test('foreign keys jsou aktivni - sekce bez instance se odmitne', () async {
    await expectLater(
      insertSection('s1', 'missing-instance', 0),
      throwsA(isA<SqliteException>()),
    );
  });

  test('cascade delete instance odstrani strukturu snapshotu', () async {
    await insertInstance('wi1');
    await insertSection('s1', 'wi1', 0);

    await (db.delete(
      db.localWorkoutInstances,
    )..where((t) => t.id.equals('wi1'))).go();

    final sections = await db.select(db.localWorkoutSections).get();
    expect(sections, isEmpty);
  });

  test('unikatni pozice sekci v ramci instance', () async {
    await insertInstance('wi1');
    await insertSection('s1', 'wi1', 0);

    await expectLater(
      insertSection('s2', 'wi1', 0),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'unikatni pozice kroku plati i pro NULL parent (expression index)',
    () async {
      await insertInstance('wi1');
      await insertSection('s1', 'wi1', 0);
      Future<void> step(String id, int position) => db
          .into(db.localWorkoutSteps)
          .insert(
            LocalWorkoutStepsCompanion.insert(
              id: id,
              sectionId: 's1',
              position: position,
              stepType: 'EXERCISE',
              title: 'Step',
              priority: 'REQUIRED',
              isSkippable: false,
              prescriptionType: 'SET_REP',
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      await step('st1', 0);
      await expectLater(step('st2', 0), throwsA(isA<SqliteException>()));
    },
  );

  test(
    'CHECK constraints: zaporne hodnoty a RPE mimo rozsah se odmitnou',
    () async {
      await insertInstance('wi1');
      await insertSection('s1', 'wi1', 0);
      await db
          .into(db.localWorkoutSteps)
          .insert(
            LocalWorkoutStepsCompanion.insert(
              id: 'st1',
              sectionId: 's1',
              position: 0,
              stepType: 'EXERCISE',
              title: 'Step',
              priority: 'REQUIRED',
              isSkippable: false,
              prescriptionType: 'SET_REP',
              createdAt: 0,
              updatedAt: 0,
            ),
          );

      Future<void> setPlan({double? rpe, int? minReps, int? maxReps}) => db
          .into(db.localSetPlans)
          .insert(
            LocalSetPlansCompanion.insert(
              id: 'sp-invalid',
              workoutStepId: 'st1',
              position: 0,
              targetRpe: Value(rpe),
              minimumRepetitions: Value(minReps),
              maximumRepetitions: Value(maxReps),
            ),
          );

      await expectLater(setPlan(rpe: 11), throwsA(isA<SqliteException>()));
      await expectLater(
        setPlan(minReps: 10, maxReps: 5),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        insertInstance('wi-bad-date', date: '20.7.2026'),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('nejvyse jedna ACTIVE nebo PAUSED session na instanci', () async {
    await insertInstance('wi1');
    await insertSession('ses1', 'wi1', status: 'ACTIVE');

    await expectLater(
      insertSession('ses2', 'wi1', status: 'PAUSED'),
      throwsA(isA<SqliteException>()),
    );

    // Dokončená session naopak další aktivní nesmí blokovat.
    await (db.update(
      db.localWorkoutSessions,
    )..where((t) => t.id.equals('ses1'))).write(
      const LocalWorkoutSessionsCompanion(
        status: Value('COMPLETED'),
        completedAt: Value(1),
      ),
    );
    await insertSession('ses3', 'wi1', status: 'ACTIVE');
  });

  test('session COMPLETED bez completed_at se odmitne', () async {
    await insertInstance('wi1');
    await expectLater(
      db
          .into(db.localWorkoutSessions)
          .insert(
            LocalWorkoutSessionsCompanion.insert(
              id: 'ses1',
              workoutInstanceId: 'wi1',
              instanceRevisionNumber: 1,
              status: 'COMPLETED',
              startedAt: 0,
              elapsedActiveSeconds: 0,
              createdAt: 0,
              updatedAt: 0,
              rowVersion: 1,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test(
    'smazani instance s existujici session je blokovano (RESTRICT)',
    () async {
      await insertInstance('wi1');
      await insertSession('ses1', 'wi1');

      await expectLater(
        (db.delete(
          db.localWorkoutInstances,
        )..where((t) => t.id.equals('wi1'))).go(),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('foreign key check nad celou databazi je cisty', () async {
    await insertInstance('wi1');
    await insertSection('s1', 'wi1', 0);

    final violations = await db.customSelect('PRAGMA foreign_key_check').get();
    expect(violations, isEmpty);
  });
}
