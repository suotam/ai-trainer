package com.aitrainer.backend

import com.aitrainer.backend.configuration.ServiceInfoProperties
import java.time.Clock
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest

/**
 * Základní Spring test bootstrapu (evidence gate R0-03): context se
 * sestaví a composition poskytuje service info a testovatelný Clock.
 */
@SpringBootTest
class AiTrainerBackendApplicationTests {

    @Autowired
    lateinit var serviceInfo: ServiceInfoProperties

    @Autowired
    lateinit var clock: Clock

    @Test
    fun contextLoads() {
        assertNotNull(clock)
    }

    @Test
    fun `service info ma bezpecne defaults`() {
        assertEquals("ai-trainer-backend", serviceInfo.name)
        assertEquals("0.0.1-dev", serviceInfo.version)
    }
}
