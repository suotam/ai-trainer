package com.aitrainer.backend.ai

import com.aitrainer.backend.ai.application.PlanProposalValidation
import com.aitrainer.backend.ai.application.PlanProposalValidator
import org.junit.jupiter.api.Test
import tools.jackson.databind.json.JsonMapper
import java.io.File
import kotlin.test.assertTrue

/**
 * R4-07 eval release gate (C32): deterministický harness nad sdíleným
 * datasetem `packages/contracts/eval/plan-proposal` (EVG-003). Součást
 * běžné suite = závazný gate (EVG-001); bez živého providera (EVG-002).
 */
class EvalGateTest {
    private val validator = PlanProposalValidator()
    private val mapper = JsonMapper.builder().build()

    // Gradle test běží s working dir apps/backend.
    private val datasetDir = File("../../packages/contracts/eval/plan-proposal")

    @Test
    fun `eval gate - 100 procent shody verdiktu a kvalitativni vlastnosti (EVG-004-008)`() {
        val files =
            datasetDir
                .listFiles { file -> file.extension == "json" }
                ?.sortedBy { it.name }
                .orEmpty()
        // Ochrana proti tichému vyprázdnění gate (EVG-007).
        assertTrue(files.size >= 10, "dataset se zmenšil: ${files.size} < 10 (EVG-007)")

        val failures = mutableListOf<String>()
        for (file in files) {
            val case = mapper.readTree(file.readText(Charsets.UTF_8))
            val name = case.path("name").asString()
            val expected = case.path("expected")
            val expectedVerdict = expected.path("verdict").asString()
            val result = validator.validate(case.path("modelOutput").asString())

            when (result) {
                is PlanProposalValidation.Valid -> {
                    if (expectedVerdict != "VALID") {
                        failures += "$name: očekáván INVALID, validátor přijal"
                        continue
                    }
                    failures += qualityFailures(name, expected, result.canonical)
                }

                PlanProposalValidation.Invalid -> {
                    if (expectedVerdict != "INVALID") {
                        failures += "$name: očekáván VALID, validátor odmítl"
                    }
                }
            }
        }
        assertTrue(failures.isEmpty(), "Eval gate červený:\n" + failures.joinToString("\n"))
    }

    /** Kvalitativní vlastnosti validních návrhů (C32 §4.2, EVG-005/008). */
    private fun qualityFailures(
        name: String,
        expected: tools.jackson.databind.JsonNode,
        canonical: Map<String, Any?>,
    ): List<String> {
        val failures = mutableListOf<String>()

        @Suppress("UNCHECKED_CAST")
        val workouts = canonical["workouts"] as? List<Map<String, Any?>> ?: emptyList()

        if (workouts.size !in 1..14) {
            failures += "$name: počet workoutů ${workouts.size} mimo 1–14"
        }
        workouts.forEachIndexed { index, workout ->
            val reason = workout["reason"] as? String
            if (reason.isNullOrBlank()) {
                failures += "$name: workout #$index bez reason (EVG-005)"
            }
            val dayOffset = workout["dayOffset"] as? Int
            if (dayOffset == null || dayOffset !in 0..27) {
                failures += "$name: workout #$index dayOffset $dayOffset mimo 0–27"
            }
        }

        if (expected.has("workoutCount") && workouts.size != expected.path("workoutCount").asInt()) {
            failures += "$name: workoutCount ${workouts.size} != ${expected.path("workoutCount").asInt()}"
        }
        if (expected.has("planTitle") && canonical["planTitle"] != expected.path("planTitle").asString()) {
            failures += "$name: planTitle '${canonical["planTitle"]}' != '${expected.path("planTitle").asString()}'"
        }
        val serialized = mapper.writeValueAsString(canonical)
        expected.path("mustNotContain").forEach { forbidden ->
            if (serialized.contains(forbidden.asString())) {
                failures += "$name: kanonický výstup obsahuje '${forbidden.asString()}' (EVG-008)"
            }
        }
        return failures
    }
}
