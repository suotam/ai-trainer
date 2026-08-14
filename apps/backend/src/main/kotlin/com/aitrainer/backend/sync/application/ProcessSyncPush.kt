package com.aitrainer.backend.sync.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.auth.application.TokenHashing
import com.aitrainer.backend.device.application.DeviceInstallationRepository
import com.aitrainer.backend.device.domain.DeviceStatus
import com.aitrainer.backend.sync.domain.SyncEntityType
import com.aitrainer.backend.sync.domain.SyncItemOutcome
import com.aitrainer.backend.sync.domain.SyncItemResult
import com.aitrainer.backend.sync.domain.SyncOperationKind
import com.aitrainer.backend.sync.domain.SyncedEntityRow
import com.aitrainer.backend.sync.domain.tombstoneScopedTypes
import org.springframework.stereotype.Service
import org.springframework.transaction.support.TransactionTemplate
import tools.jackson.databind.SerializationFeature
import tools.jackson.databind.json.JsonMapper
import java.time.Clock
import java.time.Duration
import java.util.UUID

/** Jedna push operace (C10 §4) — 1:1 mapování na outbox položku klienta. */
data class SyncPushOperation(
    val operationId: String,
    val idempotencyKey: String,
    val sequence: Long,
    val operationType: String,
    val entityType: String,
    val entityId: String,
    val payload: Map<String, Any?>,
    val expectedServerVersion: Long?,
)

sealed interface SyncPushResult {
    data class Processed(
        val outcomes: List<SyncItemOutcome>,
    ) : SyncPushResult

    /** Batch od neregistrované/revokované instalace (C10 §9). */
    data object DeviceNotRegistered : SyncPushResult
}

/**
 * Zpracování push batch (R2-05, C10): operace se aplikují v pořadí
 * `sequence` (SPC-003), každá položka ve vlastní transakci — aplikace
 * změny, IdempotencyRecord a audit commitují atomicky (IDC-004, §6 batch).
 * Ownership, validace, verze i idempotence se vyhodnocují per položka
 * (SPC-004, AOC-009); selhání položky nezastaví batch.
 *
 * Řízené rozhodnutí (C11 §6): IdempotencyRecord se ukládá pouze pro
 * commitnuté efekty (SUCCESS). Odmítnutí nemá vedlejší efekt a vyhodnocuje
 * se při retry znovu nad aktuálním stavem — nezměněný stav vede
 * deterministicky ke stejnému rozhodnutí (IDC-006 zachováno), změněný stav
 * (např. mezitím synchronizovaný parent) vede k žádoucímu novému výsledku.
 */
@Service
class ProcessSyncPush(
    private val entityRepository: SyncedEntityRepository,
    private val idempotencyRepository: SyncIdempotencyRepository,
    private val deviceRepository: DeviceInstallationRepository,
    private val auditRecorder: AuditRecorder,
    private val transactionTemplate: TransactionTemplate,
    private val clock: Clock,
) {
    companion object {
        /** Retence replay záznamů (C11 §7) — bezpečně pokrývá offline období. */
        private val IDEMPOTENCY_RETENTION: Duration = Duration.ofDays(180)
    }

    /** Deterministická kanonická reprezentace payloadu (IDC-010). */
    private val canonicalMapper: JsonMapper =
        JsonMapper
            .builder()
            .enable(SerializationFeature.ORDER_MAP_ENTRIES_BY_KEYS)
            .build()

    fun process(
        principalAccountId: UUID,
        installationId: UUID,
        operations: List<SyncPushOperation>,
    ): SyncPushResult {
        val device = deviceRepository.find(principalAccountId, installationId)
        if (device == null || device.status != DeviceStatus.ACTIVE) {
            return SyncPushResult.DeviceNotRegistered
        }
        val outcomes =
            operations
                .sortedBy { it.sequence }
                .map { operation ->
                    transactionTemplate.execute {
                        processItem(principalAccountId, installationId, operation)
                    }!!
                }
        if (outcomes.any { it.result == SyncItemResult.SUCCESS || it.result == SyncItemResult.ALREADY_APPLIED }) {
            deviceRepository.touchLastSync(principalAccountId, installationId, clock.instant())
        }
        return SyncPushResult.Processed(outcomes)
    }

    private fun processItem(
        accountId: UUID,
        installationId: UUID,
        operation: SyncPushOperation,
    ): SyncItemOutcome {
        val entityType =
            SyncEntityType.entries.find { it.name == operation.entityType }
                ?: return rejected(accountId, operation, "UNKNOWN_ENTITY_TYPE")
        val operationKind =
            SyncOperationKind.entries.find { it.name == operation.operationType }
                ?: return rejected(accountId, operation, "UNKNOWN_OPERATION_TYPE")
        val entityId =
            parseUuid(operation.entityId)
                ?: return rejected(accountId, operation, "INVALID_ENTITY_ID")

        val payloadJson = canonicalMapper.writeValueAsString(operation.payload)
        val requestHash =
            TokenHashing.hash(
                "${entityType.name}|$entityId|${operationKind.name}|$payloadJson",
            )

        // C11 §6: replay commitnutého efektu → původní výsledek bez efektů.
        val existingRecord = idempotencyRepository.find(accountId, operation.idempotencyKey)
        if (existingRecord != null) {
            if (existingRecord.requestHash == requestHash) {
                audit(
                    "IdempotentReplayReturned",
                    AuditOutcome.SUCCESS,
                    accountId,
                    entityType,
                    entityId,
                    "ALREADY_APPLIED",
                )
                return SyncItemOutcome(
                    operationId = operation.operationId,
                    result = SyncItemResult.ALREADY_APPLIED,
                    serverVersion = existingRecord.resultServerVersion,
                )
            }
            // Stejný klíč, jiný payload — chyba klienta (IDC-007).
            return rejected(accountId, operation, "IDEMPOTENCY_KEY_REUSED")
        }

        // Parent existence + ownership (C10 §6, AOC-009).
        var parentId: UUID? = null
        val parentType = entityType.parentType
        if (parentType != null) {
            val parentField = entityType.parentPayloadField!!
            parentId =
                (operation.payload[parentField] as? String)?.let(::parseUuid)
                    ?: return rejected(accountId, operation, "MISSING_PARENT_REFERENCE")
            val parent = entityRepository.find(parentType, parentId)
            if (parent == null) {
                audit(
                    "SyncOperationRejected",
                    AuditOutcome.REJECTED,
                    accountId,
                    entityType,
                    entityId,
                    "DEPENDENCY_FAILED",
                )
                return SyncItemOutcome(operation.operationId, SyncItemResult.DEPENDENCY_FAILED, null)
            }
            if (parent.accountId != accountId) {
                return denied(accountId, operation, entityType, entityId)
            }
        }

        val existing = entityRepository.find(entityType, entityId)
        return when (operationKind) {
            SyncOperationKind.CREATE_ENTITY -> {
                processCreate(accountId, installationId, operation, entityType, entityId, parentId, payloadJson, requestHash, existing)
            }

            SyncOperationKind.UPDATE_ENTITY -> {
                processUpdate(accountId, installationId, operation, entityType, entityId, payloadJson, requestHash, existing)
            }

            SyncOperationKind.DELETE_ENTITY -> {
                processDelete(accountId, operation, entityType, entityId, requestHash, existing)
            }
        }
    }

    /**
     * Tombstone (R6-04, C44 §2): `deleted = true` + verze + updated_at —
     * řádek se nikdy fyzicky nemaže (DTS-001). Optimistic concurrency jako
     * UPDATE (DTS-003); mimo P0 scope typované odmítnutí (DTS-002).
     */
    private fun processDelete(
        accountId: UUID,
        operation: SyncPushOperation,
        entityType: SyncEntityType,
        entityId: UUID,
        requestHash: String,
        existing: SyncedEntityRow?,
    ): SyncItemOutcome {
        if (entityType !in tombstoneScopedTypes) {
            return rejected(accountId, operation, "DELETE_NOT_SUPPORTED")
        }
        if (existing == null) {
            return rejected(accountId, operation, "DELETE_TARGET_MISSING")
        }
        if (existing.accountId != accountId) {
            return denied(accountId, operation, entityType, entityId)
        }
        if (operation.expectedServerVersion != existing.serverVersion) {
            audit("SyncConflictDetected", AuditOutcome.CONFLICT, accountId, entityType, entityId, "VERSION_MISMATCH")
            return SyncItemOutcome(operation.operationId, SyncItemResult.VERSION_CONFLICT, existing.serverVersion)
        }
        val now = clock.instant()
        val newVersion = entityRepository.markDeleted(entityType, entityId, now)
        idempotencyRepository.insert(
            SyncIdempotencyRecord(
                idempotencyKey = operation.idempotencyKey,
                accountId = accountId,
                requestHash = requestHash,
                resultEntityId = entityId,
                resultServerVersion = newVersion,
            ),
            operationType = "${SyncOperationKind.DELETE_ENTITY.name}:${entityType.name}",
            now = now,
            expiresAt = now.plus(IDEMPOTENCY_RETENTION),
        )
        audit("SyncOperationApplied", AuditOutcome.SUCCESS, accountId, entityType, entityId, "DELETED")
        return SyncItemOutcome(operation.operationId, SyncItemResult.SUCCESS, newVersion)
    }

    private fun processCreate(
        accountId: UUID,
        installationId: UUID,
        operation: SyncPushOperation,
        entityType: SyncEntityType,
        entityId: UUID,
        parentId: UUID?,
        payloadJson: String,
        requestHash: String,
        existing: SyncedEntityRow?,
    ): SyncItemOutcome {
        if (existing != null) {
            if (existing.accountId != accountId) {
                return denied(accountId, operation, entityType, entityId)
            }
            // Vlastní entita už existuje (např. replay po expiraci záznamu,
            // SDM-006/IDC-012) — konflikt, ne duplicita.
            audit("SyncConflictDetected", AuditOutcome.CONFLICT, accountId, entityType, entityId, "CREATE_EXISTS")
            return SyncItemOutcome(operation.operationId, SyncItemResult.VERSION_CONFLICT, existing.serverVersion)
        }
        val now = clock.instant()
        entityRepository.insert(entityType, entityId, accountId, parentId, payloadJson, installationId, now)
        idempotencyRepository.insert(
            SyncIdempotencyRecord(
                idempotencyKey = operation.idempotencyKey,
                accountId = accountId,
                requestHash = requestHash,
                resultEntityId = entityId,
                resultServerVersion = 1,
            ),
            operationType = "${SyncOperationKind.CREATE_ENTITY.name}:${entityType.name}",
            now = now,
            expiresAt = now.plus(IDEMPOTENCY_RETENTION),
        )
        audit("SyncOperationApplied", AuditOutcome.SUCCESS, accountId, entityType, entityId, "CREATED")
        return SyncItemOutcome(operation.operationId, SyncItemResult.SUCCESS, 1)
    }

    private fun processUpdate(
        accountId: UUID,
        installationId: UUID,
        operation: SyncPushOperation,
        entityType: SyncEntityType,
        entityId: UUID,
        payloadJson: String,
        requestHash: String,
        existing: SyncedEntityRow?,
    ): SyncItemOutcome {
        if (existing == null) {
            return rejected(accountId, operation, "UPDATE_TARGET_MISSING")
        }
        if (existing.accountId != accountId) {
            return denied(accountId, operation, entityType, entityId)
        }
        if (operation.expectedServerVersion != existing.serverVersion) {
            // Optimistic concurrency (C10 §10) — explicitní konflikt (§3.6).
            audit("SyncConflictDetected", AuditOutcome.CONFLICT, accountId, entityType, entityId, "VERSION_MISMATCH")
            return SyncItemOutcome(operation.operationId, SyncItemResult.VERSION_CONFLICT, existing.serverVersion)
        }
        val now = clock.instant()
        val newVersion = entityRepository.update(entityType, entityId, payloadJson, installationId, now)
        idempotencyRepository.insert(
            SyncIdempotencyRecord(
                idempotencyKey = operation.idempotencyKey,
                accountId = accountId,
                requestHash = requestHash,
                resultEntityId = entityId,
                resultServerVersion = newVersion,
            ),
            operationType = "${SyncOperationKind.UPDATE_ENTITY.name}:${entityType.name}",
            now = now,
            expiresAt = now.plus(IDEMPOTENCY_RETENTION),
        )
        audit("SyncOperationApplied", AuditOutcome.SUCCESS, accountId, entityType, entityId, "UPDATED")
        return SyncItemOutcome(operation.operationId, SyncItemResult.SUCCESS, newVersion)
    }

    private fun rejected(
        accountId: UUID,
        operation: SyncPushOperation,
        reason: String,
    ): SyncItemOutcome {
        auditRecorder.record(
            AuditEntry(
                action = "SyncOperationRejected",
                outcome = AuditOutcome.REJECTED,
                principalAccountId = accountId,
                target = "${operation.entityType}:${operation.entityId}",
                policyDecision = reason,
            ),
        )
        return SyncItemOutcome(operation.operationId, SyncItemResult.VALIDATION_FAILED, null)
    }

    private fun denied(
        accountId: UUID,
        operation: SyncPushOperation,
        entityType: SyncEntityType,
        entityId: UUID,
    ): SyncItemOutcome {
        audit("AuthorizationDenied", AuditOutcome.REJECTED, accountId, entityType, entityId, "OWNERSHIP_MISMATCH")
        return SyncItemOutcome(operation.operationId, SyncItemResult.PERMISSION_DENIED, null)
    }

    private fun audit(
        action: String,
        outcome: AuditOutcome,
        accountId: UUID,
        entityType: SyncEntityType,
        entityId: UUID,
        decision: String,
    ) {
        auditRecorder.record(
            AuditEntry(
                action = action,
                outcome = outcome,
                principalAccountId = accountId,
                target = "${entityType.name}:$entityId",
                policyDecision = decision,
            ),
        )
    }

    private fun parseUuid(value: String): UUID? =
        try {
            UUID.fromString(value)
        } catch (exception: IllegalArgumentException) {
            null
        }
}
