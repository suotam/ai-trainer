# AI Trainer – R3 Manual Activity Contract (C22)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-manual-activity-contract.md`
**Vlastník:** Domain (activity-model) + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C22 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/activity-model.md`, `docs/06-domain/r3-sports-profile-contract.md` (C17), `docs/06-domain/r3-progress-statistics-contract.md` (C23), `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/13-delivery/r3-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R3-06, C24 (sync extension)
**Vlastněné pojmy nebo kontrakty:** ruční aktivita (`Activity` se zdrojem `MANUAL`) — P0 podmnožina activity modelu, vazby, dvojí započtení a pravidla `MAC-001` až `MAC-015`

---

# 1. Purpose

R3-06 umožňuje zaznamenat **skutečnost mimo plán**: aktivitu, která proběhla, ale nemá (nutně) plánovaný protějšek (activity model §2 — „skutečnost nesmí přepsat plán", §4.1). `activity-model.md` popisuje plný tvar (importy, GPS, processing stavy); tento dokument vybírá závaznou P0 podmnožinu: **ruční záznam** (`MANUAL`).

**Blocking pro `R3-06`** (spolu s C16 rozšířením a C23).

# 2. Scope a non-goals

**Řeší:** aggregate `Activity` (MANUAL) — atributy, vazby, editace; ownership/sync/attach; invarianty `MAC-*`.

**Neřeší (non-goals R3):** importy (wearables/HealthKit), GPS, `ActivityStatus` lifecycle `RECORDING/PROCESSING` (ruční záznam je rovnou hotový fakt), strukturované metriky aktivity, aktivita přes půlnoc s přesnými časy (P0 pracuje s lokálním datem + volitelnou délkou), mazání.

# 3. Activity (kontraktně)

`Activity` je vlastnitelný aggregate root (C16 §6):

- **title** — povinný neprázdný popis (např. „Večerní běh"),
- **localDate** — povinné lokální datum (`YYYY-MM-DD`), kdy aktivita proběhla,
- volitelně: **durationMinutes** (≥ 1), **vazba na UserSport** (device-local reference, vzor GLC-008), **vazba na WorkoutInstance** (device-local; dokumentuje, že aktivita odpovídá plánovanému workoutu — klíčové pro dvojí započtení, C23), **note**,
- **source = `MANUAL`** — jediný P0 zdroj (stabilní kód; importní zdroje přidají budoucí kontrakty),
- client-generated ID, owner/sync metadata, `row_version`, časové značky.

# 4. Chování

- **Záznam je fakt po skutečnosti** — vzniká rovnou hotový; žádné stavy.
- **Editace current-state je dovolena** (vlastní ruční záznam smí uživatel opravit; verze +1, `SYNCED→DIRTY`); **mazání není P0 operace**.
- **Neúplnost je validní** — délka, sport i vazby jsou volitelné (unknown ≠ zero).
- Aktivita **nemění plán ani workout data** (§4.1) — vazba na instanci je čistě dokumentační.

# 5. Ownership, sync a attach

Owner stamping při zápisu (C16 §6.2); **attach bezpodmínečný** (uživatelská fakta bez cross-owner invariant); push začne s C24 (`R3M-007`).

# 6. Invarianty (`MAC`)

- **MAC-001 — Vlastnitelný root** s owner/sync metadaty od vzniku.
- **MAC-002 — Povinné jen title + datum**; vše ostatní volitelné, unknown ≠ zero.
- **MAC-003 — MANUAL source.** P0 zdroj je výhradně `MANUAL`; kód stabilní.
- **MAC-004 — Fakt bez lifecycle.** Ruční aktivita vzniká hotová; žádné processing stavy.
- **MAC-005 — Editovatelná, nemazatelná.** Editace current-state dovolena; mazání není P0.
- **MAC-006 — Device-local vazby.** Sport i instance jsou volitelné reference podle ID bez owner filtru; neexistující reference je validační chyba.
- **MAC-007 — Skutečnost nemění plán.** Zápis aktivity nemění instance, sessions ani summaries.
- **MAC-008 — Dvojí započtení řeší C23.** Aktivita s vazbou na instanci se ve statistikách nezapočítává vedle dokončeného workoutu (PST-006).
- **MAC-009 — Bezpodmínečný attach.**
- **MAC-010 — Deterministické read modely.** Seznam řazen datem sestupně, pak title.
- **MAC-011 — Offline first.** **MAC-012 — Bez AI.**
- **MAC-013 — Validace kódů a dat** (datum formát, délka ≥ 1).
- **MAC-014 — Sync disciplína** (`LOCAL_ONLY`/`DIRTY`; registr v C24).
- **MAC-015 — Evidence testů** dle C16 §8; flaky ≠ zelený důkaz.

# 7. Ready condition

C22 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C16 (tabulka aktivit) a C23 činí **`R3-06` `READY`**.
