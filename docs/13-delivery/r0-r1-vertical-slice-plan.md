# AI Trainer – R0/R1 Vertical Slice Implementation Plan

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r0-r1-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/07-backend/r0-api-contract.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/r1-physical-data-model.md`, `docs/13-delivery/repository-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** coding-agent/context-loading guide, issue backlog, CI workflows, OpenAPI source, repository skeleton a implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R0/R1, slice boundaries, dependencies, výsledné artefakty, evidence gates, backlog decomposition a pravidla `VSP-001` až `VSP-015`

---

# 1. Účel

Tento dokument převádí schválený scope `R0 – Technical Foundation` a `R1 – Local Workout Slice` na konkrétní pořadí malých implementačních slices.

Nevytváří nový produktový scope. Neopakují se zde detailní:

- funkční a nefunkční požadavky,
- doménové modely,
- API a datové kontrakty,
- test cases,
- Definition of Ready a Definition of Done.

Dokument určuje zejména:

- co implementovat jako první,
- které práce mohou běžet paralelně,
- které artefakty musí každý slice vytvořit,
- jaké evidence musí existovat před pokračováním,
- co nesmí být do R0 a R1 předčasně přidáno.

---

# 2. Delivery princip

Vývoj postupuje po malých spustitelných řezech. Každý slice musí:

1. mít jeden hlavní ověřitelný výsledek,
2. být `Ready` podle `definition-of-ready-and-done.md`,
3. vytvářet pouze potřebnou infrastrukturu,
4. obsahovat odpovídající testy a dokumentační změny,
5. skončit reprodukovatelným důkazem výsledku,
6. nezavádět scope pozdějších releases pouze „do zásoby“.

Technologická vrstva se nestaví izolovaně déle, než je nutné pro další spustitelný tok.

---

# 3. Celkové pořadí

Doporučené pořadí:

```text
R0-01 Repository Skeleton
    ↓
R0-02 Mobile Bootstrap
    ↓
R0-03 Backend Bootstrap
    ↓
R0-04 Contracts and Health API
    ↓
R0-05 Local Infrastructure and Migrations
    ↓
R0-06 CI and Repository Gates
    ↓
R0-07 Mobile-to-Backend Smoke Flow
    ↓
R0 Exit Review
    ↓
R1-01 Local Workout Seed and Read Model
    ↓
R1-02 Today and Workout Detail
    ↓
R1-03 Start and Persist Session
    ↓
R1-04 Record Workout Performance
    ↓
R1-05 Restart and Recovery
    ↓
R1-06 Complete Workout and History
    ↓
R1-07 Feedback, States and Accessibility
    ↓
R1-08 Critical End-to-End Evidence
    ↓
R1 Exit Review
```

R0 mobile a backend bootstrap mohou po vytvoření repository skeletonu částečně běžet paralelně. R1 začíná až po splnění R0 exit review.

---

# 4. R0-01 – Repository Skeleton

## Výsledek

Repozitář má fyzickou strukturu potvrzenou v `repository-strategy.md` a jednotné základní nástroje.

## Scope

- vytvořit `apps/mobile`,
- vytvořit `apps/backend`,
- vytvořit `packages/contracts`,
- vytvořit `database`, `tooling` a `.github` podle skutečné potřeby,
- přidat root `.editorconfig` a `.gitignore`,
- přidat bezpečný root README s lokálními příkazy,
- nevytvářet prázdné moduly pro R2 až R5.

## Artefakty

- kompilovatelný repository skeleton,
- základní lokální příkazy nebo scripts,
- ověřená absence secrets a build artefaktů.

## Evidence gate

- clean checkout má srozumitelnou strukturu,
- základní repository smoke check projde,
- žádná paralelní nebo duplicitní struktura nevznikla.

---

# 5. R0-02 – Mobile Bootstrap

## Výsledek

Flutter aplikace se spustí a má composition root odpovídající schválené architektuře.

## Scope

- Flutter aplikace pro Android a iOS,
- Riverpod composition,
- GoRouter shell,
- základní theme a localization bootstrap,
- environment configuration boundary,
- jednoduchá technická úvodní obrazovka,
- unit/widget test bootstrap.

## Non-goals

- workout feature,
- účet,
- sync,
- AI,
- produkční design system.

## Evidence gate

- Android build a spuštění na podporovaném emulátoru nebo zařízení,
- iOS projekt je technicky sestavitelný v podporovaném prostředí,
- `flutter analyze` a základní testy projdou.

---

# 6. R0-03 – Backend Bootstrap

## Výsledek

Kotlin/Spring Boot backend se lokálně spustí jako základ modulárního monolitu.

## Scope

- Spring Boot application bootstrap,
- základní package/module boundaries,
- bezpečná konfigurace,
- clock, request ID a version abstractions potřebné pro R0,
- test bootstrap,
- základní redigované logování.

## Non-goals

- identity modul,
- workout API,
- background processing,
- message broker,
- produkční deployment.

## Evidence gate

- backend startuje lokálně,
- základní Spring test projde,
- logy neobsahují secrets ani environment dump.

---

# 7. R0-04 – Contracts and Health API

## Výsledek

R0 HTTP kontrakt existuje ve strojově čitelné podobě a backend jej implementuje.

## Scope

- `packages/contracts/openapi/ai-trainer-api.yaml`,
- `GET /api/v1/health/live`,
- `GET /api/v1/health/ready`,
- standardní error envelope,
- `X-Request-Id`,
- `Cache-Control: no-store`,
- OpenAPI validace a contract tests.

## Evidence gate

- OpenAPI je validní,
- implementace odpovídá kontraktu,
- liveness není závislá na PostgreSQL,
- readiness vrací 503 při nedostupné povinné dependency,
- response neodhaluje interní detaily.

---

# 8. R0-05 – Local Infrastructure and Migrations

## Výsledek

Lokální backendová infrastruktura je reprodukovatelná a databáze vzniká výhradně migracemi.

## Scope

- `compose.yaml` pro PostgreSQL,
- bezpečné development defaults,
- Flyway bootstrap,
- minimální počáteční migrace nebo schema marker potřebný pro readiness,
- Testcontainers setup,
- test migrace od prázdné databáze.

## Non-goals

- celé budoucí serverové workout schema,
- produkční databázová topologie,
- backup a disaster-recovery runbook.

## Evidence gate

- Compose spustí PostgreSQL bez produkčních secrets,
- Flyway projde na čisté databázi,
- backend readiness rozpozná validní a nevalidní schema stav,
- integration test používá skutečný PostgreSQL.

---

# 9. R0-06 – CI and Repository Gates

## Výsledek

GitHub Actions reprodukuje povinné kontroly z čistého checkoutu.

## Scope

- mobile format/analyze/test/build gate,
- backend format/static analysis/test/build gate,
- OpenAPI validation,
- migration test,
- repository smoke check,
- secret scanning nebo ekvivalentní baseline,
- cache pouze tam, kde neohrožuje determinismus.

## Evidence gate

- workflow projde na čistém checkoutu,
- lokální příkazy odpovídají CI příkazům,
- failing povinný test skutečně zablokuje gate,
- generated drift nelze tiše ignorovat.

---

# 10. R0-07 – Mobile-to-Backend Smoke Flow

## Výsledek

Mobilní klient načte technickou health odpověď backendu přes explicitní klientský boundary.

## Scope

- minimální HTTP client adapter,
- environment base URL,
- transport DTO oddělené od domény,
- technické zobrazení dostupnosti backendu pouze pro R0 ověření,
- timeout a bezpečné error chování.

## Non-goals

- workout API,
- retry orchestrace pro sync,
- autentizace,
- produkční offline synchronizace.

## Evidence gate

- mobil načte liveness odpověď,
- nedostupný backend nezpůsobí pád aplikace,
- chyba není prezentována jako úspěch,
- test ověřuje mapping a failure behavior.

---

# 11. R0 Exit Review

R0 je dokončen pouze pokud jsou splněny release scope a Definition of Done, zejména:

- mobile a backend se reprodukovatelně sestaví,
- backend, PostgreSQL a Flyway lze lokálně spustit,
- health API odpovídá OpenAPI,
- mobile-to-backend smoke flow funguje,
- CI projde na čistém checkoutu,
- test a migration evidence existují,
- žádný secret není v repozitáři,
- R1 není závislé na backendu.

Po R0 review se odstraní pouze blokující technický dluh. Neprovádí se obecné „vylepšování infrastruktury“ bez vazby na R1.

---

# 12. R1-01 – Local Workout Seed and Read Model

## Výsledek

Mobilní aplikace vytvoří lokální Drift/SQLite databázi a načte stabilní demo workout data.

## Scope

- schema podle `r1-physical-data-model.md`,
- počáteční migrace,
- deterministický demo AthleteProfile, plán a workout,
- repository mapping,
- dotaz pro dnešní a týdenní workouty,
- databázové integration tests.

## Evidence gate

- databáze vznikne od prázdného stavu,
- seed je idempotentní,
- snapshot workoutu lze načíst bez sítě,
- foreign keys a unique constraints jsou aktivní.

---

# 13. R1-02 – Today and Workout Detail

## Výsledek

Uživatel offline otevře Today obrazovku, týdenní přehled a detail WorkoutInstance.

## Scope

- Today presentation a application flow,
- týdenní přehled,
- workout detail,
- plánované sections, steps a set plans,
- základní empty a error states,
- widget a repository integration tests.

## Non-goals

- spuštění session,
- editace plánu,
- cloud data,
- AI doporučení.

## Evidence gate

- obrazovky fungují v airplane mode,
- zobrazují data ze stabilního lokálního snapshotu,
- neplatný nebo chybějící workout má explicitní stav.

---

# 14. R1-03 – Start and Persist Session

## Výsledek

Uživatel zahájí WorkoutSession a aktivní session je okamžitě odolně uložena.

## Scope

- start-session use case,
- atomická transakce vytvoření session a změny stavu instance,
- jedna aktivní session podle schváleného kontraktu,
- routing do aktivního trackeru,
- start timestamp přes testovatelný clock.

## Evidence gate

- dvojité spuštění nevytvoří duplicitní aktivní session,
- transakce se při selhání celá vrátí,
- aplikace po startu načte stejnou aktivní session z databáze.

---

# 15. R1-04 – Record Workout Performance

## Výsledek

Uživatel zaznamená provedení podporovaného silového workoutu.

## Scope

- záznam setů, opakování, váhy, času a poznámky podle podporovaného kroku,
- dokončení nebo vynechání kroku,
- oddělení plánovaných a skutečných hodnot,
- průběžné atomické ukládání,
- validace hodnot a explicitní chyby,
- widget, unit a persistence tests.

## Evidence gate

- potvrzená hodnota je po opětovném načtení stejná,
- neplatná hodnota se neuloží jako úspěch,
- změna actual hodnot nepřepisuje planned snapshot,
- pořadí a ownership records zůstávají konzistentní.

---

# 16. R1-05 – Restart and Recovery

## Výsledek

Po ukončení nebo pádu aplikace lze bezpečně pokračovat v aktivní session bez ztráty potvrzených dat.

## Scope

- detekce aktivní session při bootstrapu,
- resume/recovery flow,
- recovery UI stav,
- načtení posledního potvrzeného výkonu,
- bezpečné zacházení s neúplným nebo nekonzistentním stavem,
- restart a recovery integration test.

## Evidence gate

- procesní restart je součástí automatického testu,
- potvrzené records se neztratí,
- nedokončený lokální UI input není vydáván za uložený,
- nekonzistentní stav má explicitní bezpečný failure path.

---

# 17. R1-06 – Complete Workout and History

## Výsledek

Uživatel dokončí workout a dokončená aktivita se objeví v lokální historii.

## Scope

- completion validation,
- atomické dokončení session,
- ActivitySummary,
- idempotentní opakování completion commandu,
- lokální history list a detail minimálního rozsahu,
- completion evidence tests.

## Evidence gate

- session, workout instance a ActivitySummary se změní v jedné transakci,
- opakované dokončení nevytvoří duplicitu,
- dokončený workout se zobrazí po restartu v historii,
- chyba uprostřed completion způsobí rollback.

---

# 18. R1-07 – Feedback, States and Accessibility

## Výsledek

Hlavní R1 flow má základní uživatelskou dokončenost a neskrývá failure stavy.

## Scope

- subjektivní náročnost a pocit po workoutu,
- viditelný stav lokálního uložení,
- loading, empty, error a recovery states,
- základní lokalizační struktura,
- základní accessibility labels, focus a text scaling kontrola,
- bezpečné potvrzovací dialogy.

## Evidence gate

- feedback je lokálně uložen a znovu načitelný,
- běžná chyba není prezentována jako úspěch,
- hlavní ovládací prvky mají srozumitelný accessibility význam,
- kritický tok je použitelný bez sítě.

---

# 19. R1-08 – Critical End-to-End Evidence

## Výsledek

Existuje automatizovaný důkaz hlavní hodnoty R1.

## Povinný scénář

1. aplikace startuje s lokálními demo daty,
2. uživatel otevře dnešní workout,
3. zahájí session,
4. zaznamená alespoň jeden výkon,
5. aplikace je ukončena a znovu spuštěna,
6. aktivní session se obnoví,
7. uživatel session dokončí,
8. workout se objeví v historii,
9. vše proběhne bez dostupného backendu a bez sítě.

## Evidence gate

- scénář je automatizovaný na podporovaném mobilním runtime,
- test je deterministický,
- používá skutečnou lokální persistence,
- failure artefakty umožňují diagnostiku,
- flaky výsledek se nepovažuje za zelený důkaz.

---

# 20. R1 Exit Review

R1 je dokončen pouze pokud:

- hlavní flow funguje v airplane mode,
- aktivní session přežije restart,
- potvrzený výkon se neztrácí,
- completion je atomická a idempotentní,
- historie obsahuje dokončený workout,
- běžné failure stavy jsou explicitní,
- critical-path testy, migration tests a CI gates jsou zelené,
- nevznikla závislost na účtu, sync, AI ani externím provideru.

R1 exit review musí odkazovat na konkrétní CI runy, testy a manuální platformní ověření požadované Definition of Done.

---

# 21. Doporučené backlog členění

Backlog položky mají používat stabilní označení:

```text
R0-01 ... R0-07
R1-01 ... R1-08
```

Každá položka má obsahovat:

- cíl,
- in-scope a out-of-scope,
- relevantní zdroje pravdy,
- dependencies,
- acceptance criteria,
- test approach,
- požadované evidence,
- dopad na dokumentaci a contracts.

Pokud je položka příliš velká pro jeden přehledný pull request, může být rozdělena na pod-položky, například `R1-04A`, `R1-04B`. Rozdělení nesmí rozbít ověřitelný výsledek ani přesunout testy do neurčité budoucnosti.

---

# 22. Paralelizace

Bezpečně paralelizovat lze zejména:

- R0-02 mobile bootstrap a R0-03 backend bootstrap po R0-01,
- část R0-04 OpenAPI kontraktu a R0-05 lokální infrastruktury,
- R1 UI komponenty a repository test utilities po stabilizaci jejich kontraktů.

Nelze bezpečně paralelizovat bez explicitní koordinace:

- schema a repository mapping,
- OpenAPI a implementační DTO,
- session state machine a persistence transakce,
- completion flow a ActivitySummary,
- CI gates a příkazy, které ještě nemají stabilní lokální podobu.

Paralelní práce nesmí vytvářet dva konkurenční zdroje pravdy.

---

# 23. Change control

Změna tohoto plánu je nutná, pokud:

- se mění pořadí kritických dependencies,
- vzniká nový blokující slice,
- mění se R0 nebo R1 exit criteria,
- implementace prokáže neplatnost důležitého předpokladu,
- je nutné přesunout položku mezi R0 a R1.

Běžné rozdělení backlog itemu, přejmenování technické pod-položky nebo zpřesnění testu nevyžaduje změnu plánu, pokud se nemění jeho význam a gate.

Scope R2 až R5 se do tohoto dokumentu nepřidává.

---

# 24. Pravidla VSP

- **VSP-001:** R0 a R1 se implementují v pořadí respektujícím dependencies uvedené v tomto plánu.
- **VSP-002:** Každý slice musí mít jeden ověřitelný výsledek a splnit Definition of Ready.
- **VSP-003:** Infrastruktura se vytváří pouze v rozsahu potřebném pro aktuální nebo bezprostředně následující slice.
- **VSP-004:** R0 nesmí zavádět workout, identity, sync ani AI produktové API.
- **VSP-005:** R1 musí být plně použitelné bez backendu a bez sítě.
- **VSP-006:** Schema, API nebo dependency změna musí předcházet implementaci, která ji používá.
- **VSP-007:** Každý slice musí dodat testy a evidence odpovídající jeho riziku.
- **VSP-008:** Kritické persistence operace R1 musí být atomické a recovery-testované.
- **VSP-009:** Potvrzený uživatelský výkon se nesmí ztratit při restartu nebo běžném pádu aplikace.
- **VSP-010:** Completion WorkoutSession musí být idempotentní.
- **VSP-011:** Paralelní práce nesmí vytvářet konkurenční kontrakty nebo repository struktury.
- **VSP-012:** R0 exit review je gate před produktovou implementací R1.
- **VSP-013:** R1 exit review vyžaduje automatizovaný offline restart/recovery end-to-end důkaz.
- **VSP-014:** Odložený scope R2 až R5 nesmí být zaveden bez nového Ready backlog itemu a příslušného kontraktu.
- **VSP-015:** Stav slice se nesmí označit jako Done bez dohledatelných test, CI a dokumentačních evidence.

---

# 25. Další krok

Po schválení tohoto plánu zbývá před zahájením programování vytvořit:

```text
docs/15-coding-agent/coding-agent-guide.md
```

Guide musí určit, jak coding agent načítá kontext, vybírá backlog item, ověřuje Ready stav, provádí změny, spouští testy, aktualizuje dokumentaci a dokládá skutečně provedené commity.