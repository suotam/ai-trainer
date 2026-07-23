package com.aitrainer.backend.infrastructure.http

import org.junit.jupiter.api.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

class RequestIdSupportTest {
    @Test
    fun `validni prichozi hodnota se prijme beze zmeny`() {
        val incoming = "01J3EXAMPLE8R0-request.ID_1"
        assertTrue(RequestIdSupport.isValid(incoming))
        assertEquals(incoming, RequestIdSupport.resolve(incoming))
    }

    @Test
    fun `chybejici hodnota se nahradi vygenerovanou`() {
        val resolved = RequestIdSupport.resolve(null)
        assertTrue(RequestIdSupport.isValid(resolved))
    }

    @Test
    fun `hodnota s nepovolenymi znaky se odmitne a nahradi`() {
        val invalid = "abc def\nghi"
        assertFalse(RequestIdSupport.isValid(invalid))
        assertNotEquals(invalid, RequestIdSupport.resolve(invalid))
        assertTrue(RequestIdSupport.isValid(RequestIdSupport.resolve(invalid)))
    }

    @Test
    fun `hodnota delsi nez 128 znaku se odmitne`() {
        val tooLong = "a".repeat(RequestIdSupport.MAX_LENGTH + 1)
        assertFalse(RequestIdSupport.isValid(tooLong))
        val maxAllowed = "a".repeat(RequestIdSupport.MAX_LENGTH)
        assertTrue(RequestIdSupport.isValid(maxAllowed))
    }

    @Test
    fun `prazdna hodnota se odmitne`() {
        assertFalse(RequestIdSupport.isValid(""))
    }

    @Test
    fun `generovana hodnota je validni a neprazdna`() {
        val generated = RequestIdSupport.generate()
        assertTrue(RequestIdSupport.isValid(generated))
        assertNotEquals(RequestIdSupport.generate(), generated)
    }
}
