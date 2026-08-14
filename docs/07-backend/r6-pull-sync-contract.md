# AI Trainer – R6 Pull Sync Protocol Contract (C41)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r6-pull-sync-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Backend
**Kontraktní ID:** C41 (dle `docs/13-delivery/r6-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r2-sync-protocol-contract.md` (C10 — push beze změny), `docs/12-data/r2-server-data-model.md` (C6 §8.4), `docs/06-domain/r3-sync-extension-contract.md` (C24), `docs/11-security/r2-authorization-ownership-contract.md` (C8), `docs/13-delivery/r6-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R6-01, C42 (klientská merge sémantika), C45 (restore orchestrace)
**Vlastněné pojmy nebo kontrakty:** pull endpoint, kurzor, batch/stránkování, pull scope a pravidla `PSP-001` až `PSP-015`

---

# 1. Purpose

Pull je **druhý směr existujícího sync mechanismu**: autentizovaný klient si vyžádá změny entit svého účtu od posledního známého kurzoru. Server **vydává přesně to, co přijal** (payload neprůhledný, C6 §8.4) — význam a aplikaci vlastní klient (C42). Push sémantika C10/C11 se nemění.

**Blocking pro `R6-01`.**

# 2. Endpoint a tvar

**`POST /api/v1/sync/pull`** (jediný pull endpoint; POST kvůli strukturovanému tělu s kurzory):

Request: `{ installationId, cursors: [{entityType, cursor?}], limit? }`
- `entityType` ∈ sjednocený sync registr (R1 šest typů + R3 osm + `DAILY_CHECK_IN`); neznámý typ = `INVALID_REQUEST` (400).
- `cursor` je **neprůhledný token vydaný serverem** (formát vlastní server; klient ho jen ukládá a vrací); chybějící/`null` = od začátku.
- `limit` volitelný, server cap 200 položek na odpověď.

Response: `{ items: [{entityType, entityId, serverVersion, payload}], cursors: [{entityType, cursor}], hasMore }`
- `items` deterministicky řazené (pořadí typů dle registru; uvnitř typu stabilní server pořadí změn).
- `cursors` vrací nový token **pro každý požadovaný typ** (i beze změn — token se nemění); klient je persistuje per typ.
- `hasMore = true` ⇒ klient opakuje volání s vrácenými kurzory, dokud není `false`.

# 3. Sémantika

- **Scope = vlastní účet** (C8): výhradně řádky `account_id = principal`; cizí data neexistují (anti-IDOR).
- **„Změny od kurzoru"**: server vydá řádky vytvořené či aktualizované po stavu, který token reprezentuje; interní řazení/format tokenu je serverová věc (PSP-004) — smí být založen na server časech/ID, klient ho nikdy neinterpretuje.
- **Overlap-safe**: protokol smí tutéž řádku doručit vícekrát (hraniční tokeny, opakování po přerušení) — aplikace na klientu je idempotentní (C42); nikdy však nesmí řádku mezi dvěma kurzory tiše přeskočit.
- **Payload beze změny**: přesně uložený JSONB + `serverVersion` (C10 §10); server nic nedopočítává.
- Prázdný výsledek je validní odpověď (`items: []`, `hasMore: false`).

# 4. Invarianty (`PSP`)

- **PSP-001 — Push beze změny.** C10/C11/C12 sémantika nedotčena; pull je aditivní endpoint.
- **PSP-002 — Ownership přísně** (C8): jen vlastní účet; žádný parametr nevybírá cizí data; access session povinná.
- **PSP-003 — Payload neprůhledný** (C6 §8.4): server payload nečte, nevalidauje ani neobohacuje.
- **PSP-004 — Kurzor je neprůhledný token** vydaný serverem; klient ukládá/vrací; formát smí server změnit bez dopadu na klienty (staré tokeny musí zůstat čitelné, nebo být bezpečně odmítnuty jako `INVALID_REQUEST`).
- **PSP-005 — Žádná ztráta mezi kurzory.** Každá změna committed před vydáním tokenu je dosažitelná následným pullem s tímto tokenem; overlap dovolen, mezera nikdy.
- **PSP-006 — Deterministické řazení** dle §2; opakovaný pull stejného stavu = identická odpověď.
- **PSP-007 — Batch cap 200** (server); `hasMore` poctivě; stránkování konverguje (konečný počet iterací pro konečný stav).
- **PSP-008 — Idempotence.** Pull nemění serverový stav (žádné side-effects mimo audit).
- **PSP-009 — Typy výhradně z registru** (`SyncEntityType`); neznámý typ typované 400; nový typ = kontrakt (C24 vzor).
- **PSP-010 — Tombstones připraveny.** Item tvar je rozšiřitelný o `deleted` příznak (C44); do té doby se smazání nevydává.
- **PSP-011 — Kanonický error envelope** (C4 vzor): 401 bez session, 400 nevalidní request; žádné leaky.
- **PSP-012 — Rate limiting baseline** platí (C4/C31 vzor — pre-auth IP).
- **PSP-013 — Audit bez payloadů** (C14): pull se audituje jen jako událost s počty, nikdy s obsahem.
- **PSP-014 — OpenAPI vlastní tvar**; contract test drží přesný path set.
- **PSP-015 — Evidence.** Testcontainers testy: od prázdného kurzoru, kurzor advance (druhý pull prázdný), stránkování s `hasMore`, update viditelný po kurzoru, ownership izolace, neznámý typ 400, determinismus; flaky ≠ zelený důkaz.

# 5. Ready condition

C41 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R6-01` `READY`**.
