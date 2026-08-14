# AI Trainer – R6 Beta Readiness Vertical Slice Plan (Pull Sync, Restore & Debt Settlement)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r6-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Navazuje na:** `docs/02-product/release-scope.md` (§10 beta baseline, krok 10), R5 Exit Review (`DOCUMENTATION_STATUS.md` §3 — otevřené dluhy), `docs/06-domain/sync-and-offline-model.md`, `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/06-domain/r3-sync-extension-contract.md` (C24 — SXC-010/011), `docs/12-data/r2-server-data-model.md` (C6), `docs/13-delivery/r5-vertical-slice-plan.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R6 detailní kontrakty (viz §7.1), implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R6, slice boundaries R6, R6 blocking contract map, evidence gates R6, R6 Exit Review a pravidla `R6P-001` až `R6P-015`

---

# 1. Účel

Kanonický implementační plán pro **R6 – Beta Readiness**: dokončit beta baseline (release scope §10) tam, kde R5 Exit Review přiznal dluhy. Jádro je **krok 10 — bezpečná obnova**: data musí téct i směrem dolů (pull sync), obnova na novém zařízení musí být úplná (včetně struktury workoutů) a smazání se musí propagovat. R6 nepřidává nové produktové funkce — **splácí strukturální dluhy, bez kterých beta není poctivá**.

Scope R6 není v release-scope.md předdefinován (ten končí R5); tento plán ho odvozuje **výhradně z beta baseline mezer a evidovaných dluhů** (R6P-015 traceability). Dokument nedefinuje endpointy, merge algoritmy ani schémata — ty vlastní navazující kontrakty (§7.1).

---

# 2. Delivery princip

- R6 se implementuje po slicech; kontrakt předchází implementaci; slice bez blokujících kontraktů je `NOT_READY`.
- **Lokální data jsou pravda zařízení; server je doručovatel** — pull nikdy tiše nepřepisuje lokální nepushnuté změny (LOCAL_ONLY/DIRTY); konflikt je typovaný stav dle C12 vzoru.
- **Idempotence oběma směry** — opakovaný pull je no-op; restore lze bezpečně přerušit a opakovat.
- **Žádná serverová reinterpretace payloadů** (C6 §8.4 trvá) — server vydává, co přijal; význam vlastní klient.
- **R1–R5 toky beze změny**; push sémantika (C10/C11) se nemění, jen rozšiřuje.

---

# 3. Celkové pořadí

```text
R6-01  Pull Sync Protocol and Server Endpoint (cursor, batch, ownership)        (backend)
R6-02  Mobile Pull Engine and Merge Semantics (aplikace, konflikty, idempotence)(mobile)
R6-03  Workout Structure Sync (sekce/kroky/sety — splacení SXC-010)             (mobile + backend)
R6-04  Delete Tombstones (propagace smazání — splacení SXC-011)                 (mobile + backend)
R6-05  New Device Restore Flow (fresh install → úplná obnova, poctivé stavy)    (mobile)
R6-06  R6 Critical End-to-End Evidence and Exit Review                          (mobile + backend)
```

Princip řazení: **protokol → aplikace → úplnost dat (struktura) → korektnost (delete) → orchestrace obnovy → důkaz celku.** Restore (R6-05) je poctivý až po R6-03/04 — obnova bez struktury workoutů nebo s „oživlými" smazanými záznamy by byla tichá lež.

---

# 4. R6 value statement

**Hlavní hodnota R6:** Uživatel může ztratit či vyměnit zařízení a **bezpečně obnovit svá data na novém** (beta baseline krok 10): po přihlášení se stáhne vše, co účet vlastní — profil, plány **včetně struktury workoutů**, historie, check-iny — smazané věci zůstanou smazané, lokální nepushnuté změny se nikdy tiše neztratí a celý proces je idempotentní a přerušitelný.

Hodnota je dosažena, až když: (a) pull protokol je kontraktní a vlastněný (cursor, batch, ownership), (b) merge nikdy tiše nepřepíše lokální pravdu, (c) struktura ručních workoutů synchronizuje oběma směry (SXC-010 splacen), (d) DELETE se propaguje tombstony (SXC-011 splacen) a (e) restore E2E deterministicky prochází.

---

# 5. Scope a non-goals

## 5.1 R6 P0 scope

Pull sync protokol + serverový endpoint; mobilní pull engine s merge pravidly; sync struktury workoutů (sekce/kroky/set plány); delete tombstones pro entity s lokálním zpětvzetím; restore flow nového zařízení; R6 E2E.

## 5.2 Non-goals R6

- real-time/průběžná synchronizace, websockety, server push,
- serverové automatické merge (konflikt zůstává explicitní uživatelské rozhodnutí, C12),
- souběžná multi-device editace nad rámec stávající optimistic concurrency,
- sdílení dat mezi účty, trenérské role, export/import,
- sync AI návrhů (APL-011 trvá — device-local rozhodovací artefakt),
- nové produktové funkce (R6 je readiness release).

## 5.3 Beta gate podmínky mimo slices (§12)

Živý provider smoke, platformní doručení notifikací a emulátorová runtime evidence **vyžadují externí zdroje** (API klíč, Android SDK/zařízení) — nejsou slices, ale podmínkami zveřejnění bety; R6 Exit Review je znovu eviduje.

---

# 6. Architektonické principy R6

- **Cursor = `server_version`** (C10 §10 monotónnost) — pull vydává změny od posledního známého kurzoru per typ; klient si kurzory drží lokálně.
- **Merge deterministicky:** server řádek s vyšší verzí aplikuj, lokální LOCAL_ONLY/DIRTY nikdy tiše nepřepiš (konflikt = C12 typovaný stav); opakovaná aplikace téhož = no-op.
- **Struktura v payloadu instance** (kandidátní rozhodnutí C43): sekce/kroky/sety cestují jako součást workout instance payloadu — žádné nové serverové parent tabulky (C6 §8.4 kostra trvá).
- **Tombstone je fakt, ne mazání historie**: DELETE se eviduje, propaguje a aplikuje idempotentně; lokální data uživatele se nikdy nemažou bez jeho akce.
- **Restore je orchestrace existujících mechanismů**: přihlášení (R2) → pull vše (R6-01/02) → běžné read modely; žádný zvláštní „import" kanál.

---

# 7. Prerequisites

1. R0–R5 uzavřené a mergnuté (splněno; Exit Reviews provedeny).
2. Existuje tento plán.
3. Pro každý slice existují blokující kontrakty (§7.1); do té doby `NOT_READY`.

## 7.1 R6 blocking contract map

Číslování navazuje na R5 (C33–C40):

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Minimum |
|---|---|---|---|---|---|
| C41 | Pull sync protocol | Domain (sync-and-offline-model) + Backend | `docs/07-backend/r6-pull-sync-contract.md` | R6-01 | pull endpoint, cursor per typ (`server_version`), batch/stránkování, ownership, žádná reinterpretace payloadů, idempotence |
| C42 | Pull merge semantics | Domain (sync-and-offline-model) + Mobile | `docs/06-domain/r6-pull-merge-contract.md` | R6-02 | aplikační pravidla per sync stav (SYNCED/DIRTY/LOCAL_ONLY), konflikt jako C12 typovaný stav, kurzor persistence, no-op idempotence |
| C43 | Workout structure sync | Data Architecture + Backend + Mobile | `docs/12-data/r6-structure-sync-contract.md` | R6-03 | struktura (sekce/kroky/sety) v instance payloadu oběma směry, verze, rekonstrukce při pull, SXC-010 splacení |
| C44 | Delete tombstones | Domain (sync-and-offline-model) + Backend | `docs/06-domain/r6-delete-sync-contract.md` | R6-04 | tombstone model a scope entit (min. availability zpětvzetí), DELETE push operace, pull propagace a idempotentní aplikace, SXC-011 splacení |
| C45 | Device restore | Domain (sync-and-offline-model) + Mobile | `docs/06-domain/r6-restore-contract.md` | R6-05 | fresh-install restore flow (pořadí typů, přerušitelnost, poctivé progress/empty stavy), interakce s attach a lokálními anonymními daty |

`R6-06` nový kontrakt nevyžaduje (E2E + Exit Review nad C41–C45).

---

# 8. Terminologická hranice

- **Pull** = doručení server stavu klientovi; **restore** = orchestrovaný první pull na čistém zařízení. Restore není import ani migrace.
- **Tombstone** = evidovaný fakt smazání; není to fyzické smazání historie na serveru.
- **Konflikt** zůstává C12 pojem (explicitní uživatelské rozhodnutí) — pull konflikty se do něj mapují, nevzniká nový mechanismus.

---

# 9. Slice detail

## 9.1 R6-01 – Pull Sync Protocol and Server Endpoint
**Výsledek:** Kontraktní pull endpoint: autentizovaný klient dostane změny svých entit od kurzoru per typ, deterministicky řazené a stránkované; server payloady nevykládá.
**Blocking:** C41. **Evidence:** Testcontainers testy (cursor, batch, ownership/anti-IDOR, idempotentní opakování, prázdný stav), OpenAPI rozšíření + contract testy.

## 9.2 R6-02 – Mobile Pull Engine and Merge Semantics
**Výsledek:** Mobilní pull engine aplikuje server řádky dle C42: SYNCED přepis vyšší verzí, LOCAL_ONLY/DIRTY nikdy tiše (konflikt = C12 stav), kurzory persistované, opakovaný pull no-op; existující typy (R1–R5 registr).
**Blocking:** C42. **Evidence:** merge matice testy, idempotence, konfliktní větve, kurzor persistence.

## 9.3 R6-03 – Workout Structure Sync
**Výsledek:** Ruční/AI workouty cestují se strukturou (sekce/kroky/set plány) v instance payloadu; pull strukturu rekonstruuje; SXC-010 splacen a odstraněn z dluhů.
**Blocking:** C43. **Evidence:** push payload se strukturou, pull rekonstrukce byte-ekvivalentního snapshotu, R1 flow na obnoveném workoutu.

## 9.4 R6-04 – Delete Tombstones
**Výsledek:** Lokální zpětvzetí (min. availability pravidla — SXC-011 scope) generuje DELETE operaci; server eviduje tombstone; pull smazání propaguje idempotentně; nic se „neoživuje".
**Blocking:** C44. **Evidence:** push DELETE + replay, pull aplikace tombstonu, restore bez oživlých záznamů.

## 9.5 R6-05 – New Device Restore Flow
**Výsledek:** Čistá instalace + přihlášení → orchestrovaná úplná obnova (pořadí typů, přerušitelnost/opakovatelnost, poctivý progress a výsledek); interakce s attach definovaná (lokální anonymní data nového zařízení se neztrácejí).
**Blocking:** C45. **Evidence:** restore scénář na prázdné DB (vše obnoveno vč. struktury, bez tombstonovaných), přerušení + opakování, attach interakce.

## 9.6 R6-06 – R6 Critical End-to-End Evidence and Exit Review
**Výsledek:** Automatizovaný důkaz hlavní hodnoty R6 + R6 Exit Review.
**Blocking:** žádné nové. **Ready:** R6-01…05 Done.
**Evidence:** deterministický E2E „zařízení A → push (vč. struktury a delete) → zařízení B → restore → identická doménová pravda → R1 flow na obnoveném workoutu → oboustranná idempotence"; beta baseline krok 10 doložen; Exit Review dle §13.

---

# 10. Cross-slice invariants

1. **Lokální nepushnutá pravda se nikdy tiše neztrácí** — pull/restore ji nepřepisuje; konflikt je C12 explicitní rozhodnutí.
2. **Idempotence oběma směry** — opakovaný push i pull je no-op; restore přerušitelný a opakovatelný.
3. **Push sémantika C10/C11 beze změny**; pull je aditivní.
4. **Žádná serverová reinterpretace payloadů** (C6 §8.4).
5. **Tombstone nikdy nemaže cizí ani lokální neodeslaná data**; aplikace idempotentní.
6. **Struktura workoutů je součást pravdy** — obnovený workout je plnohodnotná R1 struktura.
7. **AI návrhy zůstávají device-local** (APL-011).
8. **R1–R5 kritické E2E zůstávají zelené.**
9. **Kurzory jsou lokální fakt klienta**; ztráta kurzoru smí vést jen k nadbytečnému (idempotentnímu) pullu, nikdy ke ztrátě dat.
10. **Poctivé stavy restore** — progress, částečný výsledek i selhání jsou typované a viditelné; žádné tiché „hotovo".
11. **Bez nových auth/ownership mechanismů** — C8 platí na pull stejně jako na push.
12. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

- **Unit**: merge matice (C42), tombstone aplikace, restore orchestrace stavy.
- **Backend Testcontainers**: pull endpoint (cursor/batch/ownership/idempotence), DELETE operace, struktura v payloadu.
- **Mobile**: pull engine nad reálnou SQLite, struktura rekonstrukce, restore na prázdné DB, konfliktní větve.
- **Kritická E2E (R6-06)**: dvě „zařízení" (dvě DB) proti témuž fake serveru se sdíleným stavem — plný cyklus push→restore→verifikace.
- **Beta gate podmínky (§5.3)**: mimo CI; řízená manuální evidence, znovu evidováno v Exit Review.

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Živý provider smoke** (R4 dluh) — podmínka zveřejnění bety; vyžaduje API klíč; beta zůstává interní, dokud neproběhne.
- **Platformní doručení notifikací** (C40 NTF-007) a **emulátorová runtime evidence** — vyžadují Android SDK/zařízení; podmínky zveřejnění bety, ne slices; postup: instalace SDK → on-device průchod R1–R6 flow + notifikační adapter s permission flow.
- **Scope tombstonů** — P0 minimum je SXC-011 (availability zpětvzetí); rozšíření na další entity rozhodne C44 explicitně.
- **Distribuovaný rate limiter, JSONB promoce, aktivní čas, feeling kanonizace** — trvají mimo R6 scope.

---

# 13. R6 Exit Review

R6 je dokončeno pouze pokud (doloženo testy, CI runy a evidencí):

- pull protokol kontraktní: cursor/batch/ownership/idempotence testovány proti reálnému PostgreSQL,
- merge nikdy tiše nepřepsal lokální LOCAL_ONLY/DIRTY (konfliktní větve testovány),
- struktura workoutů synchronizuje oběma směry; obnovený workout drží R1 flow (SXC-010 splacen),
- DELETE se propaguje tombstony a nic se neoživuje (SXC-011 splacen),
- restore na čistém zařízení obnoví úplnou doménovou pravdu, je přerušitelný a idempotentní,
- beta baseline krok 10 („bezpečná obnova") doložen E2E,
- R1–R5 kritické E2E zůstávají zelené; R6 E2E deterministicky prochází; CI zelené,
- beta gate podmínky (§5.3) splněny, nebo znovu poctivě evidovány (beta zůstává interní),
- žádný známý blocker ani critical defect.

---

# 14. Závazná pravidla R6

- **R6P-001 – Local truth first.** Pull/restore nikdy tiše nepřepisuje nepushnutá lokální data.
- **R6P-002 – Contract precedes implementation.**
- **R6P-003 – Idempotence oběma směry.** Opakování je vždy bezpečné.
- **R6P-004 – Push sémantika beze změny.** C10/C11/C12 platí; pull je aditivní.
- **R6P-005 – Server nevykládá payloady** (C6 §8.4).
- **R6P-006 – Tombstone ≠ mazání historie**; aplikace idempotentní a scoped.
- **R6P-007 – Restore = orchestrace, ne import.** Žádný paralelní datový kanál.
- **R6P-008 – Úplnost obnovy poctivě.** Co se neobnovuje (AI návrhy, device nastavení), je explicitně přiznáno v UI/Exit Review.
- **R6P-009 – Ownership na pull** stejně přísně jako na push (C8, anti-IDOR).
- **R6P-010 – Typované stavy restore**; žádný infinite retry.
- **R6P-011 – R1–R5 stay green.**
- **R6P-012 – Bez nových produktových funkcí** — readiness release.
- **R6P-013 – Deterministické testy bez sítě**; fake server se sdíleným stavem pro multi-device scénáře.
- **R6P-014 – Honest evidence** vč. beta gate podmínek (§5.3/§12).
- **R6P-015 – Scope changes traceable** — scope odvozen výhradně z beta mezer a evidovaných dluhů.

---

# 15. Stav backlogu

R6 backlog (`R6-01` až `R6-06`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na blokující kontrakty (§7.1: C41–C45). Implementace R6 nezačala.

První kanonický krok: vytvořit **C41 – Pull sync protocol** → tím se `R6-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices, ne všechny najednou.
