package com.aitrainer.backend.auth.transport

import com.aitrainer.backend.auth.application.AccessSessionAuthenticator
import com.aitrainer.backend.auth.application.LoginResult
import com.aitrainer.backend.auth.application.LoginWithPassword
import com.aitrainer.backend.auth.application.LogoutCurrentSession
import com.aitrainer.backend.auth.application.LogoutResult
import com.aitrainer.backend.auth.application.RefreshAuthSession
import com.aitrainer.backend.auth.application.RefreshResult
import com.aitrainer.backend.auth.application.RegisterAccount
import com.aitrainer.backend.auth.application.RegisterAccountResult
import com.aitrainer.backend.auth.domain.IssuedSession
import com.aitrainer.backend.infrastructure.http.ApiException
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/**
 * Transport R2 auth API (C4): mapuje typované výsledky application vrstvy
 * na kanonické HTTP odpovědi a stabilní error kódy (§9). Žádná business
 * rozhodnutí; credentials nikdy v URL ani v logu (AAC-009). Identitu
 * a session určuje výhradně server (AAC-004).
 */
@RestController
@RequestMapping("/api/v1/auth")
class AuthController(
    private val registerAccount: RegisterAccount,
    private val loginWithPassword: LoginWithPassword,
    private val refreshAuthSession: RefreshAuthSession,
    private val logoutCurrentSession: LogoutCurrentSession,
    private val accessSessionAuthenticator: AccessSessionAuthenticator,
    private val rateLimiter: AuthRateLimiter,
) {
    companion object {
        private val IDEMPOTENCY_KEY_PATTERN = Regex("^[A-Za-z0-9._-]{8,128}$")
    }

    @PostMapping("/registrations")
    fun register(
        @RequestHeader(name = "Idempotency-Key", required = false) idempotencyKey: String?,
        @RequestBody request: RegistrationRequestDto,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<AuthSessionResponseDto> {
        rateLimiter.enforce("registrations", clientKey(httpRequest))
        if (idempotencyKey == null || !IDEMPOTENCY_KEY_PATTERN.matches(idempotencyKey)) {
            throw invalidRequest()
        }
        val email = request.email ?: throw invalidRequest()
        val password = request.password ?: throw invalidRequest()
        return when (val result = registerAccount.register(email, password, idempotencyKey)) {
            is RegisterAccountResult.Registered -> {
                ResponseEntity
                    .status(HttpStatus.CREATED)
                    .cacheControl(CacheControl.noStore())
                    .body(sessionDto(result.session))
            }

            is RegisterAccountResult.ValidationFailure -> {
                throw invalidRequest()
            }

            RegisterAccountResult.IdempotencyConflict -> {
                throw invalidRequest()
            }

            RegisterAccountResult.DuplicateLoginIdentity -> {
                throw ApiException(
                    status = HttpStatus.CONFLICT,
                    code = "DUPLICATE_LOGIN_IDENTITY",
                    message = "The login identity is already in use.",
                )
            }
        }
    }

    @PostMapping("/sessions")
    fun login(
        @RequestBody request: LoginRequestDto,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<AuthSessionResponseDto> {
        rateLimiter.enforce("sessions", clientKey(httpRequest))
        val email = request.email ?: throw invalidRequest()
        val password = request.password ?: throw invalidRequest()
        return when (val result = loginWithPassword.login(email, password)) {
            is LoginResult.LoggedIn -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(sessionDto(result.session))
            }

            LoginResult.InvalidCredentials -> {
                throw invalidCredentials()
            }

            LoginResult.AccountDisabled -> {
                throw accountDisabled()
            }

            LoginResult.AccountDeleted -> {
                throw accountDeleted()
            }
        }
    }

    @PostMapping("/sessions/refresh")
    fun refresh(
        @RequestBody request: RefreshRequestDto,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<AuthSessionResponseDto> {
        rateLimiter.enforce("refresh", clientKey(httpRequest))
        val refreshToken = request.refreshToken ?: throw invalidRequest()
        return when (val result = refreshAuthSession.refresh(refreshToken)) {
            is RefreshResult.Refreshed -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(sessionDto(result.session))
            }

            RefreshResult.InvalidRefresh -> {
                throw ApiException(
                    status = HttpStatus.UNAUTHORIZED,
                    code = "INVALID_REFRESH",
                    message = "The refresh credential is not valid.",
                )
            }

            RefreshResult.SessionRevoked -> {
                throw sessionRevoked()
            }

            RefreshResult.AccountDisabled -> {
                throw accountDisabled()
            }

            RefreshResult.AccountDeleted -> {
                throw accountDeleted()
            }
        }
    }

    @DeleteMapping("/sessions/current")
    fun logout(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<Void> {
        rateLimiter.enforce("logout", clientKey(httpRequest))
        return when (val result = logoutCurrentSession.logout(bearerToken(authorization))) {
            LogoutResult.LoggedOut, LogoutResult.AlreadyLoggedOut -> {
                ResponseEntity
                    .noContent()
                    .cacheControl(CacheControl.noStore())
                    .build()
            }

            is LogoutResult.NotAuthorized -> {
                throw denial(result.reason)
            }
        }
    }

    @GetMapping("/session")
    fun sessionContext(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<SessionContextResponseDto> {
        rateLimiter.enforce("session-context", clientKey(httpRequest))
        return when (val resolution = accessSessionAuthenticator.resolve(bearerToken(authorization))) {
            is AccessSessionAuthenticator.Resolution.Active -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(
                        SessionContextResponseDto(
                            accountId = resolution.account.id.toString(),
                            sessionId = resolution.session.id.toString(),
                            accountType = resolution.account.type.name,
                            accountStatus = resolution.account.status.name,
                            accessExpiresAt = resolution.session.accessExpiresAt.toString(),
                        ),
                    )
            }

            is AccessSessionAuthenticator.Resolution.Denied -> {
                throw denial(resolution.reason)
            }
        }
    }

    private fun sessionDto(session: IssuedSession): AuthSessionResponseDto =
        AuthSessionResponseDto(
            accountId = session.accountId.toString(),
            sessionId = session.sessionId.toString(),
            accessToken = session.accessToken,
            accessExpiresAt = session.accessExpiresAt.toString(),
            refreshToken = session.refreshToken,
            refreshExpiresAt = session.refreshExpiresAt.toString(),
        )

    private fun bearerToken(authorization: String?): String? {
        val header = authorization ?: return null
        if (!header.startsWith("Bearer ", ignoreCase = true)) return null
        return header.substring("Bearer ".length).trim().ifEmpty { null }
    }

    private fun clientKey(request: HttpServletRequest): String = request.remoteAddr ?: "unknown"

    private fun invalidRequest(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )

    private fun invalidCredentials(): ApiException =
        ApiException(
            status = HttpStatus.UNAUTHORIZED,
            code = "INVALID_CREDENTIALS",
            message = "The credentials are not valid.",
        )

    private fun sessionRevoked(): ApiException =
        ApiException(
            status = HttpStatus.UNAUTHORIZED,
            code = "SESSION_REVOKED",
            message = "The session has been revoked.",
        )

    private fun accountDisabled(): ApiException =
        ApiException(
            status = HttpStatus.FORBIDDEN,
            code = "ACCOUNT_DISABLED",
            message = "The account cannot be used at this time.",
        )

    private fun accountDeleted(): ApiException =
        ApiException(
            status = HttpStatus.FORBIDDEN,
            code = "ACCOUNT_DELETED",
            message = "The account is no longer available.",
        )

    private fun denial(reason: AccessSessionAuthenticator.DenialReason): ApiException =
        when (reason) {
            AccessSessionAuthenticator.DenialReason.EXPIRED -> {
                ApiException(
                    status = HttpStatus.UNAUTHORIZED,
                    code = "ACCESS_SESSION_EXPIRED",
                    message = "The access session is missing or expired.",
                )
            }

            AccessSessionAuthenticator.DenialReason.REVOKED -> {
                sessionRevoked()
            }
        }
}
