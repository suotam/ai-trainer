package com.aitrainer.backend.ai

import com.aitrainer.backend.ai.application.AdjustmentProposalValidator
import com.aitrainer.backend.ai.application.PlanProposalValidation
import com.aitrainer.backend.ai.application.PlanProposalValidator
import com.aitrainer.backend.ai.data.AnthropicModelProvider
import com.aitrainer.backend.ai.domain.AiModelResult
import com.aitrainer.backend.ai.domain.AiRequestType
import com.aitrainer.backend.ai.domain.PromptRegistry
import com.aitrainer.backend.ai.domain.schemaVersionFor
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable
import java.nio.file.Files
import java.nio.file.Path
import java.time.Duration

/**
 * Živý provider smoke (beta gate, R4 Exit Review postup): reálné volání
 * Anthropic API přes produkční [AnthropicModelProvider] s registrovými
 * prompty a reprezentativním minimalizovaným kontextem (C27/C36 tvar),
 * výstup validovaný toutéž deterministickou C28/C37 validací jako v
 * produkci.
 *
 * Opt-in výhradně přes `AITRAINER_LIVE_SMOKE=1` — běžná suite a CI zůstávají
 * deterministické bez sítě (EVG-006, QTR). Klíč jen runtime konfigurace
 * (AGW-003): `AITRAINER_AI_ANTHROPIC_APIKEY`. Surové i kanonické výstupy se
 * ukládají do `build/live-smoke/` jako evidence a zdroj eval fixtures
 * (C32 §5).
 */
@EnabledIfEnvironmentVariable(named = "AITRAINER_LIVE_SMOKE", matches = "1")
class LiveProviderSmokeTest {
    private val apiKey = System.getenv("AITRAINER_AI_ANTHROPIC_APIKEY").orEmpty()
    private val model = System.getenv("AITRAINER_AI_ANTHROPIC_MODEL") ?: "claude-sonnet-5"
    private val provider = AnthropicModelProvider(apiKey, model, Duration.ofSeconds(60))
    private val evidenceDir: Path = Path.of("build", "live-smoke")

    /** Reprezentativní PLAN_PROPOSAL kontext v přesném C27 §3 tvaru klienta. */
    private val planContext =
        """
        {"requestType":"PLAN_PROPOSAL",
         "sports":[{"sport":"STRENGTH_TRAINING","role":"PRIMARY","priority":1,
           "experienceLevel":"INTERMEDIATE","status":"ACTIVE","frequencyPerWeek":3,
           "typicalDurationMinutes":60,"environment":"GYM"},
          {"sport":"RUNNING","role":"SECONDARY","priority":2,
           "experienceLevel":"BEGINNER","status":"ACTIVE","frequencyPerWeek":1}],
         "goals":[{"title":"Zvednout dřep na 120 kg","goalType":"PERFORMANCE",
           "priority":1,"horizon":"MID_TERM","sport":"STRENGTH_TRAINING"}],
         "typicalWeek":[{"dayOfWeek":"MON","level":"AVAILABLE","budgetMinutes":90},
          {"dayOfWeek":"WED","level":"AVAILABLE","budgetMinutes":60},
          {"dayOfWeek":"FRI","level":"LIMITED","budgetMinutes":45},
          {"dayOfWeek":"SAT","level":"AVAILABLE","budgetMinutes":120}],
         "equipment":[{"item":"BARBELL"},{"item":"SQUAT_RACK"},{"item":"DUMBBELLS"}],
         "constraints":[{"title":"Citlivé pravé koleno při hlubokém dřepu"}],
         "statistics":{"periodDays":30,"plannedCount":10,"completedCount":7,
           "manualActivityCount":2,"manualMinutes":90}}
        """.trimIndent()

    /** Reprezentativní ADJUSTMENT_PROPOSAL kontext (C36 §3) se safety CAUTION. */
    private val adjustmentContext =
        """
        {"requestType":"ADJUSTMENT_PROPOSAL",
         "sports":[{"sport":"STRENGTH_TRAINING","role":"PRIMARY","priority":1,
           "experienceLevel":"INTERMEDIATE","status":"ACTIVE","frequencyPerWeek":3}],
         "goals":[{"title":"Zvednout dřep na 120 kg","goalType":"PERFORMANCE",
           "priority":1,"horizon":"MID_TERM","sport":"STRENGTH_TRAINING"}],
         "typicalWeek":[{"dayOfWeek":"MON","level":"AVAILABLE","budgetMinutes":90},
          {"dayOfWeek":"WED","level":"AVAILABLE","budgetMinutes":60},
          {"dayOfWeek":"SAT","level":"AVAILABLE","budgetMinutes":120}],
         "equipment":[{"item":"BARBELL"},{"item":"SQUAT_RACK"}],
         "constraints":[],
         "statistics":{"periodDays":30,"plannedCount":10,"completedCount":7,
           "manualActivityCount":2,"manualMinutes":90},
         "weekPlan":[{"dayOffset":0,"title":"Těžký dřep","workoutType":"STRENGTH",
           "status":"READY","plannedDurationMinutes":75},
          {"dayOffset":2,"title":"Intervalový běh","workoutType":"ENDURANCE",
           "status":"READY","plannedDurationMinutes":45},
          {"dayOffset":5,"title":"Full Body B","workoutType":"STRENGTH",
           "status":"READY","plannedDurationMinutes":60}],
         "checkIns":{"today":{"energyLevel":2,"fatigueLevel":4,"sleepQuality":2},
          "aggregates":{"periodDays":7,"checkInCount":5,"averageEnergy":2.6,
           "averageFatigue":3.8,"painDays":0}},
         "safety":{"state":"CAUTION","flags":[{"code":"HIGH_FATIGUE"}]}}
        """.trimIndent()

    @Test
    fun `zivy PLAN_PROPOSAL projde produkcni validaci a dava smysluplny plan`() {
        val prompt = PromptRegistry.promptFor(AiRequestType.PLAN_PROPOSAL)
        val result =
            provider.generate(prompt, planContext, schemaVersionFor(AiRequestType.PLAN_PROPOSAL))
        val success = result as? AiModelResult.Success
        assertTrue(success != null) { "Provider selhal: $result" }
        writeEvidence("plan-proposal-raw.json", success!!.rawJson)

        val validation = PlanProposalValidator().validate(success.rawJson)
        val valid = validation as? PlanProposalValidation.Valid
        assertTrue(valid != null) { "Reálný výstup neprošel C28 validací" }

        @Suppress("UNCHECKED_CAST")
        val workouts = valid!!.canonical["workouts"] as List<Map<String, Any?>>
        assertTrue(workouts.isNotEmpty()) { "Plán bez workoutů" }
        assertTrue(workouts.all { !(it["reason"] as? String).isNullOrBlank() }) {
            "Workout bez reason"
        }
        writeEvidence(
            "plan-proposal-summary.txt",
            "modelId=${success.modelId}\nworkouts=${workouts.size}\n" +
                workouts.joinToString("\n") {
                    "day=${it["dayOffset"]} ${it["workoutType"]}: ${it["title"]}"
                },
        )
    }

    @Test
    fun `zivy ADJUSTMENT_PROPOSAL projde produkcni validaci`() {
        val prompt = PromptRegistry.promptFor(AiRequestType.ADJUSTMENT_PROPOSAL)
        val result =
            provider.generate(
                prompt,
                adjustmentContext,
                schemaVersionFor(AiRequestType.ADJUSTMENT_PROPOSAL),
            )
        val success = result as? AiModelResult.Success
        assertTrue(success != null) { "Provider selhal: $result" }
        writeEvidence("adjustment-proposal-raw.json", success!!.rawJson)

        val validation = AdjustmentProposalValidator().validate(success.rawJson)
        val valid = validation as? PlanProposalValidation.Valid
        assertTrue(valid != null) { "Reálný výstup neprošel C37 validací" }

        @Suppress("UNCHECKED_CAST")
        val operations = valid!!.canonical["operations"] as List<Map<String, Any?>>
        assertTrue(operations.isNotEmpty()) { "Úprava bez operací" }
        assertTrue(operations.all { !(it["reason"] as? String).isNullOrBlank() }) {
            "Operace bez reason"
        }
        writeEvidence(
            "adjustment-proposal-summary.txt",
            "modelId=${success.modelId}\noperations=${operations.size}\n" +
                operations.joinToString("\n") { "${it["operation"]}: ${it["reason"]}" },
        )
    }

    private fun writeEvidence(
        fileName: String,
        content: String,
    ) {
        Files.createDirectories(evidenceDir)
        Files.writeString(evidenceDir.resolve(fileName), content)
    }
}
