# AI Trainer – Documentation Map

**Verze:** 2.52  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-08-14

---

# 1. Účel

Tato složka obsahuje produktovou, UX, doménovou, technickou, bezpečnostní, integrační, delivery, testovací a provozní dokumentaci AI Traineru.

Aktuální stav, mezery a kanonický další krok vlastní:

```text
docs/DOCUMENTATION_STATUS.md
```

Před dokumentační nebo implementační změnou je nutné načíst aktuální repozitář, tento README, audit a vlastnící zdroje pravdy.

---

# 2. Hierarchie zdrojů pravdy

Pokud si dokumenty odporují, platí toto pořadí:

1. právní a bezpečnostní pravidla,
2. produktové principy,
3. globální doménové invariance,
4. detailní vlastnící doménový model,
5. schválené ADR,
6. architektonický kontrakt,
7. API, event, sync nebo datový kontrakt,
8. release scope a acceptance criteria,
9. UX specifikace,
10. implementační doporučení a příklady.

Nižší vrstva může vyšší pravidlo zpřesnit, ale nesmí je obejít.

---

# 3. Hlavní zdroje pravdy

## 3.1 Vision and product

```text
docs/01-vision/vision.md
docs/01-vision/product-principles.md
docs/02-product/product-scope.md
docs/02-product/functional-requirements.md
docs/02-product/non-functional-requirements.md
docs/02-product/release-scope.md
```

`release-scope.md` vlastní R0 až R5, priority, scope boundaries a exit criteria.

## 3.2 Users and UX

```text
docs/03-users/user-personas.md
docs/03-users/user-scenarios.md
docs/04-ux/information-architecture.md
docs/04-ux/core-user-flows.md
docs/04-ux/screen-specifications.md
```

## 3.3 Domain

```text
docs/06-domain/domain-overview.md
docs/06-domain/sports-and-goals-model.md
docs/06-domain/training-plan-model.md
docs/06-domain/workout-model.md
docs/06-domain/scheduling-model.md
docs/06-domain/activity-model.md
docs/06-domain/recovery-and-limitations-model.md
docs/06-domain/ai-and-change-model.md
docs/06-domain/metrics-model.md
docs/06-domain/integration-model.md
docs/06-domain/sync-and-offline-model.md
docs/06-domain/identity-and-profile-model.md
docs/06-domain/domain-events.md
docs/06-domain/domain-invariants.md
docs/06-domain/glossary.md
```

## 3.4 Architecture and contracts

```text
docs/05-architecture/initial-architecture-decisions.md
docs/07-backend/backend-architecture.md
docs/07-backend/r0-api-contract.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/10-integrations/integration-architecture.md
docs/11-security/security-architecture.md
docs/12-data/data-architecture.md
docs/12-data/r1-physical-data-model.md
docs/07-backend/r2-identity-session-contract.md
docs/07-backend/r2-auth-api-contract.md
docs/07-backend/r2-device-registration-contract.md
docs/07-backend/r2-sync-protocol-contract.md
docs/07-backend/r2-conflict-rejection-contract.md
docs/11-security/r2-audit-event-contract.md
docs/11-security/r2-revocation-contract.md
docs/11-security/r2-token-session-storage-contract.md
docs/11-security/r2-authorization-ownership-contract.md
docs/12-data/r2-mobile-schema-migration.md
docs/12-data/r2-local-sync-metadata-contract.md
docs/12-data/r2-idempotency-contract.md
docs/12-data/r2-local-to-account-migration-contract.md
docs/12-data/r2-server-data-model.md
docs/12-data/r3-mobile-schema-migration.md
docs/06-domain/r3-sports-profile-contract.md
docs/06-domain/r3-goals-contract.md
docs/06-domain/r3-availability-contract.md
docs/06-domain/r3-manual-plan-contract.md
docs/06-domain/r3-calendar-operations-contract.md
docs/06-domain/r3-manual-activity-contract.md
docs/06-domain/r3-progress-statistics-contract.md
docs/12-data/r3-sync-extension-contract.md
docs/09-ai/r4-ai-gateway-contract.md
docs/09-ai/r4-prompt-audit-contract.md
docs/09-ai/r4-aicontext-contract.md
docs/09-ai/r4-structured-output-contract.md
docs/09-ai/r4-proposal-lifecycle-contract.md
```

- `r2-local-to-account-migration-contract.md` (**C15**, vlastník Data Architecture + Domain) vlastní připojení předpřihlašovacích anonymních dat k účtu: klasifikaci (uživatelská data ano; čistý seed ne; cizí účet nikdy), **lokální idempotentní attach** (přepis `owner_id` v jedné transakci, žádná změna ID/klíčů/hodnot — duplicitní ochranu zajišťují existující vrstvy C10/C11/C6), chování při odhlášení a druhém účtu na zařízení a invarianty `LAM-001` až `LAM-015`. Contract-only. Blokuje `R2-07`. **Tímto je kontraktní mapa R2 (C1–C15) kompletní.**

- `r3-mobile-schema-migration.md` (**C16**, vlastník Data Architecture) vlastní evoluci mobilního schématu v R3 (verze `5+`): dědí C1/`MSM-*` beze změny, verzování per slice, kontraktní přírůstky R3 tabulek, pravidlo **born ownable and syncable** (owner/sync metadata od vzniku, owner stamping při zápisu), **attach coverage** nových tabulek ve stejném slice (zpřesnění plánu §9.7 — R3-07 attach jen ověřuje) a invarianty `R3M-001` až `R3M-015`. Contract-only. Blokuje `R3-01` a každou další R3 schema změnu.

- `r3-sports-profile-contract.md` (**C17**, vlastník Domain / sports-and-goals-model + Mobile) vlastní závaznou P0 podmnožinu sportovního profilu: aggregate `UserSport` s participation patternem, minimální katalog stabilních kódů sportů + custom sport, kódy rolí/priorit/zkušeností/intenzity/prostředí, lifecycle `ACTIVE/PAUSED/ENDED` (konec je stav, ne mazání), anonymní paritu s attach pokrytím od R3-01 (vč. kolizních pravidel §8) a invarianty `ASP-001` až `ASP-015`. Contract-only. Blokuje `R3-01`.

- `r3-goals-contract.md` (**C18**, vlastník Domain / sports-and-goals-model + Mobile) vlastní závaznou P0 podmnožinu cílů: aggregate `Goal` (strukturovaná deklarace — povinný jen title), stabilní kódy typů/priorit/horizontů/stavů, lifecycle `ACTIVE↔PAUSED → COMPLETED/ABANDONED` (terminální stavy konečné, žádné mazání), volitelnou device-local vazbu na UserSport, bezpodmínečný attach a invarianty `GLC-001` až `GLC-015`. Mimo P0: metriky, hierarchie, konflikty, milníky, expirace. Contract-only. Blokuje `R3-02`.

- `r3-availability-contract.md` (**C19**, vlastník Domain / scheduling + recovery model + Mobile) vlastní závaznou P0 podmnožinu dostupnosti a tréninkového kontextu: typický týden (jedna deklarace na den, level + budget + část dne, den bez deklarace = unknown, zpětvzetí legitimní), vybavení (katalog 13 kódů XOR custom, archivace jako stav), základní omezení (deklarace bez interpretace, vyřešení jako stav), attach kolizní pravidla a invarianty `AVC-001` až `AVC-015`. **Deklarace, ne vynucení.** Contract-only. Blokuje `R3-03`.

- `r3-manual-plan-contract.md` (**C20**, vlastník Domain / training-plan + scheduling model + Mobile) vlastní závaznou P0 podmnožinu ručního plánování: `TrainingPlan` aggregate (nejvýše jeden ACTIVE na vlastníka, archivace jako stav), klíčové rozhodnutí **ručně plánovaný workout = existující R1 `WorkoutInstance`** (`source_type = USER_PLAN`, atomické vytvoření s MAIN sekcí/kroky/sety), interní kalendář = existující R1 read modely, koexistenci se seedem, attach pravidla (USER_PLAN instance = uživatelská data od vzniku; rozšíření C15 §4) a invarianty `MPC-001` až `MPC-015`. Contract-only. Blokuje `R3-04`.

- `r3-calendar-operations-contract.md` (**C21**, vlastník Domain / scheduling + workout model + Mobile) vlastní bezpečné kalendářní operace nad ručně plánovanými workouty: přesun/zrušení/nahrazení (scoped na `USER_PLAN`; seed read-only), guardy „fakta jsou nedotknutelná" (instance se session typovaně odmítnuta), append-only evidenci `CalendarChange`, stav `CANCELLED` mimo kalendářní přehledy (aditivní filtr R1 read modelu) a invarianty `CAL-001` až `CAL-015`. Contract-only. Blokuje `R3-05`.

- `r3-manual-activity-contract.md` (**C22**, vlastník Domain / activity-model + Mobile) vlastní ruční aktivitu (P0 zdroj výhradně `MANUAL`): fakt po skutečnosti bez lifecycle, povinný jen popis + datum, device-local vazby na sport/instanci (dokumentační — skutečnost nemění plán), editace bez mazání, bezpodmínečný attach a invarianty `MAC-001` až `MAC-015`. Contract-only. Blokuje `R3-06`.

- `r3-progress-statistics-contract.md` (**C23**, vlastník Domain / metrics-model + Mobile) vlastní základní progres/completion statistiky jako **deterministický read model bez perzistence**: planned (mimo CANCELLED) / completed (ze summaries) / completionRate (jen pro plán > 0, jinak „—") / manuální aktivity bez dvojího započtení, device-local scope (řízené rozhodnutí) a invarianty `PST-001` až `PST-015`. Contract-only. Blokuje `R3-06`.

- `r3-sync-extension-contract.md` (**C24**, vlastník Domain / sync-and-offline-model + Data Architecture + Backend) vlastní aditivní rozšíření sync registru o osm R3 typů (bez serverových parentů, C6 §8.4 kostra ve Flyway V5), pořadí v batchi, vyřešená otevřená rozhodnutí (plán struktura lokální; DELETE mimo P0) a invarianty `SXC-001` až `SXC-015` — **beze změny sémantiky C10/C11/C8, žádný nový endpoint**. Contract-only. Blokuje `R3-07`. **Tímto je kontraktní mapa R3 (C16–C24) kompletní.**

- `r4-ai-gateway-contract.md` (**C25**, vlastník Architecture + Backend; rozhodnutí providera je **ADR-012**) vlastní server-side AI gateway hranici: `AiModelProvider` abstrakci s typovanými selháními, první provider Anthropic Claude (model = konfigurace), klíče výhradně runtime server-side, fake provider jako default a jediná testovací cesta CI, timeouts bez auto-retry a invarianty `AGW-001` až `AGW-015`. Contract-only. Blokuje `R4-01`.

- `r4-prompt-audit-contract.md` (**C26**, vlastník Backend + Security, rozšíření C14 vzoru) vlastní verzovaný prompt registry (immutable verze `{typ}-v{N}`, prompt bez uživatelských dat), povinnou trojici verzí v každém výsledku (prompt + schema + model) a AI audit události `AiProposalRequested/Generated/Failed` bez PII a obsahu, a invarianty `PAA-001` až `PAA-015`. Contract-only. Blokuje `R4-01`.

- `r4-aicontext-contract.md` (**C27**, vlastník Domain / ai-and-change-model + Security + Mobile) vlastní klasifikaci AI požadavků (P0: `PLAN_PROPOSAL`) a **minimalizovaný autorizovaný AIContext**: co smí obsahovat (aktivní R3 data by-value + C23 agregáty), zakázaný obsah (žádná ID, poznámky, owner, secrets, detailní historie), bajtový determinismus, přiznaný ořez a invarianty `ACX-001` až `ACX-015`. Kontext staví klient lokálně. Contract-only. Blokuje `R4-02`.

- `r4-structured-output-contract.md` (**C28**, vlastník Domain + Backend + Mobile) vlastní verzované schéma `plan-proposal-schema-v1` (workouty s `dayOffset` a povinným `reason`), deterministickou fence extrakci, **dvojí validaci** (server před vrácením, klient před persistencí), kanonizaci (neznámá pole se zahazují, výstup se nikdy neopravuje) a invarianty `SOV-001` až `SOV-015`. Contract-only. Blokuje `R4-03`.

- `r4-proposal-lifecycle-contract.md` (**C29**, vlastník Domain / ai-and-change-model + Mobile) vlastní lokální persistence `AIProposal` (kanonický payload + povinná trojice verzí), P0 stavy `PROPOSED→CONFIRMED/REJECTED→EXECUTED/EXECUTION_FAILED` + `EXPIRED` (7 dní při rozhodnutí), žádné mazání, rozhodnutí výhradně uživatelem a invarianty `APL-001` až `APL-015`. Contract-only. Blokuje `R4-03`/`R4-04`.

- `r4-changeset-execution-contract.md` (**C30**, vlastník Domain / ai-and-change-model + Mobile) vlastní provedení potvrzeného návrhu: **jediná cesta změny = C20 operace** (doménová pravidla vč. MPC-002 platí beze změny), mapování `dayOffset` → lokální datum provedení, atomicitu s rollbackem (žádný částečný stav), provenance `origin = AI_PROPOSAL` + `executedPlanId` referenci, typovaná selhání s explicitním retry a invarianty `CSE-001` až `CSE-015`. Contract-only. Blokuje `R4-05`.

- `r2-sync-protocol-contract.md` (**C10**, vlastník Domain / sync-and-offline-model + Backend) vlastní R2-05 push sync protokol: tvar push operace (mapování na outbox položku), `ORDERED_OPERATIONS` batch podle deterministického `sequence`, per-item výsledky (`SUCCESS`/`ALREADY_APPLIED`/`VERSION_CONFLICT`/`VALIDATION_FAILED`/`PERMISSION_DENIED`/`DEPENDENCY_FAILED`), **potvrzení výhradně po serverovém commitu**, optimistic concurrency přes `expectedServerVersion`, R2-05 podmnožinu typů (`CREATE_ENTITY`/`UPDATE_ENTITY`) a entit, a invarianty `SPC-001` až `SPC-015`. Pull sync je mimo P0. Contract-only. Blokuje `R2-05`.

- `r2-idempotency-contract.md` (**C11**, vlastník Domain / sync-and-offline-model + Backend) vlastní R2 replay protokol: IdempotencyRecord (klíč+účet, requestHash bez secrets, výsledková reference, expirace), `ALREADY_APPLIED` bez vedlejších efektů, „stejný klíč, jiný payload = chyba", atomicitu záznamu s efektem, souběh a invarianty `IDC-001` až `IDC-015`. Jednotný protokol pro registraci účtu (R2-02) i sync (R2-05). Contract-only. Blokuje `R2-05`.

- `r2-conflict-rejection-contract.md` (**C12**, vlastník Domain / sync-and-offline-model) vlastní R2 řešení konfliktů a odmítnutí: klasifikaci (VERSION_CONFLICT = USER_REVIEW, rejection = BLOCKED), **baseline resolution jen jako explicitní uživatelské rozhodnutí** — `USE_LOCAL` (potvrzený re-push s verzí z konfliktu, nový idempotency key) nebo `CANCEL_LOCAL_CHANGE` (ruší odeslání, nikdy lokální data; rozdíl vůči serveru zůstává přiznaný jako LOCAL_ONLY), bezpečné UI bez technických diffů, audit `SyncConflictResolved` a invarianty `CRC-001` až `CRC-015`. Žádné automatické merge. Contract-only. Blokuje `R2-06`.

- `r2-revocation-contract.md` (**C13**, vlastník Security + Backend) vlastní R2 revokační operace: globální revoke-all sessions účtu a revokaci instalace (zneplatní i vázané session; revokovaná instalace nepushuje ani se tiše nereaktivuje), idempotenci, jednotnou klientskou reakci (smazat materiál, signed-out, zachovat lokální data i outbox, nepřerušit aktivní workout), audit per session/instalace a invarianty `RVC-001` až `RVC-015`. Contract-only. Blokuje `R2-06`.

- `r2-authorization-ownership-contract.md` (**C8**, vlastník Security + Backend Architecture) vlastní serverové vynucení autorizace a ownership v R2: principal výhradně z ověřené access session, ownership check na každé chráněné hranici, R2 capability baseline (`profile.read/write`, `device.manage`, `sync.push`), default deny, anti-IDOR pravidla (cizí zdroj = 404, nerozlišitelný od neexistence), audit odmítnutí a invarianty `AOC-001` až `AOC-015`. Contract-only, bez policy engine a rolí. Blokuje `R2-04` a `R2-05`.

- `r2-device-registration-contract.md` (**C9**, vlastník Backend + Domain / sync-and-offline-model) vlastní R2 registraci zařízení: client-generated installation ID (stabilní, nefingerprintové, ne-secret), idempotentní registraci po přihlášení (upsert per account+installation), vazbu auth session → zařízení (DeviceSession bez samostatné tabulky), odhlášení bez ztráty identity a dat, minimalizaci metadat a invarianty `DRC-001` až `DRC-015`. Contract-only. Blokuje `R2-04`.

- `r2-token-session-storage-contract.md` (**C7**, vlastník Security + Mobile) vlastní mobilní uložení session materiálu: klasifikaci (heslo se neukládá nikdy; refresh výhradně platformní secure storage; access in-memory/secure storage; **nikdy Drift/SQLite, preferences, log, backup**), secure storage boundary (`MAR-015`), restart/logout/revocation chování (logout čistí materiál, ne lokální data; revokace není obnovitelná ze storage) a invarianty `TSS-001` až `TSS-015`. Contract-only, bez plugin volby a UI flow. Blokuje `R2-03`.

- `r4-ai-safety-contract.md` (**C31**, vlastník Security + Backend + Mobile fallback) vlastní AI safety & abuse hardening: typovaný fallback řetěz end-to-end bez auto-retry (selhání AI nikdy nedegraduje manuální cesty), **dvouvrstvý rate limiting** (pre-auth IP baseline + dedikovaný per-account AI limit `aitrainer.ai.rate-limit.*`), prompt-injection postoj (kontext = neprůhledná data; „unesený" model může nanejvýš vrátit text, který projde striktní C28 validací a C29/C30 uživatelskou cestou), obsahové limity (kontext 32k, výstup modelu 100k), redakci logů/auditů/chybových odpovědí a invarianty `AIS-001` až `AIS-015`. Contract-only. Blokuje `R4-06`.

- `r2-audit-event-contract.md` (**C14**, vlastník Domain / domain-events + Security) vlastní seznam auditovaných auth a sync kritických událostí R2, tvar audit záznamu (principal/action/target/outcome/čas/correlation/policy) a pravidla bez citlivého payloadu; invarianty `AEC-001` až `AEC-015`. Contract-only. **Auth část** (Done, blokovala `R2-02`) i **sync část** (Done ve v0.2 — `SyncOperationApplied/Rejected`, `SyncConflictDetected`, `AuthorizationDenied`, `IdempotentReplayReturned`; blokuje `R2-05`).

- `r2-server-data-model.md` (**C6**, vlastník Data Architecture) vlastní serverový (PostgreSQL) datový model R2: baseline tabulky account/auth/session, ownership sloupce, **server-vs-client ID** politiku (client-generated ID se zachovává), Flyway append-only migrační pravidla, **rozšíření §8.1–§8.3 (profil/device, R2-04)** i **§8.4–§8.5 (synced entity se `server_version` a rozšířený idempotency_record, R2-05)** a invarianty `SDM-001` až `SDM-015`. Contract-only, bez DDL/Flyway/ORM. Blokuje `R2-02`; rozšíření blokují `R2-04`/`R2-05`.

- `initial-architecture-decisions.md` obsahuje mimo `ADR-001` až `ADR-010` (R0/R1) také **`ADR-011` – R2 authentication provider strategy** (**C5**, vlastník Architecture): rozhoduje strategii auth provideru pro R2 (first-party backend session authority + provider-neutral `AuthenticationIdentity` adaptér; konkrétní externí federated provider odložen). Blokuje `R2-02` (spolu s C3/C4/C6/C14).
- `r2-identity-session-contract.md` (**C3**, vlastník Domain / identity-and-profile-model + Backend) vlastní R2 identity & session model: anonymous/authenticated/account/device identitu, session lifecycle (access/refresh), identity transitions (anonymous → account atd.), ownership interakci s C2, security boundaries a invarianty `ISC-001` až `ISC-015`. Contract-only, bez API/DB/JWT. Blokuje `R2-02` (spolu s C4/C5/C6/C14).
- `r2-auth-api-contract.md` (**C4**, vlastník Backend Architecture) vlastní veřejné R2 autentizační API: operace register/login/refresh/logout/session-context, request/response význam, credential transport, auth error semantics nad kanonickým error envelope (`APR`), API-level idempotency/retry hranice a invarianty `AAC-001` až `AAC-015`. Contract-only, bez controllerů/DTO/OpenAPI souboru/JWT/OAuth; provider-neutral. Blokuje `R2-02` (spolu s C3/C5/C6/C14).
- `r2-mobile-schema-migration.md` (**C1**, vlastník Data Architecture) vlastní evoluci mobilního Drift/SQLite schématu v R2: schema versioning, migration rules, migration invarianty `MSM-001` až `MSM-015`, kontraktní R2 strukturální přírůstky (owner reference, sync-state, verze entity, outbox) a evidence. Contract-only, bez SQL/Drift. Blokuje `R2-01` (spolu s C2).
- `r2-local-sync-metadata-contract.md` (**C2**, vlastník Domain / sync-and-offline-model) vlastní **význam a lifecycle** lokálních ownership a sync metadat v R2: ownership model (local/anonymous vs account), sync metadata význam, pending-operation/outbox lifecycle, entity lifecycle stavy a invarianty `LSM-001` až `LSM-015`. Contract-only, bez SQL/Drift/API. Blokuje `R2-01` (spolu s C1).

## 3.5 Delivery, quality and coding agent

```text
docs/13-delivery/repository-strategy.md
docs/13-delivery/definition-of-ready-and-done.md
docs/13-delivery/r0-r1-vertical-slice-plan.md
docs/13-delivery/r2-vertical-slice-plan.md
docs/13-delivery/r3-vertical-slice-plan.md
docs/13-delivery/r4-vertical-slice-plan.md
docs/14-quality/test-strategy.md
docs/15-coding-agent/coding-agent-guide.md
```

- `repository-strategy.md` vlastní monorepo layout, boundaries a `RER-001` až `RER-015`.
- `definition-of-ready-and-done.md` vlastní Ready/Done gates a `DRD-001` až `DRD-015`.
- `r0-r1-vertical-slice-plan.md` vlastní pořadí implementace R0/R1 a `VSP-001` až `VSP-015`.
- `r2-vertical-slice-plan.md` vlastní pořadí implementace R2 (`R2-01` až `R2-08`), R2 blocking contract map, evidence gates, R2 Exit Review a `R2P-001` až `R2P-015`. **Celé R2 (`R2-01` až `R2-08`) je implementováno a R2 Exit Review je proveden** (viz `DOCUMENTATION_STATUS.md` §3; otevřená zůstává jen řízená výjimka emulátorové runtime evidence).
- `r3-vertical-slice-plan.md` vlastní pořadí implementace R3 (`R3-01` až `R3-08`), R3 blocking contract map (C16–C24), evidence gates, R3 Exit Review a `R3P-001` až `R3P-015`. **Celé R3 (`R3-01` až `R3-08`) je implementováno a R3 Exit Review proveden** (viz `DOCUMENTATION_STATUS.md` §3) — Release 3 je uzavřen.
- `r4-vertical-slice-plan.md` vlastní pořadí implementace R4 (`R4-01` až `R4-08`), R4 blocking contract map (C25–C32), evidence gates, R4 Exit Review a `R4P-001` až `R4P-015`. Základní zákon: **AI navrhuje, doména provádí** — jediná cesta změny je potvrzený ChangeSet přes existující R3 operace. **Celé R4 (`R4-01` až `R4-08`) je implementováno a Release 4 uzavřen** (R4 Exit Review viz `DOCUMENTATION_STATUS.md` §3; otevřený dluh: živý provider smoke).

- `r5-vertical-slice-plan.md` vlastní pořadí implementace R5 – Adaptive Daily Trainer Beta (`R5-01` až `R5-08`), R5 blocking contract map (**C33–C40**), evidence gates, beta baseline mapování (release scope §10), R5 Exit Review a `R5P-001` až `R5P-015`. Základní zákony: **safety je deterministická a AI jí nikdy nevelí**, medicínská hranice poctivě označená, adaptace znovupoužívá R4 pipeline (nový request typ = kontrakt), execution výhradně C20/C21, notifikace nikdy nejednají. **Žádný R5 slice není `READY`** — čeká se na kontrakty (první: C33 – DailyCheckIn).
- `test-strategy.md` vlastní test levels, quality gates a `QTR-001` až `QTR-015`.

- `r4-eval-gate-contract.md` (**C32**, vlastník Quality + Domain) vlastní R4 eval release gate: **sdílený dataset `packages/contracts/eval/plan-proposal/*.json`** (jediný zdroj pro obě strany dvojí validace), deterministický harness bez živého providera v běžné CI suite (backend `EvalGateTest` + mobilní konzistence klientského validátoru), gate kritéria (100% shoda verdiktů, vysvětlitelnost `reason`, kanonizace `mustNotContain`, minimální velikost datasetu, žádný skip/retry), poctivě přiznaný scope (kontraktní vrstva, ne kvalita modelu — ta patří smoke evidenci plánu §12), postup rozšiřování a invarianty `EVG-001` až `EVG-015`. Contract-only. Blokuje `R4-07`. **Tímto je kontraktní mapa R4 (C25–C32) kompletní.**
- `coding-agent-guide.md` vlastní context-loading protocol, pracovní cyklus, commit discipline, evidence a `CAG-001` až `CAG-015`.

---

# 4. Implementační baseline

Startovní releases jsou:

```text
R0 – Technical Foundation
R1 – Local Workout Slice
```

Startovní dokumentační minimum je dokončeno:

1. ✅ release scope,
2. ✅ repository strategy,
3. ✅ počáteční ADR,
4. ✅ fyzický datový model R1,
5. ✅ R0 API contract,
6. ✅ test strategy,
7. ✅ Definition of Ready and Done,
8. ✅ R0/R1 vertical-slice implementation plan,
9. ✅ coding-agent instructions a context-loading guide.

`R0-01` až `R0-07` jsou implementovány a R0 exit review je uzavřeno (viz `DOCUMENTATION_STATUS.md` §3). Z R1 jsou implementovány `R1-01` až `R1-08` — celé R1 je implementované a R1 Exit Review je proveden (viz `DOCUMENTATION_STATUS.md`). Release 1 je uzavřen. Existuje R2 vertical-slice plán (`docs/13-delivery/r2-vertical-slice-plan.md`) s backlogem `R2-01` až `R2-08`. **Celé R2 (`R2-01` až `R2-08`) je implementováno** (lokální ownership/sync metadata, backend account/auth baseline, mobile auth + secure session storage, AthleteProfile + registrace zařízení, první push sync, conflict/rejection resolution + revokace, local-to-account attach, kritická E2E evidence) a **R2 Exit Review je proveden** — Release 2 je uzavřen; viz `DOCUMENTATION_STATUS.md` §3 (otevřená zůstává řízená výjimka emulátorové runtime evidence). **Celé R3 (`R3-01` až `R3-08`) je implementováno a R3 Exit Review proveden** — Release 3 je uzavřen (schema v10, backend V5, sync všech R3 entit, kritická E2E evidence). Existuje R4 vertical-slice plán (backlog `R4-01` až `R4-08`, contract map C25–C32); **`R4-01` až `R4-03` jsou implementovány** (AI gateway, AIContext, strukturovaný návrh + AIProposal). Dalším kanonickým krokem je **implementace `R4-04`** (review UI), po samostatném pokynu.

---

# 5. R0/R1 implementation order

Kanonické pořadí vlastní `docs/13-delivery/r0-r1-vertical-slice-plan.md`.

## R0

```text
R0-01 Repository Skeleton
R0-02 Mobile Bootstrap
R0-03 Backend Bootstrap
R0-04 Contracts and Health API
R0-05 Local Infrastructure and Migrations
R0-06 CI and Repository Gates
R0-07 Mobile-to-Backend Smoke Flow
```

## R1

```text
R1-01 Local Workout Seed and Read Model
R1-02 Today and Workout Detail
R1-03 Start and Persist Session
R1-04 Record Workout Performance
R1-05 Restart and Recovery
R1-06 Complete Workout and History
R1-07 Feedback, States and Accessibility
R1-08 Critical End-to-End Evidence
```

R1 musí zůstat použitelné bez backendu, účtu, synchronizace, AI a externích providerů.

---

# 6. Coding-agent protocol

Před každou změnou musí agent:

1. načíst aktuální branch,
2. přečíst tento README a `DOCUMENTATION_STATUS.md`,
3. určit backlog item a release slice,
4. ověřit jeho Ready stav,
5. načíst vlastnící doménové, architektonické, kontraktní a testovací dokumenty,
6. respektovat vertical-slice plan a non-goals,
7. provést nejmenší smysluplnou změnu,
8. spustit relevantní testy a gates,
9. aktualizovat dokumentaci a evidence,
10. uvést commit pouze tehdy, pokud skutečně vznikl.

Detail vlastní `docs/15-coding-agent/coding-agent-guide.md`.

---

# 7. Delivery baseline

Backlog item smí vstoupit do implementace pouze pokud je `Ready`:

- má určený release slice a vlastníka,
- má jasný výsledek a non-goals,
- odkazuje na relevantní zdroje pravdy,
- má pozorovatelná acceptance criteria,
- má známé dependencies a test approach,
- nemá skryté technologické, datové nebo doménové rozhodnutí.

Pull request ani slice není `Done` bez:

- splněných acceptance criteria,
- relevantních testů a zelených gates,
- contract/migration evidence podle dopadu,
- aktuální dokumentace,
- vyřešených blocker a critical vad.

---

# 8. Quality baseline

Pro R0 a R1 platí zejména:

- povinné static checks,
- unit testy doménových pravidel,
- skutečné SQLite/Drift integration testy,
- PostgreSQL/Testcontainers integration testy,
- OpenAPI contract tests,
- migration a recovery tests,
- automatizovaný R1 offline restart/recovery critical path,
- flaky test není zelený důkaz.

---

# 9. R0 API baseline

R0 backend poskytuje pouze:

```text
GET /api/v1/health/live
GET /api/v1/health/ready
```

Workout, identity, sync, AI ani integration API do R0 nepatří.

---

# 10. Technology baseline

Pro R0 a R1 platí:

- Flutter a Dart,
- Riverpod,
- GoRouter,
- Drift nad SQLite,
- Kotlin a Spring Boot,
- PostgreSQL a Flyway,
- OpenAPI,
- Docker Compose,
- GitHub Actions,
- Flutter tests, Spring tests a Testcontainers.

---

# 11. Repository baseline

```text
ai-trainer/
├── apps/
│   ├── mobile/
│   └── backend/
├── packages/
│   └── contracts/
├── database/
├── tooling/
├── docs/
└── .github/
```

Mobile a backend jsou samostatné aplikace. Contracts nejsou společný interní doménový model. Serverové a mobilní migrace mají oddělený lifecycle.

---

# 12. Pravidla práce s dokumentací

- Jeden význam má jeden hlavní vlastnící dokument.
- Nový dokument vznikne pouze pro skutečnou mezeru nebo samostatný kontrakt.
- AI může interpretovat a navrhovat, ale není autoritou pro doménovou změnu.
- Kritické workout flow musí fungovat bez sítě.
- Implementace postupuje po spustitelných vertical slices.
- ID se nerecyklují.
- Po dokončení startovního minima se další obecná dokumentace nevytváří místo `R0-01`, pokud audit nepotvrdí novou blokující mezeru.

Používané řady zahrnují `PP`, `FR`, `NFR`, `INV`, `ADR`, `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`, `PDR`, `APR`, `QTR`, `DRD`, `VSP`, `CAG`, `SCN`, `FLOW`, `SCR`, `AC` a `EVT`.

---

# 13. Pracovní cyklus

```text
načíst aktuální GitHub
    ↓
přečíst README a DOCUMENTATION_STATUS
    ↓
vybrat Ready backlog item
    ↓
načíst vlastnící zdroje pravdy
    ↓
implementovat nejmenší smysluplnou změnu
    ↓
spustit povinné testy a gates
    ↓
zkontrolovat diff, secrets a dokumentační dopad
    ↓
commitnout skutečnou změnu
    ↓
uvést pravdivou evidence summary
```

---

# 14. Aktuální další krok

Release 1 i Release 2 jsou uzavřené (Exit Review provedeny; otevřený dluh R2 =
emulátorová runtime evidence, postup doplnění v R2 Exit Review). Existuje kanonický
R3 vertical-slice plán (`docs/13-delivery/r3-vertical-slice-plan.md`, backlog
`R3-01` až `R3-08`, contract map C16–C24). **Celé R3 je implementováno,
R3 Exit Review proveden a Release 3 uzavřen** (otevřené řízené výjimky:
emulátorová runtime evidence, pull sync, DELETE a plán struktura mimo P0).
Existuje kanonický R4 vertical-slice plán (`docs/13-delivery/r4-vertical-slice-plan.md`,
backlog `R4-01` až `R4-08`, contract map C25–C32 — kompletní). **Celé R4 je
implementováno, R4 Exit Review proveden a Release 4 uzavřen** (otevřené
řízené výjimky: živý provider smoke, emulátorová runtime evidence, pull
sync, DELETE a plán struktura mimo P0 — viz `DOCUMENTATION_STATUS.md` §3).
Existuje kanonický R5 vertical-slice plán
(`docs/13-delivery/r5-vertical-slice-plan.md`, backlog `R5-01` až `R5-08`,
contract map C33–C40, `R5P-001..015`); **žádný R5 slice není `READY`**.
Další kanonický krok:

```text
C33 – DailyCheckIn model & persistence kontrakt → R5-01 – DailyCheckIn
```

Tvorba kontraktů ani implementace R4 nezačíná bez samostatného pokynu.

Před další prací se znovu načte aktuální `main`, ověří reálná struktura repozitáře a Ready stav podle delivery a coding-agent kontraktů.
