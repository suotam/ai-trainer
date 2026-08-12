# AI Trainer – R2 Conflict & Rejection Contract (C12)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r2-conflict-rejection-contract.md`
**Vlastník:** Domain (sync-and-offline-model)
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C12 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sync-and-offline-model.md` (§34–§36, §53–§56), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/12-data/r2-idempotency-contract.md` (C11), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/11-security/r2-audit-event-contract.md` (C14), `docs/04-ux/screen-specifications.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-06, budoucí pull/merge kontrakt (R3+)
**Vlastněné pojmy nebo kontrakty:** R2 klasifikace konfliktu a odmítnutí, baseline resolution (explicitní uživatelské rozhodnutí), bezpečné conflict/rejection UI a pravidla `CRC-001` až `CRC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Domain (sync-and-offline-model).** R2-05 dává konfliktu a odmítnutí explicitní lokální stav (`CONFLICT`/`BLOCKED`, SPC-006), ale žádné řešení — položky zůstávají „zaseknuté". R2-06 potřebuje závazné pravidlo, **co s nimi smí uživatel udělat a co se nikdy nesmí stát automaticky**. Tímto kontraktem je C12. Doménový model konfliktů je široký (§34–§56); C12 jej zužuje na R2 P0 baseline.

C12 je **contract-only**: bez UI implementace, bez API DTO, bez merge algoritmů.

## 1.2 Které slices blokuje

- **Blocking pro `R2-06 – Conflict, Rejection and Session Revocation`** (spolu s C13).

---

# 2. Scope

## 2.1 Co C12 řeší

- **R2 klasifikaci** konfliktů a odmítnutí (§4),
- **baseline resolution** — povolená rozhodnutí a jejich sémantiku (§5),
- **bezpečné UI** stavů (§6),
- **audit resolution** (§7),
- invarianty `CRC-001…CRC-015` (§8), hranice (§9), testing/evidence (§10–§11), Ready (§12).

## 2.2 Co C12 výslovně neřeší

- **detekci konfliktu** — C10 §10 (`VERSION_CONFLICT` per-item; server ji vlastní),
- **pull synchronizaci a materializaci serverového stavu na klientu** — mimo R2 P0 (budoucí rozšíření C10); proto je `USE_SERVER` v R2 pouze „zahodit lokální neodeslanou změnu", ne „stáhnout a přepsat" (§5),
- **three-way merge, field-level merge, VersionVector** (`§32/§37/§38`) — R3+,
- **automatické merge policy** (`§56`) — R2 nemá auto-resolution; vše je explicitní uživatelské rozhodnutí,
- **delete/tombstone konflikty** (`§57/§58`) — delete je mimo R2-05/06 protokol (SPC-010),
- **revokaci session** — C13,
- **ChangeSet/AI konflikty** — R4+.

---

# 3. Source of truth and precedence

1. **Doménový model** — `sync-and-offline-model` §3.6 (konflikt je normální stav), §34 SyncConflict, §53 ConflictResolution, §55 Conflict UI, §48 (ochrana dokončeného výkonu).
2. **Sync protokol** — C10 (per-item `VERSION_CONFLICT`, `expectedServerVersion`, potvrzení po commitu).
3. **Lokální stavy** — C2 (`CONFLICT`/`BLOCKED` sync_state, outbox stavy).
4. **R2 pořadí** — `r2-vertical-slice-plan §9.6` (baseline, žádné collaborative merge).

C12 vlastní **R2 resolution baseline** a `CRC-*`.

---

# 4. R2 klasifikace

Z doménových typů (§35) používá R2 pouze:

| Stav | Zdroj (R2-05) | Význam |
|---|---|---|
| **Konflikt** (`VERSION_MISMATCH`) | per-item `VERSION_CONFLICT` | lokální změna vznikla nad zastaralou serverovou verzí; server vrátil aktuální `serverVersion` |
| **Odmítnutí** | per-item `VALIDATION_FAILED` / `PERMISSION_DENIED` | operace je pro server trvale nepřijatelná (nevalidní / cizí vlastnictví) |

- Závažnost R2 konfliktů je **USER_REVIEW** (§36) — žádná R2 entita nemá auto-resolution ani SAFETY klasifikaci (PainReport apod. nejsou v R2 entity scope).
- `DEPENDENCY_FAILED` **není** konflikt ani odmítnutí — je to přechodný stav (pending) a řeší jej další push (C10 §7).
- Ostatní typy §35 jsou forward-scoped mimo R2.

---

# 5. Baseline resolution

Z `ConflictResolution` typů (§53.2) povoluje R2 **právě dvě explicitní uživatelská rozhodnutí**; obě jsou lokální akce nad pending/conflict stavem — **žádné automatické řešení, žádné tiché zahození**:

## 5.1 `USE_LOCAL` — „ponechat moji verzi"

- Klient znovu odešle **plný aktuální lokální stav** entity (state-based, C10 §5.3) jako `UPDATE_ENTITY` s `expectedServerVersion` = **aktuální serverová verze vrácená v konfliktu**.
- Jde o **uživatelem potvrzený last-write-wins** (§33) — nikdy se neprovádí automaticky (`CRC-002`).
- Nová operace = nová outbox položka s **novým idempotency key** (nová lokální revize; IDC-001/002 — jiný payload nesmí recyklovat starý klíč).
- Pokud mezitím serverová verze znovu pokročila, výsledkem je nový `VERSION_CONFLICT` — rozhodnutí se opakuje (žádný retry loop; každé kolo je explicitní).

## 5.2 `CANCEL_LOCAL_CHANGE` — „zahodit odeslání"

- Uživatel se vzdává **odeslání** této změny: konfliktní/odmítnutá outbox položka se označí jako uzavřená a entita opustí `CONFLICT`/`BLOCKED` stav.
- **Lokální data se nemažou ani nemění** (`§3.4`, `LSM-006`, `SPC-011`) — dokončený výkon a historie zůstávají lokálně čitelné a použitelné (`§48`); entita se pouze přestane nabízet k push v této revizi. Nová lokální změna (nová revize) je opět synchronizovatelná.
- Bez pull synchronizace tímto lokální a serverový stav **zůstávají rozdílné** — to je přiznaný, viditelný důsledek (žádné předstírání „synced"): entita dostane stav `LOCAL_ONLY` (ne `SYNCED`).

## 5.3 Odmítnutí (`BLOCKED`)

- `PERMISSION_DENIED` a `VALIDATION_FAILED` nemají `USE_LOCAL` variantu (opakování stejné operace je deterministicky odmítnuto) — jediné rozhodnutí je `CANCEL_LOCAL_CHANGE` (§5.2), případně oprava dat novou lokální změnou (nová revize → nový pokus).

---

# 6. Bezpečné UI

Dle `§55` a screen-spec pravidel:

- Konflikt/odmítnutí je **viditelný stav** (seznam položek s lidským popisem entity — název workoutu, datum), ne technický JSON diff ani raw kód.
- Každá položka nabízí **explicitní akce** dle §5; žádná akce nemá destruktivní výchozí chování a `CANCEL_LOCAL_CHANGE` pravdivě popisuje důsledek („zůstane jen v tomto zařízení").
- Konfliktní stav **neblokuje R1 offline použití** entity (`R2P-004`, `§3.6`) — trénovat lze dál; blokovaný je jen přenos.
- Chybové stavy jsou typované a bezpečné (žádný interní detail, mobile-architecture §24).
- Počty v sync výsledku zůstávají poctivé (SPC-006): konflikt/odmítnutí není „synced".

---

# 7. Audit resolution

- Uživatelské rozhodnutí generuje audit záznam dle C14 tvaru: **`SyncConflictResolved`** (outcome SUCCESS, policy `USE_LOCAL`/`CANCEL_LOCAL_CHANGE`, target = `entityType:entityId`) — append-only rozšíření C14 §7 tímto kontraktem (`AEC-009` stabilní názvy).
- `USE_LOCAL` re-push se dále audituje standardně (applied/conflict dle C14 §7); serverová strana nový audit typ nepotřebuje.
- Bez citlivého payloadu (AEC-003/004).

---

# 8. Conflict/rejection invariants (`CRC`)

Nová řada. Doplňuje, neoslabuje `SPC-*`, `IDC-*`, `LSM-*`, `AEC-*`.

- **CRC-001 — Konflikt je normální stav.** Konflikt/odmítnutí má explicitní lokální stav a viditelnou reprezentaci; nikdy není prezentován jako úspěch ani skryt (`§3.6`, `SPC-006`).
- **CRC-002 — Žádné automatické řešení.** R2 nemá auto-resolution ani automatický LWW; každé řešení je explicitní uživatelské rozhodnutí (§5).
- **CRC-003 — Jen dvě rozhodnutí.** R2 baseline povoluje `USE_LOCAL` a `CANCEL_LOCAL_CHANGE`; ostatní typy §53.2 jsou forward-scoped a přidávají se kontraktem.
- **CRC-004 — USE_LOCAL je potvrzený přepis.** Re-push nese aktuální serverovou verzi z konfliktu jako `expectedServerVersion`; nový mezitímní posun verze vede na nový explicitní konflikt, ne na slepý přepis.
- **CRC-005 — Nový pokus = nový klíč.** Resolution re-push je nová logická operace s novým idempotency key (IDC-002); starý klíč se nerecykluje.
- **CRC-006 — Cancel nemaže data.** `CANCEL_LOCAL_CHANGE` ruší odeslání, nikdy lokální data; dokončený výkon a historie zůstávají nedotčené (`§3.4`, `§48`, `LSM-006`).
- **CRC-007 — Rozdíl je přiznaný.** Po `CANCEL_LOCAL_CHANGE` entita není `SYNCED`; rozdíl vůči serveru zůstává viditelný jako `LOCAL_ONLY`.
- **CRC-008 — Odmítnutí nemá USE_LOCAL.** `VALIDATION_FAILED`/`PERMISSION_DENIED` lze uzavřít jen cancelem nebo opravit novou lokální změnou; deterministicky odmítnutá operace se neopakuje beze změny.
- **CRC-009 — Konflikt neblokuje offline použití.** Entita v konfliktu zůstává lokálně plně použitelná (R1 tok, `R2P-004`); blokovaný je jen přenos.
- **CRC-010 — Aktivní session se nepřepisuje.** Žádná resolution nesmí přepsat ani ukončit aktivní lokální WorkoutSession (`R2P-008`, `§40`).
- **CRC-011 — UI bez technických diffů.** Konflikt se prezentuje lidským popisem entity a explicitními akcemi (`§55`); žádné raw JSON/kódy.
- **CRC-012 — Resolution se audituje.** Každé rozhodnutí generuje `SyncConflictResolved` audit dle C14 tvaru, bez citlivého payloadu.
- **CRC-013 — Restart-safe.** Konfliktní/odmítnuté stavy i neuzavřená rozhodnutí přežívají restart (C2 restart-safe); rozhodnutí se aplikuje idempotentně.
- **CRC-014 — Detekci vlastní server.** Klient konflikt nikdy „neuhodne" lokálně — vzniká výhradně z per-item výsledku serveru (C10 §7/§10).
- **CRC-015 — Žádné merge do zásoby.** Field-level merge, three-way merge a auto-policies se nezavádějí; vzniknou nejdřív s pull/merge kontraktem (R3+).

---

# 9. Interaction with other contracts

- **C10:** vlastní detekci (`VERSION_CONFLICT`) a transport re-push; C12 vlastní rozhodovací sémantiku nad ní.
- **C11:** nový pokus = nová operace s novým klíčem (CRC-005); replay uzavřených rozhodnutí bez efektů.
- **C2:** lokální stavy `CONFLICT`/`BLOCKED`/`LOCAL_ONLY` a outbox lifecycle; C12 definuje povolené přechody.
- **C14:** tvar audit záznamu; C12 doplňuje událost `SyncConflictResolved` (append-only, §7).
- **C13:** nezávislé — revokace není konflikt; klientská reakce na revokaci vlastní C13/C7.
- **C15 (forward):** attach konflikty (duplicitní data při připojení účtu) vlastní C15, ne C12.

---

# 10. Testing requirements (kontraktně)

Implementace R2-06 musí ověřit (`test-strategy §7/§8`):

1. **Explicitní stav** — konfliktní/odmítnutá položka je viditelná v UI a není počítána jako synced.
2. **USE_LOCAL** — re-push s verzí z konfliktu projde (server přijme, nová verze), lokální stav → `SYNCED`; při mezitímním posunu verze vznikne nový konflikt.
3. **CANCEL_LOCAL_CHANGE** — položka uzavřena, entita `LOCAL_ONLY`, lokální data byte-po-bytu nedotčená; nová lokální změna je znovu synchronizovatelná.
4. **Rejection** — `BLOCKED` položka nemá USE_LOCAL akci; cancel funguje shodně.
5. **Restart** — neuzavřený konflikt přežije restart se stejným stavem.
6. **Audit** — `SyncConflictResolved` s policy rozhodnutím, bez citlivého payloadu.
7. **Aktivní session** — resolution nikdy nepřepíše aktivní lokální WorkoutSession.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 11. Evidence gates

Implementace R2-06 musí doložit: conflict/rejection UI testy, USE_LOCAL/CANCEL testy nad skutečnou SQLite + Testcontainers re-push, restart test, audit důkaz, traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 12. Ready condition

C12 je Done, právě když definuje: R2 klasifikaci (§4), baseline resolution (§5), bezpečné UI (§6), audit (§7), invarianty `CRC-001…CRC-015` (§8), hranice (§9), testing/evidence (§10–§11); je zapsán v doc mapě a status auditu; a neobsahuje UI/merge implementaci. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C12 je **Done**.

**Dopad na R2-06:** `R2-06` vyžaduje R2-05 Done (splněno) + C12 + C13. Spolu s C13 je `R2-06` `READY`.

---

# 13. References

- `docs/06-domain/sync-and-offline-model.md` — §3.4/§3.6, §33 LWW, §34–§36 SyncConflict, §48 ochrana výkonu, §53 ConflictResolution, §55 Conflict UI, §56 auto-konflikty (mimo R2).
- `docs/07-backend/r2-sync-protocol-contract.md` — C10; §7 per-item výsledky, §10 verzování, `SPC-006/010/011`.
- `docs/12-data/r2-idempotency-contract.md` — C11; `IDC-001/002`.
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; sync stavy, outbox.
- `docs/11-security/r2-audit-event-contract.md` — C14; tvar záznamu, `AEC-009`.
- `docs/13-delivery/r2-vertical-slice-plan.md` — §9.6 R2-06, `R2P-007/008`.
- `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`.
