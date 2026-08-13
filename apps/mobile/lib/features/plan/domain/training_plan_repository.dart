import 'training_plan.dart';

/// Port ručního plánování (R3-04, C20).
///
/// Offline-first, data aktuálního lokálního vlastníka. Invariant jednoho
/// ACTIVE plánu (MPC-002) a atomické vytvoření workoutu (MPC-004)
/// vynucuje implementace v transakci s typovanými výsledky.
abstract interface class TrainingPlanRepository {
  /// Plány vlastníka: ACTIVE první, pak ARCHIVED; uvnitř podle title.
  Future<List<TrainingPlan>> plansForCurrentOwner();

  /// Vytvoří plán; druhý ACTIVE je typovaně odmítnut (MPC-002).
  /// `origin` je provenance (C30 CSE-004): default MANUAL, execution
  /// potvrzeného AI návrhu předává AI_PROPOSAL.
  Future<PlanWriteResult> createPlan({
    required String title,
    String? note,
    String origin = 'MANUAL',
    required String newId,
    required DateTime now,
  });

  /// Editace title/poznámky current-state (MPC-012).
  Future<PlanWriteResult> renamePlan(
    String id, {
    required String title,
    String? note,
    required DateTime now,
  });

  /// ACTIVE/ARCHIVED — archivace je stav (MPC-003); reaktivace kontroluje
  /// MPC-002 znovu.
  Future<PlanWriteResult> setPlanStatus(
    String id,
    String status, {
    required DateTime now,
  });

  /// Přidá ruční workout do ACTIVE plánu: v jedné transakci vytvoří
  /// instanci (`READY`/`USER_PLAN`) + MAIN sekci + exercise kroky + set
  /// plans (C20 §5.1, MPC-004/005).
  Future<PlanWriteResult> addWorkout(
    String planId,
    PlannedWorkoutInput input, {
    required String Function() newId,
    required DateTime now,
  });

  /// Workouty plánu seřazené podle data, pak title (MPC-013).
  Future<List<PlannedWorkoutSummary>> workoutsForPlan(String planId);
}
