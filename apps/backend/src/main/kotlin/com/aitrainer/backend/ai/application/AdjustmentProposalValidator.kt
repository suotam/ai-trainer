package com.aitrainer.backend.ai.application

import org.springframework.stereotype.Component
import tools.jackson.databind.JsonNode
import tools.jackson.databind.json.JsonMapper

/**
 * Deterministická validace `adjustment-proposal-schema-v1` (C37 §3):
 * seznam operací MOVE/CANCEL/REPLACE/ADD s povinným reason per operace
 * (ASJ-002), tvarová tabulka přesně (ASJ-003), target by-value (ASJ-004),
 * kanonizace bez oprav (ASJ-001). Čistá funkce (SOV-004 vzor).
 */
@Component
class AdjustmentProposalValidator {
    companion object {
        private const val MAX_RAW_CHARS = 100_000
        private const val MAX_OPERATIONS = 10
    }

    private val mapper = JsonMapper.builder().build()

    private val workoutTypes = setOf("STRENGTH", "ENDURANCE", "MOBILITY", "TECHNIQUE", "GENERAL")
    private val operationKinds = setOf("MOVE", "CANCEL", "REPLACE", "ADD")

    fun validate(rawText: String): PlanProposalValidation {
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
        val operationsNode = root.path("operations")
        if (!operationsNode.isArray || operationsNode.size() !in 1..MAX_OPERATIONS) {
            return PlanProposalValidation.Invalid
        }
        val operations = mutableListOf<Map<String, Any?>>()
        for (operation in operationsNode) {
            operations += validateOperation(operation) ?: return PlanProposalValidation.Invalid
        }
        return PlanProposalValidation.Valid(
            canonical =
                linkedMapOf(
                    "summary" to summary,
                    "operations" to operations.toList(),
                ),
        )
    }

    private fun validateOperation(operation: JsonNode): Map<String, Any?>? {
        if (!operation.isObject) return null
        val kind = operation.requiredText("operation", maxLength = 20) ?: return null
        if (kind !in operationKinds) return null
        // Vysvětlitelnost je povinná per operace (ASJ-002).
        val reason = operation.requiredText("reason", maxLength = 500) ?: return null

        // Tvarová tabulka C37 §3 (ASJ-003): povinná i zakázaná pole přesně.
        val hasTarget = operation.has("target")
        val hasWorkout = operation.has("workout")
        val hasToDay = operation.has("toDayOffset")
        val shapeOk =
            when (kind) {
                "MOVE" -> hasTarget && hasToDay && !hasWorkout
                "CANCEL" -> hasTarget && !hasToDay && !hasWorkout
                "REPLACE" -> hasTarget && hasWorkout && !hasToDay
                "ADD" -> hasWorkout && !hasTarget && !hasToDay
                else -> false
            }
        if (!shapeOk) return null

        val target = if (hasTarget) validateTarget(operation.path("target")) ?: return null else null
        val toDayOffset = if (hasToDay) operation.requiredInt("toDayOffset", 0, 27) ?: return null else null
        val workout =
            if (hasWorkout) {
                // REPLACE dědí den z targetu — dayOffset je zakázán (C37 §3).
                validateWorkout(operation.path("workout"), requireDayOffset = kind == "ADD")
                    ?: return null
            } else {
                null
            }

        return buildMap {
            put("operation", kind)
            put("reason", reason)
            if (target != null) put("target", target)
            if (toDayOffset != null) put("toDayOffset", toDayOffset)
            if (workout != null) put("workout", workout)
        }
    }

    /** Target by-value z kontextového týdne (ASJ-004): dayOffset 0–6 + title. */
    private fun validateTarget(target: JsonNode): Map<String, Any?>? {
        if (!target.isObject) return null
        val dayOffset = target.requiredInt("dayOffset", 0, 6) ?: return null
        val title = target.requiredText("title", maxLength = 120) ?: return null
        return linkedMapOf("dayOffset" to dayOffset, "title" to title)
    }

    private fun validateWorkout(
        workout: JsonNode,
        requireDayOffset: Boolean,
    ): Map<String, Any?>? {
        if (!workout.isObject) return null
        val title = workout.requiredText("title", maxLength = 120) ?: return null
        val workoutType = workout.requiredText("workoutType", maxLength = 40) ?: return null
        if (workoutType !in workoutTypes) return null
        val dayOffset =
            if (requireDayOffset) {
                workout.requiredInt("dayOffset", 0, 27) ?: return null
            } else {
                if (workout.has("dayOffset")) return null
                null
            }
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
            if (dayOffset != null) put("dayOffset", dayOffset)
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
