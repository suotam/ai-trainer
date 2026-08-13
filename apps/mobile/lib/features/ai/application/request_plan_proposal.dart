import '../../auth/domain/auth_api_client.dart';
import '../../auth/domain/secure_session_storage.dart';
import '../data/http_ai_api_client.dart';
import '../data/plan_proposal_client_validator.dart';
import '../domain/ai_context.dart';
import '../domain/ai_proposal.dart';
import '../domain/ai_proposal_repository.dart';

/// R4-03 use case: kontext (C27) → AI API → klientská re-validace (C28
/// SOV-003) → lokální `PROPOSED` návrh (C29). AI vyžaduje přihlášený účet
/// (AGW-008); všechna selhání jsou typovaná (R4P-010) a nevalidní odpověď
/// se nikdy nepersistuje (APL-002).
class RequestPlanProposal {
  const RequestPlanProposal({
    required this.storage,
    required this.contextBuilder,
    required this.apiClient,
    required this.proposals,
    required this.newId,
    required this.clock,
  });

  final SecureSessionStorage storage;
  final AiContextBuilder contextBuilder;
  final AiApiClient apiClient;
  final AiProposalRepository proposals;
  final String Function() newId;
  final DateTime Function() clock;

  Future<RequestProposalResult> call() async {
    final stored = await storage.read();
    if (stored == null) {
      return const ProposalSignInRequired();
    }
    final now = clock();
    final context = await contextBuilder.buildPlanProposalContext(now: now);

    final PlanProposalResponse response;
    try {
      response = await apiClient.requestPlanProposal(
        accessToken: stored.accessToken,
        context: context.payload,
      );
    } on AiApiFailure catch (failure) {
      return switch (failure.kind) {
        AiApiFailureKind.unavailable => const ProposalUnavailable(),
        AiApiFailureKind.invalidOutput => const ProposalInvalidOutput(),
      };
    } on AuthApiFailure {
      return const ProposalUnavailable();
    }

    // Obrana do hloubky (SOV-003): klient validuje kanonický payload znovu.
    final canonical = validatePlanProposalPayload(response.proposal);
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
