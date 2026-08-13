package com.aitrainer.backend.auth.application

import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

/**
 * Globální revokace session účtu (C13 §4, „odhlásit všude"): revokuje
 * všechny aktivní session principala včetně volající (RVC-006) a každou
 * audituje (RVC-012). Idempotentní (RVC-004) — nad již revokovaným stavem
 * je no-op. Ruší výhradně oprávnění, žádná data (RVC-005).
 */
@Service
class RevokeAllSessions(
    private val sessionRepository: AuthSessionRepository,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    @Transactional
    fun revokeAll(principalAccountId: UUID): Int {
        val revoked = sessionRepository.revokeAllForAccount(principalAccountId, clock.instant())
        revoked.forEach { sessionId ->
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REVOKED,
                    outcome = AuditOutcome.SUCCESS,
                    principalAccountId = principalAccountId,
                    principalSessionId = sessionId,
                    policyDecision = "REVOKE_ALL",
                ),
            )
        }
        return revoked.size
    }
}
