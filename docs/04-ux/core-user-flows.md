# AI Trainer – Core User Flows

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/04-ux/core-user-flows.md`

---

# 1. Účel dokumentu

Tento dokument převádí produktovou vizi, persony a uživatelské scénáře do konkrétních toků aplikace.

Popisuje:

* jak uživatel zahajuje jednotlivé akce,
* jakými obrazovkami prochází,
* jaké informace se zobrazují,
* jaké volby má k dispozici,
* kdy se vyžaduje potvrzení,
* jak se aplikace chová při chybě,
* jak funguje návrat změn,
* jaké části musí fungovat offline,
* jak se propojuje standardní rozhraní s AI trenérem.

Tento dokument zatím neurčuje přesný vizuální design. Neřeší konkrétní barvy, fonty ani pixelové rozměry.

Určuje funkční strukturu UX.

---

# 2. Hlavní navigační model

Mobilní aplikace používá hlavní spodní navigaci s pěti sekcemi:

1. **Dnes**
2. **Kalendář**
3. **AI trenér**
4. **Pokrok**
5. **Profil**

## 2.1 Dnes

Výchozí obrazovka aplikace.

Obsahuje:

* dnešní datum,
* dnešní workouty,
* týmové tréninky,
* zápasy nebo závody,
* regenerační doporučení,
* rychlý stav regenerace,
* upozornění na změny,
* rychlé akce,
* nejbližší důležitý cíl.

## 2.2 Kalendář

Obsahuje:

* denní přehled,
* týdenní přehled,
* měsíční přehled,
* plánované aktivity,
* dokončené aktivity,
* přesunuté aktivity,
* zrušené aktivity,
* návrhy AI,
* ručně přidané události.

## 2.3 AI trenér

Obsahuje:

* chat,
* rychlé návrhy témat,
* rozepracované návrhy změn,
* historii AI akcí,
* možnost vysvětlit plán,
* možnost upravit konkrétní den nebo období.

## 2.4 Pokrok

Obsahuje:

* plnění plánu,
* vývoj cílů,
* pravidelnost,
* vývoj vybraných výkonů,
* týdenní a měsíční shrnutí,
* důležité trendy,
* AI interpretaci výsledků.

## 2.5 Profil

Obsahuje:

* sporty,
* cíle,
* pravidelný rozvrh,
* vybavení,
* dostupnost,
* omezení,
* preference,
* integrace,
* notifikace,
* soukromí,
* účet.

---

# 3. Globální UX principy

## 3.1 Uživatel musí vždy vědět, co se stalo

Po každé významné akci aplikace zobrazí:

* potvrzení úspěchu,
* stručné shrnutí změny,
* možnost změnu zobrazit,
* možnost změnu vrátit, pokud je vratná.

Příklad:

> Workout byl přesunut na čtvrtek v 18:00.

Akce:

* `Zobrazit`
* `Vrátit`

## 3.2 AI nesmí měnit data neviditelně

Každá AI změna musí být v rozhraní označena.

Uživatel musí rozeznat:

* ruční změnu,
* automatickou systémovou změnu,
* změnu navrženou AI,
* změnu provedenou AI podle předem uděleného oprávnění.

## 3.3 Důležité akce vyžadují potvrzení

Potvrzení se vyžaduje zejména při:

* nahrazení celého plánu,
* změně více dnů,
* smazání budoucích workoutů,
* změně hlavního cíle,
* odstranění pravidelné sportovní aktivity,
* výrazném navýšení zátěže,
* změně zdravotního omezení,
* odpojení integrace,
* smazání účtu.

## 3.4 Běžné akce mají být rychlé

Bez dodatečného potvrzení lze obvykle:

* označit workout jako dokončený,
* změnit jednu sérii,
* upravit počet opakování,
* přidat poznámku,
* přesunout flexibilní workout v rámci stejného dne,
* změnit připomenutí,
* označit subjektivní únavu,
* označit běžnou svalovou bolest po tréninku.

## 3.5 Každá významná změna má náhled

Před potvrzením změny uživatel vidí:

* původní stav,
* navržený stav,
* důvod,
* ovlivněné dny,
* dopad na cíle,
* zda lze změnu vrátit.

---

# 4. Flow 1 – První spuštění aplikace

## 4.1 Vstupní obrazovka

Obsah:

* název aplikace,
* krátká hodnota produktu,
* ilustrace nebo jednoduchý vizuál,
* tlačítko `Začít`,
* tlačítko `Přihlásit se`,
* odkaz na soukromí a podmínky.

Hlavní sdělení:

> Osobní AI trenér, který propojí tvoje sporty, cíle a reálný život do jednoho plánu.

## 4.2 Registrace

Možnosti:

* e-mail a heslo,
* přihlášení přes Apple,
* přihlášení přes Google,
* další podporované metody později.

Po registraci:

* vytvoří se účet,
* obnoví se relace,
* uživatel pokračuje do onboardingu.

## 4.3 Povinné informace

Minimální povinné informace:

* věkové rozmezí nebo datum narození podle budoucích právních požadavků,
* země nebo region pro jednotky a právní nastavení,
* souhlas s podmínkami,
* potvrzení, že aplikace neposkytuje zdravotní diagnózu.

## 4.4 Přerušení onboardingu

Pokud uživatel onboarding opustí:

* dosavadní odpovědi se uloží,
* při návratu pokračuje na posledním dokončeném kroku,
* může onboarding dokončit později,
* bez minimálních údajů však nelze vytvořit plnohodnotný plán.

---

# 5. Flow 2 – Onboarding

Onboarding musí kombinovat strukturované obrazovky s možností přirozeného textového vstupu.

## 5.1 Úvod do onboardingu

Aplikace vysvětlí:

> Nejprve zjistíme, jak se hýbeš, čeho chceš dosáhnout a kolik máš času. Zabere to jen několik minut.

Možnosti:

* `Provést mě krok za krokem`
* `Popsat vše vlastními slovy`

## 5.2 Varianta A – Krokový onboarding

### Krok 1 – Hlavní záměr

Otázka:

> S čím ti má aplikace nejvíce pomoci?

Možnosti:

* vytvořit tréninkový plán,
* skloubit více sportů,
* zlepšit konkrétní výkon,
* začít se pravidelně hýbat,
* vrátit se po pauze,
* připravit se na závod nebo událost,
* vlastní odpověď.

### Krok 2 – Sporty

Uživatel:

* vyhledá sport,
* vybere více sportů,
* přidá vlastní sport,
* označí hlavní sport,
* označí doplňkové sporty.

Každý sport může obsahovat:

* úroveň,
* frekvenci,
* běžné dny,
* délku,
* intenzitu,
* soutěžní nebo rekreační charakter.

### Krok 3 – Pravidelný rozvrh

Uživatel přidá:

* tréninky,
* zápasy,
* závody,
* pravidelné lekce,
* jiné pevné aktivity.

Každá událost obsahuje:

* den,
* čas,
* délku,
* opakování,
* flexibilitu,
* prioritu.

### Krok 4 – Cíle

Uživatel může přidat jeden nebo více cílů.

U každého cíle:

* název,
* priorita,
* termín,
* výchozí stav,
* preferovaná metrika,
* důvod, proč je pro něj důležitý.

### Krok 5 – Časové možnosti

Uživatel nastaví:

* možné dny,
* možné části dne,
* maximální délku workoutu,
* počet hlavních workoutů týdně,
* ochotu cvičit vícekrát za den,
* preferovaný odpočinkový den.

### Krok 6 – Prostředí a vybavení

Možnosti:

* doma,
* venku,
* fitko,
* sportoviště,
* proměnlivé prostředí.

Vybavení lze:

* vybrat z katalogu,
* přidat vlastní,
* označit jako trvale nebo dočasně dostupné.

### Krok 7 – Omezení

Uživatel může uvést:

* dlouhodobá omezení,
* aktuální bolest,
* zákaz konkrétní aktivity,
* doporučení odborníka,
* žádná omezení.

Aplikace musí vysvětlit, že nejde o zdravotní diagnostiku.

### Krok 8 – Preference

Například:

* krátké nebo delší workouty,
* ranní nebo večerní trénink,
* více vysvětlení nebo stručnější vedení,
* míra automatizace,
* jazyk a jednotky,
* četnost notifikací.

## 5.3 Varianta B – Popis vlastními slovy

Uživatel napíše například:

> Hraju třikrát týdně fotbal, v neděli mám zápas, chci zesílit horní polovinu těla, cvičím doma a mám hrazdu.

AI z textu vytvoří strukturovaný návrh profilu.

Následuje obrazovka:

## Rozpoznal jsem

* Fotbal: 3× týdně
* Zápas: neděle
* Cíl: síla horní poloviny těla
* Prostředí: doma
* Vybavení: hrazda

## Potřebuji doplnit

* Ve které dny máš fotbalové tréninky?
* Kolik času máš na doplňkový workout?
* Jaká je tvoje současná úroveň?

Uživatel může:

* odpovědět v chatu,
* upravit rozpoznané hodnoty ručně,
* pokračovat krokovým formulářem.

## 5.4 Shrnutí profilu

Před vytvořením plánu uživatel vidí:

* sporty,
* cíle,
* pravidelné aktivity,
* časové možnosti,
* vybavení,
* omezení,
* preference.

Akce:

* `Vytvořit plán`
* `Upravit`
* `Uložit bez plánu`

---

# 6. Flow 3 – Vytvoření prvního plánu

## 6.1 Generování návrhu

Po potvrzení profilu se zobrazí průběhová obrazovka.

Aplikace může zobrazovat kroky:

* analyzuji sportovní rozvrh,
* hledám vhodná tréninková okna,
* skládám workouty,
* kontroluji regeneraci,
* připravuji progresi.

Aplikace nesmí předstírat přesné interní uvažování modelu.

## 6.2 Náhled plánu

Uživatel vidí:

* délku plánu,
* hlavní cíle,
* typický týden,
* počet workoutů,
* počet pravidelných sportovních aktivit,
* odpočinkové dny,
* hlavní princip progrese,
* důležité kompromisy.

Příklad:

> Přidal jsem dva workouty horní části těla týdně. Umístil jsem je na úterý a sobotu, aby nezasahovaly do fotbalových tréninků a nedělního zápasu.

## 6.3 Týdenní vizualizace

Kalendářní náhled ukáže:

* pevné aktivity,
* flexibilní workouty,
* mikro-workouty,
* regeneraci,
* volné dny.

Každý typ musí být vizuálně rozlišitelný i bez spoléhání pouze na barvy.

## 6.4 Možnosti úpravy

Uživatel může:

* změnit den,
* změnit čas,
* změnit počet workoutů,
* změnit délku,
* změnit zaměření,
* požádat AI o úpravu,
* otevřít detail workoutu,
* upravit jednotlivé cviky.

## 6.5 Potvrzení plánu

Před potvrzením aplikace zobrazí:

* počet vytvářených událostí,
* období,
* počet workoutů,
* pravidelné aktivity,
* notifikace, které se aktivují.

Akce:

* `Potvrdit a přidat do kalendáře`
* `Pokračovat v úpravách`
* `Uložit jako koncept`

---

# 7. Flow 4 – Domovská obrazovka Dnes

## 7.1 Struktura obrazovky

Pořadí obsahu:

1. datum a pozdrav,
2. stručný stav dne,
3. nejbližší aktivita,
4. dnešní timeline,
5. rychlé akce,
6. upozornění a návrhy,
7. pokrok vůči hlavnímu cíli.

## 7.2 Stav dne

Příklady:

> Dnes tě čeká krátká mobilita a večerní florbal.

> Dnes máš volnější den. Můžeš odpočívat nebo dokončit 15minutovou rutinu.

> Dnešní workout čeká na úpravu kvůli hlášené bolesti bicepsu.

## 7.3 Karta dnešního workoutu

Obsah:

* název,
* čas,
* délka,
* typ,
* účel,
* stav,
* hlavní cviky,
* vazba na cíl,
* tlačítko `Spustit`.

Další akce:

* `Upravit`
* `Přesunout`
* `Zkrátit`
* `Dnes nestíhám`
* `Probrat s AI`

## 7.4 Rychlé akce

Minimálně:

* `Jsem unavený`
* `Něco mě bolí`
* `Dnes nestíhám`
* `Změnil se mi program`
* `Přidat aktivitu`

Kliknutí otevře krátký kontextový flow, ne prázdný chat.

---

# 8. Flow 5 – Spuštění workoutu

## 8.1 Předtréninková obrazovka

Obsah:

* název workoutu,
* účel,
* očekávaná délka,
* seznam částí,
* potřebné vybavení,
* vztah k dnešním dalším aktivitám,
* upozornění na aktuální omezení.

Akce:

* `Spustit workout`
* `Upravit workout`
* `Zkrátit`
* `Odložit`

## 8.2 Kontrola připravenosti

Volitelný rychlý vstup:

* energie 1–5,
* bolest ano/ne,
* časová dostupnost,
* aktuální vybavení.

Pokud uživatel uvede problém, aplikace nabídne úpravu před spuštěním.

Tento krok nesmí být povinný při každém workoutu.

## 8.3 Aktivní workout

Horní část obrazovky:

* čas workoutu,
* průběh,
* aktuální část,
* možnost pozastavení,
* možnost ukončení.

Obsah cviku:

* název,
* video nebo ilustrace v budoucnu,
* stručné instrukce,
* cílové série,
* opakování nebo čas,
* tempo,
* pauza,
* předchozí výkon,
* poznámky.

Akce:

* dokončit sérii,
* upravit hodnotu,
* přeskočit sérii,
* nahradit cvik,
* přidat sérii,
* označit bolest nebo problém.

## 8.4 Pauzový časovač

Po dokončení série:

* automaticky spustí odpočet, pokud je nastaven,
* lze ho přeskočit,
* prodloužit,
* zkrátit,
* neblokuje zápis.

## 8.5 Nahrazení cviku

Uživatel otevře `Nahradit cvik`.

Aplikace nabídne alternativy podle:

* cíle cviku,
* vybavení,
* bolesti,
* obtížnosti,
* již provedené zátěže.

Změna se může týkat:

* pouze dnešní instance,
* všech budoucích instancí,
* šablony workoutu.

Výběr rozsahu musí být explicitní.

---

# 9. Flow 6 – Dokončení workoutu

## 9.1 Souhrn

Po dokončení se zobrazí:

* délka,
* dokončené cviky,
* skutečný objem,
* rozdíl proti plánu,
* osobní rekordy,
* vynechané části,
* poznámky.

## 9.2 Subjektivní hodnocení

Rychlé vstupy:

* celková náročnost,
* energie po workoutu,
* bolest nebo nepohodlí,
* poznámka.

Hodnocení musí být možné přeskočit.

## 9.3 Uložení

Po potvrzení:

* aktivita se označí jako dokončená,
* uloží se skutečná data,
* aktualizuje se historie,
* připraví se synchronizace,
* aktualizují se relevantní metriky.

## 9.4 Offline dokončení

Při offline režimu:

* workout se uloží lokálně,
* zobrazí se stav `Čeká na synchronizaci`,
* uživatel může pokračovat v aplikaci,
* nesmí být vyžadováno připojení.

---

# 10. Flow 7 – Nahlášení únavy

## 10.1 Zahájení

Možnosti:

* rychlá akce na obrazovce Dnes,
* chat s AI,
* před spuštěním workoutu,
* denní check-in.

## 10.2 Minimální dotazy

Aplikace zjistí:

* intenzitu únavy,
* zda jde o celkovou nebo lokální únavu,
* případný nedostatek spánku,
* zda uživatel chce workout zachovat.

Otázky musí být krátké.

## 10.3 Návrh úpravy

Možné návrhy:

* zachovat beze změny,
* zkrátit,
* snížit objem,
* snížit intenzitu,
* nahradit regenerací,
* přesunout,
* vynechat.

## 10.4 Náhled změny

Zobrazuje:

* původní workout,
* upravený workout,
* dopad na další dny,
* důvod,
* jistotu nebo nejistotu doporučení.

Akce:

* `Použít úpravu`
* `Nechat původní`
* `Upravit návrh`
* `Probrat s AI`

---

# 11. Flow 8 – Nahlášení bolesti

## 11.1 Zahájení

Možnosti:

* rychlá akce `Něco mě bolí`,
* během workoutu,
* v AI chatu,
* při hodnocení dokončeného workoutu.

## 11.2 Strukturovaný vstup

Aplikace zjistí:

* místo bolesti,
* pravá nebo levá strana,
* intenzita,
* charakter,
* vznik,
* pohyb, který ji zhoršuje,
* přítomnost v klidu,
* úraz ano/ne.

Uživatel může použít:

* jednoduchou mapu těla,
* text,
* předvolby,
* kombinaci.

## 11.3 Bezpečnostní větev

Při rizikovém vstupu aplikace:

* zastaví běžnou úpravu workoutu,
* doporučí aktivitu přerušit,
* zobrazí vhodné bezpečnostní sdělení,
* doporučí odbornou konzultaci podle situace.

Aplikace nesmí stanovovat diagnózu.

## 11.4 Běžná úprava

Pokud není zjištěno akutní riziko, AI může navrhnout:

* odstranit konkrétní cvik,
* vynechat zatíženou oblast,
* změnit intenzitu,
* použít jiný typ workoutu,
* odpočívat.

## 11.5 Doba platnosti

Uživatel zvolí nebo potvrdí:

* jen dnešní workout,
* několik dní,
* do konkrétního data,
* do ručního zrušení.

Dočasná bolest se nesmí automaticky změnit na trvalé omezení.

---

# 12. Flow 9 – Dnes nemám čas

## 12.1 Zahájení

Uživatel klikne na `Dnes nestíhám` nebo napíše zprávu.

## 12.2 Možnosti

Aplikace nabídne:

* mám 5 minut,
* mám 10 minut,
* mám 15 minut,
* přesunout,
* vynechat,
* vlastní čas.

## 12.3 Návrh

Systém určí:

* zda dává smysl zkrácení,
* co je minimální užitečná verze,
* zda je lepší workout přesunout,
* jaký bude dopad na týden.

Uživatel vidí odstraněné a zachované části.

---

# 13. Flow 10 – Změna programu

## 13.1 Vstup

Například:

> Celý víkend jedu na skály.

> Zrušili nám středeční florbal.

> Zápas se přesunul na sobotu.

## 13.2 Rozpoznání změny

AI vytvoří strukturovaný návrh:

* typ události,
* datum,
* délka,
* intenzita,
* pevnost,
* dočasnost,
* ovlivněné části plánu.

## 13.3 Doplnění nejasností

Aplikace se ptá pouze na chybějící informace.

Příklad:

> Počítáš s lezením v sobotu, v neděli, nebo oba dny?

## 13.4 Souhrnný návrh

Zobrazuje:

* novou událost,
* přesunuté workouty,
* zrušené workouty,
* upravené workouty,
* regeneraci po události,
* důvod.

Akce:

* `Potvrdit vše`
* `Upravit jednotlivé změny`
* `Odmítnout`
* `Probrat dál`

---

# 14. Flow 11 – Kalendář

## 14.1 Měsíční přehled

Slouží k orientaci.

Zobrazuje:

* počet aktivit za den,
* typy událostí,
* dokončení,
* upozornění na konflikty,
* důležité cílové termíny.

Kliknutí na den otevře denní přehled.

## 14.2 Týdenní přehled

Hlavní plánovací obrazovka.

Zobrazuje:

* časovou osu,
* všechny aktivity,
* pevné a flexibilní události,
* více workoutů v jednom dni,
* odpočinkové bloky,
* návrhy AI.

Uživatel může:

* přesouvat flexibilní workouty,
* otevřít detail,
* přidat událost,
* zobrazit týdenní zátěž,
* požádat AI o reorganizaci.

## 14.3 Denní přehled

Obsahuje:

* pořadí aktivit,
* časy,
* priority,
* detaily,
* rychlé spuštění,
* změny proti původnímu plánu.

## 14.4 Přetažení workoutu

Při drag-and-drop:

* aplikace zobrazí možné termíny,
* upozorní na konflikt,
* neblokuje legitimní ruční změnu,
* nabídne kontrolu dopadu přes AI.

---

# 15. Flow 12 – Ruční přidání aktivity

## 15.1 Zahájení

Tlačítko `Přidat` v kalendáři nebo na obrazovce Dnes.

## 15.2 Typ aktivity

Možnosti:

* workout,
* sportovní trénink,
* zápas nebo závod,
* obecná aktivita,
* regenerace,
* volno,
* vlastní typ.

## 15.3 Povinná pole

Minimálně:

* název,
* datum,
* plánovaná délka nebo čas,
* pevnost termínu.

## 15.4 Volitelná pole

* intenzita,
* sport,
* cíle,
* opakování,
* vybavení,
* poznámka,
* zatížené oblasti,
* priorita.

## 15.5 Vlastní sport

Uživatel může přidat libovolný název.

Aplikace následně může nabídnout:

> Abych s touto aktivitou lépe pracoval, doplň její typickou intenzitu a zatížení.

---

# 16. Flow 13 – AI chat

## 16.1 Výchozí stav

Chat neobsahuje pouze prázdné pole.

Zobrazuje kontextové návrhy podle situace:

* upravit dnešní workout,
* vysvětlit plán,
* naplánovat další týden,
* přidat sportovní událost,
* řešit únavu,
* změnit cíl.

## 16.2 Typy odpovědí

AI může odpovědět:

* textem,
* otázkou,
* strukturovaným návrhem,
* náhledem změny,
* kartou workoutu,
* kartou cíle,
* kalendářním náhledem,
* shrnutím pokroku.

## 16.3 Akční odpověď

Když AI navrhne změnu, chat zobrazí interaktivní kartu.

Příklad:

## Návrh změny

* Úterní workout zkrátit z 45 na 25 minut.
* Snížit tahový objem o 40 %.
* Přesunout těžší workout na pátek.

Důvod:

> Uvedl jsi bolest pravého bicepsu a ve středu máš fotbalový trénink.

Akce:

* `Potvrdit`
* `Upravit`
* `Odmítnout`

## 16.4 Kontext konverzace

Uživatel musí vidět, zda se konverzace týká:

* dnešního workoutu,
* konkrétního týdne,
* cíle,
* celého plánu,
* obecné otázky.

---

# 17. Flow 14 – Úprava plánu přes AI

## 17.1 Rozsah změny

AI musí určit:

* jednu sérii,
* jeden cvik,
* jeden workout,
* jeden den,
* jeden týden,
* tréninkový blok,
* celý plán.

## 17.2 Náhled rozdílů

Pro větší změny se zobrazí porovnání.

Příklad:

| Den     | Původně      | Nově       |
| ------- | ------------ | ---------- |
| Pátek   | Upper Body B | Volno      |
| Sobota  | Volno        | Lezení     |
| Neděle  | Lower Body   | Lezení     |
| Pondělí | Upper Body A | Regenerace |

## 17.3 Částečné potvrzení

Uživatel může potvrdit pouze některé změny.

Systém následně musí zkontrolovat, zda částečný výběr nevytváří konflikt.

## 17.4 Uložení

Po potvrzení:

* vytvoří se nová verze plánu,
* uloží se změnová sada,
* aktualizují se instance workoutů,
* zachová se historie,
* nabídne se vrácení.

---

# 18. Flow 15 – Vrácení změny

## 18.1 Rychlé vrácení

Po provedení změny se zobrazí krátká možnost `Vrátit`.

## 18.2 Historie změn

V detailu plánu nebo profilu existuje sekce:

`Historie změn`

Každý záznam obsahuje:

* datum,
* zdroj změny,
* důvod,
* rozsah,
* ovlivněné položky,
* možnost zobrazit detail.

## 18.3 Závislé změny

Pokud na původní změnu navazují další změny, aplikace upozorní:

> Obnovení této verze ovlivní také dvě pozdější úpravy.

Možnosti:

* obnovit vše,
* vytvořit nový návrh,
* zrušit.

Dokončené historické aktivity se neodstraňují.

---

# 19. Flow 16 – Cíle

## 19.1 Přehled cílů

Zobrazuje:

* hlavní cíl,
* vedlejší cíle,
* stav,
* termín,
* prioritu,
* poslední aktualizaci,
* související workouty.

## 19.2 Detail cíle

Obsahuje:

* popis,
* důvod,
* výchozí stav,
* cílový stav,
* metriky,
* milníky,
* historii,
* AI komentář,
* vazbu na plán.

## 19.3 Přidání cíle

Uživatel může:

* vybrat typ,
* napsat vlastní text,
* nechat AI cíl strukturovat.

## 19.4 Konfliktní cíle

Při více cílech aplikace zobrazí:

> Tyto cíle mohou soutěžit o stejný čas a regeneraci.

Uživatel nastaví:

* hlavní prioritu,
* vedlejší priority,
* období zaměření.

---

# 20. Flow 17 – Pokrok a týdenní revize

## 20.1 Týdenní souhrn

Obsahuje:

* plánované aktivity,
* dokončené aktivity,
* změny,
* hlavní výkony,
* subjektivní stav,
* posun cílů,
* návrh dalšího týdne.

## 20.2 Jazyk hodnocení

Aplikace nesmí hodnotit týden pouze jako úspěch nebo selhání.

Preferované formulace:

> Dokončil jsi čtyři z pěti plánovaných jednotek. Vynechaný workout nebyl přesunut, protože víkendové lezení vytvořilo podobnou zátěž.

## 20.3 Akce

* `Potvrdit další týden`
* `Upravit priority`
* `Probrat s AI`
* `Zobrazit detail`

---

# 21. Flow 18 – Profil a sportovní systém

## 21.1 Sporty

Každý sport obsahuje:

* název,
* úroveň,
* roli,
* pravidelnost,
* sezonu,
* cíle,
* plánovací charakteristiky.

Uživatel může přidat vlastní sport.

## 21.2 Vybavení

Každé vybavení obsahuje:

* název,
* dostupnost,
* prostředí,
* období platnosti,
* případné parametry.

## 21.3 Dostupnost

Uživatel může nastavit:

* běžný týden,
* dočasnou změnu,
* výjimku,
* maximální délku,
* preferované časy.

## 21.4 Omezení

Musí být odděleno:

* dlouhodobé omezení,
* dočasné omezení,
* aktuální bolest,
* odborné doporučení,
* uživatelská preference.

---

# 22. Flow 19 – Notifikace

## 22.1 Ranní přehled

Obsah:

* dnešní aktivity,
* celková plánovaná délka,
* hlavní priorita,
* případné upozornění.

Kliknutí otevře obrazovku Dnes.

## 22.2 Připomenutí workoutu

Kliknutí otevře konkrétní workout.

Pokud byl workout změněn, otevře se aktuální verze.

## 22.3 Návrh změny

Notifikace:

> Kvůli změně víkendového programu jsem připravil návrh úpravy tří workoutů.

Kliknutí otevře náhled změn.

## 22.4 Nastavení

Uživatel může samostatně řídit:

* ranní přehled,
* připomenutí,
* týdenní revize,
* AI návrhy,
* upozornění na neaktivitu,
* časové okno,
* tiché dny.

---

# 23. Flow 20 – Offline režim a synchronizace

## 23.1 Offline stav

Aplikace zobrazí nenápadný stav:

`Offline`

Základní data zůstávají dostupná.

## 23.2 Lokální změny

Lokálně lze:

* dokončit workout,
* upravit série,
* přidat poznámku,
* ručně přesunout workout,
* přidat aktivitu,
* zaznamenat únavu nebo bolest.

## 23.3 Čekající synchronizace

Položky mají stav:

* synchronizováno,
* čeká na synchronizaci,
* konflikt,
* chyba synchronizace.

## 23.4 Konflikt

Při konfliktu uživatel vidí srozumitelné porovnání.

Ne technické databázové verze.

Příklad:

> Na tomto telefonu jsi změnil počet opakování na 10. Na jiném zařízení bylo uloženo 12.

Možnosti:

* použít 10,
* použít 12,
* upravit ručně.

---

# 24. Flow 21 – AI je nedostupná

## 24.1 Chování

Aplikace zobrazí:

> AI trenér je dočasně nedostupný. Tvůj plán, workouty a historie dál fungují.

## 24.2 Dostupné funkce

Uživatel může:

* otevřít plán,
* dokončit workout,
* ručně upravit workout,
* přesunout aktivitu,
* uložit poznámku,
* zaznamenat stav.

## 24.3 Nedostupné funkce

Dočasně mohou být nedostupné:

* generování nového plánu,
* komplexní adaptace,
* AI vysvětlení,
* interpretace více zdrojů dat.

---

# 25. Flow 22 – Integrace wearables

## 25.1 Připojení

V Profilu uživatel otevře `Integrace`.

Vidí:

* dostupné služby,
* stav připojení,
* rozsah oprávnění,
* poslední synchronizaci.

## 25.2 Oprávnění

Aplikace vysvětlí konkrétně:

* co chce číst,
* proč to potřebuje,
* zda bude zapisovat data,
* jak lze přístup odebrat.

## 25.3 Importovaná aktivita

Po importu:

* aktivita se normalizuje,
* označí se zdroj,
* zkontroluje se duplicita,
* nabídne se spojení s plánovaným workoutem.

## 25.4 Nejistota

Pokud data nejsou spolehlivá:

> Záznam spánku je neúplný. Dnešní doporučení z něj nebude výrazně vycházet.

---

# 26. Flow 23 – Smazání účtu

## 26.1 Zahájení

Profil → Účet → Smazat účet.

## 26.2 Informace

Aplikace zobrazí:

* co bude smazáno,
* co může být uchováno kvůli právním povinnostem,
* možnost exportu,
* důsledky pro integrace.

## 26.3 Potvrzení

Vyžaduje se:

* explicitní potvrzení,
* nové ověření identity podle platformy,
* případná ochranná lhůta.

## 26.4 Výsledek

Uživatel obdrží potvrzení o zahájení nebo dokončení procesu.

---

# 27. Globální stavy obrazovek

Každá datová obrazovka musí podporovat:

## 27.1 Načítání

* skeleton nebo jasný stav načítání,
* žádné nekonečné prázdné obrazovky.

## 27.2 Prázdný stav

Musí vysvětlit:

* proč zde nic není,
* co může uživatel udělat.

Příklad:

> Zatím nemáš žádný cíl. Přidej první cíl nebo ho popiš AI trenérovi.

## 27.3 Chyba

Musí obsahovat:

* srozumitelnou zprávu,
* možnost opakovat,
* možnost pokračovat, pokud je to možné.

## 27.4 Částečná data

Pokud jsou dostupná lokální, ale ne aktuální serverová data:

> Zobrazuji poslední synchronizovanou verzi.

## 27.5 Nedostatečné oprávnění

Musí vysvětlit:

* které oprávnění chybí,
* proč je potřeba,
* jak ho povolit,
* co bude fungovat i bez něj.

---

# 28. Deep links

Aplikace musí být připravena na přímé otevření:

* dnešního přehledu,
* konkrétního workoutu,
* konkrétního dne,
* návrhu změn,
* cíle,
* týdenního shrnutí,
* integrace,
* obrazovky potvrzení.

Deep link musí vždy:

* ověřit přihlášení,
* načíst aktuální stav,
* zpracovat neplatný nebo zastaralý odkaz,
* nezobrazit data jiného uživatele.

---

# 29. Dostupnost

Aplikace musí počítat s:

* čtečkami obrazovky,
* zvětšeným textem,
* dostatečnými dotykovými plochami,
* ovládáním jednou rukou,
* kontrastem,
* nespoléháním pouze na barvy,
* haptickou zpětnou vazbou jako doplňkem,
* přehledným workout trackerem během pohybu.

Workout tracker musí být ovladatelný i v situaci, kdy uživatel:

* drží telefon jednou rukou,
* má zpocené ruce,
* je venku,
* používá větší text,
* potřebuje rychle zaznamenat sérii.

---

# 30. Analytické události

Produktová analytika musí měřit chování, ne citlivý obsah konverzací.

Příklady událostí:

* onboarding zahájen,
* onboarding dokončen,
* plán vytvořen,
* plán potvrzen,
* workout spuštěn,
* workout dokončen,
* workout zkrácen,
* AI návrh vytvořen,
* AI návrh přijat,
* AI návrh odmítnut,
* změna vrácena,
* aktivita přidána,
* notifikace otevřena,
* synchronizační konflikt.

Citlivý text, zdravotní údaje a obsah chatu nesmí být automaticky odesílány do běžné analytiky.

---

# 31. Kritéria dokončení UX flow

Každý flow je připraven k implementaci pouze tehdy, když má definováno:

1. vstupní bod,
2. předpoklady,
3. hlavní kroky,
4. obrazovky,
5. primární akci,
6. vedlejší akce,
7. potvrzení,
8. změněná data,
9. chybové stavy,
10. prázdný stav,
11. offline chování,
12. návrat změny,
13. přístupnost,
14. analytické události,
15. testovací scénáře.

---

# 32. Priorita toků pro první implementaci

## Priorita A – Základní lokální produkt

* domovská obrazovka Dnes,
* týdenní kalendář,
* detail workoutu,
* spuštění workoutu,
* aktivní tracker,
* dokončení workoutu,
* lokální historie.

## Priorita B – Účet a profil

* registrace,
* přihlášení,
* onboarding,
* sportovní profil,
* cíle,
* dostupnost,
* vybavení.

## Priorita C – Plánování

* vytvoření plánu,
* náhled plánu,
* potvrzení,
* změna workoutu,
* přesun,
* verzování.

## Priorita D – AI

* chat,
* strukturované návrhy,
* úprava dne,
* úprava týdne,
* vysvětlení,
* potvrzování,
* vrácení změn.

## Priorita E – Pokročilé funkce

* notifikace,
* statistiky,
* wearables,
* pokročilá synchronizace,
* GPS.

---

# 33. Závěr

AI Trainer nesmí být navržen jako soubor formulářů a samostatný chat.

Uživatel musí mít jeden propojený systém, ve kterém:

* profil určuje plán,
* plán vytváří kalendář,
* kalendář otevírá workouty,
* workouty vytvářejí historii,
* historie ovlivňuje pokrok,
* pokrok a aktuální stav ovlivňují další doporučení,
* AI dokáže celý systém vysvětlovat a bezpečně upravovat.

Nejdůležitější UX moment nenastává při otevření chatu.

Nastává ve chvíli, kdy uživatel oznámí změnu ve svém životě a aplikace ji dokáže převést do srozumitelného, konkrétního a vratného návrhu úprav.
