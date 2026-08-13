import 'ai_proposal.dart';

/// Port persistence AI návrhů (C29). Návrh nikdy nejedná (APL-001);
/// žádné mazání (APL-008).
abstract interface class AiProposalRepository {
  /// Uloží validovaný návrh jako `PROPOSED` s povinnou trojicí verzí
  /// (APL-002/003).
  Future<void> saveProposed({
    required String id,
    required String requestType,
    required Map<String, Object?> canonicalPayload,
    required String summary,
    required String promptVersion,
    required String schemaVersion,
    required String modelId,
    required DateTime now,
  });

  /// Návrhy aktuálního vlastníka, čas vytvoření sestupně (APL-012).
  Future<List<AiProposal>> proposalsForCurrentOwner();

  Future<AiProposal?> proposalById(String id);

  /// Explicitní rozhodnutí uživatele (APL-005) — jen z PROPOSED;
  /// potvrzení po 7 dnech → EXPIRED (APL-007). Odmítnutí je zachovaný
  /// stav (APL-006).
  Future<DecideProposalResult> decide(
    String id,
    ProposalDecision decision, {
    required DateTime now,
  });
}
