import 'start_session_result.dart';
import 'workout_session.dart';

/// Session write/read boundary (fyzický model §15.1, §16).
///
/// Implementace patří do data vrstvy. `startSession` je atomická transakce,
/// která vynucuje invariant maximálně jedné aktivní session a nikdy nevrací
/// raw persistence výjimku jako výsledek.
abstract interface class WorkoutSessionRepository {
  /// Atomicky zahájí session pro danou instanci. Kontroluje globálně
  /// existující aktivní/pozastavenou session a vrací typovaný výsledek.
  Future<StartSessionResult> startSession({
    required String workoutInstanceId,
    required String newSessionId,
    required DateTime now,
  });

  /// Vrátí jedinou globálně aktivní/pozastavenou session, nebo `null`
  /// (recovery po restartu).
  Future<WorkoutSessionSnapshot?> findActiveSession();

  /// Vrátí session podle stabilního ID, nebo `null`.
  Future<WorkoutSessionSnapshot?> sessionById(String id);

  /// Vrátí všechny globálně aktivní/pozastavené session (deterministicky
  /// dle času startu). Recovery z počtu odvodí kanonický nebo konfliktní
  /// stav — zdroj pravdy je tato tabulka, ne technický pointer (§19).
  Future<List<WorkoutSessionSnapshot>> findActiveSessions();

  /// Přečte technický active-session pointer z `local_app_state`
  /// (`active_session_id`), nebo `null`. Pointer je jen cache, ne zdroj
  /// pravdy (fyzický model §14/§19).
  Future<String?> readActiveSessionPointer();

  /// Bezpečně rekonstruuje technický pointer z jediné aktivní session
  /// (fyzický model §19). V jedné transakci ověří, že [sessionId] je stále
  /// jediná `ACTIVE`/`PAUSED` session, a jen tehdy pointer nastaví.
  /// Idempotentní; při porušení invariantu je no-op. Vrátí `true`, pokud
  /// pointer po operaci ukazuje na [sessionId].
  Future<bool> reconcileActiveSessionPointer({
    required String sessionId,
    required DateTime now,
  });

  /// Zda existuje workout instance daného ID (ověření snapshot vazby při
  /// recovery). Bez načítání celého read modelu.
  Future<bool> workoutInstanceExists(String instanceId);
}
