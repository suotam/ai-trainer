package com.aitrainer.backend.auth.data

import com.aitrainer.backend.auth.application.PasswordHasher
import com.aitrainer.backend.auth.application.TokenGenerator
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.stereotype.Component
import java.security.SecureRandom
import java.util.Base64

/**
 * Adaptivní hash hesla (BCrypt). Heslo se nikdy neukládá ani neloguje
 * jako plaintext (SDM-010, AAC-009). `dummyHash` umožňuje loginu ověřovat
 * i neexistující identitu se stejným výpočetním profilem (AAC-008 —
 * bez timing-based account enumeration).
 */
@Component
class BcryptPasswordHasher : PasswordHasher {
    private val encoder = BCryptPasswordEncoder()

    override val dummyHash: String = requireNotNull(encoder.encode("dummy-timing-equalizer"))

    override fun hash(rawPassword: String): String = requireNotNull(encoder.encode(rawPassword))

    override fun matches(
        rawPassword: String,
        credentialHash: String,
    ): Boolean = encoder.matches(rawPassword, credentialHash)
}

/**
 * Neprůhledný 256bitový náhodný token (access/refresh credential).
 * Formát je implementační detail za ADR-011 adaptérem — klient s ním
 * zachází jako s neprůhlednou hodnotou.
 */
@Component
class SecureRandomTokenGenerator : TokenGenerator {
    private val random = SecureRandom()
    private val encoder = Base64.getUrlEncoder().withoutPadding()

    override fun generate(): String {
        val bytes = ByteArray(32)
        random.nextBytes(bytes)
        return encoder.encodeToString(bytes)
    }
}
