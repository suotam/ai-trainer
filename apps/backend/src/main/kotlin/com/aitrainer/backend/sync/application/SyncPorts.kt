package com.aitrainer.backend.sync.application

import com.aitrainer.backend.sync.domain.SyncEntityType
import com.aitrainer.backend.sync.domain.SyncedEntityRow
import java.time.Instant
import java.util.UUID

/** Perzistence synced entit (C6 §8.4); tabulku určuje typ z registry. */
interface SyncedEntityRepository {
    fun find(
        type: SyncEntityType,
        entityId: UUID,
    ): SyncedEntityRow?

    /** Vloží novou entitu se server_version = 1 (SDM-005 — client ID se zachovává). */
    fun insert(
        type: SyncEntityType,
        entityId: UUID,
        accountId: UUID,
        parentId: UUID?,
        payloadJson: String,
        sourceInstallationId: UUID,
        now: Instant,
    )

    /** Aktualizuje payload a inkrementuje server_version; vrací novou verzi (C10 §10). */
    fun update(
        type: SyncEntityType,
        entityId: UUID,
        payloadJson: String,
        sourceInstallationId: UUID,
        now: Instant,
    ): Long

    /**
     * Tombstone (R6-04, C44): `deleted = true` + inkrement verze; řádek se
     * nikdy fyzicky nemaže (DTS-001). Vrací novou verzi.
     */
    fun markDeleted(
        type: SyncEntityType,
        entityId: UUID,
        now: Instant,
    ): Long
}

/** Uložený replay záznam (C11 §5); result reference = entityId + serverVersion. */
data class SyncIdempotencyRecord(
    val idempotencyKey: String,
    val accountId: UUID,
    val requestHash: String,
    val resultEntityId: UUID,
    val resultServerVersion: Long,
)

interface SyncIdempotencyRepository {
    fun find(
        accountId: UUID,
        idempotencyKey: String,
    ): SyncIdempotencyRecord?

    /** Ukládá se atomicky ve stejné transakci jako efekt operace (IDC-004). */
    fun insert(
        record: SyncIdempotencyRecord,
        operationType: String,
        now: Instant,
        expiresAt: Instant,
    )
}
