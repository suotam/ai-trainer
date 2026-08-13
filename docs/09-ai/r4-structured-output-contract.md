# AI Trainer – R4 Structured Output Schema & Validation Contract (C28)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-structured-output-contract.md`
**Vlastník:** Domain + Backend + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C28 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-ai-gateway-contract.md` (C25), `docs/09-ai/r4-prompt-audit-contract.md` (C26), `docs/06-domain/r3-manual-plan-contract.md` (C20 — cílový tvar workoutů), `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-03, C29 (proposal nese validovaný payload), C30 (execution mapuje na C20 vstupy), C32 (eval validuje proti schématu)
**Vlastněné pojmy nebo kontrakty:** verzované schéma `plan-proposal-schema-v1`, deterministická extrakce a validace, chování při nevalidním výstupu a pravidla `SOV-001` až `SOV-015`

---

# 1. Purpose

Model smí produkovat **výhradně strukturovaný výstup dle verzovaného schématu**; vše ostatní je typované selhání (R4P-003, §8.3 release scope). Tento kontrakt definuje P0 schéma návrhu plánu a **deterministickou dvojí validaci** (server před vrácením klientovi, klient před persistencí — defense in depth).

**Blocking pro `R4-03`.**

# 2. Schéma `plan-proposal-schema-v1`

Kanonický JSON (povinná pole tučně):

- **`summary`** — neprázdný string ≤ 2000 znaků (vysvětlení návrhu jako celku),
- **`planTitle`** — neprázdný string ≤ 120 znaků,
- **`workouts`** — pole 1–14 položek:
  - **`title`** ≤ 120, **`workoutType`** ∈ C20 §5.2 (`STRENGTH/ENDURANCE/MOBILITY/TECHNIQUE/GENERAL`),
  - **`dayOffset`** — celé číslo 0–27 (relativní den od data žádosti; absolutní datum mapuje deterministicky až execution C30 — model nikdy nepracuje s kalendářními daty),
  - **`reason`** — neprázdný string ≤ 500 (vysvětlitelnost per workout, §8.2),
  - `plannedDurationMinutes` — volitelné 1–600,
  - `exercises` — volitelné pole 0–20: **`title`** ≤ 120, **`sets`** 1–20, **`repetitions`** 1–100, `weightKg` volitelné 0–500.

# 3. Extrakce a validační pravidla

1. **Extrakce:** z raw textu se deterministicky odstraní případné ```json fence obaly; výsledek musí být jediný parsovatelný JSON objekt — jinak `INVALID_OUTPUT`.
2. **Neznámá pole se ignorují** (odstraní se; model smí být upovídaný v polích, ne ve struktuře); chybějící povinná pole, špatné typy či meze = `INVALID_OUTPUT`.
3. **Kanonizace:** validátor vrací kanonický payload (jen schválená pole, stabilní pořadí) — ten se vrací klientovi, persistuje (C29) a provádí (C30).
4. **Duplicitní `dayOffset` je dovolen** (více workoutů v jeden den); pořadí workoutů se zachovává.
5. Validace je **čistá funkce** — bez sítě, bez vedlejších efektů, identický vstup → identický výsledek.

# 4. Chování při nevalidním výstupu

Server: typovaná chyba `AI_INVALID_OUTPUT` (nikdy 200, nikdy „oprava" výstupu, žádný auto-retry v P0) + audit `AiProposalFailed`/`INVALID_OUTPUT` (C26). Klient: nevalidní odpověď (obrana do hloubky) se nepersistuje a je typovaný stav. Uživateli se nabízí ruční cesta (RSR-005).

# 5. Invarianty (`SOV`)

- **SOV-001 — Schéma je verzované** (`plan-proposal-schema-v1`); změna tvaru = nová verze; verze součástí odpovědi i návrhu (PAA-005).
- **SOV-002 — Jen schéma se provádí.** Cokoli mimo kanonický payload neexistuje pro další vrstvy.
- **SOV-003 — Dvojí validace.** Server před vrácením, klient před persistencí; obě strany implementují tatáž pravidla §2–§3.
- **SOV-004 — Deterministická čistá validace** bez sítě a vedlejších efektů.
- **SOV-005 — Nevalidní ≠ oprava.** Výstup se nikdy neopravuje ani nedoplňuje; selhání je typované (§4).
- **SOV-006 — Relativní dny.** Model pracuje s `dayOffset`; kalendářní mapování vlastní C30.
- **SOV-007 — Vysvětlitelnost povinná.** `summary` + `reason` per workout jsou povinné.
- **SOV-008 — Meze závazné** (počty, délky, rozsahy §2); překročení = `INVALID_OUTPUT`.
- **SOV-009 — Neznámá pole se zahazují**, nikdy neprovádějí.
- **SOV-010 — Kanonizace.** Další vrstvy pracují výhradně s kanonickým payloadem.
- **SOV-011 — Fence extrakce deterministická** (§3.1); jiný obal = selhání.
- **SOV-012 — Bez auto-retry** na nevalidní výstup v P0 (uživatel může požádat znovu).
- **SOV-013 — Audit selhání** dle C26 s druhem `INVALID_OUTPUT`.
- **SOV-014 — Kompatibilita s C20.** Typy a meze jsou podmnožinou proveditelných C20 vstupů — validní návrh je vždy proveditelný.
- **SOV-015 — Evidence.** Testy obou validátorů: validní/nevalidní fixtures (chybějící pole, meze, fence, ne-JSON, neznámá pole), determinismus; flaky ≠ zelený důkaz.

# 6. Ready condition

C28 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C29 činí **`R4-03` `READY`**.
