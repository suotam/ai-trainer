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
import java.util.UUID
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Integration testy R6-01 pull sync (C41) nad skutečným PostgreSQL:
 * od prázdného kurzoru, kurzor advance (idempotence), stránkování
 * s hasMore, viditelnost UPDATE po kurzoru, ownership izolace (PSP-002)
 * a typovaná 400 pro neznámý typ/nevalidní token (PSP-004/009).
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class SyncPullIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

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
                body = mapOf("email" to "pull-${UUID.randomUUID()}@example.com", "password" to "password-123"),
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
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "13"),
                accessToken = accessToken,
            )
        assertEquals(201, device.statusCode.value())
        return Principal(
            accountId = json.read("$.accountId"),
            accessToken = accessToken,
            installationId = installationId,
        )
    }

    private fun pushCreate(
        principal: Principal,
        sequence: Long,
        entityType: String,
        entityId: String,
        payload: Map<String, Any?>,
        operationType: String = "CREATE_ENTITY",
        expectedServerVersion: Long? = null,
    ) {
        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/push",
                body =
                    mapOf(
                        "installationId" to principal.installationId,
                        "operations" to
                            listOf(
                                mapOf(
                                    "operationId" to "op-$sequence-$entityId",
                                    "idempotencyKey" to "key-${UUID.randomUUID()}",
                                    "sequence" to sequence,
                                    "operationType" to operationType,
                                    "entityType" to entityType,
                                    "entityId" to entityId,
                                    "payload" to payload,
                                    "expectedServerVersion" to expectedServerVersion,
                                ),
                            ),
                    ),
                accessToken = principal.accessToken,
            )
        assertEquals(200, response.statusCode.value())
        val result = JsonPath.parse(response.body).read<List<String>>("$.results[*].result")
        assertTrue(result.all { it == "SUCCESS" }, "push selhal: $result")
    }

    private fun pull(
        principal: Principal,
        cursors: List<Map<String, Any?>>,
        limit: Int? = null,
    ): ResponseEntity<String> =
        exchange(
            HttpMethod.POST,
            "/api/v1/sync/pull",
            body =
                buildMap {
                    put("installationId", principal.installationId)
                    put("cursors", cursors)
                    if (limit != null) put("limit", limit)
                },
            accessToken = principal.accessToken,
        )

    @Test
    fun `pull od prazdneho kurzoru vraci zmeny s payloadem a kurzor advance je idempotentni`() {
        val principal = registerPrincipalWithDevice()
        val sportId = UUID.randomUUID().toString()
        val checkInId = UUID.randomUUID().toString()
        pushCreate(principal, 1, "USER_SPORT", sportId, mapOf("sportCode" to "CLIMBING", "role" to "PRIMARY"))
        pushCreate(principal, 2, "DAILY_CHECK_IN", checkInId, mapOf("localDate" to "2026-08-14", "energyLevel" to 4, "fatigueLevel" to 2))

        val first =
            pull(
                principal,
                listOf(
                    mapOf("entityType" to "USER_SPORT"),
                    mapOf("entityType" to "DAILY_CHECK_IN"),
                ),
            )
        assertEquals(200, first.statusCode.value())
        val json = JsonPath.parse(first.body)
        assertEquals(listOf("USER_SPORT", "DAILY_CHECK_IN"), json.read("$.items[*].entityType"))
        assertEquals(listOf(sportId, checkInId), json.read("$.items[*].entityId"))
        // Payload přesně jak byl přijat (PSP-003).
        assertEquals("CLIMBING", json.read("$.items[0].payload.sportCode"))
        assertEquals(4, json.read<Int>("$.items[1].payload.energyLevel"))
        assertEquals(false, json.read<Boolean>("$.hasMore"))
        val cursors = json.read<List<Map<String, Any?>>>("$.cursors")
        assertEquals(2, cursors.size)

        // Kurzor advance: druhý pull s vrácenými kurzory je prázdný (PSP-008).
        val second = pull(principal, cursors)
        val secondJson = JsonPath.parse(second.body)
        assertEquals(emptyList<Any>(), secondJson.read("$.items"))
        assertEquals(false, secondJson.read<Boolean>("$.hasMore"))

        // UPDATE je viditelný po kurzoru (PSP-005) se zvýšenou verzí.
        pushCreate(
            principal,
            3,
            "USER_SPORT",
            sportId,
            mapOf("sportCode" to "CLIMBING", "role" to "SECONDARY"),
            operationType = "UPDATE_ENTITY",
            expectedServerVersion = 1,
        )
        val third = pull(principal, cursors)
        val thirdJson = JsonPath.parse(third.body)
        assertEquals(listOf(sportId), thirdJson.read("$.items[*].entityId"))
        assertEquals(2, thirdJson.read<Int>("$.items[0].serverVersion"))
        assertEquals("SECONDARY", thirdJson.read("$.items[0].payload.role"))
    }

    @Test
    fun `strankovani respektuje limit a hasMore konverguje (PSP-007)`() {
        val principal = registerPrincipalWithDevice()
        repeat(3) { index ->
            pushCreate(
                principal,
                (index + 1).toLong(),
                "GOAL",
                UUID.randomUUID().toString(),
                mapOf("title" to "Cíl $index", "goalType" to "PERFORMANCE"),
            )
        }

        val first = pull(principal, listOf(mapOf("entityType" to "GOAL")), limit = 2)
        val firstJson = JsonPath.parse(first.body)
        assertEquals(2, firstJson.read<List<Any>>("$.items").size)
        assertEquals(true, firstJson.read<Boolean>("$.hasMore"))

        val second = pull(principal, firstJson.read("$.cursors"), limit = 2)
        val secondJson = JsonPath.parse(second.body)
        assertEquals(1, secondJson.read<List<Any>>("$.items").size)
        assertEquals(false, secondJson.read<Boolean>("$.hasMore"))

        val third = pull(principal, secondJson.read("$.cursors"), limit = 2)
        assertEquals(emptyList<Any>(), JsonPath.parse(third.body).read("$.items"))
    }

    @Test
    fun `ownership izolace - cizi ucet zmeny nevidi (PSP-002)`() {
        val owner = registerPrincipalWithDevice()
        val other = registerPrincipalWithDevice()
        pushCreate(owner, 1, "TRAINING_PLAN", UUID.randomUUID().toString(), mapOf("title" to "Můj plán", "status" to "ACTIVE"))

        val foreign = pull(other, listOf(mapOf("entityType" to "TRAINING_PLAN")))
        assertEquals(emptyList<Any>(), JsonPath.parse(foreign.body).read("$.items"))
    }

    @Test
    fun `neznamy typ a nevalidni kurzor jsou typovane odmitnuty (PSP-004-009)`() {
        val principal = registerPrincipalWithDevice()
        val unknown = pull(principal, listOf(mapOf("entityType" to "AI_PROPOSAL")))
        assertEquals(400, unknown.statusCode.value())
        assertEquals("INVALID_REQUEST", JsonPath.parse(unknown.body).read("$.code"))

        val malformed = pull(principal, listOf(mapOf("entityType" to "GOAL", "cursor" to "not-a-cursor")))
        assertEquals(400, malformed.statusCode.value())

        val unauthorized =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/pull",
                body = mapOf("installationId" to principal.installationId, "cursors" to listOf(mapOf("entityType" to "GOAL"))),
            )
        assertEquals(401, unauthorized.statusCode.value())
    }
}
