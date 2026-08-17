/// Explicitní výsledek startu WorkoutSession (R1-03).
///
/// Aplikační vrstva nikdy nevrací raw persistence výjimku — pouze tyto
/// typované výsledky nebo (u neočekávané chyby) vyhozenou doménovou/technickou
/// chybu, kterou UI mapuje na bezpečný stav.
library;

sealed class StartSessionResult {
  const StartSessionResult();
}

/// Vznikla nová aktivní session.
class SessionCreated extends StartSessionResult {
  const SessionCreated(this.sessionId);
  final String sessionId;
}

/// Pro stejný workout už aktivní session existovala — pokračuje se v ní.
class SessionResumedExisting extends StartSessionResult {
  const SessionResumedExisting(this.sessionId);
  final String sessionId;
}

/// Aktivní session existuje pro jiný workout — druhá se nevytvoří.
class ConflictWithAnotherSession extends StartSessionResult {
  const ConflictWithAnotherSession({
    required this.activeSessionId,
    required this.activeWorkoutInstanceId,
  });
  final String activeSessionId;
  final String activeWorkoutInstanceId;
}

/// Workout instance neexistuje.
class WorkoutNotFound extends StartSessionResult {
  const WorkoutNotFound();
}

/// Workout už je uzavřený (dokončený, částečně dokončený, přeskočený nebo
/// zrušený) — novou session nelze zahájit (on-device nález 9: dřív pád na
/// CHECK constraint `completed_at`).
class WorkoutAlreadyFinished extends StartSessionResult {
  const WorkoutAlreadyFinished(this.status);
  final String status;
}
