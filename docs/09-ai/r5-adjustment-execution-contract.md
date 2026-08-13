# AI Trainer – R5 Adjustment Execution Contract (C38)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r5-adjustment-execution-contract.md`
**Vlastník:** Domain + Mobile
**Kontraktní ID:** C38 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-changeset-execution-contract.md` (C30 — vzor), `docs/09-ai/r5-adjustment-schema-contract.md` (C37), `docs/06-domain/r3-calendar-change-contract.md` (C21), `docs/06-domain/r3-manual-plan-contract.md` (C20), `docs/06-domain/r5-safety-rules-contract.md` (C34), `docs/09-ai/r4-proposal-lifecycle-contract.md` (C29)
**Navazující dokumenty:** implementace R5-06, R5-08 (E2E)
**Vlastněné pojmy nebo kontrakty:** provedení potvrzeného adjustmentu, deterministická resolvace targetů, safety veto, atomicita a pravidla `AJE-001` až `AJE-015`

---

# 1. Purpose

Provedení potvrzeného adjustmentu je **jediné místo, kde se AI úprava stává doménovou změnou** — výhradně existujícími C21 operacemi (move/cancel/replace) a C20 `addWorkout`. Platí celý C30 zákon: atomicita, žádný částečný stav, typovaná selhání, explicitní retry. Nově přibývá **deterministická resolvace by-value targetů** a **safety veto**.

**Blocking pro `R5-06`.**

# 2. Spouštění a mapování dnů

- Vstup: `AIProposal` typu `ADJUSTMENT_PROPOSAL` ve stavu `CONFIRMED`/`EXECUTION_FAILED`; **potvrzení = souhlas s provedením** (C30 §2 vzor — execution v témže uživatelském kroku; tím se naplňuje ASJ-009: potvrzení nikdy neprovádí nic tiše, provádí až tento kontrakt).
- **Mapování dnů (vlastní tento kontrakt):** všechny dayOffsety (target, toDayOffset, ADD workout) jsou relativní k **lokálnímu datu vzniku návrhu** (`createdAt`) — to je týden, který model viděl v C36 kontextu; UTC aritmetika (C30 vzor).

# 3. Deterministická resolvace targetu

`target {dayOffset, title}` → instance vlastníka s `scheduledLocalDate = datum vzniku + dayOffset` a přesně shodným `title` (R1 read model):

- **0 kandidátů** → typované `TargetUnresolved` (týden se od návrhu změnil) — žádné hádání.
- **>1 kandidát** → rovněž `TargetUnresolved` (nejednoznačnost se nikdy neřeší odhadem).
- Resolvace nikdy nečte ID z payloadu (ASJ-004) a nikdy nevybírá „nejpodobnější" — přesná shoda, nebo typované selhání.

# 4. Safety veto a překlad operací

- **Safety veto (R5P-001, SFR-003):** pokud aktuální C34 stav je `DO_NOT_RECOMMEND_ACTIVITY` a adjustment obsahuje zátěž přidávající operace (`ADD`/`REPLACE`), provedení je typovaně odmítnuto (`SafetyConflict`) — deterministicky, před jakoukoli změnou. `MOVE`/`CANCEL` (konzervativní směr) veto nemají. AI veto nikdy neobchází; řešení je na uživateli (nový check-in, odmítnutí návrhu, ruční cesta).
- Překlad: `MOVE` → C21 `moveWorkout` (cíl = vznik + toDayOffset); `CANCEL` → C21 `cancelWorkout`; `REPLACE` → C21 `replaceWorkout` (datum náhrady = datum targetu); `ADD` → C20 `addWorkout` do jediného ACTIVE plánu vlastníka (bez ACTIVE plánu = typované `OperationRejected`).
- Doménové odmítnutí kterékoli operace (C21 guardy — dokončený/zahájený workout apod.) = typované `OperationRejected`; **žádná operace se nepřeskakuje** — adjustment je celek.

# 5. Atomicita a výsledek

Celé provedení (všechny operace + přechod stavu) v jedné transakci; selhání kterékoli části = rollback všeho (CSE-003 vzor). Úspěch → `EXECUTED` (reference: ID ACTIVE plánu, pokud vznikl obsah přes `ADD`; jinak bez reference — **evidence adjustmentu je C21 append-only kalendářní evidence + návrh sám**; APL-010 reference plánu je specifická pro PLAN_PROPOSAL). Selhání → `EXECUTION_FAILED` po rollbacku; retry výhradně explicitní (CSE-007).

# 6. Invarianty (`AJE`)

- **AJE-001 — Jediná cesta změny = C21/C20 operace**; žádný přímý zápis (CSE-001 vzor).
- **AJE-002 — Doménová pravidla beze změny.** C21 guardy (CAL-001/002) platí i pro AI; odmítnutí je typované selhání, ne výjimka z pravidla.
- **AJE-003 — Atomicita** dle §5; žádný částečný stav, žádné přeskakování operací.
- **AJE-004 — Deterministická resolvace** dle §3; nejednoznačnost nebo nezvěstný target = typované selhání, nikdy odhad.
- **AJE-005 — Safety veto deterministicky** dle §4; AI ho nemůže obejít ani přemluvit.
- **AJE-006 — Dny relativně ke vzniku návrhu** (§2); nikde jinde se nepřepočítávají.
- **AJE-007 — Append-only evidence.** Každá provedená operace zanechá C21 kalendářní evidenci (CAL-003); provenance dohledatelná přes návrh (typ+payload+stav).
- **AJE-008 — Typovaná selhání**: `TargetUnresolved` / `SafetyConflict` / `OperationRejected` / `InvalidState` / `NotFound` — nikdy raw výjimka, nikdy předstíraný úspěch.
- **AJE-009 — Terminalita a retry** dle C29/C30: `EXECUTED` konečné; po `EXECUTION_FAILED` jen explicitní retry.
- **AJE-010 — Owner scoping** (CSE-011 vzor).
- **AJE-011 — Žádná interpretace navíc** (CSE-012): provede se přesně kanonický payload.
- **AJE-012 — Selhání nedegraduje ruční cesty** (CSE-013); C21 operace zůstávají plně dostupné ručně.
- **AJE-013 — Bez sítě a bez AI** (CSE-014).
- **AJE-014 — Vzniklá/změněná data žijí běžným lifecycle** (CSE-009): Today, historie změn, sync existujícím push.
- **AJE-015 — Evidence.** Testy: happy path všech čtyř operací (datumy, evidence, EXECUTED), rollback (doménové odmítnutí uprostřed, target unresolved), safety veto (ADD blokován při STOP; CANCEL projde), terminalita, widget potvrzení → provedení; flaky ≠ zelený důkaz.

# 7. Ready condition

C38 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-06` `READY`**.
