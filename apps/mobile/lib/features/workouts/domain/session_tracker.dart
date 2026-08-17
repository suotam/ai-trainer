/// Doménový read model trackeru aktivní session (R1-04, fyzický model
/// §10/§11). Odděluje plánované a skutečné hodnoty (PDR-003). Neobsahuje
/// Drift typy (PDR-008).
library;

enum SetPerformanceStatus {
  planned('PLANNED'),
  completed('COMPLETED'),
  skipped('SKIPPED'),
  added('ADDED');

  const SetPerformanceStatus(this.code);
  final String code;

  bool get isCompleted => this == SetPerformanceStatus.completed;
}

enum StepPerformanceStatus {
  notStarted('NOT_STARTED'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  partial('PARTIAL'),
  skipped('SKIPPED');

  const StepPerformanceStatus(this.code);
  final String code;
}

/// Jeden trackovaný set: plánované hodnoty (neměnný snapshot) vedle
/// skutečných zadaných hodnot.
class TrackerSet {
  const TrackerSet({
    required this.setPerformanceId,
    required this.position,
    required this.status,
    this.plannedRepetitions,
    this.plannedWeightKg,
    this.actualRepetitions,
    this.actualWeightKg,
  });

  final String setPerformanceId;
  final int position;
  final SetPerformanceStatus status;

  // Plán (snapshot, jen pro zobrazení).
  final int? plannedRepetitions;
  final double? plannedWeightKg;

  // Skutečnost (zapisovatelná).
  final int? actualRepetitions;
  final double? actualWeightKg;

  bool get isCompleted => status.isCompleted;
}

/// Cvik (EXERCISE step) se svými sety.
class TrackerExercise {
  const TrackerExercise({
    required this.stepPerformanceId,
    required this.stepId,
    required this.title,
    required this.sectionTitle,
    required this.sets,
    this.status = StepPerformanceStatus.notStarted,
  });

  final String stepPerformanceId;
  final String stepId;
  final String title;
  final String sectionTitle;
  final List<TrackerSet> sets;

  /// Stav kroku (C53: `SKIPPED` je poctivý stav přeskočení, GSP-008).
  final StepPerformanceStatus status;
}

/// Tracker celé aktivní session — cviky se sety v pořadí.
class SessionTracker {
  const SessionTracker({required this.sessionId, required this.exercises});

  final String sessionId;
  final List<TrackerExercise> exercises;
}
