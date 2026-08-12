package com.aitrainer.backend.infrastructure.http

import org.springframework.http.HttpStatus

/**
 * Typovaná API chyba mapovaná centrálním handlerem na kanonický error
 * envelope (`r0-api-contract.md` §7). `code` je stabilní UPPER_SNAKE_CASE
 * (APR-006); `message` je bezpečná obecná zpráva bez interních detailů.
 */
class ApiException(
    val status: HttpStatus,
    val code: String,
    override val message: String,
    val retryAfterSeconds: Long? = null,
) : RuntimeException(message)
