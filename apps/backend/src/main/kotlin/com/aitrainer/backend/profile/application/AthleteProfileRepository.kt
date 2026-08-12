package com.aitrainer.backend.profile.application

import com.aitrainer.backend.profile.domain.AthleteProfile
import java.util.UUID

/** Perzistence AthleteProfile (C6 §8.1); schéma vlastní Flyway migrace. */
interface AthleteProfileRepository {
    /**
     * Načte profil podle ID bez ownership filtru — první autoritativní
     * ownership rozhodnutí dělá application vrstva (C8 §9), aby uměla
     * odlišit neexistenci od cizího vlastnictví pro audit (AOC-013);
     * navenek jsou nerozlišitelné (AOC-007).
     */
    fun findById(profileId: UUID): AthleteProfile?

    /** SELF profil daného účtu (právě jeden v R2, C6 §8.1). */
    fun findSelfByAccountId(accountId: UUID): AthleteProfile?

    fun insert(profile: AthleteProfile)
}
