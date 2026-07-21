# AI Trainer – Information Architecture

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/04-ux/information-architecture.md`

---

# 1. Účel dokumentu

Tento dokument definuje informační architekturu mobilní aplikace AI Trainer.

Popisuje:

* hlavní navigační strukturu,
* jednotlivé sekce aplikace,
* obrazovky a podstránky,
* vztahy mezi obrazovkami,
* vstupní body,
* hierarchii informací,
* práci s modálními okny,
* deep links,
* globální stavy,
* rozdělení funkcí mezi hlavní navigaci a kontextové akce.

Cílem je zajistit, aby aplikace působila jako jeden propojený systém a nevznikala jako nahodilá kolekce obrazovek.

Informační architektura musí podporovat:

* rychlé každodenní používání,
* přirozenou práci s kalendářem,
* přímé spuštění workoutu,
* ovládání aplikace přes AI,
* práci s více sporty,
* offline režim,
* jednoduché rozšiřování o nové funkce,
* Android i iOS z jedné Flutter codebase.

---

# 2. Základní navigační model

Aplikace používá pět hlavních sekcí dostupných ve spodní navigaci:

1. **Dnes**
2. **Kalendář**
3. **AI trenér**
4. **Pokrok**
5. **Profil**

Tyto sekce představují pět hlavních uživatelských otázek:

| Sekce     | Hlavní otázka                          |
| --------- | -------------------------------------- |
| Dnes      | Co mám dnes dělat?                     |
| Kalendář  | Jak vypadá můj plán?                   |
| AI trenér | Co potřebuji změnit nebo probrat?      |
| Pokrok    | Zlepšuji se?                           |
| Profil    | Z čeho aplikace při plánování vychází? |

Hlavní navigace musí zůstat stabilní napříč aplikací.

Nemá se dynamicky měnit podle sportu, úrovně uživatele ani připojených integrací.

---

# 3. Navigační vrstvy

Aplikace používá čtyři úrovně navigace.

## 3.1 Primární navigace

Spodní navigace:

* Dnes
* Kalendář
* AI trenér
* Pokrok
* Profil

Každá sekce si zachovává vlastní navigační historii.

Pokud uživatel například:

1. otevře Kalendář,
2. přejde do detailu workoutu,
3. přepne do Profilu,
4. vrátí se do Kalendáře,

má se vrátit do předchozího detailu workoutu, pokud mezitím neproběhla akce vyžadující reset navigace.

## 3.2 Sekundární navigace

Používá se uvnitř hlavních sekcí.

Příklady:

* záložky Den / Týden / Měsíc v Kalendáři,
* Přehled / Cíle / Statistiky v Pokroku,
* Sporty / Vybavení / Dostupnost v Profilu.

Sekundární navigace nesmí nahrazovat hlavní sekce.

## 3.3 Detailní navigace

Slouží k otevření konkrétního objektu:

* workout,
* aktivita,
* cíl,
* plán,
* sport,
* integrace,
* AI návrh,
* týdenní shrnutí.

Detailní obrazovka musí vždy jasně zobrazit:

* název objektu,
* stav,
* vztah k širšímu kontextu,
* dostupné akce.

## 3.4 Dočasná navigace

Používá se pro krátké úkoly:

* výběr času,
* nahlášení únavy,
* nahlášení bolesti,
* potvrzení změny,
* výběr alternativního cviku,
* nastavení připomenutí.

Může být zobrazena jako:

* bottom sheet,
* dialog,
* fullscreen modal,
* krátký průvodce.

Po dokončení se uživatel vrací do původního kontextu.

---

# 4. Globální aplikační shell

Globální shell aplikace obsahuje:

* hlavní navigaci,
* směrování,
* globální stav přihlášení,
* stav synchronizace,
* stav offline režimu,
* globální notifikace,
* zpracování deep linků,
* bezpečné otevření konkrétního objektu.

## 4.1 Horní aplikační lišta

Horní lišta se mění podle aktuální obrazovky.

Může obsahovat:

* název obrazovky,
* tlačítko zpět,
* kontextové menu,
* stav synchronizace,
* datum nebo období,
* informační tlačítko,
* akci pro přidání položky.

Nemá obsahovat globální hlavní navigaci.

## 4.2 Globální stav synchronizace

Uživatel musí být schopen zjistit:

* zda je aplikace online,
* zda čekají data na synchronizaci,
* zda došlo ke konfliktu,
* zda synchronizace selhala.

Stav nemá být rušivý při normálním provozu.

Viditelnější upozornění se zobrazí pouze při:

* dlouhodobé chybě,
* konfliktu,
* riziku ztráty dat,
* nemožnosti dokončit důležitou akci.

## 4.3 Globální zprávy

Používají se pro:

* potvrzení změny,
* upozornění na chybu,
* možnost vrácení,
* upozornění na offline uložení,
* informaci o nedostupnosti AI.

Preferované formy:

* snackbar,
* banner,
* inline zpráva,
* stavová karta.

---

# 5. Přehled obrazovek

## 5.1 Veřejná a autentizační část

* Splash screen
* Úvodní obrazovka
* Registrace
* Přihlášení
* Obnovení hesla
* Ověření e-mailu
* Souhlas s podmínkami
* Právní a bezpečnostní informace

## 5.2 Onboarding

* Úvod do onboardingu
* Volba způsobu onboardingu
* Konverzační onboarding
* Krokový onboarding
* Výběr sportů
* Detail sportu
* Pravidelný rozvrh
* Cíle
* Dostupnost
* Vybavení
* Omezení
* Preference
* Shrnutí profilu
* Generování prvního plánu
* Náhled prvního plánu
* Potvrzení plánu

## 5.3 Dnes

* Dnešní přehled
* Detail dnešní aktivity
* Rychlý check-in
* Nahlášení únavy
* Nahlášení bolesti
* Dnes nestíhám
* Změna programu
* Dnešní AI doporučení
* Přehled čekajících návrhů

## 5.4 Kalendář

* Denní kalendář
* Týdenní kalendář
* Měsíční kalendář
* Detail dne
* Přidání aktivity
* Úprava aktivity
* Přesunutí aktivity
* Opakovaná aktivita
* Detail plánu
* Historie změn plánu
* Náhled změnové sady

## 5.5 Workout

* Detail workoutu
* Předtréninková obrazovka
* Aktivní workout
* Detail cviku
* Výběr alternativního cviku
* Pauzový časovač
* Nahlášení problému během workoutu
* Pozastavený workout
* Dokončení workoutu
* Souhrn workoutu
* Historie workoutu

## 5.6 AI trenér

* Hlavní chat
* Nová konverzace
* Kontextová konverzace
* Detail AI návrhu
* Náhled změn
* Částečné potvrzení
* Historie AI akcí
* Vysvětlení plánu
* AI týdenní revize

## 5.7 Pokrok

* Přehled pokroku
* Cíle
* Detail cíle
* Výkonové metriky
* Pravidelnost
* Týdenní shrnutí
* Měsíční shrnutí
* Osobní rekordy
* Historie aktivit
* Detail historické aktivity

## 5.8 Profil

* Přehled profilu
* Osobní údaje
* Sporty
* Detail sportu
* Přidání sportu
* Cíle
* Pravidelný rozvrh
* Dostupnost
* Vybavení
* Omezení
* Preference tréninku
* Preference AI
* Notifikace
* Integrace
* Soukromí
* Export dat
* Účet
* Smazání účtu

---

# 6. Sekce Dnes

Sekce Dnes je výchozí obrazovkou po přihlášení.

Musí poskytovat uživateli co nejrychlejší odpověď na otázku:

> Co mám dnes dělat?

## 6.1 Hierarchie obsahu

Pořadí:

1. stav dne,
2. nejbližší aktivita,
3. dnešní timeline,
4. rychlé akce,
5. důležité AI návrhy,
6. stav regenerace,
7. hlavní cíl,
8. případný stav synchronizace.

## 6.2 Dnešní přehled

Obsahuje:

* datum,
* stručný souhrn dne,
* všechny dnešní aktivity,
* jejich pořadí,
* stav dokončení,
* pevnost nebo flexibilitu,
* plánovanou délku,
* vazbu na cíle.

## 6.3 Karta aktivity

Karta musí rozlišit:

* plánovaný workout,
* týmový trénink,
* zápas,
* závod,
* mobilitu,
* regeneraci,
* obecnou aktivitu,
* dokončenou aktivitu.

Každá karta může obsahovat:

* název,
* čas,
* délku,
* typ,
* stav,
* prioritu,
* stručný účel,
* primární akci.

## 6.4 Primární akce karty

Podle stavu:

* `Spustit`
* `Pokračovat`
* `Zobrazit`
* `Dokončit záznam`
* `Zkontrolovat změnu`
* `Potvrdit účast`

## 6.5 Rychlé akce

Rychlé akce musí být kontextové.

Základní sada:

* Jsem unavený
* Něco mě bolí
* Dnes nestíhám
* Změnil se program
* Přidat aktivitu

Pokud dnes není žádný workout, může aplikace nabídnout:

* Naplánovat aktivitu
* Zeptat se AI
* Přidat vlastní aktivitu

## 6.6 Více workoutů za den

Při více aktivitách musí být jasné:

* které jsou hlavní,
* které jsou doplňkové,
* které jsou volitelné,
* jejich doporučené pořadí,
* minimální rozestup.

---

# 7. Sekce Kalendář

Kalendář je hlavním místem pro prohlížení a ruční správu plánu.

## 7.1 Výchozí pohled

Výchozí pohled je týdenní.

Důvody:

* týden je základní plánovací jednotka,
* uživatel vidí vztahy mezi aktivitami,
* snadněji rozpozná konflikty,
* odpovídá většině tréninkových plánů.

Uživatel si může poslední používaný pohled zapamatovat.

## 7.2 Denní pohled

Použití:

* detail dne,
* více workoutů,
* pořadí aktivit,
* podrobné časy,
* rychlé přesuny.

## 7.3 Týdenní pohled

Použití:

* běžné plánování,
* kontrola zátěže,
* přesuny,
* zobrazení pevných a flexibilních aktivit,
* rychlá AI reorganizace.

## 7.4 Měsíční pohled

Použití:

* orientace,
* závody,
* zápasy,
* sportovní výjezdy,
* dlouhodobé bloky,
* cílové termíny.

Nemá zobrazovat příliš mnoho detailů jednotlivých cviků.

## 7.5 Detail dne

Otevírá se kliknutím na den.

Obsahuje:

* všechny aktivity,
* souhrnnou plánovanou zátěž,
* dokončení,
* změny proti původnímu plánu,
* poznámky,
* rychlou akci `Upravit den s AI`.

## 7.6 Přidání aktivity

Tlačítko `Přidat` otevře výběr:

* workout,
* sportovní trénink,
* zápas nebo závod,
* mobilita,
* regenerace,
* volno,
* vlastní aktivita.

## 7.7 Přesunutí aktivity

Možnosti:

* drag-and-drop,
* změna data a času ve formuláři,
* přirozený jazyk přes AI.

Při přesunu aplikace zobrazí:

* konflikt,
* vztah k dalším aktivitám,
* případné doporučení.

## 7.8 Detail plánu

Detail plánu je dostupný z Kalendáře a Profilu.

Obsahuje:

* název,
* období,
* cíle,
* aktuální blok,
* typický týden,
* verzi,
* stav,
* datum poslední změny,
* možnost revize,
* historii změn.

---

# 8. Sekce AI trenér

AI trenér je komunikační a akční vrstva.

Nemá být odděleným chatbotem bez vazby na aplikaci.

## 8.1 Hlavní obrazovka

Obsahuje:

* poslední konverzaci,
* kontextové návrhy,
* rozepracované návrhy,
* upozornění na nevyřízené změny,
* vstupní pole.

## 8.2 Kontextové návrhy

Podle situace například:

* Upravit dnešní workout
* Vysvětlit tento týden
* Naplánovat víkend
* Zkrátit tréninky
* Přidat nový cíl
* Vyhodnotit pokrok
* Změnit vybavení
* Vyřešit bolest nebo únavu

## 8.3 Typy konverzací

### Obecná konverzace

Týká se širšího sportovního života.

### Kontextová konverzace

Je navázaná na:

* workout,
* den,
* týden,
* plán,
* cíl,
* aktivitu,
* konkrétní AI návrh.

### Onboardingová konverzace

Používá se při získávání strukturovaných informací.

## 8.4 Kontextový indikátor

Chat musí jasně zobrazit aktuální kontext.

Příklad:

> Řešíme: Workout Upper Body A, dnes v 18:00

Uživatel může kontext:

* změnit,
* odstranit,
* otevřít.

## 8.5 AI návrhy

AI návrh není pouze zpráva.

Je to strukturovaný objekt s:

* typem,
* důvodem,
* změnami,
* rozsahem,
* riziky,
* stavem,
* potvrzením,
* možností vrácení.

## 8.6 Historie AI akcí

Oddělená od běžné historie chatu.

Obsahuje:

* navržené akce,
* přijaté akce,
* odmítnuté akce,
* automaticky provedené akce,
* vrácené akce.

---

# 9. Sekce Pokrok

Sekce Pokrok odpovídá na otázku:

> Zlepšuji se a funguje můj plán?

## 9.1 Výchozí obrazovka

Obsahuje:

* hlavní cíl,
* aktuální trend,
* pravidelnost,
* důležitou metriku,
* poslední týdenní shrnutí,
* nejbližší milník.

## 9.2 Přehled cílů

Rozdělení:

* hlavní cíl,
* aktivní vedlejší cíle,
* budoucí cíle,
* pozastavené cíle,
* dokončené cíle.

## 9.3 Detail cíle

Obsahuje:

* popis,
* prioritu,
* termín,
* výchozí stav,
* aktuální stav,
* cílový stav,
* metriky,
* související workouty,
* milníky,
* historii změn.

## 9.4 Statistiky

Statistiky musí být členěny podle účelu.

Ne podle toho, jaká data jsou technicky dostupná.

Kategorie:

* pravidelnost,
* výkon,
* objem,
* intenzita,
* regenerace,
* cíle,
* sportovní zatížení.

## 9.5 Týdenní shrnutí

Obsahuje:

* plán versus skutečnost,
* důležité změny,
* subjektivní stav,
* hlavní výkony,
* doporučení pro další týden.

## 9.6 Historie aktivit

Filtrování podle:

* data,
* sportu,
* typu,
* cíle,
* dokončení,
* zdroje dat.

---

# 10. Sekce Profil

Profil obsahuje dlouhodobé vstupy, ze kterých aplikace vychází.

## 10.1 Přehled profilu

Zobrazuje souhrn:

* hlavní sporty,
* hlavní cíl,
* pravidelný rozvrh,
* dostupnost,
* vybavení,
* aktivní omezení,
* připojené integrace.

## 10.2 Osobní údaje

Obsahují pouze údaje nutné pro:

* účet,
* personalizaci,
* bezpečnost,
* právní požadavky.

Nemají se míchat se sportovními preferencemi.

## 10.3 Sporty

Seznam sportů obsahuje:

* název,
* roli,
* úroveň,
* frekvenci,
* sezonní stav,
* prioritu.

## 10.4 Detail sportu

Obsahuje:

* uživatelský název,
* systémovou kategorii,
* úroveň,
* historii,
* cíle,
* pravidelný rozvrh,
* typickou zátěž,
* preferované prostředí,
* poznámky.

## 10.5 Pravidelný rozvrh

Zobrazuje opakované události:

* týmové tréninky,
* pravidelné lekce,
* zápasy,
* závody,
* dostupnost.

Musí být jasně oddělen:

* rozvrh sportovních povinností,
* obecná dostupnost uživatele.

## 10.6 Vybavení

Členění:

* doma,
* fitko,
* venku,
* přenosné,
* dočasné,
* vlastní položky.

## 10.7 Omezení

Členění:

* dlouhodobé omezení,
* dočasné omezení,
* aktuální bolest,
* doporučení odborníka,
* uživatelská preference.

## 10.8 Preference AI

Uživatel nastaví:

* míru automatizace,
* délku vysvětlení,
* styl komunikace,
* zda povolit drobné automatické změny,
* jak často má AI navrhovat revize.

## 10.9 Integrace

Každá integrace zobrazuje:

* stav,
* oprávnění,
* poslední synchronizaci,
* importované datové typy,
* možnost odpojení,
* případné chyby.

---

# 11. Workout jako samostatná navigační oblast

Workout není položkou hlavní navigace, ale samostatným detailním flow.

Může být otevřen z:

* Dnes,
* Kalendáře,
* notifikace,
* AI návrhu,
* historie,
* cíle,
* deep linku.

## 11.1 Detail workoutu

Obsahuje:

* název,
* datum,
* čas,
* stav,
* účel,
* délku,
* cviky,
* vybavení,
* vazbu na cíle,
* vazbu na plán,
* historii změn.

## 11.2 Stavy workoutu

* koncept,
* plánovaný,
* připravený,
* upravený,
* probíhající,
* pozastavený,
* dokončený,
* částečně dokončený,
* vynechaný,
* zrušený,
* přesunutý.

## 11.3 Aktivní workout

Aktivní workout používá vlastní fullscreen režim.

Důvody:

* minimalizace rušení,
* velké ovládací prvky,
* snadné zapisování,
* ochrana proti nechtěnému opuštění.

## 11.4 Návrat z aktivního workoutu

Při pokusu opustit obrazovku:

* workout zůstane aktivní,
* data se automaticky uloží,
* uživatel může pokračovat později,
* aplikace nesmí vynucovat okamžité ukončení.

---

# 12. Objekty a jejich vztahy

## 12.1 Uživatel

Má:

* profil,
* sporty,
* cíle,
* dostupnost,
* vybavení,
* omezení,
* preference,
* integrace.

## 12.2 Sport

Může být navázán na:

* cíle,
* aktivity,
* workouty,
* plán,
* metriky,
* sezonu.

## 12.3 Cíl

Může být navázán na:

* jeden nebo více sportů,
* plán,
* workouty,
* metriky,
* milníky.

## 12.4 Plán

Obsahuje:

* období,
* cíle,
* bloky,
* týdny,
* workouty,
* pravidla adaptace,
* verze.

## 12.5 Workout template

Definuje opakovatelnou strukturu.

Obsahuje:

* části,
* cviky,
* pravidla progrese,
* očekávanou délku,
* potřebné vybavení.

## 12.6 Workout instance

Je konkrétní naplánovaný výskyt.

Obsahuje:

* datum,
* čas,
* stav,
* plánované hodnoty,
* lokální úpravy,
* skutečné provedení.

## 12.7 Aktivita

Reprezentuje skutečně provedený pohyb.

Může vzniknout:

* dokončením workoutu,
* ručním zápisem,
* importem,
* GPS trackerem.

## 12.8 AI návrh

Obsahuje navržené změny jednoho nebo více objektů.

## 12.9 Změnová sada

Reprezentuje skupinu souvisejících změn.

Například:

* přidání lezeckého víkendu,
* přesun dvou workoutů,
* zkrácení pondělního workoutu,
* přidání regenerace.

---

# 13. Rozlišení plánu, kalendáře a aktivity

Tři pojmy musí být v UX jasně rozlišeny.

## 13.1 Plán

Odpovídá na otázku:

> Jaký je dlouhodobý záměr?

## 13.2 Kalendář

Odpovídá na otázku:

> Kdy mám co dělat?

## 13.3 Aktivita

Odpovídá na otázku:

> Co jsem skutečně udělal?

Uživatel nemusí znát interní technické rozdíly, ale rozhraní je nesmí směšovat.

---

# 14. Modální obrazovky

## 14.1 Bottom sheet

Použití:

* rychlý výběr,
* krátký formulář,
* jednoduchá kontextová akce.

Příklady:

* změna času,
* výběr únavy,
* přidání série,
* rychlá poznámka.

## 14.2 Dialog

Použití:

* potvrzení rizikové akce,
* jednoduché rozhodnutí,
* upozornění.

Příklady:

* zrušení workoutu,
* odstranění cíle,
* opuštění neuložené změny.

## 14.3 Fullscreen modal

Použití:

* komplexnější, ale dočasný flow.

Příklady:

* vytvoření aktivity,
* nahlášení bolesti,
* úprava workoutu,
* náhled rozsáhlé AI změny.

## 14.4 Samostatná obrazovka

Použití:

* objekt má vlastní historii,
* uživatel se k němu bude vracet,
* obsahuje více akcí.

Příklady:

* detail cíle,
* detail workoutu,
* detail sportu,
* detail plánu.

---

# 15. Deep link architektura

Aplikace musí podporovat deep links minimálně pro:

* dnešní přehled,
* konkrétní datum,
* workout,
* aktivitu,
* AI návrh,
* změnovou sadu,
* cíl,
* týdenní shrnutí,
* integraci,
* nastavení notifikací.

Příklad interní struktury:

```text
/app/today
/app/calendar/2026-08-12
/app/workouts/{workoutId}
/app/activities/{activityId}
/app/goals/{goalId}
/app/ai/proposals/{proposalId}
/app/change-sets/{changeSetId}
/app/progress/weekly/{weekId}
/app/profile/integrations/{integrationId}
```

Konkrétní URL schéma bude definováno později v technické dokumentaci.

## 15.1 Chování deep linku

Systém musí:

1. ověřit přihlášení,
2. ověřit oprávnění,
3. načíst aktuální verzi objektu,
4. zpracovat offline stav,
5. zpracovat neexistující objekt,
6. zpracovat zastaralý odkaz.

---

# 16. Vyhledávání

První verze nemusí mít globální vyhledávání přes celý produkt.

Lokální vyhledávání se používá pro:

* sporty,
* cviky,
* vybavení,
* historické aktivity,
* integrace.

Globální vyhledávání lze přidat později, pokud vznikne dostatečné množství obsahu.

---

# 17. Filtry

Filtry musí být dostupné tam, kde výrazně zvyšují přehlednost.

## 17.1 Kalendář

Možné filtry:

* sport,
* typ aktivity,
* dokončení,
* plánované versus skutečné,
* importované versus ruční.

## 17.2 Historie

Možné filtry:

* období,
* sport,
* aktivita,
* cíl,
* zdroj,
* intenzita.

## 17.3 Pokrok

Možné filtry:

* cíl,
* sport,
* metrika,
* období.

Filtry musí být resetovatelné a jejich aktivní stav musí být viditelný.

---

# 18. Prázdné stavy

Každá hlavní sekce musí mít připravený smysluplný prázdný stav.

## 18.1 Dnes bez plánu

> Dnes zatím nemáš nic naplánováno.

Akce:

* Přidat aktivitu
* Naplánovat s AI

## 18.2 Kalendář bez aktivit

> Tvůj kalendář je zatím prázdný.

Akce:

* Vytvořit plán
* Přidat aktivitu

## 18.3 AI bez konverzace

> Popiš mi své cíle nebo změnu, kterou potřebuješ vyřešit.

## 18.4 Pokrok bez dat

> Pokrok se zobrazí po dokončení prvních aktivit.

## 18.5 Profil bez sportu

> Přidej sport nebo aktivitu, které se věnuješ.

---

# 19. Chybové stavy

## 19.1 Objekt nebyl nalezen

Příklad:

> Tento workout už neexistuje nebo k němu nemáš přístup.

Akce:

* Zpět do kalendáře
* Obnovit

## 19.2 Zastaralá verze

Příklad:

> Tento plán byl mezitím změněn na jiném zařízení.

Akce:

* Zobrazit aktuální verzi
* Porovnat změny

## 19.3 Nedostupná AI

> AI trenér je dočasně nedostupný. Ostatní části aplikace dál fungují.

## 19.4 Chyba synchronizace

> Tvoje změny jsou uložené v telefonu a synchronizují se později.

## 19.5 Nedostatečná data

> K vytvoření bezpečného návrhu potřebuji ještě doplnit několik informací.

---

# 20. Offline informační architektura

Offline musí být dostupné:

* Dnes,
* synchronizovaná část Kalendáře,
* detaily uložených workoutů,
* aktivní workout,
* dokončení workoutu,
* základní Profil,
* uložené cíle,
* lokální historie.

Offline mohou být omezené:

* AI chat,
* nový AI plán,
* komplexní analýza,
* aktuální wearable synchronizace,
* některé mapové funkce.

Každá obrazovka musí jasně rozlišit:

* plně dostupné,
* dostupné z poslední synchronizace,
* nedostupné offline.

---

# 21. Informační priorita podle zkušenosti uživatele

Aplikace musí podporovat různé úrovně zkušeností bez vytváření oddělených produktů.

## 21.1 Začátečník

Preferuje:

* jednoduché názvy,
* méně metrik,
* více vysvětlení,
* jasné primární akce,
* méně možností na jedné obrazovce.

## 21.2 Pokročilý uživatel

Může zobrazit:

* více metrik,
* přesnější hodnoty,
* historii výkonu,
* podrobnější plán,
* více manuálních možností.

## 21.3 Princip progresivního odhalování

Pokročilé informace se zobrazí:

* po rozbalení,
* v detailu,
* podle nastavení,
* podle relevance.

Hlavní obrazovky nesmí být přeplněné.

---

# 22. Univerzální podpora sportů

Informační architektura nesmí být navržena jen pro:

* posilování,
* běh,
* fotbal,
* florbal,
* lezení.

Musí podporovat libovolný sport prostřednictvím obecných objektů:

* sport,
* událost,
* workout,
* aktivita,
* cíl,
* metrika,
* zatížení,
* vybavení,
* prostředí.

Specializované obrazovky mohou být později přidány pro konkrétní sporty, ale musí navazovat na společný základ.

Příklad:

* běžecký workout může zobrazovat tempo a vzdálenost,
* silový workout série a opakování,
* mobilita čas a strany těla,
* vlastní sport délku a subjektivní intenzitu.

Všechny však zůstávají součástí stejného kalendáře, historie a plánovacího systému.

---

# 23. Navigační pravidla pro Android a iOS

Aplikace používá společnou informační architekturu.

Platformní rozdíly se projeví pouze v očekávaném chování komponent.

## 23.1 Android

Respektovat:

* systémové tlačítko Zpět,
* prediktivní gesto Zpět,
* Android deep links,
* Material navigační zvyklosti.

## 23.2 iOS

Respektovat:

* swipe back,
* safe areas,
* iOS navigační zvyklosti,
* universal links,
* modální chování.

## 23.3 Společná pravidla

Na obou platformách musí být:

* stejná logika sekcí,
* stejné objekty,
* stejné akce,
* stejná dostupnost dat,
* stejné bezpečnostní potvrzení.

Vizuální a interakční detaily mohou být platformně adaptivní.

---

# 24. Stav přihlášení

Aplikace musí rozlišovat:

* nepřihlášený uživatel,
* částečně dokončená registrace,
* přihlášený uživatel bez dokončeného onboardingu,
* přihlášený uživatel bez plánu,
* plně aktivní uživatel,
* účet čekající na smazání,
* relace vyžadující nové ověření.

Směrování po spuštění musí odpovídat aktuálnímu stavu.

---

# 25. Doporučená route mapa

```text
/
├── splash
├── auth
│   ├── welcome
│   ├── sign-in
│   ├── sign-up
│   ├── verify-email
│   └── reset-password
│
├── onboarding
│   ├── intro
│   ├── method
│   ├── conversation
│   ├── sports
│   ├── schedule
│   ├── goals
│   ├── availability
│   ├── equipment
│   ├── limitations
│   ├── preferences
│   ├── summary
│   ├── plan-generation
│   └── plan-preview
│
└── app
    ├── today
    │   ├── overview
    │   ├── fatigue
    │   ├── pain
    │   ├── no-time
    │   └── schedule-change
    │
    ├── calendar
    │   ├── day
    │   ├── week
    │   ├── month
    │   ├── day-detail
    │   ├── add-activity
    │   ├── edit-activity
    │   ├── plan-detail
    │   └── plan-history
    │
    ├── coach
    │   ├── chat
    │   ├── conversation
    │   ├── proposal
    │   ├── change-preview
    │   └── action-history
    │
    ├── progress
    │   ├── overview
    │   ├── goals
    │   ├── goal-detail
    │   ├── metrics
    │   ├── weekly-review
    │   ├── monthly-review
    │   └── activity-history
    │
    ├── profile
    │   ├── overview
    │   ├── personal-data
    │   ├── sports
    │   ├── sport-detail
    │   ├── schedule
    │   ├── availability
    │   ├── equipment
    │   ├── limitations
    │   ├── ai-preferences
    │   ├── notifications
    │   ├── integrations
    │   ├── privacy
    │   ├── export
    │   └── account
    │
    ├── workouts
    │   ├── detail
    │   ├── pre-workout
    │   ├── active
    │   ├── exercise
    │   ├── replacement
    │   ├── completion
    │   └── summary
    │
    └── activities
        ├── detail
        └── edit
```

Tato mapa je produktová. Konkrétní Flutter route names budou definovány v mobilní architektuře.

---

# 26. Kritéria dokončení obrazovky

Každá obrazovka musí mít před implementací definováno:

1. účel,
2. vstupní body,
3. hlavní obsah,
4. primární akci,
5. sekundární akce,
6. navigaci zpět,
7. načítací stav,
8. prázdný stav,
9. chybový stav,
10. offline stav,
11. oprávnění,
12. analytické události,
13. přístupnost,
14. deep link, pokud je relevantní,
15. vztah k doménovým objektům.

---

# 27. Co informační architektura nesmí způsobit

Architektura nesmí:

* skrýt dnešní workout hluboko v menu,
* vyžadovat chat pro každou změnu,
* vytvořit samostatný kalendář pro každý sport,
* oddělit wearables od skutečných aktivit,
* směšovat plánované a dokončené hodnoty,
* považovat AI zprávu za náhradu skutečné změny dat,
* vytvářet duplicitní zdroje pravdy,
* zobrazovat citlivé údaje bez odpovídajícího kontextu,
* omezit uživatele na předem definované persony nebo sporty.

---

# 28. Priorita implementace obrazovek

## Stage 1

* globální shell,
* Dnes,
* týdenní Kalendář,
* detail workoutu,
* aktivní workout,
* dokončení workoutu,
* lokální historie,
* demo Profil.

## Stage 2

* autentizace,
* stav účtu,
* synchronizace,
* chybové a offline stavy.

## Stage 3

* onboarding,
* Sporty,
* Cíle,
* Dostupnost,
* Vybavení,
* Omezení.

## Stage 4

* detail plánu,
* náhled plánu,
* úprava kalendáře,
* historie verzí.

## Stage 5 a 6

* AI trenér,
* AI návrhy,
* změnové sady,
* nahlášení únavy,
* nahlášení bolesti,
* adaptace plánu.

## Pozdější etapy

* Pokrok,
* pokročilé statistiky,
* wearables,
* GPS,
* externí integrace.

---

# 29. Závěr

Informační architektura AI Traineru musí podporovat dva rovnocenné způsoby používání:

1. přímé ovládání přes standardní mobilní rozhraní,
2. přirozenou komunikaci přes AI trenéra.

Oba způsoby musí pracovat se stejnými objekty a stejnými daty.

Uživatel může workout:

* otevřít v kalendáři,
* spustit z obrazovky Dnes,
* otevřít z notifikace,
* upravit ručně,
* změnit přes AI.

Výsledek musí být vždy součástí jednoho propojeného systému.

Cílem není vytvořit co nejvíce obrazovek.

Cílem je, aby uživatel v každé situaci snadno našel odpověď na jednu z pěti základních otázek:

* Co mám dnes dělat?
* Jak vypadá můj plán?
* Co potřebuji změnit?
* Zlepšuji se?
* Z čeho aplikace při rozhodování vychází?
