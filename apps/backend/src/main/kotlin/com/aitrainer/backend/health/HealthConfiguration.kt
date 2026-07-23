package com.aitrainer.backend.health

import com.aitrainer.backend.configuration.ServiceInfoProperties
import com.aitrainer.backend.health.application.ApplicationReadinessIndicator
import com.aitrainer.backend.health.application.HealthQueryService
import com.aitrainer.backend.health.application.ReadinessIndicator
import java.time.Clock
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

/** Composition health komponent; application vrstva zůstává bez Spring anotací. */
@Configuration
class HealthConfiguration {

    @Bean
    fun applicationReadinessIndicator(): ReadinessIndicator = ApplicationReadinessIndicator()

    @Bean
    fun healthQueryService(
        serviceInfo: ServiceInfoProperties,
        clock: Clock,
        readinessIndicators: List<ReadinessIndicator>,
    ): HealthQueryService = HealthQueryService(serviceInfo, clock, readinessIndicators)
}
