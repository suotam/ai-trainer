# AI Trainer – R7 Calendar & Quick-Complete Contract (C50)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r7-calendar-quickcomplete-contract.md`  
**Vlastník:** Domain + Product + Mobile  
**Navazuje na:** C16 (workout read modely), C21 (kalendářní operace), C22 (completion), C23 (statistiky), C39 (týdenní souhrn), R1-05 (startup recovery), `docs/13-delivery/r7-vertical-slice-plan.md`  
**Blokuje:** `R7-05 – Calendar View, Quick Complete and Stats Surfacing`

---

# 1. Účel

Uzavírá denní smyčku vlastníka: tréninky vidím v **kalendáři**, odkliknu je (**rychlé dokončení**) nebo projdu plnou session, výsledky čtu ve **statistikách**; **chat se stává domovem** aplikace. Žádná nová doménová pravda — kalendář je read model nad C16, dokončení jde výhradně existujícími C22 operacemi, čísla vlastní C23/C39.

# 2. Kalendářní read model

- Pohled po měsících (mřížka MON–SUN) + výběr dne se seznamem workoutů dne; data výhradně `workoutsForLocalDateRange` (C16) — lokální data `YYYY-MM-DD`, žádné TZ přepočty mimo existující pravidla.
- Hranice měsíce deterministické (první–poslední den měsíce); navigace prev/next bez limitu; „dnes" zvýrazněno.
- Stavy instancí se zobrazují poctivě (READY/IN_PROGRESS/COMPLETED/CANCELLED…); kalendář nikdy stav nedopočítává.
- Přesuny/rušení vlastní C21 (existující cesty přes detail/plán) — kalendář nepřidává novou mutační cestu; z kalendáře vede tap na existující detail workoutu.

# 3. Rychlé dokončení (quick-complete)

- **Jediná cesta = existující C22 operace v témže kroku**: start session + okamžité dokončení (`completeWorkout`) — žádný nový zápisový mechanismus.
- **Poctivá zkrácená evidence, nikdy předstíraná plná session (R7P-010):** nevznikají žádné step/set performance řádky; summary drží **měřené** hodnoty (dokončené kroky 0 z N, aktivní čas 0 — nic se neměřilo). Instance končí **dle C22 pravidel** — bez měřených kroků tedy `PARTIALLY_COMPLETED` („proběhlo bez evidence kroků"), což UI zobrazuje poctivě („dokončeno bez měření"); C22 se kvůli quick-complete nemění. Statistiky C23 počítají dokončený záznam (summary existuje), měřené metriky zůstávají prázdné — žádné vymyšlené hodnoty.
- Typované výsledky: úspěch; existující aktivní session téže instance se dokončí (převzetí, ne duplikát); už dokončený workout = idempotentní `alreadyCompleted`; ostatní selhání typovaná bez výjimek.
- Rychlé dokončení je dostupné z kalendáře pro nedokončené workouty; plná session zůstává rovnocenně dostupná (detail → start).

# 4. Statistiky v denní smyčce

- Kalendář odkazuje na existující C23 aktivitu/progres a C39 týdenní souhrn; čísla vlastní výhradně tyto kontrakty.
- Quick-completed workout se v historii (C23 summaries) zobrazuje poctivě: dokončení bez měřených kroků/času.

# 5. Chat jako domov

- Startup recovery gate (R1-05): **zákon aktivní session trvá beze změny** (obnova aktivní session má přednost); bez aktivní session vede gate nově na **/chat** (dřív Today). Fallback stavy gate beze změny.
- Today zůstává plnohodnotně dostupný (z chatu i kalendáře); žádná funkce se neodebírá.

# 6. Invarianty

- **CQC-001** Kalendář je čistý read model nad C16; žádná vlastní pravda ani dopočty stavů.
- **CQC-002** Data dne = lokální `YYYY-MM-DD`; hranice měsíce deterministické.
- **CQC-003** Quick-complete používá výhradně existující C22 operace; žádná nová write cesta.
- **CQC-004** Quick-complete nefabrikuje metriky: žádné performance řádky, měřené hodnoty zůstávají prázdné/nulové; faktem je jen dokončení.
- **CQC-005** Výsledky quick-complete typované; opakování idempotentní (`alreadyCompleted`).
- **CQC-006** Aktivní session téže instance se quick-completem poctivě dokončí — nikdy nevzniká druhá session.
- **CQC-007** Statistiky a souhrny vlastní C23/C39; kalendář je jen odkazuje.
- **CQC-008** Mutace kalendáře (move/cancel) výhradně existující C21 cestou.
- **CQC-009** Chat je domov; obnova aktivní session má i nadále přednost (R1-05 beze změny); Today zůstává dostupný.
- **CQC-010** Po dokončení se invalidují dotčené read modely (kalendář, Today, historie, statistiky, souhrn).
- **CQC-011** Kalendář funguje plně offline a bez klíče (R7P-006).
- **CQC-012** Deterministické testy: read model hranice měsíce, quick-complete matice, home routing.
