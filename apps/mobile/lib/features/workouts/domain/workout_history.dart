import 'session_tracker.dart';

/// Read model lokální historie dokončených workoutů (VSP §17, fyzický
/// model §13/§21). Odvozeno z `local_activity_summaries` a performance dat;
/// není autoritativním zdrojem stavu a je rekonstruovatelné (DAR-006).
/// Neobsahuje Drift typy (PDR-008).
class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.activitySummaryId,
    required this.workoutSessionId,
    required this.workoutInstanceId,
    required this.title,
    required this.workoutType,
    required this.startedAt,
    required this.completedAt,
    required this.completedStepCount,
    required this.totalStepCount,
  });

  final String activitySummaryId;
  final String workoutSessionId;
  final String workoutInstanceId;

  /// Historický název (snapshot v okamžiku dokončení, PDR-011).
  final String title;
  final String workoutType;
  final DateTime startedAt;
  final DateTime completedAt;
  final int completedStepCount;
  final int totalStepCount;
}

/// Read-only detail dokončeného workoutu: historická metadata + neměnný
/// tracker read model (planned vs. actual, completion stavy) v read-only
/// režimu. Presentation jasně odliší aktivní a dokončený stav.
class CompletedWorkoutDetail {
  const CompletedWorkoutDetail({required this.entry, required this.tracker});

  final WorkoutHistoryEntry entry;
  final SessionTracker tracker;
}
