package com.aitrainer.backend.ai

import com.aitrainer.backend.testsupport.TestPostgresConfiguration
import com.jayway.jsonpath.JsonPath
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.resttestclient.TestRestTemplate
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.jdbc.core.JdbcTemplate
import java.util.UUID
import javax.sql.DataSource
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Integration testy R4-03 AI plan proposal endpointu (C28) nad skutečným
 * PostgreSQL s fake providerem (AGW-004): úspěch s trojicí verzí, auth
 * required, ohraničený kontext a audit bez obsahu.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class PlanProposalApiIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private fun exchange(
        method: HttpMethod,
        path: String,
        body: Map<String, Any?>? = null,
        accessToken: String? = null,
        headers: Map<String, String> = emptyMap(),
    ): ResponseEntity<String> {
        val httpHeaders = HttpHeaders()
        if (body != null) httpHeaders.contentType = MediaType.APPLICATION_JSON
        if (accessToken != null) httpHeaders.setBearerAuth(accessToken)
        headers.forEach { (name, value) -> httpHeaders.set(name, value) }
        return restTemplate.exchange(path, method, HttpEntity(body, httpHeaders), String::class.java)
    }

    private fun registerAccount(): Pair<String, String> {
        val registration =
            exchange(
                HttpMethod.POST,
                "/api/v1/auth/registrations",
                body = mapOf("email" to "ai-${UUID.randomUUID()}@example.com", "password" to "password-123"),
                headers = mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, registration.statusCode.value())
        val json = JsonPath.parse(registration.body)
        return json.read<String>("$.accountId") to json.read("$.accessToken")
    }

    private val context =
        mapOf(
            "requestType" to "PLAN_PROPOSAL",
            "sports" to listOf(mapOf("sport" to "CLIMBING", "role" to "PRIMARY")),
            "marker" to "SENSITIVE-CONTEXT-MARKER",
        )

    @Test
    fun `uspesny navrh vraci kanonicky payload s trojici verzi a audituje bez obsahu`() {
        val (accountId, accessToken) = registerAccount()

        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/ai/plan-proposals",
                body = mapOf("context" to context),
                accessToken = accessToken,
            )

        assertEquals(200, response.statusCode.value())
        val json = JsonPath.parse(response.body)
        assertEquals("plan-proposal-v1", json.read("$.promptVersion"))
        assertEquals("plan-proposal-schema-v1", json.read("$.schemaVersion"))
        assertEquals("fake-model", json.read("$.modelId"))
        // Fake provider fixture prošla validací (C28) a je kanonická.
        assertTrue(json.read<List<Any>>("$.proposal.workouts").isNotEmpty())
        assertTrue(json.read<String>("$.proposal.summary").isNotBlank())

        // Audit události bez obsahu kontextu (PAA-007/008).
        val actions =
            jdbc.queryForList(
                "SELECT action FROM audit_event WHERE principal_account_id = ?::uuid ORDER BY occurred_at, action",
                String::class.java,
                accountId,
            )
        assertTrue(actions.contains("AiProposalRequested"))
        assertTrue(actions.contains("AiProposalGenerated"))
        val auditDump =
            jdbc
                .queryForList("SELECT * FROM audit_event WHERE principal_account_id = ?::uuid", accountId)
                .joinToString()
        assertTrue(!auditDump.contains("SENSITIVE-CONTEXT-MARKER"), "audit nese obsah kontextu")
    }

    @Test
    fun `bez access session je pozadavek odmitnut kanonickym envelope`() {
        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/ai/plan-proposals",
                body = mapOf("context" to context),
            )
        assertEquals(401, response.statusCode.value())
        assertTrue(response.body!!.contains("\"code\""))
    }

    @Test
    fun `prilis velky kontext je odmitnut jako INVALID_REQUEST (ACX-010)`() {
        val (_, accessToken) = registerAccount()
        val oversized = mapOf("blob" to "x".repeat(40_000))

        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/ai/plan-proposals",
                body = mapOf("context" to oversized),
                accessToken = accessToken,
            )

        assertEquals(400, response.statusCode.value())
        assertEquals("INVALID_REQUEST", JsonPath.parse(response.body).read("$.code"))
    }
}
