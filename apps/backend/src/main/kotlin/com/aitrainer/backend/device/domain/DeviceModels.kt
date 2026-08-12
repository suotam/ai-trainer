package com.aitrainer.backend.device.domain

import java.time.Instant
import java.util.UUID

/** R2 baseline platformy (C9 §8, sync-model §5.3); další append-only. */
enum class DevicePlatform {
    IOS,
    ANDROID,
}

/** R2 baseline stavy (C9 §9); LOST/REPLACED/… jsou forward-scoped. */
enum class DeviceStatus {
    ACTIVE,
    REVOKED,
}

/**
 * Registrovaná instalace aplikace (C9, C6 §8.2): client-generated
 * installation ID (server jej zachovává, DRC-001), ownership přes account,
 * minimalizovaná metadata bez fingerprinting (DRC-011).
 */
data class DeviceInstallation(
    val accountId: UUID,
    val installationId: UUID,
    val platform: DevicePlatform,
    val appVersion: String,
    val localSchemaVersion: String,
    val status: DeviceStatus,
    val createdAt: Instant,
    val lastSeenAt: Instant,
)
