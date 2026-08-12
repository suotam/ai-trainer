package com.aitrainer.backend.device.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.auth.application.AuthSessionRepository
import com.aitrainer.backend.device.domain.DeviceInstallation
import com.aitrainer.backend.device.domain.DevicePlatform
import com.aitrainer.backend.device.domain.DeviceStatus
import org.springframework.dao.DuplicateKeyException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

sealed interface RegisterDeviceResult {
    data class Registered(
        val device: DeviceInstallation,
        val created: Boolean,
    ) : RegisterDeviceResult

    data class ValidationFailure(
        val reason: String,
    ) : RegisterDeviceResult

    /** Revokovaná instalace nesmí být tiše reaktivována upsertem (DRC-013). */
    data object DeviceRevoked : RegisterDeviceResult
}

/**
 * Registrace zařízení (C9 §5): idempotentní upsert podle přirozeného klíče
 * (account, installation ID) — opakovaná registrace nevytvoří duplikát;
 * ownership dostává výhradně principal (DRC-005). Registrace zároveň
 * aditivně naváže aktuální auth session na instalaci (C9 §6). Server
 * eviduje jen minimalizovaná metadata (DRC-011) a client-generated
 * installation ID zachovává (DRC-001).
 */
@Service
class RegisterDeviceInstallation(
    private val deviceRepository: DeviceInstallationRepository,
    private val sessionRepository: AuthSessionRepository,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    companion object {
        private const val MAX_VERSION_LENGTH = 60
    }

    @Transactional
    fun register(
        principalAccountId: UUID,
        principalSessionId: UUID,
        installationId: String,
        platform: String,
        appVersion: String,
        localSchemaVersion: String,
    ): RegisterDeviceResult {
        val id =
            parseUuid(installationId)
                ?: return RegisterDeviceResult.ValidationFailure("invalid installation id")
        val parsedPlatform =
            DevicePlatform.entries.find { it.name == platform }
                ?: return RegisterDeviceResult.ValidationFailure("invalid platform")
        if (appVersion.isBlank() || appVersion.length > MAX_VERSION_LENGTH) {
            return RegisterDeviceResult.ValidationFailure("invalid app version")
        }
        if (localSchemaVersion.isBlank() || localSchemaVersion.length > MAX_VERSION_LENGTH) {
            return RegisterDeviceResult.ValidationFailure("invalid schema version")
        }

        val now = clock.instant()
        val existing = deviceRepository.find(principalAccountId, id)
        if (existing != null) {
            if (existing.status == DeviceStatus.REVOKED) {
                auditRecorder.record(
                    AuditEntry(
                        action = "DeviceRegistered",
                        outcome = AuditOutcome.REJECTED,
                        principalAccountId = principalAccountId,
                        principalSessionId = principalSessionId,
                        target = "device_installation:$id",
                        policyDecision = "DEVICE_REVOKED",
                    ),
                )
                return RegisterDeviceResult.DeviceRevoked
            }
            deviceRepository.updateMetadata(
                accountId = principalAccountId,
                installationId = id,
                appVersion = appVersion,
                localSchemaVersion = localSchemaVersion,
                lastSeenAt = now,
            )
            sessionRepository.bindDeviceInstallation(principalSessionId, principalAccountId, id)
            auditRecorder.record(registeredAudit(principalAccountId, principalSessionId, id, "UPDATED"))
            return RegisterDeviceResult.Registered(
                device = deviceRepository.find(principalAccountId, id)!!,
                created = false,
            )
        }

        val device =
            DeviceInstallation(
                accountId = principalAccountId,
                installationId = id,
                platform = parsedPlatform,
                appVersion = appVersion,
                localSchemaVersion = localSchemaVersion,
                status = DeviceStatus.ACTIVE,
                createdAt = now,
                lastSeenAt = now,
            )
        val created =
            try {
                deviceRepository.insert(device)
                true
            } catch (exception: DuplicateKeyException) {
                // Souběžná registrace téže instalace — PK je poslední linie
                // (SDM-004); pokračuje se idempotentním upsertem.
                deviceRepository.updateMetadata(
                    accountId = principalAccountId,
                    installationId = id,
                    appVersion = appVersion,
                    localSchemaVersion = localSchemaVersion,
                    lastSeenAt = now,
                )
                false
            }
        sessionRepository.bindDeviceInstallation(principalSessionId, principalAccountId, id)
        auditRecorder.record(
            registeredAudit(principalAccountId, principalSessionId, id, if (created) "CREATED" else "UPDATED"),
        )
        return RegisterDeviceResult.Registered(
            device = deviceRepository.find(principalAccountId, id)!!,
            created = created,
        )
    }

    private fun registeredAudit(
        accountId: UUID,
        sessionId: UUID,
        installationId: UUID,
        decision: String,
    ): AuditEntry =
        AuditEntry(
            action = "DeviceRegistered",
            outcome = AuditOutcome.SUCCESS,
            principalAccountId = accountId,
            principalSessionId = sessionId,
            target = "device_installation:$installationId",
            policyDecision = decision,
        )

    private fun parseUuid(value: String): UUID? =
        try {
            UUID.fromString(value)
        } catch (exception: IllegalArgumentException) {
            null
        }
}
