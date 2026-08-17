import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../domain/record_performance_result.dart';
import '../domain/session_tracker.dart';
import '../domain/workout_performance_repository.dart';
import 'session_tracker_mappers.dart';

/// Drift implementace performance persistence (fyzický model §10/§11/§15.2).
///
/// Inicializace i zápisy běží v transakci. Planned hodnoty žijí v
/// `local_set_plans` (neměnný snapshot) a nikdy se sem nepřepisují —
/// skutečné hodnoty jsou výhradně v `local_set_performances` (PDR-003).
class DriftWorkoutPerformanceRepository
    implements WorkoutPerformanceRepository {
  DriftWorkoutPerformanceRepository(this._db, this._idGenerator);

  final AppDatabase _db;
  final IdGenerator _idGenerator;

  @override
  Future<void> initializePerformances({
    required String sessionId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final session = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      // Inicializace jen pro existující aktivní/pozastavenou session.
      if (session == null || !_isActive(session.status)) {
        return;
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;

      final sections =
          await (_db.select(_db.localWorkoutSections)
                ..where(
                  (t) => t.workoutInstanceId.equals(session.workoutInstanceId),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      final sectionIds = sections.map((s) => s.id).toList(growable: false);
      if (sectionIds.isEmpty) {
        return;
      }

      final exerciseSteps =
          await (_db.select(_db.localWorkoutSteps)
                ..where(
                  (t) =>
                      t.sectionId.isIn(sectionIds) &
                      t.stepType.equals('EXERCISE'),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();

      for (final step in exerciseSteps) {
        final existing =
            await (_db.select(_db.localStepPerformances)..where(
                  (t) =>
                      t.workoutSessionId.equals(sessionId) &
                      t.workoutStepId.equals(step.id),
                ))
                .getSingleOrNull();
        // Idempotence: existující StepPerformance (i s daty) se nepřepíše.
        if (existing != null) {
          continue;
        }

        final stepPerformanceId = _idGenerator.newId();
        await _db
            .into(_db.localStepPerformances)
            .insert(
              LocalStepPerformancesCompanion.insert(
                id: stepPerformanceId,
                workoutSessionId: sessionId,
                workoutStepId: step.id,
                status: 'NOT_STARTED',
                updatedAt: nowMillis,
                rowVersion: 1,
              ),
            );

        final setPlans =
            await (_db.select(_db.localSetPlans)
                  ..where((t) => t.workoutStepId.equals(step.id))
                  ..orderBy([(t) => OrderingTerm.asc(t.position)]))
                .get();
        for (final plan in setPlans) {
          await _db
              .into(_db.localSetPerformances)
              .insert(
                LocalSetPerformancesCompanion.insert(
                  id: _idGenerator.newId(),
                  stepPerformanceId: stepPerformanceId,
                  setPlanId: Value(plan.id),
                  position: plan.position,
                  status: 'PLANNED',
                  updatedAt: nowMillis,
                  rowVersion: 1,
                ),
              );
        }
      }
    });
  }

  @override
  Future<SessionTracker?> loadTracker(String sessionId) async {
    final session = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
    if (session == null) {
      return null;
    }

    final stepPerformances = await (_db.select(
      _db.localStepPerformances,
    )..where((t) => t.workoutSessionId.equals(sessionId))).get();
    if (stepPerformances.isEmpty) {
      return SessionTracker(sessionId: sessionId, exercises: const []);
    }

    final stepIds = stepPerformances
        .map((s) => s.workoutStepId)
        .toList(growable: false);
    final steps = await (_db.select(
      _db.localWorkoutSteps,
    )..where((t) => t.id.isIn(stepIds))).get();
    final stepById = {for (final s in steps) s.id: s};

    final sectionIds = steps.map((s) => s.sectionId).toSet().toList();
    final sections = await (_db.select(
      _db.localWorkoutSections,
    )..where((t) => t.id.isIn(sectionIds))).get();
    final sectionById = {for (final s in sections) s.id: s};

    final stepPerformanceIds = stepPerformances
        .map((s) => s.id)
        .toList(growable: false);
    final setPerformances =
        await (_db.select(_db.localSetPerformances)
              ..where((t) => t.stepPerformanceId.isIn(stepPerformanceIds))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();

    final setPlanIds = setPerformances
        .map((s) => s.setPlanId)
        .whereType<String>()
        .toList(growable: false);
    final setPlans = setPlanIds.isEmpty
        ? <LocalSetPlanRow>[]
        : await (_db.select(
            _db.localSetPlans,
          )..where((t) => t.id.isIn(setPlanIds))).get();
    final planById = {for (final p in setPlans) p.id: p};

    final setsByStepPerformance = <String, List<LocalSetPerformanceRow>>{};
    for (final row in setPerformances) {
      setsByStepPerformance
          .putIfAbsent(row.stepPerformanceId, () => [])
          .add(row);
    }

    final exercises = <TrackerExercise>[];
    for (final stepPerf in stepPerformances) {
      final step = stepById[stepPerf.workoutStepId];
      if (step == null) {
        continue;
      }
      final section = sectionById[step.sectionId];
      final setRows = setsByStepPerformance[stepPerf.id] ?? const [];
      exercises.add(
        mapTrackerExercise(
          stepPerformance: stepPerf,
          step: step,
          sectionTitle: section?.title ?? '',
          setRows: setRows,
          planById: planById,
        ),
      );
    }

    // Stabilní pořadí: podle section.position, pak step.position.
    exercises.sort((a, b) {
      final stepA = stepById[a.stepId]!;
      final stepB = stepById[b.stepId]!;
      final secA = sectionById[stepA.sectionId]?.position ?? 0;
      final secB = sectionById[stepB.sectionId]?.position ?? 0;
      final bySection = secA.compareTo(secB);
      return bySection != 0
          ? bySection
          : stepA.position.compareTo(stepB.position);
    });

    return SessionTracker(sessionId: sessionId, exercises: exercises);
  }

  @override
  Future<RecordPerformanceResult> recordSetActuals({
    required String setPerformanceId,
    required int? actualRepetitions,
    required double? actualWeightKg,
    required DateTime now,
    int? actualDurationSeconds,
  }) {
    return _db.transaction(() async {
      final context = await _loadSetContext(setPerformanceId);
      if (context == null) {
        return const PerformanceSetNotFound();
      }
      if (!_isActive(context.sessionStatus)) {
        return const PerformanceSessionNotActive();
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.localSetPerformances,
      )..where((t) => t.id.equals(setPerformanceId))).write(
        LocalSetPerformancesCompanion(
          actualRepetitions: Value(actualRepetitions),
          actualWeightKg: Value(actualWeightKg),
          // DURATION skutečnost (C53 GSP-010) — jen když ji volající uvede.
          actualDurationSeconds: actualDurationSeconds == null
              ? const Value.absent()
              : Value(actualDurationSeconds),
          updatedAt: Value(nowMillis),
          rowVersion: Value(context.setRowVersion + 1),
        ),
      );
      await _touchSession(context.sessionId, nowMillis);
      return const PerformanceSaved();
    });
  }

  @override
  Future<RecordPerformanceResult> startSet({
    required String setPerformanceId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final context = await _loadSetContext(setPerformanceId);
      if (context == null) {
        return const PerformanceSetNotFound();
      }
      if (!_isActive(context.sessionStatus)) {
        return const PerformanceSessionNotActive();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      final stepPerf = await (_db.select(
        _db.localStepPerformances,
      )..where((t) => t.id.equals(context.stepPerformanceId))).getSingle();
      // Krok se poprvé rozběhl: IN_PROGRESS + started_at (jen poprvé);
      // dokončený/přeskočený krok se nevrací zpět.
      if (stepPerf.status == 'NOT_STARTED') {
        await (_db.update(
          _db.localStepPerformances,
        )..where((t) => t.id.equals(stepPerf.id))).write(
          LocalStepPerformancesCompanion(
            status: const Value('IN_PROGRESS'),
            startedAt: Value(stepPerf.startedAt ?? nowMillis),
            updatedAt: Value(nowMillis),
            rowVersion: Value(stepPerf.rowVersion + 1),
          ),
        );
      }
      await _touchSession(context.sessionId, nowMillis);
      return const PerformanceSaved();
    });
  }

  @override
  Future<RecordPerformanceResult> skipStep({
    required String stepPerformanceId,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final stepPerf = await (_db.select(
        _db.localStepPerformances,
      )..where((t) => t.id.equals(stepPerformanceId))).getSingleOrNull();
      if (stepPerf == null) {
        return const PerformanceSetNotFound();
      }
      final session = await (_db.select(
        _db.localWorkoutSessions,
      )..where((t) => t.id.equals(stepPerf.workoutSessionId))).getSingle();
      if (!_isActive(session.status)) {
        return const PerformanceSessionNotActive();
      }
      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.localStepPerformances,
      )..where((t) => t.id.equals(stepPerformanceId))).write(
        LocalStepPerformancesCompanion(
          status: const Value('SKIPPED'),
          completedAt: Value(nowMillis),
          updatedAt: Value(nowMillis),
          rowVersion: Value(stepPerf.rowVersion + 1),
        ),
      );
      // Nedokončené sady poctivě SKIPPED (GSP-008); dokončené zůstávají.
      await _db.customStatement(
        "UPDATE local_set_performances SET status = 'SKIPPED', "
        'updated_at = ?, row_version = row_version + 1 '
        "WHERE step_performance_id = ? AND status <> 'COMPLETED'",
        [nowMillis, stepPerformanceId],
      );
      await _touchSession(session.id, nowMillis);
      return const PerformanceSaved();
    });
  }

  @override
  Future<RecordPerformanceResult> setSetCompletion({
    required String setPerformanceId,
    required bool completed,
    required DateTime now,
  }) {
    return _db.transaction(() async {
      final context = await _loadSetContext(setPerformanceId);
      if (context == null) {
        return const PerformanceSetNotFound();
      }
      if (!_isActive(context.sessionStatus)) {
        return const PerformanceSessionNotActive();
      }

      final nowMillis = now.toUtc().millisecondsSinceEpoch;
      await (_db.update(
        _db.localSetPerformances,
      )..where((t) => t.id.equals(setPerformanceId))).write(
        LocalSetPerformancesCompanion(
          status: Value(completed ? 'COMPLETED' : 'PLANNED'),
          completedAt: Value(completed ? nowMillis : null),
          updatedAt: Value(nowMillis),
          rowVersion: Value(context.setRowVersion + 1),
        ),
      );
      await _touchSession(context.sessionId, nowMillis);
      return const PerformanceSaved();
    });
  }

  Future<_SetContext?> _loadSetContext(String setPerformanceId) async {
    final setRow = await (_db.select(
      _db.localSetPerformances,
    )..where((t) => t.id.equals(setPerformanceId))).getSingleOrNull();
    if (setRow == null) {
      return null;
    }
    final stepPerf = await (_db.select(
      _db.localStepPerformances,
    )..where((t) => t.id.equals(setRow.stepPerformanceId))).getSingleOrNull();
    if (stepPerf == null) {
      return null;
    }
    final session = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(stepPerf.workoutSessionId))).getSingleOrNull();
    if (session == null) {
      return null;
    }
    return _SetContext(
      sessionId: session.id,
      sessionStatus: session.status,
      setRowVersion: setRow.rowVersion,
      stepPerformanceId: stepPerf.id,
    );
  }

  Future<void> _touchSession(String sessionId, int nowMillis) async {
    final session = await (_db.select(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(sessionId))).getSingle();
    await (_db.update(
      _db.localWorkoutSessions,
    )..where((t) => t.id.equals(sessionId))).write(
      LocalWorkoutSessionsCompanion(
        updatedAt: Value(nowMillis),
        rowVersion: Value(session.rowVersion + 1),
      ),
    );
    // R2-05: zapsaný výkon mění stav session — dříve synchronizovaná
    // session je znovu DIRTY (state-based push, C10 §5.3).
    await _db.customStatement(
      "UPDATE local_workout_sessions SET sync_state = 'DIRTY' "
      "WHERE id = ? AND sync_state = 'SYNCED'",
      [sessionId],
    );
  }

  bool _isActive(String status) => status == 'ACTIVE' || status == 'PAUSED';
}

class _SetContext {
  const _SetContext({
    required this.sessionId,
    required this.sessionStatus,
    required this.setRowVersion,
    required this.stepPerformanceId,
  });
  final String sessionId;
  final String sessionStatus;
  final int setRowVersion;
  final String stepPerformanceId;
}
