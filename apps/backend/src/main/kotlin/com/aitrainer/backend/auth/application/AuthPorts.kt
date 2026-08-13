package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.domain.Account
import com.aitrainer.backend.auth.domain.AuthProvider
import com.aitrainer.backend.auth.domain.AuthSession
import com.aitrainer.backend.auth.domain.AuthenticationIdentity
import com.aitrainer.backend.auth.domain.RefreshCredential
import java.time.Instant
import java.util.UUID

/**
 * Porty auth application vrstvy (C3/C6). Application vrstva nezná SQL ani
 * HTTP; perzistenci vlastní data vrstva, transport controller.
 */

data class IdempotencyRecord(
    val key: String,
    val operation: String,
    val requestHash: String,
    val accountId: UUID?,
)

interface AccountAuthRepository {
    fun findAuthenticationIdentity(
        provider: AuthProvider,
        providerSubject: String,
    ): AuthenticationIdentity?

    fun findAccountByIdentityId(identityId: UUID): Account?

    fun findAccountById(accountId: UUID): Account?

    /**
     * Atomicky založí identity + account + authentication_identity
     * (first-party EMAIL_PASSWORD baseline, ADR-011) a idempotency záznam.
     */
    fun createStandardAccount(
        providerSubject: String,
        credentialHash: String,
        idempotencyKey: String,
        requestHash: String,
        now: Instant,
    ): Account

    fun findIdempotencyRecord(key: String): IdempotencyRecord?

    fun markAuthenticationIdentityUsed(
        authenticationIdentityId: UUID,
        now: Instant,
    )
}

interface AuthSessionRepository {
    /** Atomicky uloží novou session a její ACTIVE refresh credential. */
    fun insertSession(
        session: AuthSession,
        refreshCredential: RefreshCredential,
        issuedAt: Instant,
    )

    fun findSessionByAccessTokenHash(accessTokenHash: String): AuthSession?

    fun findSessionById(sessionId: UUID): AuthSession?

    fun findRefreshCredentialByTokenHash(tokenHash: String): RefreshCredential?

    /**
     * Atomická rotace: stará refresh credential → ROTATED, nová ACTIVE,
     * nový access token hash + expirace na session.
     */
    fun rotateSession(
        sessionId: UUID,
        rotatedCredentialId: UUID,
        newAccessTokenHash: String,
        newAccessExpiresAt: Instant,
        newRefreshCredential: RefreshCredential,
        now: Instant,
    )

    /** Revokuje session a všechny její refresh credentials (ISC-007). */
    fun revokeSession(
        sessionId: UUID,
        now: Instant,
    )

    /**
     * Aditivní vazba session → registrovaná instalace (C6 §8.3, C9 §6).
     * Vazba je bezpečnostní signál, nikdy autorizační důkaz (DRC-009).
     */
    fun bindDeviceInstallation(
        sessionId: UUID,
        accountId: UUID,
        installationId: UUID,
    )

    /**
     * Globální revokace (C13 §4, RVC-001): revokuje všechny aktivní session
     * účtu včetně volající a vrací jejich ID pro audit. Idempotentní.
     */
    fun revokeAllForAccount(
        accountId: UUID,
        now: Instant,
    ): List<UUID>

    /**
     * Revokuje všechny aktivní session vázané na instalaci (C13 §4/RVC-002)
     * a vrací jejich ID pro audit. Idempotentní.
     */
    fun revokeBoundToInstallation(
        accountId: UUID,
        installationId: UUID,
        now: Instant,
    ): List<UUID>
}

/** Hash hesla; nikdy plaintext (SDM-010). `dummyHash` slouží timing-safe loginu. */
interface PasswordHasher {
    fun hash(rawPassword: String): String

    fun matches(
        rawPassword: String,
        credentialHash: String,
    ): Boolean

    val dummyHash: String
}

/** Kryptograficky bezpečný neprůhledný token (access/refresh credential). */
interface TokenGenerator {
    fun generate(): String
}

/** Výsledky auditu podle C14 §5; záznam nikdy nenese secrets (AEC-003). */
enum class AuditOutcome {
    SUCCESS,
    FAILURE,
    REJECTED,
    CONFLICT,
}

data class AuditEntry(
    val action: String,
    val outcome: AuditOutcome,
    val principalAccountId: UUID? = null,
    val principalSessionId: UUID? = null,
    val target: String? = null,
    val policyDecision: String? = null,
)

interface AuditRecorder {
    fun record(entry: AuditEntry)
}

/** Stabilní názvy auditovaných auth událostí (C14 §6, domain-events §12.2). */
object AuthAuditActions {
    const val ACCOUNT_REGISTERED = "AccountRegistered"
    const val LOGIN_SUCCEEDED = "LoginSucceeded"
    const val LOGIN_FAILED = "LoginFailed"
    const val AUTH_SESSION_ISSUED = "AuthSessionIssued"
    const val AUTH_SESSION_REFRESHED = "AuthSessionRefreshed"
    const val AUTH_SESSION_REFRESH_REJECTED = "AuthSessionRefreshRejected"
    const val AUTH_SESSION_LOGGED_OUT = "AuthSessionLoggedOut"
    const val AUTH_SESSION_REVOKED = "AuthSessionRevoked"
}
