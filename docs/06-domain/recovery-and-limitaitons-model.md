# AI Trainer – Recovery and Limitations Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/recovery-and-limitations-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model regenerace, připravenosti, únavy, bolesti, omezení a bezpečnostního rozhodování v aplikaci AI Trainer.

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
* `docs/06-domain/activity-model.md`,
* `docs/06-domain/scheduling-model.md`,
* `docs/06-domain/sports-and-goals-model.md`.

Dokument popisuje:

* subjektivní denní stav uživatele,
* únavu,
* regeneraci,
* připravenost k tréninku,
* spánek,
* stres,
* svalovou bolest,
* akutní bolest,
* dlouhodobá a dočasná omezení,
* odborná doporučení,
* jednostranná omezení,
* dopad omezení na pohybové vzory,
* bezpečnostní vyhodnocení,
* práci s nejistotou,
* vztah k wearables,
* vztah k plánovaným workoutům,
* úpravu dne, týdne a plánu,
* pravidla pro AI,
* audit,
* historii,
* offline fungování,
* synchronizaci,
* doménové invariance.

Dokument zatím neurčuje:

* konkrétní medicínské diagnostické postupy,
* klinické rozhodovací algoritmy,
* přesné databázové tabulky,
* finální API kontrakty,
* konkrétní AI prompty,
* konkrétní wearable skóre jednotlivých výrobců,
* přesné UI mapy těla,
* konkrétní právní texty.

---

# 2. Cíl modelu

Model musí umožnit, aby aplikace dokázala bezpečně reagovat na situace jako:

* „Dnes jsem hodně unavený.“
* „Spal jsem jen čtyři hodiny.“
* „Bolí mě pravý biceps.“
* „Při dřepu mě píchá v koleni.“
* „Mám svalovici po včerejším zápase.“
* „Lékař mi řekl, že dva týdny nemám běhat.“
* „Hodinky říkají, že nejsem zregenerovaný, ale cítím se dobře.“
* „Cítím se vyčerpaně, i když hodinky ukazují dobrou regeneraci.“
* „Po nemoci se chci vrátit k tréninku.“
* „Rameno mě bolí jen při tlaku nad hlavu.“
* „Mám staré zranění kolene, ale běžně sportuji.“

Systém musí umět:

* vstup strukturovat,
* rozlišit únavu od bolesti,
* rozlišit běžnou svalovou bolest od možného rizikového stavu,
* zohlednit dobu trvání,
* zohlednit stranu těla,
* zohlednit pohyb, který problém vyvolává,
* vyhodnotit ovlivněné workouty,
* navrhnout bezpečnější variantu,
* přiznat nejistotu,
* doporučit odbornou konzultaci tam, kde je to vhodné,
* zabránit tomu, aby AI stanovovala diagnózu.

---

# 3. Základní principy

## 3.1 Aplikace není zdravotnický diagnostický nástroj

AI Trainer nesmí:

* stanovovat diagnózu,
* tvrdit, že bolest má konkrétní medicínskou příčinu,
* nahrazovat lékaře, fyzioterapeuta nebo jiného odborníka,
* doporučovat ignorování odborného omezení,
* prezentovat wearable skóre jako zdravotní pravdu.

Může:

* strukturovat uživatelský vstup,
* rozpoznat varovné znaky,
* upravit nebo zastavit tréninkové doporučení,
* doporučit odbornou konzultaci,
* respektovat odborné doporučení,
* pracovat s obecnými zásadami bezpečnosti.

## 3.2 Subjektivní a objektivní data jsou rovnocenné vstupy

Wearables nejsou automaticky nadřazené uživatelskému pocitu.

Systém musí kombinovat:

* subjektivní únavu,
* subjektivní bolest,
* kvalitu spánku,
* stres,
* skutečné aktivity,
* wearable data,
* dlouhodobý trend,
* důležitost plánovaného workoutu.

## 3.3 Jedno číslo nesmí rozhodovat o celém tréninku

Například nízké HRV samo o sobě nemá automaticky zrušit workout.

Stejně tak dobré recovery score nemá přebít hlášení ostré bolesti.

## 3.4 Nejistota musí být explicitní

Každé vyhodnocení připravenosti nebo rizika musí umět vyjádřit:

* jistotu,
* kvalitu vstupních dat,
* chybějící informace,
* důvod doporučení.

## 3.5 Bezpečnostní omezení mají vyšší prioritu než výkonový cíl

Pořadí priorit:

1. akutní bezpečnost,
2. odborné doporučení,
3. aktivní omezení,
4. dlouhodobé zdraví a návrat,
5. regenerace,
6. plán a cíle,
7. preference uživatele,
8. optimalizace výkonu.

## 3.6 Omezení musí mít rozsah a dobu platnosti

Systém musí rozlišit:

* pouze dnešní problém,
* několik dní,
* konkrétní období,
* do odvolání,
* dlouhodobé omezení,
* historickou informaci bez aktuálního dopadu.

## 3.7 Bolest se nesmí automaticky převést na trvalé omezení

Jednorázový PainReport není automaticky Limitation.

Trvalejší omezení vzniká pouze:

* výslovným rozhodnutím uživatele,
* opakovaným problémem podle definovaných pravidel,
* odborným doporučením,
* potvrzeným návrhem systému.

---

# 4. Hlavní doménové objekty

Oblast regenerace a omezení obsahuje minimálně:

* DailyCheckIn,
* FatigueReport,
* SleepRecord,
* SleepSummary,
* StressReport,
* RecoveryMetric,
* RecoveryTrend,
* ReadinessAssessment,
* RecoveryRecommendation,
* MuscleSorenessReport,
* PainReport,
* PainAssessment,
* Limitation,
* LimitationRule,
* LimitationImpact,
* ProfessionalRecommendation,
* ReturnToActivityPlan,
* SafetyAssessment,
* SafetyDecision,
* RecoveryAdjustmentProposal,
* RecoveryHistoryEntry.

---

# 5. DailyCheckIn

## 5.1 Význam

DailyCheckIn je stručný subjektivní záznam aktuálního stavu uživatele.

Slouží jako základní každodenní vstup pro plánování.

## 5.2 Vlastnosti

Může obsahovat:

* datum a čas,
* energii,
* celkovou únavu,
* svalovou bolest,
* kvalitu spánku,
* stres,
* motivaci,
* náladu volitelně,
* aktuální bolest,
* pocit připravenosti,
* poznámku,
* zdroj,
* úplnost.

## 5.3 Doporučené škály

Pro běžné subjektivní vstupy je vhodná jednoduchá škála například:

* 1–5,
* nebo 1–10 podle kontextu.

Každá hodnota musí mít jasně definovaný význam.

Například únava:

* 1 = téměř žádná,
* 3 = běžná,
* 5 = velmi vysoká.

## 5.4 Volitelnost

Denní check-in nesmí být povinný pro používání aplikace.

Může být:

* ranní,
* před workoutem,
* po workoutu,
* vyžádaný AI,
* ručně spuštěný.

## 5.5 Platnost

Check-in má omezenou časovou platnost.

Ranní stav nemusí přesně odpovídat večernímu workoutu.

Proto musí mít:

* timestamp,
* případně validUntil,
* kontext.

---

# 6. DailyCheckInType

Typy:

* MORNING,
* PRE_WORKOUT,
* POST_WORKOUT,
* AD_HOC,
* AI_REQUESTED,
* WEEKLY_REVIEW.

Každý typ může mít jinou sadu polí.

---

# 7. FatigueReport

## 7.1 Význam

Strukturované hlášení únavy.

Může vzniknout:

* z DailyCheckIn,
* samostatným hlášením,
* během workoutu,
* po aktivitě.

## 7.2 Typy únavy

* GENERAL,
* MUSCULAR,
* MENTAL,
* SLEEP_RELATED,
* SPORT_SPECIFIC,
* LOCALIZED,
* UNKNOWN.

## 7.3 Vlastnosti

* intenzita,
* začátek,
* doba trvání,
* typ,
* lokalizace,
* pravděpodobný kontext,
* související aktivity,
* spánek,
* stres,
* poznámka,
* dopad na běžné fungování.

## 7.4 Lokalizovaná únava

Může obsahovat:

* BodyArea,
* stranu,
* typ pocitu,
* omezený pohyb,
* související sport.

## 7.5 Rozdíl mezi únavou a bolestí

Únava:

* pocit vyčerpání,
* těžké svaly,
* snížená energie,
* snížená výkonnost.

Bolest:

* nepříjemný senzorický vjem,
* může být ostrá, píchavá, tupá,
* může být spojena s konkrétním pohybem.

Systém se může doptat, pokud vstup není jasný.

---

# 8. FatigueSeverity

Úrovně například:

* NONE,
* LOW,
* MODERATE,
* HIGH,
* VERY_HIGH,
* UNKNOWN.

## 8.1 LOW

Obvykle nevyžaduje zásadní změnu.

## 8.2 MODERATE

Může vést k:

* snížení objemu,
* delším pauzám,
* lehčí variantě.

## 8.3 HIGH

Může vést k:

* významnému zkrácení,
* regeneraci,
* přesunu workoutu,
* vynechání náročné jednotky.

## 8.4 VERY_HIGH

Vyžaduje opatrné vyhodnocení a často doporučení odpočinku nebo dalšího posouzení.

---

# 9. MuscleSorenessReport

## 9.1 Význam

Reprezentuje svalovou bolestivost nebo svalovici po zátěži.

Je oddělena od obecného PainReport, protože má často jiný plánovací význam.

## 9.2 Vlastnosti

* oblast,
* strana,
* intenzita,
* začátek,
* vztah k předchozí aktivitě,
* omezení rozsahu pohybu,
* citlivost na dotek,
* zhoršení při pohybu,
* očekávaný vývoj,
* poznámka.

## 9.3 Možné klasifikace

* TYPICAL_POST_EXERCISE,
* UNUSUAL,
* ASYMMETRIC,
* SEVERE,
* UNKNOWN.

## 9.4 Bezpečnost

Výrazná, jednostranná nebo neobvyklá bolestivost se nemá automaticky považovat za běžnou svalovici.

---

# 10. SleepRecord

## 10.1 Význam

Záznam jedné spánkové periody.

Může pocházet:

* od uživatele,
* z wearables,
* z Apple Health,
* z Health Connect,
* z jiné integrace.

## 10.2 Vlastnosti

* začátek,
* konec,
* časové pásmo,
* celkovou délku,
* dobu v posteli,
* počet probuzení,
* subjektivní kvalitu,
* fáze spánku, pokud dostupné,
* zdroj,
* úplnost,
* kvalitu,
* uživatelskou opravu.

## 10.3 Více spánkových záznamů

Jeden den může obsahovat:

* hlavní noční spánek,
* krátký spánek,
* několik částí,
* směnný režim.

Model nesmí předpokládat pouze jeden spánek za kalendářní noc.

---

# 11. SleepSummary

## 11.1 Význam

Odvozený souhrn spánku relevantní pro regeneraci.

## 11.2 Obsah

* referenční období,
* hlavní spánek,
* celkovou délku,
* subjektivní kvalitu,
* kontinuitu,
* odchylku od uživatelského normálu,
* datovou kvalitu,
* trend,
* jistotu.

## 11.3 Normál uživatele

Systém má preferovat porovnání s osobním dlouhodobým normálem před univerzálními prahy, pokud má dost dat.

## 11.4 Omezení

Wearable odhad spánkových fází nesmí být prezentován jako klinické měření.

---

# 12. SleepQuality

Možné úrovně:

* VERY_POOR,
* POOR,
* BELOW_NORMAL,
* NORMAL,
* GOOD,
* VERY_GOOD,
* UNKNOWN.

Musí být možné rozlišit:

* subjektivní kvalitu,
* automatický odhad,
* kombinovaný výsledek.

---

# 13. SleepDebtEstimate

## 13.1 Význam

Volitelný odhad kumulovaného nedostatku spánku.

## 13.2 Pravidla

Musí mít:

* použitou metodiku,
* osobní baseline,
* období,
* nejistotu.

Nesmí být prezentován jako přesná medicínská veličina.

---

# 14. StressReport

## 14.1 Význam

Subjektivní nebo automatický záznam stresu relevantního pro trénink.

## 14.2 Typy

* GENERAL,
* WORK,
* EMOTIONAL,
* PHYSICAL,
* TRAVEL,
* ILLNESS_RELATED,
* UNKNOWN.

## 14.3 Vlastnosti

* intenzita,
* doba trvání,
* začátek,
* vliv na spánek,
* vliv na motivaci,
* vliv na dostupnost,
* poznámka.

## 14.4 Soukromí

Uživatel nemusí popisovat příčinu stresu.

Pro plánování může stačit:

* intenzita,
* trvání,
* dopad.

---

# 15. RecoveryMetric

## 15.1 Význam

Obecná metrika používaná při hodnocení regenerace.

## 15.2 Příklady

* HRV,
* klidový tep,
* dechová frekvence,
* teplota,
* délka spánku,
* subjektivní únava,
* svalová bolest,
* stres,
* wearable recovery score.

## 15.3 Vlastnosti

* MetricDefinition,
* hodnota,
* jednotka,
* čas,
* zdroj,
* kvalita,
* baseline,
* odchylka od baseline,
* jistota,
* metoda normalizace.

## 15.4 Proprietární wearable skóre

Skóre výrobce musí být uloženo jako:

* hodnota konkrétního poskytovatele,
* nikoliv jako interní univerzální readiness.

---

# 16. RecoveryMetricQuality

Dimenze:

* completeness,
* reliability,
* recency,
* consistency,
* baselineAvailability,
* sourceQuality.

Úrovně:

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

---

# 17. RecoveryTrend

## 17.1 Význam

Odvozený trend regenerace v čase.

## 17.2 Časové horizonty

* krátkodobý,
* sedmidenní,
* několikatýdenní,
* vlastní období.

## 17.3 Možné stavy

* IMPROVING,
* STABLE,
* DECLINING,
* VOLATILE,
* INSUFFICIENT_DATA.

## 17.4 Vstupy

* DailyCheckIn,
* SleepSummary,
* RecoveryMetric,
* ActivityLoad,
* skutečné workouty,
* stres.

## 17.5 Omezení

Trend nesmí být odvozen z jednoho izolovaného měření.

---

# 18. ReadinessAssessment

## 18.1 Význam

Strukturované vyhodnocení připravenosti k určitému typu zátěže v určitém čase.

Readiness není obecná neměnná vlastnost dne.

Uživatel může být:

* nepřipravený na těžký silový workout,
* ale připravený na lehkou mobilitu.

## 18.2 Kontext

Assessment se vztahuje k:

* konkrétnímu workoutu,
* sportu,
* typu zátěže,
* dni,
* plánovanému období.

## 18.3 Vlastnosti

* referenční čas,
* kontext,
* výslednou úroveň,
* podporované typy zátěže,
* omezené typy zátěže,
* vstupní data,
* datovou kvalitu,
* nejistotu,
* vysvětlení,
* dobu platnosti,
* doporučení.

## 18.4 ReadinessLevel

* UNKNOWN,
* VERY_LOW,
* LOW,
* REDUCED,
* NORMAL,
* GOOD,
* HIGH.

## 18.5 UNKNOWN

Nedostatek dat.

Systém nemá automaticky předpokládat nízkou připravenost.

## 18.6 VERY_LOW

Obvykle nevhodné pro náročný workout.

## 18.7 REDUCED

Vhodná může být lehčí nebo kratší varianta.

## 18.8 NORMAL

Není identifikován významný důvod ke změně.

## 18.9 HIGH

Neznamená automaticky doporučení zvýšit zátěž nad plán.

---

# 19. ReadinessDimension

Readiness může být vícerozměrná:

* GENERAL,
* CARDIOVASCULAR,
* MUSCULAR,
* NEUROMUSCULAR,
* LOCAL_BODY_AREA,
* MENTAL,
* SPORT_SPECIFIC,
* SLEEP_RELATED.

Příklad:

* celková energie dobrá,
* lokální tahová připravenost nízká kvůli lezení,
* nohy běžně připravené.

---

# 20. ReadinessAssessmentInput

Musí být dohledatelné, z čeho vyhodnocení vzniklo.

Příklady:

* poslední DailyCheckIn,
* SleepSummary,
* ActivityLoad posledních dnů,
* aktuální PainReport,
* aktivní Limitation,
* wearable data,
* plánovaný workout,
* dlouhodobá baseline.

---

# 21. ReadinessConfidence

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

Jistotu snižuje:

* chybějící subjektivní vstup,
* nekvalitní wearable data,
* nový uživatel bez baseline,
* rozpor mezi zdroji,
* stará data,
* neznámý sport.

---

# 22. RecoveryRecommendation

## 22.1 Význam

Doporučení vycházející z připravenosti a kontextu.

## 22.2 Typy

* KEEP_AS_PLANNED,
* SHORTEN,
* REDUCE_VOLUME,
* REDUCE_INTENSITY,
* CHANGE_EXERCISE,
* ACTIVE_RECOVERY,
* RESCHEDULE,
* REST,
* REASSESS_LATER,
* SEEK_PROFESSIONAL_ADVICE,
* STOP_ACTIVITY.

## 22.3 Vlastnosti

* typ,
* důvod,
* cílový workout nebo den,
* rozsah,
* platnost,
* jistota,
* dopad na plán,
* potřeba potvrzení.

## 22.4 Doporučení není změna

RecoveryRecommendation samo o sobě nemění plán.

Změna vznikne až jako:

* WorkoutModification,
* ChangeSet,
* RecoveryAdjustmentProposal.

---

# 23. RecoveryAdjustmentProposal

## 23.1 Význam

Strukturovaný návrh konkrétní změny workoutu nebo plánu kvůli regeneraci.

## 23.2 Rozsah

* SET,
* EXERCISE,
* WORKOUT,
* DAY,
* WEEK,
* BLOCK.

## 23.3 Obsah

* spouštěč,
* původní stav,
* nový stav,
* důvod,
* dopad,
* nejistotu,
* bezpečnostní stav,
* potvrzení,
* vratnost.

## 23.4 Příklad

Původně:

* 45 minut silový workout,
* 4 pracovní cviky.

Nově:

* 25 minut,
* 2 hlavní cviky,
* snížený počet sérií,
* bez accessory části.

---

# 24. PainReport

## 24.1 Význam

Strukturované hlášení bolesti.

Není diagnózou.

## 24.2 Vlastnosti

* datum a čas,
* BodyArea,
* strana,
* intenzita,
* charakter,
* začátek,
* mechanismus vzniku, pokud známý,
* pohyb zhoršující bolest,
* bolest v klidu,
* bolest při zatížení,
* změna v čase,
* související aktivita,
* úraz ano/ne,
* otok nebo jiný uživatelský popis,
* dopad na funkci,
* poznámka,
* zdroj.

## 24.3 PainIntensity

Například škála 0–10.

Musí být jasně vysvětlená.

## 24.4 PainCharacter

Možnosti:

* DULL,
* SHARP,
* STABBING,
* BURNING,
* ACHING,
* THROBBING,
* TIGHTNESS,
* PRESSURE,
* ELECTRIC,
* UNKNOWN,
* CUSTOM.

## 24.5 PainOnset

* SUDDEN,
* GRADUAL,
* AFTER_ACTIVITY,
* DURING_ACTIVITY,
* AT_REST,
* UNKNOWN.

## 24.6 PainTrend

* IMPROVING,
* STABLE,
* WORSENING,
* INTERMITTENT,
* UNKNOWN.

---

# 25. BodyArea

## 25.1 Význam

Standardizovaná anatomická oblast.

## 25.2 Hierarchie

Příklad:

```text
Upper limb
├── Shoulder
├── Upper arm
├── Elbow
├── Forearm
├── Wrist
└── Hand
    └── Fingers
```

A:

```text
Lower limb
├── Hip
├── Thigh
├── Knee
├── Lower leg
├── Ankle
└── Foot
```

## 25.3 Strana

* LEFT,
* RIGHT,
* BILATERAL,
* MIDLINE,
* NOT_APPLICABLE,
* UNKNOWN.

## 25.4 Úroveň detailu

Uživatel nemusí znát přesnou anatomickou strukturu.

Může vybrat obecnou oblast a doplnit text.

---

# 26. MovementPattern

Omezení a bolest musí být propojitelná s pohybovým vzorem.

Příklady:

* SQUAT,
* HINGE,
* LUNGE,
* RUNNING,
* JUMPING,
* LANDING,
* VERTICAL_PULL,
* HORIZONTAL_PULL,
* VERTICAL_PUSH,
* HORIZONTAL_PUSH,
* OVERHEAD_MOVEMENT,
* ROTATION,
* GRIP,
* WRIST_EXTENSION,
* ELBOW_FLEXION,
* SHOULDER_ABDUCTION,
* CUSTOM.

To je důležité, protože stejná oblast může bolet pouze při konkrétním pohybu.

---

# 27. PainTrigger

## 27.1 Význam

Aktivita nebo pohyb, který bolest vyvolává nebo zhoršuje.

## 27.2 Obsah

* MovementPattern,
* ExerciseDefinition,
* sport,
* intenzitu,
* rozsah pohybu,
* stranu,
* popis.

## 27.3 Příklad

* bolest pravého bicepsu při vertikálním tahu,
* bez bolesti při tlaku,
* bez bolesti v klidu.

To umožní přesnější úpravu workoutu než pouhé „bolí mě ruka“.

---

# 28. FunctionalImpact

Popisuje dopad problému na fungování:

* NONE,
* MILD,
* MODERATE,
* SEVERE,
* CANNOT_PERFORM,
* UNKNOWN.

Příklady:

* nepříjemné, ale pohyb zvládnu,
* omezuje rozsah,
* nemohu zatížit,
* bolest i při běžné chůzi.

---

# 29. PainAssessment

## 29.1 Význam

Bezpečnostní vyhodnocení PainReport.

Neurčuje diagnózu.

## 29.2 Výstup

Může určit:

* LIKELY_LOW_RISK_EXERCISE_RELATED,
* UNCERTAIN,
* MODERATE_CONCERN,
* HIGH_CONCERN,
* URGENT_EVALUATION_RECOMMENDED,
* INSUFFICIENT_DATA.

## 29.3 Vstupy

* intenzita,
* charakter,
* náhlý vznik,
* úraz,
* bolest v klidu,
* zhoršování,
* funkční omezení,
* oblast,
* opakování,
* související aktivita,
* odborné omezení.

## 29.4 Zakázané výstupy

Nesmí obsahovat:

* diagnózu,
* tvrzení o poškozené konkrétní tkáni,
* falešné ujištění, že je vše bezpečné.

---

# 30. PainAssessmentConfidence

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

U bezpečnostních rozhodnutí nízká jistota často vede ke konzervativnějšímu doporučení.

---

# 31. SafetyFlag

Bezpečnostní příznak odvozený z uživatelského vstupu.

Příklady:

* ACUTE_TRAUMA,
* SEVERE_PAIN,
* PAIN_AT_REST,
* RAPID_WORSENING,
* LOSS_OF_FUNCTION,
* NEUROLOGICAL_SYMPTOM_REPORTED,
* CHEST_SYMPTOM_REPORTED,
* BREATHING_PROBLEM_REPORTED,
* SYSTEMIC_ILLNESS_REPORTED,
* UNKNOWN_HIGH_RISK_SIGNAL.

Přesná pravidla musí projít odborným a právním posouzením.

---

# 32. SafetyAssessment

## 32.1 Význam

Obecné bezpečnostní vyhodnocení před doporučením aktivity.

Může kombinovat:

* PainAssessment,
* aktivní Limitation,
* ProfessionalRecommendation,
* akutní nemoc,
* vysokou únavu,
* rizikový workout.

## 32.2 Stav

* SAFE_WITH_CURRENT_INFORMATION,
* SAFE_WITH_MODIFICATIONS,
* CAUTION,
* DO_NOT_RECOMMEND_ACTIVITY,
* STOP_AND_SEEK_HELP,
* INSUFFICIENT_INFORMATION.

## 32.3 Důležité omezení

`SAFE_WITH_CURRENT_INFORMATION` neznamená medicínskou záruku bezpečnosti.

Uživatelský text musí být formulován opatrně.

---

# 33. SafetyDecision

## 33.1 Význam

Konkrétní rozhodnutí systému pro určitý workout nebo pohyb.

## 33.2 Možné výsledky

* ALLOW,
* ALLOW_WITH_WARNING,
* MODIFY,
* BLOCK_EXERCISE,
* BLOCK_WORKOUT,
* RECOMMEND_REST,
* REQUIRE_USER_CONFIRMATION,
* RECOMMEND_PROFESSIONAL_REVIEW,
* REQUIRE_URGENT_ACTION.

## 33.3 Vlastnosti

* cílový objekt,
* rozhodnutí,
* důvod,
* pravidla,
* vstupní data,
* jistota,
* platnost,
* audit.

## 33.4 Deterministická vrstva

Kritická bezpečnostní pravidla musí být vyhodnocována deterministicky.

AI může vysvětlit výsledek, ale nesmí bezpečnostní blokaci obejít.

---

# 34. Limitation

## 34.1 Význam

Omezení ovlivňující plánování nebo provádění aktivit.

## 34.2 Typy

* TEMPORARY_PHYSICAL,
* LONG_TERM_PHYSICAL,
* MOVEMENT_RESTRICTION,
* SPORT_RESTRICTION,
* LOAD_RESTRICTION,
* PROFESSIONAL_RECOMMENDATION,
* USER_PREFERENCE,
* EQUIPMENT_RELATED,
* ENVIRONMENT_RELATED,
* RETURN_TO_ACTIVITY,
* OTHER.

## 34.3 Vlastnosti

* název,
* popis,
* typ,
* stav,
* začátek,
* konec,
* způsob ukončení,
* zdroj,
* BodyArea,
* stranu,
* zakázané pohyby,
* omezené pohyby,
* povolené pohyby,
* limit zátěže,
* ovlivněné sporty,
* ovlivněné workouty,
* odborný zdroj,
* poznámku.

---

# 35. LimitationStatus

* DRAFT,
* ACTIVE,
* SUSPENDED,
* EXPIRED,
* RESOLVED,
* REPLACED,
* ARCHIVED.

## 35.1 ACTIVE

Musí být zohledněno v plánování.

## 35.2 EXPIRED

Časová platnost skončila, ale historie zůstává.

## 35.3 RESOLVED

Uživatel nebo oprávněný proces označil omezení jako ukončené.

## 35.4 REPLACED

Nahrazeno přesnější nebo novější verzí.

---

# 36. LimitationDurationType

* SINGLE_SESSION,
* SINGLE_DAY,
* DATE_RANGE,
* UNTIL_REVIEW,
* UNTIL_USER_REMOVES,
* LONG_TERM,
* PERMANENT,
* UNKNOWN.

Trvalé omezení musí být používáno opatrně a ideálně potvrzeno uživatelem.

---

# 37. LimitationSource

* USER,
* PAIN_ASSESSMENT,
* PROFESSIONAL,
* SYSTEM_SAFETY_RULE,
* AI_PROPOSAL,
* IMPORTED,
* ADMINISTRATIVE.

Odborné doporučení musí mít přednost před běžným AI doporučením.

---

# 38. ProfessionalRecommendation

## 38.1 Význam

Uživatelem zadané nebo importované doporučení odborníka.

Příklad:

> Dva týdny neběhat.

## 38.2 Vlastnosti

* text původního doporučení,
* strukturovaný význam,
* začátek,
* konec,
* zdroj,
* typ odborníka volitelně,
* zakázané aktivity,
* omezené aktivity,
* povolené alternativy,
* datum kontroly,
* příloha volitelně.

## 38.3 Pravidlo

Aplikace nesmí tvrdit, že doporučení odborníka je chybné.

Může upozornit na nejasnost a požádat uživatele o upřesnění.

---

# 39. LimitationRule

## 39.1 Význam

Strojově vyhodnotitelné pravidlo odvozené z Limitation.

## 39.2 Příklady

* zákaz běhu,
* zákaz skoků,
* maximálně lehká intenzita,
* nepoužívat pravou paži nad hlavou,
* bez hlubokého dřepu,
* maximálně 20 minut zátěže,
* žádná kontaktní aktivita.

## 39.3 Výsledek

Pravidlo může:

* blokovat,
* varovat,
* vyžadovat náhradu,
* omezit rozsah,
* omezit intenzitu,
* omezit délku.

---

# 40. LimitationImpact

## 40.1 Význam

Propojuje omezení s konkrétním objektem.

Může se vztahovat na:

* sport,
* WorkoutTemplate,
* WorkoutInstance,
* ExerciseDefinition,
* MovementPattern,
* BodyArea,
* ActivityType.

## 40.2 Typ dopadu

* PROHIBITS,
* LIMITS,
* REQUIRES_MODIFICATION,
* REQUIRES_WARNING,
* REQUIRES_CONFIRMATION,
* UNAFFECTED,
* UNKNOWN.

## 40.3 Jistota

Dopad může být:

* explicitní,
* odvozený,
* AI navržený,
* uživatelem potvrzený.

---

# 41. Jednostranné omezení

Model musí podporovat rozdíl mezi:

* pravou stranou,
* levou stranou,
* oboustranným omezením,
* středovou strukturou.

Příklad:

* pravé koleno,
* levé rameno,
* obě zápěstí.

Workout adaptation musí umět:

* změnit pouze jednu stranu,
* snížit zatížení asymetricky,
* vynechat jednostranný cvik,
* neaplikovat omezení automaticky na druhou stranu.

---

# 42. Rozsah pohybu

Limitation může obsahovat:

* povolený rozsah,
* omezený rozsah,
* bolestivý rozsah,
* rozsah neurčený.

Příklad:

* rameno bez bolesti do výšky ramen,
* bolest nad hlavou.

První verze nemusí ukládat přesné stupně, pokud je uživatel nezná.

Může použít funkční kategorie.

---

# 43. LoadRestriction

## 43.1 Význam

Omezení intenzity nebo objemu.

## 43.2 Příklady

* pouze lehká intenzita,
* maximálně RPE 5,
* bez těžkých vah,
* snížit objem o polovinu,
* maximálně tři série,
* bez sprintů.

## 43.3 Vlastnosti

* typ zátěže,
* maximální hodnota,
* jednotka,
* kontext,
* platnost,
* zdroj.

---

# 44. ReturnToActivityPlan

## 44.1 Význam

Strukturovaný návrat po pauze, nemoci nebo omezení.

Není klinickým rehabilitačním protokolem, pokud není vytvořen oprávněným odborníkem.

## 44.2 Vlastnosti

* důvod návratu,
* datum začátku,
* předchozí úroveň,
* aktuální úroveň,
* fáze,
* povolené aktivity,
* objem,
* intenzitu,
* kritéria postupu,
* kritéria zastavení,
* datum revize.

## 44.3 Fáze

* REINTRODUCTION,
* LOW_LOAD,
* MODERATE_LOAD,
* SPORT_SPECIFIC,
* FULL_RETURN,
* HOLD,
* REGRESSION_REQUIRED.

## 44.4 Kritéria postupu

Mohou zahrnovat:

* bez zhoršení bolesti,
* zvládnutí objemu,
* běžnou subjektivní únavu,
* dokončení několika jednotek,
* potvrzení uživatele.

---

# 45. Nemoc a systémový stav

Model musí být připraven i na obecné hlášení:

* nachlazení,
* horečka,
* celková slabost,
* nevolnost,
* jiné systémové příznaky.

Nemusí stanovovat diagnózu.

Může vytvořit:

* HealthStatusReport,
* dočasné Limitation,
* SafetyAssessment,
* doporučení netrénovat.

Podrobná pravidla musí být samostatně odborně validována.

---

# 46. HealthStatusReport

## 46.1 Význam

Obecné hlášení zdravotního stavu relevantního pro trénink.

## 46.2 Typy

* FEELING_UNWELL,
* FEVER_REPORTED,
* RESPIRATORY_SYMPTOMS_REPORTED,
* GASTROINTESTINAL_SYMPTOMS_REPORTED,
* GENERAL_WEAKNESS,
* RECOVERING_FROM_ILLNESS,
* OTHER.

## 46.3 Výsledek

Může ovlivnit:

* SafetyAssessment,
* ReadinessAssessment,
* dočasné omezení,
* návratový plán.

---

# 47. Rozpor mezi wearable daty a subjektivním pocitem

## 47.1 Wearable říká nízkou regeneraci, uživatel se cítí dobře

Systém musí:

* zkontrolovat kvalitu dat,
* zkontrolovat trend,
* zohlednit význam workoutu,
* neblokovat automaticky,
* případně doporučit opatrnější začátek.

## 47.2 Wearable říká dobrou regeneraci, uživatel se cítí špatně

Subjektivní hlášení má vysokou váhu.

Systém nesmí uživatele přesvědčovat, že je připravený jen na základě hodinek.

## 47.3 Výsledek

ReadinessAssessment musí uvést:

* zdroje jsou v rozporu,
* jaký zdroj byl upřednostněn,
* proč,
* jaká je nejistota.

---

# 48. Baseline uživatele

## 48.1 Význam

Dlouhodobý osobní normál.

Používá se například pro:

* HRV,
* klidový tep,
* délku spánku,
* subjektivní únavu,
* běžnou tréninkovou zátěž.

## 48.2 Vlastnosti

* metrika,
* období,
* střední hodnotu,
* variabilitu,
* počet dat,
* kvalitu,
* poslední aktualizaci.

## 48.3 Nový uživatel

Bez baseline systém musí používat opatrnější obecné vyhodnocení a uvést nízkou jistotu.

---

# 49. RecoveryContext

Readiness a recovery musí být vyhodnoceny v kontextu:

* dne,
* plánovaného workoutu,
* sportu,
* cíle,
* předchozí zátěže,
* následující zátěže,
* časové dostupnosti,
* aktuálních omezení.

Příklad:

Lehký mobility workout může zůstat vhodný i při nízké připravenosti na sprinty.

---

# 50. Recovery Engine

## 50.1 Odpovědnost

Recovery Engine nebo RecoveryAssessmentService zpracovává:

* subjektivní vstupy,
* spánek,
* stres,
* wearable data,
* aktivní omezení,
* poslední aktivity,
* plánovaný workout.

## 50.2 Výstupy

* ReadinessAssessment,
* RecoveryRecommendation,
* RecoveryAdjustmentProposal,
* případný SafetyAssessment.

## 50.3 Pořadí zpracování

1. bezpečnostní blokace,
2. aktivní odborná omezení,
3. aktuální bolest,
4. nemoc nebo systémový problém,
5. lokální únava,
6. celková regenerace,
7. plánovací kontext,
8. uživatelské preference.

## 50.4 Deterministické a AI části

Deterministická vrstva:

* blokující pravidla,
* platnost omezení,
* časový rozsah,
* kompatibilita cviků,
* základní bezpečnost.

AI vrstva:

* interpretace textu,
* vysvětlení,
* návrh mezi více bezpečnými variantami,
* formulace doplňujících otázek.

---

# 51. Adaptace dnešního workoutu

Možné zásahy:

* ponechat beze změny,
* snížit série,
* snížit opakování,
* snížit váhu,
* změnit RPE,
* prodloužit pauzy,
* nahradit cvik,
* odstranit rizikový pohyb,
* zkrátit workout,
* nahradit regenerací,
* přesunout,
* zrušit.

Každý zásah musí mít:

* důvod,
* rozsah,
* dopad,
* vratnost.

---

# 52. Adaptace týdne

Spouští se, pokud problém ovlivňuje více než jeden den.

Příklady:

* několik nocí špatného spánku,
* aktivní bolest na několik dní,
* nemoc,
* odborný zákaz běhu,
* kumulovaná únava.

Možné změny:

* snížení celkového objemu,
* přesun hlavních jednotek,
* nahrazení aktivit,
* přidání odpočinku,
* pozastavení progrese,
* odložení testu,
* změna cíle týdne.

---

# 53. Adaptace tréninkového bloku

Je vhodná například při:

* delší nemoci,
* návratu po pauze,
* dlouhodobém omezení,
* výrazném poklesu kapacity,
* změně odborného doporučení.

Obvykle vyžaduje:

* novou TrainingPlanVersion,
* nebo změnu TrainingBlock,
* uživatelské potvrzení.

---

# 54. Dnešní únava bez bolesti

## Příklad vstupu

> Dnes jsem hodně unavený.

## Doporučené doplňující otázky

Pouze pokud jsou nutné:

* Jak silná je únava?
* Je celková, nebo hlavně v určité části těla?
* Jak jsi spal?
* Chceš workout zachovat, nebo preferuješ lehčí variantu?

## Výstup

Například:

* 25minutová varianta místo 45 minut,
* zachované hlavní cviky,
* odstraněná accessory část.

---

# 55. Lokální únava po sportu

## Příklad

> Po včerejším lezení mám úplně unavená předloktí.

## Dopad

Systém může:

* omezit grip,
* odstranit tahové cviky,
* zachovat nohy nebo lehký core,
* přesunout upper-body workout.

Nemá automaticky rušit celý den.

---

# 56. Bolest při konkrétním cviku

## Příklad

> Rameno mě bolí při tlaku nad hlavu.

## Proces

1. PainReport,
2. PainTrigger = OVERHEAD_MOVEMENT,
3. PainAssessment,
4. vyhledání ovlivněných cviků,
5. náhrada nebo blokace,
6. dočasná platnost,
7. revize za definované období.

## Nevhodné chování

Pouze snížit váhu bez zohlednění bolestivého pohybového vzoru.

---

# 57. Bolest v klidu nebo zhoršující se stav

Takový vstup má vyšší bezpečnostní význam.

Systém může:

* nedoporučit workout,
* doporučit přerušit aktivitu,
* doporučit odborné posouzení,
* vytvořit dočasnou blokaci.

Nesmí:

* nabídnout běžný náhradní silový workout bez varování,
* tvrdit, že problém je jen svalovice.

---

# 58. Odborný zákaz aktivity

## Příklad

> Dva týdny nemám běhat.

## Výsledek

* ProfessionalRecommendation,
* aktivní Limitation,
* LimitationRule zakazující běh,
* identifikace budoucích běžeckých workoutů,
* návrh kompatibilních alternativ,
* návratový proces po skončení.

## Důležité pravidlo

Po skončení dvou týdnů se nemá automaticky obnovit původní vysoký běžecký objem.

---

# 59. Historické zranění

Uživatel může uvést:

> Před třemi lety jsem měl operaci kolene, teď běžně sportuji.

Tento údaj nemusí znamenat aktivní blokaci.

Může být uložen jako:

* HistoricalCondition,
* dlouhodobý profilový kontext,
* upozornění pro určité situace.

AI nesmí automaticky omezit všechny workouty nohou, pokud uživatel nemá aktuální problém.

---

# 60. HistoricalCondition

## 60.1 Význam

Historická informace relevantní pro plánování, ale ne nutně aktivní omezení.

## 60.2 Vlastnosti

* oblast,
* rok nebo období,
* typ obecně,
* současný stav,
* aktuální omezení ano/ne,
* uživatelská poznámka.

## 60.3 Převod na aktivní omezení

Pouze pokud:

* uživatel uvede současný dopad,
* vznikne nový PainReport,
* existuje aktivní odborné doporučení.

---

# 61. RecoveryRecommendationPriority

* INFORMATIONAL,
* LOW,
* MEDIUM,
* HIGH,
* CRITICAL.

Kritické doporučení nesmí být skryto pouze v běžném AI chatu.

---

# 62. Automatizace změn kvůli regeneraci

Bez potvrzení lze případně povolit pouze:

* změnu připomenutí,
* posun flexibilního mikro-workoutu,
* drobné snížení nepovinné části,
* přidání upozornění.

Potvrzení se vyžaduje pro:

* zrušení hlavního workoutu,
* změnu více dnů,
* vytvoření omezení,
* odstranění cviků,
* změnu cíle týdne,
* změnu bloku.

---

# 63. Platnost readiness doporučení

ReadinessAssessment musí mít:

* assessedAt,
* validUntil,
* targetContext.

Příklad:

Assessment v 7:00 nemusí být automaticky platný v 19:00.

Systém může před workoutem požádat o krátkou aktualizaci.

---

# 64. RecoveryHistoryEntry

## 64.1 Význam

Historický záznam změny regenerace nebo doporučení.

## 64.2 Obsah

* datum,
* vstupy,
* assessment,
* doporučení,
* přijatou akci,
* skutečný výsledek,
* uživatelskou zpětnou vazbu.

## 64.3 Použití

* audit,
* zlepšení personalizace,
* vyhodnocení, zda doporučení byla užitečná.

---

# 65. Zpětná vazba na adaptaci

Po upraveném workoutu může aplikace zjistit:

* Byla lehčí varianta vhodná?
* Byla stále příliš těžká?
* Cítil ses lépe nebo hůř?
* Objevila se bolest?

Výsledek může aktualizovat:

* RecoveryHistoryEntry,
* Limitation,
* budoucí adaptační pravidla.

---

# 66. Dlouhodobé přetížení

Model musí být připraven rozpoznat kombinaci:

* dlouhodobě vysoké únavy,
* zhoršujícího se spánku,
* poklesu výkonu,
* vysoké plánované zátěže,
* opakovaných vynechání.

Systém může vytvořit:

* RecoveryTrend = DECLINING,
* doporučení snížit zátěž,
* návrh odlehčovacího týdne,
* doporučení odborné konzultace při významných potížích.

Nesmí stanovovat syndrom přetrénování.

---

# 67. DeloadRecommendation

## 67.1 Význam

Návrh dočasného snížení zátěže.

## 67.2 Spouštěče

* plánovaný konec bloku,
* kumulovaná únava,
* stagnace,
* opakovaně vysoké RPE,
* dlouhodobý pokles readiness,
* uživatelský požadavek.

## 67.3 Obsah

* období,
* snížení objemu,
* snížení intenzity,
* zachované klíčové pohyby,
* důvod,
* očekávaný návrat.

---

# 68. Recovery versus adherence

Uživatel nemá být penalizován za:

* odpočinek doporučený systémem,
* vynechání kvůli aktivnímu omezení,
* zrušení workoutu kvůli nemoci,
* odborně doporučenou pauzu.

AdherenceMetric musí zohlednit:

* oprávněné změny,
* upravený plán,
* náhradní aktivity,
* recovery rozhodnutí.

---

# 69. Integrace wearables

Wearables mohou dodat:

* spánek,
* HRV,
* klidový tep,
* recovery score,
* body battery,
* tréninkovou připravenost,
* stres,
* aktivity.

Interní systém musí data převést na:

* RecoveryMetric,
* SleepRecord,
* Activity,
* nikoliv přímo převzít význam výrobce.

---

# 70. WearableDataSource

Každý zdroj musí mít:

* poskytovatele,
* zařízení,
* typ senzoru,
* čas,
* kvalitu,
* úplnost,
* externí identifikátor.

Příklad:

* HRV z Garminu,
* spánek z Apple Health,
* klidový tep z hodinek.

---

# 71. Konfliktní wearable zdroje

Pokud dvě zařízení poskytují odlišné hodnoty:

* zachovat oba zdroje,
* použít pravidla priority,
* zobrazit nejistotu,
* neprovádět významnou změnu pouze podle jednoho nekvalitního vstupu.

---

# 72. Chybějící data

ReadinessAssessment může fungovat i bez wearables.

Minimální vstupy mohou být:

* subjektivní energie,
* únava,
* bolest,
* poslední aktivity,
* dnešní workout.

Aplikace nesmí podmiňovat kvalitní používání vlastnictvím hodinek.

---

# 73. Recovery bez denního check-inu

Pokud check-in chybí:

* použít dostupná data,
* označit nižší jistotu,
* před náročným workoutem případně nabídnout rychlý check-in,
* neblokovat workout jen kvůli chybějícímu vstupu.

---

# 74. Offline režim

Offline musí být možné:

* vytvořit DailyCheckIn,
* vytvořit FatigueReport,
* vytvořit PainReport,
* zobrazit relevantní aktivní Limitation,
* upravit dnešní workout podle lokálně dostupných deterministických pravidel,
* uložit změnu lokálně,
* zobrazit bezpečnostní upozornění.

Komplexní AI interpretace může být nedostupná.

---

# 75. Offline bezpečnost

Lokální zařízení musí mít synchronizováno minimálně:

* aktivní omezení,
* profesionální doporučení,
* omezení relevantní pro dnešní workout,
* základní bezpečnostní pravidla,
* aktuální workout snapshot.

Nesmí nastat situace, kdy offline aplikace neví o aktivním zákazu běhu, který už byl synchronizován.

---

# 76. Synchronizace

Musí být synchronizovány:

* DailyCheckIn,
* PainReport,
* Limitation,
* ProfessionalRecommendation,
* ReadinessAssessment podle potřeby,
* přijaté adaptace,
* historie změn.

Citlivá data musí mít odpovídající ochranu.

---

# 77. Konflikt omezení

Příklad:

* na telefonu uživatel ukončí omezení,
* na jiném zařízení ho prodlouží.

Tento konflikt nelze vždy automaticky sloučit.

Systém musí:

* zachovat obě změny,
* zabránit nebezpečnému odstranění aktivní blokace,
* požádat o rozhodnutí,
* případně do vyřešení použít konzervativnější variantu.

---

# 78. Konflikt PainReport

PainReport je historický vstup a nemá se přepisovat.

Další zařízení může vytvořit nový report.

Systém může zobrazit trend, ale nesmí jeden záznam zničit.

---

# 79. Ochrana citlivých dat

Data o:

* bolesti,
* omezeních,
* spánku,
* stresu,
* zdravotním stavu,

musí být klasifikována jako citlivá.

Musí být řešeno:

* šifrování,
* přístup,
* audit,
* export,
* smazání,
* AI zpracování,
* analytika.

---

# 80. AI přístup k citlivým datům

AI smí dostat pouze data nutná pro konkrétní úkol.

Příklad:

Pro úpravu dnešního workoutu může potřebovat:

* aktivní bolest pravého bicepsu,
* bolestivý pohyb,
* dnešní workout.

Nemusí dostat celou zdravotní historii.

---

# 81. Souhlas s AI zpracováním

Uživatel musí být informován:

* jaká data mohou být zpracována AI,
* za jakým účelem,
* jak lze přístup omezit,
* co bude fungovat bez AI.

---

# 82. Produktová analytika

Do běžné analytiky nesmí vstupovat:

* konkrétní popis bolesti,
* diagnóza zadaná uživatelem,
* detail odborného doporučení,
* konkrétní hodnoty spánku,
* citlivé poznámky.

Lze měřit technické události:

* pain_flow_started,
* pain_report_saved,
* recovery_proposal_accepted,
* limitation_created,
* workout_modified_for_recovery.

---

# 83. Safety Rules Engine

## 83.1 Odpovědnost

Vyhodnocuje kritická pravidla nezávisle na AI.

## 83.2 Vstupy

* PainReport,
* SafetyFlag,
* Limitation,
* ProfessionalRecommendation,
* HealthStatusReport,
* plánovaný workout.

## 83.3 Výstupy

* SafetyAssessment,
* SafetyDecision,
* blokující důvod,
* povolené alternativy.

## 83.4 Verze pravidel

Každé rozhodnutí musí uchovat verzi pravidel, podle kterých vzniklo.

---

# 84. Práce s varovnými příznaky

Přesná pravidla budou vyžadovat odbornou revizi.

Produktový model však musí podporovat:

* okamžité přerušení běžného flow,
* zobrazení výrazného upozornění,
* omezení dalších doporučení,
* doporučení odborné nebo urgentní pomoci,
* záznam důvodu.

---

# 85. Bezpečnostní jazyk

Aplikace nesmí říkat:

* „Určitě je to jen natažený sval.“
* „Můžeš bezpečně pokračovat.“
* „Nemáš žádné zranění.“

Vhodnější formulace:

* „Z dostupných informací nelze příčinu určit.“
* „Kvůli náhlé ostré bolesti není vhodné pokračovat v tomto workoutu.“
* „Pokud bolest přetrvává nebo se zhoršuje, zvaž odborné posouzení.“

---

# 86. Uživatelské rozhodnutí proti doporučení

Uživatel může chtít zachovat těžký workout.

Systém musí rozlišit:

## Běžné doporučení

Uživatel může odmítnout a pokračovat.

## Významné varování

Vyžaduje explicitní potvrzení.

## Blokující bezpečnostní stav

Aplikace nesmí aktivně doporučit nebo vygenerovat zakázanou aktivitu.

Může umožnit ruční záznam skutečnosti, ale ne prezentovat ji jako doporučený plán.

---

# 87. Manual Override

## 87.1 Význam

Uživatelské rozhodnutí odlišné od doporučení.

## 87.2 Obsah

* původní doporučení,
* uživatelské rozhodnutí,
* čas,
* potvrzení,
* případné varování,
* dopad.

## 87.3 Omezení

Manual override nesmí obejít:

* cizí data,
* technické bezpečnostní invariance,
* odborně zadaný zákaz bez jasného uživatelského rozhodnutí.

---

# 88. Limitation Review

## 88.1 Význam

Pravidelná revize aktivního omezení.

## 88.2 Spouštěče

* datum konce,
* zlepšení,
* zhoršení,
* opakovaná bolest,
* konec návratové fáze,
* uživatelský požadavek.

## 88.3 Výstupy

* zachovat,
* prodloužit,
* zúžit,
* rozšířit,
* ukončit,
* nahradit novým omezením,
* doporučit odborné posouzení.

---

# 89. Automatická expirace

Dočasné omezení může po datu konce přejít do `EXPIRED`.

To však neznamená automaticky:

* obnovení plné zátěže,
* smazání historie,
* ignorování přetrvávající bolesti.

Systém může vyžádat krátkou revizi.

---

# 90. Pain Trend

Více PainReport záznamů může vytvořit trend:

* IMPROVING,
* STABLE,
* WORSENING,
* RECURRENT,
* RESOLVED,
* INSUFFICIENT_DATA.

Při zhoršování může systém zvýšit bezpečnostní úroveň.

---

# 91. Recovery Trend versus Pain Trend

Tyto trendy se nesmí směšovat.

Uživatel může:

* celkově dobře regenerovat,
* ale mít lokální zhoršující se bolest.

Readiness pro konkrétní workout pak může být nízká navzdory dobrému celkovému stavu.

---

# 92. Vztah k TrainingPlan

Aktivní Limitation může ovlivnit:

* WorkoutInstance,
* TrainingWeek,
* TrainingBlock,
* cíle,
* progresi.

Malé dočasné omezení může vést pouze k ChangeSet.

Dlouhodobé omezení může vyžadovat novou TrainingPlanVersion.

---

# 93. Vztah k WorkoutTemplate

Omezení nesmí zpětně měnit systémovou šablonu.

Může:

* vytvořit adaptovanou WorkoutInstance,
* vytvořit uživatelskou alternativu,
* označit šablonu jako nevhodnou v daném kontextu.

---

# 94. Vztah k ExerciseDefinition

ExerciseDefinition může obsahovat obecná metadata:

* pohybový vzor,
* zatížené oblasti,
* nároky na vybavení.

LimitationImpactService pak určí kompatibilitu.

ExerciseDefinition nemá obsahovat personalizovanou diagnózu nebo individuální zákaz.

---

# 95. LimitationImpactService

## 95.1 Odpovědnost

Vyhodnocuje dopad omezení na:

* cviky,
* workouty,
* sporty,
* plán.

## 95.2 Vstupy

* LimitationRule,
* ExerciseDefinition,
* MovementPattern,
* BodyArea,
* ActivityLoad,
* kontext.

## 95.3 Výstupy

* kompatibilní,
* vyžaduje úpravu,
* nevhodné,
* nejisté,
* vyžaduje potvrzení.

---

# 96. RecoveryAssessmentService

Zpracovává:

* DailyCheckIn,
* FatigueReport,
* SleepSummary,
* RecoveryMetric,
* RecoveryTrend,
* poslední zátěž.

Vytváří:

* ReadinessAssessment,
* RecoveryRecommendation.

---

# 97. PainAssessmentService

Zpracovává:

* PainReport,
* SafetyFlag,
* historii,
* aktivní omezení.

Vytváří:

* PainAssessment,
* SafetyAssessment,
* návrh dočasného omezení.

---

# 98. RecoveryAdaptationService

Zpracovává:

* readiness,
* safety,
* workout účel,
* plánovací kontext.

Vytváří:

* kratší variantu,
* lehčí variantu,
* náhrady,
* přesun,
* recovery workout,
* ChangeSet návrh.

---

# 99. ReturnToActivityService

Zpracovává:

* délku pauzy,
* důvod,
* předchozí kapacitu,
* aktuální stav,
* omezení,
* cíle.

Vytváří:

* ReturnToActivityPlan,
* upravený TrainingBlock,
* progresní pravidla.

---

# 100. Doménové události

Minimálně:

* DailyCheckInRecorded
* FatigueReported
* MuscleSorenessReported
* SleepRecordImported
* SleepSummaryUpdated
* StressReported
* RecoveryMetricRecorded
* RecoveryTrendChanged
* ReadinessAssessed
* RecoveryRecommendationCreated
* RecoveryAdjustmentProposed
* RecoveryAdjustmentApplied
* RecoveryAdjustmentRejected
* PainReported
* PainAssessmentCompleted
* SafetyFlagDetected
* SafetyAssessmentCompleted
* SafetyRestrictionTriggered
* LimitationCreated
* LimitationActivated
* LimitationUpdated
* LimitationExpired
* LimitationResolved
* ProfessionalRecommendationRecorded
* ReturnToActivityPlanCreated
* ReturnToActivityPhaseCompleted
* WorkoutBlockedByLimitation
* WorkoutModifiedForRecovery
* ManualSafetyOverrideRecorded
* LimitationReviewCompleted

---

# 101. Příkazy

Minimálně:

* RecordDailyCheckIn
* ReportFatigue
* ReportMuscleSoreness
* ImportSleepRecord
* UpdateSleepSummary
* ReportStress
* RecordRecoveryMetric
* AssessReadiness
* CreateRecoveryRecommendation
* ProposeRecoveryAdjustment
* ApplyRecoveryAdjustment
* RejectRecoveryAdjustment
* ReportPain
* AssessPain
* CreateTemporaryLimitation
* CreateLongTermLimitation
* RecordProfessionalRecommendation
* ActivateLimitation
* UpdateLimitation
* ResolveLimitation
* ReviewLimitation
* CreateReturnToActivityPlan
* AdvanceReturnToActivityPhase
* AssessWorkoutSafety
* RecordManualOverride
* RecalculateRecoveryTrend

---

# 102. Invariance – vlastnictví

* Každý DailyCheckIn patří jednomu uživateli.
* PainReport nesmí být propojen s workoutem jiného uživatele.
* Limitation musí patřit stejnému uživateli jako ovlivněný objekt.
* ProfessionalRecommendation patří jednomu uživateli.

---

# 103. Invariance – bolest

* PainReport nesmí být uložen jako diagnóza.
* Intenzita nesmí být mimo definovanou škálu.
* Report musí obsahovat alespoň oblast nebo srozumitelný text.
* Změna starého PainReport nesmí přepsat historii bez auditu.
* Jednorázový PainReport se nesmí automaticky změnit na permanentní Limitation.

---

# 104. Invariance – omezení

* Aktivní dočasné omezení musí mít dobu platnosti nebo způsob revize.
* Limitation s odborným zdrojem nesmí být odstraněno AI bez uživatelského potvrzení.
* Blokující LimitationRule se nesmí obejít AI návrhem.
* Ukončení omezení musí být auditované.
* Historické omezení se nesmí fyzicky smazat běžnou změnou plánu.

---

# 105. Invariance – readiness

* ReadinessAssessment musí mít timestamp a kontext.
* Assessment nesmí být používán po skončení platnosti bez nového vyhodnocení.
* HIGH readiness nesmí automaticky zvýšit plánovanou zátěž.
* UNKNOWN readiness nesmí být automaticky interpretována jako LOW.
* Výsledek musí uchovat vstupní zdroje a jistotu.

---

# 106. Invariance – safety

* Kritický SafetyFlag musí být vyhodnocen deterministickou vrstvou.
* AI nesmí přepsat blokující SafetyDecision.
* Závažný stav nesmí vést k běžnému workout doporučení bez varování.
* Bezpečnostní rozhodnutí musí mít audit a verzi pravidel.
* Uživatel nesmí dostat falešné ujištění o diagnóze nebo bezpečnosti.

---

# 107. Invariance – spánek a wearables

* Wearable score nesmí být interním zdrojem pravdy bez normalizace.
* Každá metrika musí mít zdroj.
* Chybějící data se nesmí nahrazovat vymyšlenými hodnotami.
* Uživatelská oprava musí zachovat původní hodnotu.
* Jeden nekvalitní záznam nesmí automaticky způsobit velkou změnu plánu.

---

# 108. Invariance – změny workoutu

* Úprava kvůli regeneraci musí zachovat původní workout revision.
* Změna více dnů musí být potvrzena, pokud není předem výslovně povolena.
* Aktivní session nesmí být neviditelně změněna.
* Dokončená historická aktivita se nesmí přepsat novým recovery rozhodnutím.
* Zastaralý RecoveryAdjustmentProposal se nesmí aplikovat.

---

# 109. Read modely

## 109.1 TodayRecoveryView

Obsahuje:

* aktuální check-in,
* readiness,
* aktivní omezení,
* dnešní doporučení,
* ovlivněné workouty.

## 109.2 ReadinessDetailView

Obsahuje:

* úroveň,
* kontext,
* vstupní data,
* trend,
* jistotu,
* vysvětlení,
* doporučení.

## 109.3 PainReportView

Obsahuje:

* oblast,
* stranu,
* intenzitu,
* charakter,
* trend,
* související pohyby,
* assessment.

## 109.4 LimitationOverview

Obsahuje:

* aktivní omezení,
* platnost,
* dopad,
* ovlivněné sporty,
* ovlivněné workouty.

## 109.5 RecoveryAdjustmentPreview

Obsahuje:

* původní workout,
* novou variantu,
* důvod,
* dopad,
* potvrzení.

## 109.6 RecoveryHistoryView

Obsahuje:

* check-iny,
* readiness trend,
* pain trend,
* změny workoutů,
* omezení.

---

# 110. Příklad – vysoká únava a špatný spánek

## Vstup

* únava 5/5,
* spánek 4 hodiny,
* bez bolesti,
* večer silový workout,
* zítra týmový trénink.

## Assessment

* general readiness: LOW,
* strength readiness: LOW,
* safety: bez blokujícího problému,
* confidence: MEDIUM.

## Návrh

* zkrátit workout,
* snížit objem,
* odstranit doplňky,
* zachovat lehký hlavní stimul,
* znovu vyhodnotit stav další den.

---

# 111. Příklad – bolest pravého bicepsu

## Vstup

* pravý biceps,
* bolest 5/10,
* při shybu,
* bez bolesti v klidu,
* postupný vznik,
* zhoršuje se při tahu.

## Assessment

* diagnosis: žádná,
* concern: UNCERTAIN nebo MODERATE podle pravidel,
* vertical pull: nevhodný,
* direct elbow flexion: nevhodný,
* tlakové cviky: mohou být posouzeny samostatně.

## Návrh

* odstranit shyby,
* odstranit bicepsové doplňky,
* zachovat nebolestivý tlak a core,
* dočasné omezení na několik dní,
* revize při přetrvávání nebo zhoršení.

---

# 112. Příklad – bolest kolene při dřepu

## Vstup

* pravé koleno,
* ostrá bolest při hlubokém dřepu,
* bez úrazu,
* při chůzi mírná.

## Výsledek

Systém nesmí pouze snížit váhu.

Musí:

* označit squat pattern,
* zohlednit funkční dopad,
* zablokovat bolestivý rozsah,
* nabídnout bezpečné přerušení workoutu,
* podle závažnosti doporučit odborné posouzení.

---

# 113. Příklad – svalovice po zápase

## Vstup

* oboustranná bolest stehen,
* vznik den po zápase,
* tupá,
* bez bolesti v klidu,
* běžná chůze možná.

## Vyhodnocení

* pravděpodobná běžná post-exercise soreness,
* readiness nohou snížená,
* lehká mobilita možná,
* těžký lower-body workout nevhodný.

Systém stále komunikuje, že nejde o diagnózu.

---

# 114. Příklad – hodinky versus subjektivní pocit

## Data

* wearable recovery: nízké,
* uživatel se cítí dobře,
* spánek subjektivně dobrý,
* žádná bolest,
* dlouhodobý trend stabilní.

## Výsledek

* assessment confidence střední,
* workout lze zachovat,
* doporučit konzervativní warm-up a kontrolu pocitu,
* nezvyšovat intenzitu nad plán.

---

# 115. Příklad – návrat po nemoci

## Vstup

* deset dní bez sportu,
* uživatel se cítí lépe,
* bez akutních příznaků,
* předtím vysoká sportovní frekvence.

## Výsledek

* ReturnToActivityPlan,
* první týden snížený objem,
* nižší intenzita,
* kontrola reakce,
* postupná obnova.

---

# 116. Příklad – odborný zákaz běhu

## Doporučení

* bez běhu dva týdny,
* cyklistika povolena lehce.

## Model

* ProfessionalRecommendation,
* LimitationRule: PROHIBITS RUNNING,
* LimitationRule: LIMITS CYCLING TO LOW_INTENSITY,
* datum revize.

## Dopad

* běžecké workouty zablokovány,
* lze navrhnout lehkou cyklistiku,
* po skončení návratový blok.

---

# 117. Příklad – historická operace kolene

## Profil

* historická operace,
* aktuálně bez bolesti,
* sportovní aktivita běžná.

## Výsledek

* HistoricalCondition,
* žádná automatická blokace,
* informace může být zohledněna při novém PainReport,
* není nutné omezovat všechny workouty.

---

# 118. Co musí být strukturované

Nesmí zůstat pouze jako text:

* únava,
* její intenzita,
* lokalizace,
* spánek,
* readiness,
* bolest,
* oblast,
* strana,
* intenzita bolesti,
* bolestivý pohyb,
* doba platnosti,
* omezení,
* odborné doporučení,
* bezpečnostní rozhodnutí,
* dopad na workout,
* změna workoutu,
* historie a audit.

Volný text může doplnit:

* subjektivní popis,
* okolnosti,
* poznámku,
* původní uživatelský vstup.

---

# 119. Otevřené otázky

* Jaké přesné škály použít pro energii, únavu a bolest?
* Jaké bezpečnostní otázky musí být povinné?
* Které SafetyFlag budou součástí první verze?
* Jak odborně validovat safety pravidla?
* Jaký rozdíl bude mezi PainReport a MuscleSorenessReport v UI?
* Kdy se má PainReport automaticky navrhnout jako Limitation?
* Jak dlouho má platit dočasné omezení bez revize?
* Jak reprezentovat bolestivý rozsah pohybu?
* Jak detailní má být BodyArea hierarchie?
* Jak modelovat nemoc bez vytváření zdravotní diagnózy?
* Jak pracovat s léky nebo zdravotnickými údaji, pokud je uživatel uvede?
* Která data budou přístupná AI?
* Jak dlouho uchovávat detailní recovery historii?
* Jak vypočítat readiness bez falešné přesnosti?
* Má být readiness jedno skóre, nebo pouze vícerozměrný stav?
* Jak zobrazit rozpor mezi wearable a subjektivními daty?
* Jaké wearable metriky podporovat v první verzi?
* Jak verzovat recovery algoritmy?
* Jak vyhodnotit dlouhodobý pokles bez diagnostiky přetrénování?
* Jak řešit chybějící baseline?
* Kdy automaticky navrhnout deload?
* Jak přesně funguje návrat po nemoci?
* Kdy vyžadovat nové potvrzení odborného omezení?
* Jak řešit nezletilé uživatele?
* Jak zpracovat citlivé zdravotní údaje právně?
* Jak funguje export a smazání těchto dat?
* Jak řešit aktivní workout při novém PainReport?
* Jaký je přesný rozsah offline safety enginu?
* Jak synchronizovat bezpečnostní blokace mezi zařízeními?
* Jak zabránit tomu, aby AI příliš často doporučovala úplný odpočinek?
* Jak zabránit opačnému problému, tedy příliš agresivnímu pokračování?
* Jak vyhodnocovat jednostranné cviky při jednostranném omezení?
* Jak aktualizovat plán po ukončení omezení?
* Jak oddělit odborně vytvořený návratový plán od běžného AI návrhu?

---

# 120. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── ai-and-change-model.md
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── identity-and-profile-model.md
├── domain-events.md
└── domain-invariants.md
```

Dále:

```text
docs/05-ai/
├── safety-rules.md
├── recovery-reasoning.md
├── pain-handling.md
├── limitation-handling.md
├── confirmation-policy.md
└── ai-tools.md
```

A:

```text
docs/07-backend/
├── recovery-service.md
├── safety-rules-engine.md
├── limitation-service.md
├── readiness-service.md
└── sensitive-data-security.md
```

A:

```text
docs/08-mobile/
├── daily-check-in.md
├── pain-report-flow.md
├── body-map.md
├── recovery-ui.md
└── offline-safety.md
```

---

# 121. Kritéria správného modelu

Model je vhodný pouze tehdy, pokud umožní:

1. zaznamenat denní únavu,
2. zaznamenat lokalizovanou únavu,
3. zaznamenat spánek,
4. importovat wearable recovery data,
5. zachovat zdroj a kvalitu dat,
6. vytvořit readiness assessment,
7. vyjádřit nejistotu,
8. reagovat na rozpor dat,
9. zaznamenat svalovici,
10. zaznamenat bolest,
11. určit stranu těla,
12. určit bolestivý pohyb,
13. rozlišit bolest v klidu a při pohybu,
14. vytvořit bezpečnostní assessment bez diagnózy,
15. zablokovat rizikový cvik,
16. upravit workout,
17. upravit týden,
18. vytvořit dočasné omezení,
19. vytvořit dlouhodobé omezení,
20. zaznamenat odborné doporučení,
21. respektovat zákaz aktivity,
22. podporovat návrat po pauze,
23. zachovat historické zranění bez automatické blokace,
24. fungovat bez wearables,
25. fungovat offline,
26. synchronizovat více zařízení,
27. zabránit ztrátě bezpečnostních dat,
28. auditovat změny,
29. chránit citlivé údaje,
30. zabránit AI v diagnostice,
31. zabránit AI v obcházení blokujících pravidel,
32. vysvětlit uživateli důvod změny,
33. umožnit uživateli odmítnout běžné doporučení,
34. zachovat historii původního workoutu,
35. zohlednit recovery rozhodnutí v adherence,
36. podporovat libovolný sport a pohybový vzor.

---

# 122. Závěr

Recovery and Limitations model propojuje aktuální stav uživatele s plánovanou zátěží.

Jeho základní tok je:

```text
DailyCheckIn
    +
SleepRecord
    +
RecoveryMetric
    +
ActivityLoad
    +
PainReport
    +
Limitation
    ↓
ReadinessAssessment
    +
SafetyAssessment
    ↓
RecoveryRecommendation
    ↓
RecoveryAdjustmentProposal
    ↓
WorkoutModification / ChangeSet
    ↓
WorkoutSession / Activity
    ↓
RecoveryHistory a další vyhodnocení
```

Bezpečnostní tok je:

```text
PainReport / HealthStatusReport
    ↓
PainAssessment
    ↓
SafetyFlag
    ↓
SafetyAssessment
    ↓
SafetyDecision
    ↓
Povolit / Upravit / Blokovat / Doporučit odbornou pomoc
```

Hlavním cílem není vytvořit univerzální „recovery score“.

Cílem je vytvořit systém, který dokáže:

* pracovat s různými zdroji,
* rozlišovat celkovou a lokální připravenost,
* přiznat nejistotu,
* respektovat odborná omezení,
* reagovat na bolest bez diagnostiky,
* upravit konkrétní workout,
* zachovat dlouhodobý směr plánu,
* chránit uživatele před nebezpečným automatickým doporučením.

Díky tomu může uživatel říct:

> Dnes jsem unavený.

nebo:

> Bolí mě pravý biceps při shybech.

A aplikace neodpoví pouze obecným textem, ale vytvoří strukturované, vysvětlitelné, bezpečné a vratné rozhodnutí, které se skutečně projeví v dnešním workoutu, kalendáři a dalším plánování.
