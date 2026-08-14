package com.aitrainer.backend.sync

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
 * Integration testy R6-04 tombstonů (C44) nad skutečným PostgreSQL:
 * DELETE_ENTITY úspěch (tombstone, ne fyzické smazání — DTS-001), replay
 * idempotence, version conflict, ownership, mimo scope a propagace přes
 * pull s `deleted: true` (DTS-010).
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class DeleteTombstoneIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private data class Principal(
        val accessToken: String,
        val installationId: String,
    )

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

    private fun registerPrincipalWithDevice(): Principal {
        val registration =
            exchange(
                HttpMethod.POST,
                "/api/v1/auth/registrations",
                body = mapOf("email" to "del-${UUID.randomUUID()}@example.com", "password" to "password-123"),
                headers = mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, registration.statusCode.value())
        val accessToken = JsonPath.parse(registration.body).read<String>("$.accessToken")
        val installationId = UUID.randomUUID().toString()
        assertEquals(
            201,
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/$installationId",
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "13"),
                accessToken = accessToken,
            ).statusCode.value(),
        )
        return Principal(accessToken, installationId)
    }

    private fun pushOne(
        principal: Principal,
        operation: Map<String, Any?>,
    ): ResponseEntity<String> =
        exchange(
            HttpMethod.POST,
            "/api/v1/sync/push",
            body = mapOf("installationId" to principal.installationId, "operations" to listOf(operation)),
            accessToken = principal.accessToken,
        )

    private fun operation(
        entityType: String,
        entityId: String,
        operationType: String,
        payload: Map<String, Any?> = emptyMap(),
        expectedServerVersion: Long? = null,
        idempotencyKey: String = "op-${UUID.randomUUID()}",
    ): Map<String, Any?> =
        mapOf(
            "operationId" to "outbox-$entityId-$operationType",
            "idempotencyKey" to idempotencyKey,
            "sequence" to 1,
            "operationType" to operationType,
            "entityType" to entityType,
            "entityId" to entityId,
            "payload" to payload,
            "expectedServerVersion" to expectedServerVersion,
        )

    @Test
    fun `DELETE oznaci tombstone bez fyzickeho smazani, replay je idempotentni a pull ho propaguje`() {
        val principal = registerPrincipalWithDevice()
        val ruleId = UUID.randomUUID().toString()
        val create = operation("AVAILABILITY_RULE", ruleId, "CREATE_ENTITY", mapOf("dayOfWeek" to "MON", "level" to "AVAILABLE"))
        assertEquals("SUCCESS", JsonPath.parse(pushOne(principal, create).body).read("$.results[0].result"))

        val deleteKey = "del-${UUID.randomUUID()}"
        val delete = operation("AVAILABILITY_RULE", ruleId, "DELETE_ENTITY", expectedServerVersion = 1, idempotencyKey = deleteKey)
        val deleted = pushOne(principal, delete)
        assertEquals("SUCCESS", JsonPath.parse(deleted.body).read("$.results[0].result"))
        assertEquals(2, JsonPath.parse(deleted.body).read<Int>("$.results[0].serverVersion"))

        // Tombstone, ne fyzické smazání (DTS-001): řádek s payloadem zůstává.
        val row =
            jdbc.queryForMap(
                "SELECT deleted, server_version, payload::text AS payload FROM synced_availability_rule WHERE id = ?::uuid",
                ruleId,
            )
        assertEquals(true, row["deleted"])
        assertEquals(2L, row["server_version"])
        assertTrue("$row".contains("MON"), "payload má zůstat (audit stopa)")

        // Replay = ALREADY_APPLIED (DTS-004).
        assertEquals("ALREADY_APPLIED", JsonPath.parse(pushOne(principal, delete).body).read("$.results[0].result"))

        // Pull propaguje deleted: true (DTS-010).
        val pull =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/pull",
                body =
                    mapOf(
                        "installationId" to principal.installationId,
                        "cursors" to listOf(mapOf("entityType" to "AVAILABILITY_RULE")),
                    ),
                accessToken = principal.accessToken,
            )
        val pullJson = JsonPath.parse(pull.body)
        assertEquals(listOf(ruleId), pullJson.read("$.items[*].entityId"))
        assertEquals(true, pullJson.read<Boolean>("$.items[0].deleted"))
        assertEquals(2, pullJson.read<Int>("$.items[0].serverVersion"))
    }

    @Test
    fun `DELETE odmitnuti - spatna verze, cizi ucet, neexistujici cil a mimo scope (DTS-002-003-012)`() {
        val principal = registerPrincipalWithDevice()
        val ruleId = UUID.randomUUID().toString()
        pushOne(principal, operation("AVAILABILITY_RULE", ruleId, "CREATE_ENTITY", mapOf("dayOfWeek" to "TUE", "level" to "LIMITED")))

        // Špatná očekávaná verze → VERSION_CONFLICT (DTS-003).
        val conflict = pushOne(principal, operation("AVAILABILITY_RULE", ruleId, "DELETE_ENTITY", expectedServerVersion = 99))
        assertEquals("VERSION_CONFLICT", JsonPath.parse(conflict.body).read("$.results[0].result"))

        // Cizí účet → PERMISSION_DENIED (DTS-012).
        val other = registerPrincipalWithDevice()
        val foreign = pushOne(other, operation("AVAILABILITY_RULE", ruleId, "DELETE_ENTITY", expectedServerVersion = 1))
        assertEquals("PERMISSION_DENIED", JsonPath.parse(foreign.body).read("$.results[0].result"))

        // Neexistující cíl → VALIDATION_FAILED.
        val missing =
            pushOne(principal, operation("AVAILABILITY_RULE", UUID.randomUUID().toString(), "DELETE_ENTITY", expectedServerVersion = 1))
        assertEquals("VALIDATION_FAILED", JsonPath.parse(missing.body).read("$.results[0].result"))

        // Mimo P0 scope → VALIDATION_FAILED (DTS-002).
        val sportId = UUID.randomUUID().toString()
        pushOne(principal, operation("USER_SPORT", sportId, "CREATE_ENTITY", mapOf("sportCode" to "RUNNING", "role" to "PRIMARY")))
        val unsupported = pushOne(principal, operation("USER_SPORT", sportId, "DELETE_ENTITY", expectedServerVersion = 1))
        assertEquals("VALIDATION_FAILED", JsonPath.parse(unsupported.body).read("$.results[0].result"))
        // Řádek zůstal nedotčený.
        assertEquals(
            1L,
            jdbc.queryForObject("SELECT server_version FROM synced_user_sport WHERE id = ?::uuid", Long::class.java, sportId),
        )
    }
}
