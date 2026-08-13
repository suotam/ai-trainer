package com.aitrainer.backend.ai.application

import com.aitrainer.backend.ai.domain.AiFailureKind
import com.aitrainer.backend.ai.domain.AiRequestType
import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import org.springframework.stereotype.Service
import java.util.UUID

/**
 * R4-03 use case: kontext → gateway → deterministická validace (C28).
 * Nevalidní výstup modelu je typované selhání s auditem (SOV-005/013) —
 * nikdy oprava, nikdy tichý úspěch, žádný auto-retry (SOV-012).
 */
sealed interface ProposePlanResult {
    data class Proposed(
        val canonical: Map<String, Any?>,
        val promptVersion: String,
        val schemaVersion: String,
        val modelId: String,
    ) : ProposePlanResult

    /** Provider/gateway selhání (AGW-005). */
    data class Unavailable(
        val kind: AiFailureKind,
    ) : ProposePlanResult

    /** Model vrátil výstup mimo schéma (C28 §4). */
    data object InvalidOutput : ProposePlanResult
}

@Service
class ProposePlan(
    private val gateway: AiGateway,
    private val validator: PlanProposalValidator,
    private val auditRecorder: AuditRecorder,
) {
    fun propose(
        accountId: UUID,
        contextJson: String,
    ): ProposePlanResult =
        when (val generated = gateway.requestProposal(accountId, AiRequestType.PLAN_PROPOSAL, contextJson)) {
            is AiGatewayResult.Failed -> {
                ProposePlanResult.Unavailable(generated.kind)
            }

            is AiGatewayResult.Generated -> {
                when (val validation = validator.validate(generated.rawJson)) {
                    is PlanProposalValidation.Valid -> {
                        ProposePlanResult.Proposed(
                            canonical = validation.canonical,
                            promptVersion = generated.promptVersion,
                            schemaVersion = generated.schemaVersion,
                            modelId = generated.modelId,
                        )
                    }

                    PlanProposalValidation.Invalid -> {
                        // Audit selhání validace (SOV-013, PAA-010) — bez obsahu.
                        auditRecorder.record(
                            AuditEntry(
                                action = "AiProposalFailed",
                                outcome = AuditOutcome.REJECTED,
                                principalAccountId = accountId,
                                target = "${AiRequestType.PLAN_PROPOSAL.name}/${generated.promptVersion}",
                                policyDecision = "INVALID_OUTPUT",
                            ),
                        )
                        ProposePlanResult.InvalidOutput
                    }
                }
            }
        }
}
