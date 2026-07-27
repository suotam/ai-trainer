# AI Trainer – R2 Account and Sync Vertical Slice Plan

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r2-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-07-27  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/domain-invariants.md`, `docs/06-domain/domain-events.md`, `docs/07-backend/backend-architecture.md`, `docs/07-backend/r0-api-contract.md`, `docs/08-mobile/mobile-architecture.md`, `docs/10-integrations/integration-architecture.md`, `docs/11-security/security-architecture.md`, `docs/12-data/data-architecture.md`, `docs/12-data/r1-physical-data-model.md`, `docs/13-delivery/repository-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/13-delivery/r0-r1-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R2 detailní kontrakty (viz §7 a §9), OpenAPI source, PostgreSQL migrace, coding-agent/context-loading guide, issue backlog, CI workflows a implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R2, slice boundaries R2, dependencies, blocking contract map, evidence gates R2, R2 backlog decomposition, R2 Exit Review a pravidla `R2P-001` až `R2P-015`

---

# 1. Účel

Tento dokument je první kanonický implementační kontrakt pro celé **R2 – Account and Sync Slice**. Převádí hrubý scope z `release-scope.md §6` na implementovatelný vertikální plán: určuje hlavní hodnotu, hranice, kanonické pořadí slices `R2-01 …`, jejich závislosti, Definition of Ready, acceptance criteria, evidence gates, non-goals, blocking contract map a R2 Exit Review.

Dokument **nedefinuje** detailní API, SQL migrace, JWT claims ani produkční kód. Pro každý slice pouze určuje, které detailní kontrakty musí vzniknout před jeho implementací, kdo je vlastní a kde budou žít.

Vztah k `r0-r1-vertical-slice-plan.md`: ten vlastní pořadí a pravidla R0/R1 (`VSP-001` až `VSP-015`) a explicitně říká „Scope R2 až R5 se do tohoto dokumentu nepřidává". Tento dokument je jeho sourozenec pro R2 a nezavádí konkurenční zdroj pravdy pro R0/R1.

---

# 2. Delivery princip

- R2 se implementuje po slicech; každý slice má jeden ověřitelný výsledek a splněnou Definition of Ready (v návaznosti na `definition-of-ready-and-done.md`).
- **Local-first zůstává invariantem** — R1 offline kritický tok musí fungovat po celé R2 (`sync-and-offline-model §3.1/§3.2`, `release-scope RSR-004`). Žádný R2 slice nesmí učinit síť podmínkou pro zaznamenání podporované operace.
- Infrastruktura (server tabulky, endpointy, secure storage, outbox) vzniká pouze v rozsahu potřebném pro aktuální nebo bezprostředně následující slice.
- **Kontrakt předchází implementaci** — schema, API, session, sync, autorizační nebo bezpečnostní rozhodnutí musí být zdokumentované dřív, než je slice, který je používá, implementován. Slice bez svých blokujících kontraktů je `NOT_READY`.
- Backend a mobil se rozšiřují společně jen tam, kde to slice vyžaduje; nevzniká „background sync do zásoby" ani serverové API „na budoucnost".

---

# 3. Celkové pořadí

Kanonické pořadí (nejmenší bezpečný slice první; detail v §9):

```text
R2-01  Local Ownership and Sync Metadata Foundation   (mobile-only, offline)
R2-02  Backend Account and Authentication Baseline     (backend)
R2-03  Mobile Auth and Secure Session Storage          (mobile)
R2-04  AthleteProfile and Device Registration          (mobile + backend)
R2-05  Ownership Authorization and First Sync (push)   (mobile + backend)
R2-06  Conflict, Rejection and Session Revocation      (mobile + backend)
R2-07  Local-to-Account Data Migration                 (mobile + backend)
R2-08  R2 Critical End-to-End Evidence and Exit Review (mobile + backend)
```

Princip řazení:
1. Nejdřív **lokální základ** (R2-01) — data se stanou „vlastnitelná" a „synchronizovatelná" bez sítě, aniž se rozbije R1 offline.
2. Poté **serverová auth baseline** (R2-02) a **mobilní bezpečná session** (R2-03) — bez nich neexistuje účet ani ownership.
3. Poté **profil + zařízení** (R2-04), teprve pak **první skutečný sync s ownership autorizací** (R2-05).
4. **Konflikt/rejection/revokace** (R2-06) zpřesní chování syncu a session.
5. **Migrace předpřihlašovacích R1 dat pod účet** (R2-07) je samostatný, explicitně kontraktovaný krok.
6. **Kritická E2E evidence + Exit Review** (R2-08) uzavírá R2.

---

# 4. R2 value statement

**Hlavní hodnota R2:** Uživatel se bezpečně přihlásí a jeho podporovaná lokální data (profil, kalendář, workouty a výsledky session) se bezpečně a idempotentně synchronizují mezi mobilním klientem a serverem, se serverovou ownership autorizací a explicitním chováním při konfliktu, odmítnutí a revokaci — **bez ztráty potvrzené lokální skutečnosti a bez ztráty R1 offline použitelnosti**.

Hodnota je dosažena, až když: (a) existuje účet a session s bezpečným refresh chováním, (b) offline vytvořená operace přežije restart a je později idempotentně přehratelná, (c) server vynucuje ownership, (d) odmítnutá operace není prezentována jako synchronizovaná a (e) R1 kritický tok stále funguje v airplane mode.

---

# 5. Scope a non-goals

## 5.1 R2 P0 scope (dle `release-scope §6.2`)

- vytvoření účtu nebo schválená alternativní authentication baseline,
- přihlášení a odhlášení,
- bezpečná access/refresh session strategie,
- bezpečné uložení přihlašovacího stavu na mobilu,
- vytvoření základního AthleteProfile,
- registrace zařízení,
- serverová ownership autorizace,
- synchronizace podporovaných R1 dat (profil, kalendář/instance, workouty, session výsledky),
- pending operation queue (outbox) a idempotentní replay,
- základní conflict a rejection flow,
- revokace session,
- audit kritických auth a sync událostí,
- migrace existujících lokálních R1 dat pod účet,
- kritická end-to-end evidence a R2 Exit Review.

## 5.2 Non-goals R2 (dle `release-scope §6.3` a tohoto plánu)

- více AthleteProfile pod jedním účtem, trenér/sportovec, týmové role, ManagedProfile,
- pokročilá správa aktivních zařízení, trusted-device UX,
- složité collaborative konflikty a merge algoritmy,
- sociální funkce, sdílení, export/import mimo nutné minimum,
- generativní AI a AI adaptace (R4+),
- konkrétní externí auth provider bez ADR, kompletní OAuth/PKCE parametrizace,
- kompletní OpenAPI pro celý produkt, cloud deployment, microservices, event bus, Kafka,
- background sync framework „do zásoby",
- R3+ plánování.

---

# 6. Architektonické principy R2

- **Local-first (MAR/`sync-and-offline-model §3`)**: mobilní lokální DB zůstává runtime zdrojem UI; síť není podmínkou pro zápis podporované operace; pending operace přežijí restart.
- **Server je autoritativní pro sdílený dlouhodobý stav** (`sync-and-offline-model §3.3`), ale nesmí tiše smazat potvrzenou lokální skutečnost (`§3.4`).
- **Idempotence (`§3.5`, `SAR-011`)**: replay stejné operace nesmí vytvořit duplicitu; server drží IdempotencyRecord a vrací `ALREADY_APPLIED`.
- **Konflikt je normální doménový stav (`§3.6`)** — má explicitní stav (SyncState `CONFLICT`), ne skrytý error; odmítnutá operace není „synchronizovaná".
- **Bezpečnost (`SAR-001` default deny, `SAR-002` server-side authorization, `SAR-003` nedůvěryhodný klient, `SAR-004` least privilege, `SAR-006` secrets mimo klienta, `SAR-007` revokovatelné session, `SAR-011` bezpečný offline replay, `SAR-012` bezpečné logování, `SAR-013` abuse protection, `SAR-014` security release gate)** jsou závazné.
- **Terminologická separace**: auth **access/refresh session** ≠ **WorkoutSession** (R1) ≠ **lokální aplikační session**. Plán ani navazující kontrakty nesmí tyto pojmy sloučit (viz §8 a `glossary`).
- **Provider-neutral auth boundary**: konkrétní externí auth provider není v dokumentaci rozhodnut (`integration-architecture` odkládá provider ADR a OAuth detaily); R2 zavádí neutral contract boundary a otevřené ADR rozhodnutí, ne provider-specific implementaci.
- **Append-only a historická interpretovatelnost** (`data-architecture DAR-003`, `sync-and-offline-model §29`): historie, session a výkon se nepřepisují aktuálním stavem ani synchronizací.

---

# 7. Prerequisites

Před implementací **kteréhokoli** R2 slice platí obecné prerequisites:

1. R0 a R1 jsou uzavřené a mergnuté (splněno; R1 Exit Review proveden).
2. Existuje tento vertical-slice plán (tento dokument).
3. Pro každý slice existují jeho **blocking detailní kontrakty** (viz §9 a contract map níže). Dokud neexistují, je slice `NOT_READY`.
4. Auth provider rozhodnutí: buď přijaté ADR, nebo potvrzený provider-neutral boundary (blocking pro R2-02).

## 7.1 Blocking contract map

Tento plán **nevytváří** detailní kontrakty. Pouze určuje vlastníka, kanonickou cestu, před kterým slicem musí vzniknout, minimální obsah a zda je blocking. Cesty jsou návrhy konzistentní s existující strukturou `docs/`.

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Blocking | Minimum |
|---|---|---|---|---|---|---|
| C1 | Mobile schema migration contract (R2, v1→v2) | Data Architecture | `docs/12-data/r2-mobile-schema-migration.md` | R2-01 | ano | verze schématu, sync/owner sloupce, zachování všech R1 dat, migrační test od reálného v1 |
| C2 | Local ownership & outbox/pending-operation contract | Domain (sync-and-offline-model) | `docs/12-data/r2-local-sync-metadata-contract.md` | R2-01 | ano | local owner identity, SyncState, LocalChangeLog/OfflineCommand, idempotency key, restart-safe queue |
| C3 | Identity & session contract (Account, AuthenticationIdentity, access/refresh session) | Domain (identity-and-profile-model) + Backend | `docs/07-backend/r2-identity-session-contract.md` | R2-02 | ano | stavy účtu, session lifecycle, refresh strategie, revokace, hranice vůči WorkoutSession |
| C4 | Authentication API contract (register/login/logout/refresh) | Backend Architecture | `docs/07-backend/r2-auth-api-contract.md` (+ OpenAPI source) | R2-02 | ano | endpointy, error envelope (APR), rate limiting baseline, contract-test hook |
| C5 | Auth provider ADR (neutral boundary vs konkrétní provider) | Architecture (ADR) | `docs/05-architecture/…` ADR záznam | R2-02 | ano | rozhodnutí nebo explicitní neutral boundary + otevřené rozhodnutí |
| C6 | Server data model (account/auth/profile/device/sync) | Data Architecture | `docs/12-data/r2-server-data-model.md` | R2-02 (rozšiřováno před R2-04/R2-05) | ano | tabulky, ownership sloupce, server vs client ID, PostgreSQL/Flyway pravidla |
| C7 | Token/session storage contract (mobile secure storage) | Security + Mobile | `docs/11-security/r2-token-session-storage-contract.md` | R2-03 | ano | žádný refresh token/heslo v běžné SQLite, secure storage boundary, restart chování |
| C8 | Authorization/ownership contract (server-side enforcement) | Security (SAR) + Backend | `docs/11-security/r2-authorization-ownership-contract.md` | R2-04 (device binding) / R2-05 (sync) | ano | default deny, server-side ownership, zákaz spoléhat jen na client owner ID |
| C9 | Device registration contract | Backend + Domain (sync-and-offline-model) | `docs/07-backend/r2-device-registration-contract.md` | R2-04 | ano | DeviceInstallation/DeviceSession, registrace, vazba na účet, odhlášení zařízení |
| C10 | Sync protocol contract (push/pull, batch, cursor, ordering) | Domain (sync-and-offline-model) + Backend | `docs/07-backend/r2-sync-protocol-contract.md` | R2-05 | ano | push/pull, pořadí, SyncOperationType, priority, checkpoint/cursor |
| C11 | Idempotency contract | Domain (sync-and-offline-model) + Backend | součást C10 nebo `docs/12-data/r2-idempotency-contract.md` | R2-05 | ano | idempotency key, IdempotencyRecord, `ALREADY_APPLIED`, rozdílný payload se stejným klíčem |
| C12 | Conflict/rejection contract | Domain (sync-and-offline-model) | součást C10 nebo `docs/07-backend/r2-conflict-rejection-contract.md` | R2-06 | ano | SyncConflict, ConflictResolution, rejection stav, „ne synchronizováno" |
| C13 | Token/session revocation contract | Security + Backend | součást C3/C7 | R2-06 | ano | revokace session/refresh, chování klienta po revokaci |
| C14 | Audit-event contract (auth + sync kritické události) | Domain (domain-events) + Security | `docs/11-security/r2-audit-event-contract.md` | R2-02 (auth) / R2-05 (sync) | ano pro pokryté události, non-blocking scaffolding | seznam auditovaných událostí, bez citlivého payloadu |
| C15 | Local-to-account migration contract (předpřihlašovací data) | Data Architecture + Domain | `docs/12-data/r2-local-to-account-migration-contract.md` | R2-07 | ano | anonymous→account attach, duplicitní ochrana, stabilita lokálních ID, seed vs user data |

Přesná finální jména a případné sloučení kontraktů určí owning tým při jejich autorizaci; toto je návrh, ne závazný název souboru.

---

# 8. Identity a authentication hranice

Plán a navazující kontrakty musí důsledně odlišit (zdroj: `identity-and-profile-model`, `sync-and-offline-model`, `glossary`):

- **UserAccount** — účet (přihlašovací identita a vlastník dat).
- **AuthenticationIdentity** — konkrétní způsob přihlášení k účtu (jeden účet, více způsobů).
- **AthleteProfile** — „pro koho se plánuje a vyhodnocuje trénink"; není přihlašovací identita.
- **DeviceInstallation / DeviceSession** — zařízení a jeho session vůči účtu.
- **access session** — krátce žijící autorizace požadavku.
- **refresh session** — delší, revokovatelný materiál pro obnovu access session.
- **authorization / ownership** — serverové vynucení, kdo smí číst/měnit data.
- **lokální aplikační session** — runtime stav appky, ne auth.
- **WorkoutSession (R1)** — doménová session tréninku; **nesmí** být zaměněna s auth session.

**Kolizní pravidlo:** žádný R2 dokument, název, typ ani endpoint nesmí použít pojem „session" bez kvalifikace, která odliší auth session, device session, lokální aplikační session a WorkoutSession.

**Provider:** externí auth provider není rozhodnut. Do přijetí ADR (C5) se používá provider-neutral contract boundary a otevřené rozhodnutí se eviduje (viz §12).

---

# 9. Detail každého slice

Formát: Výsledek / Scope / Non-goals / Blocking kontrakty / Ready / Acceptance a evidence gate. Konkrétní testy a evidence viz i §11.

## 9.1 R2-01 – Local Ownership and Sync Metadata Foundation

**Výsledek:** Lokální R1 data jsou připravena být vlastnitelná a synchronizovatelná — lokální owner identity a sync metadata (SyncState, verze, outbox) existují — **bez sítě a bez rozbití R1 offline toku**.

**Scope:**
- schema verze 2 s explicitní migrací `v1 → v2`, která zachová všechna R1 data (instance, sessions, performances, feedback, summaries, `local_app_state`),
- lokální owner identity (anonymous/local owner) na vlastnitelných entitách,
- sync metadata: `SyncState` (LOCAL_ONLY/DIRTY/QUEUED/CONFLICT/BLOCKED), verze entity, outbox (LocalChangeLog/OfflineCommand) se stabilním idempotency key,
- restart-safe pending queue scaffolding (bez odesílání).

**Non-goals:** jakýkoli síťový přenos, server, přihlášení, konflikt resolution.

**Blocking kontrakty:** C1 (mobile schema migration), C2 (local ownership & outbox).

**Ready:** `NOT_READY` dokud neexistují C1 a C2.

**Acceptance / evidence gate:** migrační test z reálného v1 stavu prokáže zachování dat a aktivní session; outbox položka přežije restart; R1 offline kritický tok beze změny; drift-check generovaného kódu čistý.

## 9.2 R2-02 – Backend Account and Authentication Baseline

**Výsledek:** Server umí založit účet a přihlásit/odhlásit uživatele a vydat access/refresh session podle schválené baseline.

**Scope:** první auth endpointy (register/login/logout/refresh) dle C4; PostgreSQL/Flyway migrace pro account/auth dle C6; vydání a revokovatelnost session dle C3; rate limiting a bezpečné error responses (`SAR-013`, `SAR-015`); audit auth událostí dle C14.

**Non-goals:** mobilní UI, profil, device, sync, konkrétní provider bez ADR.

**Blocking kontrakty:** C3, C4, C5, C6 (account/auth část), C14 (auth události).

**Ready:** `NOT_READY` dokud neexistují C3–C6.

**Acceptance / evidence gate:** Testcontainers PostgreSQL testy; API contract testy proti OpenAPI; security-negative testy (default deny, neplatné credentials, rate limit); žádné secrets/tokeny v logu; auth události auditovány bez citlivého payloadu.

## 9.3 R2-03 – Mobile Auth and Secure Session Storage

**Výsledek:** Uživatel se na mobilu přihlásí a odhlásí; přihlašovací stav je bezpečně uložen a přežije restart; R1 offline tok zůstává funkční i bez přihlášení.

**Scope:** login/logout UI a auth state composition; bezpečné uložení session/credential materiálu (C7) — **žádný refresh token/heslo v běžné SQLite**; obnova access session; recovery po restartu se zachovanou session.

**Non-goals:** sync, profil, device registration, konflikt.

**Blocking kontrakty:** C7 (token/session storage), C4 (auth API z R2-02).

**Ready:** `NOT_READY` dokud neexistuje C7.

**Acceptance / evidence gate:** widget/integration testy login/logout; test, že citlivý materiál není v Drift/SQLite; restart-with-session test; R1 offline flow beze změny; security-negative (logout skutečně zneplatní lokální session).

## 9.4 R2-04 – AthleteProfile and Device Registration

**Výsledek:** Přihlášený uživatel má základní AthleteProfile a jeho zařízení je registrováno vůči účtu se serverovou ownership vazbou.

**Scope:** vytvoření základního AthleteProfile (server + minimální mobilní UI); registrace zařízení (DeviceInstallation/DeviceSession) dle C9; serverové ownership propojení účet–profil–zařízení dle C8.

**Non-goals:** více profilů, role, pokročilá správa zařízení, sync dat.

**Blocking kontrakty:** C9 (device registration), C8 (authorization/ownership), C6 (rozšíření server data modelu o profil/device).

**Ready:** `NOT_READY` dokud neexistují C8, C9 (a rozšíření C6).

**Acceptance / evidence gate:** Testcontainers testy profilu/zařízení; ownership negativní testy (cizí účet nesmí číst/měnit); API contract testy; audit registrace.

## 9.5 R2-05 – Ownership Authorization and First Sync (push)

**Výsledek:** Podporovaná lokální data vytvořená po přihlášení se **idempotentně** nahrají na server s ownership autorizací; pending operace se přehrají z outboxu; potvrzení přijde až po serverovém commitu.

**Scope:** první sync endpoint (push) dle C10; ownership enforcement (C8); idempotentní replay a IdempotencyRecord (C11); pending-operation queue replay z R2-01 outboxu; explicitní sync stavy; audit sync událostí (C14).

**Non-goals:** pull sync nad rámec nutného potvrzení, konflikt resolution UX, migrace předpřihlašovacích dat, background framework.

**Blocking kontrakty:** C10 (sync protocol), C11 (idempotency), C8 (ownership), C6 (server data model pro synced entity), C14 (sync události).

**Ready:** `NOT_READY` dokud neexistují C10, C11 a rozšíření C6/C8.

**Acceptance / evidence gate:** idempotency/replay testy (druhý push → `ALREADY_APPLIED`, žádná duplicita); ownership negativní testy; offline-create → later-replay test; restart uprostřed pending syncu; odmítnutá operace není označena jako synchronizovaná; potvrzeno až po commitu (`data-architecture DAR`, `SAR-011`).

## 9.6 R2-06 – Conflict, Rejection and Session Revocation

**Výsledek:** Konflikt a odmítnutí mají explicitní stav a bezpečné UI; revokace session je vynutitelná a klient na ni bezpečně reaguje.

**Scope:** SyncConflict/ConflictResolution a rejection flow dle C12; revokace session/refresh dle C13; klientské chování po revokaci (bezpečné odhlášení bez ztráty lokálních dat).

**Non-goals:** složité collaborative merge, více-zařízení konfliktní politika nad rámec baseline.

**Blocking kontrakty:** C12 (conflict/rejection), C13 (revocation).

**Ready:** `NOT_READY` dokud neexistují C12 a C13.

**Acceptance / evidence gate:** conflict/rejection testy (explicitní stav, ne skrytý success); revocation test (revokovaná session ztratí přístup, lokální potvrzená data zůstanou); security-negative (revokovaný refresh nelze použít).

## 9.7 R2-07 – Local-to-Account Data Migration

**Výsledek:** Data vytvořená před přihlášením se bezpečně připojí k účtu při prvním přihlášení/syncu — bez duplicit, se stabilními lokálními ID a bez ztráty historie, sessions, feedbacku a výkonu.

**Scope:** připojení anonymous/local owner dat k účtu dle C15; ochrana proti duplicitě při prvním syncu; stabilita existujících lokálních ID vs serverová ID; odlišení seed/demo dat od uživatelských; bezpečné odhlášení bez ztráty lokálních dat.

**Non-goals:** merge více účtů, ProfileMergeRequest, cross-account transfer.

**Blocking kontrakty:** C15 (local-to-account migration), návazně C11 (idempotency).

**Ready:** `NOT_READY` dokud neexistuje C15.

**Acceptance / evidence gate:** migrační/persistence testy (předpřihlašovací data se připojí bez duplicit, ID stabilní); idempotentní opakování attach; logout bez ztráty lokálních dat; seed data se nesynchronizují jako uživatelská, pokud to kontrakt zakazuje.

## 9.8 R2-08 – R2 Critical End-to-End Evidence and Exit Review

**Výsledek:** Existuje automatizovaný důkaz hlavní hodnoty R2 a proveden R2 Exit Review.

**Scope:** automatizovaný kritický E2E scénář (viz §11) a doložení R2 Exit Review (§13) s odkazy na konkrétní CI runy, testy a manuální ověření.

**Non-goals:** nové business funkce.

**Blocking kontrakty:** žádné nové — konzumuje výstupy R2-01…R2-07.

**Ready:** `NOT_READY` dokud nejsou R2-01…R2-07 hotové a jejich kontrakty existují.

**Acceptance / evidence gate:** deterministický E2E test na podporovaném runtime; failure artefakty pro diagnostiku; flaky výsledek není zelený důkaz; R2 Exit Review kritéria splněna.

---

# 10. Cross-slice invariants

Platí po celé R2 (porušení blokuje merge):

1. **R1 offline kritický tok funguje v airplane mode** kdykoli v průběhu R2 (`RSR-004`, `sync-and-offline-model §3.1`).
2. Mobilní lokální DB je runtime zdroj UI; síť není podmínkou pro zápis podporované operace.
3. **Pending operace přežije restart**; replay je idempotentní; duplicita nevzniká.
4. **Server vynucuje ownership a autorizaci** (`SAR-001/002/003`); klientem dodané owner ID není samo o sobě důvěryhodné.
5. **Odmítnutá operace není prezentována jako synchronizovaná**; konflikt má explicitní stav.
6. **Potvrzená lokální skutečnost tiše nezmizí** (`sync-and-offline-model §3.4`).
7. **Sync nepřepíše aktivní lokální WorkoutSession** bez schváleného pravidla.
8. **Žádné heslo ani refresh token v běžné SQLite ani v logu** (`SAR-006/012`, C7).
9. **Access session je krátce žijící a revokovatelná** (`SAR-007`).
10. Terminologická separace auth session / device session / lokální aplikační session / WorkoutSession se neporušuje.
11. Historie, session a výkon se nepřepisují aktuálním stavem ani synchronizací (`DAR-003`).
12. Migrace zachovají aktivní session a všechny potvrzené performance/feedback záznamy.

---

# 11. Testovací a evidence strategie

Pro každý slice (v návaznosti na `test-strategy.md`, `definition-of-ready-and-done.md`):

- **Unit tests** — doménové přechody, session lifecycle, idempotency rozhodnutí, mapování DTO bez UI/sítě.
- **Mobile SQLite/Drift integration tests** — migrace (od reálného v1), outbox persistence, restart recovery, sync stavy nad skutečnou SQLite.
- **Backend PostgreSQL/Testcontainers tests** — auth, ownership, sync, idempotency, konflikt nad skutečným enginem.
- **API contract tests** — soulad OpenAPI a implementace pro auth/profile/device/sync endpointy.
- **Security-negative tests** — default deny, neplatné/expirované/revokované credentials, cizí ownership, rate limit, žádné secrets v logu.
- **Restart/recovery tests** — restart uprostřed pending syncu; session přežije restart.
- **Idempotency/replay tests** — druhý pokus → `ALREADY_APPLIED`, žádná duplicita; rozdílný payload se stejným klíčem je odmítnut.
- **Conflict/rejection tests** — explicitní stav, ne skrytý success.
- **Runtime evidence** — skutečné ověření na podporovaném runtime (mobile + backend), bez předstírání.

**PR CI vs kritická E2E:** V běžném PR CI běží unit, mobile Drift integration, backend Testcontainers, API contract a security-negative testy daného slice. **Kritická cross-slice E2E** (register → login → offline create → sync → idempotent replay → conflict/rejection → revocation → logout, bez ztráty dat) je vlastněna R2-08 a smí být samostatný kritický důkaz, ale musí být deterministická. **Flaky výsledek se nepovažuje za zelený důkaz** (`QTR`).

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Auth provider není rozhodnut** — R2 používá provider-neutral boundary; přijetí konkrétního providera je otevřené ADR (C5), blocking pro R2-02.
- **Server ID vs client-generated ID** — přesné pravidlo vlastní C6/C2; do jeho přijetí zůstává klient-generovaný stabilní offline identifikátor (`sync-and-offline-model §9`).
- **Seed/demo vs uživatelská data při migraci** — přesné pravidlo vlastní C15; do té doby se seed data nepovažují za synchronizovatelná uživatelská data.
- **Pull sync rozsah** — R2 P0 cílí primárně push + potvrzení; širší pull/merge je mimo P0, upřesní C10.
- Výjimky přenesené z R1 (aktivní čas workoutu = 0, kanonizace `feeling` kódů) nejsou R2 blocker; řeší je příslušné produktové slices, ne tento plán.

---

# 13. R2 Exit Review

R2 je dokončeno pouze pokud (doloženo konkrétními CI runy, testy a manuálním ověřením — analogicky R1 Exit Review):

- registrace/přihlášení podle zvolené baseline funguje,
- access/refresh session se chová bezpečně (krátký access, revokovatelný refresh, žádné tokeny v běžné SQLite/logu),
- restart aplikace zachová session podle kontraktu,
- logout a revokace fungují a nezpůsobí ztrátu lokálních dat,
- server vynucuje ownership,
- registrace zařízení funguje,
- podporovaná R1 data se synchronizují,
- offline vytvořená operace se později idempotentně přehraje,
- opakování operace nevytvoří duplicitu,
- konflikt i odmítnutí mají explicitní stav,
- **R1 offline kritický tok zůstává funkční**,
- žádné secrets ani tokeny v logu či běžné SQLite,
- CI (repository, mobile, backend) zelené a kritická E2E evidence deterministicky prochází,
- žádný známý blocker ani critical defect.

R2 Exit Review musí odkazovat na konkrétní CI runy, testy a manuální platformní ověření požadované `definition-of-ready-and-done.md`.

---

# 14. Pravidla R2P

- **R2P-001:** R2 se implementuje v pořadí respektujícím dependencies v §3; nejmenší bezpečný slice první.
- **R2P-002:** Každý slice má jeden ověřitelný výsledek a splněnou Definition of Ready; bez blokujících kontraktů je `NOT_READY`.
- **R2P-003:** Kontrakt (schema/API/session/sync/authorization/security) předchází implementaci, která ho používá.
- **R2P-004:** Local-first je invariant — žádný R2 slice nesmí učinit síť podmínkou pro zápis podporované operace ani rozbít R1 offline kritický tok.
- **R2P-005:** Server vynucuje ownership a autorizaci; klientem dodané owner ID není samo o sobě důvěryhodné.
- **R2P-006:** Sync replay je idempotentní; opakování nevytvoří duplicitu; potvrzení přijde až po serverovém commitu.
- **R2P-007:** Odmítnutá nebo konfliktní operace má explicitní stav a nesmí být prezentována jako synchronizovaná.
- **R2P-008:** Potvrzená lokální skutečnost tiše nezmizí; sync nepřepíše aktivní WorkoutSession bez schváleného pravidla.
- **R2P-009:** Žádné heslo ani refresh token v běžné SQLite ani v logu; citlivý materiál v bezpečném úložišti; access session krátce žijící a revokovatelná.
- **R2P-010:** Auth session, device session, lokální aplikační session a WorkoutSession jsou oddělené pojmy bez terminologické kolize.
- **R2P-011:** Externí auth provider se nezavádí bez ADR; do té doby platí provider-neutral boundary a otevřené rozhodnutí.
- **R2P-012:** Infrastruktura (server tabulky, endpointy, outbox, secure storage) vzniká jen v rozsahu potřebném pro aktuální nebo bezprostředně následující slice; žádný background sync „do zásoby".
- **R2P-013:** Migrace zachovají aktivní session a všechny potvrzené performance/feedback záznamy; předpřihlašovací data se připojí bez duplicit a se stabilními lokálními ID.
- **R2P-014:** Každý slice má security-negative, idempotency/replay a restart/recovery evidenci úměrnou riziku; flaky výsledek není zelený důkaz.
- **R2P-015:** Scope R0/R1 se do tohoto dokumentu nepřidává; `r0-r1-vertical-slice-plan.md` zůstává vlastníkem R0/R1 a řady `VSP`.

---

# 15. Další krok

R2 backlog (`R2-01` až `R2-08`) je **definovaný, ale zatím není žádný slice `READY`** — všechny čekají na své blokující detailní kontrakty (§7.1). Implementace R2 nezačala.

**Přesný další kanonický dokumentační krok:** vytvořit blokující kontrakty pro **R2-01**, tj. **C1 – Mobile schema migration contract** (`docs/12-data/r2-mobile-schema-migration.md`) a **C2 – Local ownership & outbox/pending-operation contract** (`docs/12-data/r2-local-sync-metadata-contract.md`). Teprve po jejich vzniku a Ready kontrole lze zahájit implementaci `R2-01`.
