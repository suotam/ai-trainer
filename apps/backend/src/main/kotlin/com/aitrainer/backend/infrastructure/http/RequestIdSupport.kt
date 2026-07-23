package com.aitrainer.backend.infrastructure.http

import java.util.UUID

/**
 * Validace a generování request ID podle `docs/07-backend/r0-api-contract.md`
 * §4.1 (APR-007): příchozí `X-Request-Id` se přijme pouze pokud projde
 * délkovou a znakovou validací, jinak se vygeneruje vlastní neprůhledný
 * identifikátor. Hodnota nesmí nést citlivá data.
 */
object RequestIdSupport {

    const val HEADER_NAME: String = "X-Request-Id"
    const val MDC_KEY: String = "requestId"
    const val MAX_LENGTH: Int = 128

    private val allowedPattern = Regex("^[A-Za-z0-9._-]{1,$MAX_LENGTH}$")

    fun isValid(candidate: String?): Boolean =
        candidate != null && allowedPattern.matches(candidate)

    /** Vrátí validní příchozí hodnotu, jinak nový vygenerovaný identifikátor. */
    fun resolve(candidate: String?): String =
        if (isValid(candidate)) candidate!! else generate()

    fun generate(): String = UUID.randomUUID().toString()
}
