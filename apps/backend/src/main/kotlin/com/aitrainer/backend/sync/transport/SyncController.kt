package com.aitrainer.backend.sync.transport

import com.aitrainer.backend.auth.transport.PrincipalResolver
import com.aitrainer.backend.infrastructure.http.ApiException
import com.aitrainer.backend.sync.application.ProcessSyncPull
import com.aitrainer.backend.sync.application.ProcessSyncPush
import com.aitrainer.backend.sync.application.SyncPushOperation
import com.aitrainer.backend.sync.application.SyncPushResult
import com.aitrainer.backend.sync.domain.SyncEntityType
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

data class SyncOperationDto(
    val operationId: String? = null,
    val idempotencyKey: String? = null,
    val sequence: Long? = null,
    val operationType: String? = null,
    val entityType: String? = null,
    val entityId: String? = null,
    val payload: Map<String, Any?>? = null,
    val expectedServerVersion: Long? = null,
)

data class SyncPushRequestDto(
    val installationId: String? = null,
    val operations: List<SyncOperationDto>? = null,
)

data class SyncItemOutcomeDto(
    val operationId: String,
    val result: String,
    val serverVersion: Long?,
)

data class SyncPushResponseDto(
    val results: List<SyncItemOutcomeDto>,
)

data class SyncPullCursorDto(
    val entityType: String? = null,
    val cursor: String? = null,
)

data class SyncPullRequestDto(
    val installationId: String? = null,
    val cursors: List<SyncPullCursorDto>? = null,
    val limit: Int? = null,
)

data class SyncPullItemDto(
    val entityType: String,
    val entityId: String,
    val serverVersion: Long,
    val payload: Map<String, Any?>,
    val deleted: Boolean,
)

data class SyncPullResponseDto(
    val items: List<SyncPullItemDto>,
    val cursors: List<SyncPullCursorDto>,
    val hasMore: Boolean,
)

/**
 * Transport push sync API (R2-05, C10 §9): jediný push endpoint. Per-item
 * výsledky jsou v těle (HTTP 200 i při odmítnutých položkách, C10 §7);
 * request-level chyby používají kanonický envelope. Žádná sync logika
 * v transportu (AOC-011).
 */
@RestController
@RequestMapping("/api/v1/sync")
class SyncController(
    private val principalResolver: PrincipalResolver,
    private val processSyncPush: ProcessSyncPush,
    private val processSyncPull: ProcessSyncPull,
) {
    companion object {
        private const val MAX_OPERATIONS = 200
    }

    @PostMapping("/push")
    fun push(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @RequestBody request: SyncPushRequestDto,
    ): ResponseEntity<SyncPushResponseDto> {
        val principal = principalResolver.require(authorization)
        val installationId =
            request.installationId?.let(::parseUuid) ?: throw invalidRequest()
        val operationDtos = request.operations ?: throw invalidRequest()
        if (operationDtos.isEmpty() || operationDtos.size > MAX_OPERATIONS) {
            throw invalidRequest()
        }
        val operations =
            operationDtos.map { dto ->
                SyncPushOperation(
                    operationId = dto.operationId ?: throw invalidRequest(),
                    idempotencyKey = dto.idempotencyKey ?: throw invalidRequest(),
                    sequence = dto.sequence ?: throw invalidRequest(),
                    operationType = dto.operationType ?: throw invalidRequest(),
                    entityType = dto.entityType ?: throw invalidRequest(),
                    entityId = dto.entityId ?: throw invalidRequest(),
                    payload = dto.payload ?: throw invalidRequest(),
                    expectedServerVersion = dto.expectedServerVersion,
                )
            }
        return when (val result = processSyncPush.process(principal.accountId, installationId, operations)) {
            is SyncPushResult.Processed -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(
                        SyncPushResponseDto(
                            results =
                                result.outcomes.map {
                                    SyncItemOutcomeDto(
                                        operationId = it.operationId,
                                        result = it.result.name,
                                        serverVersion = it.serverVersion,
                                    )
                                },
                        ),
                    )
            }

            SyncPushResult.DeviceNotRegistered -> {
                throw invalidRequest()
            }
        }
    }

    /**
     * R6-01 pull endpoint (C41 §2): změny vlastního účtu od kurzoru per
     * typ; payload neprůhledný (PSP-003), kurzor neprůhledný token
     * (PSP-004), pull bez side-effects (PSP-008).
     */
    @PostMapping("/pull")
    fun pull(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @RequestBody request: SyncPullRequestDto,
    ): ResponseEntity<SyncPullResponseDto> {
        val principal = principalResolver.require(authorization)
        request.installationId?.let(::parseUuid) ?: throw invalidRequest()
        val cursorDtos = request.cursors ?: throw invalidRequest()
        if (cursorDtos.isEmpty()) throw invalidRequest()
        val requested = LinkedHashMap<SyncEntityType, String?>()
        for (dto in cursorDtos) {
            // Typy výhradně z registru (PSP-009); duplicitní typ = 400.
            val type =
                dto.entityType?.let { name ->
                    SyncEntityType.entries.firstOrNull { it.name == name }
                } ?: throw invalidRequest()
            if (requested.containsKey(type)) throw invalidRequest()
            requested[type] = dto.cursor
        }
        val limit = request.limit ?: ProcessSyncPull.MAX_ITEMS
        if (limit < 1) throw invalidRequest()

        val result = processSyncPull.pull(principal.accountId, requested, limit)
        return ResponseEntity
            .ok()
            .cacheControl(CacheControl.noStore())
            .body(
                SyncPullResponseDto(
                    items =
                        result.items.map {
                            SyncPullItemDto(
                                entityType = it.entityType,
                                entityId = it.entityId,
                                serverVersion = it.serverVersion,
                                payload = it.payload,
                                deleted = it.deleted,
                            )
                        },
                    cursors =
                        result.cursors.map { (type, cursor) ->
                            SyncPullCursorDto(entityType = type, cursor = cursor)
                        },
                    hasMore = result.hasMore,
                ),
            )
    }

    private fun invalidRequest(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )

    private fun parseUuid(value: String): UUID? =
        try {
            UUID.fromString(value)
        } catch (exception: IllegalArgumentException) {
            null
        }
}
