package com.aitrainer.backend.configuration

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.time.Clock

/**
 * Čas se čte výhradně přes injektovaný [Clock] (ADR-010: čas musí být
 * testovatelně abstrahovaný). Přímé volání `Instant.now()` mimo tento
 * bean je zakázané.
 */
@Configuration
class TimeConfiguration {
    @Bean
    fun clock(): Clock = Clock.systemUTC()
}
