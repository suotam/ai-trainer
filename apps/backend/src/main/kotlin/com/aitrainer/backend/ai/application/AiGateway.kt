package com.aitrainer.backend.ai.application

import com.aitrainer.backend.ai.domain.AiFailureKind
import com.aitrainer.backend.ai.domain.AiModelProvider
import com.aitrainer.backend.ai.domain.AiModelResult
import com.aitrainer.backend.ai.domain.AiRequestType
import com.aitrainer.backend.ai.domain.PromptRegistry
import com.aitrainer.backend.ai.domain.schemaVersionFor
import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import org.springframework.stereotype.Service
import java.util.UUID

/**
 * R4-01 AI gateway (C25 §2): resolvuje verzovaný prompt, volá provider za
 * portem a audituje události bez obsahu (C26 §4, PAA-007/008). Žádná
 * doménová logika, žádné zápisy do domény (AGW-007, R4P-001); interpretaci
 * strukturovaného výstupu vlastní C28.
 */
sealed interface AiGatewayResult {
    /** Neinterpretovaný výstup s povinnou trojicí verzí (PAA-005). */
    data class Generated(
        val rawJson: String,
        val promptVersion: String,
        val schemaVersion: String,
        val modelId: String,
    ) : AiGatewayResult

    data class Failed(
        val kind: AiFailureKind,
    ) : AiGatewayResult
}

@Service
class AiGateway(
    private val provider: AiModelProvider,
    private val auditRecorder: AuditRecorder,
) {
    fun requestProposal(
        accountId: UUID,
        type: AiRequestType,
        contextJson: String,
    ): AiGatewayResult {
        val prompt = PromptRegistry.promptFor(type)
        // Audit bez obsahu (PAA-008): typ + prompt verze, nikdy kontext.
        auditRecorder.record(
            AuditEntry(
                action = "AiProposalRequested",
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = accountId,
                target = "${type.name}/${prompt.id}",
            ),
        )
        // Schema verze podle typu (C36 §2, ADX-009).
        val schemaVersion = schemaVersionFor(type)
        return when (val result = provider.generate(prompt, contextJson, schemaVersion)) {
            is AiModelResult.Success -> {
                auditRecorder.record(
                    AuditEntry(
                        action = "AiProposalGenerated",
                        outcome = AuditOutcome.SUCCESS,
                        principalAccountId = accountId,
                        target = "${type.name}/${prompt.id}/${result.modelId}",
                    ),
                )
                AiGatewayResult.Generated(
                    rawJson = result.rawJson,
                    promptVersion = prompt.id,
                    schemaVersion = schemaVersion,
                    modelId = result.modelId,
                )
            }

            is AiModelResult.Failure -> {
                // Selhání se audituje vždy s druhem (PAA-010).
                auditRecorder.record(
                    AuditEntry(
                        action = "AiProposalFailed",
                        outcome = AuditOutcome.REJECTED,
                        principalAccountId = accountId,
                        target = "${type.name}/${prompt.id}",
                        policyDecision = result.kind.name,
                    ),
                )
                AiGatewayResult.Failed(result.kind)
            }
        }
    }
}
