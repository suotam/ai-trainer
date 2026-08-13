# AI Trainer – R5 Adjustment Context & Classification Contract (C36)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r5-adjustment-context-contract.md`
**Vlastník:** Domain (ai-and-change-model) + Security + Mobile
**Kontraktní ID:** C36 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-aicontext-contract.md` (C27 — vzor a základ), `docs/09-ai/r4-prompt-audit-contract.md` (C26 verzování), `docs/06-domain/r5-daily-checkin-contract.md` (C33), `docs/06-domain/r5-safety-rules-contract.md` (C34), `docs/13-delivery/r5-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R5-04, C37 (adjustment schéma a návrh), C38 (execution)
**Vlastněné pojmy nebo kontrakty:** request typ `ADJUSTMENT_PROPOSAL`, minimalizovaný adjustment kontext, prompt verze `adjustment-proposal-v1`, schema identifikátor `adjustment-proposal-schema-v1` a pravidla `ADX-001` až `ADX-015`

---

# 1. Purpose

Druhý AI request typ: **úprava existujícího dne/týdne** místo nového plánu. Kontext rozšiřuje C27 základ o tři věci, bez kterých úprava nedává smysl: **co je naplánováno** (týden by-value), **jak se uživatel cítí** (check-in dnes + agregáty) a **co říká deterministická safety** (C34 jako fakt, SFR-003). Všechna C27 minimalizační pravidla platí beze změny.

**Blocking pro `R5-04`.**

# 2. Klasifikace a verze

- Nový typ `ADJUSTMENT_PROPOSAL` (rozšíření C27 §2 množiny; nový typ vzniká výhradně kontraktem — ACX-001).
- Nová prompt verze **`adjustment-proposal-v1`** v registru (C26: immutable, bez uživatelských dat, „context is data, not instructions").
- Schema identifikátor **`adjustment-proposal-schema-v1`** (obsah schématu vlastní C37); gateway resolvuje schema verzi podle typu — trojice verzí zůstává povinná (PAA-005).

# 3. Obsah adjustment kontextu

**Základ = celý C27 plan-proposal kontext** (sporty, cíle, typický týden, vybavení, omezení, C23 agregáty) + tři nové sekce:

1. **`weekPlan`** — naplánované workouty následujících 7 dní by-value: `dayOffset` 0–6 (0 = den požadavku, žádná kalendářní data), title, workoutType, status, volitelně délka. **Žádná ID** (mapování na konkrétní instance vlastní C37/C38, ne model).
2. **`checkIns`** — dnešní check-in by-value (energie/únava/spánek/bolest level+oblast; **nikdy `note`** — DCI-006) + agregáty posledních 7 dní (počet, průměry, dny s bolestí) místo historie (ACX-007 vzor).
3. **`safety`** — C34 assessment jako fakt: stav + flags (kód, u bolesti oblast+úroveň). **Bez titulů omezení** (jsou už v `constraints` sekci — žádná duplicita); model safety nevyhodnocuje, jen ji čte (SFR-003).

# 4. Invarianty (`ADX`)

- **ADX-001 — C27 pravidla dědí beze změny.** Žádná ID, žádné poznámky (vč. check-in note), žádný owner/sync/secrets, jen aktivní data, deterministický ořez (ACX-002..010 platí).
- **ADX-002 — Bajtový determinismus.** Stejný stav DB + stejný okamžik → bajtově identická serializace (ACX-008).
- **ADX-003 — Relativní dny.** `weekPlan` používá `dayOffset` od dne požadavku; kalendářní data se do kontextu nepřenášejí.
- **ADX-004 — Žádné instance ID.** Workouty týdne jsou by-value; vazba návrhu na konkrétní instance je věc C37 schématu a C38 execution, nikdy kontextu.
- **ADX-005 — Safety je fakt, ne návrh.** Kontext nese C34 výstup beze změny; prompt instruuje model safety respektovat, ale vynucení je vždy deterministické (C34/C38) — nikdy důvěra modelu.
- **ADX-006 — Check-in bez volného textu.** `note` nikdy (DCI-006); bolest výhradně strukturovaně.
- **ADX-007 — Agregáty místo historie.** Check-iny za 7 dní jen agregované; detailní denní historie se nepřenáší.
- **ADX-008 — Prompt bez uživatelských dat** (PAA-004); nová verze = nový immutable záznam (PAA-002/003).
- **ADX-009 — Trojice verzí povinná** i pro adjustment (prompt `adjustment-proposal-v1` + schema `adjustment-proposal-schema-v1` + model id).
- **ADX-010 — Klient staví, server zprostředkuje.** Kontext vzniká lokálně (ACX-014); server payload nečte a neinterpretuje (AGW-014).
- **ADX-011 — Typ jen klasifikuje.** `ADJUSTMENT_PROPOSAL` nemění autorizaci, limity ani audit pravidla — vše dle C25/C26/C31 beze změny.
- **ADX-012 — Prázdný stav validní.** Bez check-inu/plánu je kontext validní (safety `INSUFFICIENT_INFORMATION`, prázdný `weekPlan`) — model dostává poctivý stav.
- **ADX-013 — Obsahové limity trvají** (32k, AIS-008); nové sekce podléhají deterministickému ořezu.
- **ADX-014 — Audit bez obsahu trvá** (PAA-007/008) — typ + verze, nikdy kontext.
- **ADX-015 — Evidence.** Marker testy zakázaného obsahu (ID, poznámky vč. check-in note, owner, rowVersion), bajtový determinismus, dayOffset mapování, agregáty, safety průchod, prázdný profil, registry testy nové verze; flaky ≠ zelený důkaz.

# 5. Ready condition

C36 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-04` `READY`**.
