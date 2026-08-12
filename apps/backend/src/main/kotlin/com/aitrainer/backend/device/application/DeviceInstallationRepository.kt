package com.aitrainer.backend.device.application

import com.aitrainer.backend.device.domain.DeviceInstallation
import java.time.Instant
import java.util.UUID

/** Perzistence device_installation (C6 §8.2); schéma vlastní Flyway. */
interface DeviceInstallationRepository {
    fun find(
        accountId: UUID,
        installationId: UUID,
    ): DeviceInstallation?

    /** Kolekce je vždy filtrovaná principalem (AOC-008). */
    fun listByAccountId(accountId: UUID): List<DeviceInstallation>

    fun insert(device: DeviceInstallation)

    /** Upsert metadat existující registrace (C9 §5 — idempotence). */
    fun updateMetadata(
        accountId: UUID,
        installationId: UUID,
        appVersion: String,
        localSchemaVersion: String,
        lastSeenAt: Instant,
    )
}
