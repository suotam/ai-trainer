import 'goal.dart';

/// Port cílů (R3-02, C18).
///
/// Offline-first (GLC-011), data aktuálního lokálního vlastníka (GLC-010).
/// Lifecycle a validace vynucuje implementace v transakci s typovanými
/// výsledky (GLC-004/006).
abstract interface class GoalRepository {
  /// Cíle aktuálního vlastníka v deterministickém pořadí (GLC-013):
  /// status (ACTIVE, PAUSED, COMPLETED, ABANDONED), priorita, title.
  Future<List<Goal>> goalsForCurrentOwner();

  /// Vytvoří nový cíl (`existingId == null`), nebo upraví existující
  /// ne-terminální current-state (GLC-006: verze +1, `SYNCED` → `DIRTY`).
  Future<SaveGoalResult> saveGoal(
    GoalInput input, {
    String? existingId,
    required String newId,
    required DateTime now,
  });

  /// Stavový přechod dle C18 §6.1; terminální stavy jsou konečné.
  Future<SaveGoalResult> changeStatus(
    String id,
    String newStatus, {
    required DateTime now,
  });
}
