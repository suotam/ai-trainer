package com.aitrainer.backend.configuration

import org.springframework.boot.context.properties.ConfigurationProperties

/**
 * Bezpečná identifikace služby pro logy a budoucí health odpovědi (R0-04).
 *
 * `version` je bezpečný release/build identifikátor podle
 * `docs/07-backend/r0-api-contract.md` §4.2 — nesmí obsahovat cesty,
 * secrets ani environment dump.
 */
@ConfigurationProperties(prefix = "aitrainer.service")
data class ServiceInfoProperties(
    val name: String = "ai-trainer-backend",
    val version: String = "0.0.1-dev",
)
