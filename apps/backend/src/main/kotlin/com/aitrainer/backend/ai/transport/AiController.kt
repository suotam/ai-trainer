package com.aitrainer.backend.ai.transport

import com.aitrainer.backend.ai.application.ProposePlan
import com.aitrainer.backend.ai.application.ProposePlanResult
import com.aitrainer.backend.ai.domain.AiRequestType
import com.aitrainer.backend.auth.transport.AuthRateLimiter
import com.aitrainer.backend.auth.transport.PrincipalResolver
import com.aitrainer.backend.infrastructure.http.ApiException
import jakarta.servlet.http.HttpServletRequest
import org.springframework.beans.factory.annotation.Value
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
import java.time.Duration

data class PlanProposalRequestDto(
    val context: Map<String, Any?>? = null,
    // C37 §2: jediný endpoint, typ v requestu; default plan proposal.
    val requestType: String? = null,
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
    // Dedikovaný per-account AI limit (C31 §3, AIS-004) — přísnější než
    // auth baseline, protože AI volání je drahé.
    @param:Value("\${aitrainer.ai.rate-limit.limit:5}") private val aiRateLimit: Int,
    @param:Value("\${aitrainer.ai.rate-limit.window:PT1M}") private val aiRateWindow: Duration,
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
        // Dvě nezávislé vrstvy (C31 §3): pre-auth IP limit (AIS-005) a
        // per-account AI limit po resolvu session (AIS-004).
        rateLimiter.enforce("ai-plan-proposal", httpRequest.remoteAddr ?: "unknown")
        val principal = principalResolver.require(authorization)
        rateLimiter.enforce(
            "ai-plan-proposal-account",
            principal.accountId.toString(),
            aiRateLimit,
            aiRateWindow.toMillis(),
        )
        val context = request.context ?: throw invalidRequest()
        // Neznámý typ = typované odmítnutí (C37 ASJ-006).
        val type =
            when (request.requestType) {
                null, AiRequestType.PLAN_PROPOSAL.name -> AiRequestType.PLAN_PROPOSAL
                AiRequestType.ADJUSTMENT_PROPOSAL.name -> AiRequestType.ADJUSTMENT_PROPOSAL
                else -> throw invalidRequest()
            }
        val contextJson = mapper.writeValueAsString(context)
        if (contextJson.length > MAX_CONTEXT_CHARS) {
            throw invalidRequest()
        }
        return when (val result = proposePlan.propose(principal.accountId, contextJson, type)) {
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
