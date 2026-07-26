/// Typovaný výsledek dokončení workoutu (VSP §17, fyzický model §15.3,
/// PDR-006/007). Neobsahuje Drift ani SQLite typy (PDR-008) — raw
/// persistence výjimka se nikdy nevrací jako výsledek; zachytí ji až
/// controller a přemapuje na bezpečný UI error stav.
sealed class CompleteWorkoutResult {
  const CompleteWorkoutResult();
}

/// Workout byl právě dokončen v jedné atomické transakci: session
/// `COMPLETED`, instance dokončená, ActivitySummary vytvořen, pointer
/// vyčištěn.
class WorkoutCompleted extends CompleteWorkoutResult {
  const WorkoutCompleted(this.activitySummaryId);

  final String activitySummaryId;
}

/// Session už byla dokončena dříve. Idempotentní no-op — původní
/// `completed_at`, ActivitySummary ani pointer se nemění (PDR-007).
class WorkoutAlreadyCompleted extends CompleteWorkoutResult {
  const WorkoutAlreadyCompleted();
}

/// Session daného ID neexistuje.
class CompletionSessionNotFound extends CompleteWorkoutResult {
  const CompletionSessionNotFound();
}

/// Session existuje, ale není v dokončitelném stavu (např. `ABANDONED`).
class CompletionSessionNotCompletable extends CompleteWorkoutResult {
  const CompletionSessionNotCompletable();
}

/// Workout instance vázaná na session neexistuje.
class CompletionInstanceNotFound extends CompleteWorkoutResult {
  const CompletionInstanceNotFound();
}

/// Nekonzistentní stav, který nelze bezpečně dokončit — např. session je
/// aktivní, ale její instance je už v terminálním stavu. Bezpečný fallback
/// bez destrukce dat.
class CompletionInconsistentState extends CompleteWorkoutResult {
  const CompletionInconsistentState();
}
