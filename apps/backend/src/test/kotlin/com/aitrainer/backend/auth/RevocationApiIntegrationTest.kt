package com.aitrainer.backend.auth

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
 * Integration testy R2-06 revokace (C13 §10): revoke-all sessions,
 * revokace instalace vč. vázaných session a push gate, idempotence,
 * enumeration-safe 404, zachování dat a audit.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class RevocationApiIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private data class Principal(
        val accountId: String,
        val email: String,
        val accessToken: String,
        val refreshToken: String,
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
        val email = "revoke-${UUID.randomUUID()}@example.com"
        val registration =
            exchange(
                HttpMethod.POST,
                "/api/v1/auth/registrations",
                body = mapOf("email" to email, "password" to "password-123"),
                headers = mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, registration.statusCode.value())
        val json = JsonPath.parse(registration.body)
        val accessToken = json.read<String>("$.accessToken")
        val installationId = UUID.randomUUID().toString()
        assertEquals(
            201,
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/$installationId",
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "4"),
                accessToken = accessToken,
            ).statusCode.value(),
        )
        return Principal(
            accountId = json.read("$.accountId"),
            email = email,
            accessToken = accessToken,
            refreshToken = json.read("$.refreshToken"),
            installationId = installationId,
        )
    }

    private fun login(principal: Principal): Pair<String, String> {
        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/auth/sessions",
                body = mapOf("email" to principal.email, "password" to "password-123"),
            )
        assertEquals(200, response.statusCode.value())
        val json = JsonPath.parse(response.body)
        return json.read<String>("$.accessToken") to json.read<String>("$.refreshToken")
    }

    private fun errorCode(response: ResponseEntity<String>): String = JsonPath.parse(response.body).read("$.code")

    @Test
    fun `revoke-all zneplatni vsechny session uctu vcetne volajici a cizi ucet nedotkne`() {
        val principal = registerPrincipalWithDevice()
        val (secondAccess, secondRefresh) = login(principal)
        val bystander = registerPrincipalWithDevice()

        val response =
            exchange(HttpMethod.DELETE, "/api/v1/auth/sessions", accessToken = principal.accessToken)
        assertEquals(204, response.statusCode.value())

        // Všechny session účtu (obě) jsou revokované — access i refresh.
        listOf(principal.accessToken, secondAccess).forEach { token ->
            val context = exchange(HttpMethod.GET, "/api/v1/auth/session", accessToken = token)
            assertEquals(401, context.statusCode.value())
            assertEquals("SESSION_REVOKED", errorCode(context))
        }
        listOf(principal.refreshToken, secondRefresh).forEach { refresh ->
            val refreshed =
                exchange(
                    HttpMethod.POST,
                    "/api/v1/auth/sessions/refresh",
                    body = mapOf("refreshToken" to refresh),
                )
            assertEquals(401, refreshed.statusCode.value())
            assertEquals("SESSION_REVOKED", errorCode(refreshed))
        }
        // Cizí účet nedotčen.
        assertEquals(
            200,
            exchange(HttpMethod.GET, "/api/v1/auth/session", accessToken = bystander.accessToken)
                .statusCode
                .value(),
        )
        // Nové přihlášení funguje (revokace ruší oprávnění, ne účet ani data).
        val (newAccess, _) = login(principal)
        assertEquals(
            200,
            exchange(HttpMethod.GET, "/api/v1/auth/session", accessToken = newAccess).statusCode.value(),
        )
        // Audit: AuthSessionRevoked s REVOKE_ALL per session.
        val audits =
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = 'AuthSessionRevoked' AND policy_decision = 'REVOKE_ALL'
                  AND principal_account_id = ?::uuid
                """.trimIndent(),
                Int::class.java,
                principal.accountId,
            )
        assertTrue(audits!! >= 2)
    }

    @Test
    fun `revokace instalace zneplatni vazane session, push i re-registraci`() {
        val principal = registerPrincipalWithDevice()
        // Session je vázaná na instalaci registrací (C9 §6).

        val revoke =
            exchange(
                HttpMethod.DELETE,
                "/api/v1/devices/${principal.installationId}",
                accessToken = principal.accessToken,
            )
        // Volající session byla vázaná na instalaci → revoke ji zneplatnil;
        // 204 je poslední autorizovaná akce.
        assertEquals(204, revoke.statusCode.value())

        val context = exchange(HttpMethod.GET, "/api/v1/auth/session", accessToken = principal.accessToken)
        assertEquals(401, context.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(context))

        // Nové přihlášení funguje, ale revokovaná instalace nepushuje ani
        // se tiše nereaktivuje (DRC-013, RVC-007).
        val (newAccess, _) = login(principal)
        val push =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/push",
                body =
                    mapOf(
                        "installationId" to principal.installationId,
                        "operations" to
                            listOf(
                                mapOf(
                                    "operationId" to "op-1",
                                    "idempotencyKey" to "op-${UUID.randomUUID()}",
                                    "sequence" to 1,
                                    "operationType" to "CREATE_ENTITY",
                                    "entityType" to "WORKOUT_INSTANCE",
                                    "entityId" to UUID.randomUUID().toString(),
                                    "payload" to mapOf("title" to "X"),
                                ),
                            ),
                    ),
                accessToken = newAccess,
            )
        assertEquals(400, push.statusCode.value())
        val reRegister =
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/${principal.installationId}",
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.1", "localSchemaVersion" to "4"),
                accessToken = newAccess,
            )
        assertEquals(409, reRegister.statusCode.value())
        assertEquals("DEVICE_REVOKED", errorCode(reRegister))

        // Idempotence: opakovaná revokace je no-op úspěch.
        assertEquals(
            204,
            exchange(
                HttpMethod.DELETE,
                "/api/v1/devices/${principal.installationId}",
                accessToken = newAccess,
            ).statusCode.value(),
        )
        // Audit: DeviceRevoked + AuthSessionRevoked (DEVICE_REVOKED).
        assertTrue(
            jdbc.queryForObject(
                "SELECT count(*) FROM audit_event WHERE action = 'DeviceRevoked' AND principal_account_id = ?::uuid",
                Int::class.java,
                principal.accountId,
            )!! >= 1,
        )
        assertTrue(
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = 'AuthSessionRevoked' AND policy_decision = 'DEVICE_REVOKED'
                  AND principal_account_id = ?::uuid
                """.trimIndent(),
                Int::class.java,
                principal.accountId,
            )!! >= 1,
        )
    }

    @Test
    fun `cizi a neexistujici instalace jsou pri revokaci shodne 404`() {
        val alice = registerPrincipalWithDevice()
        val bob = registerPrincipalWithDevice()

        val foreign =
            exchange(
                HttpMethod.DELETE,
                "/api/v1/devices/${bob.installationId}",
                accessToken = alice.accessToken,
            )
        val unknown =
            exchange(
                HttpMethod.DELETE,
                "/api/v1/devices/${UUID.randomUUID()}",
                accessToken = alice.accessToken,
            )

        assertEquals(404, foreign.statusCode.value())
        assertEquals(404, unknown.statusCode.value())
        assertEquals("RESOURCE_NOT_FOUND", errorCode(foreign))
        assertEquals("RESOURCE_NOT_FOUND", errorCode(unknown))
        // Bobova instalace i session nedotčeny.
        assertEquals(
            200,
            exchange(HttpMethod.GET, "/api/v1/auth/session", accessToken = bob.accessToken)
                .statusCode
                .value(),
        )
    }

    @Test
    fun `revokace nemaze serverova data uctu`() {
        val principal = registerPrincipalWithDevice()
        // Synced entita před revokací.
        val entityId = UUID.randomUUID().toString()
        val push =
            exchange(
                HttpMethod.POST,
                "/api/v1/sync/push",
                body =
                    mapOf(
                        "installationId" to principal.installationId,
                        "operations" to
                            listOf(
                                mapOf(
                                    "operationId" to "op-1",
                                    "idempotencyKey" to "op-${UUID.randomUUID()}",
                                    "sequence" to 1,
                                    "operationType" to "CREATE_ENTITY",
                                    "entityType" to "WORKOUT_INSTANCE",
                                    "entityId" to entityId,
                                    "payload" to mapOf("title" to "Survives"),
                                ),
                            ),
                    ),
                accessToken = principal.accessToken,
            )
        assertEquals(200, push.statusCode.value())

        exchange(HttpMethod.DELETE, "/api/v1/auth/sessions", accessToken = principal.accessToken)

        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM synced_workout_instance WHERE id = ?::uuid",
                Int::class.java,
                entityId,
            ),
        )
    }
}
