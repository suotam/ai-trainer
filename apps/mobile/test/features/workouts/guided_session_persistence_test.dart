import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_guided_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_completion_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_performance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/guided_session.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/guided_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/record_performance_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// R8-03 persistence průvodce nad skutečnou SQLite (C53 §4/§5, GSP-001/
/// 003/008/009/011): v17 sloupce, fáze s ukotvením, pauza/pokračovat
/// posouvá ukotvení, skip = SKIPPED, startSet = IN_PROGRESS, dokončení
/// finalizuje elapsed a zachová SKIPPED; typované výsledky mimo aktivní
/// session.
void main() {
  final t0 = DateTime.utc(2026, 8, 16, 9);
  late AppDatabase db;
  late DriftWorkoutPerformanceRepository perf;
  late DriftGuidedSessionRepository guided;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    perf = DriftWorkoutPerformanceRepository(db, SequenceIdGenerator());
    guided = DriftGuidedSessionRepository(db);
    await DriftR1SeedRepository(db, now: () => t0).applySeed();
    await DriftWorkoutSessionRepository(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: t0,
    );
    await perf.initializePerformances(sessionId: 'ses-1', now: t0);
  });

  tearDown(() => db.close());

  Future<TrackerExercise> firstExercise() async =>
      (await perf.loadTracker('ses-1'))!.exercises.first;

  test('goToStep + startPhase + clearPhase persistují krok, fázi, ukotvení '
      'a sadu (v17); record je čte zpět', () async {
    final exercise = await firstExercise();
    expect(
      await guided.goToStep(
        sessionId: 'ses-1',
        stepId: exercise.stepId,
        now: t0,
      ),
      isA<GuidedSessionSaved>(),
    );
    var record = (await guided.record('ses-1'))!;
    expect(record.activeStepId, exercise.stepId);
    expect(record.phase, GuidedPhase.idle);

    await guided.startPhase(
      sessionId: 'ses-1',
      phase: GuidedPhase.restAfterSet,
      now: t0.add(const Duration(seconds: 10)),
      setPosition: 0,
    );
    record = (await guided.record('ses-1'))!;
    expect(record.phase, GuidedPhase.restAfterSet);
    expect(record.phaseStartedAt, t0.add(const Duration(seconds: 10)));
    expect(record.activeSetPosition, 0);

    await guided.clearPhase(sessionId: 'ses-1', now: t0);
    record = (await guided.record('ses-1'))!;
    expect(record.phase, GuidedPhase.idle);
    expect(record.phaseStartedAt, isNull);
    expect(record.activeSetPosition, isNull);
    // idle fáze se startPhase odmítne typovaně.
    expect(
      await guided.startPhase(
        sessionId: 'ses-1',
        phase: GuidedPhase.idle,
        now: t0,
      ),
      isA<GuidedSessionNotActive>(),
    );
    expect(
      await guided.goToStep(sessionId: 'nope', stepId: 'x', now: t0),
      isA<GuidedSessionNotFound>(),
    );
  });

  test('pause přičte běžící úsek a zmrazí; resume posune ukotvení fáze o '
      'délku pauzy (GSP-009)', () async {
    await guided.startPhase(
      sessionId: 'ses-1',
      phase: GuidedPhase.setRunning,
      now: t0.add(const Duration(seconds: 100)),
      setPosition: 0,
    );
    final pauseAt = t0.add(const Duration(seconds: 130));
    expect(
      await guided.pause(sessionId: 'ses-1', now: pauseAt),
      isA<GuidedSessionSaved>(),
    );
    var record = (await guided.record('ses-1'))!;
    expect(record.isPaused, isTrue);
    expect(record.pausedAt, pauseAt);
    expect(record.elapsedActiveSeconds, 130);
    expect(record.elapsedActiveAt(pauseAt.add(const Duration(hours: 1))), 130);
    // Dvojí pauza je typovaně odmítnuta.
    expect(
      await guided.pause(sessionId: 'ses-1', now: pauseAt),
      isA<GuidedSessionNotActive>(),
    );

    final resumeAt = pauseAt.add(const Duration(seconds: 50));
    expect(
      await guided.resume(sessionId: 'ses-1', now: resumeAt),
      isA<GuidedSessionSaved>(),
    );
    record = (await guided.record('ses-1'))!;
    expect(record.isPaused, isFalse);
    expect(record.lastResumedAt, resumeAt);
    expect(record.pausedAt, isNull);
    // Ukotvení posunuté o 50 s pauzy: 100 s + 50 s.
    expect(record.phaseStartedAt, t0.add(const Duration(seconds: 150)));
    expect(
      record.elapsedActiveAt(resumeAt.add(const Duration(seconds: 20))),
      150,
    );
  });

  test('startSet → krok IN_PROGRESS + started_at; skipStep → krok i '
      'nedokončené sady SKIPPED, dokončené zůstávají (GSP-008)', () async {
    final exercise = await firstExercise();
    final firstSet = exercise.sets.first;
    expect(
      await perf.startSet(setPerformanceId: firstSet.setPerformanceId, now: t0),
      isA<PerformanceSaved>(),
    );
    var loaded = await firstExercise();
    expect(loaded.status, StepPerformanceStatus.inProgress);

    // Dokončit první sadu, přeskočit zbytek kroku.
    await perf.recordSetActuals(
      setPerformanceId: firstSet.setPerformanceId,
      actualRepetitions: 8,
      actualWeightKg: 16,
      now: t0,
    );
    await perf.setSetCompletion(
      setPerformanceId: firstSet.setPerformanceId,
      completed: true,
      now: t0,
    );
    expect(
      await perf.skipStep(
        stepPerformanceId: exercise.stepPerformanceId,
        now: t0,
      ),
      isA<PerformanceSaved>(),
    );
    loaded = await firstExercise();
    expect(loaded.status, StepPerformanceStatus.skipped);
    expect(loaded.sets[0].status, SetPerformanceStatus.completed);
    expect(loaded.sets[1].status, SetPerformanceStatus.skipped);
    expect(loaded.sets[2].status, SetPerformanceStatus.skipped);
    expect(
      await perf.skipStep(stepPerformanceId: 'missing', now: t0),
      isA<PerformanceSetNotFound>(),
    );
  });

  test('DURATION skutečnost se zapíše (actual_duration_seconds); dokončení '
      'finalizuje elapsed_active_seconds, čistí fázi a zachová SKIPPED '
      '(GSP-010/011)', () async {
    final tracker = (await perf.loadTracker('ses-1'))!;
    final squat = tracker.exercises[0];
    final press = tracker.exercises[1];
    await perf.recordSetActuals(
      setPerformanceId: squat.sets.first.setPerformanceId,
      actualRepetitions: null,
      actualWeightKg: null,
      actualDurationSeconds: 42,
      now: t0,
    );
    final durationRow = await db
        .customSelect(
          'SELECT actual_duration_seconds FROM local_set_performances '
          'WHERE id = ?',
          variables: [Variable.withString(squat.sets.first.setPerformanceId)],
        )
        .getSingle();
    expect(durationRow.data['actual_duration_seconds'], 42);

    await perf.skipStep(stepPerformanceId: press.stepPerformanceId, now: t0);
    await guided.startPhase(
      sessionId: 'ses-1',
      phase: GuidedPhase.restAfterSet,
      now: t0,
      setPosition: 0,
    );
    // Session běží 5 minut od startu (bez pauzy) → dokončení.
    final completion = DriftWorkoutCompletionRepository(
      db,
      SequenceIdGenerator(),
    );
    final result = await completion.completeWorkout(
      sessionId: 'ses-1',
      now: t0.add(const Duration(minutes: 5)),
    );
    expect(result, isA<WorkoutCompleted>());
    final session = await db
        .customSelect(
          'SELECT status, elapsed_active_seconds, player_phase FROM '
          "local_workout_sessions WHERE id = 'ses-1'",
        )
        .getSingle();
    expect(session.data['status'], 'COMPLETED');
    expect(session.data['elapsed_active_seconds'], 300);
    expect(session.data['player_phase'], isNull);
    final summary = await db
        .customSelect(
          'SELECT active_duration_seconds, completed_step_count, '
          'total_step_count FROM local_activity_summaries',
        )
        .getSingle();
    expect(summary.data['active_duration_seconds'], 300);
    expect(summary.data['completed_step_count'], 0);
    expect(summary.data['total_step_count'], 2);
    final skipped = await db
        .customSelect(
          'SELECT status FROM local_step_performances WHERE id = ?',
          variables: [Variable.withString(press.stepPerformanceId)],
        )
        .getSingle();
    expect(skipped.data['status'], 'SKIPPED');
    // Po dokončení jsou operace průvodce typovaně odmítnuty.
    expect(
      await guided.pause(sessionId: 'ses-1', now: t0),
      isA<GuidedSessionNotActive>(),
    );
  });
}
