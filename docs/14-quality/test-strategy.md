# AI Trainer – Test Strategy

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/14-quality/test-strategy.md`  
**Vlastník:** Quality Engineering  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/07-backend/r0-api-contract.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/r1-physical-data-model.md`, `docs/13-delivery/repository-strategy.md`  
**Navazující dokumenty:** Definition of Ready and Done, vertical-slice implementation plan, CI workflows, release strategy, security testing, AI evaluation a operations evidence  
**Vlastněné pojmy nebo kontrakty:** test levels, test ownership, critical-path verification, CI quality gates, flaky-test policy, coverage interpretation, release evidence a pravidla `QTR-001` až `QTR-015`

---

# 1. Účel

Tento dokument definuje způsob, jakým AI Trainer ověřuje správnost, bezpečnost a spolehlivost implementace.

Cílem není maximalizovat počet testů ani procento coverage. Cílem je vytvořit důvěryhodný a opakovatelný důkaz, že:

- implementace odpovídá schváleným produktovým a technickým kontraktům,
- kritické R0 a R1 scénáře fungují v reálném prostředí,
- doménové invariance nelze obejít,
- potvrzená lokální data se neztrácejí,
- API implementace odpovídá OpenAPI,
- migrace jsou bezpečné a reprodukovatelné,
- chyba je zachycena co nejblíže místu svého vzniku,
- CI neposkytuje falešný pocit bezpečí.

Tento dokument vlastní strategii, test levels, ownership a quality gates. Konkrétní test cases vlastní příslušný produktový, doménový, datový nebo API kontrakt.

---

# 2. Základní principy

## 2.1 Testujeme pozorovatelné chování a kontrakty

Test má ověřovat zejména:

- veřejné chování use case,
- stavové přechody,
- invariance,
- persistence výsledky,
- transportní kontrakt,
- recovery a failure behavior.

Test nesmí být zbytečně svázaný s interní strukturou třídy, pořadím privátních metod nebo frameworkovým detailem, který není součástí kontraktu.

## 2.2 Nejnižší smysluplná úroveň

Chování se testuje na nejnižší úrovni, která poskytuje dostatečnou důvěru:

- čisté pravidlo jako unit test,
- repository mapping jako integration test,
- OpenAPI kompatibilita jako contract test,
- hlavní uživatelský tok jako omezený end-to-end test.

Stejný detail se nemá duplikovat na všech úrovních.

## 2.3 Kritické flow má více vrstev ochrany

Kritický tok může mít:

- unit test doménového pravidla,
- persistence integration test,
- UI nebo API integration test,
- jeden end-to-end smoke test.

Tato redundance je oprávněná pouze u chování, jehož selhání znamená ztrátu dat, porušení bezpečnosti nebo nefunkční hlavní hodnotu produktu.

## 2.4 Determinismus

Automatizovaný test musí být opakovatelný.

Čas, náhodná ID, filesystem, síť, databáze a platformní služby musí být řízené nebo izolované tak, aby test nepadal náhodně.

## 2.5 Produkční podobnost podle rizika

Čím vyšší riziko technologického rozdílu, tím více se testovací prostředí musí podobat skutečnému prostředí.

Proto:

- PostgreSQL integrace používá PostgreSQL přes Testcontainers,
- lokální persistence používá skutečné SQLite/Drift schema,
- migrace se netestují pouze mockem,
- HTTP kontrakt se ověřuje proti skutečné serializaci.

---

# 3. Testovací vrstvy

Projekt používá následující vrstvy:

1. static checks,
2. unit tests,
3. component a widget tests,
4. integration tests,
5. contract tests,
6. migration a recovery tests,
7. architecture tests,
8. end-to-end tests,
9. exploratory a odborné review.

Ne všechny vrstvy jsou povinné pro každou změnu.

---

# 4. Static checks

Static checks jsou nejrychlejší quality gate.

Pro mobil zahrnují minimálně:

- `dart format` kontrolu,
- `flutter analyze`,
- kontrolu generated-code driftu, pokud se generation používá,
- zákaz zakázaných dependency směrů, pokud je automatizovatelný.

Pro backend zahrnují minimálně:

- Kotlin formátování,
- kompilaci,
- statickou analýzu,
- kontrolu dependency nebo module boundary pravidel,
- validaci konfiguračních souborů.

Pro contracts a repository zahrnují:

- validaci OpenAPI,
- validaci YAML/JSON schemas,
- kontrolu necommitovaných generated změn,
- secret scanning,
- ověření základní repository struktury.

Static check nesmí nahrazovat behaviorální test.

---

# 5. Unit tests

## 5.1 Účel

Unit test ověřuje malé chování bez skutečné databáze, HTTP serveru nebo platformního runtime.

Typické cíle:

- value objects,
- stavové přechody,
- doménové invariance,
- validační pravidla,
- čisté výpočty,
- application orchestrace s fake ports,
- error mapping bez transportu.

## 5.2 Mobilní unit tests

Pro R1 musí pokrýt zejména:

- povolené a zakázané přechody WorkoutSession,
- oddělení plánovaných a skutečných hodnot,
- validaci set performance,
- dokončení povinných a volitelných kroků,
- idempotentní application command chování,
- mapování persistence DTO na doménové objekty,
- recovery rozhodnutí bez závislosti na widgetech.

## 5.3 Backendové unit tests

Pro R0 musí pokrýt zejména:

- readiness rozhodnutí nad výsledky dependency checks,
- bezpečné mapování interní chyby na error code,
- request ID validaci a generování,
- version a timestamp mapping,
- oddělení liveness od readiness.

## 5.4 Co do unit testu nepatří

- mockování ORM do takové míry, že se netestuje skutečné SQL chování,
- testování frameworkových getterů,
- ověřování počtu interních volání bez kontraktního významu,
- kopírování implementačního algoritmu do expected části testu.

---

# 6. Component a widget tests

Flutter widget test ověřuje UI komponentu nebo omezené feature flow bez plného zařízení.

Pro R1 se používá zejména pro:

- Today přehled,
- workout detail,
- zahájení session,
- zápis série,
- stav dokončení kroku,
- potvrzovací dialog dokončení,
- recovery banner nebo resume flow,
- error a empty states.

Widget test má ověřovat uživatelsky pozorovatelné prvky, nikoli přesnou interní hierarchii widgetů.

Golden testy nejsou povinným R0/R1 gate. Mohou vzniknout později pro stabilní design-system komponenty.

---

# 7. Integration tests

## 7.1 Mobilní persistence integration tests

Používají skutečné Drift schema nad izolovanou SQLite databází.

Povinně ověřují:

- vytvoření databáze od prázdného stavu,
- seed demo workoutu,
- uložení a načtení WorkoutInstance snapshotu,
- atomický start session,
- průběžný zápis výkonu,
- restart a obnovení aktivní session,
- atomické dokončení session a ActivitySummary,
- idempotentní opakování dokončení,
- foreign keys a unique constraints,
- rollback celé transakce při selhání jedné části.

## 7.2 Backend integration tests

Používají Spring Boot test context a skutečný PostgreSQL přes Testcontainers, pokud je databáze součástí ověřovaného scénáře.

Pro R0 povinně ověřují:

- application bootstrap,
- liveness při dostupné i nedostupné databázi,
- readiness při dostupné databázi a validním schema stavu,
- readiness 503 při nedostupné povinné dependency,
- bezpečný error envelope,
- response headers včetně `X-Request-Id` a `Cache-Control`,
- absenci interních detailů v response.

In-memory databáze není náhradou za PostgreSQL integration test.

---

# 8. Contract tests

## 8.1 OpenAPI contract

Kanonický OpenAPI soubor musí být validní a implementace s ním kompatibilní.

R0 contract test ověřuje minimálně:

- existenci obou health endpointů,
- podporované status codes,
- povinná response pole,
- datové typy a enum hodnoty,
- standardní error envelope,
- content type,
- nepřítomnost nezdokumentovaného breaking chování.

## 8.2 Contract ownership

- transportní schema vlastní OpenAPI,
- doménový význam vlastní doménové dokumenty,
- konkrétní persistence schema vlastní datový kontrakt,
- test strategy vlastní způsob ověření.

Contract test nesmí vytvořit druhou ručně udržovanou kopii stejného schema.

## 8.3 Budoucí compatibility tests

Při vzniku generated klientů musí CI ověřovat:

- reprodukovatelnost generation,
- žádný necommitovaný drift, pokud se output commituje,
- kompatibilitu podporované mobilní verze s API kontraktem,
- explicitní klasifikaci breaking změn.

---

# 9. Migration tests

## 9.1 Mobilní migrace

Každá změna Drift schema musí mít test:

- vytvoření nové databáze,
- migrace z každé stále podporované verze,
- zachování potvrzených workout dat,
- zachování nebo bezpečné obnovení aktivní session,
- zachování foreign-key integrity,
- odmítnutí nebo řízené řešení neplatného starého stavu.

## 9.2 Serverové migrace

Každá Flyway změna musí ověřit:

- migraci od prázdné PostgreSQL databáze,
- pořadí a checksum konzistenci,
- opakovatelný application startup po aplikaci migrací,
- kompatibilitu se současnou persistence implementací.

Destruktivní migrace vyžaduje samostatné review a rollback nebo recovery plán.

## 9.3 Migrace nejsou běžný unit test

Migration test musí pracovat se skutečným databázovým enginem a reálným schema stavem.

---

# 10. Architecture tests

Architecture test automatizuje pravidla, jejichž porušení by jinak bylo snadné přehlédnout.

Pro backend má postupně ověřovat:

- modul nesahá do interních vrstev jiného modulu,
- domain layer nezávisí na Springu, ORM ani transportu,
- controller neobsahuje doménové rozhodnutí,
- zakázané cycles mezi moduly.

Pro mobil má postupně ověřovat:

- domain vrstva nezávisí na Flutter presentation,
- feature nepřistupuje přímo do tabulek jiné feature bez vlastněného repository kontraktu,
- UI neobchází application use case přímým zápisem do DB,
- zakázané cycles mezi feature balíky.

R0 může začít minimálním smoke pravidlem. Pokrytí se rozšiřuje spolu se skutečnou strukturou, nikoli vytvářením prázdných testů.

---

# 11. End-to-end testy

End-to-end test ověřuje jen omezený počet nejdůležitějších toků. Nesmí být hlavní náhradou unit a integration testů.

## 11.1 R0 critical path

Automatizovaný R0 smoke test musí prokázat:

1. lokální infrastruktura se spustí,
2. backend se sestaví a nastartuje,
3. Flyway doběhne,
4. liveness vrátí 200,
5. readiness vrátí 200,
6. odpověď odpovídá OpenAPI,
7. po nedostupnosti databáze readiness přejde na 503 bez úniku interních detailů.

## 11.2 R1 critical path

Automatizovaný mobilní integration test musí prokázat:

1. aplikace načte seed workout,
2. uživatel otevře dnešní workout,
3. spustí WorkoutSession,
4. zapíše minimálně jednu skutečnou hodnotu,
5. aplikace je ukončena nebo simuluje restart,
6. aktivní session je obnovena,
7. uživatel workout dokončí,
8. vznikne historický ActivitySummary,
9. dokončená data zůstanou dostupná po dalším restartu.

Tento tok nesmí vyžadovat backend ani internet.

## 11.3 Omezení E2E

- E2E test nesmí testovat všechny validační kombinace,
- nesmí záviset na produkčních službách,
- musí používat deterministická fixtures,
- neúspěch musí produkovat diagnostické artefakty bez secrets.

---

# 12. Manuální, exploratory a odborné testování

Automatizace nepokrývá vše.

Před označením R1 za použitelný proběhne minimálně:

- exploratory průchod na fyzickém Android zařízení,
- ověření základního iOS buildu a spuštění,
- práce s aplikací v airplane mode,
- ukončení aplikace během aktivní session,
- ověření čitelnosti a základní accessibility,
- ověření dlouhých názvů a lokalizovaného textu,
- ověření chování při plném nebo chybujícím storage podle možností platformy.

Medicínská, sportovní a bezpečnostní správnost pozdějších doporučení vyžaduje odborné review. Automatický test ji sám nepotvrzuje.

---

# 13. Test data a fixtures

Test data musí být:

- syntetická,
- deterministická,
- minimální,
- čitelná,
- verzovaná spolu s kontraktem, který ověřují.

Do test fixtures nesmí patřit:

- reálné uživatelské exporty,
- produkční osobní nebo zdravotní data,
- skutečné tokens a credentials,
- tajné provider payloady.

Fixture builder může zjednodušit common setup, ale nesmí skrýt důležité hodnoty relevantní pro test.

---

# 14. Test doubles

Používají se podle typu hranice:

- fake pro jednoduchý deterministický port,
- stub pro řízenou odpověď,
- mock pouze tam, kde je významné ověřit interakční kontrakt,
- emulator nebo container pro technologické chování,
- skutečná implementace pro databáze a serializaci, kde mock nedává důvěru.

Nadměrné mockování je varovný signál příliš provázané architektury.

Externí AI a provider SDK se před jejich slicem netestují ani nezavádějí „do zásoby“.

---

# 15. CI quality gates

## 15.1 Pull request gate

Každá změna relevantní pro R0/R1 musí před merge projít:

- formátováním a static analysis,
- unit testy dotčených aplikací,
- relevantní integration testy,
- contract validací při změně contracts,
- migration testy při změně schema,
- buildem dotčené aplikace,
- repository smoke checks,
- kontrolou secrets.

Gate musí být povinný a nesmí být obcházen opakovaným rerunem bez pochopení příčiny.

## 15.2 Main branch gate

Na `main` musí proběhnout širší sada:

- mobile unit a widget tests,
- backend unit a integration tests,
- OpenAPI contract tests,
- supported migration tests,
- R0 smoke test,
- R1 critical-path integration test, jakmile existuje,
- build Android artefaktu,
- iOS build ověření v dostupném macOS runneru nebo řízeném release procesu.

## 15.3 Release candidate gate

Před označením slice za dokončený musí existovat:

- zelený commit na `main`,
- odkaz na CI run,
- seznam splněných exit criteria,
- známé odchylky a rizika,
- výsledky manuálního nebo exploratory ověření,
- potvrzení, že nejsou ignorované kritické flaky testy.

---

# 16. Flaky-test policy

Flaky test je test, který při nezměněném kódu nedeterministicky prochází a padá.

Flaky test:

- není považován za zelený důkaz,
- nesmí být normalizován opakovaným rerunem,
- musí mít evidovanou příčinu nebo investigation task,
- může být dočasně karantenizován pouze s vlastníkem a termínem nápravy,
- kritický test R0/R1 nesmí být tiše vypnut.

Povolené dočasné řešení musí obsahovat:

- odkaz na issue,
- ownera,
- důvod,
- datum nebo podmínku odstranění karantény,
- náhradní způsob ověření.

---

# 17. Coverage interpretace

Coverage je diagnostická metrika, nikoli důkaz správnosti.

Projekt nepoužívá jedno globální procento jako jediný merge gate.

Vyžaduje se:

- vysoká důvěra v kritické doménové větvení,
- test každé opravené regresní chyby,
- test významného stavového přechodu,
- test každé persistence transakční hranice,
- test každého deklarovaného API status code a schema varianty,
- vysvětlení netestovaného rizikového kódu.

Pokles coverage v kritickém modulu je review signal. Zvýšení coverage pomocí bezvýznamných getter testů není cílem.

---

# 18. Selhání testu a diagnostika

Neúspěšný test musí poskytnout dost informací k reprodukci:

- test name a vlastněný kontrakt,
- expected a actual výsledek,
- relevantní seed nebo fixture ID,
- bezpečně redigované logy,
- u UI testu screenshot nebo trace, pokud je dostupný,
- u migration testu výchozí a cílovou schema verzi,
- u API testu request ID a response bez secrets.

Test log nesmí obsahovat tokens, hesla ani reálná osobní data.

---

# 19. Performance a reliability baseline

R0/R1 nepotřebují samostatnou rozsáhlou performance test suite, ale musí chránit základní použitelnost.

Ověřuje se minimálně:

- startup bez zjevného blokování hlavního UI,
- otevření lokálního workoutu bez síťové dependency,
- průběžný zápis výkonu bez viditelné ztráty dat,
- readiness s bounded timeoutem,
- žádné neomezené retry smyčky,
- databázové operace nepadají na běžném R1 fixture objemu.

Přesné SLO a load testy vzniknou před produkčním releasem nebo při potvrzeném riziku.

---

# 20. Security testing baseline

R0/R1 testy musí minimálně ověřovat:

- žádné secrets v repozitáři a fixtures,
- error response bez stack traces a interních detailů,
- request ID neobsahuje citlivé údaje,
- health endpointy nemění stav,
- lokální DB není omylem součástí Git artefaktů,
- logování neobsahuje celý citlivý payload,
- dependency a secret scanning v CI.

Kompletní threat-model-driven security test plán vznikne před chráněnými produkčními flows.

---

# 21. Ownership

Test vlastní stejný tým nebo modul jako testované chování.

- mobile feature testy vlastní příslušná feature,
- mobile DB a migration testy vlastní persistence boundary,
- backend module testy vlastní backendový modul,
- OpenAPI contract testy vlastní contracts boundary,
- repository smoke checks vlastní delivery/tooling,
- cross-application critical path vlastní release slice.

Quality Engineering vlastní strategii, gates, reporting a audit, nikoliv všechen testovací kód.

Test bez vlastníka je neudržovaný artefakt.

---

# 22. Traceability a release evidence

Každý kritický R0/R1 acceptance bod musí být dohledatelný k jednomu nebo více důkazům:

```text
requirement / invariant / contract
        ↓
acceptance criterion
        ↓
automatizovaný test nebo explicitní review
        ↓
CI run / evidence
```

Před dokončením slice se eviduje minimálně:

- commit SHA,
- CI run,
- test suite výsledky,
- migration evidence, pokud relevantní,
- build artefakt nebo build potvrzení,
- manuální ověření referenční platformy,
- známé otevřené riziko.

Screenshot sám není důkazem doménové správnosti.

---

# 23. Definition of test-ready změny

Změna je připravená k implementaci testů, pokud má:

- vlastnící dokument nebo kontrakt,
- jasné pozorovatelné chování,
- známé failure modes,
- definované test data,
- určenou nejnižší vhodnou testovací úroveň,
- identifikované kritické hrany,
- vyřešenou testovatelnost času, ID a dependencies.

Podrobnou Definition of Ready a Done vlastní následující delivery dokument.

---

# 24. R0 quality gate

R0 je z pohledu testování dokončen pouze pokud:

1. mobile i backend projekty se sestaví,
2. static checks jsou zelené,
3. backend unit a integration testy projdou,
4. PostgreSQL test používá Testcontainers nebo ekvivalent skutečného engine,
5. OpenAPI je validní a contract test projde,
6. liveness a readiness jsou ověřeny v success i failure režimu,
7. Flyway migrace projdou od prázdné DB,
8. repository smoke checks projdou,
9. CI je povinný gate,
10. není známý neřešený kritický flaky test.

---

# 25. R1 quality gate

R1 je z pohledu testování dokončen pouze pokud:

1. doménové session transitions mají unit testy,
2. Drift schema vznikne od prázdné DB,
3. supported migrations projdou,
4. start session je atomický,
5. potvrzený výkon přežije restart,
6. aktivní session lze obnovit,
7. dokončení je atomické a idempotentní,
8. ActivitySummary je rekonstruovatelný,
9. hlavní R1 flow projde integration testem,
10. flow je ručně ověřeno offline na referenčním Android zařízení,
11. iOS build projde,
12. není známá chyba způsobující ztrátu potvrzených dat.

---

# 26. Záměrně odložené testovací oblasti

Před R0/R1 se nevytváří plná suite pro:

- identity a session security,
- multi-device sync,
- AI quality a safety evaluation,
- provider adapters,
- push notifications,
- wearables,
- produkční load a chaos testing,
- disaster recovery,
- SLO alerting.

Tyto oblasti musí mít strategii nejpozději před implementací nebo releasem slice, který je používá.

---

# 27. Závazná pravidla

## QTR-001

Každé kritické chování musí mít automatizovaný test nebo explicitně zdokumentovaný důvod odborného či manuálního ověření.

## QTR-002

Test se píše na nejnižší smysluplné úrovni poskytující dostatečnou důvěru.

## QTR-003

Doménové invariance a významné stavové přechody musí být ověřeny bez závislosti na UI nebo síti.

## QTR-004

Databázová kompatibilita se testuje proti skutečnému používanému engine, nikoli pouze proti mocku nebo odlišnému in-memory engine.

## QTR-005

Každá schema změna musí mít migration test a důkaz zachování podporovaných dat.

## QTR-006

OpenAPI a implementace musí být automaticky kontrolovány na kompatibilitu.

## QTR-007

R0 liveness, readiness a error behavior musí mít success i failure-path testy.

## QTR-008

R1 musí automatizovaně ověřit restart a recovery aktivní WorkoutSession.

## QTR-009

R1 dokončení workoutu musí být testováno jako atomické a idempotentní.

## QTR-010

Flaky test se nesmí považovat za úspěšný důkaz pouze opakovaným rerunem.

## QTR-011

Kritický test nesmí být vypnut bez evidovaného vlastníka, důvodu, náhradního ověření a termínu nápravy.

## QTR-012

Coverage procento nesmí být jediným kritériem kvality ani náhradou risk-based review.

## QTR-013

Test data nesmí obsahovat produkční secrets ani reálné osobní nebo zdravotní údaje.

## QTR-014

Merge do `main` nesmí obejít povinné static, test, contract a migration gates relevantní pro změnu.

## QTR-015

Slice se nesmí označit za dokončený bez dohledatelného release evidence navázaného na konkrétní commit.

---

# 28. Exit criteria dokumentu

Dokument je připraven pro R0/R1 implementaci, pokud:

- test levels mají jednoznačný účel,
- ownership je definovaný,
- R0 a R1 critical paths jsou uvedené,
- contract a migration testy mají závazná pravidla,
- CI gates jsou definované,
- flaky-test policy je explicitní,
- coverage je interpretovaná risk-based,
- release evidence má minimální podobu,
- následující Definition of Ready and Done může tato pravidla převést na každodenní workflow.
