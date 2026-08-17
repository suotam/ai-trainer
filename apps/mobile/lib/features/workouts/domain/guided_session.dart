/// Průvodce aktivní session (C53 §3): odvozený stavový model nad detailem
/// instance, trackerem výkonů a session značkami. Čistá funkce
/// [buildGuidedState] — žádný doménový stav v UI (GSP-002/005).
library;

import 'session_tracker.dart';
import 'workout_read_model.dart';
import 'workout_session.dart';

/// Fáze průvodce (C53 §3/§4). NULL v DB = [idle].
enum GuidedPhase {
  idle(null),
  setRunning('SET_RUNNING'),
  restAfterSet('REST_AFTER_SET'),
  restStep('REST_STEP'),
  done(null);

  const GuidedPhase(this.code);
  final String? code;

  static GuidedPhase fromCode(String? code) => switch (code) {
    'SET_RUNNING' => GuidedPhase.setRunning,
    'REST_AFTER_SET' => GuidedPhase.restAfterSet,
    'REST_STEP' => GuidedPhase.restStep,
    _ => GuidedPhase.idle,
  };
}

/// Persistované značky session pro průvodce (v17 + existující sloupce).
class GuidedSessionRecord {
  const GuidedSessionRecord({
    required this.sessionId,
    required this.workoutInstanceId,
    required this.status,
    required this.startedAt,
    required this.elapsedActiveSeconds,
    this.lastResumedAt,
    this.pausedAt,
    this.activeStepId,
    this.phase = GuidedPhase.idle,
    this.phaseStartedAt,
    this.activeSetPosition,
  });

  final String sessionId;
  final String workoutInstanceId;
  final WorkoutSessionStatus status;
  final DateTime startedAt;
  final int elapsedActiveSeconds;
  final DateTime? lastResumedAt;
  final DateTime? pausedAt;
  final String? activeStepId;
  final GuidedPhase phase;
  final DateTime? phaseStartedAt;
  final int? activeSetPosition;

  bool get isPaused => status == WorkoutSessionStatus.paused;

  /// Uplynulý aktivní čas (GSP-005): uložený + běžící úsek, je-li ACTIVE.
  int elapsedActiveAt(DateTime now) {
    if (status != WorkoutSessionStatus.active || lastResumedAt == null) {
      return elapsedActiveSeconds;
    }
    final running = now.difference(lastResumedAt!).inSeconds;
    return elapsedActiveSeconds + (running < 0 ? 0 : running);
  }
}

/// Sada v průvodci: plán vedle skutečnosti (z trackeru).
class GuidedSet {
  const GuidedSet({
    required this.position,
    this.setPerformanceId,
    this.plannedRepetitions,
    this.plannedDurationSeconds,
    this.plannedWeightKg,
    this.restAfterSeconds,
    this.status = SetPerformanceStatus.planned,
    this.actualRepetitions,
    this.actualWeightKg,
  });

  final int position;
  final String? setPerformanceId;
  final int? plannedRepetitions;
  final int? plannedDurationSeconds;
  final double? plannedWeightKg;
  final int? restAfterSeconds;
  final SetPerformanceStatus status;
  final int? actualRepetitions;
  final double? actualWeightKg;

  bool get isCompleted => status == SetPerformanceStatus.completed;
  bool get isSkipped => status == SetPerformanceStatus.skipped;
  bool get isDone => isCompleted || isSkipped;
}

/// Krok průvodce: plochý přes sekce, s katalogovou vazbou a výkony.
class GuidedStep {
  const GuidedStep({
    required this.stepId,
    required this.index,
    required this.sectionTitle,
    required this.sectionType,
    required this.stepType,
    required this.title,
    required this.prescriptionType,
    required this.sets,
    this.stepPerformanceId,
    this.exerciseCode,
    this.instructions,
    this.purpose,
    this.plannedDurationSeconds,
    this.performanceStatus,
  });

  final String stepId;
  final int index;
  final String sectionTitle;
  final WorkoutSectionType sectionType;
  final WorkoutStepType stepType;
  final String title;
  final StepPrescriptionType prescriptionType;
  final List<GuidedSet> sets;
  final String? stepPerformanceId;
  final String? exerciseCode;
  final String? instructions;
  final String? purpose;
  final int? plannedDurationSeconds;
  final StepPerformanceStatus? performanceStatus;

  bool get isRest => stepType == WorkoutStepType.rest;

  /// Krok se sleduje výkonově (má performance řádky) — jen EXERCISE.
  bool get isTracked => stepPerformanceId != null;
  bool get isSkipped => performanceStatus == StepPerformanceStatus.skipped;
  bool get isCompleted =>
      isSkipped ||
      (isTracked && sets.isNotEmpty && sets.every((s) => s.isDone));
  int get completedSetCount => sets.where((s) => s.isCompleted).length;
}

/// Odvozený stav průvodce (C53 §3).
class GuidedSessionState {
  const GuidedSessionState({
    required this.steps,
    required this.currentStepIndex,
    required this.currentSetIndex,
    required this.phase,
    required this.remainingSeconds,
    required this.elapsedActiveSeconds,
    required this.isPaused,
  });

  final List<GuidedStep> steps;
  final int currentStepIndex;

  /// Index první nedokončené sady aktuálního kroku; `null` bez sad/hotovo.
  final int? currentSetIndex;
  final GuidedPhase phase;

  /// Zbytek běžící fáze v sekundách (nikdy záporný); 0 = doběhlo.
  final int remainingSeconds;
  final int elapsedActiveSeconds;
  final bool isPaused;

  GuidedStep? get currentStep => steps.isEmpty ? null : steps[currentStepIndex];
  GuidedSet? get currentSet {
    final step = currentStep;
    final index = currentSetIndex;
    return step == null || index == null ? null : step.sets[index];
  }

  bool get hasPrevious => currentStepIndex > 0;
  bool get hasNext => currentStepIndex < steps.length - 1;
  bool get isDone => phase == GuidedPhase.done;

  int get totalSets =>
      steps.fold(0, (sum, s) => sum + (s.isTracked ? s.sets.length : 0));
  int get completedSets => steps.fold(0, (sum, s) => sum + s.completedSetCount);
  int get totalTrackedSteps => steps.where((s) => s.isTracked).length;
  int get completedTrackedSteps =>
      steps.where((s) => s.isTracked && s.isCompleted).length;
}

/// Čistá funkce (GSP-002): žádná mutace, deterministická pro dané vstupy.
GuidedSessionState buildGuidedState({
  required WorkoutInstanceDetail detail,
  required SessionTracker tracker,
  required GuidedSessionRecord session,
  required DateTime now,
}) {
  final perfByStepId = {for (final e in tracker.exercises) e.stepId: e};
  final steps = <GuidedStep>[];
  for (final section in detail.sections) {
    for (final step in section.steps) {
      final perf = perfByStepId[step.id];
      final sets = <GuidedSet>[];
      if (perf != null) {
        final plansByPosition = {for (final p in step.setPlans) p.position: p};
        for (final tracked in perf.sets) {
          final plan = plansByPosition[tracked.position];
          sets.add(
            GuidedSet(
              position: tracked.position,
              setPerformanceId: tracked.setPerformanceId,
              plannedRepetitions: plan?.plannedRepetitions,
              plannedDurationSeconds: plan?.plannedDurationSeconds,
              plannedWeightKg: plan?.plannedWeightKg,
              restAfterSeconds: plan?.restAfterSeconds,
              status: tracked.status,
              actualRepetitions: tracked.actualRepetitions,
              actualWeightKg: tracked.actualWeightKg,
            ),
          );
        }
      } else {
        for (final plan in step.setPlans) {
          sets.add(
            GuidedSet(
              position: plan.position,
              plannedRepetitions: plan.plannedRepetitions,
              plannedDurationSeconds: plan.plannedDurationSeconds,
              plannedWeightKg: plan.plannedWeightKg,
              restAfterSeconds: plan.restAfterSeconds,
            ),
          );
        }
      }
      steps.add(
        GuidedStep(
          stepId: step.id,
          index: steps.length,
          sectionTitle: section.title,
          sectionType: section.sectionType,
          stepType: step.stepType,
          title: step.title,
          prescriptionType: step.prescriptionType,
          sets: sets,
          stepPerformanceId: perf?.stepPerformanceId,
          exerciseCode: step.exerciseCode,
          instructions: step.instructions,
          purpose: step.purpose,
          plannedDurationSeconds: step.plannedDurationSeconds,
          performanceStatus: perf?.status,
        ),
      );
    }
  }

  // Pozice: active_step_id, jinak první nedokončený sledovaný krok, jinak 0.
  var currentIndex = steps.indexWhere((s) => s.stepId == session.activeStepId);
  if (currentIndex < 0) {
    currentIndex = steps.indexWhere((s) => s.isTracked && !s.isCompleted);
  }
  if (currentIndex < 0) {
    currentIndex = 0;
  }
  final current = steps.isEmpty ? null : steps[currentIndex];
  int? setIndex;
  if (current != null && current.sets.isNotEmpty) {
    final firstOpen = current.sets.indexWhere((s) => !s.isDone);
    setIndex = firstOpen < 0 ? null : firstOpen;
    // Běžící fáze se váže k uložené sadě (v17), pokud existuje.
    if (session.phase != GuidedPhase.idle &&
        session.activeSetPosition != null) {
      final bound = current.sets.indexWhere(
        (s) => s.position == session.activeSetPosition,
      );
      if (bound >= 0 && session.phase == GuidedPhase.setRunning) {
        setIndex = bound;
      }
    }
  }

  final allDone =
      steps.isNotEmpty &&
      steps.where((s) => s.isTracked).isNotEmpty &&
      steps.where((s) => s.isTracked).every((s) => s.isCompleted);

  var phase = session.phase;
  var remaining = 0;
  if (phase != GuidedPhase.idle && session.phaseStartedAt != null) {
    final planned = switch (phase) {
      GuidedPhase.setRunning =>
        (setIndex == null ? null : current?.sets[setIndex])
                ?.plannedDurationSeconds ??
            0,
      GuidedPhase.restAfterSet => _restForPosition(
        current,
        session.activeSetPosition,
      ),
      GuidedPhase.restStep => current?.plannedDurationSeconds ?? 0,
      _ => 0,
    };
    // Pauza zmrazí odpočet: měří se do paused_at (GSP-009).
    final until = session.isPaused && session.pausedAt != null
        ? session.pausedAt!
        : now;
    final elapsed = until.difference(session.phaseStartedAt!).inSeconds;
    remaining = planned - (elapsed < 0 ? 0 : elapsed);
    if (remaining < 0) {
      remaining = 0;
    }
  } else if (allDone) {
    phase = GuidedPhase.done;
  } else {
    phase = GuidedPhase.idle;
  }

  return GuidedSessionState(
    steps: steps,
    currentStepIndex: currentIndex,
    currentSetIndex: setIndex,
    phase: phase,
    remainingSeconds: remaining,
    elapsedActiveSeconds: session.elapsedActiveAt(now),
    isPaused: session.isPaused,
  );
}

int _restForPosition(GuidedStep? step, int? position) {
  if (step == null || position == null) {
    return 0;
  }
  for (final set in step.sets) {
    if (set.position == position) {
      return set.restAfterSeconds ?? 0;
    }
  }
  return 0;
}
