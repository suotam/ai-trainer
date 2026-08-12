package com.aitrainer.backend.sync.data

import com.aitrainer.backend.sync.application.SyncIdempotencyRecord
import com.aitrainer.backend.sync.application.SyncIdempotencyRepository
import com.aitrainer.backend.sync.application.SyncedEntityRepository
import com.aitrainer.backend.sync.domain.SyncEntityType
import com.aitrainer.backend.sync.domain.SyncedEntityRow
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import java.sql.Timestamp
import java.time.Instant
import java.util.UUID

/**
 * JDBC perzistence synced entit (C6 §8.4). Název tabulky pochází výhradně
 * z [SyncEntityType] registry (žádný uživatelský vstup v SQL); payload se
 * ukládá jako kanonický JSONB bez serverové reinterpretace.
 */
@Repository
class JdbcSyncedEntityRepository(
    private val jdbc: JdbcClient,
) : SyncedEntityRepository {
    override fun find(
        type: SyncEntityType,
        entityId: UUID,
    ): SyncedEntityRow? =
        jdbc
            .sql("SELECT id, account_id, server_version FROM ${type.tableName} WHERE id = :id")
            .param("id", entityId)
            .query { rs, _ ->
                SyncedEntityRow(
                    id = UUID.fromString(rs.getString("id")),
                    accountId = UUID.fromString(rs.getString("account_id")),
                    serverVersion = rs.getLong("server_version"),
                )
            }.optional()
            .orElse(null)

    override fun insert(
        type: SyncEntityType,
        entityId: UUID,
        accountId: UUID,
        parentId: UUID?,
        payloadJson: String,
        sourceInstallationId: UUID,
        now: Instant,
    ) {
        val parentColumn = type.parentColumn
        val columns =
            buildString {
                append("id, account_id, ")
                if (parentColumn != null) append("$parentColumn, ")
                append("server_version, source_installation_id, payload, created_at, updated_at")
            }
        val values =
            buildString {
                append(":id, :accountId, ")
                if (parentColumn != null) append(":parentId, ")
                append("1, :installationId, :payload::jsonb, :now, :now")
            }
        val spec =
            jdbc
                .sql("INSERT INTO ${type.tableName} ($columns) VALUES ($values)")
                .param("id", entityId)
                .param("accountId", accountId)
                .param("installationId", sourceInstallationId)
                .param("payload", payloadJson)
                .param("now", Timestamp.from(now))
        (if (parentColumn != null) spec.param("parentId", parentId) else spec).update()
    }

    override fun update(
        type: SyncEntityType,
        entityId: UUID,
        payloadJson: String,
        sourceInstallationId: UUID,
        now: Instant,
    ): Long {
        jdbc
            .sql(
                """
                UPDATE ${type.tableName}
                SET payload = :payload::jsonb,
                    server_version = server_version + 1,
                    source_installation_id = :installationId,
                    updated_at = :now
                WHERE id = :id
                """.trimIndent(),
            ).param("payload", payloadJson)
            .param("installationId", sourceInstallationId)
            .param("now", Timestamp.from(now))
            .param("id", entityId)
            .update()
        return jdbc
            .sql("SELECT server_version FROM ${type.tableName} WHERE id = :id")
            .param("id", entityId)
            .query(Long::class.java)
            .single()
    }
}

/** JDBC perzistence replay záznamů (C6 §8.5, C11 §5). */
@Repository
class JdbcSyncIdempotencyRepository(
    private val jdbc: JdbcClient,
) : SyncIdempotencyRepository {
    override fun find(
        accountId: UUID,
        idempotencyKey: String,
    ): SyncIdempotencyRecord? =
        jdbc
            .sql(
                """
                SELECT idempotency_key, account_id, request_hash, result_reference
                FROM idempotency_record
                WHERE account_id = :accountId AND idempotency_key = :key
                  AND result_reference IS NOT NULL
                """.trimIndent(),
            ).param("accountId", accountId)
            .param("key", idempotencyKey)
            .query { rs, _ ->
                val reference = rs.getString("result_reference").split('@')
                SyncIdempotencyRecord(
                    idempotencyKey = rs.getString("idempotency_key"),
                    accountId = UUID.fromString(rs.getString("account_id")),
                    requestHash = rs.getString("request_hash"),
                    resultEntityId = UUID.fromString(reference[0]),
                    resultServerVersion = reference[1].toLong(),
                )
            }.optional()
            .orElse(null)

    override fun insert(
        record: SyncIdempotencyRecord,
        operationType: String,
        now: Instant,
        expiresAt: Instant,
    ) {
        jdbc
            .sql(
                """
                INSERT INTO idempotency_record
                    (idempotency_key, operation, request_hash, account_id, created_at,
                     final_status, result_reference, expires_at)
                VALUES (:key, :operation, :requestHash, :accountId, :now,
                        'SUCCESS', :resultReference, :expiresAt)
                """.trimIndent(),
            ).param("key", record.idempotencyKey)
            .param("operation", operationType)
            .param("requestHash", record.requestHash)
            .param("accountId", record.accountId)
            .param("now", Timestamp.from(now))
            .param("resultReference", "${record.resultEntityId}@${record.resultServerVersion}")
            .param("expiresAt", Timestamp.from(expiresAt))
            .update()
    }
}
