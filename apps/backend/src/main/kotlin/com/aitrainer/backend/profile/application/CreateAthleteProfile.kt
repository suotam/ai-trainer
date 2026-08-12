package com.aitrainer.backend.profile.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.profile.domain.AthleteProfile
import com.aitrainer.backend.profile.domain.ProfileStatus
import com.aitrainer.backend.profile.domain.ProfileType
import com.aitrainer.backend.profile.domain.ProfileUnits
import org.springframework.dao.DuplicateKeyException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.util.UUID

sealed interface CreateProfileResult {
    data class Created(
        val profile: AthleteProfile,
    ) : CreateProfileResult

    /** Idempotentní retry: stejný profil (ID i vlastník) už existuje. */
    data class AlreadyExists(
        val profile: AthleteProfile,
    ) : CreateProfileResult

    /** Účet už má jiný SELF profil (C6 §8.1 — právě jeden v R2). */
    data object SelfProfileConflict : CreateProfileResult

    data class ValidationFailure(
        val reason: String,
    ) : CreateProfileResult

    /**
     * Kolize client-generated ID s cizí entitou — bezpečné generické
     * odmítnutí bez potvrzení existence (AOC-007 analogie).
     */
    data object IdCollision : CreateProfileResult
}

/**
 * Vytvoření R2 baseline AthleteProfile (R2-04). Ownership dostává výhradně
 * principal (AOC-005) — klientem dodaný owner se nepřijímá; client-generated
 * profil ID server zachovává (SDM-005). Retry se stejným ID je idempotentní.
 */
@Service
class CreateAthleteProfile(
    private val repository: AthleteProfileRepository,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    companion object {
        private val CODE_PATTERN = Regex("^[A-Z][A-Z0-9_]{0,39}$")
        private const val MAX_DISPLAY_NAME = 100
        private const val MAX_FREEFORM = 60
    }

    @Transactional
    fun create(
        principalAccountId: UUID,
        profileId: String,
        displayName: String,
        primarySport: String?,
        experienceLevel: String?,
        units: String?,
        timezone: String?,
        locale: String?,
    ): CreateProfileResult {
        val id =
            parseUuid(profileId)
                ?: return CreateProfileResult.ValidationFailure("invalid profile id")
        val trimmedName = displayName.trim()
        if (trimmedName.isEmpty() || trimmedName.length > MAX_DISPLAY_NAME) {
            return CreateProfileResult.ValidationFailure("invalid display name")
        }
        if (primarySport != null && !CODE_PATTERN.matches(primarySport)) {
            return CreateProfileResult.ValidationFailure("invalid sport code")
        }
        if (experienceLevel != null && !CODE_PATTERN.matches(experienceLevel)) {
            return CreateProfileResult.ValidationFailure("invalid experience code")
        }
        val parsedUnits =
            when (units) {
                null -> {
                    null
                }

                else -> {
                    ProfileUnits.entries.find { it.name == units }
                        ?: return CreateProfileResult.ValidationFailure("invalid units")
                }
            }
        if (timezone != null && (timezone.isBlank() || timezone.length > MAX_FREEFORM)) {
            return CreateProfileResult.ValidationFailure("invalid timezone")
        }
        if (locale != null && (locale.isBlank() || locale.length > 20)) {
            return CreateProfileResult.ValidationFailure("invalid locale")
        }

        val existingById = repository.findById(id)
        if (existingById != null) {
            if (existingById.accountId == principalAccountId) {
                // Idempotentní retry (retry-safe create, C8 §5 vytvoření).
                return CreateProfileResult.AlreadyExists(existingById)
            }
            auditRecorder.record(
                AuditEntry(
                    action = "AuthorizationDenied",
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = principalAccountId,
                    target = "athlete_profile:$id",
                    policyDecision = "OWNERSHIP_MISMATCH",
                ),
            )
            return CreateProfileResult.IdCollision
        }
        val existingSelf = repository.findSelfByAccountId(principalAccountId)
        if (existingSelf != null) {
            return CreateProfileResult.SelfProfileConflict
        }

        val now = clock.instant()
        val profile =
            AthleteProfile(
                id = id,
                accountId = principalAccountId,
                type = ProfileType.SELF,
                status = ProfileStatus.ACTIVE,
                displayName = trimmedName,
                primarySport = primarySport,
                experienceLevel = experienceLevel,
                units = parsedUnits,
                timezone = timezone,
                locale = locale,
                createdAt = now,
                updatedAt = now,
            )
        try {
            repository.insert(profile)
        } catch (exception: DuplicateKeyException) {
            // Souběžný pokus — unique constraints jsou poslední linie
            // (SDM-004); rozhodnutí se zopakuje nad aktuálním stavem.
            val concurrent = repository.findById(id)
            return if (concurrent != null && concurrent.accountId == principalAccountId) {
                CreateProfileResult.AlreadyExists(concurrent)
            } else if (repository.findSelfByAccountId(principalAccountId) != null) {
                CreateProfileResult.SelfProfileConflict
            } else {
                CreateProfileResult.IdCollision
            }
        }
        return CreateProfileResult.Created(profile)
    }

    private fun parseUuid(value: String): UUID? =
        try {
            UUID.fromString(value)
        } catch (exception: IllegalArgumentException) {
            null
        }
}
