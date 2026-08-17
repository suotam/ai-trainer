import 'dart:async';

import 'package:ai_trainer_mobile/core/ids/id_generator.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/r1_seed_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/start_session_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_instance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/complete_workout_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/record_performance_result.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_feedback.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_completion_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_history.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_history_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_performance_repository.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_session.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_session_repository.dart';

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

/// Deterministický ID generator pro testy (stabilní `gen-N`).
class SequenceIdGenerator implements IdGenerator {
  int _n = 0;
  @override
  String newId() => 'gen-${_n++}';
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

/// Fake session repository řízený skriptem výsledků startu a stavem aktivní
/// session — bez Drift a bez sítě.
class FakeWorkoutSessionRepository implements WorkoutSessionRepository {
  FakeWorkoutSessionRepository({
    List<Object>? startScript,
    this.activeSession,
    this.throwOnStart = false,
    Map<String, WorkoutSessionSnapshot>? sessionsById,
    List<WorkoutSessionSnapshot>? activeSessions,
    this.activePointer,
    this.existingInstanceIds,
    this.throwOnFindActiveSessions = false,
    this.rejectPointerRepair = false,
  }) : _startScript = startScript ?? const [],
       _sessionsById = sessionsById ?? const {},
       _explicitActiveSessions = activeSessions;

  /// Prvky jsou [StartSessionResult] pro postupné starty.
  final List<Object> _startScript;
  final Map<String, WorkoutSessionSnapshot> _sessionsById;
  final List<WorkoutSessionSnapshot>? _explicitActiveSessions;
  WorkoutSessionSnapshot? activeSession;
  bool throwOnStart;

  /// Technický active-session pointer (recovery testy).
  String? activePointer;

  /// Když je `null`, existují všechny instance; jinak jen tyto ID.
  Set<String>? existingInstanceIds;

  bool throwOnFindActiveSessions;

  /// Vynutí odmítnutí transakční opravy pointeru (revalidace uvnitř
  /// transakce neprošla) — pointer se nezmění a metoda vrátí `false`.
  bool rejectPointerRepair;

  int startCallCount = 0;
  int reconcileCallCount = 0;
  int pointerReadCount = 0;

  @override
  Future<StartSessionResult> startSession({
    required String workoutInstanceId,
    required String newSessionId,
    required DateTime now,
  }) async {
    if (throwOnStart) {
      throw StateError('internal persistence failure');
    }
    final result = _startScript.isEmpty
        ? SessionCreated(newSessionId)
        : _startScript[startCallCount.clamp(0, _startScript.length - 1)]
              as StartSessionResult;
    startCallCount += 1;
    return result;
  }

  @override
  Future<WorkoutSessionSnapshot?> findActiveSession() async {
    final all = _activeSessionsList();
    return all.isEmpty ? null : all.first;
  }

  @override
  Future<WorkoutSessionSnapshot?> sessionById(String id) async =>
      _sessionsById[id];

  List<WorkoutSessionSnapshot> _activeSessionsList() {
    if (_explicitActiveSessions != null) {
      return _explicitActiveSessions;
    }
    return activeSession == null ? const [] : [activeSession!];
  }

  @override
  Future<List<WorkoutSessionSnapshot>> findActiveSessions() async {
    if (throwOnFindActiveSessions) {
      throw StateError('internal persistence failure');
    }
    return _activeSessionsList();
  }

  @override
  Future<String?> readActiveSessionPointer() async {
    pointerReadCount += 1;
    return activePointer;
  }

  @override
  Future<bool> reconcileActiveSessionPointer({
    required String sessionId,
    required DateTime now,
  }) async {
    reconcileCallCount += 1;
    final all = _activeSessionsList();
    if (rejectPointerRepair || all.length != 1 || all.first.id != sessionId) {
      return false;
    }
    activePointer = sessionId;
    return true;
  }

  @override
  Future<bool> workoutInstanceExists(String instanceId) async =>
      existingInstanceIds == null || existingInstanceIds!.contains(instanceId);
}

/// Fake performance repository řízený skriptem výsledků a stavem trackeru.
class FakeWorkoutPerformanceRepository implements WorkoutPerformanceRepository {
  FakeWorkoutPerformanceRepository({
    this.tracker,
    List<RecordPerformanceResult>? recordScript,
    List<RecordPerformanceResult>? completeScript,
  }) : _recordScript = recordScript ?? const [],
       _completeScript = completeScript ?? const [];

  SessionTracker? tracker;
  final List<RecordPerformanceResult> _recordScript;
  final List<RecordPerformanceResult> _completeScript;

  int initCallCount = 0;
  int recordCallCount = 0;
  int completeCallCount = 0;

  @override
  Future<void> initializePerformances({
    required String sessionId,
    required DateTime now,
  }) async {
    initCallCount += 1;
  }

  @override
  Future<SessionTracker?> loadTracker(String sessionId) async => tracker;

  int startSetCallCount = 0;
  int skipStepCallCount = 0;

  @override
  Future<RecordPerformanceResult> startSet({
    required String setPerformanceId,
    required DateTime now,
  }) async {
    startSetCallCount += 1;
    return const PerformanceSaved();
  }

  @override
  Future<RecordPerformanceResult> skipStep({
    required String stepPerformanceId,
    required DateTime now,
  }) async {
    skipStepCallCount += 1;
    return const PerformanceSaved();
  }

  @override
  Future<RecordPerformanceResult> recordSetActuals({
    required String setPerformanceId,
    required int? actualRepetitions,
    required double? actualWeightKg,
    required DateTime now,
    int? actualDurationSeconds,
  }) async {
    final result = _recordScript.isEmpty
        ? const PerformanceSaved()
        : _recordScript[recordCallCount.clamp(0, _recordScript.length - 1)];
    recordCallCount += 1;
    return result;
  }

  @override
  Future<RecordPerformanceResult> setSetCompletion({
    required String setPerformanceId,
    required bool completed,
    required DateTime now,
  }) async {
    final result = _completeScript.isEmpty
        ? const PerformanceSaved()
        : _completeScript[completeCallCount.clamp(
            0,
            _completeScript.length - 1,
          )];
    completeCallCount += 1;
    return result;
  }
}

/// Fake completion repository řízený skriptem výsledků — bez Drift/sítě.
class FakeWorkoutCompletionRepository implements WorkoutCompletionRepository {
  FakeWorkoutCompletionRepository({List<CompleteWorkoutResult>? script})
    : _script = script ?? const [];

  final List<CompleteWorkoutResult> _script;

  int completeCallCount = 0;
  DateTime? lastNow;
  String? lastSessionId;
  WorkoutFeedbackInput? lastFeedback;

  @override
  Future<CompleteWorkoutResult> completeWorkout({
    required String sessionId,
    required DateTime now,
    WorkoutFeedbackInput? feedback,
  }) async {
    lastNow = now;
    lastSessionId = sessionId;
    lastFeedback = feedback;
    final result = _script.isEmpty
        ? const WorkoutCompleted('sum-1')
        : _script[completeCallCount.clamp(0, _script.length - 1)];
    completeCallCount += 1;
    return result;
  }
}

/// Fake history repository řízený stavem — bez Drift/sítě.
class FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  FakeWorkoutHistoryRepository({
    List<WorkoutHistoryEntry>? entries,
    this.feedback,
  }) : entries = entries ?? const [];

  List<WorkoutHistoryEntry> entries;
  WorkoutFeedbackSnapshot? feedback;

  @override
  Future<List<WorkoutHistoryEntry>> completedWorkouts() async => entries;

  @override
  Future<WorkoutHistoryEntry?> completedWorkoutBySessionId(
    String sessionId,
  ) async {
    for (final e in entries) {
      if (e.workoutSessionId == sessionId) {
        return e;
      }
    }
    return null;
  }

  @override
  Future<WorkoutFeedbackSnapshot?> feedbackBySessionId(
    String sessionId,
  ) async => feedback;
}

WorkoutHistoryEntry buildHistoryEntry({
  String activitySummaryId = 'sum-1',
  String workoutSessionId = 'ses-1',
  String workoutInstanceId = 'wi1',
  String title = 'Full Body Strength (Demo)',
  String workoutType = 'STRENGTH',
  int completedStepCount = 2,
  int totalStepCount = 2,
}) => WorkoutHistoryEntry(
  activitySummaryId: activitySummaryId,
  workoutSessionId: workoutSessionId,
  workoutInstanceId: workoutInstanceId,
  title: title,
  workoutType: workoutType,
  startedAt: DateTime.utc(2026, 7, 20, 8),
  completedAt: DateTime.utc(2026, 7, 20, 9),
  completedStepCount: completedStepCount,
  totalStepCount: totalStepCount,
);

SessionTracker buildTracker({
  String sessionId = 'ses-1',
  List<TrackerSet>? sets,
}) => SessionTracker(
  sessionId: sessionId,
  exercises: [
    TrackerExercise(
      stepPerformanceId: 'sp-1',
      stepId: 'st-1',
      title: 'Goblet squat',
      sectionTitle: 'Main',
      sets:
          sets ??
          const [
            TrackerSet(
              setPerformanceId: 'setp-1',
              position: 0,
              status: SetPerformanceStatus.planned,
              plannedRepetitions: 8,
              plannedWeightKg: 16,
            ),
          ],
    ),
  ],
);

WorkoutSessionSnapshot buildSessionSnapshot({
  String id = 'ses-1',
  String workoutInstanceId = 'wi1',
  WorkoutSessionStatus status = WorkoutSessionStatus.active,
  DateTime? startedAt,
}) => WorkoutSessionSnapshot(
  id: id,
  workoutInstanceId: workoutInstanceId,
  instanceRevisionNumber: 1,
  status: status,
  startedAt: startedAt ?? DateTime.utc(2026, 7, 20, 8),
);

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

WorkoutInstanceDetail buildDetail({
  String id = 'wi1',
  WorkoutInstanceStatus status = WorkoutInstanceStatus.ready,
}) => WorkoutInstanceDetail(
  id: id,
  title: 'Demo workout',
  workoutType: 'STRENGTH',
  scheduledLocalDate: '2026-07-20',
  status: status,
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
