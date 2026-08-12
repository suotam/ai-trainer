package com.aitrainer.backend.auth

import ch.qos.logback.classic.Logger
import ch.qos.logback.classic.spi.ILoggingEvent
import ch.qos.logback.core.read.ListAppender
import com.aitrainer.backend.testsupport.TestPostgresConfiguration
import com.jayway.jsonpath.JsonPath
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.slf4j.LoggerFactory
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
 * Log-redaction evidence (SAR-012, AAC-009, C4 §15): hesla ani vydané
 * access/refresh tokeny se během auth operací nesmí objevit v žádném
 * log výstupu aplikace.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = ["aitrainer.auth.rate-limit.limit=100000"],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class AuthLogRedactionIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    private val rootLogger = LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME) as Logger
    private val appender = ListAppender<ILoggingEvent>()

    @BeforeEach
    fun attachAppender() {
        appender.start()
        rootLogger.addAppender(appender)
    }

    @AfterEach
    fun detachAppender() {
        rootLogger.detachAppender(appender)
        appender.stop()
    }

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

    @Test
    fun `hesla a tokeny se neobjevi v logu behem auth flow`() {
        val email = "redaction-${UUID.randomUUID()}@example.com"
        val password = "redaction-secret-99"

        val registered =
            postJson(
                "/api/v1/auth/registrations",
                mapOf("email" to email, "password" to password),
                mapOf("Idempotency-Key" to "key-${UUID.randomUUID()}"),
            )
        assertEquals(201, registered.statusCode.value())
        val accessToken = JsonPath.parse(registered.body).read<String>("$.accessToken")
        val refreshToken = JsonPath.parse(registered.body).read<String>("$.refreshToken")

        assertEquals(
            200,
            postJson("/api/v1/auth/sessions", mapOf("email" to email, "password" to password)).statusCode.value(),
        )
        assertEquals(
            401,
            postJson("/api/v1/auth/sessions", mapOf("email" to email, "password" to "wrong-password-1")).statusCode.value(),
        )
        assertEquals(
            200,
            postJson("/api/v1/auth/sessions/refresh", mapOf("refreshToken" to refreshToken)).statusCode.value(),
        )

        val loggedText =
            appender.list.joinToString("\n") { event ->
                event.formattedMessage + (event.throwableProxy?.message ?: "")
            }
        listOf(password, "wrong-password-1", accessToken, refreshToken).forEach { secret ->
            assertTrue(!loggedText.contains(secret), "Log obsahuje citlivou hodnotu: $secret")
        }
    }
}
