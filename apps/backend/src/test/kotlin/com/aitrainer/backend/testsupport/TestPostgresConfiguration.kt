package com.aitrainer.backend.testsupport

import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.context.annotation.Bean
import org.testcontainers.containers.PostgreSQLContainer

/**
 * Skutečný PostgreSQL pro integration testy (ADR-010, QTR-004 — žádná
 * in-memory náhražka). Sdílený container se startuje jednou pro celý JVM
 * běh; úklid zajišťuje Testcontainers Ryuk.
 */
object SharedPostgres {
    val container: PostgreSQLContainer<*> by lazy {
        PostgreSQLContainer("postgres:17-alpine")
            .withDatabaseName("aitrainer_test")
            .withUsername("aitrainer_test")
            .withPassword("aitrainer_test_only")
            .also { it.start() }
    }
}

@TestConfiguration(proxyBeanMethods = false)
class TestPostgresConfiguration {

    @Bean
    @ServiceConnection
    fun postgresContainer(): PostgreSQLContainer<*> = SharedPostgres.container
}
