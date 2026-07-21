# AI Trainer – Metrics Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/metrics-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model metrik, jednotek, měření, časových řad, agregací, osobních rekordů, pokroku a datové kvality v aplikaci AI Trainer.

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
* `docs/06-domain/ai-and-change-model.md`.

Dokument popisuje:

* definici metrik,
* typy metrik,
* jednotky,
* převody jednotek,
* jednotlivá měření,
* časové řady,
* agregace,
* zdroje dat,
* kvalitu a důvěryhodnost,
* plánované a skutečné hodnoty,
* sportovně specifické metriky,
* odvozené metriky,
* osobní rekordy,
* cílové metriky,
* pokrok,
* adherence,
* readiness a recovery metriky,
* zátěž,
* verzování výpočtů,
* opravy,
* konflikty zdrojů,
* offline režim,
* synchronizaci,
* ochranu citlivých dat,
* rozšiřitelnost pro libovolné sporty.

Dokument zatím neurčuje:

* konkrétní databázové tabulky,
* konkrétní analytickou databázi,
* přesné algoritmy všech sportovních výpočtů,
* konkrétní grafické komponenty,
* finální podporované wearable formáty,
* konkrétní formát ukládání vysokofrekvenčních časových řad.

---

# 2. Cíl metrics modelu

Metrics model musí umožnit ukládat a vyhodnocovat široké spektrum sportovních hodnot bez toho, aby byla aplikace pevně svázána s jedním sportem.

Musí podporovat například:

* počet opakování,
* hmotnost,
* délku workoutu,
* vzdálenost,
* tempo,
* rychlost,
* tep,
* výkon,
* kadenci,
* převýšení,
* RPE,
* RIR,
* délku spánku,
* HRV,
* subjektivní energii,
* mobilitu,
* pravidelnost,
* počet dokončených aktivit,
* lezeckou obtížnost,
* vlastní metriku uživatele.

Model nesmí být založen na jediném univerzálním objektu typu:

```text
key: string
value: number
```

Takový model by sice byl flexibilní, ale neumožnil by bezpečně řešit:

* jednotky,
* validaci,
* porovnání,
* agregace,
* typ hodnoty,
* směrování pokroku,
* kvalitu dat,
* kompatibilitu sportů,
* odvozené metriky.

---

# 3. Základní principy

## 3.1 Metrika musí mít význam

Každá metrika musí mít definováno:

* co měří,
* v jaké jednotce,
* pro jaké objekty platí,
* jak se agreguje,
* zda vyšší hodnota znamená zlepšení,
* jaká je její přesnost,
* zda je měřená, odhadovaná nebo subjektivní.

## 3.2 Hodnota bez jednotky není dostatečná

Například hodnota `10` může znamenat:

* 10 kg,
* 10 opakování,
* 10 minut,
* RPE 10,
* 10 kilometrů.

Jednotka a definice metriky jsou povinnou součástí významu.

## 3.3 Plánované a skutečné hodnoty jsou oddělené

Příklad:

* plánované opakování: 8,
* skutečné opakování: 6.

Obě hodnoty musí zůstat zachované.

## 3.4 Zdroj hodnoty musí být dohledatelný

Hodnota může pocházet:

* od uživatele,
* z workout trackeru,
* z wearables,
* z externí služby,
* z výpočtu,
* z AI návrhu,
* z manuální opravy.

## 3.5 Odvozené metriky musí být verzované

Pokud aplikace vypočítá:

* sportovní zátěž,
* adherence,
* readiness,
* trend,
* odhad maxima,

musí být známé:

* použité vstupy,
* verze algoritmu,
* čas výpočtu,
* jistota,
* možnost přepočtu.

## 3.6 Systém nesmí vytvářet falešnou přesnost

Hodnota odhadnutá z hrubého vstupu se nesmí prezentovat stejně jako přesně změřená hodnota.

## 3.7 Různé sporty mohou používat stejné i odlišné metriky

Například délku používají:

* běh,
* florbal,
* lezení,
* silový workout,
* mobilita.

Tempo má smysl pro běh, ale ne pro všechny sporty.

---

# 4. Hlavní doménové objekty

Metrics oblast obsahuje minimálně:

* MetricDefinition,
* MetricCategory,
* MetricValueType,
* UnitDefinition,
* UnitDimension,
* UnitConversionRule,
* MetricValue,
* MetricValueRevision,
* MetricSeries,
* MetricSample,
* MetricAggregate,
* MetricAggregationRule,
* MetricSource,
* MetricProvenance,
* MetricQuality,
* MetricBaseline,
* MetricTarget,
* MetricTrend,
* MetricComparison,
* DerivedMetricDefinition,
* MetricCalculation,
* MetricCalculationVersion,
* PersonalRecord,
* PersonalRecordCandidate,
* ProgressSnapshot,
* AdherenceMetric,
* LoadMetric,
* GoalMetricLink,
* SportMetricLink,
* CustomMetricDefinition.

---

# 5. MetricDefinition

## 5.1 Význam

MetricDefinition určuje význam jednoho typu měřené nebo odvozené hodnoty.

## 5.2 Příklady

* repetitions,
* weight,
* duration,
* distance,
* pace,
* speed,
* heart_rate,
* power,
* cadence,
* elevation_gain,
* rpe,
* rir,
* sleep_duration,
* hrv,
* readiness_level,
* weekly_frequency,
* climbing_grade,
* mobility_score.

## 5.3 Vlastnosti

MetricDefinition obsahuje zejména:

* identifikátor,
* technický kód,
* název,
* lokalizované názvy,
* popis,
* kategorii,
* datový typ,
* podporované jednotky,
* výchozí jednotku,
* rozsah,
* směr zlepšení,
* podporované agregace,
* podporované objekty,
* podporované sporty,
* citlivost,
* stav,
* verzi.

## 5.4 Stav

* DRAFT,
* ACTIVE,
* DEPRECATED,
* REPLACED,
* ARCHIVED.

## 5.5 Systémová metrika

Je definována aplikací a uživatel ji nemůže měnit.

## 5.6 Uživatelská metrika

Může být vytvořena uživatelem, ale musí mít validovaný datový typ a jednotku.

---

# 6. MetricCategory

Možné kategorie:

* TIME,
* DISTANCE,
* SPEED,
* PACE,
* COUNT,
* WEIGHT,
* FORCE,
* POWER,
* ENERGY,
* HEART_RATE,
* RECOVERY,
* SLEEP,
* LOAD,
* INTENSITY,
* TECHNIQUE,
* MOBILITY,
* CONSISTENCY,
* BODY,
* ENVIRONMENT,
* QUALITATIVE,
* CUSTOM.

Kategorie pomáhá:

* organizaci,
* filtrování,
* volbě vizualizace,
* validaci.

---

# 7. MetricValueType

Podporované typy hodnot:

* INTEGER,
* DECIMAL,
* BOOLEAN,
* ENUM,
* STRING,
* DURATION,
* DATE,
* DATETIME,
* RANGE,
* SCORE,
* GRADE,
* VECTOR,
* SERIES_REFERENCE,
* STRUCTURED_VALUE.

## 7.1 INTEGER

Například počet opakování.

## 7.2 DECIMAL

Například vzdálenost nebo váha.

## 7.3 ENUM

Například readiness level.

## 7.4 RANGE

Například 8–10 opakování.

## 7.5 GRADE

Například lezecká obtížnost.

## 7.6 STRUCTURED_VALUE

Používá se pouze tam, kde jednoduchá hodnota nestačí a existuje validované schéma.

---

# 8. UnitDimension

## 8.1 Význam

Určuje fyzikální nebo logický rozměr jednotky.

## 8.2 Příklady

* TIME,
* LENGTH,
* MASS,
* SPEED,
* PACE,
* POWER,
* ENERGY,
* FREQUENCY,
* TEMPERATURE,
* PRESSURE,
* COUNT,
* PERCENTAGE,
* SCORE,
* GRADE,
* NONE.

## 8.3 Kompatibilita

Převod je možný pouze mezi kompatibilními jednotkami stejného rozměru.

Například:

* kilogramy ↔ libry,
* kilometry ↔ míle.

Není možné převádět:

* kilogramy ↔ opakování,
* tep ↔ RPE.

---

# 9. UnitDefinition

## 9.1 Vlastnosti

* identifikátor,
* technický kód,
* název,
* symbol,
* dimension,
* precision,
* způsob formátování,
* stav.

## 9.2 Příklady

* second,
* minute,
* hour,
* meter,
* kilometer,
* mile,
* kilogram,
* pound,
* bpm,
* watt,
* percent,
* repetition,
* set,
* level.

## 9.3 Bezrozměrná jednotka

Některé metriky mají jednotku:

* score,
* level,
* index,
* none.

Jejich význam musí být přesně definován v MetricDefinition.

---

# 10. UnitConversionRule

## 10.1 Význam

Definuje převod mezi kompatibilními jednotkami.

## 10.2 Vlastnosti

* source unit,
* target unit,
* vzorec,
* precision,
* rounding policy,
* verze.

## 10.3 Kanonická jednotka

Každá dimension by měla mít jednu interní kanonickou jednotku.

Příklad:

* délka v metrech,
* čas v sekundách,
* hmotnost v kilogramech.

Zobrazení může používat uživatelské preference.

## 10.4 Uložení

Doporučeno ukládat:

* hodnotu v kanonické jednotce,
* původní hodnotu,
* původní jednotku.

Tím se zachová původ i konzistentní výpočet.

---

# 11. Zaokrouhlování

RoundingPolicy může být:

* NONE,
* DISPLAY_ONLY,
* HALF_UP,
* HALF_EVEN,
* FLOOR,
* CEILING,
* SPORT_SPECIFIC.

Výpočty nemají používat zaokrouhlenou zobrazovanou hodnotu jako nový zdroj.

---

# 12. MetricValue

## 12.1 Význam

Jedna konkrétní hodnota metriky v určitém kontextu.

## 12.2 Vlastnosti

* identifikátor,
* MetricDefinition,
* hodnota,
* kanonická hodnota,
* jednotka,
* původní jednotka,
* čas nebo období,
* cílový objekt,
* zdroj,
* provenance,
* kvalita,
* přesnost,
* stav,
* vytvoření,
* poslední oprava.

## 12.3 Cílový objekt

MetricValue může být navázána na:

* Activity,
* WorkoutSession,
* SetPerformance,
* StepPerformance,
* Goal,
* DailyCheckIn,
* SleepRecord,
* UserSport,
* TrainingWeek,
* ProgressSnapshot,
* AthleteProfile.

## 12.4 Bodová hodnota versus období

Hodnota může platit:

* v konkrétním okamžiku,
* za interval,
* za celý den,
* za týden,
* za workout.

---

# 13. MetricValueStatus

* RAW,
* VALIDATED,
* ESTIMATED,
* DERIVED,
* CORRECTED,
* REJECTED,
* INVALID,
* ARCHIVED.

## 13.1 RAW

Přijatá hodnota před validací.

## 13.2 VALIDATED

Prošla validací.

## 13.3 ESTIMATED

Je odhadnutá.

## 13.4 DERIVED

Byla vypočtena.

## 13.5 CORRECTED

Byla opravena uživatelem nebo systémem.

---

# 14. MetricSource

Možné zdroje:

* USER_INPUT,
* WORKOUT_TRACKER,
* INTERNAL_SENSOR,
* WEARABLE,
* EXTERNAL_PROVIDER,
* CALCULATION,
* AI_PROPOSAL,
* SYSTEM_RULE,
* IMPORT,
* MANUAL_CORRECTION.

MetricSource nestačí sama o sobě.

Konkrétní původ popisuje MetricProvenance.

---

# 15. MetricProvenance

## 15.1 Význam

Detailní informace o původu konkrétní hodnoty.

## 15.2 Obsah

* zdroj,
* poskytovatel,
* zařízení,
* externí identifikátor,
* původní hodnota,
* původní jednotka,
* čas importu,
* transformace,
* uživatelská oprava,
* výpočet,
* verze algoritmu.

## 15.3 Příklad

Průměrný tep:

* hodnota 158 bpm,
* zdroj Garmin,
* zařízení hrudní pás,
* import přes Health Connect,
* sloučeno s interní Activity.

---

# 16. MetricQuality

## 16.1 Význam

Popisuje kvalitu hodnoty.

## 16.2 Dimenze

* accuracy,
* completeness,
* reliability,
* recency,
* consistency,
* sourceQuality,
* userConfirmation,
* sampleCoverage.

## 16.3 Úrovně

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

## 16.4 Příklad

Ruční vzdálenost:

* reliability MEDIUM,
* accuracy LOW až MEDIUM,
* userConfirmation HIGH.

---

# 17. MetricPrecision

Může obsahovat:

* počet desetinných míst,
* toleranci,
* odhadovanou chybu,
* confidence interval,
* přesnost zařízení.

Systém nemusí vždy zobrazovat technické detaily uživateli, ale musí je umět uchovat.

---

# 18. MetricValueRevision

## 18.1 Význam

Auditovaná změna MetricValue.

## 18.2 Vzniká při

* ruční opravě,
* změně jednotky,
* změně zdroje,
* opravě importu,
* přepočtu algoritmu,
* sloučení duplicit.

## 18.3 Obsah

* původní hodnota,
* nová hodnota,
* důvod,
* aktér,
* čas,
* dopad na agregace.

---

# 19. MetricSeries

## 19.1 Význam

Časová řada stejné metriky.

## 19.2 Příklady

* tep během běhu,
* výkon během cyklistiky,
* kadence,
* rychlost,
* nadmořská výška,
* HRV po dnech,
* tělesná hmotnost.

## 19.3 Vlastnosti

* MetricDefinition,
* vlastníka,
* cílový objekt,
* začátek,
* konec,
* vzorkovací strategii,
* jednotku,
* zdroj,
* kvalitu,
* počet vzorků,
* stav.

---

# 20. MetricSample

## 20.1 Obsah

* timestamp,
* hodnota,
* jednotka,
* kvalita,
* příznaky,
* sekvenční pořadí.

## 20.2 Chybějící vzorky

Řada musí umět označit:

* missing,
* interpolated,
* invalid,
* sensor_off,
* outlier.

## 20.3 Interpolace

Interpolovaná hodnota se nesmí vydávat za přímo změřenou.

---

# 21. Vzorkovací frekvence

Může být:

* pravidelná,
* nepravidelná,
* event-based,
* agregovaná.

Příklady:

* tep každou sekundu,
* hmotnost jednou denně,
* RPE jednou po workoutu.

---

# 22. Storage časových řad

Vysokofrekvenční data mohou být uložena odděleně od hlavní relační databáze.

Musí však zůstat dohledatelné:

* vlastnictví,
* MetricDefinition,
* jednotka,
* zdroj,
* časový rozsah,
* retention policy.

---

# 23. MetricAggregate

## 23.1 Význam

Agregovaná hodnota vypočtená z více měření.

## 23.2 Příklady

* týdenní vzdálenost,
* průměrný tep aktivity,
* maximální hmotnost,
* počet workoutů za týden,
* průměrná délka spánku,
* sedmidenní trend únavy.

## 23.3 Vlastnosti

* MetricDefinition,
* období,
* aggregation type,
* výsledek,
* jednotku,
* vstupní hodnoty nebo odkaz,
* verzi výpočtu,
* kvalitu,
* úplnost.

---

# 24. MetricAggregationType

* SUM,
* AVERAGE,
* MEDIAN,
* MIN,
* MAX,
* COUNT,
* DISTINCT_COUNT,
* LAST,
* FIRST,
* MOVING_AVERAGE,
* WEIGHTED_AVERAGE,
* PERCENTILE,
* RATE,
* DURATION_IN_ZONE,
* CUSTOM.

## 24.1 SUM

Například týdenní vzdálenost.

## 24.2 MAX

Například maximální váha.

## 24.3 LAST

Například poslední hodnota tělesné hmotnosti.

## 24.4 WEIGHTED_AVERAGE

Například průměr podle délky jednotlivých úseků.

---

# 25. MetricAggregationRule

## 25.1 Význam

Určuje, jak lze konkrétní metriku agregovat.

## 25.2 Příklad

Vzdálenost:

* SUM za týden,
* AVERAGE za aktivitu,
* MAX jednotlivé aktivity.

RPE:

* AVERAGE může být možné,
* SUM obvykle nedává přímý smysl bez další metodiky.

---

# 26. DerivedMetricDefinition

## 26.1 Význam

Definuje metriku vypočítávanou z jiných metrik nebo objektů.

## 26.2 Příklady

* pace z času a vzdálenosti,
* training volume z váhy a opakování,
* estimated one-rep max,
* adherence,
* load,
* readiness,
* trend.

## 26.3 Vlastnosti

* vstupní metriky,
* algoritmus,
* verze,
* výstupní jednotka,
* platnost,
* omezení,
* minimální datová kvalita.

---

# 27. MetricCalculationVersion

## 27.1 Význam

Neměnná verze výpočtu.

## 27.2 Obsah

* identifikátor,
* algoritmus nebo technický kód,
* verze,
* datum aktivace,
* vstupní požadavky,
* změny oproti předchozí verzi,
* stav.

## 27.3 Přepočet historie

Při změně algoritmu musí být určeno:

* zda se historie přepočítá,
* zda se zachovají staré výsledky,
* jak se označí změna.

---

# 28. MetricCalculation

## 28.1 Význam

Konkrétní provedení výpočtu odvozené metriky.

## 28.2 Obsah

* definice,
* verze,
* vstupy,
* výstup,
* čas,
* stav,
* chyby,
* jistota,
* důvod přepočtu.

---

# 29. Validace hodnot

MetricValidationRule může kontrolovat:

* datový typ,
* povolenou jednotku,
* minimální hodnotu,
* maximální hodnotu,
* sportovní kontext,
* čas,
* realistický rozsah,
* povinný zdroj.

## 29.1 Příklad

Heart rate:

* nesmí být záporný,
* musí být v bpm,
* extrémní hodnota může vyžadovat review.

## 29.2 Příklad

Repetitions:

* celé nezáporné číslo.

---

# 30. Outlier

Podezřelá hodnota může být označena jako:

* POSSIBLE_OUTLIER,
* CONFIRMED_VALID,
* REJECTED,
* CORRECTED.

Outlier se nemá automaticky odstranit.

Může jít o skutečný osobní rekord.

---

# 31. Baseline

## 31.1 MetricBaseline

Reprezentuje osobní výchozí nebo běžnou hodnotu.

## 31.2 Použití

* cíle,
* readiness,
* recovery,
* trend,
* návrat po pauze,
* sportovní výkon.

## 31.3 Vlastnosti

* MetricDefinition,
* období,
* hodnota,
* variabilita,
* počet vzorků,
* kvalita,
* způsob výpočtu,
* verze.

---

# 32. Dynamická baseline

Některé baseline se mění.

Příklad:

* klidový tep,
* HRV,
* týdenní objem,
* běžná délka spánku.

Systém musí uchovat:

* aktuální baseline,
* historii baseline,
* období výpočtu.

---

# 33. MetricTarget

## 33.1 Význam

Cílová hodnota metriky.

## 33.2 Typy

* EXACT,
* MINIMUM,
* MAXIMUM,
* RANGE,
* TREND,
* CONSISTENCY,
* COMPLETION.

## 33.3 Příklad

* alespoň 10 shybů,
* tempo pod 5:00/km,
* spánek v rozmezí,
* tři workouty týdně.

---

# 34. MetricDirection

* HIGHER_IS_BETTER,
* LOWER_IS_BETTER,
* TARGET_RANGE,
* STABILITY,
* CONSISTENCY,
* COMPLETION,
* CONTEXT_DEPENDENT,
* NONE.

Příklad:

* hmotnost není obecně HIGHER_IS_BETTER ani LOWER_IS_BETTER bez kontextu cíle.

---

# 35. MetricTrend

## 35.1 Význam

Odvozený směr vývoje metriky.

## 35.2 Stavy

* IMPROVING,
* DECLINING,
* STABLE,
* VOLATILE,
* INSUFFICIENT_DATA,
* CONTEXT_DEPENDENT.

## 35.3 Trend musí uvádět

* období,
* metodu,
* počet dat,
* kvalitu,
* statistickou nebo produktovou významnost,
* jistotu.

---

# 36. Trend versus zlepšení

Rostoucí hodnota není vždy zlepšení.

Příklad:

* rostoucí klidový tep může být negativní,
* rostoucí tréninkový objem může být pozitivní nebo rizikový,
* rostoucí bolest je negativní.

MetricDirection a kontext cíle určují interpretaci.

---

# 37. MetricComparison

## 37.1 Význam

Porovnání dvou hodnot nebo období.

## 37.2 Typy

* ABSOLUTE_DIFFERENCE,
* PERCENT_CHANGE,
* RATIO,
* TARGET_DIFFERENCE,
* BASELINE_DEVIATION,
* RANK,
* Z_SCORE,
* CUSTOM.

## 37.3 Bezpečnost interpretace

Procentní změna může být zavádějící u malé výchozí hodnoty.

Systém musí používat vhodný formát.

---

# 38. PersonalRecord

## 38.1 Význam

Potvrzený nejlepší výkon uživatele pro konkrétní definici.

## 38.2 Příklady

* nejvyšší váha,
* nejvíce opakování,
* nejrychlejší čas,
* nejdelší vzdálenost,
* nejtěžší lezecká obtížnost,
* největší objem.

## 38.3 Vlastnosti

* MetricDefinition,
* hodnota,
* jednotka,
* datum,
* Activity nebo WorkoutSession,
* ExerciseDefinition,
* varianta,
* podmínky,
* zdroj,
* stav ověření.

---

# 39. PersonalRecordScope

* ALL_TIME,
* YEAR,
* SEASON,
* EXERCISE,
* EXERCISE_VARIANT,
* DISTANCE,
* SPORT,
* CUSTOM.

Příklad:

Nejrychlejší čas na 5 km je jiný rekord než nejrychlejší kilometr.

---

# 40. PersonalRecordCandidate

## 40.1 Význam

Nová hodnota, která může být rekordem.

## 40.2 Proces

1. vznikne kandidát,
2. ověří se jednotky a kontext,
3. porovná se s existujícími rekordy,
4. zkontroluje se kvalita dat,
5. vytvoří se PersonalRecord.

## 40.3 Nízká kvalita dat

Rekord může vyžadovat potvrzení uživatele.

---

# 41. Rekord u variant cviku

Výkony se nesmí automaticky srovnávat mezi nesrovnatelnými variantami.

Příklad:

* shyb s dopomocí,
* klasický shyb,
* shyb s přidanou zátěží.

ExerciseVariant musí být součástí kontextu rekordu.

---

# 42. EstimatedOneRepMax

Pokud bude podporováno, jde o derived metric.

Musí obsahovat:

* použitý vzorec,
* váhu,
* opakování,
* verzi,
* jistotu,
* omezení.

Nesmí být prezentováno stejně jako skutečně provedené maximum.

---

# 43. TrainingVolume

Může být definován různě podle sportu.

Silový příklad:

```text
weight × repetitions
```

Ale tento výpočet:

* neřeší rozsah pohybu,
* variantu cviku,
* tempo,
* jednostrannost,
* tělesnou hmotnost.

Proto musí být jeho význam omezený a explicitní.

---

# 44. LoadMetric

## 44.1 Význam

Odvozená metrika zátěže.

## 44.2 Typy

* OVERALL,
* AEROBIC,
* ANAEROBIC,
* STRENGTH,
* POWER,
* SPEED,
* IMPACT,
* CONTACT,
* GRIP,
* LOCAL_BODY_AREA,
* TECHNICAL,
* SUBJECTIVE.

## 44.3 Vstupy

* délka,
* intenzita,
* sport,
* RPE,
* tep,
* výkon,
* série,
* opakování,
* anatomický profil.

## 44.4 Load není univerzální pravda

Musí uvádět:

* metodiku,
* jistotu,
* zdroj,
* verzi.

---

# 45. Session RPE Load

Možný jednoduchý odhad:

```text
duration × session RPE
```

Pokud bude použit:

* musí být jasně označen,
* nesmí být bez dalšího srovnáván s jinými metodikami,
* musí používat definovanou časovou jednotku.

---

# 46. ReadinessMetric

Readiness může být:

* enum,
* score,
* multidimenzionální objekt.

Doporučeno nepoužívat pouze jedno číslo.

Metriky mohou obsahovat:

* general readiness,
* local readiness,
* cardiovascular readiness,
* muscular readiness,
* mental readiness.

---

# 47. RecoveryMetric

Může zahrnovat:

* HRV,
* klidový tep,
* spánek,
* únavu,
* svalovou bolest,
* stres,
* wearable score.

Interní ReadinessAssessment nesmí být totožný s proprietárním wearable skóre.

---

# 48. SleepMetric

Příklady:

* total sleep duration,
* time in bed,
* subjective quality,
* sleep continuity,
* number of awakenings,
* sleep stage estimate,
* deviation from baseline.

Fáze spánku musí mít označený zdroj a kvalitu.

---

# 49. GoalMetricLink

## 49.1 Význam

Propojuje Goal s MetricDefinition.

## 49.2 Vlastnosti

* role,
* baseline,
* target,
* direction,
* aggregation,
* measurement frequency,
* source preference,
* completion rule.

## 49.3 Role

* PRIMARY,
* SECONDARY,
* SUPPORTING,
* SAFETY,
* CONTEXT.

---

# 50. SportMetricLink

## 50.1 Význam

Určuje relevanci metriky pro konkrétní sport.

## 50.2 Vlastnosti

* SportDefinition,
* MetricDefinition,
* role,
* default unit,
* applicability,
* special validation,
* display priority.

---

# 51. WorkoutMetricLink

Může určit:

* které metriky jsou plánované,
* které se mají zaznamenávat,
* které jsou volitelné,
* které určují dokončení.

Příklad:

Běžecký interval může vyžadovat:

* čas,
* vzdálenost,
* tempo.

---

# 52. MetricPlanValue

Plánovaná hodnota může být:

* přesná,
* minimální,
* maximální,
* rozsah,
* target zone,
* kvalitativní instrukce.

Příklad:

* 8–10 opakování,
* 30–40 minut,
* RPE 6–7,
* tepová zóna 2.

---

# 53. PlannedMetric versus ActualMetric

Musí být možné přímo porovnat:

* plánovanou hodnotu,
* skutečnou hodnotu,
* toleranci,
* stav splnění.

## 53.1 CompletionStatus

* MET,
* BELOW_TARGET,
* ABOVE_TARGET,
* WITHIN_RANGE,
* PARTIAL,
* NOT_RECORDED,
* NOT_APPLICABLE.

Nad cílem neznamená vždy lepší výsledek.

Příklad:

Vyšší RPE než plánované může být negativní.

---

# 54. MetricTolerance

Může být:

* absolutní,
* procentní,
* rozsah,
* sportovně specifická,
* bez tolerance.

Příklad:

Plán 5 km může tolerovat malou odchylku.

---

# 55. AdherenceMetric

## 55.1 Význam

Vyhodnocuje vztah mezi plánem a skutečností.

## 55.2 Nesmí být pouze

```text
completed workouts / planned workouts
```

## 55.3 Musí zohlednit

* zrušené workouty,
* schválené změny,
* náhradní aktivity,
* částečné dokončení,
* recovery úpravy,
* aktivní omezení,
* změny plánu,
* prioritu workoutů.

## 55.4 Typy adherence

* SCHEDULE_ADHERENCE,
* PURPOSE_ADHERENCE,
* VOLUME_ADHERENCE,
* FREQUENCY_ADHERENCE,
* GOAL_ADHERENCE,
* CONSISTENCY.

---

# 56. Purpose Adherence

Příklad:

Uživatel provedl hlavní silovou část, ale ne accessory cviky.

Workout může mít:

* nižší volume adherence,
* vysokou purpose adherence.

To je produktově užitečnější než jedno procento.

---

# 57. Weighted adherence

Workouty mohou mít váhu podle:

* priority,
* role,
* cíle,
* typu týdne.

Optional mobility nesmí mít stejnou váhu jako cílový závod.

---

# 58. Recovery-adjusted adherence

Workout změněný kvůli doporučené regeneraci se posuzuje vůči aktualizovanému plánu, ne původnímu.

---

# 59. ConsistencyMetric

Může vyhodnocovat:

* počet aktivních týdnů,
* splněnou frekvenci,
* pravidelnost,
* streak.

## 59.1 Streak

Streak nesmí motivovat k nebezpečnému chování.

Nemá se přerušovat při:

* plánovaném odpočinku,
* nemoci,
* odborném omezení,
* schválené změně cíle,

pokud produktová definice používá flexibilní konzistenci.

---

# 60. ProgressSnapshot

## 60.1 Význam

Odvozený přehled pokroku v určitém okamžiku.

## 60.2 Obsah

* cíle,
* hlavní metriky,
* trendy,
* milníky,
* adherence,
* osobní rekordy,
* kvalitu dat,
* nejistotu.

## 60.3 Není zdroj pravdy

Je sestaven z:

* MetricValue,
* Activity,
* Goal,
* PersonalRecord,
* GoalAssessment.

---

# 61. ProgressPeriod

Možná období:

* DAY,
* WEEK,
* MONTH,
* TRAINING_BLOCK,
* SEASON,
* PLAN,
* CUSTOM.

---

# 62. Progress interpretation

Systém musí rozlišovat:

* zlepšení,
* udržování,
* krátkodobý pokles,
* stagnaci,
* nedostatek dat,
* změnu metodiky.

---

# 63. Porovnatelnost hodnot

Dvě hodnoty lze porovnat pouze pokud mají kompatibilní:

* MetricDefinition,
* jednotku,
* sportovní kontext,
* variantu,
* podmínky,
* výpočetní verzi.

Příklad:

Čas na 5 km není přímo porovnatelný s časem na trailových 5 km bez kontextu.

---

# 64. MetricContext

Může obsahovat:

* sport,
* aktivitu,
* cvik,
* variantu,
* vzdálenost,
* povrch,
* prostředí,
* stranu těla,
* zařízení,
* fázi plánu,
* časové období.

---

# 65. ContextKey

Pro rekordy a porovnání může systém vytvářet stabilní kontextový klíč.

Příklad:

```text
exercise=pull_up
variant=bodyweight_strict
metric=repetitions
```

---

# 66. ClimbingGradeMetric

## 66.1 Problém

Lezecké obtížnosti používají různé klasifikační systémy.

## 66.2 Model

Hodnota musí obsahovat:

* grading system,
* grade,
* discipline,
* případně style.

## 66.3 Převod

Převody mezi klasifikacemi jsou pouze orientační.

Musí uvádět:

* převodní tabulku,
* verzi,
* nejistotu.

---

# 67. GradeDefinition

Může definovat:

* systém,
* pořadí,
* zobrazovanou hodnotu,
* disciplínu,
* region,
* sousední stupně.

Nelze předpokládat čistě lineární numerickou vzdálenost mezi stupni.

---

# 68. PaceMetric

Tempo musí být reprezentováno jako:

* čas na jednotku vzdálenosti,
* ne pouze běžné desetinné číslo bez významu.

Příklady:

* min/km,
* min/mile.

Interně lze ukládat sekundy na metr nebo vhodnou kanonickou hodnotu.

---

# 69. SpeedMetric

Rychlost je vzdálenost za čas.

Pace a speed jsou propojené, ale nejsou stejnou metrikou.

Převod není vhodný při nulové hodnotě a musí řešit přesnost.

---

# 70. DurationMetric

Musí rozlišovat:

* elapsed duration,
* active duration,
* moving duration,
* paused duration,
* planned duration.

---

# 71. DistanceMetric

Musí mít:

* hodnotu,
* jednotku,
* zdroj,
* kvalitu,
* způsob měření.

Příklad:

* GPS,
* footpod,
* treadmill,
* manual.

---

# 72. HeartRateMetric

Podporované hodnoty:

* average,
* maximum,
* minimum,
* resting,
* zone duration,
* sample series.

Musí být znám:

* senzor,
* zdroj,
* kvalita,
* případné mezery.

---

# 73. HeartRateZone

Zóny mohou být založené na:

* maximálním tepu,
* rezervě tepu,
* prahu,
* externí metodice,
* ručním nastavení.

Musí být verzované.

Změna zón nesmí neviditelně změnit historickou interpretaci bez přepočtu.

---

# 74. PowerMetric

Použití:

* cyklistika,
* běh,
* veslování,
* jiné sporty.

Musí rozlišovat:

* measured,
* estimated,
* average,
* maximum,
* normalized podle konkrétní metodiky.

---

# 75. RPE

## 75.1 Definice

Subjektivní vnímaná náročnost.

## 75.2 Kontexty

* set RPE,
* exercise RPE,
* session RPE,
* activity RPE.

Tyto hodnoty se nesmí směšovat.

## 75.3 Škála

Každá hodnota musí odkazovat na konkrétní škálu.

---

# 76. RIR

Repetitions in reserve.

Musí obsahovat:

* celočíselnou nebo validovanou hodnotu,
* kontext série,
* subjektivní charakter.

Není totožné s RPE, i když mezi nimi může být orientační vztah.

---

# 77. MobilityMetric

Může být:

* objektivní rozsah,
* kvalitativní test,
* subjektivní pocit,
* splnění pozice,
* score.

Musí jasně uvádět metodiku.

---

# 78. QualitativeMetric

## 78.1 Význam

Metrika bez čistě numerické povahy.

Příklady:

* technika dobrá/střední/slabá,
* subjektivní pohyblivost,
* pocit jistoty,
* bolest bez/nízká/střední/vysoká.

## 78.2 Pravidla

Musí mít:

* definované možnosti,
* pořadí, pokud existuje,
* význam,
* zdroj.

---

# 79. CustomMetricDefinition

## 79.1 Význam

Metrika vytvořená uživatelem.

## 79.2 Povinné údaje

* název,
* typ hodnoty,
* jednotka,
* směr,
* kontext,
* způsob zadání.

## 79.3 Omezení

Uživatel nesmí vytvořit metriku se stejným technickým kódem jako systémová.

## 79.4 AI pomoc

AI může navrhnout definici, ale musí být potvrzena.

---

# 80. MetricAlias

Může pomoci s různými názvy:

* body weight,
* body mass,
* hmotnost.

Alias nesmí měnit význam metriky.

---

# 81. Deprecated metric

Pokud je metrika nahrazena:

* historické hodnoty zůstávají,
* nová data se zapisují do nové definice,
* může existovat migrační nebo převodní pravidlo.

---

# 82. Metric calculation dependencies

Odvozená metrika musí uchovávat závislosti.

Příklad:

Pace závisí na:

* duration,
* distance.

Při opravě vstupu se označí odvozená hodnota k přepočtu.

---

# 83. RecalculationJob

## 83.1 Význam

Úloha přepočtu odvozených metrik.

## 83.2 Spouštěče

* oprava aktivity,
* změna algoritmu,
* sloučení duplicit,
* změna zón,
* změna baseline,
* nový import.

## 83.3 Stav

* PENDING,
* RUNNING,
* COMPLETED,
* FAILED,
* PARTIAL.

---

# 84. Výpočetní konzistence

Stejná verze algoritmu a stejné vstupy musí dát stejný výsledek, pokud algoritmus není explicitně nedeterministický.

---

# 85. Cache agregací

Často používané agregace mohou být cacheované.

Příklad:

* týdenní vzdálenost,
* měsíční počet workoutů,
* poslední rekordy.

Cache není zdroj pravdy.

Musí být možné ji přepočítat.

---

# 86. Aktualizace agregací

Může probíhat:

* synchronně,
* asynchronně,
* event-driven,
* dávkově.

Uživatel musí být informován, pokud se statistiky ještě přepočítávají.

---

# 87. Metric conflict

Konflikt může vzniknout:

* více zdrojů se stejnou metrikou,
* ruční oprava proti importu,
* dvě zařízení,
* odlišné jednotky,
* odlišné algoritmy.

---

# 88. MetricConflictResolution

Možnosti:

* prefer source,
* user selection,
* merge,
* keep both,
* mark one invalid,
* derive a new value.

Původní hodnoty se nemají bez auditu ztratit.

---

# 89. Zdrojová priorita

Musí být definovatelná podle konkrétní metriky.

Příklad:

* tep z hrudního pásu před optickým senzorem,
* sportovní klasifikace opravená uživatelem před automatickou,
* vzdálenost z footpodu před nekvalitní GPS podle kontextu.

---

# 90. MetricCorrection

Uživatelská oprava musí obsahovat:

* původní hodnotu,
* novou hodnotu,
* důvod,
* datum,
* dopad na odvozené metriky,
* původní zdroj.

---

# 91. Vyloučení ze statistik

MetricValue může být:

* validní historický údaj,
* ale vyloučený z určité agregace.

Příklad:

* chybný GPS spike,
* testovací aktivita,
* ručně označený neplatný rekord.

---

# 92. MetricInclusionPolicy

Určuje, zda se hodnota používá pro:

* progress,
* personal records,
* load,
* adherence,
* baseline,
* AI context,
* export.

---

# 93. Citlivost metrik

MetricSensitivity:

* PUBLIC,
* PERSONAL,
* SENSITIVE,
* HEALTH_RELATED,
* LOCATION_DERIVED,
* AUTHENTICATION_RELATED.

Příklady citlivých metrik:

* HRV,
* spánek,
* bolest,
* tělesná hmotnost,
* zdravotně relevantní hodnoty.

---

# 94. AI přístup k metrikám

AI smí dostat jen relevantní agregace nebo hodnoty.

Příklad:

Pro plán dne může potřebovat:

* poslední únavu,
* sleep summary,
* relevantní load.

Nemusí dostat všechny historické vzorky tepu.

---

# 95. MetricSummaryForAI

Bezpečný strukturovaný read model může obsahovat:

* aktuální hodnotu,
* baseline,
* trend,
* kvalitu,
* čas,
* kontext,
* upozornění.

---

# 96. Produktová analytika

Sportovní metriky nesmí automaticky vstupovat do běžné produktové analytiky.

Produktová analytika může zaznamenat:

* metric_recorded,
* personal_record_detected,
* metric_corrected,
* metric_sync_failed.

Ne konkrétní citlivou hodnotu.

---

# 97. Offline režim

Offline musí být možné:

* zadat MetricValue,
* uložit set performance,
* zadat RPE,
* zaznamenat délku,
* ukládat sensor samples,
* zobrazit lokálně dostupnou historii,
* vytvořit osobní rekordový kandidát.

---

# 98. Offline identifikátory

Každá nová MetricValue a MetricSample musí mít identifikátor vytvořitelný offline.

---

# 99. Offline agregace

Mobilní aplikace může počítat některé jednoduché agregace lokálně:

* počet sérií,
* délku workoutu,
* součet opakování.

Server zůstává autoritativní pro:

* komplexní výpočty,
* deduplikaci,
* globální historii,
* verzované algoritmy.

---

# 100. Synchronizace hodnot

Musí být idempotentní.

Opakované odeslání stejné MetricValue nesmí vytvořit duplicitu.

---

# 101. Konflikt hodnoty

Příklad:

* offline uživatel opraví váhu na 80 kg,
* na jiném zařízení ji opraví na 82,5 kg.

Systém musí:

* zachovat obě revize,
* označit konflikt,
* požádat o výběr,
* nepoužít náhodnou hodnotu.

---

# 102. Časová synchronizace vzorků

MetricSample musí mít:

* timestamp,
* source sequence,
* případný device clock offset.

To je důležité při sloučení více senzorů.

---

# 103. Import časových řad

Import musí řešit:

* duplicity,
* překryvy,
* změny poskytovatele,
* různé frekvence,
* chybějící data,
* opravy.

---

# 104. Retention policy

Detailní vzorky mohou mít jinou retenční dobu než agregace.

Příklad:

* vysokofrekvenční GPS a tep archivovat,
* denní souhrny ponechat déle.

Uživatel musí být informován.

---

# 105. Export metrik

Export musí umožnit:

* definice,
* hodnoty,
* jednotky,
* zdroje,
* čas,
* kvalitu,
* případné časové řady,
* odvozené hodnoty a verzi algoritmu.

---

# 106. Smazání metrik

Fyzické smazání musí zohlednit:

* zdrojovou Activity,
* odvozené agregace,
* osobní rekordy,
* cíle,
* právní a retenční pravidla.

Přepočet musí odstranit závislé derived metrics nebo je označit jako neplatné.

---

# 107. Doménové služby

## 107.1 MetricDefinitionService

Spravuje:

* definice,
* jednotky,
* kompatibilitu,
* validaci.

## 107.2 UnitConversionService

Provádí bezpečné převody.

## 107.3 MetricRecordingService

Ukládá jednotlivé hodnoty.

## 107.4 MetricSeriesService

Spravuje časové řady.

## 107.5 MetricAggregationService

Počítá agregace.

## 107.6 MetricCalculationService

Počítá odvozené metriky.

## 107.7 PersonalRecordService

Detekuje a potvrzuje rekordy.

## 107.8 ProgressMetricService

Připravuje progress snapshot.

## 107.9 MetricConflictService

Řeší konflikty zdrojů.

## 107.10 MetricCorrectionService

Provádí auditované opravy.

---

# 108. Doménové události

Minimálně:

* MetricDefinitionCreated
* MetricDefinitionUpdated
* MetricDefinitionDeprecated
* CustomMetricCreated
* MetricValueRecorded
* MetricValueValidated
* MetricValueRejected
* MetricValueCorrected
* MetricValueDeleted
* MetricSeriesCreated
* MetricSampleRecorded
* MetricSeriesCompleted
* MetricAggregateCalculated
* DerivedMetricCalculated
* MetricCalculationFailed
* MetricBaselineCalculated
* MetricBaselineUpdated
* MetricTrendCalculated
* MetricTargetReached
* PersonalRecordCandidateDetected
* PersonalRecordConfirmed
* PersonalRecordInvalidated
* MetricConflictDetected
* MetricConflictResolved
* ProgressSnapshotCreated
* AdherenceCalculated
* LoadMetricCalculated
* RecalculationRequested
* RecalculationCompleted

---

# 109. Příkazy

Minimálně:

* CreateMetricDefinition
* CreateCustomMetricDefinition
* UpdateMetricDefinition
* DeprecateMetricDefinition
* RecordMetricValue
* ValidateMetricValue
* CorrectMetricValue
* DeleteMetricValue
* CreateMetricSeries
* RecordMetricSample
* CompleteMetricSeries
* CalculateMetricAggregate
* CalculateDerivedMetric
* CalculateMetricBaseline
* CalculateMetricTrend
* CreateMetricTarget
* DetectPersonalRecord
* ConfirmPersonalRecord
* InvalidatePersonalRecord
* ResolveMetricConflict
* CreateProgressSnapshot
* CalculateAdherence
* CalculateLoadMetric
* RecalculateDependentMetrics

---

# 110. Invariance – definice

* MetricDefinition musí mít jedinečný technický kód.
* Musí mít datový typ.
* Podporované jednotky musí být kompatibilní s UnitDimension.
* Deprecated metrika nesmí přijímat nová data bez explicitní migrační politiky.

---

# 111. Invariance – hodnota

* MetricValue musí odkazovat na existující MetricDefinition.
* Hodnota musí odpovídat datovému typu.
* Jednotka musí být povolená.
* Hodnota nesmí porušit blokující validační pravidlo.
* Každá hodnota musí mít zdroj.

---

# 112. Invariance – jednotky

* Převod je povolen pouze mezi kompatibilními dimensions.
* Původní hodnota a jednotka se nesmí ztratit.
* Zobrazené zaokrouhlení nesmí změnit uložený výpočetní základ.

---

# 113. Invariance – odvozené metriky

* Derived metric musí mít výpočetní verzi.
* Musí mít dohledatelné vstupy.
* Při změně vstupu musí být označena k přepočtu.
* Odhad se nesmí vydávat za měřenou hodnotu.

---

# 114. Invariance – rekordy

* Rekord musí být založen na porovnatelné metrice.
* Musí respektovat variantu a kontext.
* DUPLICATE nebo INVALID Activity nesmí vytvořit rekord.
* Zrušení rekordu nesmí odstranit původní Activity.

---

# 115. Invariance – agregace

* Agregace musí používat povolený aggregation type.
* Musí uvádět období.
* Musí znát úplnost vstupů.
* Nesmí započítat vyloučené duplicity.

---

# 116. Invariance – cíle

* GoalMetricLink musí používat kompatibilní MetricDefinition.
* Numerický target musí mít kompatibilní jednotku.
* Kvalitativní cíl nesmí být automaticky převeden na číselné procento bez metodiky.

---

# 117. Invariance – synchronizace

* Opakovaná synchronizace nesmí vytvořit duplicitní hodnotu.
* Konflikt nesmí neviditelně zahodit uživatelskou opravu.
* Offline hodnota musí mít stabilní identifikátor.

---

# 118. Invariance – AI

* AI nesmí vytvářet historické měření bez zdroje.
* AI může navrhnout MetricDefinition, ale ne aktivovat citlivou metriku bez validace.
* AI nesmí prezentovat nízkokvalitní odhad jako přesný fakt.
* AI nesmí svévolně měnit cíl metriky.

---

# 119. Read modely

## 119.1 MetricValueView

Obsahuje:

* název,
* hodnotu,
* jednotku,
* čas,
* zdroj,
* kvalitu.

## 119.2 MetricTrendView

Obsahuje:

* období,
* trend,
* počáteční hodnotu,
* aktuální hodnotu,
* jistotu.

## 119.3 PersonalRecordView

Obsahuje:

* metriku,
* výkon,
* datum,
* kontext,
* zdroj.

## 119.4 GoalMetricProgressView

Obsahuje:

* baseline,
* current,
* target,
* trend,
* milníky,
* kvalitu dat.

## 119.5 ActivityMetricsView

Obsahuje:

* hlavní metriky aktivity,
* časové řady,
* zdroje,
* opravy.

## 119.6 WeeklyMetricsView

Obsahuje:

* agregace,
* adherence,
* load,
* změny oproti minulému období.

## 119.7 MetricConflictView

Obsahuje:

* konfliktní hodnoty,
* zdroje,
* kvalitu,
* doporučené řešení.

---

# 120. Příklad – série shybů

## Plán

* repetitions: 6–8,
* sets: 4,
* target RIR: 2.

## Skutečnost

* 8,
* 7,
* 6,
* 5 opakování.

## Uložené metriky

SetPerformance:

* repetitions,
* RIR,
* completion.

Workout aggregate:

* total repetitions = 26,
* completed sets = 4.

Potential record:

* nejvíce celkových opakování v tomto workoutu,
* pokud definice rekordu existuje.

---

# 121. Příklad – běh

## Zdroj

GPS hodinky.

## Hodnoty

* duration: 51:32,
* distance: 10.2 km,
* average pace,
* average heart rate,
* elevation gain.

## Odvozené metriky

* pace,
* load,
* trend.

Každá odvozená metrika uchovává výpočetní verzi.

---

# 122. Příklad – ruční běh bez GPS

Uživatel zadá:

* 45 minut,
* přibližně 8 km,
* RPE 6.

Kvalita:

* duration HIGH,
* distance MEDIUM nebo LOW,
* RPE user-confirmed.

Systém nesmí zobrazovat stejné množství desetinných míst jako u přesné GPS.

---

# 123. Příklad – florbal

Metriky:

* duration,
* session RPE,
* match/training,
* subjective lower-body fatigue.

Odvozené:

* session load,
* impact load estimate.

Výpočet musí být označen jako odhad.

---

# 124. Příklad – mobility goal

Cíl:

> Zlepšit mobilitu kotníků.

Metriky:

* kvalitativní test,
* knee-to-wall vzdálenost,
* pravidelnost workoutů,
* subjektivní omezení.

Není nutné převádět celý cíl na jedno procento.

---

# 125. Příklad – spánek

Zdroje:

* wearable: 6 h 22 min,
* uživatel: subjektivní kvalita 2/5.

SleepSummary kombinuje:

* délku,
* subjektivní kvalitu,
* odchylku od baseline,
* kvalitu zdrojů.

---

# 126. Příklad – konflikt tepu

Zdroje:

* optické hodinky: průměr 170,
* hrudní pás: průměr 158.

MetricConflictService:

* vyhodnotí zdrojovou prioritu,
* zachová obě hodnoty,
* použije 158 jako primární,
* provenance zůstane zachována.

---

# 127. Příklad – osobní rekord

Uživatel provede:

* 10 čistých shybů.

PersonalRecordCandidate:

* metric repetitions,
* exercise pull-up,
* variant strict bodyweight,
* data quality HIGH.

Po ověření vznikne PersonalRecord.

---

# 128. Příklad – neplatný rekord

Hodinky zaznamenají běh 1 km za 45 sekund.

Hodnota:

* POSSIBLE_OUTLIER,
* ActivityValidation review required.

Nevytvoří se automatický rekord.

---

# 129. Příklad – adherence

Plán:

* 2 hlavní workouty,
* 3 ranní mobility,
* 1 volitelný core.

Skutečnost:

* oba hlavní workouty dokončeny,
* 2 mobility,
* core vynechán.

Výsledek může být:

* vysoká purpose adherence,
* střední frequency adherence,
* volitelný core má nízkou váhu.

---

# 130. Příklad – změna plánu kvůli bolesti

Původní workout byl upraven systémem.

Adherence se posuzuje vůči schválené adaptované verzi, ne původnímu workoutu.

---

# 131. Příklad – vlastní sportovní metrika

Uživatel chce sledovat:

> Počet kvalitních technických pokusů při lezení.

CustomMetricDefinition:

* integer,
* unit attempt,
* higher is context-dependent,
* sport climbing,
* user input.

---

# 132. Co musí být strukturované

Nesmí zůstat pouze jako volný text:

* definice metriky,
* datový typ,
* jednotka,
* hodnota,
* zdroj,
* čas,
* kvalita,
* baseline,
* target,
* agregace,
* výpočetní verze,
* rekord,
* trend,
* conflict,
* oprava,
* synchronizační stav.

Volný text může doplňovat:

* poznámku,
* vysvětlení,
* subjektivní komentář,
* původní uživatelský vstup.

---

# 133. Otevřené otázky

* Jaké systémové metriky budou součástí první verze?
* Jak přesně reprezentovat rozsahovou hodnotu?
* Jak ukládat strukturované grade metriky?
* Jaký bude seznam kanonických jednotek?
* Jak přesně řešit přesnost a zaokrouhlování?
* Jak ukládat vysokofrekvenční časové řady?
* Jak dlouho uchovávat raw sensor samples?
* Jak verzovat calculation algorithms?
* Kdy přepočítat historická data?
* Jak zobrazit změnu výsledku po změně algoritmu?
* Jaké derived metrics počítat lokálně?
* Jak detekovat outliers podle sportu?
* Jakou prioritu zdrojů použít pro tep, vzdálenost a výkon?
* Jak řešit dvě validní hodnoty stejné metriky?
* Jak definovat personal record context?
* Jak porovnávat cviky s vlastní hmotností a dodatečnou zátěží?
* Jak modelovat lezecké obtížnosti?
* Jak pracovat s převody klasifikací?
* Jak definovat adherence bez manipulativního hodnocení?
* Jak zobrazovat kvalitativní pokrok?
* Jak počítat load napříč sporty?
* Má existovat univerzální overall load?
* Jak komunikovat jistotu uživateli?
* Jak pracovat s chybějícími vzorky?
* Jak synchronizovat velké časové řady?
* Jak řešit opravu staré hodnoty a přepočet revizí?
* Jak ukládat user-defined metrics bezpečně?
* Jak zabránit duplicitním definicím?
* Jak exportovat časové řady?
* Jak odstraňovat citlivé metriky?
* Které metriky smí být dostupné AI?
* Jaké agregace počítat v reálném čase?
* Jak řešit časová pásma u denních agregací?
* Jak řešit týdenní období podle lokalizace?
* Jak podporovat více systémů jednotek?
* Jak zobrazovat pace a speed?
* Jak pracovat s intervalovými hodnotami?
* Jak definovat target zones?
* Jak modelovat normativní hodnoty bez medicínského posuzování?
* Jak oddělit sportovní metriku od zdravotní interpretace?

---

# 134. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── integration-model.md
├── sync-and-offline-model.md
├── identity-and-profile-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/07-backend/
├── metrics-service.md
├── time-series-storage.md
├── aggregation-service.md
├── calculation-engine.md
├── personal-record-service.md
└── progress-service.md
```

A:

```text
docs/08-mobile/
├── metrics-ui.md
├── progress-charts.md
├── unit-formatting.md
├── offline-metrics.md
└── sensor-recording.md
```

---

# 135. Kritéria správného metrics modelu

Model je vhodný pouze tehdy, pokud umožní:

1. definovat systémovou metriku,
2. vytvořit vlastní metriku,
3. ukládat různé datové typy,
4. podporovat jednotky,
5. bezpečně převádět jednotky,
6. zachovat původní hodnotu,
7. ukládat zdroj,
8. vyjádřit kvalitu,
9. ukládat plánované hodnoty,
10. ukládat skutečné hodnoty,
11. ukládat rozsahy,
12. ukládat časové řady,
13. počítat agregace,
14. verzovat výpočty,
15. přepočítat závislé metriky,
16. vytvářet baseline,
17. vytvářet target,
18. počítat trend,
19. detekovat rekord,
20. ověřit rekord,
21. zneplatnit chybný rekord,
22. podporovat adherence,
23. podporovat load,
24. podporovat readiness,
25. podporovat recovery,
26. podporovat kvalitativní cíle,
27. podporovat libovolný sport,
28. řešit konfliktní zdroje,
29. opravovat hodnoty,
30. zachovat audit,
31. fungovat offline,
32. synchronizovat více zařízení,
33. zabránit duplicitám,
34. exportovat data,
35. chránit citlivé metriky,
36. zabránit falešné přesnosti,
37. podporovat nové metriky bez změny základního modelu.

---

# 136. Závěr

Metrics model poskytuje společný jazyk pro všechny měřené, subjektivní a odvozené hodnoty v aplikaci.

Jeho základní tok je:

```text
MetricDefinition
    ↓
MetricValue / MetricSeries
    ↓
MetricValidation
    ↓
MetricAggregate
    ↓
DerivedMetricCalculation
    ↓
MetricTrend / PersonalRecord
    ↓
GoalProgress / Readiness / Load / Adherence
```

Tok opravy je:

```text
Raw MetricValue
    ↓
MetricCorrection
    ↓
MetricValueRevision
    ↓
RecalculationJob
    ↓
Nové agregace a odvozené hodnoty
```

Tok zdrojů je:

```text
Uživatel / Workout / Wearable / GPS / Import
    ↓
MetricProvenance
    ↓
MetricQuality
    ↓
Validovaná MetricValue
```

Hlavním cílem není shromáždit co nejvíce čísel.

Cílem je vytvořit systém, ve kterém každá hodnota má:

* jasný význam,
* platnou jednotku,
* známý zdroj,
* známou kvalitu,
* správný kontext,
* odpovídající způsob porovnání,
* auditovanou historii.

Díky tomu může aplikace současně pracovat s:

* opakováními v silovém workoutu,
* vzdáleností při běhu,
* RPE po florbalu,
* lezeckou obtížností,
* kvalitou spánku,
* HRV,
* subjektivní únavou,
* pravidelností tréninku,
* vlastním ukazatelem uživatele,

aniž by všechny tyto odlišné hodnoty zjednodušila na nejasná čísla bez kontextu.
