package com.aitrainer.backend.device.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.auth.application.AuthAuditActions
import com.aitrainer.backend.auth.application.AuthSessionRepository
import com.aitrainer.backend.device.domain.DeviceStatus
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

sealed interface RevokeDeviceResult {
    /** Instalace revokována (nebo už revokovaná byla — idempotentní no-op). */
    data object Revoked : RevokeDeviceResult

    /** Cizí i neexistující instalace — navenek nerozlišitelné (RVC-003). */
    data object NotFound : RevokeDeviceResult
}

/**
 * Revokace instalace (C13 §4, RVC-002): instalace přejde do `REVOKED`
 * (bez tiché reaktivace, DRC-013) a všechny na ni vázané aktivní session
 * jsou revokovány (C6 §8.3 vazba). Vše auditováno (`DeviceRevoked` +
 * `AuthSessionRevoked` per session, C13 §7). Idempotentní; ruší výhradně
 * oprávnění, žádná data (RVC-005).
 */
@Service
class RevokeDeviceInstallation(
    private val deviceRepository: DeviceInstallationRepository,
    private val sessionRepository: AuthSessionRepository,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    @Transactional
    fun revoke(
        principalAccountId: UUID,
        installationId: String,
    ): RevokeDeviceResult {
        val id =
            try {
                UUID.fromString(installationId)
            } catch (exception: IllegalArgumentException) {
                return RevokeDeviceResult.NotFound
            }
        val device =
            deviceRepository.find(principalAccountId, id)
                ?: return RevokeDeviceResult.NotFound
        if (device.status == DeviceStatus.REVOKED) {
            return RevokeDeviceResult.Revoked
        }
        val now = clock.instant()
        deviceRepository.revoke(principalAccountId, id, now)
        auditRecorder.record(
            AuditEntry(
                action = "DeviceRevoked",
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = principalAccountId,
                target = "device_installation:$id",
            ),
        )
        val revokedSessions = sessionRepository.revokeBoundToInstallation(principalAccountId, id, now)
        revokedSessions.forEach { sessionId ->
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.AUTH_SESSION_REVOKED,
                    outcome = AuditOutcome.SUCCESS,
                    principalAccountId = principalAccountId,
                    principalSessionId = sessionId,
                    policyDecision = "DEVICE_REVOKED",
                ),
            )
        }
        return RevokeDeviceResult.Revoked
    }
}
