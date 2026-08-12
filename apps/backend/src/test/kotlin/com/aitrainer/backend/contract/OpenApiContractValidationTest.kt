package com.aitrainer.backend.contract

import io.swagger.parser.OpenAPIParser
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.parser.core.models.ParseOptions
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInstance
import java.nio.file.Files
import java.nio.file.Path
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Contract test kanonického OpenAPI (`test-strategy.md` §8.1): validita,
 * existence obou health endpointů, status codes a schémata. Čte přímo
 * kanonický soubor v packages/contracts — žádná druhá kopie schematu
 * (test-strategy §8.2).
 */
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class OpenApiContractValidationTest {
    private lateinit var openApi: OpenAPI

    private fun contractPath(): Path {
        // Testy běží s working directory apps/backend.
        val path = Path.of("../../packages/contracts/openapi/ai-trainer-api.yaml")
        assertTrue(Files.exists(path), "Kanonický OpenAPI soubor neexistuje: ${path.toAbsolutePath()}")
        return path
    }

    @BeforeAll
    fun parseContract() {
        val options = ParseOptions().apply { isResolve = true }
        val result = OpenAPIParser().readLocation(contractPath().toUri().toString(), null, options)
        assertTrue(
            result.messages.isNullOrEmpty(),
            "OpenAPI není validní: ${result.messages}",
        )
        openApi = assertNotNull(result.openAPI, "OpenAPI se nepodařilo naparsovat")
    }

    @Test
    fun `kontrakt obsahuje health, R2 auth, profile a device endpointy`() {
        assertEquals(
            setOf(
                "/api/v1/health/live",
                "/api/v1/health/ready",
                "/api/v1/auth/registrations",
                "/api/v1/auth/sessions",
                "/api/v1/auth/sessions/refresh",
                "/api/v1/auth/sessions/current",
                "/api/v1/auth/session",
                "/api/v1/profiles",
                "/api/v1/profiles/current",
                "/api/v1/profiles/{profileId}",
                "/api/v1/devices",
                "/api/v1/devices/{installationId}",
            ),
            openApi.paths.keys,
        )
    }

    @Test
    fun `profile a device operace deklaruji kanonicke operationId a status codes`() {
        val createProfile = assertNotNull(openApi.paths["/api/v1/profiles"]?.post)
        assertEquals("createProfile", createProfile.operationId)
        assertEquals(setOf("200", "201", "400", "401", "409", "500"), createProfile.responses.keys)

        val currentProfile = assertNotNull(openApi.paths["/api/v1/profiles/current"]?.get)
        assertEquals("getCurrentProfile", currentProfile.operationId)
        assertEquals(setOf("200", "401", "404", "500"), currentProfile.responses.keys)

        val profileById = assertNotNull(openApi.paths["/api/v1/profiles/{profileId}"]?.get)
        assertEquals("getProfileById", profileById.operationId)
        assertEquals(setOf("200", "401", "404", "500"), profileById.responses.keys)

        val registerDevice = assertNotNull(openApi.paths["/api/v1/devices/{installationId}"]?.put)
        assertEquals("registerDevice", registerDevice.operationId)
        assertEquals(setOf("200", "201", "400", "401", "409", "500"), registerDevice.responses.keys)

        val listDevices = assertNotNull(openApi.paths["/api/v1/devices"]?.get)
        assertEquals("listDevices", listDevices.operationId)
        assertEquals(setOf("200", "401", "500"), listDevices.responses.keys)
    }

    @Test
    fun `profile a device schemata deklaruji povinna pole`() {
        val schemas = assertNotNull(openApi.components.schemas)

        assertEquals(
            setOf("profileId", "displayName"),
            assertNotNull(schemas["CreateProfileRequest"]).required.toSet(),
        )
        assertEquals(
            setOf("profileId", "accountId", "profileType", "status", "displayName", "createdAt", "updatedAt"),
            assertNotNull(schemas["ProfileResponse"]).required.toSet(),
        )
        assertEquals(
            setOf("platform", "appVersion", "localSchemaVersion"),
            assertNotNull(schemas["RegisterDeviceRequest"]).required.toSet(),
        )
        assertEquals(
            setOf("installationId", "platform", "appVersion", "localSchemaVersion", "status", "createdAt", "lastSeenAt"),
            assertNotNull(schemas["DeviceResponse"]).required.toSet(),
        )
        assertEquals(setOf("devices"), assertNotNull(schemas["DeviceListResponse"]).required.toSet())
    }

    @Test
    fun `liveness deklaruje operationId a status codes 200 a 500`() {
        val operation = assertNotNull(openApi.paths["/api/v1/health/live"]?.get)
        assertEquals("getLiveness", operation.operationId)
        assertEquals(setOf("200", "500"), operation.responses.keys)
    }

    @Test
    fun `readiness deklaruje operationId a status codes 200, 503 a 500`() {
        val operation = assertNotNull(openApi.paths["/api/v1/health/ready"]?.get)
        assertEquals("getReadiness", operation.operationId)
        assertEquals(setOf("200", "503", "500"), operation.responses.keys)
    }

    @Test
    fun `schemata obsahuji povinna pole podle r0-api-contract`() {
        val schemas = assertNotNull(openApi.components.schemas)

        val liveness = assertNotNull(schemas["LivenessResponse"])
        assertEquals(setOf("status", "service", "timestamp", "version"), liveness.required.toSet())

        val readiness = assertNotNull(schemas["ReadinessResponse"])
        assertEquals(setOf("status", "service", "timestamp", "version", "checks"), readiness.required.toSet())

        val error = assertNotNull(schemas["ErrorResponse"])
        assertEquals(setOf("code", "message", "requestId", "timestamp"), error.required.toSet())
    }

    @Test
    fun `auth operace deklaruji kanonicke operationId a status codes podle C4`() {
        val register = assertNotNull(openApi.paths["/api/v1/auth/registrations"]?.post)
        assertEquals("registerAccount", register.operationId)
        assertEquals(setOf("201", "400", "409", "429", "500"), register.responses.keys)
        assertTrue(
            register.parameters.orEmpty().any { it.name == "Idempotency-Key" && it.required },
            "Registrace musí vyžadovat Idempotency-Key (AAC-005)",
        )

        val login = assertNotNull(openApi.paths["/api/v1/auth/sessions"]?.post)
        assertEquals("loginWithPassword", login.operationId)
        assertEquals(setOf("200", "400", "401", "403", "429", "500"), login.responses.keys)

        val refresh = assertNotNull(openApi.paths["/api/v1/auth/sessions/refresh"]?.post)
        assertEquals("refreshAuthSession", refresh.operationId)
        assertEquals(setOf("200", "400", "401", "403", "429", "500"), refresh.responses.keys)

        val logout = assertNotNull(openApi.paths["/api/v1/auth/sessions/current"]?.delete)
        assertEquals("logoutCurrentSession", logout.operationId)
        assertEquals(setOf("204", "401", "429", "500"), logout.responses.keys)

        val sessionContext = assertNotNull(openApi.paths["/api/v1/auth/session"]?.get)
        assertEquals("getSessionContext", sessionContext.operationId)
        assertEquals(setOf("200", "401", "429", "500"), sessionContext.responses.keys)
    }

    @Test
    fun `auth schemata deklaruji povinna pole a session tokeny`() {
        val schemas = assertNotNull(openApi.components.schemas)

        val session = assertNotNull(schemas["AuthSessionResponse"])
        assertEquals(
            setOf("accountId", "sessionId", "accessToken", "accessExpiresAt", "refreshToken", "refreshExpiresAt"),
            session.required.toSet(),
        )

        val context = assertNotNull(schemas["SessionContextResponse"])
        assertEquals(
            setOf("accountId", "sessionId", "accountType", "accountStatus", "accessExpiresAt"),
            context.required.toSet(),
        )

        assertEquals(setOf("email", "password"), assertNotNull(schemas["RegistrationRequest"]).required.toSet())
        assertEquals(setOf("email", "password"), assertNotNull(schemas["LoginRequest"]).required.toSet())
        assertEquals(setOf("refreshToken"), assertNotNull(schemas["RefreshRequest"]).required.toSet())
    }

    @Test
    fun `health odpovedi maji X-Request-Id header a JSON content type`() {
        listOf("/api/v1/health/live", "/api/v1/health/ready").forEach { path ->
            val operation = assertNotNull(openApi.paths[path]?.get)
            operation.responses.forEach { (status, response) ->
                assertTrue(
                    response.headers?.containsKey("X-Request-Id") == true,
                    "$path $status nemá X-Request-Id header",
                )
                assertTrue(
                    response.content?.containsKey("application/json") == true,
                    "$path $status nemá application/json content",
                )
            }
        }
    }
}
