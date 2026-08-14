# AI Trainer – R6 Delete Tombstones Contract (C44)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r6-delete-sync-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Backend
**Kontraktní ID:** C44 (dle `docs/13-delivery/r6-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/r3-sync-extension-contract.md` (C24 — SXC-011 dluh), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/07-backend/r6-pull-sync-contract.md` (C41 PSP-010), `docs/06-domain/r6-pull-merge-contract.md` (C42), `docs/06-domain/r2-local-sync-metadata-contract.md` (C2 §6.2 — DELETE záměr)
**Navazující dokumenty:** implementace R6-04, C45 (restore bez oživování)
**Vlastněné pojmy nebo kontrakty:** tombstone model, DELETE operace, pull propagace smazání a pravidla `DTS-001` až `DTS-015`

---

# 1. Purpose

Splacení **SXC-011**: lokální zpětvzetí se musí propagovat — jinak server a ostatní zařízení lžou. **Tombstone je evidovaný fakt smazání, ne mazání historie**: serverový řádek zůstává (payload vč.), jen nese příznak `deleted` s navýšenou verzí; pull ho doručí a klient aplikuje idempotentně. Nic se nikdy „neoživuje".

**Blocking pro `R6-04`.**

# 2. Scope a operace

- **P0 scope entit = `AVAILABILITY_RULE`** (SXC-011 — jediné lokální tvrdé zpětvzetí; equipment/constraints/goals používají stavovou archivaci, ne mazání). Rozšíření scope = revize kontraktu.
- **Push**: nový `operationType = DELETE_ENTITY` (rozšíření C10 §5.1 podmnožiny): bez payloadu (prázdný objekt), s `expectedServerVersion` (optimistic concurrency jako UPDATE — mismatch = `VERSION_CONFLICT`); cíl neexistuje = `VALIDATION_FAILED`; cizí = `PERMISSION_DENIED`; replay přes idempotency key = `ALREADY_APPLIED`. `DELETE_ENTITY` mimo P0 scope entit = `VALIDATION_FAILED`.
- **Server**: tombstone = `deleted = true` + `server_version + 1` + `updated_at` (Flyway aditivní sloupec na scoped tabulce); řádek se nikdy fyzicky nemaže (žádná ztráta auditní stopy).
- **Pull**: item nese `deleted: true` (naplnění PSP-010); doručuje se jako běžná změna od kurzoru.

# 3. Lokální chování

- **Vznik záměru**: lokální zpětvzetí řádku, který **server zná** (existuje evidovaná server verze) → v téže transakci se zapíše outbox `DELETE` záměr (C2 §6.2, stabilní idempotency key `DELETE:<typ>:<id>:v<verze>`) a lokální řádek se smaže. Řádek, který server nezná (`LOCAL_ONLY` bez verze), se maže jen lokálně — server se nikdy nedozví o něčem, co neexistovalo.
- **Push engine**: PENDING `DELETE` záměry se odesílají v batchi spolu s ostatními operacemi (pořadí sequence); `SUCCESS/ALREADY_APPLIED` → záměr `SYNCED`; `VERSION_CONFLICT` → `CONFLICT` (C12 flow); odmítnutí → `BLOCKED`. Žádný root sync_state se nemarkuje (řádek už lokálně není).
- **Pull aplikace tombstonu (C42 matice rozšíření)**: lokální řádek `SYNCED` → smazat + evidovat verzi; **`LOCAL_ONLY`/`DIRTY` → nikdy tiše** (typovaný konflikt — lokální pravda má přednost, PMS-001); řádek neexistuje → jen evidovat verzi (**žádné oživení**, restore tombstonovaný řádek nikdy nevytvoří).

# 4. Invarianty (`DTS`)

- **DTS-001 — Tombstone ≠ mazání historie.** Server řádek zůstává s `deleted=true`; audit stopa nedotčena.
- **DTS-002 — Scope P0 přesně** (§2); DELETE mimo scope typovaně odmítnut.
- **DTS-003 — Optimistic concurrency i pro DELETE** (`expectedServerVersion`); konflikt explicitní (C12).
- **DTS-004 — Idempotence všude**: replay push `ALREADY_APPLIED`; opakovaná pull aplikace tombstonu no-op.
- **DTS-005 — Nikdy tiché smazání lokální pravdy**: tombstone nesmaže LOCAL_ONLY/DIRTY řádek (typovaný konflikt).
- **DTS-006 — Žádné oživování**: po aplikaci tombstonu se řádek nevrací (pull/restore ho nevytvoří; evidovaná verze to jistí).
- **DTS-007 — Lokální záměr atomicky se smazáním** (§3, jedna transakce) — žádné okno „smazáno bez záměru".
- **DTS-008 — LOCAL_ONLY mazání bez serveru** (§3) — o neexistujícím se server nedozví.
- **DTS-009 — DELETE bez payloadu**; server z něj nic nečte (C6 §8.4 duch).
- **DTS-010 — Pull tvar dle C41 PSP-010** (`deleted` příznak); řazení/kurzory beze změny.
- **DTS-011 — Push/pull sémantika ostatních operací beze změny.**
- **DTS-012 — Ownership přísně** (C8) i pro DELETE.
- **DTS-013 — Audit bez payloadu** (C14): smazání auditováno typem+ID+rozhodnutím.
- **DTS-014 — Rozšíření scope jen kontraktem.**
- **DTS-015 — Evidence.** Testy: lokální záměr + atomicita, push DELETE (úspěch/replay/konflikt/cizí/neexistující/mimo scope), pull tombstone matice (SYNCED smazán, DIRTY konflikt, absent bez oživení), restore bez oživlých řádků; flaky ≠ zelený důkaz.

# 5. Ready condition

C44 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R6-04` `READY`**.
