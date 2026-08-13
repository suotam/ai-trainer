# AI Trainer – R3 Progress and Completion Statistics Contract (C23)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-progress-statistics-contract.md`
**Vlastník:** Domain (metrics-model) + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C23 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/metrics-model.md` (§3), `docs/06-domain/r3-manual-activity-contract.md` (C22), `docs/06-domain/r3-calendar-operations-contract.md` (C21), `docs/12-data/r1-physical-data-model.md`, `docs/13-delivery/r3-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R3-06, R4 kontrakty (AI čte statistiky jako kontext)
**Vlastněné pojmy nebo kontrakty:** základní progres/completion statistiky jako deterministický read model a pravidla `PST-001` až `PST-015`

---

# 1. Purpose

R3-06 dává uživateli **poctivý základní přehled**: kolik workoutů měl v období naplánováno, kolik dokončil a kolik ručních aktivit zaznamenal. Metrics model (§3) ukládá závazné principy — hodnota má význam, žádná falešná přesnost, plán a skutečnost odděleně; tento dokument definuje P0 read model.

**Blocking pro `R3-06`** (spolu s C22).

# 2. Scope a non-goals

**Řeší:** definici statistik (§3), zdroje a dvojí započtení (§4), determinismus a period (§5), invarianty `PST-*`.

**Neřeší (non-goals R3):** `MetricDefinition`/uživatelské metriky, trendy, grafy nad P0 minimum, prediktivní metriky, vyhodnocování cílů (completion-based statistiky nejsou goal assessment), aktivní čas z R1 summaries (je vždy 0 — nesmí se prezentovat, `PST-004`).

# 3. Statistiky (P0)

Pro dané období (od–do, lokální data) deterministicky:

- **plannedCount** — workout instance se `scheduled_local_date` v období, **mimo `CANCELLED`** (zrušený workout není plán — konzistentní s C21 §7),
- **completedCount** — activity summaries s dokončením v období (fakt dokončení; zdroj instance nerozhoduje — dokončený demo workout je skutečný trénink),
- **completionRate** — `completedCount / plannedCount`, definovaný jen pro `plannedCount > 0` (jinak „—", ne 0 ani 100 %),
- **manualActivityCount** — ruční aktivity (C22) s datem v období **bez vazby na instanci** (§4),
- **manualMinutes** — součet zadaných délek těchto aktivit (aktivity bez délky se do součtu nepočítají a nic se nedopočítává).

# 4. Zdroje a dvojí započtení

- Zdroje: `local_workout_instances`, `local_activity_summaries`, `local_activities`. **Žádné uložené agregáty** — vše se počítá při čtení (R3P-010).
- **PST-006 (dvojí započtení):** ruční aktivita s vazbou na workout instanci dokumentuje týž trénink — do `manualActivityCount`/`manualMinutes` se nepočítá; trénink reprezentuje summary dokončeného workoutu.
- **Device-local scope (řízené rozhodnutí):** statistiky se počítají nad daty zařízení bez owner filtru — konzistentní s Today/kalendářem (zobrazují seed i uživatelská data). Owner-scoped statistiky jsou budoucí rozhodnutí (R4+ s AI kontextem).

# 5. Determinismus a období

- Stejný stav DB + stejné období → **identický výsledek** (žádná závislost na čase výpočtu mimo vstupní období).
- P0 UI prezentuje **posledních 7 dní** a **posledních 30 dní** (včetně dneška, odvozeno z injektovaného clocku).

# 6. Invarianty (`PST`)

- **PST-001 — Read model.** Statistiky jsou odvozené, rekonstruovatelné, bez perzistence.
- **PST-002 — Determinismus.** Stejný vstup → stejný výstup.
- **PST-003 — Plán ≠ skutečnost.** Planned/completed/manual jsou oddělené hodnoty; nikdy se neslévají.
- **PST-004 — Žádná falešná přesnost.** Neznámá hodnota se neprezentuje (R1 aktivní čas = 0 se nezobrazuje; completionRate bez plánu je „—").
- **PST-005 — CANCELLED není plán.**
- **PST-006 — Bez dvojího započtení.** Aktivita vázaná na instanci se nepočítá vedle summary.
- **PST-007 — Dokončení je fakt.** completedCount čte výhradně summaries (žádné dopočítávání ze stavů instancí).
- **PST-008 — Device-local scope** (§4, řízené rozhodnutí; owner scoping později).
- **PST-009 — Poctivý empty stav.** Prázdné období ukazuje nuly/„—", žádné vymyšlené hodnoty.
- **PST-010 — Offline first.** **PST-011 — Bez AI.**
- **PST-012 — Clock injektovaný.** Období se odvozuje z injektovaného clocku (testovatelnost).
- **PST-013 — Bez vedlejších efektů.** Výpočet nikdy nezapisuje.
- **PST-014 — Stabilní definice.** Změna definice statistiky = změna tohoto kontraktu.
- **PST-015 — Evidence testů:** determinismus, dvojí započtení, CANCELLED, empty stav; flaky ≠ zelený důkaz.

# 7. Ready condition

C23 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C22 (+C16 rozšíření) činí **`R3-06` `READY`**.
