import 'package:ai_trainer_mobile/core/database/app_database.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_completion_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/data/drift_workout_session_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_feedback.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_workout_repositories.dart';

/// Feedback po dokončení nad skutečnou SQLite (QTR-009, fyzický model
/// §12/§15.3). Feedback se ukládá v atomické completion transakci, je
/// znovu načitelný a idempotentní; přeskočení nic neuloží.
void main() {
  final now = DateTime.utc(2026, 7, 20, 9);

  DriftWorkoutCompletionRepository completion(AppDatabase db) =>
      DriftWorkoutCompletionRepository(db, SequenceIdGenerator());
  DriftWorkoutHistoryRepository history(AppDatabase db) =>
      DriftWorkoutHistoryRepository(db);

  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seedStart() async {
    await DriftR1SeedRepository(db, now: () => now).applySeed();
    await DriftWorkoutSessionRepository(db).startSession(
      workoutInstanceId: 'demo-w1-instance',
      newSessionId: 'ses-1',
      now: now,
    );
  }

  Future<int> feedbackCount() async {
    final r = await db
        .customSelect('SELECT COUNT(*) AS c FROM local_workout_feedback')
        .getSingle();
    return r.data['c']! as int;
  }

  test(
    'feedback se uloží v completion transakci a je znovu načitelný',
    () async {
      await seedStart();

      final result = await completion(db).completeWorkout(
        sessionId: 'ses-1',
        now: now,
        feedback: const WorkoutFeedbackInput(
          overallEffort: 7,
          feeling: WorkoutFeeling.good,
          painReported: true,
          notes: 'solid session',
        ),
      );
      expect(result, isA<WorkoutCompleted>());

      // Feedback row uložen.
      expect(await feedbackCount(), 1);
      // Snapshot overall_effort v ActivitySummary (§13).
      final summary = await db
          .customSelect('SELECT overall_effort FROM local_activity_summaries')
          .getSingle();
      expect(summary.data['overall_effort'], 7.0);

      // Reload přes history repository.
      final snapshot = await history(db).feedbackBySessionId('ses-1');
      expect(snapshot, isNotNull);
      expect(snapshot!.overallEffort, 7.0);
      expect(snapshot.feeling, WorkoutFeeling.good);
      expect(snapshot.painReported, isTrue);
      expect(snapshot.notes, 'solid session');
    },
  );

  test('přeskočený feedback (null) nic neuloží', () async {
    await seedStart();
    await completion(db).completeWorkout(sessionId: 'ses-1', now: now);

    expect(await feedbackCount(), 0);
    final summary = await db
        .customSelect('SELECT overall_effort FROM local_activity_summaries')
        .getSingle();
    expect(summary.data['overall_effort'], isNull);
    expect(await history(db).feedbackBySessionId('ses-1'), isNull);
  });

  test('prázdný feedback (bez obsahu) se neukládá', () async {
    await seedStart();
    await completion(db).completeWorkout(
      sessionId: 'ses-1',
      now: now,
      feedback: const WorkoutFeedbackInput(),
    );
    expect(await feedbackCount(), 0);
  });

  test('opakované dokončení nevytvoří druhý feedback', () async {
    await seedStart();
    await completion(db).completeWorkout(
      sessionId: 'ses-1',
      now: now,
      feedback: const WorkoutFeedbackInput(overallEffort: 5),
    );
    final second = await completion(db).completeWorkout(
      sessionId: 'ses-1',
      now: DateTime.utc(2026, 7, 20, 11),
      feedback: const WorkoutFeedbackInput(overallEffort: 9),
    );

    expect(second, isA<WorkoutAlreadyCompleted>());
    expect(await feedbackCount(), 1);
    // Původní hodnota nezměněna.
    final snapshot = await history(db).feedbackBySessionId('ses-1');
    expect(snapshot!.overallEffort, 5.0);
  });

  test('jen pain flag se uloží jako feedback', () async {
    await seedStart();
    await completion(db).completeWorkout(
      sessionId: 'ses-1',
      now: now,
      feedback: const WorkoutFeedbackInput(painReported: true),
    );
    final snapshot = await history(db).feedbackBySessionId('ses-1');
    expect(snapshot, isNotNull);
    expect(snapshot!.painReported, isTrue);
    expect(snapshot.overallEffort, isNull);
  });
}
