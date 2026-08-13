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

/**
 * Integration testy R3-07 sync rozšíření (C24) nad skutečným PostgreSQL:
 * R3 typy přes existující push beze změny sémantiky — success + client ID,
 * idempotentní replay, version conflict a per-item ownership (SXC-004/005).
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class R3SyncExtensionIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private data class Principal(
        val accountId: String,
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
                body = mapOf("email" to "r3-${UUID.randomUUID()}@example.com", "password" to "password-123"),
                headers = mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, registration.statusCode.value())
        val json = JsonPath.parse(registration.body)
        val accessToken = json.read<String>("$.accessToken")
        val installationId = UUID.randomUUID().toString()
        val device =
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/$installationId",
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "10"),
                accessToken = accessToken,
            )
        assertEquals(201, device.statusCode.value())
        return Principal(
            accountId = json.read("$.accountId"),
            accessToken = accessToken,
            installationId = installationId,
        )
    }

    private fun operation(
        sequence: Long,
        entityType: String,
        entityId: String,
        payload: Map<String, Any?>,
        operationType: String = "CREATE_ENTITY",
        idempotencyKey: String = "op-${UUID.randomUUID()}",
        expectedServerVersion: Long? = null,
    ): Map<String, Any?> =
        mapOf(
            "operationId" to "outbox-$sequence-$entityId",
            "idempotencyKey" to idempotencyKey,
            "sequence" to sequence,
            "operationType" to operationType,
            "entityType" to entityType,
            "entityId" to entityId,
            "payload" to payload,
            "expectedServerVersion" to expectedServerVersion,
        )

    private fun push(
        principal: Principal,
        operations: List<Map<String, Any?>>,
    ): ResponseEntity<String> =
        exchange(
            HttpMethod.POST,
            "/api/v1/sync/push",
            body = mapOf("installationId" to principal.installationId, "operations" to operations),
            accessToken = principal.accessToken,
        )

    private fun results(response: ResponseEntity<String>): List<Map<String, Any?>> = JsonPath.parse(response.body).read("$.results")

    @Test
    fun `R3 typy se pushnou pres existujici endpoint se zachovanym client ID`() {
        val principal = registerPrincipalWithDevice()
        val sportId = UUID.randomUUID().toString()
        val goalId = UUID.randomUUID().toString()
        val planId = UUID.randomUUID().toString()
        val activityId = UUID.randomUUID().toString()

        val response =
            push(
                principal,
                listOf(
                    operation(1, "USER_SPORT", sportId, mapOf("sportCode" to "CLIMBING", "role" to "PRIMARY")),
                    operation(2, "GOAL", goalId, mapOf("title" to "7a", "goalType" to "PERFORMANCE", "userSportId" to sportId)),
                    operation(3, "TRAINING_PLAN", planId, mapOf("title" to "Podzim", "status" to "ACTIVE")),
                    operation(4, "MANUAL_ACTIVITY", activityId, mapOf("title" to "Běh", "localDate" to "2026-08-14")),
                ),
            )

        assertEquals(200, response.statusCode.value())
        assertEquals(listOf("SUCCESS", "SUCCESS", "SUCCESS", "SUCCESS"), results(response).map { it["result"] })
        // Client-generated ID zachováno (SDM-005/SXC-003), account ownership.
        listOf(
            "synced_user_sport" to sportId,
            "synced_goal" to goalId,
            "synced_training_plan" to planId,
            "synced_activity" to activityId,
        ).forEach { (table, id) ->
            assertEquals(
                1,
                jdbc.queryForObject(
                    "SELECT count(*) FROM $table WHERE id = ?::uuid AND account_id = ?::uuid",
                    Int::class.java,
                    id,
                    principal.accountId,
                ),
            )
        }
    }

    @Test
    fun `DAILY_CHECK_IN se pushne aditivnim typem s replay idempotenci (C33 par 4)`() {
        val principal = registerPrincipalWithDevice()
        val checkInId = UUID.randomUUID().toString()
        val create =
            operation(
                1,
                "DAILY_CHECK_IN",
                checkInId,
                mapOf(
                    "localDate" to "2026-08-14",
                    "energyLevel" to 4,
                    "fatigueLevel" to 2,
                    "painLevel" to 3,
                    "painAreaCode" to "SHOULDER",
                    "rowVersion" to 1,
                ),
            )

        assertEquals(listOf("SUCCESS"), results(push(principal, listOf(create))).map { it["result"] })
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM synced_daily_check_in WHERE id = ?::uuid AND account_id = ?::uuid",
                Int::class.java,
                checkInId,
                principal.accountId,
            ),
        )
        // Replay = ALREADY_APPLIED bez duplicity (SXC-005).
        assertEquals(listOf("ALREADY_APPLIED"), results(push(principal, listOf(create))).map { it["result"] })
    }

    @Test
    fun `replay R3 operace vraci ALREADY_APPLIED bez duplicity a konflikt je explicitni`() {
        val principal = registerPrincipalWithDevice()
        val sportId = UUID.randomUUID().toString()
        val create = operation(1, "USER_SPORT", sportId, mapOf("sportCode" to "RUNNING", "role" to "SECONDARY"))

        assertEquals(listOf("SUCCESS"), results(push(principal, listOf(create))).map { it["result"] })
        // Replay téže operace (stejný idempotency key + payload) — SXC-005.
        assertEquals(listOf("ALREADY_APPLIED"), results(push(principal, listOf(create))).map { it["result"] })
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM synced_user_sport WHERE id = ?::uuid",
                Int::class.java,
                sportId,
            ),
        )

        // UPDATE se špatnou očekávanou verzí → VERSION_CONFLICT (SXC-008).
        val conflict =
            results(
                push(
                    principal,
                    listOf(
                        operation(
                            2,
                            "USER_SPORT",
                            sportId,
                            mapOf("sportCode" to "RUNNING", "role" to "PRIMARY"),
                            operationType = "UPDATE_ENTITY",
                            expectedServerVersion = 99,
                        ),
                    ),
                ),
            )
        assertEquals(listOf("VERSION_CONFLICT"), conflict.map { it["result"] })
    }

    @Test
    fun `cizi R3 entita je per-item PERMISSION_DENIED bez efektu`() {
        val ownerPrincipal = registerPrincipalWithDevice()
        val attacker = registerPrincipalWithDevice()
        val goalId = UUID.randomUUID().toString()
        assertEquals(
            listOf("SUCCESS"),
            results(
                push(ownerPrincipal, listOf(operation(1, "GOAL", goalId, mapOf("title" to "Můj cíl")))),
            ).map { it["result"] },
        )

        val denied =
            results(
                push(
                    attacker,
                    listOf(
                        operation(
                            1,
                            "GOAL",
                            goalId,
                            mapOf("title" to "Převzatý cíl"),
                            operationType = "UPDATE_ENTITY",
                        ),
                    ),
                ),
            )
        assertEquals(listOf("PERMISSION_DENIED"), denied.map { it["result"] })
        // Data vlastníka nedotčená.
        assertEquals(
            ownerPrincipal.accountId,
            jdbc.queryForObject(
                "SELECT account_id::text FROM synced_goal WHERE id = ?::uuid",
                String::class.java,
                goalId,
            ),
        )
    }
}
