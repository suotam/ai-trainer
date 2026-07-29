# AI Trainer – R2 Authentication API Contract (C4)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r2-auth-api-contract.md`
**Vlastník:** Backend Architecture
**Poslední aktualizace:** 2026-07-29
**Kontraktní ID:** C4 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r0-api-contract.md`, `docs/07-backend/backend-architecture.md`, `docs/11-security/security-architecture.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/domain-invariants.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** OpenAPI source (auth endpointy), C5 auth provider ADR, C6 server data model, C7 token/session storage, C13 token/session revocation, C14 audit-event, C15 local-to-account migration
**Vlastněné pojmy nebo kontrakty:** veřejné R2 autentizační API (register/login/refresh/logout/session context), request/response význam, credential transport, auth error semantics, API-level retry/idempotency hranice a pravidla `AAC-001` až `AAC-015`

---

# 1. Purpose and ownership

## 1.1 Proč kontrakt existuje

R2-02 zveřejní první autentizační endpointy. Aby byly jednoznačné, bezpečné a testovatelné, potřebují **jediný kanonický HTTP kontrakt** navázaný na identity/session model (C3) a znovupoužívající kanonický error envelope a HTTP pravidla z R0 API kontraktu. Tímto kontraktem je C4. Je **contract-only**: může definovat kanonický HTTP kontrakt (operace, cesty, pole podle významu, status kódy, chyby), ale **neimplementuje** ho — žádné controllery, routy, DTO, migrace, JWT/OAuth, provider ani generovaný OpenAPI soubor.

## 1.2 Owner

**Backend Architecture** (dle C4 řádku contract mapy). Identitu/session sémantiku, kterou API realizuje, vlastní **C3**; C4 ji nepředefinovává (§3, §7).

## 1.3 Které slices blokuje

- **Blocking pro `R2-02 – Backend Account and Authentication Baseline`** (spolu s C3, C5, C6 a auth částí C14; `r2-vertical-slice-plan §9.2`).
- Auth API je referencované mobilním auth slicem (R2-03) a local-to-account migrací (R2-07); jejich vlastní blocking kontrakty jsou samostatné (§13).

## 1.4 Vztah k C3 a proč C4 není identity model ani provider ADR

C3 odpovídá **kdo** je uživatel a **co** je identita/session a jejich lifecycle. C4 odpovídá **jaké autentizační operace** backend zveřejňuje, jejich **vstupy/výstupy**, **transport credentials**, **chyby** a **retry/idempotency hranice na úrovni API**. C4 **nerozhoduje** konkrétního auth providera (to je C5 ADR) ani token format.

---

# 2. Scope

## 2.1 Co C4 řeší

- veřejné autentizační operace R2 (§4–§5),
- význam request/response polí (§5),
- transport session credentials (§6),
- session issuance a refresh sémantiku na úrovni API navázanou na C3 (§7),
- anonymous-to-account API hranici (§8),
- auth error semantics nad kanonickým error envelope (§9),
- API-level idempotency a retry hranice (§10),
- bezpečnostní preconditions (§11),
- invarianty `AAC-001…AAC-015` (§12),
- hranice vůči ostatním R2 kontraktům (§13),
- testing requirements a evidence gates (§14–§15),
- Ready condition (§16).

## 2.2 Co C4 výslovně neřeší

- **konkrétní auth provider / JWT claims / OAuth flow** — C5 (ADR),
- **fyzické serverové schéma** account/session — C6,
- **mobilní secure storage** session materiálu — C7 (token/session storage),
- **mobilní orchestraci** auth flow (UI, stavové řízení) — slice R2-03,
- **rozšířenou revokaci** (revoke jiných/všech session) a klientské chování po revokaci — C13,
- **audit-event** definice — C14,
- **ownership/local-to-account migraci** dat — C15 (C4 jen potvrzuje identity binding, §8),
- **sync protokol** — C10,
- **idempotency replay protokol / IdempotencyRecord** — C11 (C4 vlastní jen API-level požadavek idempotency key, §10),
- **implementační framework detaily**, controllery, DTO, generovaný OpenAPI.

---

# 3. Source of truth and precedence

Pořadí vlastnictví rozhodnutí (při konfliktu platí vyšší):

1. **Bezpečnostní pravidla** — `security-architecture.md` (`SAR-*`) vlastní transport/credential/revokace/logging/abuse pravidla.
2. **Identity & session sémantika** — **C3** vlastní identity kinds, session lifecycle, transitions.
3. **Kanonická HTTP pravidla a error envelope** — `r0-api-contract.md` (`APR-*`) vlastní base path, media type, korelaci, error envelope a stabilní kódy; C4 je **rozšiřuje** o auth operace, **nepředefinovává** je.
4. **Doménová identita** — `identity-and-profile-model.md` vlastní `Identity`/`AuthenticationIdentity`/`UserAccount`.
5. **R2 pořadí a scope** — `r2-vertical-slice-plan.md` (§7.1 mapa, §9.2 R2-02).

C4 vlastní **tvar veřejného auth API** a jeho AAC pravidla; nevlastní nic z bodů 1–2 a 4, a bod 3 pouze rozšiřuje.

---

# 4. API surface

Zahrnuty jsou pouze operace zdůvodněné R2 scope (`release-scope §6.2`, `r2-vertical-slice-plan §9.2` „register/login/logout/refresh") a identity/session modelem C3:

| Operace | Zdůvodnění |
|---|---|
| **Register / upgrade anonymous → account** | `release-scope §6.2` „vytvoření účtu"; `INV-013`/C3 §6.1 anonymous→account |
| **Login** | `§6.2` „přihlášení"; C3 §6.3 |
| **Refresh access session** | `§6.2` „bezpečná access/refresh session strategie"; C3 §5, `security §7.2` |
| **Logout** | `§6.2` „odhlášení"; C3 §6.2 |
| **Session context (current principal)** | minimální read companion — klient musí získat serverem-autoritativní principal/session stav (C3 `ISC-003/008`); bez něj nelze bezpečně řídit chráněné operace |

**Mimo C4 (forward reference):** rozšířená revokace session (revoke jiné/všechny session) patří **C13** (R2-06); C4 pokrývá jen ukončení aktuální session přes logout. Nové operace se **nepřidávají jen proto, že jsou běžné**.

---

# 5. Endpoint contract format

Pro každou operaci se kontraktně definuje níže uvedené. Pole jsou popsána **významem**, ne typy; **žádné DTO třídy ani frameworkové anotace**. Všechny cesty jsou pod versioned namespace `/api/v1` (`APR-002`) a používají kanonický media type a korelaci (`r0-api-contract §3–§4`).

**Povinné položky kontraktu operace:**

- **účel**,
- **HTTP metoda**,
- **kanonická cesta** (např. `POST /api/v1/auth/...`),
- **požadovaný autentizační kontext** (žádný / platná access session / platná refresh credential),
- **vstupní pole a jejich význam**,
- **výstupní pole a jejich význam** (session context / principal reference; credentials dle §6),
- **očekávané status kódy** (2xx/4xx/5xx dle `APR-008`),
- **doménové a bezpečnostní chyby** (kódy dle §9),
- **retry-safe?** (§10),
- **vyžaduje idempotency mechanismus?** (§10),
- **citlivá data a pravidla nezapisování do logů** (§6, §11).

**Kanonické cesty (kontraktně, ne implementačně):**

| Operace | Metoda | Cesta | Auth kontext |
|---|---|---|---|
| Register/upgrade | `POST` | `/api/v1/auth/registrations` | žádný nebo anonymní |
| Login | `POST` | `/api/v1/auth/sessions` | žádný |
| Refresh | `POST` | `/api/v1/auth/sessions/refresh` | platná refresh credential |
| Logout | `DELETE` | `/api/v1/auth/sessions/current` | platná access session |
| Session context | `GET` | `/api/v1/auth/session` | platná access session |

Konkrétní pole, příklady payloadů a schémata patří do OpenAPI source (navazující dokument), ne sem; C4 vlastní **význam a pravidla**.

---

# 6. Credential transport

- **Access credential** se přenáší v `Authorization` requestu chráněných operací; **nikdy v URL, query stringu ani cestě** (`SAR-006/012`).
- **Refresh credential** má přísnější zacházení: **není běžnou identity API hodnotou**, přenáší se pouze v k tomu určeném bezpečném kanálu daném security architekturou, s vazbou na session/zařízení (`security §7.2`, C3 `ISC-006`).
- **Zákaz v URL** — žádná citlivá credential (heslo, access, refresh) nesmí být v URL/logované cestě.
- **Log-redaction** — hesla, access ani refresh credentials se nikdy nelogují ani neobjeví v analytice/crash reportu (`SAR-012`, `APR-004` bezpečný payload).
- **Rotace** — refresh má rotaci nebo ekvivalentní replay ochranu a detekci opakovaného použití kompromitovaného tokenu (`security §7.2`); podmínky rotace vlastní tento kontrakt na úrovni sémantiky, **konkrétní token format vlastní C5**.
- **Reakce klienta na expiraci/revokaci** — při expiraci access session klient použije refresh; při zamítnutí (revokace) zastaví chráněné uploady a zachová bezpečný recovery stav neodeslaných změn (`security §7.3`, C2 `LSM-010/011`). Podrobné klientské chování po revokaci vlastní C13; mobilní storage C7.

Konkrétní **token format / provider mechanismus** ponechává C4 na **C5**. Konkrétní **lokální secure storage** ponechává na **C7**.

---

# 7. Session issuance and refresh semantics

Navazuje přímo na C3; C4 popisuje jen jak se to projeví na API.

- **Kdy server vydá session** — po úspěšné autentizaci (login) nebo úspěšné registraci/upgrade; server je autoritativní pro potvrzení identity (`C3 ISC-003`).
- **Access session** — krátce žijící oprávnění k chráněným operacím (C3 §5, `security §7`).
- **Refresh session** — dlouhodobá credential obnovující access session (C3 §5, `security §7.2`).
- **Refresh rotation** — každé použití refresh může vydat novou refresh credential a zneplatnit předchozí (rotace).
- **Reuse/replay refresh** — opakované použití již rotované/kompromitované refresh credential musí být **detekováno a odmítnuto** (`security §7.2`); API vrací chybu `INVALID_REFRESH` nebo `SESSION_REVOKED` (§9). Detekční protokol/uložení vlastní C6/C11/C13.
- **Expirace** — po vypršení access session nemá oprávnění; pokračování vyžaduje refresh nebo re-login.
- **Revokace** — revokovaná session/refresh **nesmí autorizovat** nové operace (`C3 ISC-007`, `security §7.3`); rozšířené revokační operace vlastní C13.
- **Vztah refresh ↔ access** — refresh vydává access; access neopravňuje k obnově sám sebe bez refresh.
- **Server-authoritative potvrzení** — identitu i platnost session určuje server, ne klient (`SAR-002/003`).

Žádná kryptografická implementace zde není; to je C5.

---

# 8. Anonymous-to-account API boundary

- **Co API potvrzuje:** že daná anonymní/lokální identita byla svázána s účtem (nebo že vznikl účet z anonymní identity) a vydává session pro account identitu.
- **Co API nepotvrzuje:** přenos ani transformaci lokálních dat. **Přenos/zachování lokálních dat nepatří do C4** — vlastní jej **C15**; lokální ownership/outbox metadata vlastní **C2**.
- **Prevence duplicitní identity:** operace vyžaduje **idempotency key** (§10); opakování se stejným klíčem nesmí vytvořit druhý účet ani druhou identitu (`INV-013`, `C3 ISC-005`, `AAC-005`). Kombinace provider + stabilní provider subject je unikátní (`INV-011`).
- **Ownership enforcement** výsledného účtu je serverový (`SAR-002`, C8); C4 pouze zveřejňuje operaci a její idempotency požadavek.

---

# 9. Error contract

Používá se **kanonický error envelope** z `r0-api-contract §7` (`code`, `message`, `requestId`, `timestamp`, volitelně `details`) — **žádný paralelní error model** (`AAC-001`, `APR-005`). Kódy jsou stabilní `UPPER_SNAKE_CASE` (`APR-006`), strojově rozlišitelné a **bez citlivých informací**.

| HTTP | `code` | Použití | Enumeration-safe |
|---:|---|---|---|
| 400 | `INVALID_REQUEST` | syntakticky/validačně neplatný request (reuse R0) | — |
| 401 | `INVALID_CREDENTIALS` | neplatné přihlašovací údaje (login) — **generický, neodhaluje existenci účtu** | ano |
| 401 | `ACCESS_SESSION_EXPIRED` | access session vypršela | — |
| 401 | `INVALID_REFRESH` | neplatná/expirovaná/rotovaná refresh credential | — |
| 401 | `SESSION_REVOKED` | session/refresh byly revokovány | — |
| 403 | `ACCOUNT_DISABLED` | účet `SUSPENDED`/`LOCKED` (bez odhalení detailu) | ano |
| 403 | `ACCOUNT_DELETED` | účet `DELETION_PENDING`/`DELETED` | ano |
| 409 | `DUPLICATE_LOGIN_IDENTITY` | kolize provider + subject mimo řízený merge (`INV-011`) | — |
| 429 | `RATE_LIMITED` | abuse protection (reuse R0; respektovat `Retry-After`) | — |
| 503 | `AUTH_UNAVAILABLE` | dočasná nedostupnost auth závislosti (pouze v rámci R2 hranice; provider-specifika C5) | — |

**Account enumeration:** chyby přihlášení a registrace nesmí prozradit, zda účet/e-mail existuje (`AAC-008`); login používá jeden generický `INVALID_CREDENTIALS`. Detailní důvod patří jen do redigovaných interních logů (`r0-api-contract §6`, `SAR-012`).

---

# 10. Idempotency and retry semantics

| Operace | Retry-safe | Idempotency key | Poznámka |
|---|---|---|---|
| Register/upgrade | ne bez klíče | **ano (povinný)** | opakování se stejným klíčem nesmí vytvořit druhý účet/identitu (`AAC-005`, `INV-013`) |
| Login | opatrně | ne | opakování může vydat novou session; nesmí vzniknout „duplicitní" trvalý vedlejší efekt |
| Refresh | **ne** | ne | refresh rotuje; naivní retpy starého refresh je replay → detekce/odmítnutí (§7) |
| Logout | ano (idempotentní) | ne | opakovaný logout je no-op na již ukončené session |
| Session context | ano (read) | ne | bezpečná read operace |

- **Co C4 vlastní:** API-level **požadavek** na idempotency key u account-creating/upgrade operací a klasifikaci retry-safe operací.
- **Co ponechává C11:** samotný **replay protokol** (IdempotencyRecord, `ALREADY_APPLIED`, chování při stejném klíči a rozdílném payloadu).
- **Chování klienta při neznámém výsledku** (timeout/ztráta odpovědi): u operací s idempotency key **opakovat se stejným klíčem**; u refresh nepoužívat starou credential poslepu, ale ověřit stav přes session context / re-login.

---

# 11. Security boundaries

Odvozeno z `security-architecture.md`:

- **Server je autorita** identity a session (`SAR-002`); rozhodnutí neurčuje klient (`SAR-003`).
- **Klientem zaslané user/owner ID není důvěryhodné** (`SAR-003`, `C3 ISC-003`); server principal odvozuje z ověřené session.
- **Revokovaná credential neautorizuje** — access po serverem potvrzené revokaci je odmítnut (`SESSION_REVOKED`, `C3 ISC-007/009`).
- **Refresh není běžná identity API hodnota** — přísnější transport a zacházení (§6).
- **Žádné citlivé hodnoty v logu** (`SAR-012`) ani v URL (`SAR-006`).
- **Bez account enumeration** — auth chyby neprozradí existenci účtu (`AAC-008`).
- **Abuse protection** — veřejné auth endpointy mají rate limiting baseline (`SAR-013`, `RATE_LIMITED`).
- **Transport** dle bezpečnostní architektury (`r0-api-contract §3.2`, `SAR-*`); reverse proxy nesmí měnit význam status codes/body.
- **Konzervativní selhání** — při nejistotě odepřít (`SAR-001/015`).

C4 **nezavádí novou bezpečnostní architekturu**; aplikuje existující na auth API.

---

# 12. Contract invariants (`AAC`)

Nová řada. Doplňuje, neoslabuje `APR-*`, `SAR-*`, `ISC-*`.

- **AAC-001 — Kanonický error envelope.** Auth chyby používají envelope z `r0-api-contract §7`; žádný paralelní error model (`APR-005`).
- **AAC-002 — Versioned namespace.** Auth endpointy jsou pod `/api/v1` (`APR-002`).
- **AAC-003 — Provider-neutral.** C4 neobsahuje provider-specifická pole/flow; provider rozhoduje C5.
- **AAC-004 — Server je autorita.** Identitu/session určuje server; klientem dodané user/owner ID není důvěryhodné (`SAR-002/003`, `ISC-003`).
- **AAC-005 — Idempotentní vznik účtu.** Account-creating/upgrade operace vyžaduje idempotency key; retry se stejným klíčem nevytvoří druhý účet/identitu (`INV-013`, `ISC-005`; replay protokol C11).
- **AAC-006 — Krátká access, rotující refresh.** Access je krátce žijící; refresh má rotaci a detekci replay; API sémantiku vlastní C4, token format C5 (`ISC-006`, `security §7.2`).
- **AAC-007 — Revokace ruší autorizaci.** Revokovaná session/refresh neautorizuje nové operace; API vrací `SESSION_REVOKED` (`ISC-007/009`).
- **AAC-008 — Bez account enumeration.** Auth chyby neprozradí existenci účtu/e-mailu; login používá generický `INVALID_CREDENTIALS`.
- **AAC-009 — Citlivé hodnoty se nelogují a nejsou v URL.** Hesla/tokeny nikdy v URL ani v logu (`SAR-006/012`).
- **AAC-010 — Refresh není běžná identity API.** Refresh credential má přísnější transport a zacházení než access (§6).
- **AAC-011 — Transport není doména.** HTTP tvar neurčuje identity sémantiku; C4 realizuje C3, nepředefinovává ji (`APR-012`).
- **AAC-012 — Stabilní strojové kódy.** Error `code` je stabilní `UPPER_SNAKE_CASE`, strojově rozlišitelný (`APR-006`).
- **AAC-013 — Abuse baseline.** Veřejné auth endpointy mají rate limiting / abuse protection baseline (`SAR-013`).
- **AAC-014 — Contract/impl/OpenAPI shoda.** Auth API má OpenAPI source jako strojový kontrakt a contract-test hook; dokumentace, kontrakt a implementace jsou ve shodě (`APR-001/015`).
- **AAC-015 — Auth API nepřenáší lokální data.** anonymous→account operace potvrzuje jen identity binding; zachování/přenos lokálních dat vlastní C15, lokální ownership/outbox C2.

---

# 13. Interaction with other R2 contracts

> Pozn.: vlastnictví níže odpovídá **contract mapě v `r2-vertical-slice-plan.md §7.1` na `main`** (autoritativní zdroj), viz §3.

- **C3 (identity & session):** vlastní identity/session **sémantiku a lifecycle**. C4 vlastní **HTTP tvar** operací, které ji realizují. Bez překryvu (§7).
- **C5 (auth provider ADR):** rozhodnutí o providerovi, token/claims. C4 je provider-neutral (`AAC-003`).
- **C6 (server account/session data model):** serverové schéma account/session/identity. C4 vlastní API tvar; C6 perzistenci.
- **C7 (token/session storage — mobile secure storage):** bezpečné mobilní uložení session materiálu a restart chování. C4 vlastní transport/expiraci/revokaci na úrovni API; C7 úložiště na klientu.
- **C10 (sync protocol):** transport synchronizace. C4 poskytuje session/principal, který sync re-ověří; C4 není sync API.
- **C11 (idempotency & replay):** replay protokol / IdempotencyRecord. C4 vlastní API-level požadavek idempotency key (`AAC-005`); protokol C11.
- **C13 (token/session revocation):** rozšířené revokační operace a klientské chování po revokaci. C4 pokrývá logout a vrací `SESSION_REVOKED`; revokační flow R2-06 vlastní C13.
- **C14 (audit-event):** definice auditovaných auth událostí. C4 stanoví, že auth operace jsou auditovatelné bez citlivého payloadu; seznam a formát událostí vlastní C14.
- **C15 (local-to-account migration):** zachování/přenos předpřihlašovacích lokálních dat. C4 potvrzuje jen identity binding (`AAC-015`); datové provedení C15.

**Forward reference (dosud nevytvořené kontrakty):** C5, C6, C7, C10, C11, C13, C14, C15.

---

# 14. Testing requirements (kontraktně)

Kontraktní požadavky na budoucí důkazy (implementaci vlastní R2-02; `test-strategy §7/§8`, `QTR-004`):

- **úspěšné přihlášení** vydá platnou session,
- **chybné credentials** → `INVALID_CREDENTIALS`, bez enumeration,
- **refresh** obnoví access session,
- **refresh rotation** vydá novou a zneplatní starou refresh credential,
- **replay** staré/rotované refresh credential → odmítnuto (`INVALID_REFRESH`/`SESSION_REVOKED`),
- **expirace** access session → `ACCESS_SESSION_EXPIRED`,
- **revokace** → revokovaná session neautorizuje (`SESSION_REVOKED`),
- **odhlášení** ukončí session; opakovaný logout je no-op,
- **anonymous → account** přechod potvrdí binding bez ztráty a bez duplicit (`AAC-005`),
- **duplicate identity** → `DUPLICATE_LOGIN_IDENTITY`,
- **disabled/deleted account** → `ACCOUNT_DISABLED`/`ACCOUNT_DELETED`,
- **retry po neznámém výsledku** s idempotency key nevytvoří duplicitu,
- **absence citlivých hodnot v logu** (hesla/tokeny),
- **rate limit** → `RATE_LIMITED` s `Retry-After`.

Testy: **API contract tests** proti OpenAPI, **backend integration** (Testcontainers PostgreSQL, `QTR-004`), **security-negative**. Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 15. Evidence gates

Implementace R2-02 (a spotřebitelské slices) musí doložit:

- **API contract evidence:** contract testy prokazující shodu implementace s OpenAPI a tímto kontraktem (`APR-015`, `AAC-014`).
- **Integration evidence:** backend integration testy nad skutečným enginem (auth flow, refresh, revokace).
- **Security-negative evidence:** default deny, neplatné/expirované/revokované credentials, žádná enumeration, žádné secrets v logu.
- **Retry/idempotency evidence:** account-creating retry se stejným klíčem bez duplicit; refresh replay odmítnut.
- **Log-redaction evidence:** hesla/tokeny se neobjeví v logu.
- **Traceability na C3 a security pravidla** (`ISC-*`, `SAR-*`) a na commit + CI run (`QTR-015`, `DRD-014`).

Chybějící povinný důkaz znamená, že slice není Done (`DRD-014`).

---

# 16. Ready condition

C4 je **Done**, právě když: všechny R2 požadované operace jsou kontraktně pokryté (§4–§5); každá operace má jednoznačné request/response/error/retry semantics; hranice vůči C3 a C5 jsou jednoznačné (§7, §13); **není vybrán konkrétní auth provider** (`AAC-003`); **není žádný produkční kód**; odkazy jsou konzistentní; pravidla `AAC-001…AAC-015` jsou unikátní a každé definováno právě jednou; a dokument projde dokumentačními kontrolami a je zapsán v doc mapě.

Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C4 je tedy **Done**.

**Dopad na R2-02:** `R2-02` má blokující kontrakty **C3, C4, C5, C6 a auth část C14**. Dokončením C4 jsou hotové C3 a C4; **`R2-02` zůstává `NOT_READY`**, protože C5, C6 a auth část C14 dosud neexistují. `R2-01` zůstává `READY` (neimplementováno); ostatní R2 slices `NOT_READY`.

**Další kanonický krok:** **C5 – Auth provider ADR** (`docs/05-architecture/…` ADR záznam, dle contract mapy `r2-vertical-slice-plan §7.1`), následně C6 a auth část C14, pokud aktuální `main` neurčí jinak.

---

# 17. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — C4 map (§7.1), R2-02 (§9.2), cross-slice invarianty (§10).
- `docs/07-backend/r2-identity-session-contract.md` — C3; identity/session sémantika, `ISC-001…ISC-015`.
- `docs/07-backend/r0-api-contract.md` — kanonická HTTP pravidla, error envelope (§7), error codes (§7.2), versioning (§11), `APR-001…APR-015`.
- `docs/11-security/security-architecture.md` — `SAR-001/002/003/006/007/009/012/013/015`, session management (§7), offline session (§7.3).
- `docs/06-domain/identity-and-profile-model.md` — `Identity`, `AuthenticationIdentity`, `UserAccount`.
- `docs/06-domain/domain-invariants.md` — `INV-011` (unikátní login), `INV-013` (anonymní upgrade bez duplicit), `INV-014` (žádná reaktivace).
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; local/anonymous vs account owner, `LSM-*`.
- `docs/07-backend/backend-architecture.md` — backend hranice a umístění auth.
- `docs/14-quality/test-strategy.md` — `§7`, `§8`, `QTR-004/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-007`, `DRD-014`.
- **Forward reference (dosud nevytvořené kontrakty):** C5 auth provider ADR, C6 server data model, C7 token/session storage (`docs/11-security/r2-token-session-storage-contract.md`), C10 sync protocol, C11 idempotency, C13 revocation, C14 audit-event (`docs/11-security/r2-audit-event-contract.md`), C15 local-to-account migration.
