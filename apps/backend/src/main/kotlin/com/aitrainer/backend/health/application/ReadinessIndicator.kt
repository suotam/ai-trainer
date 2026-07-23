package com.aitrainer.backend.health.application

enum class CheckStatus { UP, DOWN }

/**
 * Port pro readiness check jedné povinné závislosti prostředí
 * (`r0-api-contract.md` §13.2). Další povinné závislosti (database,
 * migrations v R0-05) se přidávají novým beanem bez změny veřejného
 * kontraktu — klíč se objeví v `checks` mapě readiness odpovědi.
 */
interface ReadinessIndicator {
    /** Stabilní klíč checku v readiness odpovědi (např. `application`). */
    val name: String

    /** Musí být bezpečný, bez side effects a s bounded dobou běhu. */
    fun check(): CheckStatus
}

/**
 * Bootstrap check: pokud Spring context běží a bean je volán, aplikace
 * dokončila bootstrap. Jediná povinná závislost R0-04 prostředí —
 * PostgreSQL/Flyway se stanou povinnými až v R0-05.
 */
class ApplicationReadinessIndicator : ReadinessIndicator {
    override val name: String = "application"

    override fun check(): CheckStatus = CheckStatus.UP
}
