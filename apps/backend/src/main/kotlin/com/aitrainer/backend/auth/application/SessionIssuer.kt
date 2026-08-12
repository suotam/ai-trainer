package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.AuthProperties
import com.aitrainer.backend.auth.domain.AuthSession
import com.aitrainer.backend.auth.domain.IssuedSession
import com.aitrainer.backend.auth.domain.RefreshCredential
import com.aitrainer.backend.auth.domain.RefreshCredentialStatus
import org.springframework.stereotype.Service
import java.time.Clock
import java.util.UUID

/**
 * Vydání nové aplikační auth session (C3 §5 created→active): krátce žijící
 * access credential + rotující refresh credential (ISC-006). Plaintext
 * tokeny existují jen v návratové hodnotě; do DB jde výhradně hash.
 */
@Service
class SessionIssuer(
    private val sessionRepository: AuthSessionRepository,
    private val tokenGenerator: TokenGenerator,
    private val auditRecorder: AuditRecorder,
    private val properties: AuthProperties,
    private val clock: Clock,
) {
    fun issue(accountId: UUID): IssuedSession {
        val now = clock.instant()
        val accessToken = tokenGenerator.generate()
        val refreshToken = tokenGenerator.generate()
        val session =
            AuthSession(
                id = UUID.randomUUID(),
                accountId = accountId,
                revoked = false,
                accessTokenHash = TokenHashing.hash(accessToken),
                accessExpiresAt = now.plus(properties.accessTtl),
                refreshExpiresAt = now.plus(properties.refreshTtl),
            )
        val refreshCredential =
            RefreshCredential(
                id = UUID.randomUUID(),
                sessionId = session.id,
                tokenHash = TokenHashing.hash(refreshToken),
                status = RefreshCredentialStatus.ACTIVE,
            )
        sessionRepository.insertSession(session, refreshCredential, now)
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.AUTH_SESSION_ISSUED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = accountId,
                principalSessionId = session.id,
            ),
        )
        return IssuedSession(
            sessionId = session.id,
            accountId = accountId,
            accessToken = accessToken,
            accessExpiresAt = session.accessExpiresAt,
            refreshToken = refreshToken,
            refreshExpiresAt = session.refreshExpiresAt,
        )
    }
}
