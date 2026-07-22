# AI Trainer – Mobile Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/08-mobile/mobile-architecture.md`  
**Vlastník:** Mobile Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/04-ux/`, `docs/06-domain/`, `docs/07-backend/backend-architecture.md`, `docs/12-data/data-architecture.md`  
**Navazující dokumenty:** Flutter project structure, state management ADR, local database ADR, routing, sync protocol, authentication flow, background execution, notifications, GPS tracking, health-platform access, mobile testing and release documentation  
**Vlastněné kontrakty:** mobilní architektonický styl, dependency rules, feature boundaries, lokální datový tok, offline command execution, sync orchestrace, app lifecycle, aktivní workout runtime a integrace s platformními službami

---

# 1. Účel dokumentu

Tento dokument definuje cílovou architekturu mobilní aplikace AI Trainer pro Android a iOS.

Mobilní aplikace musí:

- poskytovat rychlé a srozumitelné uživatelské rozhraní,
- fungovat offline pro kritické každodenní scénáře,
- bezpečně ukládat lokální stav,
- podporovat aktivní WorkoutSession bez ztráty dat,
- synchronizovat změny mezi zařízeními,
- respektovat serverovou autoritu a doménové invariance,
- pracovat s notifikacemi, GPS, health platformami a wearables,
- podporovat AI chat a review strukturovaných návrhů,
- zůstat testovatelná, přístupná a rozšiřitelná.

Dokument neurčuje konkrétní balíčky pro state management, routing, databázi, dependency injection ani networking. Tyto volby musí být potvrzeny v ADR.

---

# 2. Výchozí technologický směr

## 2.1 Flutter

Výchozí mobilní klient používá Flutter a Dart pro společný Android a iOS codebase.

Důvody:

- sdílená produktová a doménově orientovaná logika,
- jednotný design system,
- společné testy,
- rychlejší vývoj více platforem,
- možnost nativních adaptérů tam, kde jsou potřeba.

Flutter nesmí vést k ignorování rozdílů mezi Androidem a iOS v:

- background execution,
- permissions,
- health datech,
- notifikacích,
- GPS,
- secure storage,
- lifecycle,
- distribuci a podpisu aplikace.

## 2.2 Nativní integrace

Nativní kód nebo platform channel se použije pouze pokud:

- požadovaná funkce není spolehlivě dostupná ve Flutter vrstvě,
- platforma vyžaduje specifický lifecycle nebo entitlement,
- je nutná bezpečnostní nebo výkonnostní kontrola,
- existuje jasný testovací a fallback plán.

Každý nativní adapter má mít malé, verzované a testovatelné Dart rozhraní.

---

# 3. Architektonické cíle

Mobilní architektura musí:

1. zachovat globální invariance `INV-001` až `INV-100`,
2. naplnit CORE FR a CRITICAL NFR relevantní pro mobilní klient,
3. oddělit UI od application a data logiky,
4. používat lokální databázi jako základ čtení a offline práce,
5. zachovat server jako autoritu sdíleného potvrzeného stavu,
6. podporovat idempotentní offline příkazy,
7. obnovit aktivní WorkoutSession po ukončení procesu nebo restartu,
8. minimalizovat spotřebu baterie, sítě a úložiště,
9. umožnit bezpečný degradovaný režim při výpadku sítě, AI nebo providerů,
10. být rozdělitelná podle features bez společné monolitické state vrstvy.

---

# 4. Logické vrstvy

```text
Presentation
    ↓
Feature application
    ↓
Domain-facing models and policies
    ↓
Repositories / ports
    ↓
Local and remote data sources
    ↓
Platform adapters
```

## 4.1 Presentation layer

Obsahuje:

- obrazovky,
- widgety,
- navigační vstupy,
- zobrazovací modely,
- vizuální stav,
- accessibility semantics,
- lokalizovaný obsah.

Presentation vrstva nesmí:

- přímo volat HTTP klienta,
- přímo zapisovat do databáze,
- rozhodovat doménové invariance,
- přímo spravovat synchronizační frontu,
- interpretovat AI text jako provedenou změnu.

## 4.2 Feature application layer

Koordinuje jeden uživatelský use case.

Příklady:

- StartWorkoutSession,
- CompleteWorkoutSession,
- SubmitDailyCheckIn,
- ReviewAIProposal,
- RescheduleWorkout,
- ResolveSyncConflict.

Application layer:

- přijímá uživatelský záměr,
- ověřuje lokální preconditions,
- vytvoří lokální transakci nebo OfflineCommand,
- aktualizuje lokální read model,
- spustí synchronizaci podle policy,
- vrací strukturovaný výsledek UI.

Nesmí duplikovat autoritativní serverovou business logiku. Lokální validace chrání UX a bezpečnost, server provádí finální validaci sdíleného stavu.

## 4.3 Domain-facing models and policies

Mobilní aplikace používá stabilní klientské modely odvozené z veřejných kontraktů.

Obsahují:

- value objects,
- stavové enumy,
- validační policy potřebné offline,
- safety snapshot,
- synchronizační metadata,
- lokální command modely.

Mobilní klient nemá importovat serverové ORM entity ani interní backendové agregáty.

## 4.4 Repository layer

Repository je jediný podporovaný vstup feature vrstvy k datům.

Repository:

- kombinuje lokální a vzdálený zdroj,
- preferuje lokální observable state pro UI,
- vytváří OfflineCommand pro zapisovatelné operace,
- neukrývá konflikty nebo pending stav,
- mapuje transportní kontrakty na klientské modely.

Repository nesmí být jeden univerzální generic repository pro všechny entity.

## 4.5 Data sources

### Local data source

Odpovídá za:

- lokální transakční databázi,
- secure storage reference,
- cache souborů,
- pending uploads,
- sync metadata,
- recovery checkpoints.

### Remote data source

Odpovídá za:

- autorizované API volání,
- transportní serializaci,
- idempotency metadata,
- cursor-based sync,
- upload/download velkých objektů,
- streamování AI odpovědí podle kontraktu.

### Platform adapter

Odpovídá za:

- permissions,
- notifications,
- background scheduler,
- secure key storage,
- GPS,
- health platforms,
- biometrics,
- app lifecycle,
- connectivity hints.

---

# 5. Feature-first struktura

Doporučená logická struktura:

```text
lib/
├── app/
│   ├── bootstrap/
│   ├── navigation/
│   ├── configuration/
│   └── lifecycle/
├── core/
│   ├── contracts/
│   ├── database/
│   ├── network/
│   ├── sync/
│   ├── security/
│   ├── observability/
│   └── platform/
├── features/
│   ├── identity/
│   ├── onboarding/
│   ├── profile/
│   ├── today/
│   ├── calendar/
│   ├── plans/
│   ├── workouts/
│   ├── activities/
│   ├── recovery/
│   ├── progress/
│   ├── ai_coach/
│   ├── integrations/
│   └── settings/
└── design_system/
```

Každá feature může obsahovat:

```text
feature/
├── presentation/
├── application/
├── domain/
└── data/
```

Feature nesmí číst interní data jiné feature obcházením jejího veřejného rozhraní.

---

# 6. Dependency rules

Povolený směr:

```text
presentation → application → domain-facing abstractions
                           ↓
                       repositories
                           ↓
                    data source adapters
```

Zakázané závislosti:

- domain-facing model na Flutter widget,
- application use case na konkrétní HTTP knihovnu,
- UI na databázový DAO,
- feature na interní DAO jiné feature,
- sync engine na konkrétní obrazovku,
- platform adapter na produktovou navigaci.

Cross-feature komunikace probíhá přes:

- veřejné application facade,
- společný read model s jasným vlastníkem,
- lokální event/change notification,
- navigační kontrakt,
- nikoli přes sdílený mutable global state.

---

# 7. State management

## 7.1 Oddělení stavů

Musí být rozlišeny:

- persistent domain state,
- pending sync state,
- transient UI state,
- navigation state,
- platform permission state,
- active runtime state.

Tyto kategorie se nesmí sloučit do jednoho globálního store.

## 7.2 Zdroj stavu obrazovky

Obrazovka čte observable view state odvozený z:

- lokální databáze,
- application state,
- transient UI inputs,
- sync a permission statusu.

Síťová odpověď sama není dlouhodobým zdrojem UI stavu.

## 7.3 Unidirectional data flow

```text
User intent
    ↓
Application action
    ↓
Local transaction / runtime transition
    ↓
Observable state
    ↓
UI render
```

Vzdálené potvrzení později aktualizuje lokální stav prostřednictvím sync pipeline.

## 7.4 State management ADR

Konkrétní framework musí podporovat:

- explicitní dependency injection,
- lifecycle-aware resources,
- testování bez widget tree,
- granular rebuilds,
- async a stream state,
- error a cancellation handling,
- oddělení feature scope.

---

# 8. Lokální databáze

Lokální databáze je povinnou součástí architektury, nikoli pouze cache HTTP odpovědí.

Musí podporovat:

- transakce,
- schema migrations,
- constraints,
- indexy,
- observable queries,
- deterministické serializace,
- repair a recovery postup,
- bezpečné smazání profilu.

Ukládá minimálně:

- data pro Today a blízký plánovací horizont,
- relevantní profily, sporty a cíle,
- WorkoutInstance a jejich revize,
- aktivní WorkoutSession,
- lokálně vytvořené Activity a check-in,
- aktivní Limitation a SafetyRestriction snapshot,
- OfflineCommand queue,
- SyncOperation a cursor metadata,
- pending upload metadata,
- notifikační plán,
- lokální preference.

Citlivá pole musí používat ochranu definovanou security architecture a local-data ADR.

---

# 9. Offline-first read model

UI čte primárně z lokální databáze.

Online tok:

```text
Local state displayed
    ↓
Background refresh or sync
    ↓
Remote changes validated
    ↓
Local transaction
    ↓
UI updates reactively
```

Offline tok:

```text
Local state displayed
    ↓
User action
    ↓
Local validation
    ↓
Local transaction + OfflineCommand
    ↓
UI displays pending state
```

Síťová nedostupnost nesmí blokovat:

- otevření dnešního plánu,
- spuštění dostupného workoutu,
- záznam série nebo kroku,
- dokončení workoutu,
- základní Activity draft,
- DailyCheckIn,
- PainReport,
- lokální safety reakci podle dostupného snapshotu.

---

# 10. OfflineCommand queue

Každá synchronizovatelná lokální změna používá strukturovaný OfflineCommand.

Obsahuje minimálně:

- commandId,
- commandType,
- athleteProfileId,
- target entity reference,
- base version nebo precondition token,
- payload schema version,
- createdAt,
- sourceDeviceId,
- idempotency key,
- dependency references,
- retry state,
- sensitivity classification.

Stavy:

- LOCAL_PENDING,
- READY_TO_SYNC,
- SENDING,
- SERVER_CONFIRMED,
- RETRYABLE_FAILURE,
- REJECTED,
- CONFLICTED,
- CANCELLED.

Příkaz se po timeoutu nesmí považovat za neprovedený bez idempotentního ověření.

---

# 11. Sync engine

Sync engine je samostatná aplikační infrastruktura nezávislá na konkrétních obrazovkách.

Odpovídá za:

- odesílání pending commands,
- načítání serverových změn pomocí cursoru,
- aplikaci změn v lokální transakci,
- detekci a evidenci konfliktů,
- tombstones,
- aliases po merge,
- pending uploads,
- retry a backoff,
- sync health,
- foreground a podporovaný background režim.

## 11.1 Pořadí synchronizace

Výchozí cyklus:

1. ověřit account a device state,
2. obnovit přerušené requesty podle idempotency,
3. odeslat commands bez nesplněných dependencies,
4. zpracovat serverové výsledky,
5. stáhnout change feed,
6. aplikovat změny a tombstones,
7. aktualizovat cursor,
8. spustit navazující lokální projekce,
9. oznámit sync health.

Přesný wire protocol bude vlastnit samostatný sync contract.

## 11.2 Conflict state

Konflikt nesmí být skryt jako běžný error.

Musí obsahovat:

- conflictId,
- entity reference,
- typ konfliktu,
- lokální a serverovou revision reference,
- bezpečný dočasný stav,
- možnost automatického nebo uživatelského řešení.

---

# 12. Aktivní WorkoutSession

Aktivní workout je nejkritičtější lokální runtime scénář.

## 12.1 Persistence

Každá významná akce se musí uložit lokálně bez závislosti na síti:

- start,
- pause,
- resume,
- set nebo step record,
- změna cviku,
- skip,
- poznámka,
- feedback,
- completion.

UI nesmí držet jedinou kopii session pouze v paměti.

## 12.2 Recovery checkpoint

Checkpoint obsahuje:

- sessionId,
- WorkoutInstanceRevision reference,
- aktuální krok,
- zaznamenané výkony,
- timer anchors,
- pause state,
- poslední potvrzenou lokální sekvenci,
- pending commands,
- last persisted at.

Po restartu aplikace musí být možné session obnovit nebo bezpečně uzavřít.

## 12.3 Časovače

Timer se nesmí spoléhat pouze na běžící periodický callback.

Používá:

- monotonic nebo odpovídající clock pro aktivní interval,
- uložené timestamp anchors,
- dopočet po návratu z backgroundu,
- jasné chování při změně systémového času.

## 12.4 Revision binding

Session musí zůstat navázána na konkrétní WorkoutInstanceRevision, se kterou byla zahájena.

Pozdější změna workoutu nesmí zpětně změnit již zaznamenaný průběh.

---

# 13. Navigation architecture

Navigace musí podporovat:

- declarative route model,
- deep links,
- authentication gates,
- onboarding gates,
- active-profile context,
- modal review flow,
- obnovu navigačního stavu,
- přístupnost,
- bezpečné zpracování neplatného odkazu.

Route nesmí být zdrojem doménového oprávnění. Každá cílová feature ověřuje access scope sama.

Kritické vstupní body:

- Today,
- Calendar,
- active workout,
- AI proposal review,
- pain or recovery flow,
- integration reauthentication,
- notification deep link.

Přesné route IDs a deep-link kontrakty budou v samostatné UX/mobile specifikaci.

---

# 14. Authentication and session handling

Mobilní klient:

- ukládá pouze tokeny a klíče určené pro klienta,
- používá secure platform storage,
- neukládá heslo,
- obnovuje session podle serverového kontraktu,
- reaguje na revokaci zařízení,
- odděluje authentication state od AthleteProfile state,
- čistí chráněná lokální data při logout nebo deletion podle policy.

Citlivé změny mohou vyžadovat recent authentication nebo biometric confirmation.

Offline dostupnost dat po expiraci session se řídí security policy; nesmí automaticky znamenat možnost odesílat autorizované změny.

---

# 15. AI chat a návrhy

## 15.1 Chat transport

Mobilní klient může zobrazovat streamovanou AI odpověď, ale musí rozlišit:

- textovou odpověď,
- strukturovaný AIProposal,
- tool progress,
- potvrzení změny,
- finální ChangeSet result.

Text nesmí být interpretován jako provedená změna.

## 15.2 Proposal review

Review UI čte strukturovaný návrh a zobrazuje:

- navržené operace,
- důvod,
- dopad,
- konflikty,
- potřebné potvrzení,
- stale stav,
- možnost částečného schválení, pokud je povolena.

## 15.3 Výpadek AI

Při nedostupnosti AI musí zůstat dostupné:

- manuální prohlížení a úpravy podporovaných dat,
- tracker,
- calendar,
- recovery input,
- existující plán,
- deterministic safety rules.

---

# 16. Notifications

Mobilní aplikace rozlišuje:

- produktovou NotificationPreference,
- serverový notifikační plán,
- lokálně naplánovanou notifikaci,
- platformní permission state,
- skutečné doručení.

Notifikace musí:

- respektovat timezone a quiet hours,
- používat stabilní entity reference,
- před akcí ověřit aktuální stav,
- být idempotentně naplánovatelná a zrušitelná,
- neobsahovat nepovolený citlivý detail na lock screen.

Lokální notifikace mohou chránit kritické offline reminders; serverové push zprávy slouží pro změny a cross-device události.

---

# 17. Background execution

Background work je best-effort a platformně omezený.

Architektura nesmí předpokládat:

- nepřetržitý běh procesu,
- přesné spuštění jobu v konkrétní sekundě,
- neomezený síťový přístup,
- neomezené GPS na pozadí.

Background úlohy mohou zahrnovat:

- lehký sync,
- dokončení pending uploadu,
- obnovení reminder plánu,
- zpracování provider delivery,
- obnovu chráněné lokální projekce.

Kritické ukládání aktivního workoutu musí probíhat průběžně ve foregroundu a nespoléhat na budoucí background job.

---

# 18. App lifecycle

Musí být explicitně zpracovány:

- cold start,
- warm start,
- foreground,
- inactive,
- background,
- process termination,
- low-memory event,
- OS upgrade,
- app update,
- timezone change,
- locale change,
- permission change,
- account revocation.

Bootstrap pořadí:

1. načíst minimální konfiguraci,
2. otevřít a migrovat lokální databázi,
3. obnovit security/session stav,
4. ověřit active profile context,
5. obnovit aktivní workout checkpoint,
6. spustit UI z lokálních dat,
7. následně spustit sync a remote configuration.

Aplikace nesmí blokovat první použitelný render na nepotřebných síťových požadavcích.

---

# 19. Permissions

Permission flow musí být:

- context-based,
- vysvětlený před systémovým dialogem,
- odložitelný, pokud funkce není kritická,
- schopen fungovat v omezeném režimu,
- opakovatelný přes nastavení aplikace.

Samostatně se řeší:

- notifications,
- precise a approximate location,
- background location,
- health data read/write,
- motion/activity recognition,
- Bluetooth podle integrace,
- camera a files podle funkce.

Produktová preference a platformní permission jsou rozdílné stavy.

---

# 20. GPS a activity recording

GPS recording je samostatný runtime subsystém.

Musí podporovat:

- state machine start/pause/resume/complete,
- průběžné checkpointy,
- práci při dočasné ztrátě signálu,
- quality metadata,
- battery-aware sampling,
- route chunk persistence,
- bezpečný upload velkého záznamu,
- recovery po ukončení procesu podle platformních možností.

GPS data nesmí být přidána do běžných logů nebo analytics.

Přesná platformní implementace a sampling policy budou samostatným kontraktem.

---

# 21. Health platforms a wearables

Mobilní klient používá adaptery pro:

- Apple Health / HealthKit,
- Android Health Connect,
- Apple Watch,
- Wear OS,
- případné provider SDK.

Adapter musí:

- deklarovat capability,
- pracovat s explicitním permission scope,
- zachovat provider provenance,
- podporovat incremental reads,
- deduplikovat opakované delivery,
- reagovat na revokaci,
- izolovat provider-specific typy od domény.

Doménový model nesmí záviset na názvech tříd nebo datových typech konkrétní platformy.

---

# 22. Secure storage a lokální ochrana

Secure storage se používá pro:

- refresh nebo device credential podle auth kontraktu,
- encryption key reference,
- biometric-protected secret,
- device installation identity.

Do běžných preferences se nesmí ukládat:

- tokeny,
- citlivé health hodnoty,
- detail bolesti,
- kompletní GPS trasa,
- AI citlivý kontext.

Screenshot, clipboard, notification preview a backup policy musí být posouzeny podle data classification.

---

# 23. Networking

Network layer musí podporovat:

- timeouty podle typu operace,
- cancellation,
- idempotency keys,
- request correlation,
- autentizační refresh bez paralelního stormu,
- retry pouze pro bezpečné případy,
- response schema versioning,
- upload/download progress,
- redakci citlivých logů.

Connectivity API je pouze hint. Skutečný request může selhat i při hlášeném připojení.

Business chyba, authorization chyba, conflict, rate limit a transport failure musí být odlišné typy výsledku.

---

# 24. Error model

Mobilní aplikace rozlišuje:

- validation error,
- authorization error,
- account restriction,
- conflict,
- stale proposal,
- offline unavailable operation,
- retryable transport error,
- permanent server rejection,
- local database error,
- migration error,
- platform permission error,
- provider failure,
- unexpected defect.

UI zobrazuje bezpečné a akční sdělení. Technický detail jde pouze do redigované telemetry.

Lokální chyba nesmí vést k automatickému smazání pending dat bez recovery a explicitní policy.

---

# 25. Observability and analytics

Mobilní observability obsahuje:

- crash reporting,
- non-fatal errors,
- performance traces,
- sync health,
- database migration result,
- active workout recovery metrics,
- background job result,
- anonymizované produktové analytics podle souhlasu.

Telemetry nesmí obsahovat:

- access token,
- celý AI prompt nebo odpověď,
- PainReport text,
- GPS souřadnice,
- jméno,
- přesný schedule,
- health hodnoty bez schváleného účelu.

Každá událost musí mít definovaný účel, klasifikaci a retention.

---

# 26. Performance

Architektura musí podporovat cíle z NFR zejména pomocí:

- lokálního first renderu,
- granular observable queries,
- lazy loading,
- pagination,
- izolace těžkých výpočtů,
- omezení rebuildů,
- efektivních seznamů a grafů,
- chunked práce s GPS a sensor daty,
- omezení velkých JSON objektů v paměti.

Výkon se měří na definovaných referenčních zařízeních a datasetech.

Velká historie se nesmí načítat celá pro běžnou Today obrazovku.

---

# 27. Battery, storage and network policy

Mobilní klient musí mít policy pro:

- frekvenci background sync,
- GPS sampling,
- retry backoff,
- Wi-Fi versus cellular upload,
- battery saver,
- roaming,
- low-storage režim,
- cleanup cache,
- velikost offline horizontu,
- kompresi a chunking.

Uživatel musí mít kontrolu nad operacemi s výraznou spotřebou dat nebo baterie.

Cleanup nesmí odstranit pending command, aktivní workout ani neodeslaný záznam.

---

# 28. Configuration and feature flags

Konfigurace se dělí na:

- build-time configuration,
- environment configuration,
- remote configuration,
- feature flags,
- user preference,
- server capability.

Feature flag nesmí:

- obejít migraci,
- zpřístupnit neautorizovaná data,
- změnit význam uloženého kontraktu bez verze,
- deaktivovat povinné safety pravidlo.

Aplikace musí bezpečně reagovat na neznámou nebo zastaralou remote configuration.

---

# 29. Compatibility and migrations

Mobilní release musí počítat s:

- starší verzí serveru v rollout okně,
- novější verzí serveru,
- starší lokální databází,
- přerušenou migrací,
- pending commands vytvořenými starší aplikací,
- změnou enumů a reference dat,
- vynuceným upgradem pouze podle schválené policy.

Schema migration musí být:

- verzovaná,
- testovaná z každé podporované verze,
- idempotentní nebo bezpečně obnovitelná,
- chránící pending a historická data.

---

# 30. Testing implications

Mobilní architektura musí umožnit:

- unit testy application use cases,
- repository testy,
- local database migration testy,
- sync state-machine testy,
- widget testy,
- navigation testy,
- golden nebo visual regression testy podle potřeby,
- integration testy s fake serverem,
- offline a reconnect scénáře,
- process-death recovery testy,
- permission testy,
- accessibility testy,
- performance a battery měření,
- platform adapter contract testy.

Kritické testovací scénáře:

1. workout bez sítě,
2. ukončení procesu během workoutu,
3. duplicitní odeslání completion,
4. konflikt mezi dvěma zařízeními,
5. odvolaná session,
6. změna timezone,
7. databázová migrace s pending commands,
8. PainReport offline,
9. stale AIProposal,
10. provider permission revocation.

---

# 31. Build and environment boundaries

Minimální prostředí:

- local development,
- test/CI,
- staging,
- production.

Každé prostředí má oddělené:

- API endpointy,
- auth konfiguraci,
- signing a secrets,
- analytics a crash reporting destination,
- provider credentials,
- feature flags.

Production secret se nesmí nacházet v repozitáři ani běžném Dart source.

---

# 32. Architektonická pravidla

## MAR-001 – Flutter jako společný klient

Hlavní Android a iOS aplikace používají společný Flutter codebase; nativní kód je izolovaný za adapterem.

## MAR-002 – Feature-first modularita

Kód se organizuje primárně podle produktových features a jasných dependency boundaries.

## MAR-003 – UI bez přímého data access

Presentation vrstva nesmí přímo volat HTTP klienta, DAO ani platformní SDK.

## MAR-004 – Lokální databáze jako read source

Běžné obrazovky čtou stav z lokální observable vrstvy, nikoli přímo ze síťové odpovědi.

## MAR-005 – OfflineCommand pro lokální změny

Synchronizovatelné offline změny musí být reprezentovány strukturovaným idempotentním příkazem.

## MAR-006 – Serverová autorita

Po potvrzení synchronizace je server autoritativní pro sdílený stav; klient nesmí tiše přepsat serverový konflikt.

## MAR-007 – Aktivní workout je průběžně persistentní

WorkoutSession nesmí existovat pouze v paměti a musí být obnovitelná z checkpointu.

## MAR-008 – Stabilní revision binding

Aktivní session a historické záznamy zůstávají navázané na konkrétní revision použitou při jejich vzniku.

## MAR-009 – Background je best-effort

Kritická správnost nesmí záviset na přesném nebo nepřetržitém background execution.

## MAR-010 – Platformní oprávnění jsou oddělený stav

Produktová preference, serverový consent a OS permission se nesmí zaměňovat.

## MAR-011 – AI text neprovádí změnu

Mobilní klient provádí změny pouze přes strukturovaný AIProposal, ChangeSet a potvrzovací flow.

## MAR-012 – Citlivá data se nelogují

Tokeny, health detail, GPS, bolest a citlivý AI obsah nesmí vstupovat do běžné telemetry.

## MAR-013 – Explicitní lifecycle

Cold start, background, termination, migration a session recovery musí mít definované chování.

## MAR-014 – Žádný univerzální globální store

Persistentní, UI, runtime, navigation, sync a permission stavy musí zůstat oddělené.

## MAR-015 – Testovatelné adaptery

Network, database, clock, permissions, notifications, GPS, health a secure storage musí být dostupné přes nahraditelná rozhraní.

---

# 33. ADR potřebná před implementací

Minimálně:

- Flutter state management,
- dependency injection,
- routing,
- local database,
- serialization/code generation,
- HTTP and streaming client,
- secure storage and local encryption,
- background execution,
- local notifications,
- crash reporting and analytics,
- platform integration strategy,
- testing and mocking approach.

ADR nesmí měnit doménové invariance ani produktové požadavky; pouze vybírá technickou realizaci.

---

# 34. Otevřené otázky

- Který state-management framework nejlépe splní požadované dependency a testovací vlastnosti?
- Která lokální databáze podporuje potřebné transakce, migrace a observable queries?
- Jaký bude přesný offline data horizon?
- Jak se rozdělí local entities a read models?
- Jak bude verze mobilního sync contractu vyjednávána se serverem?
- Jaké operace budou offline zakázané?
- Jak bude chráněna lokální databáze na Androidu a iOS?
- Jaké platformní minimum verzí bude podporováno?
- Jak bude fungovat process-death recovery GPS aktivity?
- Které výpočty budou lokální a které serverové?
- Jak se bude řešit více aktivních zařízení a active session takeover?
- Jaký streaming protokol použije AI chat?
- Jaké feature flags mohou měnit lokální behavior bez app releasu?
- Jaké telemetry jsou přípustné bez analytics souhlasu?
- Jaké mobile performance budgets budou potvrzeny proof-of-concept měřením?

---

# 35. Kritéria pro `IMPLEMENTATION_READY`

Dokument lze označit jako `IMPLEMENTATION_READY`, až když:

1. jsou přijata klíčová mobile ADR,
2. existuje fyzický local data model,
3. existuje sync protocol,
4. jsou definovány route a deep-link kontrakty,
5. je schválen security model lokálních dat a tokenů,
6. je definován active-workout persistence protokol,
7. jsou potvrzeny background, GPS a notification limity obou platforem,
8. jsou CORE FR a CRITICAL NFR namapovány na mobilní komponenty,
9. existují architecture a migration testy,
10. je definován release a compatibility proces.

---

# 36. Závěr

Mobilní aplikace AI Trainer není tenký online klient. Je to offline-first sportovní runtime, který musí bezpečně fungovat i při ztrátě sítě, ukončení procesu a omezení mobilní platformy.

Základní datový tok je:

```text
User intent
    ↓
Feature application action
    ↓
Local transaction + optional OfflineCommand
    ↓
Observable local state
    ↓
UI update
    ↓
Sync engine
    ↓
Server validation and authority
    ↓
Change feed
    ↓
Local reconciliation
```

Kritický workout tok je:

```text
WorkoutInstanceRevision
    ↓
Start WorkoutSession
    ↓
Persistent local checkpoint after each meaningful action
    ↓
Optional incremental sync
    ↓
Completion command
    ↓
Server confirmation
    ↓
Activity creation and derived processing
```

Architektura musí zajistit, aby uživatel mohl telefon zamknout, ztratit připojení nebo aplikaci znovu otevřít a přesto nepřišel o průběh svého tréninku ani o kontrolu nad změnami.