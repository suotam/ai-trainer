package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.domain.AuthProvider
import com.aitrainer.backend.auth.domain.IssuedSession
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock

sealed interface LoginResult {
    data class LoggedIn(
        val session: IssuedSession,
    ) : LoginResult

    /** Generický výsledek bez account enumeration (AAC-008). */
    data object InvalidCredentials : LoginResult

    data object AccountDisabled : LoginResult

    data object AccountDeleted : LoginResult
}

/**
 * Přihlášení first-party credential (C3 §6.3): ověření hesla, kontrola
 * stavu účtu (ISC-010 — SUSPENDED/LOCKED/DELETION_PENDING/DELETED nelze
 * obejít) a vydání nové session. Neexistující identita se ověřuje proti
 * dummy hashi, aby odpověď neměla rozlišitelný timing (AAC-008).
 */
@Service
class LoginWithPassword(
    private val accountRepository: AccountAuthRepository,
    private val sessionIssuer: SessionIssuer,
    private val passwordHasher: PasswordHasher,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    @Transactional
    fun login(
        rawEmail: String,
        rawPassword: String,
    ): LoginResult {
        val email = CredentialValidation.normalizeEmail(rawEmail)
        val identity = accountRepository.findAuthenticationIdentity(AuthProvider.EMAIL_PASSWORD, email)
        val credentialHash = identity?.credentialHash ?: passwordHasher.dummyHash
        val passwordMatches = passwordHasher.matches(rawPassword, credentialHash)

        if (identity == null || !passwordMatches) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.LOGIN_FAILED,
                    outcome = AuditOutcome.FAILURE,
                    policyDecision = "INVALID_CREDENTIALS",
                ),
            )
            return LoginResult.InvalidCredentials
        }

        val account = accountRepository.findAccountByIdentityId(identity.identityId)
        if (account == null) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.LOGIN_FAILED,
                    outcome = AuditOutcome.FAILURE,
                    policyDecision = "INVALID_CREDENTIALS",
                ),
            )
            return LoginResult.InvalidCredentials
        }
        if (account.status.deleted) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.LOGIN_FAILED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = account.id,
                    policyDecision = "ACCOUNT_DELETED",
                ),
            )
            return LoginResult.AccountDeleted
        }
        if (account.status.disabled) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.LOGIN_FAILED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = account.id,
                    policyDecision = "ACCOUNT_DISABLED",
                ),
            )
            return LoginResult.AccountDisabled
        }

        accountRepository.markAuthenticationIdentityUsed(identity.id, clock.instant())
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.LOGIN_SUCCEEDED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = account.id,
            ),
        )
        return LoginResult.LoggedIn(sessionIssuer.issue(account.id))
    }
}
