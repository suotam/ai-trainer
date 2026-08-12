package com.aitrainer.backend.auth.data

import com.aitrainer.backend.auth.application.AccountAuthRepository
import com.aitrainer.backend.auth.application.IdempotencyRecord
import com.aitrainer.backend.auth.application.RegisterAccount
import com.aitrainer.backend.auth.domain.Account
import com.aitrainer.backend.auth.domain.AccountStatus
import com.aitrainer.backend.auth.domain.AccountType
import com.aitrainer.backend.auth.domain.AuthProvider
import com.aitrainer.backend.auth.domain.AuthenticationIdentity
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import org.springframework.transaction.annotation.Transactional
import java.sql.ResultSet
import java.time.Instant
import java.util.UUID

/**
 * JDBC perzistence account/identity/authentication_identity podle C6 §7.
 * Schema vlastní Flyway migrace (SDM-001); repository nikdy neukládá
 * plaintext credential (SDM-010).
 */
@Repository
class JdbcAccountAuthRepository(
    private val jdbc: JdbcClient,
) : AccountAuthRepository {
    override fun findAuthenticationIdentity(
        provider: AuthProvider,
        providerSubject: String,
    ): AuthenticationIdentity? =
        jdbc
            .sql(
                """
                SELECT id, identity_id, provider, provider_subject, credential_hash
                FROM authentication_identity
                WHERE provider = :provider AND provider_subject = :subject
                """.trimIndent(),
            ).param("provider", provider.name)
            .param("subject", providerSubject)
            .query { rs, _ -> mapAuthenticationIdentity(rs) }
            .optional()
            .orElse(null)

    override fun findAccountByIdentityId(identityId: UUID): Account? =
        jdbc
            .sql("SELECT id, identity_id, status, account_type FROM account WHERE identity_id = :identityId")
            .param("identityId", identityId)
            .query { rs, _ -> mapAccount(rs) }
            .optional()
            .orElse(null)

    override fun findAccountById(accountId: UUID): Account? =
        jdbc
            .sql("SELECT id, identity_id, status, account_type FROM account WHERE id = :id")
            .param("id", accountId)
            .query { rs, _ -> mapAccount(rs) }
            .optional()
            .orElse(null)

    @Transactional
    override fun createStandardAccount(
        providerSubject: String,
        credentialHash: String,
        idempotencyKey: String,
        requestHash: String,
        now: Instant,
    ): Account {
        val identityId = UUID.randomUUID()
        val accountId = UUID.randomUUID()
        jdbc
            .sql("INSERT INTO identity (id, status, created_at) VALUES (:id, :status, :now)")
            .param("id", identityId)
            .param("status", "ACTIVE")
            .param("now", java.sql.Timestamp.from(now))
            .update()
        jdbc
            .sql(
                """
                INSERT INTO account (id, identity_id, status, account_type, created_at, updated_at)
                VALUES (:id, :identityId, :status, :type, :now, :now)
                """.trimIndent(),
            ).param("id", accountId)
            .param("identityId", identityId)
            .param("status", AccountStatus.ACTIVE.name)
            .param("type", AccountType.STANDARD.name)
            .param("now", java.sql.Timestamp.from(now))
            .update()
        jdbc
            .sql(
                """
                INSERT INTO authentication_identity
                    (id, identity_id, provider, provider_subject, credential_hash, verified, is_primary, created_at)
                VALUES (:id, :identityId, :provider, :subject, :credentialHash, false, true, :now)
                """.trimIndent(),
            ).param("id", UUID.randomUUID())
            .param("identityId", identityId)
            .param("provider", AuthProvider.EMAIL_PASSWORD.name)
            .param("subject", providerSubject)
            .param("credentialHash", credentialHash)
            .param("now", java.sql.Timestamp.from(now))
            .update()
        jdbc
            .sql(
                """
                INSERT INTO idempotency_record (idempotency_key, operation, request_hash, account_id, created_at)
                VALUES (:key, :operation, :requestHash, :accountId, :now)
                """.trimIndent(),
            ).param("key", idempotencyKey)
            .param("operation", RegisterAccount.OPERATION)
            .param("requestHash", requestHash)
            .param("accountId", accountId)
            .param("now", java.sql.Timestamp.from(now))
            .update()
        return Account(
            id = accountId,
            identityId = identityId,
            status = AccountStatus.ACTIVE,
            type = AccountType.STANDARD,
        )
    }

    override fun findIdempotencyRecord(key: String): IdempotencyRecord? =
        jdbc
            .sql(
                """
                SELECT idempotency_key, operation, request_hash, account_id
                FROM idempotency_record
                WHERE idempotency_key = :key
                """.trimIndent(),
            ).param("key", key)
            .query { rs, _ ->
                IdempotencyRecord(
                    key = rs.getString("idempotency_key"),
                    operation = rs.getString("operation"),
                    requestHash = rs.getString("request_hash"),
                    accountId = rs.getString("account_id")?.let(UUID::fromString),
                )
            }.optional()
            .orElse(null)

    override fun markAuthenticationIdentityUsed(
        authenticationIdentityId: UUID,
        now: Instant,
    ) {
        jdbc
            .sql("UPDATE authentication_identity SET last_used_at = :now WHERE id = :id")
            .param("now", java.sql.Timestamp.from(now))
            .param("id", authenticationIdentityId)
            .update()
    }

    private fun mapAccount(rs: ResultSet): Account =
        Account(
            id = UUID.fromString(rs.getString("id")),
            identityId = UUID.fromString(rs.getString("identity_id")),
            status = AccountStatus.valueOf(rs.getString("status")),
            type = AccountType.valueOf(rs.getString("account_type")),
        )

    private fun mapAuthenticationIdentity(rs: ResultSet): AuthenticationIdentity =
        AuthenticationIdentity(
            id = UUID.fromString(rs.getString("id")),
            identityId = UUID.fromString(rs.getString("identity_id")),
            provider = AuthProvider.valueOf(rs.getString("provider")),
            providerSubject = rs.getString("provider_subject"),
            credentialHash = rs.getString("credential_hash"),
        )
}
