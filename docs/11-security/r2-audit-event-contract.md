# AI Trainer – R2 Audit-Event Contract (C14)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/11-security/r2-audit-event-contract.md`
**Vlastník:** Domain (domain-events) + Security
**Poslední aktualizace:** 2026-07-29
**Kontraktní ID:** C14 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/domain-events.md`, `docs/11-security/security-architecture.md`, `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/12-data/r2-server-data-model.md` (C6), `docs/06-domain/sync-and-offline-model.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace audit záznamů (R2-02 auth, R2-05 sync), C8 authorization/ownership, C10 sync protocol, C13 revocation
**Vlastněné pojmy nebo kontrakty:** seznam auditovaných auth a sync kritických událostí R2, tvar audit záznamu, pravidla bez citlivého payloadu a pravidla `AEC-001` až `AEC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Domain (domain-events) + Security.** R2 zavádí bezpečnostně kritické operace (přihlášení, session, synchronizace). Aby byly dohledatelné bez úniku citlivých dat, potřebuje jediný kanonický kontrakt, který určí **které události se auditují**, **jaký má audit záznam tvar** a **co se nikdy nesmí logovat**. Tímto je C14.

C14 je **contract-only**: definuje seznam událostí, tvar záznamu a pravidla; **neimplementuje** logging framework, storage ani produkční kód.

## 1.2 Které slices blokuje

- **Auth část blokuje `R2-02`** (události přihlášení / session produkované auth baseline).
- **Sync část blokuje `R2-05`** (události synchronizace / ownership).
- Obecné budoucí audit scaffolding mimo tyto konkrétní události **není blocking** (dle contract mapy).

## 1.3 Vztah k C3/C4/C6

C3 vlastní identity/session sémantiku (auditovatelnost bez citlivého payloadu, `ISC-014`); C4 vlastní auth API (jehož operace generují auth události); C6 drží serverové audit úložiště odkazující na account/session. C14 určuje **co a jak** se audituje; **nepředefinovává** je.

---

# 2. Scope

## 2.1 Co C14 řeší

- **seznam auditovaných auth událostí** (R2-02, §6) a **sync událostí** (R2-05, §7),
- **tvar audit záznamu** (§5) — principal, action, target, outcome, čas, correlation, policy decision,
- **oddělení audit záznamu od doménové události** (§4),
- **pravidla bez citlivého payloadu** (§8) a **ochranu auditu** (§9),
- invarianty `AEC-001…AEC-015` (§10), hranice (§11), testing/evidence (§12–§13), Ready (§14).

## 2.2 Co C14 neřeší

- **logging/observability framework, storage engine, retenci** — implementace + data/operations kontrakty,
- **doménový event model** jako celek — `domain-events.md` (C14 z něj čerpá),
- **auth API tvar** (C4), **identity/session sémantiku** (C3), **serverové schéma** (C6),
- **notifikace uživateli ani analytiku** (`domain-events §8/§9` — audit je odlišný),
- **sync protokol / conflict resolution** (C10/C12) — C14 jen audituje jejich kritické výsledky.

---

# 3. Source of truth and precedence

1. **Security** — `security-architecture §16` (co auditovat, tvar, ochrana) a `SAR-012` (bezpečné logování) jsou nejvyšší.
2. **Doménový event model** — `domain-events.md` (§7 audit vs událost, §10 envelope, §11–§13 EventId/Type/Version).
3. **C3/C4/C6** — zdroje auth/sync událostí a úložiště.
4. **R2 pořadí** — `r2-vertical-slice-plan §7.1/§9`.

C14 vlastní **R2 seznam auditovaných událostí a tvar záznamu** + `AEC-*`; body 1–3 promítá.

---

# 4. Audit record vs domain event

Audit záznam je **odlišný od doménové události** (`domain-events §7`): audit je bezpečnostně-provozní dohledatelnost „kdo/co/na čem/výsledek/kdy", ne doménová business událost. Audit záznam **není** analytická událost (`§9`) ani notifikace (`§8`). Může korelovat s doménovou událostí přes bezpečné technické ID, ale nikdy nekopíruje citlivý payload.

---

# 5. Audit record shape (kontraktně)

Každý audit záznam obsahuje minimálně (dle `security-architecture §16.2`):

- **principal** — kdo (account/identity/session reference, technickým ID),
- **action** — co (stabilní název události, §6/§7),
- **target** — na čem (technická reference, ne citlivý obsah),
- **outcome** — výsledek (success / failure / rejected / conflict),
- **occurredAt** — čas (UTC),
- **correlation** — korelační identita (např. request/trace ID; bezpečné technické identifikátory, ne citlivý obsah),
- **policyDecision** — relevantní rozhodnutí policy (např. default deny, rate-limit třída), je-li relevantní.

Záznam **nesmí** obsahovat secret ani nadbytečný citlivý payload (§8). Názvy událostí se řídí pravidly `domain-events §12.2` (stabilní, verzovatelné).

---

# 6. Auth audit events (R2-02)

Auditované auth události (dle `security-architecture §16.2`, produkované C4 operacemi):

- **login success** / **login failure** (v přiměřené granularitě; failure bez account enumeration, `AAC-008`),
- **registration / anonymous→account upgrade** (výsledek: created / already-linked),
- **session issued** (access/refresh vydání),
- **session refreshed** (refresh rotation),
- **session refresh rejected** (replay/expired/invalid),
- **logout** (session terminated),
- **session revoked** (individuální i globální; detail revokačního flow C13),
- **auth change** (změna přihlašovací identity / recovery).

Každá událost má outcome a bezpečný target; **žádné heslo/token/PII v payloadu** (§8).

---

# 7. Sync audit events (R2-05, forward)

Auditované sync/ownership události (blokující až `R2-05`, produkované sync protokolem C10):

- **sync operation applied** (potvrzená operace),
- **sync operation rejected** (odmítnutá — ne „synchronizováno"),
- **sync conflict detected** (explicitní konfliktní stav),
- **ownership violation / authorization denied** (default deny; enforcement C8),
- **idempotent replay** (`ALREADY_APPLIED`; detail C11).

C14 tyto události **vymezuje**; jejich přesné spuštění vlastní C10/C11/C12/C8. Auth část (§6) je pro `R2-02` kompletní; sync část je forward-scoped a doplní se před `R2-05`.

---

# 8. No-sensitive-payload rules

- **Žádné secrets** (hesla, access/refresh tokeny, provider tajemství) v audit záznamu ani logu (`SAR-012`, `DAR-010`).
- **Žádný nadbytečný citlivý payload** — jen technické reference a outcome.
- **Korelace bezpečnými technickými ID**, ne kopírováním citlivého obsahu (`security-architecture §16.1`).
- **Bez account enumeration** — auth failure audit nesmí umožnit odvození existence účtu z veřejně dostupné odpovědi (`AAC-008`); interní audit smí být detailnější, ale zůstává přístupově oddělený (§9).

---

# 9. Audit protection

Dle `security-architecture §16.3`: audit je **append-oriented**, **přístupově oddělený** a chráněný před běžnou produktovou editací. Retenci a případnou neměnnost určí data/operations kontrakty (mimo C14).

---

# 10. Audit-event invariants (`AEC`)

Doplňuje, neoslabuje `SAR-*`, `DAR-*`, `ISC-*`, `AAC-*`.

- **AEC-001 — Audit ≠ doménová událost.** Audit záznam je odlišný od doménové/analytické události a notifikace (`domain-events §7/§8/§9`).
- **AEC-002 — Povinný tvar.** Každý audit záznam nese principal, action, target, outcome, occurredAt, correlation a (relevantní) policyDecision (`security §16.2`).
- **AEC-003 — Žádné secrets.** Audit ani log neobsahuje secrets (`SAR-012`, `DAR-010`).
- **AEC-004 — Žádný nadbytečný citlivý payload.** Jen technické reference a outcome (`security §16.1/§16.2`).
- **AEC-005 — Bezpečná korelace.** Korelace přes bezpečná technická ID, ne citlivý obsah.
- **AEC-006 — Bez enumeration.** Auth-failure audit neumožní odvození existence účtu (`AAC-008`).
- **AEC-007 — Auth události kompletní pro R2-02.** login (success/failure), registration/upgrade, session issued/refreshed/refresh-rejected, logout, session revoked, auth change (§6).
- **AEC-008 — Sync události pro R2-05.** applied, rejected, conflict, ownership violation, idempotent replay (§7); doplní se před R2-05.
- **AEC-009 — Stabilní názvy událostí.** EventType názvy stabilní a verzovatelné (`domain-events §12.2/§13`).
- **AEC-010 — Append-oriented a oddělený.** Audit je append-oriented, přístupově oddělený, chráněný před běžnou editací (`security §16.3`).
- **AEC-011 — Outcome je explicitní.** Každá auditovaná operace má explicitní outcome (success/failure/rejected/conflict); odmítnutí není „úspěch" (`sync-and-offline-model §3.6`).
- **AEC-012 — Principal je technický.** Principal se odkazuje technickým ID (account/identity/session), ne citlivými osobními údaji.
- **AEC-013 — Audit neblokuje kritický tok bezpečně.** Selhání auditu nesmí tiše zamlčet bezpečnostní událost; konzervativní selhání (`SAR-015`) — ale audit nesmí být obcházen.
- **AEC-014 — Bez scaffoldingu do zásoby.** Auditují se jen události skutečně produkované daným slicem; obecné budoucí audit scaffolding se nezavádí předčasně (contract mapa).
- **AEC-015 — Traceable.** Bezpečnostní události zůstávají dohledatelné i přes redigované logy (`SAR-012`).

---

# 11. Interaction with other contracts

- **C3 (identity/session):** auditovatelnost bez citlivého payloadu (`ISC-014`); C14 určuje konkrétní auth události.
- **C4 (auth API):** operace generující auth události (§6); C4 vlastní API tvar, C14 audit.
- **C6 (server data model):** serverové audit úložiště odkazuje na account/session; C6 drží schéma, C14 obsah.
- **C7 (token/session storage):** klientské úložiště; C14 auditje serverovou stranu session událostí.
- **C8 (authorization/ownership):** ownership violation audit (§7); C8 vynucuje, C14 audituje výsledek.
- **C10/C11/C12 (sync/idempotency/conflict):** produkují sync audit události (§7); C14 je vymezuje.
- **C13 (revocation):** revokační flow; C14 audituje session-revoked (§6).

---

# 12. Testing requirements (kontraktně)

Implementace musí ověřit (`test-strategy §7/§8`):

- auth události (§6) se generují se správným outcome (login success/failure, session issued/refreshed/rejected/revoked, logout, upgrade),
- **žádné secrets/PII** v audit záznamu ani logu (§8) — security-negative test,
- **bez enumeration** — auth-failure audit/response neodhalí existenci účtu,
- audit je **append-oriented** a přístupově oddělený (§9),
- (R2-05) sync události applied/rejected/conflict se generují s explicitním outcome.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 13. Evidence gates

R2-02 (auth) a R2-05 (sync) musí doložit: generování definovaných událostí se správným outcome; log-redaction/no-secrets důkaz; no-enumeration důkaz; append-oriented/oddělený audit; traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 14. Ready condition

C14 je **Done** (v rozsahu potřebném pro odblokování), právě když definuje: tvar audit záznamu (§5), **kompletní seznam auth událostí pro R2-02** (§6), forward-scoped sync události (§7), pravidla bez citlivého payloadu (§8), ochranu auditu (§9), invarianty `AEC-001…AEC-015` (§10), hranice (§11), testing/evidence (§12–§13); je zapsán v doc mapě; a neobsahuje produkční kód. Tyto podmínky jsou splněny → **auth část C14 je Done**; sync část zůstává forward-scoped (doplní se před R2-05).

**Dopad na R2-02:** blokující kontrakty `R2-02` jsou C3, C4, C5, C6 a auth část C14 — **všechny hotové → `R2-02` je `READY` (neimplementováno).** `R2-01` zůstává `READY`. `R2-03`…`R2-08` zůstávají `NOT_READY` (čekají na dokončení předchozích slices a své kontrakty).

**Další kanonický krok:** buď **implementace R2-01/R2-02** (samostatné rozhodnutí — jde o produkční kód), nebo příprava kontraktu **C7 – Token/session storage** (`docs/11-security/r2-token-session-storage-contract.md`) pro R2-03.

---

# 15. References

- `docs/06-domain/domain-events.md` — audit vs událost (§7), envelope (§10), EventId/Type/Version (§11–§13).
- `docs/11-security/security-architecture.md` — `§16` security audit (co, tvar, ochrana), `SAR-012` bezpečné logování, `SAR-015`.
- `docs/07-backend/r2-identity-session-contract.md` — C3; `ISC-014` auditovatelnost bez citlivého payloadu.
- `docs/07-backend/r2-auth-api-contract.md` — C4; `AAC-008` no enumeration.
- `docs/12-data/r2-server-data-model.md` — C6; serverové audit úložiště, `DAR-010`.
- `docs/06-domain/sync-and-offline-model.md` — `§3.6` konflikt/rejection jako explicitní stav.
- `docs/14-quality/test-strategy.md` — `§7/§8`, `QTR-015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-014`.
