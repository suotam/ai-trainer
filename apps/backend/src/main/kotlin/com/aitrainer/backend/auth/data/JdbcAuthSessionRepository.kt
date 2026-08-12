package com.aitrainer.backend.auth.data

import com.aitrainer.backend.auth.application.AuthSessionRepository
import com.aitrainer.backend.auth.domain.AuthSession
import com.aitrainer.backend.auth.domain.RefreshCredential
import com.aitrainer.backend.auth.domain.RefreshCredentialStatus
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional
import java.sql.ResultSet
import java.sql.Timestamp
import java.time.Instant
import java.util.UUID

/**
 * JDBC perzistence auth_session a auth_refresh_credential (C6 §7.4).
 * V databázi jsou výhradně hashe tokenů (SDM-010); partial unique index
 * vynucuje právě jednu ACTIVE refresh credential na session.
 */
@Repository
class JdbcAuthSessionRepository(
    private val jdbc: JdbcClient,
) : AuthSessionRepository {
    @Transactional
    override fun insertSession(
        session: AuthSession,
        refreshCredential: RefreshCredential,
        issuedAt: Instant,
    ) {
        jdbc
            .sql(
                """
                INSERT INTO auth_session
                    (id, account_id, status, access_token_hash, access_expires_at, refresh_expires_at, issued_at)
                VALUES (:id, :accountId, 'ACTIVE', :accessHash, :accessExpiresAt, :refreshExpiresAt, :issuedAt)
                """.trimIndent(),
            ).param("id", session.id)
            .param("accountId", session.accountId)
            .param("accessHash", session.accessTokenHash)
            .param("accessExpiresAt", Timestamp.from(session.accessExpiresAt))
            .param("refreshExpiresAt", Timestamp.from(session.refreshExpiresAt))
            .param("issuedAt", Timestamp.from(issuedAt))
            .update()
        insertRefreshCredential(refreshCredential, issuedAt)
    }

    override fun findSessionByAccessTokenHash(accessTokenHash: String): AuthSession? =
        jdbc
            .sql("$SELECT_SESSION WHERE access_token_hash = :hash")
            .param("hash", accessTokenHash)
            .query { rs, _ -> mapSession(rs) }
            .optional()
            .orElse(null)

    override fun findSessionById(sessionId: UUID): AuthSession? =
        jdbc
            .sql("$SELECT_SESSION WHERE id = :id")
            .param("id", sessionId)
            .query { rs, _ -> mapSession(rs) }
            .optional()
            .orElse(null)

    override fun findRefreshCredentialByTokenHash(tokenHash: String): RefreshCredential? =
        jdbc
            .sql(
                """
                SELECT id, session_id, token_hash, status
                FROM auth_refresh_credential
                WHERE token_hash = :hash
                """.trimIndent(),
            ).param("hash", tokenHash)
            .query { rs, _ ->
                RefreshCredential(
                    id = UUID.fromString(rs.getString("id")),
                    sessionId = UUID.fromString(rs.getString("session_id")),
                    tokenHash = rs.getString("token_hash"),
                    status = RefreshCredentialStatus.valueOf(rs.getString("status")),
                )
            }.optional()
            .orElse(null)

    @Transactional
    override fun rotateSession(
        sessionId: UUID,
        rotatedCredentialId: UUID,
        newAccessTokenHash: String,
        newAccessExpiresAt: Instant,
        newRefreshCredential: RefreshCredential,
        now: Instant,
    ) {
        jdbc
            .sql(
                """
                UPDATE auth_refresh_credential
                SET status = 'ROTATED', rotated_at = :now
                WHERE id = :id AND status = 'ACTIVE'
                """.trimIndent(),
            ).param("now", Timestamp.from(now))
            .param("id", rotatedCredentialId)
            .update()
        insertRefreshCredential(newRefreshCredential, now)
        jdbc
            .sql(
                """
                UPDATE auth_session
                SET access_token_hash = :accessHash,
                    access_expires_at = :accessExpiresAt,
                    row_version = row_version + 1
                WHERE id = :id
                """.trimIndent(),
            ).param("accessHash", newAccessTokenHash)
            .param("accessExpiresAt", Timestamp.from(newAccessExpiresAt))
            .param("id", sessionId)
            .update()
    }

    @Transactional
    override fun revokeSession(
        sessionId: UUID,
        now: Instant,
    ) {
        jdbc
            .sql(
                """
                UPDATE auth_session
                SET status = 'REVOKED', revoked_at = :now, row_version = row_version + 1
                WHERE id = :id AND status = 'ACTIVE'
                """.trimIndent(),
            ).param("now", Timestamp.from(now))
            .param("id", sessionId)
            .update()
        jdbc
            .sql(
                """
                UPDATE auth_refresh_credential
                SET status = 'REVOKED', rotated_at = COALESCE(rotated_at, :now)
                WHERE session_id = :sessionId AND status <> 'REVOKED'
                """.trimIndent(),
            ).param("now", Timestamp.from(now))
            .param("sessionId", sessionId)
            .update()
    }

    private fun insertRefreshCredential(
        credential: RefreshCredential,
        now: Instant,
    ) {
        jdbc
            .sql(
                """
                INSERT INTO auth_refresh_credential (id, session_id, token_hash, status, created_at)
                VALUES (:id, :sessionId, :tokenHash, :status, :now)
                """.trimIndent(),
            ).param("id", credential.id)
            .param("sessionId", credential.sessionId)
            .param("tokenHash", credential.tokenHash)
            .param("status", credential.status.name)
            .param("now", Timestamp.from(now))
            .update()
    }

    private fun mapSession(rs: ResultSet): AuthSession =
        AuthSession(
            id = UUID.fromString(rs.getString("id")),
            accountId = UUID.fromString(rs.getString("account_id")),
            revoked = rs.getString("status") == "REVOKED",
            accessTokenHash = rs.getString("access_token_hash"),
            accessExpiresAt = rs.getTimestamp("access_expires_at").toInstant(),
            refreshExpiresAt = rs.getTimestamp("refresh_expires_at").toInstant(),
        )

    companion object {
        private const val SELECT_SESSION =
            "SELECT id, account_id, status, access_token_hash, access_expires_at, refresh_expires_at FROM auth_session"
    }
}
