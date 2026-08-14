# AI Trainer – R6 Pull Merge Semantics Contract (C42)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r6-pull-merge-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Mobile
**Kontraktní ID:** C42 (dle `docs/13-delivery/r6-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r6-pull-sync-contract.md` (C41), `docs/06-domain/r2-local-sync-metadata-contract.md` (C2), `docs/06-domain/r2-conflict-rejection-contract.md` (C12), `docs/12-data/r3-mobile-schema-migration.md` (C16 vzor), `docs/13-delivery/r6-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R6-02, C43 (rozšíření o workout hierarchii), C44 (tombstony), C45 (restore orchestrace)
**Vlastněné pojmy nebo kontrakty:** merge matice, pull engine chování, kurzor persistence a pravidla `PMS-001` až `PMS-015`

---

# 1. Purpose

Merge je **jediné místo, kde server stav vstupuje do lokální DB**. Zákon je R6P-001: **lokální nepushnutá pravda se nikdy tiše neztrácí** — server řádek smí přepsat jen čistý (SYNCED) lokální stav; vše ostatní je typovaný konflikt řešený existující C12 cestou. Aplikace je idempotentní (overlap z C41 je bezpečný).

**Blocking pro `R6-02`.**

# 2. P0 scope typů

Pull engine v P0 požaduje a aplikuje **ploché root typy bez FK závislosti na workout hierarchii**: `USER_SPORT`, `GOAL`, `AVAILABILITY_RULE`, `EQUIPMENT_ITEM`, `CONSTRAINT_ITEM`, `TRAINING_PLAN`, `DAILY_CHECK_IN` (7 typů). `MANUAL_ACTIVITY`, `CALENDAR_CHANGE` a R1 workout hierarchie se aplikují až s **C43/C45** (referencují workout instance; struktura je podmínka poctivé obnovy — SXC-010). Engine nepodporované typy **nepožaduje** — žádné tiché zahazování.

Pořadí aplikace = pořadí registru (závislosti v rámci scope: sporty před cíli).

# 3. Merge matice (per řádek)

| Lokální stav | Pravidlo |
|---|---|
| řádek neexistuje | INSERT ze server payloadu: hodnoty payloadu (jsou to přesné sloupcové hodnoty z push strany), `owner_id` = aktuální účet, `sync_state = SYNCED`, lokální časy = čas aplikace, `row_version` z payloadu; evidence server verze (`local_synced_versions`) |
| existuje, `SYNCED`, server verze > známá | UPDATE hodnotami payloadu + evidence nové verze; `sync_state` zůstává `SYNCED` |
| existuje, `SYNCED`, server verze ≤ známá | **no-op** (idempotence; overlap z C41) |
| existuje, `LOCAL_ONLY`/`DIRTY` | **nikdy tiše** — přeskočit beze změny lokálních dat, typovaný `conflictSkipped`; řešení = existující C12 flow (push ohlásí `VERSION_CONFLICT`, uživatel rozhodne) |

Selhání aplikace jednotlivého řádku (např. chybějící FK prerekvizita) = typovaný `skippedDependency` — nikdy pád celého běhu, nikdy částečně zapsaný řádek.

# 4. Engine chování

- **Explicitní běh, jen přihlášený** (SPC-001 vzor): anonymní = typovaný skip; selhání sítě = typovaná nedostupnost, žádný auto-retry.
- **Kurzory per typ** (neprůhledné C41 tokeny) persistované v lokálním app state; **kurzor typu se posune až po úspěšné aplikaci batch** (transakce) — přerušení znamená nanejvýš opakovanou (idempotentní) aplikaci.
- Smyčka `hasMore` s bezpečnostním stropem iterací; výsledek typovaný s počty (`applied`, `conflictSkipped`, `skippedDependency`).
- Pull engine nezapisuje outbox ani nemění push chování (PSP-001).

# 5. Invarianty (`PMS`)

- **PMS-001 — Lokální nepushnutá pravda nikdy tiše** (§3 řádek 4); konflikt vždy typovaný a viditelný v počtech.
- **PMS-002 — Idempotence.** Opakovaná aplikace téhož řádku/batch = no-op; overlap bezpečný (C41 PSP-005 protějšek).
- **PMS-003 — Payload = sloupcové hodnoty.** Aplikace je inverz push serializace; žádná interpretace ani dopočty (symetrie s C6 §8.4).
- **PMS-004 — Owner = aktuální účet** (C8/C2): pull aplikuje výhradně do vlastnictví přihlášeného účtu.
- **PMS-005 — SYNCED po aplikaci.** Server řádek je z definice synchronizovaný; nikdy nevzniká falešné DIRTY.
- **PMS-006 — Evidence verzí** v `local_synced_versions` — jediný zdroj `expectedServerVersion` pro push (C10 §10) i no-op rozhodnutí pullu.
- **PMS-007 — Scope §2 přesně**; rozšíření typů = revize kontraktu (C43/C45).
- **PMS-008 — Deterministické pořadí** aplikace (registr); závislé typy po prerekvizitách.
- **PMS-009 — Per-item izolace selhání** (§3) — typované počty, žádný pád běhu.
- **PMS-010 — Kurzor až po aplikaci** (§4); ztráta kurzoru = nanejvýš nadbytečný idempotentní pull (R6P cross-slice 9).
- **PMS-011 — Žádné mazání.** Pull v P0 nikdy nemaže lokální řádky (tombstony vlastní C44).
- **PMS-012 — Bez auto-retry a background běhů**; spouštění explicitní (restore/UI).
- **PMS-013 — Bez PII navíc**: engine neloguje payloady.
- **PMS-014 — Push beze změny** (PSP-001): žádná změna outbox/idempotency sémantiky.
- **PMS-015 — Evidence.** Testy: merge matice všech 4 řádků, idempotence opakovaného běhu, konflikt DIRTY beze změny dat, dependency skip, kurzor persistence a posun až po aplikaci, anonymní/nedostupnost typované; flaky ≠ zelený důkaz.

# 6. Ready condition

C42 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R6-02` `READY`**.
