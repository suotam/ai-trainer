# AI Trainer – Sync and Offline Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/sync-and-offline-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje synchronizační a offline model aplikace AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/screen-specifications.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/training-plan-model.md`,
* `docs/06-domain/workout-model.md`,
* `docs/06-domain/scheduling-model.md`,
* `docs/06-domain/sports-and-goals-model.md`,
* `docs/06-domain/activity-model.md`,
* `docs/06-domain/recovery-and-limitations-model.md`,
* `docs/06-domain/ai-and-change-model.md`,
* `docs/06-domain/metrics-model.md`,
* `docs/06-domain/integration-model.md`.

Dokument popisuje:

* offline-first principy,
* lokální úložiště,
* lokální zdroj stavu,
* serverový zdroj pravdy,
* synchronizační frontu,
* offline příkazy,
* synchronizační operace,
* změnové logy,
* identifikátory vytvářené offline,
* revize objektů,
* optimistic concurrency,
* synchronizaci více zařízení,
* konflikty,
* slučování změn,
* idempotenci,
* retry a backoff,
* pořadí operací,
* závislosti,
* synchronizaci workout trackeru,
* ochranu rozpracované session,
* synchronizaci kalendáře,
* synchronizaci AI návrhů a ChangeSet,
* synchronizaci metrik a aktivit,
* integrace,
* background execution,
* obnovu po pádu aplikace,
* migrace lokální databáze,
* mazání dat,
* šifrování,
* audit,
* diagnostiku a observabilitu.

Dokument zatím neurčuje:

* konkrétní mobilní databázovou knihovnu,
* přesné databázové tabulky,
* konkrétní transportní protokol,
* finální API endpointy,
* konkrétní implementaci background tasků,
* přesnou podobu WebSocket infrastruktury,
* konkrétní cloudovou databázi,
* přesný conflict-resolution algoritmus pro každý objekt.

---

# 2. Cíl synchronizačního modelu

Synchronizační model musí zajistit, aby aplikace byla spolehlivě použitelná:

* bez internetu,
* při nestabilním připojení,
* při přechodu mezi Wi-Fi a mobilní sítí,
* po pádu aplikace,
* po restartu telefonu,
* na více zařízeních,
* při souběžných změnách,
* při opožděném importu z wearables,
* při částečném selhání serveru,
* při neúspěšném AI požadavku,
* při dlouhotrvajícím workoutu,
* při změně časového pásma,
* při aktualizaci aplikace.

Uživatel musí být schopen offline zejména:

* zobrazit dnešní plán,
* zobrazit nejbližší workouty,
* otevřít detail workoutu,
* spustit workout,
* zaznamenávat série a kroky,
* používat časovače,
* pozastavit a dokončit workout,
* vytvořit Activity,
* vytvořit DailyCheckIn,
* nahlásit únavu nebo bolest,
* zobrazit aktivní omezení,
* přesunout flexibilní workout,
* přidat ruční aktivitu,
* upravit základní profilové údaje,
* pracovat s již staženou historií,
* vytvářet lokální změny čekající na synchronizaci.

Offline režim nesmí být pouze nouzová obrazovka.

Musí být přirozenou součástí architektury.

---

# 3. Základní principy

## 3.1 Mobilní aplikace je offline-first

Uživatelské rozhraní má primárně pracovat s lokální databází.

Běžné čtení nemá záviset na okamžité odpovědi serveru.

Zjednodušený tok:

```text
UI
 ↓
Local Application Layer
 ↓
Local Database
 ↓
Sync Engine
 ↓
Backend
```

Ne:

```text
UI
 ↓
Každá obrazovka čeká na server
```

## 3.2 Lokální data jsou okamžitým zdrojem uživatelského stavu

Po provedení uživatelské akce se změna nejprve bezpečně uloží lokálně.

Uživatel nemá čekat na síť pro:

* dokončení série,
* přidání poznámky,
* přesun workoutu,
* vytvoření aktivity,
* změnu subjektivního hodnocení.

## 3.3 Backend je autoritativní pro sdílený dlouhodobý stav

Backend je autoritativní zejména pro:

* synchronizaci mezi zařízeními,
* globální vlastnictví,
* oprávnění,
* aktivní plán,
* definitivní revize,
* serverové výpočty,
* deduplikaci,
* integrace,
* AI návrhy,
* audit,
* pokročilé agregace.

Lokální aplikace může mít plnohodnotný pracovní stav, ale musí být schopna jej bezpečně sladit se serverem.

## 3.4 Uživatel nesmí přijít o lokální skutečnost

Při konfliktu mají zvláštní ochranu:

* dokončené série,
* workout session,
* ručně zadaná Activity,
* PainReport,
* poznámky,
* subjektivní hodnocení,
* GPS data,
* jiná data představující skutečně provedenou činnost.

Serverová změna plánu nesmí tato data slepě odstranit.

## 3.5 Synchronizace musí být idempotentní

Opakované odeslání stejné operace nesmí:

* vytvořit druhý workout,
* přidat sérii dvakrát,
* vytvořit duplicitní Activity,
* opakovaně přesunout událost,
* odeslat několik stejných notifikací,
* aplikovat ChangeSet dvakrát.

## 3.6 Konflikt je normální doménový stav

Konflikt se nemá řešit:

* náhodným posledním zápisem,
* tichým přepsáním,
* odstraněním lokální změny.

Musí být:

* rozpoznán,
* klasifikován,
* automaticky sloučen, pokud je to bezpečné,
* nebo předložen uživateli.

## 3.7 Synchronizace musí být obnovitelná

Každý dlouhý nebo vícekrokový sync proces musí pokračovat po:

* pádu aplikace,
* restartu,
* přerušení sítě,
* ukončení procesu operačním systémem.

## 3.8 Odvozená data lze přepočítat

Zdrojem pravdy jsou primární doménová data.

Například:

* WeeklySummary,
* MetricAggregate,
* ProgressSnapshot,
* cache,
* indexy,

mohou být poškozeny nebo odstraněny a znovu vypočteny.

## 3.9 Bezpečnostní data mají vyšší synchronizační prioritu

Například:

* aktivní Limitation,
* ProfessionalRecommendation,
* blokující SafetyDecision,

mají vyšší prioritu než:

* starší grafy,
* nepovinné přílohy,
* historické agregace.

## 3.10 Offline aplikace nesmí předstírat aktuálnost

Uživatel musí poznat, pokud:

* plán nemusí být aktuální,
* poslední synchronizace je stará,
* čekají neodeslané změny,
* AI nemá aktuální kontext,
* integrace nebyla delší dobu obnovena.

---

# 4. Hlavní objekty synchronizační oblasti

Synchronizační oblast obsahuje minimálně:

* DeviceInstallation,
* DeviceSession,
* LocalEntity,
* LocalEntityVersion,
* SyncableEntityReference,
* SyncState,
* SyncCheckpoint,
* SyncCursor,
* SyncOperation,
* OfflineCommand,
* SyncBatch,
* SyncDependency,
* SyncAttempt,
* SyncResult,
* SyncConflict,
* ConflictResolution,
* MergeDecision,
* Tombstone,
* DeletionMarker,
* IdempotencyRecord,
* PendingUpload,
* PendingDownload,
* LocalChangeLog,
* ServerChangeLog,
* RecoveryCheckpoint,
* BackgroundSyncRequest,
* SyncHealthStatus,
* SyncAuditRecord,
* LocalDatabaseMigration,
* CacheEntry,
* DataRetentionState.

---

# 5. DeviceInstallation

## 5.1 Význam

DeviceInstallation reprezentuje jednu konkrétní instalaci aplikace na zařízení.

Není totožná s uživatelským účtem ani s jedním přihlášením.

## 5.2 Vlastnosti

Obsahuje zejména:

* identifikátor instalace,
* zařízení,
* platformu,
* verzi aplikace,
* verzi lokální databáze,
* vytvoření,
* poslední aktivitu,
* push token reference,
* stav,
* podporované capability,
* poslední synchronizaci,
* bezpečnostní stav.

## 5.3 Platformy

* IOS,
* ANDROID,
* WEB v budoucnu,
* WATCHOS,
* WEAR_OS,
* DESKTOP v budoucnu.

## 5.4 Identifikátor instalace

Musí být:

* stabilní pro životnost instalace,
* znovu vytvořen po kompletní reinstalaci,
* nesmí být odvozen z reklamního identifikátoru,
* nesmí bezdůvodně sledovat uživatele mezi reinstalacemi.

## 5.5 Stav

* ACTIVE,
* REVOKED,
* LOST,
* REPLACED,
* DELETED,
* UNKNOWN.

---

# 6. DeviceSession

## 6.1 Význam

Jedno přihlášení uživatele na instalaci.

## 6.2 Obsah

* uživatele,
* DeviceInstallation,
* čas přihlášení,
* poslední použití,
* stav autorizace,
* token reference,
* lokální účet,
* sync scope.

## 6.3 Odhlášení

Při odhlášení musí být definováno:

* zda se lokální data smažou okamžitě,
* zda zůstanou šifrovaně pro rychlé přihlášení,
* co se stane s neodeslanými změnami,
* zda se vyžaduje potvrzení.

Výchozí bezpečné pravidlo:

Neodeslané změny nesmí být tiše odstraněny.

---

# 7. Lokální databáze

## 7.1 Účel

Lokální databáze uchovává:

* pracovní doménová data,
* read modely,
* offline příkazy,
* synchronizační stav,
* aktivní session,
* cache,
* relevantní bezpečnostní data,
* migrační metadata.

## 7.2 Požadavky

Musí podporovat:

* transakce,
* indexy,
* migrace,
* šifrování nebo bezpečné uložení,
* dostatečný výkon,
* konzistentní zápis při pádu,
* pozorování změn pro UI,
* práci s větším objemem dat,
* mazání podle retention policy.

## 7.3 Kandidátní technologie

Konkrétní volba bude určena později.

Pro Flutter lze zvažovat například:

* Drift nad SQLite,
* Isar,
* ObjectBox,
* jinou prověřenou databázi.

Volba musí respektovat:

* iOS i Android,
* migrace,
* transakce,
* query možnosti,
* stabilitu knihovny,
* dlouhodobou podporu.

## 7.4 Doporučený směr

Pro komplexní relační doménu a explicitní migrace je vhodné silně zvážit SQLite s typově bezpečnou vrstvou.

Finální rozhodnutí patří do `docs/08-mobile/local-database.md`.

---

# 8. LocalEntity

## 8.1 Význam

Lokální reprezentace synchronizovatelného doménového objektu.

## 8.2 Obecná metadata

Každý synchronizovatelný lokální objekt musí mít minimálně:

* entityId,
* entityType,
* ownerId,
* localVersion,
* serverVersion,
* syncState,
* createdAt,
* updatedAt,
* serverUpdatedAt,
* lastSyncedAt,
* isDeleted,
* originDeviceId,
* lastModifiedByDeviceId.

## 8.3 Oddělení doménových a sync polí

Synchronizační metadata nemají zamořit doménovou logiku.

Lze je technicky ukládat:

* ve stejné tabulce,
* nebo v oddělené sync metadata tabulce.

Doménové služby mají pracovat přes jasné rozhraní.

---

# 9. Identifikátory vytvářené offline

## 9.1 Požadavek

Objekty musí být možné vytvořit offline bez čekání na server.

## 9.2 Vhodný formát

Identifikátor má být:

* globálně unikátní,
* vytvářitelný klientem,
* bezpečný pro distribuci,
* pokud možno časově uspořádatelný.

Možnosti:

* UUIDv7,
* ULID,
* jiný globálně unikátní formát.

## 9.3 Doporučení

Použít jednotný globální identifikátor od okamžiku vytvoření.

Nevytvářet:

* lokální dočasné ID,
* které se později nahrazuje serverovým ID,

pokud k tomu není zásadní důvod.

Tím se zjednoduší:

* reference,
* závislosti,
* idempotence,
* synchronizace,
* offline tvorba složitých objektů.

---

# 10. LocalEntityVersion

## 10.1 Význam

Lokální pořadové číslo změny objektu.

## 10.2 Použití

Při každé lokální doménové změně:

* localVersion se zvýší,
* vznikne LocalChangeLog nebo SyncOperation,
* objekt přejde do nečistého sync stavu.

## 10.3 ServerVersion

ServerVersion reprezentuje poslední serverovou verzi, o které zařízení ví.

Při odeslání změny klient posílá:

* očekávanou serverVersion,
* lokální operaci,
* idempotency key.

---

# 11. SyncState

Možné stavy synchronizovatelného objektu:

* LOCAL_ONLY,
* SYNCED,
* DIRTY,
* QUEUED,
* UPLOADING,
* DOWNLOADING,
* CONFLICT,
* SYNC_FAILED,
* DELETED_LOCALLY,
* DELETION_QUEUED,
* TOMBSTONED,
* BLOCKED,
* UNKNOWN.

## 11.1 LOCAL_ONLY

Objekt existuje pouze lokálně a zatím nebyl odeslán.

## 11.2 DIRTY

Lokální verze obsahuje změny od poslední synchronizace.

## 11.3 QUEUED

Odpovídající operace čeká ve frontě.

## 11.4 CONFLICT

Serverová a lokální změna nejsou bezpečně slučitelné.

## 11.5 BLOCKED

Operace nemůže pokračovat kvůli závislosti, oprávnění nebo bezpečnostnímu pravidlu.

---

# 12. LocalChangeLog

## 12.1 Význam

Neměnný lokální záznam významné změny objektu.

## 12.2 Obsah

* changeId,
* entity reference,
* předchozí localVersion,
* novou localVersion,
* typ změny,
* timestamp,
* deviceId,
* userId,
* commandId,
* původní hodnoty nebo diff,
* nové hodnoty nebo diff,
* sync status.

## 12.3 Účel

* vytvoření SyncOperation,
* obnova po pádu,
* audit,
* slučování,
* diagnostika.

## 12.4 Retence

Po potvrzené synchronizaci lze staré technické záznamy:

* komprimovat,
* agregovat,
* odstranit podle policy.

Produktově významný audit se ukládá odděleně.

---

# 13. OfflineCommand

## 13.1 Význam

Doménový příkaz vytvořený lokálně, který může být proveden bez okamžitého serverového spojení.

## 13.2 Příklady

* StartWorkoutSession,
* RecordSetPerformance,
* CompleteWorkoutSession,
* CreateManualActivity,
* RecordDailyCheckIn,
* ReportPain,
* RescheduleScheduleEvent,
* AddWorkoutNote,
* UpdateWorkoutFeedback.

## 13.3 Obsah

* commandId,
* commandType,
* userId,
* deviceId,
* createdAt,
* payload,
* target entities,
* expected versions,
* idempotency key,
* priority,
* dependency ids,
* local execution status,
* remote sync status.

## 13.4 Lokální provedení

OfflineCommand může být:

* plně proveden lokálně a později synchronizován,
* pouze zařazen k serverovému provedení,
* proveden částečně lokálně.

---

# 14. Typy offline příkazů

## 14.1 LOCAL_AUTHORITATIVE

Lokální provedení je plnohodnotné.

Příklad:

* záznam série,
* poznámka,
* vytvoření session.

## 14.2 SERVER_VALIDATED

Lokální změna je dočasná a server ji musí potvrdit.

Příklad:

* změna hlavního cíle,
* změna plánu,
* komplikovaná změna recurrence série.

## 14.3 SERVER_ONLY

Bez serveru nelze bezpečně provést.

Příklad:

* nový komplexní AI plán,
* připojení serverové integrace,
* změna oprávnění,
* serverová deduplikace více poskytovatelů.

## 14.4 LOCAL_FALLBACK

Lokálně lze použít omezenou deterministickou variantu.

Příklad:

* zkrácení workoutu pomocí předem připravené alternativy.

---

# 15. SyncOperation

## 15.1 Význam

Technicky synchronizovatelná operace odvozená z doménového příkazu nebo změny.

## 15.2 Obsah

* operationId,
* idempotencyKey,
* operationType,
* entityType,
* entityId,
* userId,
* deviceId,
* payload,
* expectedServerVersion,
* dependencyIds,
* priority,
* createdAt,
* nextAttemptAt,
* attemptCount,
* state,
* lastError,
* expiration policy.

## 15.3 Rozdíl oproti OfflineCommand

OfflineCommand vyjadřuje doménový záměr.

SyncOperation vyjadřuje přenosovou nebo synchronizační akci.

Jeden OfflineCommand může vytvořit:

* jednu SyncOperation,
* několik závislých operací,
* žádnou samostatnou operaci, pokud je součástí většího ChangeSet.

---

# 16. SyncOperationType

Minimálně:

* CREATE_ENTITY,
* UPDATE_ENTITY,
* DELETE_ENTITY,
* RESTORE_ENTITY,
* APPLY_COMMAND,
* APPEND_EVENT,
* UPLOAD_BLOB,
* DELETE_BLOB,
* LINK_ENTITY,
* UNLINK_ENTITY,
* ACKNOWLEDGE_SERVER_CHANGE,
* REQUEST_RECALCULATION,
* APPLY_CHANGE_SET,
* RESOLVE_CONFLICT,
* CUSTOM.

---

# 17. SyncPriority

* CRITICAL,
* HIGH,
* NORMAL,
* LOW,
* BACKGROUND.

## 17.1 CRITICAL

Například:

* PainReport s významným safety dopadem,
* aktivní blokující Limitation,
* dokončení workoutu s nebezpečnou chybou ukládání,
* zneplatnění přihlášení.

## 17.2 HIGH

* aktivní WorkoutSession,
* dnešní ScheduleEvent,
* aktuální DailyCheckIn,
* dnešní WorkoutModification.

## 17.3 NORMAL

* běžná Activity,
* profilová změna,
* plánované události.

## 17.4 LOW

* starší historie,
* agregace,
* přílohy.

---

# 18. SyncDependency

## 18.1 Význam

Určuje pořadí a závislosti mezi SyncOperation.

## 18.2 Příklady

* WorkoutSession musí být vytvořena před SetPerformance.
* Activity může záviset na dokončené WorkoutSession.
* Příloha musí odkazovat na existující Activity.
* ChangeSet musí být vytvořen před potvrzením jeho aplikace.

## 18.3 Typy

* REQUIRES_SUCCESS,
* REQUIRES_EXISTENCE,
* REQUIRES_VERSION,
* MUST_RUN_BEFORE,
* OPTIONAL,
* COMPENSATES.

## 18.4 Cyklická závislost

Fronta musí detekovat cyklickou závislost a operace zablokovat k diagnostice.

---

# 19. SyncBatch

## 19.1 Význam

Skupina operací odesílaných nebo zpracovávaných společně.

## 19.2 Použití

* efektivnější síťový přenos,
* atomická sada změn,
* synchronizace jednoho agregátu,
* ChangeSet.

## 19.3 Typy

* INDEPENDENT_OPERATIONS,
* ORDERED_OPERATIONS,
* ATOMIC_BATCH,
* BEST_EFFORT_BATCH.

## 19.4 Atomický batch

Server musí buď:

* přijmout všechny povinné operace,
* nebo žádnou.

---

# 20. SyncAttempt

## 20.1 Význam

Jeden konkrétní pokus o synchronizaci operace nebo batch.

## 20.2 Obsah

* attemptId,
* operation nebo batch,
* start,
* end,
* network state,
* request version,
* response status,
* error category,
* retryable,
* server correlation id.

---

# 21. SyncResult

Možné výsledky:

* SUCCESS,
* ALREADY_APPLIED,
* PARTIAL_SUCCESS,
* RETRY_LATER,
* VERSION_CONFLICT,
* VALIDATION_FAILED,
* AUTHENTICATION_REQUIRED,
* PERMISSION_DENIED,
* ENTITY_NOT_FOUND,
* ENTITY_DELETED,
* DEPENDENCY_FAILED,
* SAFETY_BLOCKED,
* PERMANENT_FAILURE,
* UNKNOWN_FAILURE.

## 21.1 ALREADY_APPLIED

Server zná idempotency key a vrátí původní logický výsledek.

---

# 22. IdempotencyRecord

## 22.1 Význam

Serverový nebo lokální záznam již provedené operace.

## 22.2 Obsah

* idempotencyKey,
* userId,
* operationType,
* request hash,
* firstProcessedAt,
* final status,
* result reference,
* expiration.

## 22.3 Rozdílný payload se stejným klíčem

Musí být odmítnut jako chyba.

Stejný idempotency key nesmí být použit pro dvě logicky různé operace.

---

# 23. SyncCursor

## 23.1 Význam

Pozice zařízení v serverovém proudu změn.

## 23.2 Varianty

* globální cursor uživatele,
* cursor podle entity type,
* časový cursor,
* sekvenční server change number,
* continuation token.

## 23.3 Doporučený model

Server má poskytovat monotónní změnovou sekvenci pro uživatelský datový prostor nebo jeho logické části.

Zařízení si ukládá poslední bezpečně aplikovaný cursor.

---

# 24. ServerChangeLog

## 24.1 Význam

Serverový proud změn relevantních pro zařízení.

## 24.2 Záznam obsahuje

* sequence number,
* entity reference,
* change type,
* serverVersion,
* updatedAt,
* případný payload nebo odkaz,
* tombstone,
* source device,
* source actor.

## 24.3 Účel

Klient nemusí pokaždé stahovat celý účet.

Stahuje změny od posledního cursoru.

---

# 25. Pull synchronizace

Doporučený tok:

1. klient odešle poslední cursor,
2. server vrátí dávku změn,
3. klient aplikuje změny v lokální transakci,
4. klient uloží nový cursor až po úspěchu,
5. při přerušení opakuje dávku idempotentně.

---

# 26. Push synchronizace

Doporučený tok:

1. lokální operace je uložena,
2. Sync Engine vybere připravené operace,
3. ověří závislosti,
4. odešle batch,
5. server validuje verze a idempotenci,
6. klient aplikuje serverový výsledek,
7. operace přejde do potvrzeného stavu.

---

# 27. Doporučené pořadí synchronizace

Při aktivaci synchronizace:

1. ověřit přihlášení,
2. odeslat kritické lokální změny,
3. stáhnout kritické serverové změny,
4. zpracovat konflikty aktivních objektů,
5. odeslat ostatní změny,
6. stáhnout ostatní změny,
7. aktualizovat odvozená data,
8. synchronizovat přílohy a velká data.

Přesné pořadí se může lišit podle objektu.

---

# 28. Push-first versus pull-first

## 28.1 Riziko push-first

Klient může odesílat změnu nad zastaralou verzí.

Server ji musí zachytit pomocí expectedServerVersion.

## 28.2 Riziko pull-first

Serverová změna může dočasně přepsat lokální UI před odesláním lokální skutečnosti.

## 28.3 Doporučení

Používat kombinovaný model:

* lokální skutečnost je již bezpečně uložená,
* kritické append-only operace lze odeslat před pull,
* změny editující sdílený objekt se validují proti serverové verzi,
* následně se provede pull a případné merge.

---

# 29. Append-only data

Některé objekty je vhodné synchronizovat jako append-only události.

Příklady:

* SetPerformanceRecorded,
* PainReported,
* DailyCheckInRecorded,
* ActivityFeedbackRecorded,
* časové vzorky.

Výhody:

* menší riziko konfliktu,
* lepší audit,
* snadnější idempotence.

Oprava vytvoří:

* novou revision nebo correction event,

nikoliv neviditelný přepis.

---

# 30. Stavové objekty

Jiné objekty mají aktuální měnitelný stav.

Příklady:

* Goal,
* ScheduleEvent,
* WorkoutInstance,
* UserSport,
* Limitation.

Ty vyžadují:

* verze,
* merge policy,
* conflict detection.

---

# 31. Optimistic concurrency

## 31.1 Princip

Klient při změně objektu posílá očekávanou serverovou verzi.

Server změnu přijme pouze pokud:

```text
expectedVersion == currentVersion
```

nebo pokud je operace bezpečně slučitelná.

## 31.2 Při nesouladu

Server vrátí:

* aktuální serverovou verzi,
* informace o konfliktu,
* případně bezpečný merge návrh.

---

# 32. VersionVector

## 32.1 Možná budoucí potřeba

Pro komplikované vícezařízení merge scénáře může být použit:

* version vector,
* per-field clock,
* CRDT mechanismus.

## 32.2 První verze

Pro většinu objektů je vhodnější:

* serverVersion,
* localVersion,
* expected version,
* objektově specifická merge pravidla.

Plná CRDT architektura by neměla být zavedena bez jasné potřeby.

---

# 33. Last-write-wins

Last-write-wins je povoleno pouze pro nízkoriziková pole, například:

* nepodstatný UI stav,
* poslední otevřená záložka,
* některé preference.

Nemá být použito pro:

* workout výkon,
* aktivní omezení,
* termín workoutu,
* cíle,
* historické aktivity,
* potvrzení AI změny.

---

# 34. SyncConflict

## 34.1 Význam

Strukturovaný konflikt mezi dvěma nebo více změnami.

## 34.2 Obsah

* conflictId,
* userId,
* entity reference,
* typ,
* lokální verzi,
* serverovou verzi,
* společnou základní verzi,
* konfliktní pole nebo operace,
* závažnost,
* automaticky slučitelné části,
* stav,
* createdAt,
* resolution.

---

# 35. Typy konfliktů

* VERSION_MISMATCH,
* FIELD_CONFLICT,
* DELETE_UPDATE_CONFLICT,
* MOVE_MOVE_CONFLICT,
* CREATE_DUPLICATE_CONFLICT,
* STATUS_CONFLICT,
* SESSION_PLAN_CONFLICT,
* SAFETY_CONFLICT,
* OWNERSHIP_CONFLICT,
* RECURRENCE_CONFLICT,
* CHANGE_SET_CONFLICT,
* BLOB_CONFLICT,
* ORDERING_CONFLICT,
* UNKNOWN.

---

# 36. Závažnost konfliktu

* INFORMATIONAL,
* AUTO_RESOLVABLE,
* USER_REVIEW,
* BLOCKING,
* SAFETY_CRITICAL.

## 36.1 AUTO_RESOLVABLE

Například:

* změna názvu a změna poznámky.

## 36.2 USER_REVIEW

Například:

* dva různé termíny stejného workoutu.

## 36.3 SAFETY_CRITICAL

Například:

* jedno zařízení ukončilo zákaz běhu,
* druhé jej prodloužilo.

Do vyřešení se použije konzervativnější bezpečný stav.

---

# 37. Three-way merge

## 37.1 Princip

Při merge se porovnává:

* společná základní verze,
* lokální změna,
* serverová změna.

## 37.2 Výhoda

Lze určit, zda:

* změny upravily různá pole,
* stejné pole,
* nebo navazující struktury.

## 37.3 Příklad

Base:

* název „Upper Body A“,
* čas 18:00.

Lokálně:

* název změněn na „Krátký upper body“.

Server:

* čas změněn na 19:00.

Výsledek lze automaticky sloučit.

---

# 38. Field-level merge policy

Každý synchronizovatelný typ musí mít definováno:

* která pole se slučují,
* která používají server priority,
* která používají user priority,
* která vyžadují konflikt,
* která jsou append-only.

---

# 39. Konflikt WorkoutInstance

## 39.1 Příklady

* dvě zařízení změnila počet sérií,
* jedno workout přesunulo,
* druhé workout zrušilo,
* server vytvořil novou revizi kvůli AI.

## 39.2 Pravidla

* změna času a změna poznámky mohou být sloučeny,
* dvě různé změny stejného cviku vyžadují review,
* zrušení versus dokončení chrání skutečně dokončenou session,
* změna plánu nesmí přepsat aktivní session.

---

# 40. Konflikt aktivní WorkoutSession

## 40.1 Zásadní pravidlo

Aktivní session pokračuje podle revize, se kterou začala.

## 40.2 Server změní WorkoutInstance

Session se uprostřed automaticky nezmění.

Aplikace může zobrazit:

> Plán workoutu byl mezitím upraven na jiném zařízení. Tato rozpracovaná session pokračuje podle původní verze.

## 40.3 Po dokončení

Activity zachová skutečnost.

Serverový plán může být označen:

* odlišný od provedené verze,
* částečně splněný,
* vyžadující ActivityMatch.

---

# 41. Konflikt dvou aktivních session

Příklad:

Stejný workout byl spuštěn na telefonu a hodinkách nebo na dvou telefonech.

Možnosti:

* jedna primární session,
* sloučení kompatibilních záznamů,
* označení druhé jako duplicitní,
* uživatelská kontrola.

## 41.1 Identifikace

Každá session má:

* sessionId,
* deviceId,
* startedAt,
* WorkoutInstance revision.

## 41.2 Automatické rozhodnutí

Je možné pouze při vysoké jistotě.

Například hodinky a telefon mohou být dvě části jednoho společného tracking flow, pokud mají společný correlation id.

---

# 42. Workout tracker – lokální zápis

## 42.1 Každá změna musí být nejprve lokální

Při dokončení série:

1. uložit SetPerformance,
2. uložit změnu session,
3. aktualizovat UI,
4. vytvořit sync operaci,
5. případně spustit background sync.

## 42.2 Transakce

Zápis SetPerformance a aktualizace session progress musí být v jedné lokální transakci.

## 42.3 Odezva UI

Nemá záviset na serveru.

---

# 43. Workout tracker – autosave

Autosave se spouští minimálně při:

* dokončení série,
* změně hodnoty,
* přeskočení kroku,
* náhradě cviku,
* přesunu mezi kroky,
* pozastavení,
* změně časovače relevantní pro stav,
* přechodu aplikace na pozadí,
* ukončení aplikace, pokud systém dovolí,
* hlášení bolesti.

---

# 44. RecoveryCheckpoint

## 44.1 Význam

Kompaktní snapshot rozpracované operace pro obnovu po pádu.

## 44.2 U WorkoutSession obsahuje

* sessionId,
* workout revision,
* aktuální sekci,
* aktuální krok,
* dokončené výkony,
* aktivní časovače,
* paused state,
* poslední bezpečný timestamp,
* neodeslané změny.

## 44.3 U GPS aktivity obsahuje

* activityId,
* poslední uložený bod,
* aktivní segment,
* časové údaje,
* stav senzoru.

---

# 45. Obnova workoutu po pádu

Při spuštění aplikace:

1. vyhledat nedokončené aktivní session,
2. ověřit integritu checkpointu,
3. zobrazit nabídku pokračovat,
4. obnovit časovače podle timestampů,
5. neodvozovat čas pouze z paměťového countdownu,
6. zachovat všechny dokončené série.

---

# 46. Časovače a offline režim

Časovač musí být založen na:

* startedAt,
* expectedEndAt,
* paused intervals,

nikoliv pouze na inkrementu v paměti.

Při:

* zamknutí telefonu,
* ukončení procesu,
* změně systémového času,

musí aplikace správně dopočítat stav.

## 46.1 Monotonic clock

Pro krátkodobé aktivní měření lze použít monotonic clock.

Pro obnovu po restartu je nutné mít také absolutní timestamp.

---

# 47. Dokončení WorkoutSession offline

Po dokončení:

* session přejde do lokálního COMPLETED nebo PARTIALLY_COMPLETED,
* vznikne lokální Activity,
* WorkoutInstance se lokálně označí podle výsledku,
* vytvoří se závislé SyncOperation,
* uživatel vidí workout jako dokončený.

Server může později:

* potvrdit,
* vyřešit konflikt,
* propojit s aktualizovaným plánem.

---

# 48. Ochrana dokončeného výkonu

Pokud server tvrdí, že WorkoutInstance byla mezitím:

* zrušena,
* přesunuta,
* nahrazena,

lokálně dokončená Activity se nesmí odstranit.

Možný výsledný stav:

* Activity zůstane,
* původní ScheduleEvent se označí podle serveru,
* ActivityMatch bude vyžadovat přehodnocení.

---

# 49. Synchronizace SetPerformance

## 49.1 Doporučený model

SetPerformance má stabilní ID.

Každá série se synchronizuje jako:

* vytvoření,
* případně auditovaná oprava.

## 49.2 Duplicitní odeslání

Stejné setId se nesmí vytvořit dvakrát.

## 49.3 Přidaná série

Uživatel může offline přidat sérii s novým ID.

Server ji zařadí podle:

* sequence,
* parent exercise,
* createdAt.

---

# 50. Pořadí workout kroků

Při lokálním přeskupení kroků lze použít:

* explicitní sequence number,
* order key,
* fractional indexing.

## 50.1 Konflikt pořadí

Dvě souběžné změny pořadí stejného seznamu mohou vyžadovat review.

Pro první verzi lze komplikované souběžné přeskupení omezit.

---

# 51. Synchronizace ScheduleEvent

ScheduleEvent vyžaduje:

* expected server version,
* původní čas,
* nový čas,
* časové pásmo,
* recurrence kontext,
* change scope.

## 51.1 Přesun jedné události offline

Může být proveden, pokud:

* instance je lokálně dostupná,
* nejde o složitou nematerializovanou část série,
* jsou dostupná validační pravidla.

## 51.2 Změna celé recurrence série offline

Může být:

* uložena jako pending proposal,
* nebo provedena pouze při dostatečném lokálním kontextu.

První verze může vyžadovat online potvrzení.

---

# 52. Kalendářní konflikt mezi zařízeními

Příklad:

* telefon přesune workout na úterý 18:00,
* tablet na středu 17:00.

Výsledek:

* MOVE_MOVE_CONFLICT,
* žádný termín se nemá náhodně zahodit,
* uživatel vidí obě možnosti,
* po výběru vznikne ConflictResolution.

---

# 53. ConflictResolution

## 53.1 Význam

Strukturované rozhodnutí o konfliktu.

## 53.2 Typy

* USE_LOCAL,
* USE_SERVER,
* MERGE,
* KEEP_BOTH,
* CREATE_NEW_VERSION,
* CANCEL_LOCAL_CHANGE,
* COMPENSATE,
* MANUAL_CUSTOM_VALUE,
* DEFER.

## 53.3 Obsah

* conflictId,
* aktéra,
* rozhodnutí,
* výsledné hodnoty,
* čas,
* nové serverVersion,
* audit.

---

# 54. MergeDecision

U automatického merge obsahuje:

* použitá pravidla,
* sloučená pole,
* konfliktní pole,
* confidence,
* rule version.

Musí být dohledatelné, proč systém zvolil výsledek.

---

# 55. Conflict UI

Uživatel nemá vidět technické JSON diffy.

Má vidět například:

**Workout Upper Body A**

* Tento telefon: středa 18:00
* Jiné zařízení: čtvrtek 19:00

Akce:

* použít středu,
* použít čtvrtek,
* vybrat jiný čas.

---

# 56. Konflikty, které nemají zatěžovat uživatele

Automaticky se mají řešit například:

* změna lokálního read stavu,
* aktualizace cache,
* nekolidující pole,
* duplicitní potvrzení stejné akce,
* opakovaný import stejného objektu.

---

# 57. Delete a Tombstone

## 57.1 Problém

Pokud server objekt fyzicky smaže, offline zařízení by jej mohlo později znovu nahrát.

## 57.2 Tombstone

Tombstone reprezentuje informaci:

* objekt byl odstraněn,
* v jaké verzi,
* kdy,
* kým,
* zda lze obnovit.

## 57.3 Retence tombstone

Musí být dostatečně dlouhá, aby pokryla:

* zařízení dlouho offline,
* opožděnou synchronizaci,
* obnovení ze zálohy.

---

# 58. Delete-update conflict

Příklad:

* server odstranil koncept workoutu,
* offline zařízení ho mezitím upravilo.

Možnosti:

* obnovit jako nový objekt,
* zachovat odstranění,
* uživatelská kontrola.

U historické skutečnosti se preferuje ochrana dat.

---

# 59. Soft delete

Pro významné doménové objekty se běžně používá:

* CANCELLED,
* ARCHIVED,
* INVALID,
* DELETED marker,

namísto okamžitého fyzického smazání.

Výhoda:

* audit,
* synchronizace,
* možnost obnovy,
* zachování referencí.

---

# 60. DeletionMarker

Obsahuje:

* entity reference,
* deletedAt,
* deletedBy,
* reason,
* previousVersion,
* restoration policy,
* retentionUntil.

---

# 61. Obnova objektu

Restore musí být:

* nová verze objektu,
* auditovaná,
* kompatibilní s aktuálními vazbami.

Obnova se nesmí provést, pokud:

* ID bylo právně trvale smazáno,
* objekt patří jinému účtu,
* aktuální stav je nekompatibilní.

---

# 62. Synchronizace Activity

Activity může vzniknout:

* z WorkoutSession,
* ručně,
* z integrace,
* z GPS.

## 62.1 Offline Activity

Má:

* lokální ID,
* source,
* metriky,
* sync metadata,
* případné source records.

## 62.2 Serverová deduplikace

Po synchronizaci může server zjistit, že Activity odpovídá již importovanému wearable záznamu.

Výsledek:

* Activity se sloučí,
* lokální ID může zůstat jako alias nebo merged reference,
* lokální UI obdrží mapování.

---

# 63. Entity aliasing

## 63.1 Význam

Dva dříve samostatné objekty byly sloučeny.

## 63.2 EntityAlias obsahuje

* oldEntityId,
* canonicalEntityId,
* reason,
* createdAt,
* source.

## 63.3 Klient

Při obdržení aliasu:

* aktualizuje reference,
* neztratí lokální vazby,
* označí starý objekt jako merged.

---

# 64. Synchronizace MetricValue

Každá MetricValue má:

* stabilní ID,
* definition,
* unit,
* source,
* timestamp,
* revision.

## 64.1 Časové řady

Vysokofrekvenční samples se nesynchronizují vždy jednotlivě jako běžné API příkazy.

Mohou být:

* batchované,
* komprimované,
* chunkované,
* uložené jako blob.

---

# 65. PendingUpload

## 65.1 Význam

Velký nebo binární obsah čekající na upload.

## 65.2 Příklady

* GPS trasa,
* FIT soubor,
* foto,
* video,
* dlouhá časová řada,
* diagnostický balíček.

## 65.3 Obsah

* uploadId,
* local path,
* checksum,
* size,
* mime type,
* target object,
* chunk state,
* encryption state,
* retry policy.

---

# 66. Chunked upload

Velká data se mohou nahrávat po částech.

Požadavky:

* obnovitelnost,
* checksum,
* potvrzení jednotlivých chunků,
* dokončovací krok,
* idempotence.

---

# 67. Download velkých dat

Historická časová řada nebo příloha nemusí být automaticky uložena offline.

Může používat stav:

* NOT_CACHED,
* DOWNLOAD_QUEUED,
* CACHED,
* EXPIRED,
* FAILED.

---

# 68. CacheEntry

## 68.1 Význam

Lokálně uložený odvozený nebo vzdálený obsah, který lze znovu stáhnout.

## 68.2 Obsah

* cache key,
* object reference,
* version,
* local path nebo payload,
* createdAt,
* expiresAt,
* lastAccessedAt,
* size,
* eviction priority.

## 68.3 Cache není primární offline změna

Neodeslané uživatelské změny nesmí být uloženy pouze v evictable cache.

---

# 69. Retence lokálních dat

Lokální zařízení nemusí uchovávat celý účet.

Musí být definován rozsah:

* aktivní plán,
* nejbližší týdny,
* aktivní cíle,
* aktivní omezení,
* rozpracované session,
* nedávné aktivity,
* potřebné metriky,
* uživatelsky stažená historie.

---

# 70. Doporučený základní offline rozsah

Minimálně:

* dnešek,
* předchozích 7–14 dní,
* následujících 30–60 dní,
* aktivní TrainingPlan,
* WorkoutTemplate potřebné pro instance,
* aktivní UserSport,
* aktivní Goal,
* aktivní Limitation,
* nejnovější recovery kontext,
* rozpracované Activity,
* neodeslané změny.

Přesná čísla budou produktově upravena.

---

# 71. Offline dostupná historie

Uživatel může mít možnost označit:

* konkrétní období,
* konkrétní plán,
* konkrétní sport,

jako dostupné offline.

---

# 72. Data eviction

Při nedostatku místa se mohou odstranit:

1. expirovaná cache,
2. staré read modely,
3. znovu stáhnutelné přílohy,
4. archivované časové řady,
5. starší doménová data pouze podle bezpečné policy.

Nikdy se automaticky nesmí odstranit:

* neodeslané změny,
* aktivní session,
* nedokončený GPS záznam,
* aktivní safety data,
* čekající ConflictResolution.

---

# 73. Lokální šifrování

Citlivá data musí být chráněna pomocí:

* šifrovaného úložiště,
* platformního keychain/keystore,
* případně databázového šifrování,
* omezení záloh.

## 73.1 Citlivé lokální údaje

* PainReport,
* Limitation,
* spánek,
* biometrické metriky,
* GPS,
* token reference,
* AI citlivý kontext.

---

# 74. Klíče

Šifrovací klíče se nemají ukládat přímo vedle databáze v otevřené podobě.

Musí využívat:

* iOS Keychain,
* Android Keystore,
* případně hardware-backed ochranu.

---

# 75. Záloha zařízení

Musí být rozhodnuto, zda lokální databáze:

* smí být součástí cloudové zálohy zařízení,
* má být vyloučena,
* nebo šifrována tak, aby nebyla mimo aplikaci použitelná.

Neodeslaná data nesmí být ztracena bez zvážení dopadu.

---

# 76. Přihlášení jiného uživatele

Na jednom zařízení může být postupně přihlášeno více účtů.

Data musí být:

* oddělena podle userId,
* šifrovaná,
* nesmí se zobrazit jinému účtu,
* při změně účtu se musí vyčistit paměťové cache.

---

# 77. Odhlášení s neodeslanými změnami

Aplikace musí zobrazit například:

> Na zařízení jsou 3 změny, které ještě nebyly synchronizovány.

Možnosti podle policy:

* synchronizovat nyní,
* bezpečně ponechat v zařízení,
* exportovat,
* zahodit s explicitním potvrzením.

---

# 78. Smazání účtu

Po potvrzeném smazání účtu:

* server zahájí proces odstranění,
* zařízení obdrží revoke stav,
* lokální data se bezpečně odstraní,
* neodeslané změny se již nesmí znovu synchronizovat,
* tokeny se zneplatní.

---

# 79. BackgroundSyncRequest

## 79.1 Význam

Požadavek na synchronizaci provedenou mimo aktivní UI.

## 79.2 Důvody

* nová lokální změna,
* push notification,
* periodický refresh,
* připojení k síti,
* nabíjení,
* dokončení workoutu,
* blížící se workout,
* integration import.

---

# 80. Background sync na Androidu

Může používat například:

* WorkManager,
* foreground service pro aktivní tracking,
* platformní constraints.

Musí respektovat:

* baterii,
* síť,
* Doze,
* omezení background execution,
* uživatelská oprávnění.

---

# 81. Background sync na iOS

Může používat:

* BGAppRefreshTask,
* BGProcessingTask,
* background URLSession,
* HealthKit delivery podle podpory,
* push notifications.

iOS negarantuje přesný čas spuštění.

Architektura nesmí záviset na tom, že background sync proběhne přesně v určitou minutu.

---

# 82. Foreground service

Při dlouhém aktivním GPS trackingu na Androidu může být nutný foreground service.

Musí mít:

* viditelnou notifikaci,
* jasný uživatelský účel,
* možnost ukončení,
* bezpečné checkpointy.

---

# 83. NetworkState

Sync Engine může sledovat:

* OFFLINE,
* CONNECTED_METERED,
* CONNECTED_UNMETERED,
* ROAMING,
* CAPTIVE_PORTAL,
* UNKNOWN.

Velké uploady mohou být podle preference omezeny na Wi-Fi.

Kritické malé operace mají přednost.

---

# 84. BatteryState

Velké background operace mohou respektovat:

* stav nabíjení,
* nízkou baterii,
* power saving mode.

Aktivní workout zápis se však nesmí zastavit kvůli šetření baterie.

---

# 85. RetryPolicy

## 85.1 Automaticky opakovatelné chyby

* timeout,
* dočasné odpojení,
* server 5xx,
* rate limit,
* background task termination,
* dočasný storage lock.

## 85.2 Neopakovat bez zásahu

* validation failure,
* permission denied,
* authentication revoked,
* ownership conflict,
* safety block,
* schema incompatibility.

---

# 86. Exponential backoff

Další pokus se může řídit:

```text
delay = min(base × 2^attempt + jitter, maximumDelay)
```

Přesné hodnoty budou určeny technickou specifikací.

---

# 87. Retry limit

Po překročení limitu operace přejde do:

* SYNC_FAILED,
* USER_ACTION_REQUIRED,
* DEAD_LETTER.

Nesmí z fronty tiše zmizet.

---

# 88. Dead-letter queue

## 88.1 Význam

Operace, které nelze automaticky dokončit.

## 88.2 Důvody

* nekompatibilní schema,
* opakovaná trvalá chyba,
* neexistující reference,
* poškozený payload,
* zrušené oprávnění.

## 88.3 Uživatelská komunikace

Uživatel má dostat srozumitelnou akci pouze pokud ji může řešit.

Technické detaily zůstávají pro diagnostiku.

---

# 89. SyncHealthStatus

Možné stavy:

* HEALTHY,
* SYNCING,
* OFFLINE,
* CHANGES_PENDING,
* DELAYED,
* CONFLICTS_PENDING,
* ACTION_REQUIRED,
* DEGRADED,
* FAILED,
* UNKNOWN.

## 89.1 UI

Běžný uživatel nemusí vidět sync ikonu při každém krátkém přenosu.

Musí ji vidět při:

* neodeslaných změnách,
* konfliktu,
* dlouhém zpoždění,
* chybě,
* offline zastaralosti.

---

# 90. LastSyncedAt

Jedno globální datum poslední synchronizace může být zavádějící.

Je vhodné sledovat:

* lastSuccessfulPushAt,
* lastSuccessfulPullAt,
* lastCriticalSyncAt,
* lastFullSyncAt,
* lastIntegrationSyncAt.

UI může zobrazit zjednodušenou informaci.

---

# 91. Freshness model

Lokální data mohou mít stav:

* CURRENT,
* RECENT,
* STALE,
* VERY_STALE,
* UNKNOWN.

Freshness závisí na typu objektu.

Například:

* plán může být aktuální několik hodin,
* readiness jen omezenou dobu,
* historická Activity je stabilní.

---

# 92. Push notification jako sync trigger

Push zpráva nemá obsahovat kompletní citlivá data.

Může obsahovat:

* typ změny,
* bezpečný cursor hint,
* entity type,
* obecný sync požadavek.

Klient následně načte data autorizovaným API.

---

# 93. Real-time sync

Pro aktivní obrazovky lze použít:

* WebSocket,
* server-sent events,
* push notifications,
* krátký polling.

Real-time vrstva je doplněk.

Zdroj pravdy zůstává:

* lokální databáze,
* verzovaný serverový sync protokol.

---

# 94. WebSocket výpadek

Při odpojení:

* UI dál používá lokální data,
* změny se frontují,
* po obnovení se provede cursor-based sync,
* nespoléhá se na to, že nebyla ztracena žádná real-time zpráva.

---

# 95. Full resync

## 95.1 Kdy je potřebný

* neplatný cursor,
* dlouhá neaktivita,
* poškozený lokální index,
* schema migrace,
* serverová oprava,
* nesoulad integrity.

## 95.2 Full resync nesmí

* odstranit neodeslané lokální změny,
* přepsat aktivní session,
* zničit lokální konflikty.

## 95.3 Doporučený postup

1. zazálohovat pending změny,
2. stáhnout serverový snapshot,
3. znovu aplikovat nebo merge lokální změny,
4. vytvořit konflikty,
5. obnovit frontu.

---

# 96. SyncCheckpoint

## 96.1 Význam

Trvalý bod úspěšně dokončené synchronizace.

## 96.2 Obsah

* cursor,
* timestamp,
* deviceId,
* server snapshot version,
* pending operation watermark,
* checksum nebo integrity data.

---

# 97. Integrita lokální databáze

Aplikace musí umět detekovat:

* poškozené schéma,
* neplatné reference,
* chybějící parent objekt,
* duplicitní operation ID,
* cyklické dependency,
* neplatný cursor.

---

# 98. Local repair

Možné opravy:

* přepočet read modelu,
* obnova indexu,
* odstranění expirované cache,
* stažení chybějícího parent objektu,
* rekonstrukce SyncOperation z LocalChangeLog.

Primární neodeslaná data se nesmí automaticky odstranit.

---

# 99. LocalDatabaseMigration

## 99.1 Význam

Přechod mezi verzemi lokálního schématu.

## 99.2 Obsah

* fromVersion,
* toVersion,
* status,
* startedAt,
* completedAt,
* backup reference,
* error,
* rollback capability.

## 99.3 Požadavky

Migrace musí být:

* deterministická,
* testovaná na reálných velikostech dat,
* bezpečná pro pending změny,
* obnovitelná.

---

# 100. Destruktivní migrace

Nesmí být použita na produkční uživatelská data bez:

* zálohy,
* serverového snapshotu,
* ochrany neodeslaných změn,
* explicitní migrační strategie.

---

# 101. Aplikace starší verze

Server musí podporovat:

* minimální podporovanou app version,
* schema capability negotiation,
* postupné ukončení starých kontraktů.

Pokud je aplikace příliš stará:

* nesmí odesílat nekompatibilní změny,
* musí uživatele požádat o aktualizaci,
* offline data musí zůstat bezpečně uložená.

---

# 102. SchemaVersion

Každý sync payload musí mít:

* schema version,
* případně command version,
* entity version.

Server musí odmítnout neznámé nebezpečné schéma s jasnou chybou.

---

# 103. Forward compatibility

Klient má ignorovat neznámá volitelná pole.

Nesmí ignorovat:

* nové blokující safety pole,
* změnu významu povinného stavu,
* neznámou kritickou operation type.

---

# 104. Backward compatibility

Server může:

* transformovat starší command verzi,
* vrátit kompatibilní read model,
* vyžádat upgrade.

Kompatibilita musí být časově omezená a sledovaná.

---

# 105. Synchronizace AIConversation

## 105.1 Offline zpráva

Uživatel může offline napsat zprávu.

Vznikne:

* lokální AIMessage se stavem PENDING_SEND,
* sync operation.

## 105.2 Bez zpracování

Aplikace nesmí zobrazit AI odpověď, dokud nebyla skutečně vytvořena.

## 105.3 Po připojení

Zpráva se odešle se:

* stabilním messageId,
* conversationId,
* context version,
* timestampem.

---

# 106. Zastaralý AI kontext

Pokud byl prompt napsán offline a mezitím se změnil plán:

* server musí detekovat starý context reference,
* AI může požádat o potvrzení aktuálního významu,
* nebo návrh vytvořit proti novému stavu a uvést změnu.

---

# 107. Synchronizace AIProposal

AIProposal musí synchronizovat:

* proposalId,
* revision,
* stav,
* referenční verze,
* rozhodnutí,
* platnost.

## 107.1 Schválení offline

Lze povolit pouze pokud:

* celý Proposal je lokálně dostupný,
* není expirovaný podle dostupných dat,
* confirmation policy to dovoluje.

Server může po synchronizaci schválení odmítnout jako STALE.

Lokální UI musí stav opravit.

---

# 108. Synchronizace ChangeSet

ChangeSet je citlivý na verze.

Offline lze vytvořit:

* uživatelský ChangeSet,
* nebo lokální command set.

Při serverovém provedení:

* znovu validovat,
* znovu autorizovat,
* ověřit safety,
* ověřit očekávané verze.

---

# 109. Duplicitní schválení ChangeSet

Dvě zařízení mohou schválit stejný ChangeSet.

Idempotency a state machine musí zajistit:

* jednu aplikaci,
* další schválení vrátí aktuální stav,
* žádná dvojitá změna.

---

# 110. Konflikt ProposalDecision

První platné finální rozhodnutí může uzamknout revizi.

Pozdější rozhodnutí:

* se zaznamená jako neplatný pokus,
* uživatel uvidí aktuální stav,
* nebude aplikováno.

---

# 111. Synchronizace Goal

Goal vyžaduje verzi.

Automaticky lze sloučit například:

* změnu poznámky,
* změnu připomenutí.

Konflikt vyžadují:

* dvě různé target hodnoty,
* změna PRIMARY priority,
* completed versus abandoned,
* změna cílového data na různé hodnoty.

---

# 112. Synchronizace Limitation

## 112.1 Konzervativní merge

Při konfliktu bezpečnostních omezení se dočasně použije přísnější kompatibilní stav.

## 112.2 Příklad

Lokálně:

* omezení ukončeno.

Server:

* omezení prodlouženo.

Výsledek:

* SAFETY_CONFLICT,
* dočasně zůstane aktivní,
* vyžaduje review.

---

# 113. Synchronizace PainReport

PainReport je historický záznam.

Novější report nemá přepisovat starší.

Oprava starého reportu vytvoří:

* PainReportRevision,
* nebo Correction.

---

# 114. Synchronizace DailyCheckIn

Více check-inů ve stejný den může být validních.

Musí se rozlišit:

* MORNING,
* PRE_WORKOUT,
* AD_HOC,
* jejich timestamp.

Nemají se slučovat pouze podle kalendářního data.

---

# 115. Synchronizace MetricSeries

Časové řady mohou být rozděleny na chunckované segmenty.

Každý segment má:

* seriesId,
* chunkId,
* časový rozsah,
* checksum,
* počet vzorků,
* sequence.

Server musí detekovat:

* překryv,
* duplicitu,
* chybějící chunk.

---

# 116. Synchronizace GPS aktivity

Během záznamu:

* data se ukládají lokálně,
* mohou se průběžně uploadovat,
* ale lokální tracker nesmí záviset na uploadu.

Po ukončení:

* dokončí se lokální Activity,
* upload se obnovuje na pozadí,
* souhrn může být synchronizován dříve než celá trasa.

---

# 117. Trasa bez dokončeného uploadu

Serverová Activity může mít stav:

* routeUploadPending.

Uživatel vidí aktivitu a základní metriky.

Mapa se zobrazí po dokončení synchronizace.

---

# 118. Synchronizace příloh

Příloha má samostatný lifecycle.

Activity nesmí být označena jako nesynchronizovaná jen kvůli nepovinné fotografii, pokud její hlavní data jsou bezpečně synchronizována.

---

# 119. Integrace a sync model

Provider sync a device sync jsou oddělené procesy.

Příklad:

```text
Garmin
 ↓
Backend Integration Pipeline
 ↓
Server Activity
 ↓
Device Sync
 ↓
Local Activity
```

A:

```text
Health Connect
 ↓
Mobile Integration Adapter
 ↓
Local ExternalDataRecord
 ↓
Device Sync
 ↓
Backend Import Pipeline
```

---

# 120. Provider conflict a device conflict

Musí být rozlišeno:

* konflikt dvou externích zdrojů,
* konflikt lokálního a serverového objektu,
* konflikt dvou zařízení,
* konflikt importu a ručního vstupu.

Mohou se kombinovat, ale řeší je různé služby.

---

# 121. Synchronizace notifikací

Notifikace mohou být:

* lokálně naplánované,
* serverově odesílané,
* kombinované.

## 121.1 Lokální notifikace

Výhody:

* fungují offline,
* přesný vztah k lokálnímu kalendáři.

## 121.2 Serverové notifikace

Výhody:

* centralizovaná pravidla,
* reakce na serverové změny.

## 121.3 Konflikt

Po přesunu workoutu musí být:

* stará notifikace zrušena,
* nová vytvořena,
* idempotentně.

---

# 122. NotificationScheduleVersion

Každé plánování notifikace může mít:

* eventId,
* eventVersion,
* reminderId,
* scheduleVersion.

Stará notifikace se před zobrazením nebo po otevření ověří proti aktuálnímu stavu, pokud je to možné.

---

# 123. Deep link do zastaralého objektu

Pokud uživatel otevře notifikaci na:

* přesunutý,
* zrušený,
* nahrazený workout,

aplikace musí otevřít aktuální stav nebo srozumitelné vysvětlení.

---

# 124. Multi-device presence

Server může evidovat:

* aktivní zařízení,
* poslední sync,
* zařízení s pending konfliktem,
* aktivní WorkoutSession.

To umožní například upozornit:

> Tento workout už je spuštěný na jiném zařízení.

---

# 125. Device trust

Zařízení může mít stav:

* TRUSTED,
* NEW,
* REAUTHENTICATION_REQUIRED,
* REVOKED.

Citlivé operace mohou vyžadovat:

* nedávné přihlášení,
* biometrické potvrzení,
* reautentizaci.

---

# 126. Ztracené zařízení

Uživatel může zařízení vzdáleně odvolat.

Server:

* zneplatní session,
* odmítne nové sync operace,
* zařízení při připojení vymaže citlivá lokální data podle možností platformy.

Offline ztracené zařízení nelze okamžitě fyzicky ovládat.

Proto je důležité lokální šifrování.

---

# 127. Serverový snapshot

## 127.1 Význam

Konzistentní obraz uživatelských dat pro inicializaci nebo full resync.

## 127.2 Může být rozdělen

* core profile,
* active plan,
* schedule window,
* activities,
* metrics,
* integrations,
* audit summaries.

## 127.3 Snapshot version

Všechny části musí být spojeny společnou logickou verzí nebo jasným cursor mechanismem.

---

# 128. Initial sync po přihlášení

Doporučený proces:

1. ověřit zařízení,
2. stáhnout core profile,
3. stáhnout aktivní safety data,
4. stáhnout dnešní a budoucí schedule window,
5. stáhnout aktivní plán a workouty,
6. zobrazit použitelnou aplikaci,
7. postupně stahovat historii a agregace.

Uživatel nemusí čekat na kompletní historii.

---

# 129. Progressive hydration

Lokální databáze se plní postupně podle priority.

Obrazovky musí umět zobrazit:

* základní data,
* stav načítání detailu,
* neúplnou historii,
* chybějící přílohy.

---

# 130. Sync API contracts

Každý sync endpoint musí mít:

* request schema version,
* response schema version,
* correlation id,
* idempotency podporu,
* jasné error codes,
* server timestamp,
* případný nový cursor.

---

# 131. Clock skew

Zařízení může mít nesprávný systémový čas.

Proto:

* pořadí serverových změn nesmí záviset jen na client timestamp,
* server přidává receivedAt,
* klientský čas se zachová jako observedAt,
* může být evidován odhad clock offset.

---

# 132. Časová pásma

Objekty musí rozlišovat:

* absolutní timestamp,
* lokální datum a čas,
* IANA timezone,
* původní timezone.

Synchronizace nesmí přepočítat lokální význam opakované události jako obyčejný UTC offset.

---

# 133. Změna časového pásma zařízení

Při cestování:

* ScheduleEvent zůstává podle své timezone policy,
* lokální notifikace se přepočítají,
* DailyCheckIn date grouping se řídí doménovým kontextem,
* synchronizační timestamps zůstávají absolutní.

---

# 134. Day boundary

Denní agregace musí mít definováno:

* podle jakého časového pásma,
* zda podle uživatelského home timezone,
* aktuálního timezone,
* timezone aktivity.

Tato pravidla patří do metrics a backend specifikace, ale sync je musí zachovat.

---

# 135. Observabilita synchronizace

Musí být měřeno například:

* délka sync cyklu,
* velikost fronty,
* počet retry,
* conflict rate,
* sync latency,
* failed operations,
* full resync rate,
* local recovery rate,
* data loss incidents.

---

# 136. Privacy-safe telemetry

Telemetry nesmí obsahovat:

* text bolesti,
* obsah poznámek,
* GPS body,
* workout hodnoty bez důvodu,
* tokeny,
* kompletní payload.

Může obsahovat:

* operation type,
* entity type,
* error category,
* velikost payloadu,
* anonymní technický correlation id.

---

# 137. SyncAuditRecord

## 137.1 Význam

Neměnný záznam významné synchronizační události.

## 137.2 Příklady

* konflikt vyřešen,
* full resync proveden,
* pending změna zahozena uživatelem,
* zařízení odvoláno,
* lokální data obnovena,
* ruční export neodeslaných dat.

## 137.3 Běžné retry

Každý technický retry nemusí být produktovým auditem.

Patří do diagnostických logů.

---

# 138. Diagnostický export

Uživatel nebo support může vytvořit diagnostický balíček.

Musí být:

* bezpečný,
* bez tokenů,
* bez citlivého obsahu nebo s explicitním souhlasem,
* časově omezený.

Může obsahovat:

* app version,
* database version,
* sync queue metadata,
* error categories,
* poslední correlation ids.

---

# 139. Support zásah

Support nesmí ručně měnit uživatelská sportovní data bez:

* oprávnění,
* auditované administrativní operace,
* jasného důvodu.

Preferované akce:

* restart sync jobu,
* vyžádání full resync,
* oprava mapování,
* odblokování technické fronty.

---

# 140. Sync Engine

## 140.1 Odpovědnost

Sync Engine na zařízení zajišťuje:

* sledování lokálních změn,
* frontu,
* závislosti,
* retry,
* push,
* pull,
* aplikaci serverových změn,
* konflikty,
* checkpointy,
* stav pro UI.

## 140.2 Nesmí řešit

Nemá sám rozhodovat o:

* tréninkové strategii,
* cílech,
* safety interpretaci,
* AI návrzích.

Používá doménová pravidla a merge policies.

---

# 141. SyncCoordinator

Může řídit jeden kompletní sync cyklus:

1. acquire lock,
2. zkontrolovat auth,
3. obnovit rozpracované operace,
4. zpracovat kritickou frontu,
5. pull server changes,
6. merge,
7. zpracovat běžnou frontu,
8. pull follow-up changes,
9. aktualizovat checkpoint,
10. release lock.

---

# 142. Sync lock

Na jednom zařízení nemá běžet několik konfliktních sync cyklů.

Může být použit:

* procesní mutex,
* databázový lock,
* worker unique name.

Musí se umět zotavit po pádu.

---

# 143. Reentrant sync

Nový trigger během probíhajícího sync:

* nevytvoří paralelní duplikát,
* označí další požadavek,
* po dokončení může spustit nový cyklus, pokud je potřeba.

---

# 144. ChangeFeedService

Serverová služba poskytující změny od cursoru.

Musí řešit:

* autorizaci,
* stránkování,
* tombstone,
* stabilní pořadí,
* retention změnového logu,
* invalidaci starého cursoru.

---

# 145. CommandIngestionService

Server přijímá klientské příkazy.

Kontroluje:

* autentizaci,
* vlastnictví,
* schema,
* idempotency,
* očekávanou verzi,
* doménovou validaci,
* safety,
* audit.

---

# 146. ConflictService

Spravuje:

* detekci,
* klasifikaci,
* merge návrh,
* uživatelské rozhodnutí,
* audit,
* výslednou synchronizaci.

---

# 147. DeviceService

Spravuje:

* instalace,
* session,
* odvolání,
* push token,
* trust status,
* poslední aktivitu.

---

# 148. LocalPersistenceService

Na mobilu spravuje:

* transakční zápis,
* recovery checkpoint,
* migrace,
* šifrování,
* repair,
* retention.

---

# 149. BlobSyncService

Spravuje:

* velké soubory,
* chunk upload,
* checksum,
* download,
* cache,
* retenci.

---

# 150. Doménové události sync oblasti

Minimálně:

* DeviceInstallationRegistered
* DeviceInstallationRevoked
* DeviceSessionStarted
* DeviceSessionEnded
* LocalEntityCreated
* LocalEntityChanged
* OfflineCommandCreated
* OfflineCommandExecutedLocally
* SyncOperationQueued
* SyncOperationStarted
* SyncOperationSucceeded
* SyncOperationFailed
* SyncOperationBlocked
* SyncBatchCreated
* SyncBatchApplied
* SyncAttemptRetried
* SyncConflictDetected
* SyncConflictAutoResolved
* SyncConflictRequiresReview
* SyncConflictResolved
* ServerChangesPulled
* SyncCursorAdvanced
* FullResyncStarted
* FullResyncCompleted
* FullResyncFailed
* TombstoneReceived
* LocalEntityMerged
* EntityAliasCreated
* PendingUploadCreated
* PendingUploadCompleted
* RecoveryCheckpointCreated
* ActiveSessionRecovered
* LocalDatabaseMigrationStarted
* LocalDatabaseMigrationCompleted
* LocalDatabaseRepairCompleted
* SyncHealthChanged
* UnsyncedDataDiscarded
* BackgroundSyncRequested

---

# 151. Příkazy sync oblasti

Minimálně:

* RegisterDeviceInstallation
* RevokeDeviceInstallation
* StartDeviceSession
* EndDeviceSession
* QueueSyncOperation
* CancelSyncOperation
* RetrySyncOperation
* CreateSyncBatch
* RunSyncCycle
* PushPendingChanges
* PullServerChanges
* ApplyServerChangeBatch
* AdvanceSyncCursor
* DetectSyncConflict
* ResolveSyncConflict
* CreateFullResync
* ExecuteFullResync
* CreateTombstone
* RestoreDeletedEntity
* CreateEntityAlias
* CreateRecoveryCheckpoint
* RecoverActiveSession
* StartPendingUpload
* ResumePendingUpload
* DeleteCachedBlob
* RunLocalDatabaseMigration
* RepairLocalDatabase
* ExportUnsyncedData
* DiscardUnsyncedData
* UpdateSyncPreferences

---

# 152. Invariance – identifikátory

* Každý synchronizovatelný objekt musí mít globálně unikátní ID.
* ID se po synchronizaci nesmí měnit.
* Sloučený objekt musí mít alias na canonical ID.
* Stejný operationId nesmí reprezentovat různé operace.

---

# 153. Invariance – lokální zápis

* Potvrzená uživatelská akce musí být lokálně uložena před změnou UI na úspěšný stav.
* Aktivní workout data nesmí být pouze v paměti.
* Neodeslané změny nesmí být odstraněny cache evictionem.
* Lokální transakce nesmí vytvořit částečný nekonzistentní agregát.

---

# 154. Invariance – synchronizace

* Opakovaný sync nesmí vytvářet duplicity.
* Cursor se nesmí posunout před úspěšným lokálním aplikováním změn.
* Operace s neúspěšnou povinnou závislostí se nesmí provést.
* Trvalé selhání nesmí zmizet bez záznamu.

---

# 155. Invariance – verze

* Update existujícího sdíleného objektu musí obsahovat expected server version.
* Version mismatch nesmí vést k tichému přepsání.
* ServerVersion musí růst monotónně v rámci objektu.
* Schválení Proposal nebo ChangeSet se vztahuje ke konkrétní verzi.

---

# 156. Invariance – konflikty

* Konflikt skutečných výkonových dat se nesmí řešit slepým server wins.
* Safety-critical konflikt používá dočasně konzervativnější stav.
* Uživatelské rozhodnutí o konfliktu musí být auditované.
* Vyřešený konflikt musí vytvořit novou autoritativní verzi.

---

# 157. Invariance – workout session

* Session musí odkazovat na workout revision, se kterou začala.
* Serverová změna nesmí neviditelně změnit aktivní session.
* Dokončené SetPerformance se nesmí ztratit.
* Obnova po pádu musí použít poslední konzistentní checkpoint.
* Dokončení offline musí vytvořit lokální Activity.

---

# 158. Invariance – delete

* Tombstone musí zabránit obnovení starého objektu náhodnou synchronizací.
* Historická Activity se nesmí odstranit změnou plánu.
* Fyzické smazání citlivých dat musí respektovat právní proces.
* Pending delete se nesmí oznámit jako serverově dokončený před potvrzením.

---

# 159. Invariance – více zařízení

* Jedna operace se stejným idempotency key se provede právě jednou.
* Zařízení nesmí měnit objekt jiného uživatele.
* Odvolané zařízení nesmí synchronizovat nové změny.
* Konflikt dvou zařízení musí zachovat obě verze do vyřešení.

---

# 160. Invariance – bezpečnost

* Aktivní blokující Limitation musí být dostupná offline po synchronizaci.
* Offline aplikace nesmí ignorovat známou SafetyDecision.
* Lokální změna nesmí odstranit odborné omezení bez odpovídajícího flow.
* Citlivé údaje musí být lokálně chráněné.

---

# 161. Invariance – AI

* Offline prompt nesmí být označen jako zpracovaný bez serverového výsledku.
* Stale AIProposal se nesmí aplikovat.
* Offline approval musí být serverově revalidováno.
* AI text nesmí být zdrojem změny bez ChangeSet nebo doménového příkazu.

---

# 162. Read modely

## 162.1 SyncStatusView

Obsahuje:

* online/offline stav,
* počet pending změn,
* poslední sync,
* konflikt,
* případnou akci.

## 162.2 PendingChangesView

Obsahuje:

* změny čekající na odeslání,
* typ,
* čas,
* stav,
* možnost retry nebo detailu.

## 162.3 SyncConflictView

Obsahuje:

* objekt,
* lokální verzi,
* serverovou verzi,
* doporučené řešení,
* bezpečnostní dopad.

## 162.4 DeviceListView

Obsahuje:

* zařízení,
* poslední aktivitu,
* stav,
* možnost odvolání.

## 162.5 OfflineDataView

Obsahuje:

* dostupné období,
* velikost dat,
* aktivní download,
* možnost správy.

## 162.6 SyncDiagnosticsView

Pro technickou diagnostiku:

* fronta,
* poslední errors,
* cursor,
* app version,
* database version.

---

# 163. Příklad – workout v metru bez internetu

## Stav

* dnešní workout je uložen lokálně,
* uživatel nemá internet.

## Proces

1. spustí WorkoutSession,
2. zaznamená všechny série,
3. změní jeden cvik,
4. dokončí workout,
5. vznikne Activity,
6. všechny operace čekají v lokální frontě.

Po připojení:

* session a výkony se synchronizují,
* Activity se vytvoří serverově,
* workout se označí jako dokončený,
* případné agregace se přepočítají.

---

# 164. Příklad – pád aplikace uprostřed workoutu

## Stav

Uživatel dokončil tři série.

Aplikace spadne.

## Výsledek

Po spuštění:

* nalezne se aktivní session,
* načtou se tři série,
* obnoví se aktuální krok,
* odpočinkový čas se dopočítá z timestampu,
* uživatel pokračuje.

---

# 165. Příklad – dvě zařízení přesunou workout

Telefon:

* středa 18:00.

Tablet:

* čtvrtek 19:00.

Server:

* detekuje MOVE_MOVE_CONFLICT.

Uživatel zvolí čtvrtek.

Vznikne:

* ConflictResolution,
* nová ScheduleEvent version,
* obě zařízení stáhnou výsledek.

---

# 166. Příklad – server zruší workout během aktivní session

Uživatel workout již cvičí offline.

Na jiném zařízení byl plán přeorganizován a workout zrušen.

Po synchronizaci:

* aktivní nebo dokončená session zůstává,
* Activity se zachová,
* WorkoutInstance může být označen jako plánově zrušený,
* ActivityMatch vyhodnotí skutečnou činnost.

---

# 167. Příklad – bolest nahlášená offline

Uživatel během workoutu zadá:

* ostrá bolest pravého bicepsu při shybech.

Lokálně:

* vznikne PainReport,
* offline safety pravidla zablokují tahový cvik,
* session se upraví nebo zastaví,
* změna má CRITICAL/HIGH sync prioritu.

Po připojení:

* server provede plné PainAssessment,
* může navrhnout další omezení.

---

# 168. Příklad – nový plán na jiném zařízení

Na tabletu uživatel schválí nový plán.

Telefon je dva dny offline.

Po připojení:

* stáhne nový TrainingPlanVersion,
* stáhne nové WorkoutInstance,
* zachová lokální dokončené aktivity,
* případné lokální změny starého plánu se posoudí proti novému stavu.

---

# 169. Příklad – ruční Activity a pozdější Garmin import

Offline uživatel zadá běh ručně.

Později server importuje stejný běh z Garminu.

Po synchronizaci:

* server detekuje duplicitu,
* vytvoří merge,
* zachová ruční RPE,
* doplní GPS a tep,
* zařízení obdrží canonical Activity a alias.

---

# 170. Příklad – odhlášení s pending změnami

Zařízení má:

* nedokončený upload GPS,
* nesynchronizovanou Activity.

Aplikace před odhlášením zobrazí:

> Jedna aktivita ještě nebyla synchronizována.

Uživatel může:

* počkat na sync,
* bezpečně ji ponechat na zařízení,
* zahodit po explicitním potvrzení.

---

# 171. Příklad – stará aplikace

Telefon používá verzi aplikace s nepodporovaným command schema.

Server:

* změnu neaplikuje,
* vrátí UPGRADE_REQUIRED,
* lokální data zůstanou,
* uživatel aktualizuje aplikaci,
* fronta se znovu zpracuje.

---

# 172. Příklad – poškozený cursor

Server již nemá změnový log od starého cursoru.

Výsledek:

* CURSOR_EXPIRED,
* aplikace zahájí full resync,
* pending lokální změny zazálohuje,
* po snapshotu je znovu aplikuje nebo vytvoří konflikty.

---

# 173. Příklad – změna Limitation na dvou zařízeních

Telefon:

* omezení ukončeno.

Tablet:

* omezení prodlouženo o týden.

Výsledek:

* SAFETY_CRITICAL conflict,
* omezení zůstává dočasně aktivní,
* uživatel musí potvrdit správný stav,
* žádný rizikový workout se automaticky neaktivuje.

---

# 174. Příklad – background sync na iOS se nespustí

Uživatel otevře aplikaci až večer.

Aplikace:

* okamžitě zobrazí lokální dnešní plán,
* spustí foreground sync,
* stáhne změny,
* aktualizuje stav,
* případné konflikty zobrazí bez ztráty lokálních dat.

---

# 175. Příklad – velká GPS trasa

Souhrn aktivity se synchronizuje okamžitě.

Trasa:

* se nahrává po chuncích,
* pokračuje na Wi-Fi,
* při přerušení naváže,
* po dokončení se mapa zobrazí na dalších zařízeních.

---

# 176. Co musí být strukturované

Nesmí zůstat pouze jako volný text:

* device installation,
* lokální verze,
* serverová verze,
* sync state,
* offline command,
* sync operation,
* idempotency key,
* dependency,
* retry stav,
* sync cursor,
* conflict,
* resolution,
* tombstone,
* checkpoint,
* upload stav,
* database version,
* freshness,
* last sync,
* source device.

Volný text může doplnit:

* bezpečnou chybovou zprávu,
* uživatelský důvod konfliktu,
* poznámku k ručnímu rozhodnutí,
* diagnostický komentář.

---

# 177. Otevřené otázky

* Která lokální databáze bude použita?
* Bude databáze kompletně šifrovaná?
* Jak bude řešena migrace šifrovacího klíče?
* Použije se UUIDv7, ULID nebo jiný identifikátor?
* Jak přesně bude vypadat serverový change feed?
* Bude jeden globální cursor nebo více cursorů?
* Jak dlouho server uchová change log?
* Jak dlouho uchovávat tombstone?
* Jaký bude maximální offline horizont?
* Která data se automaticky stahují do telefonu?
* Jak umožnit uživateli stáhnout delší historii offline?
* Jak velká data se budou chunkovat?
* Jaký bude maximální batch size?
* Které příkazy budou append-only?
* Které objekty budou používat objektovou verzi?
* Která pole dovolí last-write-wins?
* Jak přesně definovat merge policy pro každý agregát?
* Kdy vytvořit uživatelský konflikt a kdy automatický merge?
* Jak zabránit příliš častému zobrazování konfliktů?
* Jak řešit souběžné přeskupení workout kroků?
* Jak řešit stejné workout session na telefonu a hodinkách?
* Bude telefon nebo hodinky primárním trackerem?
* Jak synchronizovat aktivní časovač mezi hodinkami a telefonem?
* Jak obnovit session po restartu hodinek?
* Jak často autosave provádět?
* Jak omezit počet sync operací při rychlém zapisování sérií?
* Budou se operace kompaktovat před odesláním?
* Jak zachovat audit při kompaktování?
* Jak synchronizovat hlasové vstupy během workoutu?
* Jak zpracovat offline AI prompt se zastaralým kontextem?
* Které AI Proposal lze schválit offline?
* Jaká bude platnost offline approval?
* Jak přesně synchronizovat ChangeSet?
* Jak řešit serverovou částečnou aplikaci batch?
* Jak implementovat kompenzační operace?
* Jak zachovat skutečnost při konfliktu plánu a Activity?
* Jak funguje full resync při aktivním workoutu?
* Jak zabránit odstranění pending změn při reinstall?
* Má aplikace umožnit export neodeslaných dat před odhlášením?
* Jak řešit změnu uživatele na zařízení?
* Jak dlouho ponechat lokální data po odhlášení?
* Jaké údaje jsou vyloučeny z cloudové zálohy zařízení?
* Jak řešit ztracené zařízení?
* Jak rychle zneplatnit odvolané zařízení?
* Jak řešit clock skew?
* Jak řešit zařízení s úmyslně změněným časem?
* Jaké background capability budou dostupné na iOS?
* Jaké work constraints použít na Androidu?
* Kdy použít foreground service?
* Jak nastavit Wi-Fi-only preference pro velká data?
* Jak zachovat fungování při low storage?
* Jak detekovat poškození lokální databáze?
* Jak provádět automatický repair?
* Jaký diagnostický export bude bezpečný?
* Jak sledovat sync reliability bez citlivé telemetry?
* Jaké SLO bude mít synchronizace?
* Jaká maximální doba zpoždění je přijatelná?
* Jak testovat chaos scénáře?
* Jak simulovat ztrátu sítě uprostřed transakce?
* Jak testovat více zařízení automatizovaně?
* Jak testovat rollback databázové migrace?
* Jak verzovat OfflineCommand?
* Jak dlouho podporovat staré command schema?
* Jak řešit zařízení offline několik měsíců?
* Jak přepočítat notifikace po změně timezone?
* Jak synchronizovat health platform data pouze dostupná na mobilu?
* Jak sladit mobile import a server provider import?
* Jak řešit remote delete a lokální tombstone?
* Jak implementovat právo na výmaz ve více offline zařízeních?
* Jak ověřit, že zařízení citlivá data skutečně odstranilo?
* Jak zpracovat pending příkaz po zrušení účtu?
* Jak zabránit replay útoku se starou sync operací?
* Jak podepisovat nebo ověřovat kritické sync příkazy?
* Jak řešit kompromitované zařízení?
* Jak funguje synchronizace pro budoucí webovou aplikaci?
* Jak funguje synchronizace pro Apple Watch a Wear OS?

---

# 178. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── identity-and-profile-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/07-backend/
├── sync-service.md
├── change-feed-service.md
├── command-ingestion-service.md
├── conflict-service.md
├── device-service.md
├── idempotency.md
├── blob-storage.md
├── database-transactions.md
└── sync-api.md
```

A:

```text
docs/08-mobile/
├── mobile-architecture.md
├── local-database.md
├── offline-command-queue.md
├── sync-engine.md
├── conflict-resolution-ui.md
├── background-execution.md
├── workout-session-persistence.md
├── gps-offline-storage.md
├── secure-local-storage.md
└── local-database-migrations.md
```

A:

```text
docs/09-security/
├── device-security.md
├── local-data-encryption.md
├── session-security.md
├── sync-security.md
└── data-deletion.md
```

A:

```text
docs/10-quality/
├── offline-test-strategy.md
├── sync-chaos-testing.md
├── multi-device-testing.md
├── migration-testing.md
└── data-integrity-testing.md
```

---

# 179. Kritéria správného sync a offline modelu

Model je vhodný pouze tehdy, pokud umožní:

1. otevřít aplikaci bez internetu,
2. zobrazit dnešní plán offline,
3. spustit workout offline,
4. ukládat každou sérii lokálně,
5. obnovit workout po pádu,
6. dokončit workout offline,
7. vytvořit Activity offline,
8. nahlásit bolest offline,
9. respektovat aktivní omezení offline,
10. vytvořit ruční aktivitu offline,
11. přesunout flexibilní workout offline,
12. vytvořit globální identifikátor bez serveru,
13. frontovat příkazy,
14. řídit jejich závislosti,
15. opakovat neúspěšné operace,
16. zabránit duplicitnímu provedení,
17. synchronizovat změny na backend,
18. stahovat serverové změny pomocí cursoru,
19. zachovat pořadí změn,
20. používat optimistic concurrency,
21. detekovat konflikt verzí,
22. automaticky slučovat nekolidující pole,
23. zobrazit uživatelský konflikt,
24. chránit skutečně provedené workouty,
25. chránit dokončené Activity,
26. synchronizovat více zařízení,
27. zabránit dvojímu spuštění ChangeSet,
28. synchronizovat AIProposal,
29. detekovat stale návrh,
30. podporovat tombstone,
31. zabránit obnovení smazaného objektu,
32. provést full resync,
33. zachovat pending změny při full resync,
34. synchronizovat velké soubory po částech,
35. pokračovat v uploadu po přerušení,
36. spravovat lokální cache,
37. nikdy neevictovat neodeslaná data,
38. šifrovat citlivá lokální data,
39. bezpečně migrovat databázi,
40. fungovat na Androidu i iOS,
41. respektovat omezení background execution,
42. zobrazit stav zpožděné synchronizace,
43. pracovat se zastaralými daty,
44. odvolat ztracené zařízení,
45. chránit data více uživatelů na jednom zařízení,
46. řešit odhlášení s pending změnami,
47. bezpečně smazat lokální data,
48. auditovat významná rozhodnutí,
49. diagnostikovat problém bez úniku citlivých dat,
50. přidat budoucí hodinky nebo webového klienta bez přepsání celého modelu.

---

# 180. Závěr

Sync and Offline model zajišťuje, že aplikace není pouze vzdáleným klientem nad serverovým API, ale spolehlivým sportovním nástrojem použitelným v reálných podmínkách.

Základní lokální tok je:

```text
Uživatelská akce
    ↓
Doménová validace
    ↓
Lokální databázová transakce
    ↓
Okamžitá aktualizace UI
    ↓
OfflineCommand
    ↓
SyncOperation
    ↓
Synchronizační fronta
```

Synchronizační tok je:

```text
Lokální změny
    ↓
Push s idempotency key
    ↓
Serverová validace a verze
    ↓
Serverový výsledek
    ↓
Pull serverových změn
    ↓
Lokální transakční aplikace
    ↓
Posun SyncCursor
```

Konfliktní tok je:

```text
Lokální verze
    +
Serverová verze
    +
Společná základní verze
    ↓
Three-way merge
    ↓
Automatické sloučení
    nebo
SyncConflict
    ↓
ConflictResolution
    ↓
Nová autoritativní verze
```

Tok aktivního workoutu je:

```text
WorkoutInstanceRevision
    ↓
WorkoutSession
    ↓
Lokální autosave
    ↓
SetPerformance / StepPerformance
    ↓
RecoveryCheckpoint
    ↓
Dokončení offline
    ↓
Activity
    ↓
Pozdější synchronizace
```

Tok obnovy je:

```text
Pád aplikace / restart
    ↓
Kontrola RecoveryCheckpoint
    ↓
Obnova aktivní session
    ↓
Pokračování bez ztráty výkonu
```

Hlavním cílem není, aby byla ikona synchronizace vždy zelená.

Hlavním cílem je, aby uživatel mohl aplikaci důvěřovat.

Musí vědět, že:

* jeho workout nezmizí,
* dokončené série se neztratí,
* bolest nahlášená bez internetu zůstane uložená,
* změna z jiného zařízení nepřepíše skutečně provedenou aktivitu,
* stejná operace se neprovede dvakrát,
* konflikt bude řešen transparentně,
* aplikace zůstane použitelná i v horách, v tělocvičně bez signálu nebo při výpadku serveru.

Díky tomu může AI Trainer fungovat jako skutečný každodenní sportovní nástroj, nikoliv pouze jako online rozhraní, které selže ve chvíli, kdy uživatel ztratí připojení.
