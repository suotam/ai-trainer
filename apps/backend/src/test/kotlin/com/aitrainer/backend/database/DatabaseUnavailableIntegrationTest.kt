package com.aitrainer.backend.database

import com.aitrainer.backend.infrastructure.http.RequestIdSupport
import com.jayway.jsonpath.JsonPath
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.resttestclient.TestRestTemplate
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.testcontainers.service.connection.ServiceConnection
import org.springframework.context.annotation.Bean
import org.springframework.test.annotation.DirtiesContext
import org.testcontainers.containers.PostgreSQLContainer

/**
 * Failure path nedostupné databáze (`r0-api-contract.md` §14, QTR-007):
 * po zastavení PostgreSQL za běhu aplikace liveness zůstává 200 a
 * readiness přejde na 503 bez úniku interních detailů. Používá vlastní
 * container, aby zastavení neovlivnilo ostatní testy; context se po
 * testu zahodí.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["spring.datasource.hikari.connection-timeout=1500"],
)
@AutoConfigureTestRestTemplate
@DirtiesContext
class DatabaseUnavailableIntegrationTest {

    @TestConfiguration(proxyBeanMethods = false)
    class DedicatedPostgresConfiguration {
        @Bean
        @ServiceConnection
        fun dedicatedPostgres(): PostgreSQLContainer<*> =
            PostgreSQLContainer("postgres:17-alpine")
                .withDatabaseName("aitrainer_stop_test")
                .withUsername("aitrainer_test")
                .withPassword("aitrainer_test_only")
    }

    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var container: PostgreSQLContainer<*>

    @Test
    fun `po zastaveni databaze je liveness 200 a readiness 503 bez internich detailu`() {
        // Baseline: s běžící databází je instance ready.
        assertEquals(
            200,
            restTemplate.getForEntity("/api/v1/health/ready", String::class.java).statusCode.value(),
        )

        container.stop()

        val live = restTemplate.getForEntity("/api/v1/health/live", String::class.java)
        assertEquals(200, live.statusCode.value())

        val ready = restTemplate.getForEntity("/api/v1/health/ready", String::class.java)
        assertEquals(503, ready.statusCode.value())
        assertEquals("no-store", ready.headers.cacheControl)
        assertTrue(RequestIdSupport.isValid(ready.headers.getFirst(RequestIdSupport.HEADER_NAME)))
        val body = JsonPath.parse(ready.body).read<Map<String, Any>>("$")
        assertEquals("SERVICE_NOT_READY", body["code"])
        listOf("Exception", "SQL", "jdbc", "postgres", "Connection").forEach {
            assertTrue(!ready.body!!.contains(it), "503 envelope obsahuje interní detail '$it'")
        }
    }
}
