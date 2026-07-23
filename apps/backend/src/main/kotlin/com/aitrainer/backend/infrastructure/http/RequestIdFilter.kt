package com.aitrainer.backend.infrastructure.http

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.MDC
import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter

/**
 * Korelace requestů (APR-007): každá HTTP odpověď nese validní
 * `X-Request-Id` a stejná hodnota je po dobu zpracování dostupná v MDC
 * pro redigované logování. MDC se po requestu vždy vyčistí, aby hodnota
 * neprosákla mezi thready.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
class RequestIdFilter : OncePerRequestFilter() {

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val requestId = RequestIdSupport.resolve(request.getHeader(RequestIdSupport.HEADER_NAME))
        response.setHeader(RequestIdSupport.HEADER_NAME, requestId)
        MDC.put(RequestIdSupport.MDC_KEY, requestId)
        try {
            filterChain.doFilter(request, response)
        } finally {
            MDC.remove(RequestIdSupport.MDC_KEY)
        }
    }
}
