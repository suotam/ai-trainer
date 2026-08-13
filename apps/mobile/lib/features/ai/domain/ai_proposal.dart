import 'package:flutter/foundation.dart';

/// AIProposal — lokální reviewovatelný objekt (C29): most mezi výstupem
/// modelu a doménovou změnou. Nikdy nejedná sám (APL-001); nese výhradně
/// kanonický C28 payload a povinnou trojici verzí (APL-002/003).
@immutable
class AiProposal {
  const AiProposal({
    required this.id,
    required this.requestType,
    required this.payload,
    required this.summary,
    required this.promptVersion,
    required this.schemaVersion,
    required this.modelId,
    required this.status,
    required this.createdAtMillis,
    this.decidedAtMillis,
    this.executedPlanId,
  });

  final String id;
  final String requestType;

  /// Kanonický validovaný payload (C28 §3.3).
  final Map<String, Object?> payload;
  final String summary;
  final String promptVersion;
  final String schemaVersion;
  final String modelId;
  final String status;
  final int createdAtMillis;
  final int? decidedAtMillis;
  final String? executedPlanId;

  bool get isPending => status == 'PROPOSED';
}

/// Typovaný výsledek AI požadavku (R4-03) — nikdy raw výjimka do UI.
sealed class RequestProposalResult {
  const RequestProposalResult();
}

/// Návrh validován a uložen jako PROPOSED (C29).
final class ProposalCreated extends RequestProposalResult {
  const ProposalCreated(this.proposalId);
  final String proposalId;
}

/// AI vyžaduje přihlášený účet (AGW-008) — anonymní stav je typovaný.
final class ProposalSignInRequired extends RequestProposalResult {
  const ProposalSignInRequired();
}

/// Síť/AI služba nedostupná — bezpečný fallback (R4P-010).
final class ProposalUnavailable extends RequestProposalResult {
  const ProposalUnavailable();
}

/// Model vrátil nevalidní výstup (C28 §4) — nikdy se neprovádí.
final class ProposalInvalidOutput extends RequestProposalResult {
  const ProposalInvalidOutput();
}
