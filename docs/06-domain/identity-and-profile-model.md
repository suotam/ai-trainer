# AI Trainer – Identity and Profile Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/identity-and-profile-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model identity, uživatelského účtu, sportovního profilu, onboardingu, preferencí, nastavení, souhlasů, zařízení a budoucích vztahů mezi sportovcem, trenérem a dalšími uživateli aplikace AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-personas.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/information-architecture.md`,
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
* `docs/06-domain/integration-model.md`,
* `docs/06-domain/sync-and-offline-model.md`.

Dokument popisuje:

* identitu uživatele,
* přihlašovací účty,
* oddělení identity a sportovního profilu,
* AthleteProfile,
* onboarding,
* základní osobní údaje,
* sportovní zkušenosti,
* časové možnosti,
* preference tréninku,
* prostředí a vybavení,
* jednotky a lokalizaci,
* časové pásmo,
* notifikační preference,
* AI preference,
* souhlasy a privacy preference,
* profilovou úplnost,
* více zařízení,
* anonymní a dočasné používání,
* migraci hostovského účtu,
* budoucí víceprofilový model,
* vztah sportovec–trenér,
* role a oprávnění,
* profil nezletilého uživatele,
* audit a historii,
* export a smazání dat,
* doménové události,
* příkazy,
* invariance,
* read modely.

Dokument zatím neurčuje:

* konkrétní poskytovatele autentizace,
* konkrétní OAuth implementaci,
* přesné databázové tabulky,
* finální podobu obrazovek,
* finální právní texty,
* konkrétní ceny a předplatné,
* finální podporu rodinných účtů,
* konkrétní trenérské obchodní funkce,
* konkrétní pravidla pro nezletilé podle jednotlivých zemí.

---

# 2. Cíl modelu identity a profilu

Model musí umožnit používat aplikaci například jako:

* nový uživatel bez sportovní historie,
* rekreační sportovec,
* výkonnostní sportovec,
* multisportovní uživatel,
* člověk s nepravidelným rozvrhem,
* člověk s dlouhodobým omezením,
* uživatel bez wearables,
* uživatel s několika zařízeními,
* uživatel s vlastním netradičním sportem,
* sportovec vedený trenérem,
* trenér spravující více sportovců,
* nezletilý uživatel se zákonným zástupcem,
* člověk používající aplikaci nejprve anonymně.

Model nesmí předpokládat:

> Jeden účet = jeden jednoduchý profil = jeden sport.

Musí oddělovat minimálně:

```text
Identity
    ↓
UserAccount
    ↓
AthleteProfile
    ↓
UserSport / Goal / Preference / Availability
```

V budoucnu může jeden účet spravovat více profilových kontextů, ale první verze může mít vztah:

```text
UserAccount 1 ─── 1 AthleteProfile
```

---

# 3. Základní principy

## 3.1 Identita není sportovní profil

Identita odpovídá na otázku:

> Kdo se přihlašuje?

Sportovní profil odpovídá na otázku:

> Pro koho aplikace plánuje trénink?

Tyto pojmy se nesmí sloučit do jednoho objektu.

## 3.2 Aplikace musí fungovat i s neúplným profilem

Uživatel nemusí při první registraci vyplnit:

* všechny sporty,
* přesnou historii,
* všechny cíle,
* tělesné údaje,
* celý týdenní rozvrh,
* wearables.

Systém musí umět:

* pracovat s neúplností,
* vyjádřit nejistotu,
* postupně profil doplňovat,
* neblokovat základní použití.

## 3.3 Citlivé údaje mají být volitelné, pokud nejsou nezbytné

Například:

* tělesná hmotnost,
* historická zranění,
* zdravotní omezení,
* datum narození,

se nemají požadovat bez vysvětlení účelu.

## 3.4 Profil se vyvíjí v čase

Aktuální profil není neměnná registrace.

Mění se:

* sporty,
* cíle,
* priority,
* dostupnost,
* vybavení,
* zkušenost,
* omezení,
* preference,
* časové pásmo,
* zařízení.

## 3.5 Uživatel musí mít kontrolu

AI může navrhnout:

* doplnění profilu,
* interpretaci sportovní zkušenosti,
* úpravu preferencí,
* změnu dostupnosti.

Významná změna se však nesmí provést bez odpovídajícího potvrzení.

## 3.6 Profilové údaje musí mít účel

Každé pole má být získáváno proto, že ovlivňuje:

* plán,
* bezpečnost,
* personalizaci,
* zobrazování,
* integraci,
* právní povinnost.

Aplikace nemá sbírat údaje „pro jistotu“.

## 3.7 Historie se nesmí přepisovat aktuálním stavem

Pokud uživatel změní:

* hmotnost,
* zkušenost,
* sport,
* dostupnost,

historické plány a aktivity musí zůstat interpretovatelné podle tehdejšího kontextu.

---

# 4. Hlavní doménové objekty

Oblast identity a profilu obsahuje minimálně:

* Identity,
* UserAccount,
* AuthenticationIdentity,
* UserStatus,
* AthleteProfile,
* AthleteProfileRevision,
* ProfileCompleteness,
* ProfileAttribute,
* ProfileAttributeSource,
* PersonalDetails,
* BodyProfile,
* TrainingBackground,
* TrainingPreference,
* AvailabilityProfile,
* TypicalWeekProfile,
* EquipmentProfile,
* TrainingEnvironment,
* UnitPreference,
* LocalePreference,
* TimeZonePreference,
* AccessibilityPreference,
* NotificationPreference,
* AIInteractionPreference,
* PrivacyPreference,
* DataProcessingConsent,
* LegalAcceptance,
* OnboardingSession,
* OnboardingStep,
* OnboardingAnswer,
* UserRole,
* ProfileRole,
* CoachAthleteRelationship,
* GuardianRelationship,
* ManagedProfile,
* AccountDeletionRequest,
* DataExportRequest,
* ProfileMergeRequest,
* IdentityLink,
* UserDevicePreference.

---

# 5. Identity

## 5.1 Význam

Identity reprezentuje jedinečnou interní identitu člověka nebo systémového aktéra.

Není totožná s konkrétním způsobem přihlášení.

## 5.2 Vlastnosti

Obsahuje zejména:

* interní identifikátor,
* stav,
* datum vytvoření,
* datum posledního ověření,
* bezpečnostní úroveň,
* připojené autentizační identity,
* vlastněné účty nebo profily,
* auditní reference.

## 5.3 Stav

* ACTIVE,
* UNVERIFIED,
* SUSPENDED,
* LOCKED,
* DELETION_PENDING,
* DELETED,
* MERGED,
* COMPROMISED.

## 5.4 Jedna identita, více způsobů přihlášení

Uživatel může mít připojeno například:

* e-mail a heslo,
* Apple účet,
* Google účet,
* jiný identity provider.

Všechny mohou směřovat na stejnou interní Identity.

---

# 6. AuthenticationIdentity

## 6.1 Význam

Jeden konkrétní způsob autentizace.

## 6.2 Typy

* EMAIL_PASSWORD,
* MAGIC_LINK,
* GOOGLE,
* APPLE,
* MICROSOFT,
* PASSKEY,
* PHONE,
* ANONYMOUS,
* ENTERPRISE,
* CUSTOM.

## 6.3 Vlastnosti

* provider,
* provider subject id,
* ověřený e-mail,
* telefon podle potřeby,
* stav ověření,
* datum připojení,
* poslední použití,
* primary flag,
* recovery capability.

## 6.4 Provider subject

Musí být použit stabilní poskytovatelský identifikátor.

E-mail samotný nemá být jediným identifikátorem externí identity.

## 6.5 E-mail

E-mail může být:

* přihlašovací údaj,
* kontaktní údaj,
* oba významy,
* nebo žádný, pokud uživatel používá anonymní či jinou identitu.

---

# 7. UserAccount

## 7.1 Význam

UserAccount reprezentuje produktový účet uživatele.

Obsahuje:

* vlastnictví dat,
* nastavení účtu,
* stav produktu,
* předplatné v budoucnu,
* právní souhlasy,
* vazbu na profily.

## 7.2 Vlastnosti

* accountId,
* identityId,
* stav,
* datum registrace,
* primární jazyk,
* primární časové pásmo,
* region,
* typ účtu,
* aktivní AthleteProfile,
* role,
* subscription reference v budoucnu,
* deletion state.

## 7.3 Typy účtu

* STANDARD,
* ANONYMOUS,
* ATHLETE,
* COACH,
* ATHLETE_AND_COACH,
* GUARDIAN,
* ORGANIZATION_MEMBER,
* ADMINISTRATIVE.

První verze může produktově používat jen část typů.

## 7.4 Stav

* ACTIVE,
* ONBOARDING,
* LIMITED,
* SUSPENDED,
* LOCKED,
* DELETION_PENDING,
* DELETED.

---

# 8. UserStatus

Uživatel může mít produktový stav:

* NEW,
* ONBOARDING_IN_PROGRESS,
* READY,
* PROFILE_INCOMPLETE,
* ACTIVE,
* DORMANT,
* RETURNING,
* RESTRICTED,
* DELETION_PENDING.

## 8.1 PROFILE_INCOMPLETE

Neznamená, že aplikaci nelze používat.

Znamená, že některá doporučení mohou být obecnější.

---

# 9. AthleteProfile

## 9.1 Význam

AthleteProfile je hlavní sportovní profil osoby, pro kterou systém plánuje, vyhodnocuje a personalizuje trénink.

## 9.2 Vlastnosti

Obsahuje zejména:

* profileId,
* vlastníka,
* zobrazované jméno,
* stav,
* typ,
* základní osobní údaje,
* sporty,
* cíle,
* zkušenost,
* tělesný profil,
* časové možnosti,
* preference,
* prostředí,
* vybavení,
* omezení,
* jednotky,
* lokalizaci,
* časové pásmo,
* AI preference,
* privacy preference,
* datum vytvoření,
* poslední revizi.

## 9.3 ProfileType

* SELF,
* MANAGED_ATHLETE,
* CHILD,
* COACHED_ATHLETE,
* DEMO,
* TEST,
* IMPORTED.

## 9.4 První verze

První verze může podporovat pouze `SELF`.

Model však musí umožnit budoucí rozšíření bez změny základních vztahů.

---

# 10. AthleteProfileStatus

* DRAFT,
* ACTIVE,
* PAUSED,
* INCOMPLETE,
* ARCHIVED,
* MERGED,
* DELETED.

## 10.1 PAUSED

Profil může být dočasně neaktivní, například při dlouhodobé pauze.

Historie zůstává zachována.

---

# 11. AthleteProfileRevision

## 11.1 Význam

Neměnná historická revize významné změny profilu.

## 11.2 Vzniká například při

* změně data narození,
* změně tělesných údajů,
* změně hlavního sportu,
* změně zkušenostní úrovně,
* významné změně časové dostupnosti,
* změně tréninkových preferencí,
* změně časového pásma s plánovacím dopadem.

## 11.3 Obsah

* původní stav,
* nový stav,
* změněná pole,
* důvod,
* aktér,
* čas,
* zdroj,
* ChangeSet reference.

## 11.4 Drobné preference

Ne každá změna UI preference vyžaduje plnou profilovou revizi.

---

# 12. PersonalDetails

## 12.1 Význam

Základní osobní údaje relevantní pro produkt.

## 12.2 Možná pole

* preferredName,
* displayName,
* birthDate,
* birthYear,
* ageRange,
* gender-related training context volitelně a citlivě,
* country,
* region,
* primaryLanguage.

## 12.3 Preferované jméno

Aplikace má používat jméno, kterým chce být uživatel oslovován.

Nemusí být stejné jako právní jméno.

## 12.4 Právní jméno

Nemá se ukládat, pokud není nutné pro:

* fakturaci,
* právní vztah,
* trenérskou nebo organizovanou službu.

Má být odděleno od běžného AthleteProfile.

---

# 13. Datum narození a věk

## 13.1 Použití

Může ovlivnit:

* právní souhlas,
* bezpečnostní pravidla,
* doporučení pro nezletilé,
* některé obecné sportovní kontexty.

## 13.2 Minimalizace

Pokud není přesné datum potřeba, lze použít:

* rok narození,
* věkovou kategorii,
* potvrzení plnoletosti.

## 13.3 Odvozený věk

Věk se nemá ukládat jako neměnná hodnota.

Má se odvozovat z data nebo roku narození.

---

# 14. Gender and Sex Context

## 14.1 Citlivost

Údaje související s pohlavím nebo genderem jsou citlivé a nemají být povinné bez jasného důvodu.

## 14.2 Možné použití

Budoucí specializované funkce mohou řešit například:

* ženský sportovní kontext,
* těhotenství,
* menstruační cyklus,
* jiné fyziologické souvislosti.

Tyto funkce musí mít:

* samostatný souhlas,
* odbornou validaci,
* samostatný citlivý model.

## 14.3 Základní verze

Základní plánování nesmí být podmíněno uvedením tohoto údaje.

---

# 15. BodyProfile

## 15.1 Význam

Tělesné údaje relevantní pro plánování a metriky.

## 15.2 Možná pole

* height,
* bodyWeight,
* bodyComposition,
* dominantSide,
* resting values,
* další uživatelsky zadané údaje.

## 15.3 Historické hodnoty

Tělesná hmotnost a podobné hodnoty se nemají ukládat pouze přímo v profilu.

Aktuální hodnota může být read modelem nad MetricValue historií.

## 15.4 DominantSide

* LEFT,
* RIGHT,
* MIXED,
* UNKNOWN,
* NOT_RELEVANT.

Může být užitečná pro:

* jednostranné cviky,
* techniku,
* interpretaci asymetrie.

---

# 16. Height

Výška může být:

* volitelná,
* uložena jako MetricValue,
* zobrazována podle UnitPreference.

Musí mít:

* zdroj,
* datum,
* jednotku,
* případnou jistotu.

---

# 17. BodyWeight

Aktuální hmotnost může pocházet:

* z ručního zadání,
* z wearables,
* z chytré váhy,
* z importu.

Musí být zachován původ.

Nemá být automaticky používána pro hodnocení úspěchu bez souvisejícího cíle.

---

# 18. TrainingBackground

## 18.1 Význam

Souhrn sportovní historie uživatele.

## 18.2 Obsah

* roky obecné sportovní zkušenosti,
* pravidelnost posledních měsíců,
* historie silového tréninku,
* historie vytrvalostního tréninku,
* sportovní pauzy,
* návrat po pauze,
* zkušenost s plánovaným tréninkem,
* zkušenost s technickými cviky.

## 18.3 Nepřesnost

Uživatel nemusí znát přesné hodnoty.

Mohou být použity kategorie:

* žádná zkušenost,
* méně než 6 měsíců,
* 6–24 měsíců,
* 2–5 let,
* více než 5 let,
* nepravidelně,
* aktuálně po pauze.

## 18.4 Oddělení od UserSport

TrainingBackground je obecný souhrn.

Konkrétní zkušenost se sportem je v UserSport.

---

# 19. CurrentTrainingState

## 19.1 Význam

Popis aktuálního režimu před vytvořením plánu.

## 19.2 Obsah

* počet aktivit týdně,
* aktuální sporty,
* obvyklá délka,
* obvyklá intenzita,
* pravidelnost,
* datum posledního pravidelného období,
* současná pauza,
* aktuální subjektivní kapacita.

## 19.3 Použití

Pomáhá zabránit tomu, aby systém vytvořil plán výrazně nad aktuální kapacitu.

---

# 20. TrainingPreference

## 20.1 Význam

Preference uživatele ohledně formy a stylu tréninku.

## 20.2 Možná pole

* preferredSessionLength,
* minimumUsefulSessionLength,
* maximumSessionLength,
* preferredTrainingTime,
* preferredTrainingDays,
* preferredIntensityDistribution,
* preferredWorkoutStyle,
* dislikedActivities,
* favoriteActivities,
* preferenceForVariety,
* preferenceForRoutine,
* preferenceForDetailedInstructions,
* preferenceForAutonomy,
* socialPreference,
* indoorOutdoorPreference.

## 20.3 Preference není bezpečnostní pravidlo

Uživatel může nemít rád mobilitu.

To však neznamená, že ji systém nikdy nesmí doporučit.

Musí být vysvětlen kompromis.

## 20.4 Preference není tvrdé omezení

Každá preference může mít sílu:

* HARD,
* STRONG,
* NORMAL,
* WEAK,
* INFORMATIONAL.

---

# 21. PreferredSessionLength

Může být:

* konkrétní délka,
* rozsah,
* podle dne,
* podle typu tréninku.

Příklad:

* ráno maximálně 15 minut,
* večer 45–60 minut,
* o víkendu až 2 hodiny.

Proto se nemá ukládat pouze jedno globální číslo.

---

# 22. PreferredTrainingTime

Možnosti:

* EARLY_MORNING,
* MORNING,
* MIDDAY,
* AFTERNOON,
* EVENING,
* LATE_EVENING,
* VARIABLE,
* CUSTOM_TIME_RANGE.

Konkrétní dostupnost patří do AvailabilityProfile.

---

# 23. WorkoutStylePreference

Příklady:

* STRUCTURED,
* FLEXIBLE,
* MINIMALIST,
* HIGH_VARIETY,
* REPEATABLE,
* CIRCUIT_BASED,
* SET_BASED,
* TIME_BASED,
* GAMIFIED,
* COACH_LED.

AI může použít preference pro výběr mezi bezpečnými a účinnými variantami.

---

# 24. InstructionDetailPreference

Úrovně:

* MINIMAL,
* CONCISE,
* STANDARD,
* DETAILED,
* EDUCATIONAL.

Ovlivňuje:

* text cviků,
* AI odpovědi,
* počet vysvětlení,
* tracker.

Nemění doménový obsah workoutu.

---

# 25. TrainingAutonomyPreference

## 25.1 Význam

Jak moc chce uživatel, aby systém automaticky rozhodoval.

## 25.2 Úrovně

* MANUAL_CONTROL,
* SUGGEST_ONLY,
* CONFIRM_MAJOR_CHANGES,
* AUTOMATE_LOW_RISK,
* HIGH_AUTOMATION_WITH_LIMITS.

## 25.3 Omezení

Ani nejvyšší automatizace nesmí obejít:

* bezpečnostní pravidla,
* citlivé souhlasy,
* změnu hlavního cíle,
* kritické změny.

---

# 26. AvailabilityProfile

## 26.1 Význam

Obecný profil časové dostupnosti uživatele.

Nejde o konkrétní kalendářní události.

## 26.2 Obsah

* typický týden,
* dostupná časová okna,
* nedostupná okna,
* flexibilita,
* minimální předstih,
* maximální počet jednotek denně,
* preferovaný odpočinkový den,
* pracovní nebo školní režim,
* sezónní dostupnost.

## 26.3 Zdroj pravdy

Konkrétní pevné termíny jsou v scheduling modelu.

AvailabilityProfile poskytuje obecné plánovací mantinely.

---

# 27. TypicalWeekProfile

## 27.1 Význam

Strukturovaný popis obvyklého týdne.

## 27.2 Příklad

Pondělí:

* práce 8:00–16:00,
* florbal 19:00–21:00,
* ráno 15 minut.

Úterý:

* flexibilní večer,
* maximálně 60 minut.

## 27.3 Vlastnosti

* den týdne,
* časová okna,
* dostupnost,
* typická energie,
* preference,
* pevnost,
* poznámka.

## 27.4 Typická energie

Volitelně:

* HIGH,
* NORMAL,
* LOW,
* VARIABLE.

Například uživatel může preferovat těžší workout ráno.

---

# 28. AvailabilityWindow

Obsahuje:

* den nebo datum,
* start,
* end,
* timezone,
* availability type,
* maximum duration,
* preferred activity types,
* flexibility,
* source.

Typy:

* AVAILABLE,
* PREFERRED,
* POSSIBLE,
* UNAVAILABLE,
* RECOVERY_ONLY,
* MICRO_SESSION_ONLY.

---

# 29. ScheduleFlexibilityPreference

Úrovně:

* FIXED,
* LOW,
* MEDIUM,
* HIGH,
* FULLY_DYNAMIC.

Může být různá podle:

* typu workoutu,
* dne,
* cíle,
* období.

---

# 30. MaximumTrainingFrequency

Profil může obsahovat:

* maximální workouty za den,
* maximální náročné jednotky za den,
* maximální plánované jednotky týdně,
* minimální mezery,
* preference dvoufázových dnů.

Tato data nejsou jediným bezpečnostním limitem.

Plánovací engine musí zohlednit skutečnou zátěž.

---

# 31. EquipmentProfile

## 31.1 Význam

Přehled vybavení, ke kterému má uživatel přístup.

## 31.2 Příklady

* žádné vybavení,
* podložka,
* hrazda,
* odporové gumy,
* jednoručky,
* činka,
* lavice,
* kettlebell,
* domácí posilovna,
* komerční fitness centrum,
* lezecká stěna,
* běžecký pás,
* kolo,
* bazén.

## 31.3 Vlastnosti

* EquipmentDefinition,
* dostupnost,
* počet,
* parametry,
* místo,
* časové omezení,
* stav,
* datum od kdy.

## 31.4 Přístup versus vlastnictví

Uživatel nemusí vybavení vlastnit.

Může k němu mít přístup:

* doma,
* v práci,
* ve fitku,
* na konkrétní dny.

---

# 32. EquipmentAvailability

* ALWAYS,
* HOME_ONLY,
* GYM_ONLY,
* LOCATION_BASED,
* DAY_BASED,
* TEMPORARY,
* UNKNOWN.

Příklad:

Hrazda je doma vždy.

Velká činka je dostupná pouze ve fitku v úterý a čtvrtek.

---

# 33. CustomEquipment

Uživatel může přidat vlastní pomůcku.

Musí uvést:

* název,
* kategorii,
* základní použití,
* omezení,
* případně AI navržené mapování.

AI nesmí neznámé vybavení považovat za bezpečně ekvivalentní bez validace.

---

# 34. TrainingEnvironment

## 34.1 Význam

Prostředí, ve kterém může uživatel trénovat.

## 34.2 Typy

* HOME,
* GYM,
* OUTDOOR,
* OFFICE,
* CLUB,
* SPORTS_HALL,
* CLIMBING_GYM,
* POOL,
* TRAVEL,
* HOTEL,
* CUSTOM.

## 34.3 Vlastnosti

* název,
* typ,
* dostupné vybavení,
* prostor,
* hluková omezení,
* možnost skákání,
* povrch,
* časová dostupnost,
* soukromí.

## 34.4 Příklad

Domácí prostředí:

* hrazda,
* málo prostoru,
* zákaz skákání kvůli sousedům.

To musí ovlivnit výběr cviků.

---

# 35. LocationPreference

Přesná poloha není nutná pro základní plánování.

Může stačit:

* domov,
* práce,
* fitko,
* venku.

Přesná geolokace musí mít samostatný souhlas a účel.

---

# 36. UnitPreference

## 36.1 Význam

Způsob zobrazování jednotek uživateli.

## 36.2 Pole

* measurementSystem,
* distanceUnit,
* weightUnit,
* heightUnit,
* temperatureUnit,
* paceUnit,
* energyUnit,
* timeFormat,
* firstDayOfWeek.

## 36.3 MeasurementSystem

* METRIC,
* IMPERIAL,
* MIXED,
* CUSTOM.

## 36.4 Interní hodnoty

Preference nemění kanonické interní jednotky.

Ovlivňuje pouze:

* vstup,
* zobrazení,
* export.

---

# 37. TimeFormat

* HOUR_24,
* HOUR_12,
* SYSTEM_DEFAULT.

## 37.1 FirstDayOfWeek

* MONDAY,
* SUNDAY,
* SATURDAY,
* LOCALE_DEFAULT.

To ovlivňuje týdenní přehledy, ale ne interní absolutní čas.

---

# 38. LocalePreference

## 38.1 Obsah

* language,
* locale,
* dateFormat,
* numberFormat,
* translation fallback.

## 38.2 Jazyk AI

Může být:

* stejný jako aplikace,
* samostatně zvolený,
* automaticky podle konverzace.

## 38.3 Odborné názvy

Aplikace musí zachovat stabilní interní kódy nezávislé na jazyku.

---

# 39. TimeZonePreference

## 39.1 Význam

Určuje výchozí časové pásmo uživatele.

## 39.2 Pole

* homeTimeZone,
* currentTimeZone,
* planningTimeZonePolicy,
* travelBehavior.

## 39.3 PlanningTimeZonePolicy

* FOLLOW_CURRENT_LOCATION,
* KEEP_HOME_TIMEZONE,
* ASK_WHEN_CHANGED,
* EVENT_SPECIFIC.

## 39.4 Změna časového pásma

Při změně musí systém posoudit:

* workouty,
* notifikace,
* opakované události,
* denní check-in,
* agregace.

---

# 40. TravelPreference

Může určit:

* automatické přizpůsobení lokálnímu času,
* zachování domácího rytmu,
* omezené workouty během cesty,
* preferenci hotelových workoutů,
* dostupné vybavení na cestách.

---

# 41. AccessibilityPreference

## 41.1 Význam

Nastavení zpřístupnění nezávislé na systémových možnostech platformy.

## 41.2 Příklady

* largerText,
* reducedMotion,
* highContrast,
* screenReaderOptimized,
* hapticFeedback,
* audioInstructions,
* colorIndependentCharts,
* longerInteractionTimeouts.

## 41.3 Pravidlo

Klíčové stavy nesmí být komunikovány pouze:

* barvou,
* animací,
* zvukem.

---

# 42. NotificationPreference

## 42.1 Význam

Určuje, jaké notifikace uživatel chce dostávat.

## 42.2 Typy notifikací

* DAILY_PLAN,
* WORKOUT_REMINDER,
* PRE_WORKOUT_CHECK_IN,
* REST_TIMER,
* MISSED_WORKOUT,
* RECOVERY_CHECK,
* WEEKLY_REVIEW,
* GOAL_PROGRESS,
* PERSONAL_RECORD,
* INTEGRATION_ISSUE,
* SAFETY_REVIEW,
* COACH_MESSAGE,
* SYSTEM.

## 42.3 Kanály

* PUSH,
* EMAIL,
* IN_APP,
* SMS v budoucnu,
* WATCH,
* CALENDAR.

## 42.4 Nastavení

Pro každý typ:

* enabled,
* channel,
* lead time,
* quiet hours,
* frequency limit,
* importance,
* timezone behavior.

---

# 43. QuietHours

Obsahuje:

* začátek,
* konec,
* dny,
* výjimky,
* timezone.

Kritické bezpečnostní upozornění může mít jinou policy než běžný reminder.

---

# 44. NotificationFrequencyLimit

Aplikace musí zabránit zahlcení.

Může definovat:

* maximum za den,
* slučování upozornění,
* cooldown,
* preference souhrnu.

---

# 45. AIInteractionPreference

## 45.1 Význam

Preference komunikace s AI trenérem.

## 45.2 Pole

* responseLength,
* tone,
* coachingStyle,
* proactiveSuggestions,
* explanationDepth,
* motivationalStyle,
* confirmationPreference,
* useSensitiveContext,
* memoryPreference,
* suggestionFrequency.

## 45.3 ResponseLength

* VERY_SHORT,
* SHORT,
* STANDARD,
* DETAILED.

## 45.4 CoachingStyle

* DIRECT,
* SUPPORTIVE,
* EDUCATIONAL,
* ANALYTICAL,
* MINIMAL,
* BALANCED.

## 45.5 MotivationalStyle

* NEUTRAL,
* ENCOURAGING,
* CHALLENGING,
* DATA_DRIVEN,
* LOW_PRESSURE.

---

# 46. ProactiveSuggestions

Úrovně:

* OFF,
* SAFETY_ONLY,
* IMPORTANT_ONLY,
* NORMAL,
* HIGH.

Ani při HIGH nesmí AI měnit data bez ConfirmationPolicy.

---

# 47. AI Memory Preference

## 47.1 Význam

Určuje, jaké dlouhodobé informace může AI používat.

## 47.2 Kategorie

* profile facts,
* sports,
* goals,
* preferences,
* limitations,
* conversation summaries,
* sensitive health context.

## 47.3 Pravidlo

Doménová data nejsou totéž jako neřízená konverzační paměť.

AI má primárně číst aktuální strukturovaný profil.

---

# 48. AI Sensitive Context Preference

Možnosti:

* ALLOW_REQUIRED_ONLY,
* ALLOW_RELEVANT,
* ASK_EACH_TIME,
* DISALLOW_OPTIONAL_USE.

Bezpečnostní pravidla mohou používat lokálně uložené aktivní omezení i bez odeslání kompletního detailu externímu modelu.

---

# 49. PrivacyPreference

## 49.1 Význam

Uživatelské volby týkající se použití a sdílení dat.

## 49.2 Pole

* allowAiProcessing,
* allowSensitiveAiProcessing,
* allowProductAnalytics,
* allowPersonalization,
* allowResearchUse,
* allowLocationUse,
* allowRouteStorage,
* allowCoachAccess,
* profileVisibility,
* activityVisibility v budoucnu,
* dataRetentionPreference.

## 49.3 Rozdíl preference a právního souhlasu

Preference může být produktová volba.

Právně relevantní souhlas musí být uložen jako DataProcessingConsent.

---

# 50. DataProcessingConsent

## 50.1 Význam

Auditovatelný souhlas s konkrétním účelem zpracování.

## 50.2 Obsah

* consentType,
* purpose,
* data categories,
* version,
* grantedAt,
* revokedAt,
* jurisdiction,
* source,
* scope,
* status.

## 50.3 Stav

* GRANTED,
* DENIED,
* REVOKED,
* EXPIRED,
* REQUIRES_RENEWAL,
* NOT_REQUIRED.

## 50.4 Příklady

* AI zpracování citlivých dat,
* marketing,
* research use,
* health integration,
* location tracking.

---

# 51. LegalAcceptance

## 51.1 Význam

Záznam přijetí právního dokumentu.

## 51.2 Typy

* TERMS_OF_SERVICE,
* PRIVACY_POLICY,
* HEALTH_DATA_NOTICE,
* AI_DISCLOSURE,
* COACHING_TERMS,
* MINOR_CONSENT,
* SUBSCRIPTION_TERMS.

## 51.3 Vlastnosti

* document version,
* acceptedAt,
* account,
* locale,
* method,
* IP nebo jiné údaje pouze podle právní potřeby.

---

# 52. Consent withdrawal

Odvolání souhlasu musí:

* zastavit příslušné budoucí zpracování,
* změnit dostupné funkce,
* případně odstranit nebo izolovat data podle policy,
* zachovat audit odvolání.

## 52.1 Příklad

Odvolání AI zpracování:

* workout tracker dál funguje,
* ruční plánování může fungovat,
* AI chat nad citlivými daty se deaktivuje.

---

# 53. OnboardingSession

## 53.1 Význam

Jedno absolvování nebo pokračování onboardingu.

## 53.2 Vlastnosti

* sessionId,
* profileId,
* stav,
* verze onboarding flow,
* začátek,
* poslední krok,
* dokončení,
* přeskočené kroky,
* odpovědi,
* zdroj.

## 53.3 Stav

* NOT_STARTED,
* IN_PROGRESS,
* PAUSED,
* COMPLETED,
* ABANDONED,
* SUPERSEDED.

## 53.4 Obnovitelnost

Onboarding musí být možné:

* přerušit,
* pokračovat na jiném zařízení,
* přeskočit nepovinnou část,
* později doplnit.

---

# 54. OnboardingStep

## 54.1 Typy kroků

* ACCOUNT_SETUP,
* BASIC_PROFILE,
* SPORT_SELECTION,
* CURRENT_ROUTINE,
* GOAL_DEFINITION,
* AVAILABILITY,
* EQUIPMENT,
* LIMITATIONS,
* PREFERENCES,
* NOTIFICATIONS,
* INTEGRATIONS,
* PLAN_PREVIEW,
* CONSENTS.

## 54.2 Povinnost

* REQUIRED,
* RECOMMENDED,
* OPTIONAL,
* CONDITIONAL.

## 54.3 Podmíněný krok

Například:

* pokud uživatel uvede bolest,
* zobrazí se bezpečnostní flow,
* ne běžný onboarding dotaz.

---

# 55. OnboardingAnswer

## 55.1 Význam

Jedna strukturovaná odpověď během onboardingu.

## 55.2 Obsah

* step,
* question code,
* value,
* timestamp,
* source,
* confidence,
* mapped domain objects,
* original text.

## 55.3 Přirozený jazyk

Uživatel může odpovědět:

> Hraju dvakrát týdně florbal a v neděli mám zápas.

AI nebo parser připraví:

* UserSport,
* participation pattern,
* recurring schedule proposal.

Uživatel musí vidět výsledek k potvrzení.

---

# 56. Adaptive onboarding

Onboarding nemusí být stejný pro každého.

Může se řídit:

* cílem,
* sportem,
* zkušeností,
* dostupností,
* omezením,
* platformou.

## 56.1 Omezení

Adaptivní onboarding nesmí skrýt:

* povinný právní souhlas,
* bezpečnostní upozornění,
* klíčovou nejasnost.

---

# 57. Progressive profiling

## 57.1 Význam

Profil se doplňuje postupně ve chvíli, kdy je údaj užitečný.

Příklad:

* lezeckou úroveň se systém zeptá až při lezeckém cíli,
* vybavení až při tvorbě silového workoutu,
* detailní spánek až při zapnutí recovery funkce.

## 57.2 Výhoda

Snižuje délku prvního onboardingu.

---

# 58. ProfileCompleteness

## 58.1 Význam

Odvozené hodnocení, zda má systém dostatek informací pro určitou funkci.

## 58.2 Není jedno globální procento

Úplnost musí být kontextová:

* planCreationCompleteness,
* recoveryCompleteness,
* goalCompleteness,
* safetyCompleteness,
* integrationCompleteness.

## 58.3 Stavy

* SUFFICIENT,
* SUFFICIENT_WITH_UNCERTAINTY,
* MISSING_RECOMMENDED_DATA,
* MISSING_REQUIRED_DATA,
* BLOCKED.

## 58.4 Příklad

Pro vytvoření základního domácího plánu může být profil dostatečný bez:

* výšky,
* hmotnosti,
* wearables.

---

# 59. ProfileCompletenessItem

Obsahuje:

* požadovaný údaj,
* důvod,
* povinnost,
* ovlivněnou funkci,
* způsob doplnění,
* stav.

---

# 60. ProfileAttributeSource

Každý významný profilový údaj může mít zdroj:

* USER,
* AI_STRUCTURED,
* IMPORTED,
* INTEGRATION,
* COACH,
* GUARDIAN,
* SYSTEM_DERIVED,
* ADMINISTRATIVE.

## 60.1 AI_STRUCTURED

Uživatel poskytl údaj textem a AI ho převedla do struktury.

Neznamená to, že AI údaj vymyslela.

---

# 61. ProfileAttributeConfidence

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN,
* USER_CONFIRMED.

Použití například pro:

* odhad zkušenosti,
* odvozenou preferenci,
* interpretaci netradičního sportu.

---

# 62. ProfileAttributeValidity

Některé údaje mají časovou platnost.

Příklad:

* současná dostupnost,
* dočasně dostupné vybavení,
* aktuální pracovní režim.

Pole:

* validFrom,
* validUntil,
* reviewAt.

---

# 63. Preference precedence

Preference mohou existovat na více úrovních:

1. globální profil,
2. sport,
3. prostředí,
4. konkrétní plán,
5. konkrétní workout,
6. jednorázová změna.

Specifičtější platný kontext má přednost.

---

# 64. UserRole

## 64.1 Význam

Systémová role účtu.

## 64.2 Typy

* ATHLETE,
* COACH,
* GUARDIAN,
* ORGANIZATION_ADMIN,
* SUPPORT,
* SYSTEM_ADMIN.

## 64.3 Oprávnění

Role sama nestačí.

Konkrétní přístup musí být vyhodnocen proti:

* vlastnictví,
* vztahu,
* scope,
* souhlasu,
* stavu.

---

# 65. ProfileRole

## 65.1 Význam

Role konkrétního účtu vůči konkrétnímu AthleteProfile.

## 65.2 Typy

* OWNER,
* SUBJECT,
* COACH,
* ASSISTANT_COACH,
* GUARDIAN,
* VIEWER,
* MEDICAL_PROFESSIONAL v budoucnu,
* ORGANIZATION_MANAGER.

## 65.3 Příklad

U nezletilého profilu:

* dítě může být SUBJECT,
* rodič OWNER a GUARDIAN,
* trenér COACH.

---

# 66. CoachAthleteRelationship

## 66.1 Význam

Vztah mezi trenérem a sportovním profilem.

## 66.2 Vlastnosti

* relationshipId,
* coach account,
* athlete profile,
* stav,
* role,
* oprávnění,
* datum začátku,
* datum konce,
* pozvánka,
* souhlas sportovce,
* privacy scope,
* revocation policy.

## 66.3 Stav

* INVITED,
* PENDING_ACCEPTANCE,
* ACTIVE,
* PAUSED,
* REVOKED_BY_ATHLETE,
* REVOKED_BY_COACH,
* EXPIRED,
* ARCHIVED.

---

# 67. CoachPermissionScope

Možná oprávnění:

* VIEW_PROFILE,
* VIEW_SPORTS,
* VIEW_GOALS,
* VIEW_SCHEDULE,
* VIEW_ACTIVITIES,
* VIEW_METRICS,
* VIEW_RECOVERY_SUMMARY,
* VIEW_SENSITIVE_RECOVERY,
* CREATE_PLAN_PROPOSAL,
* MODIFY_PLAN,
* CREATE_WORKOUT,
* REVIEW_ACTIVITY,
* MESSAGE_ATHLETE,
* VIEW_LOCATION,
* MANAGE_INTEGRATIONS.

## 67.1 Výchozí pravidlo

Trenér nemá automaticky přístup ke:

* detailní bolesti,
* právním údajům,
* přihlašovacím údajům,
* kompletním trasám,
* citlivým AI konverzacím.

---

# 68. Coach proposal versus direct edit

Trenér může mít režim:

* návrhy vyžadující schválení sportovce,
* přímé změny v povoleném scope,
* společná správa.

To musí být explicitně nastaveno.

---

# 69. Coach access revocation

Sportovec musí mít možnost vztah ukončit.

Po ukončení:

* trenér ztratí budoucí přístup,
* audit zůstane,
* trenérem vytvořené workouty a plány mohou zůstat v historii,
* budoucí správa se zastaví.

---

# 70. GuardianRelationship

## 70.1 Význam

Právní nebo produktový vztah správce k profilu nezletilého.

## 70.2 Obsah

* guardian account,
* child profile,
* právní stav podle policy,
* oprávnění,
* souhlasy,
* datum,
* region.

## 70.3 Omezení

Přesná pravidla musí být přizpůsobena:

* věku,
* zemi,
* typu služby,
* charakteru zdravotních dat.

---

# 71. MinorProfile

Profil nezletilého může vyžadovat:

* omezené AI funkce,
* zvláštní souhlasy,
* omezené sdílení,
* zákaz některých tělesných cílů,
* rodičovskou kontrolu,
* bezpečnější notifikace.

## 71.1 Věková hranice

Nesmí být natvrdo univerzální pro celý svět.

Musí být konfigurovatelná podle jurisdikce.

---

# 72. ManagedProfile

## 72.1 Význam

Profil spravovaný jiným účtem.

Příklady:

* dítě,
* klient trenéra,
* člen týmu,
* rehabilitační klient v budoucnu.

## 72.2 První verze

Může zůstat pouze v doménovém návrhu a nebýt implementován.

---

# 73. Více profilů pod jedním účtem

Budoucí model může umožnit:

* vlastní profil,
* dětský profil,
* trenérské profily klientů.

Je třeba oddělit:

* aktuálně zvolený profil,
* oprávnění,
* data,
* notifikace,
* integrace.

---

# 74. ActiveProfileContext

## 74.1 Význam

Profil, se kterým uživatel právě pracuje.

## 74.2 Obsah

* accountId,
* profileId,
* role,
* session,
* selectedAt.

## 74.3 Bezpečnost

Každý backendový příkaz musí ověřit oprávnění nezávisle na klientském activeProfileId.

---

# 75. AnonymousAccount

## 75.1 Význam

Dočasný účet umožňující používat část aplikace bez plné registrace.

## 75.2 Možné funkce

* demo onboarding,
* lokální workout,
* jednoduchý plán,
* lokální historie,
* omezená AI podle produktu.

## 75.3 Omezení

Anonymní účet může mít omezeno:

* cloudovou synchronizaci,
* integrace,
* více zařízení,
* obnovu účtu,
* citlivá data.

---

# 76. Anonymous identity upgrade

## 76.1 Proces

Při registraci:

* anonymní Identity se propojí s ověřenou AuthenticationIdentity,
* data se zachovají,
* nevytvoří se druhý AthleteProfile,
* pending změny zůstanou.

## 76.2 Konflikt

Pokud se ověřený účet již používá, je potřeba bezpečný merge flow.

---

# 77. IdentityLink

## 77.1 Význam

Propojení další autentizační metody s existující Identity.

## 77.2 Příklad

Uživatel vytvořil účet přes Google a později přidá Apple.

## 77.3 Bezpečnost

Připojení musí vyžadovat:

* aktivní přihlášení,
* ověření nového poskytovatele,
* ochranu proti převzetí účtu.

---

# 78. Identity merge

## 78.1 Příklad

Uživatel omylem vytvořil dva účty:

* jeden přes e-mail,
* druhý přes Apple.

## 78.2 Merge musí řešit

* profily,
* aktivity,
* cíle,
* integrace,
* předplatné,
* zařízení,
* konfliktní údaje,
* právní souhlasy.

## 78.3 Stav

Vznikne ProfileMergeRequest nebo AccountMergeRequest.

Běžná AI tuto operaci nesmí provádět automaticky.

---

# 79. ProfileMergeRequest

## 79.1 Obsah

* source profile,
* target profile,
* ownership verification,
* data summary,
* conflicts,
* merge plan,
* approval,
* audit,
* state.

## 79.2 Stav

* DRAFT,
* VERIFYING,
* READY_FOR_REVIEW,
* APPROVED,
* EXECUTING,
* COMPLETED,
* FAILED,
* CANCELLED.

---

# 80. Preference history

Některé preference mohou mít historii kvůli interpretaci plánů.

Příklad:

* uživatel dříve preferoval 60minutové workouty,
* později maximálně 30 minut.

Historický plán se nemá přehodnocovat podle dnešní preference.

---

# 81. UserDevicePreference

Nastavení specifické pro zařízení:

* haptics,
* audio cues,
* local notifications,
* offline storage range,
* watch integration,
* biometric lock,
* download over cellular,
* theme.

Tyto preference nemusí být všechny synchronizovány globálně.

---

# 82. Globální versus lokální preference

## Globální

* jednotky,
* jazyk AI,
* coaching style,
* profile privacy.

## Lokální

* hlasitost,
* biometrický zámek,
* mobilní data,
* konkrétní notifikační oprávnění platformy.

## Hybridní

* notifikační preference globální,
* skutečné platformní permission lokální.

---

# 83. Notification permission state

Musí být odděleno:

* uživatel chce notifikaci,
* systémové oprávnění je uděleno.

Možné stavy platformy:

* NOT_REQUESTED,
* GRANTED,
* DENIED,
* PROVISIONAL,
* DISABLED_IN_SETTINGS,
* UNKNOWN.

---

# 84. Location permission state

Podobně:

* produktová preference,
* platformní oprávnění,
* přesnost polohy,
* background access,

jsou oddělené stavy.

---

# 85. Profile verification

Některé údaje mohou být:

* unverified,
* user-confirmed,
* provider-verified,
* coach-entered,
* guardian-confirmed.

Běžné sportovní plánování nemá vyžadovat formální ověření identity, pokud to není nutné.

---

# 86. ProfileConflict

## 86.1 Význam

Konflikt mezi dvěma zdroji profilového údaje.

## 86.2 Příklad

* uživatel zadá hmotnost 80 kg,
* chytrá váha importuje 82 kg.

To nemusí být konflikt, pokud jde o různé časy.

Konflikt vzniká spíše při:

* stejné časové platnosti,
* neslučitelném stavu,
* změně na více zařízeních.

---

# 87. Profile source priority

Výchozí principy:

* explicitní uživatelská oprava má vysokou prioritu,
* odborné omezení má prioritu v bezpečnostním kontextu,
* externí import nepřepisuje ruční hodnotu bez pravidla,
* AI odhad má nižší prioritu než potvrzený údaj.

---

# 88. User preference learning

Systém může odvozovat preference z chování.

Příklad:

* uživatel opakovaně zkracuje ranní workouty,
* systém navrhne nastavit ranní maximum 15 minut.

## 88.1 Pravidlo

Odvozená preference:

* musí mít zdroj SYSTEM_DERIVED,
* jistotu,
* návrh k potvrzení,
* nesmí neviditelně měnit profil.

---

# 89. AI profile interpretation

## 89.1 Příklad vstupu

> Ve všední dny mám ráno deset minut, večer většinou hodinu, ale ve středu mám florbal.

AI může strukturovat:

* ranní AvailabilityWindow,
* večerní AvailabilityWindow,
* středeční pevný sport.

## 89.2 Potvrzení

Uživatel musí vidět, co bylo pochopeno.

---

# 90. AI profile summary

AI může používat bezpečný strukturovaný souhrn:

* aktivní sporty,
* hlavní cíle,
* aktuální dostupnost,
* vybavení,
* důležité preference,
* aktivní omezení,
* relevantní jednotky.

Nemusí dostat:

* právní historii,
* všechny souhlasy,
* přihlašovací identity,
* tokeny,
* nesouvisející citlivá data.

---

# 91. AI profile update

AI nesmí přímo měnit AthleteProfile textovou odpovědí.

Tok:

1. rozpoznat nový profilový údaj,
2. vytvořit návrh,
3. porovnat se současným profilem,
4. zobrazit dopad,
5. potvrdit podle významu,
6. aplikovat ChangeSet,
7. vytvořit revision podle potřeby.

---

# 92. Profile and planning

Plánovací engine používá zejména:

* UserSport,
* Goal,
* AvailabilityProfile,
* EquipmentProfile,
* TrainingEnvironment,
* TrainingPreference,
* aktuální omezení,
* CurrentTrainingState.

Ne každý profilový údaj musí vstupovat do plánování.

---

# 93. Profile snapshot for TrainingPlanVersion

Při vytvoření plánu je vhodné uložit referenci nebo snapshot klíčových profilových vstupů:

* sporty,
* cíle,
* dostupnost,
* vybavení,
* preference,
* omezení,
* zkušenost.

Tím je později vysvětlitelné, proč plán vypadal určitým způsobem.

---

# 94. Profile and historical activity

Změna sportovního profilu nesmí zpětně měnit:

* sport aktivity,
* tehdejší jednotky uložené v provenance,
* tehdejší plán,
* tehdejší profilový snapshot.

---

# 95. Profile review

## 95.1 Význam

Pravidelná kontrola, zda profil stále odpovídá realitě.

## 95.2 Spouštěče

* několik měsíců od poslední kontroly,
* změna cíle,
* dlouhodobé odchylky,
* změna rozvrhu,
* návrat po pauze,
* změna sezony,
* opakované úpravy workoutů.

## 95.3 Výsledek

* potvrzen beze změny,
* aktualizovaná dostupnost,
* změněné preference,
* aktualizovaná zkušenost,
* odstraněné zastaralé vybavení.

---

# 96. ProfileReview

Obsahuje:

* reviewedAt,
* reviewedSections,
* changes,
* confirmedFields,
* nextReviewAt,
* actor.

---

# 97. Dormant user

Pokud uživatel dlouho aplikaci nepoužíval, systém nemá automaticky předpokládat, že:

* stále trénuje stejně,
* má stejnou kapacitu,
* chce pokračovat v plánu.

Může spustit návratový onboarding:

* co se změnilo,
* jak dlouhá byla pauza,
* aktuální cíle,
* aktuální dostupnost.

---

# 98. ReturningUserAssessment

Obsahuje:

* délku neaktivity,
* poslední známý stav,
* aktuální subjektivní kapacitu,
* změny sportů,
* změny omezení,
* potřebu nového plánu.

---

# 99. Account security preferences

Může obsahovat:

* biometricLock,
* requireRecentLoginForSensitiveChanges,
* activeSessionsVisibility,
* loginAlerts,
* trustedDevices.

Technické autentizační detaily budou popsány v security dokumentaci.

---

# 100. Session management

Uživatel musí mít možnost:

* zobrazit aktivní zařízení,
* odhlásit jiné zařízení,
* označit ztracené zařízení,
* změnit heslo nebo passkey,
* obnovit účet.

---

# 101. Account recovery

Musí podporovat bezpečnou obnovu bez toho, aby support nebo AI mohly obejít autentizaci.

Možnosti:

* ověřený e-mail,
* passkey,
* provider recovery,
* recovery codes v budoucnu.

---

# 102. AccountDeletionRequest

## 102.1 Význam

Auditovaný požadavek na smazání účtu.

## 102.2 Stav

* REQUESTED,
* CONFIRMATION_REQUIRED,
* COOLING_OFF,
* PROCESSING,
* PARTIALLY_COMPLETED,
* COMPLETED,
* CANCELLED,
* FAILED.

## 102.3 Obsah

* account,
* requestedAt,
* confirmation,
* scope,
* retention exceptions,
* connected integrations,
* devices,
* completion report.

---

# 103. Smazání účtu

Proces musí řešit:

* identity,
* profily,
* sporty,
* cíle,
* aktivity,
* metriky,
* AI data,
* integrace,
* externí tokeny,
* zařízení,
* audit,
* zákonné retenční výjimky.

## 103.1 Offline zařízení

Po připojení musí obdržet stav zrušeného účtu a lokální data bezpečně odstranit.

---

# 104. Profile deletion

Pokud bude existovat více profilů, lze smazat jeden AthleteProfile bez smazání celého účtu.

Musí být posouzeno:

* vlastnictví,
* spravující vztahy,
* předplatné,
* sdílené integrace,
* export.

---

# 105. DataExportRequest

## 105.1 Význam

Požadavek na export osobních dat.

## 105.2 Obsah

* account,
* profile scope,
* data categories,
* format,
* requestedAt,
* status,
* secure download,
* expiration.

## 105.3 Kategorie

* profile,
* sports,
* goals,
* plans,
* workouts,
* activities,
* metrics,
* AI conversations,
* change history,
* integrations,
* consents.

---

# 106. Data portability

Export má být:

* strojově čitelný,
* s jednotkami,
* s časem,
* s původem,
* s vysvětlením odvozených hodnot.

Citlivé tokeny se neexportují.

---

# 107. Profile visibility

I bez sociální sítě může být připraven model:

* PRIVATE,
* COACH_ONLY,
* SHARED_WITH_SELECTED,
* ORGANIZATION,
* PUBLIC v budoucnu.

Výchozí stav:

* PRIVATE.

---

# 108. Activity visibility defaults

Budoucí sdílení aktivit musí mít vlastní nastavení.

Profilová viditelnost nesmí automaticky zveřejnit:

* všechny aktivity,
* GPS trasu,
* bolest,
* recovery data.

---

# 109. Subscription profile context

Budoucí předplatné může být navázáno na:

* účet,
* profil,
* trenérský workspace,
* organizaci.

Nemá být součástí AthleteProfile jako sportovní vlastnost.

---

# 110. Organization membership

Budoucí model může podporovat:

* klub,
* tým,
* firmu,
* trenérskou organizaci.

Musí být odděleno:

* členství,
* role,
* vlastnictví dat,
* přístup,
* odchod z organizace.

---

# 111. TeamProfile relationship

Týmová účast nesmí znamenat, že tým vlastní celý osobní profil.

Tým může mít přístup pouze k:

* týmovým událostem,
* docházce,
* vybraným sportovním informacím,
* explicitně sdíleným datům.

---

# 112. Audit profilových změn

Významné změny musí mít AuditRecord:

* kdo změnil,
* co,
* kdy,
* odkud,
* důvod,
* potvrzení,
* původní a nový stav.

---

# 113. Produktová historie profilu

Uživatel může vidět například:

> 21. července 2026: Večerní dostupnost v úterý změněna na 18:00–20:00.

Nemusí vidět technické ID nebo interní diff.

---

# 114. Profile data sensitivity

Možné úrovně:

* BASIC,
* PERSONAL,
* SENSITIVE,
* HEALTH_RELATED,
* LEGAL,
* AUTHENTICATION,
* LOCATION_RELATED.

## 114.1 Příklady

BASIC:

* preferovaný jazyk.

PERSONAL:

* jméno,
* sportovní preference.

HEALTH_RELATED:

* omezení,
* bolest,
* hmotnost.

AUTHENTICATION:

* přihlašovací identity.

---

# 115. Analytics separation

Běžná produktová analytika může obsahovat:

* onboarding_started,
* onboarding_completed,
* profile_section_updated,
* unit_preference_changed.

Nesmí obsahovat:

* konkrétní hmotnost,
* obsah omezení,
* datum narození,
* jméno,
* soukromé sportovní cíle,
* přesný týdenní rozvrh.

---

# 116. ProfileSummaryForAI

Bezpečný AI read model může obsahovat:

* zobrazované jméno,
* jazyk,
* aktivní sporty,
* cíle,
* obecnou zkušenost,
* dostupnost,
* vybavení,
* preference,
* aktivní bezpečnostní omezení,
* jednotky,
* časové pásmo.

Musí respektovat:

* účel,
* souhlas,
* citlivost,
* aktuálnost.

---

# 117. Offline profil

Offline musí být dostupné minimálně:

* základní AthleteProfile,
* aktivní sporty,
* hlavní cíle,
* vybavení relevantní pro aktivní plán,
* preference,
* jednotky,
* časové pásmo,
* aktivní omezení.

---

# 118. Offline profilová změna

Lze offline změnit například:

* preference,
* dostupnost,
* vybavení,
* jednotky,
* zobrazované jméno.

Serverově citlivější změny mohou vyžadovat revalidaci:

* hlavní profilová role,
* právní souhlas,
* datum narození nezletilého,
* vlastnictví profilu,
* trenérské vztahy.

---

# 119. Synchronizace profilu

Každá profilová sekce může mít:

* vlastní verzi,
* vlastní merge policy,
* vlastní sensitivity.

To může být vhodnější než jedna obří verze celého profilu.

---

# 120. ProfileSection

Možné sekce:

* PERSONAL_DETAILS,
* BODY_PROFILE,
* TRAINING_BACKGROUND,
* AVAILABILITY,
* EQUIPMENT,
* TRAINING_PREFERENCES,
* UNITS_AND_LOCALE,
* NOTIFICATIONS,
* AI_PREFERENCES,
* PRIVACY,
* ACCESSIBILITY.

---

# 121. Profilový konflikt mezi zařízeními

Příklad:

Telefon:

* maximální večerní workout 30 minut.

Tablet:

* maximální večerní workout 60 minut.

Výsledek:

* FIELD_CONFLICT,
* uživatel zvolí hodnotu,
* nebo nastaví rozsah podle dne.

---

# 122. Automaticky slučitelné profilové změny

Příklad:

Telefon:

* změna jednotek.

Tablet:

* přidání hrazdy.

Tyto změny lze sloučit.

---

# 123. Doménové služby

## 123.1 IdentityService

Spravuje:

* interní identity,
* připojené autentizační identity,
* merge,
* bezpečnostní stav.

## 123.2 AccountService

Spravuje:

* účet,
* stav,
* deletion,
* export,
* role.

## 123.3 AthleteProfileService

Spravuje:

* sportovní profil,
* revize,
* profilové sekce,
* validaci.

## 123.4 OnboardingService

Spravuje:

* onboarding sessions,
* kroky,
* odpovědi,
* progresivní doplňování.

## 123.5 ProfileCompletenessService

Vyhodnocuje připravenost profilu pro funkce.

## 123.6 PreferenceService

Spravuje:

* preference,
* precedence,
* časovou platnost.

## 123.7 ConsentService

Spravuje:

* právní souhlasy,
* odvolání,
* verze dokumentů.

## 123.8 RelationshipService

Spravuje:

* coach-athlete,
* guardian,
* profile roles,
* přístupy.

## 123.9 ProfileMergeService

Řeší bezpečné spojování profilů nebo účtů.

## 123.10 ProfileExportService

Připravuje bezpečný export.

---

# 124. Doménové události

Minimálně:

* IdentityCreated
* AuthenticationIdentityLinked
* AuthenticationIdentityUnlinked
* IdentityVerified
* IdentityLocked
* IdentityMerged
* UserAccountCreated
* UserAccountActivated
* UserAccountSuspended
* UserAccountDeletionRequested
* UserAccountDeleted
* AthleteProfileCreated
* AthleteProfileActivated
* AthleteProfileUpdated
* AthleteProfileRevisionCreated
* AthleteProfilePaused
* AthleteProfileArchived
* ProfileSectionUpdated
* ProfileCompletenessChanged
* TrainingBackgroundUpdated
* AvailabilityProfileUpdated
* EquipmentAdded
* EquipmentRemoved
* TrainingPreferenceUpdated
* UnitPreferenceChanged
* LocalePreferenceChanged
* TimeZonePreferenceChanged
* AccessibilityPreferenceChanged
* NotificationPreferenceChanged
* AIInteractionPreferenceChanged
* PrivacyPreferenceChanged
* DataProcessingConsentGranted
* DataProcessingConsentRevoked
* LegalDocumentAccepted
* OnboardingStarted
* OnboardingStepCompleted
* OnboardingPaused
* OnboardingCompleted
* ProfileReviewRequested
* ProfileReviewCompleted
* CoachInvitationCreated
* CoachAthleteRelationshipActivated
* CoachPermissionChanged
* CoachAthleteRelationshipRevoked
* GuardianRelationshipCreated
* ManagedProfileCreated
* ActiveProfileChanged
* AnonymousAccountUpgraded
* ProfileMergeRequested
* ProfileMergeCompleted
* DataExportRequested
* DataExportCompleted

---

# 125. Příkazy

Minimálně:

* CreateIdentity
* LinkAuthenticationIdentity
* UnlinkAuthenticationIdentity
* VerifyIdentity
* LockIdentity
* MergeIdentity
* CreateUserAccount
* ActivateUserAccount
* SuspendUserAccount
* RequestAccountDeletion
* CancelAccountDeletion
* DeleteUserAccount
* CreateAthleteProfile
* UpdateAthleteProfile
* UpdateProfileSection
* PauseAthleteProfile
* ArchiveAthleteProfile
* ReviewAthleteProfile
* UpdateTrainingBackground
* UpdateAvailabilityProfile
* AddEquipment
* RemoveEquipment
* UpdateTrainingPreference
* UpdateUnitPreference
* UpdateLocalePreference
* UpdateTimeZonePreference
* UpdateAccessibilityPreference
* UpdateNotificationPreference
* UpdateAIInteractionPreference
* UpdatePrivacyPreference
* GrantDataProcessingConsent
* RevokeDataProcessingConsent
* AcceptLegalDocument
* StartOnboarding
* CompleteOnboardingStep
* PauseOnboarding
* CompleteOnboarding
* InviteCoach
* AcceptCoachInvitation
* UpdateCoachPermission
* RevokeCoachRelationship
* CreateGuardianRelationship
* CreateManagedProfile
* SelectActiveProfile
* UpgradeAnonymousAccount
* RequestProfileMerge
* ApproveProfileMerge
* ExecuteProfileMerge
* RequestDataExport

---

# 126. Invariance – identita

* Identity musí mít jedinečný interní identifikátor.
* Jedna externí provider identity nesmí být současně aktivně připojena ke dvěma interním identitám bez merge procesu.
* Odpojení poslední autentizační metody nesmí znepřístupnit účet bez bezpečné alternativy.
* AI nesmí měnit autentizační identitu.

---

# 127. Invariance – účet

* UserAccount patří právě jedné interní Identity.
* Smazaný účet nesmí vytvářet nové doménové změny.
* Suspended účet nesmí obcházet omezení přes offline synchronizaci.
* Stav účtu se nesmí měnit pouze klientským UI.

---

# 128. Invariance – profil

* AthleteProfile musí mít vlastníka nebo platný spravující vztah.
* Aktivní Self profil musí patřit správnému účtu.
* Profil nesmí odkazovat na sporty nebo cíle jiného profilu.
* Významná změna musí být auditovaná.
* Archivace profilu nesmí odstranit historii.

---

# 129. Invariance – osobní údaje

* Věk se odvozuje z data nebo roku narození.
* Budoucí datum narození je neplatné.
* Přesné datum narození se nemá vyžadovat, pokud postačuje méně přesný údaj.
* Právní jméno se nesmí používat jako běžné zobrazované jméno bez volby uživatele.

---

# 130. Invariance – preference

* Preference musí mít definovaný scope.
* Specifická preference může přepsat obecnou pouze ve svém kontextu.
* Odvozená preference nesmí bez potvrzení nahradit explicitní preference uživatele.
* Preference nesmí obejít safety pravidlo.

---

# 131. Invariance – dostupnost

* Časové okno musí mít konec po začátku.
* Časové pásmo musí být platné.
* TypicalWeekProfile nesmí přepsat konkrétní ScheduleEvent.
* Dostupnost není automaticky potvrzený workout.

---

# 132. Invariance – vybavení

* EquipmentProfile musí patřit stejnému profilu.
* Nedostupné vybavení nesmí být použito v automaticky vytvořeném workoutu.
* Dočasná dostupnost po skončení expiruje.
* AI odhad vybavení musí být potvrzen.

---

# 133. Invariance – jednotky a lokalizace

* Změna jednotek nesmí změnit kanonické uložené hodnoty.
* Locale nesmí měnit význam interních kódů.
* Změna časového pásma musí zachovat absolutní historické časy.
* Uživatelský vstup musí být bezpečně převeden do kanonické jednotky.

---

# 134. Invariance – onboarding

* Onboarding nesmí vytvářet aktivní nebezpečný plán bez validace.
* Nepovinný krok lze přeskočit.
* Povinný právní souhlas nelze označit jako dokončený bez skutečného přijetí.
* AI strukturovaná odpověď musí zachovat původní text a potvrzení.

---

# 135. Invariance – souhlasy

* Souhlas musí odkazovat na konkrétní účel a verzi.
* Odvolaný souhlas nesmí být považován za aktivní.
* Nová verze právního dokumentu může vyžadovat nové přijetí.
* AI nesmí udělit souhlas za uživatele.

---

# 136. Invariance – vztahy

* Trenér nesmí získat přístup bez aktivního vztahu a odpovídajícího scope.
* Odvolaný vztah musí okamžitě zastavit budoucí přístup.
* GuardianRelationship musí respektovat jurisdikční pravidla.
* Vlastnictví profilu se nesmí změnit běžnou profilovou editací.

---

# 137. Invariance – nezletilí

* Funkce vyžadující souhlas dospělého se nesmí aktivovat bez něj.
* Věk nesmí být AI pouze odhadnut z konverzace.
* Citlivé cíle musí mít přísnější pravidla.
* Trenér nemá automaticky plný přístup k profilu dítěte.

---

# 138. Invariance – anonymní účet

* Upgrade nesmí ztratit lokální data.
* Anonymní a registrovaný účet se nesmí duplikovat při retry.
* Anonymní účet nesmí získat funkce vyžadující ověřenou identitu bez ověření.
* Smazání aplikace může znamenat ztrátu anonymního účtu, pokud nemá recovery mechanismus; uživatel na to musí být upozorněn.

---

# 139. Invariance – AI

* AI nesmí vymýšlet profilové údaje.
* AI odvozený údaj musí mít zdroj a jistotu.
* AI nesmí změnit hlavní cíl, vlastnictví, souhlas nebo právní stav bez odpovídajícího flow.
* AI má používat pouze minimální potřebný profilový kontext.
* Citlivý kontext se nesmí použít mimo povolený účel.

---

# 140. Invariance – export a smazání

* Export nesmí obsahovat přístupové tokeny.
* Smazání musí respektovat zákonné retenční výjimky.
* Účet v deletion procesu nesmí být neviditelně znovu aktivován.
* Offline zařízení nesmí po smazání účtu znovu nahrát stará data.

---

# 141. Read modely

## 141.1 AccountOverview

Obsahuje:

* stav účtu,
* přihlašovací metody,
* aktivní zařízení,
* bezpečnostní upozornění,
* deletion stav.

## 141.2 AthleteProfileOverview

Obsahuje:

* jméno,
* aktivní sporty,
* hlavní cíle,
* aktuální plán,
* základní preference,
* profilovou úplnost.

## 141.3 ProfileEditView

Obsahuje profil po sekcích:

* osobní údaje,
* sporty,
* cíle,
* dostupnost,
* vybavení,
* preference,
* jednotky,
* privacy.

## 141.4 OnboardingProgressView

Obsahuje:

* dokončené kroky,
* další doporučený krok,
* přeskočené části,
* připravenost k vytvoření plánu.

## 141.5 AvailabilityProfileView

Obsahuje:

* typický týden,
* časová okna,
* pevné sporty,
* flexibilitu.

## 141.6 EquipmentProfileView

Obsahuje:

* vybavení,
* umístění,
* dostupnost,
* omezení.

## 141.7 PreferencesOverview

Obsahuje:

* workout preference,
* AI styl,
* jednotky,
* jazyk,
* notifikace,
* accessibility.

## 141.8 PrivacyAndConsentView

Obsahuje:

* aktivní souhlasy,
* privacy preference,
* AI processing,
* integrace,
* možnosti odvolání.

## 141.9 CoachRelationshipView

Obsahuje:

* trenéra,
* stav,
* oprávnění,
* poslední změny,
* možnost revokace.

## 141.10 ProfileCompletenessView

Obsahuje:

* funkce, pro které je profil dostatečný,
* chybějící doporučené údaje,
* důvod doplnění.

---

# 142. Příklad – nový fotbalista

## Vstup

Uživatel uvede:

* fotbal třikrát týdně,
* nedělní zápas,
* doma hrazda,
* chce posílit horní část těla,
* večer 30–45 minut.

## Vzniklé objekty

* AthleteProfile,
* UserSport: football,
* Goal: upper body strength,
* EquipmentProfile: pull-up bar,
* AvailabilityProfile,
* TrainingPreference.

## Nevyžadované údaje

Pro první plán nemusí být nutná:

* hmotnost,
* výška,
* wearable,
* přesná tepová data.

---

# 143. Příklad – florbalista a lezec

## Profil

* florbal pondělí a středa,
* zápas v neděli,
* lezení nepravidelně,
* ráno 15 minut,
* večer 45 minut,
* bez domácího vybavení.

## Preference

* krátké ranní mobility,
* delší silové workouty přes den,
* dva workouty za den jsou povoleny.

Model musí zachovat:

* sportovní priority,
* typický týden,
* prostředí,
* maximální frekvenci.

---

# 144. Příklad – nejasná zkušenost

Uživatel řekne:

> Cvičím už dlouho, ale poslední rok skoro vůbec.

Model může uložit:

* historicalExperience: ADVANCED nebo dlouhodobá,
* currentTrainingState: RETURNING,
* currentCapacityConfidence: LOW/MEDIUM.

Nemá jej automaticky plánovat jako aktuálně pokročilého ve vysokém objemu.

---

# 145. Příklad – změna rozvrhu

Uživatel řekne:

> Od příštího měsíce budu ve středu pracovat večer.

Výsledek:

* AvailabilityProfile revision s validFrom,
* kontrola budoucích ScheduleEvent,
* návrh změny plánu,
* historické středy se nemění.

---

# 146. Příklad – dočasné vybavení

Uživatel je dva týdny na cestě a má:

* pouze odporovou gumu,
* hotelový pokoj,
* málo prostoru.

Vznikne:

* dočasný TrainingEnvironment,
* EquipmentAvailability s validUntil,
* plánovací adaptace.

Po návratu se obnoví běžný profil.

---

# 147. Příklad – jednotky

Uživatel změní:

* kilogramy na libry,
* kilometry na míle.

Historické MetricValue se nepřepočítávají destruktivně.

Změní se pouze zobrazování a vstup.

---

# 148. Příklad – anonymní onboarding

Uživatel bez registrace:

* vyplní sporty,
* vytvoří základní plán,
* dokončí dva workouty.

Při registraci:

* anonymní Identity se upgraduje,
* WorkoutSession a Activity zůstanou,
* nevznikne druhý profil.

---

# 149. Příklad – trenérská pozvánka

Trenér pošle pozvánku.

Sportovec schválí:

* přístup k plánu,
* aktivitám,
* cílům,
* bez detailní bolesti a GPS tras.

CoachAthleteRelationship obsahuje přesný scope.

---

# 150. Příklad – odvolání trenéra

Sportovec ukončí vztah.

Výsledek:

* nový přístup trenéra je odmítnut,
* historické trenérské změny zůstávají v auditu,
* plán vytvořený trenérem zůstává sportovci,
* trenér již nemůže upravovat další týdny.

---

# 151. Příklad – AI odvozená preference

Uživatel šestkrát zkrátí ranní workout na deset minut.

AI navrhne:

> Mám nastavit ranní workouty na maximálně 10–15 minut?

Teprve po potvrzení se změní TrainingPreference.

---

# 152. Příklad – návrat po delší pauze

Uživatel se přihlásí po šesti měsících.

Aplikace se zeptá:

* změnily se sporty,
* změnil se rozvrh,
* jaká je aktuální kondice,
* existují nová omezení.

Původní profil se nepovažuje automaticky za aktuální.

---

# 153. Příklad – odvolání AI souhlasu

Uživatel zakáže AI zpracování citlivých dat.

Výsledek:

* AI stále může pracovat s necitlivým profilem podle preference,
* detail bolesti se neposílá modelu,
* deterministický safety engine zůstává funkční,
* aplikace vysvětlí omezené funkce.

---

# 154. Příklad – konflikt profilu

Telefon:

* úterý dostupnost do 20:00.

Tablet:

* úterý nedostupné.

Systém vytvoří ProfileConflict.

Uživatel zvolí správnou variantu nebo nastaví platnost podle období.

---

# 155. Co musí být strukturované

Nesmí zůstat pouze jako volný text:

* identity,
* účet,
* autentizační metoda,
* stav účtu,
* AthleteProfile,
* profilová role,
* sporty,
* zkušenost,
* dostupnost,
* vybavení,
* preference,
* jednotky,
* locale,
* timezone,
* souhlas,
* oprávnění trenéra,
* onboarding krok,
* profilová revize,
* deletion stav,
* export stav.

Volný text může doplňovat:

* osobní poznámku,
* vysvětlení preference,
* vlastní název prostředí,
* původní onboarding odpověď,
* důvod změny.

---

# 156. Otevřené otázky

* Bude první verze vyžadovat registraci před použitím?
* Má být podporován anonymní účet?
* Které přihlašovací metody budou v první verzi?
* Budou použity passkeys?
* Jak bude řešena obnova účtu?
* Lze bezpečně odpojit poslední autentizační metodu?
* Jak se budou slučovat duplicitní účty?
* Které profilové údaje budou povinné?
* Je nutné přesné datum narození?
* Jak přesně řešit nezletilé podle regionu?
* Bude první verze dostupná nezletilým?
* Jaké funkce budou pro nezletilé omezené?
* Jak ukládat genderový nebo fyziologický kontext?
* Bude body weight součástí základního onboardingu?
* Jaké věkové kategorie používat?
* Jak podrobně ukládat sportovní zkušenost?
* Jak rozlišit historickou zkušenost a aktuální kapacitu?
* Jak odvozovat profilovou úplnost?
* Které údaje jsou nutné pro první plán?
* Jak dlouhý má být onboarding?
* Které otázky pokládat až progresivně?
* Jak zobrazit AI strukturované odpovědi k potvrzení?
* Jaké preference mohou být odvozené automaticky?
* Jak často má probíhat profile review?
* Jak zachytit sezónní změnu dostupnosti?
* Jak modelovat pracovní směny?
* Jak modelovat nepravidelný rozvrh?
* Jak propojit AvailabilityProfile s externími kalendáři?
* Jaké EquipmentDefinition budou systémové?
* Jak řešit vlastní vybavení?
* Jak přesně mapovat prostředí na omezení cviků?
* Má být TrainingEnvironment samostatný agregát?
* Jaké jednotky budou podporovány?
* Jak řešit smíšený systém jednotek?
* Jak určit výchozí first day of week?
* Jak přesně pracovat s cestováním a timezone?
* Jaké notifikace budou zapnuté ve výchozím stavu?
* Jak zabránit zahlcení notifikacemi?
* Jaké AI styly nabídnout uživateli?
* Má AI preference ovlivnit pouze text, nebo i proaktivitu?
* Jak přesně ukládat AI memory preference?
* Které profilové údaje smí AI číst?
* Jak oddělit AI souhlas od běžné personalizace?
* Jak přesně implementovat právní souhlasy?
* Kdy vyžadovat nové přijetí dokumentu?
* Jak řešit souhlas se zdravotními daty?
* Jak dlouho uchovávat historii souhlasů?
* Bude v první verzi trenérský vztah?
* Může trenér přímo měnit plán?
* Které údaje trenér uvidí?
* Může sportovec schvalovat každou změnu trenéra?
* Jak řešit trenéra a AI současně?
* Kdo má prioritu při konfliktní změně plánu?
* Jak funguje vlastnictví plánu vytvořeného trenérem?
* Jak řešit organizace a týmy?
* Jak řešit více AthleteProfile pod účtem?
* Jak přepínat aktivní profil?
* Jak zabránit změně dat nesprávného profilu?
* Jak řešit předplatné u spravovaných profilů?
* Jak proběhne merge profilů?
* Jak řešit konfliktní aktivity při merge?
* Jak řešit integrace při merge účtů?
* Jak exportovat kompletní profil?
* Jak dlouho bude export dostupný?
* Jak zabezpečit stažení exportu?
* Jak probíhá smazání účtu při offline zařízení?
* Jak řešit zákonné retenční výjimky?
* Jak zabránit opětovnému nahrání dat po smazání?
* Jaká profilová data budou lokálně šifrovaná?
* Jaké preference jsou globální a jaké device-specific?
* Jak synchronizovat platformní permission state?
* Jak zobrazit stav částečně dokončeného profilu?
* Jak pracovat s uživatelem, který odmítne uvést citlivé údaje?
* Jak vytvořit kvalitní plán s minimem údajů?
* Jak komunikovat nejistotu bez zahlcení?
* Jak auditovat profilové změny vytvořené AI?
* Jak oddělit profilovou historii od produktové analytiky?
* Jak testovat různé jurisdikce?
* Jak testovat multi-profile a coach permissions?
* Jaké funkce musí vyžadovat reautentizaci?
* Jak řešit kompromitovaný účet?
* Jak řešit změnu primárního e-mailu?
* Jak komunikovat připojení více login providerů?
* Jaký identity provider nebo službu použít?
* Má být identity doména interní, nebo externě spravovaná?
* Jak navrhnout migraci identity provideru v budoucnu?

---

# 157. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/07-backend/
├── identity-service.md
├── account-service.md
├── profile-service.md
├── onboarding-service.md
├── consent-service.md
├── relationship-service.md
├── profile-export-service.md
├── profile-deletion-service.md
└── identity-api.md
```

Dále:

```text
docs/08-mobile/
├── authentication-flow.md
├── onboarding-flow.md
├── profile-management.md
├── preferences-storage.md
├── account-settings.md
├── coach-relationship-ui.md
├── consent-ui.md
├── account-deletion-ui.md
└── profile-offline-storage.md
```

Dále:

```text
docs/09-security/
├── authentication-security.md
├── authorization-model.md
├── account-recovery.md
├── consent-and-privacy.md
├── minor-user-protection.md
├── profile-data-security.md
└── account-deletion.md
```

A:

```text
docs/10-quality/
├── identity-testing.md
├── authorization-testing.md
├── onboarding-testing.md
├── consent-testing.md
├── multi-profile-testing.md
└── account-deletion-testing.md
```

---

# 158. Kritéria správného modelu

Model je vhodný pouze tehdy, pokud umožní:

1. vytvořit interní identitu,
2. připojit více autentizačních metod,
3. oddělit identitu a sportovní profil,
4. vytvořit AthleteProfile,
5. používat aplikaci s neúplným profilem,
6. postupně doplňovat profil,
7. vytvořit personalizovaný onboarding,
8. onboarding přerušit a obnovit,
9. strukturovat přirozený uživatelský vstup,
10. potvrdit AI interpretaci profilu,
11. uložit sportovní zkušenost,
12. odlišit historickou zkušenost a aktuální kapacitu,
13. uložit typický týden,
14. uložit dostupná časová okna,
15. uložit tréninkové preference,
16. uložit prostředí,
17. uložit vybavení,
18. řešit dočasné vybavení,
19. podporovat cestování,
20. podporovat jednotky,
21. podporovat lokalizaci,
22. podporovat časová pásma,
23. podporovat accessibility preference,
24. podporovat notifikační preference,
25. podporovat AI preference,
26. podporovat privacy preference,
27. auditovat právní souhlasy,
28. odvolat souhlas,
29. omezit funkce po odvolání souhlasu,
30. fungovat offline,
31. synchronizovat profil mezi zařízeními,
32. detekovat konflikt,
33. bezpečně slučovat nekolidující změny,
34. zachovat profilovou historii,
35. uložit snapshot vstupů plánu,
36. podporovat anonymní účet,
37. upgradovat anonymní účet bez ztráty dat,
38. připojit další login provider,
39. slučovat duplicitní identity,
40. podporovat budoucí víceprofilový účet,
41. podporovat vztah trenér–sportovec,
42. omezit trenérova oprávnění,
43. odvolat trenérský vztah,
44. podporovat budoucí guardian relationship,
45. chránit nezletilé uživatele,
46. exportovat profilová data,
47. požádat o smazání účtu,
48. bezpečně smazat lokální data,
49. zabránit opětovné synchronizaci smazaných dat,
50. přidávat budoucí role bez přepsání základního modelu.

---

# 159. Závěr

Identity and Profile model určuje, kdo aplikaci používá, pro koho se plánuje a jaké informace smí systém použít při personalizaci.

Jeho základní vztah je:

```text
Identity
    ↓
AuthenticationIdentity
    ↓
UserAccount
    ↓
AthleteProfile
    ↓
UserSport / Goal / Availability / Equipment / Preference
```

Onboardingový tok je:

```text
UserAccount
    ↓
OnboardingSession
    ↓
OnboardingAnswer
    ↓
Strukturované profilové návrhy
    ↓
Potvrzení
    ↓
AthleteProfileRevision
    ↓
ProfileCompleteness
    ↓
TrainingPlan Proposal
```

Budoucí vztahový model je:

```text
UserAccount
    ↓
ProfileRole
    ↓
AthleteProfile
    ↑
CoachAthleteRelationship / GuardianRelationship
```

Souhlasový tok je:

```text
Produktová funkce
    ↓
Požadovaný účel a datové kategorie
    ↓
DataProcessingConsent
    ↓
Povolený profilový nebo AI kontext
    ↓
Odvolání souhlasu
    ↓
Omezení budoucího zpracování
```

Profilový změnový tok je:

```text
Uživatelský vstup / AI interpretace / Integrace
    ↓
Strukturovaný návrh
    ↓
Validace
    ↓
Potvrzení podle významu
    ↓
AthleteProfileRevision
    ↓
Dopad na plánování
```

Hlavním cílem není získat při registraci co nejvíce údajů.

Cílem je vytvořit profil, který je:

* dostatečný pro konkrétní funkci,
* postupně doplnitelný,
* strukturovaný,
* časově platný,
* auditovatelný,
* bezpečný,
* přenositelný,
* respektující soukromí,
* použitelný pro libovolný sport.

Díky tomu může uživatel aplikaci říct:

> Hraju dvakrát týdně florbal, o víkendu občas lezu, ráno mám deset minut, večer hodinu, doma nemám žádné vybavení a nechci dlouhé vysvětlování.

A systém z tohoto vstupu vytvoří:

* sportovní profil,
* typický týden,
* dostupnost,
* prostředí,
* preference,
* komunikační styl,

aniž by uživatele nutil vyplňovat desítky nesouvisejících údajů nebo aby AI musela jeho situaci při každé další konverzaci znovu odhadovat.
