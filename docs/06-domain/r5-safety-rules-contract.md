# AI Trainer – R5 Deterministic Safety Rules Contract (C34)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r5-safety-rules-contract.md`
**Vlastník:** Domain (recovery-and-limitations-model §31–§33, §83) + Security
**Kontraktní ID:** C34 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/recovery-and-limitaitons-model.md` (§31 SafetyFlag, §32 SafetyAssessment, §33.4 deterministická vrstva, §83 rules engine), `docs/06-domain/r5-daily-checkin-contract.md` (C33), `docs/06-domain/r3-availability-context-contract.md` (C19 omezení), `docs/02-product/release-scope.md` (§9.3 odborná hranice)
**Navazující dokumenty:** implementace R5-02, C35 (Today doporučení čte assessment), C36/C38 (AI kontext a execution respektují safety stav)
**Vlastněné pojmy nebo kontrakty:** P0 safety pravidla, `SafetyFlag`/`SafetyAssessment` P0 podmnožina, konzervativní defaulty a pravidla `SFR-001` až `SFR-015`

---

# 1. Purpose

Deterministická safety vrstva (model §33.4): **čistá funkce** z denního check-inu (C33) a aktivních omezení (C19) na typované vyhodnocení. Žádná AI, žádná síť, žádná persistence — assessment je rekonstruovatelný read model. AI smí výsledek vysvětlit, **nikdy obejít** (R5P-001).

**Poctivá hranice (release scope §9.3):** P0 pravidla jsou konzervativní inženýrská heuristika nad subjektivními škálami — **nejsou medicínský posudek**; stavy vyžadující klinickou reakci (`STOP_AND_SEEK_HELP`, ACUTE_TRAUMA, …) jsou mimo P0, dokud neproběhne odborné a právní review (model §31). UI formulace opatrné (§32.3).

**Blocking pro `R5-02`.**

# 2. Vstup a výstup

**Vstup:** dnešní `DailyCheckIn` (nebo null — validní stav, DCI-001) + aktivní C19 omezení (tituly). Nic víc — funkce nesmí číst síť, čas ani jiná data.

**Výstup `SafetyAssessment` (P0 podmnožina modelu §32.2):**

| Stav | Význam |
|---|---|
| `INSUFFICIENT_INFORMATION` | dnes není check-in — poctivé „nevíme“, ne implicitní OK |
| `SAFE_WITH_CURRENT_INFORMATION` | žádný signál z pravidel §3; **není to medicínská záruka** (§32.3) |
| `CAUTION` | alespoň jeden CAUTION signál |
| `DO_NOT_RECOMMEND_ACTIVITY` | alespoň jeden STOP signál — konzervativní doporučení odpočinku |

+ seznam `SafetyFlag` (P0 kódy: `SEVERE_PAIN`, `PAIN_REPORTED`, `VERY_HIGH_FATIGUE`, `HIGH_FATIGUE`, `LOW_ENERGY`, `POOR_SLEEP`, `ACTIVE_CONSTRAINT`) — každý flag nese svůj zdroj (u bolesti oblast + úroveň, u omezení titul).

# 3. P0 pravidla (tabulkově, konzervativně)

| Signál | Podmínka | Flag | Příspěvek |
|---|---|---|---|
| Silná bolest | `painLevel ≥ 4` | `SEVERE_PAIN(area, level)` | STOP |
| Velmi vysoká únava | `fatigueLevel = 5` | `VERY_HIGH_FATIGUE` | STOP |
| Hlášená bolest | `painLevel 1–3` | `PAIN_REPORTED(area, level)` | CAUTION |
| Vysoká únava | `fatigueLevel = 4` | `HIGH_FATIGUE` | CAUTION |
| Nízká energie | `energyLevel ≤ 2` | `LOW_ENERGY` | CAUTION |
| Špatný spánek | `sleepQuality ≤ 2` | `POOR_SLEEP` | CAUTION |
| Aktivní omezení | každé aktivní C19 omezení | `ACTIVE_CONSTRAINT(titul)` | CAUTION |

Výsledný stav = nejpřísnější příspěvek (STOP > CAUTION > SAFE). Bez check-inu je stav vždy `INSUFFICIENT_INFORMATION` (aktivní omezení se přesto reportují jako flags). Pořadí flags je deterministické (pořadí pravidel v tabulce; omezení dle pořadí vstupu).

# 4. Invarianty (`SFR`)

- **SFR-001 — Čistá deterministická funkce.** Stejný vstup → identický výstup; žádná síť, čas, náhoda, AI ani persistence.
- **SFR-002 — Konzervativní směr.** Pravidla se smí mýlit jen směrem k opatrnosti; nejasný vstup nikdy nezvyšuje povolení.
- **SFR-003 — AI nikdy nevelí.** Assessment nevzniká z AI a AI ho nesmí přepsat ani obejít (model §33.4); C36/C38 ho konzumují jako fakt.
- **SFR-004 — Chybějící check-in ≠ OK.** `INSUFFICIENT_INFORMATION` je vlastní poctivý stav; nikdy se tiše nemapuje na SAFE.
- **SFR-005 — Bolest má vždy zdroj.** Pain flags nesou oblast + úroveň z C33 strukturovaných dat; volný text se nikdy neinterpretuje.
- **SFR-006 — Omezení jsou trvalé flags.** Aktivní C19 omezení se reportuje vždy (i bez check-inu) a drží minimálně CAUTION, dokud trvá check-in stav.
- **SFR-007 — Žádné klinické stavy v P0.** `STOP_AND_SEEK_HELP` a klinické flags modelu §31 jsou mimo P0 (odborné review); engine je nesmí emitovat.
- **SFR-008 — Opatrná formulace.** UI texty netvrdí bezpečnost ani diagnózu (§32.3); beta označení hranice povinné (R5P-003).
- **SFR-009 — Assessment nejedná.** Vyhodnocení nic nemění (žádné blokace zápisů v P0) — je to doporučující read model; rozhodnutí zůstává uživateli.
- **SFR-010 — Rekonstruovatelnost.** Žádná uložená vyhodnocení; assessment se počítá z aktuálních dat na vyžádání.
- **SFR-011 — Stabilní kódy.** Flag kódy a stavy jsou stabilní kontraktní hodnoty (UI překládá, doména ne).
- **SFR-012 — Rozšíření jen kontraktem.** Nové pravidlo/flag = revize C34, ne implementační rozhodnutí.
- **SFR-013 — Nezávislost na R1–R4.** Engine nečte plán ani workouty; kombinace se řeší v C35 (doporučení), ne tady.
- **SFR-014 — Deterministické pořadí flags** dle §3 — identický výstup i v pořadí.
- **SFR-015 — Evidence.** Tabulkové testy všech pravidel a hran (4/5 úrovně, kombinace, bez check-inu, omezení), determinismus opakovaného běhu, widget evidence opatrné formulace; flaky ≠ zelený důkaz.

# 5. Ready condition

C34 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-02` `READY`**.
