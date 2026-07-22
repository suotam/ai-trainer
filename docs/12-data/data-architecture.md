# AI Trainer – Data Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/12-data/data-architecture.md`  
**Vlastník:** Data Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/06-domain/`, `docs/07-backend/backend-architecture.md`  
**Navazující dokumenty:** physical database schema, local data model, API contracts, sync protocol, security architecture, backup and recovery, retention and deletion, analytics data model, ADR  
**Vlastněné kontrakty:** autoritativní datové vrstvy, vlastnictví dat, logické typy úložišť, transakční a historický model, lineage, migrace, retence, zálohy a pravidla datové konzistence

---

# 1. Účel dokumentu

Tento dokument definuje cílovou datovou architekturu AI Traineru.

Převádí doménové modely, globální invariance a backendovou architekturu do pravidel pro ukládání, čtení, synchronizaci, historii, ochranu a životní cyklus dat.

Dokument musí zajistit, aby data:

- měla jednoznačného vlastníka,
- měla definovaný autoritativní zdroj,
- byla historicky interpretovatelná,
- podporovala offline-first mobilní aplikaci,
- byla bezpečně synchronizovatelná mezi zařízeními,
- zachovávala provenance a audit,
- podporovala opravy bez přepisování historie,
- šla migrovat, exportovat a mazat,
- byla obnovitelná po chybě,
- nebyla zbytečně duplikována mezi moduly.

Dokument neurčuje konkrétní databázový produkt, cloudové úložiště ani ORM. Tyto volby budou potvrzeny pomocí ADR.

---

# 2. Základní principy

## 2.1 Doména vlastní význam, data architecture vlastní uložení

Datová architektura nesmí měnit význam objektů definovaný v `docs/06-domain/`.

Například:

- `WorkoutSession` zůstává doménovým objektem workout modulu,
- `Activity` zůstává samostatnou skutečností activity modulu,
- `ScheduleEvent` není databázová reprezentace workoutu,
- `MetricValue` není libovolný číselný sloupec bez `MetricDefinition`.

## 2.2 Jeden autoritativní vlastník

Každý zapisovatelný datový objekt má jeden autoritativní backendový modul.

Jiný modul může mít:

- referenci,
- read model,
- projekci,
- cache,
- denormalizovaný údaj pro čtení.

Nesmí přímo zapisovat do interních tabulek vlastníka.

## 2.3 Relační jádro jako výchozí model

Autoritativní obchodní stav má být ve výchozí architektuře uložen v transakčním relačním úložišti.

Důvody:

- silné transakce,
- constraints,
- konzistentní vztahy,
- migrace,
- auditovatelnost,
- široká provozní podpora.

Specializované úložiště se přidává pouze na základě skutečného datového nebo provozního požadavku.

## 2.4 Historie se nepřepisuje

Významné změny používají podle domény:

- revize,
- nové verze,
- opravné záznamy,
- invalidaci,
- tombstone,
- auditní událost.

Destruktivní přepsání historického významu je zakázané.

## 2.5 Kanonické hodnoty a prezentační preference

Hodnoty se ukládají v definované kanonické podobě.

Uživatelské preference jednotek, locale a formátu času ovlivňují vstup a zobrazení, nikoli význam uložených hodnot.

## 2.6 Data classification od vzniku

Každá datová kategorie musí být klasifikována nejpozději při návrhu fyzického schématu.

Minimální třídy:

- INTERNAL,
- PERSONAL,
- SENSITIVE,
- HEALTH_RELATED,
- LOCATION_RELATED,
- AUTHENTICATION_RELATED,
- LEGAL.

Klasifikace ovlivňuje přístup, logování, šifrování, retenci, export a mazání.

---

# 3. Datové vrstvy

```text
Mobile local database
        ↕ sync protocol
Authoritative transactional store
        ↓
Outbox / change feed / event transport
        ↓
Read models and caches
        ↓
Analytics and operational projections

Large binary or sensor objects
        ↕ metadata reference
Blob / object storage
```

## 3.1 Autoritativní transakční úložiště

Obsahuje zejména:

- identity a account stav,
- AthleteProfile,
- sporty a cíle,
- plány a jejich verze,
- workouty a workout sessions,
- schedule,
- aktivity,
- recovery a limitations,
- metriky a jejich definice,
- AIProposal a ChangeSet metadata,
- integration connections a lineage,
- synchronizační metadata,
- souhlasy a auditní reference.

## 3.2 Mobilní lokální databáze

Je autoritativní pouze pro dosud nesynchronizované lokální operace a lokální runtime stav podle `sync-and-offline-model.md`.

Po serverovém potvrzení je server autoritativní pro sdílený stav.

Lokální databáze musí ukládat minimálně:

- data nutná pro dnešní použití,
- aktivní WorkoutSession,
- pending OfflineCommand,
- lokální změnový stav,
- sync cursors,
- relevantní safety restrictions,
- nezbytné reference a read modely.

## 3.3 Read modely

Read model je odvozená struktura optimalizovaná pro konkrétní čtení.

Příklady:

- TodayView,
- WeeklyScheduleView,
- GoalProgressView,
- AthleteSummary,
- ActivityHistoryView,
- AIContextSummary.

Read model není autoritativním zdrojem doménového stavu a musí být rekonstruovatelný.

## 3.4 Cache

Cache nesmí být jediným místem, kde existuje doménově významný stav.

Musí mít definováno:

- cache key,
- owner,
- invalidation trigger,
- TTL,
- chování při miss,
- citlivost dat,
- maximální přijatelnou zastaralost.

## 3.5 Blob a object storage

Používá se pro data nevhodná pro přímé relační uložení, například:

- exportní soubory,
- fotografie,
- velké GPS záznamy,
- senzorové soubory,
- přílohy,
- velké provider payloady, pokud jejich uchování má oprávněný účel.

Relační databáze ukládá metadata, ownership, klasifikaci, checksum, stav a retention reference.

## 3.6 Analytics storage

Produktová analytika a datový sklad nesmí být autoritativním zdrojem pro uživatelské operace.

Do analytiky se mají přenášet pouze data potřebná pro schválený účel a po odpovídající minimalizaci nebo pseudonymizaci.

---

# 4. Vlastnictví dat podle modulů

## 4.1 Identity and Access

Vlastní:

- Identity,
- AuthenticationIdentity,
- UserAccount security state,
- session a device authorization metadata,
- access grants a role assignments.

Nevlastní sportovní obsah AthleteProfile.

## 4.2 Profile and Onboarding

Vlastní:

- AthleteProfile,
- profile revisions,
- onboarding,
- preference,
- availability profile,
- equipment a environment,
- locale, units a timezone.

## 4.3 Sports and Goals

Vlastní:

- SportDefinition reference data,
- UserSport,
- experience,
- ParticipationPattern,
- Goal,
- Milestone,
- goal lifecycle.

## 4.4 Training Planning

Vlastní:

- TrainingPlan,
- TrainingPlanVersion,
- TrainingBlock,
- TrainingWeek,
- plánovací snapshoty a validační výsledky.

## 4.5 Workouts

Vlastní:

- WorkoutTemplate,
- WorkoutDefinition,
- WorkoutInstance,
- WorkoutInstanceRevision,
- WorkoutSession,
- tracker records.

## 4.6 Scheduling

Vlastní:

- ScheduleEvent,
- recurrence rules,
- materializované výskyty,
- schedule conflicts,
- reminder scheduling metadata.

## 4.7 Activities

Vlastní:

- Activity,
- source lineage,
- duplicate and merge state,
- activity route metadata,
- activity corrections.

## 4.8 Recovery and Limitations

Vlastní:

- DailyCheckIn,
- recovery observations,
- PainReport,
- Limitation,
- SafetyRestriction,
- professional recommendation reference.

## 4.9 Metrics and Progress

Vlastní:

- MetricDefinition,
- MetricValue,
- MetricSeries,
- aggregates,
- baselines,
- trends,
- personal records,
- calculation versions.

## 4.10 AI and Change

Vlastní:

- AIConversation metadata,
- message references,
- AIProposal,
- ChangeSet,
- ChangeOperation,
- validation and approval state,
- tool invocation audit metadata.

## 4.11 Integrations

Vlastní:

- IntegrationProvider reference data,
- UserIntegration,
- encrypted credential references,
- ExternalDataRecord,
- import/export jobs,
- mapping, webhook a reconciliation state.

## 4.12 Sync

Vlastní:

- sync cursor,
- change feed metadata,
- command idempotency records,
- conflict records,
- tombstones,
- device sync health.

---

# 5. Identifikátory

## 5.1 Globální pravidla

Primární identifikátory musí být:

- globálně unikátní,
- generovatelné bez centrální sekvence, pokud je objekt vytvářen offline,
- stabilní po celý život objektu,
- nevázané na osobní údaj,
- bezpečné pro použití v API.

Preferovaná rodina bude potvrzena ADR, například UUIDv7 nebo ULID.

## 5.2 Interní databázové klíče

Implementace může používat pomocné interní klíče pouze tehdy, pokud nemění veřejnou identitu objektu.

## 5.3 Externí identifikátory

Provider ID musí být vždy uloženo spolu s provider contextem.

Samotné externí ID bez provideru není globálně unikátní.

## 5.4 Alias a merge

Při bezpečném sloučení objektů se má zachovat:

- canonical ID,
- alias původního ID,
- audit merge,
- reference migration nebo resolution policy.

---

# 6. Časový model

## 6.1 Absolutní čas

Časové okamžiky se ukládají jako timezone-independent instant s dostatečnou přesností.

## 6.2 Lokální plánovací čas

Objekty závislé na místním kalendáři mohou navíc ukládat:

- local date,
- local time,
- IANA timezone,
- recurrence policy.

## 6.3 Occurred, recorded a effective time

Model musí rozlišit:

- kdy se skutečnost stala,
- kdy ji systém zaznamenal,
- od kdy je změna účinná.

To je nutné pro offline, importy, opravy a budoucí změny plánu.

## 6.4 Zákaz závislosti na serverovém `now`

Doménový historický význam nesmí být rekonstruován pouze podle času zpracování na serveru.

---

# 7. Jednotky, precision a numerické hodnoty

## 7.1 Jednotky

Každá numerická veličina musí mít jednotku definovanou:

- přímo ve schématu,
- nebo přes MetricDefinition.

## 7.2 Decimal versus floating point

Hodnoty s požadavkem na přesnou desetinnou reprezentaci nesmí používat nepřesný floating-point typ bez zdokumentovaného důvodu.

## 7.3 Precision policy

Fyzické schema musí pro každou významnou hodnotu určit:

- rozsah,
- precision,
- scale,
- rounding policy,
- chování při překročení rozsahu.

## 7.4 Původní hodnota

Pokud je to relevantní pro lineage, může být zachována:

- původní hodnota,
- původní jednotka,
- normalizovaná kanonická hodnota.

---

# 8. Historie, verze a revize

## 8.1 Verze agregátu

Zapisovatelné agregáty mají version token pro optimistic concurrency.

## 8.2 Neměnné verze

TrainingPlanVersion, WorkoutInstanceRevision a obdobné objekty jsou po aktivaci nebo použití neměnné podle vlastnící domény.

Změna vytváří novou verzi nebo revizi.

## 8.3 Opravy skutečností

Oprava Activity, MetricValue nebo check-inu nesmí odstranit dohledatelnost původního záznamu.

## 8.4 Audit versus historie domény

AuditRecord není náhradou doménové historie.

Doménová historie musí zůstat čitelná i bez interpretace obecných technických auditních diffů.

## 8.5 Soft delete a tombstone

Soft delete se nepoužívá univerzálně.

Každý typ musí definovat, zda používá:

- archive state,
- invalidation,
- tombstone,
- hard delete,
- anonymizaci.

---

# 9. Transakce a constraints

## 9.1 Transakční hranice

Jedna transakce smí měnit pouze data v podporované hranici modulu nebo explicitně definovaného workflow.

## 9.2 Databázové constraints

Invariance, které lze spolehlivě vyjádřit v databázi, mají být podpořeny například:

- NOT NULL,
- UNIQUE,
- FOREIGN KEY,
- CHECK,
- exclusion constraint,
- partial unique index.

Constraint nenahrazuje doménovou validaci, ale chrání proti nekonzistentnímu zápisu.

## 9.3 Optimistic concurrency

Aktualizace musí ověřit očekávanou verzi tam, kde může dojít ke konkurenční změně.

## 9.4 Idempotency

Příkazy s idempotency key musí mít perzistentní záznam výsledku nebo ekvivalentní unique business constraint.

## 9.5 Outbox

Doménová změna a její OutboxMessage se zapisují ve stejné transakci.

---

# 10. Time-series a vysokofrekvenční data

## 10.1 Kategorie

Time-series model se používá například pro:

- tepové vzorky,
- GPS body,
- senzorové série,
- dlouhé MetricSeries,
- monitoring technických systémů.

## 10.2 Oddělení summary a raw dat

Autoritativní obchodní summary musí být odděleno od velkých raw sérií.

Příklad:

- Activity obsahuje summary,
- raw GPS nebo heart-rate samples jsou uloženy v samostatné sérii nebo blob objektu.

## 10.3 Retence raw dat

Raw data mohou mít jinou retenční policy než odvozené summary.

## 10.4 Přepočitatelnost

Odvozené metriky musí ukládat:

- calculation method,
- calculation version,
- input references,
- completeness,
- confidence.

---

# 11. Blob data

Každý blob objekt musí mít minimálně:

- blob ID,
- owner scope,
- purpose,
- MIME type,
- size,
- checksum,
- encryption state,
- createdAt,
- retention class,
- upload state,
- malware or content validation state podle typu.

Přístup se poskytuje krátkodobým autorizovaným mechanismem. Trvalé veřejné URL pro citlivá data jsou zakázané.

Nedokončený upload musí být bezpečně ukliditelný.

---

# 12. Integrace a lineage

## 12.1 Source lineage

Importovaný údaj musí odkazovat na:

- provider,
- connection,
- external record,
- import job,
- provider revision podle dostupnosti.

## 12.2 Canonical mapping

Provider payload se nesmí stát přímo doménovým modelem.

Tok je:

```text
raw provider record
    ↓ validation
normalized external record
    ↓ mapping
canonical domain object
```

## 12.3 Deduplikace

Deduplikace musí být deterministická, auditovatelná a vratná tam, kde hrozí falešné sloučení.

## 12.4 Provider deletion

Smazání u zdroje nesmí automaticky bez policy destruktivně smazat kanonickou Activity nebo MetricValue.

---

# 13. Offline a synchronizace

## 13.1 Server authority

Po serverovém potvrzení je autoritativní serverový stav a verze.

## 13.2 Lokální pending stav

Lokální objekt může mít stav:

- LOCAL_ONLY,
- PENDING_SYNC,
- SYNCED,
- CONFLICTED,
- REJECTED,
- TOMBSTONED.

## 13.3 Change feed

Server poskytuje uspořádaný a stránkovaný change feed s cursor semantikou definovanou budoucím sync kontraktem.

## 13.4 Merge policy

Každý synchronizovaný typ musí určit:

- mergeable fields,
- non-mergeable conflicts,
- server wins případy,
- user review případy,
- tombstone chování.

## 13.5 Aktivní WorkoutSession

Aktivní session vyžaduje časté lokální checkpointy a obnovu bez závislosti na síti.

Serverové zápisy musí být idempotentní a nesmí vytvořit duplicitní set nebo completion.

---

# 14. Read modely a projekce

Projekce musí definovat:

- zdrojové objekty nebo eventy,
- projection version,
- checkpoint,
- rebuild postup,
- maximální tolerovanou zastaralost,
- citlivost,
- owner.

Kritické rozhodnutí se nesmí provádět pouze nad zastaralou projekcí, pokud potřebuje autoritativní stav.

---

# 15. Search

Vyhledávací index je odvozený datový produkt.

Do indexu se ukládá pouze minimum potřebné pro hledání.

Citlivé health, location a authentication údaje nesmí být indexovány bez explicitní potřeby a security review.

Index musí být rekonstruovatelný z autoritativního zdroje.

---

# 16. Data security

## 16.1 Encryption at rest

Citlivá data musí být šifrována v klidu podle security architecture.

## 16.2 Field-level protection

Credential secrets a vysoce citlivé hodnoty se ukládají přes specializovaný secret nebo encrypted value mechanismus, nikoli jako běžný plaintext sloupec.

## 16.3 Row-level ownership

Každý uživatelský objekt musí mít odvoditelný owner nebo access scope.

## 16.4 Log redaction

Databázové chyby, query logy a migration logy nesmí nekontrolovaně obsahovat osobní payloady.

## 16.5 Non-production data

Produkční osobní data se nesmí kopírovat do development nebo test prostředí bez schválené anonymizace a účelu.

---

# 17. Retence, export a mazání

## 17.1 Retention class

Každá hlavní datová kategorie musí mít:

- účel,
- retention class,
- právní základ,
- deletion behavior,
- export behavior.

## 17.2 Smazání účtu

Mazání musí pokrýt:

- autoritativní data,
- read modely,
- cache,
- blob storage,
- analytics,
- search index,
- integration credentials,
- lokální zařízení přes revocation a sync policy.

## 17.3 Právní výjimky

Data uchovávaná z právního důvodu musí být oddělena od aktivního produktového profilu a nesmí být dále používána pro personalizaci.

## 17.4 Export

Export musí zachovat:

- identifikátory,
- timestamps,
- jednotky,
- provenance,
- verze,
- vysvětlení odvozených hodnot.

Secret a interní security údaje se neexportují.

---

# 18. Migrace

## 18.1 Verzionované migrace

Každá změna autoritativního schématu musí být verzovaná, reviewovaná a reprodukovatelná.

## 18.2 Backward-compatible rollout

Preferovaný postup:

1. expand schema,
2. deploy kompatibilní kód,
3. backfill,
4. přepnout reads/writes,
5. odstranit starou strukturu v samostatné verzi.

## 18.3 Backfill

Backfill musí být:

- idempotentní,
- restartovatelný,
- observovatelný,
- omezený proti přetížení,
- auditovatelný.

## 18.4 Destruktivní migrace

Vyžaduje:

- explicitní schválení,
- backup nebo rollback plán,
- ověření kompatibility klientů,
- data-loss review.

## 18.5 Lokální mobilní migrace

Lokální DB migrace musí zachovat pending commands a aktivní WorkoutSession nebo poskytnout bezpečný recovery mechanismus.

---

# 19. Backup a disaster recovery

## 19.1 Rozsah záloh

Backup strategy musí zahrnout:

- transakční databázi,
- blob metadata a objekty,
- kritická konfigurační data,
- encryption key recovery policy,
- schema a migration history.

## 19.2 Obnova

Restore postup musí být pravidelně testovaný, nikoli pouze dokumentovaný.

## 19.3 RPO a RTO

Číselné cíle vycházejí z `NFR-xxx` a musí být potvrzeny před produkčním vydáním.

## 19.4 Point-in-time recovery

Autoritativní databáze má podporovat obnovu na bod v čase, pokud to potvrdí finální ADR a provozní prostředí.

## 19.5 Integritní ověření

Po obnově se musí ověřit:

- constraints,
- počty a checksums,
- outbox stav,
- projekční checkpointy,
- blob reference,
- sync cursors.

---

# 20. Data quality

Každá významná datová pipeline má sledovat:

- completeness,
- validity,
- freshness,
- uniqueness,
- consistency,
- provenance,
- calculation version.

Neplatný import se nesmí tiše proměnit v důvěryhodný kanonický údaj.

Unknown a missing jsou odlišné od nuly nebo false.

---

# 21. Analytics a privacy

Analytics event nesmí být kopií doménového objektu.

Musí být navržen podle konkrétní analytické otázky.

Zakázané výchozí chování:

- odesílat celý profil,
- odesílat text PainReport,
- odesílat AI konverzaci,
- odesílat přesnou GPS trasu,
- odesílat autentizační údaje.

Analytics identity musí být oddělena od veřejných nebo provider identifikátorů podle privacy architecture.

---

# 22. Schema conventions

Fyzická databázová dokumentace musí jednotně definovat:

- naming convention,
- singular/plural policy,
- ID a foreign key názvy,
- timestamps,
- version fields,
- status representation,
- enums versus lookup tables,
- JSON používání,
- index naming,
- constraint naming,
- audit columns.

JSON sloupec se používá pouze pro obsah s jasným verzovaným schématem nebo provider payload, nikoli jako náhrada řádného modelu.

---

# 23. Reference data

Systémová referenční data zahrnují například:

- SportDefinition,
- MetricDefinition,
- body areas,
- unit definitions,
- provider definitions,
- reason codes.

Musí mít:

- stabilní code,
- verzi,
- lokalizovatelný display name mimo doménové jádro,
- lifecycle,
- migrační policy.

Uživatelova vlastní hodnota nesmí být ztracena, pokud systémový katalog položku neobsahuje.

---

# 24. Multi-profile a budoucí tenancy

Datový model musí odlišit:

- account ownership,
- athleteProfile ownership,
- organization membership,
- access grant.

Pouhé `user_id` na každé tabulce není dostatečný budoucí authorization model.

Případná multi-tenancy musí být zavedena ADR a security review; nemá být předstírána předčasným přidáním nejasného `tenant_id` bez významu.

---

# 25. Zakázané anti-patterny

- jedna společná databázová entita `UserData` pro nesouvisející oblasti,
- přímé foreign keys do interních tabulek jiného modulu bez schváleného kontraktu,
- libovolný JSON pro celý doménový objekt,
- ukládání přeložených textů jako doménových kódů,
- přepisování historických verzí,
- používání cache jako zdroje pravdy,
- ukládání access tokenů v plaintextu,
- nekontrolované kopírování produkčních dat,
- analytika jako náhrada auditní historie,
- spoléhání na application validation bez databázových constraints tam, kde jsou možné,
- mazání objektu bez tombstone nebo sync policy,
- provider payload jako kanonická Activity.

---

# 26. Architektonická pravidla

## DAR-001 – Jeden zapisující vlastník

Každý autoritativní datový typ má právě jeden zapisující modul.

## DAR-002 – Relační autoritativní jádro

Obchodní stav používá výchozí transakční relační model; výjimka vyžaduje ADR.

## DAR-003 – Historická interpretovatelnost

Významné změny nesmí destruktivně přepsat historii.

## DAR-004 – Kanonické jednotky

Uživatelská preference nesmí měnit význam uložené hodnoty.

## DAR-005 – Explicitní lineage

Importovaná a odvozená data musí mít dohledatelný původ.

## DAR-006 – Rekonstruovatelné projekce

Read model, cache a search index musí být obnovitelné z autoritativních zdrojů.

## DAR-007 – Offline identita

Objekty vytvářené offline používají stabilní globální identifikátor bez serverové sekvence.

## DAR-008 – Transakční outbox

Doménová změna a její outbox zápis jsou atomické.

## DAR-009 – Klasifikace před implementací

Citlivost dat musí být určena před schválením fyzického schématu.

## DAR-010 – Žádné plaintext secrets

Credential a secret data nesmí být uložena jako běžný plaintext.

## DAR-011 – Verzionované migrace

Každá změna schématu je reprodukovatelná a reviewovaná.

## DAR-012 – Retence podle účelu

Retence, export a deletion se řídí datovou kategorií a účelem, ne jedním univerzálním pravidlem.

## DAR-013 – Bezpečná lokální migrace

Mobilní migrace nesmí ztratit aktivní session nebo neodeslané příkazy bez recovery flow.

## DAR-014 – Specializované storage pouze z potřeby

Nové úložiště vyžaduje měřitelný přínos, vlastní provozní plán a ADR.

## DAR-015 – Unknown není zero

Chybějící, neznámá a nulová hodnota musí zůstat rozlišitelné.

---

# 27. Potřebná ADR

Minimálně:

- server database technology,
- ID format,
- ORM nebo data access strategy,
- schema-per-module versus jiné logické oddělení,
- migration tooling,
- blob storage,
- cache technology,
- time-series strategy,
- search technology,
- analytics storage,
- encryption key management,
- backup and PITR strategy,
- local mobile database.

---

# 28. Navazující implementační dokumenty

Po tomto dokumentu budou postupně potřeba zejména:

```text
docs/12-data/relational-data-model.md
docs/12-data/database-schema.md
docs/12-data/local-data-model.md
docs/12-data/time-series-data.md
docs/12-data/blob-storage.md
docs/12-data/data-migrations.md
docs/12-data/data-quality.md
docs/12-data/data-lineage.md
docs/12-data/backup-and-recovery.md
docs/12-data/retention-and-deletion.md
docs/12-data/data-export-format.md
```

Tyto soubory nevzniknou automaticky všechny najednou. Jejich samostatná potřeba se potvrdí podle fyzických kontraktů a auditovaného plánu.

---

# 29. Kritéria implementation-ready

Dokument může přejít do `IMPLEMENTATION_READY`, až budou:

1. potvrzena hlavní storage ADR,
2. fyzické schema namapováno na všechny CORE agregáty,
3. určeny constraints a indexy,
4. určena data classification,
5. potvrzen local data model a sync protocol,
6. stanoveny retention a deletion policy,
7. otestována migration strategy,
8. potvrzena backup, RPO a RTO strategie,
9. vyřešena time-series a blob data,
10. pravidla `DAR-001` až `DAR-015` namapována na architekturu a testy.

---

# 30. Závěr

Datová architektura AI Traineru stojí na oddělení:

```text
autoritativní doménový stav
    ↓
transakční relační uložení vlastněné modulem
    ↓
outbox a change feed
    ↓
rekonstruovatelné projekce, cache a analytics
```

Velké senzorové nebo binární objekty používají specializované uložení, ale jejich ownership, metadata, klasifikace a životní cyklus zůstávají součástí řízeného datového modelu.

Nejdůležitějším cílem není uložit co nejvíce dat. Cílem je uložit pouze potřebná data způsobem, který je konzistentní, vysvětlitelný, bezpečný, migrovatelný, obnovitelný a dlouhodobě udržitelný.