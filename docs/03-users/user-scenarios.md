# AI Trainer – User Scenarios

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/03-users/user-scenarios.md`

---

# 1. Účel dokumentu

Tento dokument definuje hlavní uživatelské situace, které musí aplikace AI Trainer zvládat.

Scénáře nejsou omezeny pouze na persony popsané v dokumentu `user-personas.md`.

Persony slouží jako testovací reprezentanti různých potřeb, nikoliv jako seznam jediných podporovaných typů uživatelů.

AI Trainer je navržen pro široké spektrum sportovně aktivních lidí bez ohledu na:

* konkrétní sport,
* počet provozovaných sportů,
* úroveň zkušeností,
* věk v rámci podporované cílové skupiny,
* dostupné vybavení,
* tréninkové prostředí,
* pravidelnost rozvrhu,
* používání wearables,
* hlavní motivaci,
* typ cíle.

Pokud aplikace nezná konkrétní sport do hloubky, musí ho stále umět reprezentovat jako obecnou sportovní aktivitu a pracovat minimálně s:

* časem,
* délkou,
* intenzitou,
* frekvencí,
* subjektivní náročností,
* zatíženými částmi těla,
* potřebou regenerace,
* pevností termínu,
* vztahem k ostatním aktivitám.

Specializovaná sportovní logika rozšiřuje kvalitu doporučení, ale její absence nesmí znemožnit používání produktu.

---

# 2. Pravidla pro použití scénářů

Každý scénář musí být později rozpracován do:

* UX flow,
* datového modelu,
* backendových operací,
* AI nástrojů,
* validačních pravidel,
* potvrzovacích mechanismů,
* offline chování,
* chybových stavů,
* testovacích případů.

Scénář není považován za podporovaný pouze proto, že AI dokáže napsat textovou odpověď.

Podporovaný scénář musí vést ke konkrétním a strukturovaným změnám v aplikaci.

Například požadavek:

> Příští víkend jedu na skály.

není vyřešen odpovědí:

> Doporučuji před víkendem odpočívat.

Aplikace musí být schopna:

* zjistit, kterých dnů se změna týká,
* přidat nebo upravit události,
* vyhodnotit konflikty,
* upravit související workouty,
* zobrazit návrh změn,
* změny po potvrzení zapsat,
* zachovat historii,
* umožnit návrat změny.

---

# 3. Scénář 1 – První spuštění aplikace

## Kontext

Uživatel aplikaci otevírá poprvé.

Nemá účet, profil ani plán.

## Cíl uživatele

Pochopit, co aplikace dělá, a co nejrychleji získat první použitelný plán.

## Očekávaný průběh

1. Aplikace stručně vysvětlí hlavní hodnotu.
2. Uživatel vytvoří účet nebo pokračuje podporovaným způsobem přihlášení.
3. Aplikace zjistí základní cíle a sportovní situaci.
4. Uživatel může odpovídat:

   * formulářem,
   * konverzací,
   * kombinací obou.
5. Aplikace vytvoří strukturovaný sportovní profil.
6. Uživatel profil zkontroluje.
7. Aplikace navrhne první plán.
8. Uživatel plán potvrdí nebo upraví.
9. Plán se zobrazí v kalendáři.
10. Domovská obrazovka ukáže nejbližší aktivitu.

## Povinné vlastnosti

* onboarding nesmí vyžadovat znalost tréninkové terminologie,
* nesmí být nutné vyplnit všechny možné údaje,
* chybějící údaje mohou být doplněny později,
* aplikace musí rozlišovat povinné a volitelné informace,
* uživatel musí vědět, proč jsou citlivé údaje požadovány.

---

# 4. Scénář 2 – Uživatel popíše celý sportovní režim jednou zprávou

## Vstup

> Třikrát týdně trénuji fotbal a v neděli mám zápas. Chci zesílit horní polovinu těla, budu cvičit doma a mám hrazdu. Udělej mi plán na další dva měsíce.

## Očekávané chování

Aplikace musí ze zprávy rozpoznat minimálně:

* hlavní sport,
* počet pravidelných tréninků,
* zápasový den,
* doplňkový cíl,
* tréninkové prostředí,
* dostupné vybavení,
* délku plánu.

Pokud nejsou známé konkrétní dny fotbalových tréninků, aplikace položí cílenou doplňující otázku.

Nemá znovu žádat informace, které už uživatel uvedl.

## Výsledek

Systém vytvoří:

* pravidelné sportovní aktivity,
* cíl,
* tréninkový blok,
* konkrétní workouty,
* kalendářní události,
* progresi,
* tracker pro každý workout.

Před uložením zobrazí:

* týdenní strukturu,
* počet doplňkových workoutů,
* délku jednotek,
* hlavní důvody rozložení,
* případné předpoklady.

---

# 5. Scénář 3 – Uživatel provozuje neznámý nebo méně běžný sport

## Kontext

Uživatel uvede sport, pro který aplikace nemá specializovaný plánovací modul.

Příklady:

* lakros,
* ultimate frisbee,
* šerm,
* veslování dračích lodí,
* parkour,
* orientační běh,
* tanec,
* bojový sport,
* akrobatická disciplína,
* regionální nebo nově vznikající sport.

## Očekávané chování

Aplikace nesmí sport odmítnout ani uživatele nutit vybrat nepřesnou náhradu.

Musí zjistit nebo odvodit:

* typ zátěže,
* délku běžné jednotky,
* intenzitu,
* pravidelnost,
* soutěžní nebo rekreační charakter,
* zatížené části těla,
* nároky na sílu,
* nároky na vytrvalost,
* nároky na mobilitu,
* potřebu regenerace,
* pevnost termínů.

## Výsledek

Sport bude uložen jako obecný sportovní typ s uživatelsky zadaným názvem a strukturovanými vlastnostmi.

AI může poskytovat obecnější doporučení a musí přiznat, pokud nemá dostatek sportovně specifických dat.

---

# 6. Scénář 4 – Vytvoření cíle

## Příklady vstupů

* „Chci zvládnout deset shybů.“
* „Za tři měsíce běžím půlmaraton.“
* „Chci být pohyblivější při lezení.“
* „Chci pravidelně cvičit třikrát týdně.“
* „Chci zesílit nohy.“
* „Chci se vrátit do kondice.“
* „Chci se připravit na lyžařskou sezónu.“
* „Chci se méně zadýchávat při turistice.“

## Očekávané chování

Aplikace musí rozlišit:

* výkonnostní cíl,
* termínovaný cíl,
* návykový cíl,
* kvalitativní cíl,
* obecný směr,
* cíl vyžadující doplnění měřitelného ukazatele.

AI nesmí předstírat, že každý cíl lze přesně vyjádřit jedním číslem.

## Výsledek

Cíl obsahuje:

* název,
* popis,
* prioritu,
* případný termín,
* výchozí stav,
* cílový stav nebo kvalitativní kritérium,
* související metriky,
* navázané aktivity,
* způsob vyhodnocení.

---

# 7. Scénář 5 – Uživatel má více současných cílů

## Vstup

> Chci zesílit nohy, zlepšit mobilitu pro lezení a zároveň se připravit na florbalovou sezonu.

## Očekávané chování

Aplikace musí:

* rozpoznat více cílů,
* zjistit jejich priority,
* identifikovat konflikty,
* vysvětlit kapacitní omezení,
* navrhnout realistický poměr zaměření.

Nemá automaticky považovat všechny cíle za stejně důležité.

## Výsledek

Plán obsahuje:

* hlavní cíl,
* vedlejší cíle,
* rozdělení priorit,
* očekávané kompromisy,
* termín revize priorit.

---

# 8. Scénář 6 – Dnešní workout z notifikace

## Kontext

Ráno přijde upozornění:

> Dnes tě čeká 25 minut mobility a večerní florbal.

## Očekávaný průběh

1. Uživatel otevře notifikaci.
2. Aplikace se otevře přímo na dnešním přehledu nebo konkrétním workoutu.
3. Uživatel vidí:

   * název,
   * délku,
   * účel,
   * plánované cviky,
   * vztah k dalším aktivitám.
4. Jedním tlačítkem spustí tracker.

## Chybové stavy

* workout byl mezitím přesunut,
* notifikace je stará,
* uživatel je offline,
* workout už byl dokončen,
* plán byl změněn na jiném zařízení.

Aplikace musí vždy zobrazit aktuální stav, ne slepě otevřít zastaralou verzi.

---

# 9. Scénář 7 – Uživatel je dnes unavený

## Vstup

> Dnes jsem hodně unavený.

## Potřebný kontext

Systém může zohlednit:

* dnešní plán,
* poslední aktivity,
* subjektivní únavu,
* spánek,
* případná wearable data,
* zítřejší a víkendové aktivity,
* důležitost dnešní jednotky.

## Očekávané chování

AI nesmí automaticky zrušit workout bez dalšího vyhodnocení.

Může nabídnout:

* kratší variantu,
* snížení počtu sérií,
* snížení intenzity,
* mobilitu nebo regeneraci,
* přesunutí workoutu,
* úplný odpočinek.

## Výsledek

Uživatel uvidí:

* navrhovanou změnu,
* původní workout,
* upravený workout,
* důvod,
* dopad na zbytek týdne,
* možnost potvrdit nebo odmítnout.

---

# 10. Scénář 8 – Uživatel hlásí bolest

## Vstupy

* „Bolí mě pravý biceps.“
* „Při dřepu mě píchá v koleni.“
* „Po běhu mě bolí achilovka.“
* „Mám ztuhlá záda.“
* „Bolí mě rameno při zvednutí ruky.“

## Očekávané chování

Aplikace musí rozlišit mezi:

* běžnou svalovou únavou,
* bolestí po tréninku,
* neobvyklou bolestí,
* ostrou nebo zhoršující se bolestí,
* možným akutním problémem.

AI nesmí stanovovat diagnózu.

Může se doptat na:

* intenzitu,
* charakter bolesti,
* vznik,
* pohyby, které bolest zhoršují,
* zda je přítomná i v klidu,
* zda došlo k úrazu.

## Bezpečnostní pravidlo

Při závažných nebo rizikových příznacích aplikace nesmí pokračovat v běžné úpravě workoutu jako by šlo pouze o únavu.

## Možné výsledky

* odstranění rizikového cviku,
* nahrazení bezpečnější alternativou,
* zkrácení workoutu,
* vynechání zatížené oblasti,
* doporučení odpočinku,
* doporučení odborné konzultace.

Změna musí být označena jako dočasná, pokud uživatel výslovně nezmění své dlouhodobé omezení.

---

# 11. Scénář 9 – Uživatel nestíhá celý workout

## Vstup

> Dnes mám jen patnáct minut.

## Očekávané chování

Aplikace vytvoří zkrácenou variantu podle priority obsahu.

Nemá pouze mechanicky odstranit poslední cviky.

Musí určit:

* hlavní účel workoutu,
* nejdůležitější cviky,
* minimální užitečný objem,
* vhodný warm-up,
* zda je lepší workout přesunout.

## Výsledek

Uživatel může porovnat:

* původní délku,
* novou délku,
* odstraněné části,
* zachovaný účel.

---

# 12. Scénář 10 – Uživatel vynechal workout

## Kontext

Plánovaný workout nebyl dokončen.

## Očekávané chování

Aplikace nesmí automaticky přesunout každý vynechaný workout na další den.

Musí vyhodnotit:

* důvod vynechání,
* důležitost workoutu,
* zbývající část týdne,
* kumulaci zátěže,
* blížící se zápas nebo závod,
* možnost bezpečného přesunu.

## Možné výsledky

* workout se přesune,
* workout se zkrátí,
* workout se spojí s jinou jednotkou,
* workout se vynechá bez náhrady,
* upraví se následující progres.

Aplikace nesmí uživatele trestat jazykem ani vytvářet pocit selhání.

---

# 13. Scénář 11 – Zrušený týmový trénink

## Vstup

> Ve středu nám zrušili florbal.

## Očekávané chování

Systém musí:

* najít konkrétní událost,
* označit ji jako zrušenou,
* vyhodnotit uvolněnou kapacitu,
* rozhodnout, zda je vhodné doplnit jiný workout,
* zohlednit celý týden.

Aplikace nemá automaticky zaplnit každý volný čas tréninkem.

## Výsledek

AI může navrhnout:

* zachovat odpočinek,
* přesunout jiný workout,
* přidat lehkou technickou jednotku,
* přidat mobilitu,
* ponechat týden beze změny.

---

# 14. Scénář 12 – Změna termínu zápasu nebo závodu

## Vstup

> Nedělní zápas se přesunul na sobotu.

## Očekávané chování

Aplikace musí:

* změnit pevnou událost,
* zkontrolovat páteční a sobotní zátěž,
* upravit předzápasovou přípravu,
* případně upravit regeneraci po zápase,
* zkontrolovat konflikt dalších aktivit.

Významnější změna více workoutů musí být uživateli ukázána jako souhrnný návrh.

---

# 15. Scénář 13 – Neplánovaný sportovní víkend

## Vstup

> Celý víkend jedu na skály.

## Očekávané chování

Systém musí zjistit:

* přesné dny,
* očekávanou intenzitu,
* zda jde o lezení, turistiku nebo kombinaci aktivit,
* zda uživatel chce událost považovat za hlavní zátěž týdne.

## Výsledek

Aplikace může:

* přidat víkendové aktivity,
* snížit tahové a úchopové zatížení před odjezdem,
* přesunout silový workout,
* upravit pondělní regeneraci,
* zachovat lehkou mobilitu,
* změnit týdenní zátěž.

Změna se musí projevit v kalendáři i workout trackerech.

---

# 16. Scénář 14 – Cestování bez vybavení

## Vstup

> Příští týden budu v hotelu a nebudu mít hrazdu ani činky.

## Očekávané chování

Aplikace musí:

* vytvořit dočasnou změnu vybavení,
* určit období platnosti,
* najít ovlivněné workouty,
* nahradit cviky,
* zachovat hlavní účel plánu.

Po návratu se má automaticky obnovit původní sada vybavení, pokud uživatel neurčí jinak.

---

# 17. Scénář 15 – Nově zakoupené vybavení

## Vstup

> Koupil jsem si kettlebell 20 kg.

## Očekávané chování

Aplikace musí rozlišit:

* trvalou změnu vybavení,
* možnost přidání nových cviků,
* nutnost ověřit zkušenost uživatele,
* vhodnost hmotnosti.

Nemá automaticky přepsat všechny workouty.

## Výsledek

AI může navrhnout:

* které budoucí workouty lze zlepšit,
* nové alternativy cviků,
* adaptační období,
* technicky jednodušší začátek.

---

# 18. Scénář 16 – Uživatel chce změnit celý dlouhodobý cíl

## Vstup

> Půlmaraton už běžet nechci. Chci se teď zaměřit na lezení.

## Očekávané chování

Jde o významnou změnu.

Aplikace musí:

* identifikovat původní cíl,
* zjistit nový cíl,
* zobrazit dopad na existující plán,
* navrhnout ukončení nebo archivaci původního plánu,
* zachovat historii,
* vytvořit nový návrh.

Změna nesmí být provedena bez potvrzení.

---

# 19. Scénář 17 – Více workoutů během jednoho dne

## Kontext

Uživatel chce ráno mobilitu a odpoledne silový nebo týmový trénink.

## Očekávané chování

Aplikace musí rozlišovat:

* hlavní workout,
* doplňkový workout,
* mikro-workout,
* warm-up,
* recovery jednotku,
* pravidelnou sportovní aktivitu.

Nemá sčítat všechny jednotky pouze podle počtu.

Musí vyhodnocovat jejich charakter a vzájemné působení.

## Výsledek

Denní přehled jasně ukáže:

* pořadí,
* délku,
* prioritu,
* možnost vynechání,
* vztah mezi jednotkami.

---

# 20. Scénář 18 – Uživatel dokončí jiný workout, než byl naplánovaný

## Kontext

Místo plánovaného běhu uživatel hrál fotbal.

## Očekávané chování

Systém musí zachovat:

* původní plán,
* skutečně provedenou aktivitu,
* rozdíl mezi nimi,
* případný důvod.

AI musí vyhodnotit, zda náhradní aktivita:

* plně nahradila účel,
* částečně nahradila účel,
* vytvořila jiný druh zátěže,
* vyžaduje úpravu dalších dnů.

---

# 21. Scénář 19 – Uživatel se vrací po několikatýdenní pauze

## Vstup

> Tři týdny jsem vůbec necvičil. Jak mám pokračovat?

## Očekávané chování

Aplikace nesmí automaticky pokračovat přesně tam, kde plán skončil.

Musí vyhodnotit:

* délku pauzy,
* důvod pauzy,
* předchozí úroveň,
* aktuální stav,
* případnou nemoc nebo zranění,
* blížící se cíle.

## Výsledek

Může vytvořit:

* návratový týden,
* snížený objem,
* kontrolní workout,
* postupnou obnovu,
* aktualizovanou progresi.

---

# 22. Scénář 20 – Uživatel chce plán ručně upravit

## Kontext

Uživatel nechce vše řešit přes chat.

## Očekávané možnosti

Uživatel musí být schopen ručně:

* přesunout workout,
* změnit čas,
* změnit délku,
* odstranit budoucí instanci,
* změnit cvik,
* změnit počet sérií,
* přidat aktivitu,
* upravit cíl,
* změnit vybavení,
* změnit dostupnost.

AI může následně upozornit na dopady, ale nesmí uživateli bránit v legitimní ruční změně.

---

# 23. Scénář 21 – AI navrhne změnu více dnů

## Kontext

Jedna změna ovlivní celý týden nebo tréninkový blok.

## Očekávané zobrazení

Návrh musí obsahovat:

* stručné shrnutí,
* seznam ovlivněných dnů,
* původní a nový stav,
* důvody,
* očekávaný přínos,
* případné kompromisy,
* možnost potvrdit vše,
* možnost potvrdit jen část,
* možnost odmítnout,
* možnost návrh dále probrat.

---

# 24. Scénář 22 – Uživatel vrátí AI změnu

## Kontext

Uživatel potvrdil úpravu, ale následně ji chce vzít zpět.

## Očekávané chování

Aplikace musí:

* najít konkrétní změnu,
* zobrazit její dopady,
* obnovit předchozí verzi,
* zachovat auditní historii,
* upozornit na případné následné změny, které na ní závisejí.

Vrácení změny nesmí odstranit dokončené historické aktivity.

---

# 25. Scénář 23 – Konflikt dat z více zařízení

## Kontext

Uživatel upraví workout offline na telefonu a zároveň dojde ke změně na jiném zařízení.

## Očekávané chování

Systém musí:

* rozlišit typy změn,
* automaticky sloučit nekolidující údaje,
* zachovat obě verze při skutečném konfliktu,
* nevymazat workout data bez vědomí uživatele,
* zobrazit srozumitelnou volbu při nutnosti rozhodnutí.

---

# 26. Scénář 24 – Workout bez internetu

## Kontext

Uživatel je bez signálu.

## Očekávané chování

Musí být možné:

* otevřít synchronizovaný workout,
* spustit tracker,
* zapisovat výsledky,
* měřit lokální časovače,
* dokončit workout,
* přidat poznámku,
* uložit vše lokálně.

Po obnovení internetu se data synchronizují.

AI funkce mohou být označeny jako dočasně nedostupné.

---

# 27. Scénář 25 – AI služba je nedostupná

## Kontext

OpenAI nebo jiná AI služba neodpovídá.

## Očekávané chování

Aplikace nesmí znemožnit běžné používání.

Uživatel může stále:

* zobrazit kalendář,
* spustit workout,
* dokončit workout,
* ručně upravit plán,
* zaznamenat únavu nebo bolest,
* uložit požadavek na pozdější zpracování, pokud je tato funkce podporována.

Aplikace musí jasně sdělit, že je nedostupná AI funkce, ne celý účet nebo všechna data.

---

# 28. Scénář 26 – Import aktivity z wearables

## Kontext

Do aplikace přijde aktivita z externího zdroje.

## Očekávané chování

Systém musí:

* identifikovat zdroj,
* normalizovat data,
* detekovat možné duplicity,
* spojit aktivitu s plánovaným workoutem, pokud odpovídá,
* zachovat původ dat,
* umožnit ruční opravu.

Nesmí automaticky předpokládat, že importovaná aktivita přesně odpovídá plánovanému workoutu.

---

# 29. Scénář 27 – Wearable data odporují subjektivnímu pocitu

## Vstup

> Hodinky ukazují špatnou regeneraci, ale cítím se dobře.

Nebo:

> Hodinky říkají, že jsem odpočatý, ale jsem úplně vyčerpaný.

## Očekávané chování

Aplikace nesmí slepě upřednostnit jednu metriku.

Musí pracovat s:

* kvalitou dat,
* dlouhodobým trendem,
* subjektivním hodnocením,
* významem dnešního workoutu,
* případnými příznaky bolesti nebo nemoci.

Výsledek musí komunikovat nejistotu.

---

# 30. Scénář 28 – Uživatel neví, co chce

## Vstup

> Chci se prostě začít hýbat.

## Očekávané chování

AI položí několik jednoduchých konkrétních otázek:

* kolik času má,
* co ho baví,
* zda má omezení,
* kde chce cvičit,
* kolikrát týdně chce začít.

Nemá uživatele zahltit kompletním sportovním dotazníkem.

## Výsledek

Aplikace vytvoří jednoduchý počáteční plán a naplánuje pozdější revizi podle skutečných zkušeností.

---

# 31. Scénář 29 – Uživatel požaduje nerealistický plán

## Vstup

> Nikdy jsem necvičil a chci trénovat dvakrát denně každý den.

Nebo:

> Za měsíc chci uběhnout maraton, teď neběhám.

## Očekávané chování

AI nesmí požadavek slepě splnit.

Musí:

* vysvětlit rizika,
* navrhnout bezpečnější variantu,
* zachovat motivaci uživatele,
* případně rozdělit dlouhodobý cíl na etapy.

---

# 32. Scénář 30 – Uživatel chce extrémně snížit hmotnost

## Kontext

Požadavek může být zdravotně rizikový.

## Očekávané chování

Aplikace nesmí podporovat:

* extrémní trénink,
* nebezpečný kalorický deficit,
* dehydrataci,
* rychlé shazování hmotnosti,
* trestání jídla pohybem.

Musí držet hranici mezi obecným fitness vedením a zdravotním či výživovým poradenstvím.

---

# 33. Scénář 31 – Uživatel chce vysvětlit doporučení

## Vstupy

* „Proč dnes necvičím nohy?“
* „Proč jsi mi zkrátil workout?“
* „Proč mám tento týden méně běhat?“
* „Z čeho usuzuješ, že jsem unavený?“

## Očekávané chování

Aplikace musí odpovědět konkrétně s odkazem na relevantní data.

Například:

* předchozí aktivita,
* spánek,
* uživatelský vstup,
* blížící se zápas,
* vývoj zátěže.

Nemá zveřejňovat interní technické prompty nebo nepodložené domněnky.

---

# 34. Scénář 32 – Uživatel nesouhlasí s AI

## Vstup

> Ne, těžký workout chci nechat dnes.

## Očekávané chování

AI musí respektovat rozhodnutí uživatele, pokud nejde o situaci, kde je nutné výrazné bezpečnostní varování.

Může:

* upozornit na riziko,
* nabídnout kompromis,
* požádat o potvrzení,
* zaznamenat rozhodnutí.

Nemá se opakovaně snažit uživatele přemluvit.

---

# 35. Scénář 33 – Pravidelná týdenní revize

## Kontext

Na konci týdne aplikace vyhodnotí plán.

## Obsah revize

* plánované aktivity,
* dokončené aktivity,
* změny,
* subjektivní pocity,
* pokrok,
* problémy,
* zátěž dalšího týdne.

## Očekávaný výsledek

Aplikace nabídne stručné shrnutí:

* co se podařilo,
* co ovlivnilo plán,
* co se mění příští týden,
* zda je nutné něco doplnit.

Revize nesmí být založena pouze na procentu dokončení.

---

# 36. Scénář 34 – Aktualizace plánu podle dlouhodobého pokroku

## Kontext

Uživatel několik týdnů pravidelně plní plán.

## Očekávané chování

Systém může navrhnout:

* zvýšení objemu,
* zvýšení obtížnosti,
* těžší variantu cviku,
* změnu frekvence,
* testovací workout,
* odlehčovací týden.

Progrese musí vycházet ze skutečně provedených dat, ne pouze z času uplynulého v kalendáři.

---

# 37. Scénář 35 – Uživatel se nezlepšuje

## Kontext

Metriky nebo subjektivní hodnocení ukazují stagnaci.

## Očekávané chování

Aplikace musí posoudit možné příčiny:

* nepravidelnost,
* příliš nízkou zátěž,
* příliš vysokou zátěž,
* nedostatečnou regeneraci,
* změnu techniky,
* nevhodnou metriku,
* nereálný časový horizont.

Nemá automaticky přidat více tréninku.

---

# 38. Scénář 36 – Dočasné zdravotní omezení

## Vstup

> Lékař mi řekl, že dva týdny nemám běhat.

## Očekávané chování

Systém musí:

* uložit dočasné omezení,
* zaznamenat období platnosti,
* odstranit nebo upravit ovlivněné aktivity,
* respektovat uvedené odborné doporučení,
* nabídnout pouze kompatibilní alternativy,
* po skončení období neobnovit vysokou zátěž skokově.

---

# 39. Scénář 37 – Trvalá změna režimu

## Vstup

> Od příštího měsíce budu mít florbal už jen jednou týdně.

## Očekávané chování

Aplikace musí rozlišit:

* jednorázovou změnu,
* dočasnou změnu,
* trvalou změnu pravidelného rozvrhu.

Následně aktualizuje zdroj pravdy pro pravidelnou aktivitu a připraví návrh změn budoucího plánu.

---

# 40. Scénář 38 – Sezónní sport

## Kontext

Uživatel část roku běhá, v zimě lyžuje a na jaře se připravuje na lezení.

## Očekávané chování

Aplikace musí umět pracovat s:

* aktivní sezonou,
* přípravným obdobím,
* přechodným obdobím,
* dočasně neaktivním sportem,
* změnou priorit.

Sport se nesmí při ukončení sezony smazat z historie.

---

# 41. Scénář 39 – Uživatel změní časové možnosti

## Vstup

> Odteď můžu cvičit jen ráno před prací a maximálně 30 minut.

## Očekávané chování

Jde o trvalejší změnu dostupnosti.

Systém musí:

* aktualizovat profil,
* identifikovat nekompatibilní workouty,
* zkrátit nebo rozdělit jednotky,
* navrhnout nový týdenní rytmus,
* ukázat dopad na cíle.

---

# 42. Scénář 40 – Uživatel přidá libovolnou vlastní aktivitu

## Kontext

Uživatel chce přidat aktivitu, která není v katalogu.

## Očekávané chování

Musí být možné zadat:

* vlastní název,
* typ zátěže,
* datum a čas,
* délku,
* intenzitu,
* případné zatížené oblasti,
* opakování,
* pevnost termínu.

Uživatelský název musí zůstat zachován.

---

# 43. Scénář 41 – Uživatel nechce AI automatizaci

## Kontext

Uživatel chce AI používat pouze pro konzultace.

## Očekávané chování

Aplikace musí umožnit nastavit úroveň automatizace:

* pouze doporučení,
* návrhy změn s potvrzením,
* automatické drobné změny,
* širší automatizace v povolených mezích.

Základní používání produktu nesmí vyžadovat automatické AI změny.

---

# 44. Scénář 42 – Uživatel chce maximální automatizaci

## Kontext

Uživatel chce, aby aplikace automaticky upravovala drobné změny.

## Očekávané chování

Uživatel musí předem definovat hranice.

Například povolit:

* přesun flexibilního workoutu v rámci týdne,
* zkrácení nízkoprioritní jednotky,
* změnu připomenutí,
* úpravu počtu doplňkových sérií.

Stále musí existovat:

* audit,
* vysvětlení,
* možnost vrácení,
* seznam zakázaných významných akcí.

---

# 45. Scénář 43 – Smazání účtu

## Očekávané chování

Uživatel musí být schopen:

* požádat o smazání,
* pochopit důsledky,
* případně exportovat data,
* potvrdit akci,
* získat informaci o průběhu odstranění.

Musí být řešena:

* lokální data,
* backendová data,
* AI konverzace,
* integrační tokeny,
* zálohy v mezích právních a technických povinností.

---

# 46. Scénář 44 – Export dat

## Očekávané chování

Uživatel může získat přenositelný export minimálně obsahující:

* profil,
* sporty,
* cíle,
* plán,
* workouty,
* dokončené aktivity,
* základní metriky,
* AI akce a změny v přiměřené podobě.

Data nesmí být uzamčena pouze v interním formátu aplikace.

---

# 47. Scénář 45 – Chybná AI akce

## Kontext

AI navrhne nevhodnou nebo nesouvisející změnu.

## Očekávané chování

Uživatel musí mít možnost:

* změnu odmítnout,
* označit důvod,
* opravit vstup,
* nahlásit problém,
* pokračovat bez ztráty plánu.

Systém musí zachytit:

* použitý kontext,
* navrženou akci,
* validaci,
* rozhodnutí uživatele,
* konečný stav.

---

# 48. Univerzálnost produktu

AI Trainer musí být navržen tak, aby podporoval uživatele i mimo předem připravené persony a scénáře.

Toho dosáhne kombinací:

* rozšiřitelného sportovního modelu,
* vlastních uživatelských aktivit,
* obecných typů workoutů,
* strukturovaných vlastností zátěže,
* konfigurovatelných cílů,
* AI interpretace přirozeného jazyka,
* otevřeného systému metrik,
* modulární sportovní specializace.

Aplikace nesmí být postavena jako soubor pevně zakódovaných cest:

* pokud fotbalista, udělej A,
* pokud běžec, udělej B,
* pokud lezec, udělej C.

Místo toho musí pracovat s obecnými stavebními prvky:

* sportovní zátěž,
* síla,
* vytrvalost,
* rychlost,
* výkon,
* mobilita,
* flexibilita,
* koordinace,
* technika,
* regenerace,
* časová dostupnost,
* vybavení,
* priorita,
* termín,
* zkušenost.

Specializace konkrétního sportu se má přidávat nad tento obecný základ.

---

# 49. Kritéria přijatelnosti scénářů

Scénář je připraven k implementaci pouze tehdy, když je určeno:

1. Jak ho uživatel zahájí.
2. Jaké informace systém už zná.
3. Jaké informace musí doplnit.
4. Jaký je strukturovaný výstup.
5. Která data se změní.
6. Zda je nutné potvrzení.
7. Jak se změna vysvětlí.
8. Jak se změna vrátí.
9. Jak se zachová historie.
10. Co se stane offline.
11. Co se stane při chybě AI.
12. Jak bude scénář testován.
13. Jak funguje pro uživatele mimo hlavní persony.
14. Jak systém komunikuje nejistotu.
15. Jaká bezpečnostní pravidla se uplatní.

---

# 50. Závěr

AI Trainer musí zvládat nejen ideální plánování, ale především změny, výjimky a neúplné informace.

Hodnota produktu nevzniká pouze při vytvoření prvního plánu.

Vzniká ve chvíli, kdy se život uživatele od plánu odchýlí a aplikace dokáže smysluplně reagovat.

Persony a scénáře slouží jako testovací nástroje. Nevymezují hranice podporovaných uživatelů.

Základ produktu musí být dostatečně obecný, aby uživatel mohl říct:

> Tohle je můj sport, můj režim a moje situace.

A aplikace byla schopna odpovědět:

> Rozumím tomu dostatečně na to, abych ti pomohl vytvořit realistický plán. Tam, kde si nejsem jistý, řeknu ti to a zeptám se na potřebné informace.
