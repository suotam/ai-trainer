# AI Trainer – R2 Identity & Session Contract (C3)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r2-identity-session-contract.md`
**Vlastník:** Domain (identity-and-profile-model) + Backend Architecture
**Poslední aktualizace:** 2026-07-29
**Kontraktní ID:** C3 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/identity-and-profile-model.md`, `docs/11-security/security-architecture.md`, `docs/07-backend/backend-architecture.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/domain-invariants.md`, `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-mobile-schema-migration.md` (C1), `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** C4 authentication API, C5 auth provider ADR, C6 server data model, C7 token/session storage, C13 session revocation, C15 local-to-account migration
**Vlastněné pojmy nebo kontrakty:** R2 identity model (anonymous/authenticated/account/device), session lifecycle (access/refresh), identity transitions, hranice vůči WorkoutSession a pravidla `ISC-001` až `ISC-015`

---

# 1. Purpose

## 1.1 Owner

**Domain (identity-and-profile-model) + Backend Architecture.** Konceptuální pojmy `Identity`, `AuthenticationIdentity`, `UserAccount`, `UserStatus` vlastní `identity-and-profile-model.md`; session a bezpečnostní pravidla vlastní `security-architecture.md`. C3 z nich odvozuje **kanonický R2 identity & session kontrakt** a nepředefinovává je.

## 1.2 Důvod existence

R2 přináší účet a synchronizaci. Server musí umět reprezentovat **kdo** uživatel je (identita/účet), spravovat **session** (access/refresh), a bezpečně řešit **přechod z anonymního na účet** bez ztráty a bez duplicit. Chybí jediný kanonický kontrakt těchto pojmů na úrovni R2; `identity-and-profile-model.md` je široký doménový model, ne R2-scoped kontrakt. Tímto kontraktem je C3.

C3 je **contract-only**: neobsahuje HTTP API, endpointy, DB migrace, JWT/OAuth implementaci ani produkční kód.

## 1.3 Vztah k R2

C3 definuje identity/session model, o který se opírají auth endpointy (C4), mobilní auth (R2-03), ownership autorizace (C8/R2-05), revokace (C13/R2-06) a local-to-account migrace (C15/R2-07). Terminologicky odděluje auth session od `WorkoutSession` (R1) i lokální aplikační session (§8, `r2-vertical-slice-plan §8`).

## 1.4 Které slices blokuje

- **Blocking pro `R2-02 – Backend Account and Authentication Baseline`** (spolu s C4, C5, C6 a auth částí C14; `r2-vertical-slice-plan §9.2`).
- C3 je referencováno pozdějšími R2 slices (mobilní session v R2-03, revokace v R2-06, migrace v R2-07), jejichž vlastní blocking kontrakty jsou samostatné (§10).

---

# 2. Scope

## 2.1 Co tento kontrakt řeší

- **identity model** R2: anonymous, authenticated, account, device identity (§4),
- **session lifecycle**: logické stavy access a refresh session (§5),
- **identity transitions**: anonymous → account, account → signed-out, signed-out → authenticated (§6),
- **ownership interakce** identity ↔ C2 (§7),
- **security boundaries** identity/session (§8),
- **identity invarianty** `ISC-001…ISC-015` (§9),
- hranice vůči budoucím kontraktům (§10),
- testing requirements a evidence gates (§11–§12),
- Ready condition (§13).

## 2.2 Co tento kontrakt výslovně neřeší

- **HTTP API, endpointy, request/response, error envelope** — C4 (+ OpenAPI),
- **transport** a on-the-wire detaily — C4/C10,
- **databázové schéma** účtu/identity/session — C6 (server) a implementace,
- **konkrétní auth provider / JWT claims / OAuth flow** — C5 (ADR); C3 je provider-neutral,
- **synchronizační protokol** — C10,
- **conflict/rejection resolution** — C12,
- **mobilní secure storage** session materiálu — C7 (C3 definuje lifecycle, ne úložiště),
- **algoritmus připojení lokálních dat k účtu** — C15 (C3 vlastní jen identity transition),
- **revokační operační flow R2-06** — C13 (C3 vlastní revokační *sémantiku* v modelu),
- **AthleteProfile a device registration** — R2-04 (C9); C3 se profilu ani registrace zařízení nedotýká nad rámec vazby session↔device.

---

# 3. Source of truth

## 3.1 Jediný zdroj pravdy

Pro **R2 identity & session model** (identity kinds, session lifecycle stavy, identity transitions, jejich bezpečnostní pravidla a `ISC-*`) je jediným zdrojem pravdy tento dokument. Skutečný rozpor s vlastníky níže se řeší změnou dokumentu, ne tichou odchylkou.

## 3.2 Vztah k dalším zdrojům

- **`identity-and-profile-model.md`** vlastní `Identity` (§5), `AuthenticationIdentity` (§6, typy vč. `ANONYMOUS`), `UserAccount` (§7, typy/stavy), `UserStatus` (§8), `AthleteProfile` (§9). C3 je promítá do R2 kontraktu; nepředefinovává je.
- **`security-architecture.md`** vlastní session/token/revokace pravidla (`SAR-*`, §7 session management, §7.3 offline session). C3 na ně odkazuje.
- **`sync-and-offline-model.md`** vlastní offline garance a serverovou re-verifikaci principal/session při synchronizaci. C3 dodává identity/session, které sync re-verifikuje.
- **C2 (`r2-local-sync-metadata-contract.md`)** vlastní lokální ownership metadata a outbox. C3 vlastní identitu vlastníka (account) a anonymous identitu (§7).
- **`r2-vertical-slice-plan.md`** vlastní pořadí, contract mapu (§7.1), R2-02 (§9.2), identity hranice (§8), cross-slice invarianty (§10).

---

# 4. Identity model (kontraktně)

Bez implementace; hodnoty referencují `identity-and-profile-model.md`.

## 4.1 Anonymous identity

První použití je možné **anonymně** (`identity-and-profile-model §2`, `AuthenticationIdentity` typ `ANONYMOUS §6.2`, `UserAccount` typ `ANONYMOUS §7.3`). Anonymní identita je **plnohodnotná lokální identita**, ke které patří local/anonymous owner z C2 (§7). Umožňuje R1-styl offline používání i v R2.

## 4.2 Authenticated identity

Konkrétní způsob autentizace (`AuthenticationIdentity §6`: EMAIL_PASSWORD, MAGIC_LINK, GOOGLE, APPLE, PASSKEY, … a ANONYMOUS). Provider subject musí být **stabilní** identifikátor; samotný e-mail není jediným identifikátorem (`§6.4`). Konkrétní provider(y) rozhoduje C5 (ADR); C3 je provider-neutral.

## 4.3 Account identity

`UserAccount` (`§7`) je produktový účet nesoucí vlastnictví dat, stav a vazbu na profil(y). `Identity` (`§5`) je vnitřní identita, na kterou může směřovat více `AuthenticationIdentity` (`§5.4`). C3 pracuje s minimem R2: anonymous a standardní account; ostatní typy/role (COACH, GUARDIAN, ORGANIZATION_MEMBER) jsou R2 non-goal (`release-scope §6.3`).

## 4.4 Device identity

Session smí být **vázána na zařízení** (`security-architecture §7.2` — refresh vázán na session/zařízení). C3 device identitu používá pouze jako **cíl vazby** session; **registraci zařízení** vlastní R2-04 (C9), ne C3.

## 4.5 Oddělení pojmů

`Identity` ≠ `UserAccount` ≠ `AthleteProfile` jsou oddělené pojmy (`INV-010`); jeden nesmí neřízeně suplovat druhý.

---

# 5. Session lifecycle (logické stavy)

Kontraktní logické stavy; bez transportu, bez token formátu.

- **created** — session vznikne po úspěšné autentizaci (nebo pro anonymní identitu jako lokální session bez serverového oprávnění nad rámec dříve synchronizovaných dat).
- **active** — access session je **krátce žijící** (`security-architecture §7`) a opravňuje k chráněným operacím do expirace.
- **refreshed** — dlouhodobá **refresh credential** obnoví access session; refresh má rotaci nebo ekvivalentní replay ochranu, vazbu na session/zařízení a detekci opakovaného použití kompromitovaného tokenu (`§7.2`). Strategii rotace vlastní tento kontrakt na úrovni pravidel; konkrétní token format vlastní C5/C4.
- **expired** — access session po vypršení nemá oprávnění; pokračování vyžaduje refresh nebo re-autentizaci.
- **terminated / revoked** — logout nebo revokace ukončí session; **revokovaná session nesmí potvrdit nové serverové operace** (`§7.3`, `SAR-007`). Individuální i globální revokace musí být možná (`§7.2`).

Session je **serverem evidovaná** tak, aby šlo zobrazit aktivní session, revokovat jednu/všechny a svázat security event s principal a session identitou (`security-architecture §16`/§ session management). Offline: platná lokální session smí zpřístupnit dříve synchronizovaná data, ale **nesmí obnovit serverové oprávnění po revokaci** (`§7.3`).

---

# 6. Identity transitions

Popsáno logicky, bez API/endpointů (ty vlastní C4).

## 6.1 anonymous → account

Anonymní uživatel se zaregistruje/přihlásí. Přechod **musí zachovat** existující lokální data (profil, workouty, activity, session, feedback, pending operace) a **nesmí vytvořit druhý účet ani profil** (`INV-013`, `ISC-005`). Přechod je idempotentní (retry nevytvoří duplicitu). Samotný **algoritmus připojení lokálních dat k účtu** (owner rewrite, řešení duplicit, stabilita ID) vlastní **C15**; C3 vlastní identity přechod a jeho invarianty.

## 6.2 account → signed-out

Odhlášení ukončí aktivní session (§5). **Nesmí ztratit lokální data** — odhlášený stav se vrací k local/anonymous ownership pro čtení a k bezpečnému recovery stavu neodeslaných změn (`security-architecture §7.3`, C2 `LSM-006`). Odhlášení není smazání účtu.

## 6.3 signed-out → authenticated

Opětovné přihlášení ustaví novou session (§5) pro existující identitu/účet. Musí respektovat stav účtu (`UserAccount §7.4`); `SUSPENDED`/`LOCKED`/`DELETION_PENDING`/`DELETED` nesmí být obejity a **pozdní offline operace nesmí obnovit autoritativně zrušený účet** (`INV-014`, `ISC-010`).

---

# 7. Ownership interaction (identity ↔ C2)

| Aspekt | Vlastní **C3** (identity & session) | Vlastní **C2** (local ownership & outbox) |
|---|---|---|
| Kdo je **account owner** (identita účtu) | ano | ne |
| Anonymous **identita** jako subjekt | ano | ne (C2 drží jen owner *referenci*) |
| Session lifecycle a autentizace | ano | ne |
| **Lokální owner reference** na entitách | ne | ano (`LSM-001`) |
| Lokální **sync metadata / outbox** lifecycle | ne | ano |
| **Identity transition** anonymous → account | ano (§6.1) | ne |
| **Data-attach algoritmus** při transition | ne (C15) | ne (C15) |
| Serverové **vynucení** ownership | ne (C8) | ne (C8) |

Vazba: C2 „local/anonymous owner" odpovídá anonymní identitě z C3 (§4.1); „account owner" odpovídá `UserAccount` z C3 (§4.3). Přechod mezi nimi definuje C3 (§6.1); jeho datové provedení C15; serverovou autorizaci C8.

---

# 8. Security boundaries

Pouze kontraktně, odvozeno z `security-architecture.md`:

- **Server je autorita** pro identitu, účet, session a oprávnění (`SAR-002`); klient identitu ani oprávnění **neurčuje** (`SAR-003`).
- **Session není sama o sobě trust boundary** — server na každé chráněné hranici re-ověří principal, session stav, resource ownership, capability, idempotency identity, schema verzi a doménové invarianty (`security-architecture §` server re-verify, `SAR-009`).
- **Revokovatelnost** session a credentials je povinná (`SAR-007`); revokovaná session nepotvrdí nové operace (`§7.3`).
- **Secrets mimo klienta** — hesla ani refresh tokeny nesmí být v běžné SQLite ani v logu (`SAR-006/012`); jejich mobilní uložení vlastní C7.
- **Krátce žijící access session** + bezpečná refresh strategie (`§7.2`).
- **Konzervativní selhání** — při nejistotě se odepře, ne povolí (`SAR-001`, `SAR-015`).
- **Auditovatelnost** kritických auth/session událostí bez citlivého payloadu (`security-architecture §16.2`); audit-event kontrakt vlastní C14.

C3 **nezavádí nová bezpečnostní pravidla** nad rámec architektury; pouze je aplikuje na R2 identity/session.

---

# 9. Identity invariants (`ISC`)

Nová řada. Doplňuje, neoslabuje `INV-*`, `SAR-*`, `LSM-*`, `MSM-*`.

- **ISC-001 — Oddělené pojmy.** Identity, UserAccount a AthleteProfile jsou oddělené; C3 vlastní identity/account/session, ne AthleteProfile (`INV-010`).
- **ISC-002 — Anonymous je plnohodnotná identita.** Aplikaci lze používat anonymně; anonymní identita je first-class a odpovídá local/anonymous owner z C2 (`identity-and-profile-model §2`, `AuthenticationIdentity ANONYMOUS`).
- **ISC-003 — Server je autorita identity.** Identitu, účet, session a oprávnění určuje server; klient je neurčuje (`SAR-002/003`).
- **ISC-004 — Externí login identita je unikátní.** Jedna kombinace provider + stabilní provider subject nepatří dvěma identitám mimo řízený merge; e-mail není jediný identifikátor (`INV-011`, `§6.4`).
- **ISC-005 — Upgrade nezduplikuje.** anonymous → account zachová existující data a nevytvoří druhý účet/profil; retry je idempotentní (`INV-013`).
- **ISC-006 — Krátká access, bezpečná refresh.** Access session je krátce žijící; refresh má rotaci/replay ochranu, vazbu na session/zařízení a individuální i globální revokaci (`SAR-007`, `security-architecture §7.2`).
- **ISC-007 — Revokovaná session nepotvrzuje.** Revokovaná session nesmí potvrdit nové serverové operace; klient zachová srozumitelný recovery stav neodeslaných změn (`§7.3`, `SAR-007`, C2 `LSM-010/011`).
- **ISC-008 — Session není trust boundary.** Server re-ověří principal/session/ownership/capability/idempotency/schema/invarianty na každé chráněné hranici (`SAR-009`, `sync-and-offline-model` re-verifikace).
- **ISC-009 — Offline session neobnoví oprávnění.** Platná lokální session smí číst dříve synchronizovaná data, ale nesmí po revokaci obnovit serverové oprávnění (`security-architecture §7.3`).
- **ISC-010 — Zrušený účet se offline neobnoví.** Pozdní offline operace nesmí reaktivovat `SUSPENDED`/`LOCKED`/`DELETION_PENDING`/`DELETED` účet ani revokovaná oprávnění (`INV-014`, `INV-016`).
- **ISC-011 — Terminologická separace.** Auth access/refresh session ≠ `WorkoutSession` (R1) ≠ lokální aplikační session ≠ device session; pojmy se neslévají (`r2-vertical-slice-plan §8`, `glossary`).
- **ISC-012 — Bezpečný přístup a žádná ztráta při odhlášení.** Účet nesmí zůstat bez bezpečné možnosti přístupu (`INV-012`); odhlášení neztratí lokální data (C2 `LSM-006`).
- **ISC-013 — Session materiál je SECRET.** Hesla/refresh tokeny nikdy v běžné SQLite ani v logu (`SAR-006/012`); mobilní úložiště vlastní C7, C3 jen lifecycle.
- **ISC-014 — Auditovatelnost bez citlivého payloadu.** Login/logout/refresh/revocation jsou auditovatelné bez citlivého obsahu (`security-architecture §16.2`); audit kontrakt vlastní C14.
- **ISC-015 — Provider-neutral.** C3 nerozhoduje konkrétní auth provider ani token format/claims; to vlastní C5 (ADR) / C4.

---

# 10. Interaction with future contracts

- **C4 (authentication API):** endpointy register/login/logout/refresh, error envelope (APR), rate limiting. C3 vlastní **lifecycle a stavovou sémantiku**, kterou tyto endpointy realizují; C4 vlastní HTTP tvar. Bez překryvu.
- **C5 (auth provider ADR):** rozhodnutí o providerovi a token/claims. C3 je provider-neutral (`ISC-015`).
- **C6 (server data model):** perzistence identity/account/session na serveru. C3 vlastní význam; C6 schéma.
- **C7 (token/session storage):** mobilní bezpečné uložení session materiálu. C3 vlastní lifecycle; C7 úložiště (`ISC-013`).
- **C10 (sync protocol):** transport a re-verifikace při synchronizaci. C3 poskytuje principal/session identitu, kterou sync re-ověří (`ISC-008`); C10 protokol.
- **C11 (idempotency):** replay resolution upgrade/auth operací. C3 stanoví invariant „bez duplicit" (`ISC-005`); stabilní idempotency key vlastní C2, replay protokol C11.
- **C12 (conflict/rejection):** klasifikace/řešení odmítnutí (např. revokovaná session). C3 stanoví, že revokovaná session nepotvrzuje (`ISC-007`); resolution vlastní C12.
- **C13 (session revocation, R2-06):** revokační operační flow. C3 vlastní revokační **sémantiku** v identity/session modelu (`ISC-006/007/009`); operační kontrakt R2-06 vlastní C13.
- **C15 (local-to-account migration):** data-attach algoritmus při anonymous → account. C3 vlastní **identity transition** (§6.1); C15 datové provedení.
- **C8 (authorization/ownership):** serverové vynucení ownership. C3 poskytuje identitu principalu; C8 autorizaci (`SAR-002`).

---

# 11. Testing requirements (kontraktně)

Kontraktní požadavky na ověření (implementaci vlastní R2-02/R2-03; `test-strategy §5.2/§7/§8`):

1. **Session lifecycle** — created → active → refreshed → expired → terminated/revoked; revokovaná session nepotvrdí operaci (`ISC-007`); backend integration (Testcontainers PostgreSQL) + security-negative.
2. **Identity transition** — anonymous → account zachová data a nevytvoří duplicitu (`ISC-005`); account → signed-out neztratí lokální data; signed-out → authenticated respektuje stav účtu (`ISC-010`).
3. **Anonymous registration** — idempotentní upgrade (retry nevytvoří druhý účet/profil) (`INV-013`).
4. **Restart persistence** — po restartu klienta zůstane přihlašovací stav bezpečně obnovitelný dle C7; anonymní identita a lokální data přežijí restart (`ISC-002/012`, návaznost na C2 restart-safe).
5. **Security-negative** — neplatné/expirované/revokované session neautorizují; default deny (`SAR-001`, `ISC-003/008/009`); žádné secrets/tokeny v logu (`ISC-013`).

Bez UI a bez sítě tam, kde to jde (`QTR-003`); backend/DB proti skutečnému enginu (`QTR-004`). Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 12. Evidence gates

Při implementaci slices, které C3 spotřebují (zejména R2-02, dále R2-03/R2-07), musí být doloženo:

- **Session evidence:** testy lifecycle a revokace (revokovaná session nepotvrdí operaci).
- **Transition evidence:** test anonymous → account bez ztráty a bez duplicit (`ISC-005`), a bezpečného sign-out/sign-in.
- **Security-negative evidence:** default deny, neplatné/expirované/revokované credentials, žádné secrets v logu.
- **Restart evidence:** přihlašovací stav i anonymní data přežijí restart bezpečně (dle C7/C2).
- **Audit evidence:** kritické auth/session události auditovány bez citlivého payloadu (dle C14).
- **Traceable release evidence** navázaná na commit a CI run (`QTR-015`, `DRD-014`).

Chybějící povinný důkaz znamená, že slice není Done (`DRD-014`).

---

# 13. Ready condition

## 13.1 Kdy je C3 dokončen (Done)

C3 je Done, právě když tento dokument definuje: identity model (§4), session lifecycle (§5), identity transitions (§6), ownership interakci s C2 (§7), security boundaries (§8), invarianty `ISC-001…ISC-015` (§9), hranice vůči budoucím kontraktům (§10), testing requirements a evidence gates (§11–§12); je zapsán v doc mapě a status auditu; a neobsahuje API, endpointy, DB migrace, JWT/OAuth ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C3 je tedy **Done**.

## 13.2 Dopad na R2-02

`R2-02` má dle `r2-vertical-slice-plan §9.2` blokující kontrakty **C3, C4, C5, C6 a auth část C14**. Dokončením C3 je splněn jeden z nich; **`R2-02` zůstává `NOT_READY`**, protože C4 (a C5, C6, C14) dosud neexistují. `R2-01` zůstává `READY` (C1+C2 hotové); ostatní R2 slices `NOT_READY`.

## 13.3 Další kanonický krok

**C4 – Authentication API contract** — `docs/07-backend/r2-auth-api-contract.md` (endpointy register/login/logout/refresh nad tímto identity/session modelem, error envelope dle APR, rate limiting baseline, contract-test hook). C3 tento kontrakt **nevytváří**.

---

# 14. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — C3 map (§7.1), R2-02 (§9.2), identity hranice (§8), cross-slice invarianty (§10).
- `docs/06-domain/identity-and-profile-model.md` — `Identity §5`, `AuthenticationIdentity §6` (typy vč. `ANONYMOUS`, provider subject §6.4), `UserAccount §7` (typy/stavy), `UserStatus §8`, `AthleteProfile §9`.
- `docs/11-security/security-architecture.md` — session management a `§7.2` access/refresh, `§7.3` offline session, `§16.2` security audit, `SAR-001/002/003/006/007/009/012/015`.
- `docs/06-domain/sync-and-offline-model.md` — serverová re-verifikace principal/session při synchronizaci, offline garance `§3`.
- `docs/06-domain/domain-invariants.md` — `INV-010` (oddělené pojmy), `INV-011` (unikátní login), `INV-012` (bezpečný přístup), `INV-013` (anonymní upgrade bez duplicit), `INV-014` (žádná reaktivace), `INV-016` (revokace invaliduje cache).
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; local/anonymous vs account owner, `LSM-*`.
- `docs/12-data/r2-mobile-schema-migration.md` — C1; `MSM-*`.
- `docs/07-backend/backend-architecture.md` — backend hranice a auth umístění.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-007`, `DRD-014`.
- `docs/14-quality/test-strategy.md` — `§5.2`, `§7`, `§8`, `QTR-003/004/015`.
