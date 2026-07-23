package com.aitrainer.backend.health.application

import com.aitrainer.backend.configuration.ServiceInfoProperties
import java.time.Clock
import java.time.Instant

data class LivenessResult(
    val service: String,
    val version: String,
    val timestamp: Instant,
)

data class ReadinessResult(
    val ready: Boolean,
    val service: String,
    val version: String,
    val timestamp: Instant,
    val checks: Map<String, CheckStatus>,
)

/**
 * Health application service (`r0-api-contract.md` §13.2): skládá bezpečný
 * výsledek z injektovaných [ReadinessIndicator] portů. Nerozhoduje podle
 * raw exception textu a nevrací interní detaily — ty patří pouze do
 * redigovaných logů.
 */
class HealthQueryService(
    private val serviceInfo: ServiceInfoProperties,
    private val clock: Clock,
    private val readinessIndicators: List<ReadinessIndicator>,
) {
    /** Liveness nesmí záviset na žádné externí závislosti (APR-003). */
    fun liveness(): LivenessResult =
        LivenessResult(
            service = serviceInfo.name,
            version = serviceInfo.version,
            timestamp = clock.instant(),
        )

    fun readiness(): ReadinessResult {
        val checks =
            readinessIndicators.associate { indicator ->
                indicator.name to safeCheck(indicator)
            }
        return ReadinessResult(
            ready = checks.isNotEmpty() && checks.values.all { it == CheckStatus.UP },
            service = serviceInfo.name,
            version = serviceInfo.version,
            timestamp = clock.instant(),
            checks = checks,
        )
    }

    /** Selhání checku je DOWN, nikdy propagovaná výjimka s interním detailem. */
    private fun safeCheck(indicator: ReadinessIndicator): CheckStatus =
        try {
            indicator.check()
        } catch (_: Exception) {
            CheckStatus.DOWN
        }
}
