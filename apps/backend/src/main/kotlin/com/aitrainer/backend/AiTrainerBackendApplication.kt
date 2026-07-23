package com.aitrainer.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

/**
 * Bootstrap modulárního monolitu (BAR-001). Produktové moduly vzniknou
 * až se slices, které je potřebují; bootstrap nevlastní business logiku.
 */
@SpringBootApplication
@ConfigurationPropertiesScan
class AiTrainerBackendApplication

fun main(args: Array<String>) {
    runApplication<AiTrainerBackendApplication>(*args)
}
