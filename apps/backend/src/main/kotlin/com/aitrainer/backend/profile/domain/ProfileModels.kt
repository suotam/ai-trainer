package com.aitrainer.backend.profile.domain

import java.time.Instant
import java.util.UUID

/** R2 baseline typ profilu (C6 §8.1); ostatní typy jsou R3+ non-goal. */
enum class ProfileType {
    SELF,
}

enum class ProfileStatus {
    ACTIVE,
}

/** Podporované jednotky (bezpečné minimum C6 §8.1). */
enum class ProfileUnits {
    METRIC,
    IMPERIAL,
}

/**
 * R2 baseline AthleteProfile (`identity-and-profile-model §9`, C6 §8.1):
 * client-generated ID (server jej zachovává, SDM-005), ownership přes
 * account (SDM-008). Citlivé zdravotní údaje a AI preference do baseline
 * nepatří (R3+).
 */
data class AthleteProfile(
    val id: UUID,
    val accountId: UUID,
    val type: ProfileType,
    val status: ProfileStatus,
    val displayName: String,
    val primarySport: String?,
    val experienceLevel: String?,
    val units: ProfileUnits?,
    val timezone: String?,
    val locale: String?,
    val createdAt: Instant,
    val updatedAt: Instant,
)
