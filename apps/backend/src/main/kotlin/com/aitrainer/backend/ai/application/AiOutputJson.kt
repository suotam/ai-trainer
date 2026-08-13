package com.aitrainer.backend.ai.application

import tools.jackson.databind.JsonNode

/**
 * Sdílené deterministické helpery validace strukturovaného výstupu
 * (C28/C37): fence extrakce (SOV-011) a přísné čtení polí — žádná oprava
 * ani koerce (SOV-005).
 */
internal fun extractJsonOutput(rawText: String): String? {
    val trimmed = rawText.trim()
    if (trimmed.startsWith("{")) return trimmed
    val fenced = Regex("^```(?:json)?\\s*(\\{.*})\\s*```$", RegexOption.DOT_MATCHES_ALL)
    return fenced.find(trimmed)?.groupValues?.get(1)
}

internal fun JsonNode.requiredText(
    field: String,
    maxLength: Int,
): String? {
    val node = path(field)
    if (!node.isString) return null
    val value = node.asString().trim()
    return value.takeIf { it.isNotEmpty() && it.length <= maxLength }
}

internal fun JsonNode.requiredInt(
    field: String,
    min: Int,
    max: Int,
): Int? {
    val node = path(field)
    if (!node.isIntegralNumber) return null
    return node.asInt().takeIf { it in min..max }
}
