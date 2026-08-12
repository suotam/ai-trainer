# AI Trainer – R2 Sync Protocol Contract (C10)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r2-sync-protocol-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Backend Architecture
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C10 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sync-and-offline-model.md` (§15–§28, §154), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-idempotency-contract.md` (C11), `docs/11-security/r2-authorization-ownership-contract.md` (C8), `docs/07-backend/r2-device-registration-contract.md` (C9), `docs/12-data/r2-server-data-model.md` (C6), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/07-backend/r0-api-contract.md`, `docs/11-security/r2-audit-event-contract.md` (C14), `docs/12-data/data-architecture.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-05 (sync push), OpenAPI rozšíření, C12 conflict/rejection (R2-06), budoucí pull sync kontrakt
**Vlastněné pojmy nebo kontrakty:** R2 push sync protokol (tvar push operace, batch, pořadí, per-item výsledky, potvrzení po commitu, R2-05 podmnožina SyncOperationType/SyncResult, entity scope) a pravidla `SPC-001` až `SPC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Domain (sync-and-offline-model) + Backend Architecture.** R2-05 přenese poprvé lokální data na server. Doménový model synchronizace je široký (`sync-and-offline-model` §15–§28); R2-05 potřebuje jeho **závaznou, malou podmnožinu**: jak vypadá push operace, jak se dávkuje, v jakém pořadí se aplikuje, jak vypadá výsledek a kdy smí klient operaci označit za synchronizovanou. Tímto kontraktem je C10.

C10 je **contract-only**: nedefinuje DTO, controllery, DB migrace ani mobilní sync engine. Doménové pojmy vlastní `sync-and-offline-model`; C10 je zužuje na R2-05 P0.

## 1.2 Které slices blokuje

- **Blocking pro `R2-05 – Ownership Authorization and First Sync (push)`** (spolu s C11, rozšířením C6 o synced entity a sync částí C14).
- Referencován R2-06 (conflict/rejection — C12 na C10 navazuje) a R2-07 (replay při attach — C15).

## 1.3 P0 zúžení (plán §12)

R2 P0 je **push + serverové potvrzení**. Pull synchronizace, ServerChangeLog konzumace, merge a konflikt resolution UX jsou mimo tento kontrakt (pull vlastní budoucí rozšíření C10; resolution C12). Push response smí vracet autoritativní `serverVersion` — to není pull.

---

# 2. Scope

## 2.1 Co C10 řeší

- **push operaci** — tvar a význam polí (§4),
- **R2-05 podmnožinu SyncOperationType a entity scope** (§5),
- **batch a pořadí aplikace** (§6),
- **per-item výsledky a R2-05 podmnožinu SyncResult** (§7),
- **potvrzení po serverovém commitu** a stavové přechody outboxu (§8),
- **transport hranici** (kanonická cesta, auth kontext) (§9),
- **verzování entit na serveru (expectedServerVersion baseline)** (§10),
- invarianty `SPC-001…SPC-015` (§11), hranice (§12), testing/evidence (§13–§14), Ready (§15).

## 2.2 Co C10 výslovně neřeší

- **pull sync, ServerChangeLog, cursor konzumace** — budoucí rozšíření (P0 mimo scope; `SyncCursor` §23 zůstává doménový),
- **idempotency replay protokol** — **C11** (C10 jen vyžaduje idempotency key per operace),
- **conflict/rejection klasifikaci a resolution** — **C12** (C10 vlastní jen to, že `VERSION_CONFLICT`/odmítnutí je explicitní per-item výsledek),
- **ownership enforcement pravidla** — **C8** (C10 je aplikuje per položka),
- **lokální outbox lifecycle** — **C2** (C10 definuje jen mapování outbox → push operace a potvrzovací přechod),
- **serverové schéma synced entit** — **C6 §8.4** (C10 vlastní protokol, ne úložiště),
- **background sync, retry policy, backoff, dead-letter** — R2 non-goal „background framework do zásoby" (`r2-vertical-slice-plan §5.2`); R2-05 spouští sync explicitně,
- **blob/attachment upload, AI objekty, integrace** — R3+/R4+,
- **atomický batch (`ATOMIC_BATCH`)** — forward-scoped; R2-05 používá `ORDERED_OPERATIONS` (§6).

---

# 3. Source of truth and precedence

1. **Bezpečnost** — `SAR-*`, C8 (`AOC-*` — per-item ownership, default deny).
2. **Doménový sync model** — `sync-and-offline-model` §15–§28 a invarianty §154; C10 nepředefinovává, zužuje.
3. **Lokální metadata** — C2 (`LSM-*` — stabilní idempotency key, deterministické pořadí, outbox stavy).
4. **Datová architektura** — `DAR-*` (potvrzení až po commitu, append-only historie), C6.
5. **HTTP pravidla** — `r0-api-contract` (`APR-*`), C4 (auth kontext).

C10 vlastní **R2-05 push protokol** a `SPC-*`.

---

# 4. Push operace (kontraktně)

Jedna push operace odpovídá jedné outbox položce (C2 `LocalChangeLog`/`OfflineCommand`) a nese (podmnožina `SyncOperation §15.2`):

| Pole | Význam | Zdroj |
|---|---|---|
| `operationId` | client-generated ID operace | outbox `id` (C2) |
| `idempotencyKey` | stabilní klíč operace (C11) | outbox `idempotency_key` (LSM-008) |
| `sequence` | deterministické pořadí per zařízení | outbox `sequence` (LSM-012) |
| `operationType` | typ operace (§5) | outbox `operation_type` |
| `entityType` / `entityId` | cílová entita (client-generated ID, SDM-005) | outbox |
| `payload` | plný aktuální stav entity (state-based push, §5.3) | lokální DB snapshot |
| `expectedServerVersion` | verze, nad kterou klient operoval; `null` = první push (§10) | lokální sync metadata |

- **Owner se nepřenáší jako důvěryhodná hodnota**: principal je z ověřené session (AOC-002); lokální `owner_id` smí být v payload jen informativně a server jej ověří (AOC-006). `deviceId` = installation ID (C9) je povinná technická reference batch (§6), ne autorizační důkaz (DRC-009).
- **Payload neobsahuje secrets** ani data cizích vlastníků.

---

# 5. R2-05 podmnožina typů a entit

## 5.1 SyncOperationType (z `§16`)

R2-05 používá pouze: **`CREATE_ENTITY`**, **`UPDATE_ENTITY`**. Ostatní typy (`DELETE_ENTITY`, `RESTORE_ENTITY`, `APPLY_COMMAND`, `UPLOAD_BLOB`, …) jsou forward-scoped a přidávají se append-only s kontraktem, který je potřebuje. Neznámý typ server odmítne (`VALIDATION_FAILED`, default deny).

## 5.2 Entity scope R2-05

Podporovaná data (plán §5.1 „profil, kalendář/instance, workouty, session výsledky"): `WORKOUT_INSTANCE`, `WORKOUT_SESSION`, `STEP_PERFORMANCE`, `SET_PERFORMANCE`, `WORKOUT_FEEDBACK`, `ACTIVITY_SUMMARY`. AthleteProfile se synchronizuje už přes R2-04 API (mimo outbox). Seed/demo data se **nesynchronizují** jako uživatelská (plán §12; přesné pravidlo vlastní C15).

## 5.3 State-based push

R2-05 přenáší **plný aktuální stav entity** (state-based), ne delta příkazy — odpovídá C2 pojetí outbox položky jako „změna entity" a snižuje P0 složitost. Append-only pravidlo trvá: performance/feedback/summary se serverově nikdy nepřepisují destruktivně (`§29`, `DAR-003`); `UPDATE_ENTITY` na append-only entitě smí jen doplňovat/aktualizovat vlastní řádek dle §10.

---

# 6. Batch a pořadí

- Push batch je **`ORDERED_OPERATIONS`** (`§19.3`): operace jednoho zařízení seřazené podle `sequence` (LSM-012). Server je aplikuje **v tomto pořadí**; tím jsou pokryty přirozené závislosti R1 dat (instance → session → performance → feedback/summary) bez samostatného dependency grafu (SyncDependency §18 je forward).
- Batch nese **installation ID zařízení** (C9) pro evidenci a audit.
- **Selhání položky nezastaví batch** (žádný `ATOMIC_BATCH` v P0): následující položky se zpracují; položka závislá na odmítnuté entitě přirozeně skončí `DEPENDENCY_FAILED`/`VALIDATION_FAILED` a zůstává pending/rejected na klientu.
- Velikost batch je omezená (konkrétní limit je implementační konfigurace; překročení = `INVALID_REQUEST`).
- **Jedna položka = jedna transakce** na serveru (aplikace změny + idempotency záznam + audit atomicky; C11 §6).

---

# 7. Per-item výsledky (podmnožina `SyncResult §21`)

Server vrací výsledek **pro každou položku**:

| Výsledek | Význam | Klientský efekt (C2) |
|---|---|---|
| `SUCCESS` | operace commitnuta; vrací autoritativní `serverVersion` | outbox → potvrzeno; sync_state → `SYNCED` |
| `ALREADY_APPLIED` | idempotentní replay (C11) — vrací původní výsledek | jako `SUCCESS`, bez duplicity |
| `VERSION_CONFLICT` | `expectedServerVersion` nesouhlasí (§10) | explicitní `CONFLICT` stav; **ne synchronizováno**; resolution C12/R2-06 |
| `VALIDATION_FAILED` | nevalidní payload/typ/entita | explicitní rejected stav; ne synchronizováno |
| `PERMISSION_DENIED` | ownership/authorization selhání (C8; per-item, AOC-009) | explicitní rejected stav; ne synchronizováno |
| `DEPENDENCY_FAILED` | cílová nadřazená entita neexistuje/odmítnuta | zůstává pending/rejected dle příčiny |

- Enumeration-safe: `PERMISSION_DENIED` per-item **neprozrazuje existenci** cizí entity (tělo bez detailu; AOC-007 duch pravidla platí i zde).
- Ostatní `SyncResult` hodnoty (`RETRY_LATER`, `SAFETY_BLOCKED`, …) jsou forward-scoped.
- HTTP status batch requestu je 200 i při odmítnutých položkách (výsledky jsou per-item); 4xx/5xx platí jen pro selhání requestu jako celku (auth, nevalidní obálka, server error) dle `APR-*`/C4.

---

# 8. Potvrzení a stavové přechody

- **Potvrzení přijde až po serverovém commitu** (`R2P-006`, `SAR-011`): klient označí outbox položku jako potvrzenou a entitu `SYNCED` **výhradně** na základě `SUCCESS`/`ALREADY_APPLIED` odpovědi. Optimistické potvrzení je zakázáno.
- **Odmítnutá operace není synchronizovaná** (`R2P-007`): `VERSION_CONFLICT`/`VALIDATION_FAILED`/`PERMISSION_DENIED` vede na explicitní lokální stav (C2 `CONFLICT`/`BLOCKED`), nikdy na tiché zahození ani na `SYNCED`.
- **Restart uprostřed push**: neodpovězené operace zůstávají pending (restart-safe outbox, C2); opakování je idempotentní přes stejný `idempotencyKey` (C11) — žádná duplicita (`R2P-006`).
- **Potvrzená lokální skutečnost tiše nezmizí** (`§3.4`, `R2P-008`): žádný výsledek push nesmí vést k lokálnímu smazání potvrzených dat; sync nepřepisuje aktivní lokální WorkoutSession.
- Server ukládá `last_sync_at` zařízení (C6 §8.2) při úspěšném batchi.

---

# 9. Transport hranice

- Kanonická operace: **`POST /api/v1/sync/push`** (jediný push endpoint pro R2-05; detailní tvar vlastní OpenAPI při implementaci, analogicky C4→OpenAPI).
- Vyžaduje **platnou access session** (C4) a registrované zařízení (C9) — batch od neregistrované instalace je `INVALID_REQUEST`.
- Kanonický error envelope pro request-level chyby (`APR-*`); per-item výsledky jsou v těle odpovědi (§7).
- Credentials nikdy v URL; payload se neloguje (SAR-012).

---

# 10. Verzování entit (baseline)

- Server drží pro každou synced entitu **monotónní `serverVersion`** (C6 §9); `SUCCESS` ji vrací a klient si ji uloží do lokálních sync metadat.
- `CREATE_ENTITY`: `expectedServerVersion = null`; existuje-li entita (a nejde o idempotentní replay), je to `VERSION_CONFLICT`.
- `UPDATE_ENTITY`: `expectedServerVersion` musí odpovídat aktuální serverové verzi, jinak `VERSION_CONFLICT` (optimistic concurrency `§31`; push-first riziko `§28.1`).
- Konflikt je **normální doménový stav** (`§3.6`) — explicitní výsledek, ne skrytá chyba; **resolution vlastní C12** (R2-06). V R2-05 konfliktní položka zůstává lokálně v `CONFLICT` stavu.
- VersionVector, three-way merge a field-level merge (`§32/§37/§38`) jsou mimo R2.

---

# 11. Sync protocol invariants (`SPC`)

Nová řada. Doplňuje, neoslabuje `LSM-*`, `AOC-*`, `SDM-*`, `DRC-*`, `R2P-*`.

- **SPC-001 — Push jen přihlášený a registrovaný.** Push vyžaduje platnou access session a registrovanou instalaci (C4, C9); anonymní data se nepushují (attach vlastní C15).
- **SPC-002 — Operace = outbox položka.** Každá push operace odpovídá outbox položce se stabilním `idempotencyKey` a deterministickým `sequence` (C2 LSM-008/012).
- **SPC-003 — Pořadí per zařízení.** Server aplikuje operace jednoho batch v pořadí `sequence`; přeuspořádání je zakázáno.
- **SPC-004 — Per-item rozhodnutí.** Ownership, validace, verze i idempotence se vyhodnocují per položka (AOC-009); selhání položky nezastaví batch a úspěch batch nepotvrzuje odmítnuté položky.
- **SPC-005 — Potvrzení až po commitu.** `SYNCED`/potvrzený outbox vzniká výhradně z `SUCCESS`/`ALREADY_APPLIED` po serverovém commitu (`R2P-006`, `SAR-011`).
- **SPC-006 — Odmítnutí je explicitní.** Odmítnutá/konfliktní položka má explicitní per-item výsledek a explicitní lokální stav; nikdy není prezentována jako synchronizovaná (`R2P-007`, `§3.6`).
- **SPC-007 — Idempotentní replay.** Opakování operace se stejným klíčem nevytvoří duplicitu a vrátí původní logický výsledek (`ALREADY_APPLIED`; protokol C11).
- **SPC-008 — Client ID se zachovává.** Server přijímá client-generated entity ID a nepřečíslovává je (SDM-005); mapování ID neexistuje.
- **SPC-009 — Optimistic concurrency.** `UPDATE_ENTITY` nese `expectedServerVersion`; nesoulad je `VERSION_CONFLICT`, ne přepis (`§31`, `§28.1`).
- **SPC-010 — Append-only se nepřepisuje.** Performance/feedback/summary data se serverově nemažou ani destruktivně nepřepisují (`§29`, `DAR-003`); tombstone/delete je mimo R2-05.
- **SPC-011 — Lokální skutečnost nemizí.** Žádný push výsledek nevede k tichému smazání potvrzených lokálních dat ani k přepsání aktivní lokální WorkoutSession (`R2P-008`).
- **SPC-012 — Restart-safe replay.** Neodpovězené operace zůstávají pending a po restartu se přehrají idempotentně; klient nikdy „neuhádne" výsledek.
- **SPC-013 — Typová podmnožina append-only.** R2-05 zná jen `CREATE_ENTITY`/`UPDATE_ENTITY` a entity scope §5.2; nové typy/entity se přidávají kontraktem, ne implementací (`R2P-003/012`).
- **SPC-014 — Sync se audituje.** applied/rejected/conflict/ownership-denied/replay generují audit záznamy dle C14 §7, bez citlivého payloadu.
- **SPC-015 — Žádný background framework.** R2-05 spouští push explicitně (uživatelská akce / přihlášení); background scheduling, retry policy a backoff jsou mimo R2 (`r2-vertical-slice-plan §5.2`).

---

# 12. Interaction with other contracts

- **C2 (outbox):** vlastní lokální lifecycle; C10 definuje mapování na push operaci a potvrzovací přechody (§4, §8).
- **C11 (idempotency):** vlastní replay protokol a IdempotencyRecord; C10 jen vyžaduje klíč a definuje `ALREADY_APPLIED` místo v protokolu.
- **C8 (ownership):** vlastní autorizační pravidla; C10 je aplikuje per položka (`PERMISSION_DENIED`).
- **C9 (device):** dodává installation ID batch; sync per zařízení (`last_sync_at`).
- **C6 (server data model):** §8.4 drží synced tabulky a `serverVersion` sloupce; C10 protokol.
- **C12 (conflict/rejection, forward):** klasifikace a resolution konfliktů/odmítnutí; C10 vlastní jen jejich explicitní per-item signalizaci.
- **C14 (audit):** sync události §7; C10 určuje kdy vznikají.
- **C15 (migration, forward):** attach předpřihlašovacích dat; C10 pushuje jen data účtu (SPC-001).

---

# 13. Testing requirements (kontraktně)

Implementace R2-05 musí ověřit (`test-strategy §7/§8`, `QTR-004/005`):

1. **Offline-create → later-replay** — operace vytvořená offline přežije restart a později se idempotentně přehraje (SPC-012).
2. **Druhý push → `ALREADY_APPLIED`** — žádná duplicita na serveru (Testcontainers; s C11).
3. **Pořadí** — batch se aplikuje podle `sequence`; performance před session selže (`DEPENDENCY_FAILED`/`VALIDATION_FAILED`), správné pořadí projde.
4. **Ownership per-item** — smíšená batch odmítne jen cizí položky (`PERMISSION_DENIED`), vlastní projdou (AOC-009).
5. **Version conflict** — `UPDATE_ENTITY` se starou verzí → `VERSION_CONFLICT`, serverový stav nezměněn, lokální stav `CONFLICT`.
6. **Potvrzení po commitu** — klient označí `SYNCED` až po odpovědi; restart uprostřed push nevede k duplicitě ani ke ztrátě.
7. **Odmítnutí ≠ synchronizováno** — rejected položka má explicitní stav; UI ji neprezentuje jako synced.
8. **Client ID zachováno** — serverová entita nese client-generated ID (SDM-005).
9. **Audit** — applied/rejected/conflict/replay události dle C14 §7 bez citlivého payloadu.
10. **R1 offline tok beze změny** (R2P-004) — airplane mode kritický tok.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 14. Evidence gates

Implementace R2-05 musí doložit: idempotency/replay testy, ownership per-item testy, ordering testy, version-conflict testy, restart-uprostřed-push test, potvrzení-po-commitu důkaz, audit důkaz, R1 offline regresi; traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 15. Ready condition

## 15.1 Kdy je C10 dokončen (Done)

C10 je Done, právě když definuje: push operaci (§4), R2-05 podmnožinu typů a entit (§5), batch a pořadí (§6), per-item výsledky (§7), potvrzení po commitu (§8), transport hranici (§9), verzování (§10), invarianty `SPC-001…SPC-015` (§11), hranice (§12), testing/evidence (§13–§14); je zapsán v doc mapě a status auditu; a neobsahuje DTO, endpoint implementaci ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C10 je **Done**.

## 15.2 Dopad na R2-05

`R2-05` vyžaduje R2-04 Done (splněno) + C10, C11, rozšíření C6 o synced entity a sync část C14. C10 je hotov; zbývající části viz C11/C6/C14.

---

# 16. References

- `docs/06-domain/sync-and-offline-model.md` — §3 principy, §15 SyncOperation, §16 typy, §19 batch, §21 SyncResult (`ALREADY_APPLIED` §21.1), §22 IdempotencyRecord, §23 cursor (forward), §26 push tok, §28 push-first rizika, §29 append-only, §31 optimistic concurrency, §154 invariance synchronizace.
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-008/009/010/011/012/013`.
- `docs/12-data/r2-idempotency-contract.md` — C11.
- `docs/11-security/r2-authorization-ownership-contract.md` — C8; `AOC-002/006/007/009`.
- `docs/07-backend/r2-device-registration-contract.md` — C9; `DRC-009`.
- `docs/12-data/r2-server-data-model.md` — C6; §8.4 synced entity, §9 sync metadata.
- `docs/07-backend/r2-auth-api-contract.md` — C4; auth kontext.
- `docs/07-backend/r0-api-contract.md` — `APR-*` envelope.
- `docs/11-security/r2-audit-event-contract.md` — C14 §7 sync události.
- `docs/12-data/data-architecture.md` — `DAR-003` append-only, potvrzení po commitu.
- `docs/13-delivery/r2-vertical-slice-plan.md` — §9.5 R2-05, §12 P0 push zúžení, `R2P-004/006/007/008/012`.
- `docs/14-quality/test-strategy.md` — `QTR-004/005/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-014`.
