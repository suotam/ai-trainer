package com.aitrainer.backend.auth.data

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.infrastructure.http.RequestIdSupport
import org.slf4j.MDC
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import java.sql.Timestamp
import java.time.Clock

/**
 * Append-oriented serverový audit (C14 §5, AEC-010): zápis do audit_event
 * v rámci transakce auditované operace — bezpečnostní událost se nemůže
 * tiše ztratit potvrzením změny bez auditu (AEC-013). Korelace přes
 * request ID z MDC (AEC-005); nikdy žádný secret ani citlivý payload
 * (AEC-003/004).
 */
@Repository
class JdbcAuditRecorder(
    private val jdbc: JdbcClient,
    private val clock: Clock,
) : AuditRecorder {
    override fun record(entry: AuditEntry) {
        jdbc
            .sql(
                """
                INSERT INTO audit_event
                    (occurred_at, action, outcome, principal_account_id, principal_session_id,
                     target, correlation_id, policy_decision)
                VALUES (:occurredAt, :action, :outcome, :accountId, :sessionId, :target, :correlationId, :policyDecision)
                """.trimIndent(),
            ).param("occurredAt", Timestamp.from(clock.instant()))
            .param("action", entry.action)
            .param("outcome", entry.outcome.name)
            .param("accountId", entry.principalAccountId)
            .param("sessionId", entry.principalSessionId)
            .param("target", entry.target)
            .param("correlationId", MDC.get(RequestIdSupport.MDC_KEY))
            .param("policyDecision", entry.policyDecision)
            .update()
    }
}
