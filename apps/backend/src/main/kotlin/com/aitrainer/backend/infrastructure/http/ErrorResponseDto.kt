package com.aitrainer.backend.infrastructure.http

import com.fasterxml.jackson.annotation.JsonInclude

/**
 * Standardní error envelope (`r0-api-contract.md` §7). Obsahuje pouze
 * bezpečná pole — žádné stack traces, interní třídy, SQL ani secrets.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
data class ErrorResponseDto(
    val code: String,
    val message: String,
    val requestId: String,
    val timestamp: String,
    val details: List<Map<String, Any>>? = null,
)
