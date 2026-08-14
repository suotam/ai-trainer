package com.aitrainer.backend.ai

import com.aitrainer.backend.ai.application.AiGateway
import com.aitrainer.backend.ai.application.AiGatewayResult
import com.aitrainer.backend.ai.data.FakeModelProvider
import com.aitrainer.backend.ai.domain.AiFailureKind
import com.aitrainer.backend.ai.domain.AiModelProvider
import com.aitrainer.backend.ai.domain.AiModelResult
import com.aitrainer.backend.ai.domain.AiPrompt
import com.aitrainer.backend.ai.domain.AiRequestType
import com.aitrainer.backend.ai.domain.PromptRegistry
import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import org.junit.jupiter.api.Test
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertIs
import kotlin.test.assertTrue

/**
 * R4-01 unit testy AI gateway (C25/C26): trojice verzĂ­ v ĂşspÄ›chu (PAA-005),
 * typovanĂˇ selhĂˇnĂ­ (AGW-005), audit udĂˇlosti bez obsahu (PAA-007/008/010)
 * a deterministickĂ˝ fake provider (AGW-004).
 */
class AiGatewayTest {
    private class RecordingAudit : AuditRecorder {
        val entries = mutableListOf<AuditEntry>()

        override fun record(entry: AuditEntry) {
            entries += entry
        }
    }

    private class ScriptedProvider(
        private val result: AiModelResult,
    ) : AiModelProvider {
        override fun generate(
            prompt: AiPrompt,
            contextJson: String,
            schemaVersion: String,
        ): AiModelResult = result
    }

    private val accountId: UUID = UUID.randomUUID()
    private val secretContext = """{"sports":[{"code":"CLIMBING"}],"marker":"SENSITIVE-CONTEXT"}"""

    @Test
    fun `uspesny navrh nese trojici verzi a audituje Requested plus Generated bez obsahu`() {
        val audit = RecordingAudit()
        val gateway =
            AiGateway(
                ScriptedProvider(AiModelResult.Success(rawJson = "{}", modelId = "fake-model")),
                audit,
            )

        val result = gateway.requestProposal(accountId, AiRequestType.PLAN_PROPOSAL, secretContext)

        val generated = assertIs<AiGatewayResult.Generated>(result)
        assertEquals("plan-proposal-v2", generated.promptVersion)
        assertEquals("plan-proposal-schema-v1", generated.schemaVersion)
        assertEquals("fake-model", generated.modelId)

        assertEquals(listOf("AiProposalRequested", "AiProposalGenerated"), audit.entries.map { it.action })
        assertTrue(audit.entries.all { it.outcome == AuditOutcome.SUCCESS })
        assertTrue(audit.entries.all { it.principalAccountId == accountId })
        // Audit bez obsahu (PAA-008): ĹľĂˇdnĂ© pole nenese kontext.
        audit.entries.forEach { entry ->
            listOf(entry.action, entry.target.orEmpty(), entry.policyDecision.orEmpty()).forEach {
                assertTrue(!it.contains("SENSITIVE-CONTEXT"), "audit nese obsah kontextu: $it")
            }
        }
    }

    @Test
    fun `selhani providera je typovane a audituje se s druhem selhani`() {
        val audit = RecordingAudit()
        val gateway = AiGateway(ScriptedProvider(AiModelResult.Failure(AiFailureKind.TIMEOUT)), audit)

        val result = gateway.requestProposal(accountId, AiRequestType.PLAN_PROPOSAL, secretContext)

        val failed = assertIs<AiGatewayResult.Failed>(result)
        assertEquals(AiFailureKind.TIMEOUT, failed.kind)
        assertEquals(listOf("AiProposalRequested", "AiProposalFailed"), audit.entries.map { it.action })
        val failure = audit.entries.last()
        assertEquals(AuditOutcome.REJECTED, failure.outcome)
        assertEquals("TIMEOUT", failure.policyDecision)
    }

    @Test
    fun `prompt registry je verzovany a stabilni`() {
        val prompt = PromptRegistry.promptFor(AiRequestType.PLAN_PROPOSAL)
        assertEquals("plan-proposal-v2", prompt.id)
        assertTrue(prompt.template.isNotBlank())
        // Stabilita (PAA-002/003): opakovanĂ© ÄŤtenĂ­ vracĂ­ identickĂ˝ artefakt.
        assertEquals(prompt, PromptRegistry.promptFor(AiRequestType.PLAN_PROPOSAL))
        // Prompt bez uĹľivatelskĂ˝ch dat (PAA-004) â€” Ĺˇablona neobsahuje placeholdery
        // kontextu (v2 legitimnÄ› obsahuje literĂˇlnĂ­ JSON tvar vĂ˝stupu).
        assertTrue(!prompt.template.contains("\${"), "Ĺˇablona nesmĂ­ interpolovat kontext")
        assertTrue(!prompt.template.contains("{{"), "Ĺˇablona nesmĂ­ interpolovat kontext")
    }

    @Test
    fun `adjustment typ resolvuje vlastni prompt a schema verzi (C36 ADX-008-009)`() {
        val audit = RecordingAudit()
        val gateway =
            AiGateway(
                ScriptedProvider(AiModelResult.Success(rawJson = "{}", modelId = "fake-model")),
                audit,
            )

        val result = gateway.requestProposal(accountId, AiRequestType.ADJUSTMENT_PROPOSAL, secretContext)

        val generated = assertIs<AiGatewayResult.Generated>(result)
        assertEquals("adjustment-proposal-v2", generated.promptVersion)
        assertEquals("adjustment-proposal-schema-v1", generated.schemaVersion)
        assertTrue(audit.entries.all { it.target.orEmpty().contains("adjustment-proposal-v2") })

        // Registry: novĂˇ verze je immutable artefakt bez uĹľivatelskĂ˝ch dat
        // (PAA-002/003/004) a bez interpolace kontextu.
        val prompt = PromptRegistry.promptFor(AiRequestType.ADJUSTMENT_PROPOSAL)
        assertEquals("adjustment-proposal-v2", prompt.id)
        assertEquals(prompt, PromptRegistry.promptFor(AiRequestType.ADJUSTMENT_PROPOSAL))
        assertTrue(!prompt.template.contains("\${"), "Ĺˇablona nesmĂ­ interpolovat kontext")
        assertTrue(!prompt.template.contains("{{"), "Ĺˇablona nesmĂ­ interpolovat kontext")
        // Plan-proposal verze zĹŻstĂˇvĂˇ nedotÄŤenĂˇ (aditivnĂ­ rozĹˇĂ­Ĺ™enĂ­).
        assertEquals("plan-proposal-v2", PromptRegistry.promptFor(AiRequestType.PLAN_PROPOSAL).id)
    }

    @Test
    fun `fake provider je deterministicky - stejny vstup stejny vystup`() {
        val provider = FakeModelProvider()
        val prompt = PromptRegistry.promptFor(AiRequestType.PLAN_PROPOSAL)
        val first = provider.generate(prompt, secretContext, "plan-proposal-schema-v1")
        val second = provider.generate(prompt, secretContext, "plan-proposal-schema-v1")
        assertEquals(first, second)
        val success = assertIs<AiModelResult.Success>(first)
        assertEquals("fake-model", success.modelId)
        assertTrue(success.rawJson.contains("plan-proposal-schema-v1"))
    }
}
