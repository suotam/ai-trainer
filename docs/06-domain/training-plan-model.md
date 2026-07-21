# AI Trainer – Training Plan Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/training-plan-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje doménový model tréninkového plánování v aplikaci AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/information-architecture.md`,
* `docs/06-domain/domain-overview.md`.

Dokument popisuje:

* význam tréninkového plánu,
* vztah plánu k cílům a sportům,
* strukturu plánovacích období,
* verze plánu,
* bloky,
* týdny,
* plánovací pravidla,
* omezení,
* workout instance,
* pevné sportovní události,
* adaptace plánu,
* potvrzování změn,
* historii,
* vratnost,
* podporu více sportů,
* chování při výpadku AI,
* základní invariance.

Dokument zatím neurčuje:

* konkrétní databázové tabulky,
* API endpointy,
* přesné JSON kontrakty,
* konkrétní Kotlin nebo Dart implementaci,
* finální plánovací algoritmus,
* finální AI prompty.

---

# 2. Definice tréninkového plánu

Tréninkový plán je dlouhodobý strukturovaný záměr, který převádí cíle, sporty, dostupnost, omezení a preference uživatele do konkrétních plánovaných aktivit.

Tréninkový plán není:

* pouze seznam workoutů,
* statické PDF,
* text v AI konverzaci,
* kalendářní pohled,
* historie dokončených aktivit,
* jedna šablona opakující se každý týden.

Tréninkový plán je živý a verzovaný doménový objekt.

Určuje:

* proč uživatel trénuje,
* které cíle jsou prioritní,
* jaké sporty se musí vzájemně koordinovat,
* jaké období plán pokrývá,
* jaké tréninkové bloky obsahuje,
* jaké aktivity mají být provedeny,
* jaká pravidla se při plánování uplatňují,
* kdy a proč se plán může změnit,
* jak se změny vysvětlují a potvrzují.

---

# 3. Hlavní principy plánovacího modelu

## 3.1 Jeden uživatel má jeden propojený sportovní systém

Uživatel může mít:

* více sportů,
* více cílů,
* více pravidelných aktivit,
* více workoutů v jednom dni,
* více plánovacích období.

Systém je však musí vyhodnocovat společně.

Nesmí vzniknout několik izolovaných plánů, které nevědí jeden o druhém.

Například:

* běžecký plán musí vědět o florbalu,
* silový plán musí vědět o lezení,
* mobilitní plán musí vědět o zápase,
* příprava na závod musí vědět o pracovním cestování.

## 3.2 Plán a kalendář nejsou totéž

Plán popisuje dlouhodobou strategii.

Kalendář zobrazuje konkrétní časově umístěné události.

Z plánu mohou vznikat kalendářní události, ale kalendář může obsahovat také položky mimo plán:

* ručně přidanou aktivitu,
* týmový trénink,
* závod,
* jednorázový výlet,
* pracovní omezení,
* regenerační den.

## 3.3 Plán a skutečnost jsou oddělené

Plán stanovuje očekávané aktivity.

Skutečnost je reprezentována dokončenými aktivitami a workout sessions.

Pokud uživatel provede jinou aktivitu, systém musí zachovat:

* původní plán,
* změnu,
* skutečně provedenou aktivitu,
* dopad na další plánování.

## 3.4 Plán je verzovaný

Každá významná změna musí být dohledatelná.

Původní verze se nesmí přepsat.

## 3.5 AI plán pouze navrhuje

AI může vytvořit:

* návrh plánu,
* návrh nové verze,
* návrh úpravy týdne,
* návrh změny workoutu.

Aktivní plán však vzniká až po:

* validaci,
* kontrole oprávnění,
* případném uživatelském potvrzení,
* uložení do doménového modelu.

## 3.6 Plán musí fungovat bez AI

Základní plánovací objekty musí být:

* čitelné,
* upravitelné,
* spustitelné,
* synchronizovatelné,

i při nedostupnosti AI služby.

---

# 4. Hlavní objekty plánovací oblasti

Plánovací oblast obsahuje minimálně:

* TrainingPlan,
* TrainingPlanVersion,
* TrainingBlock,
* TrainingWeek,
* PlannedDay,
* PlanningConstraint,
* PlanningRule,
* PlanGoalLink,
* PlanSportLink,
* PlanEventReference,
* WorkoutInstance,
* ScheduleEvent,
* ChangeSet,
* PlanReview.

---

# 5. TrainingPlan

## 5.1 Význam

TrainingPlan je hlavní dlouhodobý objekt plánování.

Reprezentuje jednu souvislou strategii pro konkrétní období.

## 5.2 Základní vlastnosti

TrainingPlan obsahuje zejména:

* identifikátor,
* vlastníka,
* název,
* popis,
* stav,
* datum začátku,
* plánované datum konce,
* skutečné datum konce,
* aktivní verzi,
* hlavní účel,
* vytvořeno kým,
* datum vytvoření,
* datum poslední významné změny,
* míru automatizace,
* zdroj vzniku.

## 5.3 Zdroj vzniku

Plán může vzniknout:

* ručně,
* pomocí deterministického plánovacího enginu,
* návrhem AI,
* kopírováním staršího plánu,
* adaptací existujícího plánu,
* importem schváleného externího plánu v budoucnu.

## 5.4 Stav plánu

Minimální stavy:

* DRAFT,
* PENDING_CONFIRMATION,
* ACTIVE,
* PAUSED,
* COMPLETED,
* REPLACED,
* CANCELLED,
* ARCHIVED.

### DRAFT

Plán je koncept.

Nemá plný dopad na aktivní kalendář.

### PENDING_CONFIRMATION

Plán je připraven k aktivaci, ale čeká na potvrzení.

### ACTIVE

Plán je aktuálně používán pro plánování.

### PAUSED

Plán je dočasně pozastaven.

### COMPLETED

Plán dosáhl svého plánovaného nebo ručně ukončeného konce.

### REPLACED

Plán byl nahrazen novým plánem.

### CANCELLED

Plán byl ukončen předčasně bez náhrady.

### ARCHIVED

Plán zůstává dostupný pouze jako historie.

## 5.5 Invariance TrainingPlan

* Aktivní plán musí mít aktivní verzi.
* Aktivní plán musí mít alespoň jeden účel nebo vazbu na cíl.
* Datum začátku nesmí být po plánovaném datu konce.
* Dokončené aktivity se při ukončení plánu nemažou.
* Nahrazený plán musí odkazovat na nový plán, pokud existuje.
* Aktivace plánu musí být auditovaná.

---

# 6. Více plánů jednoho uživatele

Uživatel může mít více plánů, ale jejich role musí být jasná.

## 6.1 Primární integrovaný plán

Výchozí model počítá s jedním hlavním aktivním integrovaným plánem, který koordinuje všechny sporty a cíle.

## 6.2 Doplňkové plány

Do budoucna mohou existovat specializované podplány, například:

* rehabilitační plán od odborníka,
* závodní plán,
* klubový plán,
* specializovaný technický plán.

Tyto plány však nesmí nezávisle zapisovat workouty bez koordinace s hlavním plánovacím systémem.

## 6.3 Konflikt více aktivních plánů

Pokud existuje více plánů:

* musí být určena priorita,
* musí být znám vlastník rozhodování,
* konflikty musí být validovány,
* uživatel musí vidět společný kalendář.

## 6.4 První verze

První verze produktu má podporovat:

* jeden hlavní aktivní plán,
* libovolný počet konceptů,
* archivované a dokončené plány.

---

# 7. TrainingPlanVersion

## 7.1 Význam

TrainingPlanVersion je neměnný snímek struktury plánu v určitém okamžiku.

Umožňuje:

* historii,
* porovnání,
* audit,
* návrat,
* vysvětlení změn.

## 7.2 Obsah

TrainingPlanVersion obsahuje:

* identifikátor,
* číslo nebo pořadí verze,
* vazbu na TrainingPlan,
* vazbu na předchozí verzi,
* čas vytvoření,
* důvod vytvoření,
* zdroj změny,
* autora nebo systém,
* stav schválení,
* strukturu bloků,
* hlavní pravidla,
* souhrn změn,
* referenční kontext.

## 7.3 Neměnnost

Po aktivaci se obsah verze nemá měnit.

Oprava chyby vytváří:

* novou verzi,
* nebo samostatný auditovaný opravný ChangeSet,

podle rozsahu změny.

## 7.4 Kdy vzniká nová verze

Nová TrainingPlanVersion vzniká zejména při:

* změně hlavního cíle,
* změně priorit cílů,
* změně délky plánu,
* přidání nebo odebrání tréninkového bloku,
* zásadní změně týdenní struktury,
* významné změně sportovního režimu,
* přeplánování většího období,
* návratu po delší pauze,
* změně přípravy na závod nebo sezonu.

## 7.5 Kdy nová verze vznikat nemusí

Nová verze nemusí vznikat při:

* přesunu jednoho workoutu,
* zkrácení jedné instance,
* nahrazení jednoho cviku pouze dnes,
* změně jedné notifikace,
* opravě času jedné události,
* jednorázové změně víkendu.

Tyto změny mohou být reprezentovány pomocí ChangeSet.

## 7.6 Verze versus ChangeSet

TrainingPlanVersion reprezentuje nový strategický stav plánu.

ChangeSet reprezentuje konkrétní změnu dat.

Jedna nová verze může být aplikována prostřednictvím jednoho nebo více ChangeSet objektů.

---

# 8. TrainingBlock

## 8.1 Význam

TrainingBlock je souvislé období uvnitř plánu se specifickým zaměřením.

## 8.2 Příklady

* adaptace po pauze,
* základní síla,
* hypertrofie,
* sportovně specifická síla,
* rozvoj vytrvalosti,
* příprava na závod,
* závodní období,
* deload,
* regenerace,
* návrat po omezení,
* udržovací období.

## 8.3 Vlastnosti

TrainingBlock obsahuje:

* identifikátor,
* pořadí,
* název,
* začátek,
* konec,
* hlavní zaměření,
* vedlejší zaměření,
* podporované cíle,
* sporty,
* plánovanou zátěž,
* progresní strategii,
* pravidla adaptace,
* stav.

## 8.4 Stav bloku

* PLANNED,
* ACTIVE,
* COMPLETED,
* PAUSED,
* SHORTENED,
* EXTENDED,
* REPLACED,
* CANCELLED.

## 8.5 Pravidla

* Bloky v jednom plánu se nemají nevysvětleně překrývat.
* Překrytí může být povoleno, pokud jde o paralelní zaměření.
* Každý blok musí mít jasný účel.
* Blok musí respektovat cíle a omezení platná v daném období.
* Změna délky bloku musí být auditovaná.

---

# 9. Paralelní zaměření v bloku

Multisportovní plán často nemá pouze jedno zaměření.

TrainingBlock proto může obsahovat:

* primární zaměření,
* sekundární zaměření,
* udržovací zaměření.

Příklad:

## Primární

Zlepšení síly nohou.

## Sekundární

Mobilita pro lezení.

## Udržovací

Tahová síla horní části těla.

Systém musí umět vyjádřit, že některé schopnosti se rozvíjejí, jiné udržují a jiné jsou dočasně upozaděné.

---

# 10. TrainingWeek

## 10.1 Význam

TrainingWeek je základní krátkodobá plánovací jednotka.

Představuje konkrétní týden nebo jiné sedmidenní období v rámci plánu.

## 10.2 Obsah

TrainingWeek obsahuje:

* identifikátor,
* pořadí v plánu,
* začátek,
* konec,
* vazbu na TrainingBlock,
* hlavní cíl týdne,
* plánovanou zátěž,
* stav,
* plánované workouty,
* pevné sportovní události,
* doporučenou regeneraci,
* revizi týdne.

## 10.3 Stav týdne

* FUTURE,
* CURRENT,
* COMPLETED,
* REVIEW_PENDING,
* REVIEWED,
* REPLANNED,
* SKIPPED.

## 10.4 Typ týdne

Příklady:

* standardní,
* adaptační,
* progresní,
* odlehčovací,
* závodní,
* regenerační,
* cestovní,
* návratový,
* testovací.

## 10.5 Týdenní cíl

Každý týden může mít stručný účel:

> Udržet fotbalovou výkonnost a dokončit dva workouty horní části těla.

Tento účel pomáhá při adaptaci.

Když uživatel nestíhá, systém se snaží zachovat účel týdne, ne všechny původní položky.

---

# 11. PlannedDay

## 11.1 Význam

PlannedDay je logický plán dne uvnitř TrainingWeek.

Nemusí být samostatně uložen jako databázová entita, pokud lze odvodit z workoutů a událostí.

Produktově však jde o důležitý koncept.

## 11.2 Obsah

PlannedDay může obsahovat:

* datum,
* hlavní účel dne,
* aktivity,
* prioritu,
* očekávanou zátěž,
* doporučené pořadí,
* recovery poznámku,
* stav dne.

## 11.3 Typ dne

Příklady:

* vysoká zátěž,
* střední zátěž,
* nízká zátěž,
* odpočinek,
* závod,
* cestování,
* kombinovaný den,
* neznámý.

## 11.4 Více aktivit za den

PlannedDay musí podporovat:

* hlavní workout,
* týmový trénink,
* mikro-workout,
* mobilitu,
* regeneraci,
* obecnou aktivitu.

Každá aktivita má vlastní prioritu a roli.

---

# 12. Role plánované aktivity

Každá plánovaná aktivita může mít roli:

* PRIMARY,
* SUPPORTING,
* OPTIONAL,
* RECOVERY,
* FIXED_EXTERNAL,
* TEST,
* EVENT.

## 12.1 PRIMARY

Hlavní tréninková jednotka dne.

## 12.2 SUPPORTING

Doplňková jednotka podporující hlavní cíl.

## 12.3 OPTIONAL

Volitelná aktivita, kterou lze snadno vynechat.

## 12.4 RECOVERY

Regenerační nebo lehká pohybová jednotka.

## 12.5 FIXED_EXTERNAL

Pevná aktivita, například týmový trénink.

## 12.6 TEST

Testovací aktivita nebo kontrolní workout.

## 12.7 EVENT

Zápas, závod, výjezd nebo jiná významná událost.

---

# 13. PlanGoalLink

## 13.1 Význam

Reprezentuje vztah mezi TrainingPlan a Goal.

## 13.2 Vlastnosti

* identifikátor cíle,
* role cíle v plánu,
* priorita,
* očekávaný přínos,
* období zaměření,
* způsob vyhodnocení.

## 13.3 Role cíle

* PRIMARY,
* SECONDARY,
* MAINTENANCE,
* SUPPORTING,
* DEFERRED.

## 13.4 Konflikt cílů

Pokud jsou cíle v konfliktu, plán musí obsahovat:

* popis kompromisu,
* prioritu,
* období, kdy se který cíl upřednostňuje,
* pravidlo revize.

---

# 14. PlanSportLink

## 14.1 Význam

Určuje, jakou roli má konkrétní sport v plánu.

## 14.2 Vlastnosti

* UserSport,
* role,
* očekávaná frekvence,
* sezona,
* priorita,
* typická zátěž,
* plánovací zacházení.

## 14.3 Příklady rolí

* hlavní rozvojový sport,
* pevná externí zátěž,
* doplňkový sport,
* rekreační aktivita,
* sezonní aktivita,
* udržovací aktivita.

---

# 15. PlanningConstraint

## 15.1 Význam

PlanningConstraint je omezení, které musí nebo má být při plánování respektováno.

## 15.2 Kategorie

* časové,
* regenerační,
* zdravotní,
* vybavení,
* prostředí,
* sportovní,
* uživatelské,
* bezpečnostní,
* technické.

## 15.3 Tvrdost omezení

Každé omezení má úroveň:

* HARD,
* SOFT,
* PREFERENCE.

### HARD

Nesmí být porušeno.

Příklady:

* uživatel není dostupný,
* zákaz konkrétní aktivity od lékaře,
* chybějící nutné vybavení,
* překročení bezpečnostního limitu.

### SOFT

Může být porušeno pouze s vysvětlením.

Příklady:

* preferovaný odpočinkový den,
* doporučený rozestup mezi jednotkami,
* preferovaný čas.

### PREFERENCE

Použije se při výběru mezi více vhodnými variantami.

## 15.4 Platnost

Omezení může být:

* trvalé,
* časově omezené,
* platné pro sport,
* platné pro blok,
* platné pro konkrétní týden,
* platné pro jeden workout.

## 15.5 Zdroj

* uživatel,
* odborné doporučení,
* systém,
* sportovní modul,
* AI návrh,
* integrace.

---

# 16. PlanningRule

## 16.1 Význam

PlanningRule je pravidlo, podle kterého systém vyhodnocuje nebo vytváří plán.

## 16.2 Typy pravidel

* bezpečnostní,
* časové,
* zátěžové,
* sportovně specifické,
* progresní,
* regenerační,
* uživatelské,
* adaptační.

## 16.3 Příklady

* neplánovat těžké nohy den před zápasem,
* zachovat minimálně jeden regenerační den,
* nezvyšovat objem po delší pauze skokově,
* neplánovat těžké tahové cviky před lezeckým víkendem,
* zkrátit doplňkový workout při nízké dostupnosti,
* preferovat kratší workout před úplným vynecháním, pokud zachová účel.

## 16.4 Priorita pravidel

Při konfliktu platí pořadí:

1. bezpečnost,
2. odborné omezení,
3. tvrdá časová omezení,
4. pevné sportovní události,
5. dlouhodobé cíle,
6. regenerace,
7. preference,
8. optimalizace pohodlí.

## 16.5 Výsledek pravidla

Pravidlo může:

* povolit,
* zakázat,
* doporučit,
* penalizovat variantu,
* vytvořit varování,
* vyžádat potvrzení.

---

# 17. PlanEventReference

## 17.1 Význam

PlanEventReference propojuje plán s významnou externí nebo pevnou událostí.

Příklady:

* zápas,
* závod,
* lezecký víkend,
* dovolená,
* soustředění,
* sportovní kemp,
* pracovní cesta.

## 17.2 Vlastnosti

* typ události,
* datum nebo období,
* priorita,
* pevnost,
* sport,
* očekávaná zátěž,
* dopad na plán,
* zdroj.

## 17.3 Chování

Událost může ovlivnit:

* předchozí dny,
* samotný den,
* následnou regeneraci,
* délku bloku,
* cíle týdne.

---

# 18. WorkoutInstance v kontextu plánu

## 18.1 Význam

WorkoutInstance je konkrétní plánovaná jednotka vytvořená nebo převzatá plánem.

## 18.2 Vztah k plánu

WorkoutInstance může mít vazbu na:

* TrainingPlan,
* TrainingPlanVersion,
* TrainingBlock,
* TrainingWeek,
* WorkoutTemplate,
* Goal,
* UserSport.

## 18.3 Zdroj vytvoření

* plánovací engine,
* AI návrh,
* ruční vytvoření,
* opakované pravidlo,
* kopie,
* náhrada jiné aktivity.

## 18.4 Nezávislost instance

Po vytvoření může být instance lokálně upravena bez změny šablony.

Musí být možné určit:

* zda odpovídá původní šabloně,
* co se změnilo,
* proč,
* zda změna platí pouze dnes.

## 18.5 Instance versus pevná sportovní událost

Ne každá plánovaná sportovní aktivita musí být WorkoutInstance.

Například florbalový trénink může být:

* ScheduleEvent,
* FIXED_EXTERNAL aktivita,
* bez strukturovaných cviků.

Po dokončení z něj vznikne Activity.

---

# 19. Generování workout instancí

## 19.1 Strategie

Plán nemusí vytvořit všechny workouty na několik měsíců dopředu ve finální podobě.

Možné strategie:

* plné vygenerování,
* rolling horizon,
* kombinovaný model.

## 19.2 Plné vygenerování

Všechny instance vzniknou při aktivaci plánu.

Výhody:

* jednoduché zobrazení,
* offline dostupnost,
* přehlednost.

Nevýhody:

* větší množství změn,
* zastarávání,
* náročnější adaptace.

## 19.3 Rolling horizon

Detailní workouty se generují pouze na omezené období dopředu.

Například:

* 2 týdny detailně,
* další týdny pouze rámcově.

Výhody:

* lepší adaptace,
* méně zastaralých instancí.

Nevýhody:

* závislost na průběžném generování,
* složitější offline chování.

## 19.4 Doporučený model

Použít kombinaci:

* celý plán má dlouhodobou strukturu,
* všechny týdny mají rámcový obsah,
* detailní WorkoutInstance se vytvářejí v dostatečném horizontu,
* nejbližší týdny jsou plně dostupné offline.

Konkrétní horizont bude definován později.

---

# 20. Pevná a flexibilní aktivita

## 20.1 Pevná aktivita

Má konkrétní termín, který systém nemá běžně měnit.

Příklady:

* týmový trénink,
* zápas,
* závod,
* rezervovaná lekce.

## 20.2 Flexibilní aktivita

Může být přesunuta v povoleném rozsahu.

Příklady:

* domácí silový workout,
* mobilita,
* běh bez pevného času.

## 20.3 FlexibilityWindow

Určuje:

* nejdřívější možný čas,
* nejpozdější možný čas,
* povolené dny,
* minimální rozestupy,
* zakázané konflikty.

## 20.4 Automatické přesuny

Mohou být povoleny pouze:

* u flexibilních aktivit,
* v předem daném rozsahu,
* podle AutomationPreference,
* s auditním záznamem,
* s možností vrácení.

---

# 21. Progrese

## 21.1 Význam

Progrese popisuje, jak se má plán v čase měnit.

## 21.2 Typy progrese

* zvýšení objemu,
* zvýšení intenzity,
* zvýšení obtížnosti,
* zvýšení frekvence,
* prodloužení času,
* zkrácení pauz,
* složitější varianta,
* zlepšení technické kvality,
* zvýšení sportovní specifičnosti.

## 21.3 ProgressionStrategy

Obsahuje:

* cílovou metriku,
* podmínku pro zvýšení,
* maximální krok změny,
* podmínku pro zachování,
* podmínku pro snížení,
* odlehčovací pravidla,
* závislost na skutečných výsledcích.

## 21.4 Progrese podle skutečnosti

Progrese nesmí vycházet pouze z kalendářního času.

Musí zohlednit:

* dokončení,
* skutečný výkon,
* subjektivní náročnost,
* bolest,
* únavu,
* vynechané aktivity,
* náhradní aktivity.

---

# 22. Týdenní zátěž

## 22.1 Význam

TrainingWeek může obsahovat plánovanou souhrnnou zátěž.

Nemusí jít o jedno přesné číslo.

## 22.2 Složky

* celková zátěž,
* vytrvalostní,
* silová,
* lokální,
* sportovně specifická,
* kontaktní,
* úchopová,
* rychlostní,
* mobilitní.

## 22.3 Kvalita odhadu

Každý odhad musí mít:

* zdroj,
* míru spolehlivosti,
* použitou metodu,
* omezení.

## 22.4 Bez falešné přesnosti

Systém nesmí zobrazovat přesné závěry, pokud vychází pouze z hrubého subjektivního odhadu.

---

# 23. Adaptace plánu

## 23.1 Význam

Adaptace je změna plánu na základě nové informace.

## 23.2 Spouštěče

* únava,
* bolest,
* nemoc,
* změna dostupnosti,
* zrušený trénink,
* nový zápas,
* sportovní víkend,
* cestování,
* nové vybavení,
* ztráta vybavení,
* vynechaný workout,
* lepší nebo horší pokrok,
* změna cíle,
* wearable data,
* ruční požadavek.

## 23.3 Rozsah adaptace

* SET,
* EXERCISE,
* WORKOUT,
* DAY,
* WEEK,
* BLOCK,
* PLAN.

## 23.4 AdaptationProposal

Návrh adaptace musí obsahovat:

* spouštěč,
* rozsah,
* původní stav,
* navržený stav,
* důvod,
* dopad,
* rizika,
* jistotu,
* potřebu potvrzení,
* vratnost.

## 23.5 Malá změna

Příklady:

* snížení jedné série,
* posun času,
* změna notifikace.

## 23.6 Střední změna

Příklady:

* zkrácení workoutu,
* přesun workoutu na jiný den,
* změna několika cviků.

## 23.7 Velká změna

Příklady:

* reorganizace týdne,
* změna bloku,
* změna hlavního cíle,
* zrušení více workoutů.

---

# 24. Potvrzování adaptací

## 24.1 Bez potvrzení

Pouze pokud:

* jde o nízkorizikovou změnu,
* uživatel ji předem povolil,
* změna je vratná,
* neovlivní významně cíl nebo zátěž.

## 24.2 Vyžaduje potvrzení

Zejména:

* změna více dnů,
* zrušení workoutu,
* změna hlavního cíle,
* významné zvýšení nebo snížení zátěže,
* změna bloku,
* změna pravidelné aktivity,
* změna omezení.

## 24.3 Částečné potvrzení

Uživatel může potvrdit jen část návrhu.

Systém musí poté:

* znovu validovat plán,
* zkontrolovat konflikty,
* vytvořit finální ChangeSet,
* vysvětlit případné důsledky.

---

# 25. ChangeSet v plánovacím modelu

## 25.1 Význam

ChangeSet reprezentuje konkrétní skupinu změn aplikovaných na plánovací objekty.

## 25.2 Příklad

Uživatel jede o víkendu lézt.

ChangeSet může obsahovat:

1. vytvoření sobotní lezecké události,
2. vytvoření nedělní lezecké události,
3. přesun pátečního tahového workoutu,
4. zrušení sobotního silového workoutu,
5. přidání pondělní regenerace.

## 25.3 Atomická aplikace

Pokud to doménově dává smysl, ChangeSet se aplikuje jako celek.

Pokud část selže:

* nesmí vzniknout nekonzistentní plán,
* musí být znám stav každé operace,
* systém musí umět rollback nebo bezpečné dokončení.

## 25.4 Idempotence

Opakované zpracování stejného ChangeSet nesmí vytvořit duplicity.

---

# 26. Vrácení změny

## 26.1 Podmínky

Změna je vratná, pokud:

* nebyla překryta nekompatibilní novější změnou,
* neodstraňuje skutečně dokončené aktivity,
* nevytváří bezpečnostní konflikt,
* lze rekonstruovat původní stav.

## 26.2 Závislé změny

Pokud na změnu navázaly další změny, systém musí nabídnout:

* vrátit celý řetězec,
* vytvořit nový kompenzační návrh,
* návrat odmítnout s vysvětlením.

## 26.3 Dokončené workouty

Vrácení změny nesmí přepsat dokončenou historii.

Může pouze upravit budoucí plán.

---

# 27. Změna cíle

## 27.1 Malá změna cíle

Příklad:

* změna termínu o několik dní,
* úprava vedlejší metriky.

Může vytvořit ChangeSet.

## 27.2 Významná změna cíle

Příklad:

* půlmaraton se ruší,
* hlavním cílem se stává lezení.

Musí obvykle vytvořit:

* novou verzi plánu,
* nebo nový TrainingPlan.

## 27.3 Zachování historie

Původní cíl a plán se archivují nebo označí jako nahrazené.

---

# 28. Vynechaný workout

## 28.1 Stav

WorkoutInstance může být označena jako SKIPPED.

## 28.2 Důvod

Volitelně:

* nedostatek času,
* únava,
* bolest,
* nemoc,
* změna programu,
* vlastní rozhodnutí,
* neznámý důvod.

## 28.3 Automatická reakce

Systém nesmí automaticky přesunout každý vynechaný workout.

Musí vyhodnotit:

* účel týdne,
* prioritu,
* další zátěž,
* možnost náhrady,
* bezpečnost.

## 28.4 Možné výsledky

* bez náhrady,
* přesun,
* zkrácená náhrada,
* spojení,
* změna progrese,
* reorganizace týdne.

---

# 29. Náhradní aktivita

## 29.1 Příklad

Uživatel místo plánovaného běhu hrál fotbal.

## 29.2 Vyhodnocení

ActivityMatch může určit:

* plná náhrada,
* částečná náhrada,
* jiný typ zátěže,
* žádná náhrada.

## 29.3 Dopad

Plánovací systém může:

* zachovat další týden,
* upravit workout,
* snížit lokální zátěž,
* nechat původní cíl týdne nesplněný.

---

# 30. Pauza v plánu

## 30.1 Spouštěče

* nemoc,
* zranění,
* cestování,
* ztráta motivace,
* pracovní období,
* vlastní rozhodnutí.

## 30.2 PausePeriod

Obsahuje:

* začátek,
* očekávaný konec,
* důvod,
* povolené aktivity,
* pravidla návratu.

## 30.3 Návrat

Po pauze systém nesmí automaticky pokračovat na původní intenzitě.

Musí posoudit:

* délku pauzy,
* důvod,
* předchozí úroveň,
* aktuální stav,
* termíny cílů.

---

# 31. PlanReview

## 31.1 Význam

PlanReview je pravidelné vyhodnocení plánu.

## 31.2 Typy

* denní,
* týdenní,
* bloková,
* před závodem,
* po závodu,
* mimořádná,
* při stagnaci.

## 31.3 WeeklyReview

Obsahuje:

* plánované aktivity,
* dokončené aktivity,
* náhradní aktivity,
* vynechané aktivity,
* změny,
* subjektivní stav,
* vývoj cíle,
* doporučení.

## 31.4 Výsledek revize

* plán bez změny,
* malý ChangeSet,
* nová verze,
* pozastavení,
* změna cíle,
* potřeba dalšího vstupu.

---

# 32. Deterministické a AI plánování

## 32.1 Deterministická vrstva

Musí řešit:

* tvrdá omezení,
* časové konflikty,
* základní regenerační rozestupy,
* dostupnost vybavení,
* validaci bezpečnosti,
* povinné invariance.

## 32.2 AI vrstva

Může pomáhat s:

* interpretací přirozeného jazyka,
* návrhem strategie,
* vysvětlením,
* volbou mezi více rozumnými variantami,
* přizpůsobením preferencím,
* vytvořením strukturovaného návrhu.

## 32.3 Zásada

AI návrh nesmí obejít deterministickou validaci.

## 32.4 Fallback

Při nedostupnosti AI může systém:

* zachovat existující plán,
* ručně upravit workouty,
* použít deterministické zkrácení,
* upozornit na konflikty,
* vytvořit základní šablonový plán.

---

# 33. Univerzální podpora sportů

Plánovací model nesmí obsahovat pouze pevné větve:

* footballPlan,
* runningPlan,
* climbingPlan.

Musí pracovat s obecnými charakteristikami:

* frekvence,
* intenzita,
* pevnost,
* vytrvalostní zátěž,
* silová zátěž,
* rychlost,
* mobilita,
* koordinace,
* lokální zatížení,
* kontaktnost,
* regenerace,
* vybavení,
* prostředí.

Sportovní modul může přidat:

* specializovaná pravidla,
* metriky,
* workout šablony,
* periodizační znalosti.

Obecný sport však musí zůstat plánovatelný.

---

# 34. Příklad plánu – fotbal a domácí síla

## Vstup

* fotbal pondělí, středa, pátek,
* zápas neděle,
* cíl zesílit horní polovinu těla,
* hrazda,
* doma,
* období osm týdnů.

## Struktura

### TrainingPlan

> Football + Upper Body Strength

### Blok 1

Týdny 1–2:

* adaptační síla,
* technika cviků,
* nižší objem.

### Blok 2

Týdny 3–6:

* progresivní síla,
* dvě jednotky týdně.

### Blok 3

Týdny 7–8:

* konsolidace,
* kontrolní workout,
* bez zvyšování únavy před zápasy.

## Typický týden

* Pondělí: fotbal,
* Úterý: Upper Body A,
* Středa: fotbal,
* Čtvrtek: volno nebo mobilita,
* Pátek: fotbal,
* Sobota: Upper Body B lehčí,
* Neděle: zápas.

Plánovací pravidla musí posoudit, zda je sobotní workout vhodný podle intenzity a času zápasu.

---

# 35. Příklad plánu – florbal, lezení, mobilita a nohy

## Vstup

* florbal pondělí a středa,
* zápas neděle,
* lezení nepravidelně,
* ranní mobilita,
* posílení nohou,
* bez vybavení.

## Struktura

### Primární cíle

* síla nohou,
* mobilita pro lezení.

### Pevné zátěže

* pondělní florbal,
* středeční florbal,
* nedělní zápas.

### Mikro-workouty

* krátké ranní mobility.

### Hlavní silová jednotka

* umístěna s ohledem na zápas a florbal.

### Adaptace

Lezecký víkend může:

* snížit doplňkovou zátěž,
* přesunout hlavní silový workout,
* změnit pondělní regeneraci.

---

# 36. Příklad adaptace – únava

## Původní stav

Dnes:

* 45 minut silový workout.

Zítra:

* týmový trénink.

## Nový vstup

> Dnes jsem hodně unavený a spal jsem čtyři hodiny.

## Návrh

* zkrátit workout na 20 minut,
* zachovat hlavní tlakový a tahový vzor,
* odstranit doplňkové série,
* neměnit zítřejší týmový trénink,
* znovu vyhodnotit stav ráno.

## Doménový výsledek

* AIProposal,
* validovaný ChangeSet,
* update WorkoutInstance,
* zachovaná původní verze instance,
* auditní důvod,
* případný DailyCheckIn.

---

# 37. Příklad adaptace – bolest bicepsu

## Vstup

> Bolí mě pravý biceps.

## Proces

1. vznikne PainReport,
2. proběhne bezpečnostní vyhodnocení,
3. identifikují se ovlivněné tahové cviky,
4. vytvoří se dočasné omezení,
5. návrh upraví pouze relevantní workouty,
6. významná změna se potvrdí.

## Plánovací zásada

Bolest se nesmí automaticky uložit jako trvalý problém.

---

# 38. Invariance plánovacího modelu

## 38.1 Plán

* ACTIVE TrainingPlan musí mít aktivní TrainingPlanVersion.
* Aktivní verze musí patřit ke stejnému uživateli jako plán.
* Plán musí mít účel nebo cíl.
* Historická verze se nesmí přepsat.
* Datum bloku musí být uvnitř období plánu, pokud není výslovně označen jako přechodový.

## 38.2 Týden

* TrainingWeek musí patřit právě jednomu plánu nebo verzi.
* WorkoutInstance nesmí být bez vysvětlení mimo období svého týdne.
* Pevná událost se nesmí automaticky přesunout bez oprávnění.
* Týdenní cíl musí být kompatibilní s blokem.

## 38.3 Workout

* WorkoutInstance patří jednomu uživateli.
* Dokončená instance se nesmí upravovat jako budoucí plán.
* Změna šablony nesmí zpětně přepsat historickou instanci.
* Přesun musí zachovat historii původního termínu.

## 38.4 AI

* Nevalidovaný AI návrh se nesmí aplikovat.
* Zastaralý AIProposal se nesmí aplikovat bez přepočtu.
* Akce vyžadující potvrzení musí mít platné potvrzení.
* AI změna musí mít srozumitelný důvod.

## 38.5 Bezpečnost

* HARD constraint se nesmí porušit.
* Odborné omezení má přednost před výkonovým cílem.
* Plán nesmí ignorovat aktivní rizikový PainAssessment.

---

# 39. Doménové události plánování

Minimálně:

* TrainingPlanDraftCreated
* TrainingPlanSubmittedForConfirmation
* TrainingPlanActivated
* TrainingPlanPaused
* TrainingPlanResumed
* TrainingPlanCompleted
* TrainingPlanReplaced
* TrainingPlanVersionCreated
* TrainingBlockStarted
* TrainingBlockCompleted
* TrainingWeekCreated
* TrainingWeekReplanned
* WorkoutInstanceCreated
* WorkoutInstanceRescheduled
* WorkoutInstanceShortened
* WorkoutInstanceCancelled
* WorkoutInstanceSkipped
* PlanningConflictDetected
* PlanningConflictResolved
* PlanReviewRequested
* PlanReviewCompleted
* AdaptationProposalCreated
* AdaptationApplied
* AdaptationReverted

---

# 40. Příkazy plánovací oblasti

Minimálně:

* CreateTrainingPlanDraft
* UpdateTrainingPlanDraft
* SubmitTrainingPlanForConfirmation
* ActivateTrainingPlan
* PauseTrainingPlan
* ResumeTrainingPlan
* CompleteTrainingPlan
* ReplaceTrainingPlan
* CreateTrainingPlanVersion
* AddTrainingBlock
* UpdateTrainingBlock
* CreateTrainingWeek
* ReplanTrainingWeek
* ScheduleWorkoutInstance
* RescheduleWorkoutInstance
* ShortenWorkoutInstance
* CancelWorkoutInstance
* SkipWorkoutInstance
* ApplyAdaptationProposal
* RevertPlanChange
* ResolvePlanningConflict
* CompletePlanReview

---

# 41. Read modely plánovací oblasti

## 41.1 TrainingPlanSummary

Obsahuje:

* název,
* stav,
* období,
* cíle,
* aktuální blok,
* nejbližší událost,
* poslední změnu.

## 41.2 TrainingPlanDetail

Obsahuje:

* strukturu bloků,
* cíle,
* sporty,
* pravidla,
* verzi,
* historii.

## 41.3 WeeklyPlanView

Obsahuje:

* dny,
* aktivity,
* workouty,
* priority,
* flexibilitu,
* konflikty,
* souhrnnou zátěž.

## 41.4 PlanChangePreview

Obsahuje:

* původní stav,
* nový stav,
* změny,
* důvody,
* potvrzení,
* vratnost.

## 41.5 PlanHistoryView

Obsahuje:

* verze,
* ChangeSet objekty,
* zdroje změn,
* možnost porovnání.

---

# 42. Otevřené otázky

* Má být TrainingWeek samostatná persistentní entita, nebo read model nad daty?
* Má být PlannedDay ukládán, nebo odvozován?
* Jaký bude detailní rolling horizon workoutů?
* Jak přesně reprezentovat přesunutou instanci?
* Kdy vzniká nová verze plánu a kdy pouze ChangeSet?
* Má být zátěž ukládána, nebo vždy přepočítávána?
* Jak se budou plánovací pravidla verzovat?
* Jak oddělit systémová a uživatelská pravidla?
* Jak reprezentovat více současných plánů v pozdější verzi?
* Jak dlouho může AIProposal zůstat platný?
* Jak přesně bude fungovat částečné potvrzení ChangeSet?
* Jak se bude řešit změna časového pásma během plánu?
* Jak se bude řešit přechod přes letní a zimní čas?
* Jak se budou generovat instance z recurrence pravidel?
* Jak se budou opravovat chybně vytvořené budoucí instance?

---

# 43. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── workout-model.md
├── scheduling-model.md
├── sports-and-goals-model.md
├── recovery-and-limitations-model.md
├── ai-and-change-model.md
├── activity-model.md
├── sync-and-offline-model.md
├── domain-events.md
└── domain-invariants.md
```

Dále:

```text
docs/05-ai/
├── ai-planning-behavior.md
├── ai-tools.md
├── confirmation-policy.md
└── safety-rules.md
```

A technicky:

```text
docs/07-backend/
├── backend-architecture.md
├── planning-service.md
├── api-contracts.md
└── persistence-model.md
```

---

# 44. Kritéria správného plánovacího modelu

Model je vhodný pouze tehdy, pokud umožní:

1. vytvořit dlouhodobý plán pro více sportů,
2. spojit pevné a flexibilní aktivity,
3. podporovat více cílů a jejich priority,
4. rozdělit plán do bloků a týdnů,
5. generovat konkrétní workout instance,
6. upravit jeden workout bez přepsání celé šablony,
7. reorganizovat týden,
8. reagovat na únavu,
9. reagovat na bolest,
10. reagovat na cestování,
11. reagovat na sportovní víkend,
12. zachovat původní plán,
13. porovnat verze,
14. vrátit změnu,
15. fungovat bez AI,
16. podporovat libovolný sport,
17. pracovat offline,
18. synchronizovat více zařízení,
19. zabránit nebezpečné změně,
20. vysvětlit uživateli důvod změny.

---

# 45. Závěr

TrainingPlan není pouze obálka nad seznamem workoutů.

Je to verzovaný strategický objekt, který propojuje:

* cíle,
* sporty,
* dostupnost,
* pravidelné události,
* workouty,
* regeneraci,
* omezení,
* skutečný pokrok,
* změny v životě uživatele.

Jeho strukturu lze shrnout takto:

```text
TrainingPlan
    ↓
TrainingPlanVersion
    ↓
TrainingBlock
    ↓
TrainingWeek
    ↓
PlannedDay
    ↓
WorkoutInstance / ScheduleEvent
    ↓
WorkoutSession / Activity
    ↓
PlanReview
    ↓
Adaptace nebo nová verze
```

Tento cyklus se opakuje po celou dobu používání aplikace.

Cílem není vytvořit plán, který se nikdy nezmění.

Cílem je vytvořit systém, který dokáže změny provádět bezpečně, srozumitelně, vratně a bez ztráty dlouhodobého směru.
