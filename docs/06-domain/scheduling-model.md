# AI Trainer – Scheduling Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/scheduling-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje časový a kalendářní model aplikace AI Trainer.

Navazuje zejména na:

* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/information-architecture.md`,
* `docs/04-ux/screen-specifications.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/training-plan-model.md`,
* `docs/06-domain/workout-model.md`.

Dokument popisuje:

* interní sportovní kalendář,
* obecný časově umístěný objekt,
* rozdíl mezi událostí, workoutem a aktivitou,
* pevné a flexibilní události,
* dostupnost uživatele,
* časová okna,
* opakované události,
* konkrétní instance opakování,
* výjimky,
* přesouvání a rušení událostí,
* více aktivit během jednoho dne,
* konflikty,
* časová pásma,
* cestování,
* letní a zimní čas,
* externí kalendáře,
* notifikace a deep links,
* offline změny,
* synchronizační konflikty,
* doménové invariance.

Dokument zatím neurčuje:

* přesné databázové tabulky,
* finální API kontrakty,
* konkrétní Flutter kalendářní komponenty,
* konkrétní knihovnu pro pravidla opakování,
* finální integraci Google Calendar nebo Apple Calendar,
* přesný plánovací algoritmus.

---

# 2. Cíl scheduling modelu

Scheduling model musí umožnit zobrazit a koordinovat celý sportovní život uživatele v jednom kalendáři.

Musí podporovat:

* plánované workouty,
* pravidelné týmové tréninky,
* zápasy,
* závody,
* sportovní výjezdy,
* mobilitu,
* regeneraci,
* odpočinek,
* vlastní aktivity,
* časovou dostupnost,
* dočasné změny režimu,
* více aktivit v jednom dni,
* události bez přesného času,
* opakované události,
* cestování mezi časovými pásmy,
* offline úpravy,
* externí kalendářní integrace.

Kalendář nesmí být pouze vizualizace workoutů.

Je to společná časová vrstva, která propojuje:

* plán,
* pravidelné sportovní povinnosti,
* běžnou dostupnost,
* jednorázové změny,
* skutečně provedené aktivity.

---

# 3. Základní časové objekty

Scheduling oblast musí rozlišovat minimálně:

1. `AvailabilityRule`
2. `AvailabilityException`
3. `RecurrenceSeries`
4. `ScheduleEvent`
5. `WorkoutInstance`
6. `Activity`
7. `ScheduleConflict`
8. `EventReminder`
9. `ExternalCalendarLink`

## 3.1 AvailabilityRule

Popisuje, kdy uživatel obvykle může nebo nemůže trénovat.

## 3.2 AvailabilityException

Popisuje dočasnou odchylku od běžné dostupnosti.

## 3.3 RecurrenceSeries

Definuje opakovanou událost.

Například:

> Florbal každou středu v 19:00.

## 3.4 ScheduleEvent

Konkrétní časově umístěná událost v interním kalendáři.

## 3.5 WorkoutInstance

Konkrétní strukturovaný workout.

Může mít odpovídající ScheduleEvent.

## 3.6 Activity

Skutečně provedená aktivita.

Může být spojena s plánovanou událostí.

---

# 4. Rozdíl mezi kalendářní událostí a doménovým objektem

ScheduleEvent není vždy samotným zdrojem detailních informací.

Může fungovat jako časová reprezentace jiného objektu.

Například:

```text
WorkoutInstance
    ↓
ScheduleEvent
```

WorkoutInstance obsahuje:

* cviky,
* série,
* účel,
* vybavení,
* workout stav.

ScheduleEvent obsahuje:

* datum,
* čas,
* časové pásmo,
* flexibilitu,
* stav v kalendáři.

Podobně:

```text
CompetitionEvent
    ↓
ScheduleEvent
```

nebo:

```text
RecoveryRecommendation
    ↓
ScheduleEvent
```

ScheduleEvent musí být obecný, ale nesmí duplikovat detailní data navázaného objektu.

---

# 5. ScheduleEvent

## 5.1 Význam

ScheduleEvent reprezentuje konkrétní událost umístěnou do času.

## 5.2 Základní vlastnosti

Obsahuje zejména:

* identifikátor,
* uživatele,
* název,
* stručný popis,
* typ události,
* datum,
* čas začátku,
* čas konce nebo délku,
* časové pásmo,
* all-day stav,
* flexibilitu,
* prioritu,
* stav,
* zdroj,
* vazbu na doménový objekt,
* vazbu na opakovanou sérii,
* původní termín,
* datum vytvoření,
* datum poslední změny.

## 5.3 Typy událostí

Minimálně:

* WORKOUT,
* TEAM_TRAINING,
* MATCH,
* COMPETITION,
* GENERAL_SPORT,
* MOBILITY,
* RECOVERY,
* REST,
* TRAVEL,
* CAMP,
* SPORT_TRIP,
* AVAILABILITY_BLOCK,
* USER_EVENT,
* PLAN_MARKER,
* CUSTOM.

## 5.4 Doménová vazba

Událost může odkazovat například na:

* WorkoutInstance,
* Activity,
* UserSport,
* TrainingPlan,
* Goal,
* AvailabilityException,
* externí kalendářní položku.

## 5.5 Událost bez doménové vazby

Je povolená například pro:

* vlastní krátkou poznámku,
* blok nedostupnosti,
* obecnou sportovní událost,
* zatím nestrukturovanou vlastní aktivitu.

---

# 6. Stav ScheduleEvent

Minimální stavy:

* DRAFT,
* SCHEDULED,
* CONFIRMED,
* TENTATIVE,
* IN_PROGRESS,
* COMPLETED,
* PARTIALLY_COMPLETED,
* SKIPPED,
* CANCELLED,
* RESCHEDULED,
* REPLACED,
* EXPIRED.

## 6.1 DRAFT

Událost je součástí konceptu plánu a ještě není aktivní.

## 6.2 SCHEDULED

Událost je naplánovaná.

## 6.3 CONFIRMED

Pevná událost byla potvrzena uživatelem nebo externím zdrojem.

## 6.4 TENTATIVE

Termín nebo účast nejsou jisté.

Příklad:

> Možná pojedu o víkendu lézt.

## 6.5 IN_PROGRESS

Událost právě probíhá nebo je navázána na aktivní workout.

## 6.6 COMPLETED

Událost byla uskutečněna.

## 6.7 SKIPPED

Událost se neuskutečnila bez formálního zrušení.

## 6.8 CANCELLED

Událost byla vědomě zrušena.

## 6.9 RESCHEDULED

Původní termín byl změněn.

Událost musí zachovat informaci o předchozím termínu.

## 6.10 REPLACED

Událost byla nahrazena jinou aktivitou.

---

# 7. EventFlexibility

## 7.1 Význam

EventFlexibility určuje, jak lze událost přesouvat a měnit.

## 7.2 Typy flexibility

* FIXED,
* FLEXIBLE_WITHIN_DAY,
* FLEXIBLE_WITHIN_WINDOW,
* FLEXIBLE_WITHIN_WEEK,
* OPTIONAL,
* TENTATIVE.

## 7.3 FIXED

Událost se nemá automaticky přesouvat.

Příklady:

* zápas,
* závod,
* týmový trénink,
* objednaná lekce.

## 7.4 FLEXIBLE_WITHIN_DAY

Událost lze přesunout v rámci stejného dne.

## 7.5 FLEXIBLE_WITHIN_WINDOW

Událost lze přesunout pouze v definovaném časovém okně.

## 7.6 FLEXIBLE_WITHIN_WEEK

Událost lze přesunout na jiný povolený den stejného týdne.

## 7.7 OPTIONAL

Událost lze vynechat bez zásadního narušení plánu.

## 7.8 TENTATIVE

Událost zatím není potvrzená.

---

# 8. FlexibilityWindow

## 8.1 Význam

FlexibilityWindow definuje přesné hranice přesunu.

## 8.2 Vlastnosti

* nejdřívější datum a čas,
* nejpozdější datum a čas,
* povolené dny,
* preferované dny,
* zakázané časy,
* minimální rozestup od jiné aktivity,
* maximální posun,
* platnost.

## 8.3 Příklad

Workout je naplánován na úterý večer, ale může být proveden:

* v úterý mezi 16:00 a 21:00,
* nebo ve středu ráno,
* ne však méně než šest hodin před florbalem.

---

# 9. EventPriority

Událost může mít prioritu:

* CRITICAL,
* HIGH,
* NORMAL,
* LOW,
* OPTIONAL.

## 9.1 CRITICAL

Například:

* cílový závod,
* mistrovský zápas,
* odborně doporučená kontrolní událost.

## 9.2 HIGH

Klíčový workout týdne nebo důležitý týmový trénink.

## 9.3 NORMAL

Běžná plánovaná aktivita.

## 9.4 LOW

Doplňkový workout.

## 9.5 OPTIONAL

Aktivita bez zásadního dopadu při vynechání.

Priorita se používá při:

* řešení konfliktu,
* zkracování týdne,
* adaptaci na únavu,
* změně dostupnosti.

---

# 10. AvailabilityRule

## 10.1 Význam

AvailabilityRule popisuje běžnou časovou dostupnost uživatele.

Nejde o sportovní událost.

Jde o vstup do plánování.

## 10.2 Vlastnosti

* den v týdnu,
* čas začátku,
* čas konce,
* časové pásmo,
* typ dostupnosti,
* preference,
* maximální délka workoutu,
* prostředí,
* dostupné vybavení,
* platnost,
* opakování.

## 10.3 Typy dostupnosti

* AVAILABLE,
* PREFERRED,
* FALLBACK,
* UNAVAILABLE,
* LIMITED.

## 10.4 AVAILABLE

Uživatel obvykle může trénovat.

## 10.5 PREFERRED

Preferovaný čas.

## 10.6 FALLBACK

Čas použitelný pouze jako náhradní varianta.

## 10.7 UNAVAILABLE

Systém zde nemá plánovat workouty.

## 10.8 LIMITED

Dostupnost s omezením.

Například:

* maximálně 20 minut,
* pouze bez vybavení,
* pouze lehká aktivita.

---

# 11. Dostupnost versus existující kalendářní události

Dostupnost neurčuje, že je konkrétní čas skutečně volný.

Příklad:

Uživatel má obvykle v úterý čas od 17:00 do 20:00.

V konkrétním týdnu má ale v 18:00 rodinnou událost.

PlanningService musí pracovat s:

1. běžnou AvailabilityRule,
2. AvailabilityException,
3. pevnými ScheduleEvent,
4. případnými externími kalendáři,
5. workout constraints.

---

# 12. AvailabilityException

## 12.1 Význam

Dočasná změna běžné dostupnosti.

## 12.2 Příklady

* pracovní cesta,
* dovolená,
* zkouškové období,
* noční směna,
* rodinná akce,
* víkend bez vybavení,
* krátkodobá nemoc,
* jednorázově volný den.

## 12.3 Vlastnosti

* začátek,
* konec,
* důvod,
* typ změny,
* nová dostupnost,
* nové prostředí,
* dočasné vybavení,
* priorita,
* zdroj.

## 12.4 Typy změny

* OVERRIDE,
* ADD_AVAILABILITY,
* REMOVE_AVAILABILITY,
* LIMIT_DURATION,
* CHANGE_ENVIRONMENT,
* CHANGE_EQUIPMENT.

## 12.5 Priorita

AvailabilityException má přednost před běžnou AvailabilityRule v překrývajícím se období.

---

# 13. RecurrenceSeries

## 13.1 Význam

RecurrenceSeries reprezentuje opakovanou událost nebo pravidelný workout.

Příklad:

> Fotbal každé pondělí v 18:30.

## 13.2 Vlastnosti

* identifikátor,
* uživatele,
* název,
* typ události,
* datum začátku,
* případné datum konce,
* lokální čas,
* časové pásmo,
* pravidlo opakování,
* výchozí délku,
* flexibilitu,
* prioritu,
* zdroj,
* stav,
* vazbu na sport,
* vazbu na šablonu nebo jiný objekt.

## 13.3 Stav série

* DRAFT,
* ACTIVE,
* PAUSED,
* ENDED,
* CANCELLED,
* ARCHIVED.

## 13.4 Zdroj série

* USER,
* TRAINING_PLAN,
* TEAM_SCHEDULE,
* EXTERNAL_CALENDAR,
* AI_PROPOSAL,
* SYSTEM.

---

# 14. RecurrenceRule

## 14.1 Význam

Definuje vzor opakování.

Musí podporovat minimálně:

* denní,
* týdenní,
* více dnů týdně,
* interval každých několik týdnů,
* měsíční,
* konečný počet opakování,
* konec k určitému datu.

## 14.2 Příklady

* každé pondělí a středu,
* každé dva týdny v sobotu,
* každý den po dobu 14 dní,
* první neděli v měsíci.

## 14.3 Časové pásmo

Opakování se musí řídit zamýšleným lokálním časem.

Například:

> Každou středu v 19:00 Europe/Prague.

Nesmí se ukládat pouze jako pravidelné přičítání 168 hodin v UTC.

Jinak by při změně letního času vznikl posun.

## 14.4 Standard

Technická implementace může vycházet z RFC 5545 RRULE, ale doménový model nesmí být závislý pouze na surovém textovém pravidle.

Musí existovat validovaná strukturovaná reprezentace.

---

# 15. Instance opakované série

## 15.1 Význam

Každý konkrétní výskyt RecurrenceSeries je samostatná ScheduleEvent.

Příklad:

```text
RecurrenceSeries:
Florbal každou středu v 19:00

ScheduleEvent:
Florbal, středa 12. srpna 2026 v 19:00
```

## 15.2 Důvod oddělení

Jednotlivá instance může být:

* zrušena,
* přesunuta,
* potvrzena,
* dokončena,
* nahrazena,
* upravena,

bez změny celé série.

## 15.3 Generování instancí

Možné strategie:

* generovat všechny instance do konce série,
* generovat v časovém horizontu,
* generovat při načtení.

Doporučený model:

* používat rolling horizon,
* nejbližší období materializovat jako ScheduleEvent,
* vzdálenější výskyty odvozovat,
* výjimky uchovávat explicitně.

## 15.4 Offline požadavek

Nejbližší plánované instance musí být dostupné lokálně.

---

# 16. RecurrenceException

## 16.1 Význam

Výjimka z konkrétní opakované série.

## 16.2 Typy

* CANCEL_OCCURRENCE,
* MOVE_OCCURRENCE,
* MODIFY_OCCURRENCE,
* ADD_OCCURRENCE,
* SKIP_OCCURRENCE.

## 16.3 Příklad

Florbal je každou středu v 19:00, ale:

* 12. srpna je zrušen,
* 19. srpna začíná v 20:00.

Série zůstává stejná.

Konkrétní dny mají RecurrenceException.

## 16.4 Historie

Původní plánovaný čas musí zůstat dohledatelný.

---

# 17. Změna jedné instance versus celé série

Při úpravě opakované události musí uživatel zvolit rozsah:

* pouze tato událost,
* tato a všechny následující,
* celá série.

## 17.1 Pouze tato událost

Vytvoří RecurrenceException.

## 17.2 Tato a následující

Původní série se ukončí před zvolenou instancí.

Vznikne nová série s novými pravidly.

## 17.3 Celá série

Aktualizuje se RecurrenceSeries a přegenerují se nedokončené budoucí instance.

## 17.4 Historické instance

Dokončené a proběhlé události se nesmí zpětně změnit.

---

# 18. Přesunutí události

## 18.1 Význam

Přesunutí mění plánovaný čas události.

## 18.2 Povinné informace

Musí se zachovat:

* původní začátek,
* původní konec,
* nový začátek,
* nový konec,
* důvod,
* zdroj,
* čas změny,
* případný ChangeSet.

## 18.3 Strategie identity

Preferovaný přístup:

* zachovat stejný identifikátor ScheduleEvent,
* aktualizovat čas,
* uchovat historii přes EventRevision nebo ChangeOperation.

To usnadňuje:

* deep links,
* synchronizaci,
* vztah k WorkoutInstance.

## 18.4 Stav RESCHEDULED

Stav může sloužit jako historické označení, ale aktuálně platná událost může zůstat SCHEDULED s historií přesunu.

Finální implementační rozhodnutí bude určeno později.

---

# 19. EventRevision

## 19.1 Význam

Neměnný záznam jedné verze ScheduleEvent.

## 19.2 Obsah

* číslo revize,
* původní revizi,
* plánovaný čas,
* délku,
* flexibilitu,
* prioritu,
* stav,
* zdroj,
* důvod,
* čas změny.

## 19.3 Použití

* přesun,
* změna délky,
* změna stavu,
* změna flexibility,
* změna priority,
* změna vazby na plán.

Menší technické změny nemusí vytvářet produktovou revizi, pokud neovlivňují význam události.

---

# 20. Zrušení události

## 20.1 Stav CANCELLED

Událost zůstává v historii.

## 20.2 Důvod zrušení

Příklady:

* tým zrušil trénink,
* nemoc,
* změna programu,
* počasí,
* vlastní rozhodnutí,
* nahrazeno jinou aktivitou.

## 20.3 Dopad

Zrušení může vyvolat:

* přepočet týdne,
* nový volný čas,
* návrh náhradního workoutu,
* zachování odpočinku,
* úpravu zátěže.

Systém nesmí automaticky zaplnit každý uvolněný termín.

---

# 21. Vynechání versus zrušení

## 21.1 CANCELLED

Událost byla zrušena před plánovaným termínem nebo formálním rozhodnutím.

## 21.2 SKIPPED

Termín proběhl, ale uživatel aktivitu neprovedl.

## 21.3 Rozdíl

Rozdíl je důležitý pro:

* adherence,
* plánovací revizi,
* historii,
* notifikace,
* důvod neuskutečnění.

---

# 22. Nahrazení události

## 22.1 Příklad

Uživatel měl běžet, ale místo toho hrál fotbal.

## 22.2 Vztah

Původní ScheduleEvent může být označena:

* REPLACED,
* SKIPPED_WITH_REPLACEMENT,
* nebo zůstat SKIPPED s ActivityMatch.

Doporučený obecný model:

* původní plánovaná událost zůstane,
* skutečná Activity se uloží,
* ActivityMatch popíše vztah,
* plánovací revize rozhodne o dopadu.

---

# 23. Událost bez přesného času

## 23.1 Použití

Například:

* flexibilní mobilita během dne,
* víkendové lezení,
* odpočinek,
* orientační běh.

## 23.2 Reprezentace

Událost může mít:

* datum,
* bez přesného času,
* doporučenou část dne,
* časové okno,
* all-day příznak.

## 23.3 Rozdíl all-day versus unscheduled time

All-day:

> Událost zabírá nebo tematicky označuje celý den.

Unscheduled time:

> Aktivita má proběhnout během dne, ale zatím nemá konkrétní čas.

Tyto stavy nesmí být směšovány.

---

# 24. Vícedenní události

## 24.1 Příklady

* lezecký víkend,
* soustředění,
* sportovní kemp,
* přechod hor,
* závodní výjezd,
* dovolená.

## 24.2 Model

Vícedenní událost může být:

* jedna ScheduleEvent s intervalem,
* nadřazený EventGroup s denními instancemi,
* kombinace.

Doporučený přístup:

* hlavní EventGroup nebo TripEvent,
* konkrétní denní ScheduleEvent podle potřeb plánování.

## 24.3 Důvod

Plánovací engine potřebuje vědět:

* které konkrétní dny budou zatížené,
* očekávanou intenzitu každý den,
* cestovní dny,
* následnou regeneraci.

---

# 25. EventGroup

## 25.1 Význam

Skupina souvisejících kalendářních událostí.

## 25.2 Příklady

* víkend na skalách,
* několikadenní závod,
* tréninkový kemp,
* turnaj,
* dovolená.

## 25.3 Obsah

* název,
* začátek,
* konec,
* typ,
* sport,
* priorita,
* dílčí události,
* očekávaná zátěž,
* cestovní informace,
* poznámka.

## 25.4 Výhoda

Umožní změnit celý výjezd jako jeden logický objekt, ale zachovat denní detail.

---

# 26. Více aktivit během jednoho dne

Scheduling model musí podporovat libovolný počet událostí během dne.

Každá událost musí mít:

* roli,
* prioritu,
* čas nebo časové okno,
* zátěž,
* vztah k ostatním událostem.

## 26.1 DailySequence

Může popisovat doporučené pořadí aktivit.

Příklad:

1. ranní mobilita,
2. práce,
3. večerní florbal.

## 26.2 Minimální rozestup

Některé události mohou vyžadovat minimální rozestup.

Příklad:

* silový workout nejméně šest hodin před týmovým tréninkem.

## 26.3 Pořadí bez přesného času

Pokud aktivity nemají přesný čas, lze definovat:

* BEFORE_EVENT,
* AFTER_EVENT,
* MORNING,
* AFTERNOON,
* EVENING,
* ANYTIME.

---

# 27. EventDependency

## 27.1 Význam

Vztah mezi dvěma událostmi.

## 27.2 Typy

* BEFORE,
* AFTER,
* SAME_DAY,
* NOT_SAME_DAY,
* MINIMUM_GAP,
* MAXIMUM_GAP,
* REQUIRES_COMPLETION,
* ALTERNATIVE_TO,
* REPLACES.

## 27.3 Příklad

Cooldown:

* musí být po hlavním workoutu.

Testovací workout:

* má být nejméně 48 hodin po těžkém zápase.

---

# 28. ScheduleConflict

## 28.1 Význam

ScheduleConflict představuje časový nebo plánovací problém.

## 28.2 Kategorie

* TIME_OVERLAP,
* AVAILABILITY_CONFLICT,
* RECOVERY_CONFLICT,
* EQUIPMENT_CONFLICT,
* ENVIRONMENT_CONFLICT,
* LIMITATION_CONFLICT,
* PRIORITY_CONFLICT,
* EXTERNAL_CALENDAR_CONFLICT,
* TIMEZONE_CONFLICT,
* DUPLICATE_EVENT.

## 28.3 Závažnost

* INFO,
* WARNING,
* ERROR,
* BLOCKING.

## 28.4 INFO

Upozornění bez nutnosti zásahu.

## 28.5 WARNING

Plán je možný, ale méně vhodný.

## 28.6 ERROR

Je potřeba úprava nebo explicitní potvrzení.

## 28.7 BLOCKING

Událost nelze aktivovat.

Příkladem může být porušení tvrdého zdravotního omezení.

---

# 29. Detekce časového překryvu

Dvě události se časově překrývají, pokud jejich intervaly mají společnou část.

Musí být zohledněno:

* časové pásmo,
* all-day události,
* otevřené časové okno,
* cestovní čas v budoucnu,
* flexibilní aktivita bez přesného času.

Ne každý překryv musí být konflikt.

Příklad:

* lehká mobilita může být zobrazena uvnitř delšího sportovního kempu jako dílčí aktivita.

---

# 30. Řešení konfliktu

Možné výstupy:

* ponechat,
* přesunout,
* zkrátit,
* změnit prioritu,
* změnit flexibilitu,
* zrušit,
* nahradit,
* vyžádat potvrzení,
* požádat AI o návrh.

Každé řešení musí zachovat:

* důvod,
* původní stav,
* nový stav,
* audit.

---

# 31. Časová pásma

## 31.1 Základní pravidlo

Každá časová událost musí mít:

* absolutní okamžik pro synchronizaci,
* lokální datum a čas pro uživatelský význam,
* IANA časové pásmo.

Příklad:

```text
2026-08-18T18:00:00
Europe/Prague
```

## 31.2 Uživatelské časové pásmo

UserAccount nebo AthleteProfile má výchozí časové pásmo.

## 31.3 Časové pásmo události

Konkrétní událost může mít jiné časové pásmo.

Například závod v USA.

## 31.4 Zobrazení

Aplikace může zobrazit událost:

* v lokálním čase zařízení,
* v původním čase události,
* případně obojí u cestování.

---

# 32. Cestování mezi časovými pásmy

## 32.1 AvailabilityException

Cestování může vytvořit dočasnou změnu:

* časového pásma,
* dostupnosti,
* vybavení,
* prostředí.

## 32.2 Workouty během cestování

Systém musí určit, zda workout:

* zachovává lokální čas,
* zachovává původní okamžik,
* má být přeplánován.

Výchozí produktové pravidlo:

Sportovní workout se obvykle váže na lokální denní režim uživatele, ne na absolutní UTC okamžik.

## 32.3 Pevné události

Let, závod nebo rezervace se řídí časovým pásmem místa události.

---

# 33. Letní a zimní čas

Opakované události se musí držet lokálního času.

Příklad:

> Florbal každou středu v 19:00.

Po změně času musí zůstat v 19:00 místního času.

Technická implementace musí zabránit:

* posunu o hodinu,
* vytvoření neexistujícího času,
* duplicitě při opakované hodině.

---

# 34. Neexistující a opakovaný lokální čas

## 34.1 Neexistující čas

Při jarním přechodu může některý lokální čas neexistovat.

Systém musí mít definovanou politiku:

* posunout na nejbližší platný čas,
* vyžádat potvrzení,
* použít pravidlo poskytovatele.

## 34.2 Opakovaný čas

Při podzimním přechodu může stejný lokální čas nastat dvakrát.

Událost musí být jednoznačně spojena s konkrétním UTC okamžikem.

## 34.3 Uživatelská komunikace

Pokud má změna praktický dopad, uživatel musí být upozorněn srozumitelně.

---

# 35. Workouts a ScheduleEvent

## 35.1 Doporučený vztah

Každý časově naplánovaný WorkoutInstance má jednu hlavní ScheduleEvent.

```text
WorkoutInstance 1 ─── 1 ScheduleEvent
```

## 35.2 Workout bez termínu

Workout může existovat jako koncept bez ScheduleEvent.

Například:

* workout šablona,
* nerozvržený návrh,
* zásobník volitelných workoutů.

## 35.3 Přesunutí

Přesun ScheduleEvent aktualizuje plánovaný termín WorkoutInstance prostřednictvím jedné doménové operace.

Nesmí vzniknout dva nezávislé zdroje času.

## 35.4 Zdroj pravdy času

Pro naplánovaný workout musí být jasně určeno, který objekt je zdrojem pravdy.

Doporučení:

* ScheduleEvent je zdrojem kalendářního termínu,
* WorkoutInstance obsahuje odkaz a případný denormalizovaný read údaj,
* změna musí probíhat přes SchedulingService.

---

# 36. Sportovní události bez WorkoutInstance

Týmový trénink, zápas nebo závod nemusí mít detailní workout.

Může být reprezentován:

```text
ScheduleEvent
    ↓
UserSport
```

Po uskutečnění může vzniknout:

```text
Activity
```

Pokud uživatel chce detailní tracking, lze vytvořit jednoduchou WorkoutSession nebo sportovní specializovaný tracker.

---

# 37. Activity a ScheduleEvent

## 37.1 Plánovaná a skutečná časová hodnota

ScheduleEvent obsahuje:

* plánovaný začátek,
* plánovaný konec.

Activity obsahuje:

* skutečný začátek,
* skutečný konec.

## 37.2 Shoda

ActivityMatch určuje, zda aktivita odpovídá plánované události.

## 37.3 Automatická shoda

Může vycházet z:

* času,
* sportu,
* délky,
* zdroje,
* uživatelského potvrzení.

Automatická shoda musí mít míru jistoty.

---

# 38. Přidání ruční aktivity do minulosti

Uživatel může přidat již dokončenou aktivitu.

V takovém případě může vzniknout:

* pouze Activity,
* nebo zpětná ScheduleEvent společně s Activity, pokud je to potřebné pro historii.

Doporučený model:

* skutečnost reprezentuje Activity,
* plánovaná ScheduleEvent se zpětně nevytváří, pokud aktivita nebyla plánovaná.

---

# 39. Rest a Recovery události

## 39.1 REST

Záměrný den nebo období bez tréninku.

## 39.2 RECOVERY

Lehká aktivita podporující regeneraci.

Příklady:

* procházka,
* lehká mobilita,
* dechová rutina.

## 39.3 Kalendářní význam

Rest event nemusí blokovat celý den.

Může sloužit jako:

* plánovací marker,
* pravidlo,
* uživatelské doporučení.

---

# 40. Odpočinkový den

Odpočinkový den není nutně den bez jakéhokoliv pohybu.

Může obsahovat:

* chůzi,
* lehkou mobilitu,
* běžný životní pohyb.

Model musí rozlišit:

* NO_TRAINING,
* ACTIVE_RECOVERY,
* LOW_LOAD_DAY.

---

# 41. Kalendářní markery

Některé položky nemají být skutečnou aktivitou.

Příklady:

* začátek bloku,
* konec plánu,
* termín cíle,
* den revize,
* očekávaný deload.

Tyto položky mohou být reprezentovány jako:

* PLAN_MARKER,
* GOAL_DEADLINE,
* REVIEW_EVENT.

Nemají se započítávat jako sportovní zátěž.

---

# 42. Událost závodu nebo zápasu

## 42.1 CompetitionEvent

Specializovaný doménový objekt může obsahovat:

* název,
* sport,
* důležitost,
* místo,
* registraci,
* očekávanou délku,
* cílový výkon,
* typ akce.

## 42.2 Scheduling vztah

CompetitionEvent má odpovídající ScheduleEvent.

## 42.3 Dopad na plán

Událost může ovlivnit:

* taper,
* předchozí workouty,
* warm-up,
* následnou regeneraci,
* revizi cíle.

---

# 43. Místo a prostředí události

ScheduleEvent může obsahovat:

* název místa,
* obecnou lokaci,
* adresu,
* zeměpisné souřadnice v budoucnu,
* TrainingEnvironment,
* časové pásmo místa.

Přesná poloha je citlivý údaj a musí se ukládat pouze tam, kde je potřebná.

---

# 44. TravelBuffer

## 44.1 Význam

Volitelný čas potřebný na cestu před nebo po události.

## 44.2 Použití

Například:

* cesta do fitka,
* cesta na zápas,
* cesta na skály.

## 44.3 Plánovací dopad

TravelBuffer může blokovat dostupnost, aniž by byl sportovní aktivitou.

V první verzi může být tato funkce omezená nebo ruční.

---

# 45. Externí kalendáře

## 45.1 Role

Google Calendar, Apple Calendar a další kalendáře jsou externí zdroje nebo cíle.

Interní kalendář AI Traineru zůstává zdrojem pravdy pro sportovní plán.

## 45.2 Možné režimy

* export interních workoutů,
* import relevantních událostí,
* obousměrná synchronizace v budoucnu,
* pouze čtení časové obsazenosti.

## 45.3 Minimální oprávnění

Aplikace má požadovat pouze rozsah nutný pro zvolenou funkci.

## 45.4 Soukromí

AI nemusí znát název soukromé externí události.

Pro plánování často stačí:

* obsazeno,
* čas,
* délka.

---

# 46. ExternalCalendarEvent

## 46.1 Význam

Normalizovaná reprezentace externí kalendářní události.

## 46.2 Obsah

* poskytovatel,
* externí identifikátor,
* kalendář,
* začátek,
* konec,
* časové pásmo,
* busy/free stav,
* citlivost,
* synchronizační verze,
* volitelně bezpečný název.

## 46.3 Interní převod

Externí událost se nemá automaticky stát ScheduleEvent.

Může sloužit pouze jako časové omezení.

---

# 47. ExternalCalendarLink

## 47.1 Význam

Propojení interní ScheduleEvent s externí položkou.

## 47.2 Obsah

* interní event,
* poskytovatel,
* externí identifikátor,
* směr synchronizace,
* stav,
* poslední synchronizace,
* konflikt.

## 47.3 Zdroj pravdy

Musí být určeno:

* interní systém,
* externí kalendář,
* ruční konflikt.

V počáteční verzi je vhodné, aby sportovní workouty řídil interní systém a do externího kalendáře se pouze exportovaly.

---

# 48. Synchronizace externího kalendáře

Musí řešit:

* změnu času,
* smazání,
* duplicitní import,
* změnu časového pásma,
* odpojení účtu,
* nedostupné oprávnění,
* konfliktní úpravu.

Systém nesmí smazat interní workout pouze proto, že uživatel odstranil exportovanou kopii v externím kalendáři, pokud toto chování nebylo výslovně nastaveno.

---

# 49. EventReminder

## 49.1 Význam

Pravidlo připomenutí konkrétní události.

## 49.2 Obsah

* event,
* typ připomenutí,
* předstih,
* konkrétní čas,
* časové pásmo,
* kanál,
* stav,
* deep link,
* citlivost textu.

## 49.3 Typy

* ranní přehled,
* připomenutí před workoutem,
* připomenutí zahájeného workoutu,
* připomenutí potvrzení změny,
* následné hodnocení.

## 49.4 Více připomenutí

Událost může mít více připomenutí.

Příklad:

* ráno,
* 30 minut před začátkem.

---

# 50. Notifikace při přesunutí

Pokud se událost přesune:

* neplatná budoucí notifikace se musí zrušit,
* vytvoří se nová,
* starý deep link musí otevřít aktuální stav,
* uživatel nemá dostat připomenutí starého termínu.

---

# 51. Deep links do kalendáře

Musí být podporováno otevření:

* konkrétní události,
* konkrétního dne,
* týdne,
* workoutu,
* návrhu přesunu,
* konfliktu,
* série opakování.

Deep link musí vždy načíst aktuální verzi objektu.

---

# 52. Kalendářní read modely

## 52.1 TodayScheduleView

Obsahuje:

* dnešní události,
* pořadí,
* stav,
* nejbližší aktivitu,
* konflikty,
* čekající návrhy.

## 52.2 DailyCalendarView

Obsahuje:

* časovou osu,
* události s časem,
* flexibilní události,
* all-day položky,
* souhrn dne.

## 52.3 WeeklyCalendarView

Obsahuje:

* sedm dní,
* události,
* priority,
* flexibilitu,
* konflikty,
* plánovanou zátěž.

## 52.4 MonthlyCalendarView

Obsahuje:

* indikátory dnů,
* významné události,
* cílové termíny,
* bloky plánu.

## 52.5 ScheduleEventDetailView

Obsahuje:

* termín,
* typ,
* stav,
* vazbu na workout nebo sport,
* historii změn,
* dostupné akce.

## 52.6 RecurrenceSeriesView

Obsahuje:

* pravidlo,
* budoucí instance,
* výjimky,
* stav série.

---

# 53. SchedulingService

## 53.1 Odpovědnost

Doménová služba spravující kalendářní změny.

Může zajišťovat:

* vytvoření události,
* přesunutí,
* změnu série,
* materializaci opakování,
* konfliktovou kontrolu,
* vazbu na WorkoutInstance,
* správu časových pásem.

## 53.2 Nesmí řešit

SchedulingService sám nemá rozhodovat o kompletní tréninkové strategii.

Tu řeší PlanningService.

SchedulingService zajišťuje časovou konzistenci.

---

# 54. AvailabilityService

Může zajišťovat:

* výpočet efektivní dostupnosti,
* aplikaci výjimek,
* kombinaci pravidel,
* hledání volných oken,
* kontrolu maximální délky,
* dostupnost prostředí a vybavení.

---

# 55. RecurrenceService

Může zajišťovat:

* validaci pravidel opakování,
* generování instancí,
* výjimky,
* změnu této a následujících událostí,
* časová pásma,
* letní a zimní čas,
* idempotentní materializaci.

---

# 56. ConflictDetectionService

Může kontrolovat:

* časový překryv,
* dostupnost,
* minimum regenerace,
* omezení,
* vybavení,
* externí kalendáře,
* duplicity,
* závislosti.

Výsledek musí být strukturovaný a vysvětlitelný.

---

# 57. Změna programu přes AI

## 57.1 Příklad

> Celý víkend jedu na skály.

## 57.2 Strukturovaný výstup

AIProposal může obsahovat:

* EventGroup pro lezecký víkend,
* sobotní ScheduleEvent,
* nedělní ScheduleEvent,
* očekávanou zátěž,
* návrhy přesunů,
* regeneraci.

## 57.3 Validace

SchedulingService ověří:

* přesná data,
* konflikty,
* časová pásma,
* duplicity,
* flexibilitu ovlivněných workoutů.

## 57.4 Potvrzení

Po potvrzení vznikne jeden ChangeSet.

---

# 58. Změna běžného rozvrhu

## 58.1 Příklad

> Od příštího měsíce budu mít florbal jen ve středu.

## 58.2 Výsledek

* ukončení původní RecurrenceSeries,
* vytvoření nové série nebo úprava budoucí části,
* zachování historických instancí,
* analýza dopadu na plán,
* případná nová TrainingPlanVersion.

---

# 59. Jednorázové zrušení pravidelné události

## 59.1 Příklad

> Tento týden se středeční florbal ruší.

## 59.2 Výsledek

* zruší se konkrétní ScheduleEvent,
* vytvoří se RecurrenceException,
* série zůstane aktivní,
* systém může navrhnout úpravu týdne.

---

# 60. Události vytvořené plánem

Když se aktivuje TrainingPlan:

* mohou se vytvořit WorkoutInstance,
* vytvoří se jejich ScheduleEvent,
* případně se vytvoří plánovací markery,
* nastaví se připomenutí.

Události musí uchovávat:

* plán,
* verzi plánu,
* zdroj,
* možnost identifikovat pozdější lokální změny.

---

# 61. Zrušení nebo nahrazení plánu

Při ukončení plánu systém musí určit, co se stane s budoucími událostmi:

* zrušit,
* archivovat,
* ponechat jako nezávislé,
* nahradit událostmi nového plánu.

Uživatel musí před potvrzením vidět počet ovlivněných událostí.

Dokončené a minulé události se nesmí odstranit.

---

# 62. Offline vytváření a změny

Offline musí být možné:

* vytvořit vlastní událost,
* přesunout flexibilní workout,
* zrušit událost,
* označit workout jako vynechaný,
* přidat Activity,
* změnit připomenutí dostupné lokálně.

Každá změna vytvoří:

* lokální revizi,
* OfflineCommand,
* stabilní identifikátor,
* synchronizační stav.

---

# 63. Offline opakované série

Uživatel může offline upravit jednu již materializovanou instanci.

Změna celé série může vyžadovat:

* dostupnou lokální definici série,
* nebo online validaci.

V první verzi lze složitější úpravy celé série offline omezit, ale uživatel nesmí ztratit již provedenou změnu.

---

# 64. Synchronizační konflikty

## 64.1 Příklady

* workout přesunut offline i na jiném zařízení,
* série upravena na serveru,
* událost zrušena a současně dokončena,
* externí kalendář změnil čas.

## 64.2 Automaticky slučitelné změny

Například:

* změna poznámky a změna připomenutí.

## 64.3 Neslučitelné změny

Například:

* dva různé nové termíny stejného workoutu.

## 64.4 Ochrana skutečnosti

Dokončená Activity má přednost jako historická skutečnost.

Plánovaný čas lze následně opravit nebo označit jako odlišný.

---

# 65. Idempotence

Každý scheduling příkaz musí mít stabilní identifikátor operace.

Opakované zpracování nesmí:

* vytvořit druhou stejnou událost,
* vytvořit duplicitní výjimku,
* opakovaně přesunout čas,
* poslat duplicitní notifikaci.

---

# 66. Audit scheduling změn

Audit musí obsahovat minimálně:

* objekt,
* původní termín,
* nový termín,
* zdroj,
* důvod,
* čas změny,
* zařízení nebo systém,
* uživatelské potvrzení,
* ChangeSet.

---

# 67. Mazání událostí

## 67.1 Budoucí koncept bez návazností

Může být fyzicky odstraněn.

## 67.2 Aktivní nebo historická událost

Preferuje se:

* CANCELLED,
* ARCHIVED,
* soft delete.

## 67.3 Událost s Activity

Nesmí být fyzicky odstraněna běžnou změnou plánu.

---

# 68. Doménové události scheduling oblasti

Minimálně:

* AvailabilityRuleCreated
* AvailabilityRuleUpdated
* AvailabilityExceptionCreated
* RecurrenceSeriesCreated
* RecurrenceSeriesUpdated
* RecurrenceSeriesEnded
* ScheduleEventCreated
* ScheduleEventConfirmed
* ScheduleEventRescheduled
* ScheduleEventCancelled
* ScheduleEventSkipped
* ScheduleEventCompleted
* ScheduleEventReplaced
* RecurrenceExceptionCreated
* ScheduleConflictDetected
* ScheduleConflictResolved
* EventReminderScheduled
* EventReminderCancelled
* ExternalCalendarLinked
* ExternalCalendarConflictDetected
* TimezoneChanged
* EventGroupCreated

---

# 69. Příkazy scheduling oblasti

Minimálně:

* CreateScheduleEvent
* UpdateScheduleEvent
* RescheduleScheduleEvent
* CancelScheduleEvent
* SkipScheduleEvent
* ConfirmScheduleEvent
* CompleteScheduleEvent
* CreateRecurrenceSeries
* UpdateRecurrenceSeries
* UpdateSingleOccurrence
* UpdateThisAndFollowingOccurrences
* EndRecurrenceSeries
* CreateAvailabilityRule
* UpdateAvailabilityRule
* CreateAvailabilityException
* ResolveScheduleConflict
* CreateEventReminder
* CancelEventReminder
* LinkExternalCalendarEvent
* UnlinkExternalCalendarEvent
* CreateEventGroup

---

# 70. Invariance scheduling modelu

## 70.1 Vlastnictví

* Každá uživatelská událost patří jednomu uživateli.
* Událost nesmí odkazovat na WorkoutInstance jiného uživatele.

## 70.2 Čas

* Konec události nesmí být před začátkem.
* Délka nesmí být záporná.
* Časové pásmo musí být platné IANA pásmo.
* Událost s přesným časem musí mít jednoznačný UTC interval.

## 70.3 Opakování

* Instance musí patřit správné sérii.
* Výjimka musí odkazovat na konkrétní původní výskyt.
* Změna série nesmí přepsat dokončené historické instance.
* Materializace musí být idempotentní.

## 70.4 Workout

* Jeden WorkoutInstance nesmí mít více současně aktivních hlavních ScheduleEvent.
* Přesun eventu a termínu workoutu musí být atomický.
* Dokončený workout se nesmí změnit na budoucí událost bez opravy.

## 70.5 Konflikty

* BLOCKING konflikt se nesmí obejít bez oprávněného řešení.
* HARD availability constraint se nesmí porušit.
* Pevná událost se nesmí automaticky přesunout bez oprávnění.

## 70.6 AI

* AI nesmí změnit sérii nebo více událostí bez validace.
* Zastaralý AIProposal se nesmí aplikovat.
* Významná změna kalendáře musí mít potvrzení.

## 70.7 Offline

* Konflikt nesmí automaticky odstranit lokální změnu.
* Opakovaná synchronizace nesmí vytvářet duplicity.

---

# 71. Příklad – pravidelný florbal

## RecurrenceSeries

* název: Florbalový trénink,
* sport: florbal,
* každé pondělí a středu,
* čas: 19:00,
* délka: 90 minut,
* časové pásmo: Europe/Prague,
* flexibilita: FIXED,
* priorita: HIGH.

## Instance

Pro každý nejbližší termín vznikne ScheduleEvent.

## Jednorázová výjimka

Středeční trénink se ruší:

* konkrétní ScheduleEvent → CANCELLED,
* vznikne RecurrenceException,
* série pokračuje další týden.

---

# 72. Příklad – flexibilní domácí workout

## WorkoutInstance

* Upper Body A,
* plánovaný na úterý,
* délka 40 minut.

## ScheduleEvent

* preferovaný čas 18:00,
* flexibilní mezi 16:00 a 21:00,
* FLEXIBLE_WITHIN_DAY.

## Změna

Uživatel napíše:

> Dnes můžu až ve 20:00.

Událost se přesune v rámci povoleného okna bez zásadní změny plánu.

---

# 73. Příklad – víkend na skalách

## EventGroup

* název: Lezení na skalách,
* sobota až neděle.

## Dílčí ScheduleEvent

Sobota:

* lezení,
* 10:00–17:00,
* vysoká tahová a úchopová zátěž.

Neděle:

* lezení,
* 09:00–15:00,
* střední až vysoká zátěž.

## Dopad

ChangeSet může:

* přesunout páteční tahový workout,
* zrušit sobotní doplňkovou sílu,
* přidat pondělní regeneraci.

---

# 74. Příklad – pracovní cesta

## AvailabilityException

* pondělí až čtvrtek,
* hotel,
* bez hrazdy,
* pouze ráno,
* maximálně 20 minut.

## Dopad

PlanningService najde ovlivněné workouty.

SchedulingService řeší jejich nové časy.

WorkoutAdaptationService vytvoří varianty bez vybavení.

---

# 75. Příklad – změna časového pásma

Uživatel odletí z Prahy do New Yorku.

## Pevná událost

Závod v New Yorku:

* uložen v America/New_York,
* zobrazí se správně podle lokálního času.

## Běžná ranní mobilita

Může se přesunout na ráno podle nového lokálního režimu.

Nemá automaticky proběhnout v okamžiku odpovídajícím původnímu českému ránu.

---

# 76. Příklad – externí pracovní kalendář

Aplikace má oprávnění číst pouze busy/free stav.

Externí událost:

* úterý 17:00–18:30,
* soukromý obsah nezobrazen.

PlanningService ví, že čas není dostupný.

AI nemusí dostat název ani popis schůzky.

---

# 77. Co nesmí být pouze jako volný text

Následující informace musí být strukturované:

* datum,
* čas,
* časové pásmo,
* délka,
* opakování,
* flexibilita,
* priorita,
* stav,
* vazba na workout,
* původní termín,
* nový termín,
* důvod zrušení,
* výjimka série,
* konflikt,
* dostupnost,
* připomenutí.

Volný text může doplňovat:

* poznámku,
* místo,
* vysvětlení,
* uživatelský kontext.

---

# 78. Otevřené otázky

* Bude ScheduleEvent samostatný agregát?
* Má WorkoutInstance obsahovat termín, nebo pouze odkaz na ScheduleEvent?
* Jak přesně materializovat rolling horizon opakovaných událostí?
* Jak dlouhý horizont uchovávat lokálně?
* Jaký formát použít pro RecurrenceRule?
* Jak řešit úpravy opakování offline?
* Jak reprezentovat celodenní sportovní výjezdy přes více časových pásem?
* Jak přesně modelovat EventGroup?
* Jak řešit událost s neznámým koncem?
* Jak řešit workout přes půlnoc?
* Jakou politiku použít pro neexistující lokální čas při změně DST?
* Jak určit automatickou shodu Activity se ScheduleEvent?
* Jak řešit zrušení události v externím kalendáři?
* Jak přesně synchronizovat interní události do Google Calendar?
* Budou osobní externí události ukládány, nebo jen dočasně zpracovány?
* Jak dlouho uchovávat historii EventRevision?
* Jak zobrazovat několik překrývajících se aktivit na malém displeji?
* Jak plánovat travel buffer?
* Které kalendářní změny vyžadují novou TrainingPlanVersion?
* Jak přesně funguje částečné potvrzení změn série?

---

# 79. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── sports-and-goals-model.md
├── activity-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── sync-and-offline-model.md
├── integration-model.md
├── domain-events.md
└── domain-invariants.md
```

Dále:

```text
docs/07-backend/
├── scheduling-service.md
├── calendar-api.md
├── recurrence-engine.md
├── notification-service.md
└── external-calendar-integrations.md
```

A:

```text
docs/08-mobile/
├── calendar-architecture.md
├── offline-calendar.md
├── deep-linking.md
└── notification-navigation.md
```

---

# 80. Kritéria správného scheduling modelu

Model je vhodný pouze tehdy, pokud umožní:

1. zobrazit všechny sporty v jednom kalendáři,
2. přidat pevnou událost,
3. přidat flexibilní workout,
4. zadat událost bez přesného času,
5. podporovat více aktivit denně,
6. vytvořit opakovanou sérii,
7. upravit jednu instanci série,
8. upravit tuto a následující instance,
9. zrušit jednu pravidelnou událost,
10. přesunout workout,
11. zachovat původní termín,
12. odlišit zrušení a vynechání,
13. přidat vícedenní sportovní výjezd,
14. pracovat s časovým pásmem,
15. správně zvládnout změnu letního času,
16. kombinovat dostupnost a výjimky,
17. detekovat konflikty,
18. reagovat na externí kalendář,
19. plánovat notifikace,
20. otevřít správný objekt z deep linku,
21. fungovat offline,
22. synchronizovat více zařízení,
23. chránit workout data při konfliktu,
24. podporovat libovolný sport,
25. umožnit AI bezpečně navrhovat změny.

---

# 81. Závěr

Scheduling model propojuje strategický plán s konkrétním každodenním životem uživatele.

Jeho základní tok je:

```text
AvailabilityRule
    +
AvailabilityException
    +
RecurrenceSeries
    +
TrainingPlan
    ↓
ScheduleEvent
    ↓
WorkoutInstance nebo jiná sportovní událost
    ↓
WorkoutSession / Activity
    ↓
Kalendářní historie a další adaptace
```

Kalendář není pouze seznam termínů.

Je to časová vrstva celého sportovního systému.

Musí vědět:

* co je pevné,
* co je flexibilní,
* co se opakuje,
* co se změnilo,
* co bylo skutečně provedeno,
* co se smí automaticky přesunout,
* co vyžaduje potvrzení.

Díky tomu může uživatel říct:

> Zápas se přesunul na sobotu.

nebo:

> Příští týden můžu cvičit jen ráno.

A systém dokáže bezpečně a srozumitelně upravit konkrétní kalendářní události, aniž by ztratil vztah k workoutům, dlouhodobému plánu nebo historii.
