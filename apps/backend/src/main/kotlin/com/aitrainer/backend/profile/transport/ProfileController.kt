package com.aitrainer.backend.profile.transport

import com.aitrainer.backend.auth.transport.PrincipalResolver
import com.aitrainer.backend.infrastructure.http.ApiException
import com.aitrainer.backend.profile.application.CreateAthleteProfile
import com.aitrainer.backend.profile.application.CreateProfileResult
import com.aitrainer.backend.profile.application.GetAthleteProfile
import com.aitrainer.backend.profile.application.GetProfileResult
import com.aitrainer.backend.profile.domain.AthleteProfile
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

data class CreateProfileRequestDto(
    val profileId: String? = null,
    val displayName: String? = null,
    val primarySport: String? = null,
    val experienceLevel: String? = null,
    val units: String? = null,
    val timezone: String? = null,
    val locale: String? = null,
)

data class ProfileResponseDto(
    val profileId: String,
    val accountId: String,
    val profileType: String,
    val status: String,
    val displayName: String,
    val primarySport: String?,
    val experienceLevel: String?,
    val units: String?,
    val timezone: String?,
    val locale: String?,
    val createdAt: String,
    val updatedAt: String,
)

/**
 * Transport AthleteProfile API (R2-04): principal výhradně z ověřené
 * session (AOC-002), ownership rozhoduje application vrstva (C8 §9);
 * cizí i neexistující profil je shodně 404 (AOC-007). Žádná autorizační
 * logika v transportu (AOC-011).
 */
@RestController
@RequestMapping("/api/v1/profiles")
class ProfileController(
    private val principalResolver: PrincipalResolver,
    private val createAthleteProfile: CreateAthleteProfile,
    private val getAthleteProfile: GetAthleteProfile,
) {
    @PostMapping
    fun create(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @RequestBody request: CreateProfileRequestDto,
    ): ResponseEntity<ProfileResponseDto> {
        val principal = principalResolver.require(authorization)
        val profileId = request.profileId ?: throw invalidRequest()
        val displayName = request.displayName ?: throw invalidRequest()
        val result =
            createAthleteProfile.create(
                principalAccountId = principal.accountId,
                profileId = profileId,
                displayName = displayName,
                primarySport = request.primarySport,
                experienceLevel = request.experienceLevel,
                units = request.units,
                timezone = request.timezone,
                locale = request.locale,
            )
        return when (result) {
            is CreateProfileResult.Created -> {
                ResponseEntity
                    .status(HttpStatus.CREATED)
                    .cacheControl(CacheControl.noStore())
                    .body(dto(result.profile))
            }

            is CreateProfileResult.AlreadyExists -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(dto(result.profile))
            }

            CreateProfileResult.SelfProfileConflict -> {
                throw ApiException(
                    status = HttpStatus.CONFLICT,
                    code = "PROFILE_ALREADY_EXISTS",
                    message = "The account already has a profile.",
                )
            }

            is CreateProfileResult.ValidationFailure -> {
                throw invalidRequest()
            }

            CreateProfileResult.IdCollision -> {
                throw invalidRequest()
            }
        }
    }

    @GetMapping("/current")
    fun current(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
    ): ResponseEntity<ProfileResponseDto> {
        val principal = principalResolver.require(authorization)
        return when (val result = getAthleteProfile.currentSelf(principal.accountId)) {
            is GetProfileResult.Found -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(dto(result.profile))
            }

            GetProfileResult.NotFound -> {
                throw notFound()
            }
        }
    }

    @GetMapping("/{profileId}")
    fun byId(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @PathVariable profileId: String,
    ): ResponseEntity<ProfileResponseDto> {
        val principal = principalResolver.require(authorization)
        return when (val result = getAthleteProfile.byId(principal.accountId, profileId)) {
            is GetProfileResult.Found -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(dto(result.profile))
            }

            GetProfileResult.NotFound -> {
                throw notFound()
            }
        }
    }

    private fun dto(profile: AthleteProfile): ProfileResponseDto =
        ProfileResponseDto(
            profileId = profile.id.toString(),
            accountId = profile.accountId.toString(),
            profileType = profile.type.name,
            status = profile.status.name,
            displayName = profile.displayName,
            primarySport = profile.primarySport,
            experienceLevel = profile.experienceLevel,
            units = profile.units?.name,
            timezone = profile.timezone,
            locale = profile.locale,
            createdAt = profile.createdAt.toString(),
            updatedAt = profile.updatedAt.toString(),
        )

    private fun invalidRequest(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )

    private fun notFound(): ApiException =
        ApiException(
            status = HttpStatus.NOT_FOUND,
            code = "RESOURCE_NOT_FOUND",
            message = "The requested resource was not found.",
        )
}
