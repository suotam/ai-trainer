# Product-Principles.md

# AI Trainer – Product Principles

**Verze:** 0.1
**Stav:** Draft
**Účel dokumentu:** Definovat neměnné principy, podle kterých se bude navrhovat, implementovat a vyhodnocovat celý produkt.

---

# 1. Účel produktových principů

Produktové principy jsou pravidla, která pomáhají rozhodovat v situacích, kdy existuje více možných řešení.

Nejsou to konkrétní funkce.

Neříkají přesně, jak má vypadat určitá obrazovka nebo jaké technologie mají být použity.

Určují však, jaký má produkt být, jak se má chovat a jaký vztah má mít s uživatelem.

Každá větší funkce, návrhové rozhodnutí nebo změna architektury musí být s těmito principy v souladu.

Pokud je navrhované řešení v rozporu s některým z těchto principů, musí být přepracováno nebo musí být výjimka výslovně zdůvodněna.

---

# 2. AI není doplněk

AI není samostatná chatovací funkce přidaná k běžné fitness aplikaci.

AI je rozhodovací a koordinační vrstva celého produktu.

Rozumí:

* uživatelským cílům,
* sportovnímu profilu,
* historii tréninků,
* plánovaným aktivitám,
* regeneraci,
* dostupnému času,
* vybavení,
* omezením,
* změnám v životě uživatele.

AI může vytvářet a navrhovat změny v:

* tréninkových plánech,
* konkrétních workoutech,
* kalendáři,
* cílech,
* regeneraci,
* mobilitě,
* upozorněních,
* dlouhodobých prioritách.

Chat je pouze jeden ze způsobů, jak s touto inteligencí komunikovat.

---

# 3. Uživatel má poslední slovo

AI může doporučovat, plánovat a připravovat změny, ale uživatel musí mít kontrolu nad důležitými rozhodnutími.

Významné změny nesmí být provedeny bez vědomí uživatele.

Mezi významné změny patří například:

* odstranění tréninkového plánu,
* smazání více budoucích workoutů,
* zásadní změna dlouhodobého cíle,
* výrazné navýšení tréninkové zátěže,
* nahrazení celé tréninkové fáze,
* změna pravidelných sportovních aktivit,
* změna zdravotních omezení.

Aplikace může předem povolit automatické provádění drobných změn, pokud uživatel tuto možnost výslovně zapne.

Uživatel musí mít možnost:

* změnu potvrdit,
* změnu odmítnout,
* návrh upravit,
* vrátit poslední změnu,
* zobrazit důvod změny.

---

# 4. Každé rozhodnutí musí být vysvětlitelné

AI nesmí měnit plán bez srozumitelného důvodu.

Uživatel musí být schopen pochopit:

* co se změnilo,
* proč se to změnilo,
* z jakých dat AI vycházela,
* jaký očekává přínos,
* jaké jsou případné nevýhody.

Příklad:

> Dnešní silový trénink jsem zkrátil o dvě série, protože jsi uvedl vysokou únavu a poslední dvě noci jsi spal méně než šest hodin.

Vysvětlení musí být stručné, konkrétní a přiměřené situaci.

Uživatel nesmí mít pocit, že aplikace provádí nevysvětlitelné změny.

---

# 5. Jeden uživatel má jeden společný sportovní systém

Aplikace nesmí posuzovat každý sport izolovaně.

Fotbal, běh, posilování, lezení, cyklistika, mobilita a další aktivity tvoří společnou tréninkovou zátěž.

Plánování musí zohlednit jejich vzájemné působení.

Například:

* fotbalový zápas ovlivňuje plánování silového tréninku nohou,
* lezecký víkend ovlivňuje tahové a úchopové workouty,
* dlouhý běh ovlivňuje regeneraci před florbalem,
* silový trénink ramen ovlivňuje další den lezení,
* nedostatek spánku ovlivňuje všechny druhy aktivit.

Systém proto nepracuje s několika oddělenými plány, ale s jedním společným plánem fyzické přípravy.

---

# 6. Plán je živý, nikoliv statický

Tréninkový plán není dokument vytvořený jednou na několik měsíců.

Je to živý objekt, který reaguje na nové informace.

Může se měnit podle:

* dokončených tréninků,
* vynechaných tréninků,
* subjektivní únavy,
* bolesti,
* spánku,
* wearable dat,
* změn rozvrhu,
* nových sportovních akcí,
* cestování,
* změny vybavení,
* změny cíle,
* vývoje výkonnosti.

Každá změna musí zachovat historii původního plánu a jeho předchozích verzí.

---

# 7. Historie se nepřepisuje

Dokončené aktivity představují historická data a nesmí být zpětně svévolně přepisovány.

Aplikace musí rozlišovat mezi:

* plánovaným workoutem,
* upraveným workoutem,
* skutečně provedeným workoutem,
* subjektivním hodnocením,
* automaticky naměřenými daty.

Pokud uživatel dokončí jiný trénink, než byl naplánovaný, systém musí zachovat:

* původní plán,
* provedenou skutečnost,
* důvod změny, pokud je známý.

Historická data mohou být opravena pouze vědomou uživatelskou akcí a oprava musí být dohledatelná.

---

# 8. Aplikace minimalizuje administrativu

Uživatel má sportovat, ne vyplňovat formuláře.

Aplikace musí aktivně snižovat množství ruční práce.

Preferované chování:

* předvyplnění známých údajů,
* opakované použití workout šablon,
* automatické načtení wearable dat,
* rychlé subjektivní hodnocení,
* jednoduché potvrzení plánovaných aktivit,
* zadávání změn přirozeným jazykem,
* inteligentní návrhy místo dlouhých formulářů.

Ruční zadání musí být vždy možné, ale nesmí být hlavním způsobem ovládání.

---

# 9. Nejčastější úkoly musí být nejrychlejší

Každodenní používání musí být jednoduché.

Uživatel se musí rychle dostat k odpovědím:

* Co mě dnes čeká?
* Jak spustím dnešní workout?
* Co mám udělat, když se necítím dobře?
* Jak změním dnešní plán?
* Jak zapíšu dokončenou aktivitu?
* Jak zjistím, zda se zlepšuji?

Z domovské obrazovky musí být možné:

* spustit dnešní workout,
* zobrazit dnešní plán,
* nahlásit únavu nebo bolest,
* změnit dostupnost,
* kontaktovat AI trenéra.

Nejdůležitější akce nesmí být skryté hluboko v navigaci.

---

# 10. AI pracuje pouze s oprávněnými nástroji

AI nesmí mít přímý neomezený přístup k databázi.

Nesmí vytvářet vlastní SQL dotazy ani svévolně měnit libovolná data.

Může používat pouze předem definované nástroje, například:

* vytvořit návrh workoutu,
* naplánovat workout,
* přesunout workout,
* zkrátit workout,
* vytvořit cíl,
* upravit cíl,
* zaznamenat subjektivní únavu,
* zobrazit progres,
* vytvořit návrh změny plánu.

Každý nástroj musí mít:

* jasný účel,
* validovaný vstup,
* ověřená oprávnění,
* definované následky,
* auditní záznam,
* pravidla pro potvrzení uživatelem.

AI navrhuje akci. Aplikace rozhoduje, zda je možné ji bezpečně provést.

---

# 11. Bezpečnost má přednost před výkonem

Aplikace nesmí maximalizovat výkon za cenu ignorování bolesti, únavy nebo zdravotního rizika.

Při nejistotě musí být doporučení konzervativnější.

AI musí rozlišovat mezi:

* běžnou tréninkovou únavou,
* svalovou bolestí po tréninku,
* neobvyklou nebo ostrou bolestí,
* potenciálně akutním problémem,
* situací vyžadující odbornou pomoc.

AI nesmí vystupovat jako lékař ani vytvářet diagnózy.

Při rizikových příznacích má doporučit přerušení aktivity a vhodnou odbornou konzultaci.

Zdravotní bezpečnost nesmí být nahrazena pouze obecným upozorněním v podmínkách používání.

---

# 12. Personalizace musí vycházet z dat

Aplikace se nesmí pouze tvářit personalizovaně.

Doporučení musí vycházet z konkrétních dostupných informací.

Personalizaci mohou ovlivňovat například:

* věk,
* úroveň zkušeností,
* sporty,
* cíle,
* pravidelný rozvrh,
* vybavení,
* délka dostupného času,
* preference,
* historie tréninku,
* subjektivní náročnost,
* spánek,
* tepová frekvence,
* HRV,
* zranění a omezení,
* dokončování předchozích plánů.

Pokud nemá aplikace dostatek dat, musí to přiznat a případně si vyžádat doplnění.

Nesmí předstírat jistotu.

---

# 13. Doporučení musí respektovat realitu uživatele

Dokonalý plán, který uživatel nedokáže dodržovat, je špatný plán.

Aplikace musí respektovat:

* pracovní a školní rozvrh,
* rodinné povinnosti,
* dostupné vybavení,
* finanční omezení,
* cestování,
* preference,
* počasí, pokud je relevantní,
* přístup ke sportovištím,
* maximální přijatelnou délku tréninku.

Udržitelnost má přednost před teoretickou dokonalostí.

Plán se musí přizpůsobit životu uživatele, ne požadovat, aby uživatel přizpůsobil celý život aplikaci.

---

# 14. Každá důležitá informace má jeden zdroj pravdy

Stejná informace nesmí být vedena nezávisle na několika místech.

Například pravidelný florbalový trénink nesmí být samostatně uložen:

* v kalendáři,
* v uživatelském profilu,
* v AI paměti,
* v tréninkovém plánu,

aniž by mezi těmito záznamy existoval jednoznačný vztah.

Systém musí určit hlavní zdroj pravdy a ostatní zobrazení z něj odvozovat.

Tento princip platí zejména pro:

* uživatelský profil,
* cíle,
* sportovní aktivity,
* kalendář,
* workouty,
* zdravotní omezení,
* vybavení,
* wearable data,
* AI akce.

---

# 15. Automatizace musí být vratná

Každá automatická nebo AI provedená změna musí být, pokud je to technicky a logicky možné, vratná.

Uživatel musí mít možnost:

* vrátit poslední změnu,
* obnovit předchozí verzi plánu,
* porovnat plán před a po změně,
* zjistit, kdo nebo co změnu provedlo.

Systém musí ukládat historii významných změn.

Cílem není pouze zabránit chybám, ale také zvýšit důvěru uživatele v automatizaci.

---

# 16. Aplikace musí fungovat i bez AI

Základní sportovní funkce nesmí přestat fungovat při:

* výpadku AI služby,
* dočasné nedostupnosti internetu,
* vyčerpání limitu,
* chybě modelu.

Uživatel musí být i nadále schopen:

* zobrazit svůj plán,
* spustit workout,
* dokončit workout,
* zapisovat série a opakování,
* prohlížet kalendář,
* zobrazit uložené cíle,
* synchronizovat data později.

AI přidává inteligenci, ale nesmí být jedinou cestou k základním datům.

---

# 17. Offline režim je součást produktu

Mobilní aplikace musí počítat s používáním:

* v posilovně se slabým signálem,
* na venkovním hřišti,
* v horách,
* na skalách,
* při cestování,
* v zahraničí.

Uživatel musí být schopen offline alespoň:

* otevřít uložený plán,
* zobrazit dnešní workout,
* zaznamenat provedení cviků,
* dokončit workout,
* zapsat poznámku,
* zaznamenat základní aktivitu.

Data se synchronizují po obnovení spojení.

Funkce vyžadující AI mohou počkat, ale nesmí dojít ke ztrátě uživatelských dat.

---

# 18. Soukromí je výchozí nastavení

Sportovní, zdravotní a osobní data jsou soukromá.

Ve výchozím stavu nesmí být veřejná ani sdílená.

Uživatel musí přesně vědět:

* jaká data aplikace ukládá,
* odkud data pocházejí,
* která data jsou odesílána AI službě,
* s kým jsou data sdílena,
* jak data exportovat,
* jak data odstranit.

Sdílení musí být dobrovolné a konkrétní.

Souhlas s jedním druhem integrace nesmí automaticky znamenat souhlas se všemi ostatními.

---

# 19. Integrace nesmí určovat architekturu produktu

Health Connect, Apple Health, Garmin, Strava a další služby jsou zdroje a cíle dat.

Nesmí být hlavním datovým modelem aplikace.

Interní doménový model musí být nezávislý na konkrétním poskytovateli.

Externí data musí být převáděna do jednotného interního formátu.

Díky tomu může aplikace:

* kombinovat více zdrojů,
* řešit konflikty,
* měnit poskytovatele,
* podporovat nové integrace,
* fungovat i bez konkrétní služby.

---

# 20. Komplexita má být skryta, ne odstraněna

Tréninkové plánování je složité.

Aplikace tuto složitost nesmí ignorovat, ale musí ji skrýt za jednoduchým rozhraním.

Uživatel nemusí rozumět:

* periodizaci,
* řízení objemu,
* intenzitě,
* kumulované únavě,
* tréninkovým blokům,
* synchronizaci dat,
* AI nástrojům.

Musí však být schopen pochopit konkrétní doporučení a jejich důvody.

Systém může být uvnitř složitý, ale používání musí být jednoduché.

---

# 21. Základní uživatelská zkušenost musí být rychlá

Výkon aplikace je součást produktu.

Aplikace musí:

* rychle zobrazit dnešní plán,
* okamžitě reagovat při zapisování workoutu,
* neztrácet rozepsaná data,
* nezáviset při každém kliknutí na odpovědi serveru,
* používat optimistické aktualizace tam, kde je to bezpečné,
* mít jasné stavy načítání a synchronizace.

AI odpověď může trvat déle než běžná interakce, ale aplikace musí uživateli okamžitě ukázat, že požadavek zpracovává.

---

# 22. Produkt roste postupně

Dlouhodobá vize je rozsáhlá, ale implementace musí být inkrementální.

Každá vývojová etapa musí dodat funkční a otestovatelný celek.

Nová funkce se přidává pouze tehdy, když:

* má jasnou uživatelskou hodnotu,
* má definovaný datový model,
* má popsané UX,
* má bezpečnostní pravidla,
* má testovací scénáře,
* nenarušuje základní principy.

Budoucí ambiciózní nápady se zapisují do dokumentace, ale nesmí automaticky rozšiřovat aktuální implementační etapu.

---

# 23. Technologie slouží produktu

Technologie se vybírá podle potřeb produktu, nikoliv podle momentální popularity.

Každé technické rozhodnutí musí zohlednit:

* dlouhodobou udržovatelnost,
* bezpečnost,
* testovatelnost,
* multiplatformní podporu,
* offline používání,
* synchronizaci,
* provozní náklady,
* dostupnost vývojářů,
* možnost budoucí migrace.

Architektura nesmí být zbytečně složitá pouze proto, aby působila profesionálně.

---

# 24. Kvalita dat je důležitější než množství dat

Více dat automaticky neznamená lepší doporučení.

Systém musí rozlišovat mezi:

* spolehlivě naměřenými daty,
* odhadovanými daty,
* ručně zadanými daty,
* subjektivními pocity,
* daty importovanými z externích zdrojů,
* chybějícími daty.

Doporučení musí odpovídat kvalitě dostupných informací.

Aplikace nesmí vytvářet přesné závěry z nepřesných nebo neúplných dat.

---

# 25. Důvěra je důležitější než překvapení

Cílem AI není uživatele ohromovat nečekanými změnami.

Cílem je být spolehlivým partnerem.

Aplikace má být:

* předvídatelná,
* transparentní,
* konzistentní,
* bezpečná,
* opravitelná.

Uživatel musí vědět, co může od aplikace očekávat.

Chytrá funkce, které uživatel nedůvěřuje, nemá dlouhodobou hodnotu.

---

# 26. Měření souladu s principy

Před implementací každé významné funkce musí být zodpovězeny následující otázky:

1. Jakou konkrétní hodnotu přináší uživateli?
2. Snižuje, nebo zvyšuje administrativu?
3. Zůstává uživatel pod kontrolou?
4. Je chování vysvětlitelné?
5. Je změna vratná?
6. Funguje základní scénář bez AI?
7. Je respektováno soukromí?
8. Je určeno, který systém je zdrojem pravdy?
9. Funguje řešení pro více sportů?
10. Je možné funkci spolehlivě testovat?
11. Je řešení bezpečné při chybě nebo neúplných datech?
12. Patří funkce do aktuální etapy projektu?

Pokud na některou otázku neexistuje uspokojivá odpověď, funkce není připravena k implementaci.

---

# 27. Priorita principů

Pokud jsou dva principy v konkrétní situaci v konfliktu, platí následující pořadí priorit:

1. Bezpečnost uživatele.
2. Soukromí a ochrana dat.
3. Kontrola uživatele.
4. Zachování dat a historie.
5. Spolehlivost.
6. Srozumitelnost.
7. Jednoduchost používání.
8. Personalizace.
9. Automatizace.
10. Rychlost vývoje.

Toto pořadí neznamená, že méně prioritní principy nejsou důležité. Určuje však, jak rozhodovat při skutečném konfliktu.

---

# 28. Závěrečné pravidlo

AI Trainer nesmí uživateli přidávat další povinnost.

Musí mu ubírat rozhodování, administrativu a nejistotu.

Každá součást produktu musí směřovat k tomu, aby uživatel mohl věnovat méně času plánování a více času smysluplnému pohybu.
