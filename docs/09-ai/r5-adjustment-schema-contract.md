# AI Trainer – R5 Adjustment Structured Output & Proposal Contract (C37)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r5-adjustment-schema-contract.md`
**Vlastník:** Domain + Backend + Mobile
**Kontraktní ID:** C37 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-structured-output-contract.md` (C28 — vzor), `docs/09-ai/r5-adjustment-context-contract.md` (C36), `docs/09-ai/r4-proposal-lifecycle-contract.md` (C29), `docs/14-quality/r4-eval-gate-contract.md` (C32 §5), `docs/13-delivery/r5-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R5-05, C38 (execution operací)
**Vlastněné pojmy nebo kontrakty:** schéma `adjustment-proposal-schema-v1`, endpoint rozhodnutí, dvojí validace adjustmentu, AIProposal reuse a pravidla `ASJ-001` až `ASJ-015`

---

# 1. Purpose

Strukturovaný výstup pro úpravu existujícího týdne: **seznam operací** nad naplánovanými workouty s povinným vysvětlením každé operace. Platí celý C28 zákon: deterministická dvojí validace, kanonizace, nevalidní výstup se nikdy neprovede, žádná oprava.

**Blocking pro `R5-05`.**

# 2. Endpoint rozhodnutí

**Jediný AI endpoint trvá (AGW-001):** `POST /api/v1/ai/plan-proposals` se rozšiřuje o volitelné pole `requestType` (`PLAN_PROPOSAL` default | `ADJUSTMENT_PROPOSAL`); neznámý typ = `INVALID_REQUEST` (400). Server volí prompt, schema verzi (C36 §2) i validátor podle typu; auth/rate limity/audit beze změny (ADX-011).

# 3. Schéma `adjustment-proposal-schema-v1`

```json
{
  "summary": "string 1–2000",
  "operations": [ 1–10 operací ]
}
```

Operace: `{ "operation": MOVE|CANCEL|REPLACE|ADD, "reason": "string 1–500 (povinné)", ... }`:

| Operace | Povinná pole | Zakázaná pole |
|---|---|---|
| `MOVE` | `target`, `toDayOffset` 0–27 | `workout` |
| `CANCEL` | `target` | `workout`, `toDayOffset` |
| `REPLACE` | `target`, `workout` (bez `dayOffset` — den dědí z targetu) | `toDayOffset` |
| `ADD` | `workout` (s `dayOffset` 0–27) | `target`, `toDayOffset` |

- **`target`** = `{ "dayOffset": 0–6, "title": "string 1–120" }` — odkaz na workout z C36 `weekPlan` **by-value** (žádná ID; deterministickou resolvaci na instanci vlastní C38).
- **`workout`** = C28 workout tvar bez per-workout `reason` (vysvětlení nese operace): title 1–120, workoutType z C20 množiny, volitelná délka 1–600, volitelné cviky (C28 meze); `dayOffset` dle tabulky.
- Neznámá pole se zahazují (kanonizace); porušení tabulky = nevalidní výstup, nikdy oprava (SOV-005 vzor).

# 4. Dvojí validace a persistence

- **Server** `AdjustmentProposalValidator` (fence extrakce, meze, kanonizace) → nevalidní = `AI_INVALID_OUTPUT` (502) + audit `INVALID_OUTPUT`; **klient** zrcadlový validátor před persistencí (SOV-003).
- Persistence = **existující `AIProposal`** (C29 beze změny): `requestType = ADJUSTMENT_PROPOSAL`, kanonický payload, trojice verzí (`adjustment-proposal-v1` + `adjustment-proposal-schema-v1` + model id), stavy/expirace/attach identické.
- **Review UI** zobrazuje operace s dopady (co se přesune/zruší/nahradí/přidá, kam a proč); rozhodnutí výhradně uživatel (APL-005); **potvrzený adjustment zůstává `CONFIRMED` do C38** — execution je následující slice, potvrzení nikdy neprovádí nic tiše.

# 5. Invarianty (`ASJ`)

- **ASJ-001 — C28 zákon platí celý.** Deterministická validace, kanonizace, žádná oprava, nevalidní se nikdy neprovede, text ≠ změna.
- **ASJ-002 — Reason per operace povinný.** Operace bez vysvětlení je nevalidní (vysvětlitelnost je gate vlastnost).
- **ASJ-003 — Tvarová tabulka §3 přesně.** Chybějící/zakázaná pole dle operace = nevalidní výstup.
- **ASJ-004 — Target by-value.** Odkaz výhradně dayOffset+title z kontextového týdne; žádná ID (ADX-004); resolvace instance je C38.
- **ASJ-005 — Meze:** operations 1–10, dayOffsety a texty dle §3; mimo meze = nevalidní.
- **ASJ-006 — Jediný endpoint** dle §2; typ v requestu, neznámý typ typovaně odmítnut.
- **ASJ-007 — Trojice verzí povinná** (adjustment prompt + schema + model, ADX-009).
- **ASJ-008 — AIProposal reuse beze změny.** Žádná nová tabulka ani lifecycle; C29 stavy/expirace/attach platí.
- **ASJ-009 — Potvrzení ≠ provedení.** `CONFIRMED` adjustment čeká na C38; nikdy tichá změna při potvrzení.
- **ASJ-010 — Dvojí validace povinná** (server před vrácením, klient před persistencí); nevalidní odpověď se nepersistuje (APL-002).
- **ASJ-011 — Safety se nevaliduje důvěrou.** Validátor nekontroluje „rozumnost" vůči safety (to je C38/uživatel); kontroluje výhradně tvar a meze.
- **ASJ-012 — Bez auto-retry** (SOV-012) a obsahové limity trvají (AIS-008).
- **ASJ-013 — Eval rozšíření povinné.** Sdílený dataset dostává adjustment cases (C32 §5, vlastní adresář `packages/contracts/eval/adjustment-proposal/`), oba harnessy je vyhodnocují; minimum 6 cases vč. adversariálních.
- **ASJ-014 — Review s dopady.** UI zobrazuje operace srozumitelně (typ, cíl, kam, proč); odmítnutí viditelné (APL-006).
- **ASJ-015 — Evidence.** Validator fixtures obou stran (tvarová tabulka, meze, kanonizace, injection), endpoint typ testy, persistence s trojicí verzí, review widget testy, eval gate rozšířen; flaky ≠ zelený důkaz.

# 6. Ready condition

C37 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-05` `READY`**.
