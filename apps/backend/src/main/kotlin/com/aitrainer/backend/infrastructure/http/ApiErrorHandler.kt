package com.aitrainer.backend.infrastructure.http

import com.aitrainer.backend.health.application.ServiceNotReadyException
import java.time.Clock
import org.slf4j.LoggerFactory
import org.slf4j.MDC
import org.springframework.http.CacheControl
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.HttpMediaTypeNotAcceptableException
import org.springframework.web.HttpMediaTypeNotSupportedException
import org.springframework.web.HttpRequestMethodNotSupportedException
import org.springframework.web.bind.ServletRequestBindingException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.servlet.NoHandlerFoundException
import org.springframework.web.servlet.resource.NoResourceFoundException

/**
 * Centralizované bezpečné mapování chyb na standardní error envelope
 * (`r0-api-contract.md` §7). Interní detail se loguje redigovaně; do HTTP
 * odpovědi nikdy nepatří stack trace, interní třídy, SQL ani secrets.
 */
@RestControllerAdvice
class ApiErrorHandler(private val clock: Clock) {

    private val log = LoggerFactory.getLogger(ApiErrorHandler::class.java)

    @ExceptionHandler(ServiceNotReadyException::class)
    fun handleNotReady(exception: ServiceNotReadyException): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.SERVICE_UNAVAILABLE, "SERVICE_NOT_READY", "Service is not ready to accept traffic.")
            .also { log.warn("Readiness check failed; returning 503") }

    @ExceptionHandler(NoResourceFoundException::class, NoHandlerFoundException::class)
    fun handleNotFound(exception: Exception): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.NOT_FOUND, "RESOURCE_NOT_FOUND", "The requested resource was not found.")

    @ExceptionHandler(HttpRequestMethodNotSupportedException::class)
    fun handleMethodNotAllowed(exception: HttpRequestMethodNotSupportedException): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.METHOD_NOT_ALLOWED, "METHOD_NOT_ALLOWED", "The HTTP method is not supported for this resource.")

    @ExceptionHandler(HttpMediaTypeNotAcceptableException::class)
    fun handleNotAcceptable(exception: HttpMediaTypeNotAcceptableException): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.NOT_ACCEPTABLE, "NOT_ACCEPTABLE", "The requested response media type is not supported.")

    @ExceptionHandler(HttpMediaTypeNotSupportedException::class)
    fun handleUnsupportedMediaType(exception: HttpMediaTypeNotSupportedException): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.UNSUPPORTED_MEDIA_TYPE, "UNSUPPORTED_MEDIA_TYPE", "The request media type is not supported.")

    @ExceptionHandler(ServletRequestBindingException::class)
    fun handleInvalidRequest(exception: ServletRequestBindingException): ResponseEntity<ErrorResponseDto> =
        envelope(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", "The request is invalid.")

    @ExceptionHandler(Exception::class)
    fun handleUnexpected(exception: Exception): ResponseEntity<ErrorResponseDto> {
        log.error("Unhandled exception while processing request", exception)
        return envelope(HttpStatus.INTERNAL_SERVER_ERROR, "INTERNAL_ERROR", "An unexpected internal error occurred.")
    }

    private fun envelope(
        status: HttpStatus,
        code: String,
        message: String,
    ): ResponseEntity<ErrorResponseDto> {
        val requestId = MDC.get(RequestIdSupport.MDC_KEY) ?: RequestIdSupport.generate()
        return ResponseEntity.status(status)
            .cacheControl(CacheControl.noStore())
            .body(
                ErrorResponseDto(
                    code = code,
                    message = message,
                    requestId = requestId,
                    timestamp = clock.instant().toString(),
                ),
            )
    }
}
