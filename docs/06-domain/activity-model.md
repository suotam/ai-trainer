# AI Trainer – Activity Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/activity-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model skutečně provedených sportovních aktivit v aplikaci AI Trainer.

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
* `docs/06-domain/sports-and-goals-model.md`.

Dokument popisuje:

* význam aktivity v doménovém modelu,
* rozdíl mezi plánovanou událostí a skutečností,
* vznik aktivity z workout trackeru,
* ručně zadané aktivity,
* importované aktivity,
* budoucí GPS tracking,
* zdroje dat,
* párování aktivity s plánem,
* náhradní aktivity,
* částečné splnění plánu,
* duplicity,
* slučování dat,
* metriky,
* sportovní a anatomickou zátěž,
* kvalitu a důvěryhodnost dat,
* editace a opravy,
* offline režim,
* synchronizaci,
* audit a historii,
* rozšiřitelnost pro libovolné sporty.

Dokument zatím neurčuje:

* přesné databázové tabulky,
* konkrétní API endpointy,
* konkrétní implementaci Apple Health nebo Health Connect,
* finální algoritmus detekce duplicit,
* finální algoritmus sportovní zátěže,
* konkrétní mapový nebo GPS formát,
* konkrétní UI detailu aktivity.

---

# 2. Definice aktivity

`Activity` reprezentuje skutečně provedenou sportovní nebo pohybovou činnost uživatele.

Aktivita odpovídá na otázku:

> Co uživatel skutečně udělal?

Může vzniknout:

* dokončením strukturovaného workoutu,
* ručním zápisem,
* potvrzením týmového tréninku,
* potvrzením zápasu nebo závodu,
* importem z wearables,
* importem ze sportovní služby,
* GPS záznamem přímo v aplikaci,
* spojením více souvisejících zdrojů.

Activity není:

* plán,
* workout šablona,
* plánovaná kalendářní událost,
* samotná AI zpráva,
* agregovaná statistika,
* nezpracovaný externí záznam.

Activity je historická skutečnost používaná pro:

* progres,
* regeneraci,
* vyhodnocení plánu,
* plnění cílů,
* týdenní revize,
* adaptaci budoucích workoutů,
* osobní rekordy,
* statistiky.

---

# 3. Základní rozlišení plán versus skutečnost

Systém musí oddělovat minimálně čtyři pojmy:

1. `ScheduleEvent`
2. `WorkoutInstance`
3. `WorkoutSession`
4. `Activity`

## 3.1 ScheduleEvent

Popisuje, kdy má něco proběhnout.

Příklad:

> Fotbalový trénink ve středu v 19:00.

## 3.2 WorkoutInstance

Popisuje konkrétní plánovaný obsah strukturovaného workoutu.

Příklad:

> Upper Body A se čtyřmi sériemi shybů a kliků.

## 3.3 WorkoutSession

Popisuje průběh provádění workoutu v trackeru.

Příklad:

> Workout začal v 18:12, uživatel dokončil tři série a jeden cvik nahradil.

## 3.4 Activity

Popisuje historickou skutečnost.

Příklad:

> Silový trénink horní poloviny těla, skutečná délka 38 minut, subjektivní intenzita 7 z 10.

Základní vztah může vypadat takto:

```text
ScheduleEvent
    ↓
WorkoutInstance
    ↓
WorkoutSession
    ↓
Activity
```

Ne každá Activity však musí mít všechny předchozí objekty.

Například ručně zapsaná turistika může vzniknout bez ScheduleEvent i WorkoutInstance.

---

# 4. Hlavní principy activity modelu

## 4.1 Skutečnost nesmí přepsat plán

Pokud se aktivita liší od plánu, systém zachová:

* původně plánovanou hodnotu,
* skutečně provedenou hodnotu,
* důvod rozdílu, pokud je znám,
* dopad na další plánování.

## 4.2 Původ dat musí být dohledatelný

Každá aktivita musí uvádět:

* odkud vznikla,
* zda byla importovaná,
* zda ji uživatel upravil,
* zda byla sloučena z více zdrojů,
* jaká je kvalita dat.

## 4.3 Duplicitní záznamy se nesmí započítat vícekrát

Stejná aktivita může přijít například:

* z hodinek do Apple Health,
* z Apple Health do aplikace,
* současně přímo z Garmin integrace.

Model musí umožnit duplicitu rozpoznat a spravovat.

## 4.4 Aktivita musí podporovat obecné i sportovně specifické údaje

Společný základ obsahuje například:

* čas,
* délku,
* sport,
* intenzitu,
* zdroj.

Sportovní moduly mohou přidávat:

* tempo,
* vzdálenost,
* výkon,
* převýšení,
* série,
* lezeckou obtížnost,
* GPS trasu,
* další metriky.

## 4.5 Importovaná data nejsou automaticky pravdivější než uživatelský vstup

Wearable může:

* chybně rozpoznat sport,
* nepřesně změřit spánek nebo tep,
* vytvořit duplicitní aktivitu,
* nesprávně určit začátek a konec.

Systém musí zachovat zdroj a nejistotu.

## 4.6 Historické aktivity se běžně nemažou změnou plánu

Nová verze plánu nesmí odstranit skutečně provedené aktivity.

---

# 5. Hlavní objekty activity oblasti

Activity oblast obsahuje minimálně:

* Activity,
* ActivityRevision,
* ActivitySource,
* ActivitySourceRecord,
* ActivityMetric,
* ActivityMetricSeries,
* ActivitySegment,
* ActivityLap,
* ActivityRoute,
* ActivityLocationPoint,
* ActivityLoad,
* ActivityBodyLoad,
* ActivityMatch,
* ActivityDuplicateGroup,
* ActivityMerge,
* ActivityCorrection,
* ActivityFeedback,
* ActivityAttachment,
* ActivityTag,
* ActivitySummary.

Ne všechny objekty musí být součástí první implementace.

Model však musí umožnit jejich postupné doplnění.

---

# 6. Activity

## 6.1 Význam

Activity je hlavní doménový objekt historické sportovní činnosti.

## 6.2 Základní vlastnosti

Activity obsahuje zejména:

* identifikátor,
* uživatele,
* název,
* sport nebo vlastní sport,
* typ aktivity,
* stav,
* skutečný začátek,
* skutečný konec,
* délku,
* časové pásmo,
* zdroj,
* primární zdroj dat,
* vztah k plánované události,
* vztah k workout session,
* intenzitu,
* subjektivní hodnocení,
* metriky,
* zátěž,
* synchronizační stav,
* datum vytvoření,
* datum poslední opravy.

## 6.3 Aktivita bez přesného času

U ručního historického zápisu nemusí uživatel znát přesný čas.

Musí být možné uložit:

* pouze datum,
* přibližnou část dne,
* odhadovanou délku,
* označení nejistoty.

## 6.4 Aktivita přes půlnoc

Activity může začít jeden den a skončit další den.

Příklady:

* noční horský výstup,
* ultramaraton,
* vícedenní výprava.

Délka se nesmí odvozovat pouze z lokálních časů bez časového pásma.

---

# 7. ActivityStatus

Minimální stavy:

* DRAFT,
* RECORDING,
* PROCESSING,
* COMPLETED,
* PARTIALLY_RECORDED,
* CORRECTED,
* MERGED,
* DUPLICATE,
* INVALID,
* DELETED,
* ARCHIVED.

## 7.1 DRAFT

Ručně vytvořený záznam, který ještě není dokončený.

## 7.2 RECORDING

Aktivita je právě zaznamenávána.

Používá se například při GPS trackeru.

## 7.3 PROCESSING

Aktivita čeká na:

* výpočet metrik,
* import,
* normalizaci,
* kontrolu duplicity,
* zpracování trasy.

## 7.4 COMPLETED

Aktivita je platným historickým záznamem.

## 7.5 PARTIALLY_RECORDED

Část dat chybí.

Například:

* výpadek GPS,
* nedokončená synchronizace,
* ruční záznam bez přesného času.

## 7.6 CORRECTED

Aktivita byla uživatelem nebo systémem opravena.

## 7.7 MERGED

Aktivita byla sloučena do jiného hlavního záznamu.

## 7.8 DUPLICATE

Aktivita je označena jako duplicitní a nemá se započítávat do statistik.

## 7.9 INVALID

Záznam není použitelný.

Příklad:

* nulová aktivita vytvořená chybou zařízení.

---

# 8. ActivityType

ActivityType popisuje obecný charakter skutečné aktivity.

Minimálně:

* STRUCTURED_WORKOUT,
* SPORT_TRAINING,
* MATCH,
* COMPETITION,
* ENDURANCE_ACTIVITY,
* STRENGTH_ACTIVITY,
* MOBILITY_ACTIVITY,
* RECOVERY_ACTIVITY,
* GENERAL_ACTIVITY,
* OUTDOOR_ACTIVITY,
* GPS_ACTIVITY,
* CUSTOM.

ActivityType nenahrazuje konkrétní sport.

Příklad:

* sport: florbal,
* ActivityType: MATCH.

Nebo:

* sport: běh,
* ActivityType: ENDURANCE_ACTIVITY.

---

# 9. ActivitySource

## 9.1 Význam

Určuje, jakým způsobem Activity vznikla.

## 9.2 Základní zdroje

* WORKOUT_SESSION,
* MANUAL_ENTRY,
* QUICK_CONFIRMATION,
* INTERNAL_GPS,
* APPLE_HEALTH,
* HEALTH_CONNECT,
* GARMIN,
* STRAVA,
* POLAR,
* COROS,
* SUUNTO,
* FITBIT,
* EXTERNAL_IMPORT,
* SYSTEM_MERGE.

## 9.3 Primární a vedlejší zdroj

Aktivita může mít více zdrojových záznamů.

Například:

* primární čas a trasa z Garminu,
* uživatelská poznámka z aplikace,
* plánované spojení z WorkoutInstance.

Activity má jeden primární zdroj, ale zachovává všechny příspěvky.

---

# 10. ActivitySourceRecord

## 10.1 Význam

Reprezentuje jeden konkrétní zdrojový záznam, ze kterého Activity vznikla.

## 10.2 Vlastnosti

* poskytovatel,
* externí identifikátor,
* interní identifikátor importu,
* čas vytvoření,
* čas poslední změny,
* původní typ aktivity,
* původní data nebo bezpečný odkaz,
* stav zpracování,
* hash obsahu,
* verzi,
* kvalitu,
* prioritu zdroje.

## 10.3 Důvod oddělení

Jedna Activity může být sestavena z více ActivitySourceRecord.

Tím se zabrání tomu, aby interní model byl závislý na jednom poskytovateli.

---

# 11. DataProvenance

Každá důležitá hodnota musí mít dohledatelný původ.

Příklad:

| Hodnota       | Zdroj                           |
| ------------- | ------------------------------- |
| Čas aktivity  | Garmin                          |
| Název         | Uživatel                        |
| Sport         | Uživatel opravil původní import |
| Průměrný tep  | Garmin hrudní pás               |
| RPE           | Uživatel                        |
| Vazba na plán | ActivityMatchingService         |

DataProvenance musí umožnit zjistit:

* původní zdroj,
* případnou uživatelskou opravu,
* automatické odvození,
* datum změny,
* důvěryhodnost.

---

# 12. Activity vytvořená z WorkoutSession

## 12.1 Proces

Po dokončení WorkoutSession:

1. uzavře se session,
2. uloží se skutečné StepPerformance a SetPerformance,
3. vytvoří se Activity,
4. Activity získá souhrnné metriky,
5. připojí se k WorkoutInstance a ScheduleEvent,
6. aktualizuje se stav plánované položky,
7. vyvolají se události pro progres a revizi.

## 12.2 Obsah Activity

Activity nemusí kopírovat všechny série.

Detail zůstává ve WorkoutSession.

Activity obsahuje například:

* název,
* sport,
* typ,
* začátek,
* konec,
* délku,
* intenzitu,
* celkový objem,
* hlavní výkony,
* feedback,
* vazbu na session.

## 12.3 Jedna session a jedna aktivita

Výchozí vztah:

```text
WorkoutSession 1 ─── 1 Activity
```

Model může později podporovat výjimky:

* jedna dlouhá session rozdělená na více sportů,
* několik částí sloučených do jedné aktivity.

---

# 13. Ručně vytvořená aktivita

## 13.1 Použití

Uživatel může zpětně zadat:

* týmový trénink,
* túru,
* běh,
* lezení,
* posilování,
* vlastní sport,
* aktivitu, kterou zařízení nezaznamenalo.

## 13.2 Povinné minimum

* datum,
* název nebo sport,
* přibližná délka nebo časový interval,
* základní intenzita.

## 13.3 Volitelné údaje

* přesný čas,
* vzdálenost,
* poznámka,
* RPE,
* zatížené oblasti,
* vazba na plán,
* metriky,
* místo.

## 13.4 Označení přesnosti

Ručně zadaná data mohou mít přesnost:

* EXACT,
* ESTIMATED,
* UNKNOWN.

---

# 14. QuickConfirmation

## 14.1 Význam

Zjednodušené potvrzení pevné sportovní události.

Příklad:

> Proběhl dnešní florbalový trénink?

Uživatel zadá:

* ano,
* délku,
* intenzitu,
* případnou bolest,
* poznámku.

## 14.2 Výsledek

Vznikne Activity propojená se ScheduleEvent.

Není nutné vytvářet detailní WorkoutSession.

## 14.3 Použití

Vhodné pro:

* týmové sporty,
* lekce,
* zápasy,
* volné sportovní aktivity.

---

# 15. Importovaná aktivita

## 15.1 Proces importu

1. externí poskytovatel poskytne záznam,
2. vznikne ExternalDataRecord nebo ActivitySourceRecord,
3. data se validují,
4. převedou se do interních jednotek,
5. systém hledá duplicitu,
6. systém hledá plánovanou událost,
7. vznikne nová Activity nebo aktualizace existující,
8. zachová se původ dat.

## 15.2 Import nesmí automaticky měnit plán

Importovaná Activity může spustit návrh změny.

Nemá však bez validace a oprávnění:

* rušit budoucí workouty,
* měnit cíle,
* přepisovat plán.

## 15.3 Pozdní import

Aktivita může přijít až po několika hodinách nebo dnech.

Systém musí být schopen:

* zpětně ji spárovat,
* přepočítat pokrok,
* aktualizovat týdenní revizi,
* zabránit duplicitě.

---

# 16. GPS aktivita

## 16.1 Budoucí použití

Interní GPS tracker může podporovat:

* běh,
* chůzi,
* turistiku,
* cyklistiku,
* další venkovní sporty.

## 16.2 Vznik

Během záznamu:

* Activity má stav RECORDING,
* ukládají se segmenty a body,
* data se průběžně ukládají lokálně,
* po ukončení se aktivita zpracuje.

## 16.3 GPS data

Mohou obsahovat:

* zeměpisnou šířku,
* zeměpisnou délku,
* nadmořskou výšku,
* čas,
* přesnost,
* rychlost,
* směr,
* zdroj polohy.

## 16.4 Soukromí

GPS trasa je citlivý údaj.

Musí být možné:

* trasu neukládat,
* trasu odstranit a ponechat souhrn,
* skrýt začátek a konec,
* exportovat ji samostatně,
* omezit její používání AI.

---

# 17. ActivityRoute

## 17.1 Význam

Reprezentuje trasu venkovní aktivity.

## 17.2 Obsah

* začátek,
* konec,
* délku,
* převýšení,
* sestup,
* geografický bounding box,
* polyline nebo jinou optimalizovanou reprezentaci,
* odkaz na detailní body,
* kvalitu trasy,
* zdroj.

## 17.3 Trasa není povinná

Activity může obsahovat:

* vzdálenost a čas,
* ale žádnou uloženou trasu.

---

# 18. ActivityLocationPoint

## 18.1 Obsah

* timestamp,
* latitude,
* longitude,
* altitude,
* accuracy,
* speed,
* bearing,
* source.

## 18.2 Množství dat

Body mohou být velmi objemné.

Nemusí být ukládány ve stejné tabulce nebo službě jako Activity.

## 18.3 Zpracování

Lze je:

* komprimovat,
* zjednodušit,
* archivovat,
* agregovat,
* odstranit při zachování souhrnu.

---

# 19. ActivitySegment

## 19.1 Význam

Logická část aktivity.

Příklady:

* warm-up,
* intervalový blok,
* cooldown,
* první a druhý poločas,
* stoupání,
* sjezd,
* jednotlivé sporty v multisportovní aktivitě.

## 19.2 Obsah

* začátek,
* konec,
* typ,
* pořadí,
* metriky,
* intenzitu,
* poznámku.

## 19.3 Použití

Segmenty jsou obecnější než běžecká kola.

---

# 20. ActivityLap

## 20.1 Význam

Opakovaný nebo uživatelsky označený úsek.

Příklady:

* kilometr,
* běžecké kolo,
* interval,
* okruh,
* automatické kolo z hodinek.

## 20.2 Obsah

* pořadí,
* začátek,
* konec,
* délku,
* vzdálenost,
* tempo,
* tep,
* výkon,
* zdroj.

---

# 21. ActivityMetric

## 21.1 Význam

Jedna agregovaná hodnota spojená s aktivitou.

## 21.2 Příklady

* vzdálenost,
* průměrné tempo,
* maximální tempo,
* průměrný tep,
* maximální tep,
* převýšení,
* energetický výdej,
* počet kroků,
* tréninkový objem,
* počet sérií,
* počet opakování,
* subjektivní RPE,
* obtížnost lezení.

## 21.3 Vlastnosti

* MetricDefinition,
* hodnota,
* jednotka,
* zdroj,
* časový rozsah,
* kvalita,
* jistota,
* stav opravy.

## 21.4 Více zdrojů stejné metriky

Například průměrný tep může být dostupný:

* z hodinek,
* z hrudního pásu.

Systém musí znát prioritu nebo umožnit výběr.

---

# 22. ActivityMetricSeries

## 22.1 Význam

Časová řada hodnot během aktivity.

Příklady:

* tep,
* rychlost,
* výkon,
* kadence,
* nadmořská výška.

## 22.2 Obsah

* MetricDefinition,
* body v čase,
* vzorkovací frekvence,
* jednotku,
* zdroj,
* kvalitu,
* případné mezery.

## 22.3 Uložení

Časové řady mohou být uloženy odděleně od hlavního Activity agregátu.

---

# 23. ActivityFeedback

## 23.1 Význam

Subjektivní hodnocení skutečné aktivity.

## 23.2 Pole

* RPE,
* pocit před aktivitou,
* pocit po aktivitě,
* energie,
* zábavnost,
* bolest,
* technický pocit,
* spokojenost,
* poznámka.

## 23.3 Využití

* readiness,
* plánovací adaptace,
* týdenní revize,
* sportovní preference,
* vyhodnocení cílů.

---

# 24. ActivityLoad

## 24.1 Význam

Normalizovaný odhad zatížení způsobeného aktivitou.

Nemá představovat absolutní zdravotní pravdu.

## 24.2 Složky

Může obsahovat:

* overallLoad,
* aerobicLoad,
* anaerobicLoad,
* strengthLoad,
* powerLoad,
* speedLoad,
* impactLoad,
* gripLoad,
* contactLoad,
* mobilityLoad,
* technicalLoad.

## 24.3 Zdroje výpočtu

* délka,
* intenzita,
* tep,
* výkon,
* sport,
* RPE,
* série,
* vzdálenost,
* capability profil sportu,
* uživatelská úroveň.

## 24.4 Jistota

Každý ActivityLoad musí mít:

* confidence,
* method,
* input completeness,
* calculation version.

## 24.5 Více metod

Systém může mít různé metody podle dostupných dat.

Například:

* pouze délka a RPE,
* tepová data,
* výkonová data,
* silový objem,
* sportovní obecný odhad.

Výsledky nesmí být bez vysvětlení považovány za totožně přesné.

---

# 25. ActivityBodyLoad

## 25.1 Význam

Odhad zatížení konkrétních částí těla.

## 25.2 Obsah

* BodyArea,
* typ zatížení,
* relativní úroveň,
* stranu,
* jistotu,
* zdroj.

## 25.3 Příklad

Lezecká aktivita:

* prsty: HIGH,
* předloktí: HIGH,
* lokty: MODERATE,
* ramena: MODERATE.

## 25.4 Použití

* plánování dalších workoutů,
* kontrola aktivních omezení,
* souhrnná lokální zátěž,
* náhrada cviků.

---

# 26. ActivityMatch

## 26.1 Význam

Reprezentuje vztah mezi skutečnou Activity a plánovaným objektem.

Může spojovat Activity s:

* ScheduleEvent,
* WorkoutInstance,
* plánovanou sportovní událostí,
* cílem,
* workout session.

## 26.2 Typy shody

* EXACT,
* PROBABLE,
* PARTIAL,
* REPLACEMENT,
* RELATED,
* UNRELATED,
* REJECTED.

## 26.3 EXACT

Skutečnost odpovídá plánované aktivitě.

Příklad:

* naplánovaný běh 8 km,
* importovaný běh 8,1 km ve stejný čas.

## 26.4 PROBABLE

Shoda je pravděpodobná, ale není jistá.

## 26.5 PARTIAL

Aktivita splnila jen část účelu.

## 26.6 REPLACEMENT

Jiná aktivita nahradila plánovanou.

Příklad:

* místo běhu proběhl fotbal.

## 26.7 RELATED

Aktivita souvisí s plánem, ale není jeho splněním.

Příklad:

* navíc provedená procházka.

---

# 27. ActivityMatchConfidence

Shoda musí mít jistotu:

* HIGH,
* MEDIUM,
* LOW,
* USER_CONFIRMED,
* USER_REJECTED.

Jistota může vycházet z:

* času,
* sportu,
* délky,
* názvu,
* externího identifikátoru,
* workout session,
* uživatelského potvrzení.

---

# 28. Automatické párování s plánem

## 28.1 Vstupy

ActivityMatchingService může použít:

* časovou blízkost,
* překryv intervalů,
* sport,
* typ aktivity,
* délku,
* vzdálenost,
* zdroj,
* plánované metriky,
* vazbu z trackeru,
* název.

## 28.2 Bezpečné chování

Při nízké jistotě systém nesmí shodu definitivně provést bez uživatele.

Může nabídnout:

> Odpovídá tento běh plánovanému workoutu z úterý?

## 28.3 Změna shody

Uživatel může:

* potvrdit,
* odmítnout,
* propojit s jinou událostí,
* označit jako neplánovanou aktivitu.

---

# 29. Náhradní aktivita

## 29.1 Příklad

Plán:

* 40 minut lehkého běhu.

Skutečnost:

* 90 minut florbalu.

## 29.2 Vyhodnocení

ActivityMatch typu REPLACEMENT může obsahovat:

* míru nahrazení,
* nahrazený účel,
* nenahrazený účel,
* dodatečnou zátěž,
* dopad na další plán.

## 29.3 Výsledek

Systém může určit:

* původní workout není nutné nahrazovat,
* vytrvalostní stimul byl částečně splněn,
* lokální zatížení nohou bylo vyšší,
* další silový workout nohou je vhodné upravit.

---

# 30. Částečné splnění workoutu

WorkoutSession může být PARTIALLY_COMPLETED.

ActivityMatch vůči WorkoutInstance může obsahovat:

* completionRatio,
* completedPurpose,
* missingPurpose,
* důvod,
* doporučení.

Procento samo o sobě nestačí.

Příklad:

Uživatel provedl hlavní silovou část, ale vynechal accessory cviky.

Z pohledu účelu mohl workout splnit z větší části.

---

# 31. Neplánovaná aktivita

Neplánovaná Activity není automaticky problém.

Může jít o:

* spontánní sport,
* chůzi,
* turistiku,
* další trénink,
* aktivní dopravu,
* sportovní výlet.

Systém musí posoudit její dopad na:

* zátěž,
* regeneraci,
* plánované workouty,
* cíle.

Nemá uživatele trestat za aktivitu mimo plán.

---

# 32. ActivityDuplicateGroup

## 32.1 Význam

Skupina záznamů, které pravděpodobně reprezentují stejnou skutečnou aktivitu.

## 32.2 Příklad

* Garmin aktivita,
* stejná aktivita importovaná přes Apple Health,
* ruční potvrzení v aplikaci.

## 32.3 Obsah

* kandidátní Activity nebo source records,
* míru podobnosti,
* důvod podezření,
* doporučený hlavní záznam,
* stav řešení.

## 32.4 Stav

* DETECTED,
* AUTO_RESOLVED,
* USER_REVIEW_REQUIRED,
* MERGED,
* MARKED_DISTINCT,
* IGNORED.

---

# 33. Detekce duplicity

Může vycházet z:

* externího identifikátoru,
* poskytovatele,
* času začátku,
* času konce,
* sportu,
* vzdálenosti,
* trasy,
* délky,
* názvu,
* zařízení,
* hashů dat.

Přesná pravidla musí být sportovně a zdrojově citlivá.

Dvě aktivity ve stejný čas nemusí být duplicita.

Příklad:

* silový workout zaznamenaný hodinkami,
* současně workout session v aplikaci.

Tyto zdroje mohou být vhodné ke sloučení.

---

# 34. ActivityMerge

## 34.1 Význam

Proces sloučení více záznamů do jedné hlavní Activity.

## 34.2 Výsledek

* určí se hlavní Activity,
* zachovají se všechny ActivitySourceRecord,
* vyberou se nejlepší hodnoty,
* uloží se původ každé hodnoty,
* duplicitní Activity se označí jako MERGED nebo DUPLICATE.

## 34.3 Výběr dat

Příklad:

* název z WorkoutSession,
* tep z Garminu,
* GPS trasa z hodinek,
* RPE od uživatele,
* plánová vazba z interního kalendáře.

## 34.4 Vratnost

Sloučení by mělo být vratné, pokud není technicky nebo právně nutné jinak.

---

# 35. Pravidla priority zdrojů

Priority nesmí být globálně pevné pro všechny metriky.

Příklad:

## Tep

* hrudní pás může mít vyšší prioritu než optické hodinky.

## Název aktivity

* uživatelský název může mít vyšší prioritu než automatický název.

## Plánová vazba

* přímá vazba z WorkoutSession má vyšší jistotu než časová shoda.

## Sport

* uživatelská oprava má přednost před automatickou klasifikací.

Priority musí být definovatelné podle:

* typu metriky,
* poskytovatele,
* zařízení,
* kvality,
* uživatelské opravy.

---

# 36. ActivityCorrection

## 36.1 Význam

Auditovaná oprava historické aktivity.

## 36.2 Příklady

* změna sportu,
* oprava času,
* oprava délky,
* změna vzdálenosti,
* doplnění RPE,
* oprava vazby na plán,
* odstranění chybné metriky.

## 36.3 Obsah

* původní hodnota,
* nová hodnota,
* důvod,
* zdroj opravy,
* čas,
* uživatel nebo systém,
* dopad na statistiky.

## 36.4 Původní externí data

Uživatelská oprava nemá nevratně přepsat původní zdrojový záznam.

Interní Activity může používat opravenou hodnotu, ale provenance zůstává zachovaná.

---

# 37. ActivityRevision

## 37.1 Význam

Neměnný historický stav Activity.

## 37.2 Vzniká při

* významné ruční opravě,
* sloučení,
* změně sportu,
* změně časového rozsahu,
* změně hlavního zdroje,
* odstranění duplicitní metriky.

## 37.3 Ne každá změna potřebuje plnou revizi

Například přidání běžného tagu může být řešeno jednodušší auditní operací.

---

# 38. ActivityTag

## 38.1 Význam

Pomocné uživatelské nebo systémové označení.

Příklady:

* lehký trénink,
* závod,
* skály,
* návrat po pauze,
* test,
* nemoc,
* osobní rekord.

## 38.2 Omezení

Tag nesmí nahrazovat strukturovaný sport, stav nebo typ aktivity.

---

# 39. ActivityAttachment

## 39.1 Budoucí použití

Může obsahovat:

* fotografii,
* video,
* GPX soubor,
* dokument,
* externí výsledek závodu.

## 39.2 Vlastnosti

* typ,
* úložiště,
* vlastnictví,
* soukromí,
* velikost,
* čas,
* stav zpracování.

## 39.3 Bezpečnost

Přílohy mohou obsahovat citlivá data a musí mít samostatná přístupová pravidla.

---

# 40. ActivitySummary

## 40.1 Význam

Odvozený souhrn aktivity určený pro rychlé zobrazení.

## 40.2 Obsah

Podle sportu například:

* název,
* datum,
* délku,
* vzdálenost,
* intenzitu,
* hlavní výkon,
* sport,
* stav shody s plánem.

## 40.3 Není zdroj pravdy

ActivitySummary je read model.

---

# 41. Sportovně specifické aktivity

## 41.1 Silový trénink

Může zobrazovat:

* délku,
* počet cviků,
* počet sérií,
* celkový objem,
* hlavní výkony,
* RPE.

Detailní data zůstávají ve WorkoutSession.

## 41.2 Běh

Může obsahovat:

* vzdálenost,
* čas,
* tempo,
* převýšení,
* tep,
* trasu,
* intervaly.

## 41.3 Cyklistika

Může obsahovat:

* vzdálenost,
* čas,
* rychlost,
* výkon,
* kadenci,
* převýšení,
* trasu.

## 41.4 Lezení

V základní verzi může obsahovat:

* typ lezení,
* délku session,
* intenzitu,
* prostředí,
* hlavní zatížení,
* subjektivní hodnocení.

Specializovaný lezecký modul může později přidat:

* obtížnost,
* cesty,
* pokusy,
* styl přelezu.

## 41.5 Týmový sport

Může obsahovat:

* trénink nebo zápas,
* délku,
* intenzitu,
* pozici v budoucnu,
* subjektivní zátěž,
* případný výsledek.

## 41.6 Mobilita

Může obsahovat:

* délku,
* oblasti,
* typ mobility,
* subjektivní rozsah,
* intenzitu.

## 41.7 Vlastní sport

Musí podporovat minimálně:

* vlastní název,
* délku,
* intenzitu,
* capability profil,
* zatížené části těla,
* poznámku.

---

# 42. Multisportovní aktivita

## 42.1 Příklady

* triatlon,
* horský výlet s chůzí a lezením,
* kombinace běhu a posilování,
* vícedenní sportovní výprava.

## 42.2 Model

Možnosti:

* jedna Activity s více ActivitySegment,
* EventGroup nebo ActivityGroup s více Activity,
* kombinace.

## 42.3 Doporučení

Pokud mají části:

* výrazně odlišné sporty,
* odlišné metriky,
* samostatný význam,

je vhodné vytvořit ActivityGroup s několika Activity.

Pokud jde o jeden souvislý multisportovní výkon, lze použít jednu Activity se segmenty.

---

# 43. ActivityGroup

## 43.1 Význam

Skupina souvisejících aktivit.

## 43.2 Příklady

* triatlonový závod,
* lezecký víkend,
* sportovní kemp,
* dvoufázový trénink,
* horský přechod.

## 43.3 Obsah

* název,
* období,
* typ,
* dílčí aktivity,
* sportovní kontext,
* celkovou zátěž,
* vazbu na EventGroup.

---

# 44. Intenzita aktivity

Intenzita může být zaznamenána různými způsoby:

* subjektivní RPE,
* tepová zóna,
* tempo,
* výkon,
* závodní charakter,
* lehká/střední/těžká,
* procento maxima.

Model musí zachovat typ intenzity.

Nemá převádět všechny vstupy do jednoho čísla bez znalosti metody a nejistoty.

---

# 45. Subjektivní RPE

## 45.1 Použití

RPE může být praktická univerzální metrika pro sporty bez detailních dat.

## 45.2 Obsah

* škála,
* hodnota,
* čas zadání,
* kontext,
* poznámka.

## 45.3 Konzistence škály

Aplikace musí používat jasně definovanou škálu.

Například:

* 1 až 10.

Nemá směšovat odlišné škály bez převodu.

---

# 46. Energetický výdej

Kalorie nebo energetický výdej mohou být importované nebo odhadované.

Musí obsahovat:

* zdroj,
* metodu,
* jednotku,
* kvalitu,
* jistotu.

Aplikace nesmí prezentovat odhad jako přesnou hodnotu.

---

# 47. Časové metriky

Musí se rozlišovat:

* elapsedTime,
* activeTime,
* movingTime,
* pausedTime,
* plannedDuration.

Příklad:

Turistika mohla trvat šest hodin, ale movingTime byl čtyři a půl hodiny.

---

# 48. Vzdálenost

Vzdálenost může pocházet:

* z GPS,
* ze senzoru,
* z běžeckého pásu,
* z ručního vstupu,
* z externí služby.

Musí mít:

* jednotku,
* zdroj,
* přesnost,
* případnou opravu.

---

# 49. Nadmořská výška a převýšení

Musí se rozlišovat:

* altitude,
* elevationGain,
* elevationLoss,
* minimumAltitude,
* maximumAltitude.

Zdroj může být:

* GPS,
* barometr,
* mapový přepočet,
* externí služba.

Tyto zdroje mohou dávat odlišné výsledky.

---

# 50. Tepová data

Mohou obsahovat:

* průměrný tep,
* maximální tep,
* minimální tep,
* čas v zónách,
* časovou řadu,
* zdroj senzoru.

Systém musí rozlišit:

* měřené údaje,
* odhad,
* chybějící části,
* nereálné hodnoty.

---

# 51. Výkon a kadence

U podporovaných sportů mohou být uloženy:

* průměrný výkon,
* normalizovaný výkon podle budoucí metodiky,
* maximální výkon,
* kadence,
* časové řady.

Výpočet odvozených metrik musí být verzovaný a vysvětlitelný.

---

# 52. Aktivita a cíle

Activity může přispívat k jednomu nebo více cílům.

Vztah může obsahovat:

* typ příspěvku,
* míru relevance,
* metriku,
* zda šlo o plánovaný příspěvek,
* vyhodnocení GoalProgressService.

Příklad:

Lezecká session může podporovat:

* výkonnostní lezecký cíl,
* návykový cíl pravidelnosti,
* vytrvalostní cíl předloktí.

---

# 53. Aktivita a TrainingPlan

Activity může mít vazbu na:

* TrainingPlan,
* TrainingPlanVersion,
* TrainingBlock,
* TrainingWeek.

Musí být jasné, zda aktivita:

* byla plánovaná,
* nahradila plánovanou,
* byla navíc,
* proběhla mimo aktivní plán.

---

# 54. Aktivita a regenerace

Activity může ovlivnit:

* DailyCheckIn interpretaci,
* ReadinessAssessment,
* budoucí plánování,
* doporučený odpočinek,
* lokální zátěž.

Activity sama však nemá přímo rozhodovat o změně plánu.

Spouští vyhodnocení v příslušné službě.

---

# 55. Aktivita a bolest

Pokud uživatel během nebo po aktivitě nahlásí bolest:

* vznikne WorkoutIssue nebo PainReport,
* Activity odkazuje na tento záznam,
* bolest není uložena pouze jako textová poznámka,
* budoucí plánování může vytvořit adaptaci.

---

# 56. ActivityDataQuality

## 56.1 Význam

Popisuje kvalitu a úplnost aktivity.

## 56.2 Dimenze

* completeness,
* timingAccuracy,
* metricAccuracy,
* sportClassificationConfidence,
* routeQuality,
* sourceReliability,
* userConfirmation.

## 56.3 Úrovně

* HIGH,
* MEDIUM,
* LOW,
* UNKNOWN.

## 56.4 Příklad

Ručně zapsaná turistika:

* vysoká jistota sportu,
* střední jistota délky,
* neznámá vzdálenost,
* bez GPS.

---

# 57. ActivityProcessingStatus

Importované nebo GPS aktivity mohou procházet zpracováním:

* RECEIVED,
* VALIDATING,
* NORMALIZING,
* DUPLICATE_CHECK,
* MATCHING,
* METRIC_CALCULATION,
* READY,
* FAILED,
* NEEDS_REVIEW.

Uživatel nemusí vidět všechny technické stavy.

---

# 58. ActivityValidation

Před zařazením do historie se může kontrolovat:

* platný čas,
* nezáporná délka,
* platný sport,
* realistická vzdálenost,
* jednotky,
* vlastnictví,
* duplicita,
* konzistence zdrojů,
* GPS kvalita.

## 58.1 Výsledek

* VALID,
* VALID_WITH_WARNINGS,
* INVALID,
* USER_REVIEW_REQUIRED.

---

# 59. Extrémní nebo nereálná data

Příklady:

* běh 200 km za 20 minut,
* tep 400 bpm,
* záporná vzdálenost,
* aktivita v budoucnosti bez plánovaného záznamu.

Systém musí:

* data označit,
* nezapočítat je bez kontroly,
* zachovat původní záznam,
* nabídnout opravu.

---

# 60. Oprava sportovní klasifikace

Příklad:

Hodinky označí florbal jako běh.

Uživatel změní sport na florbal.

Systém musí:

* zachovat původní klasifikaci zdroje,
* používat opravený sport interně,
* případně přepočítat sportovní zátěž,
* aktualizovat statistiky.

---

# 61. Odstranění aktivity

## 61.1 Běžné odstranění

U historické Activity se preferuje:

* označení jako INVALID,
* soft delete,
* vyloučení ze statistik.

## 61.2 Fyzické smazání

Používá se například:

* při smazání účtu,
* u omylem vytvořeného konceptu,
* na základě právního požadavku.

## 61.3 Aktivita propojená s plánem

Odstranění Activity nesmí automaticky odstranit původní ScheduleEvent nebo WorkoutInstance.

Plánovaná položka může znovu přejít do stavu:

* bez skutečné aktivity,
* vyžaduje kontrolu.

---

# 62. Archivace detailních dat

Po dlouhé době může systém:

* ponechat Activity a souhrn,
* archivovat detailní GPS body,
* archivovat vysokofrekvenční tep,
* ponechat agregované metriky.

Musí být definováno:

* co se archivuje,
* co se odstraní,
* jak to ovlivní export,
* jak se zachová provenance.

---

# 63. Offline vytvoření aktivity

Offline musí být možné:

* dokončit WorkoutSession,
* vytvořit Activity,
* ručně přidat aktivitu,
* doplnit feedback,
* opravit základní hodnoty.

Activity získá:

* lokálně vytvořitelný identifikátor,
* stav čekající synchronizace,
* OfflineCommand,
* lokální revizi.

---

# 64. Offline GPS záznam

Budoucí GPS tracker musí fungovat bez internetu.

Musí:

* ukládat body lokálně,
* průběžně checkpointovat,
* obnovit záznam po pádu,
* fungovat na pozadí podle oprávnění platformy,
* vytvořit Activity bez mapového připojení.

Mapové podklady nemusí být offline dostupné, pokud nebudou staženy.

---

# 65. Synchronizace aktivit

Synchronizace musí být idempotentní.

Opakované odeslání stejné Activity nebo stejného zdrojového záznamu nesmí vytvořit duplicitu.

Musí být možné synchronizovat:

* Activity,
* ActivityRevision,
* metriky,
* feedback,
* trasu,
* vazbu na plán,
* opravy.

---

# 66. Konflikt editace aktivity

Příklad:

* uživatel offline změní sport,
* na jiném zařízení změní název.

Tyto změny mohou být slučitelné.

Příklad neslučitelného konfliktu:

* na jednom zařízení je aktivita označena jako duplicitní,
* na druhém je připojena k jinému workoutu.

Systém musí:

* sloučit nekolidující pole,
* zachovat obě verze při konfliktu,
* neztratit skutečná data,
* nabídnout srozumitelnou volbu.

---

# 67. Konflikt importu a ručního záznamu

Uživatel ručně zadá běh.

Později přijde stejný běh z hodinek.

Systém má:

* detekovat pravděpodobnou duplicitu,
* nabídnout sloučení,
* zachovat uživatelskou poznámku,
* doplnit GPS a tep,
* nevytvořit dvě započítané aktivity.

---

# 68. Idempotence importu

Každý externí zdrojový záznam musí mít:

* provider,
* externalId,
* případně verzi nebo hash.

Opakovaný import stejného záznamu:

* aktualizuje existující ActivitySourceRecord,
* nevytváří novou Activity,
* spustí přepočet jen při změně dat.

---

# 69. Import smazané externí aktivity

Pokud poskytovatel aktivitu smaže, interní systém musí znát politiku:

* odstranit pouze vazbu,
* označit externí zdroj jako smazaný,
* zachovat Activity, pokud ji uživatel upravil nebo propojil,
* požádat uživatele o rozhodnutí.

Nemá automaticky zničit interní historii.

---

# 70. ActivityPrivacy

Activity může mít vlastní nastavení soukromí.

I když první verze nemá sociální síť, může být relevantní:

* pro export,
* sdílení,
* AI zpracování,
* přesnou lokaci,
* zdravotní údaje.

Možné příznaky:

* allowAiProcessing,
* includeRouteInExport,
* retainDetailedSensorData,
* sensitiveLocation.

---

# 71. Analytika produktu versus sportovní data

Produktová analytika nesmí automaticky obsahovat:

* GPS trasu,
* přesné časy pohybu,
* detailní tep,
* poznámku,
* bolest,
* název soukromé aktivity.

Může obsahovat technické události:

* activity_created,
* activity_imported,
* activity_merged,
* activity_corrected,
* duplicate_detected.

---

# 72. Doménové služby activity oblasti

## 72.1 ActivityCreationService

Vytváří Activity z:

* WorkoutSession,
* ručního vstupu,
* quick confirmation,
* GPS záznamu.

## 72.2 ActivityImportService

Zajišťuje:

* přijetí externích záznamů,
* validaci,
* normalizaci,
* převod jednotek,
* vytvoření ActivitySourceRecord.

## 72.3 ActivityMatchingService

Spojuje Activity s:

* ScheduleEvent,
* WorkoutInstance,
* plánem.

## 72.4 DuplicateDetectionService

Vyhledává možné duplicity.

## 72.5 ActivityMergeService

Bezpečně slučuje zdroje.

## 72.6 ActivityLoadService

Počítá sportovní a anatomickou zátěž.

## 72.7 ActivityCorrectionService

Provádí auditované opravy.

## 72.8 ActivityMetricService

Normalizuje a agreguje metriky.

---

# 73. Doménové události

Minimálně:

* ActivityDraftCreated
* ActivityRecordingStarted
* ActivityRecordingPaused
* ActivityRecordingResumed
* ActivityRecordingCompleted
* ActivityCreatedFromWorkout
* ActivityCreatedManually
* ActivityImported
* ActivityValidated
* ActivityProcessingFailed
* ActivityMatchedToScheduleEvent
* ActivityMatchedToWorkout
* ActivityMatchRejected
* ActivityMarkedAsReplacement
* ActivityDuplicateDetected
* ActivitiesMerged
* ActivityCorrected
* ActivityInvalidated
* ActivityDeleted
* ActivityFeedbackRecorded
* ActivityLoadCalculated
* ActivityMetricsUpdated
* ActivityRouteProcessed
* ActivityLinkedToGoal
* ActivityUnlinkedFromGoal

---

# 74. Příkazy

Minimálně:

* CreateManualActivity
* ConfirmScheduledActivity
* StartGpsActivity
* PauseGpsActivity
* ResumeGpsActivity
* CompleteGpsActivity
* ImportActivitySourceRecord
* ValidateActivity
* MatchActivityToScheduleEvent
* MatchActivityToWorkout
* RejectActivityMatch
* MarkActivityAsReplacement
* DetectActivityDuplicates
* MergeActivities
* SeparateMergedActivities
* CorrectActivity
* AddActivityFeedback
* AddActivityMetric
* RemoveActivityMetric
* InvalidateActivity
* RestoreActivity
* DeleteActivity
* RecalculateActivityLoad

---

# 75. Invariance activity modelu

## 75.1 Vlastnictví

* Každá Activity patří právě jednomu uživateli.
* Activity nesmí být propojena s workoutem jiného uživatele.
* Zdrojové záznamy musí patřit stejnému uživateli jako Activity.

## 75.2 Čas

* Konec nesmí být před začátkem.
* Délka nesmí být záporná.
* Přesný čas musí mít platné časové pásmo nebo UTC okamžik.
* Aktivita bez přesného času musí být označena jako odhadovaná.

## 75.3 Zdroj

* Activity musí mít alespoň jeden zdroj.
* Každá převzatá hodnota musí mít dohledatelný původ.
* Uživatelská oprava nesmí vymazat původní externí hodnotu bez auditu.

## 75.4 Duplicity

* DUPLICATE Activity se nesmí započítávat do agregovaných statistik.
* Sloučení nesmí ztratit zdrojové záznamy.
* Opakovaný import nesmí vytvořit novou aktivitu.

## 75.5 Plán versus skutečnost

* Activity nesmí přepsat ScheduleEvent.
* Zrušení plánu nesmí odstranit Activity.
* Změna ActivityMatch nesmí změnit skutečná data aktivity.
* Plánované a skutečné časy musí být oddělené.

## 75.6 Metriky

* Hodnota musí odpovídat MetricDefinition.
* Jednotka musí být platná.
* Agregovaná metrika musí uvádět zdroj nebo metodu.
* Odhad nesmí být vydáván za měřenou hodnotu.

## 75.7 GPS

* Trasa musí patřit stejné Activity.
* Body musí být chronologicky zpracovatelné.
* Odstranění trasy nesmí nutně odstranit celou Activity.

## 75.8 AI

* AI nesmí vytvořit fiktivní historickou Activity bez uživatelského nebo datového podkladu.
* AI může navrhnout opravu nebo párování, ale významná změna musí být validována.
* AI nesmí označit neznámou aktivitu za dokončený workout pouze na základě podobného názvu.

---

# 76. Read modely

## 76.1 ActivityCardView

Obsahuje:

* název,
* sport,
* datum,
* délku,
* hlavní metriku,
* zdroj,
* stav shody s plánem.

## 76.2 ActivityDetailView

Obsahuje:

* základní údaje,
* metriky,
* segmenty,
* trasu,
* feedback,
* plánovou vazbu,
* zdroje,
* opravy.

## 76.3 ActivityHistoryView

Obsahuje:

* seznam aktivit,
* filtry,
* souhrny,
* stav synchronizace.

## 76.4 ActivityMatchReviewView

Obsahuje:

* Activity,
* kandidátní plánovanou událost,
* důvody shody,
* jistotu,
* akce potvrdit nebo odmítnout.

## 76.5 ActivityDuplicateReviewView

Obsahuje:

* kandidátní záznamy,
* porovnání zdrojů,
* doporučené sloučení,
* hodnoty, které budou použity.

## 76.6 ActivityLoadSummaryView

Obsahuje:

* celkovou zátěž,
* hlavní typy zátěže,
* anatomické oblasti,
* jistotu.

---

# 77. Příklad – dokončený domácí workout

## Plán

WorkoutInstance:

* Upper Body A,
* 40 minut,
* čtyři hlavní cviky.

## Skutečnost

WorkoutSession:

* 36 minut,
* tři série shybů místo čtyř,
* kliky splněny,
* accessory cvik vynechán,
* RPE 8.

## Activity

* sport: silový trénink,
* typ: STRUCTURED_WORKOUT,
* délka: 36 minut,
* zdroj: WORKOUT_SESSION,
* vazba: EXACT nebo PARTIAL podle účelu,
* strengthLoad: střední až vysoká.

---

# 78. Příklad – florbalový trénink

## ScheduleEvent

* středa 19:00,
* florbal,
* pevná událost.

## QuickConfirmation

Uživatel zadá:

* proběhl,
* 90 minut,
* RPE 8,
* těžké nohy,
* bez bolesti.

## Activity

* sport: florbal,
* typ: SPORT_TRAINING,
* vazba na ScheduleEvent: EXACT,
* impactLoad: HIGH,
* lowerBodyLoad: HIGH.

---

# 79. Příklad – běh importovaný dvakrát

## Zdroje

* Garmin,
* Apple Health.

Oba záznamy:

* začátek 08:01,
* délka 52 minut,
* vzdálenost přibližně 10 km.

## DuplicateDetection

Systém vytvoří ActivityDuplicateGroup.

## Merge

Hlavní Activity:

* GPS z Garminu,
* tep z hrudního pásu,
* synchronizační zdroj z obou záznamů,
* jedna započítaná aktivita.

---

# 80. Příklad – ruční aktivita následně doplněná hodinkami

Uživatel ručně zapíše:

* běh 45 minut,
* RPE 6.

Později se importuje:

* běh 44:32,
* 8,2 km,
* GPS,
* tep.

Systém nabídne sloučení.

Po sloučení:

* přesný čas, vzdálenost a tep z hodinek,
* RPE a poznámka od uživatele,
* původ obou zdrojů zachován.

---

# 81. Příklad – náhradní aktivita

## Plán

* lehký běh 30 minut.

## Skutečnost

* dvě hodiny lezení.

## Vyhodnocení

ActivityMatch:

* typ REPLACEMENT,
* běžecký účel nenahrazen,
* obecná aktivita splněna,
* vyšší tahová a úchopová zátěž,
* návrh upravit další workout horní části těla.

---

# 82. Příklad – neznámý sport

Uživatel ručně zadá:

* aerial hoop,
* 75 minut,
* RPE 8,
* vysoké zatížení ramen, úchopu a core.

Activity používá:

* vlastní UserSport,
* obecné metriky,
* ActivityBodyLoad,
* capability profil.

Není nutný specializovaný tracker.

---

# 83. Příklad – chybná aktivita z hodinek

Import:

* běh 18 hodin,
* 3 km,
* průměrný tep 240.

ActivityValidation:

* USER_REVIEW_REQUIRED.

Uživatel může:

* opravit,
* označit jako chybnou,
* sloučit s jinou aktivitou,
* ignorovat.

Do potvrzení se nemá započítat do pokroku ani zátěže.

---

# 84. Příklad – aktivita s výpadkem GPS

Běh:

* první 4 km mají trasu,
* další část GPS chybí,
* celková délka je známa z footpodu.

Activity:

* PARTIALLY_RECORDED,
* vzdálenost může mít střední až vysokou jistotu,
* trasa nízkou úplnost,
* uživatel vidí, že mapa není kompletní.

---

# 85. Co musí být strukturované

Nesmí zůstat pouze jako volný text:

* sport,
* typ aktivity,
* datum,
* čas,
* délka,
* zdroj,
* stav,
* vazba na plán,
* vazba na workout,
* intenzita,
* metriky,
* duplicita,
* sloučení,
* oprava,
* zátěž,
* kvalita dat,
* synchronizační stav.

Volný text může doplňovat:

* poznámku,
* subjektivní popis,
* vlastní název,
* popis průběhu.

---

# 86. Otevřené otázky

* Má být Activity samostatný agregát oddělený od WorkoutSession?
* Má vzniknout Activity vždy i u částečně dokončené session?
* Jak přesně modelovat ActivityGroup?
* Jaké metriky ukládat přímo a jaké odvozovat?
* Jaký storage použít pro vysokofrekvenční časové řady?
* Jak dlouho uchovávat detailní GPS body?
* Jak přesně funguje odstranění trasy při zachování souhrnu?
* Jaká pravidla priority zdrojů použít pro jednotlivé metriky?
* Jak řešit dvě současně zaznamenané odlišné aktivity?
* Jaký algoritmus použít pro detekci duplicit?
* Jaká hranice jistoty umožní automatické sloučení?
* Jak reprezentovat uživatelskou opravu externích dat?
* Jak řešit aktivitu později změněnou poskytovatelem?
* Jak řešit smazání externího zdroje?
* Jak párovat týmový trénink bez přesného času?
* Jak přesně vyhodnotit částečnou náhradu workoutu?
* Jak vytvořit ActivityLoad bez falešné přesnosti?
* Jak verzovat výpočet zátěže?
* Jak srovnávat zátěž různých sportů?
* Jak zobrazit uživateli nejistotu jednoduše?
* Jak řešit aktivity provedené před registrací a importované zpětně?
* Jaká historická data importovat při připojení integrace?
* Jak zabránit opakovanému přepočtu celé historie?
* Jak synchronizovat rozpracovanou GPS aktivitu mezi zařízeními?
* Jak řešit aktivitu zaznamenávanou současně telefonem a hodinkami?
* Jaké Activity údaje budou dostupné AI?
* Jak anonymizovat trasu pro analytické nebo diagnostické účely?
* Jak řešit více uživatelských úprav stejné metriky?
* Jak se bude historická oprava promítat do starých týdenních revizí?

---

# 87. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── domain-events.md
└── domain-invariants.md
```

Dále:

```text
docs/07-backend/
├── activity-service.md
├── activity-api.md
├── activity-import-pipeline.md
├── duplicate-detection.md
├── activity-matching.md
└── time-series-storage.md
```

A:

```text
docs/08-mobile/
├── activity-history.md
├── manual-activity-entry.md
├── gps-tracking-architecture.md
├── background-location.md
└── offline-activity-storage.md
```

---

# 88. Kritéria správného activity modelu

Model je vhodný pouze tehdy, pokud umožní:

1. vytvořit Activity z workout trackeru,
2. ručně zapsat aktivitu,
3. potvrdit týmový trénink,
4. importovat aktivitu z wearables,
5. zachovat původ dat,
6. spojit více zdrojů,
7. detekovat duplicity,
8. sloučit duplicitní záznamy,
9. párovat aktivitu s plánem,
10. odmítnout chybné párování,
11. označit náhradní aktivitu,
12. zachovat plán a skutečnost odděleně,
13. podporovat obecný sport,
14. podporovat sportovní metriky,
15. podporovat GPS trasu,
16. pracovat s chybějícími daty,
17. komunikovat nejistotu,
18. opravit historický záznam,
19. zachovat původní externí hodnoty,
20. vypočítat zátěž s uvedenou jistotou,
21. fungovat offline,
22. synchronizovat více zařízení,
23. zabránit duplicitnímu importu,
24. zachovat aktivity po změně plánu,
25. exportovat uživatelská data,
26. odstranit detailní trasu bez odstranění celé aktivity,
27. pracovat s aktivitami mimo plán,
28. zohlednit skutečnou aktivitu v dalších doporučeních.

---

# 89. Závěr

Activity model reprezentuje skutečnou sportovní historii uživatele.

Jeho základní tok je:

```text
ScheduleEvent / WorkoutInstance
              ↓
       WorkoutSession
              ↓
           Activity
              ↓
  ActivityMetric / ActivityLoad
              ↓
 ActivityMatch / Goal Progress
              ↓
 Recovery, review a adaptace plánu
```

Současně musí podporovat i tok bez předchozího plánu:

```text
Ruční vstup / Wearable / GPS
              ↓
     ActivitySourceRecord
              ↓
      Validace a duplicity
              ↓
           Activity
              ↓
   Párování s plánem a cíli
```

Nejdůležitější je zachovat rozdíl mezi:

* tím, co bylo naplánováno,
* tím, co bylo skutečně provedeno,
* tím, odkud informace pochází,
* tím, jak jisté údaje jsou,
* tím, jak aktivita ovlivní další plánování.

Díky tomu může uživatel:

* dokončit workout v trackeru,
* ručně doplnit florbal,
* importovat běh z hodinek,
* spojit duplicitní záznamy,
* nahradit plánovaný běh lezením,
* opravit chybný sport,

aniž by aplikace ztratila původní plán, historickou skutečnost nebo původ jednotlivých dat.
