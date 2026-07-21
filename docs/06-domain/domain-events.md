# AI Trainer – Domain Events

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/domain-events.md`

---

# 1. Účel dokumentu

Tento dokument sjednocuje model doménových událostí napříč aplikací AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/sports-and-goals-model.md`,
* `docs/06-domain/training-plan-model.md`,
* `docs/06-domain/workout-model.md`,
* `docs/06-domain/scheduling-model.md`,
* `docs/06-domain/activity-model.md`,
* `docs/06-domain/recovery-and-limitations-model.md`,
* `docs/06-domain/ai-and-change-model.md`,
* `docs/06-domain/metrics-model.md`,
* `docs/06-domain/integration-model.md`,
* `docs/06-domain/sync-and-offline-model.md`,
* `docs/06-domain/identity-and-profile-model.md`.

Dokument definuje:

* význam doménové události,
* rozdíl mezi doménovou, integrační a technickou událostí,
* společnou obálku událostí,
* názvosloví,
* identifikátory,
* pořadí,
* čas,
* verze,
* metadata,
* korelaci a kauzalitu,
* publikování,
* transakční outbox,
* idempotentní konzumaci,
* opakované doručení,
* chyby a dead-letter fronty,
* soukromí,
* audit,
* retenci,
* projekce a read modely,
* reakce dalších domén,
* úplný katalog hlavních událostí.

Dokument zatím neurčuje:

* konkrétní message broker,
* přesný formát Kafka topiců,
* konkrétní cloudovou event službu,
* fyzickou podobu databázových tabulek,
* přesná Avro nebo Protobuf schémata,
* konkrétní implementaci outbox workeru,
* konečné časové limity retence.

---

# 2. Cíl event modelu

Event model musí umožnit, aby se významné změny v jedné části aplikace bezpečně promítly do dalších částí.

Příklad:

```text
WorkoutSessionCompleted
    ↓
ActivityCreatedFromWorkout
    ↓
ActivityLoadCalculated
    ↓
GoalProgressRecalculated
    ↓
ReadinessInputsChanged
    ↓
WeeklySummaryUpdated
```

Události musí umožnit:

* oddělit domény,
* odstranit přímé závislosti mezi službami,
* spouštět asynchronní výpočty,
* vytvářet read modely,
* auditovat významné změny,
* bezpečně opakovat zpracování,
* rekonstruovat příčinu změny,
* podporovat offline synchronizaci,
* přidávat nové konzumenty bez změny původního producenta.

---

# 3. Co je doménová událost

Doménová událost reprezentuje skutečnost, která již nastala a je významná pro doménu.

Příklady:

* GoalCreated,
* WorkoutSessionStarted,
* PainReported,
* ActivityImported,
* TrainingPlanActivated.

Událost je formulována v minulém čase.

Událost neříká:

> Udělej něco.

Říká:

> Něco se stalo.

---

# 4. Příkaz versus událost

## 4.1 Příkaz

Příkaz vyjadřuje záměr.

Příklad:

```text
CompleteWorkoutSession
```

Příkaz může:

* uspět,
* selhat,
* být odmítnut,
* být opakován.

## 4.2 Událost

Událost potvrzuje výsledek.

Příklad:

```text
WorkoutSessionCompleted
```

Událost nemá být formulována jako požadavek.

## 4.3 Tok

```text
Command
    ↓
Authorization
    ↓
Validation
    ↓
Aggregate transition
    ↓
Domain Event
```

---

# 5. Doménová událost versus integrační událost

## 5.1 Doménová událost

Vyjadřuje interní doménovou skutečnost.

Příklad:

```text
ActivityCreated
```

## 5.2 Integrační událost

Je stabilní veřejný kontrakt určený jiným službám nebo systémům.

Příklad:

```text
activity.created.v1
```

Integrační událost může být vytvořena z doménové události.

## 5.3 Proč je oddělovat

Interní doménový model se může měnit rychleji než veřejné integrační kontrakty.

Producent nesmí být nucen zachovat každý interní detail navždy.

---

# 6. Doménová událost versus technická událost

Technická událost popisuje provozní stav.

Příklady:

* SyncAttemptFailed,
* DatabaseMigrationCompleted,
* CacheInvalidated,
* WebhookReceived.

Nemusí být doménovou událostí, pokud nemá produktový význam.

Technické události mají vlastní:

* telemetry,
* logování,
* alerting,
* retenční politiku.

---

# 7. Doménová událost versus auditní záznam

Doménová událost:

* slouží k reakci systému,
* může být distribuována,
* má strukturovaný kontrakt.

Auditní záznam:

* slouží k dohledatelnosti,
* může obsahovat detailnější změnový kontext,
* musí být neměnný,
* nemusí být distribuován všem službám.

Jedna doménová změna může vytvořit:

* DomainEvent,
* AuditRecord,
* ChangeFeedEntry.

Tyto objekty nejsou totožné.

---

# 8. Událost versus notifikace uživateli

Doménová událost není push notifikace.

Příklad:

```text
WorkoutScheduled
```

může vést k:

```text
WorkoutReminderScheduled
```

a později k:

```text
PushNotificationSent
```

Ne každá doménová událost má vyvolat uživatelské upozornění.

---

# 9. Událost versus analytická událost

Produktová analytika může evidovat:

```text
onboarding_completed
```

Doménová událost může být:

```text
OnboardingCompleted
```

Doménový event nesmí být přímo bez filtrace odeslán do analytiky, protože může obsahovat:

* citlivé identifikátory,
* zdravotní kontext,
* interní metadata.

Analytická vrstva musí vytvořit bezpečný odvozený event.

---

# 10. Základní event envelope

Každá přenášená doménová nebo integrační událost musí mít společnou obálku.

Doporučená logická struktura:

```text
DomainEventEnvelope
├── eventId
├── eventType
├── eventVersion
├── occurredAt
├── recordedAt
├── aggregateType
├── aggregateId
├── aggregateVersion
├── actor
├── ownerId
├── correlationId
├── causationId
├── commandId
├── changeSetId
├── sourceService
├── sourceDeviceId
├── traceContext
├── dataClassification
├── payload
└── metadata
```

---

# 11. EventId

## 11.1 Význam

Globálně unikátní identifikátor konkrétní události.

## 11.2 Požadavky

Musí být:

* unikátní,
* neměnný,
* vhodný pro idempotenci,
* vytvořitelný producentem.

## 11.3 Formát

Lze použít například:

* UUIDv7,
* ULID.

Musí být jednotný napříč službami.

---

# 12. EventType

## 12.1 Význam

Stabilní technický název události.

Příklady:

```text
TrainingPlanActivated
WorkoutSessionCompleted
PainReported
ActivityImported
```

## 12.2 Pravidla názvů

* minulý čas,
* bez názvu konkrétní databázové tabulky,
* bez implementačních detailů,
* jeden jasný význam,
* PascalCase v doménovém modelu,
* stabilní external name v integračním kontraktu.

---

# 13. EventVersion

## 13.1 Význam

Verze schématu události.

Příklad:

```text
WorkoutSessionCompleted v1
WorkoutSessionCompleted v2
```

## 13.2 Změnu verze vyžaduje například

* odstranění pole,
* změna významu pole,
* změna datového typu,
* nové povinné pole,
* změna jednotek,
* změna struktury identity.

## 13.3 Novou verzi nemusí vyžadovat

* nové volitelné pole,
* rozšíření metadata,
* oprava dokumentace bez změny významu.

---

# 14. OccurredAt

Čas, kdy doménová skutečnost nastala.

Příklad:

* uživatel dokončil workout v 18:42,
* událost byla serverem zapsána v 18:44.

`occurredAt` je 18:42.

Musí být ukládán jako absolutní časový okamžik.

---

# 15. RecordedAt

Čas, kdy byla událost zapsána do autoritativního úložiště.

Může se lišit od occurredAt kvůli:

* offline režimu,
* opožděnému importu,
* batch zpracování,
* obnově po pádu.

---

# 16. ReceivedAt

Konzument nebo message infrastruktura může doplnit:

* čas přijetí události.

Není součástí původní doménové skutečnosti.

Používá se pro:

* latenci,
* monitoring,
* diagnostiku.

---

# 17. AggregateType

Typ agregátu, který událost vytvořil.

Příklady:

* Goal,
* TrainingPlan,
* WorkoutSession,
* Activity,
* AthleteProfile,
* UserIntegration.

---

# 18. AggregateId

Identifikátor konkrétního agregátu.

Události jednoho agregátu musí být možné:

* seskupit,
* seřadit,
* auditovat,
* kontrolovat podle verze.

---

# 19. AggregateVersion

## 19.1 Význam

Verze agregátu po aplikaci změny, která událost vytvořila.

Příklad:

```text
Goal version 4
    ↓
GoalPriorityChanged
aggregateVersion = 5
```

## 19.2 Použití

* detekce chybějící události,
* pořadí,
* projekce,
* optimistic concurrency,
* diagnostika.

---

# 20. OwnerId

Identifikátor uživatele nebo profilu, kterému data patří.

Musí být odlišeno:

* accountId,
* athleteProfileId,
* organizationId,
* actorId.

Konkrétní event schema musí jasně určit vlastníka.

---

# 21. Actor

## 21.1 Význam

Kdo změnu způsobil.

## 21.2 ActorType

* USER,
* COACH,
* GUARDIAN,
* AI,
* SYSTEM,
* AUTOMATION,
* IMPORT,
* EXTERNAL_PROVIDER,
* ADMINISTRATOR,
* SUPPORT_TOOL.

## 21.3 ActorId

Je uvedeno, pokud je relevantní a bezpečné.

AI událost má odlišit:

* AI návrh,
* uživatelsky schválenou změnu,
* systémovou automatizaci.

---

# 22. CorrelationId

## 22.1 Význam

Spojuje všechny operace a události jednoho logického procesu.

Příklad:

```text
Uživatel dokončí workout
    ↓
WorkoutSessionCompleted
    ↓
ActivityCreated
    ↓
MetricAggregateCalculated
    ↓
GoalProgressUpdated
```

Všechny mohou sdílet jeden `correlationId`.

---

# 23. CausationId

## 23.1 Význam

Identifikátor bezprostřední příčiny události.

Může odkazovat na:

* commandId,
* eventId,
* ChangeSet operation,
* webhook event.

Příklad:

```text
WorkoutSessionCompleted.eventId
```

je `causationId` události:

```text
ActivityCreatedFromWorkout
```

---

# 24. CommandId

Identifikátor příkazu, který přímo vedl ke změně.

Je důležitý pro:

* audit,
* idempotenci,
* offline synchronizaci,
* spojení uživatelské akce s výsledkem.

---

# 25. ChangeSetId

Pokud je událost součástí větší změny, musí odkazovat na:

* ChangeSet,
* případně ChangeOperation.

Příklad:

Reorganizace týdne může vytvořit několik:

* ScheduleEventRescheduled,
* WorkoutInstanceCancelled,
* RecoveryWorkoutCreated.

Všechny sdílejí `changeSetId`.

---

# 26. SourceService

Technický producent události.

Příklady:

* plan-service,
* workout-service,
* activity-service,
* profile-service,
* integration-service.

Není totožný s doménovým aktérem.

---

# 27. SourceDeviceId

Použije se, pokud změna vznikla na zařízení.

Pomáhá při:

* offline synchronizaci,
* multi-device konfliktech,
* diagnostice,
* obnově workout session.

Nesmí být používán jako trvalý behaviorální tracking identifikátor mimo potřebný účel.

---

# 28. TraceContext

Obsahuje technické údaje pro distribuované trasování.

Například:

* traceId,
* spanId.

Nesmí obsahovat citlivý payload.

---

# 29. DataClassification

Každá událost musí mít klasifikaci dat.

Možné hodnoty:

* PUBLIC,
* INTERNAL,
* PERSONAL,
* SENSITIVE,
* HEALTH_RELATED,
* LOCATION_RELATED,
* AUTHENTICATION_RELATED,
* LEGAL.

Klasifikace ovlivňuje:

* povolené konzumenty,
* logování,
* retenci,
* export,
* šifrování.

---

# 30. Payload

Payload obsahuje fakta potřebná pro pochopení události.

Nemá obsahovat celý agregát bez důvodu.

Preferuje se:

* identifikátor,
* relevantní změna,
* důležitý kontext,
* předchozí a nová hodnota pouze tam, kde je nutná.

---

# 31. Event metadata

Metadata mohou obsahovat:

* schemaVersion,
* locale,
* timezone,
* appVersion,
* API version,
* integration provider,
* calculation version,
* safety rule version.

Metadata nesmí sloužit jako neřízené odkladiště doménových dat.

---

# 32. Minimal event principle

Událost má obsahovat minimum potřebné pro:

* význam události,
* bezpečnou reakci,
* auditovatelnou kauzalitu.

Pokud konzument potřebuje aktuální detail objektu, může jej načíst autorizovaným query rozhraním.

---

# 33. Event-carried state transfer

Některé integrační události mohou nést větší snapshot stavu.

Použije se pouze pokud:

* konzument musí fungovat bez synchronního dotazu,
* stav je stabilně verzovaný,
* citlivost je přijatelná,
* payload není příliš velký.

Nemá být výchozím řešením pro všechny události.

---

# 34. Citlivá data v událostech

Událost nesmí běžně obsahovat:

* celý text PainReport,
* detail AI konverzace,
* GPS trasu,
* access token,
* e-mail bez potřeby,
* celé právní dokumenty,
* detailní zdravotní historii.

Může obsahovat například:

```text
PainReported
- painReportId
- athleteProfileId
- bodyAreaCode
- laterality
- severityBand
- safetyReviewRequired
```

Detail se načte pouze oprávněnou službou.

---

# 35. Šifrování

Citlivé event streamy musí používat:

* šifrování při přenosu,
* šifrování v úložišti,
* omezená oprávnění,
* oddělené topic nebo subscription policy podle potřeby.

---

# 36. Logování událostí

Do běžných logů se nemá zapisovat celý payload.

Log může obsahovat:

* eventId,
* eventType,
* eventVersion,
* aggregateId,
* correlationId,
* processing result,
* duration.

Citlivé údaje musí být redigované.

---

# 37. Publikování události

Doménová událost vzniká uvnitř doménové transakce.

Musí být zajištěno, že nenastane:

* změna databáze bez události,
* událost bez skutečné změny.

---

# 38. Transactional outbox

## 38.1 Princip

Ve stejné databázové transakci se uloží:

* změna agregátu,
* outbox záznam události.

Následně worker událost publikuje.

## 38.2 Tok

```text
Database transaction
├── Update aggregate
└── Insert OutboxMessage
        ↓
Outbox Publisher
        ↓
Message Broker
```

## 38.3 Výhoda

Odstraňuje dual-write problém.

---

# 39. OutboxMessage

Obsahuje minimálně:

* outboxId,
* event envelope,
* createdAt,
* publishState,
* attemptCount,
* nextAttemptAt,
* publishedAt,
* lastError.

---

# 40. Outbox stav

* PENDING,
* PUBLISHING,
* PUBLISHED,
* RETRY,
* FAILED,
* DEAD_LETTERED.

`PUBLISHED` neznamená, že všichni konzumenti událost zpracovali.

---

# 41. Outbox retry

Dočasné chyby se opakují s:

* exponenciálním backoffem,
* jitterem,
* maximálním intervalem.

Permanentní chyba schématu nesmí být opakována bez omezení.

---

# 42. Inbox pattern

Každý kritický konzument může používat InboxRecord.

InboxRecord obsahuje:

* consumerName,
* eventId,
* receivedAt,
* processedAt,
* status,
* result,
* retryCount.

To umožňuje idempotentní zpracování.

---

# 43. At-least-once delivery

Výchozí předpoklad:

> Událost může být doručena více než jednou.

Systém nesmí předpokládat přesně jedno doručení.

Konzumenti musí být idempotentní.

---

# 44. Exactly-once business effect

Technicky může být doručení opakované.

Doménový efekt však musí nastat právě jednou.

Příklad:

`ActivityCreated` nesmí:

* dvakrát zvýšit počet aktivit,
* dvakrát vytvořit osobní rekord,
* dvakrát započítat zátěž.

---

# 45. Idempotentní konzument

Může použít:

* eventId,
* business key,
* aggregateVersion,
* unique constraint,
* inbox record.

---

# 46. Pořadí událostí

## 46.1 Globální pořadí

Není nutné ani realistické pro celý systém.

## 46.2 Pořadí agregátu

Události jednoho agregátu musí být zpracovatelné podle:

* aggregateVersion.

## 46.3 Partition key

Při použití brokeru má být událost směrována podle:

* aggregateId,
* případně ownerId podle případu.

---

# 47. Událost mimo pořadí

Konzument může obdržet:

* verzi 5 před verzí 4.

Možné chování:

* krátce počkat,
* načíst aktuální stav,
* uložit pending event,
* přepočítat projekci ze zdroje pravdy.

Nesmí slepě vytvořit nekonzistentní projekci.

---

# 48. Chybějící událost

Pokud projekce zjistí mezeru v aggregateVersion:

* označí projekci jako neúplnou,
* vyžádá replay nebo aktuální snapshot,
* nezobrazuje nepravdivý definitivní stav.

---

# 49. Eventual consistency

Některé části systému se aktualizují s malým zpožděním.

Příklad:

* Activity je uložena okamžitě,
* osobní rekord se objeví za chvíli,
* týdenní graf se přepočítá asynchronně.

UI musí rozlišit:

* autoritativní dokončení,
* probíhající výpočet odvozených dat.

---

# 50. Kritické synchronní reakce

Některé kontroly nesmí čekat na asynchronní event.

Před potvrzením změny musí synchronně proběhnout například:

* autorizace,
* safety validace,
* ownership kontrola,
* version kontrola,
* blokující schedule conflict.

Události se používají pro následné reakce, ne pro nahrazení kritické validace.

---

# 51. Event handler

Každý handler musí definovat:

* přijímaný event type a verzi,
* idempotency strategy,
* transakční hranici,
* retry policy,
* dead-letter policy,
* datovou klasifikaci,
* očekávané vedlejší efekty.

---

# 52. Handler failure

Chyba jednoho konzumenta nesmí zablokovat ostatní konzumenty.

Příklad:

* ProgressProjection selže,
* ale NotificationService může událost zpracovat.

---

# 53. Retryable handler failure

Příklady:

* databázový timeout,
* dočasný síťový problém,
* krátký výpadek závislosti.

---

# 54. Non-retryable handler failure

Příklady:

* nepodporovaná verze schématu,
* neplatný povinný údaj,
* porušená ownership invariance,
* neznámý kritický event type.

Taková událost přechází do kontrolovaného failure flow.

---

# 55. Dead-letter event

Dead-letter záznam musí obsahovat:

* původní eventId,
* consumer,
* error category,
* bezpečný popis,
* počet pokusů,
* firstFailedAt,
* lastFailedAt,
* možnost replay.

---

# 56. Replay

Události lze znovu zpracovat například při:

* opravě handleru,
* rekonstrukci projekce,
* nové výpočetní metodice,
* obnově po incidentu.

Replay nesmí:

* znovu poslat uživatelskou notifikaci bez policy,
* znovu provést externí platbu,
* znovu aplikovat nevratnou akci,
* zdvojit auditní záznam jako novou doménovou skutečnost.

---

# 57. Replay mode

Konzument musí vědět, zda zpracovává:

* LIVE,
* REPLAY,
* REBUILD,
* RECONCILIATION.

Podle toho může potlačit externí vedlejší efekty.

---

# 58. Projekce

Projekce vytvářejí read modely například:

* TodayView,
* WeeklyScheduleView,
* GoalProgressView,
* ActivityHistoryView,
* RecoveryOverview,
* AIContextSummary.

---

# 59. Rebuild projekce

Projekci musí být možné:

* smazat,
* znovu vytvořit z autoritativních dat nebo event streamu,
* porovnat s existujícím stavem.

Projekce není zdroj pravdy.

---

# 60. Event sourcing

Celá aplikace nemusí být postavena jako plný event-sourced systém.

Doporučený model:

* běžné stavové agregáty v relační databázi,
* doménové události,
* audit,
* outbox,
* event-driven projekce.

Event sourcing lze použít selektivně tam, kde má jasný přínos.

---

# 61. Události a offline synchronizace

Mobilní klient může vytvářet lokální doménové události nebo change log.

Serverovou autoritativní DomainEvent však vytváří až po:

* přijetí commandu,
* validaci,
* potvrzení transakce.

Lokální event může mít jiný status:

* LOCAL_PENDING,
* SERVER_CONFIRMED,
* REJECTED,
* CONFLICTED.

---

# 62. Offline occurredAt

Při offline akci:

* `occurredAt` pochází ze zařízení,
* `recordedAt` přidá server,
* uloží se device clock metadata,
* server nesmí pořadí stavět pouze na klientském čase.

---

# 63. Importované události

Externí provider event není automaticky doménová událost.

Tok:

```text
ProviderWebhookReceived
    ↓
ExternalDataRecordCreated
    ↓
Validation
    ↓
ActivityImported
```

`ProviderWebhookReceived` je integrační nebo technická událost.

`ActivityImported` je doménová událost.

---

# 64. Události a ChangeSet

Jeden ChangeSet může vytvořit více událostí.

Musí být možné zjistit:

* které události patří ke stejné změně,
* zda ChangeSet uspěl celý,
* zda byly použity kompenzace.

---

# 65. ChangeSetCompleted

Po úspěšné aplikaci lze publikovat souhrnnou událost:

```text
ChangeSetApplied
```

Nemá nahrazovat detailní události jednotlivých agregátů.

Konzument si vybírá:

* detailní doménový event,
* nebo souhrnný procesní event.

---

# 66. Process event

Procesní událost popisuje stav dlouhodobého workflow.

Příklady:

* TrainingPlanGenerationCompleted,
* DataImportJobCompleted,
* AccountDeletionCompleted,
* FullResyncCompleted.

Nemusí patřit jednomu klasickému agregátu.

---

# 67. Compensation event

Při kompenzaci může vzniknout například:

```text
ScheduleEventRescheduleCompensated
```

nebo běžná nová událost:

```text
ScheduleEventRescheduled
```

s metadata:

* compensationForChangeSetId.

Preferuje se doménově srozumitelná skutečnost před technickým názvem rollbacku.

---

# 68. Události a audit AI

Nesmí se ukládat soukromý chain-of-thought.

Lze auditovat:

* AIIntentDetected,
* AIProposalCreated,
* ProposalValidated,
* ProposalApproved,
* ChangeSetApplied,
* použitý model,
* prompt template version,
* tool invocation,
* strukturované důvody.

---

# 69. Události a citlivý AI obsah

`AIMessageGenerated` nemá v distribuovaném payloadu obsahovat celý text zprávy.

Může obsahovat:

* messageId,
* conversationId,
* messageType,
* proposalCreated,
* safetyCategory,
* completion status.

---

# 70. Události a notifikace

Notification service může reagovat například na:

* WorkoutScheduled,
* ScheduleEventRescheduled,
* LimitationActivated,
* IntegrationReauthenticationRequired,
* PersonalRecordConfirmed.

Musí respektovat:

* NotificationPreference,
* quiet hours,
* event freshness,
* replay mode,
* aktuální verzi objektu.

---

# 71. Zastaralá notifikace

Před odesláním notifikace musí služba ověřit, zda:

* workout stále existuje,
* čas se nezměnil,
* událost nebyla zrušena,
* reminder je stále povolený.

Starý event nesmí vytvořit zastaralé upozornění.

---

# 72. Event schema registry

Integrační události musí mít centrálně spravovaná schémata.

Registry má obsahovat:

* event type,
* verzi,
* vlastníka,
* schema,
* klasifikaci,
* kompatibilitu,
* příklady,
* deprecation stav.

---

# 73. Vlastník event kontraktu

Každá událost má jednoho doménového vlastníka.

Například:

* WorkoutSessionCompleted vlastní workout doména,
* ActivityImported vlastní activity doména,
* AthleteProfileUpdated vlastní profile doména.

Konzumenti nemají měnit význam události.

---

# 74. Deprecation

Starší verze eventu může být:

* ACTIVE,
* DEPRECATED,
* END_OF_SUPPORT,
* REMOVED.

Musí existovat:

* migrační období,
* seznam konzumentů,
* datum ukončení,
* kompatibilní publisher nebo transformer.

---

# 75. Upcasting

Při replay starších eventů lze použít upcaster:

```text
Event v1
    ↓
Upcaster
    ↓
Event v2 model pro handler
```

Upcaster nesmí vymýšlet fakta, která ve starém eventu neexistovala.

Chybějící údaj musí být:

* null,
* unknown,
* nebo načten z autoritativního snapshotu podle policy.

---

# 76. Downcasting

Obecně se nedoporučuje.

Starý konzument má dostávat:

* starší podporovaný kontrakt,
* nebo být aktualizován.

---

# 77. Event size

Události musí mít rozumnou velikost.

Velká data se předávají pomocí reference:

* GPS route blob,
* obrázek,
* video,
* dlouhá sensor série,
* exportní soubor.

Událost obsahuje:

* resourceId,
* checksum,
* classification,
* availability state.

---

# 78. Retence

Různé event streamy mohou mít rozdílnou retenci.

## 78.1 Dlouhodobě významné

* změny plánu,
* bezpečnostní omezení,
* souhlasy,
* účetní a právní události,
* audit změn.

## 78.2 Kratší technická retence

* cache invalidation,
* běžné sync pokusy,
* heartbeat,
* transient telemetry.

Přesná retence musí respektovat:

* GDPR,
* právní účel,
* export,
* smazání účtu,
* potřebu replay.

---

# 79. Smazání uživatele a eventy

Po smazání účtu je nutné řešit:

* odstranění nebo anonymizaci osobních payloadů,
* zachování právně nutných auditních údajů,
* odstranění projekcí,
* zneplatnění odkazů,
* zákaz replay osobních eventů do aktivních read modelů.

---

# 80. Event anonymization

Pokud musí být event zachován bez osobní identity:

* ownerId se pseudonymizuje nebo odstraní,
* payload se minimalizuje,
* citlivé reference se odstraní,
* vazba zpět na osobu nesmí zůstat bez právního důvodu.

---

# 81. Přístup ke streamům

Oprávnění se musí řídit:

* službou,
* event type,
* data classification,
* prostředím,
* účelem.

Notification service nepotřebuje přístup k celému zdravotnímu payloadu.

---

# 82. Produkční a testovací eventy

Testovací eventy nesmí vstoupit do produkční historie.

Musí být odděleny pomocí:

* prostředí,
* namespace,
* tenant,
* test flag pouze v izolovaném systému.

---

# 83. Event observability

Musí být sledováno:

* počet publikovaných eventů,
* publish latency,
* consumer lag,
* failure rate,
* dead-letter count,
* duplicate delivery,
* event size,
* schema errors,
* projection delay.

---

# 84. SLO příklady

Budoucí technická specifikace může určit:

* kritické safety eventy zpracované do několika sekund,
* běžné read modely aktualizované v krátkém intervalu,
* historické agregace do několika minut.

Doménový dokument neurčuje přesná čísla.

---

# 85. Event storm prevention

Jedna změna nesmí nekontrolovaně spustit nekonečný cyklus.

Příklad rizika:

```text
MetricUpdated
    ↓
ProgressUpdated
    ↓
PlanRecalculationRequested
    ↓
MetricUpdated
```

Každý handler musí mít:

* jasnou odpovědnost,
* idempotenci,
* podmínky publikování,
* kauzální ochranu.

---

# 86. Cyclic causation detection

Lze sledovat:

* correlationId,
* causation chain,
* maximální hloubku,
* opakované event type v procesu.

Při podezření se workflow zastaví a vytvoří technický incident.

---

# 87. Publikování pouze při skutečné změně

Příkaz, který nezmění stav, nemá vytvářet falešnou doménovou událost.

Může vrátit:

* NO_OP,
* ALREADY_APPLIED.

Příklad:

Nastavení stejné hodnoty preference znovu nemusí vytvořit `PreferenceChanged`.

---

# 88. Události s původní a novou hodnotou

Používat jen tam, kde je to prakticky potřebné.

Příklad:

```text
GoalPriorityChanged
- previousPriority
- newPriority
```

U velkých objektů je vhodnější:

* změněné field codes,
* nová revision reference.

---

# 89. Snapshot reference

Událost může obsahovat:

* revisionId,
* snapshotVersion.

Konzument si může načíst autorizovaný stav.

Musí počítat s tím, že aktuální stav už může být novější.

---

# 90. Katalog domén identity a profilu

Hlavní události:

* IdentityCreated
* IdentityVerified
* IdentityLocked
* IdentityUnlocked
* IdentityCompromised
* IdentityMerged
* AuthenticationIdentityLinked
* AuthenticationIdentityUnlinked
* AuthenticationIdentityVerified
* UserAccountCreated
* UserAccountActivated
* UserAccountSuspended
* UserAccountReactivated
* UserAccountDeletionRequested
* UserAccountDeletionCancelled
* UserAccountDeleted
* AthleteProfileCreated
* AthleteProfileActivated
* AthleteProfileUpdated
* AthleteProfilePaused
* AthleteProfileArchived
* AthleteProfileMerged
* AthleteProfileRevisionCreated
* ProfileSectionUpdated
* ProfileCompletenessChanged
* ProfileReviewRequested
* ProfileReviewCompleted
* OnboardingStarted
* OnboardingStepCompleted
* OnboardingPaused
* OnboardingCompleted
* OnboardingAbandoned
* UnitPreferenceChanged
* LocalePreferenceChanged
* TimeZonePreferenceChanged
* NotificationPreferenceChanged
* AccessibilityPreferenceChanged
* AIInteractionPreferenceChanged
* PrivacyPreferenceChanged
* DataProcessingConsentGranted
* DataProcessingConsentRevoked
* LegalDocumentAccepted
* AnonymousAccountUpgraded
* ActiveProfileChanged
* DataExportRequested
* DataExportCompleted

---

# 91. Katalog sportů a cílů

* UserSportCreated
* UserSportActivated
* UserSportUpdated
* UserSportPaused
* UserSportArchived
* UserSportPriorityChanged
* SportExperienceUpdated
* ParticipationPatternCreated
* ParticipationPatternUpdated
* GoalCreated
* GoalActivated
* GoalUpdated
* GoalPriorityChanged
* GoalPaused
* GoalResumed
* GoalCompleted
* GoalAbandoned
* GoalArchived
* GoalRevisionCreated
* GoalMetricLinked
* GoalMetricUnlinked
* GoalProgressUpdated
* GoalMilestoneReached
* GoalAssessmentCompleted
* GoalBecameAtRisk
* GoalReturnedOnTrack
* GoalConflictDetected
* GoalConflictResolved

---

# 92. Katalog training plan domény

* TrainingPlanDraftCreated
* TrainingPlanGenerated
* TrainingPlanValidated
* TrainingPlanValidationFailed
* TrainingPlanActivated
* TrainingPlanPaused
* TrainingPlanResumed
* TrainingPlanCompleted
* TrainingPlanCancelled
* TrainingPlanArchived
* TrainingPlanVersionCreated
* TrainingPlanVersionActivated
* TrainingPlanVersionSuperseded
* TrainingBlockCreated
* TrainingBlockUpdated
* TrainingBlockStarted
* TrainingBlockCompleted
* TrainingBlockPaused
* TrainingBlockExtended
* TrainingWeekCreated
* TrainingWeekUpdated
* TrainingWeekStarted
* TrainingWeekCompleted
* DeloadWeekCreated
* PlanAdjustmentProposed
* PlanAdjustmentApproved
* PlanAdjustmentRejected
* PlanAdjustmentApplied
* PlanRegenerationRequested
* PlanRegenerated

---

# 93. Katalog workout domény

* WorkoutTemplateCreated
* WorkoutTemplateUpdated
* WorkoutTemplateDeprecated
* WorkoutInstanceCreated
* WorkoutInstanceRevisionCreated
* WorkoutInstanceScheduled
* WorkoutInstanceUpdated
* WorkoutInstanceAdapted
* WorkoutInstanceShortened
* WorkoutInstanceRescheduled
* WorkoutInstanceCancelled
* WorkoutInstanceSkipped
* WorkoutInstanceReplaced
* WorkoutInstanceCompleted
* WorkoutExerciseAdded
* WorkoutExerciseRemoved
* WorkoutExerciseReplaced
* WorkoutExerciseReordered
* WorkoutVolumeChanged
* WorkoutIntensityChanged
* WorkoutSessionStarted
* WorkoutSessionPaused
* WorkoutSessionResumed
* WorkoutSessionRecovered
* WorkoutSessionCompleted
* WorkoutSessionPartiallyCompleted
* WorkoutSessionAbandoned
* WorkoutSessionInvalidated
* SetPerformanceRecorded
* SetPerformanceCorrected
* StepPerformanceRecorded
* ExerciseSkipped
* ExerciseSubstituted
* RestTimerStarted
* RestTimerCompleted
* WorkoutFeedbackRecorded
* WorkoutIssueReported

---

# 94. Katalog scheduling domény

* ScheduleEventCreated
* ScheduleEventUpdated
* ScheduleEventScheduled
* ScheduleEventRescheduled
* ScheduleEventCancelled
* ScheduleEventSkipped
* ScheduleEventCompleted
* ScheduleEventRestored
* ScheduleEventLinkedToWorkout
* ScheduleEventUnlinkedFromWorkout
* RecurrenceRuleCreated
* RecurrenceRuleUpdated
* RecurrenceRuleCancelled
* RecurrenceInstanceMaterialized
* ScheduleConflictDetected
* ScheduleConflictResolved
* AvailabilityWindowCreated
* AvailabilityWindowUpdated
* AvailabilityWindowRemoved
* BusyIntervalImported
* EventGroupCreated
* EventGroupUpdated
* EventGroupCancelled
* ReminderScheduled
* ReminderRescheduled
* ReminderCancelled

---

# 95. Katalog activity domény

* ActivityDraftCreated
* ActivityRecordingStarted
* ActivityRecordingPaused
* ActivityRecordingResumed
* ActivityRecordingCompleted
* ActivityCreated
* ActivityCreatedFromWorkout
* ActivityCreatedManually
* ActivityImported
* ActivityValidated
* ActivityValidationFailed
* ActivityProcessingCompleted
* ActivityProcessingFailed
* ActivityMatchedToScheduleEvent
* ActivityMatchedToWorkout
* ActivityMatchRejected
* ActivityMarkedAsReplacement
* ActivityMarkedAsPartialCompletion
* ActivityDuplicateDetected
* ActivityMarkedAsDuplicate
* ActivitiesMerged
* ActivitiesSeparated
* ActivityCorrected
* ActivityInvalidated
* ActivityRestored
* ActivityDeleted
* ActivityFeedbackRecorded
* ActivityMetricAdded
* ActivityMetricsUpdated
* ActivityLoadCalculated
* ActivityBodyLoadCalculated
* ActivityRouteProcessed
* ActivityRouteDeleted
* ActivityLinkedToGoal
* ActivityUnlinkedFromGoal
* ActivityGroupCreated

---

# 96. Katalog recovery a limitation domény

* DailyCheckInRecorded
* DailyCheckInCorrected
* FatigueReported
* FatigueReportUpdated
* MuscleSorenessReported
* StressReported
* SleepRecordCreated
* SleepRecordImported
* SleepRecordCorrected
* SleepSummaryUpdated
* RecoveryMetricRecorded
* RecoveryMetricCorrected
* RecoveryTrendChanged
* ReadinessAssessed
* ReadinessAssessmentExpired
* RecoveryRecommendationCreated
* RecoveryAdjustmentProposed
* RecoveryAdjustmentApproved
* RecoveryAdjustmentRejected
* RecoveryAdjustmentApplied
* PainReported
* PainReportCorrected
* PainAssessmentCompleted
* PainTrendChanged
* SafetyFlagDetected
* SafetyAssessmentCompleted
* SafetyRestrictionTriggered
* SafetyRestrictionCleared
* LimitationCreated
* LimitationActivated
* LimitationUpdated
* LimitationSuspended
* LimitationExpired
* LimitationResolved
* LimitationReplaced
* LimitationReviewRequested
* LimitationReviewCompleted
* ProfessionalRecommendationRecorded
* ProfessionalRecommendationUpdated
* ReturnToActivityPlanCreated
* ReturnToActivityPhaseStarted
* ReturnToActivityPhaseCompleted
* ReturnToActivityPlanCompleted
* WorkoutBlockedByLimitation
* WorkoutModifiedForRecovery
* ManualSafetyOverrideRecorded
* DeloadRecommended

---

# 97. Katalog AI a změnové domény

* AIConversationCreated
* AIConversationArchived
* AIConversationDeleted
* AIMessageReceived
* AIMessageGenerated
* AIMessageGenerationFailed
* AIIntentDetected
* AIIntentDetectionFailed
* AIClarificationRequested
* AIContextPrepared
* AIProposalCreated
* AIProposalRevised
* AIProposalValidated
* AIProposalValidationFailed
* AIProposalBecameStale
* AIProposalExpired
* AIProposalSuperseded
* AIProposalApproved
* AIProposalPartiallyApproved
* AIProposalRejected
* AIToolInvocationCreated
* AIToolInvocationAuthorized
* AIToolInvocationRejected
* AIToolInvocationStarted
* AIToolInvocationSucceeded
* AIToolInvocationFailed
* ChangeSetCreated
* ChangeSetValidated
* ChangeSetValidationFailed
* ChangeSetApproved
* ChangeSetPartiallyApproved
* ChangeSetExecutionStarted
* ChangeOperationApplied
* ChangeOperationFailed
* ChangeSetApplied
* ChangeSetPartiallyApplied
* ChangeSetFailed
* ChangeSetBecameStale
* ChangeConflictDetected
* ChangeConflictResolved
* UndoPlanCreated
* ChangeSetRevertRequested
* ChangeSetReverted
* ChangeSetRevertFailed
* CompensationApplied
* AutomationPolicyChanged

---

# 98. Katalog metrics domény

* MetricDefinitionCreated
* MetricDefinitionUpdated
* MetricDefinitionDeprecated
* CustomMetricDefinitionCreated
* MetricValueRecorded
* MetricValueValidated
* MetricValueRejected
* MetricValueCorrected
* MetricValueInvalidated
* MetricValueDeleted
* MetricSeriesCreated
* MetricSampleRecorded
* MetricSeriesCompleted
* MetricSeriesInvalidated
* MetricAggregateCalculated
* MetricAggregateInvalidated
* DerivedMetricCalculated
* DerivedMetricInvalidated
* MetricCalculationFailed
* MetricBaselineCalculated
* MetricBaselineUpdated
* MetricTrendCalculated
* MetricTargetCreated
* MetricTargetReached
* MetricTargetMissed
* PersonalRecordCandidateDetected
* PersonalRecordConfirmed
* PersonalRecordInvalidated
* MetricConflictDetected
* MetricConflictResolved
* ProgressSnapshotCreated
* AdherenceCalculated
* LoadMetricCalculated
* RecalculationRequested
* RecalculationStarted
* RecalculationCompleted
* RecalculationFailed

---

# 99. Katalog integration domény

* IntegrationProviderActivated
* IntegrationProviderDegraded
* IntegrationProviderSuspended
* UserIntegrationConnectionStarted
* UserIntegrationConnected
* UserIntegrationPartiallyConnected
* UserIntegrationConnectionFailed
* IntegrationPermissionRequested
* IntegrationPermissionGranted
* IntegrationPermissionDenied
* IntegrationPermissionRevoked
* IntegrationReauthenticationRequired
* IntegrationPaused
* IntegrationResumed
* UserIntegrationDisconnectRequested
* UserIntegrationDisconnected
* IntegrationCredentialRefreshed
* IntegrationCredentialRevoked
* DataImportJobCreated
* DataImportStarted
* DataImportCompleted
* DataImportPartiallyCompleted
* DataImportFailed
* HistoricalBackfillStarted
* HistoricalBackfillCompleted
* ExternalDataRecordReceived
* ExternalDataRecordValidated
* ExternalDataRecordNormalized
* ExternalDataRecordMapped
* ExternalDataRecordImported
* ExternalDataRecordRejected
* ExternalDataRevisionReceived
* ExternalResourceDeletedAtSource
* DuplicateExternalActivityDetected
* DataExportJobCreated
* DataExportStarted
* DataExportCompleted
* DataExportFailed
* ExternalCalendarEventLinked
* ExternalCalendarEventUnlinked
* ExternalCalendarLinkBroken
* IntegrationWebhookSubscribed
* IntegrationWebhookRenewed
* IntegrationWebhookExpired
* IntegrationWebhookEventReceived
* IntegrationWebhookValidationFailed
* IntegrationRateLimitReached
* IntegrationConflictDetected
* IntegrationConflictResolved
* IntegrationMappingUpdated
* IntegrationHealthChanged
* IntegrationRepairRequested
* IntegrationRepairCompleted
* IntegrationReconciliationCompleted

---

# 100. Katalog sync a offline domény

* DeviceInstallationRegistered
* DeviceInstallationRevoked
* DeviceSessionStarted
* DeviceSessionEnded
* LocalEntityCreated
* LocalEntityChanged
* OfflineCommandCreated
* OfflineCommandExecutedLocally
* OfflineCommandRejected
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
* ServerChangeApplied
* SyncCursorAdvanced
* FullResyncStarted
* FullResyncCompleted
* FullResyncFailed
* TombstoneCreated
* TombstoneReceived
* LocalEntityMerged
* EntityAliasCreated
* PendingUploadCreated
* PendingUploadStarted
* PendingUploadCompleted
* PendingUploadFailed
* RecoveryCheckpointCreated
* ActiveSessionRecovered
* LocalDatabaseMigrationStarted
* LocalDatabaseMigrationCompleted
* LocalDatabaseMigrationFailed
* LocalDatabaseRepairCompleted
* SyncHealthChanged
* UnsyncedDataDiscarded
* BackgroundSyncRequested

---

# 101. Katalog vztahů a oprávnění

* CoachInvitationCreated
* CoachInvitationAccepted
* CoachInvitationRejected
* CoachAthleteRelationshipActivated
* CoachAthleteRelationshipPaused
* CoachPermissionChanged
* CoachAthleteRelationshipRevoked
* GuardianRelationshipCreated
* GuardianRelationshipVerified
* GuardianPermissionChanged
* GuardianRelationshipRevoked
* ManagedProfileCreated
* ProfileRoleGranted
* ProfileRoleChanged
* ProfileRoleRevoked
* OrganizationMembershipCreated
* OrganizationMembershipChanged
* OrganizationMembershipRevoked

---

# 102. Události, které nesmí automaticky spouštět změnu plánu

Například:

* ActivityImported,
* LowRecoveryScoreImported,
* GoalProgressUpdated,
* SleepRecordImported.

Tyto události mohou spustit:

* vyhodnocení,
* návrh,
* RecoveryRecommendation,
* PlanAdjustmentProposal.

Nemají samy bez policy a validace přímo měnit aktivní plán.

---

# 103. Události spouštějící přepočty

Příklady:

## Metric recalculation

* ActivityCorrected
* ActivitiesMerged
* MetricValueCorrected
* SleepRecordCorrected

## Goal progress

* ActivityValidated
* ActivityLinkedToGoal
* MetricAggregateCalculated
* WorkoutSessionCompleted

## Readiness

* DailyCheckInRecorded
* SleepSummaryUpdated
* ActivityLoadCalculated
* PainReported
* LimitationActivated

---

# 104. Události spouštějící kontrolu notifikací

* ScheduleEventCreated
* ScheduleEventRescheduled
* ScheduleEventCancelled
* WorkoutInstanceAdapted
* LimitationActivated
* UserIntegrationReauthenticationRequired
* TimeZonePreferenceChanged
* NotificationPreferenceChanged

---

# 105. Události spouštějící invalidaci cache

* AthleteProfileUpdated
* TrainingPlanVersionActivated
* WorkoutInstanceRevisionCreated
* ActivityCorrected
* MetricAggregateCalculated
* GoalProgressUpdated
* PrivacyPreferenceChanged.

Cache invalidation je technický efekt.

Nemusí publikovat další doménovou událost.

---

# 106. Události spouštějící AI kontext invalidaci

* GoalUpdated
* TrainingPlanVersionActivated
* WorkoutInstanceRevisionCreated
* DailyCheckInRecorded
* PainReported
* LimitationActivated
* LimitationResolved
* AthleteProfileUpdated
* AvailabilityProfileUpdated.

AI Proposal odkazující na starší kontext může přejít do STALE.

---

# 107. Události a safety priorita

Safety eventy mají vyšší prioritu zpracování:

* SafetyFlagDetected
* SafetyRestrictionTriggered
* LimitationActivated
* ProfessionalRecommendationRecorded
* DeviceInstallationRevoked
* DataProcessingConsentRevoked.

Konzumenti musí mít definovanou maximální přijatelnou latenci.

---

# 108. Události vyžadující aktuální kontrolu stavu

Některé eventy jsou pouze trigger.

Konzument si musí před akcí načíst aktuální stav.

Příklad:

`ScheduleEventCreated` spustí plánování reminderu.

Před vytvořením reminderu se ověří:

* event stále existuje,
* nebyl přesunut,
* notifikace jsou povolené.

---

# 109. Události a výpočtové verze

Výpočtové eventy musí obsahovat:

* calculationDefinition,
* calculationVersion,
* input completeness,
* confidence.

Příklad:

```text
ActivityLoadCalculated
- activityId
- loadMetricId
- methodCode
- methodVersion
- confidence
```

---

# 110. Události a uživatelská oprava

Correction event musí zachovat:

* correctedObjectId,
* correctionId,
* correctedFields,
* actor,
* reason code,
* previous revision,
* new revision.

Nemusí distribuovat citlivé původní a nové hodnoty všem konzumentům.

---

# 111. ReasonCode

Události mohou používat strukturované důvody.

Příklady:

* USER_REQUEST,
* RECOVERY_ADJUSTMENT,
* PAIN_REPORTED,
* SCHEDULE_CONFLICT,
* GOAL_CHANGED,
* PROVIDER_CORRECTION,
* DUPLICATE_MERGE,
* ADMINISTRATIVE_REPAIR.

Volný text důvodu zůstává v auditním objektu podle citlivosti.

---

# 112. Události a localization

Event payloady obsahují:

* stabilní interní kódy,
* nikoliv již přeložený text.

Překlad vzniká až v prezentační vrstvě.

---

# 113. Události a jednotky

Numerické hodnoty v události musí mít:

* MetricDefinition nebo jasný field contract,
* jednotku,
* ideálně kanonickou hodnotu,
* původní jednotku jen pokud je relevantní.

Nesmí být publikováno neurčité:

```text
distance = 10
```

bez definovaného významu.

---

# 114. Události a časová pásma

Event envelope používá absolutní timestamps.

Doménový payload může navíc obsahovat:

* localDate,
* localTime,
* IANA timezone,
* timezone policy.

To je nutné například u ScheduleEvent.

---

# 115. Události a recurrence

Událost změny opakované série musí uvést scope:

* THIS_INSTANCE,
* ENTIRE_SERIES,
* THIS_AND_FOLLOWING.

Jinak konzument nemůže správně interpretovat dopad.

---

# 116. Události a více profilů

Každá událost pracující se sportovními daty musí mít:

* athleteProfileId.

`accountId` samotné v budoucím multi-profile modelu nestačí.

---

# 117. Události a trenér

Změna provedená trenérem musí obsahovat:

* actorType = COACH,
* coachAccountId,
* athleteProfileId,
* relationshipId,
* permission scope reference.

To umožňuje auditovat oprávnění v okamžiku změny.

---

# 118. Události a anonymní účet

Při upgradu anonymního účtu:

* původní objekty nemají měnit ID,
* eventy získají aktualizovanou identity vazbu podle bezpečné migrace,
* nevytvářejí se duplicitní creation eventy.

---

# 119. Události a importované zařízení

Provider lineage se neukládá do každého doménového eventu v plné podobě.

Event může obsahovat:

* primarySourceRecordId,
* providerCode,
* originSourceType.

Detail zůstává v integrační doméně.

---

# 120. Event consumer registry

Musí existovat přehled:

* event type,
* verze,
* producent,
* konzumenti,
* účel konzumenta,
* data classification,
* owner team,
* retry policy.

Pomáhá při:

* změně schématu,
* odstraňování události,
* incidentu,
* auditu přístupu.

---

# 121. Dokumentace jednoho eventu

Každá významná událost musí mít samostatnou specifikaci nebo katalogový záznam:

```text
Event name:
Owner:
Purpose:
Producer:
Trigger:
Aggregate:
Payload:
Classification:
Consumers:
Ordering:
Idempotency:
Retention:
Versions:
Example:
```

---

# 122. Příklad – WorkoutSessionCompleted

```text
Event name:
WorkoutSessionCompleted

Owner:
Workout domain

Producer:
WorkoutService

Trigger:
Úspěšné dokončení WorkoutSession

Aggregate:
WorkoutSession

Key payload:
- workoutSessionId
- workoutInstanceId
- workoutInstanceRevisionId
- athleteProfileId
- startedAt
- completedAt
- completionStatus
- sessionRpe
- issueCount
- localOriginDeviceId

Classification:
HEALTH_RELATED

Likely consumers:
- ActivityService
- MetricsService
- GoalProgressService
- RecoveryService
- NotificationService
- SyncChangeFeedService
```

---

# 123. Příklad – PainReported

```text
Event name:
PainReported

Owner:
Recovery and Limitations domain

Key payload:
- painReportId
- athleteProfileId
- occurredAt
- bodyAreaCode
- laterality
- severityBand
- duringActiveWorkout
- safetyReviewRequired

Classification:
HEALTH_RELATED

Likely consumers:
- PainAssessmentService
- SafetyRulesEngine
- WorkoutService
- PlanAdjustmentService
- SyncChangeFeedService
```

Plný popis bolesti není v běžném event payloadu.

---

# 124. Příklad – ScheduleEventRescheduled

```text
Event name:
ScheduleEventRescheduled

Key payload:
- scheduleEventId
- athleteProfileId
- previousStart
- previousEnd
- newStart
- newEnd
- timezone
- recurrenceScope
- reasonCode
- changeSetId
```

Konzumenti:

* ReminderService,
* ExternalCalendarExportService,
* TodayProjection,
* WeeklyScheduleProjection,
* AIProposalValidityService.

---

# 125. Příklad – ActivityImported

```text
Event name:
ActivityImported

Key payload:
- activityId
- athleteProfileId
- primarySourceRecordId
- providerCode
- activityType
- sportId
- startedAt
- endedAt
- duplicateReviewRequired
- processingState
```

Událost sama nemusí znamenat, že Activity je již připravena pro:

* load,
* goals,
* personal records.

K tomu slouží například `ActivityValidated`.

---

# 126. Příklad – TrainingPlanVersionActivated

Konzumenti mohou:

* materializovat WorkoutInstance,
* aktualizovat schedule projekci,
* invalidovat staré AI Proposal,
* přepočítat reminder,
* synchronizovat zařízení.

Payload musí obsahovat:

* trainingPlanId,
* activatedVersionId,
* previousVersionId,
* effectiveFrom,
* athleteProfileId,
* activationReason.

---

# 127. Příklad – DataProcessingConsentRevoked

Tato událost má vysokou bezpečnostní prioritu.

Konzumenti mohou:

* zakázat AI zpracování,
* zastavit analytické exporty,
* upravit integrace,
* zahájit data cleanup,
* invalidovat cache.

Payload:

* consentId,
* accountId,
* athleteProfileId podle scope,
* purposeCode,
* revokedAt,
* effectiveImmediately.

---

# 128. Příklad – ActivitiesMerged

Payload může obsahovat:

* canonicalActivityId,
* mergedActivityIds,
* athleteProfileId,
* mergeReason,
* sourceCount,
* affectedMetricCategories,
* recalculationRequired.

Konzumenti musí:

* opravit reference,
* zneplatnit duplicitní agregace,
* přepočítat rekordy,
* aktualizovat projekce.

---

# 129. Příklad – AIProposalBecameStale

Payload:

* proposalId,
* proposalRevisionId,
* athleteProfileId,
* staleReasonCode,
* changedContextReferences,
* detectedAt.

Konzumenti:

* chat UI,
* proposal review UI,
* notification service podle potřeby.

---

# 130. Příklad – SyncConflictRequiresReview

Payload:

* conflictId,
* athleteProfileId,
* entityType,
* entityId,
* conflictType,
* severity,
* safeTemporaryState,
* sourceDeviceIds.

Citlivé hodnoty konfliktu se načtou přes autorizovaný detail.

---

# 131. Event contract testy

Každý event má mít testy:

* schema validation,
* required fields,
* backward compatibility,
* serialization,
* deserialization,
* classification,
* redaction,
* example payload.

---

# 132. Consumer contract testy

Každý konzument má testovat:

* podporované verze,
* duplicate delivery,
* out-of-order delivery,
* retry,
* malformed event,
* replay mode,
* missing referenced object.

---

# 133. End-to-end event testy

Příklady:

* dokončení workoutu vytvoří Activity,
* Activity aktualizuje cílový progress,
* změna schedule přepočítá reminder,
* odvolání souhlasu zastaví AI processing,
* LimitationActivated zabrání nevhodnému workoutu.

---

# 134. Chaos testy

Systém musí být testován při:

* duplicitním eventu,
* zpožděném eventu,
* eventu mimo pořadí,
* nedostupném brokeru,
* pádu outbox publisheru,
* pádu handleru po částečném zápisu,
* obnově dead-letter eventu.

---

# 135. Transakce handleru

Konzument má ve své transakci uložit:

* doménovou změnu nebo projekci,
* InboxRecord,
* případný vlastní OutboxMessage.

Tím se zabrání:

* aplikaci změny bez označení eventu jako zpracovaného,
* publikování další události bez uloženého výsledku.

---

# 136. Handler side effects

Externí side effect, například e-mail nebo provider API, vyžaduje:

* vlastní idempotency key,
* outbox nebo job,
* potvrzený stav.

Handler nemá přímo během broker callbacku provést nevratnou externí operaci bez ochrany.

---

# 137. Event processing priority

Doporučené třídy:

* CRITICAL,
* HIGH,
* NORMAL,
* LOW,
* BULK.

## CRITICAL

* consent revocation,
* safety restriction,
* device revocation,
* account deletion.

## HIGH

* aktivní workout,
* dnešní schedule,
* pain assessment,
* aktuální limitation.

## NORMAL

* aktivity,
* cíle,
* běžné projekce.

## LOW/BULK

* historické přepočty,
* backfill,
* analytické projekce.

---

# 138. Oddělené fronty

Pro snížení rizika lze oddělit:

* critical safety events,
* user-facing domain events,
* integration jobs,
* bulk recalculation,
* telemetry.

Historický backfill nesmí zablokovat PainReported.

---

# 139. Backpressure

Při přetížení se mají omezit:

* bulk přepočty,
* staré projekce,
* nepovinné analytické eventy.

Nemají být odloženy kritické:

* safety,
* consent,
* active workout,
* account security eventy.

---

# 140. Event processing state v UI

Uživatel nemá vidět interní broker stav.

Může vidět produktové stavy:

* aktivita se zpracovává,
* graf se aktualizuje,
* import pokračuje,
* změna čeká na synchronizaci,
* vyžaduje kontrolu.

---

# 141. Doménové invariance eventů

* Událost popisuje již nastalou skutečnost.
* EventId je globálně unikátní.
* EventType a EventVersion musí být registrované.
* Událost musí mít occurredAt.
* Událost změny agregátu musí mít aggregateId a aggregateVersion.
* Událost nesmí být po publikování změněna.
* Stejná událost může být doručena vícekrát.
* Konzument musí být idempotentní.
* Citlivý payload musí být minimalizován.
* Původní událost se při opravě nemaže; vzniká nová opravná skutečnost.
* Replay nesmí nechtěně opakovat externí vedlejší efekty.
* Doménová změna a outbox zápis musí být transakčně konzistentní.
* Event version nesmí měnit význam existujícího pole.
* Neznámý kritický event se nesmí tiše ignorovat.
* Událost nesmí být použita jako náhrada synchronní autorizace.
* User-facing notifikace musí ověřit aktuální stav.
* Safety event nesmí čekat za bulk frontou.
* Odvolání souhlasu musí mít okamžitý nebo jasně definovaný účinek.
* Smazání uživatele musí řešit event payloady a projekce.
* AI události nesmí ukládat chain-of-thought.

---

# 142. Doporučené technické členění

```text
events/
├── envelope/
├── identity/
├── profile/
├── sports/
├── goals/
├── plans/
├── workouts/
├── scheduling/
├── activities/
├── recovery/
├── ai/
├── metrics/
├── integrations/
├── sync/
└── relationships/
```

Každá složka může obsahovat:

* schema,
* examples,
* compatibility tests,
* documentation.

---

# 143. Event topic strategy

Konkrétní broker zatím není určen.

Možné strategie:

## Topic podle domény

```text
workout-events
activity-events
recovery-events
```

## Topic podle klasifikace

```text
critical-safety-events
health-domain-events
general-domain-events
```

## Kombinovaný model

Rozhodnutí musí zohlednit:

* pořadí,
* zabezpečení,
* množství,
* konzumenty,
* provozní jednoduchost.

---

# 144. Tenant a owner partitioning

Pokud vznikne multi-tenant organizace, event envelope musí umožnit:

* tenantId,
* athleteProfileId,
* accountId.

Tenant partition nesmí umožnit únik dat mezi organizacemi.

---

# 145. Události pro budoucí wearables klienty

Hodinky mohou odebírat například:

* WorkoutInstancePreparedForDevice,
* WorkoutInstanceUpdated,
* WorkoutInstanceCancelled,
* ActiveLimitationChanged,
* UserUnitPreferenceChanged.

Zařízení nemusí dostávat celý obecný event stream.

Použije se bezpečný device sync model.

---

# 146. Události pro budoucí trenérský portál

Trenérský portál může reagovat na:

* AthleteCompletedAssignedWorkout,
* PlanChangeRequested,
* CoachProposalApproved,
* AthleteSharedActivity,
* CoachRelationshipRevoked.

Tyto mohou být specializované integrační eventy odvozené z interních doménových událostí.

---

# 147. Event naming anti-patterns

Nevhodné:

* UpdateWorkoutEvent
* WorkoutChangedSomething
* ProcessActivity
* TableRowInserted
* HandlePain
* SendNotification

Vhodné:

* WorkoutInstanceRescheduled
* ActivityValidated
* PainReported
* NotificationPreferenceChanged.

---

# 148. Payload anti-patterns

Nevhodné:

```text
payload: arbitrary JSON
```

Nevhodné:

```text
entity: complete database row
```

Nevhodné:

```text
value: string
```

bez definice.

Vhodné je explicitní verzované schéma.

---

# 149. Event governance

Musí být stanoveno:

* kdo může vytvořit nový event type,
* kdo schvaluje změnu schématu,
* jak se kontroluje citlivost,
* jak se evidují konzumenti,
* jak se event deprecatuje,
* jak se testuje kompatibilita.

---

# 150. Checklist před přidáním události

Před vytvořením nového eventu je nutné odpovědět:

1. Jaká doménová skutečnost nastala?
2. Který agregát ji vlastní?
3. Je skutečně potřebná pro jinou část systému?
4. Nestačí interní metoda nebo audit?
5. Jaká je datová klasifikace?
6. Jaký je minimální payload?
7. Jak se zajistí idempotence?
8. Potřebuje pořadí?
9. Jak dlouho se uchovává?
10. Co se stane při replay?
11. Kdo je konzument?
12. Co se stane při chybě?
13. Jak se bude verze měnit?
14. Jak se event testuje?

---

# 151. Otevřené otázky

* Jaký message broker bude použit?
* Bude backend nejprve modulární monolit, nebo více služeb?
* Budou události v první verzi interní in-process a outbox-ready?
* Jaké události musí být distribuované už v MVP?
* Jak bude vypadat event schema registry?
* Použije se JSON, Avro, Protobuf nebo jiný formát?
* Jaké budou topic naming conventions?
* Jaké eventy potřebují přísné pořadí?
* Jaký partition key použít?
* Jak dlouho uchovávat jednotlivé streamy?
* Jak dlouho uchovávat outbox?
* Jak dlouho uchovávat inbox?
* Jak řešit event payload po smazání účtu?
* Jak přesně anonymizovat historické eventy?
* Které eventy budou součástí právního auditu?
* Které eventy budou dostupné trenérskému portálu?
* Jak oddělit health-related streamy?
* Které eventy potřebují šifrování na úrovni payloadu?
* Jak řešit key rotation?
* Jak zabránit úniku payloadu do logů?
* Jak definovat maximální velikost eventu?
* Jak řešit blob reference?
* Jak detekovat chybějící aggregate version?
* Jak dlouho čekat na event mimo pořadí?
* Jak rekonstruovat projekci bez úplného event sourcingu?
* Kdy použít aktuální snapshot místo replay?
* Jak implementovat replay mode?
* Jak potlačit notifikace při replay?
* Jak zabránit cyklickým procesům?
* Jak auditovat automatické merge?
* Jak testovat duplicate delivery?
* Jak testovat broker outage?
* Jak funguje outbox při databázovém failoveru?
* Jak funguje inbox u více instancí konzumenta?
* Jak provádět blue-green nasazení event schématu?
* Jak podporovat starší mobilní klienty?
* Které události budou mapovány do device change feedu?
* Jaká metadata musí mít event z offline commandu?
* Jak řešit nesprávný device clock?
* Jaký je vztah EventId a CommandId?
* Jak eventy mapovat na OpenTelemetry trace?
* Jaké eventy budou publikované do analytiky?
* Jak odfiltrovat citlivé hodnoty?
* Jak monitorovat consumer lag?
* Jaké budou SLO pro safety události?
* Jak odlišit doménový event a process event v kódu?
* Jaké události se publikují při částečném ChangeSet?
* Jak přesně modelovat kompenzační události?
* Jaký event vzniká při NO_OP?
* Jak dokumentovat event katalog automaticky?
* Jak kontrolovat nepoužívané eventy?
* Jak bezpečně odstranit posledního konzumenta?
* Jak řešit eventy při migraci modulárního monolitu na mikroservisy?

---

# 152. Navazující dokumenty

Na tento dokument navazuje zejména:

```text
docs/06-domain/
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/07-backend/
├── backend-architecture.md
├── modular-boundaries.md
├── event-architecture.md
├── transactional-outbox.md
├── idempotent-consumers.md
├── event-schema-registry.md
├── audit-service.md
├── change-feed-service.md
└── observability.md
```

Dále:

```text
docs/09-security/
├── event-security.md
├── data-classification.md
├── audit-and-retention.md
└── data-deletion.md
```

A:

```text
docs/10-quality/
├── event-contract-testing.md
├── event-replay-testing.md
├── event-chaos-testing.md
└── projection-testing.md
```

---

# 153. Kritéria správného event modelu

Model je vhodný pouze tehdy, pokud umožní:

1. rozlišit command a event,
2. rozlišit doménový a integrační event,
3. rozlišit event a audit,
4. používat společnou event envelope,
5. jednoznačně identifikovat event,
6. verzovat schéma,
7. určit agregát a jeho verzi,
8. zachovat occurredAt a recordedAt,
9. sledovat aktéra,
10. sledovat korelaci a kauzalitu,
11. propojit event s ChangeSet,
12. klasifikovat citlivost,
13. minimalizovat payload,
14. publikovat transakčně přes outbox,
15. konzumovat idempotentně,
16. zvládnout opakované doručení,
17. zvládnout event mimo pořadí,
18. detekovat chybějící verzi,
19. opakovat dočasné chyby,
20. používat dead-letter flow,
21. bezpečně provést replay,
22. rekonstruovat projekci,
23. potlačit externí side effect při replay,
24. oddělit kritické safety eventy,
25. zabránit event stormu,
26. verzovat výpočtové metody,
27. podporovat offline původ změny,
28. podporovat importované zdroje,
29. podporovat více zařízení,
30. chránit citlivá data,
31. auditovat AI změny bez chain-of-thought,
32. odvolat souhlas napříč službami,
33. zpracovat smazání účtu,
34. dokumentovat producenta a konzumenty,
35. testovat kompatibilitu,
36. přidávat nové konzumenty bez změny producenta,
37. umožnit budoucí rozdělení backendu bez přepsání doménových kontraktů.

---

# 154. Závěr

Domain Events model propojuje jednotlivé části AI Traineru bez toho, aby mezi nimi vznikly nekontrolované přímé závislosti.

Základní tok je:

```text
Command
    ↓
Doménová validace
    ↓
Změna agregátu
    ↓
DomainEvent
    ↓
Transactional Outbox
    ↓
Message transport
    ↓
Idempotent Consumer
    ↓
Projekce / Výpočet / Navazující workflow
```

Tok kauzality je:

```text
User action
    ↓
CommandId
    ↓
DomainEvent.eventId
    ↓
CausationId
    ↓
Navazující event
    ↓
Společný CorrelationId
```

Tok opakovaného doručení je:

```text
Event doručen
    ↓
Inbox kontrola
    ├── již zpracován → vrátit existující výsledek
    └── nový → provést transakci
                 ├── změna
                 ├── InboxRecord
                 └── případný nový OutboxMessage
```

Tok chyby je:

```text
Handler failure
    ↓
Klasifikace chyby
    ├── dočasná → retry + backoff
    └── trvalá → dead-letter + diagnostika
```

Tok změny workoutu může vypadat:

```text
WorkoutSessionCompleted
    ↓
ActivityCreatedFromWorkout
    ↓
ActivityValidated
    ↓
ActivityLoadCalculated
    ↓
GoalProgressUpdated
    ↓
RecoveryInputsChanged
    ↓
Budoucí doporučení nebo návrh adaptace
```

Hlavní zásadou je, že event není pouze technická zpráva.

Je to stabilně pojmenovaná doménová skutečnost, která musí mít:

* jasného vlastníka,
* jednoznačný význam,
* verzi,
* kauzalitu,
* správnou klasifikaci dat,
* idempotentní zpracování,
* definovanou retenci,
* dokumentované konzumenty.

Díky tomu bude možné začít s jednodušším modulárním backendem a později jednotlivé části oddělovat, aniž by se musela přepisovat pravidla celé aplikace.
