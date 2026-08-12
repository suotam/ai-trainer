package com.aitrainer.backend.auth.application

import java.nio.charset.StandardCharsets
import java.security.MessageDigest

/**
 * Deterministický otisk access/refresh tokenu pro serverové uložení a
 * vyhledání. V databázi je vždy jen hash, nikdy plaintext token
 * (SDM-010, DAR-010). SHA-256 stačí — token je 256bitová náhodná hodnota,
 * ne uživatelské heslo (to hashuje [PasswordHasher] s adaptivní funkcí).
 */
object TokenHashing {
    fun hash(token: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val bytes = digest.digest(token.toByteArray(StandardCharsets.UTF_8))
        return bytes.joinToString(separator = "") { "%02x".format(it) }
    }
}
