import 'guided_session.dart';

/// Typovaný výsledek operací průvodce (C53 §5) — nikdy raw výjimka.
sealed class GuidedSessionResult {
  const GuidedSessionResult();
}

final class GuidedSessionSaved extends GuidedSessionResult {
  const GuidedSessionSaved();
}

final class GuidedSessionNotFound extends GuidedSessionResult {
  const GuidedSessionNotFound();
}

/// Session není ACTIVE ani PAUSED (nebo operace nedává v jejím stavu smysl).
final class GuidedSessionNotActive extends GuidedSessionResult {
  const GuidedSessionNotActive();
}

/// Persistence stavu průvodce na session (C53 §4/§5, v17): pozice kroku,
/// fáze s ukotvením, pauza/pokračovat. Zařízení-lokální pomocník obnovy
/// (GSP-003/004); mění výhradně `local_workout_sessions`.
abstract interface class GuidedSessionRepository {
  Future<GuidedSessionRecord?> record(String sessionId);

  /// Nastaví aktuální krok; fáze se ruší (GSP: posun je explicitní akce).
  Future<GuidedSessionResult> goToStep({
    required String sessionId,
    required String stepId,
    required DateTime now,
  });

  /// Zahájí fázi s ukotvením `now` (SET_RUNNING / REST_AFTER_SET /
  /// REST_STEP); [stepId] volitelně přenastaví aktuální krok.
  Future<GuidedSessionResult> startPhase({
    required String sessionId,
    required GuidedPhase phase,
    required DateTime now,
    String? stepId,
    int? setPosition,
  });

  /// Ukončí běžící fázi (uživatelské potvrzení, GSP-006).
  Future<GuidedSessionResult> clearPhase({
    required String sessionId,
    required DateTime now,
  });

  /// ACTIVE → PAUSED: `paused_at`, přičtení běžícího úseku do
  /// `elapsed_active_seconds`; fáze zmrazena (GSP-009).
  Future<GuidedSessionResult> pause({
    required String sessionId,
    required DateTime now,
  });

  /// PAUSED → ACTIVE: `last_resumed_at = now`; ukotvení fáze posunuté o
  /// délku pauzy (GSP-009).
  Future<GuidedSessionResult> resume({
    required String sessionId,
    required DateTime now,
  });
}
