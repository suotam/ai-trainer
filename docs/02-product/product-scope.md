# AI Trainer – Product Scope

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/02-product/product-scope.md`

---

# 1. Účel dokumentu

Tento dokument vymezuje rozsah produktu AI Trainer.

Rozlišuje mezi:

* dlouhodobou vizí produktu,
* první veřejně použitelnou verzí,
* jednotlivými implementačními etapami,
* funkcemi odloženými do budoucna,
* funkcemi, které do produktu nepatří.

Cílem je zabránit nekontrolovanému rozšiřování projektu a umožnit jeho postupnou implementaci po samostatně testovatelných částech.

Kompletní vize produktu je rozsáhlá. To však neznamená, že musí být implementována najednou.

Každá etapa musí vytvořit funkční celek, který lze:

* spustit,
* otestovat,
* použít,
* vyhodnotit,
* dále rozvíjet.

---

# 2. Produktová definice

AI Trainer je osobní AI trenér pro sportovce, který propojuje:

* sportovní profil uživatele,
* dlouhodobé cíle,
* pravidelné sportovní aktivity,
* tréninkové plánování,
* workout tracker,
* kalendář,
* regeneraci,
* subjektivní zpětnou vazbu,
* data z mobilních zařízení a wearables,
* AI komunikaci a rozhodování.

AI Trainer nevytváří pouze jednorázové tréninkové plány.

Průběžně:

* sleduje plánované a dokončené aktivity,
* reaguje na změny,
* upravuje plán,
* vysvětluje své návrhy,
* vyhodnocuje vývoj,
* pomáhá uživateli rozhodovat, co má dělat dnes a v dalších dnech.

---

# 3. Dlouhodobý rozsah produktu

Dlouhodobá verze produktu může zahrnovat následující oblasti.

## 3.1 Uživatelský účet a profil

* registrace a přihlášení,
* správa účtu,
* více zařízení,
* základní osobní údaje,
* sportovní historie,
* zkušenostní úroveň,
* časové možnosti,
* dostupné vybavení,
* preferované tréninkové prostředí,
* zdravotní a pohybová omezení,
* preference komunikace,
* nastavení jednotek,
* nastavení soukromí,
* export a odstranění dat.

## 3.2 Sportovní profil

Uživatel může provozovat více sportů současně.

Každý sport může obsahovat:

* úroveň zkušeností,
* pravidelnost,
* obvyklé dny,
* sezónnost,
* soutěže a zápasy,
* tréninkové priority,
* dlouhodobé cíle,
* historická data,
* zatížení specifických svalových skupin,
* požadavky na regeneraci.

Sportovní profil není odděleným plánem pro každý sport. Všechny sporty vstupují do jednoho společného plánovacího systému.

## 3.3 Cíle

Aplikace může pracovat s různými typy cílů:

* výkonový cíl,
* silový cíl,
* vytrvalostní cíl,
* mobilitní cíl,
* návykový cíl,
* tělesný cíl,
* sportovní událost,
* návrat po pauze,
* pravidelnost tréninku,
* příprava na sezónu.

Cíl může obsahovat:

* název,
* popis,
* prioritu,
* termín,
* výchozí stav,
* cílový stav,
* metriky,
* související sporty,
* omezení,
* milníky,
* stav plnění.

## 3.4 Tréninkové plány

Aplikace může vytvářet dlouhodobé plány na základě:

* cílů,
* sportovního rozvrhu,
* dostupného času,
* vybavení,
* zkušeností,
* předchozích výsledků,
* regenerace,
* omezení,
* preferencí.

Plán může být rozdělen na:

* tréninkové období,
* blok,
* týden,
* jednotlivé workouty,
* regenerační jednotky,
* sportovní aktivity,
* testovací jednotky,
* odpočinkové dny.

## 3.5 Kalendář

Interní kalendář obsahuje:

* plánované workouty,
* týmové tréninky,
* zápasy,
* závody,
* výlety,
* sportovní kempy,
* regenerační aktivity,
* odpočinek,
* testování výkonu,
* uživatelské události relevantní pro plánování.

Kalendář musí rozlišovat mezi:

* pevnými událostmi,
* flexibilními workouty,
* návrhy AI,
* dokončenými aktivitami,
* zrušenými aktivitami,
* přesunutými aktivitami.

## 3.6 Workout tracker

Workout tracker umožňuje:

* spustit konkrétní workout,
* zobrazit warm-up,
* zobrazit cviky,
* zapisovat série,
* zapisovat opakování,
* zapisovat čas,
* zapisovat vzdálenost,
* zapisovat váhu,
* zapisovat tempo,
* zapisovat subjektivní náročnost,
* měřit pauzy,
* měnit cvik během workoutu,
* vynechat cvik,
* přidat poznámku,
* dokončit workout,
* zhodnotit celkový pocit.

Tracker musí podporovat různé typy aktivit, nikoliv pouze klasické posilování.

## 3.7 AI trenér

AI trenér může:

* vytvořit plán,
* vysvětlit plán,
* navrhnout změnu,
* reagovat na únavu,
* reagovat na bolest,
* reagovat na změnu rozvrhu,
* reagovat na cestování,
* reagovat na změnu vybavení,
* upravit jednotlivý workout,
* upravit celý týden,
* upravit tréninkový blok,
* analyzovat dokončování plánu,
* shrnout pokrok,
* navrhnout další kroky.

AI nesmí být jediným mechanismem ovládání aplikace. Všechny základní funkce musí být dostupné také přes standardní rozhraní.

## 3.8 Regenerace

Aplikace může pracovat s:

* subjektivní únavou,
* svalovou bolestí,
* kvalitou spánku,
* délkou spánku,
* stresem,
* motivací,
* ranním pocitem,
* klidovou tepovou frekvencí,
* HRV,
* předchozím tréninkovým zatížením,
* doporučením odpočinku.

Regenerace je jedním ze vstupů pro plánování, nikoliv samostatným zdravotnickým diagnostickým systémem.

## 3.9 Statistiky a analýzy

Aplikace může zobrazovat:

* dokončené workouty,
* plánované versus dokončené aktivity,
* pravidelnost,
* objem,
* intenzitu,
* vývoj výkonu,
* osobní rekordy,
* zatížení podle sportu,
* zatížení svalových skupin,
* vývoj subjektivní náročnosti,
* plnění cílů,
* tréninkové série,
* období vysoké a nízké aktivity.

Statistiky musí být srozumitelné a praktické. Nemají zobrazovat data pouze proto, že je systém dokáže změřit.

## 3.10 Notifikace

Notifikace mohou upozorňovat na:

* dnešní plán,
* blížící se workout,
* změnu plánu,
* potřebu potvrzení AI návrhu,
* nedokončený workout,
* doporučenou regeneraci,
* týdenní shrnutí,
* dosažení cíle,
* dlouhodobou neaktivitu.

Uživatel musí mít kontrolu nad jejich frekvencí a typem.

## 3.11 Wearables a zdravotní platformy

Dlouhodobý rozsah může zahrnovat:

* Apple Health,
* Health Connect,
* Apple Watch,
* Wear OS,
* Garmin,
* Polar,
* Coros,
* Suunto,
* Fitbit,
* další sportovní ekosystémy.

Importovaná data mohou zahrnovat:

* srdeční tep,
* klidový tep,
* HRV,
* spánek,
* kroky,
* energetický výdej,
* zaznamenané aktivity,
* vzdálenost,
* rychlost,
* tempo,
* převýšení,
* GPS trasu.

Každá integrace bude implementována samostatně. Ne všechny integrace budou součástí první veřejné verze.

## 3.12 GPS aktivity

Dlouhodobě může aplikace umožnit:

* spuštění GPS záznamu,
* měření vzdálenosti,
* měření času,
* měření tempa,
* měření převýšení,
* zobrazení trasy,
* označení typu aktivity,
* pauzu a obnovení,
* dokončení aktivity,
* import aktivity z jiného zařízení.

GPS tracker je samostatná technicky náročná část a nesmí blokovat vytvoření základního AI trenéra.

## 3.13 Integrace externích kalendářů

Dlouhodobě může aplikace podporovat:

* Google Calendar,
* Apple Calendar,
* systémový kalendář zařízení.

Možné scénáře:

* export workoutu do externího kalendáře,
* import časové dostupnosti,
* zobrazení sportovních událostí,
* detekce časových konfliktů.

AI nesmí automaticky číst celý osobní kalendář bez jasného souhlasu uživatele.

---

# 4. První veřejně použitelná verze

První veřejně použitelná verze není kompletní dlouhodobou vizí.

Musí ale již demonstrovat hlavní hodnotu produktu:

> Uživatel popíše své sporty, cíle a časové možnosti. AI vytvoří plán, vloží ho do kalendáře a uživatel může jednotlivé workouty přímo provádět a průběžně upravovat.

První použitelná verze musí obsahovat následující hlavní části.

## 4.1 Uživatelský účet

* registrace,
* přihlášení,
* odhlášení,
* obnovení relace,
* základní profil,
* možnost smazání účtu.

## 4.2 Onboarding

Onboarding zjistí:

* hlavní cíle,
* provozované sporty,
* pravidelný sportovní rozvrh,
* dostupné dny a časy,
* zkušenostní úroveň,
* dostupné vybavení,
* preferované prostředí,
* základní omezení,
* preferovanou délku workoutů.

Onboarding musí být možné dokončit:

* formulářem,
* konverzací s AI,
* kombinací obou přístupů.

## 4.3 Sportovní profil

Uživatel může zobrazit a upravit:

* sporty,
* pravidelné aktivity,
* cíle,
* vybavení,
* časové možnosti,
* omezení,
* preference.

## 4.4 AI vytvoření plánu

Uživatel může přirozeným jazykem popsat situaci.

Například:

> Trénuji třikrát týdně fotbal a v neděli mám zápas. Chtěl bych zesílit horní polovinu těla. Nebudu chodit do fitka, cvičím doma a mám hrazdu. Udělej mi plán na dva měsíce.

Systém:

1. vyhodnotí dostupná data,
2. položí pouze nutné doplňující otázky,
3. vytvoří strukturovaný návrh,
4. zobrazí shrnutí,
5. umožní úpravu,
6. vyžádá potvrzení,
7. uloží plán,
8. vytvoří workouty v interním kalendáři.

## 4.5 Interní kalendář

Kalendář musí umožnit:

* měsíční přehled,
* týdenní přehled,
* denní přehled,
* zobrazení aktivit,
* otevření detailu workoutu,
* přesunutí workoutu,
* zrušení workoutu,
* ruční přidání aktivity,
* rozlišení plánovaných a dokončených aktivit.

## 4.6 Dnešní přehled

Domovská obrazovka musí zobrazit:

* dnešní datum,
* dnešní workouty,
* pravidelný sportovní trénink,
* stav dokončení,
* rychlé spuštění workoutu,
* stručné doporučení AI,
* možnost nahlásit únavu,
* možnost nahlásit bolest,
* možnost oznámit změnu dnešního programu.

## 4.7 Workout tracker

První verze musí podporovat minimálně:

* silový workout,
* mobilitu,
* intervalový workout,
* časový workout,
* obecnou sportovní aktivitu.

Uživatel může:

* zahájit workout,
* procházet cviky,
* zaznamenávat série a opakování,
* zaznamenávat čas,
* označit cvik jako dokončený,
* upravit plánovanou hodnotu,
* přidat poznámku,
* dokončit workout,
* ohodnotit náročnost a pocit.

## 4.8 Úpravy plánu přes AI

Uživatel může napsat například:

* „Dnes jsem unavený.“
* „Bolí mě pravý biceps.“
* „Celý víkend jedu na skály.“
* „Zrušili nám středeční trénink.“
* „Příští týden budu bez hrazdy.“
* „Dnešní workout nestihnu.“
* „Chci zkrátit všechny ranní workouty na 15 minut.“

AI vytvoří návrh změn.

Návrh musí zobrazit:

* co se změní,
* proč se to mění,
* kterých dnů se změna týká,
* zda jde změnu vrátit.

Významnější změny vyžadují potvrzení.

## 4.9 Notifikace

První verze musí podporovat:

* ranní přehled dne,
* připomenutí workoutu,
* otevření konkrétního workoutu z notifikace,
* upozornění na návrh změny plánu.

## 4.10 Základní statistiky

První verze zobrazí:

* počet plánovaných workoutů,
* počet dokončených workoutů,
* procento dokončení,
* tréninkovou pravidelnost,
* základní vývoj vybraných cviků nebo výkonů,
* aktuální postup vůči cíli.

## 4.11 Základní offline funkce

Bez internetu musí být možné:

* zobrazit synchronizovaný kalendář,
* otevřít dnešní workout,
* provést workout,
* zapsat výsledky,
* dokončit workout,
* uložit změny lokálně.

AI chat a generování nového plánu mohou vyžadovat internet.

---

# 5. Rozdělení implementace do etap

## Stage 0 – Projektový základ

Cíl:

Vytvořit stabilní technický základ projektu bez produktových funkcí.

Obsah:

* Git repozitář,
* základ Flutter projektu,
* Android a iOS konfigurace,
* backend projekt,
* lokální vývojové prostředí,
* Docker Compose,
* PostgreSQL,
* základní CI,
* linting,
* formátování,
* testovací struktura,
* správa konfigurace,
* prostředí development a test,
* základ dokumentace,
* základní design systém.

Výstup:

* Flutter aplikace se spustí na Androidu,
* Flutter aplikace se sestaví pro iOS,
* backend se spustí,
* aplikace se připojí k backendu,
* testovací endpoint funguje,
* automatické testy projdou.

## Stage 1 – Lokální produktový prototyp

Cíl:

Ověřit hlavní UX bez účtů, AI a backendové složitosti.

Obsah:

* domovská obrazovka,
* týdenní kalendář,
* demo sportovní profil,
* demo plán,
* detail workoutu,
* workout tracker,
* lokální ukládání,
* dokončení workoutu,
* základní historie.

Výstup:

Uživatel může na jednom zařízení otevřít demo plán, spustit workout a dokončit ho.

## Stage 2 – Účet a synchronizace

Cíl:

Převést aplikaci z lokálního prototypu na skutečný vícezařízenový systém.

Obsah:

* registrace,
* přihlášení,
* uživatelský účet,
* backendová databáze,
* synchronizace profilu,
* synchronizace kalendáře,
* synchronizace workoutů,
* bezpečné ukládání tokenů,
* řešení základních konfliktů.

Výstup:

Uživatel se přihlásí a jeho data jsou dostupná po opětovném spuštění aplikace.

## Stage 3 – Onboarding a sportovní profil

Cíl:

Získat strukturované údaje nutné pro plánování.

Obsah:

* cíle,
* sporty,
* pravidelný rozvrh,
* dostupnost,
* vybavení,
* zkušenost,
* omezení,
* preference,
* editace profilu.

Výstup:

Uživatel vytvoří sportovní profil bez zásahu AI.

## Stage 4 – Deterministické plánování

Cíl:

Vytvořit plánovací systém, který nevyžaduje AI.

Obsah:

* šablony workoutů,
* pravidla rozložení aktivit,
* kalendářní plánování,
* konflikty,
* pevné a flexibilní události,
* vytvoření plánu z předdefinovaných pravidel,
* potvrzení plánu,
* verzování plánu.

Výstup:

Systém dokáže vytvořit základní plán ze strukturovaných vstupů.

## Stage 5 – AI trenér

Cíl:

Přidat přirozenou komunikaci a tvorbu strukturovaných návrhů.

Obsah:

* AI chat,
* kontext uživatele,
* strukturované výstupy,
* AI nástroje,
* návrh plánu,
* vysvětlení plánu,
* návrhy změn,
* potvrzování akcí,
* audit AI akcí,
* bezpečnostní pravidla.

Výstup:

Uživatel popíše svůj sportovní život přirozeným jazykem a AI připraví použitelný plán.

## Stage 6 – Adaptivní plán

Cíl:

Umožnit průběžnou úpravu existujícího plánu.

Obsah:

* hlášení únavy,
* hlášení bolesti,
* změny dostupnosti,
* jednorázové události,
* úprava dne,
* úprava týdne,
* přesun aktivit,
* zjednodušení workoutu,
* nahrazení cviků,
* návrat změn,
* historie verzí.

Výstup:

Plán reaguje na běžné změny sportovního života uživatele.

## Stage 7 – Notifikace a návyky

Cíl:

Zvýšit každodenní použitelnost.

Obsah:

* ranní přehled,
* připomenutí workoutu,
* deep link do trackeru,
* uživatelská konfigurace,
* týdenní shrnutí,
* upozornění na nedokončené aktivity.

Výstup:

Uživatel se z notifikace dostane jedním kliknutím k dnešnímu workoutu.

## Stage 8 – Statistiky a progres

Cíl:

Ukázat uživateli, zda se skutečně zlepšuje.

Obsah:

* dokončování plánu,
* vývoj výkonu,
* osobní rekordy,
* plnění cílů,
* týdenní a měsíční přehledy,
* základní zátěžové metriky,
* AI shrnutí pokroku.

Výstup:

Uživatel rozumí tomu, co se zlepšuje a co je potřeba změnit.

## Stage 9 – Health platformy

Cíl:

Napojit systémová fitness data mobilních platforem.

Obsah:

* Health Connect pro Android,
* Apple Health pro iOS,
* oprávnění,
* import aktivit,
* import spánku,
* import tepu,
* import HRV, pokud je dostupné,
* normalizace dat,
* synchronizace,
* řešení duplicit.

Výstup:

Aplikace načítá základní data z podporovaných zdravotních platforem.

## Stage 10 – Wearable adaptace

Cíl:

Použít wearable data jako další vstup pro doporučení.

Obsah:

* denní recovery stav,
* kvalita a dostupnost dat,
* odhad únavy,
* transparentní vysvětlení,
* návrhy změn na základě dat,
* uživatelské potvrzení,
* bezpečnostní omezení.

Výstup:

Aplikace dokáže zohlednit spánek, HRV a klidový tep, aniž by předstírala lékařskou přesnost.

## Stage 11 – GPS tracking

Cíl:

Přidat vlastní záznam venkovních aktivit.

Obsah:

* záznam polohy,
* background tracking,
* čas,
* vzdálenost,
* tempo,
* převýšení,
* mapa,
* pauza,
* dokončení,
* offline ukládání,
* spotřeba baterie,
* oprávnění.

Výstup:

Uživatel může zaznamenat běh, chůzi nebo cyklistiku přímo v aplikaci.

## Stage 12 – Externí sportovní integrace

Cíl:

Rozšířit zdroje sportovních dat.

Možné integrace:

* Garmin,
* Strava,
* Polar,
* Coros,
* Suunto,
* Fitbit.

Každá integrace bude mít samostatné technické a produktové vyhodnocení.

---

# 6. Co nebude součástí první implementované verze

Následující funkce mohou být součástí dlouhodobé vize, ale nepatří do počátečních etap:

* sociální síť,
* veřejný feed,
* soutěžení mezi uživateli,
* marketplace trenérů,
* placené plány externích trenérů,
* živé tréninky,
* videohovory,
* automatická videoanalýza techniky,
* jídelníček,
* počítání kalorií z fotografií,
* zdravotní diagnostika,
* rehabilitační léčebné plány,
* propojení se zaměstnavateli,
* týmová správa sportovců,
* klubové účty,
* dětské účty,
* rodinné účty,
* webová aplikace se všemi funkcemi,
* desktopová aplikace,
* vlastní hardware.

Tyto funkce se mohou později přesunout do samostatných dokumentů Future Ideas.

---

# 7. Funkce, které do produktu nepatří

AI Trainer nebude:

* nahrazovat lékaře,
* diagnostikovat zranění,
* doporučovat užívání zakázaných látek,
* podporovat nebezpečné snižování hmotnosti,
* vytvářet extrémní tréninkové plány bez bezpečnostních omezení,
* zveřejňovat zdravotní data bez výslovného souhlasu,
* prodávat uživatelská zdravotní data,
* měnit významné cíle bez vědomí uživatele,
* předstírat přesnost při nekvalitních datech,
* vydávat obecné AI odpovědi za individuální odbornou diagnózu.

---

# 8. MVP versus kompletní produkt

Pojem MVP v tomto projektu neznamená „malá aplikace bez hlavních funkcí“.

MVP musí ověřit základní produktovou hypotézu:

> Uživatel chce mít AI trenéra, který rozumí jeho sportovnímu rozvrhu, vytvoří mu plán a dokáže ho průběžně upravovat.

Pro ověření této hypotézy není nutné mít:

* všechny wearables,
* vlastní GPS tracker,
* desítky sportovních integrací,
* pokročilé statistiky,
* sociální funkce.

Je však nutné mít:

* sportovní profil,
* cíle,
* plán,
* kalendář,
* workout tracker,
* AI komunikaci,
* úpravu plánu,
* vysvětlení změn,
* potvrzování významných akcí.

Wearables jsou důležitou součástí kompletního produktu, ale nejsou podmínkou ověření jeho hlavní hodnoty.

---

# 9. Podporované sporty v první verzi

První verze nebude obsahovat specializovaný plánovací engine pro každý existující sport.

Musí však podporovat následující kategorie:

## Týmové sporty

Například:

* fotbal,
* florbal,
* basketbal,
* házená,
* volejbal,
* hokej.

Aplikace bude týmové tréninky a zápasy vnímat primárně jako pevně danou zátěž.

## Silový trénink

* vlastní váha,
* domácí vybavení,
* posilovna,
* základní silový rozvoj,
* hypertrofie,
* doplňková příprava.

## Vytrvalostní sporty

* běh,
* cyklistika,
* chůze,
* turistika.

V první verzi mohou být bez vlastního GPS záznamu.

## Lezení

* bouldering,
* sportovní lezení,
* obecný lezecký trénink.

První verze nemusí obsahovat specializovaný lezecký deník ani databázi cest.

## Mobilita a flexibilita

* obecná mobilita,
* sportovně specifická mobilita,
* krátké denní rutiny,
* warm-up,
* cooldown.

## Obecná aktivita

Uživatel může přidat jakoukoliv další aktivitu jako obecný typ, i když pro ni zatím neexistuje specializovaná logika.

---

# 10. Rozhodnutí o šířce cílové skupiny

Dlouhodobou cílovou skupinou jsou všichni sportovně aktivní lidé.

První implementace však musí být navržena a testována především na uživatelích, kteří:

* kombinují více sportů,
* mají pravidelný týmový nebo individuální sport,
* chtějí přidat doplňkový trénink,
* nemají vlastního osobního trenéra,
* potřebují skloubit sport s běžným životem,
* chtějí plán průběžně měnit.

Příklady:

* fotbalista, který chce doma posílit horní část těla,
* florbalista, který chce posílit nohy a zlepšit mobilitu,
* lezec, který chce přidat silový a kompenzační trénink,
* běžec, který chce kombinovat běh s posilováním,
* rekreační sportovec, který střídá více aktivit.

Toto zaměření neomezuje dlouhodobou vizi. Pouze zajišťuje, že první verze bude řešit konkrétní a testovatelný problém.

---

# 11. Kritéria dokončení funkce

Funkce není dokončena pouze tím, že funguje při ideálním scénáři.

Každá významná funkce musí mít:

* produktový popis,
* UX scénář,
* datový model,
* backendové rozhraní, pokud je potřeba,
* mobilní implementaci,
* validační pravidla,
* chybové stavy,
* offline chování,
* oprávnění,
* testy,
* dokumentaci,
* analytické události, pokud jsou relevantní.

AI funkce navíc musí mít:

* definované nástroje,
* strukturovaný výstup,
* pravidla potvrzení,
* bezpečnostní omezení,
* auditní záznam,
* fallback při nedostupnosti modelu.

---

# 12. Kritéria první veřejné beta verze

První beta verze je připravena pro uživatele, pokud:

1. Uživatel se dokáže registrovat a přihlásit.
2. Dokáže vytvořit sportovní profil.
3. Dokáže zadat alespoň jeden cíl.
4. Dokáže přidat pravidelné sportovní aktivity.
5. AI dokáže navrhnout více týdenní plán.
6. Plán se zobrazí v kalendáři.
7. Uživatel může plán upravit před potvrzením.
8. Uživatel může spustit a dokončit workout.
9. Uživatel může nahlásit únavu nebo bolest.
10. AI dokáže navrhnout bezpečnou úpravu workoutu.
11. Významné změny vyžadují potvrzení.
12. Změny plánu jsou dohledatelné a vratné.
13. Aplikace funguje na Androidu i iOS.
14. Základní workout funguje offline.
15. Uživatelská data se neztratí při restartu aplikace.
16. Notifikace otevře správný workout.
17. Základní bezpečnostní a soukromé scénáře jsou otestované.
18. Aplikace jasně komunikuje, že neposkytuje zdravotní diagnózu.

---

# 13. Kritéria dlouhodobého úspěchu

Produkt naplňuje svou vizi, pokud:

* uživatelé pravidelně otevírají dnešní přehled,
* používají vytvořené workouty,
* přijímají nebo upravují AI návrhy,
* vracejí se k aplikaci i po změně rozvrhu,
* dokážou skloubit více sportů,
* mají pocit, že je plán realistický,
* rozumějí důvodům změn,
* důvěřují aplikaci,
* vykazují dlouhodobější pravidelnost,
* nemusí neustále hledat nové plány jinde.

Úspěch nebude měřen počtem vygenerovaných AI zpráv.

AI konverzace je prostředek, nikoliv konečný cíl.

---

# 14. Pravidlo řízení rozsahu

Nový požadavek může být zařazen do aktuální etapy pouze tehdy, pokud:

* je nezbytný pro její hlavní cíl,
* bez něj etapa nevytváří použitelný celek,
* je popsán jeho dopad na data, UX a testování,
* nezpůsobí nepřiměřené rozšíření implementace.

Jinak bude zařazen do:

* pozdější etapy,
* backlogu,
* dokumentu Future Ideas.

Každá etapa musí mít před zahájením zmrazený rozsah.

Během implementace lze rozsah měnit pouze při:

* nalezení bezpečnostního problému,
* nalezení zásadní architektonické chyby,
* zjištění, že bez změny nelze splnit hlavní cíl etapy.

---

# 15. Závěr

AI Trainer je dlouhodobě rozsáhlý produkt zahrnující AI plánování, workout tracking, kalendář, regeneraci, wearables a sportovní data.

Nebude však vytvářen najednou.

Projekt bude postupovat od stabilního technického základu přes lokální workout tracker, účty, sportovní profil a deterministické plánování až k AI trenérovi, adaptivnímu plánu a wearable integracím.

Každá etapa musí být samostatně funkční, testovatelná a použitelná.

Hlavní produktová hodnota vzniká ve chvíli, kdy uživatel může říct:

> Tohle je můj sportovní život, moje cíle a moje omezení.

A aplikace mu odpoví:

> Rozumím. Tady je realistický plán a budu ho s tebou průběžně upravovat.
