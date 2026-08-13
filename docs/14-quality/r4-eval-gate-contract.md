# AI Trainer – R4 Eval Dataset & Release Gate Contract (C32)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/14-quality/r4-eval-gate-contract.md`
**Vlastník:** Quality + Domain (+ Backend/Mobile harness)
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C32 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-structured-output-contract.md` (C28), `docs/11-security/r4-ai-safety-contract.md` (C31), `docs/14-quality/test-strategy.md`, `docs/13-delivery/r4-vertical-slice-plan.md §12` (živý provider mimo CI)
**Navazující dokumenty:** implementace R4-07, R4-08 (Exit Review cituje gate), budoucí rozšiřování datasetu z manuálních smoke běhů
**Vlastněné pojmy nebo kontrakty:** eval dataset, deterministický eval harness, gate kritéria, postup rozšiřování a pravidla `EVG-001` až `EVG-015`

---

# 1. Purpose

Release gate potřebuje **opakovatelný důkaz, že AI vrstva drží své kontrakty** — bez živého providera. Eval dataset je korpus reprezentativních výstupů modelu (validní, hraniční, nevalidní, adversariální) s očekávanými verdikty a vlastnostmi; harness je deterministický běh obou validátorů nad tímto korpusem v běžné CI test suite.

**Poctivý scope:** gate ověřuje **deterministickou kontraktní vrstvu** (validace, kanonizace, bezpečnostní vlastnosti, konzistence dvojí validace) — ne kvalitu úsudku modelu. Kvalita modelu se dokazuje řízeným manuálním smoke během (plán §12); jeho zachycené výstupy se stávají novými fixtures datasetu.

**Blocking pro `R4-07`.**

# 2. Dataset

- **Umístění:** `packages/contracts/eval/plan-proposal/*.json` — jediný sdílený zdroj; konzumují ho backendový i mobilní harness (vymáhá SOV-003 konzistenci dvojí validace).
- **Tvar case:** `{ "name", "description", "modelOutput" (raw text výstupu modelu), "expected": { "verdict": "VALID"|"INVALID", volitelně "workoutCount", "planTitle", "mustNotContain": [...] } }`.
- **Minimální pokrytí kategorií:** validní základ, hraniční meze (max hodnoty), fence obal, neznámá pole, injektovaná pole, volný text, chybějící `reason`, meze mimo rozsah, neznámý typ, prázdné workouts — dataset má **≥ 10 cases** a nikdy se tiše nezmenšuje.

# 3. Harness

- **Backend** (`EvalGateTest`): načte všechny cases, spustí `PlanProposalValidator`, verdikt musí sedět; u `VALID` navíc kvalitativní vlastnosti §4. Součást běžné test suite (= release gate, žádný zvláštní pipeline krok).
- **Mobil** (`eval_gate_consistency_test`): tentýž dataset přes klientský validátor — pro cases, jejichž `modelOutput` je přímo JSON payload (fence extrakce je serverová záležitost), musí klientský verdikt souhlasit s očekáváním; minimálně 8 cases musí být klientsky vyhodnotitelných.
- **Determinismus:** žádná síť, žádný živý provider, žádný čas/náhoda; stejný dataset → identický výsledek.

# 4. Gate kritéria

1. **100% shoda verdiktů** — každý case musí dopadnout přesně dle `expected.verdict`; jediný nesoulad = červený gate.
2. **Kvalitativní vlastnosti validních návrhů:** každý workout má neprázdný `reason` (vysvětlitelnost), `dayOffset` 0–27, počet workoutů 1–14; kanonický výstup obsahuje jen schválená pole a nikdy řetězce z `mustNotContain`.
3. **Konzistence dvojí validace:** klientský verdikt = serverový verdikt na sdílených cases.
4. **Velikost datasetu ≥ 10** (a klientsky vyhodnotitelných ≥ 8) — ochrana proti tichému vyprázdnění gate.
5. **Flaky ≠ zelený** — gate nesmí být retryován ani skipnut; skip/ignore je červený gate.

# 5. Postup rozšiřování datasetu

1. Nový case = nový JSON soubor v adresáři (harness auto-discovery, žádná registrace v kódu).
2. Zdroje nových cases: manuální smoke běhy živého providera (výstup se **redakovaně** uloží jako fixture — nikdy s PII/reálným kontextem uživatele), incidenty nevalidních výstupů, nové hrany schématu.
3. Změna schématu (C28) = nová verze schématu a **revize celého datasetu** v témže PR; cases starého schématu se neupravují tiše.
4. Odstranění case vyžaduje zdůvodnění v PR (append-only preference).

# 6. Invarianty (`EVG`)

- **EVG-001 — Gate je závazný.** Eval běží v běžné CI test suite; červený eval = release blocker (R4P cross-slice 11).
- **EVG-002 — Deterministický.** Bez živého providera, sítě, času a náhody; opakovaný běh = identický výsledek.
- **EVG-003 — Jeden sdílený dataset** pro obě strany dvojí validace; žádné oddělené kopie.
- **EVG-004 — 100% shoda verdiktů** (§4.1); částečný úspěch neexistuje.
- **EVG-005 — Vysvětlitelnost je gate vlastnost.** Validní návrh bez `reason` u workoutu je červený gate.
- **EVG-006 — Adversariální cases povinné.** Dataset vždy obsahuje injection a volný text cases.
- **EVG-007 — Minimální velikost** dle §4.4; tichá redukce je červený gate.
- **EVG-008 — Kanonizace ověřená.** `mustNotContain` se kontroluje nad kanonickým výstupem.
- **EVG-009 — Konzistence dvojí validace** dle §4.3.
- **EVG-010 — Žádný skip/retry.** Skipnutý, ignorovaný nebo retryovaný eval není zelený důkaz.
- **EVG-011 — Scope poctivě přiznaný.** Gate nedokazuje kvalitu modelu (§1); tvrzení o kvalitě se opírá o smoke evidence plánu §12.
- **EVG-012 — Fixtures bez PII a secrets.** Redakce před uložením; sentinel markery dovolené.
- **EVG-013 — Rozšiřování dle §5**; schéma změna = revize datasetu v témže PR.
- **EVG-014 — Auto-discovery.** Harness načítá adresář; case nevyžaduje registraci v kódu.
- **EVG-015 — Evidence.** Zelený backend i mobilní harness běh v suite + dokumentovaný postup §5; flaky ≠ zelený důkaz.

# 7. Ready condition

C32 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R4-07` `READY`**.
