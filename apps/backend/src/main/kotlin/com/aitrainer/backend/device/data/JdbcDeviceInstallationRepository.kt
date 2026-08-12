package com.aitrainer.backend.device.data

import com.aitrainer.backend.device.application.DeviceInstallationRepository
import com.aitrainer.backend.device.domain.DeviceInstallation
import com.aitrainer.backend.device.domain.DevicePlatform
import com.aitrainer.backend.device.domain.DeviceStatus
import org.springframework.jdbc.core.simple.JdbcClient
import org.springframework.stereotype.Repository
import java.sql.ResultSet
import java.sql.Timestamp
import java.time.Instant
import java.util.UUID

/** JDBC perzistence device_installation (C6 §8.2). */
@Repository
class JdbcDeviceInstallationRepository(
    private val jdbc: JdbcClient,
) : DeviceInstallationRepository {
    override fun find(
        accountId: UUID,
        installationId: UUID,
    ): DeviceInstallation? =
        jdbc
            .sql("$SELECT WHERE account_id = :accountId AND installation_id = :installationId")
            .param("accountId", accountId)
            .param("installationId", installationId)
            .query { rs, _ -> map(rs) }
            .optional()
            .orElse(null)

    override fun listByAccountId(accountId: UUID): List<DeviceInstallation> =
        jdbc
            .sql("$SELECT WHERE account_id = :accountId ORDER BY created_at")
            .param("accountId", accountId)
            .query { rs, _ -> map(rs) }
            .list()

    override fun insert(device: DeviceInstallation) {
        jdbc
            .sql(
                """
                INSERT INTO device_installation
                    (account_id, installation_id, platform, app_version, local_schema_version,
                     status, created_at, last_seen_at)
                VALUES (:accountId, :installationId, :platform, :appVersion, :localSchemaVersion,
                        :status, :createdAt, :lastSeenAt)
                """.trimIndent(),
            ).param("accountId", device.accountId)
            .param("installationId", device.installationId)
            .param("platform", device.platform.name)
            .param("appVersion", device.appVersion)
            .param("localSchemaVersion", device.localSchemaVersion)
            .param("status", device.status.name)
            .param("createdAt", Timestamp.from(device.createdAt))
            .param("lastSeenAt", Timestamp.from(device.lastSeenAt))
            .update()
    }

    override fun updateMetadata(
        accountId: UUID,
        installationId: UUID,
        appVersion: String,
        localSchemaVersion: String,
        lastSeenAt: Instant,
    ) {
        jdbc
            .sql(
                """
                UPDATE device_installation
                SET app_version = :appVersion,
                    local_schema_version = :localSchemaVersion,
                    last_seen_at = :lastSeenAt,
                    row_version = row_version + 1
                WHERE account_id = :accountId AND installation_id = :installationId
                """.trimIndent(),
            ).param("appVersion", appVersion)
            .param("localSchemaVersion", localSchemaVersion)
            .param("lastSeenAt", Timestamp.from(lastSeenAt))
            .param("accountId", accountId)
            .param("installationId", installationId)
            .update()
    }

    private fun map(rs: ResultSet): DeviceInstallation =
        DeviceInstallation(
            accountId = UUID.fromString(rs.getString("account_id")),
            installationId = UUID.fromString(rs.getString("installation_id")),
            platform = DevicePlatform.valueOf(rs.getString("platform")),
            appVersion = rs.getString("app_version"),
            localSchemaVersion = rs.getString("local_schema_version"),
            status = DeviceStatus.valueOf(rs.getString("status")),
            createdAt = rs.getTimestamp("created_at").toInstant(),
            lastSeenAt = rs.getTimestamp("last_seen_at").toInstant(),
        )

    companion object {
        private const val SELECT =
            "SELECT account_id, installation_id, platform, app_version, local_schema_version, " +
                "status, created_at, last_seen_at FROM device_installation"
    }
}
