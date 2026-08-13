# AI Trainer – R4 ChangeSet Execution Contract (C30)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-changeset-execution-contract.md`
**Vlastník:** Domain (ai-and-change-model §18–§21) + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C30 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-proposal-lifecycle-contract.md` (C29), `docs/09-ai/r4-structured-output-contract.md` (C28), `docs/06-domain/r3-manual-plan-contract.md` (C20), `docs/06-domain/r3-calendar-change-contract.md` (C21), `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-05, C31 (safety hardening), R4-08 (E2E evidence)
**Vlastněné pojmy nebo kontrakty:** provedení potvrzeného návrhu, mapování `dayOffset` → kalendářní datum, provenance `AI_PROPOSAL`, atomicita/rollback a pravidla `CSE-001` až `CSE-015`

---

# 1. Purpose

Provedení (execution) je **jediné místo, kde se AI návrh stává doménovou změnou** — a děje se výhradně existujícími doménovými cestami (C20). AI nikdy nezapisuje doménová data přímo (R4P-001); execution je deterministický překlad kanonického C28 payloadu na C20 operace pod plnou doménovou validací.

**Blocking pro `R4-05`.**

# 2. Vstup a spouštění

- Vstupem je výhradně `AIProposal` ve stavu `CONFIRMED` nebo `EXECUTION_FAILED` (C29 §3); jiný stav je typovaný `InvalidState`.
- Execution spouští výhradně explicitní akce uživatele: potvrzení návrhu (potvrzení = souhlas s provedením, APL-005) nebo explicitní opakování po `EXECUTION_FAILED` (APL-009 — nikdy tichý auto-retry).
- Execution je čistě lokální operace (offline schopná, APL-013) — síť není podmínkou.

# 3. Překlad payloadu (deterministický)

- `planTitle` → `createPlan` (C20); `summary`/`reason` se do doménových dat nepřenášejí (zůstávají na návrhu — provenance je návrh sám).
- Každý `workouts[]` prvek → `addWorkout` do vzniklého plánu (C20 §5.1): title, workoutType, volitelná délka, cviky se sets/reps/váhou.
- **Mapování `dayOffset` → datum (vlastní tento kontrakt):** `scheduledLocalDate = lokální kalendářní datum okamžiku provedení + dayOffset dní`. Den 0 = den provedení v lokální časové zóně zařízení. Mapování je deterministické vůči hodinám (clock) a počítá se jednotně pro celý návrh z jednoho okamžiku.
- Payload je už kanonický (C28) — execution jej **nikdy neopravuje ani nedoplňuje**; nemapovatelný payload je typované selhání, nikdy částečné provedení.

# 4. Invarianty (`CSE`)

- **CSE-001 — Jediná cesta změny.** Doménová data vznikají výhradně voláním C20 operací (`createPlan`/`addWorkout`); žádný přímý zápis do workout/plan tabulek mimo ně.
- **CSE-002 — Doménová pravidla platí beze změny.** C20 validace a invarianty (MPC-002 jeden ACTIVE plán, MPC-004 atomická struktura workoutu) nejsou pro AI obcházeny ani oslabeny; konflikt ACTIVE plánu je typované selhání execution, ne výjimka z pravidla.
- **CSE-003 — Atomicita.** Celé provedení (plán + všechny workouty + přechod stavu návrhu) proběhne v jedné transakci; selhání kterékoli části = žádný částečný stav (rollback všeho).
- **CSE-004 — Provenance.** Vzniklý plán nese `origin = AI_PROPOSAL` (C20 rozšíření: `createPlan` přijímá origin, default `MANUAL`); návrh nese referenci vzniklého plánu (`executedPlanId`, APL-010). Provenance přežívá sync (origin je součástí plán payloadu).
- **CSE-005 — Výsledek je stav návrhu.** Úspěch → `EXECUTED` + reference (v téže transakci); selhání → `EXECUTION_FAILED` (zapsané po rollbacku) — auditovatelná append-only historie výsledku (APL-008).
- **CSE-006 — Typovaná selhání.** `NotFound`/`InvalidState`/`ActivePlanConflict`/`InvalidPayload` — nikdy raw výjimka do UI, nikdy předstíraný úspěch.
- **CSE-007 — Opakování jen explicitně.** Po `EXECUTION_FAILED` nový pokus výhradně akcí uživatele; úspěšný retry se chová identicky jako první provedení.
- **CSE-008 — dayOffset mapování dle §3.** Jediný vlastník mapování; nikde jinde se offset nepřepočítává.
- **CSE-009 — Vzniklá data žijí běžným R3/R1 lifecycle.** AI-vytvořený workout je plnohodnotná R1 struktura (sekce/kroky/sety přes C20), viditelná v Today/kalendáři, editovatelná C21 operacemi a synchronizovaná existujícím push — žádná zvláštní AI větev.
- **CSE-010 — Idempotence vůči stavu.** Opakované volání na `EXECUTED` návrhu je typovaný `InvalidState`; nikdy druhý plán z téhož návrhu.
- **CSE-011 — Owner scoping.** Execution jen nad návrhem aktuálního vlastníka; vzniklá data patří témuž vlastníkovi (C20 owner stamping).
- **CSE-012 — Žádná interpretace navíc.** Execution nepřidává workouty, nemění tituly, nedopočítává obsah — provede přesně kanonický payload.
- **CSE-013 — Selhání nedegraduje ruční cesty.** Po `EXECUTION_FAILED` je ruční plánování plně funkční (R4P-010); konflikt ACTIVE plánu řeší uživatel běžnou archivací (C20).
- **CSE-014 — Bez sítě a bez AI.** Execution nevolá model ani backend; je to čistě doménová lokální operace.
- **CSE-015 — Evidence.** Testy: úspěšné provedení (struktura, datumy, provenance, reference), atomicita/rollback (konflikt i nemapovatelný payload → žádný částečný stav), terminalita/idempotence, retry po archivaci, viditelnost v R1 read modelech a sync collection vzniklého plánu; flaky ≠ zelený důkaz.

# 5. Ready condition

C30 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R4-05` `READY`**.
