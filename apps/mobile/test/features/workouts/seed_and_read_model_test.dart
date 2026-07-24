import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_instance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Seed a read model nad skutečnou SQLite (evidence gate R1-01): seed je
/// idempotentní, snapshot lze načíst bez sítě, mapper odmítá neznámé kódy.
void main() {
  final fixedNow = DateTime(2026, 7, 20, 8, 0);

  late AppDatabase db;
  late DriftR1SeedRepository seed;
  late DriftWorkoutInstanceRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seed = DriftR1SeedRepository(db, now: () => fixedNow);
    repository = DriftWorkoutInstanceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('seed vytvori demo data a je idempotentni', () async {
    expect(await seed.applySeed(), SeedResult.applied);
    final countAfterFirst = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_instances')
        .getSingle();
    expect(countAfterFirst.data['c'], 3);

    expect(await seed.applySeed(), SeedResult.alreadyApplied);
    final countAfterSecond = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_instances')
        .getSingle();
    expect(countAfterSecond.data['c'], 3);

    final versionRow =
        await (db.select(
              db.localAppState,
            )..where((t) => t.key.equals(DriftR1SeedRepository.seedVersionKey)))
            .getSingle();
    expect(versionRow.value, '1');
  });

  test(
    'seed je deterministicky pri fixnim case (stabilni ID a data)',
    () async {
      await seed.applySeed();

      final summaries = await repository.workoutsForLocalDateRange(
        '2026-07-20',
        '2026-07-26',
      );
      expect(summaries.map((s) => s.id), [
        'demo-w1-instance',
        'demo-w2-instance',
        'demo-w3-instance',
      ]);
      expect(summaries.map((s) => s.scheduledLocalDate), [
        '2026-07-20',
        '2026-07-22',
        '2026-07-25',
      ]);
      expect(
        summaries.every((s) => s.status == WorkoutInstanceStatus.ready),
        isTrue,
      );
    },
  );

  test('seed neprepise uzivatelsky zmenenou instanci', () async {
    await seed.applySeed();
    await (db.update(
      db.localWorkoutInstances,
    )..where((t) => t.id.equals('demo-w1-instance'))).write(
      const LocalWorkoutInstancesCompanion(
        title: Value('Muj upraveny workout'),
        rowVersion: Value(2),
      ),
    );
    // Vynucene znovuspusteni seedu (smazani verze simuluje budouci upgrade).
    await (db.delete(db.localAppState)).go();

    await seed.applySeed();

    final row = await (db.select(
      db.localWorkoutInstances,
    )..where((t) => t.id.equals('demo-w1-instance'))).getSingle();
    expect(row.title, 'Muj upraveny workout');
    expect(row.rowVersion, 2);
  });

  test('dnesni dotaz vrati dnesni workout', () async {
    await seed.applySeed();

    final today = await repository.workoutsForLocalDate('2026-07-20');

    expect(today, hasLength(1));
    expect(today.single.id, 'demo-w1-instance');
    expect(today.single.title, 'Full Body Strength (Demo)');
  });

  test('cely snapshot instance lze nacist bez site', () async {
    await seed.applySeed();

    final detail = await repository.workoutInstanceById('demo-w1-instance');

    expect(detail, isNotNull);
    expect(detail!.revisionNumber, 1);
    expect(detail.sections.map((s) => s.sectionType), [
      WorkoutSectionType.warmUp,
      WorkoutSectionType.main,
      WorkoutSectionType.cooldown,
    ]);

    final main = detail.sections[1];
    expect(main.steps, hasLength(2));
    final squat = main.steps.first;
    expect(squat.stepType, WorkoutStepType.exercise);
    expect(squat.prescriptionType, StepPrescriptionType.setRep);
    expect(squat.setPlans, hasLength(3));
    expect(squat.setPlans.map((p) => p.position), [0, 1, 2]);
    expect(squat.setPlans.first.plannedRepetitions, 8);
    expect(squat.setPlans.first.plannedWeightKg, 16);

    final warmup = detail.sections.first.steps.single;
    expect(warmup.stepType, WorkoutStepType.duration);
    expect(warmup.plannedDurationSeconds, 120);
  });

  test('neexistujici instance vraci null', () async {
    await seed.applySeed();
    expect(await repository.workoutInstanceById('missing'), isNull);
  });

  test('mapper odmitne neznamy enum kod misto ticheho defaultu', () async {
    await seed.applySeed();
    // Poskozeni dat mimo aplikacni cestu: neznamy status.
    await db.customStatement(
      "UPDATE local_workout_instances SET status = 'MYSTERY' "
      "WHERE id = 'demo-w1-instance'",
    );

    await expectLater(
      repository.workoutsForLocalDate('2026-07-20'),
      throwsA(isA<UnsupportedPersistedValue>()),
    );
  });
}
