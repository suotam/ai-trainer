package com.aitrainer.backend.health.infrastructure

import com.aitrainer.backend.health.application.CheckStatus
import com.aitrainer.backend.health.application.ReadinessIndicator
import org.springframework.jdbc.core.JdbcTemplate

/**
 * PostgreSQL connectivity check (`r0-api-contract.md` §6.2). Selhání se
 * v [com.aitrainer.backend.health.application.HealthQueryService] mapuje
 * na DOWN — interní výjimka nikdy neopustí health boundary (APR-004).
 */
class DatabaseReadinessIndicator(private val jdbcTemplate: JdbcTemplate) : ReadinessIndicator {

    override val name: String = "database"

    override fun check(): CheckStatus {
        jdbcTemplate.queryForObject("SELECT 1", Int::class.java)
        return CheckStatus.UP
    }
}
