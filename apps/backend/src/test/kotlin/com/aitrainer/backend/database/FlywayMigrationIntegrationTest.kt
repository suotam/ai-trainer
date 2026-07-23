package com.aitrainer.backend.database

import com.aitrainer.backend.testsupport.TestPostgresConfiguration
import org.flywaydb.core.Flyway
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.jdbc.core.JdbcTemplate
import javax.sql.DataSource
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Migration testy od prázdné databáze (test-strategy §9.2, QTR-005):
 * čistý PostgreSQL container dosáhne validního stavu výhradně migracemi
 * (Flyway běží při startu contextu) a opakovaná migrace je bezpečná.
 */
@SpringBootTest
@Import(TestPostgresConfiguration::class)
class FlywayMigrationIntegrationTest {
    @Autowired
    lateinit var flyway: Flyway

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    @Test
    fun `flyway projde od prazdne databaze a vytvori baseline schema`() {
        val baselineVersion =
            jdbc.queryForObject(
                "SELECT baseline_version FROM schema_baseline WHERE id = 1",
                String::class.java,
            )
        assertEquals("r0", baselineVersion)
    }

    @Test
    fun `schema history obsahuje uspesnou migraci V1`() {
        val current = assertNotNull(flyway.info().current())
        assertEquals("1", current.version.version)
        assertTrue(current.state.isApplied)
        assertTrue(flyway.info().pending().isEmpty())
    }

    @Test
    fun `opakovana migrace nad jiz migrovanou databazi je bezpecna`() {
        val result = flyway.migrate()

        assertEquals(0, result.migrationsExecuted)
        assertTrue(result.success)
        assertEquals(
            1,
            jdbc.queryForObject("SELECT count(*) FROM schema_baseline", Int::class.java),
        )
    }
}
