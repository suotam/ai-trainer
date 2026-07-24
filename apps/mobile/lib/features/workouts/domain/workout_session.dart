/// Doménové modely aktivní WorkoutSession pro R1-03 (workout-model §29,
/// fyzický model §9). Stabilní enum kódy odpovídají persistence kontraktu;
/// neznámý kód je chyba dat, nikoli tichý default.
library;

enum WorkoutSessionStatus {
  active('ACTIVE'),
  paused('PAUSED'),
  completed('COMPLETED'),
  abandoned('ABANDONED');

  const WorkoutSessionStatus(this.code);
  final String code;

  bool get isActiveOrPaused =>
      this == WorkoutSessionStatus.active ||
      this == WorkoutSessionStatus.paused;
}

/// Snapshot aktivní (nebo obnovené) session pro presentation vrstvu.
/// Neobsahuje Drift typy (PDR-008).
class WorkoutSessionSnapshot {
  const WorkoutSessionSnapshot({
    required this.id,
    required this.workoutInstanceId,
    required this.instanceRevisionNumber,
    required this.status,
    required this.startedAt,
  });

  final String id;
  final String workoutInstanceId;
  final int instanceRevisionNumber;
  final WorkoutSessionStatus status;
  final DateTime startedAt;
}
