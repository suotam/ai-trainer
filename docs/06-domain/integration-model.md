# AI Trainer – Integration Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/integration-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje doménový model externích integrací v aplikaci AI Trainer.

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
* `docs/06-domain/metrics-model.md`.

Dokument popisuje:

* obecný model externího poskytovatele,
* připojení uživatelského účtu,
* oprávnění a rozsahy přístupu,
* Apple Health,
* Health Connect,
* Garmin,
* Stravu,
* další wearable poskytovatele,
* externí kalendáře,
* import aktivit,
* import spánku a recovery dat,
* export workoutů,
* synchronizační směry,
* tokeny a přihlašovací údaje,
* webhooks a polling,
* synchronizační úlohy,
* původ dat,
* deduplikaci,
* mapování sportů a metrik,
* konflikty,
* odpojení služby,
* obnovu oprávnění,
* bezpečnost,
* soukromí,
* audit,
* offline režim,
* postupné rozšiřování integrační vrstvy.

Dokument zatím neurčuje:

* konkrétní API endpointy jednotlivých poskytovatelů,
* přesný OAuth flow každé služby,
* konkrétní mobilní knihovny,
* konkrétní databázové tabulky,
* přesné limity API,
* finální obchodní podmínky jednotlivých integrací,
* konkrétní implementační jazyky adaptérů,
* konkrétní certifikační procesy poskytovatelů.

---

# 2. Cíl integračního modelu

Integrační model musí umožnit, aby AI Trainer pracoval s daty a službami mimo vlastní aplikaci, aniž by se interní doménový model stal závislým na konkrétním poskytovateli.

Musí podporovat zejména:

* import sportovních aktivit,
* import spánku,
* import tepových a recovery metrik,
* import tělesných metrik,
* import kalendářní obsazenosti,
* export workoutů do kalendáře,
* budoucí export workoutů do wearables,
* propojení externích a interních záznamů,
* deduplikaci stejných aktivit,
* řízení oprávnění,
* připojení a odpojení účtu,
* práci s chybami a výpadky,
* audit přístupu k citlivým datům.

Aplikace musí být schopná fungovat i bez jakékoliv externí integrace.

Integrace rozšiřují možnosti systému, ale nesmí být podmínkou pro:

* vytvoření plánu,
* workout tracking,
* ruční záznam aktivit,
* práci s cíli,
* kalendář,
* základní recovery vyhodnocení.

---

# 3. Základní principy

## 3.1 Interní model je nezávislý na poskytovateli

Objekty jako:

* Activity,
* MetricValue,
* SleepRecord,
* ScheduleEvent,
* WorkoutInstance,

nesmí obsahovat logiku specifickou pouze pro Garmin, Stravu, Apple Health nebo jinou službu.

Konkrétní poskytovatel se převádí přes integrační adaptér.

## 3.2 Externí data nejsou automaticky zdroj pravdy

Externí služba může obsahovat:

* chybnou sportovní klasifikaci,
* neúplná data,
* duplicitní aktivitu,
* zpožděnou synchronizaci,
* změněný nebo smazaný záznam.

Interní systém musí data:

* validovat,
* normalizovat,
* porovnat,
* případně požádat uživatele o rozhodnutí.

## 3.3 Původ dat musí zůstat zachovaný

Každý importovaný údaj musí mít dohledatelný:

* poskytovatel,
* externí identifikátor,
* čas importu,
* verzi,
* původní hodnotu,
* transformace,
* případnou uživatelskou opravu.

## 3.4 Oprávnění musí být minimální

Aplikace má požadovat pouze oprávnění nutná pro konkrétní funkci.

Příklad:

Pokud uživatel chce pouze import aktivit, aplikace nemá automaticky požadovat:

* zápis workoutů,
* čtení tělesné hmotnosti,
* čtení kalendáře,
* zápis do kalendáře.

## 3.5 Integrace musí být odpojitelné

Uživatel musí mít možnost:

* integraci pozastavit,
* odebrat některá oprávnění,
* změnit synchronizované datové typy,
* účet odpojit,
* rozhodnout, co se stane s již importovanými daty.

## 3.6 Výpadek integrace nesmí blokovat aplikaci

Při nedostupnosti poskytovatele musí dál fungovat:

* kalendář,
* workout tracker,
* historie již synchronizovaných dat,
* ruční záznam,
* plán,
* AI nad dostupnými interními daty.

## 3.7 Citlivé tokeny jsou oddělené od běžných dat

Přístupové tokeny a další tajné údaje musí být:

* šifrované,
* oddělené,
* přístupné pouze integrační vrstvě,
* auditované,
* pravidelně obnovované nebo zneplatňované.

## 3.8 Integrace nesmí obcházet doménová pravidla

Importovaná nebo exportovaná data musí respektovat:

* vlastnictví,
* validaci,
* bezpečnost,
* audit,
* idempotenci,
* deduplikaci,
* soukromí.

---

# 4. Hlavní doménové objekty

Integrační oblast obsahuje minimálně:

* IntegrationProvider,
* IntegrationCapability,
* IntegrationDataType,
* IntegrationProviderConfiguration,
* UserIntegration,
* IntegrationAccount,
* IntegrationCredential,
* IntegrationConsent,
* IntegrationPermission,
* IntegrationScope,
* IntegrationDataSelection,
* ExternalResourceReference,
* ExternalDataRecord,
* ExternalDataRevision,
* DataImportJob,
* DataExportJob,
* IntegrationSyncCursor,
* IntegrationWebhookSubscription,
* IntegrationWebhookEvent,
* IntegrationMapping,
* SportMapping,
* MetricMapping,
* UnitMapping,
* CalendarMapping,
* IntegrationConflict,
* IntegrationError,
* IntegrationHealthStatus,
* IntegrationAuditRecord,
* IntegrationDisconnectPolicy,
* IntegrationRetentionPolicy.

---

# 5. IntegrationProvider

## 5.1 Význam

IntegrationProvider je systémová definice externí služby nebo platformy.

## 5.2 Příklady

* APPLE_HEALTH,
* HEALTH_CONNECT,
* GARMIN,
* STRAVA,
* POLAR,
* COROS,
* SUUNTO,
* FITBIT,
* GOOGLE_CALENDAR,
* APPLE_CALENDAR,
* MICROSOFT_OUTLOOK,
* GENERIC_FILE_IMPORT,
* GENERIC_WEBHOOK,
* CUSTOM_PROVIDER.

## 5.3 Vlastnosti

IntegrationProvider obsahuje zejména:

* identifikátor,
* technický kód,
* název,
* popis,
* typ,
* podporované platformy,
* podporované schopnosti,
* podporované datové typy,
* způsob autentizace,
* stav,
* dokumentační verzi,
* regionální dostupnost,
* požadavky na certifikaci,
* limity,
* podmínky používání.

## 5.4 Stav poskytovatele

* PLANNED,
* DEVELOPMENT,
* TESTING,
* ACTIVE,
* LIMITED,
* DEGRADED,
* SUSPENDED,
* DEPRECATED,
* REMOVED.

## 5.5 ACTIVE

Integrace je připravená pro běžné uživatele.

## 5.6 LIMITED

Funguje jen:

* na určité platformě,
* v určitém regionu,
* pro část dat,
* pro vybrané uživatele.

## 5.7 DEGRADED

Integrace dočasně funguje omezeně.

---

# 6. IntegrationProviderType

Možné typy:

* HEALTH_DATA_PLATFORM,
* WEARABLE_PROVIDER,
* SPORT_PLATFORM,
* CALENDAR_PROVIDER,
* IDENTITY_PROVIDER,
* FILE_IMPORT,
* NOTIFICATION_PROVIDER,
* MAPPING_PROVIDER,
* CUSTOM.

## 6.1 HEALTH_DATA_PLATFORM

Příklad:

* Apple Health,
* Health Connect.

Obvykle agreguje data více aplikací a zařízení.

## 6.2 WEARABLE_PROVIDER

Příklad:

* Garmin,
* Polar,
* Coros.

## 6.3 SPORT_PLATFORM

Příklad:

* Strava.

## 6.4 CALENDAR_PROVIDER

Příklad:

* Google Calendar,
* Apple Calendar.

---

# 7. IntegrationCapability

## 7.1 Význam

Jedna funkce, kterou poskytovatel podporuje.

## 7.2 Příklady

* READ_ACTIVITIES,
* WRITE_ACTIVITIES,
* READ_SLEEP,
* READ_HEART_RATE,
* READ_HRV,
* READ_BODY_METRICS,
* READ_RECOVERY_SCORE,
* READ_CALENDAR,
* WRITE_CALENDAR_EVENTS,
* READ_BUSY_TIME,
* WRITE_WORKOUTS,
* READ_WORKOUTS,
* RECEIVE_WEBHOOKS,
* HISTORICAL_IMPORT,
* INCREMENTAL_SYNC,
* DELETE_REMOTE_DATA,
* UPDATE_REMOTE_DATA.

## 7.3 Dostupnost capability

Schopnost může být:

* plně podporovaná,
* platformně omezená,
* experimentální,
* vyžadující schválení poskytovatele,
* nedostupná pro některé účty.

---

# 8. IntegrationDataType

## 8.1 Význam

Normalizovaný typ dat, který může integrace číst nebo zapisovat.

## 8.2 Příklady

* ACTIVITY,
* WORKOUT,
* SLEEP,
* HEART_RATE,
* RESTING_HEART_RATE,
* HRV,
* STEPS,
* DISTANCE,
* ENERGY_EXPENDITURE,
* BODY_WEIGHT,
* BODY_COMPOSITION,
* RESPIRATORY_RATE,
* TEMPERATURE,
* RECOVERY_SCORE,
* STRESS_SCORE,
* READINESS_SCORE,
* CALENDAR_EVENT,
* CALENDAR_BUSY_INTERVAL,
* ROUTE,
* LOCATION_SERIES,
* POWER_SERIES,
* CADENCE_SERIES,
* CUSTOM.

## 8.3 Rozdíl capability a data type

Capability:

> READ_SLEEP

Data type:

> SLEEP

Capability určuje operaci.

Data type určuje obsah.

---

# 9. IntegrationProviderConfiguration

## 9.1 Význam

Systémová konfigurace poskytovatele.

## 9.2 Obsah

* API base URL,
* OAuth endpointy,
* podporované scope,
* rate limits,
* časové limity,
* webhook konfiguraci,
* retry policy,
* mapovací verzi,
* feature flags,
* regionální varianty.

## 9.3 Citlivé údaje

Client secret nebo jiný systémový klíč nesmí být součástí běžného doménového objektu přístupného aplikaci.

---

# 10. UserIntegration

## 10.1 Význam

Reprezentuje konkrétní připojení uživatele ke konkrétnímu poskytovateli.

## 10.2 Vlastnosti

* identifikátor,
* uživatele,
* poskytovatele,
* stav,
* připojený externí účet,
* udělená oprávnění,
* zvolené datové typy,
* směr synchronizace,
* datum připojení,
* poslední úspěšnou synchronizaci,
* poslední pokus,
* poslední chybu,
* stav tokenu,
* stav webhooku,
* sync cursor,
* uživatelské preference,
* disconnect policy.

## 10.3 Jeden uživatel a více účtů

Model musí být připraven na:

* více poskytovatelů,
* případně více účtů stejného poskytovatele,
* více zařízení pod jedním účtem.

První verze může více účtů stejného poskytovatele omezit.

---

# 11. UserIntegrationStatus

* DRAFT,
* CONNECTING,
* ACTIVE,
* PARTIALLY_ACTIVE,
* REAUTHENTICATION_REQUIRED,
* PERMISSION_REVOKED,
* RATE_LIMITED,
* DEGRADED,
* PAUSED,
* DISCONNECTING,
* DISCONNECTED,
* FAILED,
* DELETED.

## 11.1 CONNECTING

Probíhá autentizace nebo první nastavení.

## 11.2 PARTIALLY_ACTIVE

Část funkcí funguje, jiná ne.

Příklad:

* import aktivit funguje,
* spánek nemá oprávnění.

## 11.3 REAUTHENTICATION_REQUIRED

Token vypršel nebo byl odvolán.

## 11.4 PAUSED

Synchronizace je pozastavená, ale propojení a token mohou zůstat zachované.

## 11.5 DISCONNECTED

Účet již není aktivně propojen.

Historická importovaná data mohou zůstat.

---

# 12. IntegrationAccount

## 12.1 Význam

Bezpečná reference na externí účet.

## 12.2 Obsah

* provider account id,
* bezpečný zobrazovaný název,
* případný e-mail, pokud je nutný a povolený,
* region,
* stav,
* datum posledního ověření.

## 12.3 Minimalizace

Aplikace nemá ukládat další údaje externího profilu, pokud nejsou funkčně potřebné.

---

# 13. IntegrationCredential

## 13.1 Význam

Citlivé přihlašovací údaje potřebné pro komunikaci s poskytovatelem.

## 13.2 Možný obsah

* access token,
* refresh token,
* token expiry,
* token type,
* signed credentials,
* provider session reference,
* device authorization reference.

## 13.3 Bezpečnostní pravidla

Credential musí být:

* šifrovaný,
* oddělený od běžné databázové entity,
* nepřístupný mobilnímu klientu, pokud to není platformně nutné,
* auditovaný,
* rotovatelný,
* zneplatnitelný.

## 13.4 Zákaz logování

Tokeny nesmí být zapisovány do:

* aplikačních logů,
* analytiky,
* AI kontextu,
* chybových hlášení,
* uživatelského exportu v čitelné podobě.

---

# 14. AuthenticationMethod

Možné metody:

* OAUTH2_AUTHORIZATION_CODE,
* OAUTH2_PKCE,
* DEVICE_AUTHORIZATION,
* PLATFORM_PERMISSION,
* API_KEY,
* SIGNED_REQUEST,
* LOCAL_DEVICE_ACCESS,
* FILE_IMPORT,
* NONE.

## 14.1 PLATFORM_PERMISSION

Typické pro:

* Apple Health,
* Health Connect.

Nejde nutně o klasické OAuth připojení účtu.

## 14.2 FILE_IMPORT

Uživatel poskytne soubor, například:

* GPX,
* FIT,
* TCX,
* CSV,
* JSON.

---

# 15. IntegrationConsent

## 15.1 Význam

Záznam uživatelského souhlasu s konkrétní integrační funkcí.

## 15.2 Obsah

* uživatele,
* poskytovatele,
* účel,
* datové typy,
* směr,
* verzi textu,
* datum,
* stav,
* odvolání.

## 15.3 Oddělení od platformního oprávnění

Uživatel může:

* dát aplikaci interní souhlas,
* ale na platformě odmítnout systémové oprávnění.

Oba stavy musí být rozlišeny.

---

# 16. IntegrationPermission

## 16.1 Význam

Konkrétní oprávnění udělené poskytovatelem nebo platformou.

## 16.2 Stav

* REQUESTED,
* GRANTED,
* PARTIALLY_GRANTED,
* DENIED,
* REVOKED,
* EXPIRED,
* UNKNOWN.

## 16.3 Příklad

Health Connect může povolit:

* čtení aktivit,
* ale nepovolit spánek.

UserIntegration musí zůstat částečně aktivní.

---

# 17. IntegrationScope

## 17.1 Význam

Technický nebo doménový rozsah oprávnění.

## 17.2 Vlastnosti

* provider scope code,
* interní capability,
* datový typ,
* read/write směr,
* citlivost,
* povinnost reautentizace,
* stav.

## 17.3 Mapování

Jeden provider scope může pokrývat více interních capability.

A naopak jedna interní capability může vyžadovat více provider scopes.

---

# 18. IntegrationDataSelection

## 18.1 Význam

Uživatelské nastavení, které datové typy chce synchronizovat.

## 18.2 Příklady

Uživatel může povolit:

* aktivity,
* spánek,
* HRV,
* klidový tep,

ale zakázat:

* tělesnou hmotnost,
* lokaci,
* body composition.

## 18.3 Směr

Pro každý typ může být:

* IMPORT_ONLY,
* EXPORT_ONLY,
* BIDIRECTIONAL,
* DISABLED.

## 18.4 Omezení poskytovatele

Pokud poskytovatel obousměrnou synchronizaci nepodporuje, nastavení ji nesmí nabízet.

---

# 19. SyncDirection

* IMPORT_ONLY,
* EXPORT_ONLY,
* BIDIRECTIONAL,
* READ_BUSY_ONLY,
* MANUAL_IMPORT,
* MANUAL_EXPORT,
* DISABLED.

## 19.1 READ_BUSY_ONLY

Používá se například u externího kalendáře.

Aplikace zná:

* čas obsazenosti,
* ale nemusí číst název nebo popis události.

---

# 20. ExternalResourceReference

## 20.1 Význam

Stabilní reference na konkrétní objekt externího poskytovatele.

## 20.2 Obsah

* provider,
* external account,
* resource type,
* external id,
* external version,
* created at,
* updated at,
* deleted flag,
* checksum,
* sync status.

## 20.3 Použití

Může odkazovat na:

* aktivitu,
* workout,
* kalendářní událost,
* spánkový záznam,
* tělesnou metriku,
* trasu.

---

# 21. ExternalDataRecord

## 21.1 Význam

Nezpracovaný nebo normalizovaný záznam získaný z externí služby.

## 21.2 Obsah

* poskytovatele,
* uživatele,
* typ dat,
* external resource reference,
* čas přijetí,
* původní čas,
* payload reference,
* normalizační stav,
* validační stav,
* deduplikační stav,
* cílový interní objekt,
* retention policy.

## 21.3 Raw payload

Původní payload může být:

* uložen dočasně,
* uložen v bezpečném objektovém úložišti,
* zredukován po zpracování,
* neuložen vůbec, pokud to není nutné.

Musí být definována retenční politika podle citlivosti a právních potřeb.

---

# 22. ExternalDataRecordStatus

* RECEIVED,
* VALIDATING,
* NORMALIZING,
* MAPPING,
* DUPLICATE_CHECK,
* IMPORTING,
* IMPORTED,
* LINKED,
* NEEDS_REVIEW,
* FAILED,
* IGNORED,
* DELETED_AT_SOURCE,
* ARCHIVED.

---

# 23. ExternalDataRevision

## 23.1 Význam

Jedna verze externího záznamu.

Poskytovatel může stejný objekt později upravit.

## 23.2 Příklad

Garmin nebo Strava může později:

* doplnit název,
* změnit sportovní typ,
* upravit vzdálenost,
* změnit privacy status.

## 23.3 Pravidlo

Nová externí revize nesmí bez kontroly přepsat:

* uživatelské opravy,
* interní poznámky,
* plánovou vazbu,
* ručně potvrzený sport.

---

# 24. DataImportJob

## 24.1 Význam

Jedna technická a doménová synchronizační úloha pro import dat.

## 24.2 Typy

* INITIAL_IMPORT,
* INCREMENTAL_SYNC,
* HISTORICAL_BACKFILL,
* MANUAL_REFRESH,
* WEBHOOK_PROCESSING,
* RECONCILIATION,
* RETRY,
* REPAIR.

## 24.3 Obsah

* integraci,
* datové typy,
* časový rozsah,
* cursor,
* začátek,
* konec,
* stav,
* počet přijatých záznamů,
* počet importovaných,
* počet duplicit,
* počet chyb,
* počet záznamů vyžadujících kontrolu,
* retry count,
* rate limit stav.

---

# 25. DataImportJobStatus

* QUEUED,
* RUNNING,
* WAITING_FOR_PROVIDER,
* RATE_LIMITED,
* PARTIALLY_COMPLETED,
* COMPLETED,
* FAILED,
* CANCELLED,
* EXPIRED.

## 25.1 PARTIALLY_COMPLETED

Část dat byla zpracována, část selhala.

Úloha musí uchovat přesný stav.

---

# 26. DataExportJob

## 26.1 Význam

Jedna úloha zapisující interní data do externí služby.

## 26.2 Příklady

* export workoutu do kalendáře,
* export dokončené aktivity,
* budoucí export workoutu do hodinek,
* aktualizace externí kalendářní události.

## 26.3 Obsah

* uživatele,
* integraci,
* interní objekt,
* cílový externí typ,
* operaci,
* stav,
* payload version,
* idempotency key,
* výsledek,
* externí identifikátor,
* chybu.

---

# 27. DataExportOperation

* CREATE,
* UPDATE,
* DELETE,
* CANCEL,
* UPSERT,
* REPLACE,
* NO_OP.

## 27.1 NO_OP

Externí objekt již odpovídá internímu stavu.

---

# 28. Exportní zdroj pravdy

Před exportem musí být určeno, který systém je zdrojem pravdy.

## 28.1 Interní zdroj pravdy

Příklad:

Workouty vytvořené AI Trainerem exportované do Google Calendar.

Změny se řídí interním ScheduleEvent.

## 28.2 Externí zdroj pravdy

Příklad:

Týmový kalendář načítaný pouze pro čtení.

## 28.3 Sdílený režim

Obousměrná synchronizace je složitější a musí mít explicitní konfliktovou politiku.

---

# 29. IntegrationSyncCursor

## 29.1 Význam

Pozice v průběžné synchronizaci poskytovatele.

## 29.2 Může obsahovat

* timestamp,
* continuation token,
* page token,
* change token,
* provider-specific cursor,
* poslední external id.

## 29.3 Pravidlo

Cursor se aktualizuje až po bezpečném zpracování odpovídajících dat.

---

# 30. Initial Import

## 30.1 Význam

První synchronizace po připojení integrace.

## 30.2 Rozsah

Uživatel může zvolit:

* pouze budoucí data,
* posledních 30 dní,
* posledních 90 dní,
* poslední rok,
* maximální dostupnou historii.

## 30.3 Omezení

Rozsah může být omezen:

* poskytovatelem,
* výkonem,
* cenou,
* právními pravidly,
* zvoleným plánem produktu.

## 30.4 Uživatelská komunikace

Uživatel musí vědět:

* jak hluboká historie se importuje,
* že mohou vzniknout duplicity,
* že import může pokračovat postupně.

---

# 31. Incremental Sync

## 31.1 Význam

Pravidelné načítání nových nebo změněných dat.

## 31.2 Spouštění

* webhook,
* push notification,
* polling,
* otevření aplikace,
* plánovaná serverová úloha,
* ruční refresh.

## 31.3 Idempotence

Stejný externí záznam nesmí vytvořit více interních objektů.

---

# 32. Historical Backfill

## 32.1 Význam

Dodatečný import starších dat.

## 32.2 Dopady

Může způsobit:

* nové duplicity,
* přepočet trendů,
* nové osobní rekordy,
* změnu baseline,
* změnu historických progress snapshotů.

## 32.3 Pravidlo

Backfill nesmí neviditelně přepsat uživatelsky potvrzené historické údaje.

---

# 33. IntegrationWebhookSubscription

## 33.1 Význam

Registrace odběru událostí od poskytovatele.

## 33.2 Obsah

* provider,
* user integration,
* subscription id,
* event types,
* callback reference,
* stav,
* expiration,
* last renewal,
* secret reference.

## 33.3 Stav

* REQUESTED,
* ACTIVE,
* EXPIRING,
* EXPIRED,
* FAILED,
* REVOKED.

---

# 34. IntegrationWebhookEvent

## 34.1 Význam

Jedna událost přijatá od poskytovatele.

## 34.2 Obsah

* provider event id,
* subscription,
* event type,
* external resource,
* received at,
* signature validation,
* processing status,
* idempotency key.

## 34.3 Bezpečnost

Webhook musí být ověřen podle mechanismu poskytovatele.

Neověřený webhook nesmí měnit interní data.

---

# 35. Polling

Pokud poskytovatel nepodporuje webhook:

* použije se periodický polling,
* respektují se rate limits,
* používá se incremental cursor,
* plánuje se backoff.

Polling nemá běžet častěji, než je produktově nutné.

---

# 36. RateLimitState

## 36.1 Význam

Aktuální stav API limitů poskytovatele.

## 36.2 Obsah

* limit,
* zbývající počet,
* reset time,
* endpoint category,
* penalty state,
* backoff until.

## 36.3 Chování

Při limitu systém:

* úlohu odloží,
* nepovažuje integraci za odpojenou,
* informuje uživatele jen tehdy, když má problém reálný dopad.

---

# 37. RetryPolicy

## 37.1 Automaticky opakovatelné chyby

* timeout,
* dočasná nedostupnost,
* 5xx chyba,
* rate limit po resetu,
* dočasné síťové selhání.

## 37.2 Neopakovat bez změny

* neplatný token,
* odmítnuté oprávnění,
* nevalidní payload,
* trvale neexistující objekt,
* doménový konflikt.

## 37.3 Backoff

Použije se:

* exponenciální backoff,
* jitter,
* maximální počet pokusů,
* dead-letter stav.

---

# 38. IntegrationError

## 38.1 Význam

Strukturovaná chyba integrační operace.

## 38.2 Kategorie

* AUTHENTICATION,
* AUTHORIZATION,
* PERMISSION,
* RATE_LIMIT,
* NETWORK,
* PROVIDER_UNAVAILABLE,
* VALIDATION,
* MAPPING,
* DUPLICATE,
* CONFLICT,
* UNSUPPORTED_DATA,
* WEBHOOK,
* STORAGE,
* UNKNOWN.

## 38.3 Vlastnosti

* provider,
* operation,
* code,
* bezpečnou zprávu,
* technický detail,
* retryable,
* userActionRequired,
* occurredAt,
* resolvedAt.

---

# 39. User-facing Integration Issue

Technická chyba musí být převedena do srozumitelného stavu.

Příklady:

* „Je potřeba znovu připojit Garmin.“
* „Aplikace nemá oprávnění číst spánek.“
* „Dnešní aktivity se zatím nepodařilo načíst.“
* „Google Calendar dočasně není dostupný.“

Uživateli se nesmí zobrazovat:

* tokeny,
* interní stack trace,
* citlivý provider payload.

---

# 40. IntegrationHealthStatus

## 40.1 Význam

Souhrnný stav jedné UserIntegration.

## 40.2 Stavy

* HEALTHY,
* DELAYED,
* PARTIALLY_WORKING,
* ACTION_REQUIRED,
* PROVIDER_OUTAGE,
* PAUSED,
* DISCONNECTED,
* UNKNOWN.

## 40.3 Vstupy

* poslední synchronizace,
* chyby,
* webhook stav,
* token,
* oprávnění,
* rate limits,
* provider incident.

---

# 41. Data normalization

## 41.1 Význam

Převod externích dat do interních struktur.

## 41.2 Kroky

1. ověření zdroje,
2. parsování,
3. převod času,
4. převod jednotek,
5. mapování sportu,
6. mapování metrik,
7. validace,
8. detekce duplicit,
9. vytvoření interního objektu.

## 41.3 Raw versus normalized data

Raw data zachovávají původ.

Normalized data používají interní doménové pojmy.

---

# 42. IntegrationMapping

## 42.1 Význam

Obecná mapovací definice mezi externím a interním významem.

## 42.2 Typy

* SPORT,
* ACTIVITY_TYPE,
* METRIC,
* UNIT,
* CALENDAR_EVENT,
* SLEEP_STAGE,
* DEVICE_TYPE,
* PRIVACY_STATUS,
* CUSTOM.

## 42.3 Vlastnosti

* provider,
* external code,
* internal target,
* verze,
* confidence,
* stav,
* fallback,
* poznámka.

---

# 43. SportMapping

## 43.1 Příklad

Externí typ:

* `RUN`,
* `TRAIL_RUN`,
* `INDOOR_RUN`.

Interní mapování:

* UserSport nebo SportDefinition běh,
* Activity subtype.

## 43.2 Neznámý sport

Pokud externí typ není známý:

* vytvoří se unmapped stav,
* použije se obecná Activity,
* uživatel může sport potvrdit,
* mapování lze později rozšířit.

## 43.3 Uživatelská oprava

Uživatelská oprava jedné aktivity nemusí automaticky změnit globální mapování.

Systém může nabídnout:

> Používat toto mapování i pro další aktivity tohoto typu?

---

# 44. MetricMapping

## 44.1 Význam

Převádí externí metrický typ na MetricDefinition.

## 44.2 Obsah

* external metric code,
* internal MetricDefinition,
* unit mapping,
* transformaci,
* zdrojovou kvalitu,
* podporovaný časový formát.

## 44.3 Proprietární skóre

Například Garmin Body Battery nebo jiné skóre se mapuje na vlastní provider-specific MetricDefinition.

Nemá být automaticky mapováno na interní readiness.

---

# 45. UnitMapping

## 45.1 Význam

Převod externí jednotky do UnitDefinition.

## 45.2 Příklad

* meters,
* kilometers,
* miles,
* seconds,
* milliseconds,
* bpm.

## 45.3 Neznámá jednotka

Záznam se nesmí importovat jako jiná náhodná jednotka.

Musí přejít do:

* NEEDS_REVIEW,
* UNSUPPORTED_DATA,
* nebo být uložen pouze jako ExternalDataRecord.

---

# 46. SleepStageMapping

Externí fáze spánku se mohou lišit.

Interní model může podporovat:

* AWAKE,
* LIGHT,
* DEEP,
* REM,
* ASLEEP_UNSPECIFIED,
* UNKNOWN.

Mapování musí zachovat původní hodnotu a provider-specific význam.

---

# 47. CalendarMapping

## 47.1 Význam

Určuje převod mezi externí událostí a interním kalendářním významem.

## 47.2 Režimy

* BUSY_ONLY,
* IMPORT_AS_SCHEDULE_EVENT,
* LINK_TO_INTERNAL_EVENT,
* EXPORT_COPY,
* BIDIRECTIONAL_LINK.

## 47.3 Výchozí bezpečný režim

U osobních externích kalendářů je vhodné začít režimem:

* busy/free bez obsahu,
* nebo export interních workoutů.

---

# 48. External calendar busy intervals

## 48.1 Význam

Časové intervaly, kdy je uživatel podle externího kalendáře obsazen.

## 48.2 Obsah

* začátek,
* konec,
* časové pásmo,
* busy/free,
* provider,
* kalendář,
* privacy level.

## 48.3 AI kontext

AI obvykle potřebuje pouze:

* obsazený interval,
* ne název schůzky.

---

# 49. External calendar event import

Pokud uživatel povolí import obsahu, může externí událost obsahovat:

* název,
* popis,
* místo,
* opakování,
* stav,
* účastníky.

Aplikace musí určit, které údaje skutečně potřebuje.

Externí účastníci se nemají automaticky importovat do AI kontextu.

---

# 50. Calendar export

## 50.1 Příklad

WorkoutInstance má ScheduleEvent.

Při exportu do Google Calendar vznikne externí kopie.

## 50.2 Exportovaný obsah

Může obsahovat:

* název workoutu,
* čas,
* délku,
* krátký popis,
* deep link do aplikace.

Nemusí obsahovat:

* citlivé omezení,
* bolest,
* detailní recovery stav,
* kompletní seznam osobních cílů.

## 50.3 Privacy mode

Uživatel může zvolit:

* plný název,
* obecný název „Workout“,
* pouze blokaci času.

---

# 51. ExternalCalendarLink

## 51.1 Význam

Vazba mezi interní ScheduleEvent a externí kalendářní položkou.

## 51.2 Obsah

* interní event,
* provider,
* external resource,
* sync direction,
* source of truth,
* last synced revision,
* conflict state,
* export privacy mode.

---

# 52. Změna externí kalendářní kopie

Pokud je interní systém zdrojem pravdy a uživatel externí kopii změní:

* změna se nemusí importovat,
* může vzniknout konflikt,
* interní aplikace může export obnovit,
* uživatel musí znát očekávané chování.

---

# 53. Smazání externí kalendářní kopie

Nesmí automaticky smazat interní WorkoutInstance.

Možnosti:

* znovu vytvořit export,
* odpojit konkrétní vazbu,
* upozornit uživatele,
* podle policy importovat zrušení jako návrh.

---

# 54. Apple Health

## 54.1 Role

Apple Health funguje jako platformní úložiště zdravotních a fitness dat na Apple zařízeních.

Integrační model ho musí chápat jako:

* agregátor různých zdrojů,
* nikoliv nutně jako původního výrobce dat.

## 54.2 Potenciální import

* workouty,
* aktivity,
* tep,
* HRV,
* spánek,
* kroky,
* vzdálenost,
* aktivní energie,
* hmotnost,
* další povolené metriky.

## 54.3 Původ zdroje

Každý záznam může mít:

* Apple Health jako platformu,
* ale jiné zařízení nebo aplikaci jako původní source.

To musí být zachováno v provenance.

## 54.4 Oprávnění

Oprávnění jsou řízena platformou a mohou být udělena po datových typech.

Aplikace nemusí vždy jednoznačně poznat, zda uživatel konkrétní read permission odmítl, nebo zda pouze nejsou data.

Produkt musí s touto nejistotou počítat.

---

# 55. Health Connect

## 55.1 Role

Health Connect funguje jako platformní vrstva pro sdílení zdravotních a fitness dat na Androidu.

## 55.2 Potenciální import

* exercise sessions,
* sleep sessions,
* heart rate,
* HRV,
* steps,
* distance,
* body metrics,
* active calories,
* další podporované typy.

## 55.3 Historická oprávnění

Některé platformní režimy mohou odlišovat běžný a rozšířený historický přístup.

Model musí podporovat:

* omezené časové okno,
* dodatečnou žádost o historii,
* částečně dostupná data.

## 55.4 Lokální povaha

Část integrace může probíhat přímo v mobilní aplikaci.

Backend nemusí mít přímý přístup k platformním datům bez synchronizace z telefonu.

---

# 56. Garmin

## 56.1 Potenciální funkce

* import aktivit,
* import spánku,
* import recovery metrik,
* import tepu a HRV,
* budoucí export workoutů,
* webhook nebo serverová synchronizace podle dostupných API.

## 56.2 Omezení

Přístup může vyžadovat:

* schválení aplikace,
* partnerský program,
* specifické smluvní podmínky,
* omezení dat a regionů.

Doménový model s integrací počítá, ale produktový plán musí respektovat skutečnou dostupnost API.

## 56.3 Garmin-specific data

Proprietární metriky se uchovávají jako provider-specific MetricDefinition.

---

# 57. Strava

## 57.1 Potenciální funkce

* import aktivit,
* import základních sportovních metrik,
* import tras podle oprávnění,
* budoucí export aktivit, pokud je povolený a smysluplný.

## 57.2 Strava jako sekundární zdroj

Stejná aktivita může existovat:

* přímo z Garminu,
* a zároveň ve Stravě.

DuplicateDetectionService musí zabránit dvojímu započítání.

## 57.3 Sociální data

AI Trainer nepotřebuje importovat:

* komentáře,
* kudos,
* sociální feed,

pokud to není součástí explicitního budoucího produktu.

---

# 58. Další wearable integrace

Model musí umožnit přidat například:

* Polar,
* Coros,
* Suunto,
* Fitbit,
* Whoop,
* Oura,
* Samsung Health,
* další budoucí služby.

Každý poskytovatel dostane:

* vlastní adaptér,
* mapování,
* capability definice,
* credential flow,
* error mapping,
* testovací sadu.

---

# 59. Integration Adapter

## 59.1 Význam

Technická anti-corruption vrstva převádějící externí API do interního integračního modelu.

## 59.2 Odpovědnost

* autentizace,
* načtení dat,
* zápis dat,
* parsování,
* mapování provider chyb,
* převod externích objektů na ExternalDataRecord,
* webhook validace.

## 59.3 Nesmí rozhodovat

Adaptér nemá rozhodovat o:

* cílech,
* plánování,
* readiness,
* finální deduplikaci,
* změně workoutů.

---

# 60. Import Pipeline

Doporučený tok:

```text
Provider API / Platform
    ↓
Provider Adapter
    ↓
ExternalDataRecord
    ↓
Validation
    ↓
Normalization
    ↓
Mapping
    ↓
Duplicate Detection
    ↓
Internal Domain Object
    ↓
Matching / Metrics / Load
```

---

# 61. Export Pipeline

Doporučený tok:

```text
Internal Domain Object
    ↓
Export Eligibility Validation
    ↓
Privacy Filtering
    ↓
Provider Mapping
    ↓
Provider Adapter
    ↓
External Resource
    ↓
ExternalResourceReference
```

---

# 62. Export Eligibility Validation

Před exportem se ověřuje:

* integrace je aktivní,
* existuje potřebné oprávnění,
* objekt patří uživateli,
* datový typ je podporovaný,
* export není duplicitní,
* citlivá data jsou odfiltrována,
* objekt není ve stavu, který se exportovat nemá.

---

# 63. IntegrationConflict

## 63.1 Význam

Konflikt mezi interním a externím stavem nebo mezi více externími zdroji.

## 63.2 Typy

* DUPLICATE_ACTIVITY,
* FIELD_VALUE_CONFLICT,
* SPORT_MAPPING_CONFLICT,
* TIME_CONFLICT,
* DELETION_CONFLICT,
* UPDATE_CONFLICT,
* SOURCE_PRIORITY_CONFLICT,
* CALENDAR_CONFLICT,
* PERMISSION_CONFLICT,
* ACCOUNT_CONFLICT,
* UNSUPPORTED_CHANGE.

## 63.3 Stav

* DETECTED,
* AUTO_RESOLVED,
* USER_REVIEW_REQUIRED,
* RESOLVED,
* IGNORED,
* SUPERSEDED.

---

# 64. Field Value Conflict

Příklad:

* Garmin uvádí vzdálenost 10,1 km,
* Strava 10,3 km,
* ruční oprava 10,0 km.

Systém musí:

* zachovat všechny zdroje,
* použít pravidla priority,
* respektovat uživatelskou opravu,
* zaznamenat provenance.

---

# 65. Source priority

Priorita musí být definována podle:

* datového typu,
* konkrétní metriky,
* zařízení,
* kvality,
* uživatelské opravy,
* přímého versus sekundárního importu.

Příklad:

Aktivita přímo z Garminu může mít vyšší prioritu než stejná aktivita importovaná ze Stravy.

To ale nemusí platit pro uživatelsky upravený název ve Stravě.

---

# 66. Duplicate detection across integrations

## 66.1 Vstupy

* začátek,
* konec,
* sport,
* vzdálenost,
* trasa,
* externí device id,
* provider chain,
* název,
* tep,
* workout reference.

## 66.2 Provider chain

Je důležité poznat:

```text
Garmin → Apple Health → AI Trainer
```

a:

```text
Garmin → AI Trainer
```

jako možné dvě reprezentace stejného zdroje.

---

# 67. Provider lineage

## 67.1 Význam

Řetězec, přes který data prošla.

## 67.2 Příklad

* origin device: Garmin watch,
* origin provider: Garmin,
* aggregator: Apple Health,
* import provider: Apple Health.

## 67.3 Použití

Pomáhá:

* deduplikaci,
* výběru hlavního zdroje,
* vysvětlení uživateli,
* auditování.

---

# 68. Integration Data Quality

Každý import může mít kvalitu:

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

Dimenze:

* completeness,
* source reliability,
* mapping confidence,
* time accuracy,
* metric accuracy,
* duplicate confidence.

---

# 69. Partial records

Externí záznam může být neúplný.

Příklady:

* aktivita bez trasy,
* spánek bez fází,
* tep s výpadky,
* kalendářní událost bez konce.

Systém může záznam importovat jako částečný, pokud je stále užitečný.

---

# 70. Unsupported external data

Pokud externí služba poskytne neznámý typ:

* uložit bezpečný ExternalDataRecord podle policy,
* nehádat interní význam,
* označit unsupported,
* případně přidat nové mapování později.

---

# 71. Data deletion at provider

## 71.1 Příklad

Uživatel smaže aktivitu ve Stravě.

## 71.2 Možné chování

* označit externí zdroj jako smazaný,
* zachovat interní Activity, pokud má další zdroje,
* zachovat uživatelské opravy,
* požádat uživatele o rozhodnutí,
* podle nastavení interní objekt skrýt.

## 71.3 Pravidlo

Externí smazání nesmí automaticky zničit interní historický záznam bez policy a auditu.

---

# 72. Data deletion in AI Trainer

Pokud uživatel odstraní interní Activity:

* nemusí se automaticky smazat externí zdroj,
* může se pouze odpojit,
* případný remote delete vyžaduje explicitní podporu a potvrzení.

---

# 73. IntegrationDisconnectPolicy

## 73.1 Význam

Určuje, co se stane při odpojení integrace.

## 73.2 Možnosti

* KEEP_IMPORTED_DATA,
* KEEP_SUMMARIES_ONLY,
* DELETE_PROVIDER_SPECIFIC_RAW_DATA,
* DELETE_ALL_IMPORTED_DATA_IF_POSSIBLE,
* UNLINK_ONLY,
* USER_CHOICE_REQUIRED.

## 73.3 Výchozí bezpečný režim

Obvykle:

* zastavit budoucí synchronizaci,
* odebrat credential,
* ponechat interní data a provenance,
* umožnit uživateli dodatečně požádat o smazání.

---

# 74. Odpojení integrace

Proces:

1. zobrazit dopad,
2. zrušit budoucí synchronizace,
3. zrušit webhooky,
4. zneplatnit token,
5. nastavit disconnect policy,
6. auditovat,
7. případně zahájit mazání dat.

---

# 75. Znovupřipojení integrace

Musí řešit:

* stejný externí účet,
* jiný externí účet,
* existující externí reference,
* historické cursor hodnoty,
* duplicity,
* opětovné vytvoření webhooků.

Při jiném externím účtu nesmí být data automaticky smíchána bez potvrzení.

---

# 76. Reauthentication

## 76.1 Spouštěče

* expirovaný refresh token,
* odvolané oprávnění,
* změna hesla,
* provider security policy,
* změna požadovaných scope.

## 76.2 Chování

* integrace přejde do REAUTHENTICATION_REQUIRED,
* existující data zůstávají,
* synchronizace se pozastaví,
* uživatel dostane jasnou akci.

---

# 77. Permission upgrade

Pokud aplikace později potřebuje nové oprávnění:

* musí vysvětlit novou funkci,
* vyžádat pouze nový scope,
* neblokovat stávající funkce, pokud nové oprávnění není nutné,
* zaznamenat nový souhlas.

---

# 78. Permission downgrade

Uživatel může některé datové typy odebrat.

Systém musí:

* přestat je synchronizovat,
* zachovat stav ostatních oprávnění,
* určit nakládání s již importovanými daty.

---

# 79. IntegrationRetentionPolicy

## 79.1 Význam

Určuje uchovávání importovaných a technických dat.

## 79.2 Kategorie

* raw payload,
* normalized external record,
* provider identifiers,
* imported domain objects,
* sensor samples,
* webhook logs,
* credentials,
* audit.

## 79.3 Různé doby

Credential může být odstraněn okamžitě při odpojení.

Audit může být uchován déle.

Raw payload může mít krátkou retenční dobu.

---

# 80. Privacy classification

Integrační data mohou obsahovat:

* osobní údaje,
* zdravotně relevantní údaje,
* lokaci,
* spánek,
* biometrické metriky,
* kalendářní obsah,
* identifikátory zařízení.

Každý IntegrationDataType musí mít DataClassification.

---

# 81. Sensitive calendar content

Název kalendářní události může obsahovat citlivé údaje.

Výchozí doporučení:

* pro plánování používat busy/free,
* obsah importovat jen po explicitním souhlasu,
* neposílat automaticky do AI.

---

# 82. Sensitive location data

Trasy a přesná poloha musí mít zvláštní pravidla.

Uživatel musí mít možnost:

* neimportovat trasu,
* odstranit trasu,
* ponechat pouze souhrn,
* zakázat její AI zpracování.

---

# 83. IntegrationAuditRecord

## 83.1 Význam

Neměnný záznam významné integrační operace.

## 83.2 Příklady

* účet připojen,
* oprávnění uděleno,
* oprávnění odvoláno,
* token obnoven,
* import dokončen,
* data exportována,
* integrace odpojena,
* remote delete požadován.

## 83.3 Obsah

* čas,
* uživatele,
* poskytovatele,
* operaci,
* výsledek,
* rozsah dat,
* aktéra,
* technický correlation id.

---

# 84. AI přístup k integracím

AI může:

* vysvětlit dostupné integrace,
* navrhnout připojení,
* použít již importovaná interní data,
* upozornit na chybějící synchronizaci.

AI nesmí:

* zobrazit token,
* změnit oprávnění bez potvrzení,
* připojit účet bez uživatelského OAuth flow,
* rozšířit scope,
* odeslat data externě bez odpovídající policy.

---

# 85. IntegrationSummaryForAI

Bezpečný AI read model může obsahovat:

* poskytovatel,
* stav,
* dostupné datové typy,
* poslední synchronizaci,
* zda data mohou být neaktuální,
* obecný problém.

Nemá obsahovat:

* credential,
* externí identifikátory, pokud nejsou nutné,
* citlivý kalendářní obsah,
* raw payload.

---

# 86. Produktová analytika

Lze měřit například:

* integration_connect_started,
* integration_connected,
* permission_denied,
* sync_completed,
* sync_failed,
* integration_disconnected.

Nemá se posílat:

* konkrétní aktivita,
* konkrétní zdravotní hodnota,
* trasa,
* externí token,
* název kalendářní události.

---

# 87. Offline režim

## 87.1 Platformní zdravotní integrace

Část importu z Apple Health nebo Health Connect může probíhat až při běhu mobilní aplikace.

Offline lze:

* číst lokálně dostupná platformní data podle oprávnění,
* vytvořit lokální ExternalDataRecord,
* později synchronizovat s backendem.

## 87.2 Serverové integrace

Garmin nebo Strava mohou pokračovat serverově i bez otevřené aplikace, pokud je integrace aktivní.

## 87.3 Offline export

Export do externí služby se uloží jako čekající DataExportJob.

Uživatel nesmí dostat potvrzení remote úspěchu před skutečným provedením.

---

# 88. Mobile-to-server import

Doporučený tok pro platformní data:

```text
Apple Health / Health Connect
    ↓
Mobile Integration Adapter
    ↓
Local ExternalDataRecord
    ↓
Local Validation
    ↓
Secure Sync
    ↓
Backend Import Pipeline
```

---

# 89. Mobile permission state

Mobilní aplikace musí lokálně sledovat:

* požadované oprávnění,
* udělené oprávnění,
* odmítnuté oprávnění,
* možnost požádat znovu,
* nutnost otevřít systémové nastavení.

Backend nemusí vždy znát přesný aktuální platformní permission stav, dokud ho telefon nesynchronizuje.

---

# 90. Integration command queue

Offline nebo dočasně neproveditelné operace mohou čekat ve frontě:

* upload health records,
* export calendar event,
* unlink external event,
* update sync preferences.

Každá operace musí mít:

* stabilní identifikátor,
* idempotency key,
* očekávaný stav,
* retry policy.

---

# 91. Synchronizační konflikt mezi mobilem a serverem

Příklad:

* telefon importoval Health Connect aktivitu,
* backend současně importoval stejnou aktivitu ze Stravy.

Řešení:

* obě vytvoří ExternalDataRecord,
* deduplikační pipeline najde shodu,
* vznikne jedna Activity s více zdroji.

---

# 92. Security boundary

Integrační vrstva musí být oddělena od:

* AI orchestrace,
* běžného klientského přístupu,
* analytiky,
* administrativního rozhraní.

Credential access je povolen pouze úzké sadě služeb.

---

# 93. Secret rotation

Systémové i uživatelské integrační secret údaje musí podporovat:

* rotaci,
* revokaci,
* expiraci,
* náhradu bez ztráty doménových dat.

---

# 94. Provider impersonation protection

Externí odpověď nebo webhook musí být ověřeny:

* TLS,
* podpisem,
* callback state,
* nonce,
* PKCE,
* provider-specific validací.

---

# 95. OAuth state

OAuth flow musí chránit před:

* CSRF,
* propojením špatného uživatele,
* opakovaným callbackem,
* session fixation.

State musí být:

* krátkodobý,
* jednoúčelový,
* spojený s uživatelem a integrací.

---

# 96. Account linking protection

Při callbacku se musí ověřit:

* přihlášený uživatel,
* původní flow,
* provider,
* redirect,
* external account.

Nesmí být možné připojit cizí integraci pomocí podvrženého callbacku.

---

# 97. Integration administration

Administrativní nástroje mohou umožnit:

* zobrazit technický stav,
* restartovat sync job,
* zneplatnit credential,
* označit provider outage,
* opravit mapping.

Nemají běžně umožnit:

* zobrazit uživatelské tokeny,
* číst citlivá raw data bez důvodu,
* měnit sportovní historii bez auditu.

---

# 98. Provider outage

## 98.1 Stav

Systém může evidovat provider-wide incident.

## 98.2 Dopad

* nové sync job se odloží,
* uživatelské integrace se nemusí označit jako individuálně chybné,
* aplikace může zobrazit obecné upozornění.

---

# 99. Reconciliation Job

## 99.1 Význam

Pravidelná kontrola, zda interní a externí stav odpovídají očekávání.

## 99.2 Může kontrolovat

* chybějící záznamy,
* neaktuální cursor,
* expirované webhooky,
* ztracené exportní vazby,
* externí smazání,
* duplicity.

---

# 100. Integration Repair

## 100.1 Příklady

* obnovit webhook,
* zopakovat neúspěšný import,
* znovu vytvořit exportovanou událost,
* přepočítat provider lineage,
* opravit mapping po nové verzi.

## 100.2 Audit

Opravná akce musí být auditovaná a idempotentní.

---

# 101. Mapping version changes

Pokud se změní mapování poskytovatele:

* nové záznamy používají novou verzi,
* historie se může přepočítat podle policy,
* původní mapping version zůstává dohledatelná.

---

# 102. Provider API version changes

IntegrationProviderConfiguration musí podporovat více API verzí během migrace.

Je třeba řešit:

* postupné přepnutí,
* kompatibilitu webhooků,
* migraci cursorů,
* mapovací změny,
* testovací účty.

---

# 103. Integration contract testing

Každý adaptér musí mít testy pro:

* autentizaci,
* mapování,
* chyby,
* rate limits,
* webhooky,
* neúplná data,
* duplicity,
* změnu verze.

---

# 104. Sandbox provider

Pokud poskytovatel nabízí sandbox, musí být oddělen od produkce.

Sandbox záznamy nesmí vstupovat do skutečné sportovní historie uživatele.

---

# 105. Generic file import

## 105.1 Podporované budoucí formáty

* GPX,
* FIT,
* TCX,
* CSV,
* JSON.

## 105.2 Proces

* uživatel nahraje soubor,
* soubor se validuje,
* zpracuje v izolovaném prostředí,
* vzniknou ExternalDataRecord,
* proběhne mapping a deduplikace.

## 105.3 Bezpečnost

Soubor musí být kontrolován na:

* typ,
* velikost,
* poškození,
* nebezpečný obsah,
* nesprávnou příponu.

---

# 106. File import source

Generic file import musí uvádět:

* původní název,
* typ,
* čas importu,
* checksum,
* parser version,
* případného výrobce souboru.

---

# 107. File reimport

Opětovný import stejného souboru nesmí vytvořit duplicity.

Použije se:

* checksum,
* obsahové identifikátory,
* external activity id,
* deduplikační logika.

---

# 108. Workout export to wearables

## 108.1 Budoucí schopnost

Aplikace může připravit strukturovaný workout pro hodinky.

## 108.2 Nutné mapování

Interní WorkoutStep se musí převést na schopnosti konkrétního zařízení.

Některé prvky nemusí být podporované:

* složité supersety,
* kvalitativní technické instrukce,
* nestandardní cviky,
* adaptace během workoutu.

## 108.3 Fallback

Pokud zařízení workout neumí plně reprezentovat:

* exportovat zjednodušenou verzi,
* zobrazit rozdíl,
* nebo export odmítnout.

---

# 109. ExportedWorkoutReference

Obsahuje:

* WorkoutInstance,
* provider,
* external workout id,
* exported revision,
* stav,
* omezení formátu,
* poslední synchronizaci.

---

# 110. Změna workoutu po exportu

Pokud se interní WorkoutInstance změní:

* zjistit, zda poskytovatel umožňuje update,
* aktualizovat externí verzi,
* nebo původní zrušit a vytvořit novou,
* zabránit duplicitě.

---

# 111. Workout completed on wearable

Budoucí tok:

* interní workout je exportován,
* uživatel ho provede na hodinkách,
* aktivita se importuje,
* ActivityMatchingService ji spojí s WorkoutInstance,
* vznikne WorkoutSession nebo zjednodušená reprezentace výkonu podle dat.

---

# 112. Missing execution detail

Wearable nemusí vrátit:

* každou sérii,
* každou změnu,
* subjektivní RPE.

Systém musí vytvořit Activity s kvalitou odpovídající dostupným datům.

Nemá vymýšlet chybějící výkon.

---

# 113. Integration prioritization

První implementační pořadí může rozlišovat:

## Základní platformní integrace

* Apple Health,
* Health Connect.

## Externí sportovní platforma

* Strava.

## Pokročilé wearable integrace

* Garmin a další podle dostupnosti API a partnerství.

## Kalendáře

* export workoutů,
* později import busy/free.

Doménový model však zůstává pro všechny společný.

---

# 114. Integration feature flags

Jednotlivé schopnosti mohou být řízené:

* platformou,
* regionem,
* verzí aplikace,
* typem účtu,
* beta programem,
* provider approval stavem.

---

# 115. Data freshness

Každý importovaný údaj musí mít:

* observedAt,
* importedAt,
* lastConfirmedAt,
* freshness status.

Stavy například:

* FRESH,
* RECENT,
* STALE,
* VERY_STALE,
* UNKNOWN.

---

# 116. Stale integration data

AI a planning služby musí vědět, když data nejsou aktuální.

Příklad:

> Poslední synchronizace Garminu proběhla před třemi dny.

Systém nemá tvrdit, že zná dnešní recovery stav.

---

# 117. Integration sync summary

Uživatel může vidět:

* poslední úspěšnou synchronizaci,
* synchronizované typy,
* počet nových položek,
* záznamy vyžadující kontrolu,
* případný problém.

Nemusí vidět technické job id nebo cursor.

---

# 118. Manual refresh

Uživatel může požádat o novou synchronizaci.

Systém musí zabránit:

* paralelním duplicitním jobům,
* obcházení rate limitů,
* neomezenému spamování poskytovatele.

---

# 119. Import review

Záznam může vyžadovat kontrolu, pokud:

* sport není známý,
* duplicita je nejistá,
* čas je neplatný,
* data jsou extrémní,
* mapování je nejasné,
* koliduje s ručním záznamem.

---

# 120. Import Review Decision

Uživatel může:

* potvrdit import,
* změnit sport,
* sloučit,
* ponechat odděleně,
* ignorovat,
* označit jako neplatný.

---

# 121. Integration and goals

Importované metriky mohou ovlivnit cíle až po:

* validaci,
* deduplikaci,
* správném mapování,
* případném potvrzení.

Raw externí data nemají přímo dokončit cíl.

---

# 122. Integration and readiness

Wearable metriky mohou vstupovat do ReadinessAssessment.

Musí však nést:

* zdroj,
* čerstvost,
* kvalitu,
* baseline,
* provider-specific význam.

---

# 123. Integration and training plan

Externí aktivita může vést k návrhu úpravy plánu.

Nemá sama automaticky:

* zrušit workout,
* změnit cíl,
* vytvořit omezení.

Výjimkou mohou být předem povolené nízkorizikové automation policy po doménové validaci.

---

# 124. Integration and activity matching

Importovaná aktivita prochází:

1. validací,
2. deduplikací,
3. mapováním,
4. ActivityMatchingService.

Může být spojena s:

* WorkoutInstance,
* ScheduleEvent,
* TrainingPlan,
* Goal.

---

# 125. Integration and metric conflict

Pokud provider doplní novou hodnotu již existující metriky:

* nevytváří se automaticky nová primární hodnota,
* MetricConflictService vyhodnotí zdroje,
* uživatelská korekce zůstává chráněná.

---

# 126. Domain events

Minimálně:

* IntegrationProviderActivated
* UserIntegrationConnectionStarted
* UserIntegrationConnected
* UserIntegrationPartiallyConnected
* IntegrationPermissionGranted
* IntegrationPermissionDenied
* IntegrationPermissionRevoked
* IntegrationReauthenticationRequired
* IntegrationPaused
* IntegrationResumed
* UserIntegrationDisconnected
* IntegrationCredentialRefreshed
* IntegrationCredentialRevoked
* DataImportJobCreated
* DataImportStarted
* DataImportCompleted
* DataImportPartiallyCompleted
* DataImportFailed
* ExternalDataRecordReceived
* ExternalDataRecordNormalized
* ExternalDataRecordImported
* ExternalDataRecordRejected
* ExternalDataRevisionReceived
* ExternalResourceDeletedAtSource
* DuplicateExternalActivityDetected
* DataExportJobCreated
* DataExportCompleted
* DataExportFailed
* ExternalCalendarEventLinked
* ExternalCalendarLinkBroken
* IntegrationWebhookSubscribed
* IntegrationWebhookExpired
* IntegrationWebhookEventReceived
* IntegrationRateLimitReached
* IntegrationConflictDetected
* IntegrationConflictResolved
* IntegrationMappingUpdated
* IntegrationHealthChanged
* IntegrationRepairCompleted
* HistoricalBackfillCompleted

---

# 127. Commands

Minimálně:

* StartIntegrationConnection
* CompleteIntegrationConnection
* RequestIntegrationPermission
* UpdateIntegrationDataSelection
* PauseIntegration
* ResumeIntegration
* DisconnectIntegration
* ReauthenticateIntegration
* RefreshIntegrationCredential
* RevokeIntegrationCredential
* StartInitialImport
* StartHistoricalBackfill
* RunIncrementalSync
* RefreshIntegrationManually
* ProcessWebhookEvent
* CreateDataImportJob
* RetryDataImportJob
* CancelDataImportJob
* CreateDataExportJob
* RetryDataExportJob
* NormalizeExternalDataRecord
* MapExternalSport
* MapExternalMetric
* ResolveIntegrationConflict
* MergeExternalActivitySources
* LinkExternalCalendarEvent
* UnlinkExternalCalendarEvent
* ExportScheduleEvent
* DeleteExternalExport
* ReconcileIntegration
* RepairIntegration
* UpdateIntegrationRetentionPolicy
* ApplyIntegrationDisconnectPolicy

---

# 128. Invariance – vlastnictví

* UserIntegration patří právě jednomu uživateli.
* Importovaný interní objekt musí patřit stejnému uživateli jako integrace.
* ExternalDataRecord nesmí být připojen k objektu jiného uživatele.
* Credential musí být spojen se správnou UserIntegration.

---

# 129. Invariance – credential

* Credential nesmí být uložen v otevřené podobě.
* Nesmí být dostupný AI.
* Nesmí se objevit v běžném uživatelském exportu.
* Odpojení integrace musí credential zneplatnit nebo odstranit podle poskytovatele.
* Expirovaný credential nesmí být použit.

---

# 130. Invariance – oprávnění

* Data se nesmí číst bez odpovídajícího oprávnění.
* Data se nesmí zapisovat bez write permission.
* Odebrání scope musí zastavit příslušnou synchronizaci.
* Částečně udělená oprávnění nesmí být prezentována jako plná integrace.

---

# 131. Invariance – import

* Každý externí záznam musí mít provider a external reference nebo jiný stabilní identifikátor.
* Opakovaný import nesmí vytvořit duplicitní interní objekt.
* Import nesmí neviditelně přepsat uživatelskou opravu.
* Nevalidní záznam nesmí ovlivnit cíle, zátěž nebo readiness.

---

# 132. Invariance – export

* Export musí mít idempotency key.
* Externí kopie nesmí vzniknout dvakrát při retry.
* Interní a externí stav musí mít explicitní source-of-truth policy.
* Export nesmí obsahovat nepovolená citlivá data.
* Neúspěšný export nesmí být oznámen jako dokončený.

---

# 133. Invariance – mapování

* Externí sport se nesmí mapovat na náhodnou interní definici.
* Neznámá jednotka nesmí být automaticky považována za známou.
* Mapping version musí být dohledatelná.
* Uživatelská oprava má přednost podle definovaných pravidel.

---

# 134. Invariance – webhook

* Webhook musí být ověřen.
* Stejný event id nesmí být zpracován vícekrát.
* Neověřený webhook nesmí vytvořit import job.
* Expirovaná subscription se nesmí považovat za aktivní.

---

# 135. Invariance – odpojení

* Odpojení musí zastavit budoucí synchronizaci.
* Musí zneplatnit credential.
* Historická data se nesmí smazat bez policy a potvrzení.
* ExternalResourceReference může zůstat jako provenance bez aktivního přístupu.

---

# 136. Invariance – AI

* AI nesmí připojit nebo odpojit integraci bez explicitní uživatelské akce.
* AI nesmí rozšířit scope.
* AI nesmí přistupovat k raw credential.
* AI nesmí vydávat stará externí data za aktuální.
* AI návrh založený na integraci musí uvádět případnou neaktuálnost dat.

---

# 137. Read modely

## 137.1 IntegrationsOverview

Obsahuje:

* dostupné poskytovatele,
* připojené integrace,
* jejich stav,
* poslední synchronizaci,
* vyžadované akce.

## 137.2 IntegrationDetailView

Obsahuje:

* poskytovatele,
* připojený účet,
* synchronizované datové typy,
* oprávnění,
* směr synchronizace,
* stav,
* historii problémů,
* akce.

## 137.3 IntegrationPermissionView

Obsahuje:

* požadované datové typy,
* udělené oprávnění,
* chybějící oprávnění,
* vysvětlení účelu.

## 137.4 SyncHistoryView

Obsahuje:

* poslední úlohy,
* čas,
* stav,
* počet importovaných záznamů,
* chyby.

## 137.5 ImportReviewView

Obsahuje:

* externí záznam,
* navržené mapování,
* duplicity,
* interní dopad,
* možnosti rozhodnutí.

## 137.6 IntegrationConflictView

Obsahuje:

* konfliktní hodnoty,
* zdroje,
* kvalitu,
* doporučené řešení.

## 137.7 IntegrationHealthView

Obsahuje:

* stav tokenu,
* oprávnění,
* sync freshness,
* provider incident,
* doporučenou akci.

---

# 138. Příklad – připojení Health Connect

## Proces

1. uživatel zvolí Health Connect,
2. vybere datové typy,
3. aplikace požádá systém o oprávnění,
4. vznikne UserIntegration,
5. synchronizují se skutečně udělená oprávnění,
6. proběhne initial import,
7. data se odešlou do backendu,
8. deduplikují se.

## Možný stav

* aktivity povoleny,
* spánek odmítnut,
* integrace PARTIALLY_ACTIVE.

---

# 139. Příklad – Apple Health a Garmin duplicita

## Zdroje

* stejný běh přímo z Garmin integrace,
* stejný běh přes Apple Health.

## Lineage

Apple Health záznam uvádí Garmin jako origin source.

## Výsledek

* dvě ExternalDataRecord,
* jedna Activity,
* primární source Garmin,
* Apple Health zůstává jako sekundární provenance.

---

# 140. Příklad – Strava jako druhý zdroj

Uživatel upravil název aktivity ve Stravě.

Po sloučení:

* čas a trasa z Garminu,
* uživatelsky upravený název ze Stravy,
* interní RPE z AI Traineru.

Každé pole má vlastní provenance.

---

# 141. Příklad – import spánku

Provider dodá:

* začátek,
* konec,
* sleep stages,
* recovery score.

Interní výsledek:

* SleepRecord,
* provider-specific MetricValue pro recovery score,
* SleepSummary vytvořený interním systémem.

Provider recovery score se nesmí stát přímo ReadinessAssessment.

---

# 142. Příklad – Google Calendar export

Workout:

* Upper Body A,
* úterý 18:00.

Uživatel má privacy mode:

* obecný název.

Externí událost:

* „Workout“,
* čas 18:00–18:45,
* deep link.

Interní ScheduleEvent zůstává zdrojem pravdy.

---

# 143. Příklad – externí kalendářní konflikt

Google Calendar má novou schůzku ve stejný čas jako flexibilní workout.

Pokud aplikace čte busy intervaly:

* vznikne ScheduleConflict,
* AI může navrhnout přesun,
* externí událost se nemění.

---

# 144. Příklad – odvolané oprávnění

Uživatel v systému odebere přístup ke spánku.

Výsledek:

* Sleep permission → REVOKED,
* import spánku se zastaví,
* ostatní datové typy fungují,
* integrace PARTIALLY_ACTIVE,
* historické SleepRecord zůstávají podle policy.

---

# 145. Příklad – expirovaný Garmin token

Výsledek:

* credential nelze obnovit,
* UserIntegration → REAUTHENTICATION_REQUIRED,
* synchronizace se pozastaví,
* existující Activity zůstávají,
* uživatel dostane akci „Znovu připojit“.

---

# 146. Příklad – smazaná aktivita ve Stravě

Aktivita má také Garmin source.

Strava source se označí jako deleted.

Interní Activity zůstává díky Garmin zdroji.

---

# 147. Příklad – pouze Strava source smazaný

Pokud jde o jediný zdroj:

* Activity se automaticky nemaže,
* záznam se označí k revizi,
* uživatel může zvolit ponechat nebo skrýt.

---

# 148. Příklad – import neznámého sportu

Provider typ:

* `AERIAL_SPORT`.

Mapping neexistuje.

Výsledek:

* ExternalDataRecord → NEEDS_REVIEW,
* navržený CustomSportProfile,
* uživatel potvrdí aerial hoop,
* Activity se importuje.

---

# 149. Příklad – export workoutu na hodinky

Interní workout obsahuje:

* superset,
* vlastní cvik,
* kvalitativní instrukci.

Zařízení podporuje pouze lineární kroky.

Aplikace zobrazí:

* superset bude exportován jako dva samostatné kroky,
* vlastní cvik jako obecná instrukce,
* některé detaily budou dostupné jen v telefonu.

---

# 150. Příklad – provider outage

Garmin API je dočasně nedostupné.

Výsledek:

* nové joby čekají,
* UserIntegration může mít stav DELAYED,
* aplikace dál funguje,
* AI ví, že dnešní data mohou chybět.

---

# 151. Příklad – ruční refresh při rate limitu

Uživatel opakovaně stiskne synchronizaci.

Systém:

* nevytvoří deset jobů,
* vrátí existující čekající job,
* zobrazí přibližný stav,
* respektuje provider limit.

---

# 152. Příklad – změna mapping verze

Provider přidá nový běžecký typ.

Nové mapování ho správně zařadí jako trail running.

Starší záznamy mohou být:

* ponechány,
* nebo přepočítány pomocí ReconciliationJob.

Původní mapping version zůstává dohledatelná.

---

# 153. Co musí být strukturované

Nesmí zůstat pouze jako volný text:

* poskytovatel,
* capability,
* datový typ,
* stav integrace,
* oprávnění,
* scope,
* směr synchronizace,
* externí identifikátor,
* import job,
* export job,
* cursor,
* mapping,
* duplicita,
* konflikt,
* credential stav,
* webhook stav,
* disconnect policy,
* retention policy,
* data freshness.

Volný text může doplňovat:

* uživatelskou poznámku,
* bezpečnou chybovou zprávu,
* vysvětlení problému,
* popis vlastního poskytovatele.

---

# 154. Otevřené otázky

* Které integrace budou skutečně součástí první verze?
* Které Garmin API budou reálně dostupné?
* Které datové typy bude možné exportovat?
* Jaké platformní rozdíly budou mezi iOS a Androidem?
* Která data z Apple Health a Health Connect půjdou na backend?
* Které výpočty se provedou pouze lokálně?
* Jaké historické období importovat jako výchozí?
* Jak uživateli vysvětlit duplicitní zdroje jednoduše?
* Jak určit source priority podle metrik?
* Jak přesně modelovat provider lineage?
* Jak dlouho uchovávat raw payload?
* Kdy raw payload neukládat vůbec?
* Jak ukládat velké FIT, GPX a časové řady?
* Jak dlouho uchovávat webhook eventy?
* Jak řešit provider API bez stabilního external id?
* Jak řešit změnu externího účtu stejného poskytovatele?
* Jak řešit více Garmin nebo Strava účtů?
* Jak řešit rodinné nebo sdílené kalendáře?
* Jak importovat pouze busy intervaly bez názvů?
* Jak podporovat obousměrnou kalendářní synchronizaci?
* Jak řešit změnu opakované události v externím kalendáři?
* Jak přesně aktualizovat exportovaný workout?
* Jak řešit workout dokončený na hodinkách bez detailních sérií?
* Jak mapovat proprietary recovery scores?
* Jak komunikovat rozdíl mezi provider skóre a interním readiness?
* Které provider chyby zobrazovat uživateli?
* Jak monitorovat provider-wide outage?
* Jak řešit rate limit pro velký historický import?
* Jak provést backfill bez zahlcení výpočtů?
* Jak přepočítat baseline po importu starší historie?
* Jak zabránit vytvoření falešných osobních rekordů z importu?
* Jak řešit externí smazání uživatelsky upravené aktivity?
* Jak provést remote delete při smazání účtu?
* Jaké právní souhlasy jsou potřeba pro health data?
* Jak dlouho uchovávat IntegrationAuditRecord?
* Jak implementovat secret storage?
* Jak řešit token rotation?
* Jaké údaje budou dostupné support pracovníkům?
* Jak anonymizovat integrační diagnostiku?
* Jak testovat poskytovatele bez produkčních účtů?
* Jak verzovat IntegrationProviderConfiguration?
* Jak provádět migraci na novou API verzi?
* Jak zachovat funkčnost při odstranění poskytovatele?
* Jak uživateli exportovat historii integrací?
* Jak se zachovají externí reference po odpojení?
* Jak bude fungovat automatická oprava rozbitého webhooku?
* Jak přesně synchronizovat platformní data při background omezeních iOS?
* Jak přesně synchronizovat Health Connect při omezeném běhu aplikace?
* Jaké integrační operace mohou probíhat offline?
* Jaká data smí být poslána AI?
* Jak oddělit citlivé kalendářní údaje od planning enginu?
* Jak řešit data nezletilých uživatelů?
* Jaké certifikace nebo audity budou potřeba pro jednotlivé poskytovatele?

---

# 155. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── sync-and-offline-model.md
├── identity-and-profile-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/07-backend/
├── integration-service.md
├── integration-adapters.md
├── credential-security.md
├── import-pipeline.md
├── export-pipeline.md
├── webhook-processing.md
├── provider-mapping.md
├── integration-reconciliation.md
└── integration-api.md
```

A:

```text
docs/08-mobile/
├── health-connect-integration.md
├── apple-health-integration.md
├── platform-permissions.md
├── mobile-integration-sync.md
├── integration-settings-ui.md
└── background-health-import.md
```

A:

```text
docs/09-security/
├── secrets-management.md
├── oauth-security.md
├── health-data-security.md
├── webhook-security.md
└── third-party-data-processing.md
```

---

# 156. Kritéria správného integračního modelu

Model je vhodný pouze tehdy, pokud umožní:

1. definovat nového poskytovatele,
2. definovat jeho schopnosti,
3. připojit uživatelský účet,
4. pracovat s platformním oprávněním,
5. udělit pouze část oprávnění,
6. zvolit synchronizované datové typy,
7. podporovat import a export,
8. importovat historii,
9. provádět incremental sync,
10. zpracovat webhook,
11. používat polling,
12. respektovat rate limits,
13. obnovovat tokeny,
14. vyžádat reautentizaci,
15. chránit credential,
16. mapovat sporty,
17. mapovat metriky,
18. převádět jednotky,
19. zachovat původní data,
20. uchovat provider lineage,
21. detekovat duplicity napříč poskytovateli,
22. sloučit zdroje do jedné Activity,
23. řešit konfliktní hodnoty,
24. importovat spánek,
25. importovat recovery metriky,
26. importovat aktivity,
27. importovat trasy,
28. exportovat kalendářní událost,
29. chránit citlivý kalendářní obsah,
30. fungovat při výpadku poskytovatele,
31. fungovat bez integrací,
32. zobrazit stav synchronizace,
33. pozastavit integraci,
34. odpojit integraci,
35. určit nakládání s historickými daty,
36. respektovat odvolání oprávnění,
37. zabránit duplicitnímu importu,
38. zabránit duplicitnímu exportu,
39. podporovat offline mobilní import,
40. synchronizovat data z telefonu na backend,
41. auditovat významné operace,
42. chránit data před AI a analytikou,
43. přidat nového poskytovatele bez změny hlavního doménového modelu,
44. odstranit poskytovatele bez ztráty interní sportovní historie.

---

# 157. Závěr

Integration model vytváří bezpečnou hranici mezi AI Trainerem a externími službami.

Jeho základní importní tok je:

```text
IntegrationProvider
    ↓
UserIntegration
    ↓
IntegrationPermission
    ↓
Provider Adapter
    ↓
ExternalDataRecord
    ↓
Normalization a Mapping
    ↓
Duplicate Detection
    ↓
Activity / MetricValue / SleepRecord / ScheduleEvent
```

Exportní tok je:

```text
WorkoutInstance / ScheduleEvent / Activity
    ↓
Export Validation
    ↓
Privacy Filtering
    ↓
Provider Mapping
    ↓
DataExportJob
    ↓
External Resource
    ↓
ExternalResourceReference
```

Bezpečnostní tok je:

```text
User Consent
    +
Platform Permission
    +
Integration Scope
    ↓
Tool Authorization
    ↓
Credential Access
    ↓
Provider Operation
    ↓
Audit
```

Hlavní zásadou je, že externí služby poskytují data a další možnosti, ale nevlastní interní logiku aplikace.

Garmin aktivita není přímo interní Activity.

Apple Health recovery score není interní ReadinessAssessment.

Google Calendar událost není automaticky sportovní ScheduleEvent.

Každý externí objekt musí projít:

* autorizací,
* validací,
* normalizací,
* mapováním,
* deduplikací,
* doménovým zpracováním.

Díky tomu může uživatel:

* připojit hodinky,
* importovat aktivity,
* načíst spánek,
* zobrazit workout v externím kalendáři,
* později exportovat plán do wearables,
* připojit více služeb současně,

aniž by aplikace započítávala stejné aktivity vícekrát, ztratila původ dat nebo předala externím službám více citlivých informací, než je skutečně nutné.
