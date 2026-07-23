package com.aitrainer.backend.health.infrastructure

import com.aitrainer.backend.health.application.CheckStatus
import com.aitrainer.backend.health.application.ReadinessIndicator
import org.flywaydb.core.Flyway

/**
 * Flyway schema-state check (`r0-api-contract.md` §6.2): schema je validní,
 * pouze pokud existuje úspěšně aplikovaná aktuální migrace a žádná
 * nečeká. Check pouze čte stav — health endpoint nesmí migrovat ani jinak
 * měnit stav (APR-010).
 */
class MigrationsReadinessIndicator(private val flyway: Flyway) : ReadinessIndicator {

    override val name: String = "migrations"

    override fun check(): CheckStatus {
        val info = flyway.info()
        val current = info.current()
        val applied = current != null && current.state.isApplied
        val nothingPending = info.pending().isEmpty()
        return if (applied && nothingPending) CheckStatus.UP else CheckStatus.DOWN
    }
}
