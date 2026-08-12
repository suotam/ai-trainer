package com.aitrainer.backend.profile.data

import com.aitrainer.backend.profile.application.AthleteProfileRepository
import com.aitrainer.backend.profile.domain.AthleteProfile
import com.aitrainer.backend.profile.domain.ProfileStatus
import com.aitrainer.backend.profile.domain.ProfileType
import com.aitrainer.backend.profile.domain.ProfileUnits
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import java.sql.ResultSet
import java.sql.Timestamp
import java.util.UUID

/** JDBC perzistence athlete_profile (C6 §8.1). */
@Repository
class JdbcAthleteProfileRepository(
    private val jdbc: JdbcClient,
) : AthleteProfileRepository {
    override fun findById(profileId: UUID): AthleteProfile? =
        jdbc
            .sql("$SELECT WHERE id = :id")
            .param("id", profileId)
            .query { rs, _ -> map(rs) }
            .optional()
            .orElse(null)

    override fun findSelfByAccountId(accountId: UUID): AthleteProfile? =
        jdbc
            .sql("$SELECT WHERE account_id = :accountId AND profile_type = 'SELF'")
            .param("accountId", accountId)
            .query { rs, _ -> map(rs) }
            .optional()
            .orElse(null)

    override fun insert(profile: AthleteProfile) {
        jdbc
            .sql(
                """
                INSERT INTO athlete_profile
                    (id, account_id, profile_type, status, display_name, primary_sport,
                     experience_level, units, timezone, locale, created_at, updated_at)
                VALUES (:id, :accountId, :type, :status, :displayName, :primarySport,
                        :experienceLevel, :units, :timezone, :locale, :createdAt, :updatedAt)
                """.trimIndent(),
            ).param("id", profile.id)
            .param("accountId", profile.accountId)
            .param("type", profile.type.name)
            .param("status", profile.status.name)
            .param("displayName", profile.displayName)
            .param("primarySport", profile.primarySport)
            .param("experienceLevel", profile.experienceLevel)
            .param("units", profile.units?.name)
            .param("timezone", profile.timezone)
            .param("locale", profile.locale)
            .param("createdAt", Timestamp.from(profile.createdAt))
            .param("updatedAt", Timestamp.from(profile.updatedAt))
            .update()
    }

    private fun map(rs: ResultSet): AthleteProfile =
        AthleteProfile(
            id = UUID.fromString(rs.getString("id")),
            accountId = UUID.fromString(rs.getString("account_id")),
            type = ProfileType.valueOf(rs.getString("profile_type")),
            status = ProfileStatus.valueOf(rs.getString("status")),
            displayName = rs.getString("display_name"),
            primarySport = rs.getString("primary_sport"),
            experienceLevel = rs.getString("experience_level"),
            units = rs.getString("units")?.let(ProfileUnits::valueOf),
            timezone = rs.getString("timezone"),
            locale = rs.getString("locale"),
            createdAt = rs.getTimestamp("created_at").toInstant(),
            updatedAt = rs.getTimestamp("updated_at").toInstant(),
        )

    companion object {
        private const val SELECT =
            "SELECT id, account_id, profile_type, status, display_name, primary_sport, " +
                "experience_level, units, timezone, locale, created_at, updated_at FROM athlete_profile"
    }
}
