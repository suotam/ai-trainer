# AI Trainer – Domain Overview

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/domain-overview.md`

---

# 1. Účel dokumentu

Tento dokument definuje základní doménový model aplikace AI Trainer.

Doménový model popisuje:

* hlavní objekty systému,
* jejich význam,
* jejich vzájemné vztahy,
* hranice jednotlivých oblastí,
* zdroje pravdy,
* rozdíl mezi plánem a skutečností,
* životní cyklus důležitých objektů,
* pravidla pro historii, verzování a audit,
* způsob podpory libovolných sportů,
* základy pro databázi, backend, mobilní aplikaci a AI nástroje.

Dokument zatím neurčuje:

* přesné databázové tabulky,
* konkrétní názvy sloupců,
* SQL migrace,
* REST endpointy,
* konkrétní Kotlin nebo Dart třídy,
* finální JSON schémata,
* implementační detaily synchronizace.

Tyto oblasti budou rozpracovány v navazujících dokumentech.

---

# 2. Cíl doménového modelu

Doménový model musí umožnit reprezentovat celý sportovní život uživatele jako jeden propojený systém.

Musí podporovat:

* jednoho uživatele s více sporty,
* více současných cílů,
* pravidelný i nepravidelný rozvrh,
* dlouhodobé plány,
* konkrétní workouty,
* skutečně provedené aktivity,
* ruční i automatická data,
* AI návrhy,
* změny plánu,
* dočasná i dlouhodobá omezení,
* offline práci,
* synchronizaci,
* integrace,
* libovolné sporty a vlastní aktivity.

Model nesmí být navržen pouze pro:

* posilování,
* běh,
* fotbal,
* lezení,
* konkrétní wearable službu.

Musí mít obecný základ, nad kterým mohou vznikat sportovní specializace.

---

# 3. Základní doménové principy

## 3.1 Plán a skutečnost jsou oddělené

Systém musí rozlišovat:

* co bylo původně plánováno,
* co bylo později upraveno,
* co uživatel skutečně provedl,
* co bylo importováno z externí služby,
* co uživatel subjektivně uvedl.

Dokončená aktivita nesmí přepsat původní plán.

## 3.2 Historie se nepřepisuje

Významné změny musí být dohledatelné.

Systém musí uchovávat:

* původní stav,
* nový stav,
* čas změny,
* zdroj změny,
* důvod,
* autora nebo systém,
* možnost vrácení, pokud je dostupná.

## 3.3 AI není zdroj pravdy

AI může:

* interpretovat,
* navrhovat,
* vysvětlovat,
* připravovat strukturované akce.

AI nesmí být jediným místem, kde existuje informace o:

* cíli,
* sportu,
* workoutu,
* omezení,
* kalendářní události,
* vybavení,
* provedené aktivitě.

Po potvrzení se informace uloží do standardního doménového modelu.

## 3.4 Externí služby nejsou zdroj interní struktury

Garmin, Apple Health, Health Connect, Strava a další služby poskytují data.

Interní model musí být na konkrétní službě nezávislý.

## 3.5 Každá důležitá informace má jeden hlavní zdroj pravdy

Například:

* uživatelský cíl má zdroj pravdy v objektu Goal,
* sportovní aktivita v Activity,
* plánovaný workout ve WorkoutInstance,
* vybavení v EquipmentItem,
* aktuální omezení v Limitation,
* AI změna v ChangeSet a AIProposal.

Ostatní obrazovky a souhrny tyto informace pouze zobrazují nebo odvozují.

---

# 4. Hlavní doménové oblasti

Doménový model je rozdělen do následujících oblastí:

1. Identity and Account
2. Athlete Profile
3. Sports
4. Goals
5. Scheduling and Availability
6. Training Planning
7. Workouts
8. Activities
9. Recovery and Readiness
10. Limitations and Pain
11. Equipment and Environment
12. AI Coaching
13. Change Management
14. Progress and Metrics
15. Notifications
16. Integrations
17. Synchronization and Offline
18. Privacy and Audit

Každá oblast má vlastní odpovědnost, ale všechny pracují se stejným uživatelem a jeho sportovním systémem.

---

# 5. Identity and Account

Tato oblast reprezentuje technickou identitu uživatele.

## 5.1 UserAccount

Reprezentuje účet v aplikaci.

Obsahuje zejména:

* technický identifikátor,
* stav účtu,
* datum vytvoření,
* datum posledního přihlášení,
* preferovaný jazyk,
* region,
* časové pásmo,
* stav onboardingu,
* stav smazání účtu.

Neobsahuje detailní sportovní informace.

## 5.2 AuthenticationIdentity

Reprezentuje konkrétní způsob přihlášení.

Příklady:

* e-mail a heslo,
* Google,
* Apple.

Jeden účet může mít více přihlašovacích identit.

## 5.3 UserSession

Reprezentuje přihlášenou relaci nebo zařízení.

Slouží pro:

* obnovu přihlášení,
* správu aktivních relací,
* odhlášení zařízení,
* bezpečnostní audit.

## 5.4 AccountConsent

Reprezentuje uživatelský souhlas.

Příklady:

* podmínky používání,
* zásady ochrany soukromí,
* analytika,
* AI zpracování,
* přístup ke zdravotním datům,
* konkrétní integrace.

Každý souhlas musí mít:

* typ,
* verzi textu,
* datum,
* stav,
* případné odvolání.

---

# 6. Athlete Profile

Tato oblast obsahuje dlouhodobý sportovní profil uživatele.

## 6.1 AthleteProfile

Hlavní agregovaný profil sportovce.

Obsahuje odkazy na:

* základní údaje,
* sporty,
* cíle,
* dostupnost,
* vybavení,
* omezení,
* preference,
* úroveň automatizace AI.

Nemá duplikovat detailní data ostatních objektů.

## 6.2 PersonalAttributes

Může obsahovat údaje relevantní pro plánování:

* datum narození nebo věkové rozmezí,
* výšku,
* hmotnost,
* biologické údaje pouze tam, kde jsou skutečně potřebné,
* preferované jednotky.

Citlivé údaje musí být volitelné, pokud nejsou právně nebo funkčně nezbytné.

## 6.3 TrainingPreference

Reprezentuje preference uživatele.

Například:

* preferovaná délka workoutu,
* preferovaná část dne,
* maximální počet workoutů denně,
* preferovaný odpočinkový den,
* stručnost vysvětlení,
* oblíbené a neoblíbené aktivity,
* tolerance změn plánu.

## 6.4 AutomationPreference

Určuje, co může AI nebo systém provádět automaticky.

Příklady:

* pouze doporučení,
* návrhy vyžadující potvrzení,
* automatické přesunutí flexibilní aktivity,
* automatická změna připomenutí,
* automatické zkrácení nízkoprioritního workoutu.

Významné akce zůstávají zakázané bez explicitního potvrzení.

---

# 7. Sports

Tato oblast reprezentuje sporty a pohybové disciplíny uživatele.

## 7.1 SportDefinition

Systémová definice sportu.

Příklady:

* běh,
* fotbal,
* florbal,
* silový trénink,
* lezení,
* cyklistika.

Obsahuje obecné charakteristiky:

* kategorii,
* typické fyzické nároky,
* podporované metriky,
* případné specializované funkce.

SportDefinition není uživatelský záznam.

## 7.2 UserSport

Reprezentuje vztah konkrétního uživatele ke sportu.

Obsahuje:

* uživatelský nebo systémový název,
* vazbu na SportDefinition, pokud existuje,
* roli sportu,
* zkušenostní úroveň,
* frekvenci,
* prioritu,
* sezonní stav,
* soutěžní nebo rekreační charakter,
* uživatelské poznámky.

Role sportu může být:

* hlavní,
* vedlejší,
* doplňkový,
* příležitostný,
* dočasně neaktivní.

## 7.3 CustomSportProfile

Používá se pro vlastní nebo neznámý sport.

Může obsahovat:

* uživatelský název,
* vytrvalostní náročnost,
* silovou náročnost,
* rychlostní náročnost,
* mobilitní nároky,
* koordinační nároky,
* kontaktnost,
* hlavní zatížené oblasti,
* typickou intenzitu,
* typickou délku,
* potřebu regenerace.

Tím lze sport zapojit do plánování i bez specializovaného modulu.

## 7.4 SportSeason

Reprezentuje sezonní období sportu.

Příklady stavů:

* přípravné období,
* soutěžní období,
* přechodné období,
* mimo sezonu,
* pozastaveno.

SportSeason může mít:

* začátek,
* konec,
* prioritu,
* poznámku,
* očekávané události.

---

# 8. Goals

Tato oblast reprezentuje dlouhodobé a krátkodobé cíle.

## 8.1 Goal

Základní objekt cíle.

Obsahuje:

* název,
* popis,
* typ,
* prioritu,
* stav,
* termín,
* důvod,
* výchozí stav,
* cílový stav,
* způsob vyhodnocení,
* vazbu na sporty,
* vazbu na plán.

## 8.2 Typy cílů

Minimálně:

* výkonový,
* silový,
* vytrvalostní,
* mobilitní,
* návykový,
* kvalitativní,
* termínovaná událost,
* návrat po pauze,
* udržovací,
* obecný vlastní cíl.

## 8.3 GoalPriority

Příklady:

* hlavní,
* vysoká,
* střední,
* nízká,
* pozastavená.

Systém nesmí automaticky považovat všechny cíle za stejně důležité.

## 8.4 GoalStatus

Příklady:

* návrh,
* aktivní,
* pozastavený,
* dokončený,
* opuštěný,
* nahrazený,
* archivovaný.

## 8.5 GoalMetric

Reprezentuje metriku používanou pro vyhodnocení cíle.

Například:

* počet shybů,
* čas závodu,
* vzdálenost,
* frekvence tréninku,
* rozsah pohybu,
* subjektivní hodnocení.

Ne každý cíl musí mít jedinou číselnou metriku.

## 8.6 GoalMilestone

Dílčí milník.

Obsahuje:

* název,
* pořadí,
* termín,
* očekávanou hodnotu,
* stav,
* datum dosažení.

## 8.7 GoalRelationship

Reprezentuje vztah mezi cíli.

Příklady:

* podporuje,
* je v konfliktu,
* je podřízený,
* nahrazuje,
* závisí na.

---

# 9. Scheduling and Availability

Tato oblast reprezentuje časový rámec uživatele.

## 9.1 AvailabilityRule

Reprezentuje běžnou dostupnost uživatele.

Obsahuje:

* den v týdnu,
* časové okno,
* preferenci,
* maximální délku,
* platnost,
* typ dostupnosti.

Typy:

* dostupný,
* preferovaný,
* náhradní,
* nedostupný.

## 9.2 AvailabilityException

Dočasná výjimka.

Příklady:

* pracovní cesta,
* dovolená,
* rodinná událost,
* období bez vybavení,
* dočasná změna směn.

Obsahuje:

* začátek,
* konec,
* důvod,
* upravenou dostupnost,
* dočasné prostředí,
* dočasné vybavení.

## 9.3 ScheduleEvent

Obecný kalendářní objekt.

Reprezentuje časově umístěnou událost.

Může být napojen na:

* WorkoutInstance,
* sportovní trénink,
* zápas,
* závod,
* odpočinek,
* regeneraci,
* vlastní událost.

Obsahuje:

* začátek,
* konec,
* časové pásmo,
* pevnost termínu,
* prioritu,
* opakování,
* stav.

## 9.4 EventFlexibility

Určuje, jak lze s událostí pracovat.

Příklady:

* pevná,
* flexibilní v rámci dne,
* flexibilní v rámci týdne,
* volitelná,
* pouze orientační.

## 9.5 RecurrenceRule

Definuje opakování.

Používá se například pro:

* týmové tréninky,
* pravidelné lekce,
* ranní mobilitu,
* opakované workouty.

Konkrétní instance musí být oddělitelné od pravidla opakování.

## 9.6 ScheduleConflict

Reprezentuje zjištěný konflikt.

Příklady:

* časové překrytí,
* nedostatečná regenerace,
* chybějící vybavení,
* nepovolené prostředí,
* vysoká kumulovaná zátěž.

Konflikt může být:

* informační,
* varovný,
* blokující.

---

# 10. Training Planning

Tato oblast reprezentuje dlouhodobé plánování.

## 10.1 TrainingPlan

Hlavní dlouhodobý plán.

Obsahuje:

* název,
* stav,
* období,
* cíle,
* sporty,
* plánovací strategii,
* aktuální verzi,
* míru automatizace,
* autora návrhu.

## 10.2 TrainingPlanStatus

Příklady:

* koncept,
* čeká na potvrzení,
* aktivní,
* pozastavený,
* dokončený,
* nahrazený,
* zrušený,
* archivovaný.

## 10.3 TrainingPlanVersion

Neměnná verze plánu.

Každá významná změna vytváří novou verzi nebo změnovou sadu.

Obsahuje:

* číslo verze,
* čas vytvoření,
* důvod,
* zdroj,
* vazbu na předchozí verzi,
* souhrn změn.

## 10.4 TrainingBlock

Část plánu zaměřená na určité období nebo adaptaci.

Příklady:

* návratový blok,
* silový blok,
* příprava na závod,
* soutěžní blok,
* odlehčovací blok.

Obsahuje:

* období,
* hlavní zaměření,
* cíle,
* očekávanou zátěž,
* pravidla progrese.

## 10.5 TrainingWeek

Logická týdenní jednotka.

Obsahuje:

* období,
* hlavní cíl týdne,
* plánované workouty,
* pevné sportovní aktivity,
* doporučenou regeneraci,
* týdenní zátěž,
* stav revize.

TrainingWeek nemusí nutně odpovídat kalendářnímu pondělí až neděli, ale výchozí chování ano.

## 10.6 PlanningConstraint

Reprezentuje omezení plánování.

Příklady:

* maximální délka workoutu,
* zakázané dny,
* minimální rozestup,
* pevný zápas,
* dostupné vybavení,
* omezení pohybu,
* maximální počet náročných dnů.

## 10.7 PlanningRule

Reprezentuje deterministické pravidlo.

Příklady:

* těžké nohy neplánovat den před zápasem,
* nepřidávat tahový workout před lezeckým víkendem,
* po návratu z pauzy použít snížený objem,
* respektovat maximální délku uživatele.

Pravidla mohou být:

* globální,
* sportovní,
* uživatelská,
* dočasná,
* bezpečnostní.

---

# 11. Workouts

Tato oblast reprezentuje plánované strukturované tréninky.

## 11.1 WorkoutTemplate

Opakovatelná šablona workoutu.

Obsahuje:

* název,
* účel,
* typ,
* očekávanou délku,
* potřebné vybavení,
* části,
* pravidla progrese,
* podporované metriky.

Šablona není konkrétní kalendářní událost.

## 11.2 WorkoutInstance

Konkrétní plánovaný workout.

Obsahuje:

* vazbu na šablonu,
* datum a čas,
* plánované hodnoty,
* lokální úpravy,
* stav,
* prioritu,
* vazbu na plán,
* vazbu na cíle,
* omezení,
* zdroj vytvoření.

## 11.3 WorkoutInstanceStatus

Příklady:

* koncept,
* plánovaný,
* připravený,
* upravený,
* probíhající,
* pozastavený,
* dokončený,
* částečně dokončený,
* vynechaný,
* zrušený,
* přesunutý,
* nahrazený.

## 11.4 WorkoutSection

Logická část workoutu.

Příklady:

* warm-up,
* hlavní část,
* doplňková část,
* mobilita,
* cooldown.

## 11.5 ExerciseDefinition

Systémová nebo uživatelská definice cviku.

Obsahuje:

* název,
* popis,
* typ pohybu,
* zatížené oblasti,
* vybavení,
* obtížnost,
* varianty,
* případné instrukce.

## 11.6 WorkoutExercise

Konkrétní použití cviku ve workoutu.

Obsahuje:

* pořadí,
* plánované hodnoty,
* tempo,
* pauzu,
* variantu,
* poznámku,
* podmínky náhrady.

## 11.7 ExerciseSetPlan

Plán jedné série nebo pracovního úseku.

Podle typu může obsahovat:

* opakování,
* váhu,
* čas,
* vzdálenost,
* tempo,
* intenzitu,
* RPE,
* rezervu opakování,
* stranu těla.

## 11.8 WorkoutAlternative

Povolená alternativa workoutu nebo cviku.

Příklady:

* kratší varianta,
* varianta bez vybavení,
* lehčí varianta,
* varianta při lokální únavě,
* cestovní varianta.

## 11.9 MicroWorkout

Krátká doplňková jednotka.

Příklady:

* ranní mobilita,
* krátká aktivace,
* desetiminutový core,
* dechová rutina.

Může být reprezentován jako specializovaný WorkoutTemplate nebo typ workoutu, nikoliv zcela oddělený systém.

---

# 12. Workout Execution

Tato oblast reprezentuje průběh skutečného workoutu.

## 12.1 WorkoutSession

Aktivní nebo dokončené provádění WorkoutInstance.

Obsahuje:

* čas zahájení,
* čas ukončení,
* stav,
* skutečnou délku,
* vazbu na zařízení,
* offline stav,
* subjektivní hodnocení.

## 12.2 ExercisePerformance

Skutečné provedení konkrétního cviku.

Obsahuje:

* vazbu na plánovaný cvik,
* skutečnou variantu,
* stav,
* poznámku,
* případný důvod změny.

## 12.3 SetPerformance

Skutečné provedení série.

Může obsahovat:

* opakování,
* váhu,
* čas,
* vzdálenost,
* tempo,
* intenzitu,
* RPE,
* stav dokončení,
* časový záznam.

## 12.4 WorkoutSessionStatus

Příklady:

* nezačatý,
* probíhající,
* pozastavený,
* dokončený,
* částečně dokončený,
* ukončený,
* zahozený.

## 12.5 WorkoutFeedback

Subjektivní zpětná vazba po workoutu.

Obsahuje:

* celkovou náročnost,
* energii,
* spokojenost,
* bolest,
* poznámku,
* pocit splnění účelu.

---

# 13. Activities

Aktivita reprezentuje skutečně provedený pohyb.

## 13.1 Activity

Obecný historický záznam aktivity.

Může vzniknout:

* dokončením WorkoutSession,
* ručním přidáním,
* importem,
* GPS trackingem,
* potvrzením týmového tréninku nebo zápasu.

Obsahuje:

* název,
* sport,
* typ,
* začátek,
* konec,
* délku,
* intenzitu,
* zdroj,
* vazbu na plánovaný objekt,
* stav synchronizace.

## 13.2 ActivitySource

Příklady:

* workout tracker,
* ruční zadání,
* Health Connect,
* Apple Health,
* Garmin,
* Strava,
* vlastní GPS tracker.

## 13.3 ActivityMatch

Reprezentuje vztah importované nebo ruční aktivity k plánované aktivitě.

Stavy:

* přesná shoda,
* pravděpodobná shoda,
* částečná náhrada,
* jiná aktivita,
* nepotvrzeno.

## 13.4 ActivityMetric

Obecná naměřená nebo zadaná hodnota.

Příklady:

* vzdálenost,
* tempo,
* tep,
* převýšení,
* energetický výdej,
* počet kroků,
* subjektivní intenzita.

## 13.5 ActivityLoad

Normalizovaný popis zátěže.

Může obsahovat:

* celkovou intenzitu,
* vytrvalostní zátěž,
* silovou zátěž,
* lokální zatížení,
* subjektivní náročnost,
* spolehlivost odhadu.

Nesmí předstírat vyšší přesnost, než umožňují data.

---

# 14. Recovery and Readiness

Tato oblast obsahuje informace o regeneraci a připravenosti.

## 14.1 DailyCheckIn

Subjektivní denní vstup.

Může obsahovat:

* energii,
* únavu,
* motivaci,
* kvalitu spánku,
* stres,
* svalovou bolest,
* poznámku.

## 14.2 SleepRecord

Záznam spánku.

Může pocházet:

* od uživatele,
* z wearables,
* z Health Connect,
* z Apple Health.

Obsahuje:

* začátek,
* konec,
* délku,
* kvalitu,
* zdroj,
* úplnost,
* důvěryhodnost.

## 14.3 RecoveryMetric

Obecná regenerační metrika.

Příklady:

* HRV,
* klidový tep,
* subjektivní únava,
* kvalita spánku.

Každá hodnota musí mít:

* zdroj,
* čas,
* jednotku,
* kvalitu,
* případnou normalizaci.

## 14.4 ReadinessAssessment

Vyhodnocení připravenosti.

Není to zdravotní diagnóza.

Obsahuje:

* výsledný stav,
* vysvětlení,
* vstupní data,
* míru nejistoty,
* čas platnosti,
* doporučené akce.

## 14.5 ReadinessLevel

Příklady:

* neznámá,
* nízká,
* snížená,
* běžná,
* vysoká.

Systém nesmí používat pouze jednu metriku jako definitivní výsledek.

---

# 15. Limitations and Pain

Tato oblast reprezentuje omezení, bolest a relevantní doporučení.

## 15.1 Limitation

Obecné omezení ovlivňující plánování.

Typy:

* dlouhodobé,
* dočasné,
* pohybové,
* sportovní,
* vybavení,
* odborné doporučení,
* uživatelská preference.

Obsahuje:

* popis,
* začátek,
* konec,
* stav,
* zdroj,
* ovlivněné oblasti,
* zakázané nebo omezené pohyby.

## 15.2 PainReport

Konkrétní hlášení bolesti.

Obsahuje:

* oblast těla,
* stranu,
* intenzitu,
* charakter,
* vznik,
* zhoršující pohyby,
* bolest v klidu,
* úraz,
* poznámku,
* čas.

PainReport není diagnóza.

## 15.3 PainAssessment

Bezpečnostní vyhodnocení vstupu.

Může určit:

* běžná svalová bolest,
* nejasný stav,
* zvýšené riziko,
* nutnost přerušení aktivity,
* doporučení odborné konzultace.

Musí uchovávat:

* použitá pravidla,
* nejistotu,
* doporučený další krok.

## 15.4 BodyArea

Standardizovaná oblast těla.

Musí podporovat:

* stranu,
* obecnou oblast,
* jemnější strukturu podle potřeby.

Nesmí se ukládat pouze jako volný text.

## 15.5 LimitationImpact

Vztah omezení k:

* cviku,
* sportu,
* workoutu,
* části těla,
* typu pohybu.

Umožňuje zjistit, které budoucí workouty mohou být ovlivněny.

---

# 16. Equipment and Environment

## 16.1 EquipmentDefinition

Systémová definice vybavení.

Příklady:

* hrazda,
* kettlebell,
* jednoručky,
* odporová guma,
* podložka,
* běžecký pás.

## 16.2 EquipmentItem

Konkrétní vybavení uživatele.

Obsahuje:

* název,
* typ,
* množství,
* parametry,
* místo,
* stav,
* dostupnost,
* platnost.

## 16.3 CustomEquipment

Uživatelsky definované vybavení, pokud není v katalogu.

## 16.4 TrainingEnvironment

Prostředí.

Příklady:

* doma,
* fitko,
* venku,
* hotel,
* sportovní hala,
* lezecká stěna,
* skály.

## 16.5 EquipmentAvailability

Určuje, kdy a kde je vybavení dostupné.

Příklady:

* trvale doma,
* pouze ve fitku,
* jen během dovolené,
* dočasně nedostupné.

---

# 17. AI Coaching

Tato oblast reprezentuje AI komunikaci a návrhy.

## 17.1 AIConversation

Logická konverzace s AI trenérem.

Obsahuje:

* název nebo téma,
* stav,
* kontext,
* čas vytvoření,
* poslední aktivitu.

## 17.2 AIMessage

Jedna zpráva v konverzaci.

Obsahuje:

* roli,
* obsah,
* strukturované přílohy,
* čas,
* stav,
* použitý kontext.

Citlivý text musí mít odpovídající pravidla ukládání a ochrany.

## 17.3 AIContextReference

Explicitní odkaz na objekt, kterého se konverzace týká.

Například:

* workout,
* den,
* týden,
* cíl,
* plán,
* aktivita,
* omezení.

## 17.4 AIProposal

Strukturovaný návrh AI.

Obsahuje:

* typ,
* důvod,
* rozsah,
* vstupní kontext,
* navržené akce,
* rizika,
* stav,
* dobu platnosti,
* vazbu na změnovou sadu.

## 17.5 AIProposalStatus

Příklady:

* koncept,
* čeká na doplnění,
* připraven,
* částečně potvrzen,
* potvrzen,
* odmítnut,
* proveden,
* vrácen,
* expirovaný,
* zastaralý,
* neplatný.

## 17.6 AIToolDefinition

Definice povoleného nástroje.

Obsahuje:

* název,
* účel,
* vstupní schéma,
* validační pravidla,
* požadované oprávnění,
* úroveň rizika,
* potřebu potvrzení.

## 17.7 AIToolInvocation

Konkrétní pokus o použití nástroje.

Obsahuje:

* nástroj,
* vstup,
* výsledek validace,
* stav,
* chybu,
* čas,
* vazbu na návrh.

## 17.8 AIModelExecution

Technický audit jednoho volání modelu.

Může obsahovat:

* typ požadavku,
* model,
* dobu trvání,
* stav,
* náklady nebo tokeny,
* technický identifikátor.

Nemá být běžně zobrazován uživateli.

---

# 18. Change Management

Tato oblast je klíčová pro vratnost a historii.

## 18.1 ChangeSet

Skupina souvisejících změn provedených jako jedna logická akce.

Příklad:

* přidání lezeckého víkendu,
* přesun dvou workoutů,
* zrušení jednoho workoutu,
* přidání regenerace.

Obsahuje:

* název,
* důvod,
* zdroj,
* stav,
* čas,
* uživatele nebo AI,
* seznam změn,
* možnost vrácení.

## 18.2 ChangeOperation

Jedna atomická změna.

Typy:

* create,
* update,
* move,
* cancel,
* replace,
* archive,
* restore.

Obsahuje:

* typ objektu,
* identifikátor objektu,
* původní hodnotu,
* novou hodnotu,
* pořadí,
* stav.

## 18.3 ChangeSource

Příklady:

* uživatel,
* AI návrh,
* AI automatizace,
* systémové pravidlo,
* import,
* administrativní zásah.

## 18.4 ChangeSetStatus

Příklady:

* koncept,
* čeká na potvrzení,
* částečně schválen,
* schválen,
* aplikován,
* selhal,
* částečně aplikován,
* vrácen,
* nelze vrátit.

## 18.5 UndoOperation

Reprezentuje návrat změny.

Musí zohlednit:

* závislé změny,
* dokončené aktivity,
* novější verze,
* částečnou vratnost.

## 18.6 AuditRecord

Neměnný auditní záznam.

Obsahuje:

* objekt,
* operaci,
* čas,
* aktéra,
* technický kontext,
* důvod,
* výsledek.

---

# 19. Progress and Metrics

## 19.1 MetricDefinition

Definice metriky.

Příklady:

* počet opakování,
* maximální váha,
* čas,
* vzdálenost,
* pravidelnost,
* rozsah pohybu,
* subjektivní únava.

Obsahuje:

* název,
* jednotku,
* typ,
* způsob agregace,
* podporované sporty,
* význam.

## 19.2 MetricValue

Jedna konkrétní hodnota.

Obsahuje:

* metriku,
* hodnotu,
* čas,
* zdroj,
* spolehlivost,
* vazbu na aktivitu nebo cíl.

## 19.3 ProgressSnapshot

Souhrnný stav pokroku k určitému datu.

Může obsahovat:

* hodnoty cílů,
* trendy,
* adherence,
* důležité výkony,
* stav plánu.

## 19.4 PersonalRecord

Osobní rekord.

Obsahuje:

* metriku,
* hodnotu,
* datum,
* zdroj,
* aktivitu,
* stav ověření.

## 19.5 AdherenceMetric

Vyhodnocuje vztah mezi plánem a skutečností.

Nesmí počítat pouze prosté procento dokončení.

Musí zohlednit:

* náhradní aktivity,
* částečné workouty,
* oprávněné změny,
* zrušené události,
* změny plánu.

## 19.6 WeeklyReview

Týdenní revize.

Obsahuje:

* plán,
* skutečnost,
* změny,
* subjektivní stav,
* hlavní výsledky,
* problémy,
* návrh dalšího týdne,
* stav potvrzení.

---

# 20. Notifications

## 20.1 NotificationPreference

Uživatelské nastavení typu notifikace.

Příklady:

* ranní přehled,
* připomenutí workoutu,
* AI návrh,
* týdenní revize,
* synchronizační problém.

## 20.2 NotificationSchedule

Definuje plánované doručení.

Obsahuje:

* čas,
* časové pásmo,
* typ,
* cílový objekt,
* deep link,
* citlivost obsahu.

## 20.3 NotificationDelivery

Záznam konkrétního doručení.

Stavy:

* plánováno,
* odesláno,
* doručeno,
* otevřeno,
* selhalo,
* zrušeno.

## 20.4 NotificationAction

Akce z notifikace.

Příklady:

* otevřít workout,
* odložit připomenutí,
* označit jako dokončené,
* otevřít AI návrh.

---

# 21. Integrations

## 21.1 IntegrationProvider

Definice externí služby.

Příklady:

* Apple Health,
* Health Connect,
* Garmin,
* Strava.

## 21.2 UserIntegration

Připojení konkrétního uživatele.

Obsahuje:

* poskytovatele,
* stav,
* rozsah oprávnění,
* poslední synchronizaci,
* chybu,
* konfiguraci.

## 21.3 IntegrationCredential

Citlivé tokeny a přihlašovací údaje.

Musí být:

* šifrované,
* oddělené od běžného profilu,
* omezené přístupem,
* auditované.

## 21.4 ExternalDataRecord

Původní nebo normalizovaný záznam z externí služby.

Obsahuje:

* externí identifikátor,
* poskytovatele,
* typ,
* čas,
* hash nebo verzi,
* stav zpracování.

## 21.5 DataImportJob

Jedna synchronizační úloha.

Obsahuje:

* poskytovatele,
* období,
* stav,
* počet záznamů,
* chyby,
* duplicity.

## 21.6 DataProvenance

Informace o původu dat.

Musí být zachováno:

* odkud data přišla,
* zda byla změněna,
* zda byla sloučena,
* zda ji uživatel ručně opravil.

---

# 22. Synchronization and Offline

## 22.1 LocalEntityState

Lokální stav objektu.

Příklady:

* synchronizovaný,
* lokálně vytvořený,
* lokálně změněný,
* čeká na smazání,
* konflikt,
* chyba.

## 22.2 SyncOperation

Jedna čekající synchronizační operace.

Obsahuje:

* objekt,
* typ operace,
* lokální verzi,
* serverovou verzi,
* počet pokusů,
* poslední chybu.

## 22.3 EntityVersion

Technická verze objektu používaná pro řešení konfliktů.

Nesmí být zaměněna s produktovou TrainingPlanVersion.

## 22.4 SyncConflict

Skutečný konflikt mezi dvěma změnami.

Obsahuje:

* objekt,
* lokální stav,
* serverový stav,
* typ konfliktu,
* doporučené řešení,
* stav uživatelského rozhodnutí.

## 22.5 OfflineCommand

Akce provedená offline, která čeká na serverové zpracování.

Například:

* dokončení workoutu,
* přesun workoutu,
* vytvoření aktivity,
* zápis check-inu.

AI akce mohou vyžadovat online stav a nemají být předstírány jako dokončené offline.

---

# 23. Privacy and Data Management

## 23.1 DataClassification

Každý typ dat musí mít klasifikaci.

Příklady:

* běžná,
* osobní,
* citlivá,
* zdravotně relevantní,
* autentizační,
* finanční,
* technická.

## 23.2 DataRetentionRule

Určuje dobu a důvod uchování dat.

## 23.3 DataExportRequest

Požadavek na export.

Obsahuje:

* rozsah,
* formát,
* stav,
* čas vytvoření,
* čas expirace,
* bezpečnostní ověření.

## 23.4 AccountDeletionRequest

Požadavek na smazání účtu.

Obsahuje:

* stav,
* čas,
* ochrannou lhůtu,
* výjimky,
* dokončení.

## 23.5 DataAccessLog

Audit přístupu k citlivým datům.

Používá se zejména pro:

* administrativní přístup,
* export,
* integrace,
* bezpečnostní incidenty.

---

# 24. Hlavní agregáty

Agregát představuje skupinu objektů, které se mění konzistentně prostřednictvím jednoho hlavního objektu.

## 24.1 UserAccount Aggregate

Kořen:

* UserAccount

Obsahuje nebo spravuje:

* AuthenticationIdentity,
* UserSession,
* AccountConsent.

## 24.2 AthleteProfile Aggregate

Kořen:

* AthleteProfile

Spravuje vztahy na:

* TrainingPreference,
* AutomationPreference,
* UserSport,
* EquipmentItem,
* základní osobní nastavení.

## 24.3 Goal Aggregate

Kořen:

* Goal

Obsahuje:

* GoalMetric,
* GoalMilestone,
* GoalRelationship.

## 24.4 TrainingPlan Aggregate

Kořen:

* TrainingPlan

Obsahuje:

* TrainingPlanVersion,
* TrainingBlock,
* TrainingWeek,
* PlanningConstraint,
* odkazy na WorkoutInstance.

WorkoutInstance může být samostatným agregátem kvůli velikosti, offline práci a životnímu cyklu.

## 24.5 Workout Aggregate

Kořen:

* WorkoutInstance

Obsahuje:

* WorkoutSection,
* WorkoutExercise,
* ExerciseSetPlan.

## 24.6 WorkoutSession Aggregate

Kořen:

* WorkoutSession

Obsahuje:

* ExercisePerformance,
* SetPerformance,
* WorkoutFeedback.

Musí být optimalizován pro časté offline ukládání.

## 24.7 Activity Aggregate

Kořen:

* Activity

Obsahuje:

* ActivityMetric,
* ActivityLoad,
* ActivityMatch.

## 24.8 Limitation Aggregate

Kořen:

* Limitation nebo PainReport podle konkrétního případu.

## 24.9 AIProposal Aggregate

Kořen:

* AIProposal

Obsahuje:

* navržené AIToolInvocation,
* odkazy na ChangeSet,
* stav potvrzení.

## 24.10 ChangeSet Aggregate

Kořen:

* ChangeSet

Obsahuje:

* ChangeOperation,
* UndoOperation,
* související AuditRecord.

---

# 25. Hlavní vztahy

## 25.1 Uživatel a sporty

```text
UserAccount
    1
    │
    1
AthleteProfile
    1
    │
    *
UserSport
```

Jeden uživatel může mít libovolný počet sportů.

## 25.2 Uživatel a cíle

```text
AthleteProfile
    1
    │
    *
Goal
```

Cíl může souviset s více sporty.

## 25.3 Cíl a plán

```text
Goal * ─── * TrainingPlan
```

Jeden plán může podporovat více cílů a jeden cíl může být podporován více po sobě jdoucími plány.

## 25.4 Plán a workout

```text
TrainingPlan
    1
    │
    *
WorkoutInstance
```

WorkoutInstance může existovat i bez dlouhodobého plánu jako ručně vytvořený workout.

## 25.5 Workout a provedení

```text
WorkoutInstance
    1
    │
    0..*
WorkoutSession
```

Ve většině případů bude mít workout jednu hlavní session.

Model však může podporovat:

* přerušené pokusy,
* opakované spuštění,
* opravený záznam.

## 25.6 Workout a aktivita

```text
WorkoutSession
    0..1
    │
    1
Activity
```

Po dokončení workoutu vznikne skutečná Activity.

## 25.7 Plánovaná a importovaná aktivita

```text
ScheduleEvent
    0..1
    │
    0..*
ActivityMatch
    *
    │
    1
Activity
```

## 25.8 AI návrh a změny

```text
AIProposal
    1
    │
    0..1
ChangeSet
    1
    │
    *
ChangeOperation
```

---

# 26. Životní cyklus tréninkového plánu

## 26.1 Koncept

Plán je vytvořen, ale není aktivní.

Uživatel ho může upravovat bez dopadu na kalendář.

## 26.2 Čeká na potvrzení

Plán je připravený k aktivaci.

## 26.3 Aktivní

Plán vytváří nebo řídí budoucí workouty.

## 26.4 Upravený

Vzniká nová verze nebo ChangeSet.

Původní verze zůstává zachována.

## 26.5 Pozastavený

Dočasně nevytváří nové workouty nebo se nevyhodnocuje.

## 26.6 Dokončený

Plán dosáhl konce období.

## 26.7 Nahrazený

Nový plán převzal jeho roli.

## 26.8 Archivovaný

Zůstává dostupný v historii.

---

# 27. Životní cyklus workoutu

```text
Koncept
   ↓
Plánovaný
   ↓
Připravený
   ↓
Probíhající
   ↓
Pozastavený
   ↓
Dokončený
```

Alternativní větve:

```text
Plánovaný → Přesunutý
Plánovaný → Zrušený
Plánovaný → Vynechaný
Plánovaný → Nahrazený
Probíhající → Částečně dokončený
Probíhající → Ukončený
```

Přesunutý workout může být reprezentován:

* změnou času stejné instance,
* nebo nahrazením původní instance novou,

podle požadavků historie a synchronizace.

Finální rozhodnutí bude popsáno v detailním workout modelu.

---

# 28. Životní cyklus AI návrhu

```text
Koncept
   ↓
Čeká na doplnění
   ↓
Připraven
   ↓
Čeká na potvrzení
   ↓
Potvrzen
   ↓
Proveden
```

Alternativní stavy:

* částečně potvrzen,
* odmítnut,
* zastaralý,
* expirovaný,
* selhal,
* vrácen.

AI návrh musí být označen jako zastaralý, pokud se změnil objekt, ze kterého vycházel.

---

# 29. Životní cyklus omezení

```text
Návrh
   ↓
Aktivní
   ↓
Ukončené
   ↓
Archivované
```

Dočasné omezení může mít automatické datum ukončení.

Po skončení omezení se plán nesmí automaticky vrátit k plné zátěži bez vyhodnocení, pokud by to bylo rizikové.

---

# 30. Rozdíl mezi šablonou a instancí

Tento rozdíl je zásadní.

## 30.1 WorkoutTemplate

Popisuje obecnou strukturu.

Například:

> Upper Body A

## 30.2 WorkoutInstance

Konkrétní výskyt.

Například:

> Upper Body A, úterý 18. srpna v 18:00

## 30.3 WorkoutSession

Skutečné provedení.

Například:

> Uživatel začal v 18:12, dokončil 4 z 5 cviků a snížil shyby ze 4 sérií na 3.

## 30.4 Activity

Historický sportovní záznam vytvořený z provedení.

Tím systém zachová:

* plán,
* konkrétní upravenou instanci,
* skutečné provedení,
* historickou aktivitu.

---

# 31. Rozdíl mezi pravidelnou událostí a instancí

Například pravidelný florbal každou středu.

## 31.1 RecurrenceRule

Definuje:

> Každou středu v 19:00.

## 31.2 ScheduleEvent Instance

Definuje:

> Středa 19. srpna v 19:00.

Konkrétní instance může být:

* zrušena,
* přesunuta,
* upravena,
* dokončena,

aniž by se měnila celá série.

---

# 32. Zdroj pravdy podle oblasti

| Informace                    | Hlavní zdroj pravdy   |
| ---------------------------- | --------------------- |
| Stav účtu                    | UserAccount           |
| Sportovní profil             | AthleteProfile        |
| Sport uživatele              | UserSport             |
| Cíl                          | Goal                  |
| Běžná dostupnost             | AvailabilityRule      |
| Dočasná změna dostupnosti    | AvailabilityException |
| Pravidelný rozvrh            | RecurrenceRule        |
| Konkrétní kalendářní událost | ScheduleEvent         |
| Dlouhodobý plán              | TrainingPlan          |
| Verze plánu                  | TrainingPlanVersion   |
| Plánovaný workout            | WorkoutInstance       |
| Průběh workoutu              | WorkoutSession        |
| Skutečná aktivita            | Activity              |
| Denní subjektivní stav       | DailyCheckIn          |
| Bolest                       | PainReport            |
| Aktivní omezení              | Limitation            |
| Vybavení                     | EquipmentItem         |
| AI návrh                     | AIProposal            |
| Provedená skupina změn       | ChangeSet             |
| Historie změny               | AuditRecord           |
| Metrika pokroku              | MetricValue           |
| Připojená služba             | UserIntegration       |

---

# 33. Doménové události

Doménová událost vyjadřuje, že se v systému stalo něco významného.

Příklady:

* UserRegistered
* OnboardingCompleted
* UserSportAdded
* GoalCreated
* GoalPriorityChanged
* TrainingPlanDrafted
* TrainingPlanActivated
* TrainingPlanVersionCreated
* WorkoutScheduled
* WorkoutRescheduled
* WorkoutStarted
* WorkoutPaused
* WorkoutCompleted
* ActivityImported
* ActivityMatched
* PainReported
* LimitationActivated
* LimitationExpired
* DailyCheckInRecorded
* AIProposalCreated
* AIProposalApproved
* ChangeSetApplied
* ChangeSetReverted
* WeeklyReviewCompleted
* IntegrationConnected
* SyncConflictDetected
* AccountDeletionRequested

Doménové události mohou později spouštět:

* notifikace,
* synchronizaci,
* analytiku,
* přepočet statistik,
* AI revizi,
* audit.

---

# 34. Příklady hlavních příkazů

Příkaz reprezentuje požadavek na změnu systému.

Příklady:

* CreateGoal
* AddUserSport
* UpdateAvailability
* CreateTrainingPlanDraft
* ActivateTrainingPlan
* ScheduleWorkout
* RescheduleWorkout
* StartWorkoutSession
* RecordSetPerformance
* CompleteWorkoutSession
* ReportPain
* CreateTemporaryLimitation
* CreateAIProposal
* ApproveAIProposal
* ApplyChangeSet
* RevertChangeSet
* ConnectIntegration
* ResolveSyncConflict

Příkazy musí být validovány před změnou dat.

---

# 35. Doménové invariance

Invariant je pravidlo, které musí být vždy pravdivé.

## 35.1 Účet

* Každý doménový objekt patří právě jednomu uživateli, pokud není explicitně systémový.
* Cizí uživatel nesmí objekt zobrazit ani změnit.

## 35.2 Workout

* Dokončený workout nesmí být zpětně změněn na plánovaný bez auditované opravy.
* Skutečný výkon nesmí být přepsán plánovanými hodnotami.
* WorkoutSession musí být navázána na jednoho uživatele.

## 35.3 Plán

* Aktivní plán musí mít alespoň jeden cíl nebo jasně definovaný účel.
* Nová verze plánu nesmí odstranit starou verzi.
* Potvrzené historické aktivity nesmí být odstraněny změnou plánu.

## 35.4 AI

* AIProposal nesmí být proveden bez validace.
* Akce vyžadující potvrzení nesmí být provedena bez platného potvrzení.
* AI nesmí měnit objekt jiného uživatele.
* Zastaralý návrh nesmí být automaticky proveden.

## 35.5 Omezení

* Dočasné omezení musí mít datum ukončení nebo explicitní způsob ukončení.
* PainReport nesmí být uložen jako diagnóza.
* Závažný bezpečnostní stav nesmí vést k běžnému generickému workoutu bez varování.

## 35.6 Synchronizace

* Konflikt nesmí automaticky odstranit neodeslaná workout data.
* Každá lokální změna musí mít stabilní identifikátor.
* Opakované zpracování stejné operace nesmí vytvářet duplicity.

---

# 36. Identifikátory

Každý hlavní objekt musí mít globálně jedinečný identifikátor.

Doporučené vlastnosti:

* vytvořitelný offline,
* bezpečný pro synchronizaci,
* nezávislý na pořadí databáze,
* neměnný po celý život objektu.

Konkrétní formát bude určen v technické architektuře.

Možnosti:

* UUID,
* UUIDv7,
* ULID.

Pro offline-first systém je nevhodné spoléhat pouze na databázové auto-increment identifikátory.

---

# 37. Čas a časová pásma

Všechny časové objekty musí rozlišovat:

* okamžik v UTC,
* uživatelské časové pásmo,
* lokální datum,
* lokální čas,
* případně původní časové pásmo události.

To je důležité pro:

* cestování,
* notifikace,
* opakované události,
* závody v zahraničí,
* synchronizaci mezi zařízeními.

Opakované události musí být definovány vůči zamýšlenému lokálnímu času, ne pouze jako opakování UTC okamžiku.

---

# 38. Mazání a archivace

Většina historicky významných objektů se nemá fyzicky mazat běžnou uživatelskou akcí.

Preferované chování:

* archivace,
* zrušení,
* ukončení platnosti,
* soft delete.

Týká se zejména:

* sportů s historií,
* cílů,
* plánů,
* workoutů,
* aktivit,
* omezení,
* AI návrhů,
* změnových sad.

Fyzické odstranění se používá zejména:

* při smazání účtu,
* u omylem vytvořených objektů bez návazností,
* podle pravidel ochrany dat.

---

# 39. Podpora obecného sportu

Každý sport musí být možné reprezentovat minimálně pomocí:

* názvu,
* kategorie,
* délky,
* intenzity,
* frekvence,
* fyzických nároků,
* zatížených oblastí,
* pevnosti termínu,
* potřeby regenerace,
* uživatelského hodnocení.

Specializované sportovní moduly mohou přidat:

* specifické metriky,
* specializovaný tracker,
* sportovní pravidla,
* doporučené workouty,
* pokročilé analýzy.

Obecná funkčnost však nesmí být závislá na jejich existenci.

---

# 40. Rozšiřitelnost metrik

Metriky nesmí být zakódovány pouze jako pevné sloupce v jednom objektu.

Systém musí být připraven na:

* různé jednotky,
* různé sporty,
* uživatelské metriky,
* nové wearable datové typy,
* kvalitativní hodnoty,
* časové řady.

Současně nesmí vzniknout nekontrolovaný systém libovolných klíčů bez validace.

MetricDefinition určuje význam, jednotku a způsob použití metriky.

---

# 41. Rozšiřitelnost workoutů

Workout musí podporovat různé struktury.

Příklady:

## Silový workout

* cviky,
* série,
* opakování,
* váha,
* pauza.

## Intervalový běh

* warm-up,
* intervaly,
* tempo,
* čas,
* cooldown.

## Mobilita

* pozice,
* délka,
* strana,
* opakování,
* dech.

## Týmový trénink

* čas,
* délka,
* subjektivní intenzita,
* poznámka.

## Vlastní aktivita

* uživatelský název,
* délka,
* obecná intenzita,
* poznámka.

Model proto musí podporovat společný základ a typově specifické detaily.

---

# 42. Read modely

Backend a mobilní aplikace nemusí pro každou obrazovku načítat celý doménový agregát.

Mohou používat specializované read modely.

Příklady:

* TodayOverview
* WeeklyCalendarView
* WorkoutDetailView
* ActiveWorkoutView
* ProgressOverview
* AthleteProfileSummary
* PendingAIProposalSummary
* WeeklyReviewSummary

Read modely:

* nejsou zdrojem pravdy,
* jsou odvozené,
* mohou být optimalizované pro zobrazení,
* mohou být lokálně cacheované.

---

# 43. Doménové služby

Některá pravidla nepatří přirozeně jednomu objektu.

Příklady doménových služeb:

## PlanningService

* hledá vhodná tréninková okna,
* vyhodnocuje omezení,
* sestavuje deterministický plán.

## LoadAssessmentService

* vyhodnocuje kombinovanou zátěž,
* pracuje s více sporty,
* komunikuje nejistotu.

## WorkoutAdaptationService

* vytváří kratší nebo lehčí variantu,
* zachovává hlavní účel workoutu.

## ActivityMatchingService

* spojuje importovanou aktivitu s plánovanou.

## ChangeValidationService

* kontroluje AI a ruční změny,
* hledá konflikty,
* ověřuje oprávnění.

## ReadinessAssessmentService

* kombinuje subjektivní a automatická data.

## GoalProgressService

* vyhodnocuje vývoj cíle.

## SyncConflictResolutionService

* slučuje nekolidující změny,
* připravuje uživatelské porovnání.

---

# 44. Anti-corruption vrstvy integrací

Každá externí služba musí mít vlastní překladovou vrstvu.

Například:

```text
Garmin data
    ↓
Garmin adapter
    ↓
Internal Activity / SleepRecord / MetricValue
```

Externí pojmy se nesmí šířit přímo do doménového modelu.

Příklad:

* Garmin recovery score není interní ReadinessAssessment,
* Apple workout není přímo interní Activity bez převodu,
* Strava activity type není automaticky interní sportovní kategorie.

---

# 45. Příklady doménových scénářů

## 45.1 Uživatel vytvoří první plán

1. AthleteProfile obsahuje sporty, cíle a dostupnost.
2. PlanningService vytvoří TrainingPlan jako koncept.
3. Vznikne TrainingPlanVersion.
4. Vytvoří se WorkoutInstance objekty.
5. Uživatel plán potvrdí.
6. TrainingPlan přejde do stavu aktivní.
7. ScheduleEvent objekty se zobrazí v kalendáři.

## 45.2 Uživatel oznámí lezecký víkend

1. AIConversation přijme zprávu.
2. AI vytvoří AIProposal.
3. Proposal obsahuje návrh nové události a úprav workoutů.
4. ChangeValidationService návrh ověří.
5. Uživatel návrh potvrdí.
6. Vznikne ChangeSet.
7. ChangeSet vytvoří nebo upraví ScheduleEvent a WorkoutInstance.
8. AuditRecord uloží historii.
9. Kalendář zobrazí nový stav.

## 45.3 Uživatel dokončí workout offline

1. Lokálně vznikne WorkoutSession.
2. SetPerformance se ukládají průběžně.
3. WorkoutSession je dokončena.
4. Lokálně vznikne Activity.
5. SyncOperation čeká na připojení.
6. Po připojení backend operaci zpracuje idempotentně.
7. WorkoutInstance se na serveru označí jako dokončený.
8. Progress metriky se přepočítají.

## 45.4 Uživatel nahlásí bolest bicepsu

1. Vznikne PainReport.
2. PainAssessment vyhodnotí bezpečnost.
3. Systém najde ovlivněné cviky.
4. AI nebo WorkoutAdaptationService vytvoří návrh.
5. Uživatel změnu potvrdí.
6. Vznikne dočasné Limitation.
7. Změní se pouze relevantní budoucí workouty.
8. Historie původního plánu zůstane zachována.

---

# 46. Co nesmí být uloženo pouze jako text

Následující informace nesmí existovat pouze uvnitř AI konverzace nebo poznámky:

* sport,
* cíl,
* pravidelný trénink,
* dostupnost,
* vybavení,
* bolest,
* omezení,
* datum závodu,
* workout,
* změna plánu,
* potvrzení uživatele.

Volný text může být zachován jako původní vstup, ale musí být doplněn strukturovanou reprezentací.

---

# 47. Co může zůstat jako volný text

Příklady:

* osobní poznámka,
* důvod cíle,
* subjektivní komentář,
* poznámka k workoutu,
* popis pocitu,
* dodatečné vysvětlení,
* původní uživatelský prompt.

Volný text však nesmí nahrazovat data nutná pro bezpečnost, plánování nebo synchronizaci.

---

# 48. Otevřené doménové otázky

Následující otázky budou řešeny v detailních dokumentech:

* Má být ScheduleEvent samostatným agregátem, nebo projekcí z workoutů a aktivit?
* Jak přesně reprezentovat přesunutý workout?
* Jak oddělit WorkoutTemplate od sportovně specifických šablon?
* Jak obecně modelovat workout kroky bez ztráty typové bezpečnosti?
* Jak detailně ukládat svalové a pohybové zatížení?
* Jak reprezentovat uživatelsky definované metriky?
* Jak dlouho uchovávat detailní AI konverzace?
* Které změny vytvářejí novou verzi plánu a které pouze ChangeSet?
* Jak řešit více aktivních plánů?
* Jak spojit týmový trénink s Activity bez workout trackeru?
* Jak reprezentovat částečné nahrazení plánované aktivity?
* Jak přesně funguje idempotence offline příkazů?
* Jak řešit opakované workouty po ruční změně šablony?
* Jak verzovat ExerciseDefinition a instrukce?
* Jak pracovat s opraveným historickým záznamem?

---

# 49. Navazující dokumenty

Na tento přehled musí navázat minimálně:

```text
docs/06-domain/
├── domain-overview.md
├── identity-and-profile-model.md
├── sports-and-goals-model.md
├── scheduling-model.md
├── training-plan-model.md
├── workout-model.md
├── activity-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Detailní dokumenty mohou strukturu dále upravit, ale musí zůstat v souladu s produktovými principy.

---

# 50. Kritéria správného doménového modelu

Model je vhodný pouze tehdy, pokud umožní bez zásadní změny základní architektury:

1. přidat libovolný sport,
2. kombinovat více sportů,
3. vytvořit více cílů,
4. reprezentovat pevné i flexibilní události,
5. oddělit plán od skutečnosti,
6. provést workout offline,
7. importovat aktivitu z wearables,
8. spojit aktivitu s plánem,
9. upravit plán přes AI,
10. potvrdit nebo odmítnout změnu,
11. změnu vrátit,
12. zachovat historii,
13. reagovat na bolest a únavu,
14. podporovat různé workout trackery,
15. přidávat nové metriky,
16. změnit poskytovatele integrace,
17. synchronizovat více zařízení,
18. bezpečně smazat nebo exportovat data.

---

# 51. Závěr

Doménový model AI Traineru musí reprezentovat celý tréninkový proces:

```text
Uživatel
    ↓
Sportovní profil
    ↓
Cíle
    ↓
Tréninkový plán
    ↓
Kalendář
    ↓
Workout
    ↓
Skutečné provedení
    ↓
Aktivita
    ↓
Pokrok a regenerace
    ↓
Další úprava plánu
```

AI vstupuje do tohoto procesu jako inteligentní interpretační a návrhová vrstva.

Nevlastní však samotná data a nesmí obcházet doménová pravidla.

Hlavní hodnotou modelu je schopnost zachovat souvislost mezi:

* tím, co uživatel chce,
* tím, co bylo naplánováno,
* tím, co se změnilo,
* tím, co skutečně provedl,
* tím, jak na to systém reaguje.

Právě tato souvislost umožní, aby aplikace nebyla pouze workout trackerem ani chatbotem, ale skutečným adaptivním sportovním systémem.
