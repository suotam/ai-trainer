package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.domain.IssuedSession
import com.aitrainer.backend.auth.domain.RefreshCredential
import com.aitrainer.backend.auth.domain.RefreshCredentialStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

sealed interface RefreshResult {
    data class Refreshed(
        val session: IssuedSession,
    ) : RefreshResult

    /** Neznámá nebo expirovaná refresh credential. */
    data object InvalidRefresh : RefreshResult

    /** Session je revokovaná (včetně revokace vyvolané detekcí replay). */
    data object SessionRevoked : RefreshResult

    data object AccountDisabled : RefreshResult

    data object AccountDeleted : RefreshResult
}

/**
 * Obnova access session rotující refresh credential (C3 §5 refreshed,
 * security §7.2): každé použití refresh vydá novou refresh credential
 * a zneplatní předchozí. Použití již ROTATED/REVOKED credential je
 * detekovaný replay — celá session se revokuje (ISC-006/007).
 */
@Service
class RefreshAuthSession(
    private val sessionRepository: AuthSessionRepository,
    private val accountRepository: AccountAuthRepository,
    private val tokenGenerator: TokenGenerator,
    private val auditRecorder: AuditRecorder,
    private val properties: com.aitrainer.backend.auth.AuthProperties,
    private val clock: Clock,
) {
    @Transactional
    fun refresh(presentedRefreshToken: String): RefreshResult {
        val now = clock.instant()
        val credential = sessionRepository.findRefreshCredentialByTokenHash(TokenHashing.hash(presentedRefreshToken))
        if (credential == null) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    policyDecision = "UNKNOWN_REFRESH",
                ),
            )
            return RefreshResult.InvalidRefresh
        }

        val session = sessionRepository.findSessionById(credential.sessionId)
        if (session == null) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalSessionId = credential.sessionId,
                    policyDecision = "UNKNOWN_SESSION",
                ),
            )
            return RefreshResult.InvalidRefresh
        }

        if (credential.status != RefreshCredentialStatus.ACTIVE) {
            // Replay rotované/revokované credential: konzervativně revokovat
            // celou session — credential mohla být kompromitována (security §7.2).
            if (!session.revoked) {
                sessionRepository.revokeSession(session.id, now)
                auditRecorder.record(
                    AuditEntry(
                        action = AuthAuditActions.AUTH_SESSION_REVOKED,
                        outcome = AuditOutcome.SUCCESS,
                        principalAccountId = session.accountId,
                        principalSessionId = session.id,
                        policyDecision = "REFRESH_REPLAY_DETECTED",
                    ),
                )
            }
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = session.accountId,
                    principalSessionId = session.id,
                    policyDecision = "REFRESH_REPLAY_DETECTED",
                ),
            )
            return RefreshResult.SessionRevoked
        }

        if (session.revoked) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = session.accountId,
                    principalSessionId = session.id,
                    policyDecision = "SESSION_REVOKED",
                ),
            )
            return RefreshResult.SessionRevoked
        }

        if (!session.refreshExpiresAt.isAfter(now)) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = session.accountId,
                    principalSessionId = session.id,
                    policyDecision = "REFRESH_EXPIRED",
                ),
            )
            return RefreshResult.InvalidRefresh
        }

        val account = accountRepository.findAccountById(session.accountId)
        if (account == null || account.status.deleted) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = session.accountId,
                    principalSessionId = session.id,
                    policyDecision = "ACCOUNT_DELETED",
                ),
            )
            return RefreshResult.AccountDeleted
        }
        if (account.status.disabled) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REFRESH_REJECTED,
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = session.accountId,
                    principalSessionId = session.id,
                    policyDecision = "ACCOUNT_DISABLED",
                ),
            )
            return RefreshResult.AccountDisabled
        }

        val newAccessToken = tokenGenerator.generate()
        val newRefreshToken = tokenGenerator.generate()
        val newAccessExpiresAt = now.plus(properties.accessTtl)
        val newCredential =
            RefreshCredential(
                id = UUID.randomUUID(),
                sessionId = session.id,
                tokenHash = TokenHashing.hash(newRefreshToken),
                status = RefreshCredentialStatus.ACTIVE,
            )
        sessionRepository.rotateSession(
            sessionId = session.id,
            rotatedCredentialId = credential.id,
            newAccessTokenHash = TokenHashing.hash(newAccessToken),
            newAccessExpiresAt = newAccessExpiresAt,
            newRefreshCredential = newCredential,
            now = now,
        )
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.AUTH_SESSION_REFRESHED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = session.accountId,
                principalSessionId = session.id,
            ),
        )
        return RefreshResult.Refreshed(
            IssuedSession(
                sessionId = session.id,
                accountId = session.accountId,
                accessToken = newAccessToken,
                accessExpiresAt = newAccessExpiresAt,
                refreshToken = newRefreshToken,
                refreshExpiresAt = session.refreshExpiresAt,
            ),
        )
    }
}
