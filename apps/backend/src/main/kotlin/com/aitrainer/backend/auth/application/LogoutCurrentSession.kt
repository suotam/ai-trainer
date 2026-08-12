package com.aitrainer.backend.auth.application

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock

sealed interface LogoutResult {
    data object LoggedOut : LogoutResult

    /** Session už byla ukončena — opakovaný logout je no-op (C4 §10). */
    data object AlreadyLoggedOut : LogoutResult

    data class NotAuthorized(
        val reason: AccessSessionAuthenticator.DenialReason,
    ) : LogoutResult
}

/**
 * Odhlášení = ukončení aktuální session (C3 §6.2): revokuje session
 * příslušnou k předložené access credential. Revokovaná session dále
 * nepotvrdí žádnou serverovou operaci (ISC-007). Odhlášení není smazání
 * účtu ani lokálních dat (LSM-006 vlastní mobilní strana).
 */
@Service
class LogoutCurrentSession(
    private val sessionRepository: AuthSessionRepository,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    @Transactional
    fun logout(accessToken: String?): LogoutResult {
        if (accessToken.isNullOrBlank()) {
            return LogoutResult.NotAuthorized(AccessSessionAuthenticator.DenialReason.EXPIRED)
        }
        val session =
            sessionRepository.findSessionByAccessTokenHash(TokenHashing.hash(accessToken))
                ?: return LogoutResult.NotAuthorized(AccessSessionAuthenticator.DenialReason.EXPIRED)
        if (session.revoked) {
            return LogoutResult.AlreadyLoggedOut
        }
        val now = clock.instant()
        if (!session.accessExpiresAt.isAfter(now)) {
            return LogoutResult.NotAuthorized(AccessSessionAuthenticator.DenialReason.EXPIRED)
        }
        sessionRepository.revokeSession(session.id, now)
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.AUTH_SESSION_LOGGED_OUT,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = session.accountId,
                principalSessionId = session.id,
            ),
        )
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.AUTH_SESSION_REVOKED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = session.accountId,
                principalSessionId = session.id,
                policyDecision = "LOGOUT",
            ),
        )
        return LogoutResult.LoggedOut
    }
}
