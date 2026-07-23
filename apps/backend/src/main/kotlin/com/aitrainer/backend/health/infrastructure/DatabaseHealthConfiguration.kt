package com.aitrainer.backend.health.infrastructure

import com.aitrainer.backend.health.application.ReadinessIndicator
import javax.sql.DataSource
import org.flywaydb.core.Flyway
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.core.JdbcTemplate

/**
 * Composition databázových readiness adapterů (R0-05). PostgreSQL a
 * validní Flyway stav jsou od R0-05 povinné závislosti prostředí —
 * indikátory se přidávají k portu z R0-04 bez změny veřejného kontraktu.
 */
@Configuration
class DatabaseHealthConfiguration {

    @Bean
    fun databaseReadinessIndicator(dataSource: DataSource): ReadinessIndicator {
        val jdbcTemplate = JdbcTemplate(dataSource)
        // Bounded dotaz, aby readiness neblokoval při pomalé databázi.
        jdbcTemplate.queryTimeout = 2
        return DatabaseReadinessIndicator(jdbcTemplate)
    }

    @Bean
    fun migrationsReadinessIndicator(flyway: Flyway): ReadinessIndicator =
        MigrationsReadinessIndicator(flyway)
}
