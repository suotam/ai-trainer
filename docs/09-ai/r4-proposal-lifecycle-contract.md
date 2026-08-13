# AI Trainer – R4 AIProposal Lifecycle Contract (C29)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-proposal-lifecycle-contract.md`
**Vlastník:** Domain (ai-and-change-model §12–§17) + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C29 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/ai-and-change-model.md` (§12 AIProposal, §14 status, §17 decision), `docs/09-ai/r4-structured-output-contract.md` (C28), `docs/09-ai/r4-prompt-audit-contract.md` (C26), `docs/12-data/r3-mobile-schema-migration.md` (C16 vzor), `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-03/R4-04, C30 (execution mění stav na EXECUTED/EXECUTION_FAILED)
**Vlastněné pojmy nebo kontrakty:** lokální persistence `AIProposal`, P0 stavy a přechody, expirace, provenance verzí a pravidla `APL-001` až `APL-015`

---

# 1. Purpose

`AIProposal` je **reviewovatelný lokální objekt** — most mezi výstupem modelu a doménovou změnou. Nikdy se neprovádí sám (R4P-001); nese kanonický payload (C28), povinnou trojici verzí (C26) a explicitní lifecycle s viditelným odmítnutím (RSR-012).

**Blocking pro `R4-03` (persistence) a `R4-04` (rozhodnutí).**

# 2. Persistence

Nová lokální tabulka `local_ai_proposals` (mobilní schema bump dle C16 pravidel): client-generated ID, request typ, **kanonický payload** (serializovaný, C28), summary (denormalizované pro seznam), **prompt/schema/model verze** (povinné, PAA-005), status, časy (vytvořeno/rozhodnuto), reference provedeného plánu (plní C30), owner/sync metadata dle C16 vzoru. **Návrhy se v P0 nesynchronizují** (nejsou v C24 registru — device-local rozhodovací artefakt; sync je budoucí rozhodnutí); **attach bezpodmínečný** v témže slice (R3M-006 vzor).

# 3. Stavy a přechody (P0 podmnožina modelu §14)

`PROPOSED` →(uživatel)→ `CONFIRMED` | `REJECTED`; `CONFIRMED` →(C30 execution)→ `EXECUTED` | `EXECUTION_FAILED`; `PROPOSED` →(pokus o potvrzení po 7 dnech)→ `EXPIRED`.

- `REJECTED`, `EXECUTED`, `EXPIRED` jsou terminální; `EXECUTION_FAILED` dovoluje nový pokus o execution (C30), nikdy tichý auto-retry.
- Expirace se vyhodnocuje **při rozhodování** (žádný background job): potvrzení návrhu staršího 7 dní → `EXPIRED` + typovaný výsledek.
- Žádné mazání — historie návrhů a rozhodnutí je append-only interpretace (provenance).

# 4. Invarianty (`APL`)

- **APL-001 — Návrh nikdy nejedná.** Persistence návrhu nemění žádná doménová data; jediná cesta je C30.
- **APL-002 — Jen validovaný payload.** Persistuje se výhradně kanonický C28 payload; nevalidní výstup se nepersistuje.
- **APL-003 — Trojice verzí povinná** (prompt/schema/model, PAA-005); bez nich je návrh nevalidní.
- **APL-004 — Explicitní stavy** dle §3; nevalidní přechod je typovaný výsledek.
- **APL-005 — Rozhodnutí jen uživatel.** `CONFIRMED`/`REJECTED` vzniká výhradně explicitní akcí (R4P-007); nikdy automaticky.
- **APL-006 — Odmítnutí viditelné.** `REJECTED` je zachovaný stav, ne smazání (RSR-012).
- **APL-007 — Expirace při rozhodnutí** (7 dní, §3); žádné background joby.
- **APL-008 — Žádné mazání.** Návrhy jsou append-only historie.
- **APL-009 — Terminalita.** `REJECTED`/`EXECUTED`/`EXPIRED` konečné; `EXECUTION_FAILED` → nový pokus jen explicitně.
- **APL-010 — Execution reference.** `EXECUTED` nese referenci vzniklého plánu (C30); bez ní přechod neplatí.
- **APL-011 — Owner scoping + attach.** Návrhy patří vlastníkovi; attach bezpodmínečný; v P0 mimo sync registr (vědomé rozhodnutí).
- **APL-012 — Deterministické read modely.** Seznam řazen časem vytvoření sestupně; poctivý empty stav.
- **APL-013 — Offline review.** Uložený návrh je plně reviewovatelný offline (síť jen pro vznik).
- **APL-014 — Bez PII navíc.** Návrh nese jen payload + metadata; nikdy kontext requestu.
- **APL-015 — Evidence.** Testy: persistence s verzemi, přechody vč. expirace a terminality, attach, determinismus řazení; flaky ≠ zelený důkaz.

# 5. Ready condition

C29 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C28 činí **`R4-03` `READY`** (a pokrývá rozhodovací část `R4-04`).
