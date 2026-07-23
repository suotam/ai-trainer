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
    fun `kontrakt obsahuje pouze oba health endpointy`() {
        assertEquals(
            setOf("/api/v1/health/live", "/api/v1/health/ready"),
            openApi.paths.keys,
        )
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
