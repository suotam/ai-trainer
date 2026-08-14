package com.aitrainer.backend.ai

import com.aitrainer.backend.ai.data.AnthropicModelProvider
import com.aitrainer.backend.ai.domain.AiFailureKind
import com.aitrainer.backend.ai.domain.AiModelResult
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import java.time.Duration

/**
 * Deterministický regres parse vrstvy [AnthropicModelProvider] (bez sítě).
 * Kryje defekt nalezený živým smoke: model s aktivním reasoningem vrací
 * `thinking` blok před `text` blokem — parse musí najít první `text` blok,
 * ne slepě `content[0]`.
 */
class AnthropicResponseParseTest {
    private val provider =
        AnthropicModelProvider("test-key", "claude-sonnet-5", Duration.ofSeconds(1))

    @Test
    fun `text jako jediny blok se parsuje`() {
        val result =
            provider.parse(
                """{"model":"m1","content":[{"type":"text","text":"{\"ok\":true}"}]}""",
            )
        val success = result as AiModelResult.Success
        assertEquals("""{"ok":true}""", success.rawJson)
        assertEquals("m1", success.modelId)
    }

    @Test
    fun `thinking blok pred text blokem se preskoci (zivy smoke defekt)`() {
        val result =
            provider.parse(
                """{"model":"m1","content":[
                   {"type":"thinking","thinking":"...","signature":"sig"},
                   {"type":"text","text":"{\"ok\":true}"}]}""",
            )
        val success = result as AiModelResult.Success
        assertEquals("""{"ok":true}""", success.rawJson)
    }

    @Test
    fun `odpoved bez text bloku je typovane INVALID_RESPONSE`() {
        val result =
            provider.parse(
                """{"model":"m1","content":[{"type":"thinking","thinking":"..."}]}""",
            )
        assertEquals(AiModelResult.Failure(AiFailureKind.INVALID_RESPONSE), result)
    }

    @Test
    fun `nevalidni JSON je typovane INVALID_RESPONSE`() {
        assertEquals(
            AiModelResult.Failure(AiFailureKind.INVALID_RESPONSE),
            provider.parse("not-json"),
        )
    }
}
