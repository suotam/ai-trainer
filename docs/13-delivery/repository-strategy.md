# AI Trainer – Repository Strategy

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/repository-strategy.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/data-architecture.md`, `docs/11-security/security-architecture.md`, `docs/10-integrations/integration-architecture.md`  
**Navazující dokumenty:** počáteční ADR balík, physical data model R1, API contract, test strategy, Definition of Ready and Done, vertical-slice implementation plan a coding-agent guide  
**Vlastněné pojmy nebo kontrakty:** monorepo layout, repository boundaries, source layout, dependency direction, shared contracts, migrations ownership, test placement, generated code policy, tooling boundaries a pravidla `RER-001` až `RER-015`

---

# 1. Účel

Tento dokument určuje skutečnou strukturu repozitáře AI Trainer pro startovní releasy `R0 – Technical Foundation` a `R1 – Local Workout Slice`.

Cílem je:

- vytvořit jednoznačné místo pro mobilní aplikaci, backend, kontrakty, tooling a dokumentaci,
- zabránit nekontrolovanému sdílení interních modelů mezi platformami,
- umožnit vývoj po vertikálních slices,
- zajistit, aby coding agent vždy věděl, kam změna patří,
- oddělit ručně psaný kód, generovaný kód, migrace, fixtures a build artefakty,
- umožnit pozdější rozšíření o sync, AI a integrace bez reorganizace celého projektu.

Tento dokument neurčuje finální frameworky, knihovny, databázový engine ani CI provider. Tyto volby patří do ADR.

---

# 2. Základní rozhodnutí

Projekt bude veden jako **monorepo**.

Monorepo obsahuje:

- mobilní Flutter aplikaci,
- backendovou aplikaci,
- explicitní veřejné kontrakty,
- databázové migrace,
- vývojové a CI nástroje,
- dokumentaci,
- později provider adaptéry a pomocné služby, pouze pokud pro ně vznikne skutečná potřeba.

Monorepo neznamená jeden společný aplikační model. Mobil, backend a contracts mají oddělené vlastnictví a dependency boundaries.

---

# 3. Kanonická kořenová struktura

```text
ai-trainer/
├── apps/
│   ├── mobile/
│   └── backend/
├── packages/
│   └── contracts/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── fixtures/
├── tooling/
│   ├── scripts/
│   ├── ci/
│   └── dev/
├── docs/
├── .github/
├── .editorconfig
├── .gitignore
├── README.md
└── compose.yaml
```

Adresáře se nevytvářejí pouze „do zásoby“. R0 vytvoří minimálně ty části, které jsou potřeba ke spuštění mobile, backendu, testů a lokálního prostředí.

---

# 4. `apps/mobile`

Mobilní aplikace je samostatná Flutter aplikace.

Doporučená struktura:

```text
apps/mobile/
├── lib/
│   ├── app/
│   ├── core/
│   ├── features/
│   └── shared/
├── test/
├── integration_test/
├── assets/
├── android/
├── ios/
└── pubspec.yaml
```

## 4.1 `app`

Obsahuje pouze composition root:

- spuštění aplikace,
- dependency composition,
- routing shell,
- globální theme,
- environment bootstrap,
- lifecycle wiring.

Nevlastní business logiku workoutu, profilu ani sync.

## 4.2 `core`

Obsahuje skutečně průřezové technické prvky:

- error model,
- clock a ID abstractions,
- lokální persistence infrastructure,
- network infrastructure,
- logging boundary,
- platform adapters,
- obecné test utilities.

`core` nesmí sloužit jako odkladiště business logiky.

## 4.3 `features`

Produktové chování je organizováno feature-first.

Pro R1 se očekává minimálně:

```text
features/
├── today/
├── workout_details/
├── workout_session/
└── workout_history/
```

Každá feature může obsahovat:

```text
feature_name/
├── domain/
├── application/
├── data/
└── presentation/
```

Vynechaná vrstva se nevytváří prázdná. Struktura musí odpovídat skutečné složitosti feature.

## 4.4 `shared`

Obsahuje znovupoužitelné prezentační komponenty a typy bez business ownershipu. Doménové entity nesmí být přesouvány do `shared` pouze proto, že je používá více obrazovek.

---

# 5. `apps/backend`

Backend je samostatná aplikace respektující modulární monolit z `backend-architecture.md`.

Doporučená logická struktura:

```text
apps/backend/
├── src/
│   ├── main/
│   └── test/
├── modules/
├── config/
└── build definition
```

Konkrétní fyzická podoba závisí na zvoleném jazyku a frameworku v ADR. Bez ohledu na technologii platí:

- modul vlastní své use cases a persistence access,
- cizí modul se neobchází přímým zápisem do jeho tabulek,
- veřejné rozhraní modulu je menší než jeho interní model,
- transportní DTO nejsou doménové entity,
- frameworkový kód nesmí určovat doménový význam.

Pro R0 může backend obsahovat pouze bootstrap, health endpoint a testovací infrastrukturu. R1 je lokální mobilní slice a nesmí být uměle závislý na backendu.

---

# 6. `packages/contracts`

Tento adresář vlastní explicitní kontrakty mezi procesy nebo platformami, nikoli interní business model.

Může obsahovat:

- OpenAPI specifikace,
- event schemas,
- sync schemas,
- AI tool schemas,
- generátor klientů,
- compatibility tests.

Pro R0 bude vytvořen pouze minimální skeleton, pokud jej vyžaduje health nebo testovací API. Pro R1 bez backendového toku není nutné vyrábět umělý workout API contract.

Mobil a backend nesmí sdílet zdrojové doménové třídy přes tento balík.

---

# 7. `database`

```text
database/
├── migrations/
├── seeds/
└── fixtures/
```

## 7.1 Migrations

- jsou verzované a append-only,
- každá má jednoznačné pořadí,
- nesmí být po použití v sdíleném prostředí přepisována,
- musí být testovatelná od prázdné databáze,
- vlastní je backend/data boundary, nikoli mobilní klient.

## 7.2 Seeds

Seeds slouží pro řízená referenční nebo vývojová data. Nesmí nahrazovat migrace ani test fixtures.

## 7.3 Fixtures

Fixtures jsou deterministická testovací data. Produkční secrets, reálné zdravotní údaje ani exporty uživatelů do repozitáře nepatří.

Mobilní lokální schema a jeho migrace zůstávají v `apps/mobile`, protože mají jiný lifecycle než serverová databáze.

---

# 8. `tooling`

Tooling je rozdělen podle účelu:

```text
tooling/
├── scripts/
├── ci/
└── dev/
```

- `scripts` obsahuje opakovatelné repository úlohy,
- `ci` obsahuje CI-specific pomocné soubory,
- `dev` obsahuje lokální bootstrap a development tooling.

Skript, který je nutný pro běžný build, musí fungovat stejně lokálně i v CI, nebo musí být rozdíl explicitně zdokumentovaný.

Skripty nesmí tiše měnit produkční data ani zapisovat secrets do souborů sledovaných Gitem.

---

# 9. Testovací umístění

Test má být co nejblíže k vlastnícímu kódu, ale testovací kontrakty napříč aplikacemi mají vlastní místo.

- mobile unit/widget tests: `apps/mobile/test`,
- mobile end-to-end tests: `apps/mobile/integration_test`,
- backend unit/integration tests: backendový test source set,
- contract compatibility tests: `packages/contracts`,
- repository smoke tests: `tooling` nebo CI workflow,
- provider fixtures později u integračního adaptéru nebo ve specializovaném fixture balíku.

Nesmí vzniknout jeden globální `tests/` adresář bez jasného ownershipu.

---

# 10. Dependency pravidla

Povolený obecný směr závislostí:

```text
presentation → application → domain
                         ↘ infrastructure adapters
```

Doména nesmí záviset na:

- UI frameworku,
- databázové knihovně,
- HTTP klientu,
- konkrétním AI provideru,
- konkrétním integration provideru.

Mobilní aplikace nesmí importovat backendové interní moduly. Backend nesmí importovat mobilní kód. Sdílený contracts balík nesmí obsahovat interní persistence entity.

Dependency cycle mezi feature nebo backend moduly je chyba návrhu a musí být odstraněn změnou hranice nebo explicitním kontraktem.

---

# 11. Generated code

Generovaný kód musí být:

- jednoznačně označený,
- reprodukovatelný jedním zdokumentovaným příkazem,
- oddělený od ručně psaného kódu,
- kontrolovaný na drift v CI.

Rozhodnutí, zda je konkrétní generated output commitovaný, patří do ADR nebo tooling policy. Nikdy se nesmí ručně opravovat pouze výsledný generated soubor bez opravy zdroje nebo generátoru.

Build artefakty, lokální databáze, credentials a IDE cache se necommitují.

---

# 12. Konfigurace a prostředí

Repozitář může obsahovat:

- bezpečné defaulty,
- příklady konfigurace,
- schema environment proměnných,
- lokální development composition.

Repozitář nesmí obsahovat:

- produkční secrets,
- skutečné OAuth credentials,
- signing keys,
- uživatelská data,
- exportované produkční databáze.

Konfigurace musí být oddělena od doménového kódu. Environment-specific rozdíl nesmí vyžadovat fork business logiky.

---

# 13. Branch a commit discipline

Výchozí integrační branch je `main`.

Každá změna má:

- malý a srozumitelný účel,
- odpovídající testy,
- aktualizovanou dokumentaci při změně kontraktu,
- žádné nesouvisející hromadné formátování,
- commit message popisující výsledný stav.

Velký slice se dělí na malé dokončitelné změny, ale mezistavy na `main` nesmí rozbíjet build nebo test baseline.

---

# 14. Ownership změn

Před změnou musí být určeno:

1. release slice,
2. vlastnící doména nebo technická oblast,
3. dotčený veřejný kontrakt,
4. potřebné migrace,
5. testovací úroveň,
6. dokumentace, kterou změna aktualizuje.

Nový top-level adresář vyžaduje aktualizaci tohoto dokumentu nebo přijaté ADR. Coding agent nesmí vytvářet paralelní strukturu pouze podle zvyklostí frameworku, pokud odporuje tomuto kontraktu.

---

# 15. R0 minimální repository baseline

R0 je dokončeno z pohledu repozitáře, když:

- existuje kanonická top-level struktura,
- mobile projekt lze spustit a otestovat,
- backend lze spustit a otestovat,
- lokální development prostředí má zdokumentovaný start,
- lint a format kontroly jsou automatizované,
- CI ověřuje minimálně build, lint a testy,
- secrets nejsou součástí repozitáře,
- existuje jeden root README s bootstrap postupem,
- build artefakty a lokální stav jsou správně ignorované.

---

# 16. R1 repository baseline

R1 je připraveno k implementaci, když:

- workout feature má jednoho vlastníka,
- lokální schema a migrace mají určené místo,
- demo/fixture data jsou oddělena od produkčního runtime,
- Today, workout detail, session a history nekomunikují přes skryté globální mutable state,
- unit, persistence a end-to-end testy mají jasné umístění,
- R1 nevyžaduje backend ani účet,
- pozdější sync lze doplnit přes explicitní repository nebo port boundary.

---

# 17. Závazná pravidla

## RER-001 – Monorepo

Mobile, backend, contracts, database, tooling a docs jsou spravovány v jednom repozitáři, dokud přijaté ADR neprokáže potřebu rozdělení.

## RER-002 – Oddělené aplikace

Mobil a backend jsou samostatné aplikace a nesmí sdílet interní zdrojové modely.

## RER-003 – Feature-first mobile

Mobilní produktové chování musí být organizováno podle features, nikoli pouze podle technických typů souborů.

## RER-004 – Modulární backend

Backendová struktura musí zachovat module ownership a nesmí umožnit obcházení aplikačních boundaries.

## RER-005 – Contracts nejsou shared domain

`packages/contracts` smí vlastnit pouze explicitní mezisystémové kontrakty, nikoli společný interní doménový model.

## RER-006 – Migrations jsou append-only

Použitá serverová migrace se nepřepisuje; oprava vzniká novou migrací nebo schváleným recovery postupem.

## RER-007 – Lokální schema patří mobilu

Mobilní persistence a její migrace mají lifecycle uvnitř mobilní aplikace a nesmí být zaměňovány se serverovými migracemi.

## RER-008 – Test ownership

Každý test má jednoznačného vlastníka a je umístěn u kódu nebo kontraktu, který ověřuje.

## RER-009 – Žádné dependency cycles

Cycle mezi moduly nebo features je architektonická chyba a nesmí být řešen globálním service locatorem nebo přesunem business logiky do shared.

## RER-010 – Reprodukovatelný generated code

Generovaný kód musí být reprodukovatelný, označený a kontrolovaný proti driftu.

## RER-011 – Žádné secrets a user data

Secrets, credentials a skutečná uživatelská data nesmí být commitnuta do repozitáře ani test fixtures.

## RER-012 – Vertical slice first

Struktura repozitáře musí podporovat spustitelné vertikální slices a nesmí podporovat dlouhé izolované budování vrstev bez uživatelského flow.

## RER-013 – R1 je lokální

První workout slice nesmí být blokován backendem, účtem, sync, AI ani integracemi.

## RER-014 – Nový top-level adresář je rozhodnutí

Nový top-level adresář vyžaduje zdokumentovaný účel a aktualizaci repository contractu nebo ADR.

## RER-015 – Změna kontraktu aktualizuje dokumentaci

Změna veřejného API, eventu, schema, repository boundary nebo build procesu musí ve stejném change setu aktualizovat vlastnící dokumentaci a testy.

---

# 18. Co ještě vyžaduje rozhodnutí

Před `IMPLEMENTATION_READY` pro R0/R1 je nutné přijmout alespoň:

- ADR pro backendový jazyk a framework,
- ADR pro mobilní state management a dependency injection,
- ADR pro lokální mobilní databázi,
- ADR pro serverovou databázi a migrace,
- ADR pro contract formát a code generation,
- ADR pro CI a development environment,
- minimální test strategy.

Konkrétní názvy package, module namespace a build příkazy se doplní po těchto ADR bez oslabení pravidel tohoto dokumentu.