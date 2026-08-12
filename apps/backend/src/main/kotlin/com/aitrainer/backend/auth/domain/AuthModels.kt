package com.aitrainer.backend.auth.domain

import java.time.Instant
import java.util.UUID

/**
 * Stavy interní identity (`identity-and-profile-model` §5.3). Doménové
 * modely v tomto souboru odpovídají C3 (identity/session sémantika)
 * a C6 (serverový datový model); auth session je oddělený pojem od
 * WorkoutSession i lokální aplikační session (ISC-011).
 */
enum class IdentityStatus {
    ACTIVE,
    UNVERIFIED,
    SUSPENDED,
    LOCKED,
    DELETION_PENDING,
    DELETED,
    MERGED,
    COMPROMISED,
}

/** Stavy účtu (`UserAccount` §7.4); rozhodují o možnosti přihlášení (ISC-010). */
enum class AccountStatus {
    ACTIVE,
    ONBOARDING,
    LIMITED,
    SUSPENDED,
    LOCKED,
    DELETION_PENDING,
    DELETED,
    ;

    /** SUSPENDED/LOCKED nedovolují přihlášení, ale účet existuje (ACCOUNT_DISABLED). */
    val disabled: Boolean get() = this == SUSPENDED || this == LOCKED

    /** DELETION_PENDING/DELETED nedovolují přihlášení (ACCOUNT_DELETED). */
    val deleted: Boolean get() = this == DELETION_PENDING || this == DELETED
}

/** R2 baseline typy účtu (C6 §7.1); ostatní typy jsou R2 non-goal. */
enum class AccountType {
    ANONYMOUS,
    STANDARD,
}

/** Provider přihlašovací identity; R2 baseline používá EMAIL_PASSWORD (ADR-011). */
enum class AuthProvider {
    EMAIL_PASSWORD,
    MAGIC_LINK,
    GOOGLE,
    APPLE,
    MICROSOFT,
    PASSKEY,
    PHONE,
    ANONYMOUS,
    ENTERPRISE,
    CUSTOM,
}

data class Account(
    val id: UUID,
    val identityId: UUID,
    val status: AccountStatus,
    val type: AccountType,
)

/** Záznam způsobu přihlášení; credentialHash nikdy neobsahuje plaintext (SDM-010). */
data class AuthenticationIdentity(
    val id: UUID,
    val identityId: UUID,
    val provider: AuthProvider,
    val providerSubject: String,
    val credentialHash: String?,
)

/** Serverem evidovaná aplikační auth session (C3 §5); drží jen hashe tokenů. */
data class AuthSession(
    val id: UUID,
    val accountId: UUID,
    val revoked: Boolean,
    val accessTokenHash: String,
    val accessExpiresAt: Instant,
    val refreshExpiresAt: Instant,
)

enum class RefreshCredentialStatus {
    ACTIVE,
    ROTATED,
    REVOKED,
}

/** Refresh credential vázaná na session; rotace a replay detekce (security §7.2). */
data class RefreshCredential(
    val id: UUID,
    val sessionId: UUID,
    val tokenHash: String,
    val status: RefreshCredentialStatus,
)

/** Vydaná session s plaintext tokeny — existují jen v odpovědi, nikdy v DB ani logu. */
data class IssuedSession(
    val sessionId: UUID,
    val accountId: UUID,
    val accessToken: String,
    val accessExpiresAt: Instant,
    val refreshToken: String,
    val refreshExpiresAt: Instant,
)
