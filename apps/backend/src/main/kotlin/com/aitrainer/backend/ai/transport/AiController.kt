package com.aitrainer.backend.ai.transport

import com.aitrainer.backend.ai.application.ProposePlan
import com.aitrainer.backend.ai.application.ProposePlanResult
import com.aitrainer.backend.auth.transport.AuthRateLimiter
import com.aitrainer.backend.auth.transport.PrincipalResolver
import com.aitrainer.backend.infrastructure.http.ApiException
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.CacheControl
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestHeader
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import tools.jackson.databind.json.JsonMapper

data class PlanProposalRequestDto(
    val context: Map<String, Any?>? = null,
)

data class PlanProposalResponseDto(
    val proposal: Map<String, Any?>,
    val promptVersion: String,
    val schemaVersion: String,
    val modelId: String,
)

/**
 * Transport AI plan proposal API (R4-03, C28/C29): jediný AI endpoint
 * (SXC/AGW-001). Vyžaduje platnou access session (AGW-008), rate limiting
 * baseline (AGW-009) a ohraničený kontext (ACX-010). Selhání modelu i
 * nevalidní výstup jsou typované kanonické chyby — nikdy 200 (C28 §4).
 */
@RestController
@RequestMapping("/api/v1/ai")
class AiController(
    private val principalResolver: PrincipalResolver,
    private val rateLimiter: AuthRateLimiter,
    private val proposePlan: ProposePlan,
) {
    companion object {
        private const val MAX_CONTEXT_CHARS = 32_000
    }

    private val mapper = JsonMapper.builder().build()

    @PostMapping("/plan-proposals")
    fun proposePlan(
        @RequestHeader(name = HttpHeaders.AUTHORIZATION, required = false) authorization: String?,
        @RequestBody request: PlanProposalRequestDto,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<PlanProposalResponseDto> {
        rateLimiter.enforce("ai-plan-proposal", httpRequest.remoteAddr ?: "unknown")
        val principal = principalResolver.require(authorization)
        val context = request.context ?: throw invalidRequest()
        val contextJson = mapper.writeValueAsString(context)
        if (contextJson.length > MAX_CONTEXT_CHARS) {
            throw invalidRequest()
        }
        return when (val result = proposePlan.propose(principal.accountId, contextJson)) {
            is ProposePlanResult.Proposed -> {
                ResponseEntity
                    .ok()
                    .cacheControl(CacheControl.noStore())
                    .body(
                        PlanProposalResponseDto(
                            proposal = result.canonical,
                            promptVersion = result.promptVersion,
                            schemaVersion = result.schemaVersion,
                            modelId = result.modelId,
                        ),
                    )
            }

            is ProposePlanResult.Unavailable -> {
                throw ApiException(
                    status = HttpStatus.SERVICE_UNAVAILABLE,
                    code = "AI_UNAVAILABLE",
                    message = "The AI service is temporarily unavailable.",
                )
            }

            ProposePlanResult.InvalidOutput -> {
                throw ApiException(
                    status = HttpStatus.BAD_GATEWAY,
                    code = "AI_INVALID_OUTPUT",
                    message = "The AI service returned an invalid proposal.",
                )
            }
        }
    }

    private fun invalidRequest(): ApiException =
        ApiException(
            status = HttpStatus.BAD_REQUEST,
            code = "INVALID_REQUEST",
            message = "The request is invalid.",
        )
}
