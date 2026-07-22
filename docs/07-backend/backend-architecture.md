# AI Trainer – Backend Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/07-backend/backend-architecture.md`  
**Vlastník:** Backend Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, všechny dokumenty v `docs/06-domain/`  
**Navazující dokumenty:** data architecture, mobile architecture, AI architecture, security architecture, integration architecture, API contracts, ADR, testing and operations documentation  
**Vlastněné kontrakty:** backendový architektonický styl, modulární hranice, dependency rules, transakční model, command/query execution, event processing, background processing a provozní odpovědnosti backendu

---

# 1. Účel dokumentu

Tento dokument definuje cílovou backendovou architekturu AI Traineru.

Převádí produktové požadavky, doménové modely a globální invariance do technického uspořádání serverové aplikace tak, aby backend:

- zachovával doménové hranice,
- bezpečně prováděl změny,
- podporoval offline-first mobilní klienty,
- umožňoval AI návrhy bez přímého zápisu AI do databáze,
- zpracovával integrace a background úlohy,
- byl testovatelný a auditovatelný,
- mohl začít jako provozně jednoduchý systém,
- mohl se později rozdělit bez přepsání domény.

Dokument neurčuje konkrétní programovací jazyk, framework, cloud ani message broker. Tyto volby musí být zaznamenány v ADR.

---

# 2. Architektonické cíle

Backend musí především:

1. chránit globální invariance `INV-001` až `INV-100`,
2. poskytovat autoritativní serverový stav synchronizovaným klientům,
3. oddělit doménovou logiku od transportu, persistence a provider SDK,
4. zachovat historii, revize, provenance a audit,
5. podporovat idempotentní příkazy a opakované doručení,
6. podporovat postupnou implementaci po vertikálních řezech,
7. umožnit bezpečný degradovaný režim při výpadku AI nebo integrace,
8. nevytvářet distribuovanou složitost před skutečnou potřebou.

---

# 3. Výchozí architektonický styl

## 3.1 Modulární monolit

Výchozí backend je **modulární monolit**.

To znamená:

- jeden nasaditelný backendový celek v počátečních etapách,
- jasně oddělené moduly podle bounded contexts,
- explicitní veřejná rozhraní modulů,
- zákaz přímého přístupu do interních tabulek jiného modulu,
- možnost provozovat background workery ze stejného codebase,
- přípravu na budoucí fyzické oddělení vybraných modulů.

Modulární monolit není povolení vytvořit jednu společnou service vrstvu, jeden obecný repository balík nebo sdílený datový model pro celý systém.

## 3.2 Proč ne mikroservisy od začátku

Mikroservisy se v první etapě nezavádějí, protože by předčasně přinesly:

- distribuované transakce,
- síťové failure modes,
- složitější local development,
- vyšší provozní náklady,
- obtížnější refaktoring domény,
- více deployment a observability povinností.

Fyzické rozdělení modulu je možné pouze na základě ADR a měřitelné potřeby.

## 3.3 Kritéria budoucí extrakce

Modul lze oddělit, pokud má:

- stabilní veřejný kontrakt,
- vlastní data a transakční hranice,
- významně odlišný scaling profil,
- bezpečnostní nebo regulatorní důvod izolace,
- samostatnou provozní odpovědnost,
- prokazatelný přínos převyšující distribuovanou složitost.

---

# 4. Logické vrstvy

Každý doménový modul používá následující logické vrstvy:

```text
Transport / Delivery
        ↓
Application
        ↓
Domain
        ↓
Ports
        ↓
Infrastructure adapters
```

## 4.1 Transport / Delivery

Obsahuje:

- HTTP nebo jiný API transport,
- autentizační kontext transportu,
- serializaci a deserializaci,
- syntaktickou validaci vstupu,
- mapování transportních chyb,
- versioned contracts.

Nesmí obsahovat doménová rozhodnutí.

## 4.2 Application layer

Application layer:

- přijímá command nebo query,
- ověřuje oprávnění a scope,
- načítá potřebné agregáty,
- koordinuje doménové operace,
- řídí transakci,
- ukládá změny,
- zapisuje outbox,
- vrací strukturovaný výsledek.

Application service nesmí obcházet metody agregátu přímou změnou jeho interního stavu.

## 4.3 Domain layer

Domain layer obsahuje:

- agregáty,
- entity,
- value objects,
- doménové služby,
- invariance,
- stavové přechody,
- doménové události,
- doménové chyby.

Domain layer nesmí záviset na:

- web frameworku,
- ORM detailech,
- provider SDK,
- message brokeru,
- AI provideru,
- mobilním klientovi.

## 4.4 Ports

Port je rozhraní vyjadřující potřebu application nebo domain vrstvy.

Příklady:

- repository port,
- clock,
- ID generator,
- authorization evaluator,
- event publisher abstraction,
- file storage,
- notification dispatch,
- AI orchestration,
- provider connector.

## 4.5 Infrastructure adapters

Adapter implementuje port pomocí konkrétní technologie.

Příklady:

- relační repository,
- outbox publisher,
- cloud blob storage,
- OAuth provider adapter,
- push notification adapter,
- AI provider adapter.

---

# 5. Hlavní backendové moduly

Počáteční modulární mapa vychází z `domain-overview.md`.

## 5.1 Identity and Access

Odpovědnost:

- Identity,
- AuthenticationIdentity,
- UserAccount status,
- session a device authorization,
- account recovery orchestrace,
- profile access grants,
- role and permission evaluation.

Nevlastní sportovní obsah AthleteProfile.

## 5.2 Profile and Onboarding

Odpovědnost:

- AthleteProfile,
- onboarding,
- preference,
- availability profile,
- equipment and environment,
- locale, units and timezone,
- profile completeness,
- profile revisions.

## 5.3 Sports and Goals

Odpovědnost:

- SportDefinition,
- UserSport,
- sport experience,
- participation patterns,
- Goal,
- Milestone,
- goal priorities and lifecycle.

## 5.4 Training Planning

Odpovědnost:

- TrainingPlan,
- TrainingPlanVersion,
- TrainingBlock,
- TrainingWeek,
- activation and superseding,
- plan validation,
- plan adjustment proposals.

Planning algorithm může být samostatnou doménovou službou uvnitř modulu, nikoli přímou AI odpovědí.

## 5.5 Workouts

Odpovědnost:

- WorkoutTemplate,
- WorkoutDefinition,
- WorkoutInstance,
- WorkoutInstanceRevision,
- WorkoutSession,
- tracker records,
- substitutions and completion.

Aktivní WorkoutSession vyžaduje zvláštní spolehlivost a idempotentní příkazy.

## 5.6 Scheduling

Odpovědnost:

- ScheduleEvent,
- recurrence,
- materialized occurrence,
- flexibility,
- conflict detection,
- reminder scheduling intent,
- vazba na workout a externí kalendář.

## 5.7 Activities

Odpovědnost:

- Activity,
- provenance,
- manual and imported records,
- matching,
- correction,
- deduplication,
- merge and invalidation,
- route reference.

## 5.8 Recovery and Limitations

Odpovědnost:

- DailyCheckIn,
- SleepRecord,
- ReadinessAssessment,
- PainReport,
- Limitation,
- SafetyFlag,
- SafetyRestriction,
- return-to-activity state.

Safety-critical rozhodnutí musí mít deterministickou validační vrstvu a nesmí být závislá pouze na LLM.

## 5.9 Metrics and Progress

Odpovědnost:

- MetricDefinition,
- MetricValue,
- MetricSeries,
- aggregate and derived metrics,
- trends,
- personal records,
- goal progress projections,
- calculation versions.

## 5.10 AI and Change Orchestration

Odpovědnost:

- AIConversation metadata,
- context assembly orchestration,
- AIProposal,
- structured output validation,
- tool authorization,
- ChangeSet,
- approval,
- execution,
- stale detection,
- undo and compensation coordination.

Nevlastní doménová data ostatních modulů a nezapisuje je přímo mimo jejich application commands.

## 5.11 Integrations

Odpovědnost:

- UserIntegration,
- credentials reference,
- import/export jobs,
- external records,
- mapping,
- webhooks,
- reconciliation,
- provider health.

## 5.12 Sync and Change Feed

Odpovědnost:

- device registration,
- sync cursor,
- accepted offline commands,
- change feed,
- tombstones,
- conflict records,
- full resync coordination.

## 5.13 Notifications

Odpovědnost:

- notification intent,
- preference evaluation,
- quiet hours,
- deduplication,
- channel dispatch jobs,
- delivery status.

Doménový modul publikuje skutečnost; Notification modul rozhoduje, zda vznikne uživatelské upozornění.

## 5.14 Audit and Compliance

Odpovědnost:

- AuditRecord,
- privileged access records,
- consent evidence references,
- export and deletion workflow audit,
- immutable operational history podle retention policy.

## 5.15 Files and Blobs

Odpovědnost:

- bezpečné upload sessions,
- blob metadata,
- checksum,
- classification,
- retention and deletion,
- autorizované download references.

GPS trasy, obrázky a velké série se nepřenášejí jako běžný event payload.

---

# 6. Modulární dependency rules

## 6.1 Povolené závislosti

Modul může:

- volat veřejný application contract jiného modulu,
- reagovat na jeho publikovaný DomainEvent nebo IntegrationEvent,
- používat sdílené technické primitives bez doménového významu,
- používat kanonické IDs a contract DTO.

## 6.2 Zakázané závislosti

Modul nesmí:

- číst interní tabulky jiného modulu,
- importovat jeho interní entity nebo repository,
- měnit cizí agregát ve své transakci přímým zápisem,
- sdílet univerzální mutable domain model,
- používat provider DTO jako doménový model.

## 6.3 Shared kernel

Shared kernel musí být minimální a stabilní.

Může obsahovat například:

- typed IDs,
- Instant a timezone primitives,
- Money pouze pokud bude skutečně potřeba,
- Result/Error primitives,
- pagination contracts,
- event envelope abstraction.

Nesmí obsahovat:

- User,
- Workout,
- Goal,
- Activity,
- obecný BaseEntity s doménovým chováním,
- sdílené repository pro všechny entity.

---

# 7. Command execution model

## 7.1 Command pipeline

```text
Authenticated request / background trigger
    ↓
Contract validation
    ↓
Identity and authorization
    ↓
Idempotency check
    ↓
Load aggregate and dependencies
    ↓
Domain validation and transition
    ↓
Persistence transaction
    ├── aggregate changes
    ├── audit records
    └── outbox messages
    ↓
Commit
    ↓
Response / asynchronous follow-up
```

## 7.2 Command requirements

Každý mutační command musí definovat:

- command type,
- command ID nebo idempotency key,
- actor,
- target AthleteProfile,
- expected version podle potřeby,
- authorization scope,
- validation rules,
- possible domain errors,
- resulting events.

## 7.3 Idempotence

Příkazy z mobilní sync queue, provider webhooků a retryable klientů musí být idempotentní.

Stejný command ID:

- nesmí vytvořit druhý business effect,
- musí vrátit kompatibilní původní výsledek nebo stav already-applied,
- nesmí znovu poslat nevratný externí side effect.

## 7.4 Optimistic concurrency

Agregáty se mění s očekávanou verzí tam, kde hrozí souběžná editace.

Při konfliktu backend vrátí strukturovaný conflict result, nikoli silent last-write-wins, pokud daná pole nemají explicitní merge policy.

---

# 8. Query model

## 8.1 Oddělení command a query

Backend používá pragmatické CQRS:

- command model chrání invariance,
- query model optimalizuje čtení,
- není vyžadována samostatná databáze pro každý read model,
- projekce mohou být synchronní nebo asynchronní podle konzistenční potřeby.

## 8.2 Read models

Typické read modely:

- TodayView,
- WeeklyScheduleView,
- ActivePlanOverview,
- WorkoutExecutionView,
- ActivityHistoryView,
- RecoveryOverview,
- GoalProgressView,
- IntegrationStatusView,
- SyncChangeFeed.

## 8.3 Autoritativnost

Read model není zdrojem pravdy pro mutace.

Pokud je projekce opožděná, UI musí umět zobrazit processing nebo pending stav místo nepravdivé definitivní hodnoty.

---

# 9. Transakční model

## 9.1 Základní pravidlo

Jedna transakce má primárně měnit agregáty jednoho modulu.

Cross-module workflow používá:

- veřejné commands,
- domain events,
- process manager nebo saga,
- kompenzaci tam, kde je nutná.

## 9.2 Lokální atomické změny

Atomicky se ukládá:

- změna agregátu,
- jeho revision nebo audit podle pravidel,
- odpovídající outbox zprávy,
- idempotency/inbox záznam, pokud operace vznikla z eventu.

## 9.3 Zakázané distribuované předpoklady

Backend nesmí předpokládat, že:

- externí provider odpoví v rámci databázové transakce,
- push notifikace je doručena přesně jednou,
- AI odpověď je dostupná nebo validní,
- event broker zajistí business-level exactly-once.

---

# 10. Event architecture

Technický event model implementuje `docs/06-domain/domain-events.md`.

## 10.1 Výchozí realizace

V modulárním monolitu mohou být události zpočátku distribuovány interním event dispatcherem, ale musí být zapisovány přes transactional outbox tam, kde spouštějí:

- background processing,
- integraci,
- notifikaci,
- změnu jiného modulu,
- změnu change feedu,
- dlouhodobý workflow.

## 10.2 Consumer pravidla

Každý consumer musí být:

- idempotentní,
- verzovaný,
- observovatelný,
- retryable podle typu chyby,
- schopný dead-letter nebo manual review flow,
- bezpečný při replay.

## 10.3 Pořadí

Pořadí se garantuje pouze v nutném scope, typicky podle aggregateId nebo workflow ID.

Globální pořadí všech eventů není požadováno.

---

# 11. Background processing

Background jobs zpracovávají zejména:

- outbox publishing,
- integration import/export,
- webhook processing,
- metric recalculation,
- projection rebuild,
- notification delivery,
- AI generation jobs,
- account export and deletion,
- retention cleanup,
- reconciliation,
- scheduled plan review.

Každý job musí mít:

- stabilní job ID,
- stav,
- retry policy,
- timeout,
- cancellation policy,
- deduplication strategy,
- progress nebo checkpoint podle potřeby,
- audit a telemetry.

Dlouhý job nesmí držet jednu databázovou transakci po celou dobu.

---

# 12. AI orchestration boundary

## 12.1 AI jako nedůvěryhodný návrhový vstup

Výstup modelu se považuje za nedůvěryhodný externí vstup.

Musí projít:

1. schema validation,
2. semantic validation,
3. authorization,
4. domain validation,
5. safety rules,
6. ConfirmationPolicy,
7. ChangeSet execution.

## 12.2 Zakázané chování

AI provider nesmí:

- získat databázové credentials,
- volat repository přímo,
- vytvářet libovolný SQL nebo interní command,
- měnit data bez tool authorization,
- přepisovat safety restrictions,
- dostávat více citlivých dat, než vyžaduje účel.

## 12.3 Fallback

Při výpadku AI musí zůstat dostupné:

- ruční zobrazení a editace podporovaných dat,
- aktivní plán,
- tracker,
- offline workflow,
- deterministická safety pravidla,
- synchronizace bez AI enrichments.

---

# 13. Sync backend boundary

Backend je autoritativní pro synchronizovaný stav.

Sync API musí podporovat:

- push offline commands,
- idempotency,
- per-command result,
- pull change feed,
- cursor,
- tombstones,
- conflict information,
- full resync,
- device revocation.

Sync modul nesmí obcházet application commands jednotlivých domén. Offline command se po přijetí zpracuje stejnými doménovými pravidly jako online command.

---

# 14. Integration boundary

Externí payload se nejprve ukládá nebo eviduje jako ExternalDataRecord.

Pipeline:

```text
Webhook / polling / file
    ↓
Authentication and signature validation
    ↓
Raw external record reference
    ↓
Normalization
    ↓
Mapping
    ↓
Validation and deduplication
    ↓
Domain command
    ↓
Imported Activity / Metric / Calendar link
```

Provider není zdrojem pravdy pro interní doménové významy, pokud integrační model neurčí explicitní autoritu konkrétního pole.

---

# 15. Security boundaries

Backend musí v každé operaci ověřit:

- Identity,
- session validity,
- actor type,
- AthleteProfile scope,
- relationship permission,
- data classification,
- purpose and consent podle potřeby.

Klientský `profileId`, role nebo feature flag se nikdy nepovažuje za dostatečný důkaz oprávnění.

Privilegované operace vyžadují audit a podle rizika recent authentication nebo step-up verification.

Detailní mechanismy vlastní budoucí `security-architecture.md`.

---

# 16. Error model

Backend rozlišuje minimálně:

- validation error,
- authentication error,
- authorization error,
- not found,
- version conflict,
- domain rule violation,
- safety block,
- stale proposal,
- idempotency conflict,
- rate limit,
- dependency unavailable,
- temporary processing failure,
- permanent processing failure.

Chyba musí mít:

- stabilní machine-readable code,
- bezpečný user-facing message key,
- correlation ID,
- retryability flag,
- field details pouze tam, kde jsou bezpečné.

Interní stack trace nebo provider secret se klientovi nevrací.

---

# 17. Data ownership and persistence rules

Každý modul vlastní své tabulky nebo jasně označené schema objekty.

Jiný modul:

- nesmí zapisovat do jeho tabulek,
- nesmí stavět doménové rozhodnutí na nezdokumentovaném joinu do interního schématu,
- může používat publikovaný read model nebo contract view.

Konkrétní fyzický model, indexy, partitioning, retention a backup vlastní `data-architecture.md` a navazující schema dokumentace.

---

# 18. Caching

Cache je optimalizace, nikoli zdroj pravdy.

Cache musí mít:

- definovaný key scope,
- tenant/profile isolation,
- TTL nebo invalidation strategy,
- klasifikaci dat,
- bezpečný fallback při miss nebo výpadku,
- zákaz ukládání credentials a nepřiměřeně citlivých payloadů.

Command validace nesmí záviset výhradně na potenciálně zastaralé cache.

---

# 19. Observability

Každý request, command, event a job musí být korelovatelný pomocí trace/correlation ID.

Backend publikuje minimálně:

- request latency and error rate,
- command success/conflict/failure,
- database latency,
- outbox lag,
- consumer lag and dead letters,
- job queue depth,
- sync success and conflicts,
- provider health,
- AI latency, validation failure and cost indicators,
- notification delivery status,
- safety workflow failures.

Logy nesmí obsahovat neredigované citlivé payloady.

---

# 20. Configuration and feature flags

Konfigurace se odděluje od kódu a prostředí.

Feature flag:

- nesmí obejít authorization nebo invariance,
- musí mít vlastníka a expiry/review datum,
- musí být auditovatelný u safety-relevant změn,
- nesmí vytvářet nevratnou datovou migraci bez compatibility plánu.

Secrets se nikdy neukládají do běžné konfigurace nebo repozitáře.

---

# 21. API boundary principles

Backendové API musí být:

- versioned,
- explicitní,
- doménově pojmenované,
- idempotentní pro retryable mutace,
- kompatibilní s podporovanými mobilními verzemi,
- schopné vracet partial processing state,
- oddělené od interního ORM modelu.

Obecné CRUD endpointy nesmí nahradit doménové commands tam, kde existují invariance nebo auditní význam.

---

# 22. Testing implications

Backendová architektura musí umožnit:

- unit test agregátů bez infrastruktury,
- application tests s fake ports,
- persistence integration tests,
- module boundary tests,
- API contract tests,
- event contract tests,
- idempotency tests,
- concurrency tests,
- replay tests,
- security authorization matrix tests,
- sync multi-device tests,
- AI structured-output and tool authorization tests,
- failure injection tests.

Architektonické testy mají automaticky hlídat zakázané dependency směry.

---

# 23. Deployment topology

Počáteční logická topologie může obsahovat:

```text
API process
Worker process
Relational database
Blob storage
Cache / coordination store podle potřeby
External providers
```

API a worker mohou používat stejný codebase, ale odlišný runtime profil.

Konkrétní topology, cloud, autoscaling a deployment strategy budou rozhodnuty později.

---

# 24. Modulární projektová struktura

Ilustrační struktura bez vazby na konkrétní jazyk:

```text
backend/
├── bootstrap/
├── shared-kernel/
├── modules/
│   ├── identity-access/
│   ├── profile-onboarding/
│   ├── sports-goals/
│   ├── training-planning/
│   ├── workouts/
│   ├── scheduling/
│   ├── activities/
│   ├── recovery-limitations/
│   ├── metrics-progress/
│   ├── ai-change/
│   ├── integrations/
│   ├── sync/
│   ├── notifications/
│   ├── audit-compliance/
│   └── files-blobs/
├── infrastructure/
├── api-contracts/
└── tests/
```

Každý modul obsahuje vlastní:

- domain,
- application,
- ports,
- infrastructure adapters,
- public contracts,
- tests.

---

# 25. Architektonická pravidla s identifikátory

## BAR-001 – Modulární monolit jako výchozí stav

Backend začíná jako modulární monolit; fyzické rozdělení vyžaduje ADR.

## BAR-002 – Doména bez framework dependencies

Domain layer nesmí záviset na frameworku, ORM ani provider SDK.

## BAR-003 – Modul vlastní svá data

Pouze vlastnící modul smí měnit své autoritativní doménové úložiště.

## BAR-004 – Mutace přes application command

Doménová změna musí projít autorizovaným application commandem.

## BAR-005 – Atomický aggregate, audit a outbox zápis

Změna stavu, nutný audit a outbox se ukládají v jedné lokální transakci.

## BAR-006 – Idempotentní externí a offline vstupy

Offline commands, webhooky, event consumers a retryable API mutace musí být idempotentní.

## BAR-007 – AI pouze navrhuje

AI výstup se aplikuje pouze přes validovaný AIProposal, ConfirmationPolicy a ChangeSet.

## BAR-008 – Read model není zdroj pravdy

Projekce a cache nesmí být autoritativním zdrojem mutace.

## BAR-009 – Kritická safety validace synchronně

Bezpečnostní blokace potřebná k rozhodnutí commandu nesmí záviset pouze na pozdějším event consumeru.

## BAR-010 – Cross-module workflow bez přímého zápisu

Cross-module proces používá commands, events a process manager, nikoli přímý zápis do cizích tabulek.

## BAR-011 – Bezpečná degradace

Výpadek AI, integrace, notifikace nebo projekce nesmí znepřístupnit bezpečné základní funkce.

## BAR-012 – Traceability

Každý významný command, event a background job musí být korelovatelný a auditovatelný.

## BAR-013 – Contract compatibility

Veřejný API nebo event kontrakt se mění pouze verzovaně a s compatibility plánem.

## BAR-014 – Citlivá data podle purpose

Backend poskytne každému modulu, provideru a AI procesu pouze data nutná pro autorizovaný účel.

## BAR-015 – Architektonické dependency testy

Zakázané dependency směry musí být kontrolovány automaticky v CI.

---

# 26. Rozhodnutí vyžadující ADR

Před implementací musí být rozhodnuto minimálně:

- backend language and framework,
- build system,
- relational database,
- ORM nebo query strategy,
- migration tool,
- authentication provider,
- API style and schema generation,
- event transport strategy,
- job queue strategy,
- cache/coordination technology,
- blob storage,
- AI provider abstraction,
- deployment platform,
- secrets management,
- observability stack.

Tento dokument stanovuje požadované vlastnosti, nikoli konkrétní produkty.

---

# 27. Otevřené otázky

- Bude prvním backendem jediná aplikace s odděleným worker procesem?
- Které eventy musí být distribuované od první etapy?
- Které read modely vyžadují synchronní konzistenci?
- Jaký je maximální podporovaný offline interval před full resync?
- Které moduly budou používat samostatná databázová schémata?
- Jak se technicky vynutí zákaz cross-module tabulkových zápisů?
- Které background joby jsou kritické a které best-effort?
- Jak se budou verzovat calculation definitions?
- Jak dlouho budou podporované staré mobilní API verze?
- Které operace vyžadují recent authentication?
- Jaký je přesný isolation model trenéra, guardian a organizace?
- Jak bude řešena anonymizace eventů po smazání účtu?
- Jak se bude provádět bezpečný projection rebuild?
- Kdy bude nutné oddělit time-series workload?
- Které safety rules budou hard-coded, konfigurované nebo verzované jako data?

---

# 28. Kritéria `IMPLEMENTATION_READY`

Dokument může být označen `IMPLEMENTATION_READY`, až když:

1. jsou přijaté klíčové ADR,
2. je hotová data architecture,
3. je hotová security architecture,
4. je definován API a sync contract směr,
5. jsou potvrzené module boundaries,
6. jsou namapované CORE FR a CRITICAL NFR,
7. jsou definované transakční hranice kritických workflow,
8. je potvrzen event/outbox strategy,
9. jsou definované error a idempotency contracts,
10. jsou připravené architecture tests a quality gates.

---

# 29. Závěr

Backend AI Traineru bude nejprve provozně jednoduchý modulární monolit s přísnými doménovými hranicemi.

Základní cesta změny je:

```text
Transport
    ↓
Authorization and idempotency
    ↓
Application command
    ↓
Domain aggregate
    ↓
Transaction
    ├── state
    ├── audit
    └── outbox
    ↓
Events, projections and background workflows
```

Nejdůležitější vlastností architektury není počet služeb. Je jí schopnost zachovat:

- bezpečnost,
- doménovou konzistenci,
- historii,
- offline synchronizaci,
- auditovatelnou AI změnu,
- testovatelnost,
- budoucí evoluci bez nekontrolovaných závislostí.
