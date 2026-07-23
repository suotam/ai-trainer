package com.aitrainer.backend.health.transport

import com.aitrainer.backend.health.application.CheckStatus
import com.aitrainer.backend.health.application.ReadinessIndicator
import com.aitrainer.backend.infrastructure.http.RequestIdSupport
import com.jayway.jsonpath.JsonPath
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.boot.resttestclient.TestRestTemplate
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate
import org.springframework.context.annotation.Bean

/**
 * Failure-path readiness (`r0-api-contract.md` §14, QTR-007): nedostupná
 * povinná závislost se simuluje test-registrovaným indikátorem — skutečná
 * databázová závislost vznikne až v R0-05 a tento slice ji nepředstírá.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
class ReadinessFailureIntegrationTest {

    @TestConfiguration
    class FailingDependencyConfiguration {
        @Bean
        fun failingReadinessIndicator(): ReadinessIndicator = object : ReadinessIndicator {
            override val name: String = "test-required-dependency"
            override fun check(): CheckStatus = CheckStatus.DOWN
        }
    }

    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Test
    fun `readiness vraci 503 s bezpecnym envelope pri nedostupne povinne zavislosti`() {
        val response = restTemplate.getForEntity("/api/v1/health/ready", String::class.java)

        assertEquals(503, response.statusCode.value())
        assertEquals("no-store", response.headers.cacheControl)
        val headerRequestId = response.headers.getFirst(RequestIdSupport.HEADER_NAME)
        assertTrue(RequestIdSupport.isValid(headerRequestId))

        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(setOf("code", "message", "requestId", "timestamp"), body.keys)
        assertEquals("SERVICE_NOT_READY", body["code"])
        assertEquals(headerRequestId, body["requestId"])
        listOf("Exception", "com.aitrainer", "stackTrace", "SQL", "test-required-dependency").forEach {
            assertTrue(!response.body!!.contains(it), "503 envelope obsahuje interní detail '$it'")
        }
    }

    @Test
    fun `liveness zustava 200 i pri selhavajici readiness zavislosti`() {
        val response = restTemplate.getForEntity("/api/v1/health/live", String::class.java)

        assertEquals(200, response.statusCode.value())
    }
}
