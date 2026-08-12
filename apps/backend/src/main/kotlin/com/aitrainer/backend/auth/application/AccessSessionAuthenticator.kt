package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.domain.Account
import com.aitrainer.backend.auth.domain.AuthSession
import org.springframework.stereotype.Service
import java.time.Clock

/**
 * Serverové ověření access credential na chráněné hranici (ISC-008 —
 * session není trust boundary; principal se odvozuje z ověřené session,
 * nikdy z klientem dodaného ID, SAR-003). Default deny (SAR-001):
 * neznámá, expirovaná i revokovaná credential je odmítnuta.
 */
@Service
class AccessSessionAuthenticator(
    private val sessionRepository: AuthSessionRepository,
    private val accountRepository: AccountAuthRepository,
    private val clock: Clock,
) {
    enum class DenialReason {
        /** Neznámá nebo expirovaná access credential → ACCESS_SESSION_EXPIRED. */
        EXPIRED,

        /** Revokovaná session nebo účet bez oprávnění → SESSION_REVOKED. */
        REVOKED,
    }

    sealed interface Resolution {
        data class Active(
            val session: AuthSession,
            val account: Account,
        ) : Resolution

        data class Denied(
            val reason: DenialReason,
        ) : Resolution
    }

    fun resolve(accessToken: String?): Resolution {
        if (accessToken.isNullOrBlank()) {
            return Resolution.Denied(DenialReason.EXPIRED)
        }
        val session =
            sessionRepository.findSessionByAccessTokenHash(TokenHashing.hash(accessToken))
                ?: return Resolution.Denied(DenialReason.EXPIRED)
        if (session.revoked) {
            return Resolution.Denied(DenialReason.REVOKED)
        }
        if (!session.accessExpiresAt.isAfter(clock.instant())) {
            return Resolution.Denied(DenialReason.EXPIRED)
        }
        val account =
            accountRepository.findAccountById(session.accountId)
                ?: return Resolution.Denied(DenialReason.REVOKED)
        if (account.status.disabled || account.status.deleted) {
            return Resolution.Denied(DenialReason.REVOKED)
        }
        return Resolution.Active(session, account)
    }
}
