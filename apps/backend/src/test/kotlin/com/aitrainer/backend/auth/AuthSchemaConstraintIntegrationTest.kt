package com.aitrainer.backend.auth

import com.aitrainer.backend.testsupport.TestPostgresConfiguration
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.Import
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.jdbc.core.JdbcTemplate
import java.util.UUID
import javax.sql.DataSource
import kotlin.test.assertEquals

/**
 * Constraint testy V2 schématu (SDM-004 — invarianty nese FK/UNIQUE/CHECK):
 * unikátní přihlašovací identita (SDM-009/INV-011), právě jedna ACTIVE
 * refresh credential na session a odmítnutí neznámých stavových hodnot.
 */
@SpringBootTest
@Import(TestPostgresConfiguration::class)
class AuthSchemaConstraintIntegrationTest {
    @Autowired
    lateinit var dataSource: DataSource

    private val jdbc by lazy { JdbcTemplate(dataSource) }

    private fun insertIdentity(): UUID {
        val id = UUID.randomUUID()
        jdbc.update("INSERT INTO identity (id, status, created_at) VALUES (?, 'ACTIVE', now())", id)
        return id
    }

    private fun insertAccount(identityId: UUID): UUID {
        val id = UUID.randomUUID()
        jdbc.update(
            """
            INSERT INTO account (id, identity_id, status, account_type, created_at, updated_at)
            VALUES (?, ?, 'ACTIVE', 'STANDARD', now(), now())
            """.trimIndent(),
            id,
            identityId,
        )
        return id
    }

    private fun insertSession(accountId: UUID): UUID {
        val id = UUID.randomUUID()
        jdbc.update(
            """
            INSERT INTO auth_session
                (id, account_id, status, access_token_hash, access_expires_at, refresh_expires_at, issued_at)
            VALUES (?, ?, 'ACTIVE', ?, now() + interval '15 minutes', now() + interval '30 days', now())
            """.trimIndent(),
            id,
            accountId,
            "hash-${UUID.randomUUID()}",
        )
        return id
    }

    @Test
    fun `unikatni provider a provider_subject odmitne druhou identitu`() {
        val subject = "unique-${UUID.randomUUID()}@example.com"
        val first = insertIdentity()
        val second = insertIdentity()
        jdbc.update(
            """
            INSERT INTO authentication_identity (id, identity_id, provider, provider_subject, created_at)
            VALUES (?, ?, 'EMAIL_PASSWORD', ?, now())
            """.trimIndent(),
            UUID.randomUUID(),
            first,
            subject,
        )

        assertThrows<DataIntegrityViolationException> {
            jdbc.update(
                """
                INSERT INTO authentication_identity (id, identity_id, provider, provider_subject, created_at)
                VALUES (?, ?, 'EMAIL_PASSWORD', ?, now())
                """.trimIndent(),
                UUID.randomUUID(),
                second,
                subject,
            )
        }
    }

    @Test
    fun `session smi mit jen jednu ACTIVE refresh credential`() {
        val sessionId = insertSession(insertAccount(insertIdentity()))

        fun insertRefresh(status: String) =
            jdbc.update(
                """
                INSERT INTO auth_refresh_credential (id, session_id, token_hash, status, created_at)
                VALUES (?, ?, ?, ?, now())
                """.trimIndent(),
                UUID.randomUUID(),
                sessionId,
                "refresh-hash-${UUID.randomUUID()}",
                status,
            )

        insertRefresh("ACTIVE")
        assertThrows<DataIntegrityViolationException> { insertRefresh("ACTIVE") }
        // Rotované credentials se hromadit smí — unikátnost platí jen pro ACTIVE.
        insertRefresh("ROTATED")
        assertEquals(
            2,
            jdbc.queryForObject(
                "SELECT count(*) FROM auth_refresh_credential WHERE session_id = ?",
                Int::class.java,
                sessionId,
            ),
        )
    }

    @Test
    fun `neznamy stav uctu nebo session je odmitnut CHECK constraintem`() {
        val identityId = insertIdentity()
        assertThrows<DataIntegrityViolationException> {
            jdbc.update(
                """
                INSERT INTO account (id, identity_id, status, account_type, created_at, updated_at)
                VALUES (?, ?, 'NOT_A_STATUS', 'STANDARD', now(), now())
                """.trimIndent(),
                UUID.randomUUID(),
                identityId,
            )
        }

        val accountId = insertAccount(insertIdentity())
        assertThrows<DataIntegrityViolationException> {
            jdbc.update(
                """
                INSERT INTO auth_session
                    (id, account_id, status, access_token_hash, access_expires_at, refresh_expires_at, issued_at)
                VALUES (?, ?, 'NOT_A_STATUS', ?, now(), now(), now())
                """.trimIndent(),
                UUID.randomUUID(),
                accountId,
                "hash-${UUID.randomUUID()}",
            )
        }
    }

    @Test
    fun `audit_event odmitne neznamy outcome`() {
        assertThrows<DataIntegrityViolationException> {
            jdbc.update(
                "INSERT INTO audit_event (occurred_at, action, outcome) VALUES (now(), 'LoginSucceeded', 'MAYBE')",
            )
        }
    }
}
