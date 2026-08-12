package com.aitrainer.backend.auth

import org.springframework.boot.context.properties.ConfigurationProperties
import java.time.Duration

/**
 * Konfigurace R2 auth baseline. Bezpečné development defaults — krátká
 * access session (C3 §5, ISC-006), delší revokovatelná refresh session
 * a rate limiting baseline veřejných auth endpointů (SAR-013, AAC-013).
 */
@ConfigurationProperties(prefix = "aitrainer.auth")
data class AuthProperties(
    val accessTtl: Duration = Duration.ofMinutes(15),
    val refreshTtl: Duration = Duration.ofDays(30),
    val rateLimit: RateLimitProperties = RateLimitProperties(),
) {
    data class RateLimitProperties(
        /** Maximum requestů na klienta a operaci v rámci okna. */
        val limit: Int = 20,
        val window: Duration = Duration.ofMinutes(1),
    )
}
