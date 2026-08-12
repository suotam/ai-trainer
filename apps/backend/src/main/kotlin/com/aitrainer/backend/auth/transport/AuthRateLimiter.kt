package com.aitrainer.backend.auth.transport

import com.aitrainer.backend.auth.AuthProperties
import com.aitrainer.backend.infrastructure.http.ApiException
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Component
import java.time.Clock
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

/**
 * In-memory fixed-window rate limiting baseline veřejných auth endpointů
 * (SAR-013, AAC-013). Klíč je klient (adresa) + operace; překročení vrací
 * RATE_LIMITED s Retry-After (C4 §9). Distribuovaný limiter je vědomě
 * mimo R2 baseline — vznikne až s produkčním deploymentem.
 */
@Component
class AuthRateLimiter(
    private val properties: AuthProperties,
    private val clock: Clock,
) {
    private data class Window(
        val startEpochMs: Long,
        val count: AtomicInteger,
    )

    private val windows = ConcurrentHashMap<String, Window>()

    fun enforce(
        operation: String,
        clientKey: String,
    ) {
        val limit = properties.rateLimit.limit
        val windowMs = properties.rateLimit.window.toMillis()
        val nowMs = clock.millis()
        val key = "$operation:$clientKey"
        val window =
            windows.compute(key) { _, existing ->
                if (existing == null || nowMs - existing.startEpochMs >= windowMs) {
                    Window(nowMs, AtomicInteger(0))
                } else {
                    existing
                }
            }!!
        if (window.count.incrementAndGet() > limit) {
            val retryAfterSeconds = ((window.startEpochMs + windowMs - nowMs) / 1000).coerceAtLeast(1)
            throw ApiException(
                status = HttpStatus.TOO_MANY_REQUESTS,
                code = "RATE_LIMITED",
                message = "Too many requests. Retry later.",
                retryAfterSeconds = retryAfterSeconds,
            )
        }
    }
}
