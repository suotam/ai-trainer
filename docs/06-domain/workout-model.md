# AI Trainer – Workout Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/workout-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje doménový model workoutů v aplikaci AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/screen-specifications.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/training-plan-model.md`.

Dokument popisuje:

* rozdíl mezi šablonou, plánovanou instancí a skutečným provedením,
* obecnou strukturu workoutu,
* workout sekce,
* cviky a jiné tréninkové kroky,
* série, intervaly, časové úseky a další typy předpisu,
* podporu silového tréninku,
* mobilitu,
* běh a vytrvalost,
* týmové sporty,
* obecné a vlastní aktivity,
* varianty workoutu,
* zkrácení a adaptaci,
* nahrazení cviku,
* aktivní tracker,
* offline průběh workoutu,
* dokončení a historický záznam,
* životní cyklus workoutu,
* doménové invariance,
* rozšiřitelnost pro další sporty.

Dokument zatím neurčuje:

* přesné databázové tabulky,
* finální API kontrakty,
* konkrétní Flutter widgety,
* konkrétní UI design trackeru,
* kompletní katalog cviků,
* finální algoritmy pro progresi,
* konkrétní video a multimediální řešení.

---

# 2. Cíl workout modelu

Workout model musí umožnit vytvořit, naplánovat, upravit, provést a vyhodnotit širokou škálu tréninkových jednotek.

Musí podporovat například:

* domácí silový workout,
* posilování ve fitku,
* krátký core,
* mobilitu,
* flexibilitu,
* warm-up,
* cooldown,
* intervalový běh,
* souvislý běh,
* cyklistický trénink,
* lezeckou kompenzaci,
* sportovní techniku,
* týmový trénink,
* obecnou pohybovou aktivitu,
* vlastní sport uživatele.

Workout model nesmí být navržen pouze jako:

> Exercise → Set → Repetitions

Tento model je vhodný pro část silového tréninku, ale nestačí pro všechny sporty.

Základ musí být obecný a specializované struktury se přidávají nad něj.

---

# 3. Základní rozdělení

Workout oblast musí rozlišovat minimálně čtyři vrstvy:

1. `WorkoutTemplate`
2. `WorkoutInstance`
3. `WorkoutSession`
4. `Activity`

## 3.1 WorkoutTemplate

Opakovatelný návrh workoutu.

Příklad:

> Upper Body A

Obsahuje obecnou strukturu:

* warm-up,
* shyby,
* kliky,
* přítahy,
* core,
* cooldown.

Nemá konkrétní datum ani skutečné provedení.

## 3.2 WorkoutInstance

Konkrétní naplánovaný výskyt šablony.

Příklad:

> Upper Body A, úterý 18. srpna v 18:00

Může být oproti šabloně lokálně upraven.

## 3.3 WorkoutSession

Skutečný průběh workoutu.

Příklad:

* zahájeno v 18:12,
* dokončeny tři série shybů,
* kliky nahrazeny lehčí variantou,
* workout dokončen za 38 minut.

## 3.4 Activity

Historický záznam skutečné aktivity.

Vzniká po dokončení workoutu nebo jiným způsobem.

Activity je součástí sportovní historie a statistik.

---

# 4. Hlavní principy workout modelu

## 4.1 Šablona se nesmí přepisovat změnou jedné instance

Pokud uživatel dnes sníží počet sérií, nesmí se automaticky změnit všechny další workouty.

Rozsah změny musí být explicitní:

* jen dnešní instance,
* všechny budoucí instance v plánu,
* zdrojová šablona.

## 4.2 Plánované a skutečné hodnoty jsou oddělené

Příklad:

* plán: 4 série po 8 opakováních,
* skutečnost: 3 série po 7, 7 a 6 opakováních.

Systém musí zachovat obě informace.

## 4.3 Workout musí být proveditelný offline

Po načtení do zařízení musí být možné bez internetu:

* otevřít workout,
* spustit session,
* zapisovat průběh,
* měnit hodnoty,
* přidat poznámku,
* pozastavit,
* dokončit,
* vytvořit lokální Activity.

## 4.4 Každý workout musí mít účel

Workout nemá být pouze seznam cviků.

Měl by mít definováno:

* proč existuje,
* co rozvíjí,
* jakou roli má v plánu,
* které cíle podporuje,
* jaké části jsou prioritní.

To umožňuje smysluplné zkrácení a adaptaci.

## 4.5 Adaptace musí zachovat hlavní účel, pokud je to možné

Při zkrácení workoutu systém nemá pouze odstranit poslední cviky.

Musí nejprve určit:

* hlavní účel,
* hlavní pohybové vzory,
* minimální užitečný objem,
* bezpečný warm-up,
* části, které lze vynechat.

## 4.6 Workout musí podporovat obecné kroky

Ne každá položka workoutu je klasický cvik.

Může jít o:

* běžecký interval,
* odpočinek,
* mobilitní pozici,
* dechové cvičení,
* technický blok,
* časový úsek,
* vzdálenost,
* sportovní drill,
* obecnou instrukci.

---

# 5. Hlavní objekty workout oblasti

Workout oblast obsahuje minimálně:

* WorkoutTemplate,
* WorkoutTemplateVersion,
* WorkoutInstance,
* WorkoutSection,
* WorkoutStep,
* ExerciseDefinition,
* ExerciseVariant,
* WorkoutExercise,
* Prescription,
* SetPlan,
* IntervalPlan,
* DurationPlan,
* DistancePlan,
* WorkoutAlternative,
* WorkoutSession,
* SectionPerformance,
* StepPerformance,
* ExercisePerformance,
* SetPerformance,
* WorkoutFeedback,
* WorkoutIssue,
* WorkoutModification.

---

# 6. WorkoutTemplate

## 6.1 Význam

WorkoutTemplate je opakovatelný předpis workoutu.

Může být vytvořen:

* systémem,
* trenérem v budoucnu,
* uživatelem,
* plánovacím enginem,
* AI návrhem.

## 6.2 Vlastnosti

WorkoutTemplate obsahuje:

* identifikátor,
* vlastníka nebo systémový původ,
* název,
* popis,
* účel,
* typ,
* očekávanou délku,
* obtížnost,
* potřebné vybavení,
* vhodné prostředí,
* podporované cíle,
* podporované sporty,
* sekce,
* pravidla adaptace,
* pravidla progrese,
* stav,
* verzi.

## 6.3 Typ šablony

Minimálně:

* STRENGTH,
* HYPERTROPHY,
* MOBILITY,
* FLEXIBILITY,
* CONDITIONING,
* ENDURANCE,
* INTERVAL,
* RECOVERY,
* WARM_UP,
* COOLDOWN,
* TECHNIQUE,
* SPORT_SESSION,
* TEST,
* MIXED,
* CUSTOM.

Typ slouží jako obecná klasifikace.

Nesmí sám určovat kompletní strukturu.

## 6.4 Původ šablony

* SYSTEM,
* USER,
* AI_GENERATED,
* PLAN_GENERATED,
* IMPORTED,
* COACH_CREATED v budoucnu.

## 6.5 Stav šablony

* DRAFT,
* ACTIVE,
* INACTIVE,
* ARCHIVED,
* REPLACED.

## 6.6 Systémová a uživatelská šablona

Systémová šablona:

* může být aktualizována novou verzí,
* nemá být uživatelem přímo přepisována,
* může být zkopírována do uživatelské varianty.

Uživatelská šablona:

* patří uživateli,
* může být upravována,
* změny musí respektovat historické instance.

---

# 7. WorkoutTemplateVersion

## 7.1 Význam

Neměnná verze šablony.

Je důležitá, protože historický workout musí být možné zobrazit podle struktury platné v době plánování.

## 7.2 Obsah

* identifikátor,
* vazba na WorkoutTemplate,
* pořadí verze,
* čas vytvoření,
* autor,
* důvod změny,
* sekce,
* kroky,
* pravidla,
* vybavení,
* očekávaná délka.

## 7.3 Kdy vzniká nová verze

Například při:

* změně hlavní struktury,
* přidání nebo odebrání sekce,
* změně hlavních cviků,
* změně progresní logiky,
* změně významu workoutu.

Drobná oprava textu instrukce může být řešena samostatně podle budoucích pravidel verzování obsahu.

---

# 8. WorkoutInstance

## 8.1 Význam

WorkoutInstance je konkrétní naplánovaný workout.

## 8.2 Vlastnosti

Obsahuje:

* identifikátor,
* uživatele,
* název,
* vazbu na šablonu a její verzi,
* vazbu na plán,
* blok,
* týden,
* cíle,
* sporty,
* plánované datum a čas,
* časové pásmo,
* plánovanou délku,
* prioritu,
* roli v daném dni,
* flexibilitu,
* stav,
* lokální úpravy,
* důvod vytvoření,
* zdroj vytvoření,
* aktuální revizi.

## 8.3 Workout bez šablony

WorkoutInstance může existovat i bez WorkoutTemplate.

Například:

* jednorázový AI workout,
* ručně vytvořený workout,
* vlastní netypická aktivita.

V takovém případě obsahuje kompletní vlastní strukturu.

## 8.4 Snapshot struktury

Instance musí mít stabilní snapshot svého plánovaného obsahu.

Nesmí být při otevření závislá pouze na aktuální verzi šablony.

Jinak by změna šablony zpětně změnila již naplánované workouty.

## 8.5 Zdroj vytvoření

* TRAINING_PLAN,
* USER,
* AI_PROPOSAL,
* RECURRENCE,
* DUPLICATE,
* REPLACEMENT,
* IMPORT.

## 8.6 Stav instance

* DRAFT,
* PLANNED,
* READY,
* MODIFIED,
* IN_PROGRESS,
* PAUSED,
* COMPLETED,
* PARTIALLY_COMPLETED,
* SKIPPED,
* CANCELLED,
* RESCHEDULED,
* REPLACED,
* EXPIRED.

## 8.7 READY

Stav může označovat, že workout je detailně vygenerovaný a dostupný pro provedení.

To je užitečné při rolling horizon plánování.

---

# 9. Revize WorkoutInstance

WorkoutInstance může mít interní revize.

To umožňuje zachovat změny jedné instance bez vytváření nové TrainingPlanVersion.

## 9.1 WorkoutInstanceRevision

Obsahuje:

* číslo revize,
* původní revizi,
* čas,
* zdroj,
* důvod,
* kompletní nebo rozdílový snapshot,
* ChangeSet.

## 9.2 Příklady změny revize

* zkrácení workoutu,
* nahrazení cviku,
* změna počtu sérií,
* změna času,
* adaptace kvůli bolesti,
* adaptace kvůli vybavení.

## 9.3 Historická stabilita

WorkoutSession musí odkazovat na revizi, podle které byla zahájena.

Pokud se workout během session změní, musí být změna zachycena jako samostatná runtime úprava.

---

# 10. WorkoutSection

## 10.1 Význam

WorkoutSection je logická část workoutu.

## 10.2 Příklady

* Warm-up
* Activation
* Main Strength
* Accessory Work
* Conditioning
* Mobility
* Cooldown
* Technique
* Recovery

## 10.3 Vlastnosti

* identifikátor,
* název,
* typ,
* pořadí,
* účel,
* očekávaná délka,
* priorita,
* volitelnost,
* kroky,
* pravidlo dokončení.

## 10.4 Priorita sekce

* REQUIRED,
* HIGH,
* NORMAL,
* OPTIONAL.

Při zkrácení workoutu se nejprve odebírají volitelné části.

## 10.5 Stav sekce během provedení

* NOT_STARTED,
* IN_PROGRESS,
* COMPLETED,
* PARTIALLY_COMPLETED,
* SKIPPED.

---

# 11. WorkoutStep

## 11.1 Význam

WorkoutStep je obecná nejmenší plánovaná položka workoutu.

Může reprezentovat:

* cvik,
* interval,
* běžecký úsek,
* odpočinek,
* mobilitní pozici,
* technický drill,
* instrukci,
* časový blok,
* sportovní úkol.

## 11.2 Typy kroků

Minimálně:

* EXERCISE,
* INTERVAL,
* DURATION,
* DISTANCE,
* REST,
* MOBILITY_POSITION,
* TECHNIQUE_DRILL,
* ACTIVITY_BLOCK,
* INSTRUCTION,
* CIRCUIT,
* SUPERSET,
* CUSTOM.

## 11.3 Vlastnosti

* identifikátor,
* typ,
* název,
* pořadí,
* účel,
* priorita,
* plánovaný předpis,
* potřebné vybavení,
* instrukce,
* alternativy,
* možnost přeskočení,
* podmínky dokončení.

## 11.4 Typová data

WorkoutStep má společný základ a typově specifický předpis.

Nemá používat jeden nekontrolovaný objekt libovolných klíčů.

Typové schéma musí být validovatelné.

---

# 12. Hierarchické workout kroky

Některé kroky obsahují další kroky.

Příklady:

## Circuit

* dřepy,
* kliky,
* plank,
* opakovat tři kola.

## Superset

* shyby,
* kliky,
* společná pauza.

## Interval block

* 5× rychlý úsek,
* meziklusu.

Model musí podporovat kompozici.

## 12.1 CompositeWorkoutStep

Obsahuje:

* typ kompozice,
* podřízené kroky,
* počet kol,
* pravidlo pořadí,
* pravidlo odpočinku,
* pravidlo ukončení.

## 12.2 Maximální složitost

Systém musí omezit příliš hluboké vnoření.

Pro první verzi je vhodné podporovat přehlednou strukturu maximálně několika úrovní.

---

# 13. ExerciseDefinition

## 13.1 Význam

ExerciseDefinition je obecná definice cviku nezávislá na konkrétním workoutu.

## 13.2 Obsah

* identifikátor,
* systémový název,
* lokalizované názvy,
* popis,
* pohybový vzor,
* hlavní zatížené oblasti,
* vedlejší zatížené oblasti,
* potřebné vybavení,
* prostředí,
* obtížnost,
* technické požadavky,
* kontraindikace jako obecná metadata,
* dostupné varianty,
* instrukce.

## 13.3 Příklady pohybových vzorů

* horizontal push,
* vertical push,
* horizontal pull,
* vertical pull,
* squat,
* hinge,
* lunge,
* carry,
* rotation,
* anti-rotation,
* locomotion,
* mobility,
* isometric,
* grip.

## 13.4 Vlastní cvik

Uživatel může vytvořit CustomExerciseDefinition.

Musí zadat minimálně:

* název,
* základní typ,
* způsob měření,
* případně vybavení.

## 13.5 Historie názvu a instrukcí

Historická session musí zůstat srozumitelná i po aktualizaci ExerciseDefinition.

Je vhodné ukládat snapshot základních zobrazovaných údajů do WorkoutStep nebo session.

---

# 14. ExerciseVariant

## 14.1 Význam

Varianta konkrétního cviku.

Příklady:

* klasický klik,
* klik na kolenou,
* klik s nohama výše,
* shyb s gumou,
* negativní shyb.

## 14.2 Vlastnosti

* identifikátor,
* výchozí ExerciseDefinition,
* název,
* obtížnost,
* změna vybavení,
* technická odlišnost,
* vhodné použití,
* případná progrese nebo regrese.

## 14.3 Vztah variant

Varianty mohou být propojeny:

* EASIER_THAN,
* HARDER_THAN,
* EQUIPMENT_ALTERNATIVE,
* PAIN_ALTERNATIVE,
* TECHNIQUE_ALTERNATIVE.

Tyto vztahy pomáhají při adaptaci.

---

# 15. WorkoutExercise

## 15.1 Význam

WorkoutExercise je použití ExerciseDefinition nebo ExerciseVariant uvnitř konkrétního workoutu.

## 15.2 Obsah

* cvik,
* varianta,
* pořadí,
* účel,
* předpis,
* tempo,
* odpočinek,
* priorita,
* poznámka,
* alternativy,
* důvod zařazení.

## 15.3 Snapshot

Musí obsahovat dostatečný snapshot pro offline zobrazení:

* název,
* instrukce,
* jednotky,
* plánované hodnoty,
* případné médium nebo lokální odkaz.

---

# 16. Prescription

## 16.1 Význam

Prescription popisuje, co má uživatel v daném kroku provést.

Je obecnější než SetPlan.

## 16.2 Typy předpisů

* SET_REP,
* DURATION,
* DISTANCE,
* INTERVAL,
* OPEN_ACTIVITY,
* HOLD,
* REPETITION,
* TARGET_METRIC,
* COMPLETION_ONLY,
* CUSTOM.

## 16.3 Společné vlastnosti

* cílová intenzita,
* rozsah hodnot,
* počet opakování struktury,
* jednotky,
* instrukce,
* tolerance odchylky,
* pravidla dokončení.

---

# 17. SetPlan

## 17.1 Význam

Plán jedné silové série nebo podobného pracovního úseku.

## 17.2 Možná pole

* plannedRepetitions,
* minimumRepetitions,
* maximumRepetitions,
* plannedWeight,
* weightUnit,
* plannedDuration,
* tempo,
* restAfter,
* targetRpe,
* targetRir,
* side,
* setType.

## 17.3 Typ série

* WARM_UP,
* WORKING,
* BACK_OFF,
* DROP,
* AMRAP,
* ISOMETRIC,
* TECHNIQUE,
* TEST.

## 17.4 Rozsahy místo falešné přesnosti

Předpis může být:

> 8–10 opakování při RPE 7

Nemusí být vždy jedno přesné číslo.

---

# 18. IntervalPlan

## 18.1 Význam

Předpis intervalového úseku.

## 18.2 Obsah

* počet opakování,
* pracovní délka nebo vzdálenost,
* cílová intenzita,
* tempo nebo zóna,
* délka odpočinku,
* typ odpočinku,
* warm-up,
* cooldown.

## 18.3 Příklady

* 6× 2 minuty rychle / 2 minuty lehce,
* 8× 400 metrů,
* 10× 30 sekund práce / 30 sekund pauza.

---

# 19. DurationPlan

## 19.1 Význam

Předpis založený na času.

Příklady:

* plank 30 sekund,
* mobilitní pozice 60 sekund,
* lehký běh 40 minut,
* dechová rutina 5 minut.

## 19.2 Vlastnosti

* plánovaná délka,
* minimální délka,
* maximální délka,
* intenzita,
* strana,
* opakování,
* pravidlo dokončení.

---

# 20. DistancePlan

## 20.1 Význam

Předpis založený na vzdálenosti.

Příklady:

* běh 8 km,
* 5× 400 m,
* cyklistika 50 km.

## 20.2 Vlastnosti

* vzdálenost,
* jednotka,
* cílové tempo,
* intenzita,
* převýšení volitelně,
* tolerance.

---

# 21. MobilityPrescription

## 21.1 Význam

Specializovaný předpis mobility nebo flexibility.

## 21.2 Obsah

* pozice nebo pohyb,
* strana,
* délka,
* počet opakování,
* rozsah pohybu,
* dynamický nebo statický charakter,
* dechová instrukce,
* intenzita tahu,
* bezpečnostní poznámka.

## 21.3 Mobilita není vždy regenerace

Model musí odlišit:

* lehkou regenerační mobilitu,
* intenzivní flexibilitu,
* aktivní mobilitu,
* silový rozsah pohybu.

Každý typ může mít odlišnou zátěž.

---

# 22. TechniqueDrill

## 22.1 Význam

Technický úkol, který se nehodnotí pouze objemem.

Příklady:

* běžecká abeceda,
* fotbalová práce s míčem,
* lezecký technický drill,
* nácvik dopadu,
* balanční cvičení.

## 22.2 Obsah

* název,
* účel,
* délka,
* počet pokusů,
* kvalitativní instrukce,
* subjektivní hodnocení,
* případně video v budoucnu.

---

# 23. OpenActivityBlock

## 23.1 Význam

Volnější blok bez přesného seznamu kroků.

Příklad:

> 60 minut florbalový trénink

nebo:

> 2 hodiny lehké lezení

## 23.2 Obsah

* název,
* sport,
* délka,
* cílová intenzita,
* účel,
* doporučené zaměření,
* subjektivní hodnocení po dokončení.

Tento typ je důležitý pro sporty, které nelze nebo není vhodné rozepisovat na cviky.

---

# 24. WorkoutAlternative

## 24.1 Význam

Předem připravená alternativa workoutu.

## 24.2 Typy

* SHORTER,
* EASIER,
* HARDER,
* NO_EQUIPMENT,
* TRAVEL,
* PAIN_ADAPTED,
* LOW_READINESS,
* HOME,
* GYM,
* OUTDOOR.

## 24.3 Obsah

* podmínka použití,
* rozdíl od hlavní verze,
* očekávaná délka,
* zachovaný účel,
* odstraněné části,
* změněné vybavení,
* omezení použití.

## 24.4 Vytváření alternativ

Alternativa může být:

* součástí šablony,
* vygenerována deterministicky,
* navržena AI,
* vytvořena uživatelem.

---

# 25. Zkrácení workoutu

## 25.1 Cíl

Vytvořit kratší workout bez ztráty jeho hlavního smyslu.

## 25.2 Vstupy

* dostupný čas,
* hlavní účel,
* priorita sekcí,
* nutný warm-up,
* dnešní další zátěž,
* únava,
* omezení.

## 25.3 Strategie

Pořadí:

1. zachovat bezpečný minimální warm-up,
2. zachovat hlavní část,
3. snížit počet pracovních sérií,
4. odstranit volitelné doplňky,
5. zkrátit cooldown podle bezpečnosti,
6. případně doporučit přesun místo neúčelné krátké varianty.

## 25.4 WorkoutModification

Zkrácení musí vytvořit auditovaný WorkoutModification nebo ChangeSet.

---

# 26. Zlehčení workoutu

## 26.1 Možné změny

* snížení sérií,
* snížení opakování,
* snížení váhy,
* snížení RPE,
* lehčí varianta cviku,
* delší pauzy,
* nižší tempo,
* kratší intervaly,
* odstranění vysokointenzivní části.

## 26.2 Rozdíl oproti zkrácení

Zkrácení řeší primárně čas.

Zlehčení řeší primárně fyzickou náročnost.

Obě změny se mohou kombinovat.

---

# 27. Nahrazení cviku

## 27.1 Důvody

* chybějící vybavení,
* bolest,
* příliš vysoká obtížnost,
* příliš nízká obtížnost,
* preference,
* obsazené zařízení,
* technická nejistota,
* únava,
* prostředí.

## 27.2 Kritéria náhrady

Náhradní cvik by měl pokud možno zachovat:

* hlavní pohybový vzor,
* hlavní cíl,
* podobné zatížení,
* vhodnou obtížnost,
* kompatibilitu s vybavením,
* bezpečnost.

## 27.3 Rozsah změny

* CURRENT_SESSION_ONLY,
* CURRENT_INSTANCE,
* FUTURE_INSTANCES,
* TEMPLATE.

## 27.4 Bezpečnost

Při náhradě kvůli bolesti nesmí systém pouze vybrat cvik se stejným svalem.

Musí zohlednit:

* bolestivý pohyb,
* oblast,
* zatížení,
* aktivní omezení,
* jistotu doporučení.

---

# 28. WorkoutModification

## 28.1 Význam

Strukturovaný záznam změny workoutu.

## 28.2 Typy

* SHORTENED,
* LIGHTENED,
* EXERCISE_REPLACED,
* SETS_CHANGED,
* INTENSITY_CHANGED,
* TIME_CHANGED,
* EQUIPMENT_ADAPTED,
* PAIN_ADAPTED,
* USER_CUSTOMIZED,
* AI_ADAPTED.

## 28.3 Obsah

* původní stav,
* nový stav,
* důvod,
* zdroj,
* rozsah,
* čas,
* vratnost,
* vazba na ChangeSet.

---

# 29. WorkoutSession

## 29.1 Význam

WorkoutSession reprezentuje skutečný průběh workoutu.

## 29.2 Vlastnosti

* identifikátor,
* uživatele,
* WorkoutInstance,
* revizi instance,
* zařízení,
* začátek,
* konec,
* aktivní čas,
* pauzy,
* stav,
* aktuální krok,
* lokální synchronizační stav,
* feedback,
* poznámky.

## 29.3 Session bez WorkoutInstance

Uživatel může spustit ad hoc workout.

V takovém případě WorkoutSession existuje bez plánované instance, ale po dokončení vytvoří Activity.

## 29.4 Více session k jedné instanci

Model může podporovat více session například při:

* přerušení,
* chybném spuštění,
* opakování,
* obnovení po technickém problému.

Musí být určeno, která session je hlavní pro dokončení instance.

## 29.5 Stav session

* NOT_STARTED,
* IN_PROGRESS,
* PAUSED,
* COMPLETED,
* PARTIALLY_COMPLETED,
* ABORTED,
* DISCARDED,
* SYNC_PENDING,
* SYNC_FAILED.

---

# 30. Automatické ukládání session

## 30.1 Požadavek

Každá významná změna musí být lokálně uložena okamžitě nebo téměř okamžitě.

## 30.2 Ukládané změny

* dokončení série,
* změna hodnoty,
* změna cviku,
* poznámka,
* posun na další krok,
* pozastavení,
* časovač,
* hlášení problému.

## 30.3 Obnova

Po pádu aplikace nebo restartu musí být možné:

* detekovat nedokončenou session,
* zobrazit stav,
* pokračovat,
* ukončit ji jako částečnou.

---

# 31. SectionPerformance

## 31.1 Význam

Skutečné provedení WorkoutSection.

## 31.2 Obsah

* stav,
* začátek,
* konec,
* skutečná délka,
* dokončené kroky,
* poznámka,
* důvod přeskočení.

---

# 32. StepPerformance

## 32.1 Význam

Obecné skutečné provedení WorkoutStep.

## 32.2 Obsah

* plánovaný krok,
* skutečný typ,
* stav,
* skutečné hodnoty,
* začátek,
* konec,
* poznámka,
* změny,
* problém.

## 32.3 Stav

* NOT_STARTED,
* IN_PROGRESS,
* COMPLETED,
* PARTIALLY_COMPLETED,
* SKIPPED,
* REPLACED,
* FAILED.

---

# 33. ExercisePerformance

## 33.1 Význam

Skutečné provedení cviku.

## 33.2 Obsah

* plánovaný WorkoutExercise,
* skutečně použitá varianta,
* série,
* poznámka,
* stav,
* důvod náhrady,
* technické hodnocení volitelně.

---

# 34. SetPerformance

## 34.1 Význam

Skutečný výsledek jedné série.

## 34.2 Možná pole

* repetitions,
* weight,
* duration,
* distance,
* tempo,
* heartRate,
* rpe,
* rir,
* side,
* completed,
* skipped,
* timestamp,
* note.

## 34.3 Plán versus skutečnost

SetPerformance musí odkazovat na SetPlan, pokud existuje.

## 34.4 Přidaná série

Uživatel může přidat sérii, která nebyla plánovaná.

Ta musí být označena jako:

* USER_ADDED,
* AI_ADDED,
* AUTO_GENERATED.

---

# 35. IntervalPerformance

## 35.1 Význam

Skutečné provedení intervalového kroku.

## 35.2 Obsah

* pořadí intervalu,
* skutečná délka,
* skutečná vzdálenost,
* tempo,
* intenzita,
* tep,
* délka odpočinku,
* stav.

---

# 36. MobilityPerformance

## 36.1 Obsah

* skutečný čas,
* strana,
* počet opakování,
* subjektivní rozsah,
* intenzita,
* nepohodlí nebo bolest,
* dokončení.

Nemá předstírat přesné měření mobility, pokud uživatel zadá jen subjektivní pocit.

---

# 37. WorkoutIssue

## 37.1 Význam

Problém zaznamenaný během workoutu.

## 37.2 Typy

* PAIN,
* EQUIPMENT_UNAVAILABLE,
* EXERCISE_TOO_HARD,
* EXERCISE_TOO_EASY,
* TIME_LIMIT,
* TECHNIQUE_UNCERTAINTY,
* FATIGUE,
* ENVIRONMENT,
* APP_ERROR,
* OTHER.

## 37.3 Výsledek

WorkoutIssue může vést k:

* nahrazení kroku,
* zkrácení,
* přerušení,
* dočasnému omezení,
* AI návrhu,
* bezpečnostnímu flow.

---

# 38. Pozastavení workoutu

## 38.1 Důvody

* běžná pauza,
* telefonát,
* přerušení,
* změna prostředí,
* bolest,
* nedostatek času.

## 38.2 Chování

WorkoutSession zůstává aktivní nebo přejde do PAUSED.

Aplikace musí uchovat:

* poslední krok,
* hodnoty,
* čas,
* lokální stav.

## 38.3 Dlouhé pozastavení

Pokud je session pozastavena neobvykle dlouho, aplikace při návratu nabídne:

* pokračovat,
* dokončit jako částečný workout,
* ukončit,
* upravit skutečný čas.

---

# 39. Dokončení workoutu

## 39.1 Podmínky

Workout může být dokončen jako:

* COMPLETED,
* PARTIALLY_COMPLETED,
* ABORTED.

## 39.2 Kompletní dokončení

Neznamená nutně splnění všech plánovaných hodnot.

Znamená, že uživatel workout vědomě uzavřel jako dokončený.

## 39.3 Částečné dokončení

Používá se, pokud:

* část workoutu nebyla provedena,
* uživatel musel skončit,
* byla provedena pouze hlavní část.

## 39.4 Povinný výstup

Při dokončení:

* uzavřít session,
* uložit výkony,
* vytvořit nebo aktualizovat Activity,
* aktualizovat stav WorkoutInstance,
* uložit feedback,
* vytvořit synchronizační operaci,
* vyvolat doménovou událost.

---

# 40. WorkoutFeedback

## 40.1 Význam

Subjektivní zhodnocení workoutu.

## 40.2 Pole

* sessionRpe,
* energie před,
* energie po,
* pocit náročnosti,
* pocit splnění účelu,
* bolest,
* spokojenost,
* volná poznámka.

## 40.3 Volitelnost

Feedback nemá být povinný pokaždé.

Aplikace může použít rychlou minimalistickou variantu.

## 40.4 Využití

* progresní rozhodování,
* readiness,
* týdenní revize,
* adaptace budoucích workoutů.

---

# 41. Activity vytvořená z workoutu

## 41.1 Vztah

Po dokončení WorkoutSession obvykle vznikne Activity.

## 41.2 Activity obsahuje

* sport nebo aktivitu,
* skutečný čas,
* délku,
* intenzitu,
* zdroj WORKOUT_SESSION,
* souhrn výkonu,
* vazbu na WorkoutInstance,
* vazbu na WorkoutSession.

## 41.3 Detailní data

Detailní série mohou zůstat ve WorkoutSession.

Activity obsahuje agregovaný historický přehled.

## 41.4 Oprava

Oprava Activity nesmí automaticky přepsat detailní session bez explicitní logiky.

---

# 42. Workout bez trackeru

Ne každá aktivita potřebuje detailní tracker.

Příklady:

* týmový trénink,
* zápas,
* volné lezení,
* turistika,
* taneční lekce.

Takový workout může mít:

* jednoduchý předtréninkový detail,
* tlačítko zahájit,
* časovač volitelně,
* dokončení,
* délku,
* intenzitu,
* poznámku.

Workout model musí podporovat jednoduchou i detailní session.

---

# 43. Mikro-workout

## 43.1 Význam

Krátká jednotka obvykle 5–20 minut.

## 43.2 Příklady

* ranní mobilita,
* core,
* aktivace,
* kompenzace,
* dechová rutina.

## 43.3 Zvláštní chování

* rychlé spuštění,
* minimum mezikroků,
* krátké notifikace,
* může být volitelný,
* nemá neúměrně ovlivňovat adherence.

---

# 44. Warm-up a cooldown

## 44.1 Samostatný workout nebo sekce

Mohou existovat jako:

* sekce hlavního workoutu,
* samostatná šablona,
* dynamicky přidaný blok.

## 44.2 Kontextová tvorba

Warm-up může záviset na:

* hlavním workoutu,
* sportu,
* aktuální bolesti,
* prostředí,
* počasí v budoucnu,
* dostupném čase.

## 44.3 Bezpečné zkrácení

Warm-up se nemá automaticky celý odstranit při nedostatku času.

---

# 45. Supersety, okruhy a komplexy

## 45.1 Superset

Dva nebo více kroků prováděných v páru.

## 45.2 Circuit

Více kroků opakovaných po kolech.

## 45.3 Complex

Sekvence cviků s jedním náčiním nebo souvislým provedením.

## 45.4 Model

Použít CompositeWorkoutStep.

Obsahuje:

* podřízené kroky,
* počet kol,
* pořadí,
* společnou pauzu,
* pravidla přechodu.

---

# 46. AMRAP, EMOM a časové formáty

## 46.1 AMRAP

Maximální počet kol nebo opakování v daném čase.

## 46.2 EMOM

Úkol na začátku každé minuty.

## 46.3 For Time

Dokončení stanovené práce co nejrychleji.

## 46.4 Podpora

Workout model musí umožnit tyto formáty jako:

* speciální CompositeWorkoutStep,
* s časovým limitem,
* pravidly dokončení,
* metrikou výsledku.

---

# 47. Jednostranné cviky

Model musí rozlišovat:

* LEFT,
* RIGHT,
* BOTH,
* ALTERNATING,
* NOT_APPLICABLE.

Plán může předepisovat:

* stejný počet na obě strany,
* odlišné hodnoty,
* střídavé provedení.

Skutečné výsledky se musí dát uložit samostatně.

---

# 48. Tempo

## 48.1 Silové tempo

Může být reprezentováno například:

* excentrická fáze,
* pauza,
* koncentrická fáze,
* horní pauza.

## 48.2 Obecné tempo

U běhu nebo pohybu jde o rychlost nebo intenzitu.

Model nesmí směšovat silové tempo a běžecké tempo pod jeden nejasný význam.

---

# 49. Intenzita

Intenzita může být vyjádřena různými způsoby:

* RPE,
* RIR,
* procento maxima,
* tepová zóna,
* tempo,
* subjektivní lehká/střední/těžká,
* výkon,
* rychlost,
* technická náročnost.

Každý předpis musí uvést:

* typ intenzity,
* hodnotu nebo rozsah,
* jednotku,
* případnou nejistotu.

---

# 50. Odpočinek

Odpočinek může být:

* mezi sériemi,
* mezi cviky,
* mezi intervaly,
* mezi koly,
* volný,
* pevně daný,
* založený na zotavení.

## 50.1 RestPrescription

Obsahuje:

* délku,
* minimum,
* maximum,
* typ,
* možnost přeskočení,
* automatický časovač.

---

# 51. Časovače

Workout tracker může používat:

* celkový čas workoutu,
* čas kroku,
* čas série,
* intervalový časovač,
* odpočinek,
* odpočet,
* stopky.

Časovač je UI a aplikační služba, ale jeho výsledky se ukládají do session domény.

Při přechodu aplikace na pozadí musí čas vycházet ze skutečných časových okamžiků, ne pouze z aktivního lokálního odpočtu.

---

# 52. Osobní rekordy

WorkoutSession může vytvořit kandidáta na PersonalRecord.

Příklady:

* nejvyšší váha,
* nejvíce opakování,
* nejlepší čas,
* nejdelší vzdálenost,
* nejvyšší objem.

Rekord musí mít:

* definovanou metriku,
* srovnatelný kontext,
* jednotku,
* zdroj,
* případné ověření.

Systém nesmí porovnávat nesrovnatelné varianty cviku bez jasného pravidla.

---

# 53. Progrese workoutu

## 53.1 Zdroj

Progrese může být definována:

* šablonou,
* plánem,
* sportovním modulem,
* AI návrhem,
* uživatelem.

## 53.2 Vstupy

* skutečný výkon,
* RPE nebo RIR,
* dokončení,
* bolest,
* únava,
* počet předchozích úspěšných session,
* fáze plánu.

## 53.3 Výstupy

* zvýšit váhu,
* zvýšit opakování,
* přidat sérii,
* těžší variantu,
* prodloužit interval,
* snížit pauzu,
* zachovat,
* snížit zátěž.

## 53.4 Bezpečnost

Progrese nesmí být založena pouze na tom, že uběhl další týden.

---

# 54. Workout a aktivní omezení

Před otevřením nebo spuštěním workoutu systém musí zkontrolovat:

* aktivní Limitation,
* aktuální PainReport,
* dočasně nedostupné vybavení,
* změnu prostředí,
* případný nový konflikt.

Výsledek:

* workout beze změny,
* upozornění,
* doporučená adaptace,
* blokace rizikového kroku,
* potřeba dalšího vstupu.

---

# 55. Validace workoutu

Workout musí projít validací před:

* aktivací,
* naplánováním,
* aplikací AI změny,
* spuštěním, pokud se změnila omezení.

## 55.1 Příklady kontrol

* dostupné vybavení,
* platné jednotky,
* existující cviky,
* smysluplné pořadí,
* žádné záporné hodnoty,
* časová proveditelnost,
* kompatibilita s omezeními,
* nepřekročení tvrdých pravidel,
* validní alternativy.

---

# 56. Workout Validation Result

Obsahuje:

* validní ano/ne,
* chyby,
* varování,
* doporučení,
* blokující problémy,
* možnosti automatické opravy.

AI nesmí aplikovat nevalidní workout.

---

# 57. Offline model

## 57.1 Lokální dostupnost

Zařízení musí mít uložené:

* WorkoutInstance snapshot,
* potřebné instrukce,
* cviky,
* předpisy,
* alternativy v rozumném rozsahu,
* aktivní omezení relevantní pro workout,
* poslední výkon, pokud je zobrazován.

## 57.2 Lokální identifikátory

WorkoutSession a její výkony musí mít identifikátory vytvořitelné offline.

## 57.3 Synchronizace

Každá změna se ukládá jako idempotentní SyncOperation nebo OfflineCommand.

## 57.4 Konflikt

Při konfliktu:

* skutečný výkon se nesmí zahodit,
* serverová změna plánu se nesmí slepě přepsat lokální session,
* uživatel musí dostat srozumitelné řešení.

---

# 58. Konflikt změny během aktivní session

Příklad:

* uživatel cvičí offline,
* na jiném zařízení se workout změní.

Pravidlo:

* aktivní session pokračuje podle revize, se kterou začala,
* nová plánová revize se neaplikuje doprostřed session bez potvrzení,
* po synchronizaci se zachová skutečné provedení,
* systém označí odlišnost oproti aktuálnímu plánu.

---

# 59. Editace dokončeného workoutu

## 59.1 Důvod

Uživatel může potřebovat opravit:

* opakování,
* váhu,
* čas,
* poznámku,
* omylem vynechaný cvik.

## 59.2 Pravidla

* změna musí být auditovaná,
* původní hodnota musí být dohledatelná,
* musí se aktualizovat Activity a metriky,
* plánovaná data se nesmí přepsat,
* importovaná data musí zachovat původ.

## 59.3 Omezení

Některé systémově nebo externě podepsané údaje mohou být opravovány pouze jako uživatelská korekce, nikoliv přepsání původního záznamu.

---

# 60. Mazání workout dat

## 60.1 Plánovaný workout bez historie

Může být zrušen nebo archivován.

## 60.2 Dokončený workout

Nemá být běžně fyzicky smazán.

Uživatel může:

* opravit,
* označit jako chybný,
* skrýt z běžných statistik,
* požádat o odstranění v rámci ochrany dat.

## 60.3 Zahozená session

Technicky chybná nedokončená session může být zahozena po potvrzení, pokud na ni nenavazuje významná historie.

---

# 61. Doménové události workout oblasti

Minimálně:

* WorkoutTemplateCreated
* WorkoutTemplateVersionCreated
* WorkoutInstanceCreated
* WorkoutInstanceModified
* WorkoutInstanceReady
* WorkoutInstanceRescheduled
* WorkoutInstanceShortened
* WorkoutInstanceLightened
* WorkoutExerciseReplaced
* WorkoutSessionStarted
* WorkoutSessionPaused
* WorkoutSessionResumed
* WorkoutSessionPartiallyCompleted
* WorkoutSessionCompleted
* WorkoutSessionAborted
* SetPerformanceRecorded
* WorkoutIssueReported
* WorkoutFeedbackRecorded
* ActivityCreatedFromWorkout
* WorkoutProgressionProposed
* WorkoutProgressionApplied
* WorkoutCorrectionApplied

---

# 62. Příkazy workout oblasti

Minimálně:

* CreateWorkoutTemplate
* CreateWorkoutTemplateVersion
* CreateWorkoutInstance
* UpdateWorkoutInstance
* RescheduleWorkoutInstance
* ShortenWorkoutInstance
* LightenWorkoutInstance
* ReplaceWorkoutExercise
* StartWorkoutSession
* PauseWorkoutSession
* ResumeWorkoutSession
* RecordSetPerformance
* RecordStepPerformance
* AddSetPerformance
* ReportWorkoutIssue
* CompleteWorkoutSession
* PartiallyCompleteWorkoutSession
* AbortWorkoutSession
* RecordWorkoutFeedback
* CorrectWorkoutPerformance
* DiscardWorkoutSession

---

# 63. Invariance workout modelu

## 63.1 Vlastnictví

* Každá uživatelská instance a session patří právě jednomu uživateli.
* Session nesmí být spojena s workoutem jiného uživatele.

## 63.2 Šablona a instance

* Změna šablony nesmí zpětně změnit historickou instanci.
* Instance musí mít stabilní snapshot.
* Session musí znát revizi instance, podle které začala.

## 63.3 Plán versus skutečnost

* SetPerformance nesmí přepsat SetPlan.
* Dokončená session nesmí být změněna na plánovanou.
* Úprava skutečného výkonu musí být auditovaná.

## 63.4 Stav

* Nelze dokončit session, která nebyla zahájena, s výjimkou rychlého ručního záznamu podle zvláštního flow.
* Dokončená session nesmí být znovu aktivována bez vytvoření nové opravné nebo pokračovací session.
* Zrušený workout nelze běžně spustit bez obnovení nebo kopie.

## 63.5 Hodnoty

* Počet opakování nesmí být záporný.
* Délka a vzdálenost nesmí být záporná.
* Jednotky musí odpovídat typu metriky.
* Povinný krok musí mít definovaný způsob dokončení.

## 63.6 AI

* AI náhrada cviku musí projít validací.
* AI nesmí změnit aktivní session bez uživatelského vědomí.
* Zastaralý AI návrh workoutu se nesmí automaticky aplikovat.

## 63.7 Offline

* Opakovaná synchronizace stejného výkonu nesmí vytvořit duplicitní sérii.
* Konflikt nesmí odstranit lokální workout data bez explicitního rozhodnutí.

---

# 64. Read modely workout oblasti

## 64.1 WorkoutCardView

Obsahuje:

* název,
* čas,
* délku,
* typ,
* stav,
* hlavní akci.

## 64.2 WorkoutDetailView

Obsahuje:

* účel,
* sekce,
* kroky,
* vybavení,
* omezení,
* vazbu na cíle,
* změny.

## 64.3 ActiveWorkoutView

Optimalizovaný pro tracker:

* aktuální krok,
* předpis,
* skutečné hodnoty,
* časovače,
* postup,
* lokální stav.

## 64.4 WorkoutSummaryView

Obsahuje:

* plán versus skutečnost,
* výkony,
* trvání,
* feedback,
* rekordy.

## 64.5 ExerciseHistoryView

Obsahuje:

* předchozí výkony,
* varianty,
* trendy,
* poznámky.

## 64.6 WorkoutModificationPreview

Obsahuje:

* původní a nový workout,
* odstraněné a změněné části,
* důvod,
* dopad.

---

# 65. Příklad – domácí silový workout

## WorkoutTemplate

**Název:** Upper Body A
**Typ:** STRENGTH
**Účel:** Rozvoj tahové a tlakové síly horní části těla.

## Sekce 1 – Warm-up

* kroužení ramen,
* scapular push-ups,
* lehké visy.

## Sekce 2 – Main strength

* shyby,
* kliky,
* přítahy pod stolem nebo na kruzích.

## Sekce 3 – Accessory

* pike push-ups,
* dead bug,
* side plank.

## Předpis

Shyby:

* 4 série,
* 4–8 opakování,
* RIR 2,
* pauza 120 sekund.

## Kratší alternativa

* 3 hlavní cviky,
* 2–3 série,
* bez accessory sekce.

---

# 66. Příklad – ranní mobilita

## Typ

MOBILITY / MICRO_WORKOUT

## Délka

15 minut.

## Sekce

* kotníky,
* kyčle,
* hrudní páteř,
* ramena.

## Kroky

* knee-to-wall,
* 90/90 transitions,
* thoracic rotations,
* shoulder CARs.

Každý krok obsahuje:

* čas nebo opakování,
* stranu,
* instrukci,
* intenzitu.

---

# 67. Příklad – intervalový běh

## Typ

INTERVAL

## Sekce

1. Warm-up
2. Running drills
3. Interval block
4. Cooldown

## Interval block

* 6 opakování,
* 2 minuty rychle,
* 2 minuty lehce,
* cílová intenzita RPE 8.

## Skutečné provedení

Každý interval může obsahovat:

* délku,
* vzdálenost,
* tempo,
* tep,
* subjektivní pocit.

---

# 68. Příklad – florbalový trénink

## Typ

SPORT_SESSION

## Struktura

Nemusí obsahovat detailní cviky.

Obsahuje:

* čas,
* očekávanou délku,
* intenzitu,
* pevnou událost,
* hlavní sport,
* případnou poznámku.

Po dokončení uživatel zadá:

* skutečnou délku,
* intenzitu,
* pocit,
* případnou bolest.

---

# 69. Příklad – lezecký den

## Typ

OPEN_ACTIVITY_BLOCK

## Obsah

* prostředí: skály,
* očekávaná délka: 5 hodin,
* intenzita: střední až vysoká,
* charakter: sportovní lezení,
* hlavní zatížení: prsty, předloktí, tahová síla, ramena.

Tracker může být jednoduchý.

Detailnější lezecký deník může vzniknout později jako specializovaný modul.

---

# 70. Příklad – adaptace kvůli bicepsu

## Původní workout

* shyby,
* přítahy,
* kliky,
* bicepsové doplňky.

## Aktivní vstup

* pravý biceps bolí při tahu.

## Možný návrh

* odstranit shyby a přítahy,
* odstranit přímý biceps,
* ponechat nebolestivé tlakové a core cviky,
* snížit celkový objem,
* označit workout jako PAIN_ADAPTED.

Systém nesmí tvrdit, že jde o konkrétní diagnózu.

---

# 71. Univerzální sportovní rozšiřitelnost

Nový sportovní modul může přidat:

* nové WorkoutStep typy,
* nové Prescription typy,
* nové metriky,
* specializovaný tracker,
* sportovní pravidla,
* specifické alternativy.

Musí však používat společné:

* WorkoutTemplate,
* WorkoutInstance,
* WorkoutSession,
* Activity,
* ChangeSet,
* synchronizaci,
* audit.

---

# 72. Co nesmí být pouze jako volný text

Následující informace musí být strukturované:

* typ workoutu,
* plánovaná délka,
* sekce,
* pořadí kroků,
* cvik,
* série,
* opakování,
* čas,
* vzdálenost,
* vybavení,
* stav dokončení,
* náhrada cviku,
* skutečný výkon,
* důvod změny,
* bolest nebo problém ovlivňující workout.

Volný text může být doplněk, ne jediný zdroj.

---

# 73. Otevřené otázky

* Jak přesně implementovat typově bezpečné WorkoutStep varianty v databázi?
* Použít relační tabulky, JSON strukturu, nebo kombinaci?
* Jak hluboké vnoření composite kroků povolit?
* Má být WorkoutTemplateVersion kompletní snapshot?
* Jak přesně verzovat ExerciseDefinition?
* Jak ukládat média a jejich offline varianty?
* Jak pracovat s hlasovým zadáváním během workoutu?
* Jak řešit automatický přechod mezi intervaly na pozadí?
* Jak přesně určit hlavní session při více spuštěních stejného workoutu?
* Kdy vytvořit Activity při částečném workoutu?
* Jak reprezentovat workout, který trvá přes půlnoc?
* Jak řešit změnu časového pásma aktivní session?
* Jak agregovat objem mezi různými variantami cviků?
* Jak porovnávat osobní rekordy u jednostranných cviků?
* Jak funguje editace importovaného workoutu?
* Které alternativy musí být dostupné offline?
* Jak dlouho uchovávat detailní průběžné autosave záznamy?
* Jak přesně pracovat s workoutem provedeným současně na hodinkách a telefonu?

---

# 74. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── activity-model.md
├── scheduling-model.md
├── recovery-and-limitations-model.md
├── sports-and-goals-model.md
├── ai-and-change-model.md
├── metrics-model.md
└── sync-and-offline-model.md
```

Později také:

```text
docs/08-mobile/
├── mobile-architecture.md
├── workout-tracker-architecture.md
├── local-database.md
└── background-execution.md
```

A:

```text
docs/07-backend/
├── workout-service.md
├── workout-api.md
└── persistence-model.md
```

---

# 75. Kritéria správného workout modelu

Model je vhodný pouze tehdy, pokud umožní:

1. vytvořit opakovatelnou šablonu,
2. vytvořit konkrétní instanci,
3. upravit pouze jednu instanci,
4. zachovat historickou verzi,
5. spustit workout offline,
6. průběžně ukládat výkon,
7. pokračovat po pádu aplikace,
8. dokončit workout částečně,
9. oddělit plán a skutečnost,
10. podporovat série a opakování,
11. podporovat čas a vzdálenost,
12. podporovat intervaly,
13. podporovat mobilitu,
14. podporovat týmový sport bez detailních cviků,
15. podporovat vlastní aktivitu,
16. zkrátit workout podle účelu,
17. zlehčit workout,
18. nahradit cvik,
19. reagovat na bolest,
20. reagovat na chybějící vybavení,
21. vytvořit historickou Activity,
22. navrhnout progresi,
23. synchronizovat více zařízení,
24. zachovat workout data při konfliktu,
25. přidávat nové sportovní typy bez přepsání základu.

---

# 76. Závěr

Workout model AI Traineru musí podporovat celý životní cyklus tréninkové jednotky:

```text
WorkoutTemplate
    ↓
WorkoutTemplateVersion
    ↓
WorkoutInstance
    ↓
WorkoutInstanceRevision
    ↓
WorkoutSession
    ↓
StepPerformance / SetPerformance
    ↓
WorkoutFeedback
    ↓
Activity
    ↓
Progression nebo adaptace dalšího workoutu
```

Nejdůležitější je zachovat rozdíl mezi:

* obecnou šablonou,
* konkrétním plánem na určitý den,
* skutečným průběhem,
* historickou aktivitou.

Díky tomu může uživatel říct:

> Dnes mám jen patnáct minut.

nebo:

> Bolí mě biceps, uprav shyby.

A systém dokáže vytvořit konkrétní, bezpečnou a vratnou změnu workoutu, aniž by poškodil šablonu, dlouhodobý plán nebo historická data.
