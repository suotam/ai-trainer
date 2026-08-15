import '../../auth/domain/auth_api_client.dart';
import '../data/adjustment_proposal_client_validator.dart';
import '../data/http_ai_api_client.dart';
import '../data/plan_proposal_client_validator.dart';
import '../domain/ai_context.dart';
import '../domain/ai_proposal.dart';
import '../domain/ai_proposal_repository.dart';

/// R4-03/R5-05/R7-01 use case: kontext (C27/C36) → AI klient → klientská
/// validace podle typu (C28/C37 — v osobním režimu jediná a proto
/// nekompromisní, BYK-007) → lokální `PROPOSED` návrh (C29 beze změny).
/// Osobní režim (C46) účet nevyžaduje — stavy klíče jsou typované
/// (BYK-010); všechna selhání typovaná (R4P-010) a nevalidní odpověď se
/// nikdy nepersistuje (APL-002).
class RequestPlanProposal {
  const RequestPlanProposal({
    required this.contextBuilder,
    required this.apiClient,
    required this.proposals,
    required this.newId,
    required this.clock,
  });

  final AiContextBuilder contextBuilder;
  final AiApiClient apiClient;
  final AiProposalRepository proposals;
  final String Function() newId;
  final DateTime Function() clock;

  Future<RequestProposalResult> call({
    AiRequestType type = AiRequestType.planProposal,
  }) async {
    final now = clock();
    final context = switch (type) {
      AiRequestType.planProposal =>
        await contextBuilder.buildPlanProposalContext(now: now),
      AiRequestType.adjustmentProposal =>
        await contextBuilder.buildAdjustmentContext(now: now),
    };

    final PlanProposalResponse response;
    try {
      response = await apiClient.requestPlanProposal(
        context: context.payload,
        requestType: type.code,
      );
    } on AiApiFailure catch (failure) {
      return switch (failure.kind) {
        AiApiFailureKind.unavailable => const ProposalUnavailable(),
        AiApiFailureKind.invalidOutput => const ProposalInvalidOutput(),
        AiApiFailureKind.keyMissing => const ProposalKeyMissing(),
        AiApiFailureKind.invalidKey => const ProposalKeyInvalid(),
        AiApiFailureKind.noCredit => const ProposalNoCredit(),
      };
    } on AuthApiFailure {
      return const ProposalUnavailable();
    }

    // Obrana do hloubky (SOV-003): klient validuje kanonický payload
    // znovu — validátor podle typu (C37 §4).
    final canonical = switch (type) {
      AiRequestType.planProposal => validatePlanProposalPayload(
        response.proposal,
      ),
      AiRequestType.adjustmentProposal => validateAdjustmentProposalPayload(
        response.proposal,
      ),
    };
    if (canonical == null) {
      return const ProposalInvalidOutput();
    }
    final proposalId = newId();
    await proposals.saveProposed(
      id: proposalId,
      requestType: context.requestType.code,
      canonicalPayload: canonical,
      summary: canonical['summary']! as String,
      promptVersion: response.promptVersion,
      schemaVersion: response.schemaVersion,
      modelId: response.modelId,
      now: now,
    );
    return ProposalCreated(proposalId);
  }
}
