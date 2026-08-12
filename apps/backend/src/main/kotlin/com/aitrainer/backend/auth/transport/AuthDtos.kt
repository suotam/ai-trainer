package com.aitrainer.backend.auth.transport

/**
 * Transport DTO auth API podle kanonického OpenAPI (C4/AAC-014). Vstupy
 * jsou nullable a validují se explicitně — chybějící pole je bezpečný
 * INVALID_REQUEST, ne 500. Response DTO nese plaintext tokeny výhradně
 * v HTTP odpovědi; nikdy se nelogují (AAC-009).
 */

data class RegistrationRequestDto(
    val email: String? = null,
    val password: String? = null,
)

data class LoginRequestDto(
    val email: String? = null,
    val password: String? = null,
)

data class RefreshRequestDto(
    val refreshToken: String? = null,
)

data class AuthSessionResponseDto(
    val accountId: String,
    val sessionId: String,
    val accessToken: String,
    val accessExpiresAt: String,
    val refreshToken: String,
    val refreshExpiresAt: String,
)

data class SessionContextResponseDto(
    val accountId: String,
    val sessionId: String,
    val accountType: String,
    val accountStatus: String,
    val accessExpiresAt: String,
)
