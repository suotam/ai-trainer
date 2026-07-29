# AI Trainer – R2 Local Ownership & Outbox / Pending-Operation Contract (C2)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r2-local-sync-metadata-contract.md`
**Vlastník:** Domain (sync-and-offline-model), co-located v `12-data` jako lokální persistence-facing kontrakt
**Poslední aktualizace:** 2026-07-29
**Kontraktní ID:** C2 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/domain-invariants.md`, `docs/12-data/r2-mobile-schema-migration.md` (C1), `docs/12-data/data-architecture.md`, `docs/11-security/security-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** C3 identity & session, C6 server data model, C10 sync protocol, C11 idempotency, C12 conflict/rejection, C15 local-to-account migration; mobile persistence a outbox pro R2-01
**Vlastněné pojmy nebo kontrakty:** lokální ownership metadata, lokální sync metadata (význam), outbox / pending-operation lifecycle, entity lifecycle stavy a pravidla `LSM-001` až `LSM-015`

---

# 1. Purpose

## 1.1 Owner

**Domain (sync-and-offline-model)** jako vlastnící doména; artefakt je co-located v `docs/12-data/` jako lokální persistence-facing kontrakt, konzistentně s C2 řádkem contract mapy (`r2-vertical-slice-plan.md §7.1`). Konceptuální pojmy (`SyncState`, `LocalChangeLog`, `OfflineCommand`, `SyncOperation`) zůstávají vlastněné `sync-and-offline-model.md`; C2 z nich odvozuje **lokální kontrakt pro R2** a nepředefinovává je.

## 1.2 Proč tento kontrakt existuje

R2 potřebuje lokální data učinit **vlastnitelná a synchronizovatelná** bez rozbití offline-first toku R1. C1 (`r2-mobile-schema-migration.md`) zavedl **strukturální** existenci owner reference, sync-state, verze entity a outboxu a pravidla jejich bezpečné migrace. Chybí jediný kanonický kontrakt pro **význam a lifecycle** těchto metadat: co je lokální vlastnictví, jaké má stavy pending operace, jak funguje outbox, jak entita přechází od lokální změny k serverem potvrzenému stavu. Tímto kontraktem je C2.

C2 je záměrně **contract-only**: neobsahuje produkční kód, SQL, Drift, HTTP API ani serializaci.

## 1.3 Vztah ke C1

C1 a C2 jsou **dva blokující kontrakty `R2-01`**. C1 vlastní *jak se mobilní schéma bezpečně mění a strukturální existenci* metadat; C2 vlastní *co ta metadata znamenají a jak se chovají v čase*. Přesná hranice je v §10.

## 1.4 Které slices blokuje

- **Blocking pro `R2-01 – Local Ownership and Sync Metadata Foundation`** (spolu s C1).
- C2 sémantika je referencovaná pozdějšími R2 slices (sync v `R2-05`, conflict/rejection v `R2-06`, local-to-account migrace v `R2-07`), ale jejich vlastní blocking kontrakty jsou samostatné (viz §11).

---

# 2. Scope

## 2.1 Co tento kontrakt řeší

- **ownership model** lokálních dat: local/anonymous owner vs account owner (§4),
- **význam lokálních sync metadat**: sync state, dirty, pending, timestampy, local version, odkaz na server version (§5),
- **pending operations**: lifecycle (create/update/delete záměr), fronta, retry, pořadí, garance (§6),
- **outbox kontrakt**: co to je, kdo vlastní, kdy vzniká/zaniká (§7),
- **entity lifecycle**: logické stavy od lokální změny po serverové potvrzení (§8),
- **ownership/outbox invarianty** `LSM-001…LSM-015` (§9),
- hranice vůči C1 (§10) a budoucím kontraktům (§11),
- testing requirements a evidence gates (§12–§13),
- Ready condition (§14).

## 2.2 Co tento kontrakt výslovně neřeší

- **HTTP API, autentizaci, server, deployment** — C3/C4/C6 a backend architektura,
- **implementaci, SQL, Drift model, konkrétní názvy sloupců/tabulek/typů** — implementace `R2-01` řízená C1,
- **serializaci requestů / transport / batching / on-the-wire pořadí** — sync protocol **C10**,
- **idempotency protokol a IdempotencyRecord / `ALREADY_APPLIED` resolution** — **C11** (C2 vlastní jen *stabilní lokální idempotency key*, §6.4),
- **conflict resolution a rejection resolution algoritmy** — **C12** (C2 vlastní jen *existenci explicitního lokálního stavu*, §8),
- **algoritmus připojení lokálních dat k účtu** — **C15** (C2 vlastní jen *local/anonymous owner identitu*, která migraci umožní),
- **identity/session sémantiku účtu** — **C3** (C2 referencuje „account owner" jako identitu ustavenou C3/C4),
- **serverovou reprezentaci a server version** — **C6**/C10.

---

# 3. Source of truth

## 3.1 Jediný zdroj pravdy

Pro **význam a lifecycle lokálních ownership a sync metadat v R2** (ownership stavy, sync metadata význam, pending-operation/outbox lifecycle, entity lifecycle stavy a `LSM-*`) je jediným zdrojem pravdy tento dokument. Skutečný rozpor s vlastníky níže se řeší změnou dokumentu, ne tichou odchylkou.

## 3.2 Vztah k dalším zdrojům

- **`sync-and-offline-model.md`** vlastní konceptuální `SyncState` (§11), `LocalChangeLog` (§12), `OfflineCommand` (§13–§14), `SyncOperation` (§15–§16), `SyncPriority` (§17), `SyncDependency` (§18) a offline garance (§3). C2 na ně odkazuje a promítá je do lokálního R2 kontraktu; **nepředefinovává je**.
- **C1 (`r2-mobile-schema-migration.md`)** vlastní schema versioning, migrační pravidla a **strukturální** existenci metadat (`MSM-*`). C2 dodává jejich **význam**. Bez překryvu (§10).
- **`identity-and-profile-model.md`** vlastní `UserAccount`, `AthleteProfile`, `IdentityKind` (vč. `ANONYMOUS`). C2 referencuje anonymous/local a account owner; identitu účtu ustavuje C3.
- **Server data model (C6)** a **sync protocol (C10)** vlastní serverovou reprezentaci a transport; C2 je local-only.
- **`r2-vertical-slice-plan.md`** vlastní pořadí, contract mapu (§7.1), R2-01 (§9.1) a cross-slice invarianty (§10).

---

# 4. Ownership model (kontraktně)

## 4.1 Local owner reference

Každá **vlastnitelná** lokální entita (workout instance, session, performance, feedback, activity summary — přesný výčet potvrdí implementace R2-01 dle C1/§7) nese **odkaz na lokálního vlastníka**. C2 definuje jeho význam, ne fyzický sloupec (ten je v gesci C1/implementace).

## 4.2 Ownership stavy

Lokální vlastnictví má dva kontraktní stavy:

- **local/anonymous owner** — data vzniklá před přihlášením; stabilní lokální identita (odpovídá `IdentityKind ANONYMOUS`, `identity-and-profile-model §6`).
- **account owner** — data vlastněná přihlášeným `UserAccount`; identitu účtu ustavuje C3/C4.

## 4.3 Anonymous/local ownership

R1 a offline-vzniklá data patří **local/anonymous owner** (žádné „bez vlastníka"). Migrace z R1 inicializuje existující data na local/anonymous owner (`MSM-014`). Vlastnictví se **nikdy neodhaduje** (`LSM-003`).

## 4.4 Account ownership a připojení

Přihlášení musí **zachovat** existující local/anonymous data a připojit je k účtu bez duplicity (`INV-013`). **Algoritmus** připojení (local-to-account migrace) vlastní **C15**; C2 pouze garantuje, že local/anonymous owner identita takové připojení umožní a že server je autoritativní pro výsledné account ownership (`SAR-002/003`).

---

# 5. Sync metadata (význam, ne názvy sloupců)

Kontraktní význam lokálních sync metadat (fyzické názvy vlastní implementace dle C1):

- **sync state** — lokální stav synchronizace entity/operace; nabývá hodnot doménového `SyncState` (`sync-and-offline-model §11`); pro R2 relevantní minimálně `LOCAL_ONLY`, `DIRTY`, `QUEUED`, `CONFLICT`, `BLOCKED` (a serverem potvrzený „synced" stav).
- **dirty state** — entita má lokální změny neodeslané od poslední synchronizace.
- **pending state** — existuje čekající operace (outbox) pro danou entitu.
- **timestamps** — časové značky vzniku/změny pro pořadí, audit a diagnostiku; konzistentní s časovou politikou R1 modelu.
- **local version** — lokální verze entity pro detekci změn a pozdější konflikt (`sync-and-offline-model §12`).
- **server version reference** — placeholder odkaz na naposledy potvrzenou serverovou verzi; jeho reprezentaci a naplnění vlastní C6/C10, ne C2.

C2 určuje pouze **význam**; přechody stavů řízené výsledkem synchronizace vlastní sync protocol (C10) a conflict/rejection (C12).

---

# 6. Pending operations (lifecycle)

## 6.1 Význam

Pending operation je lokálně vytvořený **záměr změny** čekající na serverovou synchronizaci — lokální projekce doménového `OfflineCommand` (`sync-and-offline-model §13`). C2 vlastní jeho **lokální lifecycle**; doménovou taxonomii příkazů (`§13–§14`) vlastní sync model.

## 6.2 Typy záměru

Kontraktně minimálně **create / update / delete** vlastnitelné entity (konkrétní doménové příkazy jako `RecordSetPerformance`, `CompleteWorkoutSession` vlastní `sync-and-offline-model §13.2`). Delete je vždy **logický záměr**, nikoli tiché fyzické smazání potvrzených dat (`§3.4`, `LSM-006`).

## 6.3 Fronta, pořadí, retry, garance

- **Fronta:** pending operace jsou zařazeny do lokální fronty (outbox, §7).
- **Pořadí:** fronta zachovává **deterministické lokální pořadí** a deklarované závislosti mezi operacemi (`SyncDependency`, `sync-and-offline-model §18`); on-the-wire pořadí a transport vlastní C10.
- **Retry:** neúspěšná/neodeslaná operace se smí opakovat; opakování **nesmí vytvořit duplicitu** (`§3.5`, `LSM-009`). C2 nevlastní backoff/retry politiku transportu (C10); vlastní pravidlo, že retry zachovává stabilní identitu operace (§6.4).
- **Garance:** pending operace **přežije restart** (`§3.7`, `LSM-007`); dokud není serverem potvrzena, není prezentována jako synchronizovaná (`LSM-010/011`).

## 6.4 Stabilní idempotency key

Každá pending operace má **stabilní idempotency key** přiřazený při vzniku; **stejná logická operace si klíč drží napříč retry** (`sync-and-offline-model §13.3`, `§3.5`). C2 vlastní kontrakt *stability a lokálního přiřazení* tohoto klíče. **Replay resolution** (jak server pozná a odmítne duplicitu, IdempotencyRecord, `ALREADY_APPLIED`) vlastní **C11**, ne C2.

---

# 7. Outbox contract

## 7.1 Co je outbox

Outbox je **restart-safe lokální fronta pending operací** (§6) reprezentující doménové `OfflineCommand`/`SyncOperation` čekající na synchronizaci. Slouží k spolehlivému doručení lokálních záměrů na server bez ztráty a bez duplicit.

## 7.2 Kdo jej vlastní

- **Kontrakt (význam, lifecycle, garance):** tento dokument (C2).
- **Strukturální existence a migrace** outbox úložiště: C1 (`MSM-*`).
- **Transport / odeslání / potvrzení:** sync protocol (C10) — mimo scope C2.

## 7.3 Kdy položka vzniká

Outbox položka vzniká **v okamžiku lokálního potvrzeného zápisu** vlastnitelné změny (v souladu s local-first zápisem, `sync-and-offline-model §3.2`), atomicky s danou lokální transakcí, aby nevznikl potvrzený zápis bez odpovídajícího záměru ani naopak.

## 7.4 Kdy položka zaniká

Outbox položka smí být odstraněna/kompaktována **až po serverem potvrzené synchronizaci** dle retenční politiky (`sync-and-offline-model §12.4`), a nikdy tak, aby zmizela potvrzená business skutečnost (`LSM-015`, `DAR-003`). Odmítnutá nebo konfliktní položka nezaniká tiše — přechází do explicitního stavu (§8).

---

# 8. Entity lifecycle (logické stavy)

Logická cesta vlastnitelné entity / její pending operace od lokální změny po serverové potvrzení (bez síťového protokolu; hodnoty referencují `SyncState`, `sync-and-offline-model §11`):

1. **LOCAL_ONLY** — entita existuje jen lokálně; po migraci z R1 výchozí (`MSM-014`).
2. **DIRTY** — má lokální změny neodeslané od poslední synchronizace.
3. **QUEUED** — odpovídající pending operace čeká v outboxu (§7).
4. *(in-flight)* — operace je předána synchronizaci; přechody z tohoto bodu vlastní sync protocol (C10).
5. **synced** — server potvrdil; entita/operace je synchronizovaná. Do tohoto stavu ji smí přesunout **pouze serverový výsledek** (`LSM-010`).
6. **CONFLICT** — serverová a lokální změna nejsou bezpečně slučitelné (`§3.6`); explicitní stav, ne skrytý error. Resolution vlastní C12.
7. **BLOCKED** — operace nemůže pokračovat kvůli závislosti, oprávnění nebo bezpečnostnímu pravidlu (`sync-and-offline-model §11.5`).
8. **rejected** — server operaci odmítl; **není prezentována jako synchronizovaná** (`LSM-011`); handling vlastní C12.

C2 vlastní **existenci a význam** těchto lokálních stavů a pravidlo, že klient nikdy nepotvrdí sám sebe. **Konkrétní přechodová pravidla řízená serverem** (5→8) vlastní C10/C12.

---

# 9. Ownership & outbox invariants (`LSM`)

Nová řada pro lokální ownership a outbox metadata. Doplňuje, neoslabuje `INV-*`, `PDR-*`, `DAR-*`, `MSM-*`.

- **LSM-001 — Vlastnitelná entita má vlastníka.** Každá vlastnitelná lokální entita nese owner reference; vlastník je `local/anonymous` nebo `account` (§4).
- **LSM-002 — Zachování dat před přihlášením.** Data vzniklá před přihlášením patří stabilnímu local/anonymous owner; přihlášení je zachová a připojí bez duplicity (`INV-013`; algoritmus C15).
- **LSM-003 — Ownership se neodhaduje.** Neznámé vlastnictví se nedefaultuje na account; „unknown" ≠ „account" (`DAR-015`, analogicky `PDR-012`).
- **LSM-004 — Server vynucuje ownership.** Klientem dodané owner ID není samo o sobě důvěryhodné; autoritativní je server (`SAR-002/003`, R2 invariant §10.4).
- **LSM-005 — Bezpečná inicializace sync stavu.** Vlastnitelná/synchronizovatelná entita má lokální sync state; migrovaná R1 data začínají `LOCAL_ONLY` (`MSM-014`).
- **LSM-006 — Potvrzená lokální skutečnost tiše nezmizí.** Sync ani delete-záměr nesmí tiše odstranit potvrzená data (dokončené série, session, feedback, activity, poznámky) (`§3.4`, R2 invariant §10.6).
- **LSM-007 — Pending přežije restart.** Outbox položka přežije restart aplikace (`§3.7`, R2 invariant §10.3).
- **LSM-008 — Stabilní idempotency key.** Každá pending operace má stabilní idempotency key přiřazený při vzniku; stejná logická operace si klíč drží napříč retry (`§13.3`, `§3.5`). Replay resolution vlastní C11.
- **LSM-009 — Retry bez duplicit.** Opakování operace se stabilním klíčem nesmí vytvořit druhý workout/sérii/activity/completion (`§3.5`, `INV` o dvojím dokončení).
- **LSM-010 — Klient nepotvrzuje sám sebe.** Do „synced" přesune operaci pouze serverový výsledek; klient nikdy nepotvrdí vlastní operaci (server autoritativní, `§3.3`; analogicky `PDR-004`).
- **LSM-011 — Odmítnutí není synchronizace.** Odmítnutá nebo konfliktní operace má explicitní lokální stav (`CONFLICT`/`BLOCKED`/`rejected`) a nesmí být prezentována jako synchronizovaná (`§3.6`, R2 invariant §10.5).
- **LSM-012 — Deterministické pořadí a závislosti.** Outbox zachovává deterministické lokální pořadí a deklarované závislosti (`SyncDependency §18`); transport vlastní C10.
- **LSM-013 — Stabilní nerecyklované identifikátory.** Lokální identifikátory jsou stabilní a nerecyklují se při připojení k účtu, merge ani sync (`INV-021`).
- **LSM-014 — Pozdní offline operace neobnoví zrušené.** Pozdě přijatá/odeslaná offline operace nesmí obnovit účet, vztah ani data autoritativně zrušená/smazaná (`INV-014`).
- **LSM-015 — Append-only interpretace, bezpečná retence.** Lokální change/outbox log je pro interpretaci append-only; technické záznamy se smí kompaktovat dle retence až po potvrzené synchronizaci, nikdy se ztrátou potvrzené business skutečnosti (`§12.4`, `DAR-003`).

---

# 10. Interaction with C1

| Aspekt | Vlastní **C1** (mobile schema migration) | Vlastní **C2** (tento kontrakt) |
|---|---|---|
| Schema versioning a migrační pravidla | ano (`MSM-*`) | ne |
| **Strukturální existence** owner ref / sync-state / verze / outbox | ano | ne |
| Bezpečná migrace a inicializace metadat (na úrovni „proběhne bezpečně") | ano (`MSM-005/014`) | ne |
| **Význam** owner reference (local/anonymous vs account) | ne | ano (§4) |
| **Význam** sync state / dirty / pending / version | ne | ano (§5) |
| **Lifecycle** pending operace a outboxu | ne | ano (§6–§8) |
| Stabilní **idempotency key** (lokální identita operace) | ne | ano (§6.4) |
| Ownership/outbox **invarianty** | ne | ano (`LSM-*`) |

Bez překryvu: C1 = *jak se schéma bezpečně mění a co strukturálně existuje*; C2 = *co to znamená a jak se to chová v čase*. Implementace `R2-01` naplní obojí.

---

# 11. Interaction with future contracts

- **C3 (identity & session):** ustavuje `UserAccount` a auth session. C2 referencuje „account owner" jako identitu z C3; C2 nevlastní auth ani session. Terminologicky: auth session ≠ WorkoutSession ≠ lokální aplikační session (`r2-vertical-slice-plan §8`).
- **C6 (server data model):** serverová reprezentace vlastnictví a verzí, server version. C2 je local-only; server version reference (§5) je placeholder naplněný C6/C10.
- **C10 (sync protocol):** transport, push/pull, on-the-wire pořadí, batching, retry/backoff politika, přechody in-flight → synced/rejected. C2 vlastní lokální frontu, pořadí a stabilní klíč; ne protokol.
- **C11 (idempotency):** replay resolution, IdempotencyRecord, `ALREADY_APPLIED`. C2 vlastní stabilní lokální idempotency key; ne serverové rozhodnutí o duplicitě.
- **C12 (conflict/rejection):** klasifikace a resolution konfliktů a odmítnutí. C2 vlastní existenci explicitních lokálních stavů `CONFLICT`/`BLOCKED`/`rejected`; ne jejich resolution.
- **C15 (local-to-account migration):** algoritmus připojení local/anonymous dat k účtu při prvním přihlášení, řešení duplicit a stabilita ID. C2 vlastní local/anonymous owner identitu (`LSM-002/013`), která migraci umožní; ne samotný algoritmus.

---

# 12. Testing requirements (kontraktně)

Kontraktní požadavky na ověření (implementaci vlastní `R2-01`; `test-strategy §5.2/§7.1`, `QTR-003/004`):

1. **Pending persistence** — nad skutečnou SQLite (`QTR-004`): outbox položka vzniká atomicky s lokálním zápisem a je perzistentní (`LSM-007`, §7.3).
2. **Restart** — po restartu aplikace pending operace stále existuje a je zpracovatelná; entita si drží svůj lokální stav (`LSM-007`, `§3.7`).
3. **Ordering** — deterministické lokální pořadí a respektování deklarovaných závislostí (`LSM-012`).
4. **Ownership** — nová i migrovaná data mají korektní owner (local/anonymous po migraci); vlastnictví se neodhaduje (`LSM-001/003/005`).
5. **Determinismus** — stejný vstupní stav a stejná operace vedou k témuž lokálnímu stavu a témuž stabilnímu idempotency key; retry key nemění (`LSM-008`, deterministicky, ne flaky — `QTR`).
6. **Bez duplicit / bez ztráty** — opakování se stabilním klíčem nevytvoří duplicitu (`LSM-009`); potvrzená data se neztratí (`LSM-006`).
7. **Explicitní ne-synchronizovaný stav** — dokud není serverové potvrzení, operace není „synced" (`LSM-010/011`) — ověřitelné bez sítě přes lokální stav.

Bez UI a bez sítě tam, kde to jde (`QTR-003`). Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 13. Evidence gates

Při implementaci `R2-01` (v části vlastněné C2) musí být doloženo:

- **Outbox/pending evidence:** test vzniku, perzistence a restart-safe obnovy pending operace.
- **Ownership evidence:** test inicializace local/anonymous owner na migrovaných datech a absence odhadu vlastnictví.
- **Idempotency-key evidence:** test stability klíče napříč retry (bez duplicit) — replay resolution je odloženo do C11.
- **Ordering evidence:** test deterministického pořadí a závislostí.
- **No-silent-loss evidence:** test, že delete-záměr ani sync stav neodstraní potvrzená data.
- **R1 regression evidence:** R1 offline kritický tok beze změny (R2 invariant §10.1).
- **Traceable release evidence** navázaná na konkrétní commit a CI run (`QTR-015`, `DRD-014`).

Chybějící povinný důkaz znamená, že slice není Done (`DRD-014`).

---

# 14. Ready condition

## 14.1 Kdy je C2 dokončen (Done)

C2 je Done, právě když tento dokument definuje: ownership model (§4), význam sync metadat (§5), pending-operation lifecycle (§6), outbox kontrakt (§7), entity lifecycle stavy (§8), invarianty `LSM-001…LSM-015` (§9), hranice vůči C1 (§10) a budoucím kontraktům (§11), testing requirements a evidence gates (§12–§13); je zapsán v doc mapě a status auditu; a neobsahuje produkční kód, SQL, Drift ani API. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C2 je tedy **Done**.

## 14.2 Dopad na R2-01

`R2-01` má dle `r2-vertical-slice-plan §9.1` **právě dva** blokující kontrakty: **C1 a C2**. Oba jsou nyní Done → **`R2-01` je `READY`** (neimplementováno). `R2-02` až `R2-08` zůstávají `NOT_READY` (čekají na své blokující kontrakty).

## 14.3 Další kanonický krok

Podle `r2-vertical-slice-plan §9.2` a contract mapy jsou dalšími blokujícími kontrakty (pro `R2-02`):

- **C3 – Identity & session contract** — `docs/07-backend/r2-identity-session-contract.md`,
- **C4 – Authentication API contract** — `docs/07-backend/r2-auth-api-contract.md`.

C2 tyto kontrakty **nevytváří**; jsou dalším dokumentačním krokem.

---

# 15. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — C2 map (§7.1), R2-01 (§9.1), identity hranice (§8), cross-slice invarianty (§10).
- `docs/12-data/r2-mobile-schema-migration.md` — C1; `MSM-001…MSM-015`, strukturální metadata (§7).
- `docs/06-domain/sync-and-offline-model.md` — offline garance `§3`, `SyncState §11`, `LocalChangeLog §12`, `OfflineCommand §13–§14`, `SyncOperation §15–§16`, `SyncPriority §17`, `SyncDependency §18`.
- `docs/06-domain/identity-and-profile-model.md` — `UserAccount`, `AthleteProfile`, `IdentityKind` (`ANONYMOUS`), anonymní použití a připojení.
- `docs/06-domain/domain-invariants.md` — `INV-013` (zachování při registraci), `INV-014` (žádná reaktivace zrušeného), `INV-021` (nerecyklace ID), invarianty recovery a dvojího dokončení.
- `docs/12-data/data-architecture.md` — `DAR-003` (historická interpretovatelnost), `DAR-013` (bezpečná lokální migrace), `DAR-015` (unknown ≠ zero).
- `docs/11-security/security-architecture.md` — `SAR-002` (server-side authorization), `SAR-003` (nedůvěryhodný klient), `SAR-006` (secrets mimo klienta), `SAR-011` (bezpečný offline replay).
- `docs/08-mobile/mobile-architecture.md` — local-first read model, recovery/checkpoint (`MAR-007/013`).
- `docs/14-quality/test-strategy.md` — `§5.2`, `§7.1`, `QTR-003/004/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-007`, `DRD-014`.
