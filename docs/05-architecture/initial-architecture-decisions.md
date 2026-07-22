# AI Trainer – Initial Architecture Decisions

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/05-architecture/initial-architecture-decisions.md`  
**Vlastník:** Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/data-architecture.md`, `docs/13-delivery/repository-strategy.md`  
**Navazující dokumenty:** physical data model R1, minimal API contract, test strategy, Definition of Ready and Done, vertical-slice implementation plan a coding-agent guide  
**Vlastněné pojmy nebo kontrakty:** počáteční technologická rozhodnutí pro R0 a R1, jejich stav, důvody, důsledky a pravidla `ADR-001` až `ADR-010`

---

# 1. Účel

Tento dokument přijímá pouze ta technologická rozhodnutí, která jsou nutná pro zahájení `R0 – Technical Foundation` a `R1 – Local Workout Slice`.

Nejde o úplný katalog budoucích rozhodnutí. Konkrétní technologie pro identity, cloudový sync, generativní AI, externí integrace, produkční observabilitu a škálování se rozhodnou nejpozději před slicem, který je skutečně potřebuje.

Každé rozhodnutí obsahuje:

- stav,
- kontext,
- rozhodnutí,
- důvody,
- důsledky,
- podmínky přehodnocení.

Stavy:

- **ACCEPTED** – závazné pro implementaci,
- **PROVISIONAL** – použitelné pro start, ale vyžaduje ověření,
- **DEFERRED** – záměrně odloženo,
- **SUPERSEDED** – nahrazeno novým ADR.

---

# 2. ADR-001 – Flutter jako mobilní platforma

**Stav:** ACCEPTED

## Kontext

Produkt musí podporovat Android a iOS z jednoho sdíleného kódu, zachovat kvalitní offline chování a umožnit rychlý vývoj mobilních vertikálních slices.

## Rozhodnutí

Mobilní aplikace bude implementována ve Flutteru a jazyce Dart.

## Důvody

- jedna hlavní codebase pro Android a iOS,
- vhodné prostředí pro feature-first architekturu,
- dobrá podpora lokální persistence a offline-first toku,
- rychlá iterace UI a widget testy,
- již potvrzeno v mobile architecture a repository strategy.

## Důsledky

- platformně specifický kód bude izolován za adapters,
- doména nesmí záviset na Flutter widgetech,
- Android a iOS build musí být ověřován od R0.

## Přehodnocení

Pouze pokud se ukáže zásadní nepřekonatelná platformní překážka potvrzená prototypem.

---

# 3. ADR-002 – Riverpod pro state management a dependency composition

**Stav:** ACCEPTED

## Kontext

R1 potřebuje předvídatelný stav workout session, dependency composition, testovatelnost a oddělení presentation od application vrstvy bez těžkého service locatoru.

## Rozhodnutí

Mobilní state management a dependency composition budou používat Riverpod.

## Důvody

- explicitní dependency graph,
- dobrá testovatelnost providerů,
- podpora synchronního i asynchronního stavu,
- vhodné pro feature-first uspořádání,
- omezuje globální mutable singletony.

## Důsledky

- provider není doménový objekt,
- business pravidla zůstávají v domain/application vrstvě,
- Riverpod typy nesmí pronikat do persistence modelu ani veřejných kontraktů,
- generování kódu je možné, ale není povinné pro R0.

## Přehodnocení

Po R1 pouze při doloženém problému s testovatelností, výkonem nebo maintainability.

---

# 4. ADR-003 – GoRouter pro navigaci

**Stav:** ACCEPTED

## Kontext

Aplikace potřebuje deklarativní routing, deep links z notifikací v pozdějších slices a testovatelnou navigaci mezi Today, detailem workoutu, aktivní session a historií.

## Rozhodnutí

Mobilní navigace bude používat GoRouter.

## Důvody

- deklarativní routing,
- podpora nested routes a deep links,
- vhodné napojení na Flutter,
- jasná route konfigurace v composition root.

## Důsledky

- route names a paths musí být centralizované,
- feature nesmí navigovat přes neřízené globální klíče,
- autorizace a business validace nesmí být nahrazena route guardem.

## Přehodnocení

Pokud R1 prokáže zásadní omezení pro obnovu aktivní workout session nebo nested navigation.

---

# 5. ADR-004 – Drift a SQLite pro lokální mobilní persistence

**Stav:** ACCEPTED

## Kontext

R1 musí fungovat bez backendu a bez sítě. Potřebuje transakční lokální databázi, migrace, typované dotazy a bezpečné zachování aktivní workout session.

## Rozhodnutí

Lokální mobilní databáze bude SQLite přístupná přes Drift.

## Důvody

- relační model odpovídá workout datům a historii,
- transakce a constraints,
- explicitní schema a migrace,
- typované dotazy,
- vhodné pro offline-first a pozdější sync metadata.

## Důsledky

- lokální schema má vlastní lifecycle v `apps/mobile`,
- persistence DTO nejsou doménové entity,
- každá změna schématu musí mít migraci a test,
- aktivní session a pending lokální změny nesmí být migrací ztraceny.

## Přehodnocení

Pouze pokud prototyp prokáže zásadní problém s podporovanými platformami nebo migracemi.

---

# 6. ADR-005 – Kotlin a Spring Boot pro backend

**Stav:** ACCEPTED

## Kontext

R0 vyžaduje spustitelný backend, health endpoint, testovací základ a budoucí modulární monolit s transakcemi, background jobs, API a integracemi.

## Rozhodnutí

Backend bude implementován v Kotlinu na Spring Bootu.

## Důvody

- silné typování a null-safety,
- zralý ekosystém pro REST, validaci, security, persistence a testy,
- vhodné prostředí pro modulární monolit,
- dobrá interoperabilita s JVM knihovnami,
- zkušenost týmu s Kotlin/Spring stackem.

## Důsledky

- doménový model nesmí být tvořen JPA anotacemi jako zdrojem významu,
- Spring komponenty zůstávají v application/infrastructure hranicích,
- modulární hranice budou ověřovány testy,
- R1 nesmí být uměle závislý na backendu.

## Přehodnocení

Pouze před významnou backendovou implementací, pokud R0 prokáže zásadní provozní nebo vývojovou překážku.

---

# 7. ADR-006 – PostgreSQL a Flyway pro serverová data

**Stav:** ACCEPTED

## Kontext

Budoucí R2 potřebuje transakční autoritativní databázi, constraints, auditovatelnou historii a verzované migrace. R0 potřebuje pouze připravit konzistentní lokální prostředí.

## Rozhodnutí

Serverová relační databáze bude PostgreSQL a migrace bude spravovat Flyway.

## Důvody

- silné transakční vlastnosti,
- constraints a relační integrita,
- JSON podpora pro omezené vhodné případy,
- zralé provozní a backup možnosti,
- append-only verzované migrace přes Flyway.

## Důsledky

- schema vzniká výhradně přes migrace,
- automatické produkční schema generation je zakázáno,
- migrace musí projít testem od prázdné databáze,
- konkrétní tabulky pro R1 budou popsány samostatným physical-data dokumentem; R1 samotný používá lokální SQLite.

## Přehodnocení

Pouze při potvrzeném zásadním omezení před R2.

---

# 8. ADR-007 – OpenAPI jako zdroj HTTP kontraktu

**Stav:** ACCEPTED

## Kontext

Mobil a backend nesmí sdílet interní doménové třídy. Budoucí HTTP komunikace potřebuje explicitní, verzovatelný a testovatelný kontrakt.

## Rozhodnutí

Veřejné HTTP API bude specifikováno pomocí OpenAPI v `packages/contracts`.

## Důvody

- jazykově nezávislý kontrakt,
- možnost generovat klientské DTO a klienty,
- compatibility a contract testy,
- oddělení transportu od interní domény.

## Důsledky

- OpenAPI není zdrojem doménového významu,
- změna kontraktu musí být reviewovaná a verzovatelná,
- generated output se nesmí ručně opravovat,
- pro R0 vznikne pouze minimální health contract; R1 nepotřebuje workout API.

## Přehodnocení

Při doloženém problému s code generation nebo kompatibilitou; princip explicitního kontraktu zůstává.

---

# 9. ADR-008 – Docker Compose pro lokální infrastrukturu

**Stav:** ACCEPTED

## Kontext

R0 musí umožnit opakovatelně spustit backend a PostgreSQL bez ručního nastavování lokálních služeb.

## Rozhodnutí

Lokální infrastrukturní závislosti budou spouštěny přes `compose.yaml`.

## Důvody

- jednoduchý onboarding,
- opakovatelné verze služeb,
- izolace lokální databáze,
- shoda lokálního a CI prostředí tam, kde je praktická.

## Důsledky

- secrets se necommitují do Compose souboru,
- safe development defaults mohou být v repozitáři,
- aplikace samotné mohou být při vývoji spouštěny mimo kontejnery,
- Compose není automaticky produkční deployment strategie.

## Přehodnocení

Pokud lokální vývoj prokáže, že jiný nástroj významně zjednoduší stejný kontrakt bez vendor lock-in.

---

# 10. ADR-009 – GitHub Actions jako počáteční CI

**Stav:** ACCEPTED

## Kontext

Repozitář je hostovaný na GitHubu a R0 potřebuje automatické ověření formátování, statické analýzy, testů a buildů.

## Rozhodnutí

Počáteční CI bude implementováno pomocí GitHub Actions.

## Důvody

- přímá integrace s repozitářem,
- vhodné pro mobile i JVM buildy,
- jednoduché pull-request gates,
- podpora cache a service containers.

## Důsledky

- build příkazy musí být dostupné i lokálně přes repository tooling,
- workflow nesmí obsahovat produkční secrets v plaintextu,
- R0 musí ověřit minimálně mobile analyze/test/build a backend test/build,
- konkrétní release pipeline vznikne později.

## Přehodnocení

Při zásadním provozním, cenovém nebo compliance omezení.

---

# 11. ADR-010 – Testovací základ pro R0 a R1

**Stav:** ACCEPTED

## Kontext

Technologická rozhodnutí nejsou dostatečná bez minimálního způsobu ověření. Podrobnou strategii bude vlastnit samostatný test strategy dokument.

## Rozhodnutí

Startovní baseline bude používat:

- Flutter unit a widget tests,
- Flutter integration tests pro hlavní R1 flow,
- Kotlin unit tests,
- Spring Boot integration tests,
- Testcontainers pro backendovou databázovou integraci,
- repository smoke checks v CI.

## Důvody

- testy odpovídají vlastníkům kódu,
- reálná PostgreSQL kompatibilita bez in-memory náhražky,
- možnost ověřit end-to-end lokální workout flow,
- rychlá zpětná vazba v R0.

## Důsledky

- testy nesmí záviset na sdíleném vývojovém prostředí,
- čas, IDs a persistence musí být testovatelně abstrahované,
- R1 musí mít restart/recovery a migration testy,
- přesné coverage a release gates stanoví test strategy.

## Přehodnocení

Při tvorbě test strategy lze nástroje zpřesnit, ale nesmí se oslabit požadovaná úroveň ověření.

---

# 12. Záměrně odložená rozhodnutí

Před R0 a R1 se nevybírá:

- identity provider,
- token a session mechanismus,
- cloud provider a produkční deployment platforma,
- message broker,
- cache server,
- AI model provider,
- vector database,
- analytics provider,
- push notification provider,
- konkrétní wearable nebo calendar provider,
- produkční secrets manager.

Tyto volby nesmí být zavedeny do kódu pouze „do zásoby“.

---

# 13. Implementační baseline R0

R0 vytvoří minimálně:

- Flutter aplikaci v `apps/mobile`,
- Kotlin/Spring Boot aplikaci v `apps/backend`,
- minimální `packages/contracts`,
- PostgreSQL ve `compose.yaml`,
- Flyway bootstrap,
- backend health endpoint,
- GitHub Actions workflow,
- společné formátovací a lint příkazy,
- smoke test mobilního a backendového buildu.

R0 nevytváří business tabulky ani umělé abstrakce pro R2 až R5.

---

# 14. Implementační baseline R1

R1 používá:

- Flutter + Riverpod + GoRouter,
- Drift + SQLite,
- lokální demo data a migrace,
- žádnou povinnou backendovou komunikaci,
- automatizovaný hlavní flow test:
  - otevřít Today,
  - otevřít workout,
  - zahájit session,
  - zapsat výkon,
  - dokončit workout,
  - restartovat aplikaci,
  - ověřit zachovaný výsledek a historii.

---

# 15. Závazná pravidla

## ADR-001

Mobilní klient pro R0 a R1 MUSÍ používat Flutter a Dart.

## ADR-002

Mobilní stav a dependency composition MUSÍ používat Riverpod; business logika NESMÍ být vlastněna providerem.

## ADR-003

Navigace MUSÍ používat GoRouter a route guard NESMÍ nahrazovat doménovou autorizaci.

## ADR-004

Lokální persistence R1 MUSÍ používat Drift nad SQLite a každá změna schématu MUSÍ mít testovanou migraci.

## ADR-005

Backend R0 MUSÍ používat Kotlin a Spring Boot a MUSÍ respektovat modular-monolith boundaries.

## ADR-006

Serverová databáze MUSÍ být PostgreSQL a změny schématu MUSÍ probíhat přes Flyway.

## ADR-007

HTTP kontrakty MUSÍ mít explicitní OpenAPI zdroj pravdy a NESMÍ sdílet interní doménové třídy.

## ADR-008

Lokální infrastrukturní závislosti MUSÍ být spustitelné přes Docker Compose bez commitovaných secrets.

## ADR-009

R0 CI MUSÍ používat GitHub Actions a ověřit mobile i backend build a test.

## ADR-010

R1 MUSÍ mít automatizovaný restart/recovery test hlavního lokálního workout flow.

---

# 16. Připravenost a další krok

Po přijetí tohoto balíku jsou hlavní technologie pro R0 a R1 rozhodnuté.

Další blokující dokument je:

```text
docs/12-data/r1-physical-data-model.md
```

Ten musí konkretizovat pouze lokální mobilní schema a minimální serverový bootstrap potřebný pro R0/R1, nikoli celé budoucí produkční schéma.