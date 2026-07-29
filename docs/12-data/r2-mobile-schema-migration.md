# AI Trainer – R2 Mobile Schema Migration Contract (C1)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r2-mobile-schema-migration.md`
**Vlastník:** Data Architecture
**Poslední aktualizace:** 2026-07-27
**Kontraktní ID:** C1 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/12-data/r1-physical-data-model.md`, `docs/12-data/data-architecture.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/domain-invariants.md`, `docs/08-mobile/mobile-architecture.md`, `docs/13-delivery/repository-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/r2-vertical-slice-plan.md`
**Navazující dokumenty:** C2 – Local ownership & outbox/pending-operation contract (`docs/12-data/r2-local-sync-metadata-contract.md`), Drift migrace a mobile persistence pro R2-01
**Vlastněné pojmy nebo kontrakty:** evoluce mobilního Drift/SQLite schématu během R2, mobile schema versioning, migration strategy, migration invariants a pravidla `MSM-001` až `MSM-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

R2 (`Account and Sync`) potřebuje mobilní lokální data učinit **vlastnitelná a synchronizovatelná**, aniž by se rozbil offline-first kritický tok R1. To vyžaduje strukturální evoluci mobilního Drift/SQLite schématu (owner reference, sync metadata, verze entity, outbox). `r1-physical-data-model.md §18` definuje pouze bázová pravidla migrace pro R1 (schema verze `1`). R2 zavádí schema verze `2` a případné další verze v průběhu R2 a potřebuje **jediný kanonický kontrakt**, který určí, jak se mobilní schéma smí bezpečně měnit po celou R2.

Tento dokument je tímto kontraktem. Je záměrně **contract-only**: neobsahuje žádný produkční kód, SQL, `CREATE TABLE` ani Drift definice. Obsahuje pravidla, invarianty, migration strategy, ownership a evidence.

## 1.2 Owner

**Data Architecture.** Sémantiku migrovaných dat sdílí s vlastníky navazujících kontraktů (viz §3.3), ale pravidla a verzování mobilního schématu a jeho migrací vlastní tento dokument, v souladu s `RER-007` (lokální schéma a jeho migrace mají lifecycle uvnitř mobilní aplikace).

## 1.3 Vztah k R2 vertical-slice plánu

Tento dokument je kontrakt **C1** z `r2-vertical-slice-plan.md §7.1`. Minimum požadované plánem — „verze schématu, sync/owner sloupce, zachování všech R1 dat, migrační test od reálného v1" — je pokryto v §5–§12.

## 1.4 Které slices blokuje

- **Blocking pro `R2-01 – Local Ownership and Sync Metadata Foundation`** (spolu s C2). `R2-01` je první R2 slice, proto je C1 transitivně na kritické cestě celé R2.
- Kterákoli pozdější R2 změna mobilního schématu (např. rozšíření o synced entity v `R2-05`, migrace lokálních dat pod účet v `R2-07`) se řídí tímto kontraktem; C1 tedy zůstává závazný po celou R2, ne pouze pro `R2-01`.

C1 **neblokuje** čistě backendové slices (`R2-02`), které se mobilního schématu nedotýkají.

---

# 2. Scope

## 2.1 Co tento kontrakt řeší

- politiku verzování mobilního Drift/SQLite schématu v R2 (§5),
- pravidla a zákazy migrací (§6),
- **kontraktní** výčet strukturálních přírůstků schématu potřebných pro R2 (owner reference, sync metadata, verze entity, outbox/change-log) — bez implementace (§7),
- ownership metadata na úrovni schématu (§8),
- sync metadata na úrovni schématu (§9),
- migration invarianty `MSM-*` (§10),
- požadavky na testování a evidence migrací (§11–§12),
- Ready podmínku C1 (§13).

## 2.2 Co tento kontrakt výslovně neřeší

- **žádný produkční kód, SQL, `CREATE TABLE`, Drift kód ani konkrétní typy sloupců**,
- **sémantiku** local owner identity a outbox/pending-operation lifecycle — vlastní **C2** (`r2-local-sync-metadata-contract.md`),
- **synchronizační protokol**, push/pull, transport a serverovou reprezentaci — vlastní sync protocol contract (**C10**) a server data model (**C6**),
- **idempotency algoritmus / IdempotencyRecord** — vlastní **C11**,
- **conflict resolution a rejection sémantiku** — vlastní **C12**,
- **token/session storage** a bezpečné mobilní uložení credentials — vlastní **C7**,
- **local-to-account migraci** (připojení existujících dat k účtu při prvním přihlášení) — vlastní **C15**; C1 pouze garantuje, že strukturální předpoklady pro takovou migraci vzniknou bezpečně,
- serverové PostgreSQL migrace (jiný lifecycle, `RER-007`).

C1 určuje **jak se mobilní schéma smí bezpečně měnit a které strukturální přírůstky přibudou**; **význam** těch přírůstků a jejich runtime chování vlastní navazující kontrakty výše.

---

# 3. Source of truth

## 3.1 Jediný zdroj pravdy

Pro **evoluci mobilního schématu v R2** (verzování, migrační pravidla, migration invarianty, strukturální přírůstky a jejich migrace) je jediným zdrojem pravdy tento dokument. Při rozporu s nekanonickým textem platí tento dokument; skutečný rozpor s vlastníky níže se řeší změnou dokumentu, ne tichou odchylkou.

## 3.2 Vztah k `r1-physical-data-model.md`

`r1-physical-data-model.md` zůstává autoritativní pro **existující R1 schéma verze `1`** (tabulky, constraints, transakční hranice, `PDR-001…PDR-015`) a pro **bázová migrační pravidla §18**. C1 tato bázová pravidla **rozšiřuje** pro R2 (schema verze `2+`) a nesmí je oslabit. R1 tabulky a jejich `PDR` invarianty se migrací nemění destruktivně.

## 3.3 Vztah k dalším zdrojům

- **Sync model (`sync-and-offline-model.md`)** vlastní `SyncState` (§11), `LocalChangeLog`/`OfflineCommand` sémantiku (§12) a offline-first pravidla (§3). C1 na tyto pojmy odkazuje a zajišťuje, že mobilní schéma je bude umět reprezentovat; **nepředefinovává je**.
- **Ownership model** (identity/profile, C2 a serverová ownership autorizace C8) vlastní význam vlastnictví. C1 pouze zajišťuje strukturální **owner reference** na vlastnitelných entitách.
- **Future server schema** (**C6**) je oddělený lifecycle (`RER-007`). Mobilní a serverové ID a schémata se neztotožňují; vztah client-generated vs server ID řeší sync protocol (C10) a C2, ne C1.

---

# 4. Migration philosophy

Mobilní migrace v R2 se řídí těmito principy (rozvedeno do závazných pravidel v §6 a §10):

- **Schema versioning:** jediná monotónně rostoucí celočíselná verze mobilního schématu; R1 = `1`, první R2 verze = `2`. Verze roste **forward-only**.
- **Append-only migrace:** vydaná migrace se nikdy needituje; oprava vzniká **novou** migrací (`§18`, analogie `RER-006` pro mobilní lifecycle).
- **Forward-only, deterministické migrace:** každý krok `vN → vN+1` je deterministický a nezávislý na síti; pro daný vstupní stav dává stejný výsledek.
- **Non-destructive:** žádné `drop and recreate`, žádné tiché mazání řádků, žádná ztráta potvrzených dat v produkčním buildu (`§18`, `DAR-013`).
- **Rollback není produkční scénář:** oprava se řeší forward-fix migrací, ne spoléháním na down-migrace (§10 `MSM-010`).
- **Generated Drift code je součást evidence:** generovaný kód je commitovaný a v CI kontrolovaný na drift (`RER-010`).
- **Migration ownership:** lifecycle mobilních migrací je uvnitř `apps/mobile` (`RER-007`), oddělený od serverových migrací.

---

# 5. Version policy

## 5.1 Jak vzniká nová schema verze

Nová mobilní schema verze vzniká **právě tehdy**, když se mění tvar perzistovaného schématu způsobem, který vyžaduje deterministickou transformaci existujících dat nebo strukturální změnu (nová tabulka, nový sloupec, změna constraintu, index dotýkající se korektnosti). Verze se zvýší o `1` a doprovodí ji explicitní migrační krok od předchozí podporované verze.

## 5.2 Změny vyžadující migraci (a bump verze)

- přidání tabulky nebo sloupce,
- přidání nebo změna `FK`, `CHECK`, `UNIQUE` nebo korektnostního indexu,
- změna nullability nebo významu existujícího sloupce,
- rename tabulky/sloupce (viz `MSM-012`),
- zavedení owner reference, sync-state, verze entity nebo outbox struktur (R2 přírůstky, §7).

## 5.3 Změny nevyžadující migraci (ani bump verze)

- čistě dokumentační změny,
- změny výhradně v aplikační/prezentační vrstvě bez dopadu na perzistované schéma,
- přidání čistě odvozené in-memory projekce, která se neukládá,
- ne-korektnostní výkonový index, který nemění sémantiku dat **a** je vytvořen idempotentně — pouze pokud to samostatné ADR/kontrakt výslovně dovolí; jinak se s ním zachází jako se změnou dle §5.2.

---

# 6. Migration rules

Závazná pravidla (viz též `MSM-*` v §10):

1. **Nikdy needitovat vydanou migraci.** Oprava = nová migrace s vyšší verzí.
2. **Žádná destruktivní změna v produkčním buildu:** žádné `drop and recreate`, žádné tiché smazání neznámých ani známých řádků potvrzených dat.
3. **Nullable → non-null:** nový sloupec se přidává jako `nullable` nebo s bezpečným deterministickým backfillem; přechod na `non-null` je možný jen migrací, která nejprve **backfilluje** všechny řádky a poté zpřísní constraint. „Unknown" se nesmí ztotožnit s „zero" (`DAR-015`).
4. **Rename strategy:** rename se provádí přidáním nového sloupce/tabulky, backfillem a vyřazením starého — nikdy in-place destruktivním přejmenováním, které by ohrozilo data.
5. **Index strategy:** korektnostní (unique/partiální) indexy se zavádějí migrací a ověřují po migraci; nesmí být zavedeny způsobem, který tiše zahodí porušující řádky.
6. **FK pravidla:** nové cizí klíče respektují existující `ON DELETE` politiky R1 modelu (`r1-physical-data-model`) a po migraci se ověřuje `foreign_key_check`.
7. **CHECK pravidla:** nové `CHECK` constrainty musí platit pro všechna existující data po backfillu; migrace nesmí být označena za úspěšnou, pokud by je existující řádky porušovaly.
8. **Verze až po commitu:** schema version se zvýší **až po** úspěšném dokončení celé migrační transakce (`§18.6`).
9. **Bez sítě:** migrace nesmí vyžadovat backend ani síť (`RSR-004`, local-first).

---

# 7. R2 schema additions (kontraktně)

Tato sekce popisuje **kontraktně a bez implementace**, jaké nové strukturální prvky R2 do mobilního schématu přinese. Neobsahuje SQL, Drift kód, `CREATE TABLE` ani konkrétní typy. Sémantiku vlastní C2 a sync model; zde je zachycena pouze **strukturální existence a migrační dopad**.

Migrace `v1 → v2` (vlastněná implementací `R2-01`, řízená tímto kontraktem) kontraktně zavede:

## 7.1 Owner reference na vlastnitelných entitách

Vlastnitelné R1 entity (workout instance, session, performance, feedback, activity summary — přesný výčet potvrdí C2) získají **odkaz na lokálního vlastníka**. Existující data se při migraci přiřadí **anonymous/local owner** (viz §8, `MSM-014`). Význam vlastnictví a připojení k účtu vlastní C2/C15.

## 7.2 Sync-state atribut

Synchronizovatelné entity získají **sync-state atribut** schopný reprezentovat doménový `SyncState` (`sync-and-offline-model §11`). Existující R1 data se inicializují do bezpečného počátečního stavu **`LOCAL_ONLY`** (`MSM-014`) — nikdy ne „synced". C1 nevlastní přechody mezi stavy (sync protocol / C2).

## 7.3 Verze entity (local version)

Synchronizovatelné entity získají **lokální verzovací atribut** pro detekci změn a pozdější konflikt (`sync-and-offline-model §12`). C1 zajišťuje jeho strukturální přítomnost a deterministickou počáteční hodnotu; sémantiku inkrementace vlastní C2/sync protocol.

## 7.4 Outbox / local change log

Zavede se **outbox / pending-operation struktura** (v souladu s `LocalChangeLog`/`OfflineCommand`, `sync-and-offline-model §12`) se **stabilním idempotency key**, **restart-safe** (přežije restart aplikace). C1 vlastní pouze její **strukturální existenci a migrační bezpečnost**; lifecycle operací, idempotency key pravidla a replay vlastní **C2** (a idempotency contract **C11**).

## 7.5 Co C1 zde NEdělá

- neurčuje konkrétní názvy, typy ani počty sloupců/tabulek,
- neurčuje serializační formát operací,
- nezavádí synchronizační protokol ani stavový automat přechodů,
- nezavádí serverové ID mapování.

---

# 8. Ownership metadata

## 8.1 Jaká metadata přibudou

Na úrovni schématu přibude **owner reference** (§7.1) a podpora **anonymous/local owner identity** pro data vzniklá před přihlášením.

## 8.2 Proč

R2 musí umět odlišit data vlastněná lokálním (dosud nepřihlášeným) uživatelem od dat připojených k účtu, aby bylo možné je později bezpečně připojit k účtu (`R2-07`/C15) bez ztráty a bez duplicit, a aby server mohl vynucovat ownership (`SAR-002/003`). Bez lokální owner identity by připojení k účtu nebylo deterministické.

## 8.3 Kdo je autorita

- **Struktura owner reference v mobilním schématu:** tento kontrakt (C1).
- **Sémantika local owner identity a připojení k účtu:** C2 (local ownership) a C15 (local-to-account migration).
- **Serverové vynucení ownershipu:** C8; klientem dodané owner ID není samo o sobě důvěryhodné (`SAR-003`, cross-slice invariant §10.4 R2 plánu).

---

# 9. Sync metadata (kontraktně)

Na úrovni schématu přibude podpora těchto sync metadat (sémantiku vlastní sync model a C2, ne C1):

- **sync-state** (§7.2) — reprezentace doménového `SyncState`,
- **pending operations / outbox** (§7.4) — restart-safe fronta s idempotency key,
- **ownership** (§8) — owner reference,
- **timestamps** — audit/ordering časové značky pro migrované i nové entity, konzistentní s časovou politikou R1 modelu,
- **versioning** (§7.3) — lokální verze entity.

C1 **nenavrhuje synchronizační protokol**: neurčuje pořadí odesílání, transport, retry politiku, batching ani reprezentaci na serveru. Určuje pouze, že mobilní schéma tato metadata **strukturálně unese** a že jejich zavedení proběhne bezpečnou migrací.

---

# 10. Migration invariants (`MSM`)

Nové invarianty pro mobilní migrace R2. Doplňují, neoslabují `PDR-*`, `DAR-*` a `§18`.

- **MSM-001 — Jediná monotónní verze.** Mobilní schéma má jedinou celočíselnou verzi rostoucí forward-only; R1 = `1`, první R2 = `2`.
- **MSM-002 — Explicitní testovaná migrace.** Každá verze `≥ 2` má explicitní migrační krok testovaný **od reálného předchozího podporovaného stavu** (`§18`, `DRD-007`, `QTR-005`).
- **MSM-003 — Append-only.** Vydaná migrace se needituje; oprava je nová migrace.
- **MSM-004 — Non-destructive.** Žádné `drop and recreate`, žádné tiché mazání potvrzených dat v produkčním buildu (`§18`, `DAR-013`).
- **MSM-005 — Zachování potvrzených dat.** Migrace nesmí ztratit žádná potvrzená R1 data (instance, sessions, performances, feedback, summaries, `local_app_state`) ani **aktivní session** (`PDR-009`, `DAR-013`, R2 invariant §10.12).
- **MSM-006 — Deterministická a idempotentní.** Stejný vstupní stav → stejný výsledek; opětovné spuštění již dokončené migrace je no-op.
- **MSM-007 — Verze až po commitu.** Schema version se zvýší až po úspěšném dokončení celé migrační transakce.
- **MSM-008 — Integrita po migraci.** Po migraci se ověří `foreign_key_check` a platnost nových `UNIQUE`/`CHECK` constraintů.
- **MSM-009 — Generated code je evidence.** Generovaný Drift kód je commitovaný a v CI kontrolovaný na drift (`RER-010`).
- **MSM-010 — Bez produkčního rollbacku.** Down-migrace nejsou produkční scénář; oprava je forward-fix.
- **MSM-011 — Bezpečné přidání sloupce.** Nový sloupec je `nullable` nebo má bezpečný deterministický backfill; `non-null` až po backfillu (viz §6.3).
- **MSM-012 — Bezpečný rename.** Rename přes add-new + backfill + retire; nikdy destruktivní in-place.
- **MSM-013 — Unknown ≠ zero.** Migrace zachovává rozlišitelnost chybějící, neznámé a nulové hodnoty (`DAR-015`).
- **MSM-014 — Bezpečná inicializace metadat.** Přidaná owner/sync metadata inicializují existující R1 řádky na **local/anonymous owner** a **`LOCAL_ONLY`**; migrace nikdy neoznačí předchozí data za „synced" ani je nepřiřadí k účtu.
- **MSM-015 — Offline migrace.** Migrace nevyžaduje síť ani backend (`RSR-004`, local-first).

---

# 11. Testing requirements

Kontraktní požadavky na dokazování migrací (implementaci vlastní příslušný slice; `test-strategy §7.1/§9`, `QTR-004/005`):

1. **Migration test od reálného v1 stavu** — nad skutečným Drift/SQLite enginem (`QTR-004`), ne mock/odlišný in-memory engine; prokazuje zachování všech potvrzených dat a aktivní session (`MSM-002/005`).
2. **Idempotence a determinismus** — opětovné spuštění dokončené migrace je no-op; stejný vstup → stejný výstup (`MSM-006`).
3. **Integrita po migraci** — `foreign_key_check` čistý; nové `UNIQUE`/`CHECK` platí (`MSM-008`).
4. **Metadata init** — existující řádky mají `local/anonymous owner` a `LOCAL_ONLY`; nic není označeno jako synced (`MSM-014`).
5. **Restart-safe outbox** — outbox položka přežije restart aplikace (R2 invariant §10.3, `sync-and-offline-model §3.7`).
6. **R1 offline kritický tok beze změny** — kritický R1 flow zůstává funkční v airplane mode (R2 invariant §10.1, `RSR-004`).
7. **Drift-check** — generovaný kód bez driftu (`MSM-009`, `RER-010`).

Flaky migrační/critical-path test se nepovažuje za zelený důkaz (`QTR`, `DRD`).

---

# 12. Evidence gates

Při implementaci `R2-01` (a jakékoli pozdější R2 migrace) musí být doloženo:

- **Migration evidence:** zelený migration test od reálného předchozího stavu prokazující zachování dat + aktivní session.
- **Drift evidence:** `drift-check` generovaného kódu čistý v PR CI.
- **Integrity evidence:** `foreign_key_check` a constraint kontrola po migraci.
- **Metadata evidence:** test inicializace owner/sync metadat (`MSM-014`).
- **Restart evidence:** test, že outbox položka přežije restart.
- **R1 regression evidence:** R1 offline kritický tok stále prochází (unit/integration/E2E dle dopadu).
- **Traceable release evidence** navázaná na konkrétní commit a CI run (`QTR-015`, `DRD-014`).

Chybějící povinný důkaz znamená, že slice není Done (`DRD-014`).

---

# 13. Ready condition

## 13.1 Kdy je C1 dokončen (Done)

C1 je Done, právě když tento dokument:

1. definuje **version policy** (§5) — jak vzniká nová verze a které změny ji vyžadují,
2. definuje **migration rules a zákazy** (§6),
3. kontraktně (bez implementace) vymezuje **R2 strukturální přírůstky** — owner reference, sync-state, verze entity, outbox (§7),
4. určuje **ownership a sync metadata** na úrovni schématu a jejich autoritu (§8–§9),
5. zavádí **migration invarianty `MSM-001…MSM-015`** (§10),
6. definuje **testing requirements a evidence gates** (§11–§12),
7. je zapsán v `docs/README.md` (mapa + ownership) a v `docs/DOCUMENTATION_STATUS.md` jako existující kontrakt,
8. neobsahuje žádný produkční kód, SQL ani Drift definice.

Tyto podmínky jsou vytvořením tohoto dokumentu a doprovodné aktualizace doc mapy **splněny**; C1 je tedy **Done**.

## 13.2 Co C1 odblokuje

C1 je jeden ze dvou blocking kontraktů `R2-01`. `R2-01` zůstává `NOT_READY`, dokud **není hotový i C2** (`r2-local-sync-metadata-contract.md`). C1 sám o sobě neopravňuje zahájit implementaci `R2-01`.

## 13.3 Další kanonický krok

Vytvoření **C2 – Local ownership & outbox/pending-operation contract** (`docs/12-data/r2-local-sync-metadata-contract.md`). Teprve po C1 **i** C2 a Ready kontrole lze zahájit implementaci `R2-01`.

---

# 14. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — R2 plán; C1 map (§7.1), R2-01 (§9.1), cross-slice invariants (§10).
- `docs/12-data/r1-physical-data-model.md` — R1 schéma, `PDR-001…PDR-015`, migrace `§18`, recovery `§19`.
- `docs/12-data/data-architecture.md` — `DAR-003` (historická interpretovatelnost), `DAR-006` (rekonstruovatelné projekce), `DAR-007` (offline identita), `DAR-013` (bezpečná lokální migrace), `DAR-015` (unknown ≠ zero).
- `docs/06-domain/sync-and-offline-model.md` — offline-first `§3`, `SyncState` `§11`, `LocalChangeLog`/`OfflineCommand` `§12`.
- `docs/06-domain/domain-invariants.md` — doménové invarianty (`INV`).
- `docs/08-mobile/mobile-architecture.md` — bootstrap/migrace `§18`, `MAR-013` (definované chování migrace/recovery).
- `docs/13-delivery/repository-strategy.md` — `RER-007` (mobilní schéma lifecycle), `RER-010` (reprodukovatelný generated code / drift-check).
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-007` (migration test), `DRD-014` (žádné tvrzení Done bez důkazu).
- `docs/14-quality/test-strategy.md` — persistence integration `§7.1`, migration tests `§9`, `QTR-004/005/015`.
- `docs/02-product/release-scope.md` — R2 scope `§6`, `RSR-004` (R1 bez závislosti na síti).
