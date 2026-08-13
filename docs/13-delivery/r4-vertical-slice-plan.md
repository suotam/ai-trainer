# AI Trainer – R4 AI Plan Proposal Vertical Slice Plan

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r4-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-08-14  
**Navazuje na:** `docs/02-product/release-scope.md` (§8, §10), `docs/06-domain/ai-and-change-model.md`, `docs/09-ai/ai-architecture.md`, `docs/10-integrations/integration-architecture.md`, `docs/11-security/security-architecture.md`, `docs/06-domain/training-plan-model.md`, kontrakty C16–C24 (R3), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/11-security/r2-audit-event-contract.md` (C14), `docs/13-delivery/definition-of-ready-and-done.md`, `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R4 detailní kontrakty (viz §7.1), ADR AI providera a gateway, OpenAPI rozšíření, implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R4, slice boundaries R4, R4 blocking contract map, evidence gates R4, R4 backlog decomposition, R4 Exit Review a pravidla `R4P-001` až `R4P-015`

---

# 1. Účel

Tento dokument je kanonický implementační plán pro celé **R4 – AI Plan Proposal Slice**: AI poprvé vstupuje do produktu — vytváří **vysvětlitelný strukturovaný návrh plánu**, ale doménová změna nastane **pouze po deterministické validaci a uživatelském potvrzení** (release scope §8, `RSR-006`). Převádí hrubý scope na vertikální plán: hodnotu, pořadí slices `R4-01…`, blocking contract map, evidence gates, non-goals a R4 Exit Review.

Dokument **nedefinuje** prompty, JSON schémata, endpointy ani kód — ty vlastní navazující kontrakty (§7.1).

---

# 2. Delivery princip

- R4 se implementuje po slicech; kontrakt předchází implementaci; slice bez blokujících kontraktů je `NOT_READY`.
- **AI navrhuje, doména provádí (`RSR-006`)** — základní zákon celého R4. Zakázané zkratky release scope §8.3 jsou závazné pro každý slice: AI nikdy nezapisuje přímo do doménových tabulek; textová odpověď se nikdy nevydává za uloženou změnu; model nerozhoduje o autorizaci; nevalidní strukturovaný výstup se neprovede.
- **Manual path zůstává plnohodnotný (`RSR-005`)** — vše, co R4 umí navrhnout, jde dál udělat ručně (R3); selhání AI nesmí degradovat žádnou existující funkci.
- **Local-first zůstává invariantem** — R1–R3 toky nikdy nevyžadují AI ani síť; AI je volitelná online funkce s poctivým offline stavem.
- **Testy bez živého providera** — celá test suite běží deterministicky proti fake/replay provideru; živý provider není podmínkou CI (viz §12).

---

# 3. Celkové pořadí

```text
R4-01  Backend AI Gateway Baseline (provider abstraction, prompt registry, audit)   (backend)
R4-02  AIContext and Request Classification (minimalizovaný autorizovaný kontext)    (mobile)
R4-03  Structured Plan Proposal (endpoint + schema + deterministická validace)       (mobile + backend)
R4-04  Proposal Review (důvody, dopady, potvrzení/odmítnutí)                         (mobile)
R4-05  ChangeSet Execution Boundary (potvrzený návrh → doménové změny R3 cestami)    (mobile)
R4-06  AI Safety, Fallback and Abuse Protection (hardening)                          (mobile + backend)
R4-07  Eval Dataset and Release Gate                                                 (backend + quality)
R4-08  R4 Critical End-to-End Evidence and Exit Review                               (mobile + backend)
```

Princip řazení:

1. **Bezpečnostní a provider základ nejdřív** (R4-01) — provider za abstrakcí na serveru (klíče nikdy na klientu), verzované prompty, audit; bez něj nesmí vzniknout žádné AI volání.
2. **Kontext před návrhem** (R4-02) — minimalizovaný AIContext je vstupní disciplína; klient ho staví z lokálních dat (žádné serverové čtení JSONB payloadů — C6 §8.4 zůstává).
3. **Návrh** (R4-03) — strukturovaný výstup dle schématu + deterministická validace na obou stranách; `AIProposal` je lokální reviewovatelný objekt.
4. **Review** (R4-04) a **provedení** (R4-05) — potvrzení uživatelem a ChangeSet výhradně přes existující R3 doménové cesty (C20/C21), s AI provenance.
5. **Hardening** (R4-06), **eval gate** (R4-07), **E2E + Exit Review** (R4-08).

---

# 4. R4 value statement

**Hlavní hodnota R4:** Uživatel požádá o návrh tréninkového plánu; AI vytvoří **strukturovaný, vysvětlitelný návrh** postavený na jeho R3 profilu (sporty, cíle, dostupnost, vybavení, omezení); uživatel vidí důvody a dopady, návrh **potvrdí nebo odmítne**; potvrzený návrh se provede validovaným ChangeSetem přes existující ruční plánovací cesty — **bez ztráty manuální kontroly, bez tichých změn a bez závislosti R1–R3 na AI**.

Hodnota je dosažena, až když: (a) návrh vzniká z minimalizovaného autorizovaného kontextu, (b) nevalidní výstup modelu se nikdy neprovede, (c) provedená změna je běžný R3 plán se stejným lifecycle (kalendář, operace, sync) a AI provenance, (d) selhání modelu je bezpečný typovaný stav a (e) eval gate drží kvalitu deterministicky.

---

# 5. Scope a non-goals

## 5.1 R4 P0 scope (dle release scope §8.2)

AI request classification; autorizovaný a minimalizovaný AIContext; verzovaný prompt; provider abstraction; structured output schema; deterministická validace návrhu; AIProposal (lokální reviewovatelný objekt s lifecycle); zobrazení důvodů a dopadů; uživatelské potvrzení; ChangeSet execution boundary; audit výsledku; bezpečný fallback při selhání modelu; základní eval dataset a release gate.

## 5.2 Non-goals R4

- **AIConversation / chat UX** — P0 je jednorázový návrh, ne konverzace (model §5–§7 je budoucí směr),
- adaptivní denní doporučení, DailyCheckIn, únava/bolest (R5; medicínská hranice §9.3 release scope),
- AI tool-calling do domény (`AIToolInvocation`) — P0 má jediný výstup: strukturovaný návrh plánu,
- automatické provedení bez potvrzení, vzdálené zásahy,
- serverové čtení/promoce R3 JSONB payloadů (kontext staví klient; C6 §8.4 beze změny),
- fine-tuning, více modelů, A/B, personalizace promptů,
- wearables/kalendáře/importy.

---

# 6. Architektonické principy R4

- **AI gateway na backendu**: provider klíče a volání výhradně server-side za abstrakcí (ADR, §7.1 C25); mobil komunikuje jen s vlastním backendem (auth session + rate limiting z R2).
- **Klient staví kontext**: AIContext vzniká lokálně z R3 dat (minimalizace, účelové omezení, žádné secrets/PII nad rámec účelu) a posílá se v requestu — server payloady nečte, jen zprostředkuje modelu.
- **Structured output only**: model vrací JSON dle verzovaného schématu; parsování/validace deterministická; text mimo schéma se zahazuje.
- **Dvojí validace**: server validuje schéma a bezpečnostní limity; klient validuje doménovou proveditelnost (proti C17–C21 pravidlům) před nabídnutím potvrzení.
- **Execution přes existující cesty**: ChangeSet volá výhradně C20/C21 repository operace (plán, workouty) — žádný nový zápisový kanál; provenance `source = AI_PROPOSAL` + reference návrhu.
- **Verzování a audit**: každý návrh nese prompt verzi, schema verzi a model identifikátor; audit AI událostí dle C14 vzoru bez PII/promptů v logu.
- **Determinismus testů**: fake provider + zaznamenané fixtures; eval dataset běží v CI bez sítě.

---

# 7. Prerequisites

1. R0–R3 uzavřené a mergnuté (splněno; Exit Reviews provedeny).
2. Existuje tento plán.
3. Pro každý slice existují blokující kontrakty (§7.1); do té doby `NOT_READY`.
4. **Provider ADR** (C25) je blocking pro R4-01 — do jeho přijetí žádné AI volání neexistuje.

## 7.1 R4 blocking contract map

Číslování navazuje na R3 (C16–C24):

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Minimum |
|---|---|---|---|---|---|
| C25 | AI provider ADR + gateway architecture | Architecture (ADR) + Backend | ADR v `docs/05-architecture/…` + `docs/09-ai/r4-ai-gateway-contract.md` | R4-01 | volba providera (nebo neutral boundary s odloženou volbou), server-side klíče, gateway hranice, timeouts, žádné klíče v repo |
| C26 | Prompt versioning & AI audit contract | Backend + Security (C14 rozšíření) | `docs/09-ai/r4-prompt-audit-contract.md` | R4-01 | prompt registry s verzemi, model id v odpovědi, AI audit události bez PII/prompt obsahu |
| C27 | AIContext & request classification contract | Domain (ai-and-change-model §8–§10) + Security | `docs/09-ai/r4-aicontext-contract.md` | R4-02 | typy požadavků (P0: PLAN_PROPOSAL), minimalizační pravidla per typ, autorizace kontextu, PII/secrets zákazy |
| C28 | Structured output schema & validation contract | Domain + Backend | `docs/09-ai/r4-structured-output-contract.md` | R4-03 | verzované JSON schéma návrhu plánu, deterministická validační pravidla (server + klient), chování při nevalidním výstupu |
| C29 | AIProposal lifecycle contract | Domain (ai-and-change-model §12–§17) + Mobile | `docs/09-ai/r4-proposal-lifecycle-contract.md` | R4-03/R4-04 | lokální persistence návrhu, stavy (navrženo/potvrzeno/odmítnuto/provedeno/selhalo), důvody a dopady, expirace |
| C30 | ChangeSet execution contract | Domain + Mobile | `docs/09-ai/r4-changeset-execution-contract.md` | R4-05 | povolené operace = C20/C21 cesty, atomicita, provenance AI, rollback při selhání, audit výsledku |
| C31 | AI safety & abuse contract | Security + Backend | `docs/11-security/r4-ai-safety-contract.md` | R4-06 (baseline pravidla už v R4-01) | fallback/timeout/typované chyby, rate limiting AI endpointů, prompt-injection postoj, obsahové limity |
| C32 | Eval dataset & release gate contract | Quality + Domain | `docs/14-quality/r4-eval-gate-contract.md` | R4-07 | základní eval dataset (fixtures), deterministický harness, gate kritéria, evidence |

---

# 8. Terminologická hranice

Dle `ai-and-change-model` a glossary: **AIContext** (minimalizovaný vstup) ≠ **AIProposal** (reviewovatelný návrh) ≠ **ChangeSet** (validované provedení) ≠ výsledný **TrainingPlan/WorkoutInstance** (běžná R3 doména). „Návrh" nikdy neznamená „změna"; „odesláno modelu" nikdy neznamená „uloženo". Prompt, schéma i model jsou verzované artefakty, ne implicitní detaily.

---

# 9. Detail každého slice

## 9.1 R4-01 – Backend AI Gateway Baseline
**Výsledek:** Backend má bezpečnou AI hranici: provider za abstrakcí (fake provider pro testy), verzovaný prompt registry, AI audit, timeouts a rate limiting — žádný produktový endpoint ještě nemusí existovat.
**Blocking:** C25, C26. **Non-goals:** kontext, návrhy, UI.
**Evidence:** Testcontainers/unit testy gateway (fake provider, verzování, audit bez PII), žádné klíče v repo, security-negative (bez session 401, rate limit).

## 9.2 R4-02 – AIContext and Request Classification
**Výsledek:** Mobil sestaví autorizovaný minimalizovaný AIContext typu `PLAN_PROPOSAL` z lokálních R3 dat (sporty, cíle, dostupnost, vybavení, omezení, agregované completion statistiky) — deterministicky a testovatelně, bez PII nad rámec účelu.
**Blocking:** C27. **Non-goals:** síťové volání, návrh.
**Evidence:** unit/persistence testy builderu (minimalizace — co NESMÍ obsahovat; determinismus; prázdný profil = validní kontext).

## 9.3 R4-03 – Structured Plan Proposal
**Výsledek:** `POST /api/v1/ai/plan-proposals`: kontext → gateway → model (fake v testech) → strukturovaný návrh dle verzovaného schématu; server i klient deterministicky validují; validní návrh se uloží lokálně jako `AIProposal`.
**Blocking:** C28, C29 (+ R4-01/02 Done). **Non-goals:** UI review, provedení.
**Evidence:** backend contract + validace testy (nevalidní výstup modelu → typovaná chyba, nikdy „úspěch"); mobilní testy uložení návrhu s prompt/schema/model verzí.

## 9.4 R4-04 – Proposal Review
**Výsledek:** Uživatel vidí návrh s důvody a dopady (co vznikne, kolik workoutů, které dny) a explicitně potvrdí či odmítne; odmítnutí je viditelný stav (RSR-012).
**Blocking:** C29. **Evidence:** widget testy (review, potvrzení, odmítnutí, expirace), accessibility základ.

## 9.5 R4-05 – ChangeSet Execution Boundary
**Výsledek:** Potvrzený návrh se provede atomicky výhradně přes C20/C21 cesty (vytvoření plánu/workoutů) s provenance `AI_PROPOSAL`; selhání = žádný částečný stav; výsledek auditován; vzniklá data žijí běžným R3 lifecycle (kalendář, operace, sync).
**Blocking:** C30. **Evidence:** atomicita/rollback testy, provenance, R1 flow na AI-vytvořeném workoutu, sync AI-vytvořených dat existujícím push.

## 9.6 R4-06 – AI Safety, Fallback and Abuse Protection
**Výsledek:** Selhání modelu/gateway/timeout je bezpečný typovaný stav (aplikace plně použitelná ručně); rate limiting AI endpointů; prompt-injection postoj (kontext data ≠ instrukce); žádné secrets/PII v promptech ani logu.
**Blocking:** C31. **Evidence:** security-negative testy, fallback testy, log-redaction.

## 9.7 R4-07 – Eval Dataset and Release Gate
**Výsledek:** Deterministický eval harness nad základním datasetem (fixtures kontextů + očekávané vlastnosti návrhů) běží jako release gate v CI — bez živého providera.
**Blocking:** C32. **Evidence:** eval běh v CI, gate kritéria, dokumentovaný postup rozšiřování datasetu.

## 9.8 R4-08 – R4 Critical End-to-End Evidence and Exit Review
**Výsledek:** Automatizovaný důkaz hlavní hodnoty R4 + R4 Exit Review.
**Blocking:** žádné nové. **Ready:** R4-01…07 Done.
**Evidence:** deterministický E2E (profil → žádost → návrh /fake provider/ → review → potvrzení → ChangeSet → workout v Today → R1 flow → sync; plus odmítnutí a fallback větve); Exit Review dle §13.

---

# 10. Cross-slice invariants

1. **AI nikdy nezapisuje do domény** — jediná cesta je potvrzený ChangeSet přes C20/C21 (RSR-006, §8.3).
2. **Nevalidní výstup se nikdy neprovede**; text ≠ změna.
3. **Model nerozhoduje o autorizaci** — auth/ownership výhradně R2 mechanismy.
4. **R1–R3 toky beze změny a bez AI závislosti**; selhání AI nedegraduje manuální cesty.
5. **Minimalizovaný kontext** — jen účelová data, nikdy secrets; PII jen v nutném rozsahu dle C27.
6. **Provider za abstrakcí, klíče jen na serveru, žádné klíče v repo**; testy bez živého providera.
7. **Verzování**: návrh nese prompt/schema/model verze; změna schématu = nová verze.
8. **Provenance a audit**: návrhy, rozhodnutí i provedení jsou dohledatelné append-only; AI-vytvořená data nesou AI provenance.
9. **Potvrzení povinné; odmítnutí viditelné** (RSR-012).
10. **Bezpečný fallback** — typované chyby, žádný infinite retry.
11. **Eval gate závazný** — flaky/degradovaný eval není zelený důkaz.
12. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

- **Unit**: context builder (minimalizace, determinismus), validace schématu, ChangeSet mapování.
- **Backend Testcontainers**: gateway s fake providerem, contract testy endpointu, security-negative (auth, rate limit, oversized context), audit.
- **Mobile**: proposal persistence/lifecycle, review widget testy, execution atomicita + provenance, fallback stavy.
- **Eval harness**: deterministické fixtures, gate kritéria (C32).
- **Kritická E2E (R4-08)**: celý cyklus vč. negativních větví (odmítnutí, nevalidní výstup, výpadek modelu).
- **Živý provider**: mimo CI; řízená manuální smoke evidence (viz §12).

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Konkrétní provider a model** — rozhodne C25 (ADR); do té doby neutral boundary + fake provider. Živé volání modelu není podmínkou žádného gate v CI; **manuální smoke s reálným providerem** je řízená evidence před uzavřením R4 (analogie emulátorového dluhu — pokud klíč/prostředí nebude dostupné, eviduje se otevřený dluh).
- **Přenesené dluhy R2/R3 trvají**: emulátorová runtime evidence, pull sync, DELETE, plán struktura sync — nejsou R4 blocker, ale R4-08 je znovu poctivě eviduje.
- **AIConversation/chat, tool-calling, R5 adaptace** — mimo R4 (§5.2).
- **Náklady/kvóty providera** — provozní politika mimo P0; C31 řeší jen abuse ochranu.

---

# 13. R4 Exit Review

R4 je dokončeno pouze pokud (doloženo testy, CI runy a evidencí):

- návrh vzniká z minimalizovaného autorizovaného kontextu (ověřeno testy „co kontext nesmí obsahovat"),
- strukturovaný výstup je validován deterministicky; nevalidní výstup se neprovede a je typovaným stavem,
- AIProposal má úplný lifecycle vč. viditelného odmítnutí a expirace,
- potvrzený návrh se provádí atomicky přes C20/C21 s AI provenance; žádný jiný zápisový kanál neexistuje,
- AI-vytvořený plán žije běžným R3 lifecycle (Today, R1 flow, operace, sync),
- selhání modelu je bezpečný fallback; manuální cesty nedegradované,
- prompty/schémata/model verzované; audit bez PII; žádné klíče v repo,
- rate limiting AI endpointů funkční,
- eval gate běží deterministicky v CI a prochází,
- R1, R2 i R3 kritické E2E zůstávají zelené,
- CI zelené; R4 kritická E2E deterministicky prochází,
- živý provider smoke proveden, nebo poctivě evidován jako otevřený dluh,
- žádný známý blocker ani critical defect.

---

# 14. Závazná pravidla R4

- **R4P-001 – AI proposes, domain executes.** Jediná cesta změny je potvrzený ChangeSet přes existující doménové operace.
- **R4P-002 – Contract precedes implementation.**
- **R4P-003 – No raw output execution.** Nevalidní/nestrukturovaný výstup se nikdy neprovede; text ≠ změna.
- **R4P-004 – Model decides nothing about authorization.**
- **R4P-005 – Minimized purposeful context.** Kontext jen pro účel požadavku; žádné secrets; PII dle C27.
- **R4P-006 – Provider behind server-side abstraction.** Klíče jen na serveru; žádné klíče v repo; testy s fake providerem.
- **R4P-007 – Mandatory confirmation, visible rejection.**
- **R4P-008 – Versioned prompts, schemas and models.**
- **R4P-009 – Append-only provenance and audit.** AI data nesou AI provenance; audit bez PII/prompt obsahu.
- **R4P-010 – Safe fallback, manual path intact.** (`RSR-005`)
- **R4P-011 – R1–R3 stay green.** Všechny předchozí kritické E2E zůstávají zelené po celou R4.
- **R4P-012 – Execution reuses R3 pathways.** Žádný paralelní zápisový mechanismus.
- **R4P-013 – Deterministic eval gate.** Eval běží bez sítě; flaky ≠ zelený.
- **R4P-014 – Honest evidence.** Vč. řízené evidence živého provider smoke.
- **R4P-015 – Scope changes traceable** (release scope §13).

---

# 15. Stav backlogu

R4 backlog (`R4-01` až `R4-08`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na blokující kontrakty (§7.1: C25–C32). Implementace R4 nezačala.

První kanonický krok: **C25 – AI provider ADR + gateway architecture** a **C26 – Prompt versioning & AI audit** → tím se `R4-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices.
