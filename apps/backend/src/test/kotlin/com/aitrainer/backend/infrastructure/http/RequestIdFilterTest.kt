package com.aitrainer.backend.infrastructure.http

import org.junit.jupiter.api.Test
import org.slf4j.MDC
import org.springframework.mock.web.MockFilterChain
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertNull
import kotlin.test.assertTrue

class RequestIdFilterTest {
    private val filter = RequestIdFilter()

    @Test
    fun `odpoved nese validni prichozi request id`() {
        val request = MockHttpServletRequest()
        request.addHeader(RequestIdSupport.HEADER_NAME, "incoming-id-123")
        val response = MockHttpServletResponse()

        filter.doFilter(request, response, MockFilterChain())

        assertEquals("incoming-id-123", response.getHeader(RequestIdSupport.HEADER_NAME))
    }

    @Test
    fun `nevalidni prichozi request id se bezpecne nahradi`() {
        val request = MockHttpServletRequest()
        request.addHeader(RequestIdSupport.HEADER_NAME, "bad value\nwith newline")
        val response = MockHttpServletResponse()

        filter.doFilter(request, response, MockFilterChain())

        val header = response.getHeader(RequestIdSupport.HEADER_NAME)
        assertNotEquals("bad value\nwith newline", header)
        assertTrue(RequestIdSupport.isValid(header))
    }

    @Test
    fun `request id je behem zpracovani v MDC a po requestu se vycisti`() {
        val request = MockHttpServletRequest()
        request.addHeader(RequestIdSupport.HEADER_NAME, "mdc-check-id")
        val response = MockHttpServletResponse()
        var observedMdcValue: String? = null
        val chain =
            MockFilterChain(
                object : jakarta.servlet.http.HttpServlet() {},
                object : jakarta.servlet.Filter {
                    override fun doFilter(
                        req: jakarta.servlet.ServletRequest,
                        res: jakarta.servlet.ServletResponse,
                        innerChain: jakarta.servlet.FilterChain,
                    ) {
                        observedMdcValue = MDC.get(RequestIdSupport.MDC_KEY)
                        innerChain.doFilter(req, res)
                    }
                },
            )

        filter.doFilter(request, response, chain)

        assertEquals("mdc-check-id", observedMdcValue)
        assertNull(MDC.get(RequestIdSupport.MDC_KEY))
    }
}
