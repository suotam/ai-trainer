# AI Trainer – R3 Mobile Schema Migration Contract (C16)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r3-mobile-schema-migration.md`
**Vlastník:** Data Architecture
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C16 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/12-data/r2-mobile-schema-migration.md` (C1), `docs/12-data/r1-physical-data-model.md`, `docs/12-data/data-architecture.md`, `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/06-domain/sync-and-offline-model.md`, `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** C17–C23 (sémantika R3 entit), C24 (sync extension), Drift migrace v4→v5+ v implementacích R3 slices
**Vlastněné pojmy nebo kontrakty:** evoluce mobilního Drift/SQLite schématu během R3 (verze `5+`), R3 strukturální přírůstky, „born ownable and syncable" pravidlo, attach coverage nových tabulek a pravidla `R3M-001` až `R3M-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

R3 (`Profile and Manual Planning`) zavádí nové lokální datové oblasti (sportovní profil, cíle, dostupnost/vybavení/omezení, ruční plán, evidence kalendářních změn, ruční aktivita). Mobilní schéma skončilo R2 na verzi **4**; R3 potřebuje jediný kanonický kontrakt, který určí, jak schéma bezpečně poroste na verze **5+** — aniž by se rozbil R1 offline tok, R2 sync/attach chování nebo ztratila jakákoli potvrzená data.

Dokument je **contract-only**: žádný SQL, `CREATE TABLE` ani Drift kód. C1 (`r2-mobile-schema-migration.md`) zůstává závazný — C16 jeho pravidla **dědí a rozšiřuje** o R3 specifika; nic z C1/`MSM-*` neoslabuje.

## 1.2 Owner

**Data Architecture.** Sémantiku nových entit vlastní doménové kontrakty C17–C23; sync registr a serverovou reprezentaci vlastní C24; tento dokument vlastní strukturální evoluci a migrační bezpečnost mobilního schématu v R3.

## 1.3 Které slices blokuje

- **Blocking pro `R3-01`** (spolu s C17) a transitivně pro každý další R3 slice, který zavádí nebo mění lokální tabulku (`R3-02` až `R3-06`; `R3-07` jen pokud vyžaduje schema změnu).
- Každá R3 změna mobilního schématu se řídí tímto kontraktem po celou dobu R3.

---

# 2. Scope

## 2.1 Co tento kontrakt řeší

- verzovací politiku schématu v R3 (§4),
- kontraktní výčet R3 strukturálních přírůstků po slicech (§5),
- pravidlo **born ownable and syncable** pro nové aggregate roots (§6),
- **attach coverage** nových tabulek (§6.3 — zpřesnění plánu §9.7),
- migrační invarianty `R3M-*` (§7),
- testovací požadavky a evidence gates (§8–§9),
- Ready podmínku (§10).

## 2.2 Co tento kontrakt výslovně neřeší

- sémantiku entit (sporty/cíle/dostupnost/plán/operace/aktivita/statistiky) — vlastní **C17–C23**,
- sync registr, serverové tabulky a rozšíření push protokolu — vlastní **C24** (a beze změny platí C10/C11),
- sémantiku attach — vlastní **C15** (C16 určuje jen povinnost pokrytí nových tabulek),
- serverové PostgreSQL migrace (oddělený lifecycle, `RER-007`).

---

# 3. Source of truth

- **C1 (`MSM-001..015`) platí beze změny** pro všechny mobilní migrace `v ≥ 5`; C16 je rozšiřuje, neduplikuje ani neoslabuje. Při rozporu platí přísnější pravidlo.
- `r1-physical-data-model.md` zůstává autoritativní pro R1 tabulky; skutečný stav verzí v2–v4 je evidován v `DOCUMENTATION_STATUS.md` §3 (R2-01: v2 owner/sync/outbox; R2-05: v3 synced versions; R2-06: v4 sync resolutions).
- Pro **R3 strukturální přírůstky a jejich migrační pravidla** je jediným zdrojem pravdy tento dokument.

---

# 4. Version policy (R3)

- R3 začíná verzí **5**. Každý slice, který zavádí nebo mění tabulku, zvýší verzi o `1` explicitní migrací od reálného předchozího stavu; slice bez schema změny verzi nemění.
- Pravidla C1 §5 (co vyžaduje bump) platí beze změny.
- Očekávaný průběh (informativní, ne závazný počet): v5 = R3-01 (sportovní profil), v6 = R3-02 (cíle), v7 = R3-03 (dostupnost/vybavení/omezení), v8 = R3-04 (plán), v9 = R3-05 (evidence kalendářních změn), v10 = R3-06 (aktivita). Sloučení více přírůstků do jedné verze je dovoleno jen uvnitř jednoho slice.

---

# 5. R3 structural additions (kontraktně)

Bez SQL a bez konkrétních typů; sémantiku vlastní uvedené kontrakty:

| Slice | Přírůstek (aggregate root / struktura) | Sémantika |
|---|---|---|
| R3-01 | sportovní profil uživatele (UserSport vč. participation pattern) | C17 |
| R3-02 | cíle s prioritami a lifecycle | C18 |
| R3-03 | dostupnost (typický týden), vybavení/prostředí, základní omezení | C19 |
| R3-04 | ruční tréninkový plán + vazba plán→workout instance | C20 |
| R3-05 | append-only evidence kalendářních změn (move/cancel/replace) | C21 |
| R3-06 | ruční aktivita (MANUAL) | C22 |

Statistiky (C23) jsou čistý read model — **žádná nová perzistovaná struktura** (žádné uložené agregáty, `R3P-010`).

---

# 6. Born ownable and syncable

## 6.1 Povinná metadata nových roots

Každá nová vlastnitelná R3 aggregate root tabulka má **od vzniku**: owner reference, sync-state atribut, lokální verzi entity a časové značky — ve shodě s C2 vzorem. Child struktury jsou vlastněny tranzitivně přes root (R2-01 vzor).

## 6.2 Stamping vlastníka a sync stavů

Nový řádek dostává **aktuálního lokálního vlastníka v okamžiku zápisu** (anonymní, nebo účet dle R2-05 owner bindingu). Zápisy od vzniku udržují sync-state disciplínu (`LOCAL_ONLY` při vytvoření, `SYNCED→DIRTY` při úpravě). **Push/enqueue nových typů začíná až rozšířením registru (C24/R3-07)** — do té doby sync-state jen poctivě eviduje stav; žádná data se neztrácí ani nepředstírají synchronizaci.

## 6.3 Attach coverage (zpřesnění plánu §9.7)

Každá nová vlastnitelná tabulka musí být zahrnuta do **C15 attach transakce ve stejném slice, který ji zavádí**. Bez toho by se anonymně vytvořená R3 data po přihlášení „ztratila" z owner-filtrovaných read modelů. `R3-07` attach pokrytí již jen ověřuje E2E testem, nerozšiřuje ho.

---

# 7. Migration invariants (`R3M`)

- **R3M-001 — C1 platí.** `MSM-001..015` platí beze změny pro všechny verze `≥ 5`; C16 je neoslabuje.
- **R3M-002 — Verze per slice.** R3 začíná verzí 5; každý slice se schema změnou = nová verze s explicitní migrací testovanou od reálného předchozího stavu.
- **R3M-003 — Aditivní evoluce.** R3 migrace nemění destruktivně žádnou R1/R2 tabulku; úpravy existujících tabulek jsou výhradně aditivní a řídí se C1 §6.
- **R3M-004 — Born ownable.** Nové vlastnitelné roots mají owner reference, sync-state, lokální verzi a časové značky od vzniku (§6.1).
- **R3M-005 — Owner při zápisu.** Vlastníka razí aplikace v okamžiku zápisu aktuálním lokálním vlastníkem; migrace ani schéma nikdy nepřiřazují účet.
- **R3M-006 — Attach coverage.** Nová vlastnitelná tabulka je součástí C15 attach transakce od slice, který ji zavádí (§6.3).
- **R3M-007 — Sync-state disciplína před registrem.** Do rozšíření registru (C24) sync-state pouze eviduje skutečnost; nic není označeno jako synchronizované a žádná operace se nepředstírá.
- **R3M-008 — Prázdná inicializace.** Nové R3 tabulky vznikají prázdné; migrace neseeduje obsah (R3 nemá profilový/plánovací seed).
- **R3M-009 — Rekurzivní pravidla.** Pozdější evoluce R3 tabulek se řídí týmiž pravidly (aditivní, deterministická, testovaná).
- **R3M-010 — Migrační test od reálného stavu.** Každá migrace prokazuje zachování všech R1+R2 dat (vč. aktivní session, outboxu, resolutions, sync stavů) i dříve vzniklých R3 dat.
- **R3M-011 — Integrita po migraci.** `foreign_key_check` čistý; nové `UNIQUE`/`CHECK` platí pro existující data.
- **R3M-012 — Generated code je evidence.** Drift generovaný kód commitovaný, drift-check v CI čistý (`RER-010`).
- **R3M-013 — Offline migrace.** Bez sítě a backendu (`RSR-004`).
- **R3M-014 — Unknown ≠ zero.** Volitelné atributy jsou nullable/`UNKNOWN`; chybějící hodnota se nenahrazuje vymyšleným defaultem (`DAR-015`).
- **R3M-015 — Verze evidována.** Aktuální schema verze je po každém slice zapsána v `DOCUMENTATION_STATUS.md` §3.

---

# 8. Testing requirements

1. **Migrační test od reálného vN-1 stavu** nad skutečnou SQLite — zachování R1+R2+dřívějších R3 dat, aktivní session, outbox, resolutions (`R3M-010`).
2. **Idempotence/determinismus** migrace (no-op při opakování).
3. **Integrita** — `foreign_key_check` + constraint kontrola (`R3M-011`).
4. **Attach test** — anonymně vytvořený řádek nové tabulky se attachem připojí k účtu (`R3M-006`).
5. **Owner stamping test** — řádek vytvořený pod účtem nese účet, anonymně anonymního vlastníka (`R3M-005`).
6. **R1/R2 regression** — R1 offline kritický tok i R2 kritická cesta zůstávají zelené.
7. **Drift-check** čistý.

Flaky výsledek není zelený důkaz.

---

# 9. Evidence gates

Při každém R3 slice se schema změnou musí být doloženo: zelený migrační test od reálného předchozího stavu, drift-check, integrity check, attach coverage test, owner stamping test, R1+R2 regression a traceable CI evidence (`DRD-014`, `QTR-015`). Chybějící důkaz = slice není Done.

---

# 10. Ready condition

## 10.1 Kdy je C16 Done

C16 je Done, právě když definuje verzovací politiku R3 (§4), kontraktní přírůstky (§5), born-ownable a attach-coverage pravidla (§6), invarianty `R3M-001..015` (§7), testy a evidence (§8–§9) a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C16 je **Done**.

## 10.2 Co C16 odblokuje

C16 je jeden ze dvou blocking kontraktů `R3-01`; druhý je **C17** (`docs/06-domain/r3-sports-profile-contract.md`). Zůstává závazný pro všechny další R3 schema změny.
