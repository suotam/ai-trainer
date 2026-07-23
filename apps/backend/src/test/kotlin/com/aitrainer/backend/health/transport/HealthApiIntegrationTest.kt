package com.aitrainer.backend.health.transport

import com.aitrainer.backend.infrastructure.http.RequestIdSupport
import com.jayway.jsonpath.JsonPath
import java.time.Instant
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.resttestclient.TestRestTemplate
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.ResponseEntity

/**
 * Integration testy R0 health API proti skutečnému HTTP serveru
 * (`r0-api-contract.md` §14, test-strategy §7.2). PostgreSQL readiness
 * scénáře doplní R0-05, až se databáze stane povinnou závislostí.
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureTestRestTemplate
class HealthApiIntegrationTest {

    @Autowired
    lateinit var restTemplate: TestRestTemplate

    private fun get(path: String, headers: Map<String, String> = emptyMap()): ResponseEntity<String> {
        val httpHeaders = HttpHeaders()
        headers.forEach { (name, value) -> httpHeaders.set(name, value) }
        return restTemplate.exchange(path, HttpMethod.GET, HttpEntity<Void>(httpHeaders), String::class.java)
    }

    private fun assertNoInternalDetails(body: String) {
        listOf("Exception", "com.aitrainer", "stackTrace", "SQL", "jdbc", "/Users/").forEach { forbidden ->
            assertTrue(!body.contains(forbidden), "Response obsahuje interní detail '$forbidden': $body")
        }
    }

    @Test
    fun `liveness vraci 200 s poli kontraktu, request id a no-store`() {
        val response = get("/api/v1/health/live")

        assertEquals(200, response.statusCode.value())
        assertTrue(response.headers.contentType.toString().startsWith("application/json"))
        assertEquals("no-store", response.headers.cacheControl)
        assertTrue(RequestIdSupport.isValid(response.headers.getFirst(RequestIdSupport.HEADER_NAME)))

        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(setOf("status", "service", "timestamp", "version"), body.keys)
        assertEquals("UP", body["status"])
        assertEquals("ai-trainer-backend", body["service"])
        assertEquals("0.0.1-dev", body["version"])
        assertNotNull(Instant.parse(body["timestamp"] as String))
        assertNoInternalDetails(response.body!!)
    }

    @Test
    fun `readiness vraci 200 READY s pravdivym bootstrap checkem`() {
        val response = get("/api/v1/health/ready")

        assertEquals(200, response.statusCode.value())
        assertEquals("no-store", response.headers.cacheControl)
        assertTrue(RequestIdSupport.isValid(response.headers.getFirst(RequestIdSupport.HEADER_NAME)))

        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(setOf("status", "service", "timestamp", "version", "checks"), body.keys)
        assertEquals("READY", body["status"])
        assertEquals(mapOf("application" to "UP"), body["checks"])
        assertNoInternalDetails(response.body!!)
    }

    @Test
    fun `validni prichozi request id se zachova`() {
        val response = get("/api/v1/health/live", mapOf(RequestIdSupport.HEADER_NAME to "incoming-valid-42"))

        assertEquals("incoming-valid-42", response.headers.getFirst(RequestIdSupport.HEADER_NAME))
    }

    @Test
    fun `nevalidni prichozi request id se nahradi validnim`() {
        val invalid = "x".repeat(200)
        val response = get("/api/v1/health/live", mapOf(RequestIdSupport.HEADER_NAME to invalid))

        val returned = response.headers.getFirst(RequestIdSupport.HEADER_NAME)
        assertNotEquals(invalid, returned)
        assertTrue(RequestIdSupport.isValid(returned))
    }

    @Test
    fun `neexistujici route vraci bezpecny 404 envelope s korelaci`() {
        val response = get("/api/v1/nonexistent")

        assertEquals(404, response.statusCode.value())
        val headerRequestId = response.headers.getFirst(RequestIdSupport.HEADER_NAME)
        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(setOf("code", "message", "requestId", "timestamp"), body.keys)
        assertEquals("RESOURCE_NOT_FOUND", body["code"])
        assertEquals(headerRequestId, body["requestId"])
        assertNoInternalDetails(response.body!!)
    }

    @Test
    fun `nepodporovana metoda vraci 405 envelope`() {
        val response = restTemplate.exchange(
            "/api/v1/health/live",
            HttpMethod.POST,
            HttpEntity<Void>(HttpHeaders()),
            String::class.java,
        )

        assertEquals(405, response.statusCode.value())
        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals("METHOD_NOT_ALLOWED", body["code"])
        assertNoInternalDetails(response.body!!)
    }

    @Test
    fun `health endpointy jsou bez side effects a opakovatelne`() {
        repeat(2) {
            assertEquals(200, get("/api/v1/health/live").statusCode.value())
            assertEquals(200, get("/api/v1/health/ready").statusCode.value())
        }
    }
}
