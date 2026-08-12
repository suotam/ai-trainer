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
 * Integration testy R2-05 push sync (C10 §13, C11 §10) nad skutečným
 * PostgreSQL: pořadí, idempotentní replay, per-item ownership, version
 * conflict, dependency failure, zachování client ID a audit.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class SyncPushApiIntegrationTest {
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
                body = mapOf("email" to "sync-${UUID.randomUUID()}@example.com", "password" to "password-123"),
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
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "3"),
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
    fun `batch se aplikuje v poradi sequence a zachova client ID`() {
        val principal = registerPrincipalWithDevice()
        val instanceId = UUID.randomUUID().toString()
        val sessionId = UUID.randomUUID().toString()

        // Záměrně předané v opačném pořadí — server řadí podle sequence.
        val response =
            push(
                principal,
                listOf(
                    operation(2, "WORKOUT_SESSION", sessionId, mapOf("workoutInstanceId" to instanceId, "status" to "COMPLETED")),
                    operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Full Body", "status" to "COMPLETED")),
                ),
            )

        assertEquals(200, response.statusCode.value())
        val items = results(response)
        assertEquals(listOf("SUCCESS", "SUCCESS"), items.map { it["result"] })
        // Client-generated ID server zachovává (SDM-005).
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM synced_workout_session WHERE id = ?::uuid AND account_id = ?::uuid",
                Int::class.java,
                sessionId,
                principal.accountId,
            ),
        )
        // last_sync_at zařízení je zaznamenán (C6 §8.2).
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM device_installation WHERE installation_id = ?::uuid AND last_sync_at IS NOT NULL",
                Int::class.java,
                principal.installationId,
            ),
        )
    }

    @Test
    fun `druhy push stejne operace je ALREADY_APPLIED bez duplicity`() {
        val principal = registerPrincipalWithDevice()
        val instanceId = UUID.randomUUID().toString()
        val key = "op-${UUID.randomUUID()}"
        val op = operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Push"), idempotencyKey = key)

        val first = push(principal, listOf(op))
        assertEquals("SUCCESS", results(first).single()["result"])

        val replay = push(principal, listOf(op))
        val outcome = results(replay).single()
        assertEquals("ALREADY_APPLIED", outcome["result"])
        assertEquals(1, (outcome["serverVersion"] as Number).toInt())
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM synced_workout_instance WHERE id = ?::uuid",
                Int::class.java,
                instanceId,
            ),
        )
    }

    @Test
    fun `stejny klic s jinym payloadem je odmitnut a nemeni stav`() {
        val principal = registerPrincipalWithDevice()
        val instanceId = UUID.randomUUID().toString()
        val key = "op-${UUID.randomUUID()}"
        push(principal, listOf(operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Original"), idempotencyKey = key)))

        val tampered =
            push(
                principal,
                listOf(operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Tampered"), idempotencyKey = key)),
            )

        assertEquals("VALIDATION_FAILED", results(tampered).single()["result"])
        assertEquals(
            "Original",
            jdbc.queryForObject(
                "SELECT payload->>'title' FROM synced_workout_instance WHERE id = ?::uuid",
                String::class.java,
                instanceId,
            ),
        )
    }

    @Test
    fun `update s expectedServerVersion projde a se starou verzi je VERSION_CONFLICT`() {
        val principal = registerPrincipalWithDevice()
        val instanceId = UUID.randomUUID().toString()
        push(principal, listOf(operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "V1"))))

        val update =
            push(
                principal,
                listOf(
                    operation(
                        2,
                        "WORKOUT_INSTANCE",
                        instanceId,
                        mapOf("title" to "V2"),
                        operationType = "UPDATE_ENTITY",
                        expectedServerVersion = 1,
                    ),
                ),
            )
        val updated = results(update).single()
        assertEquals("SUCCESS", updated["result"])
        assertEquals(2, (updated["serverVersion"] as Number).toInt())

        val stale =
            push(
                principal,
                listOf(
                    operation(
                        3,
                        "WORKOUT_INSTANCE",
                        instanceId,
                        mapOf("title" to "V3-stale"),
                        operationType = "UPDATE_ENTITY",
                        expectedServerVersion = 1,
                    ),
                ),
            )
        val conflict = results(stale).single()
        assertEquals("VERSION_CONFLICT", conflict["result"])
        assertEquals(2, (conflict["serverVersion"] as Number).toInt())
        // Serverový stav nezměněn.
        assertEquals(
            "V2",
            jdbc.queryForObject(
                "SELECT payload->>'title' FROM synced_workout_instance WHERE id = ?::uuid",
                String::class.java,
                instanceId,
            ),
        )
    }

    @Test
    fun `smisena batch odmitne jen cizi polozky (per-item ownership)`() {
        val alice = registerPrincipalWithDevice()
        val bob = registerPrincipalWithDevice()
        val bobInstance = UUID.randomUUID().toString()
        push(bob, listOf(operation(1, "WORKOUT_INSTANCE", bobInstance, mapOf("title" to "Bob"))))

        val aliceInstance = UUID.randomUUID().toString()
        val response =
            push(
                alice,
                listOf(
                    operation(1, "WORKOUT_INSTANCE", aliceInstance, mapOf("title" to "Alice")),
                    // Pokus přepsat Bobovu entitu.
                    operation(
                        2,
                        "WORKOUT_INSTANCE",
                        bobInstance,
                        mapOf("title" to "Hijack"),
                        operationType = "UPDATE_ENTITY",
                        expectedServerVersion = 1,
                    ),
                ),
            )

        val items = results(response)
        assertEquals("SUCCESS", items[0]["result"])
        assertEquals("PERMISSION_DENIED", items[1]["result"])
        assertEquals(
            "Bob",
            jdbc.queryForObject(
                "SELECT payload->>'title' FROM synced_workout_instance WHERE id = ?::uuid",
                String::class.java,
                bobInstance,
            ),
        )
        // AOC-013/C14: ownership violation auditována.
        val denials =
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = 'AuthorizationDenied' AND principal_account_id = ?::uuid
                  AND policy_decision = 'OWNERSHIP_MISMATCH'
                """.trimIndent(),
                Int::class.java,
                alice.accountId,
            )
        assertTrue(denials!! >= 1)
    }

    @Test
    fun `chybejici parent je DEPENDENCY_FAILED a spravne poradi projde`() {
        val principal = registerPrincipalWithDevice()
        val orphanSession = UUID.randomUUID().toString()

        val orphan =
            push(
                principal,
                listOf(
                    operation(
                        1,
                        "WORKOUT_SESSION",
                        orphanSession,
                        mapOf("workoutInstanceId" to UUID.randomUUID().toString()),
                    ),
                ),
            )
        assertEquals("DEPENDENCY_FAILED", results(orphan).single()["result"])

        // Celá hierarchie ve správném pořadí projde.
        val instanceId = UUID.randomUUID().toString()
        val sessionId = UUID.randomUUID().toString()
        val stepId = UUID.randomUUID().toString()
        val setId = UUID.randomUUID().toString()
        val feedbackId = UUID.randomUUID().toString()
        val summaryId = UUID.randomUUID().toString()
        val full =
            push(
                principal,
                listOf(
                    operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Chain")),
                    operation(2, "WORKOUT_SESSION", sessionId, mapOf("workoutInstanceId" to instanceId)),
                    operation(3, "STEP_PERFORMANCE", stepId, mapOf("workoutSessionId" to sessionId)),
                    operation(4, "SET_PERFORMANCE", setId, mapOf("stepPerformanceId" to stepId, "actualReps" to 10)),
                    operation(5, "WORKOUT_FEEDBACK", feedbackId, mapOf("workoutSessionId" to sessionId, "effort" to 7)),
                    operation(6, "ACTIVITY_SUMMARY", summaryId, mapOf("workoutSessionId" to sessionId)),
                ),
            )
        assertEquals(List(6) { "SUCCESS" }, results(full).map { it["result"] })
    }

    @Test
    fun `nevalidni typ, nevalidni entita a neregistrovane zarizeni jsou bezpecne odmitnuty`() {
        val principal = registerPrincipalWithDevice()

        val badType =
            push(principal, listOf(operation(1, "NOT_A_TYPE", UUID.randomUUID().toString(), mapOf())))
        assertEquals("VALIDATION_FAILED", results(badType).single()["result"])

        val badOp =
            push(
                principal,
                listOf(
                    operation(
                        1,
                        "WORKOUT_INSTANCE",
                        UUID.randomUUID().toString(),
                        mapOf(),
                        operationType = "DELETE_ENTITY",
                    ),
                ),
            )
        assertEquals("VALIDATION_FAILED", results(badOp).single()["result"])

        val unregistered =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/push",
                body =
                    mapOf(
                        "installationId" to UUID.randomUUID().toString(),
                        "operations" to listOf(operation(1, "WORKOUT_INSTANCE", UUID.randomUUID().toString(), mapOf())),
                    ),
                accessToken = principal.accessToken,
            )
        assertEquals(400, unregistered.statusCode.value())
        assertEquals("INVALID_REQUEST", JsonPath.parse(unregistered.body).read("$.code"))

        val unauthenticated =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/push",
                body = mapOf("installationId" to principal.installationId, "operations" to listOf<Any>()),
            )
        assertEquals(401, unauthenticated.statusCode.value())
    }

    @Test
    fun `sync udalosti se audituji s explicitnim outcome (C14 s7)`() {
        val principal = registerPrincipalWithDevice()
        val instanceId = UUID.randomUUID().toString()
        val key = "op-${UUID.randomUUID()}"
        val op = operation(1, "WORKOUT_INSTANCE", instanceId, mapOf("title" to "Audit"), idempotencyKey = key)
        push(principal, listOf(op))
        push(principal, listOf(op))
        push(
            principal,
            listOf(
                operation(
                    2,
                    "WORKOUT_INSTANCE",
                    instanceId,
                    mapOf("title" to "Stale"),
                    operationType = "UPDATE_ENTITY",
                    expectedServerVersion = 99,
                ),
            ),
        )

        fun count(
            action: String,
            outcome: String,
        ): Int =
            jdbc.queryForObject(
                "SELECT count(*) FROM audit_event WHERE action = ? AND outcome = ? AND principal_account_id = ?::uuid",
                Int::class.java,
                action,
                outcome,
                principal.accountId,
            )!!

        assertTrue(count("SyncOperationApplied", "SUCCESS") >= 1)
        assertTrue(count("IdempotentReplayReturned", "SUCCESS") >= 1)
        assertTrue(count("SyncConflictDetected", "CONFLICT") >= 1)
    }
}
