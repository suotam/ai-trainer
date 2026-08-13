# AI Trainer – R5 Adaptive Daily Trainer Beta Vertical Slice Plan

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r5-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Navazuje na:** `docs/02-product/release-scope.md` (§9, §10), `docs/06-domain/recovery-and-limitaitons-model.md`, `docs/06-domain/ai-and-change-model.md`, `docs/06-domain/metrics-model.md`, `docs/06-domain/training-plan-model.md`, kontrakty C16–C32 (R3/R4), `docs/13-delivery/r4-vertical-slice-plan.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R5 detailní kontrakty (viz §7.1), implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R5, slice boundaries R5, R5 blocking contract map, evidence gates R5, R5 backlog decomposition, R5 Exit Review a pravidla `R5P-001` až `R5P-015`

---

# 1. Účel

Kanonický implementační plán pro celé **R5 – Adaptive Daily Trainer Beta** (release scope §9): uživatel denně hlásí svůj stav (únava, bolest, energie), systém ho **deterministicky chrání** (safety pravidla nejsou AI), Today dává poctivé doporučení, a na změnu stavu lze reagovat **AI návrhem úpravy dne či týdne** — provedeným výhradně potvrzeným ChangeSetem přes existující doménové cesty. R5 uzavírá scope první externě testovatelné bety (release scope §10).

Dokument **nedefinuje** tvary check-inů, safety pravidla, schémata ani kód — ty vlastní navazující kontrakty (§7.1).

---

# 2. Delivery princip

- R5 se implementuje po slicech; kontrakt předchází implementaci; slice bez blokujících kontraktů je `NOT_READY`.
- **Safety je deterministická a AI jí nikdy nevelí (`RSR` §9.3)** — safety pravidla jsou kód, ne model; AI návrh úprav se pohybuje uvnitř safety stavu a konflikt je typovaný stav pro uživatele, nikdy tichý override.
- **Medicínská hranice poctivě**: pain/limitation/recovery workflow není produkčně připravený bez medicínského a právního review — beta jej nese s poctivým označením a konzervativními defaulty.
- **Adaptace znovupoužívá R4 pipeline** — tentýž gateway, verzované prompty/schémata, dvojí validace, AIProposal lifecycle a execution boundary; nový request typ vzniká kontraktem, ne implementací.
- **Manual path zůstává plnohodnotný (`RSR-005`)** a **local-first invariant trvá**: check-in, safety, doporučení i týdenní shrnutí fungují plně offline; AI úprava je volitelná online funkce.

---

# 3. Celkové pořadí

```text
R5-01  DailyCheckIn (strukturovaný denní stav, persistence, sync)               (mobile + backend)
R5-02  Deterministic Safety Rules (flags/assessment z check-inů a omezení)      (mobile)
R5-03  Today Recommendation (deterministické doporučení dne)                    (mobile)
R5-04  Adjustment Context and Classification (nový AI request typ + kontext)    (mobile + backend)
R5-05  Structured Adjustment Proposal (schéma operací + dvojí validace)         (mobile + backend)
R5-06  Adjustment ChangeSet Execution (C20/C21 cesty, atomicita, provenance)    (mobile)
R5-07  Weekly Summary, Progress Explanation and Local Notifications             (mobile)
R5-08  R5 Critical End-to-End Evidence, Beta Baseline and Exit Review           (mobile + backend)
```

Princip řazení:

1. **Vstupní data nejdřív** (R5-01) — bez check-inu není co vyhodnocovat.
2. **Deterministická ochrana před AI** (R5-02, R5-03) — safety a doporučení fungují bez modelu a bez sítě; AI přichází až nad ně.
3. **Adaptace jako R4 vzor** (R5-04 → R5-05 → R5-06) — kontext → strukturovaný návrh → review → execution, stejná disciplína, nový typ.
4. **Souhrn a připomínky** (R5-07), **beta E2E + Exit Review** (R5-08).

---

# 4. R5 value statement

**Hlavní hodnota R5:** Uživatel má praktický denní přehled a může bezpečně reagovat na únavu, bolest nebo změnu programu: denní check-in → deterministické safety vyhodnocení → poctivé Today doporučení → na vyžádání **vysvětlitelný AI návrh úpravy dne/týdne**, který se po potvrzení provede běžnými doménovými operacemi (přesun/zrušení/náhrada/přidání) — s historií, vysvětlením a bez ztráty manuální kontroly.

Hodnota je dosažena, až když: (a) check-in je strukturovaný lokální záznam se sync podporou, (b) safety vyhodnocení je deterministické, konzervativní a nezávislé na AI, (c) doporučení i shrnutí jsou deterministické read modely, (d) AI úprava drží celý R4 zákon (validace → potvrzení → C20/C21 execution s provenance) a (e) beta baseline scénář (release scope §10) je doložitelný.

---

# 5. Scope a non-goals

## 5.1 R5 P0 scope (dle release scope §9.2)

DailyCheckIn; hlášení únavy a bolesti; deterministické safety omezení; návrh úpravy dne nebo týdne; potvrditelný ChangeSet; Today doporučení; základní lokální notifikace; týdenní shrnutí; základní vysvětlení progresu.

## 5.2 Non-goals R5

- AIConversation / chat UX, AI tool-calling (trvá z R4 §5.2),
- produkční medicínské tvrzení — pain/recovery workflow zůstává beta s poctivým označením (§9.3 release scope),
- automatické provedení úprav bez potvrzení; vzdálené zásahy; server push notifikace (P0 = lokální),
- prediktivní metriky, únavové modely, ML skórování — R5 safety je pravidlový kód,
- wearables/kalendáře/importy/GPS,
- **pull sync / obnova zařízení** — vědomě mimo R5 P0 (trvající dluh C10); beta krok 10 „bezpečná obnova" se dokládá v rozsahu možností push-only, jinak zůstává přiznaným dluhem (§12).

---

# 6. Architektonické principy R5

- **Check-in je běžná R3-vzorová entita**: born ownable & syncable (R3M-004), attach v témže slice, client-generated ID, žádná PII navíc (bolest = strukturované kódy oblastí/úrovní, volný text jen lokální poznámka mimo sync i AI kontext).
- **Safety engine deterministický**: čistá funkce (check-iny + aktivní omezení → flags/assessment); stejný vstup → stejný výsledek; žádná AI, žádná síť; konzervativní defaulty.
- **Doporučení a shrnutí = read modely** (C23 vzor): bez uložených agregátů, deterministické, rekonstruovatelné.
- **Adaptace přes R4 infrastrukturu**: nový request typ + prompt verze v registru (C26), minimalizovaný kontext (C27 vzor — týden plánu by-value, check-in agregáty, safety stav; žádná ID), nové verzované schéma operací (C28 vzor), AIProposal lifecycle beze změny (C29), execution výhradně C20/C21 (C30 vzor).
- **Notifikace jsou připomínky, ne akce**: lokální, opt-in, nikdy nemění doménová data; tap = navigace.

---

# 7. Prerequisites

1. R0–R4 uzavřené a mergnuté (splněno; Exit Reviews provedeny).
2. Existuje tento plán.
3. Pro každý slice existují blokující kontrakty (§7.1); do té doby `NOT_READY`.
4. Živý provider smoke (R4 dluh) není blocker R5 implementace, ale **je podmínkou beta gate** (§12, §13).

## 7.1 R5 blocking contract map

Číslování navazuje na R4 (C25–C32):

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Minimum |
|---|---|---|---|---|---|
| C33 | DailyCheckIn model & persistence | Domain (recovery-model §5–§6) + Mobile + Data | `docs/06-domain/r5-daily-checkin-contract.md` | R5-01 | strukturované tvary (únava/bolest/energie), denní klíč a editace dne, schema bump, owner/sync/attach, rozšíření sync registru |
| C34 | Deterministic safety rules baseline | Domain (recovery-model §31–§33, §83) + Security | `docs/06-domain/r5-safety-rules-contract.md` | R5-02 | SafetyFlag/SafetyAssessment z check-inů + omezení, konzervativní deterministická pravidla, medicínská hranice a beta označení, žádná AI |
| C35 | Today recommendation read model | Domain + Mobile | `docs/06-domain/r5-today-recommendation-contract.md` | R5-03 | deterministické doporučení dne (plán + check-in + safety), typované stavy vč. „bez check-inu", offline |
| C36 | Adjustment context & classification | Domain (ai-and-change-model) + Security | `docs/09-ai/r5-adjustment-context-contract.md` | R5-04 | request typ ADJUSTMENT_PROPOSAL, minimalizovaný kontext (týden plánu by-value, check-in agregáty, safety stav), prompt verze, zákazy obsahu |
| C37 | Adjustment structured output & proposal | Domain + Backend + Mobile | `docs/09-ai/r5-adjustment-schema-contract.md` | R5-05 | `adjustment-proposal-schema-v1` (operace move/cancel/replace/add s povinným reason), dvojí validace, AIProposal reuse, endpoint rozhodnutí |
| C38 | Adjustment execution | Domain + Mobile | `docs/09-ai/r5-adjustment-execution-contract.md` | R5-06 | provedení výhradně C20/C21 operacemi, atomicita/rollback, provenance, safety konflikt jako typovaný stav |
| C39 | Weekly summary & progress explanation | Domain (metrics-model) + Mobile | `docs/06-domain/r5-weekly-summary-contract.md` | R5-07 | deterministický týdenní souhrn a vysvětlení progresu z C23 základů, bez uložených agregátů |
| C40 | Local notifications baseline | Mobile + Product | `docs/08-mobile/r5-notifications-contract.md` | R5-07 | lokální připomínky (check-in, dnešní workout), opt-in, žádné akce z notifikace, platformní evidence hranice |

---

# 8. Terminologická hranice

- **DailyCheckIn** = subjektivní denní stav (vstup); není to ManualActivity (vykonaná aktivita) ani feedback workoutu.
- **SafetyAssessment** = deterministický výstup pravidel; není to AI návrh ani lékařská diagnóza.
- **Recommendation** = deterministický read model dne (nic nemění); **Proposal** = AI artefakt čekající na rozhodnutí (C29).
- **Adjustment** = úprava existujícího plánu přes C21/C20 operace; **Plan proposal** (R4/C30) = nový plán. Oba jsou AIProposal, liší se typem a execution cestou.

---

# 9. Slice detail

## 9.1 R5-01 – DailyCheckIn
**Výsledek:** Uživatel zaznamená denní stav (únava, bolest se strukturovanou oblastí/úrovní, energie); jeden záznam na den s editací; historie; born ownable & syncable + attach; sync registr rozšířen (C24 vzor).
**Blocking:** C33. **Evidence:** persistence/edit/denní klíč testy, attach, migrace, sync push nového typu, žádná PII v sync payloadu navíc.

## 9.2 R5-02 – Deterministic Safety Rules
**Výsledek:** Čistý deterministický engine: check-iny + aktivní omezení → SafetyFlags/SafetyAssessment (např. vysoká únava → doporučení odlehčení; hlášená bolest → konzervativní omezení oblasti); beta označení medicínské hranice v UI.
**Blocking:** C34. **Evidence:** tabulkové testy pravidel (stejný vstup → stejný výsledek), konzervativní hrany, žádná síť/AI závislost.

## 9.3 R5-03 – Today Recommendation
**Výsledek:** Today zobrazuje poctivé deterministické doporučení dne (trénuj dle plánu / zvaž odlehčení / zvaž odpočinek) s důvody z check-inu a safety; typované stavy vč. chybějícího check-inu; čistě read model.
**Blocking:** C35. **Evidence:** read model testy, widget testy stavů, offline determinismus.

## 9.4 R5-04 – Adjustment Context and Classification
**Výsledek:** Nový request typ `ADJUSTMENT_PROPOSAL` (C27 rozšíření): minimalizovaný kontext = R4 základ + týden plánu by-value (bez ID), check-in agregáty a safety stav; nová prompt verze v registru (C26 vzor).
**Blocking:** C36. **Evidence:** marker testy zakázaného obsahu, bajtový determinismus, prompt registry testy.

## 9.5 R5-05 – Structured Adjustment Proposal
**Výsledek:** `adjustment-proposal-schema-v1`: seznam operací (move/cancel/replace/add) s povinným `reason` per operace; dvojí deterministická validace; persistence jako AIProposal (C29 lifecycle beze změny); review UI s dopady operací.
**Blocking:** C37. **Evidence:** validátor fixtures (server+klient), eval dataset rozšířen o adjustment cases (C32 §5), review widget testy.

## 9.6 R5-06 – Adjustment ChangeSet Execution
**Výsledek:** Potvrzený adjustment se provede atomicky výhradně C21 operacemi (+C20 add) s append-only evidencí a provenance; safety konflikt i doménové odmítnutí (např. dokončený workout) = typované selhání bez částečného stavu; `EXECUTED`/`EXECUTION_FAILED` + reference.
**Blocking:** C38. **Evidence:** atomicita/rollback testy, provenance, kalendářní evidence, terminalita.

## 9.7 R5-07 – Weekly Summary, Progress Explanation and Local Notifications
**Výsledek:** Deterministický týdenní souhrn (plán vs. dokončeno, aktivity, check-in trend) se základním vysvětlením progresu; lokální opt-in připomínky (check-in, dnešní workout) bez doménových akcí.
**Blocking:** C39 + C40. **Evidence:** read model determinismus testy, widget testy, notifikační scheduling logika testovaná deterministicky (platformní doručení = emulátorový dluh, poctivě evidováno).

## 9.8 R5-08 – R5 Critical End-to-End Evidence, Beta Baseline and Exit Review
**Výsledek:** Automatizovaný důkaz hlavní hodnoty R5 + mapování beta baseline scénáře (release scope §10) + R5 Exit Review.
**Blocking:** žádné nové. **Ready:** R5-01…07 Done.
**Evidence:** deterministický E2E (check-in → safety → doporučení → žádost o úpravu /fake provider/ → review → potvrzení → provedené operace v kalendáři/Today → sync; plus odmítnutí, safety konflikt a fallback větve); beta scénář krok po kroku doložen nebo poctivě přiznán jako dluh; Exit Review dle §13.

---

# 10. Cross-slice invariants

1. **Safety je deterministická a nadřazená AI** — AI návrh nikdy neobchází safety stav; konflikt je typovaný stav pro uživatele.
2. **Medicínská hranice poctivě označená** — žádné produkční tvrzení bez review (release scope §9.3).
3. **AI nikdy nezapisuje do domény** — jediná cesta je potvrzený ChangeSet přes C20/C21 (trvá z R4).
4. **R1–R4 toky beze změny a bez závislosti na R5 funkcích**; check-in je volitelný — bez něj vše funguje jako dřív.
5. **Nové entity born ownable & syncable** + attach v témže slice (R3M vzor).
6. **Minimalizovaný kontext** — check-in volný text nikdy do AI kontextu ani sync payloadu.
7. **Verzování promptů/schémat/modelů trvá**; nový typ = nové verze, eval dataset se rozšiřuje (C32 §5).
8. **Potvrzení povinné; odmítnutí viditelné** (RSR-012).
9. **Bezpečný fallback** — typované chyby, žádný auto-retry; notifikace nikdy nejednají.
10. **Deterministické read modely** — doporučení/souhrn bez uložených agregátů.
11. **Eval gate závazný** — adjustment cases rozšiřují dataset; flaky ≠ zelený důkaz.
12. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

- **Unit**: safety pravidla (tabulkové), context builder rozšíření, adjustment validace, notifikační scheduling logika.
- **Backend Testcontainers**: nový request typ přes gateway s fake providerem, sync registr rozšíření, security-negative.
- **Mobile**: check-in persistence/attach, doporučení/souhrn read modely, review+execution testy, fallback stavy.
- **Eval harness**: adjustment cases ve sdíleném datasetu (C32).
- **Kritická E2E (R5-08)**: celý cyklus vč. negativních větví (safety konflikt, odmítnutí, výpadek modelu).
- **Živý provider a platformní notifikace**: mimo CI; řízená manuální evidence (§12).

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Živý provider smoke (R4 dluh)** — není blocker R5 slices, ale **je podmínkou beta gate**: před vyhlášením beta baseline musí proběhnout, nebo beta zůstává interní s přiznaným dluhem.
- **Pull sync / obnova zařízení** — trvá mimo P0 (C10); beta krok 10 „bezpečná obnova" se dokládá v mezích push-only reality; plná obnova je kandidát R6.
- **Emulátorová runtime evidence** — trvá (bez SDK na stroji); rozšíří se o R5 kroky; platformní doručení notifikací patří sem.
- **Přenesené dluhy R2–R4 trvají** (DELETE, plán struktura sync, distribuovaný rate limiter, …) — nejsou R5 blocker, R5-08 je znovu eviduje.
- **Medicínské/právní review** pain/recovery workflow — mimo inženýrský scope; beta označení povinné do jeho provedení.

---

# 13. R5 Exit Review

R5 je dokončeno pouze pokud (doloženo testy, CI runy a evidencí):

- check-in je strukturovaný, denně editovatelný, vlastněný a synchronizovaný; žádná PII navíc,
- safety vyhodnocení je deterministické, konzervativní, testované tabulkově a nezávislé na AI/síti,
- Today doporučení je poctivý deterministický read model s typovanými stavy,
- adjustment návrh drží celý R4 zákon (minimalizovaný kontext, dvojí validace, potvrzení, viditelné odmítnutí),
- potvrzený adjustment se provádí atomicky přes C20/C21 s provenance; safety konflikt je typovaný stav,
- týdenní souhrn a vysvětlení progresu jsou deterministické read modely,
- notifikace jsou lokální, opt-in a nikdy nejednají,
- eval gate rozšířen o adjustment cases a prochází,
- R1–R4 kritické E2E zůstávají zelené; R5 E2E deterministicky prochází; CI zelené,
- beta baseline scénář (release scope §10) doložen krok po kroku, nebo s poctivě přiznanými dluhy,
- živý provider smoke proveden, nebo beta explicitně označena jako interní s dluhem,
- medicínská hranice poctivě označena v UI i dokumentaci,
- žádný známý blocker ani critical defect.

---

# 14. Závazná pravidla R5

- **R5P-001 – Deterministic safety first.** Safety pravidla jsou kód; AI jim nikdy nevelí a neobchází je.
- **R5P-002 – Contract precedes implementation.**
- **R5P-003 – Honest medical boundary.** Beta označení pain/recovery workflow povinné; konzervativní defaulty.
- **R5P-004 – Adjustment reuses R4 pipeline.** Gateway, verze, dvojí validace, AIProposal lifecycle, execution boundary.
- **R5P-005 – Execution only via C20/C21.** Žádný nový zápisový kanál; provenance povinná.
- **R5P-006 – Manual path intact.** Vše jde udělat ručně; AI i notifikace jsou volitelné.
- **R5P-007 – Local-first.** Check-in, safety, doporučení, souhrn plně offline; AI úprava online volitelná.
- **R5P-008 – Born ownable and syncable.** Nové tabulky dle R3M vzoru, attach v témže slice.
- **R5P-009 – Mandatory confirmation, visible rejection.**
- **R5P-010 – Safe fallback, typed states.** Žádný auto-retry.
- **R5P-011 – R1–R4 stay green.**
- **R5P-012 – Deterministic read models.** Žádné uložené agregáty pro doporučení/souhrn.
- **R5P-013 – Notifications never act.** Připomínka ≠ akce; žádné tiché změny.
- **R5P-014 – Honest evidence.** Vč. beta gate podmínek (živý smoke) a emulátorových dluhů.
- **R5P-015 – Scope changes traceable.**

---

# 15. Stav backlogu

R5 backlog (`R5-01` až `R5-08`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na blokující kontrakty (§7.1: C33–C40). Implementace R5 nezačala.

První kanonický krok: vytvořit **C33 – DailyCheckIn model & persistence** → tím se `R5-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices, ne všechny najednou.
