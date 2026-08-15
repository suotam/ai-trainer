# AI Trainer – Initial Architecture Decisions

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/05-architecture/initial-architecture-decisions.md`  
**Vlastník:** Architecture  
**Poslední aktualizace:** 2026-07-29  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/data-architecture.md`, `docs/13-delivery/repository-strategy.md`, `docs/07-backend/r2-identity-session-contract.md`, `docs/07-backend/r2-auth-api-contract.md`  
**Navazující dokumenty:** physical data model R1, minimal API contract, test strategy, Definition of Ready and Done, vertical-slice implementation plan a coding-agent guide  
**Vlastněné pojmy nebo kontrakty:** počáteční technologická rozhodnutí pro R0 a R1 a navazující R2 architektonické rozhodnutí (ADR-011, C5 auth provider strategy), jejich stav, důvody, důsledky a pravidla `ADR-001` až `ADR-011`

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

# 12. ADR-011 – R2 authentication provider strategy (C5)

**Stav:** ACCEPTED (strategie); konkrétní externí federated provider je dílčí **DEFERRED** rozhodnutí (viz Rozhodnutí)

Tento ADR je kontrakt **C5** dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`. Je to rozhodovací ADR (ne průzkum). Neimplementuje provider SDK, Spring Security, OAuth callback, JWT parser, secrets, env proměnné, Docker služby, mobilní login flow ani migrace.

## Kontext

`R2 – Account and Sync` potřebuje autentizaci. `§12` dříve odkládal „identity provider" a „token a session mechanismus"; R2 to nyní vyžaduje rozhodnout. Požadavky přicházejí z:

- **C3 (identity & session):** server-authoritative identita/session, anonymous → account přechod, krátká access + rotující refresh, revokovatelnost, oddělení `Identity`/`AuthenticationIdentity`/`UserAccount` (`ISC-*`, `INV-010`).
- **C4 (auth API):** backend zveřejňuje register/login/refresh/logout/session-context, provider-neutral, kanonický error envelope, bez account enumeration (`AAC-*`).
- **security-architecture:** server je autorita (`SAR-002`), nedůvěryhodný klient (`SAR-003`), secrets mimo klienta (`SAR-006`), revokovatelné session (`SAR-007`), bezpečné logování (`SAR-012`).
- **offline-first (R1 invariant):** kritický lokální tok musí fungovat bez sítě; anonymní použití zůstává.

Rozsah MVP je malý; dokumentace neuvádí rozpočet, počty uživatelů ani cloud platformu — tento ADR proto nedělá neověřené předpoklady o nich a rozhoduje na úrovni **strategie**, ne konkrétního produktu.

## Rozhodovací kritéria

- kompatibilita s C3/C4 (server-authoritative session, provider-neutral),
- bezpečnost (revokace, secret ownership, žádná enumeration),
- podpora anonymous → account bez duplicit (`INV-013`),
- offline-first hranice (žádná závislost R1 toku na provideru),
- backend i mobile integrace,
- vendor lock-in a možnost exitu,
- provozní složitost a lokální development/CI bez produkčního provideru,
- testovatelnost.

## Zvažované varianty

- **A – First-party backend session authority + provider-neutral `AuthenticationIdentity` adapter:** backend validuje credential, vydává a vlastní aplikační session (access/refresh) i revokaci; externí providery (pokud přibudou) jsou za adaptérem. R2 baseline používá first-party credential (např. e-mail+heslo nebo schválenou minimální baseline) za stejným adaptérem.
- **B – Self-hosted identity provider** (kategorie samostatného IdP): plná federace, ale přidává provozní komponentu a závislost už v MVP.
- **C – Managed identity provider** (kategorie hostované IdP služby): rychlý start, ale vendor dependency a rozhodnutí o produktu/nákladech, která zatím nejsou k dispozici.
- **D – Přímé provider tokeny jako aplikační identita** (backend důvěřuje provider tokenu přímo, bez vlastní app session).

## Rozhodovací matice

| Kritérium | A first-party + adapter | B self-hosted IdP | C managed IdP | D přímé provider tokeny |
|---|---|---|---|---|
| Kompatibilita s C3/C4 | strong fit | acceptable | acceptable | disqualifying |
| Server-authoritative session + revokace | strong fit | acceptable | acceptable | disqualifying |
| Anonymous → account bez duplicit | strong fit | acceptable | acceptable | weak fit |
| Offline-first hranice | strong fit | acceptable | acceptable | weak fit |
| Vendor lock-in / exit | strong fit | acceptable | weak fit | weak fit |
| Provozní složitost / lokální dev + CI | strong fit | weak fit | acceptable | acceptable |
| Odklad konkrétní volby bez blokace R2 | strong fit | weak fit | weak fit | disqualifying |

## Rozhodnutí

Zvolena **varianta A**: **backend je first-party autorita aplikační session; externí autentizace je za provider-neutral `AuthenticationIdentity` adaptérem; R2 baseline používá first-party credential za tímto adaptérem.**

- **Proč A:** jediná varianta se strong fit vůči C3/C4 a bezpečnosti; nezavádí provozní/vendor závislost do MVP; umožňuje přidat externí providery později bez změny identity/session modelu ani auth API.
- **Proč ne B/C:** přijatelné dlouhodobě, ale zavádějí provozní komponentu, resp. vendor dependency a produkt/náklad rozhodnutí, která dokumentace zatím neposkytuje; lze je přidat jako adaptér později.
- **Proč ne D:** diskvalifikováno — porušuje server-authoritative session, vlastnictví revokace a offline session model (C3/C4/security).
- **Dílčí DEFERRED rozhodnutí:** konkrétní **externí federated provider** (např. Apple/Google/… kategorie) se **nevybírá nyní**; volba je odložena do doby, kdy vzniknou produktové požadavky. R2 baseline funguje bez něj.
- **Konečnost:** strategie (A) je konečné R2 rozhodnutí; dílčí volba externího providera je časově omezené DEFERRED. ADR se znovu otevře při volbě externího providera nebo pokud C6/C7 prokážou zásadní překážku.

Rozhodnutí neodporuje C3 ani C4.

## Integrační hranice

- **Provider (adaptér):** ověří externí přihlašovací identitu a vrátí stabilní provider subject; nikdy neurčuje interní doménovou identitu.
- **Backend:** validuje credential, mapuje `AuthenticationIdentity` na interní `Identity`/`UserAccount`, vydává a vlastní aplikační session, ownership a revokaci (C3/C6/C8).
- **Mobilní klient:** spouští auth flow a bezpečně ukládá vydaný session materiál (storage vlastní C7); neurčuje identitu.
- **Vlastní DB aplikace:** autoritativní account/session/identity (C6).
- **Externí vs interní ID:** provider subject je externí identifikátor; **externí provider identifier nesmí bez výslovného existujícího rozhodnutí automaticky nahradit interní doménovou identitu** (`UserAccount` ID) — ověřeno vůči `identity-and-profile-model §5/§6` a C3 (`ISC-001/004`).

## Session a token hranice

- Credentials **vydává a obnovuje backend** (aplikační access/refresh session); **validuje** je backend; **revokaci vlastní** backend (C3/C13).
- Backend **nepřijímá provider-issued token přímo jako aplikační session** — případný provider token se směňuje za aplikační session (varianta D odmítnuta).
- Vztah provider session ↔ aplikační session: provider ověří přihlášení; aplikační session je samostatná, serverem vlastněná a revokovatelná.
- Konkrétní HTTP tvar vlastní C4; konkrétní token format je součást implementace za adaptérem; mobilní storage vlastní C7.

## Anonymous-to-account důsledek

Strategie A přirozeně podporuje existující anonymní/lokální identitu (C3 §4.1): registrace/přihlášení naváže externí nebo first-party `AuthenticationIdentity` na interní účet, přičemž unikátnost provider+subject (`INV-011`) a idempotency key (C4 `AAC-005`) brání duplicitnímu účtu. **Algoritmus zachování lokálních dat nepřebírá tento ADR — vlastní jej C15**; C2 vlastní lokální ownership/outbox.

## Bezpečnostní důsledky

- **Trust boundary:** server je autorita; klient a provider jsou nedůvěryhodní vstupem (`SAR-002/003`).
- **Secret ownership:** provider a session secrets patří serveru/secure storage, nikdy do klientské SQLite ani logu (`SAR-006/012`, C7).
- **Token validation:** provider/credential ověřuje backend; klíč discovery/rotace providera je konceptuálně na straně adaptéru.
- **Account enumeration:** auth chyby jsou generické (C4 `AAC-008`).
- **Compromised credential / revokace:** revokovaná session neautorizuje (C3 `ISC-007`, C13).
- **Provider outage / dependency risk:** first-party baseline snižuje závislost; adaptér izoluje výpadek providera.
- Detailní threat model vlastní `security-architecture`, ne tento ADR.

## Provozní důsledky

- **Lokální dev / test / CI:** first-party baseline za adaptérem je testovatelná bez produkčního providera (adapter contract + fake).
- **Staging/production:** případný externí provider se konfiguruje mimo kód a mimo repozitář (secrets manager je odložen, `§` deferred).
- **Availability / failure modes:** výpadek externího providera nesmí shodit R1 offline tok; first-party baseline zůstává.
- **Backup/export identity dat, monitoring, incident response:** vlastní data zůstávají v aplikační DB (C6); export/observability dle příslušných dokumentů.

## Testovací důsledky

Implementační slices (R2-02+) musí ověřit: provider **adapter contract**, úspěšné/neúspěšné přihlášení, registraci, refresh, revokaci, duplicate identity, anonymous upgrade, provider outage, neplatnou provider odpověď, expiraci/clock skew (je-li relevantní) a **lokální testování bez produkčního providera**.

## Migrace a exit strategy

- Vendor lock-in omezuje **provider-neutral adaptér**: identity/session model ani auth API nezávisí na konkrétním providerovi.
- Provider identities se mapují přes stabilní provider subject na interní `Identity`.
- Exportovatelná musí zůstat autoritativní account/session/identity data (C6).
- Migrace na jiného providera = nový adaptér + přemapování `AuthenticationIdentity`; aktivní aplikační session zůstávají serverové a revokovatelné.

## Důsledky

- **Positive:** silná shoda s C3/C4/security; žádná vendor závislost v MVP; pozdější přidání providera bez změny modelu; testovatelné lokálně.
- **Negative:** first-party credential znamená, že backend nese odpovědnost za credential handling baseline (za adaptérem).
- **Accepted trade-off:** konkrétní externí federated provider je odložen; R2 baseline je first-party.

## Navazující kontrakty

- **C6 (server data model):** account/auth/identity/session tabulky odrážející tuto strategii.
- **C7 (token/session storage):** mobilní bezpečné uložení session materiálu.
- **C13 (token/session revocation):** revokační flow.
- **C14 (audit-event):** auditované auth události.
Tento ADR tyto kontrakty **nevytváří**.

## Přehodnocení

Znovu otevřít při volbě konkrétního externího providera, při produktovém požadavku na federaci, nebo pokud C6/C7 prokážou zásadní překážku strategie A.

---

# 13. Záměrně odložená rozhodnutí

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

**Aktualizace pro R2:** `ADR-011` (§12, C5) rozhoduje **strategii** identity provideru a token/session mechanismu pro R2 (first-party backend session authority + provider-neutral adaptér). Konkrétní **externí federated provider** i produkční **secrets manager** zůstávají odložené dle výše uvedeného seznamu.

---

# 14. Implementační baseline R0

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

# 15. Implementační baseline R1

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

# 16. Závazná pravidla

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

## ADR-011

R2 autentizace MUSÍ používat backend jako first-party autoritu aplikační session za provider-neutral `AuthenticationIdentity` adaptérem; konkrétní externí federated provider je odložen a NESMÍ být zaveden do kódu bez samostatného rozhodnutí. Externí provider identifier NESMÍ automaticky nahradit interní doménovou identitu.

## ADR-012

R4 AI volání MUSÍ probíhat výhradně server-side přes AI gateway za provider abstrakcí (`AiModelProvider`). Prvním podporovaným providerem je **Anthropic (Claude, Messages API)**; konkrétní model je konfigurační hodnota, ne kód. Provider klíče NESMÍ existovat na klientu ani v repozitáři (výhradně runtime konfigurace serveru). Testy a CI MUSÍ běžet deterministicky proti fake provideru — živý provider NESMÍ být podmínkou žádného gate. Výměna providera je nové rozhodnutí za touž abstrakcí, ne přepis volajícího kódu. (C25, `docs/09-ai/r4-ai-gateway-contract.md`)

## ADR-013

R7 zavádí **osobní režim (local-first BYOK)** jako primární provozní režim aplikace: AI volání SMÍ probíhat přímo z mobilního klienta na Anthropic API s **API klíčem vlastníka aplikace**, uloženým výhradně v platformním secure storage (C7 vzor). Tím se pro osobní režim **superseduje serverová výhrada ADR-012** („klíče nesmí existovat na klientu") — klíč vlastníka na jeho vlastním zařízení není klíč aplikace. Bezpečnostní invarianty ADR-012 se přenášejí beze změny: klíč NESMÍ existovat v repozitáři, Drift/SQLite, preferencích, log výstupu, chybových hláškách ani záloze; volání MUSÍ mít bounded timeout, typovaná selhání a obsahové limity (C31); testy a CI MUSÍ běžet deterministicky proti fake providerům — živý provider NESMÍ být podmínkou žádného gate. Backend AI gateway (C25) zůstává dormantní alternativou pro budoucí serverový režim; není podmínkou žádného R7 flow. (C46, `docs/08-mobile/r7-byok-provider-contract.md`)

---

# 17. Připravenost a další krok

Po přijetí tohoto balíku jsou hlavní technologie pro R0 a R1 rozhodnuté.

Další blokující dokument je:

```text
docs/12-data/r1-physical-data-model.md
```

Ten musí konkretizovat pouze lokální mobilní schema a minimální serverový bootstrap potřebný pro R0/R1, nikoli celé budoucí produkční schéma.