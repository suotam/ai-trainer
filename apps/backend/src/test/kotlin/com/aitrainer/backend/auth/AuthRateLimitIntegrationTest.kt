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
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

/**
 * Abuse protection baseline (SAR-013, AAC-013): po překročení limitu
 * vrací veřejný auth endpoint 429 RATE_LIMITED s Retry-After (C4 §9).
 * Vlastní context s nízkým limitem, aby test neovlivnil ostatní suite.
 */
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = [
        "aitrainer.auth.rate-limit.limit=3",
        "aitrainer.auth.rate-limit.window=PT1M",
    ],
)
@AutoConfigureTestRestTemplate
@Import(TestPostgresConfiguration::class)
class AuthRateLimitIntegrationTest {
    @Autowired
    lateinit var restTemplate: TestRestTemplate

    private fun attemptLogin(): ResponseEntity<String> {
        val headers = HttpHeaders()
        headers.contentType = MediaType.APPLICATION_JSON
        val body = mapOf("email" to "rate-limit@example.com", "password" to "wrong-password-1")
        return restTemplate.exchange("/api/v1/auth/sessions", HttpMethod.POST, HttpEntity(body, headers), String::class.java)
    }

    @Test
    fun `prekroceni limitu vraci 429 RATE_LIMITED s Retry-After`() {
        repeat(3) {
            assertEquals(401, attemptLogin().statusCode.value())
        }

        val limited = attemptLogin()
        assertEquals(429, limited.statusCode.value())
        assertEquals("RATE_LIMITED", JsonPath.parse(limited.body).read("$.code"))
        val retryAfter = assertNotNull(limited.headers.getFirst("Retry-After"))
        assertTrue(retryAfter.toLong() >= 1)
    }
}
