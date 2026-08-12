package com.aitrainer.backend.auth.application

import com.aitrainer.backend.auth.domain.AuthProvider
import com.aitrainer.backend.auth.domain.IssuedSession
import org.springframework.dao.DuplicateKeyException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock

sealed interface RegisterAccountResult {
    /** Účet vytvořen (created) nebo idempotentně potvrzen (alreadyLinked). */
    data class Registered(
        val session: IssuedSession,
        val alreadyLinked: Boolean,
    ) : RegisterAccountResult

    data class ValidationFailure(
        val reason: String,
    ) : RegisterAccountResult

    /** Kolize provider + subject mimo řízený merge (INV-011). */
    data object DuplicateLoginIdentity : RegisterAccountResult

    /** Stejný idempotency key s jiným payloadem — bezpečné odmítnutí. */
    data object IdempotencyConflict : RegisterAccountResult
}

/**
 * Registrace účtu z first-party credential (ADR-011 baseline) s povinným
 * idempotency key (AAC-005): opakování se stejným klíčem a stejným
 * payloadem nevytvoří druhý účet ani identitu (ISC-005, INV-013).
 * Operace potvrzuje pouze identity binding — přenos lokálních dat
 * vlastní C15 (AAC-015).
 */
@Service
class RegisterAccount(
    private val accountRepository: AccountAuthRepository,
    private val sessionIssuer: SessionIssuer,
    private val passwordHasher: PasswordHasher,
    private val auditRecorder: AuditRecorder,
    private val clock: Clock,
) {
    companion object {
        const val OPERATION = "AccountRegistration"
    }

    @Transactional
    fun register(
        rawEmail: String,
        rawPassword: String,
        idempotencyKey: String,
    ): RegisterAccountResult {
        val email = CredentialValidation.normalizeEmail(rawEmail)
        if (!CredentialValidation.isValidEmail(email)) {
            return RegisterAccountResult.ValidationFailure("invalid email")
        }
        if (!CredentialValidation.isValidPassword(rawPassword)) {
            return RegisterAccountResult.ValidationFailure("invalid password")
        }

        val existingRecord = accountRepository.findIdempotencyRecord(idempotencyKey)
        if (existingRecord != null) {
            return replay(existingRecord, email, rawPassword)
        }

        val existingIdentity = accountRepository.findAuthenticationIdentity(AuthProvider.EMAIL_PASSWORD, email)
        if (existingIdentity != null) {
            auditRecorder.record(
                AuditEntry(
                    action = AuthAuditActions.ACCOUNT_REGISTERED,
                    outcome = AuditOutcome.CONFLICT,
                    policyDecision = "DUPLICATE_LOGIN_IDENTITY",
                ),
            )
            return RegisterAccountResult.DuplicateLoginIdentity
        }

        val account =
            try {
                accountRepository.createStandardAccount(
                    providerSubject = email,
                    credentialHash = passwordHasher.hash(rawPassword),
                    idempotencyKey = idempotencyKey,
                    requestHash = TokenHashing.hash(email),
                    now = clock.instant(),
                )
            } catch (exception: DuplicateKeyException) {
                // Souběžná registrace stejné identity nebo stejného klíče:
                // unique constraints jsou poslední linie (SDM-004).
                auditRecorder.record(
                    AuditEntry(
                        action = AuthAuditActions.ACCOUNT_REGISTERED,
                        outcome = AuditOutcome.CONFLICT,
                        policyDecision = "DUPLICATE_LOGIN_IDENTITY",
                    ),
                )
                return RegisterAccountResult.DuplicateLoginIdentity
            }

        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.ACCOUNT_REGISTERED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = account.id,
                policyDecision = "CREATED",
            ),
        )
        return RegisterAccountResult.Registered(
            session = sessionIssuer.issue(account.id),
            alreadyLinked = false,
        )
    }

    /**
     * Idempotentní replay (AAC-005): stejný klíč + stejný payload vrátí
     * existující účet s čerstvou session; jiný payload je odmítnut.
     * Shoda payloadu se ověřuje otiskem subjektu a bcrypt ověřením hesla —
     * žádný fast-hash hesla se neukládá (DAR-010).
     */
    private fun replay(
        record: IdempotencyRecord,
        email: String,
        rawPassword: String,
    ): RegisterAccountResult {
        val accountId = record.accountId
        if (record.operation != OPERATION || accountId == null || record.requestHash != TokenHashing.hash(email)) {
            return RegisterAccountResult.IdempotencyConflict
        }
        val account =
            accountRepository.findAccountById(accountId)
                ?: return RegisterAccountResult.IdempotencyConflict
        val identity =
            accountRepository.findAuthenticationIdentity(AuthProvider.EMAIL_PASSWORD, email)
                ?: return RegisterAccountResult.IdempotencyConflict
        val credentialHash = identity.credentialHash
        if (identity.identityId != account.identityId ||
            credentialHash == null ||
            !passwordHasher.matches(rawPassword, credentialHash)
        ) {
            return RegisterAccountResult.IdempotencyConflict
        }
        auditRecorder.record(
            AuditEntry(
                action = AuthAuditActions.ACCOUNT_REGISTERED,
                outcome = AuditOutcome.SUCCESS,
                principalAccountId = account.id,
                policyDecision = "ALREADY_LINKED",
            ),
        )
        return RegisterAccountResult.Registered(
            session = sessionIssuer.issue(account.id),
            alreadyLinked = true,
        )
    }
}
