import 'dart:async';

import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_instance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';

/// Skriptovaný seed pro testy bootstrapu: postupně vrací výsledky nebo
/// vyhazuje výjimky. Počítá volání pro ověření idempotence a absence loopu.
class FakeSeedRepository implements R1SeedRepository {
  FakeSeedRepository(this.script);

  /// Prvky jsou [SeedResult] nebo [Object] k vyhození.
  final List<Object> script;
  int callCount = 0;

  @override
  Future<SeedResult> applySeed() async {
    final step = script[callCount.clamp(0, script.length - 1)];
    callCount += 1;
    if (step is SeedResult) {
      return step;
    }
    throw step;
  }
}

/// Seed, který nedokončí, dokud jej test explicitně nedokončí — pro
/// ověření loading stavu.
class HangingSeedRepository implements R1SeedRepository {
  final Completer<SeedResult> _completer = Completer<SeedResult>();

  @override
  Future<SeedResult> applySeed() => _completer.future;

  void complete() => _completer.complete(SeedResult.applied);
}

/// Fake read model repository řízený testem — bez Drift a bez sítě.
class FakeWorkoutInstanceRepository implements WorkoutInstanceRepository {
  FakeWorkoutInstanceRepository({
    this.today = const [],
    this.range = const [],
    this.detailsById = const {},
    this.throwOnToday = false,
  });

  final List<WorkoutInstanceSummary> today;
  final List<WorkoutInstanceSummary> range;
  final Map<String, WorkoutInstanceDetail> detailsById;
  final bool throwOnToday;

  int todayCallCount = 0;

  @override
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDate(
    String localDate,
  ) async {
    todayCallCount += 1;
    if (throwOnToday) {
      throw StateError('internal repository failure');
    }
    return today;
  }

  @override
  Future<List<WorkoutInstanceSummary>> workoutsForLocalDateRange(
    String fromLocalDate,
    String toLocalDate,
  ) async => range;

  @override
  Future<WorkoutInstanceDetail?> workoutInstanceById(String id) async =>
      detailsById[id];
}

WorkoutInstanceSummary buildSummary({
  String id = 'wi1',
  String title = 'Demo workout',
  String workoutType = 'STRENGTH',
  String scheduledLocalDate = '2026-07-20',
  WorkoutInstanceStatus status = WorkoutInstanceStatus.ready,
  int? plannedDurationSeconds = 2700,
}) => WorkoutInstanceSummary(
  id: id,
  title: title,
  workoutType: workoutType,
  scheduledLocalDate: scheduledLocalDate,
  status: status,
  plannedDurationSeconds: plannedDurationSeconds,
);

WorkoutInstanceDetail buildDetail({String id = 'wi1'}) => WorkoutInstanceDetail(
  id: id,
  title: 'Demo workout',
  workoutType: 'STRENGTH',
  scheduledLocalDate: '2026-07-20',
  status: WorkoutInstanceStatus.ready,
  revisionNumber: 1,
  plannedDurationSeconds: 2700,
  sections: [
    WorkoutSection(
      id: '$id-main',
      position: 0,
      title: 'Main',
      sectionType: WorkoutSectionType.main,
      priority: WorkoutPriority.required,
      isOptional: false,
      steps: [
        WorkoutStep(
          id: '$id-squat',
          position: 0,
          stepType: WorkoutStepType.exercise,
          title: 'Goblet squat',
          priority: WorkoutPriority.required,
          isSkippable: false,
          prescriptionType: StepPrescriptionType.setRep,
          setPlans: const [
            WorkoutSetPlan(
              id: 's0',
              position: 0,
              plannedRepetitions: 8,
              plannedWeightKg: 16,
            ),
          ],
          childSteps: const [],
        ),
        WorkoutStep(
          id: '$id-press',
          position: 1,
          stepType: WorkoutStepType.exercise,
          title: 'Bench press',
          priority: WorkoutPriority.required,
          isSkippable: false,
          prescriptionType: StepPrescriptionType.setRep,
          setPlans: const [],
          childSteps: const [],
        ),
      ],
    ),
  ],
);
