import 'package:ai_trainer_mobile/features/workouts/domain/guided_session.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/session_tracker.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_read_model.dart';
import 'package:ai_trainer_mobile/features/workouts/domain/workout_session.dart';
import 'package:flutter_test/flutter_test.dart';

/// R8-03 testy čisté funkce průvodce (C53 §3/§6, GSP-002/005/006/007/009):
/// pozice z active_step_id / první nedokončené, fáze a zbytek z ukotvení
/// + now (běží, doběhlo = 0, zmrazeno pauzou), DONE, souhrny, REST a
/// kroky bez výkonů (v1) — deterministicky s pevným časem.
void main() {
  final t0 = DateTime.utc(2026, 8, 16, 10);

  WorkoutStep exercise(
    String id, {
    String? code,
    StepPrescriptionType prescription = StepPrescriptionType.setRep,
    List<WorkoutSetPlan> sets = const [],
  }) => WorkoutStep(
    id: id,
    position: 0,
    stepType: WorkoutStepType.exercise,
    title: id,
    exerciseCode: code,
    priority: WorkoutPriority.required,
    isSkippable: false,
    prescriptionType: prescription,
    setPlans: sets,
    childSteps: const [],
  );

  final detail = WorkoutInstanceDetail(
    id: 'wi',
    title: 'Lezecký den',
    workoutType: 'STRENGTH',
    scheduledLocalDate: '2026-08-16',
    status: WorkoutInstanceStatus.inProgress,
    revisionNumber: 1,
    sections: [
      WorkoutSection(
        id: 'warm',
        position: 0,
        title: 'Warm-up',
        sectionType: WorkoutSectionType.warmUp,
        priority: WorkoutPriority.required,
        isOptional: false,
        steps: [
          exercise(
            'jj',
            code: 'JUMPING_JACKS',
            prescription: StepPrescriptionType.duration,
            sets: const [
              WorkoutSetPlan(
                id: 'jj-0',
                position: 0,
                plannedDurationSeconds: 60,
              ),
            ],
          ),
        ],
      ),
      WorkoutSection(
        id: 'main',
        position: 1,
        title: 'Main',
        sectionType: WorkoutSectionType.main,
        priority: WorkoutPriority.required,
        isOptional: false,
        steps: [
          exercise(
            'pu',
            code: 'PULL_UP',
            sets: const [
              WorkoutSetPlan(
                id: 'pu-0',
                position: 0,
                plannedRepetitions: 5,
                restAfterSeconds: 90,
              ),
              WorkoutSetPlan(
                id: 'pu-1',
                position: 1,
                plannedRepetitions: 5,
                restAfterSeconds: 90,
              ),
            ],
          ),
          const WorkoutStep(
            id: 'rest',
            position: 1,
            stepType: WorkoutStepType.rest,
            title: 'REST',
            priority: WorkoutPriority.required,
            isSkippable: true,
            prescriptionType: StepPrescriptionType.duration,
            plannedDurationSeconds: 120,
            setPlans: [],
            childSteps: [],
          ),
        ],
      ),
    ],
  );

  SessionTracker tracker({
    SetPerformanceStatus jj = SetPerformanceStatus.planned,
    SetPerformanceStatus pu0 = SetPerformanceStatus.planned,
    SetPerformanceStatus pu1 = SetPerformanceStatus.planned,
    StepPerformanceStatus puStatus = StepPerformanceStatus.notStarted,
  }) => SessionTracker(
    sessionId: 's',
    exercises: [
      TrackerExercise(
        stepPerformanceId: 'sp-jj',
        stepId: 'jj',
        title: 'jj',
        sectionTitle: 'Warm-up',
        sets: [
          TrackerSet(setPerformanceId: 'set-jj-0', position: 0, status: jj),
        ],
      ),
      TrackerExercise(
        stepPerformanceId: 'sp-pu',
        stepId: 'pu',
        title: 'pu',
        sectionTitle: 'Main',
        status: puStatus,
        sets: [
          TrackerSet(setPerformanceId: 'set-pu-0', position: 0, status: pu0),
          TrackerSet(setPerformanceId: 'set-pu-1', position: 1, status: pu1),
        ],
      ),
    ],
  );

  GuidedSessionRecord record({
    WorkoutSessionStatus status = WorkoutSessionStatus.active,
    String? activeStepId,
    GuidedPhase phase = GuidedPhase.idle,
    DateTime? phaseStartedAt,
    int? activeSetPosition,
    DateTime? pausedAt,
    int elapsed = 0,
  }) => GuidedSessionRecord(
    sessionId: 's',
    workoutInstanceId: 'wi',
    status: status,
    startedAt: t0,
    lastResumedAt: t0,
    elapsedActiveSeconds: elapsed,
    activeStepId: activeStepId,
    phase: phase,
    phaseStartedAt: phaseStartedAt,
    activeSetPosition: activeSetPosition,
    pausedAt: pausedAt,
  );

  test('bez active_step_id = první nedokončený krok; REST krok bez výkonů; '
      'souhrny sad a kroků', () {
    final state = buildGuidedState(
      detail: detail,
      tracker: tracker(jj: SetPerformanceStatus.completed),
      session: record(),
      now: t0.add(const Duration(seconds: 30)),
    );
    expect(state.steps.map((s) => s.stepId), ['jj', 'pu', 'rest']);
    expect(state.currentStepIndex, 1);
    expect(state.currentStep!.exerciseCode, 'PULL_UP');
    expect(state.currentSetIndex, 0);
    expect(state.phase, GuidedPhase.idle);
    expect(state.steps[2].isRest, isTrue);
    expect(state.steps[2].isTracked, isFalse);
    expect(state.totalSets, 3);
    expect(state.completedSets, 1);
    expect(state.totalTrackedSteps, 2);
    expect(state.completedTrackedSteps, 1);
    expect(state.elapsedActiveSeconds, 30);
    expect(state.hasPrevious, isTrue);
    expect(state.hasNext, isTrue);
  });

  test('active_step_id určuje pozici; sada = první nedokončená', () {
    final state = buildGuidedState(
      detail: detail,
      tracker: tracker(pu0: SetPerformanceStatus.completed),
      session: record(activeStepId: 'pu'),
      now: t0,
    );
    expect(state.currentStepIndex, 1);
    expect(state.currentSetIndex, 1);
    expect(state.currentSet!.plannedRepetitions, 5);
    expect(state.currentSet!.restAfterSeconds, 90);
  });

  test('SET_RUNNING: zbytek = plán − uplynulé; doběhlo → 0 (GSP-005/006)', () {
    GuidedSessionState at(int seconds) => buildGuidedState(
      detail: detail,
      tracker: tracker(),
      session: record(
        activeStepId: 'jj',
        phase: GuidedPhase.setRunning,
        phaseStartedAt: t0,
        activeSetPosition: 0,
      ),
      now: t0.add(Duration(seconds: seconds)),
    );
    expect(at(0).remainingSeconds, 60);
    expect(at(0).phase, GuidedPhase.setRunning);
    expect(at(45).remainingSeconds, 15);
    expect(at(60).remainingSeconds, 0);
    expect(at(90).remainingSeconds, 0);
    expect(at(90).phase, GuidedPhase.setRunning);
  });

  test(
    'REST_AFTER_SET používá pauzu dokončené sady; REST_STEP délku kroku',
    () {
      final rest = buildGuidedState(
        detail: detail,
        tracker: tracker(pu0: SetPerformanceStatus.completed),
        session: record(
          activeStepId: 'pu',
          phase: GuidedPhase.restAfterSet,
          phaseStartedAt: t0,
          activeSetPosition: 0,
        ),
        now: t0.add(const Duration(seconds: 30)),
      );
      expect(rest.phase, GuidedPhase.restAfterSet);
      expect(rest.remainingSeconds, 60);
      expect(rest.currentSetIndex, 1);
      final restStep = buildGuidedState(
        detail: detail,
        tracker: tracker(),
        session: record(
          activeStepId: 'rest',
          phase: GuidedPhase.restStep,
          phaseStartedAt: t0,
        ),
        now: t0.add(const Duration(seconds: 100)),
      );
      expect(restStep.currentStep!.isRest, isTrue);
      expect(restStep.remainingSeconds, 20);
    },
  );

  test('pauza zmrazí odpočet i uplynulý čas (GSP-009)', () {
    final paused = buildGuidedState(
      detail: detail,
      tracker: tracker(),
      session: record(
        status: WorkoutSessionStatus.paused,
        activeStepId: 'jj',
        phase: GuidedPhase.setRunning,
        phaseStartedAt: t0,
        activeSetPosition: 0,
        pausedAt: t0.add(const Duration(seconds: 20)),
        elapsed: 20,
      ),
      now: t0.add(const Duration(minutes: 10)),
    );
    expect(paused.isPaused, isTrue);
    expect(paused.remainingSeconds, 40);
    expect(paused.elapsedActiveSeconds, 20);
  });

  test('DONE: všechny sledované kroky dokončené nebo přeskočené (GSP-008)', () {
    final state = buildGuidedState(
      detail: detail,
      tracker: tracker(
        jj: SetPerformanceStatus.completed,
        pu0: SetPerformanceStatus.skipped,
        pu1: SetPerformanceStatus.skipped,
        puStatus: StepPerformanceStatus.skipped,
      ),
      session: record(activeStepId: 'pu'),
      now: t0,
    );
    expect(state.phase, GuidedPhase.done);
    expect(state.isDone, isTrue);
    expect(state.steps[1].isSkipped, isTrue);
    expect(state.steps[1].isCompleted, isTrue);
    expect(state.completedTrackedSteps, 2);
    expect(state.completedSets, 1);
    expect(state.currentSetIndex, isNull);
  });

  test('krok bez výkonových řádků (v1 seed bez init) má sady jen z plánu a '
      'není sledovaný — průvodce degraduje poctivě (GSP-012)', () {
    final state = buildGuidedState(
      detail: detail,
      tracker: const SessionTracker(sessionId: 's', exercises: []),
      session: record(),
      now: t0,
    );
    expect(state.currentStepIndex, 0);
    expect(state.steps[0].isTracked, isFalse);
    expect(state.steps[0].sets.single.plannedDurationSeconds, 60);
    expect(state.totalSets, 0);
    expect(state.phase, GuidedPhase.idle);
  });
}
