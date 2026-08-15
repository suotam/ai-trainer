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

  /// Adjustment návrh (C37) — payload nese operace místo plánu.
  bool get isAdjustment => requestType == 'ADJUSTMENT_PROPOSAL';

  /// Po EXECUTION_FAILED je dovolen explicitní nový pokus (CSE-007).
  bool get canRetryExecution => status == 'EXECUTION_FAILED';
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

/// Chybí API klíč (osobní režim, C46 §4 BYK-010; nahrazuje dřívější
/// sign-in gating AGW-008 — osobní režim účet nevyžaduje) — poctivý stav
/// s odkazem na správu klíče, nikdy tiché selhání.
final class ProposalKeyMissing extends RequestProposalResult {
  const ProposalKeyMissing();
}

/// Klíč byl odmítnut providerem (401) — typovaný stav (BYK-008).
final class ProposalKeyInvalid extends RequestProposalResult {
  const ProposalKeyInvalid();
}

/// Účet u providera nemá kredit — typovaný stav (BYK-008).
final class ProposalNoCredit extends RequestProposalResult {
  const ProposalNoCredit();
}

/// Síť/AI služba nedostupná — bezpečný fallback (R4P-010).
final class ProposalUnavailable extends RequestProposalResult {
  const ProposalUnavailable();
}

/// Model vrátil nevalidní výstup (C28 §4) — nikdy se neprovádí.
final class ProposalInvalidOutput extends RequestProposalResult {
  const ProposalInvalidOutput();
}

/// Rozhodnutí uživatele nad návrhem (C29 §3, APL-005).
enum ProposalDecision { confirm, reject }

/// Typovaný výsledek rozhodnutí (APL-004) — nikdy raw výjimka.
sealed class DecideProposalResult {
  const DecideProposalResult();
}

final class DecisionSaved extends DecideProposalResult {
  const DecisionSaved(this.newStatus);
  final String newStatus;
}

/// Potvrzení návrhu staršího 7 dní → EXPIRED (APL-007).
final class DecisionExpired extends DecideProposalResult {
  const DecisionExpired();
}

final class DecisionNotFound extends DecideProposalResult {
  const DecisionNotFound();
}

/// Návrh není v rozhodnutelném stavu PROPOSED (APL-004/009).
final class DecisionInvalidState extends DecideProposalResult {
  const DecisionInvalidState();
}
