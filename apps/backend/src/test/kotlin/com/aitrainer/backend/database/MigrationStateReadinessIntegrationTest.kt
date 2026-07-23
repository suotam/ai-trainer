package com.aitrainer.backend.database

import com.aitrainer.backend.infrastructure.http.RequestIdSupport
import com.aitrainer.backend.testsupport.TestPostgresConfiguration
import com.jayway.jsonpath.JsonPath
import org.flywaydb.core.Flyway
import org.junit.jupiter.api.MethodOrderer
import org.junit.jupiter.api.Order
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestMethodOrder
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.resttestclient.TestRestTemplate
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.jdbc.core.JdbcTemplate
import javax.sql.DataSource
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Readiness při nevalidním migration stavu (`r0-api-contract.md` §14):
 * po řízeném rozbití schema stavu vrací readiness 503 a po nové migraci
 * se vrátí do 200 — recovery odpovídá append-only Flyway lifecycle.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
@TestMethodOrder(MethodOrderer.OrderAnnotation::class)
class MigrationStateReadinessIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var flyway: Flyway

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    @Test
    @Order(1)
    fun `nevalidni migration stav vraci readiness 503 s bezpecnym envelope`() {
        // Řízené rozbití pouze v izolovaném test containeru.
        jdbc.execute("DELETE FROM flyway_schema_history")
        jdbc.execute("DROP TABLE IF EXISTS schema_baseline")

        val response = restTemplate.getForEntity("/api/v1/health/ready", String::class.java)

        assertEquals(503, response.statusCode.value())
        assertEquals("no-store", response.headers.cacheControl)
        assertTrue(RequestIdSupport.isValid(response.headers.getFirst(RequestIdSupport.HEADER_NAME)))
        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals("SERVICE_NOT_READY", body["code"])
        listOf("Exception", "SQL", "flyway_schema_history", "jdbc").forEach {
            assertTrue(!response.body!!.contains(it), "503 envelope obsahuje interní detail '$it'")
        }
    }

    @Test
    @Order(2)
    fun `po opetovne migraci se readiness vrati na 200`() {
        flyway.migrate()

        val response = restTemplate.getForEntity("/api/v1/health/ready", String::class.java)

        assertEquals(200, response.statusCode.value())
        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(
            mapOf("application" to "UP", "database" to "UP", "migrations" to "UP"),
            body["checks"],
        )
    }
}
