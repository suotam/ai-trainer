package com.aitrainer.backend.ai

import com.aitrainer.backend.ai.application.PlanProposalValidation
import com.aitrainer.backend.ai.application.PlanProposalValidator
import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertIs

/**
 * R4-03 unit testy deterministické validace `plan-proposal-schema-v1`
 * (C28 §2–§3): fence extrakce, povinná pole a meze, ignorování neznámých
 * polí, kanonizace a determinismus (SOV-004/009/010/011/015).
 */
class PlanProposalValidatorTest {
    private val validator = PlanProposalValidator()

    private val validJson =
        """
        {"summary":"Týdenní plán zaměřený na sílu.","planTitle":"Silový týden",
         "workouts":[
           {"title":"Full Body A","workoutType":"STRENGTH","dayOffset":0,
            "reason":"Základní silový stimul.","plannedDurationMinutes":60,
            "exercises":[{"title":"Dřep","sets":3,"repetitions":5,"weightKg":80}]},
           {"title":"Lehká mobilita","workoutType":"MOBILITY","dayOffset":2,
            "reason":"Aktivní regenerace."}
         ],
         "unknownField":"ignore me"}
        """.trimIndent()

    @Test
    fun `validni vystup se kanonizuje - nezname pole zmizi a schvalena zustanou`() {
        val result = assertIs<PlanProposalValidation.Valid>(validator.validate(validJson))
        assertEquals(setOf("summary", "planTitle", "workouts"), result.canonical.keys)
        @Suppress("UNCHECKED_CAST")
        val workouts = result.canonical["workouts"] as List<Map<String, Any?>>
        assertEquals(2, workouts.size)
        assertEquals(0, workouts[0]["dayOffset"])
        assertEquals("Aktivní regenerace.", workouts[1]["reason"])
        // Kanonizace: unknownField nikde (SOV-009/010).
        assertEquals(false, result.canonical.toString().contains("unknownField"))
        // Determinismus (SOV-004).
        assertEquals(result, validator.validate(validJson))
    }

    @Test
    fun `json ve fence obalu se deterministicky extrahuje (SOV-011)`() {
        val fenced = "```json\n$validJson\n```"
        assertIs<PlanProposalValidation.Valid>(validator.validate(fenced))
    }

    @Test
    fun `nevalidni vystupy jsou typovane odmitnuty (SOV-005-008)`() {
        val invalidCases =
            listOf(
                // Volný text mimo JSON.
                "Here is your plan: do squats on Monday.",
                // Chybějící povinné pole reason.
                """{"summary":"s","planTitle":"p","workouts":[{"title":"W","workoutType":"STRENGTH","dayOffset":0}]}""",
                // Neznámý workoutType.
                """{"summary":"s","planTitle":"p","workouts":[{"title":"W","workoutType":"CARDIO","dayOffset":0,"reason":"r"}]}""",
                // dayOffset mimo meze.
                """{"summary":"s","planTitle":"p","workouts":[{"title":"W","workoutType":"STRENGTH","dayOffset":99,"reason":"r"}]}""",
                // Prázdné workouts.
                """{"summary":"s","planTitle":"p","workouts":[]}""",
                // Sety mimo meze.
                """{"summary":"s","planTitle":"p","workouts":[{"title":"W","workoutType":"STRENGTH","dayOffset":0,"reason":"r",
                   "exercises":[{"title":"Dřep","sets":0,"repetitions":5}]}]}""",
                // Prázdný summary.
                """{"summary":"  ","planTitle":"p","workouts":[{"title":"W","workoutType":"STRENGTH","dayOffset":0,"reason":"r"}]}""",
            )
        invalidCases.forEachIndexed { index, case ->
            assertEquals(
                PlanProposalValidation.Invalid,
                validator.validate(case),
                "case #$index měl být Invalid",
            )
        }
    }
}
