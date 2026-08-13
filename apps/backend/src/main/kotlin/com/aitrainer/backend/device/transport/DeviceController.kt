package com.aitrainer.backend.device.transport

import com.aitrainer.backend.auth.transport.PrincipalResolver
import com.aitrainer.backend.device.application.DeviceInstallationRepository
import com.aitrainer.backend.device.application.RegisterDeviceInstallation
import com.aitrainer.backend.device.application.RegisterDeviceResult
import com.aitrainer.backend.device.application.RevokeDeviceInstallation
import com.aitrainer.backend.device.application.RevokeDeviceResult
import com.aitrainer.backend.device.domain.DeviceInstallation
import com.aitrainer.backend.infrastructure.http.ApiException
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class RegisterDeviceRequestDto(
    val platform: String? = null,
    val appVersion: String? = null,
    val localSchemaVersion: String? = null,
)

data class DeviceResponseDto(
    val installationId: String,
    val platform: String,
    val appVersion: String,
    val localSchemaVersion: String,
    val status: String,
    val createdAt: String,
    val lastSeenAt: String,
)

data class DeviceListResponseDto(
    val devices: List<DeviceResponseDto>,
)

/**
 * Transport device API (R2-04, C9): registrace je idempotentní PUT podle
 * client-generated installation ID (DRC-006); kolekce je filtrovaná
 * principalem (AOC-008). Installation ID v cestě není credential ani
 * citlivá hodnota (DRC-003).
 */
@RestController
@RequestMapping("/api/v1/devices")
class DeviceController(
    private val principalResolver: PrincipalResolver,
    private val registerDeviceInstallation: RegisterDeviceInstallation,
    private val revokeDeviceInstallation: RevokeDeviceInstallation,
    private val deviceRepository: DeviceInstallationRepository,
) {
    /**
     * Revokace instalace (C13 §4, RVC-002/003): zneplatní instalaci i na ni
     * vázané session. Cizí a neexistující instalace jsou shodně 404;
     * opakování je idempotentní no-op (RVC-004).
     */
    @DeleteMapping("/{installationId}")
    fun revoke(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @PathVariable installationId: String,
    ): ResponseEntity<Void> {
        val principal = principalResolver.require(authorization)
        return when (revokeDeviceInstallation.revoke(principal.accountId, installationId)) {
            RevokeDeviceResult.Revoked -> {
                ResponseEntity
                    .noContent()
                    .cacheControl(CacheControl.noStore())
                    .build()
            }

            RevokeDeviceResult.NotFound -> {
                throw ApiException(
                    status = HttpStatus.NOT_FOUND,
                    code = "RESOURCE_NOT_FOUND",
                    message = "The requested resource was not found.",
                )
            }
        }
    }

    @PutMapping("/{installationId}")
    fun register(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @PathVariable installationId: String,
        @RequestBody request: RegisterDeviceRequestDto,
    ): ResponseEntity<DeviceResponseDto> {
        val principal = principalResolver.require(authorization)
        val platform = request.platform ?: throw invalidRequest()
        val appVersion = request.appVersion ?: throw invalidRequest()
        val localSchemaVersion = request.localSchemaVersion ?: throw invalidRequest()
        val result =
            registerDeviceInstallation.register(
                principalAccountId = principal.accountId,
                principalSessionId = principal.sessionId,
                installationId = installationId,
                platform = platform,
                appVersion = appVersion,
                localSchemaVersion = localSchemaVersion,
            )
        return when (result) {
            is RegisterDeviceResult.Registered -> {
                ResponseEntity
                    .status(if (result.created) HttpStatus.CREATED else HttpStatus.OK)
                    .cacheControl(CacheControl.noStore())
                    .body(dto(result.device))
            }

            is RegisterDeviceResult.ValidationFailure -> {
                throw invalidRequest()
            }

            RegisterDeviceResult.DeviceRevoked -> {
                throw ApiException(
                    status = HttpStatus.CONFLICT,
                    code = "DEVICE_REVOKED",
                    message = "The device installation has been revoked.",
                )
            }
        }
    }

    @GetMapping
    fun list(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
    ): ResponseEntity<DeviceListResponseDto> {
        val principal = principalResolver.require(authorization)
        val devices = deviceRepository.listByAccountId(principal.accountId)
        return ResponseEntity
            .ok()
            .cacheControl(CacheControl.noStore())
            .body(DeviceListResponseDto(devices.map(::dto)))
    }

    private fun dto(device: DeviceInstallation): DeviceResponseDto =
        DeviceResponseDto(
            installationId = device.installationId.toString(),
            platform = device.platform.name,
            appVersion = device.appVersion,
            localSchemaVersion = device.localSchemaVersion,
            status = device.status.name,
            createdAt = device.createdAt.toString(),
            lastSeenAt = device.lastSeenAt.toString(),
        )

    private fun invalidRequest(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )
}
