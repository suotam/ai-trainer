package com.aitrainer.backend.auth.application

/**
 * Baseline validace first-party credentials (ADR-011). Normalizovaný e-mail
 * je stabilní provider subject pro EMAIL_PASSWORD (C3 §4.2); e-mail sám
 * o sobě není interní identita (ISC-004).
 */
object CredentialValidation {
    const val MIN_PASSWORD_LENGTH = 8
    const val MAX_PASSWORD_LENGTH = 200
    const val MAX_EMAIL_LENGTH = 320

    private val emailPattern = Regex("^[^@\\s]{1,64}@[^@\\s]+\\.[^@\\s]+$")

    fun normalizeEmail(rawEmail: String): String = rawEmail.trim().lowercase()

    fun isValidEmail(normalizedEmail: String): Boolean = normalizedEmail.length <= MAX_EMAIL_LENGTH && emailPattern.matches(normalizedEmail)

    fun isValidPassword(rawPassword: String): Boolean = rawPassword.length in MIN_PASSWORD_LENGTH..MAX_PASSWORD_LENGTH
}
