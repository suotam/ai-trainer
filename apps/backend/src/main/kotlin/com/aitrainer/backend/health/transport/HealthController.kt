package com.aitrainer.backend.health.transport

import com.aitrainer.backend.health.application.HealthQueryService
import com.aitrainer.backend.health.application.ServiceNotReadyException
import org.springframework.http.CacheControl
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/**
 * Transport health endpointů (`r0-api-contract.md` §13.1): mapuje výsledek
 * application vrstvy na contract DTO, nastavuje status a headers. Žádná
 * business rozhodnutí, žádné side effects (APR-010).
 */
@RestController
@RequestMapping("/api/v1/health")
class HealthController(
    private val healthQueryService: HealthQueryService,
) {
    @GetMapping("/live")
    fun getLiveness(): ResponseEntity<LivenessResponseDto> {
        val result = healthQueryService.liveness()
        return ResponseEntity
            .ok()
            .cacheControl(CacheControl.noStore())
            .body(
                LivenessResponseDto(
                    status = "UP",
                    service = result.service,
                    timestamp = result.timestamp.toString(),
                    version = result.version,
                ),
            )
    }

    @GetMapping("/ready")
    fun getReadiness(): ResponseEntity<ReadinessResponseDto> {
        val result = healthQueryService.readiness()
        if (!result.ready) {
            throw ServiceNotReadyException()
        }
        return ResponseEntity
            .ok()
            .cacheControl(CacheControl.noStore())
            .body(
                ReadinessResponseDto(
                    status = "READY",
                    service = result.service,
                    timestamp = result.timestamp.toString(),
                    version = result.version,
                    checks = result.checks.mapValues { it.value.name },
                ),
            )
    }
}
