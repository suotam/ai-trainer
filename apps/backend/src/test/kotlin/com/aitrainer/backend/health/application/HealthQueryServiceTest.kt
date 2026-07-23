package com.aitrainer.backend.health.application

import com.aitrainer.backend.configuration.ServiceInfoProperties
import java.time.Clock
import java.time.Instant
import java.time.ZoneOffset
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.jupiter.api.Test

class HealthQueryServiceTest {

    private val fixedInstant = Instant.parse("2026-07-23T10:00:00Z")
    private val fixedClock = Clock.fixed(fixedInstant, ZoneOffset.UTC)
    private val serviceInfo = ServiceInfoProperties(name = "ai-trainer-backend", version = "0.0.1-test")

    private fun indicator(name: String, status: CheckStatus) = object : ReadinessIndicator {
        override val name: String = name
        override fun check(): CheckStatus = status
    }

    @Test
    fun `liveness vraci service info a cas z injektovaneho clocku`() {
        val service = HealthQueryService(serviceInfo, fixedClock, emptyList())

        val result = service.liveness()

        assertEquals("ai-trainer-backend", result.service)
        assertEquals("0.0.1-test", result.version)
        assertEquals(fixedInstant, result.timestamp)
    }

    @Test
    fun `readiness je ready kdyz vsechny checky jsou UP`() {
        val service = HealthQueryService(
            serviceInfo,
            fixedClock,
            listOf(indicator("application", CheckStatus.UP)),
        )

        val result = service.readiness()

        assertTrue(result.ready)
        assertEquals(mapOf("application" to CheckStatus.UP), result.checks)
        assertEquals(fixedInstant, result.timestamp)
    }

    @Test
    fun `readiness neni ready kdyz je libovolny check DOWN`() {
        val service = HealthQueryService(
            serviceInfo,
            fixedClock,
            listOf(
                indicator("application", CheckStatus.UP),
                indicator("database", CheckStatus.DOWN),
            ),
        )

        val result = service.readiness()

        assertFalse(result.ready)
        assertEquals(CheckStatus.DOWN, result.checks["database"])
        assertEquals(CheckStatus.UP, result.checks["application"])
    }

    @Test
    fun `vyjimka checku se mapuje na DOWN bez propagace interniho detailu`() {
        val failing = object : ReadinessIndicator {
            override val name: String = "failing"
            override fun check(): CheckStatus = error("internal detail must not leak")
        }
        val service = HealthQueryService(serviceInfo, fixedClock, listOf(failing))

        val result = service.readiness()

        assertFalse(result.ready)
        assertEquals(CheckStatus.DOWN, result.checks["failing"])
    }

    @Test
    fun `readiness bez indikatoru neni ready`() {
        val service = HealthQueryService(serviceInfo, fixedClock, emptyList())

        assertFalse(service.readiness().ready)
    }
}
