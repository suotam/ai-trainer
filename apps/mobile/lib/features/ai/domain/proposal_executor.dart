/// Port provedení potvrzeného AI návrhu (C30).
///
/// Jediné místo, kde se návrh stává doménovou změnou — a to výhradně
/// existujícími C20 operacemi (CSE-001). Atomické: selhání kterékoli
/// části = žádný částečný stav (CSE-003).
abstract interface class ProposalExecutor {
  /// Provede návrh ve stavu CONFIRMED nebo EXECUTION_FAILED (retry,
  /// CSE-007). Mapování `dayOffset` → lokální datum okamžiku `now`
  /// (C30 §3, CSE-008).
  Future<ExecuteProposalResult> execute(
    String proposalId, {
    required String Function() newId,
    required DateTime now,
  });
}

/// Typovaný výsledek execution (CSE-006) — nikdy raw výjimka do UI.
sealed class ExecuteProposalResult {
  const ExecuteProposalResult();
}

/// Plán vznikl, návrh je EXECUTED s referencí (CSE-005, APL-010).
final class ExecutionSaved extends ExecuteProposalResult {
  const ExecutionSaved(this.planId);
  final String planId;
}

final class ExecutionNotFound extends ExecuteProposalResult {
  const ExecutionNotFound();
}

/// Návrh není v proveditelném stavu (C30 §2, CSE-010).
final class ExecutionInvalidState extends ExecuteProposalResult {
  const ExecutionInvalidState();
}

/// MPC-002 platí i pro AI (CSE-002): vlastník už má ACTIVE plán;
/// řešení je běžná archivace + explicitní retry (CSE-013).
final class ExecutionActivePlanConflict extends ExecuteProposalResult {
  const ExecutionActivePlanConflict();
}

/// Payload nelze přeložit na C20 operace — žádné částečné provedení
/// (CSE-003), žádná oprava payloadu (CSE-012).
final class ExecutionInvalidPayload extends ExecuteProposalResult {
  const ExecutionInvalidPayload();
}
