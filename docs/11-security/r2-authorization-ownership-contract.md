# AI Trainer – R2 Authorization & Ownership Contract (C8)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/11-security/r2-authorization-ownership-contract.md`
**Vlastník:** Security (SAR) + Backend Architecture
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C8 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/11-security/security-architecture.md`, `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/12-data/r2-server-data-model.md` (C6), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/07-backend/r0-api-contract.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/domain-invariants.md`, `docs/11-security/r2-audit-event-contract.md` (C14), `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-04/R2-05 (ownership enforcement v produkčním kódu), C9 device registration, C10 sync protocol, C12 conflict/rejection
**Vlastněné pojmy nebo kontrakty:** serverové vynucení autorizace a ownership v R2 (principal resolution, ownership check, R2 capability baseline, error semantics odmítnutí) a pravidla `AOC-001` až `AOC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Security (SAR) + Backend Architecture.** R2-04 zavádí první vlastnitelné serverové entity dostupné přes API (AthleteProfile, DeviceInstallation) a R2-05 první sync. Aby žádná chráněná operace nespoléhala na klientem dodané owner ID a aby odmítnutí mělo jednotnou, enumeration-safe sémantiku, potřebuje R2 jediný kanonický kontrakt serverového vynucení. Tímto je C8.

C8 je **contract-only**: definuje model vynucení a pravidla; **neimplementuje** policy engine, interceptory ani produkční kód. Nepředefinovává `security-architecture §8` — aplikuje ji na R2.

## 1.2 Které slices blokuje

- **Blocking pro `R2-04 – AthleteProfile and Device Registration`** (ownership vazba účet–profil–zařízení; spolu s C9 a rozšířením C6).
- **Blocking pro `R2-05 – Ownership Authorization and First Sync`** (ownership enforcement při push sync; garantováno dokončeným R2-04).

## 1.3 Vztah k C3/C6

C3 poskytuje **identitu principalu** (ověřená access session, `ISC-003/008`); C6 drží **ownership sloupce** (`account_id`, `SDM-008`). C8 vlastní **pravidla vynucení** nad nimi — kdo smí co, jak se rozhoduje a jak vypadá odmítnutí.

---

# 2. Scope

## 2.1 Co C8 řeší

- **principal resolution** na chráněné hranici (§4),
- **ownership check** vlastnitelných entit (§5),
- **R2 capability baseline** (§6),
- **objektová autorizace** a anti-IDOR/BOLA pravidla (§7),
- **error semantics odmítnutí** bez enumeration (§8),
- **umístění vynucení** v architektuře backendu (§9),
- **audit odmítnutí** (§10),
- invarianty `AOC-001…AOC-015` (§11), hranice (§12), testing/evidence (§13–§14), Ready (§15).

## 2.2 Co C8 výslovně neřeší

- **autentizaci a session lifecycle** — C3/C4 (C8 začíná až u ověřeného principalu),
- **schéma ownership sloupců** — C6,
- **device registrační flow** — C9 (C8 vlastní jen autorizaci registračních operací),
- **sync protokol, idempotency, konflikt** — C10/C11/C12 (C8 vlastní ownership rozhodnutí, ne transport),
- **role trenér/guardian/tým, sdílení, ManagedProfile** — R2 non-goal (`release-scope §6.3`); vztahová autorizace (`security §8.1` „aktivní vztah") je forward-scoped mimo R2,
- **plný capability registry a mapování na role** — samostatný budoucí kontrakt (`security §8.2`); C8 definuje jen R2 baseline podmnožinu,
- **administrativní/support přístup** — `security §8.4`, mimo R2 scope,
- **step-up / recent authentication** — forward-scoped (`security §9`); R2 operace ji nevyžadují.

---

# 3. Source of truth and precedence

1. **Bezpečnost** — `security-architecture §8` (authorization architecture, default deny §8.5, IDOR/BOLA §8.3) a `SAR-001/002/003/004/009/015` jsou nejvyšší; C8 je aplikuje, neoslabuje.
2. **Identity/session** — C3 (`ISC-003/008` — server je autorita, session není trust boundary).
3. **Serverový datový model** — C6 (`SDM-007/008` — jeden zapisující vlastník, `account_id` ownership).
4. **HTTP pravidla** — `r0-api-contract` (error envelope, stabilní kódy) a C4 (auth error sémantika).
5. **R2 pořadí** — `r2-vertical-slice-plan §7.1/§9.4/§9.5/§10`.

C8 vlastní **R2 enforcement model** a `AOC-*`.

---

# 4. Principal resolution

- Principal chráněné operace se odvozuje **výhradně ze serverem ověřené access session** (C3 §5, R2-02 `AccessSessionAuthenticator`): session → account. Klientem dodaný account/owner/profile identifikátor **není** zdroj principalu (`SAR-003`, `AOC-002`).
- Ověření probíhá **na každé chráněné hranici** — session není trust boundary (`ISC-008`, `SAR-009`): platnost session, stav účtu (ISC-010) a teprve pak autorizace.
- Chybějící/neplatná/revokovaná credential končí autentizační chybou dle C4 (`ACCESS_SESSION_EXPIRED`/`SESSION_REVOKED`) — autorizace se vůbec nevyhodnocuje.
- R2 principal je vždy **account** (`UserAccount`); vztahové principaly (trenér, guardian) jsou mimo R2 (§2.2).

---

# 5. Ownership check

- Každá vlastnitelná serverová entita nese `account_id` (C6 §6). **Ownership rozhodnutí = porovnání principal account vs. `account_id` cílové entity na serveru,** nad autoritativními daty (žádná cache z klienta).
- **Klientem dodané owner ID není důkaz** (`SAR-003`, `R2P-005`): payload smí owner referenci obsahovat (např. pro sync), ale server ji **ověří proti principalu** a při nesouladu operaci odmítne — nikdy ji tiše nepřepíše na principalova data.
- **Zápis i čtení** podléhají stejnému ownership pravidlu (`profile.read` i `workout.write`, §6); read není implicitně veřejný.
- Vytvoření nové vlastnitelné entity přiřadí ownership **vždy z principalu**, ne z payloadu.
- Tranzitivní ownership: entita vlastněná přes rodiče (např. budoucí performance přes session) se autorizuje přes ownership aggregate root — konzistentně s C2 lokálním modelem.

---

# 6. R2 capability baseline

R2 používá **minimální podmnožinu** capability-oriented policy (`security §8.2`); plný registry je budoucí kontrakt. Baseline pro R2-04/R2-05:

| Capability | Význam | Slice |
|---|---|---|
| `profile.read` | čtení vlastního AthleteProfile | R2-04 |
| `profile.write` | vytvoření/úprava vlastního AthleteProfile | R2-04 |
| `device.manage` | registrace/odhlášení vlastního zařízení | R2-04 |
| `sync.push` | push vlastních podporovaných dat | R2-05 |

- V R2 má standardní účet (`STANDARD`, stav umožňující přihlášení) **všechny baseline capabilities pouze nad vlastními daty** — capability nikdy nerozšiřuje ownership.
- Neznámá capability nebo chybějící policy context → **default deny** (`security §8.5`, `SAR-001`).
- Capability checks jsou **centralizované** (jedno vlastnící místo v application vrstvě), ne rozptýlené string checks v controllerech (`security §8.2`).

---

# 7. Objektová autorizace (anti-IDOR/BOLA)

- Každý přístup k objektu podle identifikátoru je omezen vlastníkem (`security §8.3`): **neexistence a cizí vlastnictví jsou navenek nerozlišitelné** (§8).
- Identifikátory (client-generated i server-assigned) se považují za **hádatelné** — nezveřejnění ID není ochrana.
- Kolekční dotazy (list zařízení, profilů) jsou **implicitně filtrované principalem**; neexistuje „list všech".
- Batch operace (sync push, R2-05): ownership se ověřuje **per položka**; jedna cizí položka neautorizuje ani neshodí ostatní — odmítne se položka, ne celá batch (detailní chování batch vlastní C10/C12).

---

# 8. Error semantics odmítnutí

Používá kanonický error envelope (`r0-api-contract §7`); kódy jsou stabilní `UPPER_SNAKE_CASE`:

| Situace | HTTP | `code` | Poznámka |
|---|---:|---|---|
| Neautentizováno / neplatná session | 401 | dle C4 | autorizace se nevyhodnocuje |
| Cizí entita **nebo** neexistující entita | 404 | `RESOURCE_NOT_FOUND` | enumeration-safe: existence cizího zdroje se neprozrazuje (`AOC-007`) |
| Autorizační selhání bez cílové entity (chybějící capability, zakázaná operace jako celek) | 403 | `OPERATION_FORBIDDEN` | bez interního detailu policy |
| Ownership nesoulad v payload/sync položce | — | vlastní C10/C12 | per-item rejection; „ne synchronizováno" |

- **404 pro cizí zdroje je závazné pravidlo** — 403 na cizím ID by potvrdilo existenci (IDOR enumeration).
- Selhání autorizační logiky (výjimka, nedostupný kontext) → **deny** (`SAR-015`), nikdy fail-open; navenek bezpečný 404/403/500 dle situace bez interního detailu.

---

# 9. Umístění vynucení

- Ownership/capability rozhodnutí žije v **application vrstvě backendu** (use case / autorizační služba), ne v controllerech ani v SQL fragmentech rozptýlených po repositories — konzistentně s R2-02 stylem (`AccessSessionAuthenticator` je vzor pro principal resolution).
- Transport (controller) mapuje typovaná odmítnutí na §8 kódy; **žádná autorizační logika v transport vrstvě**.
- Data vrstva smí ownership filtrovat (WHERE `account_id` = principal) jako **druhou linii**; první autoritativní rozhodnutí je aplikační (`SDM-004` analogie: DB constraint je poslední linie).
- Route guard na klientu není autorizace (`security §8.1`, ADR-003) — mobilní UI stav nikdy nenahrazuje serverové rozhodnutí.

---

# 10. Audit odmítnutí

- **Ownership violation / authorization denied** je auditovaná událost (C14 §7 — `ownership violation / authorization denied`, outcome `REJECTED`, policy decision `DEFAULT_DENY`/`OWNERSHIP_MISMATCH`), bez citlivého payloadu (AEC-003/004).
- Audit odmítnutí nesmí obsahovat obsah cizí entity — jen technické reference (principal, action, target ID).
- Sync část auditu (R2-05) vlastní C14 §7; C8 určuje, **kdy** je odmítnutí ownership violation.

---

# 11. Authorization/ownership invariants (`AOC`)

Nová řada. Doplňuje, neoslabuje `SAR-*`, `ISC-*`, `SDM-*`, `AAC-*`.

- **AOC-001 — Server rozhoduje.** Autorizace a ownership se vyhodnocují výhradně na serveru nad autoritativními daty (`SAR-002`); klientský stav není důkaz.
- **AOC-002 — Principal jen z ověřené session.** Principal se odvozuje z ověřené access session (C3); klientem dodané account/owner/profile ID principal neurčuje (`SAR-003`).
- **AOC-003 — Default deny.** Neznámá capability, chybějící kontext, neplatný stav nebo selhání autorizační logiky vede k zamítnutí (`security §8.5`, `SAR-001/015`).
- **AOC-004 — Ownership na každé chráněné hranici.** Každá chráněná operace ověří ownership cílové entity; session není trust boundary (`ISC-008`, `SAR-009`).
- **AOC-005 — Vytvoření vlastní principal.** Nově vytvořená vlastnitelná entita dostává ownership z principalu, nikdy z payloadu.
- **AOC-006 — Payload owner se ověřuje.** Owner reference v payloadu se porovnává s principalem; nesoulad je odmítnutí, ne tichý přepis.
- **AOC-007 — Enumeration-safe odmítnutí.** Cizí a neexistující zdroj jsou navenek nerozlišitelné (404 `RESOURCE_NOT_FOUND`); 403 se nevrací na cizí ID.
- **AOC-008 — Kolekce filtrované principalem.** Každý kolekční dotaz je implicitně omezen na data principalu; „list všech" neexistuje.
- **AOC-009 — Per-item ownership v batch.** Batch/sync ověřuje ownership per položka; cizí položka je odmítnuta jednotlivě (návazně C10/C12).
- **AOC-010 — Capability nerozšiřuje ownership.** R2 baseline capabilities platí jen nad vlastními daty; žádná capability nedává přístup k cizím datům.
- **AOC-011 — Centralizované vynucení.** Autorizační rozhodnutí je centralizované v application vrstvě; žádné rozptýlené string checks v controllerech (`security §8.2`), žádná autorizace v transport vrstvě.
- **AOC-012 — DB filtr je druhá linie.** Ownership WHERE filtr v data vrstvě doplňuje, nenahrazuje aplikační rozhodnutí.
- **AOC-013 — Odmítnutí se audituje.** Ownership violation / authorization denied generuje audit záznam dle C14 s explicitním outcome, bez citlivého payloadu.
- **AOC-014 — Bez rolí do zásoby.** R2 nezavádí role, vztahy ani admin přístup; capability baseline je minimální podmnožina (§6) a rozšiřuje se až kontraktem, který ji potřebuje (`R2P-012`).
- **AOC-015 — Device je signál, ne principal.** Device identity (C9) nikdy nenahrazuje principal ani ownership rozhodnutí (`security §9`); autorizuje se vždy účet.

---

# 12. Interaction with other contracts

- **C3 (identity/session):** dodává ověřený principal (`ISC-008`); C8 na něm staví autorizaci. Bez překryvu.
- **C4 (auth API):** vlastní autentizační chyby (401); C8 vlastní autorizační odmítnutí (403/404) nad nimi.
- **C6 (server data model):** drží `account_id` sloupce a constraints (`SDM-008`); C8 vlastní pravidla vynucení.
- **C9 (device registration):** registrační operace podléhají C8 (`device.manage`, ownership účet–zařízení); C9 vlastní registrační sémantiku.
- **C10/C11 (sync/idempotency, forward):** sync push podléhá `sync.push` + per-item ownership (AOC-009); protokol vlastní C10/C11.
- **C12 (conflict/rejection, forward):** klasifikaci odmítnuté sync položky vlastní C12; C8 určuje, kdy je důvodem ownership.
- **C14 (audit):** tvar a seznam audit událostí vlastní C14; C8 určuje spouštěcí podmínku ownership violation.

**Forward reference (dosud nevytvořené kontrakty):** C10, C11, C12, C13, C15, capability registry.

---

# 13. Testing requirements (kontraktně)

Implementace R2-04/R2-05 musí ověřit (`test-strategy §7/§8`, `QTR-004`):

1. **Cizí čtení/zápis odmítnuty** — účet A nesmí číst ani měnit profil/zařízení účtu B; odpověď je 404 nerozlišitelná od neexistence (Testcontainers, security-negative).
2. **Payload owner mismatch** — operace s cizím owner ID v payloadu je odmítnuta, data nezměněna.
3. **Default deny** — chybějící capability kontext / neočekávané selhání policy vede na deny, ne na povolení.
4. **Kolekce filtrované** — list zařízení/profilů vrací jen data principalu.
5. **Vytvoření vlastní principal** — entita vytvořená s cizím owner ID v payloadu buď odmítnuta, nebo vlastněna principalem dle §5 (odmítnutí je kanonické).
6. **Deaktivovaný účet** — SUSPENDED/LOCKED/DELETED principal neprojde autorizací (návaznost ISC-010).
7. **Audit** — ownership violation vygeneruje audit záznam s outcome REJECTED bez citlivého payloadu.
8. (R2-05) **Per-item batch ownership** — smíšená batch odmítne jen cizí položky.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 14. Evidence gates

Implementace R2-04 (a R2-05) musí doložit: ownership negativní testy (cizí účet, payload mismatch, 404 nerozlišitelnost), default deny testy, kolekční filtr testy, audit odmítnutí, traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 15. Ready condition

## 15.1 Kdy je C8 dokončen (Done)

C8 je Done, právě když definuje: principal resolution (§4), ownership check (§5), R2 capability baseline (§6), objektovou autorizaci (§7), error semantics (§8), umístění vynucení (§9), audit odmítnutí (§10), invarianty `AOC-001…AOC-015` (§11), hranice (§12), testing/evidence (§13–§14); je zapsán v doc mapě a status auditu; a neobsahuje policy engine, role registry ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C8 je tedy **Done**.

## 15.2 Dopad na R2-04

`R2-04` má blokující kontrakty **C8, C9 a rozšíření C6 o profil/device** (Ready podmínka zahrnuje R2-03 Done — splněno). C8 je hotov; `R2-04` je `READY`, jakmile existují i C9 a rozšíření C6.

## 15.3 Další kanonický krok

**C9 – Device registration contract** (`docs/07-backend/r2-device-registration-contract.md`) a **append-only rozšíření C6** o profil/device tabulky. C8 je nevytváří.

---

# 16. References

- `docs/11-security/security-architecture.md` — `§8` authorization architecture (8.1 server autorita, 8.2 capability, 8.3 IDOR/BOLA, 8.5 default deny), `§9` session/device security, `SAR-001/002/003/004/009/015`.
- `docs/07-backend/r2-identity-session-contract.md` — C3; `ISC-003/008/010`.
- `docs/12-data/r2-server-data-model.md` — C6; `SDM-007/008`, ownership sloupce.
- `docs/07-backend/r2-auth-api-contract.md` — C4; autentizační error sémantika.
- `docs/07-backend/r0-api-contract.md` — error envelope, stabilní kódy.
- `docs/11-security/r2-audit-event-contract.md` — C14; ownership violation událost (§7).
- `docs/06-domain/domain-invariants.md` — vlastnické invarianty.
- `docs/13-delivery/r2-vertical-slice-plan.md` — C8 map (§7.1), R2-04/05 (§9.4/§9.5), `R2P-005`.
- `docs/14-quality/test-strategy.md` — `§7/§8`, `QTR-004/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-014`.
