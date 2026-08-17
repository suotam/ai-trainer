# AI Trainer – R8 Guided Session Player Contract (C53)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r8-guided-session-contract.md`  
**Vlastník:** Domain (workout-model) + Mobile  
**Poslední aktualizace:** 2026-08-16  
**Kontraktní ID:** C53 (dle `docs/13-delivery/r8-vertical-slice-plan.md §7.1`)  
**Navazuje na:** `docs/06-domain/workout-model.md` (session, kroky, výkony), `docs/12-data/r1-physical-data-model.md` (§9 session, §10/§11 performance), R1-03/R1-04/R1-05 (start, tracker, dokončení, obnova aktivní session — zákon), `docs/06-domain/r8-exercise-catalog-contract.md` (C51 — popis a cue), `docs/09-ai/r8-plan-schema-v2-contract.md` (C52 — struktura, kterou průvodce čte), `docs/06-domain/r7-calendar-quickcomplete-contract.md` (C50 — quick-complete zůstává zkrácenou evidencí), `docs/12-data/r3-mobile-schema-migration.md` (C16)  
**Navazující dokumenty:** implementace R8-03, C54 (ilustrace v průvodci)  
**Vlastněné pojmy nebo kontrakty:** průvodce (player) aktivní session, stavový model `GuidedSessionState` (krok, sada, fáze, časovače), persistovaný stav průvodce na session (v17), operace pauza/pokračovat/přeskočit/start sady/další, obnova po přerušení, vztah k zápisu výkonů a dokončení, pravidla `GSP-001` až `GSP-014`

---

# 1. Purpose

Tracker aktivní session je dnes plochý formulář sad bez vedení (nález 4). C53 definuje **průvodce**: krokový režim nad **existující session** — aktuální krok (název, popis provedení a cue z katalogu C51, předpis), počítadlo sad se zápisem skutečných hodnot, **odpočet pauzy** po sadě, **časovač** u DURATION sad a REST kroků, další/předchozí/přeskočit, **pauza/pokračovat**, uplynulý aktivní čas; **obnovitelný po přerušení** (R1-05 zákon). Průvodce **nezavádí paralelní cestu**: čte R1 read modely a zapisuje výhradně existujícími performance/completion operacemi.

**Blocking pro `R8-03 – Guided Session Player`.**

---

# 2. Scope

- stavový model průvodce a jeho odvození (§3),
- persistovaný stav na session — schéma v17 (§4),
- operace průvodce a jejich mapování na doménové operace (§5),
- časovače, obnova a determinismus (§6),
- vztah k dokončení, statistikám a quick-complete (§7),
- UI minimum (§8), invarianty `GSP-001..014` (§9), testy (§10), Ready (§11).

Mimo scope: autoregulace zátěže, zvuky/hlas mimo prostý signál konce odpočtu, wearables, editace plánu za běhu, ilustrace (C54).

---

# 3. Stavový model `GuidedSessionState`

Čistá funkce `buildGuidedState(detail, tracker, session, now)`:

- **Kroky průvodce** = ploché pořadí kroků instance přes sekce (sekce.position, krok.position), typy `EXERCISE` (s výkonovými řádky), `REST` (bez výkonových řádků), ostatní typy jako informativní kroky bez zápisu. Každý krok nese: sekci, katalogový kód/vlastní název, popis provedení a cue (C51), předpis, sady (plán + skutečnost z trackeru), stav (`NOT_STARTED/IN_PROGRESS/COMPLETED/PARTIAL/SKIPPED`).
- **Pozice**: `currentStepIndex` (z `session.activeStepId`; není-li nastaven → první nedokončený krok, jinak 0) a `currentSetIndex` (první nedokončená sada aktuálního kroku).
- **Fáze** (`GuidedPhase`): `IDLE` (čeká na akci uživatele), `SET_RUNNING` (běží DURATION sada), `REST_AFTER_SET` (odpočet pauzy po dokončené sadě), `REST_STEP` (běží REST krok), `DONE` (všechny kroky dokončené/přeskočené).
- **Časy**: `remainingSeconds` fáze (z ukotvení §4 a plánované délky; nikdy záporné), `elapsedActiveSeconds` session (§6), `sessionPaused` (`session.status == PAUSED`).
- **Souhrn**: `completedSets/totalSets`, `completedSteps/totalSteps` (jen kroky s výkonovými řádky).

Stav je **odvozený**, ne uložený — jediné persistované vstupy jsou session sloupce §4 a existující výkonové řádky.

# 4. Persistovaný stav průvodce (schéma v17)

`local_workout_sessions` dostává aditivně (C16 vzor, v16 → v17):
- `player_phase TEXT NULL` — `SET_RUNNING | REST_AFTER_SET | REST_STEP` (NULL = IDLE),
- `player_phase_started_at INTEGER NULL` — UTC ms ukotvení běžícího odpočtu/časovače,
- `active_set_position INTEGER NULL` — pozice sady, ke které se fáze vztahuje.
Existující `active_step_id` nese aktuální krok. Sync payload session (R2) tyto sloupce nepřenáší jako povinné (backend dormantní; chybějící klíč → NULL) — stav průvodce je zařízení-lokální pomocník obnovy, ne doménový fakt (`GSP-004`).

# 5. Operace průvodce

Všechny operace jsou repository metody s typovaným výsledkem, ověřují aktivní/pozastavenou session; žádná raw výjimka:

| Operace | Efekt (výhradně existující tabulky) |
|---|---|
| `goToStep(sessionId, stepId)` | `active_step_id`, fáze → NULL |
| `startSet(setPerformanceId)` (DURATION) | fáze `SET_RUNNING`, ukotvení `now`, `active_set_position`; step performance `IN_PROGRESS` + `started_at` (poprvé) |
| `completeSet(setPerformanceId, actuals)` | existující `recordSetActuals` (rozšířeno o `actualDurationSeconds`) + `setSetCompletion(true)`; má-li sada `restAfterSeconds > 0` → fáze `REST_AFTER_SET` s ukotvením `now`, jinak fáze NULL |
| `uncompleteSet` | existující `setSetCompletion(false)`; fáze NULL |
| `startRestStep(sessionId, stepId)` | `active_step_id`, fáze `REST_STEP`, ukotvení `now` |
| `finishPhase(sessionId)` | fáze NULL (uživatel potvrdil konec pauzy/REST kroku; timer dojetý na 0 stav sám nemění — `GSP-006`) |
| `skipStep(stepPerformanceId)` | step performance `SKIPPED`, jeho nedokončené sady `SKIPPED` (poctivý stav; dokončení ho nikdy nepočítá jako COMPLETED) |
| `pauseSession(sessionId)` | `status PAUSED`, `paused_at`, `elapsed_active_seconds += now − last_resumed_at`; běžící fáze se **zmrazí** (ukotvení se při resume posune o délku pauzy) |
| `resumeSession(sessionId)` | `status ACTIVE`, `last_resumed_at = now`, `paused_at NULL`, ukotvení fáze `+= now − paused_at` |
| dokončení | existující C22 `completeWorkout`; navíc **finalizuje `elapsed_active_seconds`** (přičte běžící úsek) → `ActivitySummary.activeDurationSeconds` je poctivé (`GSP-011`) |

`SKIPPED` krok zůstává `SKIPPED` i po finalizaci dokončení (finalizace ho nepřepíše na NOT_STARTED); instance končí `PARTIALLY_COMPLETED`, pokud nejsou všechny kroky s výkony COMPLETED (C22 pravidlo trvá).

# 6. Časovače, obnova, determinismus

- Všechny časy se **odvozují z uložených značek** (`player_phase_started_at`, `last_resumed_at`, `elapsed_active_seconds`) a injektovaného `now` (clock provider) — UI má jen sekundový ticker pro překreslení; žádný stav časovače nežije jen v paměti (`GSP-005`).
- Přerušení aplikace (kill, restart) → R1-05 obnova session → průvodce se otevře na stejném kroku/sadě, běžící odpočet pokračuje ze správného zbytku (nebo 0), pauza zůstává pauzou (`GSP-007`).
- Konec odpočtu je **signál** (vizuální + volitelně haptický/zvukový prostý signál), ne mutace: uživatel potvrdí „Další" (`GSP-006`). Skutečná doba DURATION sady = `min(plán, now − ukotvení)` při potvrzení, nebo hodnota zadaná uživatelem.

# 7. Vztah k dokončení, statistikám a quick-complete

- Dokončení z průvodce = táž C22 operace jako dosud (feedback dialog, summary, statistiky C23) — žádné vymyšlené hodnoty; jen to, co uživatel odklikl/zadal (`GSP-010`).
- Quick-complete (C50) zůstává zkrácenou evidencí bez průvodce.
- Průvodce funguje pro seed, ruční i AI v1 tréninky (kroky bez sekcí/kódu/pauz se vedou jak jsou; bez popisu = poctivě „bez popisu", C51 EXC-009).

# 8. UI minimum (obrazovka aktivní session)

Průvodce je **primární horní část** obrazovky aktivní session (existující cesta Start i obnova R1-05 vedou sem beze změny trasy): karta aktuálního kroku (sekce, název, ilustrace C54 později, popis + cue, předpis a sada X/Y, plán vs. skutečnost), velký časovač/odpočet ve fázi, hlavní akce podle fáze (Start sady / Hotovo / Další / Přeskočit), předchozí/další krok, pauza/pokračovat, uplynulý čas, přehled postupu (kroky × sady). Stávající plochý zápis výkonů zůstává **pod** průvodcem (rozbalitelný seznam) a tlačítko dokončení beze změny.

# 9. Invarianty

- **GSP-001** Průvodce nezavádí novou write cestu — každá mutace jde existujícími performance/session/completion operacemi.
- **GSP-002** Stav průvodce je odvozený z detailu, trackeru, session a `now` (čistá funkce); UI nedrží doménový stav.
- **GSP-003** Persistence průvodce = aditivní v17 sloupce session; historická data beze změny.
- **GSP-004** Stav průvodce je zařízení-lokální pomocník obnovy; není doménový fakt a sync ho nevyžaduje.
- **GSP-005** Časy výhradně z uložených značek + injektovaného `now`; ticker jen překresluje.
- **GSP-006** Konec odpočtu nemění data; posun je explicitní akce uživatele.
- **GSP-007** Obnovitelnost: po přerušení stejný krok/sada/fáze/zbytek; pauza zůstává pauzou (R1-05).
- **GSP-008** Přeskočení = poctivý `SKIPPED` (krok i jeho sady), nikdy COMPLETED; dokončení ho nepřepíše.
- **GSP-009** Pauza/pokračovat mění jen session (status, značky, elapsed) a posouvá ukotvení fáze o délku pauzy.
- **GSP-010** Žádné vymyšlené výkony — jen zadané/odkliknuté; DURATION skutečnost = min(plán, měřený čas) nebo zadaná.
- **GSP-011** `elapsed_active_seconds` se finalizuje při dokončení → poctivý `activeDurationSeconds` v summary.
- **GSP-012** Průvodce vede i tréninky bez katalogu/sekcí/pauz (seed, ruční, AI v1) — degraduje poctivě, nikdy nefunguje „jen pro v2".
- **GSP-013** Trasa aktivní session i R1-05 obnova beze změny; quick-complete beze změny.
- **GSP-014** Evidence dle §10; časovače testované deterministicky s fake clock; flaky ≠ zelený důkaz.

# 10. Testy a evidence (R8-03)

- Unit `buildGuidedState`: pozice z `active_step_id`/první nedokončené; fáze a `remainingSeconds` z ukotvení + `now` (běžící, doběhlý = 0, po pauze posunutý); DONE; souhrny; kroky bez výkonových řádků (REST) a bez sekcí (v1).
- Repository: v17 migrace aditivní; `startSet/completeSet(rest)/finishPhase/goToStep/startRestStep/skipStep/pause/resume` — stavy sloupců, `IN_PROGRESS`/`SKIPPED`, ukotvení posunuté o pauzu; dokončení finalizuje elapsed a zachová SKIPPED; typované výsledky mimo aktivní session.
- Widget: průvodce na seed tréninku (start sady → hotovo → odpočet → další → přeskočit → pauza/pokračovat → dokončení přes existující dialog); po restartu (nový ProviderScope nad touž DB) stejný krok a zbytek odpočtu.
- R1/R7 E2E zůstávají zelené (obnova a dokončení beze změny trasy).

# 11. Ready podmínka

`R8-03` je `READY`, jakmile tento dokument existuje (verze 0.1). Definition of Done: §10 zelená, R1–R7 kritické E2E zelené, analyze čistý, `DOCUMENTATION_STATUS.md` aktualizován.
