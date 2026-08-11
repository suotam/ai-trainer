# AI Trainer – R2 Server Data Model Contract (C6)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r2-server-data-model.md`
**Vlastník:** Data Architecture
**Poslední aktualizace:** 2026-07-29
**Kontraktní ID:** C6 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/12-data/data-architecture.md`, `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/05-architecture/initial-architecture-decisions.md` (ADR-006, ADR-011/C5), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/domain-invariants.md`, `docs/11-security/security-architecture.md`, `docs/13-delivery/repository-strategy.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** PostgreSQL/Flyway migrace (implementace R2-02+), C7 token/session storage, C8 authorization/ownership, C9 device registration, C10 sync protocol, C11 idempotency, C14 audit-event, C15 local-to-account migration
**Vlastněné pojmy nebo kontrakty:** serverový (PostgreSQL) datový model pro account/auth/profile/device/sync v R2, ownership a server-vs-client ID pravidla, Flyway migrační pravidla a pravidla `SDM-001` až `SDM-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Data Architecture.** R2 zavádí server jako autoritu sdíleného stavu (účet, session, synchronizovaná data). Aby serverové schéma vznikalo bezpečně, konzistentně s C3/C4/C5 a s jasným pravidlem server-vs-client ID, potřebuje jediný kanonický kontrakt serverového datového modelu. Tímto je C6.

C6 je **contract-only**: popisuje tabulky, sloupce (významem), ownership a ID pravidla a Flyway migrační pravidla; **neimplementuje** DDL, konkrétní Flyway soubory, ORM entity ani produkční kód.

## 1.2 Které slices blokuje

- **Blocking pro `R2-02 – Backend Account and Authentication Baseline`** (account/auth/session baseline; spolu s C3, C4, C5, auth část C14).
- **Rozšiřováno před `R2-04`** (AthleteProfile baseline + device) a před `R2-05`** (serverová reprezentace synchronizovaných entit) — stejným kontraktem a append-only migracemi (§8).

## 1.3 Vztah k C3/C4/C5/C2

- **C3** vlastní identity/session **sémantiku**; C6 je **perzistuje** (tabulky Account/Identity/AuthenticationIdentity/Session).
- **C4** vlastní auth **API**; C6 poskytuje jeho úložiště.
- **C5/ADR-011** rozhodl first-party session authority + provider-neutral adaptér; C6 podle toho drží `AuthenticationIdentity` s provider subjektem a serverem vydávané session.
- **C2** vlastní **lokální** ownership/outbox; C6 drží **serverovou** ownership a server-vs-client ID pravidlo pro pozdější sync.

---

# 2. Scope

## 2.1 Co C6 řeší

- serverové tabulky a klíčové sloupce pro **account/auth/session** (baseline, §7),
- **ownership** na serveru a **server-vs-client ID** pravidlo (§5–§6),
- **Flyway migrační pravidla** serverového schématu (§4),
- rozšiřující rozsah pro **profil/device (R2-04)** a **synchronizované entity (R2-05)** (§8),
- serverová **sync metadata** na úrovni sloupců (§9),
- invarianty `SDM-001…SDM-015` (§10),
- hranice vůči ostatním kontraktům (§11), testing/evidence (§12–§13), Ready (§14).

## 2.2 Co C6 výslovně neřeší

- **konkrétní DDL / Flyway soubory / ORM** — implementace R2-02+,
- **identity/session sémantiku** (C3) a **auth API tvar** (C4),
- **konkrétní auth provider** (C5/ADR-011 — provider-neutral),
- **mobilní schéma** (C1) — samostatný lifecycle (`RER-007`),
- **token/session storage na klientu** (C7),
- **serverovou autorizaci/ownership enforcement** (C8) — C6 drží data, C8 pravidla vynucení,
- **sync protokol / transport / idempotency replay** (C10/C11),
- **audit-event definice** (C14) a **local-to-account migraci** (C15),
- **plný AthleteProfile** (R3) — C6 drží jen R2 baseline profilu.

---

# 3. Source of truth and precedence

Pořadí vlastnictví (vyšší platí při konfliktu):

1. **Bezpečnost** — `security-architecture` (`SAR-*`, `DAR-010` no plaintext secrets).
2. **Datová architektura** — `data-architecture` (`DAR-*`) vlastní datové vlastnictví, lineage, ID a migrační principy; C6 je aplikuje na R2 server.
3. **Identity/session sémantika** — C3.
4. **ADR** — `ADR-006` (PostgreSQL/Flyway), `ADR-011` (auth strategie).
5. **R2 pořadí** — `r2-vertical-slice-plan §7.1/§9`.

C6 vlastní **konkrétní serverový datový model R2** a `SDM-*`; nevlastní body 1–4, pouze je promítá.

---

# 4. Migration philosophy (server / Flyway)

- **PostgreSQL + Flyway** (`ADR-006`), schema vzniká **výhradně přes migrace**; automatické produkční schema generation je zakázáno.
- **Append-only** — použitá migrace se nepřepisuje; oprava = nová migrace (`RER-006`, `DAR-011`).
- **Verzované, deterministické** migrace testované **od prázdné databáze** (`ADR-006`, `test-strategy`).
- **Non-destructive** v produkci — žádné tiché mazání potvrzených dat; nullable→non-null až po backfillu.
- **Integrita** — `FK`, `UNIQUE`, `CHECK` a partial unique indexy nesou invarianty (`DAR-002` relační autoritativní jádro).
- **Serverový lifecycle je oddělený** od mobilního (`RER-007`); serverové migrace žijí v `database/migrations` (z R0-05).

---

# 5. Server vs client ID policy

Klíčové rozhodnutí C6 (dle `DAR-007`, `INV-021`, C2 `LSM-013`):

- **Offline vytvořené vlastnitelné entity** (workout instance, session, performance, feedback, activity — data vzniklá na klientu) nesou **stabilní globální client-generated identifikátor** (bez serverové sekvence). **Server tento identifikátor přijímá a zachovává; nepřečíslovává jej** při synchronizaci.
- **Server-only entity** (Account, Session, serverové audit záznamy) mají **server-assigned identifikátor**.
- Identifikátory se **nerecyklují** při připojení k účtu, merge ani sync (`INV-021`, `LSM-013`).
- Server smí přidat vlastní **serverovou verzi/lineage** (§9), ale nesmí přepsat význam client ID.

Tím se serverový model přímo napojuje na C2/C15: local/anonymous data lze připojit k účtu beze změny jejich ID.

---

# 6. Ownership model (server)

- Každá vlastnitelná serverová entita nese **owner referenci na Account** (`account_id`).
- **Jeden zapisující vlastník** dané entity (`DAR-001`); server je autoritativní pro ownership (`SAR-002`), klientem dodané owner ID není důvěryhodné (`SAR-003`) — server jej ověří (enforcement vlastní **C8**).
- `AuthenticationIdentity` je vázána na `Identity`/`Account`; kombinace provider + stabilní provider subject je **unikátní** (`INV-011`).
- Ownership sloupce a jejich constraints jsou součástí baseline i rozšíření (§7–§8).

---

# 7. Baseline tables (R2-02, kontraktně)

Popsáno **významem sloupců a constraintů**, bez DDL. Baseline pokrývá account/auth/session pro R2-02.

## 7.1 `account`
- server-assigned `id`,
- odkaz na interní `identity_id`,
- stav účtu (dle `UserAccount §7.4`: ACTIVE/ONBOARDING/LIMITED/SUSPENDED/LOCKED/DELETION_PENDING/DELETED),
- typ účtu (R2 baseline: ANONYMOUS, STANDARD),
- region/jazyk/timezone (bezpečné minimum),
- `created_at`, `updated_at`, `row_version`.

## 7.2 `identity`
- server-assigned `id`,
- stav (dle `Identity §5.3`),
- bezpečnostní úroveň, `created_at`, `last_verified_at`.

## 7.3 `authentication_identity`
- `id`, `identity_id` (FK),
- `provider` (typ dle `AuthenticationIdentity §6.2`; R2 baseline dle C5 first-party + provider-neutral),
- **`provider_subject`** (stabilní externí subjekt; **UNIQUE(provider, provider_subject)** — `INV-011`),
- ověřený stav, `primary` flag, `created_at`, `last_used_at`.
- **Žádné plaintext secrets** (`DAR-010`); credential material dle security architektury a C7.

## 7.4 `auth_session`
- server-assigned `id`, `account_id` (FK),
- stav session (aktivní/revokovaná/expirovaná — sémantika C3 §5),
- vazba na zařízení (nullable v R2-02; device tabulka přijde v R2-04),
- `issued_at`, `expires_at`, `refresh` metadata (rotace/replay ochrana — hodnoty dle C7/security, ne plaintext),
- revokační značka (`revoked_at`), `row_version`.
- **Refresh/heslo se neukládají jako plaintext** (`DAR-010`, `SAR-006`).

## 7.5 `idempotency_record` (baseline pro account-creating operace)
- klíč operace (idempotency key z C4 `AAC-005`), výsledek/stav, `created_at`.
- Detailní replay sémantiku vlastní **C11**; C6 drží jen úložiště.

---

# 8. Extension scope (R2-04 / R2-05, kontraktně)

Rozšíření probíhá **append-only migracemi** v rámci tohoto kontraktu:

- **R2-04 (profil/device):** `athlete_profile` (R2 baseline: odkaz na account, sport/zkušenost minimum — plný profil je R3), `device` / `device_session` (registrace zařízení, vazba na account, odhlášení zařízení — sémantiku registrace vlastní **C9**).
- **R2-05 (synchronizované entity):** serverová reprezentace synchronizovaných workout dat (instance/session/performance/feedback/activity summary) s **client-generated ID** (§5), `account_id` ownership (§6) a sync metadaty (§9). Doménový význam vlastní R1 model; C6 drží serverové úložiště a ownership.

C6 tyto entity **vymezuje kontraktně**; jejich detailní sloupce se doplní append-only před příslušným slicem, nikdy přepsáním baseline.

---

# 9. Server sync metadata (kontraktně)

Synchronizovatelné serverové entity nesou:

- **`account_id`** ownership (§6),
- **client-generated `id`** (§5),
- **serverová verze / lineage** pro detekci konfliktu a pořadí (`DAR-005` lineage) — reprezentaci a použití při sync vlastní **C10**,
- **tombstone / deletion stav** pro logické mazání (historie se nepřepisuje, `DAR-003`),
- `created_at`, `updated_at`.

C6 **nenavrhuje sync protokol** (pořadí, cursor, batch, `ALREADY_APPLIED`) — to vlastní C10/C11; drží jen sloupce, které protokol potřebuje.

---

# 10. Server data model invariants (`SDM`)

Doplňuje, neoslabuje `DAR-*`, `PDR-*`, `INV-*`, `SAR-*`.

- **SDM-001 — Schema jen migracemi.** Serverové schéma vzniká výhradně Flyway migracemi; auto-generation zakázán (`ADR-006`).
- **SDM-002 — Append-only migrace.** Vydaná migrace se nepřepisuje; oprava je nová migrace (`RER-006`, `DAR-011`).
- **SDM-003 — Test od prázdné DB.** Každá migrace je testována od prázdné databáze nad skutečným PostgreSQL (`ADR-006`, `QTR-004`).
- **SDM-004 — Relační integrita.** Invarianty nese `FK`/`UNIQUE`/`CHECK`/partial unique index (`DAR-002`).
- **SDM-005 — Client ID se zachovává.** Offline vzniklé entity mají stabilní client-generated ID; server je nepřečíslovává (`DAR-007`).
- **SDM-006 — ID se nerecyklují.** Identifikátory se nerecyklují při připojení k účtu, merge ani sync (`INV-021`, `LSM-013`).
- **SDM-007 — Jeden zapisující vlastník.** Každá vlastnitelná entita má právě jeden autoritativní zapisující vlastník (`DAR-001`).
- **SDM-008 — Serverová ownership.** Vlastnitelná entita nese `account_id`; server ownership ověřuje, klientem dodané owner ID není důvěryhodné (`SAR-002/003`; enforcement C8).
- **SDM-009 — Unikátní login identita.** `UNIQUE(provider, provider_subject)` (`INV-011`).
- **SDM-010 — Žádné plaintext secrets.** Hesla/refresh tokeny se neukládají jako plaintext (`DAR-010`, `SAR-006`).
- **SDM-011 — Non-destructive migrace.** Žádné tiché mazání potvrzených dat; nullable→non-null až po backfillu.
- **SDM-012 — Unknown ≠ zero.** Migrace zachová rozlišitelnost chybějící/neznámé/nulové hodnoty (`DAR-015`).
- **SDM-013 — Historie se nepřepisuje.** Významné změny nemažou historii destruktivně; mazání je logické/tombstone (`DAR-003`).
- **SDM-014 — Oddělený lifecycle.** Serverové schéma a migrace jsou oddělené od mobilního (`RER-007`); serverové migrace v `database/migrations`.
- **SDM-015 — Rozšíření append-only.** Profil/device (R2-04) a synced entity (R2-05) se přidávají append-only, ne přepsáním baseline.

---

# 11. Interaction with other contracts

- **C1 (mobile schema):** oddělený lifecycle; C6 je serverová strana, C1 klientská. Server-vs-client ID (§5) je jejich most.
- **C2 (local ownership/outbox):** local/anonymous owner ↔ serverový `account_id`; client ID se zachovává (SDM-005) pro pozdější attach.
- **C3/C4/C5:** C6 perzistuje identitu/session (C3), poskytuje úložiště auth API (C4), drží provider-neutral `AuthenticationIdentity` (C5).
- **C7 (token/session storage):** klientské úložiště session materiálu; C6 drží serverovou session bez plaintext secrets.
- **C8 (authorization/ownership):** C6 drží ownership sloupce; **C8 vlastní enforcement**.
- **C9 (device registration):** device tabulky (§8) drží C6; registrační flow/sémantiku vlastní C9.
- **C10/C11 (sync/idempotency):** C6 drží sync sloupce a idempotency_record úložiště; protokol a replay resolution vlastní C10/C11.
- **C14 (audit-event):** serverové audit záznamy odkazují na account/session; definici událostí vlastní C14.
- **C15 (local-to-account migration):** attach algoritmus používá client ID zachované serverem (SDM-005); algoritmus vlastní C15.

---

# 12. Testing requirements (kontraktně)

Implementace (R2-02+) musí ověřit (`test-strategy §7/§9`, `QTR-004/005`):

- **migrace od prázdné DB** nad skutečným PostgreSQL (Testcontainers),
- **constraints** (`UNIQUE(provider, provider_subject)`, FK, CHECK) odmítají neplatná data,
- **client ID zachování** — synced entita si drží client-generated ID (SDM-005),
- **ownership** — vlastnitelná entita má `account_id`; cizí ownership je odmítnut (s C8),
- **append-only rozšíření** — R2-04/R2-05 migrace nezničí baseline data,
- **žádné plaintext secrets** v tabulkách/logu (SDM-010),
- **data-preservation** migračního testu (`QTR-005`).

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 13. Evidence gates

Implementace R2-02 (a rozšíření R2-04/R2-05) musí doložit: migration test od prázdné DB; constraint/negative testy; client-ID zachování; ownership sloupce + (s C8) enforcement; žádné plaintext secrets; data-preservation při append-only rozšíření; traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 14. Ready condition

C6 je **Done**, právě když definuje: Flyway migrační pravidla (§4), server-vs-client ID politiku (§5), server ownership (§6), baseline tabulky account/auth/session (§7), rozšiřující rozsah profil/device/sync (§8), serverová sync metadata (§9), invarianty `SDM-001…SDM-015` (§10), hranice (§11), testing/evidence (§12–§13); je zapsán v doc mapě; a neobsahuje DDL/Flyway/ORM/produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C6 je **Done**.

**Dopad na R2-02:** blokující kontrakty `R2-02` jsou C3, C4, C5, C6 a auth část C14. Dokončením C6 zbývá pro `R2-02` už jen **auth část C14**; `R2-02` zůstává `NOT_READY`, dokud C14 (auth) nevznikne. `R2-01` zůstává `READY`.

**Další kanonický krok:** **auth část C14 – Audit-event contract** (`docs/11-security/r2-audit-event-contract.md`, dle contract mapy) → poté je `R2-02` `READY`. Následně C7 (R2-03), C8/C9 (R2-04), C10/C11/C12 (R2-05/06), C15 (R2-07).

---

# 15. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — C6 map (§7.1), R2-02/04/05 (§9), invarianty (§10).
- `docs/12-data/data-architecture.md` — `DAR-001/002/003/005/007/010/011/015`.
- `docs/07-backend/r2-identity-session-contract.md` — C3; `ISC-*`.
- `docs/07-backend/r2-auth-api-contract.md` — C4; `AAC-*` (idempotency key).
- `docs/05-architecture/initial-architecture-decisions.md` — `ADR-006` (PostgreSQL/Flyway), `ADR-011` (C5 auth strategie).
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-013` stabilní ID.
- `docs/06-domain/identity-and-profile-model.md` — `Identity`, `AuthenticationIdentity`, `UserAccount`, `AthleteProfile`.
- `docs/06-domain/domain-invariants.md` — `INV-011`, `INV-021`.
- `docs/11-security/security-architecture.md` — `SAR-002/003/006`.
- `docs/13-delivery/repository-strategy.md` — `RER-006` (append-only), `RER-007` (oddělený lifecycle).
- `docs/14-quality/test-strategy.md` — `§7/§9`, `QTR-004/005/015`.
