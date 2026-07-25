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
}
