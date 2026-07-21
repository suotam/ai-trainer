# AI Trainer – User Personas

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/03-users/user-personas.md`

---

# 1. Účel dokumentu

Tento dokument definuje hlavní typy uživatelů aplikace AI Trainer.

Persony neslouží pouze marketingu. Budou používány při návrhu:

* onboardingu,
* sportovního profilu,
* tréninkového plánování,
* AI komunikace,
* kalendáře,
* workout trackeru,
* notifikací,
* statistik,
* wearable integrací,
* bezpečnostních pravidel,
* testovacích scénářů.

Každá persona reprezentuje reálnou kombinaci:

* sportovních cílů,
* časových možností,
* zkušeností,
* omezení,
* vybavení,
* motivace,
* způsobu používání aplikace.

Cílem není pokrýt všechny možné uživatele. Cílem je zachytit hlavní situace, pro které musí produkt fungovat dobře.

---

# 2. Primární cílová skupina

Primární cílovou skupinou jsou sportovně aktivní lidé, kteří:

* kombinují více sportů,
* nemají osobního trenéra,
* potřebují realistický plán,
* chtějí skloubit sport s běžným životem,
* potřebují plán průběžně upravovat,
* nechtějí sami studovat tréninkovou metodiku,
* chtějí jasné vedení bez zbytečné administrativy.

Typický uživatel nechce pouze evidovat aktivitu.

Chce odpověď na otázky:

* Co mám dnes dělat?
* Jak mám skloubit své sporty?
* Kdy mám posilovat?
* Kdy mám odpočívat?
* Co mám změnit, když jsem unavený?
* Co mám změnit, když mě něco bolí?
* Jak mám upravit plán před zápasem, závodem nebo sportovním víkendem?
* Zlepšuji se?
* Není můj plán příliš náročný?

---

# 3. Persona 1 – Týmový sportovec s doplňkovým posilováním

## 3.1 Základní profil

**Jméno:** Petr
**Věk:** 24 let
**Hlavní sport:** Fotbal
**Úroveň:** Rekreačně soutěžní
**Další cíl:** Zesílit horní polovinu těla
**Tréninkové prostředí:** Doma
**Vybavení:** Hrazda, podlaha, židle
**Čas na doplňkový workout:** 30–45 minut

## 3.2 Běžný týden

* Pondělí: fotbalový trénink
* Středa: fotbalový trénink
* Pátek: fotbalový trénink
* Neděle: zápas
* Práce nebo škola přes den
* Nepravidelný spánek
* Občasný víkendový program

## 3.3 Hlavní potřeby

Petr chce:

* zesílit záda, hrudník, ramena a paže,
* nepřetížit nohy před fotbalem,
* necvičit ve fitku,
* dostat konkrétní plán,
* nemuset řešit periodizaci,
* vědět, co dělat při únavě,
* přizpůsobit plán zápasům.

## 3.4 Typický vstup do AI

> Trénuji třikrát týdně fotbal a v neděli mám zápas. Chtěl bych zesílit horní polovinu těla. Nebudu chodit do fitka, budu cvičit doma a mám hrazdu. Udělej mi plán na další dva měsíce.

## 3.5 Očekávaný výsledek

Aplikace:

* identifikuje fotbalové tréninky jako pevnou zátěž,
* nepřidá těžký trénink nohou,
* navrhne dva krátké workouty horní části těla,
* vhodně rozloží tahové a tlakové cviky,
* zohlední nedělní zápas,
* vytvoří osm týdnů v kalendáři,
* vytvoří konkrétní workout trackery,
* nastaví progresi,
* přidá připomenutí.

## 3.6 Typické změny plánu

Petr může napsat:

* „Dnes jsem hodně unavený.“
* „Zítra máme mimořádný trénink.“
* „Bolí mě pravý biceps.“
* „Nedělní zápas se přesunul na sobotu.“
* „Tento týden nestihnu úterní workout.“
* „Koupil jsem si gymnastické kruhy.“
* „Shyby jsou pro mě zatím moc těžké.“

Aplikace musí umět:

* zkrátit workout,
* snížit počet sérií,
* nahradit nevhodné cviky,
* přesunout workout,
* upravit celý týden,
* aktualizovat budoucí progresi,
* vysvětlit změny.

## 3.7 Rizika

* příliš mnoho tahového objemu,
* přetížení ramen nebo loktů,
* nevhodné posilování nohou před zápasem,
* příliš ambiciózní domácí plán,
* nízká adherence kvůli délce workoutů.

## 3.8 Kritérium úspěchu

Petr používá aplikaci alespoň osm týdnů, dokončuje většinu doplňkových workoutů a nemá pocit, že plán narušuje fotbal.

---

# 4. Persona 2 – Multisportovní florbalista

## 4.1 Základní profil

**Jméno:** Matěj
**Věk:** 25 let
**Hlavní sport:** Florbal
**Vedlejší sport:** Lezení
**Úroveň:** Pokročilý rekreační sportovec
**Cíle:** Silnější nohy, lepší mobilita a flexibilita pro lezení
**Tréninkové prostředí:** Doma
**Vybavení:** Bez vybavení
**Preference:** Krátké ranní a delší odpolední jednotky

## 4.2 Běžný týden

* Pondělí večer: florbal
* Středa večer: florbal
* Neděle: zápas
* Některé víkendy: lezení na skalách
* Ráno má 15–25 minut
* Odpoledne nebo večer má 30–60 minut

## 4.3 Hlavní potřeby

Matěj chce:

* kombinovat dva sporty,
* posílit nohy,
* zlepšit mobilitu kyčlí, kotníků a ramen,
* zlepšit flexibilitu pro lezení,
* nepřetěžovat nohy před florbalem,
* reagovat na víkendové lezení,
* cvičit dvakrát denně, ale udržitelně.

## 4.4 Typický vstup do AI

> Trénuji florbal dvakrát týdně v pondělí a ve středu a v neděli mám zápas. Chci cvičit dvakrát denně, jednou ráno a jednou přes den. Chci zlepšit flexibilitu a mobilitu na lezení a posílit nohy. Cvičím doma bez pomůcek.

## 4.5 Očekávaný výsledek

Aplikace:

* oddělí krátké mobilitní rutiny od hlavních workoutů,
* nevytvoří dva náročné workouty denně,
* rozliší mikrojednotku a hlavní trénink,
* zařadí silový trénink nohou v bezpečné vzdálenosti od zápasu,
* vytvoří mobilitu zaměřenou na lezení,
* započítá florbalovou zátěž,
* nastaví odpočinek,
* umožní přidat lezecký víkend jako jednorázovou událost.

## 4.6 Typické změny plánu

Matěj může napsat:

* „Celý víkend jedu na skály.“
* „V pondělí se florbal ruší.“
* „Po lezení mě bolí předloktí.“
* „Ve středu mám důležitý zápas.“
* „Dnes ráno nestíhám.“
* „Chci na měsíc více zaměřit kotníky.“
* „Mám těžké nohy po florbalu.“

Aplikace musí:

* odstranit nebo upravit tahové zatížení,
* snížit silový objem před lezením,
* přesunout těžký trénink nohou,
* zachovat krátké mobilitní minimum,
* reagovat na únavu z týmového sportu,
* nevyhodnocovat každou vynechanou mikrojednotku jako selhání.

## 4.7 Rizika

* příliš vysoká celková frekvence,
* zaměňování mobility za regeneraci bez zohlednění intenzity,
* nevhodné posilování nohou před zápasem,
* přetížení prstů, loktů a ramen při lezení,
* nereálný požadavek dvou tréninků denně.

## 4.8 Kritérium úspěchu

Matěj dokáže dlouhodobě kombinovat florbal, lezení, mobilitu a sílu bez pocitu, že používá čtyři oddělené plány.

---

# 5. Persona 3 – Rekreační běžkyně s konkrétním závodem

## 5.1 Základní profil

**Jméno:** Anna
**Věk:** 31 let
**Hlavní sport:** Běh
**Cíl:** Uběhnout první půlmaraton
**Úroveň:** Středně pokročilá
**Další aktivita:** Jóga a občasné domácí posilování
**Vybavení:** Podložka, odporová guma
**Časový horizont:** 12 týdnů

## 5.2 Běžný týden

* Pracuje pondělí až pátek
* Může běhat třikrát týdně
* O víkendu má více času
* Občas cestuje
* Nemá přesně stejné volné dny každý týden

## 5.3 Hlavní potřeby

Anna chce:

* realistický běžecký plán,
* postupné navyšování zátěže,
* doplňkové posilování,
* přizpůsobení cestování,
* ochranu před příliš rychlou progresí,
* jasné vysvětlení různých běhů,
* jednoduché sledování pokroku.

## 5.4 Typický vstup do AI

> Za dvanáct týdnů chci uběhnout půlmaraton. Teď běhám přibližně dvakrát týdně pět až osm kilometrů. Můžu trénovat třikrát týdně a o víkendu mám čas na delší běh.

## 5.5 Očekávaný výsledek

Aplikace:

* vytvoří strukturovaný běžecký plán,
* zařadí lehké, tempové a delší běhy,
* postupně navyšuje objem,
* zařadí odlehčovací týdny,
* přidá krátké posilování,
* rozliší pevné a flexibilní workouty,
* ukáže vztah plánu k cílovému závodu.

## 5.6 Typické změny plánu

Anna může napsat:

* „Příští týden budu tři dny služebně pryč.“
* „Dnes mám těžké nohy.“
* „Vynechala jsem dlouhý běh.“
* „Začalo mě pobolívat koleno.“
* „Závod se posunul o dva týdny.“
* „Chci běhat jen ráno.“
* „Dnes mám jen dvacet minut.“

Aplikace musí:

* nepřesouvat slepě všechny vynechané běhy,
* zachovat smysl týdne,
* upravit progresi,
* snížit zátěž při bolesti,
* nepředstírat diagnózu,
* vysvětlit důsledky vynechaného klíčového workoutu.

## 5.7 Rizika

* příliš rychlý růst objemu,
* ignorování bolesti,
* snaha nahrazovat každý vynechaný workout,
* přetížení před závodem,
* nepřesná práce s tempem bez dostatečných dat.

## 5.8 Kritérium úspěchu

Anna se dostane na start zdravá, rozumí jednotlivým typům tréninku a plán se dokáže přizpůsobit změnám bez ztráty dlouhodobého směru.

---

# 6. Persona 4 – Lezec s doplňkovou fyzickou přípravou

## 6.1 Základní profil

**Jméno:** Honza
**Věk:** 28 let
**Hlavní sport:** Sportovní lezení a bouldering
**Cíl:** Zlepšit sílu, mobilitu a kompenzaci
**Úroveň:** Pokročilý
**Další aktivita:** Turistika a občasné běhání
**Vybavení:** Hrazda, gumy, závěsné kruhy
**Prostředí:** Lezecká stěna, domov, skály

## 6.2 Běžný týden

* Dvakrát týdně leze na stěně
* Některé víkendy jezdí na skály
* Chce přidat sílu a kompenzaci
* Termíny lezení se často mění podle počasí a partnerů

## 6.3 Hlavní potřeby

Honza chce:

* nepřetěžovat prsty, lokty a ramena,
* rozumně spojit lezení a posilování,
* přidat antagonistické cviky,
* zlepšit mobilitu ramen a kyčlí,
* reagovat na neplánované lezecké víkendy,
* plánovat regeneraci po těžkém lezení.

## 6.4 Typický vstup do AI

> Lezu dvakrát týdně na stěně a přibližně každý druhý víkend na skalách. Chci zesílit, zlepšit mobilitu a přidat kompenzační cvičení. Doma mám hrazdu, kruhy a odporové gumy.

## 6.5 Očekávaný výsledek

Aplikace:

* započítá lezení jako silovou tahovou a úchopovou zátěž,
* nepřidá nevhodný objem shybů,
* zařadí antagonistické cviky,
* přidá mobilitu,
* navrhne progresi,
* zachová flexibilitu pro venkovní lezení,
* umožní rychle označit lezecký den jako těžký nebo lehký.

## 6.6 Typické změny plánu

Honza může napsat:

* „V sobotu a v neděli jedu lézt.“
* „Dnes jsem lezl těžké bouldery.“
* „Bolí mě vnitřní strana lokte.“
* „Tento týden se na stěnu nedostanu.“
* „Za šest týdnů jedu na lezecký trip.“
* „Chci se zaměřit na vytrvalost.“
* „Včera jsem nečekaně lezl tři hodiny.“

Aplikace musí:

* upravit tahovou a úchopovou zátěž,
* rozlišit intenzitu lezení,
* snížit rizikové cviky při bolesti,
* pracovat s přípravou na trip,
* změnit priority bez přepsání historie.

## 6.7 Rizika

* podcenění lezecké zátěže,
* přetížení loktů a prstů,
* příliš mnoho tahového tréninku,
* generické workouty bez sportovní relevance,
* nevhodná doporučení při bolesti šlach.

## 6.8 Kritérium úspěchu

Honza má pocit, že aplikace rozumí lezení jako reálné zátěži a nepřidává mu pouze obecné fitness workouty.

---

# 7. Persona 5 – Začínající sportovec bez jasného plánu

## 7.1 Základní profil

**Jméno:** Lucie
**Věk:** 35 let
**Hlavní cíl:** Začít se pravidelně hýbat
**Sportovní historie:** Nepravidelná
**Úroveň:** Začátečník
**Vybavení:** Bez vybavení
**Čas:** Třikrát týdně 20–30 minut
**Motivace:** Zlepšit kondici a cítit se lépe

## 7.2 Běžný týden

* Sedavá práce
* Nepravidelný režim
* Málo zkušeností s tréninkem
* Nezná názvy cviků
* Neví, jakou intenzitu zvolit
* Často začne příliš ambiciózně a následně přestane

## 7.3 Hlavní potřeby

Lucie chce:

* jednoduchý začátek,
* krátké workouty,
* jasné instrukce,
* bezpečnou progresi,
* motivaci bez nátlaku,
* minimum nastavování,
* možnost plán snadno změnit.

## 7.4 Typický vstup do AI

> Chci se začít více hýbat a zlepšit kondici. Dlouho jsem pravidelně necvičila. Mám čas asi třikrát týdně na půl hodiny a nechci chodit do fitka.

## 7.5 Očekávaný výsledek

Aplikace:

* nepředpokládá znalost tréninkových pojmů,
* navrhne nízkou počáteční zátěž,
* vytvoří jednoduché workouty,
* přidá dostatek regenerace,
* vysvětlí cviky,
* používá pozitivní a věcný jazyk,
* nezahlcuje statistikami.

## 7.6 Typické změny plánu

Lucie může napsat:

* „Dnes se mi nechce.“
* „Po minulém workoutu mě všechno bolelo.“
* „Nestíhám půl hodiny.“
* „Tento týden jsem necvičila vůbec.“
* „Cvik je pro mě moc těžký.“
* „Nevím, jestli to dělám správně.“
* „Chci raději chodit ven.“

Aplikace musí:

* nabídnout kratší variantu,
* snížit intenzitu,
* nahradit cvik,
* nevyvolávat pocit selhání,
* obnovit plán po pauze,
* dát srozumitelné instrukce,
* doporučit bezpečnější alternativu.

## 7.7 Rizika

* příliš složitý onboarding,
* nevhodná počáteční intenzita,
* odborný jazyk,
* příliš mnoho notifikací,
* demotivující hodnocení adherence,
* generování náročných cviků bez alternativ.

## 7.8 Kritérium úspěchu

Lucie používá aplikaci i po prvních čtyřech týdnech a vnímá plán jako zvládnutelný, nikoliv jako další povinnost.

---

# 8. Persona 6 – Výkonnostně orientovaný uživatel s wearables

## 8.1 Základní profil

**Jméno:** David
**Věk:** 33 let
**Hlavní sport:** Cyklistika a běh
**Úroveň:** Pokročilý amatér
**Cíl:** Zlepšit výkon v závodech
**Zařízení:** Sportovní hodinky, hrudní pás, chytrý telefon
**Data:** Tep, HRV, spánek, GPS aktivity
**Preference:** Detailní analýzy a vysvětlení

## 8.2 Běžný týden

* Trénuje pětkrát až osmkrát týdně
* Má strukturované intervaly
* Sleduje výkonnostní data
* Účastní se závodů
* Aktivně řeší regeneraci
* Používá více sportovních služeb

## 8.3 Hlavní potřeby

David chce:

* propojit tréninkový plán s reálnými daty,
* porovnávat plánovanou a skutečnou zátěž,
* reagovat na spánek a regeneraci,
* chápat důvody změn,
* zachovat kontrolu nad plánem,
* nechat si shrnout data bez ruční analýzy.

## 8.4 Typický vstup do AI

> Mám za osm týdnů cyklistický závod. Trénuji pětkrát týdně a používám hodinky, které měří spánek, HRV a tep. Chci, aby plán reagoval na regeneraci, ale nechci, aby se každý den automaticky měnil.

## 8.5 Očekávaný výsledek

Aplikace:

* vytvoří plán navázaný na závod,
* importuje dostupná data,
* označí kvalitu a původ dat,
* nevydává jednu metriku za absolutní pravdu,
* navrhuje změny transparentně,
* umožní nastavit míru automatizace,
* ukazuje plán versus skutečnost.

## 8.6 Typické změny plánu

David může napsat:

* „HRV je nízké, ale cítím se dobře.“
* „Dnes jsem měl vyšší tep než obvykle.“
* „Hodinky špatně zaznamenaly spánek.“
* „Závod jsem jel výrazně intenzivněji.“
* „Chci tento týden zachovat intervaly.“
* „Importovala se mi aktivita dvakrát.“
* „Příští měsíc měním hodinky.“

Aplikace musí:

* kombinovat subjektivní a automatická data,
* řešit duplicity,
* nepřeceňovat HRV,
* zobrazit nejistotu,
* umožnit ruční korekci,
* udržet interní datový model nezávislý na poskytovateli.

## 8.7 Rizika

* falešná přesnost,
* automatické přizpůsobování podle jedné metriky,
* nekonzistentní data z více zdrojů,
* ztráta důvěry při nevysvětlené změně,
* složitost integrací,
* zahlcení metrikami.

## 8.8 Kritérium úspěchu

David vnímá aplikaci jako nástroj, který data smysluplně interpretuje, nikoliv jako další dashboard s grafy.

---

# 9. Persona 7 – Časově vytížený uživatel s proměnlivým režimem

## 9.1 Základní profil

**Jméno:** Tomáš
**Věk:** 38 let
**Sporty:** Běh, domácí posilování, turistika
**Cíl:** Udržet kondici
**Práce:** Nepravidelný režim a služební cesty
**Vybavení:** Proměnlivé
**Čas:** Některé dny 15 minut, jindy více než hodinu

## 9.2 Běžný týden

Tomáš nemá pevný sportovní režim.

Jeho dostupnost se často mění podle:

* práce,
* cestování,
* rodiny,
* energie,
* počasí,
* přístupu k vybavení.

## 9.3 Hlavní potřeby

Tomáš chce:

* flexibilní plán,
* rychlé alternativy,
* možnost snadno oznámit změny,
* workouty podle aktuálního času,
* plán, který se nerozpadne po vynechání několika dní,
* udržet dlouhodobou pravidelnost.

## 9.4 Typický vstup do AI

> Chci si udržet kondici, ale každý týden mám jiný režim. Někdy můžu trénovat hodinu a někdy jen patnáct minut. Často cestuji a nemám vždy stejné vybavení.

## 9.5 Očekávaný výsledek

Aplikace:

* nevytvoří rigidní plán,
* pracuje s prioritami workoutů,
* označí minimální, standardní a rozšířenou variantu,
* umožní rychlou reorganizaci týdne,
* nabídne workout podle času a vybavení,
* nepřesouvá nekonečně nesplněné aktivity.

## 9.6 Typické změny plánu

Tomáš může napsat:

* „Dnes mám jen patnáct minut.“
* „Do pátku jsem v hotelu.“
* „Nemám žádné vybavení.“
* „Zítra mám nečekaně volno.“
* „Celý týden jsem nestíhal.“
* „O víkendu jdu na celodenní túru.“
* „Dnes jsem místo workoutu šel hodinu pěšky.“

Aplikace musí:

* pracovat s minimální efektivní variantou,
* přepočítat priority,
* započítat náhradní aktivitu,
* nezahlcovat uživatele přesouvanými resty,
* obnovit plán po přerušení.

## 9.7 Rizika

* příliš rigidní plánování,
* zahlcení upozorněními,
* pocit selhání,
* hromadění zmeškaných workoutů,
* nereálné dlouhodobé cíle.

## 9.8 Kritérium úspěchu

Tomáš má pocit, že aplikace pracuje s jeho skutečným životem, ne s ideálním kalendářem.

---

# 10. Persona 8 – Uživatel vracející se po pauze

## 10.1 Základní profil

**Jméno:** Klára
**Věk:** 29 let
**Původní sport:** Běh a posilování
**Aktuální stav:** Návrat po několikaměsíční pauze
**Cíl:** Obnovit pravidelnost a základní kondici
**Zkušenost:** Dříve středně pokročilá
**Současná kapacita:** Nejistá

## 10.2 Hlavní potřeby

Klára chce:

* nezačít na původní úrovni,
* obnovit návyk,
* postupně zjistit aktuální kondici,
* vyhnout se přetížení,
* necítit se hodnocena podle starých výkonů,
* získat realistický návratový plán.

## 10.3 Typický vstup do AI

> Dříve jsem běhala a posilovala čtyřikrát týdně, ale poslední půlrok jsem skoro necvičila. Chci se vrátit, ale nechci to přehnat.

## 10.4 Očekávaný výsledek

Aplikace:

* oddělí historickou a současnou výkonnost,
* vytvoří návratovou fázi,
* použije konzervativní progresi,
* nebude automaticky navazovat na staré hodnoty,
* pravidelně vyhodnotí toleranci zátěže,
* umožní postupné zvýšení frekvence.

## 10.5 Typické změny plánu

Klára může napsat:

* „Workout byl příliš lehký.“
* „Po tréninku mě tři dny bolely svaly.“
* „Chci přidat další den.“
* „Tento týden jsem zase nic nestihla.“
* „Cítím se lépe, než jsem čekala.“
* „Mám strach, že znovu přestanu.“

Aplikace musí:

* upravit progresi,
* nepodléhat jednorázovému přecenění,
* pracovat s adherence,
* nenavyšovat objem příliš rychle,
* komunikovat bez pocitu viny.

## 10.6 Rizika

* použití starých osobních rekordů jako aktuálního základu,
* příliš rychlá progrese,
* demotivující porovnávání s minulostí,
* plán založený na deklarovaných zkušenostech místo aktuální schopnosti.

## 10.7 Kritérium úspěchu

Klára se během prvních osmi týdnů vrátí k pravidelnosti bez výrazného přetížení.

---

# 11. Společné potřeby napříč personami

Přestože se persony liší, většina uživatelů potřebuje:

* rychle zjistit dnešní plán,
* chápat důvod jednotlivých workoutů,
* jednoduše nahlásit změnu,
* upravit plán bez ručního přesouvání každé položky,
* otevřít konkrétní workout z kalendáře nebo notifikace,
* zaznamenat skutečně provedenou aktivitu,
* zachovat historii,
* vrátit AI změnu,
* používat aplikaci i bez připojení,
* mít kontrolu nad svými daty.

---

# 12. Rozdíly, které musí produkt respektovat

Produkt nesmí předpokládat, že všichni uživatelé:

* chtějí vysoký výkon,
* mají pravidelný kalendář,
* používají wearables,
* rozumějí tréninkovým pojmům,
* chtějí sledovat mnoho metrik,
* mají přístup do fitka,
* mají stejné vybavení každý týden,
* provozují pouze jeden sport,
* chtějí automatické změny,
* chtějí trénovat co nejčastěji.

Aplikace musí být schopna přizpůsobit:

* hloubku vysvětlení,
* množství zobrazených dat,
* intenzitu notifikací,
* míru automatizace,
* délku workoutů,
* používanou terminologii,
* složitost plánu,
* způsob hodnocení pokroku.

---

# 13. Primární persony pro první beta verzi

Pro první beta verzi mají nejvyšší prioritu:

1. Týmový sportovec s doplňkovým posilováním.
2. Multisportovní florbalista.
3. Lezec s doplňkovou fyzickou přípravou.
4. Časově vytížený uživatel s proměnlivým režimem.
5. Začínající sportovec bez jasného plánu.

Tyto persony nejlépe ověřují hlavní produktovou hypotézu:

> Aplikace dokáže propojit pevně dané sportovní aktivity, doplňkový trénink, reálný život a průběžné změny do jednoho adaptivního plánu.

Běžkyně se závodem a výkonnostní uživatel s wearables zůstávají důležité, ale některé jejich pokročilé scénáře budou plně podporovány až v pozdějších etapách.

---

# 14. Negativní persony

Negativní persona představuje uživatele, pro kterého produkt není primárně určen.

## 14.1 Profesionální sportovec s realizačním týmem

Profesionální sportovec, který má:

* hlavního trenéra,
* kondičního trenéra,
* fyzioterapeuta,
* lékařský tým,
* detailní individuální diagnostiku,

nemá být v první verzi hlavním cílovým uživatelem.

AI Trainer může později sloužit jako podpůrný nástroj, ale nesmí nahrazovat profesionální realizační tým.

## 14.2 Uživatel hledající zdravotní diagnózu

Produkt není určen pro uživatele, který očekává:

* diagnostiku zranění,
* léčebný plán,
* rehabilitaci bez odborného vedení,
* vyhodnocení akutních zdravotních příznaků.

Aplikace musí jasně vymezit hranice a v rizikových situacích doporučit odbornou pomoc.

## 14.3 Uživatel zaměřený pouze na sociální síť

Uživatel, jehož hlavním cílem je:

* veřejně sdílet všechny aktivity,
* sledovat feed,
* soutěžit s přáteli,
* sbírat lajky,

není primární personou.

Sociální funkce nejsou jádrem produktu.

## 14.4 Uživatel hledající pouze jídelníček

Výživa může být v budoucnu doplňkovou oblastí, ale AI Trainer není primárně:

* kalorická kalkulačka,
* jídelníček,
* aplikace pro vážení jídla,
* databáze receptů.

---

# 15. Použití person při vývoji

Každá významná funkce musí být vyhodnocena minimálně proti třem relevantním personám.

Příklad:

Funkce „AI upraví dnešní workout podle únavy“ musí být ověřena minimálně pro:

* Petra, který má večer fotbal,
* Lucii, která je začátečník,
* Davida, který má nízké HRV, ale subjektivně se cítí dobře.

Každý návrh musí odpovědět:

* Jak funkci uživatel objeví?
* Jaké informace musí zadat?
* Jaké informace už systém zná?
* Jaký výsledek očekává?
* Co se stane při nedostatku dat?
* Co se stane při konfliktu informací?
* Jak se změna vysvětlí?
* Je nutné potvrzení?
* Lze změnu vrátit?
* Jak bude funkce fungovat offline?

---

# 16. Testovací matice person

| Funkce                |     Petr |     Matěj |      Anna |     Honza |    Lucie |    David |     Tomáš |     Klára |
| --------------------- | -------: | --------: | --------: | --------: | -------: | -------: | --------: | --------: |
| Více sportů           |      Ano |       Ano |  Částečně |       Ano |       Ne |      Ano |       Ano |  Částečně |
| Pevné týmové tréninky |      Ano |       Ano |        Ne |        Ne |       Ne |       Ne |        Ne |        Ne |
| Domácí workout        |      Ano |       Ano |       Ano |       Ano |      Ano | Částečně |       Ano |       Ano |
| Adaptace na únavu     |      Ano |       Ano |       Ano |       Ano |      Ano |      Ano |       Ano |       Ano |
| Adaptace na bolest    |      Ano |       Ano |       Ano |       Ano |      Ano |      Ano |       Ano |       Ano |
| Proměnlivý rozvrh     | Částečně |  Částečně |       Ano |       Ano |      Ano | Částečně |       Ano |       Ano |
| Závodní termín        | Částečně |       Ano |       Ano |  Částečně |       Ne |      Ano |        Ne |        Ne |
| Wearable data         |       Ne | Volitelně | Volitelně | Volitelně |       Ne |      Ano | Volitelně | Volitelně |
| Začátečnické UX       |       Ne |        Ne |        Ne |        Ne |      Ano |       Ne |  Částečně |  Částečně |
| Návrat po pauze       |       Ne |        Ne |        Ne |        Ne | Částečně |       Ne |  Částečně |       Ano |
| Offline workout       |      Ano |       Ano |       Ano |       Ano |      Ano |      Ano |       Ano |       Ano |

Tato matice se bude postupně rozšiřovat podle konkrétních funkcí.

---

# 17. Otevřené produktové otázky

Následující otázky budou řešeny v dalších dokumentech:

* Jak hluboký má být onboarding pro začátečníka a pokročilého?
* Jak bude aplikace rozlišovat pevnou a flexibilní aktivitu?
* Jak bude uživatel určovat prioritu cíle?
* Jak se bude zaznamenávat bolest?
* Jak se bude odlišovat únava, bolest a zranění?
* Jak budou fungovat krátké mikro-workouty?
* Jak bude systém pracovat s více workouty v jednom dni?
* Jak se bude zacházet s vynechanými aktivitami?
* Jaká míra automatizace bude výchozí?
* Jaké sporty dostanou specializovaný plánovací model jako první?
* Jak budou reprezentovány sportovní zápasy, závody a výjezdy?
* Jak bude aplikace komunikovat nejistotu?
* Jak se bude přizpůsobovat složitost rozhraní zkušenosti uživatele?

Tyto otázky nejsou blokátorem tohoto dokumentu. Budou rozpracovány v produktové specifikaci, UX flows, doménovém modelu a AI specifikaci.

---

# 18. Závěr

AI Trainer musí fungovat pro široké spektrum sportovců, ale nesmí se od začátku snažit řešit všechny scénáře stejně hluboce.

První verze se zaměří především na lidi, kteří:

* kombinují více sportů,
* chtějí přidat doplňkový trénink,
* potřebují realistický kalendář,
* často mění plán podle skutečného života,
* chtějí komunikovat přirozeným jazykem,
* nemají osobního trenéra.

Persony budou sloužit jako praktický test každého dalšího rozhodnutí.

Pokud funkce funguje pouze pro ideálního uživatele s pravidelným režimem, jedním sportem, perfektními daty a neomezeným časem, není dostatečně navržena pro AI Trainer.
