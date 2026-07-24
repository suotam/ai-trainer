import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/r1_seed_repository.dart';

/// Deterministický verzovaný demo seed (fyzický model §17, PDR-010).
///
/// - verze se eviduje v `local_app_state` pod klíčem [seedVersionKey],
/// - stabilní `demo-` ID, `source_type = 'DEMO'`,
/// - opakované spuštění je no-op,
/// - existující řádky se nikdy nepřepisují (ochrana uživatelských změn),
/// - data neobsahují osobní ani produkční údaje.
///
/// Datumy demo workoutů se odvozují od lokálního data při prvním seedu
/// (dnes, +2 a +5 dní), aby Today flow mělo obsah; s injektovaným časem je
/// výstup plně deterministický.
class DriftR1SeedRepository implements R1SeedRepository {
  DriftR1SeedRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const String seedVersionKey = 'seed_version';
  static const int seedVersion = 1;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<SeedResult> applySeed() {
    return _db.transaction(() async {
      final versionRow = await (_db.select(
        _db.localAppState,
      )..where((t) => t.key.equals(seedVersionKey))).getSingleOrNull();
      final appliedVersion = versionRow == null
          ? 0
          : int.tryParse(versionRow.value) ?? 0;
      if (appliedVersion >= seedVersion) {
        return SeedResult.alreadyApplied;
      }

      final now = _now();
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final today = _localDate(now);

      await _insertDemoStrengthWorkout(
        idPrefix: 'demo-w1',
        title: 'Full Body Strength (Demo)',
        localDate: today,
        nowMillis: nowMillis,
      );
      await _insertDemoStrengthWorkout(
        idPrefix: 'demo-w2',
        title: 'Upper Body Strength (Demo)',
        localDate: _localDate(now.add(const Duration(days: 2))),
        nowMillis: nowMillis,
      );
      await _insertDemoStrengthWorkout(
        idPrefix: 'demo-w3',
        title: 'Lower Body Strength (Demo)',
        localDate: _localDate(now.add(const Duration(days: 5))),
        nowMillis: nowMillis,
      );

      await _db
          .into(_db.localAppState)
          .insertOnConflictUpdate(
            LocalAppStateCompanion.insert(
              key: seedVersionKey,
              value: '$seedVersion',
              updatedAt: nowMillis,
            ),
          );
      return SeedResult.applied;
    });
  }

  static String _localDate(DateTime moment) {
    final local = moment.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Future<void> _insertDemoStrengthWorkout({
    required String idPrefix,
    required String title,
    required String localDate,
    required int nowMillis,
  }) async {
    final existing = await (_db.select(
      _db.localWorkoutInstances,
    )..where((t) => t.id.equals('$idPrefix-instance'))).getSingleOrNull();
    if (existing != null) {
      // Existující instance (včetně uživatelsky změněné) se nepřepisuje.
      return;
    }

    await _db
        .into(_db.localWorkoutInstances)
        .insert(
          LocalWorkoutInstancesCompanion.insert(
            id: '$idPrefix-instance',
            title: title,
            description: const Value(
              'Demo strength workout for the local R1 slice.',
            ),
            workoutType: 'STRENGTH',
            scheduledLocalDate: localDate,
            plannedDurationSeconds: const Value(2700),
            status: 'READY',
            sourceType: 'DEMO',
            sourceReference: Value('seed-v$seedVersion/$idPrefix'),
            revisionNumber: 1,
            createdAt: nowMillis,
            updatedAt: nowMillis,
            rowVersion: 1,
          ),
        );

    Future<void> section({
      required String idSuffix,
      required int position,
      required String sectionTitle,
      required String sectionType,
      required String priority,
      required bool isOptional,
      int? durationSeconds,
    }) => _db
        .into(_db.localWorkoutSections)
        .insert(
          LocalWorkoutSectionsCompanion.insert(
            id: '$idPrefix-$idSuffix',
            workoutInstanceId: '$idPrefix-instance',
            position: position,
            title: sectionTitle,
            sectionType: sectionType,
            priority: priority,
            isOptional: isOptional,
            plannedDurationSeconds: Value(durationSeconds),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
        );

    await section(
      idSuffix: 'warmup',
      position: 0,
      sectionTitle: 'Warm-up',
      sectionType: 'WARM_UP',
      priority: 'HIGH',
      isOptional: false,
      durationSeconds: 300,
    );
    await section(
      idSuffix: 'main',
      position: 1,
      sectionTitle: 'Main strength block',
      sectionType: 'MAIN',
      priority: 'REQUIRED',
      isOptional: false,
      durationSeconds: 1800,
    );
    await section(
      idSuffix: 'cooldown',
      position: 2,
      sectionTitle: 'Cooldown',
      sectionType: 'COOLDOWN',
      priority: 'OPTIONAL',
      isOptional: true,
      durationSeconds: 300,
    );

    await _db
        .into(_db.localWorkoutSteps)
        .insert(
          LocalWorkoutStepsCompanion.insert(
            id: '$idPrefix-warmup-jacks',
            sectionId: '$idPrefix-warmup',
            position: 0,
            stepType: 'DURATION',
            title: 'Jumping jacks',
            instructions: const Value('Easy pace, keep breathing steady.'),
            priority: 'HIGH',
            isSkippable: true,
            prescriptionType: 'DURATION',
            plannedDurationSeconds: const Value(120),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
        );

    Future<void> exerciseStep({
      required String idSuffix,
      required int position,
      required String stepTitle,
      required double weightKg,
    }) async {
      await _db
          .into(_db.localWorkoutSteps)
          .insert(
            LocalWorkoutStepsCompanion.insert(
              id: '$idPrefix-$idSuffix',
              sectionId: '$idPrefix-main',
              position: position,
              stepType: 'EXERCISE',
              title: stepTitle,
              priority: 'REQUIRED',
              isSkippable: false,
              prescriptionType: 'SET_REP',
              createdAt: nowMillis,
              updatedAt: nowMillis,
            ),
          );
      for (var set = 0; set < 3; set++) {
        await _db
            .into(_db.localSetPlans)
            .insert(
              LocalSetPlansCompanion.insert(
                id: '$idPrefix-$idSuffix-set$set',
                workoutStepId: '$idPrefix-$idSuffix',
                position: set,
                plannedRepetitions: const Value(8),
                minimumRepetitions: const Value(6),
                maximumRepetitions: const Value(10),
                plannedWeightKg: Value(weightKg),
                restAfterSeconds: const Value(120),
                targetRpe: const Value(7),
              ),
            );
      }
    }

    await exerciseStep(
      idSuffix: 'squat',
      position: 0,
      stepTitle: 'Goblet squat',
      weightKg: 16,
    );
    await exerciseStep(
      idSuffix: 'press',
      position: 1,
      stepTitle: 'Dumbbell bench press',
      weightKg: 12.5,
    );

    await _db
        .into(_db.localWorkoutSteps)
        .insert(
          LocalWorkoutStepsCompanion.insert(
            id: '$idPrefix-cooldown-stretch',
            sectionId: '$idPrefix-cooldown',
            position: 0,
            stepType: 'MOBILITY_POSITION',
            title: 'Full body stretch',
            priority: 'OPTIONAL',
            isSkippable: true,
            prescriptionType: 'COMPLETION_ONLY',
            plannedDurationSeconds: const Value(300),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
        );
  }
}
