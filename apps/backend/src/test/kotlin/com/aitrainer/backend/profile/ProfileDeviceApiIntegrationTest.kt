package com.aitrainer.backend.profile

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
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Integration testy R2-04 (C8 §13, C9 §12) nad skutečným PostgreSQL:
 * profil (vytvoření, idempotentní retry, jeden SELF na účet), registrace
 * zařízení (idempotentní upsert, vazba session→zařízení), ownership
 * negativní scénáře (cizí zdroj = 404 nerozlišitelný od neexistence,
 * kolekce filtrované principalem) a audit.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class ProfileDeviceApiIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private data class TestPrincipal(
        val accountId: String,
        val sessionId: String,
        val accessToken: String,
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

    private fun registerPrincipal(): TestPrincipal {
        val response =
            exchange(
                HttpMethod.POST,
                "/api/v1/auth/registrations",
                body = mapOf("email" to "owner-${UUID.randomUUID()}@example.com", "password" to "password-123"),
                headers = mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, response.statusCode.value())
        val json = JsonPath.parse(response.body)
        return TestPrincipal(
            accountId = json.read("$.accountId"),
            sessionId = json.read("$.sessionId"),
            accessToken = json.read("$.accessToken"),
        )
    }

    private fun createProfile(
        principal: TestPrincipal,
        profileId: String = UUID.randomUUID().toString(),
        displayName: String = "Athlete",
    ): ResponseEntity<String> =
        exchange(
            HttpMethod.POST,
            "/api/v1/profiles",
            body =
                mapOf(
                    "profileId" to profileId,
                    "displayName" to displayName,
                    "primarySport" to "RUNNING",
                    "experienceLevel" to "INTERMEDIATE",
                    "units" to "METRIC",
                ),
            accessToken = principal.accessToken,
        )

    private fun registerDevice(
        principal: TestPrincipal,
        installationId: String = UUID.randomUUID().toString(),
        appVersion: String = "1.0.0",
    ): ResponseEntity<String> =
        exchange(
            HttpMethod.PUT,
            "/api/v1/devices/$installationId",
            body =
                mapOf(
                    "platform" to "ANDROID",
                    "appVersion" to appVersion,
                    "localSchemaVersion" to "2",
                ),
            accessToken = principal.accessToken,
        )

    private fun errorCode(response: ResponseEntity<String>): String = JsonPath.parse(response.body).read("$.code")

    @Test
    fun `vytvoreni profilu patri principalu a je idempotentni podle profileId`() {
        val principal = registerPrincipal()
        val profileId = UUID.randomUUID().toString()

        val created = createProfile(principal, profileId = profileId)
        assertEquals(201, created.statusCode.value())
        assertEquals(principal.accountId, JsonPath.parse(created.body).read("$.accountId"))
        assertEquals("SELF", JsonPath.parse(created.body).read("$.profileType"))
        // Client-generated ID server zachovává (SDM-005).
        assertEquals(profileId, JsonPath.parse(created.body).read("$.profileId"))

        val retry = createProfile(principal, profileId = profileId)
        assertEquals(200, retry.statusCode.value())
        assertEquals(profileId, JsonPath.parse(retry.body).read("$.profileId"))
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM athlete_profile WHERE account_id = ?::uuid",
                Int::class.java,
                principal.accountId,
            ),
        )
    }

    @Test
    fun `ucet smi mit jen jeden SELF profil`() {
        val principal = registerPrincipal()
        assertEquals(201, createProfile(principal).statusCode.value())

        val second = createProfile(principal)
        assertEquals(409, second.statusCode.value())
        assertEquals("PROFILE_ALREADY_EXISTS", errorCode(second))
    }

    @Test
    fun `cizi profil je 404 nerozlisitelny od neexistence a audituje se`() {
        val owner = registerPrincipal()
        val attacker = registerPrincipal()
        val profileId = UUID.randomUUID().toString()
        assertEquals(201, createProfile(owner, profileId = profileId).statusCode.value())

        val foreign = exchange(HttpMethod.GET, "/api/v1/profiles/$profileId", accessToken = attacker.accessToken)
        val nonexistent =
            exchange(
                HttpMethod.GET,
                "/api/v1/profiles/${UUID.randomUUID()}",
                accessToken = attacker.accessToken,
            )

        // AOC-007: stejný kód i tvar odpovědi pro cizí a neexistující zdroj.
        assertEquals(404, foreign.statusCode.value())
        assertEquals(404, nonexistent.statusCode.value())
        assertEquals("RESOURCE_NOT_FOUND", errorCode(foreign))
        assertEquals("RESOURCE_NOT_FOUND", errorCode(nonexistent))
        assertEquals(
            JsonPath.parse(foreign.body).read<Map<String, Any>>("$").keys,
            JsonPath.parse(nonexistent.body).read<Map<String, Any>>("$").keys,
        )

        // AOC-013: ownership violation je auditovaná.
        val denials =
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = 'AuthorizationDenied' AND outcome = 'REJECTED'
                  AND principal_account_id = ?::uuid AND policy_decision = 'OWNERSHIP_MISMATCH'
                """.trimIndent(),
                Int::class.java,
                attacker.accountId,
            )
        assertTrue(denials!! >= 1)
    }

    @Test
    fun `vlastni profil je dostupny pres current i pres id`() {
        val principal = registerPrincipal()
        val profileId = UUID.randomUUID().toString()
        createProfile(principal, profileId = profileId, displayName = "Own Athlete")

        val current = exchange(HttpMethod.GET, "/api/v1/profiles/current", accessToken = principal.accessToken)
        assertEquals(200, current.statusCode.value())
        assertEquals("Own Athlete", JsonPath.parse(current.body).read("$.displayName"))

        val byId = exchange(HttpMethod.GET, "/api/v1/profiles/$profileId", accessToken = principal.accessToken)
        assertEquals(200, byId.statusCode.value())
    }

    @Test
    fun `current bez profilu je 404 a chranene operace vyzaduji session`() {
        val principal = registerPrincipal()
        val current = exchange(HttpMethod.GET, "/api/v1/profiles/current", accessToken = principal.accessToken)
        assertEquals(404, current.statusCode.value())

        // Default deny bez credential (AOC-003) — 401 dle C4.
        val unauthenticated = exchange(HttpMethod.GET, "/api/v1/profiles/current")
        assertEquals(401, unauthenticated.statusCode.value())
        assertEquals("ACCESS_SESSION_EXPIRED", errorCode(unauthenticated))
        val unauthenticatedCreate =
            exchange(
                HttpMethod.POST,
                "/api/v1/profiles",
                body = mapOf("profileId" to UUID.randomUUID().toString(), "displayName" to "X"),
            )
        assertEquals(401, unauthenticatedCreate.statusCode.value())
    }

    @Test
    fun `neplatny vstup profilu je INVALID_REQUEST`() {
        val principal = registerPrincipal()
        val badSport =
            exchange(
                HttpMethod.POST,
                "/api/v1/profiles",
                body =
                    mapOf(
                        "profileId" to UUID.randomUUID().toString(),
                        "displayName" to "Athlete",
                        "primarySport" to "not a code",
                    ),
                accessToken = principal.accessToken,
            )
        assertEquals(400, badSport.statusCode.value())

        val badId =
            exchange(
                HttpMethod.POST,
                "/api/v1/profiles",
                body = mapOf("profileId" to "not-a-uuid", "displayName" to "Athlete"),
                accessToken = principal.accessToken,
            )
        assertEquals(400, badId.statusCode.value())
    }

    @Test
    fun `registrace zarizeni je idempotentni upsert a vaze session na instalaci`() {
        val principal = registerPrincipal()
        val installationId = UUID.randomUUID().toString()

        val first = registerDevice(principal, installationId = installationId, appVersion = "1.0.0")
        assertEquals(201, first.statusCode.value())
        assertEquals(installationId, JsonPath.parse(first.body).read("$.installationId"))
        assertEquals("ACTIVE", JsonPath.parse(first.body).read("$.status"))

        val second = registerDevice(principal, installationId = installationId, appVersion = "1.1.0")
        assertEquals(200, second.statusCode.value())
        assertEquals("1.1.0", JsonPath.parse(second.body).read("$.appVersion"))

        // DRC-006: žádný duplikát.
        assertEquals(
            1,
            jdbc.queryForObject(
                "SELECT count(*) FROM device_installation WHERE account_id = ?::uuid",
                Int::class.java,
                principal.accountId,
            ),
        )
        // C9 §6: aktuální auth session je navázaná na instalaci.
        assertEquals(
            installationId,
            jdbc.queryForObject(
                "SELECT device_installation_id::text FROM auth_session WHERE id = ?::uuid",
                String::class.java,
                principal.sessionId,
            ),
        )
        // DRC-014: registrace je auditovaná.
        val audits =
            jdbc.queryForObject(
                """
                SELECT count(*) FROM audit_event
                WHERE action = 'DeviceRegistered' AND outcome = 'SUCCESS'
                  AND principal_account_id = ?::uuid
                """.trimIndent(),
                Int::class.java,
                principal.accountId,
            )
        assertTrue(audits!! >= 2)
    }

    @Test
    fun `kolekce zarizeni je filtrovana principalem a stejna instalace pod druhym uctem je oddelena`() {
        val alice = registerPrincipal()
        val bob = registerPrincipal()
        val sharedInstallation = UUID.randomUUID().toString()

        assertEquals(201, registerDevice(alice, installationId = sharedInstallation).statusCode.value())
        // Stejný fyzický přístroj pod druhým účtem = oddělená registrace (C9 §5).
        assertEquals(201, registerDevice(bob, installationId = sharedInstallation).statusCode.value())

        val aliceDevices = exchange(HttpMethod.GET, "/api/v1/devices", accessToken = alice.accessToken)
        assertEquals(200, aliceDevices.statusCode.value())
        val aliceList = JsonPath.parse(aliceDevices.body).read<List<Map<String, Any>>>("$.devices")
        assertEquals(1, aliceList.size)
        assertEquals(sharedInstallation, aliceList.single()["installationId"])

        val bobDevices = exchange(HttpMethod.GET, "/api/v1/devices", accessToken = bob.accessToken)
        assertEquals(1, JsonPath.parse(bobDevices.body).read<List<Map<String, Any>>>("$.devices").size)
    }

    @Test
    fun `revokovana instalace se neda tise reaktivovat`() {
        val principal = registerPrincipal()
        val installationId = UUID.randomUUID().toString()
        assertEquals(201, registerDevice(principal, installationId = installationId).statusCode.value())
        jdbc.update(
            "UPDATE device_installation SET status = 'REVOKED' WHERE installation_id = ?::uuid",
            installationId,
        )

        val reRegister = registerDevice(principal, installationId = installationId)
        assertEquals(409, reRegister.statusCode.value())
        assertEquals("DEVICE_REVOKED", errorCode(reRegister))
    }

    @Test
    fun `neplatny vstup zarizeni je INVALID_REQUEST`() {
        val principal = registerPrincipal()
        val badPlatform =
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/${UUID.randomUUID()}",
                body = mapOf("platform" to "TOASTER", "appVersion" to "1.0.0", "localSchemaVersion" to "2"),
                accessToken = principal.accessToken,
            )
        assertEquals(400, badPlatform.statusCode.value())

        val badInstallation =
            exchange(
                HttpMethod.PUT,
                "/api/v1/devices/not-a-uuid",
                body = mapOf("platform" to "ANDROID", "appVersion" to "1.0.0", "localSchemaVersion" to "2"),
                accessToken = principal.accessToken,
            )
        assertEquals(400, badInstallation.statusCode.value())
    }

    @Test
    fun `constraints V3 vynucuji jeden SELF profil a unikatni par ucet-instalace`() {
        val principal = registerPrincipal()
        createProfile(principal)
        val accountId = UUID.fromString(principal.accountId)

        val selfViolation =
            runCatching {
                jdbc.update(
                    """
                    INSERT INTO athlete_profile
                        (id, account_id, profile_type, status, display_name, created_at, updated_at)
                    VALUES (?, ?, 'SELF', 'ACTIVE', 'Second', now(), now())
                    """.trimIndent(),
                    UUID.randomUUID(),
                    accountId,
                )
            }
        assertTrue(selfViolation.isFailure, "partial unique index jednoho SELF profilu musí odmítnout druhý")

        val installationId = UUID.randomUUID()
        jdbc.update(
            """
            INSERT INTO device_installation
                (account_id, installation_id, platform, app_version, local_schema_version, status, created_at, last_seen_at)
            VALUES (?, ?, 'ANDROID', '1.0.0', '2', 'ACTIVE', now(), now())
            """.trimIndent(),
            accountId,
            installationId,
        )
        val pkViolation =
            runCatching {
                jdbc.update(
                    """
                    INSERT INTO device_installation
                        (account_id, installation_id, platform, app_version, local_schema_version, status, created_at, last_seen_at)
                    VALUES (?, ?, 'ANDROID', '1.0.0', '2', 'ACTIVE', now(), now())
                    """.trimIndent(),
                    accountId,
                    installationId,
                )
            }
        assertTrue(pkViolation.isFailure, "PK (account, installation) musí odmítnout duplikát")

        // FK vazby session→zařízení: nevalidní instalace je odmítnuta.
        val fkViolation =
            runCatching {
                jdbc.update(
                    "UPDATE auth_session SET device_installation_id = ? WHERE account_id = ?",
                    UUID.randomUUID(),
                    accountId,
                )
            }
        assertTrue(fkViolation.isFailure, "composite FK musí odmítnout neregistrovanou instalaci")
        assertNotNull(fkViolation.exceptionOrNull())
    }
}
