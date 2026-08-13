package com.aitrainer.backend.ai.application

import org.springframework.stereotype.Component
import tools.jackson.databind.JsonNode
import tools.jackson.databind.json.JsonMapper

/**
 * Deterministická validace strukturovaného výstupu `plan-proposal-schema-v1`
 * (C28 §2–§3): fence extrakce, přísná povinná pole a meze, ignorování
 * neznámých polí a kanonizace payloadu. Čistá funkce bez vedlejších efektů
 * (SOV-004); nevalidní výstup se nikdy neopravuje (SOV-005).
 */
sealed interface PlanProposalValidation {
    /** Kanonický payload — jediné, co smí pokračovat dál (SOV-002/010). */
    data class Valid(
        val canonical: Map<String, Any?>,
    ) : PlanProposalValidation

    data object Invalid : PlanProposalValidation
}

@Component
class PlanProposalValidator {
    companion object {
        /** Obsahový limit raw výstupu modelu (C31 §5, AIS-008). */
        private const val MAX_RAW_CHARS = 100_000
    }

    private val mapper = JsonMapper.builder().build()

    private val workoutTypes = setOf("STRENGTH", "ENDURANCE", "MOBILITY", "TECHNIQUE", "GENERAL")

    fun validate(rawText: String): PlanProposalValidation {
        // Delší výstup se ani neparsuje — nevalidní výstup (AIS-008).
        if (rawText.length > MAX_RAW_CHARS) return PlanProposalValidation.Invalid
        val json = extractJsonOutput(rawText) ?: return PlanProposalValidation.Invalid
        val root =
            try {
                mapper.readTree(json)
            } catch (_: Exception) {
                return PlanProposalValidation.Invalid
            }
        if (!root.isObject) return PlanProposalValidation.Invalid

        val summary = root.requiredText("summary", maxLength = 2000) ?: return PlanProposalValidation.Invalid
        val planTitle = root.requiredText("planTitle", maxLength = 120) ?: return PlanProposalValidation.Invalid
        val workoutsNode = root.path("workouts")
        if (!workoutsNode.isArray || workoutsNode.size() !in 1..14) return PlanProposalValidation.Invalid

        val workouts = mutableListOf<Map<String, Any?>>()
        for (workout in workoutsNode) {
            workouts += validateWorkout(workout) ?: return PlanProposalValidation.Invalid
        }

        // Kanonizace (SOV-010): jen schválená pole ve stabilním pořadí.
        return PlanProposalValidation.Valid(
            canonical =
                linkedMapOf(
                    "summary" to summary,
                    "planTitle" to planTitle,
                    "workouts" to workouts.toList(),
                ),
        )
    }

    private fun validateWorkout(workout: JsonNode): Map<String, Any?>? {
        if (!workout.isObject) return null
        val title = workout.requiredText("title", maxLength = 120) ?: return null
        val workoutType = workout.requiredText("workoutType", maxLength = 40) ?: return null
        if (workoutType !in workoutTypes) return null
        val dayOffset = workout.requiredInt("dayOffset", 0, 27) ?: return null
        val reason = workout.requiredText("reason", maxLength = 500) ?: return null
        val duration =
            if (workout.has("plannedDurationMinutes")) {
                workout.requiredInt("plannedDurationMinutes", 1, 600) ?: return null
            } else {
                null
            }

        val exercises = mutableListOf<Map<String, Any?>>()
        if (workout.has("exercises")) {
            val exercisesNode = workout.path("exercises")
            if (!exercisesNode.isArray || exercisesNode.size() > 20) return null
            for (exercise in exercisesNode) {
                exercises += validateExercise(exercise) ?: return null
            }
        }

        return buildMap {
            put("title", title)
            put("workoutType", workoutType)
            put("dayOffset", dayOffset)
            put("reason", reason)
            if (duration != null) put("plannedDurationMinutes", duration)
            if (exercises.isNotEmpty()) put("exercises", exercises.toList())
        }
    }

    private fun validateExercise(exercise: JsonNode): Map<String, Any?>? {
        if (!exercise.isObject) return null
        val title = exercise.requiredText("title", maxLength = 120) ?: return null
        val sets = exercise.requiredInt("sets", 1, 20) ?: return null
        val repetitions = exercise.requiredInt("repetitions", 1, 100) ?: return null
        val weight =
            if (exercise.has("weightKg")) {
                val value = exercise.path("weightKg").asDouble(Double.NaN)
                if (value.isNaN() || value < 0 || value > 500) return null
                value
            } else {
                null
            }
        return buildMap {
            put("title", title)
            put("sets", sets)
            put("repetitions", repetitions)
            if (weight != null) put("weightKg", weight)
        }
    }
}
