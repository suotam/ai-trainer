package com.aitrainer.backend.auth.transport

import com.aitrainer.backend.auth.application.AccessSessionAuthenticator
import com.aitrainer.backend.infrastructure.http.ApiException
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Component
import java.util.UUID

/**
 * Principal chráněné operace (C8 §4, AOC-002): odvozuje se výhradně ze
 * serverem ověřené access session — klientem dodané account/owner ID není
 * důkaz. Default deny (AOC-003): chybějící/expirovaná/revokovaná credential
 * končí typovanou 401 dle C4, autorizace se nevyhodnocuje.
 */
@Component
class PrincipalResolver(
    private val accessSessionAuthenticator: AccessSessionAuthenticator,
) {
    data class Principal(
        val accountId: UUID,
        val sessionId: UUID,
    )

    fun require(authorization: String?): Principal =
        when (val resolution = accessSessionAuthenticator.resolve(bearerToken(authorization))) {
            is AccessSessionAuthenticator.Resolution.Active -> {
                Principal(
                    accountId = resolution.account.id,
                    sessionId = resolution.session.id,
                )
            }

            is AccessSessionAuthenticator.Resolution.Denied -> {
                when (resolution.reason) {
                    AccessSessionAuthenticator.DenialReason.EXPIRED -> {
                        throw ApiException(
                            status = HttpStatus.UNAUTHORIZED,
                            code = "ACCESS_SESSION_EXPIRED",
                            message = "The access session is missing or expired.",
                        )
                    }

                    AccessSessionAuthenticator.DenialReason.REVOKED -> {
                        throw ApiException(
                            status = HttpStatus.UNAUTHORIZED,
                            code = "SESSION_REVOKED",
                            message = "The session has been revoked.",
                        )
                    }
                }
            }
        }

    private fun bearerToken(authorization: String?): String? {
        val header = authorization ?: return null
        if (!header.startsWith("Bearer ", ignoreCase = true)) return null
        return header.substring("Bearer ".length).trim().ifEmpty { null }
    }
}
