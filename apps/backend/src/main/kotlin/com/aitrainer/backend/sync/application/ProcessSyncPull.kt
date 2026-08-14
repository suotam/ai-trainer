package com.aitrainer.backend.sync.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.infrastructure.http.ApiException
import com.aitrainer.backend.sync.domain.SyncEntityType
import org.springframework.http.HttpStatus
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Service
import tools.jackson.databind.json.JsonMapper
import java.sql.Timestamp
import java.time.Instant
import java.util.UUID

/**
 * R6-01 pull sync (C41): změny entit vlastního účtu od kurzoru per typ.
 * Server payload nevykládá (PSP-003); kurzor je neprůhledný token vydaný
 * serverem (PSP-004 — interně `epochSecond:nano|id` z `updated_at`);
 * overlap je dovolen, mezera nikdy (PSP-005). Pull nemění stav (PSP-008);
 * audit jen s počty (PSP-013).
 */
data class SyncPullItem(
    val entityType: String,
    val entityId: String,
    val serverVersion: Long,
    val payload: Map<String, Any?>,
)

data class SyncPullResult(
    val items: List<SyncPullItem>,
    val cursors: Map<String, String?>,
    val hasMore: Boolean,
)

@Service
class ProcessSyncPull(
    private val jdbc: JdbcClient,
    private val auditRecorder: AuditRecorder,
) {
    companion object {
        /** Batch cap (PSP-007). */
        const val MAX_ITEMS = 200
    }

    private val mapper = JsonMapper.builder().build()

    private data class CursorPosition(
        val updatedAt: Instant,
        val id: String,
    )

    private data class PulledRow(
        val id: String,
        val serverVersion: Long,
        val payloadJson: String,
        val updatedAt: Instant,
    )

    fun pull(
        accountId: UUID,
        requestedCursors: LinkedHashMap<SyncEntityType, String?>,
        limit: Int,
    ): SyncPullResult {
        val cap = limit.coerceIn(1, MAX_ITEMS)
        val items = mutableListOf<SyncPullItem>()
        val nextCursors = linkedMapOf<String, String?>()
        var hasMore = false

        // Deterministické pořadí typů dle registru (PSP-006) v pořadí
        // požadavku klienta (request je LinkedHashMap validovaná transportem).
        for ((type, token) in requestedCursors) {
            var cursorOut = token
            val remaining = cap - items.size
            if (remaining <= 0) {
                // Typ se v tomto batchi nedostal na řadu — kurzor beze změny.
                hasMore = hasMore || hasChangesAfter(type, accountId, parseCursor(token))
                nextCursors[type.name] = cursorOut
                continue
            }
            val rows = fetch(type, accountId, parseCursor(token), remaining + 1)
            val emitted = rows.take(remaining)
            if (rows.size > remaining) {
                hasMore = true
            }
            for (row in emitted) {
                items +=
                    SyncPullItem(
                        entityType = type.name,
                        entityId = row.id,
                        serverVersion = row.serverVersion,
                        payload = readPayload(row.payloadJson),
                    )
            }
            if (emitted.isNotEmpty()) {
                val last = emitted.last()
                cursorOut = encodeCursor(CursorPosition(last.updatedAt, last.id))
            }
            nextCursors[type.name] = cursorOut
        }

        auditRecorder.record(
            AuditEntry(
                action = "SyncPullServed",
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = accountId,
                // Jen počty, nikdy obsah (PSP-013).
                target = "items=${items.size}",
            ),
        )
        return SyncPullResult(items = items, cursors = nextCursors, hasMore = hasMore)
    }

    private fun fetch(
        type: SyncEntityType,
        accountId: UUID,
        cursor: CursorPosition?,
        limit: Int,
    ): List<PulledRow> {
        val predicate =
            if (cursor == null) {
                ""
            } else {
                "AND (updated_at > :cursorTs OR (updated_at = :cursorTs AND id::text > :cursorId))"
            }
        var spec =
            jdbc
                .sql(
                    """
                    SELECT id, server_version, payload::text AS payload, updated_at
                    FROM ${type.tableName}
                    WHERE account_id = :accountId $predicate
                    ORDER BY updated_at, id::text
                    LIMIT :limit
                    """.trimIndent(),
                ).param("accountId", accountId)
                .param("limit", limit)
        if (cursor != null) {
            spec =
                spec
                    .param("cursorTs", Timestamp.from(cursor.updatedAt))
                    .param("cursorId", cursor.id)
        }
        return spec
            .query { rs, _ ->
                PulledRow(
                    id = rs.getString("id"),
                    serverVersion = rs.getLong("server_version"),
                    payloadJson = rs.getString("payload"),
                    updatedAt = rs.getTimestamp("updated_at").toInstant(),
                )
            }.list()
    }

    private fun hasChangesAfter(
        type: SyncEntityType,
        accountId: UUID,
        cursor: CursorPosition?,
    ): Boolean = fetch(type, accountId, cursor, 1).isNotEmpty()

    private fun readPayload(json: String): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        return mapper.readValue(json, Map::class.java) as Map<String, Any?>
    }

    private fun encodeCursor(position: CursorPosition): String =
        "${position.updatedAt.epochSecond}:${position.updatedAt.nano}|${position.id}"

    /** Nevalidní token je bezpečně odmítnut (PSP-004). */
    private fun parseCursor(token: String?): CursorPosition? {
        if (token.isNullOrBlank()) return null
        val separator = token.indexOf('|')
        if (separator <= 0) throw invalidCursor()
        val timePart = token.substring(0, separator).split(':')
        if (timePart.size != 2) throw invalidCursor()
        val seconds = timePart[0].toLongOrNull() ?: throw invalidCursor()
        val nanos = timePart[1].toLongOrNull() ?: throw invalidCursor()
        if (nanos !in 0..999_999_999) throw invalidCursor()
        return CursorPosition(
            updatedAt = Instant.ofEpochSecond(seconds, nanos),
            id = token.substring(separator + 1),
        )
    }

    private fun invalidCursor(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )
}
