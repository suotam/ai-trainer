# AI Trainer – Sports and Goals Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/sports-and-goals-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model sportů, sportovního profilu, sezon, cílů, priorit, milníků a vztahů mezi cíli v aplikaci AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-personas.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/training-plan-model.md`,
* `docs/06-domain/workout-model.md`,
* `docs/06-domain/scheduling-model.md`.

Dokument popisuje:

* systémovou definici sportu,
* vlastní a méně běžné sporty,
* vztah uživatele ke sportu,
* sportovní charakteristiky,
* úroveň zkušeností,
* sportovní priority,
* sezony a fáze sezony,
* typy cílů,
* měřitelné a kvalitativní cíle,
* hierarchii cílů,
* vztahy a konflikty mezi cíli,
* milníky,
* metriky,
* vyhodnocování pokroku,
* změnu a ukončení cíle,
* roli AI při interpretaci cílů,
* univerzální podporu libovolných sportovců.

Dokument zatím neurčuje:

* konkrétní databázové tabulky,
* finální API kontrakty,
* detailní plánovací algoritmy pro každý sport,
* kompletní katalog sportů,
* finální metriky pro konkrétní disciplíny,
* přesné UI formuláře.

---

# 2. Cíl modelu sportů a cílů

Model musí umožnit, aby aplikaci používal:

* člověk s jedním sportem,
* multisportovní uživatel,
* začátečník,
* výkonnostní sportovec,
* člověk s pevným týmovým rozvrhem,
* člověk s nepravidelným režimem,
* člověk provozující známý sport,
* člověk provozující méně běžný nebo vlastní sport,
* člověk s jedním konkrétním cílem,
* člověk s několika současnými cíli,
* člověk bez přesně definovaného cíle.

Model nesmí být založen na předpokladu:

> Jeden uživatel = jeden sport = jeden cíl.

Základní vztah je:

```text
AthleteProfile
    ↓
UserSport *
    ↓
Goal *
    ↓
TrainingPlan
```

Sporty a cíle jsou vstupy do jednoho společného plánovacího systému.

---

# 3. Hlavní principy

## 3.1 Sport uživatele není pouze název

Nestačí uložit:

> Fotbal

Systém potřebuje znát například:

* jak často uživatel trénuje,
* jaká je jeho úroveň,
* zda jde o hlavní nebo doplňkový sport,
* zda je sport soutěžní,
* jaká je typická zátěž,
* které části těla zatěžuje,
* zda má pevné termíny,
* zda je sezonní.

## 3.2 Aplikace musí podporovat libovolný sport

Pokud neexistuje specializovaný sportovní modul, sport se nesmí odmítnout.

Musí být možné ho popsat pomocí obecných charakteristik.

## 3.3 Cíl není vždy jedno číslo

Cíl může být:

* přesně měřitelný,
* kvalitativní,
* návykový,
* termínovaný,
* udržovací,
* návratový,
* víceúrovňový.

## 3.4 Všechny cíle nejsou stejně důležité

Systém musí znát:

* hlavní cíl,
* vedlejší cíle,
* udržovací cíle,
* pozastavené cíle,
* budoucí cíle.

## 3.5 Cíle mohou být v konfliktu

Například:

* maximální nárůst svalové hmoty,
* příprava na vytrvalostní závod,
* vysoká frekvence týmového sportu,
* minimální čas na regeneraci.

Konflikt se nesmí skrývat.

## 3.6 AI nesmí definovat uživateli cíl bez jeho vědomí

AI může:

* cíl interpretovat,
* navrhnout strukturu,
* doporučit metriku,
* upozornit na nereálnost,
* rozdělit cíl na milníky.

Uživatel však musí mít kontrolu nad významem a prioritou cíle.

---

# 4. Hlavní objekty

Oblast sportů a cílů obsahuje minimálně:

* SportDefinition,
* SportCategory,
* SportCapabilityProfile,
* UserSport,
* CustomSportProfile,
* UserSportPreference,
* SportSeason,
* SportPhase,
* SportEventType,
* Goal,
* GoalType,
* GoalPriority,
* GoalStatus,
* GoalMetric,
* GoalMilestone,
* GoalRelationship,
* GoalAssessment,
* GoalProgressSnapshot,
* GoalRevision,
* GoalReview.

---

# 5. SportDefinition

## 5.1 Význam

SportDefinition je systémová definice známého sportu nebo disciplíny.

Není to sport konkrétního uživatele.

## 5.2 Příklady

* fotbal,
* florbal,
* běh,
* silový trénink,
* bouldering,
* sportovní lezení,
* cyklistika,
* plavání,
* veslování,
* bojové sporty,
* turistika,
* jóga.

## 5.3 Vlastnosti

SportDefinition může obsahovat:

* identifikátor,
* systémový název,
* lokalizované názvy,
* kategorii,
* popis,
* typické formy aktivity,
* typické metriky,
* typické fyzické nároky,
* obvyklé události,
* podporované specializované moduly,
* stav podpory,
* verzi.

## 5.4 Stav podpory

* FULLY_SPECIALIZED,
* PARTIALLY_SPECIALIZED,
* GENERIC_SUPPORTED,
* EXPERIMENTAL,
* DEPRECATED.

### FULLY_SPECIALIZED

Sport má:

* specializované metriky,
* plánovací pravidla,
* workout šablony,
* případně specializovaný tracker.

### PARTIALLY_SPECIALIZED

Sport má část specifické logiky.

### GENERIC_SUPPORTED

Sport funguje přes obecný model.

### EXPERIMENTAL

Podpora je omezená nebo ve vývoji.

---

# 6. SportCategory

## 6.1 Význam

Obecná kategorie sportu.

## 6.2 Příklady

* TEAM_SPORT,
* ENDURANCE,
* STRENGTH,
* COMBAT,
* RACKET,
* CLIMBING,
* WATER_SPORT,
* WINTER_SPORT,
* DANCE,
* MOBILITY,
* MIND_BODY,
* OUTDOOR,
* SKILL,
* MIXED,
* CUSTOM.

## 6.3 Omezení

Kategorie slouží k orientaci a obecným pravidlům.

Nesmí nahradit detailní charakteristiky.

Dva sporty ve stejné kategorii mohou mít velmi odlišné nároky.

---

# 7. SportCapabilityProfile

## 7.1 Význam

Popisuje obecné fyzické a technické nároky sportu.

## 7.2 Dimenze

Minimálně:

* aerobicEndurance,
* anaerobicEndurance,
* maximalStrength,
* strengthEndurance,
* power,
* speed,
* agility,
* mobility,
* flexibility,
* coordination,
* balance,
* technique,
* reaction,
* gripDemand,
* impactLoad,
* contactLoad,
* eccentricLoad,
* cognitiveDemand.

## 7.3 Hodnoty

Dimenze mohou být vyjádřeny například:

* NONE,
* LOW,
* MODERATE,
* HIGH,
* VERY_HIGH,
* UNKNOWN.

## 7.4 Účel

Používá se pro:

* obecné plánování,
* konflikt zátěží,
* neznámé sporty,
* doporučení doplňkového tréninku,
* regeneraci,
* nahrazování aktivit.

## 7.5 Nejistota

Každý profil může mít:

* zdroj,
* verzi,
* míru jistoty,
* uživatelskou úpravu.

---

# 8. AnatomicalLoadProfile

## 8.1 Význam

Popisuje typické zatížení částí těla.

## 8.2 Příklady oblastí

* chodidla,
* kotníky,
* lýtka,
* kolena,
* kyčle,
* hamstringy,
* kvadricepsy,
* bedra,
* core,
* hrudník,
* ramena,
* lokty,
* předloktí,
* zápěstí,
* prsty,
* krk.

## 8.3 Typ zatížení

* LOW,
* MODERATE,
* HIGH,
* VERY_HIGH.

## 8.4 Použití

Například:

Lezení může mít:

* vysoké zatížení prstů,
* vysoké zatížení předloktí,
* vysokou tahovou zátěž,
* střední zatížení ramen.

Fotbal může mít:

* vysoké zatížení nohou,
* vysokou rychlostní a změnovou zátěž,
* střední kontaktní zátěž.

---

# 9. UserSport

## 9.1 Význam

UserSport reprezentuje vztah konkrétního uživatele ke konkrétnímu sportu.

## 9.2 Vlastnosti

Obsahuje zejména:

* identifikátor,
* uživatele,
* SportDefinition nebo vlastní sport,
* uživatelský název,
* roli,
* prioritu,
* úroveň zkušeností,
* frekvenci,
* typickou délku,
* typickou intenzitu,
* soutěžní charakter,
* sezonní stav,
* datum začátku,
* datum ukončení nebo pozastavení,
* poznámku,
* vlastní capability profil,
* vlastní anatomický profil.

## 9.3 Role sportu

* PRIMARY,
* SECONDARY,
* SUPPORTING,
* RECREATIONAL,
* OCCASIONAL,
* SEASONAL,
* PAUSED,
* HISTORICAL.

## 9.4 PRIMARY

Hlavní sport nebo aktivita, které se uživatel věnuje nejvíce.

## 9.5 SECONDARY

Důležitý vedlejší sport.

## 9.6 SUPPORTING

Sport nebo aktivita sloužící jako doplněk.

## 9.7 RECREATIONAL

Rekreační aktivita bez hlavního výkonnostního cíle.

## 9.8 OCCASIONAL

Nepravidelná aktivita.

## 9.9 SEASONAL

Sport provozovaný pouze část roku.

## 9.10 HISTORICAL

Sport zůstává v historii, ale aktuálně se neplánuje.

---

# 10. UserSportPriority

Sportovní priorita může být oddělená od role.

Příklady:

* CRITICAL,
* HIGH,
* MEDIUM,
* LOW,
* BACKGROUND.

Například florbal může být PRIMARY a zároveň HIGH.

Mobilita může být SUPPORTING, ale v období návratu po zranění může mít HIGH prioritu.

---

# 11. ExperienceLevel

## 11.1 Význam

Popisuje zkušenost uživatele v konkrétním sportu.

## 11.2 Základní úrovně

* BEGINNER,
* NOVICE,
* INTERMEDIATE,
* ADVANCED,
* EXPERT,
* PROFESSIONAL,
* UNKNOWN.

## 11.3 Problém jediné úrovně

Jedna úroveň nemusí stačit.

Uživatel může být:

* technicky pokročilý,
* kondičně slabší po pauze,
* zkušený, ale aktuálně netrénovaný.

Proto může být užitečné rozlišit:

* historicalExperience,
* currentCapacity,
* technicalLevel,
* competitiveLevel.

## 11.4 První verze

V první verzi může být použita hlavní zkušenostní úroveň doplněná o:

* datum poslední pravidelné aktivity,
* návrat po pauze,
* aktuální subjektivní úroveň.

---

# 12. SportParticipationPattern

## 12.1 Význam

Popisuje, jak uživatel sport obvykle provozuje.

## 12.2 Vlastnosti

* frekvence týdně,
* obvyklá délka,
* obvyklá intenzita,
* pevné dny,
* proměnlivost,
* soutěžní četnost,
* prostředí,
* sezonnost.

## 12.3 Zdroj pravdy

Pravidelné konkrétní termíny musí zůstat v scheduling modelu.

UserSport obsahuje pouze souhrnný profil nebo odkaz.

---

# 13. CustomSportProfile

## 13.1 Význam

Reprezentuje sport nebo disciplínu, pro kterou neexistuje SportDefinition.

## 13.2 Povinné minimum

* uživatelský název,
* základní kategorie nebo CUSTOM,
* typická délka,
* typická intenzita,
* pevnost termínů,
* hlavní fyzické nároky.

## 13.3 Doporučená pole

* capability profil,
* anatomické zatížení,
* soutěžní charakter,
* technická náročnost,
* kontaktnost,
* prostředí,
* potřebné vybavení,
* potřeba regenerace.

## 13.4 AI pomoc

AI může z popisu uživatele navrhnout strukturovaný profil.

Příklad:

> Dělám historical fencing dvakrát týdně, trénink trvá dvě hodiny a hodně zatěžuje předloktí, ramena a nohy.

AI připraví návrh.

Uživatel ho potvrdí nebo upraví.

## 13.5 Přiznání nejistoty

Pokud systém sport nezná, musí zobrazit:

> Doporučení budou zatím obecnější a budou vycházet z charakteristik, které jsi uvedl.

---

# 14. UserSportPreference

## 14.1 Význam

Preference uživatele vztahující se ke konkrétnímu sportu.

## 14.2 Příklady

* oblíbené formy tréninku,
* neoblíbené formy,
* preferované prostředí,
* maximální frekvence,
* cílové dny,
* tolerance intenzity,
* preference soutěžení,
* preference skupinové nebo individuální aktivity.

## 14.3 Vztah k obecným preferencím

Obecné preference jsou v AthleteProfile.

UserSportPreference je přepisuje pro konkrétní sport.

---

# 15. SportSeason

## 15.1 Význam

SportSeason reprezentuje časově omezené období sportu.

## 15.2 Příklady

* fotbalová sezona,
* lezecká sezona,
* skialpová zima,
* závodní běžecké období,
* přípravné období.

## 15.3 Vlastnosti

* identifikátor,
* UserSport,
* název,
* začátek,
* konec,
* priorita,
* cíl sezony,
* stav,
* fáze,
* významné události.

## 15.4 Stav

* UPCOMING,
* ACTIVE,
* COMPLETED,
* PAUSED,
* CANCELLED,
* ARCHIVED.

## 15.5 Historie

Ukončení sezony nesmí odstranit sport nebo výsledky.

---

# 16. SportPhase

## 16.1 Význam

Fáze uvnitř sportovní sezony.

## 16.2 Typy

* OFF_SEASON,
* GENERAL_PREPARATION,
* SPECIFIC_PREPARATION,
* PRE_COMPETITION,
* COMPETITION,
* PEAK,
* TRANSITION,
* RECOVERY,
* RETURN_TO_SPORT,
* CUSTOM.

## 16.3 Použití

Fáze ovlivňuje:

* sportovní prioritu,
* typ doplňkového tréninku,
* toleranci zátěže,
* cíle,
* plánovací pravidla.

## 16.4 Více sportů

Uživatel může být zároveň:

* v soutěžní sezoně florbalu,
* v přípravné fázi na lezecký trip.

Plán musí koordinovat obě fáze.

---

# 17. SportEventType

## 17.1 Význam

Definuje typ významné sportovní události.

## 17.2 Příklady

* TRAINING,
* MATCH,
* COMPETITION,
* RACE,
* TOURNAMENT,
* TRIP,
* CAMP,
* TEST,
* QUALIFICATION,
* PERSONAL_CHALLENGE,
* CUSTOM.

## 17.3 Vztah

SportEventType je používán scheduling modelem a cíli.

---

# 18. Goal

## 18.1 Význam

Goal reprezentuje záměr uživatele, kterého chce dosáhnout nebo dlouhodobě udržovat.

## 18.2 Vlastnosti

Goal obsahuje zejména:

* identifikátor,
* uživatele,
* název,
* popis,
* typ,
* stav,
* prioritu,
* důvod,
* datum vytvoření,
* datum začátku,
* cílové datum,
* skutečné datum dokončení,
* výchozí stav,
* cílový stav,
* způsob vyhodnocení,
* související sporty,
* související plán,
* milníky,
* metriky,
* nejistotu,
* zdroj vytvoření.

## 18.3 Zdroj vytvoření

* USER,
* AI_STRUCTURED,
* SYSTEM_SUGGESTED,
* PLAN_DERIVED,
* COACH_CREATED v budoucnu,
* IMPORTED.

AI_STRUCTURED znamená, že uživatel cíl popsal přirozeným jazykem a AI ho převedla do struktury.

---

# 19. GoalType

Minimálně:

* PERFORMANCE,
* STRENGTH,
* ENDURANCE,
* SPEED,
* POWER,
* MOBILITY,
* FLEXIBILITY,
* SKILL,
* HABIT,
* CONSISTENCY,
* BODY_COMPOSITION,
* EVENT_PREPARATION,
* RETURN_TO_ACTIVITY,
* RECOVERY,
* MAINTENANCE,
* WELLBEING,
* QUALITATIVE,
* CUSTOM.

## 19.1 PERFORMANCE

Konkrétní sportovní výkon.

Příklad:

> Vylézt 7a.

## 19.2 STRENGTH

Příklad:

> Udělat deset shybů.

## 19.3 ENDURANCE

Příklad:

> Uběhnout půlmaraton.

## 19.4 HABIT

Příklad:

> Cvičit třikrát týdně.

## 19.5 EVENT_PREPARATION

Příklad:

> Připravit se na závod 10. října.

## 19.6 RETURN_TO_ACTIVITY

Příklad:

> Vrátit se k pravidelnému běhání po půlroční pauze.

## 19.7 MAINTENANCE

Příklad:

> Udržet sílu během fotbalové sezony.

## 19.8 QUALITATIVE

Příklad:

> Cítit se pohyblivější při lezení.

---

# 20. GoalStatus

Minimálně:

* DRAFT,
* ACTIVE,
* PAUSED,
* COMPLETED,
* ABANDONED,
* REPLACED,
* EXPIRED,
* ARCHIVED.

## 20.1 DRAFT

Cíl ještě není potvrzen.

## 20.2 ACTIVE

Cíl je součástí plánování.

## 20.3 PAUSED

Dočasně se neplánuje.

## 20.4 COMPLETED

Cíl byl dosažen nebo uživatel ho označil jako dokončený.

## 20.5 ABANDONED

Uživatel se rozhodl cíl opustit.

## 20.6 REPLACED

Cíl byl nahrazen jiným cílem.

## 20.7 EXPIRED

Termín uplynul bez dosažení a cíl nebyl prodloužen.

---

# 21. GoalPriority

## 21.1 Úrovně

* PRIMARY,
* HIGH,
* MEDIUM,
* LOW,
* MAINTENANCE,
* DEFERRED.

## 21.2 PRIMARY

Hlavní aktivní cíl.

První verze může omezit počet hlavních cílů například na jeden nebo malý počet, ale model musí umožnit budoucí rozšíření.

## 21.3 MAINTENANCE

Cíl, který se nemá výrazně rozvíjet, ale udržovat.

## 21.4 DEFERRED

Platný cíl odložený na pozdější období.

---

# 22. Goal Horizon

Cíl může mít časový horizont:

* IMMEDIATE,
* SHORT_TERM,
* MEDIUM_TERM,
* LONG_TERM,
* OPEN_ENDED.

## 22.1 IMMEDIATE

Dny až jednotky týdnů.

## 22.2 SHORT_TERM

Několik týdnů.

## 22.3 MEDIUM_TERM

Několik měsíců.

## 22.4 LONG_TERM

Rok nebo více.

## 22.5 OPEN_ENDED

Bez pevného konce.

Příklad:

> Pravidelně se hýbat.

---

# 23. GoalMetric

## 23.1 Význam

Metrika používaná k hodnocení cíle.

## 23.2 Vlastnosti

* MetricDefinition,
* role,
* výchozí hodnota,
* cílová hodnota,
* jednotka,
* směr zlepšení,
* tolerance,
* zdroj,
* způsob agregace,
* četnost měření.

## 23.3 Role metriky

* PRIMARY,
* SECONDARY,
* SUPPORTING,
* SAFETY,
* CONTEXT.

## 23.4 Směr zlepšení

* HIGHER_IS_BETTER,
* LOWER_IS_BETTER,
* TARGET_RANGE,
* CONSISTENCY,
* COMPLETION,
* QUALITATIVE.

## 23.5 Příklad

Cíl:

> Uběhnout půlmaraton.

Primární metrika:

* dokončení 21,1 km.

Sekundární metriky:

* délka dlouhého běhu,
* týdenní pravidelnost,
* subjektivní tolerance.

---

# 24. Kvalitativní cíl

## 24.1 Problém

Ne každý cíl lze přesně měřit.

Příklad:

> Chci mít lepší mobilitu pro lezení.

## 24.2 Řešení

Goal může mít způsob vyhodnocení:

* QUALITATIVE_REVIEW,
* SELF_ASSESSMENT,
* TASK_COMPLETION,
* PROXY_METRICS,
* EXPERT_ASSESSMENT v budoucnu.

## 24.3 Proxy metriky

Například:

* pravidelnost mobilitních workoutů,
* vybrané pohybové testy,
* subjektivní omezení,
* schopnost provést konkrétní pohyb.

Systém musí jasně označit, že jde o nepřímé ukazatele.

---

# 25. GoalBaseline

## 25.1 Význam

Výchozí stav uživatele při založení cíle.

## 25.2 Obsah

* datum,
* hodnota nebo kvalitativní popis,
* zdroj,
* jistota,
* test nebo aktivita,
* kontext.

## 25.3 Příklad

Cíl:

> Deset shybů.

Baseline:

* 4 čisté shyby,
* měřeno 20. července 2026,
* ruční vstup.

## 25.4 Chybějící baseline

Cíl může být aktivován bez baseline, pokud ji nelze bezpečně nebo smysluplně určit.

Systém může naplánovat pozdější kontrolní workout.

---

# 26. GoalTarget

## 26.1 Význam

Cílový stav.

## 26.2 Typy

* exact value,
* minimum value,
* maximum value,
* range,
* event completion,
* qualitative outcome,
* consistency threshold.

## 26.3 Realističnost

Cílová hodnota může mít stav:

* UNASSESSED,
* REALISTIC,
* AMBITIOUS,
* UNLIKELY,
* UNSAFE,
* UNKNOWN.

AI nebo systém může upozornit na nereálnost, ale nesmí bez vědomí uživatele cíl přepsat.

---

# 27. GoalMilestone

## 27.1 Význam

Dílčí krok na cestě k cíli.

## 27.2 Vlastnosti

* identifikátor,
* název,
* pořadí,
* cílové datum,
* očekávaný stav,
* metriky,
* stav,
* skutečné datum dosažení,
* návaznosti.

## 27.3 Příklad

Cíl:

> Deset shybů.

Milníky:

1. 5 shybů,
2. 7 shybů,
3. 9 shybů,
4. 10 shybů.

## 27.4 Dynamické milníky

Milník lze přepočítat podle reálného vývoje.

Historie původního milníku musí zůstat dohledatelná.

---

# 28. GoalRelationship

## 28.1 Význam

Reprezentuje vztah mezi dvěma cíli.

## 28.2 Typy

* SUPPORTS,
* CONFLICTS_WITH,
* DEPENDS_ON,
* SUBGOAL_OF,
* REPLACES,
* MAINTAINS,
* SHARES_METRIC_WITH,
* SEQUENCED_AFTER.

## 28.3 SUPPORTS

Například:

> Zlepšení mobility podporuje lezecký cíl.

## 28.4 CONFLICTS_WITH

Například:

> Maximální hypertrofie může částečně konfliktovat s vysokou vytrvalostní zátěží.

## 28.5 DEPENDS_ON

Například:

> Návrat k běhu závisí na dokončení návratové fáze.

## 28.6 SUBGOAL_OF

Například:

> Zvládnout 15 km dlouhý běh je podcíl půlmaratonu.

---

# 29. GoalConflict

## 29.1 Význam

Strukturované vyhodnocení konfliktu mezi cíli.

## 29.2 Typy konfliktu

* TIME,
* RECOVERY,
* TRAINING_ADAPTATION,
* EQUIPMENT,
* SCHEDULE,
* BODY_COMPOSITION,
* EVENT_TIMING,
* SAFETY,
* PRIORITY.

## 29.3 Závažnost

* LOW,
* MODERATE,
* HIGH,
* BLOCKING.

## 29.4 Obsah

* cíle,
* důvod,
* období konfliktu,
* důkazy nebo pravidla,
* možnosti řešení,
* doporučený kompromis,
* nejistota.

## 29.5 Chování

Konflikt nemusí znamenat, že cíle nelze kombinovat.

Může znamenat:

* pomalejší progres,
* střídání priorit,
* sekvenční plánování,
* udržování jednoho cíle,
* změnu termínu.

---

# 30. GoalCapacityAssessment

## 30.1 Význam

Vyhodnocuje, zda celkový soubor cílů odpovídá dostupné kapacitě uživatele.

## 30.2 Vstupy

* dostupný čas,
* pevné sporty,
* regenerace,
* zkušenost,
* termíny,
* omezení,
* počet cílů,
* požadovaná rychlost pokroku.

## 30.3 Výstup

* FEASIBLE,
* FEASIBLE_WITH_COMPROMISES,
* OVERLOADED,
* INSUFFICIENT_DATA,
* UNSAFE.

## 30.4 Vysvětlení

Například:

> Při třech fotbalových trénincích a nedělním zápase je realistické přidat dvě kratší jednotky horní části těla. Tři těžké silové workouty by pravděpodobně snižovaly regeneraci.

---

# 31. GoalRevision

## 31.1 Význam

Historická revize cíle.

## 31.2 Vzniká při

* změně termínu,
* změně cílové hodnoty,
* změně priority,
* změně metriky,
* změně popisu významu,
* změně souvisejícího sportu,
* významné změně strategie.

## 31.3 Obsah

* původní stav,
* nový stav,
* důvod,
* zdroj,
* čas,
* potvrzení,
* vazba na ChangeSet.

## 31.4 Historie

Původní verze cíle se nesmí ztratit.

---

# 32. GoalAssessment

## 32.1 Význam

Vyhodnocení aktuálního stavu cíle.

## 32.2 Typy

* INITIAL,
* PERIODIC,
* MILESTONE,
* EVENT_RESULT,
* MANUAL,
* AI_REVIEW,
* FINAL.

## 32.3 Obsah

* datum,
* aktuální stav,
* použité metriky,
* kvalitativní vstup,
* trend,
* jistota,
* komentář,
* doporučení,
* zdroj.

## 32.4 AI role

AI může vysvětlit vývoj, ale podklad musí vycházet ze strukturovaných dat.

---

# 33. GoalProgressSnapshot

## 33.1 Význam

Odvozený stav cíle k určitému okamžiku.

## 33.2 Obsah

* datum,
* metriky,
* dosažené milníky,
* trend,
* odhadovaný stav,
* adherence relevantních aktivit,
* kvalitativní hodnocení,
* nejistota.

## 33.3 Není zdroj pravdy

Snapshot je odvozený read model nebo analytický objekt.

Zdrojem pravdy zůstávají:

* Goal,
* MetricValue,
* Activity,
* GoalAssessment,
* GoalMilestone.

---

# 34. GoalReview

## 34.1 Význam

Pravidelná revize smyslu a nastavení cíle.

## 34.2 Spouštěče

* konec týdne,
* konec bloku,
* stagnace,
* rychlejší pokrok,
* změna rozvrhu,
* bolest,
* změna sportu,
* blížící se termín,
* uživatelský požadavek.

## 34.3 Výsledky

* bez změny,
* změna metriky,
* změna termínu,
* změna priority,
* přidání milníku,
* pozastavení,
* nahrazení,
* dokončení,
* vytvoření nového plánu.

---

# 35. Cíl bez pevného termínu

Některé cíle jsou průběžné.

Příklady:

* pravidelně cvičit,
* udržet kondici,
* zlepšovat mobilitu,
* zůstat aktivní.

Takový cíl může mít:

* OPEN_ENDED horizont,
* periodické revize,
* stavové milníky,
* udržovací metriky.

Nemá být automaticky označen jako nesplněný pouze proto, že nemá konečné datum.

---

# 36. Event-based goal

## 36.1 Význam

Cíl spojený s konkrétní událostí.

Příklady:

* půlmaraton,
* fotbalový turnaj,
* lezecký trip,
* horský přechod,
* cyklistický závod.

## 36.2 Vztah

Goal odkazuje na:

* CompetitionEvent,
* ScheduleEvent,
* EventGroup,
* cílové datum.

## 36.3 Změna události

Pokud se událost přesune:

* cíl se automaticky nepřepíše bez kontroly,
* systém vytvoří návrh změny termínu a plánu.

---

# 37. Habit Goal

## 37.1 Význam

Cíl založený na pravidelnosti.

Příklad:

> Cvičit třikrát týdně.

## 37.2 Parametry

* cílová frekvence,
* typ aktivit,
* minimální délka nebo kvalita,
* perioda hodnocení,
* tolerance,
* pravidla náhradní aktivity.

## 37.3 Riziko

Habit goal nesmí motivovat uživatele k nebezpečnému doplňování tréninků jen kvůli sérii.

## 37.4 Hodnocení

Musí zohlednit:

* plánované změny,
* nemoc,
* aktivní omezení,
* náhradní aktivity,
* odpočinkové období.

---

# 38. Maintenance Goal

## 38.1 Význam

Cíl udržet schopnost během období jiné priority.

Příklad:

> Udržet sílu horní části těla během fotbalové sezony.

## 38.2 Parametry

* minimální přijatelná úroveň,
* frekvence udržovacích stimulů,
* tolerance poklesu,
* období platnosti,
* hlavní konfliktní cíl.

## 38.3 Vyhodnocení

Nejde o neustálé zvyšování výkonu.

Úspěch může znamenat stabilitu.

---

# 39. Return-to-Activity Goal

## 39.1 Význam

Návrat po pauze, nemoci nebo omezení.

## 39.2 Vlastnosti

* předchozí úroveň,
* současný stav,
* délka pauzy,
* důvod pauzy,
* fáze návratu,
* bezpečnostní omezení,
* kontrolní body.

## 39.3 Omezení

Aplikace nesmí nahrazovat odborný rehabilitační plán.

Může řídit obecný návrat pouze v bezpečných mezích.

---

# 40. Body Composition Goal

## 40.1 Význam

Cíl související s tělesnou hmotností nebo složením těla.

## 40.2 Bezpečnost

Model musí zabránit podpoře:

* extrémního úbytku hmotnosti,
* nebezpečných termínů,
* trestání jídla cvičením,
* dehydratace,
* nezdravého tréninkového objemu.

## 40.3 Rozsah první verze

Aplikace může pracovat s obecným fitness cílem, ale nemá poskytovat detailní klinické nebo výživové vedení bez odpovídajícího modulu a pravidel.

---

# 41. Wellbeing Goal

## 41.1 Význam

Příklad:

* mít více energie,
* méně se zadýchávat,
* cítit se pohyblivější,
* pravidelně se hýbat.

## 41.2 Vyhodnocení

Může kombinovat:

* subjektivní stav,
* návyky,
* funkční testy,
* frekvenci aktivity,
* jednoduché výkonové ukazatele.

Systém musí komunikovat nejistotu a subjektivitu.

---

# 42. Goal and TrainingPlan

## 42.1 Vztah

Cíl může být podporován jedním nebo více plány v čase.

TrainingPlan může podporovat více cílů.

```text
Goal * ─── * TrainingPlan
```

## 42.2 PlanGoalLink

Obsahuje:

* roli cíle,
* prioritu v plánu,
* očekávaný příspěvek,
* období zaměření,
* metriky,
* kompromisy.

## 42.3 Změna priority

Významná změna priority cíle může vyžadovat novou TrainingPlanVersion.

---

# 43. Goal and Workout

Workout může podporovat jeden nebo více cílů.

Vztah musí obsahovat:

* roli workoutu,
* očekávaný příspěvek,
* prioritu.

Příklad:

Upper Body A může podporovat:

* hlavní cíl: síla horní poloviny těla,
* vedlejší cíl: stabilita ramen,
* udržovací cíl: core.

---

# 44. Goal and Metric

Metrika nemusí patřit pouze jednomu cíli.

Například:

* počet shybů může být relevantní pro silový i lezecký cíl,
* týdenní objem běhu pro půlmaraton i obecnou kondici.

Musí být zachován kontext použití.

---

# 45. Goal and Sport Season

Cíl může být:

* sezónní,
* přípravný,
* soutěžní,
* přechodový,
* mimo sezonu.

Příklad:

> Zlepšit sílu nohou během přípravy na florbalovou sezonu.

Goal může odkazovat na SportSeason nebo SportPhase.

---

# 46. Prioritizace více sportů

Systém musí rozlišovat:

* hlavní sport,
* hlavní aktuální cíl,
* pevnou sportovní zátěž,
* doplňkový sport,
* rekreační aktivitu.

Příklad:

Uživatel může:

* považovat lezení za hlavní sport,
* mít florbal jako pevnou soutěžní povinnost,
* chtít dočasně zlepšit sílu nohou.

Plán nesmí mechanicky předpokládat, že hlavní sport má vždy absolutní přednost před vším ostatním.

---

# 47. Sport priority by period

Priorita sportu se může v čase měnit.

Příklad:

* zima: skialpy HIGH,
* jaro: lezení PRIMARY,
* podzim: florbal PRIMARY.

Proto může existovat:

* výchozí UserSportPriority,
* časově omezený SportPriorityPeriod.

## 47.1 SportPriorityPeriod

Obsahuje:

* UserSport,
* začátek,
* konec,
* prioritu,
* důvod,
* související cíl nebo sezonu.

---

# 48. Sport conflict

## 48.1 Význam

Dva sporty mohou mít konfliktní zátěž.

Příklady:

* lezení a vysoký objem shybů,
* fotbal a těžké nohy,
* běžecké intervaly a florbalový zápas,
* bojový sport a silový trénink ramen.

## 48.2 SportConflictProfile

Může popisovat:

* typ konfliktu,
* zasažené capability dimenze,
* anatomické oblasti,
* minimální doporučený rozestup,
* závažnost,
* jistotu.

## 48.3 Dynamika

Konflikt závisí na:

* intenzitě,
* délce,
* zkušenosti,
* skutečné únavě,
* období sezony.

Nesmí být vždy absolutním zákazem.

---

# 49. Goal feasibility

## 49.1 Vyhodnocení

GoalFeasibilityAssessment může posoudit:

* dostupný čas,
* aktuální úroveň,
* termín,
* pevné sporty,
* omezení,
* regeneraci,
* data historie,
* požadovanou změnu.

## 49.2 Výstup

* REALISTIC,
* AMBITIOUS,
* UNLIKELY,
* UNSAFE,
* INSUFFICIENT_DATA.

## 49.3 Pravidlo

UNLIKELY neznamená automatické zamítnutí.

UNSAFE znamená, že aplikace nesmí slepě vytvořit požadovaný plán.

---

# 50. AI interpretace cíle

## 50.1 Příklad vstupu

> Chci být lepší v lezení.

## 50.2 AI musí zjistit nebo navrhnout

* co pro uživatele znamená „lepší“,
* typ lezení,
* aktuální úroveň,
* časový horizont,
* slabé stránky,
* dostupný čas,
* prioritu.

## 50.3 Strukturovaný návrh

AI může navrhnout:

* kvalitativní hlavní cíl,
* konkrétní podcíle,
* metriky,
* kontrolní období.

## 50.4 Uživatel potvrzuje

AI nesmí svévolně rozhodnout, že hlavní metrikou je například počet shybů, pokud uživatel řeší techniku nebo vytrvalost.

---

# 51. AI interpretace neznámého sportu

## 51.1 Vstup

> Trénuji capoeiru třikrát týdně a chci k tomu posílit záda.

## 51.2 AI může navrhnout

* sportovní kategorii,
* capability profil,
* typické zatížení,
* pevné tréninky,
* vztah k cíli.

## 51.3 Validace

Uživatel vidí:

> Capoeiru jsem vyhodnotil jako technicky, koordinačně a kondičně náročnou aktivitu s vyšším zatížením ramen, kyčlí a nohou. Odpovídá to tvým tréninkům?

---

# 52. Goal completion

## 52.1 Automatické dokončení

Cíl může být automaticky navržen k dokončení, pokud:

* metrika dosáhne cílové hodnoty,
* proběhne cílová událost,
* jsou splněny definované podmínky.

## 52.2 Potvrzení

U některých cílů musí uživatel potvrdit:

* zda výkon považuje za platný,
* zda cíl skutečně dokončil,
* zda chce pokračovat novým cílem.

## 52.3 Po dokončení

Možnosti:

* archivovat,
* vytvořit udržovací cíl,
* zvýšit cílovou úroveň,
* vytvořit nový související cíl,
* zachovat historii.

---

# 53. Goal failure or missed deadline

Uplynutí termínu neznamená automaticky selhání uživatele.

Systém musí nabídnout:

* vyhodnocení,
* prodloužení,
* úpravu cíle,
* nahrazení,
* ukončení,
* vytvoření realističtějšího cíle.

Jazyk musí být neutrální a věcný.

---

# 54. Goal pause

Cíl může být pozastaven například kvůli:

* změně sezony,
* bolesti,
* časové vytíženosti,
* změně priority,
* cestování,
* osobnímu rozhodnutí.

Pozastavení musí obsahovat:

* důvod,
* začátek,
* očekávaný konec,
* pravidlo návratu.

---

# 55. Goal replacement

## 55.1 Příklad

> Půlmaraton už nechci běžet. Chci se zaměřit na lezení.

## 55.2 Výsledek

* původní cíl → REPLACED nebo ABANDONED,
* nový cíl → DRAFT nebo ACTIVE,
* GoalRelationship typu REPLACES,
* návrh nové verze plánu,
* zachování historie.

---

# 56. Goal deletion

Cíl s historií se nemá běžně fyzicky mazat.

Preferované stavy:

* ARCHIVED,
* ABANDONED,
* REPLACED.

Fyzické odstranění je vhodné pouze pro:

* omylem vytvořený koncept,
* cíl bez návazností,
* požadavek na smazání osobních dat.

---

# 57. Sport deletion

UserSport s historií se nemá fyzicky mazat.

Možnosti:

* PAUSED,
* HISTORICAL,
* ARCHIVED.

Při odstranění aktivního sportu musí systém ukázat dopad na:

* pravidelné události,
* cíle,
* plán,
* workouty,
* metriky.

---

# 58. Sport merging

## 58.1 Příklad

Uživatel má omylem:

* „Běh“
* „Running“

Systém může nabídnout sloučení.

## 58.2 Pravidla

Sloučení musí zachovat:

* historii,
* aktivity,
* cíle,
* metriky,
* události.

Musí být auditované a vratné, pokud je to možné.

---

# 59. Sport aliases

SportDefinition může mít aliasy.

Příklady:

* soccer → football podle regionu,
* gym workout → strength training,
* indoor climbing → climbing subtype.

Alias nesmí změnit uživatelský vlastní název bez jeho vědomí.

---

# 60. Sport hierarchy

Sport může mít hierarchii:

```text
Climbing
├── Sport Climbing
├── Bouldering
├── Trad Climbing
└── Indoor Climbing
```

nebo:

```text
Running
├── Road Running
├── Trail Running
├── Track Running
└── Treadmill Running
```

## 60.1 Použití

* společné metriky,
* specializace,
* filtry,
* plánovací pravidla,
* historie.

## 60.2 UserSport

Uživatel může mít:

* obecný sport,
* konkrétní disciplínu,
* více disciplín stejného sportu.

---

# 61. Sport specialization

Specializovaný modul může přidat:

* metriky,
* workout typy,
* capability profil,
* event typy,
* plánovací pravidla,
* safety pravidla,
* specializovaný onboarding.

Musí však používat společné:

* UserSport,
* Goal,
* TrainingPlan,
* ScheduleEvent,
* Activity,
* MetricValue.

---

# 62. General sport fallback

Pokud modul neexistuje, aplikace musí minimálně podporovat:

* název sportu,
* tréninkové události,
* délku,
* intenzitu,
* frekvenci,
* plánovací prioritu,
* capability profil,
* anatomickou zátěž,
* obecnou Activity,
* vlastní cíle,
* uživatelskou zpětnou vazbu.

---

# 63. Sport metrics

Každý sport může podporovat vlastní metriky.

Příklady:

## Běh

* vzdálenost,
* tempo,
* čas,
* převýšení,
* tep.

## Silový trénink

* váha,
* opakování,
* objem,
* RPE,
* osobní rekord.

## Lezení

* obtížnost,
* počet pokusů,
* styl přelezu,
* délka session,
* subjektivní intenzita.

## Týmový sport

* délka,
* intenzita,
* zápas versus trénink,
* subjektivní zátěž.

Metriky jsou definovány přes MetricDefinition, ne pevně přímo v UserSport.

---

# 64. Goal metric quality

Každá GoalMetric musí mít:

* datový zdroj,
* jednotku,
* kvalitu,
* spolehlivost,
* četnost,
* význam.

Příklad:

Subjektivní mobilita 1–5 má jinou přesnost než změřený rozsah pohybu.

Systém to musí respektovat.

---

# 65. Goal progress direction

Pokrok nemusí být lineární.

Systém musí podporovat:

* kolísání,
* sezonnost,
* deload,
* dočasný pokles,
* návrat po pauze,
* udržování.

Graf nebo AI shrnutí nesmí označit krátkodobý pokles automaticky jako problém.

---

# 66. Goal confidence

GoalProgressSnapshot nebo Assessment může mít jistotu:

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

Příklad:

Cíl síly má vyšší jistotu, pokud je pravidelně měřen stejným testem.

Kvalitativní cíl může mít nižší jistotu.

---

# 67. Sport profile confidence

CustomSportProfile a automaticky odvozené charakteristiky musí mít:

* zdroj,
* datum,
* jistotu,
* potvrzení uživatelem.

AI nesmí prezentovat odhad jako jistou sportovní znalost.

---

# 68. Příklad – fotbalista s cílem horní části těla

## UserSport

Fotbal:

* role PRIMARY,
* soutěžní,
* 3 tréninky týdně,
* zápas v neděli,
* vysoké zatížení nohou,
* vysoká rychlostní zátěž.

## Goal

> Zesílit horní polovinu těla.

Typ:

* STRENGTH.

Priorita:

* HIGH.

Termín:

* 8 týdnů.

Metriky:

* počet shybů,
* progres variant kliků,
* dokončování workoutů.

## Konflikt

Těžké doplňkové nohy by konfliktovaly s fotbalem.

Horní část těla je relativně kompatibilní, ale tahový objem musí respektovat bolest loktů nebo ramen.

---

# 69. Příklad – multisportovní florbalista a lezec

## UserSport

Florbal:

* PRIMARY,
* soutěžní,
* pevné tréninky a zápas.

Lezení:

* SECONDARY,
* nepravidelné,
* víkendové výjezdy.

## Goals

1. Posílit nohy.
2. Zlepšit mobilitu pro lezení.
3. Udržet výkon ve florbalu.

## GoalPriority

* florbalový výkon: PRIMARY,
* síla nohou: HIGH,
* mobilita: HIGH nebo SUPPORTING podle období.

## Konflikt

* silový workout nohou před zápasem,
* lezecký víkend a tahová zátěž,
* vysoká frekvence dvoufázového tréninku.

---

# 70. Příklad – začátečník bez jasného cíle

## Vstup

> Chci se začít hýbat a cítit se lépe.

## Goal návrh

Hlavní cíl:

* WELLBEING nebo CONSISTENCY.

Milník:

* dokončit 2–3 krátké aktivity týdně po dobu čtyř týdnů.

Metriky:

* frekvence,
* subjektivní energie,
* zvládnutelnost.

## Pravidlo

Systém nesmí uživateli bez souhlasu vytvořit ambiciózní výkonový cíl.

---

# 71. Příklad – neznámý sport

## Vstup

> Dělám aerial hoop dvakrát týdně a chci posílit ramena a core.

## CustomSportProfile

* category: SKILL / STRENGTH / DANCE,
* vysoká síla horní části těla,
* vysoká mobilita ramen,
* vysoké zatížení úchopu,
* technická náročnost,
* střední až vysoká lokální zátěž ramen a předloktí.

## Goal

* posílení ramen a core,
* ale plán musí zohlednit již existující vysokou zátěž horní části těla.

---

# 72. Příklad – termínovaný závod

## Goal

> Uběhnout půlmaraton 18. října.

Typ:

* EVENT_PREPARATION.

Vazba:

* CompetitionEvent.

Milníky:

* 10 km souvisle,
* 14 km dlouhý běh,
* 18 km dlouhý běh,
* taper.

## Změna termínu

Pokud se závod přesune:

* vznikne GoalRevision,
* vyhodnotí se TrainingPlan,
* případně nová verze plánu.

---

# 73. Příklad – sezónní priority

## Zima

* skialpy HIGH,
* lezení MAINTENANCE,
* běh LOW.

## Jaro

* lezení PRIMARY,
* mobilita HIGH,
* skialpy HISTORICAL nebo PAUSED.

SportPriorityPeriod umožní změnu bez mazání sportů.

---

# 74. Doménové události

Minimálně:

* SportDefinitionCreated
* UserSportAdded
* UserSportUpdated
* UserSportPaused
* UserSportArchived
* CustomSportProfileCreated
* SportSeasonCreated
* SportSeasonStarted
* SportSeasonCompleted
* SportPriorityChanged
* GoalDraftCreated
* GoalActivated
* GoalUpdated
* GoalPriorityChanged
* GoalPaused
* GoalResumed
* GoalCompleted
* GoalAbandoned
* GoalReplaced
* GoalMilestoneCreated
* GoalMilestoneReached
* GoalRelationshipCreated
* GoalConflictDetected
* GoalAssessmentCompleted
* GoalReviewCompleted
* GoalDeadlineChanged
* GoalFeasibilityAssessed

---

# 75. Příkazy

Minimálně:

* AddUserSport
* AddCustomSport
* UpdateUserSport
* PauseUserSport
* ArchiveUserSport
* CreateSportSeason
* StartSportSeason
* CompleteSportSeason
* ChangeSportPriority
* CreateGoalDraft
* ActivateGoal
* UpdateGoal
* ChangeGoalPriority
* PauseGoal
* ResumeGoal
* CompleteGoal
* AbandonGoal
* ReplaceGoal
* AddGoalMilestone
* RecordGoalAssessment
* ReviewGoal
* CreateGoalRelationship
* ResolveGoalConflict
* AssessGoalFeasibility

---

# 76. Invariance sportovního modelu

## 76.1 Vlastnictví

* Každý UserSport patří jednomu uživateli.
* Cíl nesmí odkazovat na UserSport jiného uživatele.
* CustomSportProfile patří stejnému uživateli jako UserSport.

## 76.2 Sport

* UserSport musí mít systémovou definici nebo vlastní profil.
* Aktivní sport musí mít platný název.
* Historie sportu se nesmí odstranit běžným pozastavením.
* SportDefinition nesmí být uživatelem přepsána.

## 76.3 Sezona

* Konec sezony nesmí být před začátkem.
* Aktivní fáze musí být uvnitř sezony.
* Dokončená sezona se nesmí zpětně přepsat bez auditu.

---

# 77. Invariance cíle

## 77.1 Základní

* Goal patří jednomu uživateli.
* Aktivní cíl musí mít název a význam.
* Cílové datum nesmí být před datem začátku.
* Dokončený cíl musí mít datum dokončení nebo auditovaný důvod.
* Nahrazený cíl musí odkazovat na nový cíl, pokud existuje.

## 77.2 Metriky

* Jednotka musí odpovídat MetricDefinition.
* Výchozí a cílová hodnota musí být porovnatelné, pokud jde o numerický cíl.
* Kvalitativní cíl nesmí předstírat přesnou číselnou progresi bez definované metody.

## 77.3 Priority

* Změna hlavní priority musí být auditovaná.
* Konfliktní hlavní cíle musí být označeny nebo vyhodnoceny.
* AI nesmí bez potvrzení změnit PRIMARY cíl.

## 77.4 Bezpečnost

* UNSAFE cíl nesmí vést k automatickému vytvoření plánu.
* Extrémní požadavek musí vyvolat bezpečnější návrh.
* Zdravotní cíl nesmí být interpretován jako diagnóza nebo léčba.

---

# 78. AI invariance

* AI vytvořený sportovní profil musí být validován.
* Neznámý sport musí mít označenou míru jistoty.
* AIProposal nesmí aktivovat nový hlavní cíl bez potvrzení.
* AI nesmí odstranit sport s historií.
* AI nesmí označit kvalitativní cíl za dosažený pouze na základě vlastního textového odhadu.
* Zastaralé GoalAssessment nesmí přepsat novější hodnoty.

---

# 79. Read modely

## 79.1 SportsOverview

Obsahuje:

* aktivní sporty,
* role,
* priority,
* sezony,
* nejbližší události.

## 79.2 UserSportDetail

Obsahuje:

* definici,
* zkušenost,
* frekvenci,
* capability profil,
* zatížení,
* cíle,
* sezonu,
* historii.

## 79.3 GoalsOverview

Obsahuje:

* hlavní cíl,
* aktivní cíle,
* pozastavené cíle,
* termíny,
* stručný pokrok.

## 79.4 GoalDetailView

Obsahuje:

* popis,
* priority,
* metriky,
* baseline,
* target,
* milníky,
* vztahy,
* plán,
* revize.

## 79.5 GoalConflictView

Obsahuje:

* cíle,
* typ konfliktu,
* období,
* možnosti řešení,
* doporučený kompromis.

## 79.6 SportSeasonView

Obsahuje:

* období,
* fázi,
* priority,
* události,
* související cíle.

---

# 80. Sport and Goal Services

## 80.1 SportProfileService

Může zajišťovat:

* validaci sportovního profilu,
* fallback pro vlastní sport,
* slučování sportů,
* práci s aliasy,
* capability profil.

## 80.2 GoalStructuringService

Může převádět:

* obecný uživatelský záměr,
* do strukturovaného Goal návrhu.

## 80.3 GoalConflictService

Vyhodnocuje:

* konflikty cílů,
* čas,
* regeneraci,
* adaptační neslučitelnost,
* termíny.

## 80.4 GoalProgressService

Vyhodnocuje:

* metriky,
* milníky,
* trend,
* dokončení,
* nejistotu.

## 80.5 GoalFeasibilityService

Posuzuje:

* realističnost,
* bezpečnost,
* dostupnou kapacitu,
* chybějící data.

---

# 81. Co musí být strukturované

Nesmí zůstat pouze jako text:

* sport,
* role sportu,
* priorita,
* zkušenost,
* sezona,
* hlavní fyzické nároky,
* cíl,
* typ cíle,
* priorita cíle,
* termín,
* metrika,
* milník,
* konflikt,
* stav cíle,
* vztah cíle ke sportu,
* změna cíle.

Volný text může doplnit:

* důvod,
* osobní význam,
* poznámku,
* subjektivní popis.

---

# 82. Otevřené otázky

* Jak detailní má být systémový katalog sportů v první verzi?
* Jak verzovat SportDefinition a capability profily?
* Má být capability profil ukládán jako pevná struktura, nebo rozšiřitelný seznam dimenzí?
* Jak přesně reprezentovat sportovní disciplíny a poddisciplíny?
* Může mít uživatel více UserSport záznamů stejného sportu v různých kontextech?
* Jak reprezentovat týmovou sezonu versus osobní sezonu?
* Jak detailně ukládat soutěžní úroveň?
* Jaký počet aktivních hlavních cílů povolit v první verzi?
* Jak automaticky detekovat konflikt cílů bez falešných závěrů?
* Jaká část GoalFeasibility bude deterministická a jaká AI?
* Jak měřit kvalitativní cíle bez falešné přesnosti?
* Jak řešit cíl s více jednotkami nebo několika primárními metrikami?
* Jak pracovat s metrikou, která pochází z více zdrojů?
* Jak upravit cíl po změně jednotek?
* Jak přesně funguje dokončení habit goal?
* Jak řešit cíle bez termínu v notifikacích a revizích?
* Jak dlouho uchovávat GoalProgressSnapshot?
* Jak zobrazit více konfliktujících cílů jednoduše?
* Jak modelovat cíle vytvořené trenérem v budoucnu?
* Jak pracovat s cílem u nezletilého uživatele?
* Jak řešit uživatele bez jakéhokoliv cíle?
* Jak rozlišit aktivitu pro radost od cílově řízeného sportu?

---

# 83. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── activity-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── metrics-model.md
├── identity-and-profile-model.md
├── domain-events.md
└── domain-invariants.md
```

Dále:

```text
docs/05-ai/
├── goal-interpretation.md
├── sport-understanding.md
├── planning-behavior.md
└── safety-rules.md
```

A:

```text
docs/07-backend/
├── sport-service.md
├── goal-service.md
├── goal-progress-service.md
└── sport-catalog.md
```

---

# 84. Kritéria správného modelu

Model je vhodný pouze tehdy, pokud umožní:

1. přidat známý sport,
2. přidat libovolný vlastní sport,
3. popsat jeho fyzické nároky,
4. určit hlavní a vedlejší sporty,
5. měnit sportovní prioritu v čase,
6. podporovat sportovní sezonu,
7. podporovat více disciplín,
8. vytvořit měřitelný cíl,
9. vytvořit kvalitativní cíl,
10. vytvořit návykový cíl,
11. vytvořit termínovaný cíl,
12. podporovat více současných cílů,
13. určit jejich priority,
14. zjistit konflikt,
15. navrhnout kompromis,
16. přidat milníky,
17. měřit pokrok,
18. pracovat s nejistotou,
19. změnit termín,
20. pozastavit cíl,
21. nahradit cíl,
22. zachovat historii,
23. propojit cíle s plánem,
24. propojit cíle s workouty,
25. fungovat pro uživatele mimo připravené persony.

---

# 85. Závěr

Model sportů a cílů určuje, komu se uživatel sportovně věnuje, co chce zlepšit a jaké priority má aplikace respektovat.

Jeho základní vztah je:

```text
AthleteProfile
    ↓
UserSport
    ↓
SportSeason / SportPhase
    ↓
Goal
    ↓
GoalMetric / GoalMilestone / GoalRelationship
    ↓
TrainingPlan
    ↓
WorkoutInstance
    ↓
Activity
    ↓
GoalAssessment
```

Aplikace nesmí fungovat pouze pro předem vybrané sportovce nebo sporty.

Persony slouží pro testování.

SportDefinition poskytuje specializaci.

CustomSportProfile zajišťuje univerzálnost.

Goal model zajišťuje, že aplikace neplánuje pohyb bez směru, ale zároveň nenutí každého uživatele převést svůj sportovní život na jedno číslo.

Díky tomu může uživatel říct:

> Hraju netradiční sport, mám nepravidelný režim a chci být silnější, pohyblivější a zároveň se nepřetěžovat.

A systém dokáže jeho situaci strukturovat, přiznat nejistotu, určit priority a vytvořit společný plán bez nutnosti, aby pro jeho konkrétní sport existovala předem naprogramovaná pevná větev.
