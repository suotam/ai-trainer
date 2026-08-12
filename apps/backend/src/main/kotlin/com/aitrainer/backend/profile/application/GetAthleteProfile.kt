package com.aitrainer.backend.profile.application

import com.aitrainer.backend.auth.application.AuditEntry
import com.aitrainer.backend.auth.application.AuditOutcome
import com.aitrainer.backend.auth.application.AuditRecorder
import com.aitrainer.backend.profile.domain.AthleteProfile
import org.springframework.stereotype.Service
import java.util.UUID

sealed interface GetProfileResult {
    data class Found(
        val profile: AthleteProfile,
    ) : GetProfileResult

    /** Neexistence i cizí vlastnictví — navenek nerozlišitelné (AOC-007). */
    data object NotFound : GetProfileResult
}

/**
 * Čtení profilu s ownership rozhodnutím v application vrstvě (C8 §5/§9,
 * AOC-004): cizí profil je odmítnut a auditován jako ownership violation
 * (AOC-013), navenek nerozlišitelný od neexistence.
 */
@Service
class GetAthleteProfile(
    private val repository: AthleteProfileRepository,
    private val auditRecorder: AuditRecorder,
) {
    fun byId(
        principalAccountId: UUID,
        profileId: String,
    ): GetProfileResult {
        val id =
            try {
                UUID.fromString(profileId)
            } catch (exception: IllegalArgumentException) {
                return GetProfileResult.NotFound
            }
        val profile = repository.findById(id) ?: return GetProfileResult.NotFound
        if (profile.accountId != principalAccountId) {
            auditRecorder.record(
                AuditEntry(
                    action = "AuthorizationDenied",
                    outcome = AuditOutcome.REJECTED,
                    principalAccountId = principalAccountId,
                    target = "athlete_profile:$id",
                    policyDecision = "OWNERSHIP_MISMATCH",
                ),
            )
            return GetProfileResult.NotFound
        }
        return GetProfileResult.Found(profile)
    }

    fun currentSelf(principalAccountId: UUID): GetProfileResult {
        val profile =
            repository.findSelfByAccountId(principalAccountId)
                ?: return GetProfileResult.NotFound
        return GetProfileResult.Found(profile)
    }
}
