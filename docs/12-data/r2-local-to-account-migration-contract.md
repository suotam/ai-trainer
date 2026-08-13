# AI Trainer – R2 Local-to-Account Migration Contract (C15)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r2-local-to-account-migration-contract.md`
**Vlastník:** Data Architecture + Domain (identity-and-profile-model / sync-and-offline-model)
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C15 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r2-identity-session-contract.md` (C3 §6.1), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-mobile-schema-migration.md` (C1), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/12-data/r2-idempotency-contract.md` (C11), `docs/07-backend/r2-conflict-rejection-contract.md` (C12), `docs/11-security/r2-token-session-storage-contract.md` (C7), `docs/12-data/r2-server-data-model.md` (C6), `docs/06-domain/domain-invariants.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-07, R2-08 (E2E evidence)
**Vlastněné pojmy nebo kontrakty:** připojení předpřihlašovacích (anonymních) lokálních dat k účtu — attach algoritmus, klasifikace seed vs. uživatelská data, duplicitní ochrana, stabilita ID, chování při odhlášení a druhém účtu — a pravidla `LAM-001` až `LAM-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Data Architecture + Domain.** Uživatel může trénovat anonymně (R1, ISC-002) a teprve poté si vytvořit účet. C3 §6.1 garantuje, že přechod anonymous → account **zachová data a nevytvoří duplicity** (`INV-013`, `ISC-005`) — ale datové provedení výslovně odkládá na C15. Od R2-05 navíc platí, že sync push posílá výhradně data vlastněná účtem — anonymní data by bez attach zůstala trvale nesynchronizovatelná. Tímto kontraktem je C15, poslední položka R2 contract mapy.

C15 je **contract-only**: bez kódu, migrací a UI.

## 1.2 Které slices blokuje

- **Blocking pro `R2-07 – Local-to-Account Data Migration`** (Ready = R2-05 Done ✓ + C15).

---

# 2. Scope

## 2.1 Co C15 řeší

- **klasifikaci lokálních dat** — seed/demo vs. uživatelská (§4),
- **attach algoritmus** — lokální přepis vlastníka (§5),
- **spouštění a idempotenci** attach (§6),
- **duplicitní ochranu** při následném syncu (§7),
- **odhlášení a druhý účet na zařízení** (§8),
- invarianty `LAM-001…LAM-015` (§9), hranice (§10), testing/evidence (§11–§12), Ready (§13).

## 2.2 Co C15 výslovně neřeší

- **identity transition sémantiku** — C3 §6.1 (C15 je datové provedení),
- **serverovou registraci účtu** — C4/R2-02,
- **sync transport a idempotency replay** — C10/C11 (attach z nich jen těží),
- **konflikt resolution** — C12,
- **merge dvou účtů, ProfileMergeRequest, cross-account transfer** — R3+ non-goal (plán §9.7),
- **smazání lokálních dat při odhlášení** — nikdy (C7 §7, `LSM-006`); C15 jen potvrzuje,
- **AthleteProfile** — vzniká na serveru přes R2-04 API, není předpřihlašovací lokální entita.

---

# 3. Source of truth and precedence

1. **Doménové invarianty** — `INV-013` (anonymní upgrade bez duplicit), `INV-021` (ID se nerecyklují).
2. **Identity transition** — C3 §6.1 (`ISC-005` idempotentní, `ISC-012` bez ztráty při odhlášení).
3. **Lokální ownership** — C2 (`LSM-001` owner reference, `LSM-006` logout neztrácí data, `LSM-013` stabilní ID).
4. **Sync/idempotence** — C10 (`SPC-001` push jen account-owned, `SPC-008` client ID se zachovává), C11, C6 §5 (`SDM-005/006`).
5. **R2 pořadí** — `r2-vertical-slice-plan §9.7`.

C15 vlastní **attach datový algoritmus** a `LAM-*`.

---

# 4. Klasifikace lokálních dat

Rozhodnutí, **co se připojuje**, vychází z existující R2-01/R2-05 sémantiky vlastnictví:

| Data | Klasifikace | Attach? |
|---|---|---|
| WorkoutSession, Step/SetPerformance, WorkoutFeedback, ActivitySummary vlastněné `local-anonymous` | **uživatelská** — vznikají výhradně uživatelskou akcí | **ano** |
| WorkoutInstance vlastněná `local-anonymous`, na které existuje session (nebo je `startedSessionId`/status mimo `PLANNED`) | **uživatelsky dotčená** — uživatel na ní trénoval | **ano** |
| WorkoutInstance vlastněná `local-anonymous` se `sourceType = SEED`, bez session a ve stavu `PLANNED` | **čistý seed/demo** | **ne** (plán §12 — seed se nesynchronizuje jako uživatelská data) |
| Data už vlastněná jiným účtem (`owner_id` = jiný account) | cizí účet na témže zařízení (`sync-model §76`) | **nikdy** (LAM-007) |
| Outbox položky, sync verze, resolutions | technická metadata | řídí se vlastníkem entity (§5) |

Hierarchická konzistence: attach session implikuje attach její (seed) instance — session nesmí zůstat account-owned s anonymním parentem (jinak by push skončil trvalým `DEPENDENCY_FAILED`).

---

# 5. Attach algoritmus (lokální, bez sítě)

Attach je **čistě lokální transakce** nad mobilní DB — žádný nový endpoint, žádný přenos (přenos zajistí standardní push C10 poté):

1. Vstup: `accountId` přihlášeného účtu (z ověřené session, C3).
2. V jedné transakci přepsat `owner_id` z `local-anonymous` na `accountId` u entit klasifikovaných v §4 jako attach-eligible: sessions → jejich instance (vč. seed instancí se session) → summaries; children (performance/feedback) jsou vlastněny tranzitivně přes session (R2-01) a `owner_id` sloupec mají jen roots + outbox.
3. `sync_state` připojených entit: `SYNCED` se nemění (už jsou na serveru pod týmž účtem — jen re-login případ); `LOCAL_ONLY`/`DIRTY`/`CONFLICT`/`BLOCKED` zůstávají beze změny hodnoty — attach mění vlastníka, ne sync stav.
4. Anonymní outbox položky (`owner_id = local-anonymous`) se přepíší na `accountId` — historie záměrů zůstává konzistentní s vlastníkem entit.
5. **Žádná jiná pole se nemění**: ID (LAM-004), row_version, časy, doménové hodnoty i aktivní session zůstávají nedotčené (`R2P-013`).

Čistý seed zůstává `local-anonymous` a nesynchronizuje se; uživatelským (a připojitelným) se stane až startem workoutu (existující R2-05 stamping — po přihlášení už rovnou s účtem).

---

# 6. Spouštění a idempotence

- Attach běží **automaticky po úspěšném přihlášení i registraci** (C3 §6.1 — transition „musí zachovat" data; bez attach by data zůstala nesynchronizovatelná) a je součástí téže lokální posloupnosti jako vazba lokálního vlastníka (R2-05 `LocalOwnerBinding`).
- Attach je **idempotentní** (`ISC-005`): opakované spuštění (retry, restart uprostřed, každé další přihlášení téhož účtu) je no-op nad už připojenými daty — `WHERE owner_id = 'local-anonymous'` přirozeně nic nenajde.
- Attach **nevyžaduje síť** a jeho selhání nesmí shodit přihlášení (fail-safe jako binding) — nová data mezitím vznikají rovnou pod účtem; nepřipojená anonymní data připojí další běh.
- Restart uprostřed attach: transakce zajistí vše-nebo-nic; opakování je bezpečné.

---

# 7. Duplicitní ochrana při syncu

Attach sám duplicity nevytváří (jen přepis vlastníka). Ochrana při následném push je vrstvená a **existuje z R2-05**:

1. **Stabilní client-generated ID** (LAM-004, `SDM-005`) — připojená entita jde na server pod týmž ID.
2. **Stabilní idempotency key** outbox položky (`LSM-008`, C11) — retry po neznámém výsledku vrací `ALREADY_APPLIED`.
3. **Server CREATE nad existující vlastní entitou** (re-login scénář po expiraci záznamu) → `VERSION_CONFLICT`, nikdy druhá entita (`SDM-006`, C10 §10) — řeší C12 rozhodnutím.
4. Cizí ID → `PERMISSION_DENIED` (C8) — data jiného účtu se nikdy „nepřivlastní".

C15 nepřidává nový mechanismus — **vyžaduje**, aby attach žádnou z těchto vrstev neobešel (zejména nikdy nemění ID ani idempotency keys).

---

# 8. Odhlášení a druhý účet

- **Odhlášení nemění vlastnictví**: data připojená k účtu A zůstávají `owner_id = A` (čitelná lokálně, `security §7.3`); pouze *nová* data vznikají opět jako `local-anonymous` (R2-05 binding zpět na anonymní). Odhlášení nikdy nemaže data ani outbox (`LSM-006`, `TSS-009`).
- **Přihlášení účtu B na témže zařízení** (`sync-model §76`): attach připojí jen `local-anonymous` data (vzniklá po odhlášení A); data účtu A se **nepřipojují k B** (LAM-007) a jejich push je pro B nemožný (server ownership, C8). R2 baseline nezavádí per-account izolaci čtení lokální DB — to je přiznaná mez (viz §9 LAM-015 a plán non-goals správy více účtů).
- Opětovné přihlášení účtu A: jeho data jsou dál jeho; attach je no-op; sync pokračuje, kde přestal.

---

# 9. Migration invariants (`LAM`)

Nová řada. Doplňuje, neoslabuje `INV-*`, `ISC-*`, `LSM-*`, `SPC-*`, `IDC-*`.

- **LAM-001 — Attach je lokální.** Připojení je lokální přepis vlastníka bez sítě; přenos vlastní standardní sync (C10).
- **LAM-002 — Automaticky a idempotentně.** Attach běží po každém úspěšném přihlášení/registraci a opakování je no-op (`ISC-005`, `INV-013`).
- **LAM-003 — Vše-nebo-nic.** Attach běží v jedné lokální transakci; restart uprostřed nezanechá částečný stav.
- **LAM-004 — ID se nemění.** Lokální client-generated ID, idempotency keys ani `row_version` se attachem nemění (`LSM-013`, `INV-021`).
- **LAM-005 — Jen anonymní data.** Attach přepisuje výhradně `owner_id = local-anonymous`; data jiného účtu se nikdy nepřepisují (LAM-007).
- **LAM-006 — Seed se nepřipojuje.** Čistý seed/demo (SEED, bez session, `PLANNED`) zůstává anonymní a nesynchronizuje se; uživatelským se stává až uživatelskou akcí.
- **LAM-007 — Žádné přivlastnění cizích dat.** Data vlastněná účtem A se nikdy nepřipojí k účtu B; server ownership je druhá linie (C8).
- **LAM-008 — Hierarchická konzistence.** Připojení session implikuje připojení její instance; žádná account-owned entita nesmí mít anonymního parenta.
- **LAM-009 — Sync stav se nemění.** Attach mění vlastníka, ne `sync_state` ani outbox status; konflikt/rejection stavy zůstávají viditelné (C12).
- **LAM-010 — Aktivní session přežije.** Attach nemění stav, ID ani hodnoty aktivní WorkoutSession (`R2P-013`); trénink pokračuje.
- **LAM-011 — Selhání neshodí přihlášení.** Attach je fail-safe; neúspěch připojí další běh, přihlášení platí.
- **LAM-012 — Duplicitní ochranu neobchází.** Attach nikdy nemění mechanismy §7 (ID, klíče, verze); duplicitu na serveru nelze attachem vytvořit.
- **LAM-013 — Odhlášení bez ztráty i bez převodu.** Logout nemaže data ani nemění vlastnictví; nová data jsou opět anonymní.
- **LAM-014 — Feedback/performance tranzitivně.** Children bez `owner_id` sloupce jsou vlastněny přes session root (R2-01); attach roots je připojuje implicitně.
- **LAM-015 — Přiznaná mez více účtů.** R2 negarantuje per-account izolaci čtení lokální DB na sdíleném zařízení; správa více účtů je mimo R2 (plán §5.2) a data cizího účtu nejsou synchronizovatelná (C8).

---

# 10. Interaction with other contracts

- **C3:** vlastní transition sémantiku (§6.1); C15 datové provedení.
- **C2:** vlastní `owner_id`/outbox model; C15 definuje jediný povolený hromadný přepis vlastníka.
- **C7:** logout chování (materiál vs. data); C15 doplňuje vlastnickou stránku.
- **C10/C11:** přenos a replay připojených dat; C15 garantuje, že attach jejich ochrany neobchází.
- **C12:** konflikty z re-login push scénářů (`VERSION_CONFLICT` na CREATE) řeší standardní resolution.
- **C8:** server-side ownership jako druhá linie proti přivlastnění.
- **C6:** `SDM-005/006` — server přijímá připojená client ID beze změny.

---

# 11. Testing requirements (kontraktně)

Implementace R2-07 musí ověřit (`test-strategy §5/§7`, `QTR-003/005`):

1. **Attach po přihlášení** — anonymní session + performance + summary + dotčená (seed) instance přejdou pod účet; ID, row_version, hodnoty i časy byte-po-bytu nezměněné.
2. **Seed zůstává** — čisté seed instance zůstávají anonymní a v push batchi se neobjeví.
3. **Idempotence** — druhý attach (i po restartu) je no-op; opakované přihlášení nevytvoří změnu.
4. **Aktivní session** — attach během aktivní session ji nezmění a recovery po restartu funguje (R1-05 regresní).
5. **Sync po attach** — připojená data se pushnou pod týmž ID (server je přijme; žádná duplicita), vč. offline-created → attach → replay.
6. **Druhý účet** — po logout A + login B se data A nepřipojí k B a B je nemůže pushnout (lokální klasifikace + server ownership negativní test).
7. **Fail-safe** — simulované selhání attach neshodí přihlášení; další běh připojí.
8. **R1 offline tok beze změny** (R2P-004).

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 12. Evidence gates

Implementace R2-07 musí doložit: attach persistence testy nad skutečnou SQLite (zachování dat byte-po-bytu, idempotence, transakčnost), seed exclusion test, second-account testy, end-to-end anonymní-trénink → registrace → attach → push (Testcontainers), traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 13. Ready condition

C15 je Done, právě když definuje: klasifikaci dat (§4), attach algoritmus (§5), spouštění a idempotenci (§6), duplicitní ochranu (§7), chování při odhlášení a druhém účtu (§8), invarianty `LAM-001…LAM-015` (§9), hranice (§10), testing/evidence (§11–§12); je zapsán v doc mapě a status auditu; a neobsahuje kód ani migrace. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C15 je **Done** — **kontraktní mapa R2 (C1–C15) je tím kompletní**.

**Dopad na R2-07:** Ready podmínka = R2-05 Done (✓) + C15 (✓) → **`R2-07` je `READY` (neimplementováno)**. `R2-08` zůstává `NOT_READY` do dokončení R2-07.

**Další kanonický krok:** **implementace `R2-07`** (samostatné rozhodnutí), poté `R2-08` — kritická E2E evidence a R2 Exit Review.

---

# 14. References

- `docs/07-backend/r2-identity-session-contract.md` — C3 §6.1, `ISC-005/012`.
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-001/006/008/013`.
- `docs/07-backend/r2-sync-protocol-contract.md` — C10; `SPC-001/008`.
- `docs/12-data/r2-idempotency-contract.md` — C11; `IDC-001/012`.
- `docs/07-backend/r2-conflict-rejection-contract.md` — C12; re-login konflikty.
- `docs/11-security/r2-token-session-storage-contract.md` — C7 §7; `TSS-009`.
- `docs/12-data/r2-server-data-model.md` — C6 §5; `SDM-005/006`.
- `docs/11-security/r2-authorization-ownership-contract.md` — C8; druhá linie.
- `docs/06-domain/domain-invariants.md` — `INV-013/021`.
- `docs/06-domain/sync-and-offline-model.md` — `§76` více účtů, `§77` odhlášení s pending změnami.
- `docs/13-delivery/r2-vertical-slice-plan.md` — §9.7 R2-07, §12 seed pravidlo, `R2P-013`.
- `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`.
