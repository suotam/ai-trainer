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
import kotlin.test.assertNotEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Integration testy R2 auth API (C4 §14) nad skutečným PostgreSQL:
 * registrace s idempotency key, login, refresh rotation + replay detekce,
 * logout, session context, stavy účtu a security-negative scénáře.
 * Rate limit má vlastní test s odděleným contextem.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class AuthApiIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private fun uniqueEmail(): String = "user-${UUID.randomUUID()}@example.com"

    private fun newIdempotencyKey(): String = "key-${UUID.randomUUID()}"

    private fun postJson(
        path: String,
        body: Map<String, Any?>,
        headers: Map<String, String> = emptyMap(),
    ): ResponseEntity<String> {
        val httpHeaders = HttpHeaders()
        httpHeaders.contentType = MediaType.APPLICATION_JSON
        headers.forEach { (name, value) -> httpHeaders.set(name, value) }
        return restTemplate.exchange(path, HttpMethod.POST, HttpEntity(body, httpHeaders), String::class.java)
    }

    private fun register(
        email: String,
        password: String = "correct-horse-9",
        idempotencyKey: String = newIdempotencyKey(),
    ): ResponseEntity<String> =
        postJson(
            "/api/v1/auth/registrations",
            mapOf("email" to email, "password" to password),
            mapOf("Idempotency-Key" to idempotencyKey),
        )

    private fun login(
        email: String,
        password: String,
    ): ResponseEntity<String> = postJson("/api/v1/auth/sessions", mapOf("email" to email, "password" to password))

    private fun refresh(refreshToken: String): ResponseEntity<String> =
        postJson("/api/v1/auth/sessions/refresh", mapOf("refreshToken" to refreshToken))

    private fun withBearer(
        method: HttpMethod,
        path: String,
        accessToken: String?,
    ): ResponseEntity<String> {
        val headers = HttpHeaders()
        if (accessToken != null) {
            headers.setBearerAuth(accessToken)
        }
        return restTemplate.exchange(path, method, HttpEntity<Void>(headers), String::class.java)
    }

    private fun sessionContext(accessToken: String?): ResponseEntity<String> =
        withBearer(HttpMethod.GET, "/api/v1/auth/session", accessToken)

    private fun logout(accessToken: String?): ResponseEntity<String> =
        withBearer(HttpMethod.DELETE, "/api/v1/auth/sessions/current", accessToken)

    private fun field(
        response: ResponseEntity<String>,
        name: String,
    ): String = assertNotNull(JsonPath.parse(response.body).read<String>("$.$name"), "missing $name in ${response.body}")

    private fun errorCode(response: ResponseEntity<String>): String = field(response, "code")

    private fun accountCountFor(email: String): Int =
        jdbc.queryForObject(
            """
            SELECT count(*) FROM account a
            JOIN authentication_identity ai ON ai.identity_id = a.identity_id
            WHERE ai.provider_subject = ?
            """.trimIndent(),
            Int::class.java,
            email,
        )!!

    @Test
    fun `registrace vytvori ucet a vyda session s tokeny`() {
        val email = uniqueEmail()
        val response = register(email)

        assertEquals(201, response.statusCode.value())
        assertEquals("no-store", response.headers.cacheControl)
        val accessToken = field(response, "accessToken")
        val refreshToken = field(response, "refreshToken")
        assertNotEquals(accessToken, refreshToken)
        assertNotNull(java.time.Instant.parse(field(response, "accessExpiresAt")))
        assertEquals(1, accountCountFor(email))

        val context = sessionContext(accessToken)
        assertEquals(200, context.statusCode.value())
        assertEquals(field(response, "accountId"), field(context, "accountId"))
        assertEquals("STANDARD", field(context, "accountType"))
        assertEquals("ACTIVE", field(context, "accountStatus"))
    }

    @Test
    fun `retry registrace se stejnym klicem a payloadem nevytvori druhy ucet`() {
        val email = uniqueEmail()
        val key = newIdempotencyKey()

        val first = register(email, idempotencyKey = key)
        val retry = register(email, idempotencyKey = key)

        assertEquals(201, first.statusCode.value())
        assertEquals(201, retry.statusCode.value())
        assertEquals(field(first, "accountId"), field(retry, "accountId"))
        assertEquals(1, accountCountFor(email))
    }

    @Test
    fun `stejny idempotency key s jinym payloadem je odmitnut`() {
        val key = newIdempotencyKey()
        assertEquals(201, register(uniqueEmail(), idempotencyKey = key).statusCode.value())

        val conflict = register(uniqueEmail(), idempotencyKey = key)
        assertEquals(400, conflict.statusCode.value())
        assertEquals("INVALID_REQUEST", errorCode(conflict))
    }

    @Test
    fun `duplicitni prihlasovaci identita vraci 409`() {
        val email = uniqueEmail()
        assertEquals(201, register(email).statusCode.value())

        val duplicate = register(email)
        assertEquals(409, duplicate.statusCode.value())
        assertEquals("DUPLICATE_LOGIN_IDENTITY", errorCode(duplicate))
        assertEquals(1, accountCountFor(email))
    }

    @Test
    fun `registrace bez idempotency key nebo s neplatnym vstupem je INVALID_REQUEST`() {
        val missingKey =
            postJson("/api/v1/auth/registrations", mapOf("email" to uniqueEmail(), "password" to "correct-horse-9"))
        assertEquals(400, missingKey.statusCode.value())
        assertEquals("INVALID_REQUEST", errorCode(missingKey))

        val shortPassword = register(uniqueEmail(), password = "short")
        assertEquals(400, shortPassword.statusCode.value())

        val invalidEmail = register("not-an-email")
        assertEquals(400, invalidEmail.statusCode.value())
    }

    @Test
    fun `login vyda novou session a spatne credentials jsou genericke`() {
        val email = uniqueEmail()
        val password = "correct-horse-9"
        register(email, password)

        val success = login(email, password)
        assertEquals(200, success.statusCode.value())
        assertNotNull(field(success, "accessToken"))

        val wrongPassword = login(email, "wrong-password-1")
        val unknownEmail = login(uniqueEmail(), "wrong-password-1")

        // Bez account enumeration (AAC-008): stejný kód i tvar odpovědi.
        assertEquals(401, wrongPassword.statusCode.value())
        assertEquals(401, unknownEmail.statusCode.value())
        assertEquals("INVALID_CREDENTIALS", errorCode(wrongPassword))
        assertEquals("INVALID_CREDENTIALS", errorCode(unknownEmail))
        assertEquals(
            JsonPath.parse(wrongPassword.body).read<Map<String, Any>>("$").keys,
            JsonPath.parse(unknownEmail.body).read<Map<String, Any>>("$").keys,
        )
    }

    @Test
    fun `refresh rotuje credentials a replay stare refresh credential revokuje session`() {
        val registered = register(uniqueEmail())
        val originalAccess = field(registered, "accessToken")
        val originalRefresh = field(registered, "refreshToken")

        val refreshed = refresh(originalRefresh)
        assertEquals(200, refreshed.statusCode.value())
        val newAccess = field(refreshed, "accessToken")
        val newRefresh = field(refreshed, "refreshToken")
        assertNotEquals(originalAccess, newAccess)
        assertNotEquals(originalRefresh, newRefresh)
        assertEquals(200, sessionContext(newAccess).statusCode.value())

        // Replay již rotované refresh credential → detekce, revokace celé session.
        val replay = refresh(originalRefresh)
        assertEquals(401, replay.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(replay))

        // Revokovaná session nepotvrdí žádnou další operaci (ISC-007).
        val afterReplayContext = sessionContext(newAccess)
        assertEquals(401, afterReplayContext.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(afterReplayContext))
        val afterReplayRefresh = refresh(newRefresh)
        assertEquals(401, afterReplayRefresh.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(afterReplayRefresh))
    }

    @Test
    fun `neznama refresh credential je INVALID_REFRESH`() {
        val response = refresh("nonexistent-refresh-token")
        assertEquals(401, response.statusCode.value())
        assertEquals("INVALID_REFRESH", errorCode(response))
    }

    @Test
    fun `logout revokuje session a opakovany logout je no-op`() {
        val registered = register(uniqueEmail())
        val accessToken = field(registered, "accessToken")
        val refreshToken = field(registered, "refreshToken")

        assertEquals(204, logout(accessToken).statusCode.value())

        val contextAfterLogout = sessionContext(accessToken)
        assertEquals(401, contextAfterLogout.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(contextAfterLogout))

        val refreshAfterLogout = refresh(refreshToken)
        assertEquals(401, refreshAfterLogout.statusCode.value())
        assertEquals("SESSION_REVOKED", errorCode(refreshAfterLogout))

        // Idempotentní no-op (C4 §10).
        assertEquals(204, logout(accessToken).statusCode.value())
    }

    @Test
    fun `chybejici nebo neznama access credential je odmitnuta default deny`() {
        val noToken = sessionContext(null)
        assertEquals(401, noToken.statusCode.value())
        assertEquals("ACCESS_SESSION_EXPIRED", errorCode(noToken))

        val garbage = sessionContext("garbage-token")
        assertEquals(401, garbage.statusCode.value())
        assertEquals("ACCESS_SESSION_EXPIRED", errorCode(garbage))

        val logoutWithoutToken = logout(null)
        assertEquals(401, logoutWithoutToken.statusCode.value())
    }

    @Test
    fun `expirovana access session je ACCESS_SESSION_EXPIRED a refresh ji obnovi`() {
        val registered = register(uniqueEmail())
        val accessToken = field(registered, "accessToken")
        val refreshToken = field(registered, "refreshToken")
        val sessionId = UUID.fromString(field(registered, "sessionId"))

        jdbc.update(
            "UPDATE auth_session SET access_expires_at = now() - interval '1 minute' WHERE id = ?",
            sessionId,
        )

        val expired = sessionContext(accessToken)
        assertEquals(401, expired.statusCode.value())
        assertEquals("ACCESS_SESSION_EXPIRED", errorCode(expired))

        val refreshed = refresh(refreshToken)
        assertEquals(200, refreshed.statusCode.value())
        assertEquals(200, sessionContext(field(refreshed, "accessToken")).statusCode.value())
    }

    @Test
    fun `expirovana refresh session je INVALID_REFRESH`() {
        val registered = register(uniqueEmail())
        val sessionId = UUID.fromString(field(registered, "sessionId"))
        jdbc.update(
            "UPDATE auth_session SET refresh_expires_at = now() - interval '1 minute' WHERE id = ?",
            sessionId,
        )

        val response = refresh(field(registered, "refreshToken"))
        assertEquals(401, response.statusCode.value())
        assertEquals("INVALID_REFRESH", errorCode(response))
    }

    @Test
    fun `suspendovany ucet je ACCOUNT_DISABLED a smazany ACCOUNT_DELETED`() {
        val email = uniqueEmail()
        val password = "correct-horse-9"
        val registered = register(email, password)
        val accountId = UUID.fromString(field(registered, "accountId"))

        jdbc.update("UPDATE account SET status = 'SUSPENDED' WHERE id = ?", accountId)
        val disabledLogin = login(email, password)
        assertEquals(403, disabledLogin.statusCode.value())
        assertEquals("ACCOUNT_DISABLED", errorCode(disabledLogin))
        val disabledRefresh = refresh(field(registered, "refreshToken"))
        assertEquals(403, disabledRefresh.statusCode.value())
        // Deaktivovaný účet ztrácí i access oprávnění (default deny, SAR-001).
        assertEquals(401, sessionContext(field(registered, "accessToken")).statusCode.value())

        jdbc.update("UPDATE account SET status = 'DELETION_PENDING' WHERE id = ?", accountId)
        val deletedLogin = login(email, password)
        assertEquals(403, deletedLogin.statusCode.value())
        assertEquals("ACCOUNT_DELETED", errorCode(deletedLogin))
    }

    @Test
    fun `v databazi neni zadny plaintext secret`() {
        val email = uniqueEmail()
        val password = "super-secret-password-42"
        val registered = register(email, password)
        val accessToken = field(registered, "accessToken")
        val refreshToken = field(registered, "refreshToken")

        val storedValues = mutableListOf<String>()
        jdbc
            .queryForList("SELECT credential_hash FROM authentication_identity")
            .forEach { row -> row.values.filterNotNull().forEach { storedValues.add(it.toString()) } }
        jdbc
            .queryForList("SELECT access_token_hash FROM auth_session")
            .forEach { row -> row.values.filterNotNull().forEach { storedValues.add(it.toString()) } }
        jdbc
            .queryForList("SELECT token_hash FROM auth_refresh_credential")
            .forEach { row -> row.values.filterNotNull().forEach { storedValues.add(it.toString()) } }
        jdbc
            .queryForList("SELECT action, outcome, target, correlation_id, policy_decision FROM audit_event")
            .forEach { row -> row.values.filterNotNull().forEach { storedValues.add(it.toString()) } }

        listOf(password, accessToken, refreshToken).forEach { secret ->
            storedValues.forEach { stored ->
                assertTrue(!stored.contains(secret), "Nalezen plaintext secret v DB: $stored")
            }
        }
    }

    @Test
    fun `auth udalosti se audituji se spravnym outcome bez citliveho payloadu`() {
        val email = uniqueEmail()
        val password = "correct-horse-9"
        val registered = register(email, password)
        val accountId = UUID.fromString(field(registered, "accountId"))
        login(email, password)
        login(email, "wrong-password-1")
        val loginSession = login(email, password)
        refresh(field(loginSession, "refreshToken"))
        logout(field(registered, "accessToken"))

        fun countByAction(
            action: String,
            outcome: String,
        ): Int =
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = ? AND outcome = ?
                  AND (principal_account_id = ? OR principal_account_id IS NULL)
                """.trimIndent(),
                Int::class.java,
                action,
                outcome,
                accountId,
            )!!

        assertTrue(countByAction("AccountRegistered", "SUCCESS") >= 1)
        assertTrue(countByAction("LoginSucceeded", "SUCCESS") >= 2)
        assertTrue(countByAction("LoginFailed", "FAILURE") >= 1)
        assertTrue(countByAction("AuthSessionIssued", "SUCCESS") >= 3)
        assertTrue(countByAction("AuthSessionRefreshed", "SUCCESS") >= 1)
        assertTrue(countByAction("AuthSessionLoggedOut", "SUCCESS") >= 1)
        assertTrue(countByAction("AuthSessionRevoked", "SUCCESS") >= 1)

        // Audit má korelaci a nikdy nenese e-mail, heslo ani token (AEC-003/004).
        val rows =
            jdbc.queryForList(
                "SELECT action, target, correlation_id, policy_decision FROM audit_event WHERE principal_account_id = ?",
                accountId,
            )
        assertTrue(rows.isNotEmpty())
        rows.forEach { row ->
            row.values.filterNotNull().forEach { value ->
                val text = value.toString()
                assertTrue(!text.contains(email), "Audit obsahuje e-mail: $text")
                assertTrue(!text.contains(password), "Audit obsahuje heslo: $text")
            }
        }
    }

    @Test
    fun `auth error odpovedi pouzivaji kanonicky envelope bez internich detailu`() {
        val response = login(uniqueEmail(), "wrong-password-1")
        val body = JsonPath.parse(response.body).read<Map<String, Any>>("$")
        assertEquals(setOf("code", "message", "requestId", "timestamp"), body.keys)
        listOf("Exception", "com.aitrainer", "stackTrace", "SQL", "jdbc").forEach { forbidden ->
            assertTrue(!response.body!!.contains(forbidden), "Response obsahuje interní detail '$forbidden'")
        }
    }

    @Test
    fun `nevalidni JSON body je bezpecny INVALID_REQUEST`() {
        val headers = HttpHeaders()
        headers.contentType = MediaType.APPLICATION_JSON
        val response =
            restTemplate.exchange(
                "/api/v1/auth/sessions",
                HttpMethod.POST,
                HttpEntity("not-json{", headers),
                String::class.java,
            )
        assertEquals(400, response.statusCode.value())
        assertEquals("INVALID_REQUEST", errorCode(response))
    }
}
