package com.aitrainer.backend.sync.domain

import java.util.UUID

/**
 * R2-05 entity scope (C10 §5.2) s registry vazeb dle R1 hierarchie
 * (C6 §8.4): tabulka, parent sloupec a název parent pole v payloadu.
 * Nové entity se přidávají kontraktem, ne implementací (SPC-013).
 */
enum class SyncEntityType(
    val tableName: String,
    val parentColumn: String?,
    val parentPayloadField: String?,
) {
    WORKOUT_INSTANCE("synced_workout_instance", null, null),
    WORKOUT_SESSION("synced_workout_session", "workout_instance_id", "workoutInstanceId"),
    STEP_PERFORMANCE("synced_step_performance", "workout_session_id", "workoutSessionId"),
    SET_PERFORMANCE("synced_set_performance", "step_performance_id", "stepPerformanceId"),
    WORKOUT_FEEDBACK("synced_workout_feedback", "workout_session_id", "workoutSessionId"),
    ACTIVITY_SUMMARY("synced_activity_summary", "workout_session_id", "workoutSessionId"),

    // R3-07 (C24 §2): R3 entity bez serverových parentů — device-local
    // reference jsou součást neprůhledného payloadu (SXC-003).
    USER_SPORT("synced_user_sport", null, null),
    GOAL("synced_goal", null, null),
    AVAILABILITY_RULE("synced_availability_rule", null, null),
    EQUIPMENT_ITEM("synced_equipment_item", null, null),
    CONSTRAINT_ITEM("synced_constraint", null, null),
    TRAINING_PLAN("synced_training_plan", null, null),
    CALENDAR_CHANGE("synced_calendar_change", null, null),
    MANUAL_ACTIVITY("synced_activity", null, null),
    ;

    /** Parent typ dle R1 hierarchie; enum konstanty se odkazují jménem, aby nevznikla dopředná reference. */
    val parentType: SyncEntityType?
        get() =
            when (this) {
                WORKOUT_INSTANCE -> null

                WORKOUT_SESSION -> WORKOUT_INSTANCE

                STEP_PERFORMANCE -> WORKOUT_SESSION

                SET_PERFORMANCE -> STEP_PERFORMANCE

                WORKOUT_FEEDBACK -> WORKOUT_SESSION

                ACTIVITY_SUMMARY -> WORKOUT_SESSION

                USER_SPORT, GOAL, AVAILABILITY_RULE, EQUIPMENT_ITEM,
                CONSTRAINT_ITEM, TRAINING_PLAN, CALENDAR_CHANGE, MANUAL_ACTIVITY,
                -> null
            }
}

/** R2-05 podmnožina `SyncOperationType` (C10 §5.1). */
enum class SyncOperationKind {
    CREATE_ENTITY,
    UPDATE_ENTITY,
}

/** R2-05 podmnožina `SyncResult` (C10 §7). */
enum class SyncItemResult {
    SUCCESS,
    ALREADY_APPLIED,
    VERSION_CONFLICT,
    VALIDATION_FAILED,
    PERMISSION_DENIED,
    DEPENDENCY_FAILED,
}

/** Relační kostra synced entity (C6 §8.4) — payload je pro server neprůhledný. */
data class SyncedEntityRow(
    val id: UUID,
    val accountId: UUID,
    val serverVersion: Long,
)

/** Per-item výsledek push operace (C10 §7). */
data class SyncItemOutcome(
    val operationId: String,
    val result: SyncItemResult,
    val serverVersion: Long?,
)
