package com.aitrainer.backend.health.transport

/**
 * Transportní DTO kontraktu `packages/contracts/openapi/ai-trainer-api.yaml`.
 * Nejsou doménové entity (APR-012). Timestamp je RFC 3339 UTC string.
 */
data class LivenessResponseDto(
    val status: String,
    val service: String,
    val timestamp: String,
    val version: String,
)

data class ReadinessResponseDto(
    val status: String,
    val service: String,
    val timestamp: String,
    val version: String,
    val checks: Map<String, String>,
)
