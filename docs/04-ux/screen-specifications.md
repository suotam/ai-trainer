# AI Trainer – Screen Specifications

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/04-ux/screen-specifications.md`

---

# 1. Účel dokumentu

Tento dokument definuje funkční specifikaci hlavních obrazovek mobilní aplikace AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-personas.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/information-architecture.md`.

Cílem dokumentu je určit:

* účel každé obrazovky,
* její vstupní body,
* hierarchii obsahu,
* komponenty,
* primární a sekundární akce,
* stavy dat,
* offline chování,
* chybové stavy,
* přístupnost,
* deep links,
* analytické události,
* vazbu na doménové objekty.

Dokument zatím neurčuje:

* finální grafický styl,
* konkrétní barvy,
* přesné fonty,
* pixelové rozměry,
* konkrétní Flutter widgety,
* finální texty všech informačních hlášek.

Tyto oblasti budou řešeny v design systému a mobilní technické architektuře.

---

# 2. Obecná pravidla obrazovek

## 2.1 Každá obrazovka musí mít jasný hlavní účel

Na jedné obrazovce nesmí soutěžit několik stejně důležitých primárních akcí.

Uživatel musí během několika sekund pochopit:

* kde se nachází,
* co zde vidí,
* co zde může udělat,
* která akce je nejdůležitější.

## 2.2 Každá obrazovka musí podporovat systémové stavy

Podle relevance musí být definovány:

* načítání,
* prázdný stav,
* částečně načtená data,
* offline stav,
* čekající synchronizace,
* chyba synchronizace,
* konflikt,
* nedostatečné oprávnění,
* nedostupná AI,
* zastaralá verze objektu,
* objekt nenalezen.

## 2.3 Citlivé informace nesmí být zbytečně vystavené

Údaje o:

* bolesti,
* zdravotních omezeních,
* spánku,
* regeneraci,
* osobních datech,

se zobrazují jen tam, kde jsou relevantní.

Notifikace na zamčené obrazovce nesmí ve výchozím stavu zobrazovat citlivý detail.

## 2.4 Obrazovky musí fungovat s obecnými sporty

Komponenty nesmí předpokládat, že každá aktivita má:

* série,
* opakování,
* váhu,
* tempo,
* vzdálenost,
* GPS trasu.

Obsah se přizpůsobuje typu aktivity.

## 2.5 Akce AI musí být vizuálně rozlišitelné

Uživatel musí poznat:

* běžnou informaci,
* AI doporučení,
* AI návrh změny,
* čekající potvrzení,
* automaticky provedenou změnu,
* bezpečnostní upozornění.

## 2.6 Primární akce musí být snadno dosažitelná

Na mobilu musí být nejčastější akce dostupná:

* bez horizontálního posouvání,
* bez skrytí v rozbalovacím menu,
* s dostatečně velkou dotykovou plochou,
* pokud možno v dolní části obrazovky.

---

# 3. Společné komponenty

## 3.1 App Bar

Může obsahovat:

* název obrazovky,
* tlačítko zpět,
* datum nebo období,
* stav synchronizace,
* kontextové menu,
* tlačítko přidání,
* informační tlačítko.

App Bar nesmí být přeplněný.

## 3.2 Bottom Navigation

Položky:

* Dnes,
* Kalendář,
* AI trenér,
* Pokrok,
* Profil.

Musí podporovat:

* textový popisek,
* ikonu,
* zvýraznění aktivní položky,
* badge pro čekající návrh nebo problém.

Badge se používá střídmě.

## 3.3 Status Banner

Použití:

* offline stav,
* nedostupná AI,
* konflikt synchronizace,
* čekající potvrzení,
* bezpečnostní upozornění.

Banner musí mít:

* stručný text,
* relevantní akci,
* možnost zavření pouze tam, kde je to bezpečné.

## 3.4 Activity Card

Zobrazuje podle typu:

* název,
* čas,
* délku,
* sport,
* stav,
* prioritu,
* plánovanou nebo skutečnou hodnotu,
* primární akci.

Musí rozlišovat:

* pevnou událost,
* flexibilní workout,
* dokončenou aktivitu,
* AI návrh,
* zrušenou událost,
* aktivitu čekající na synchronizaci.

## 3.5 Goal Card

Obsahuje:

* název cíle,
* prioritu,
* aktuální stav,
* cílový stav,
* termín,
* poslední trend,
* vazbu na plán.

## 3.6 AI Proposal Card

Obsahuje:

* název návrhu,
* důvod,
* počet změn,
* rozsah,
* rizika nebo kompromisy,
* stav,
* akce.

Stavy:

* koncept,
* čeká na doplnění,
* připraven k potvrzení,
* částečně potvrzen,
* potvrzen,
* odmítnut,
* proveden,
* vrácen,
* neplatný kvůli novějším změnám.

## 3.7 Sync Indicator

Stavy:

* synchronizováno,
* synchronizace probíhá,
* čeká na připojení,
* chyba,
* konflikt.

Nemá se zobrazovat výrazně při normálním stavu.

## 3.8 Empty State

Obsahuje:

* srozumitelné vysvětlení,
* doporučenou primární akci,
* volitelnou sekundární akci,
* jednoduchý vizuál.

## 3.9 Confirmation Sheet

Použití:

* potvrzení významné změny,
* volba rozsahu změny,
* upozornění na důsledky.

Obsahuje:

* co se změní,
* co zůstane,
* zda je změna vratná,
* primární potvrzovací akci,
* bezpečné zrušení.

---

# 4. Splash Screen

## 4.1 Účel

Krátce překlenout inicializaci aplikace a určit další navigační krok.

## 4.2 Vstupní bod

* spuštění aplikace,
* návrat po ukončení procesu,
* otevření deep linku.

## 4.3 Obsah

* logo,
* název aplikace,
* jednoduchý indikátor inicializace pouze při delším načítání.

## 4.4 Logika

Aplikace během této fáze zjistí:

* stav přihlášení,
* stav onboardingu,
* stav lokální databáze,
* dostupný deep link,
* případnou nutnost migrace,
* zda účet čeká na nové ověření.

## 4.5 Navigační výsledky

* nepřihlášený → Úvodní obrazovka,
* nedokončená registrace → příslušný krok,
* nedokončený onboarding → poslední krok onboardingu,
* přihlášený bez plánu → Dnes s prázdným stavem,
* aktivní uživatel → Dnes,
* deep link → cílová obrazovka po ověření přístupu.

## 4.6 Chyba

Při lokální chybě:

* zobrazit stručnou zprávu,
* nabídnout opakování,
* případně bezpečný reset lokální cache bez ztráty serverových dat.

---

# 5. Úvodní obrazovka

## 5.1 Účel

Vysvětlit hlavní hodnotu produktu a nabídnout registraci nebo přihlášení.

## 5.2 Obsah

Pořadí:

1. logo,
2. hlavní sdělení,
3. krátké vysvětlení,
4. tlačítko `Začít`,
5. tlačítko `Přihlásit se`,
6. odkazy na soukromí a podmínky.

## 5.3 Hlavní sdělení

Příklad:

> Jeden plán pro všechny tvoje sporty, cíle a skutečný život.

## 5.4 Primární akce

`Začít`

## 5.5 Sekundární akce

`Přihlásit se`

## 5.6 Analytické události

* welcome_viewed,
* sign_up_started,
* sign_in_started,
* privacy_opened,
* terms_opened.

---

# 6. Registrace

## 6.1 Účel

Vytvořit nový uživatelský účet.

## 6.2 Možnosti

Podle dostupnosti:

* Apple,
* Google,
* e-mail a heslo.

## 6.3 Obsah e-mailové registrace

* e-mail,
* heslo,
* potvrzení hesla, pokud bude potřeba,
* souhlas s podmínkami,
* potvrzení věkového limitu,
* tlačítko vytvoření účtu.

## 6.4 Validace

* platný e-mail,
* požadovaná bezpečnost hesla,
* existující účet,
* souhlasy,
* síťová chyba.

## 6.5 Chování při offline stavu

Registraci nelze dokončit.

Aplikace musí jasně sdělit, že vyžaduje připojení.

## 6.6 Úspěšný výsledek

* vytvoření účtu,
* přihlášení,
* případné ověření e-mailu,
* přechod do onboardingu.

---

# 7. Přihlášení

## 7.1 Účel

Přihlásit existujícího uživatele.

## 7.2 Obsah

* e-mail,
* heslo,
* tlačítko přihlášení,
* Apple,
* Google,
* odkaz na obnovení hesla,
* odkaz na registraci.

## 7.3 Chybové stavy

* neplatné údaje,
* neověřený e-mail,
* zablokovaný účet,
* síťová chyba,
* účet čekající na odstranění,
* vypršená autentizační metoda.

## 7.4 Po úspěchu

* stáhnout minimální profil,
* spustit synchronizaci,
* zpracovat deep link,
* přejít na správnou obrazovku podle stavu účtu.

---

# 8. Úvod do onboardingu

## 8.1 Účel

Vysvětlit, co aplikace potřebuje zjistit a proč.

## 8.2 Obsah

* krátké vysvětlení,
* orientační oblasti onboardingu,
* informace o možnosti pozdější úpravy,
* informace o citlivých údajích,
* volba způsobu onboardingu.

## 8.3 Primární volby

* `Provést mě krok za krokem`
* `Popsat vše vlastními slovy`

## 8.4 Sekundární volba

`Dokončit později`

Tato volba může vést do omezené verze aplikace bez vytvořeného plánu.

---

# 9. Výběr sportů

## 9.1 Účel

Získat seznam sportů a pohybových aktivit uživatele.

## 9.2 Obsah

* vyhledávací pole,
* doporučené sporty,
* nedávno použité nebo oblíbené kategorie,
* seznam vybraných sportů,
* možnost přidat vlastní sport.

## 9.3 Podpora vlastního sportu

Uživatel zadá:

* vlastní název,
* případně základní kategorii,
* typickou intenzitu,
* obvyklou délku,
* hlavní fyzické nároky.

Tyto detaily lze doplnit později.

## 9.4 Akce

* vybrat sport,
* odebrat sport,
* označit hlavní sport,
* upravit detail sportu,
* pokračovat.

## 9.5 Prázdný stav hledání

> Tento sport jsme nenašli. Můžeš ho přidat pod vlastním názvem.

## 9.6 Přístupnost

Každý sport musí být označen textem, ne pouze ikonou.

---

# 10. Detail sportu v onboardingu

## 10.1 Účel

Získat informace potřebné pro plánování konkrétního sportu.

## 10.2 Pole

* název,
* role: hlavní / vedlejší / příležitostný,
* úroveň,
* frekvence,
* běžná délka,
* intenzita,
* soutěžní charakter,
* sezónnost,
* pravidelné dny,
* uživatelská poznámka.

## 10.3 Pro neznámý sport

Navíc:

* vytrvalostní náročnost,
* silová náročnost,
* rychlostní náročnost,
* mobilita,
* koordinace,
* kontaktnost,
* hlavní zatížené části těla.

## 10.4 Primární akce

`Uložit sport`

---

# 11. Pravidelný rozvrh

## 11.1 Účel

Zadat pevné a opakované aktivity.

## 11.2 Obsah

* týdenní přehled,
* existující pravidelné aktivity,
* tlačítko přidání,
* vysvětlení rozdílu mezi pevnou aktivitou a dostupností.

## 11.3 Přidání pravidelné aktivity

Pole:

* sport,
* název,
* den,
* čas,
* délka,
* opakování,
* datum začátku,
* případný konec,
* pevnost termínu,
* typ: trénink / zápas / lekce / jiný.

## 11.4 Akce

* přidat,
* upravit,
* smazat budoucí opakování,
* změnit jen jednu instanci,
* pokračovat.

## 11.5 Konflikt

Pokud se dvě pevné události překrývají:

* zobrazit konflikt,
* neblokovat uložení, pokud jde o legitimní situaci,
* požádat o vyjasnění před generováním plánu.

---

# 12. Cíle v onboardingu

## 12.1 Účel

Získat hlavní a vedlejší cíle.

## 12.2 Obsah

* předvolené typy cílů,
* možnost vlastního textu,
* seznam přidaných cílů,
* určení priority.

## 12.3 Detail cíle

Pole podle typu:

* název,
* popis,
* důvod,
* priorita,
* termín,
* výchozí stav,
* cílový stav,
* metrika,
* související sport.

## 12.4 Nejasný cíl

Například:

> Chci být v lepší kondici.

Aplikace může nabídnout:

* uložit jako kvalitativní cíl,
* doplnit měřitelné ukazatele,
* nechat AI navrhnout způsob sledování.

## 12.5 Konfliktní cíle

Aplikace zobrazí upozornění a nabídne priorizaci.

---

# 13. Dostupnost

## 13.1 Účel

Zjistit, kdy a jak dlouho může uživatel cvičit.

## 13.2 Obsah

* dny v týdnu,
* části dne,
* časová okna,
* maximální délka,
* preferovaná délka,
* více workoutů za den,
* preferovaný odpočinkový den.

## 13.3 Flexibilita

Uživatel může označit:

* pevně dostupný čas,
* preferovaný čas,
* možný náhradní čas,
* nedostupnost.

## 13.4 Dočasná dostupnost

V onboardingu se řeší běžný režim.

Dočasné změny budou spravovány později v Profilu nebo Kalendáři.

---

# 14. Vybavení

## 14.1 Účel

Zjistit dostupné pomůcky a prostředí.

## 14.2 Kategorie

* bez vybavení,
* domácí vybavení,
* fitko,
* venkovní prostředí,
* sportovní zařízení,
* vlastní položka.

## 14.3 Vybavení může obsahovat

* název,
* množství,
* hmotnost,
* odpor,
* dostupné prostředí,
* trvalou nebo dočasnou dostupnost.

## 14.4 Primární akce

`Uložit a pokračovat`

---

# 15. Omezení

## 15.1 Účel

Získat informace relevantní pro bezpečné plánování.

## 15.2 Kategorie

* žádná známá omezení,
* dlouhodobé omezení,
* dočasné omezení,
* aktuální bolest,
* odborné doporučení,
* pohyb, kterému se chce uživatel vyhnout.

## 15.3 Bezpečnostní text

Musí jasně uvést:

* aplikace nestanovuje diagnózy,
* při akutních potížích je vhodná odborná pomoc,
* uživatel může údaje kdykoliv změnit.

## 15.4 Citlivost

Uživatel nesmí být nucen zadat více zdravotních údajů, než je nutné.

## 15.5 Rizikový vstup

Pokud uživatel během onboardingu uvede akutní problém:

* nechat bezpečně dokončit profil,
* neumožnit vytvořit rizikový plán bez dalšího vyhodnocení,
* zobrazit odpovídající doporučení.

---

# 16. Preference

## 16.1 Účel

Přizpůsobit styl plánu a komunikace.

## 16.2 Pole

* preferovaná délka workoutů,
* ranní / odpolední / večerní preference,
* stručné nebo podrobné vysvětlení,
* začátečnická nebo pokročilá terminologie,
* míra automatizace,
* četnost notifikací,
* jednotky,
* jazyk.

## 16.3 Automatizace

Možnosti:

* pouze doporučení,
* návrhy s potvrzením,
* automatické drobné změny.

Významné změny nelze plně automatizovat v počáteční verzi.

---

# 17. Konverzační onboarding

## 17.1 Účel

Umožnit uživateli popsat sportovní situaci přirozeným jazykem.

## 17.2 Rozložení

* horní vysvětlení,
* chatová historie,
* textové pole,
* strukturovaný panel rozpoznaných údajů,
* indikátor chybějících údajů.

## 17.3 Zpracování zprávy

Po zprávě se zobrazí:

### Rozpoznané údaje

* sporty,
* cíle,
* pravidelný rozvrh,
* vybavení,
* dostupnost,
* omezení.

### Nejasnosti

* pouze otázky nezbytné pro vytvoření bezpečného plánu.

## 17.4 Úprava rozpoznaných údajů

Každou položku lze:

* potvrdit,
* upravit,
* odstranit.

## 17.5 Nedostupná AI

Uživatel může přejít na krokový onboarding bez ztráty rozpoznaných nebo ručně zadaných údajů.

---

# 18. Shrnutí profilu

## 18.1 Účel

Umožnit uživateli zkontrolovat vstupy před vytvořením plánu.

## 18.2 Sekce

* hlavní záměr,
* sporty,
* cíle,
* pravidelné aktivity,
* dostupnost,
* vybavení,
* omezení,
* preference.

## 18.3 Indikátor úplnosti

Rozlišuje:

* dostatečné pro vytvoření plánu,
* doporučené doplnění,
* chybějící povinné údaje.

## 18.4 Primární akce

`Vytvořit plán`

## 18.5 Sekundární akce

* `Upravit`
* `Uložit bez plánu`

---

# 19. Generování plánu

## 19.1 Účel

Informovat uživatele o probíhajícím vytváření návrhu.

## 19.2 Obsah

* indikátor průběhu,
* obecné fáze procesu,
* možnost bezpečně odejít,
* informace, že výsledek bude uložen jako koncept.

## 19.3 Zakázané chování

Aplikace nesmí zobrazovat údajný interní řetězec uvažování AI.

## 19.4 Dlouhé zpracování

Uživatel může přejít jinam.

Po dokončení dostane stavové upozornění nebo notifikaci v aplikaci.

## 19.5 Chyba

Možnosti:

* opakovat,
* upravit profil,
* vytvořit jednodušší návrh deterministicky,
* uložit profil bez plánu.

---

# 20. Náhled prvního plánu

## 20.1 Účel

Umožnit uživateli plán pochopit a upravit před potvrzením.

## 20.2 Hierarchie obsahu

1. název a období,
2. hlavní cíle,
3. stručné vysvětlení,
4. typický týden,
5. kalendářní náhled,
6. workouty,
7. progrese,
8. kompromisy,
9. upozornění,
10. akce.

## 20.3 Zobrazení týdne

Každý den ukazuje:

* pevné aktivity,
* AI workouty,
* mikro-workouty,
* regeneraci,
* volno.

## 20.4 Detail workoutu

Otevření bez opuštění konceptu plánu.

Uživatel může upravit:

* název,
* délku,
* den,
* čas,
* cviky,
* prioritu.

## 20.5 Primární akce

`Potvrdit a přidat do kalendáře`

## 20.6 Sekundární akce

* `Upravit s AI`
* `Upravit ručně`
* `Uložit jako koncept`
* `Zahodit návrh`

## 20.7 Potvrzovací přehled

Před konečným potvrzením:

* období,
* počet workoutů,
* počet událostí,
* aktivní notifikace,
* míra automatizace.

---

# 21. Obrazovka Dnes

## 21.1 Účel

Poskytnout nejrychlejší každodenní přehled a přístup k dnešním aktivitám.

## 21.2 Vstupní body

* hlavní navigace,
* spuštění aplikace,
* ranní notifikace,
* deep link `/app/today`,
* návrat z workoutu.

## 21.3 Hierarchie obsahu

1. datum,
2. stav dne,
3. nejbližší aktivita,
4. denní timeline,
5. rychlé akce,
6. čekající návrhy,
7. regenerace,
8. hlavní cíl.

## 21.4 Stav dne

Příklad:

> Dnes tě čeká ranní mobilita a večerní fotbal.

Musí vycházet ze skutečných strukturovaných dat.

## 21.5 Nejbližší aktivita

Zvýrazněná karta obsahuje:

* čas,
* název,
* typ,
* délku,
* hlavní účel,
* primární akci.

## 21.6 Denní timeline

Řazení podle času.

Aktivity bez konkrétního času se zobrazují jako flexibilní.

## 21.7 Rychlé akce

* Jsem unavený
* Něco mě bolí
* Dnes nestíhám
* Změnil se program
* Přidat aktivitu

## 21.8 Čekající AI návrh

Pokud existuje:

* důvod,
* rozsah,
* počet změn,
* tlačítko `Zkontrolovat`.

## 21.9 Prázdný stav

> Dnes nemáš nic naplánováno.

Akce:

* `Přidat aktivitu`
* `Naplánovat s AI`

## 21.10 Offline stav

Zobrazit poslední synchronizovaný plán.

Lokální změny musí být možné.

## 21.11 Analytické události

* today_viewed,
* today_activity_opened,
* quick_action_selected,
* ai_proposal_opened,
* workout_started_from_today.

---

# 22. Rychlý check-in

## 22.1 Účel

Získat stručné subjektivní informace bez dlouhého formuláře.

## 22.2 Pole

* energie 1–5,
* celková únava 1–5,
* motivace volitelně,
* bolest ano/ne,
* krátká poznámka.

## 22.3 Použití

* ráno,
* před workoutem,
* na vyžádání AI.

## 22.4 Primární akce

`Uložit`

## 22.5 Po uložení

Aplikace může:

* ponechat plán,
* zobrazit doporučení,
* navrhnout úpravu.

Check-in sám nesmí automaticky měnit významné části plánu.

---

# 23. Nahlášení únavy

## 23.1 Účel

Převést obecné sdělení o únavě do strukturovaného vstupu a bezpečného návrhu.

## 23.2 Kroky

1. intenzita,
2. lokalizace nebo celková únava,
3. spánek,
4. dnešní časové možnosti,
5. preference uživatele,
6. návrh.

## 23.3 Návrh změny

Zobrazuje:

* původní workout,
* novou variantu,
* důvod,
* dopad na další dny,
* možnost ponechat původní workout.

## 23.4 Primární akce

`Použít úpravu`

## 23.5 Sekundární akce

* `Nechat původní`
* `Upravit návrh`
* `Probrat s AI`

---

# 24. Nahlášení bolesti

## 24.1 Účel

Zaznamenat bolest a zabránit nevhodnému doporučení.

## 24.2 Rozložení

Může používat vícekrokový fullscreen flow.

## 24.3 Kroky

1. místo na těle,
2. strana,
3. intenzita,
4. charakter,
5. vznik,
6. zhoršující pohyb,
7. bolest v klidu,
8. úraz,
9. délka platnosti.

## 24.4 Bezpečnostní větev

Při rizikovém vstupu:

* výrazné upozornění,
* doporučení přerušit aktivitu,
* vhodné další kroky,
* žádný generický náhradní workout bez bezpečnostního posouzení.

## 24.5 Běžná větev

Zobrazí návrh:

* odstranit cvik,
* změnit rozsah,
* vynechat oblast,
* přesunout workout,
* odpočívat.

## 24.6 Uložení

Uložený záznam musí rozlišovat:

* jednorázovou bolest,
* dočasné omezení,
* dlouhodobé omezení.

---

# 25. Dnes nestíhám

## 25.1 Účel

Rychle přizpůsobit dnešní plán dostupnému času.

## 25.2 Volby

* 5 minut,
* 10 minut,
* 15 minut,
* vlastní čas,
* přesunout,
* vynechat.

## 25.3 Výsledek

Zobrazit:

* původní délku,
* novou délku,
* zachované části,
* odstraněné části,
* dopad na týden.

## 25.4 Primární akce

Podle návrhu:

* `Použít kratší verzi`
* `Přesunout`
* `Vynechat bez náhrady`

---

# 26. Změna programu

## 26.1 Účel

Zpracovat jednorázovou nebo trvalou změnu reálného života.

## 26.2 Vstup

* text,
* hlas v budoucnu,
* formulář,
* výběr typu změny.

## 26.3 Příklady

* lezecký víkend,
* zrušený trénink,
* přesunutý zápas,
* pracovní cesta,
* nové vybavení,
* změna dostupnosti.

## 26.4 Výsledek

Strukturovaný návrh:

* nové události,
* změněné události,
* zrušené workouty,
* přesunuté workouty,
* dopad na regeneraci.

## 26.5 Primární akce

`Zkontrolovat změny`

---

# 27. Týdenní kalendář

## 27.1 Účel

Zobrazit a spravovat hlavní plánovací jednotku.

## 27.2 Vstupní body

* hlavní navigace,
* Dnes,
* AI návrh,
* detail plánu,
* deep link na týden.

## 27.3 Obsah

* přepínač období,
* dny týdne,
* časové bloky,
* aktivity,
* konflikty,
* souhrn zátěže,
* tlačítko přidání.

## 27.4 Aktivita v kalendáři

Musí zobrazit minimálně:

* čas nebo flexibilní stav,
* název,
* typ,
* stav.

## 27.5 Akce

* otevřít detail,
* přetáhnout,
* dlouhým stiskem otevřít rychlé akce,
* přidat událost,
* reorganizovat s AI.

## 27.6 Pevná versus flexibilní aktivita

Musí být jasně odlišena ikonou nebo textem, ne pouze barvou.

## 27.7 Konflikt

Překryv se zobrazí jako upozornění.

Uživatel může:

* ponechat,
* přesunout,
* požádat AI o řešení.

## 27.8 Offline

Drag-and-drop změna se uloží lokálně a čeká na synchronizaci.

---

# 28. Denní kalendář

## 28.1 Účel

Zobrazit podrobnou časovou osu jednoho dne.

## 28.2 Obsah

* datum,
* souhrn dne,
* chronologické aktivity,
* flexibilní aktivity,
* odpočinek,
* čekající návrhy,
* poznámky.

## 28.3 Akce

* spustit workout,
* otevřít aktivitu,
* přesunout,
* přidat,
* upravit den s AI.

---

# 29. Měsíční kalendář

## 29.1 Účel

Poskytnout dlouhodobou orientaci.

## 29.2 Obsah

* měsíční mřížka,
* indikátory aktivit,
* závody,
* zápasy,
* sportovní výjezdy,
* cílové termíny,
* tréninkové bloky.

## 29.3 Kliknutí na den

Otevře denní přehled.

## 29.4 Omezení

Nemá zobrazovat detail jednotlivých cviků nebo sérií.

---

# 30. Detail dne

## 30.1 Účel

Zobrazit souhrn všech plánovaných a skutečných událostí daného dne.

## 30.2 Obsah

* datum,
* stav dne,
* plánované aktivity,
* dokončené aktivity,
* změny,
* subjektivní check-in,
* souhrnná zátěž,
* poznámky.

## 30.3 Akce

* upravit den,
* přidat aktivitu,
* reorganizovat s AI,
* zobrazit historii změn.

---

# 31. Přidání aktivity

## 31.1 Účel

Ručně vytvořit libovolnou sportovní nebo plánovací událost.

## 31.2 První krok

Výběr typu:

* workout,
* sportovní trénink,
* zápas,
* závod,
* mobilita,
* regenerace,
* odpočinek,
* vlastní aktivita.

## 31.3 Základní pole

* název,
* datum,
* čas,
* délka,
* sport,
* pevnost termínu.

## 31.4 Volitelná pole

* intenzita,
* priorita,
* opakování,
* cíl,
* vybavení,
* zatížené oblasti,
* poznámka.

## 31.5 Vlastní aktivita

Musí umožnit libovolný název.

## 31.6 Primární akce

`Přidat do kalendáře`

---

# 32. Detail plánu

## 32.1 Účel

Zobrazit dlouhodobý tréninkový rámec.

## 32.2 Obsah

* název,
* stav,
* období,
* hlavní a vedlejší cíle,
* aktuální blok,
* typický týden,
* progrese,
* verze,
* datum poslední změny,
* míra automatizace.

## 32.3 Akce

* upravit,
* pozastavit,
* ukončit,
* vytvořit novou verzi,
* vysvětlit s AI,
* zobrazit historii.

## 32.4 Ukončení plánu

Vyžaduje potvrzení.

Historie zůstává zachovaná.

---

# 33. Historie změn plánu

## 33.1 Účel

Umožnit dohledat, jak a proč se plán měnil.

## 33.2 Každý záznam obsahuje

* datum a čas,
* zdroj změny,
* důvod,
* rozsah,
* počet ovlivněných objektů,
* stav,
* možnost detailu.

## 33.3 Filtry

* ruční změny,
* AI návrhy,
* automatické změny,
* vrácené změny.

## 33.4 Akce

* zobrazit detail,
* porovnat verze,
* vrátit změnu.

---

# 34. Detail workoutu

## 34.1 Účel

Zobrazit plánovaný workout a všechny související informace.

## 34.2 Vstupní body

* Dnes,
* Kalendář,
* notifikace,
* AI návrh,
* historie,
* deep link.

## 34.3 Obsah

* název,
* datum a čas,
* stav,
* účel,
* očekávaná délka,
* části workoutu,
* cviky,
* vybavení,
* vazba na cíle,
* omezení,
* historie změn.

## 34.4 Primární akce

Podle stavu:

* `Spustit workout`
* `Pokračovat`
* `Zobrazit souhrn`

## 34.5 Sekundární akce

* upravit,
* přesunout,
* zkrátit,
* nahradit,
* zrušit,
* probrat s AI.

## 34.6 Rozsah úpravy

Při změně se musí rozlišit:

* pouze dnešní instance,
* všechny budoucí instance,
* šablona.

---

# 35. Předtréninková obrazovka

## 35.1 Účel

Připravit uživatele na zahájení workoutu.

## 35.2 Obsah

* účel,
* délka,
* potřebné vybavení,
* hlavní části,
* warm-up,
* aktuální omezení,
* další dnešní aktivity.

## 35.3 Volitelný check-in

* energie,
* bolest,
* čas,
* vybavení.

## 35.4 Primární akce

`Spustit workout`

## 35.5 Sekundární akce

* `Zkrátit`
* `Upravit`
* `Odložit`

---

# 36. Aktivní workout

## 36.1 Účel

Umožnit rychlé a spolehlivé zaznamenávání workoutu.

## 36.2 Režim

Fullscreen s omezeným rušením.

## 36.3 Horní část

* název,
* celkový čas,
* průběh,
* pozastavení,
* ukončení.

## 36.4 Obsah aktuálního cviku

* název,
* instrukce,
* plán,
* skutečné hodnoty,
* předchozí výkon,
* poznámka,
* případná ilustrace.

## 36.5 Akce série

* dokončit,
* upravit,
* přeskočit,
* přidat,
* označit problém.

## 36.6 Navigace mezi cviky

* další,
* předchozí,
* seznam všech částí.

## 36.7 Pauza

Automatický časovač nesmí blokovat ostatní operace.

## 36.8 Automatické ukládání

Každá změna se ukládá lokálně okamžitě.

## 36.9 Opuštění obrazovky

Workout zůstane aktivní.

Aplikace zobrazí možnost pokračovat.

## 36.10 Přístupnost

* velké prvky,
* minimální nutnost psaní,
* ovládání jednou rukou,
* jasná haptická odezva jako doplněk.

---

# 37. Detail cviku

## 37.1 Účel

Poskytnout instrukce a historii konkrétního cviku.

## 37.2 Obsah

* název,
* účel,
* instrukce,
* hlavní chyby,
* potřebné vybavení,
* varianty,
* předchozí výkony,
* poznámky.

## 37.3 Akce

* nahradit,
* upravit plánované hodnoty,
* označit problém,
* otevřít historii.

---

# 38. Výběr alternativního cviku

## 38.1 Účel

Nahradit cvik bez narušení hlavního účelu workoutu.

## 38.2 Filtry návrhů

* stejné zaměření,
* dostupné vybavení,
* bezpečnost,
* obtížnost,
* bolest nebo omezení,
* únava,
* předchozí zátěž.

## 38.3 Každá alternativa obsahuje

* název,
* důvod vhodnosti,
* rozdíl oproti původnímu cviku,
* potřebné vybavení.

## 38.4 Rozsah změny

* pouze dnes,
* budoucí instance,
* šablona.

## 38.5 Primární akce

`Použít cvik`

---

# 39. Pozastavený workout

## 39.1 Účel

Umožnit pokračování bez ztráty dat.

## 39.2 Obsah

* uplynulý čas,
* stav dokončení,
* poslední cvik,
* datum pozastavení,
* akce.

## 39.3 Akce

* pokračovat,
* dokončit jako částečný,
* ukončit bez dokončení,
* zahodit záznam po potvrzení.

---

# 40. Dokončení workoutu

## 40.1 Účel

Uzavřít workout a získat stručnou zpětnou vazbu.

## 40.2 Obsah

* délka,
* dokončené části,
* rozdíl proti plánu,
* objem,
* osobní rekordy,
* vynechané cviky.

## 40.3 Hodnocení

* náročnost,
* energie po workoutu,
* bolest,
* poznámka.

## 40.4 Primární akce

`Dokončit a uložit`

## 40.5 Offline

Uloží se lokálně se stavem čekající synchronizace.

---

# 41. Souhrn workoutu

## 41.1 Účel

Zobrazit skutečný výsledek dokončeného workoutu.

## 41.2 Obsah

* plán versus skutečnost,
* jednotlivé cviky,
* výkony,
* subjektivní hodnocení,
* poznámky,
* vazba na cíl,
* zdroj dat,
* synchronizační stav.

## 41.3 Akce

* upravit záznam,
* sdílení až v budoucnu,
* probrat s AI,
* zobrazit progres.

---

# 42. Hlavní obrazovka AI trenéra

## 42.1 Účel

Umožnit přirozenou komunikaci a správu AI návrhů.

## 42.2 Obsah

* kontextový nadpis,
* poslední konverzace,
* rychlé návrhy,
* čekající akční karty,
* textové pole,
* připojený kontext.

## 42.3 Rychlé návrhy

Podle situace:

* upravit dnešní workout,
* vysvětlit týden,
* změnit program,
* přidat cíl,
* vyhodnotit pokrok,
* řešit únavu.

## 42.4 Odpovědi

Mohou obsahovat:

* text,
* otázku,
* kartu workoutu,
* kartu cíle,
* návrh změn,
* kalendářní náhled.

## 42.5 Zakázané chování

Text AI nesmí působit, že změna byla provedena, pokud zatím nebyla potvrzena a zapsána.

---

# 43. Kontextová AI konverzace

## 43.1 Účel

Řešit konkrétní objekt bez ztráty souvislosti.

## 43.2 Kontexty

* workout,
* den,
* týden,
* plán,
* cíl,
* aktivita,
* AI návrh.

## 43.3 Indikátor kontextu

Zobrazuje:

* typ,
* název,
* datum,
* možnost otevření,
* možnost odebrání.

## 43.4 Příklad

> Řešíme: Upper Body A, úterý 18:00

---

# 44. Detail AI návrhu

## 44.1 Účel

Umožnit bezpečně posoudit navržené změny.

## 44.2 Obsah

* název,
* důvod,
* zdroje relevantních dat,
* rozsah,
* seznam změn,
* dopad,
* kompromisy,
* stav vratnosti.

## 44.3 Akce

* potvrdit vše,
* potvrdit část,
* upravit,
* odmítnout,
* probrat s AI.

## 44.4 Zastaralý návrh

Pokud se plán mezitím změnil:

> Tento návrh vychází ze starší verze plánu.

Akce:

* přepočítat,
* zobrazit původní návrh,
* zahodit.

---

# 45. Porovnání změn

## 45.1 Účel

Zobrazit původní a nový stav srozumitelně.

## 45.2 Formy

* tabulka dnů,
* porovnání workoutu,
* seznam přidaných a odebraných položek,
* časová osa.

## 45.3 Povinné rozlišení

* přidáno,
* odstraněno,
* přesunuto,
* zkráceno,
* nahrazeno,
* nezměněno.

## 45.4 Částečné potvrzení

Uživatel může vybrat jednotlivé změny.

Systém musí následně znovu zkontrolovat konflikty.

---

# 46. Historie AI akcí

## 46.1 Účel

Oddělit skutečné AI akce od běžného chatu.

## 46.2 Záznam obsahuje

* datum,
* typ akce,
* objekt,
* stav,
* důvod,
* uživatelské rozhodnutí,
* možnost detailu.

## 46.3 Filtry

* potvrzené,
* odmítnuté,
* automatické,
* vrácené,
* chybné.

---

# 47. Přehled pokroku

## 47.1 Účel

Ukázat nejdůležitější informace o dlouhodobém vývoji.

## 47.2 Hierarchie

1. hlavní cíl,
2. důležitý trend,
3. pravidelnost,
4. poslední týden,
5. vybrané metriky,
6. nejbližší milník.

## 47.3 Prázdný stav

> Pokrok se zobrazí po dokončení prvních aktivit.

## 47.4 Omezení

Nemá zobrazovat všechny dostupné metriky najednou.

---

# 48. Přehled cílů

## 48.1 Obsah

Kategorie:

* hlavní,
* aktivní vedlejší,
* budoucí,
* pozastavené,
* dokončené.

## 48.2 Karta cíle

* název,
* stav,
* priorita,
* termín,
* stručný trend,
* poslední aktualizace.

## 48.3 Akce

* otevřít,
* přidat cíl,
* změnit priority,
* probrat s AI.

---

# 49. Detail cíle

## 49.1 Obsah

* název,
* důvod,
* priorita,
* výchozí stav,
* aktuální stav,
* cílový stav,
* termín,
* metriky,
* milníky,
* navázané workouty,
* historie.

## 49.2 Akce

* upravit,
* pozastavit,
* dokončit,
* ukončit,
* změnit prioritu,
* vysvětlit s AI.

---

# 50. Týdenní shrnutí

## 50.1 Účel

Vyhodnotit týden a připravit další.

## 50.2 Obsah

* plánované versus dokončené,
* nahrazené aktivity,
* důležité změny,
* subjektivní stav,
* trend,
* AI komentář,
* návrh dalšího týdne.

## 50.3 Jazyk

Nesmí trestat uživatele za vynechání.

Musí zohlednit skutečné náhradní aktivity a změny.

## 50.4 Akce

* potvrdit další týden,
* upravit,
* změnit priority,
* probrat s AI.

---

# 51. Historie aktivit

## 51.1 Účel

Zobrazit skutečně provedené aktivity.

## 51.2 Filtry

* období,
* sport,
* typ,
* cíl,
* zdroj,
* stav synchronizace.

## 51.3 Každá položka

* datum,
* název,
* typ,
* délka,
* hlavní výsledek,
* zdroj.

## 51.4 Prázdný stav

> Zatím nemáš žádné dokončené aktivity.

---

# 52. Přehled profilu

## 52.1 Účel

Ukázat, z jakých dlouhodobých informací aplikace vychází.

## 52.2 Sekce

* osobní údaje,
* sporty,
* cíle,
* pravidelný rozvrh,
* dostupnost,
* vybavení,
* omezení,
* AI preference,
* integrace.

## 52.3 Stav úplnosti

Užitečné upozornění:

> Doplň časové možnosti, aby byly návrhy plánu přesnější.

---

# 53. Sporty v Profilu

## 53.1 Obsah

Seznam sportů s:

* názvem,
* rolí,
* úrovní,
* frekvencí,
* sezonním stavem.

## 53.2 Akce

* přidat,
* upravit,
* pozastavit,
* označit jako hlavní,
* archivovat.

Sport s historií se nemá běžně mazat.

---

# 54. Detail sportu

## 54.1 Obsah

* název,
* kategorie,
* úroveň,
* role,
* typická zátěž,
* sezona,
* pravidelné aktivity,
* cíle,
* poznámky.

## 54.2 Akce

* upravit,
* pozastavit sezonu,
* změnit prioritu,
* zobrazit historii.

---

# 55. Dostupnost v Profilu

## 55.1 Účel

Spravovat běžný režim a dočasné výjimky.

## 55.2 Záložky

* Běžný týden
* Dočasné změny

## 55.3 Akce

* upravit časová okna,
* přidat pracovní cestu,
* přidat období bez vybavení,
* nastavit dočasnou nedostupnost.

---

# 56. Vybavení v Profilu

## 56.1 Obsah

Členění podle prostředí.

Každá položka:

* název,
* parametry,
* místo,
* dostupnost,
* platnost.

## 56.2 Akce

* přidat,
* upravit,
* dočasně deaktivovat,
* odebrat.

Odebrání vybavení může vyvolat návrh úpravy budoucích workoutů.

---

# 57. Omezení v Profilu

## 57.1 Obsah

Oddělené sekce:

* dlouhodobá omezení,
* dočasná omezení,
* aktuální bolest,
* odborná doporučení,
* pohybové preference.

## 57.2 Každá položka

* typ,
* oblast,
* začátek,
* případný konec,
* zdroj,
* poznámka,
* stav.

## 57.3 Akce

* přidat,
* upravit,
* ukončit platnost,
* zobrazit ovlivněné workouty.

---

# 58. Preference AI

## 58.1 Obsah

* míra automatizace,
* délka odpovědí,
* úroveň vysvětlení,
* terminologie,
* četnost revizí,
* povolené drobné automatické akce.

## 58.2 Automatické akce

Každý typ musí být samostatně povolitelný.

Například:

* přesun flexibilního workoutu,
* změna připomenutí,
* zkrácení doplňkové jednotky.

## 58.3 Nepovolené automatické akce

V počáteční verzi zejména:

* změna hlavního cíle,
* zrušení celého plánu,
* velké navýšení zátěže,
* trvalá změna omezení.

---

# 59. Nastavení notifikací

## 59.1 Kategorie

* ranní přehled,
* workout připomenutí,
* AI návrhy,
* týdenní revize,
* neaktivita,
* synchronizační problémy.

## 59.2 Nastavení

* zapnuto/vypnuto,
* čas,
* předstih,
* tiché dny,
* citlivost textu na zamčené obrazovce.

---

# 60. Integrace

## 60.1 Účel

Spravovat externí zdroje a cíle dat.

## 60.2 Karta integrace

* název,
* stav,
* poslední synchronizace,
* čtené datové typy,
* zapisované datové typy,
* chyba.

## 60.3 Akce

* připojit,
* změnit oprávnění,
* synchronizovat,
* odpojit,
* zobrazit importovaná data.

## 60.4 Odpojení

Musí vysvětlit:

* zda data zůstanou v aplikaci,
* zda se přestanou aktualizovat,
* zda se smažou tokeny.

---

# 61. Soukromí

## 61.1 Obsah

* ukládaná data,
* AI zpracování,
* integrace,
* analytika,
* export,
* odstranění dat,
* správa souhlasů.

## 61.2 Princip

Informace musí být konkrétní a srozumitelné.

---

# 62. Export dat

## 62.1 Účel

Umožnit uživateli získat vlastní data.

## 62.2 Volby

* rozsah,
* formát,
* období,
* zahrnutí AI historie,
* zahrnutí citlivých údajů.

## 62.3 Průběh

* vytvoření požadavku,
* stav,
* bezpečné stažení nebo doručení,
* expirace odkazu.

---

# 63. Účet

## 63.1 Obsah

* e-mail,
* přihlašovací metody,
* aktivní relace,
* změna hesla,
* odhlášení,
* smazání účtu.

## 63.2 Bezpečnost

Citlivé akce mohou vyžadovat nové ověření identity.

---

# 64. Smazání účtu

## 64.1 Účel

Umožnit bezpečné a srozumitelné odstranění účtu.

## 64.2 Kroky

1. vysvětlení,
2. nabídka exportu,
3. výčet důsledků,
4. ověření identity,
5. potvrzení,
6. stav procesu.

## 64.3 Primární akce

Musí být jasně destruktivní, ale ne manipulativní.

## 64.4 Historie a zálohy

Aplikace musí uvést, co se děje s:

* aktivními daty,
* lokálními daty,
* integračními tokeny,
* zálohami,
* právně povinnými záznamy.

---

# 65. Globální offline obrazovka

## 65.1 Účel

Vysvětlit rozsah dostupných funkcí při delším offline stavu.

## 65.2 Obsah

* stav připojení,
* čas poslední synchronizace,
* čekající změny,
* dostupné funkce,
* nedostupné funkce.

## 65.3 Akce

* opakovat synchronizaci,
* zobrazit čekající změny,
* pokračovat offline.

---

# 66. Konflikt synchronizace

## 66.1 Účel

Vyřešit skutečný konflikt bez technického žargonu.

## 66.2 Obsah

* objekt,
* lokální hodnota,
* serverová hodnota,
* čas změny,
* zdroj,
* doporučená volba.

## 66.3 Akce

* použít lokální,
* použít serverovou,
* upravit ručně.

## 66.4 Bezpečnost

Workout výsledky se nesmí automaticky zahodit.

---

# 67. AI je nedostupná

## 67.1 Účel

Jasně oddělit výpadek AI od výpadku celé aplikace.

## 67.2 Text

> AI trenér je dočasně nedostupný. Kalendář, workouty a uložená data dál fungují.

## 67.3 Akce

* pokračovat bez AI,
* zkusit znovu,
* ručně upravit plán.

---

# 68. Objekt nenalezen

## 68.1 Příklady

* smazaný workout,
* neplatný deep link,
* cizí objekt,
* zastaralá notifikace.

## 68.2 Obsah

* srozumitelná zpráva,
* bezpečný návrat,
* možnost obnovit.

Nesmí odhalovat existenci cizích uživatelských dat.

---

# 69. Analytické požadavky

Každá obrazovka musí definovat pouze nezbytné analytické události.

## 69.1 Základní struktura události

* název obrazovky,
* typ akce,
* anonymní technický identifikátor relace,
* technický stav,
* verze aplikace.

## 69.2 Zakázané údaje v běžné analytice

* text AI chatu,
* popis bolesti,
* zdravotní omezení,
* přesný obsah cíle,
* e-mail,
* celé jméno,
* GPS trasa,
* detail spánku.

---

# 70. Přístupnost obrazovek

Každá obrazovka musí splnit:

* textové popisky ovládacích prvků,
* podporu zvětšeného textu,
* logické pořadí pro čtečku,
* nespoléhání pouze na barvu,
* dostatečnou velikost dotykových ploch,
* srozumitelná chybová hlášení,
* podporu snížených animací,
* zachování funkčnosti při orientaci zařízení podle podporovaného režimu.

Aktivní workout musí být prioritně testován pro:

* ovládání jednou rukou,
* rychlé zadávání,
* venkovní použití,
* slabé osvětlení,
* zpocené ruce.

---

# 71. Adaptivní obsah podle typu workoutu

## 71.1 Silový workout

Zobrazuje:

* série,
* opakování,
* váhu,
* tempo,
* pauzu,
* RPE nebo rezervu opakování.

## 71.2 Mobilita

Zobrazuje:

* čas,
* stranu těla,
* rozsah,
* kontrolu pohybu,
* dechové instrukce.

## 71.3 Běh

Zobrazuje:

* čas,
* vzdálenost,
* tempo,
* zóny,
* intervaly.

## 71.4 Týmový sport

Zobrazuje:

* čas,
* délku,
* intenzitu,
* zápasový nebo tréninkový charakter,
* subjektivní zátěž.

## 71.5 Obecná aktivita

Zobrazuje:

* název,
* délku,
* intenzitu,
* poznámku,
* zatížené oblasti.

## 71.6 Vlastní sport

Rozhraní vychází z obecných vlastností aktivity.

Nesmí odmítnout zobrazení jen proto, že neexistuje specializovaná komponenta.

---

# 72. Priorita implementace

## Stage 1 – Lokální prototyp

Implementovat:

* Splash,
* základní aplikační shell,
* Dnes,
* týdenní Kalendář,
* detail workoutu,
* předtréninkovou obrazovku,
* aktivní workout,
* dokončení workoutu,
* souhrn workoutu,
* lokální historii,
* demo Profil.

## Stage 2 – Účet a synchronizace

Implementovat:

* Úvodní obrazovku,
* Registraci,
* Přihlášení,
* obnovu relace,
* offline a synchronizační stavy,
* konflikt synchronizace.

## Stage 3 – Onboarding a profil

Implementovat:

* úvod onboardingu,
* sporty,
* detail sportu,
* rozvrh,
* cíle,
* dostupnost,
* vybavení,
* omezení,
* preference,
* shrnutí profilu.

## Stage 4 – Plánování

Implementovat:

* generování návrhu,
* náhled plánu,
* detail plánu,
* přidání aktivity,
* editaci kalendáře,
* historii změn.

## Stage 5–6 – AI a adaptace

Implementovat:

* AI trenéra,
* kontextovou konverzaci,
* návrhy,
* porovnání změn,
* únavu,
* bolest,
* nedostatek času,
* změnu programu,
* vrácení změny.

## Stage 7–8

Implementovat:

* notifikace,
* Pokrok,
* cíle,
* týdenní shrnutí,
* historii aktivit.

## Pozdější etapy

Implementovat:

* integrace,
* wearable data,
* pokročilou analytiku,
* GPS obrazovky.

---

# 73. Kritéria připravenosti obrazovky k vývoji

Obrazovka je připravena k implementaci, pokud má definováno:

1. účel,
2. vstupní body,
3. oprávnění,
4. doménové objekty,
5. hierarchii obsahu,
6. primární akci,
7. sekundární akce,
8. navigaci,
9. načítání,
10. prázdný stav,
11. chybový stav,
12. offline stav,
13. synchronizační stav,
14. analytické události,
15. přístupnost,
16. testovací scénáře,
17. chování pro obecný sport,
18. chování při nedostupné AI,
19. deep link, pokud je relevantní,
20. vztah k ostatním obrazovkám.

---

# 74. Závěr

Obrazovky AI Traineru musí tvořit jeden propojený systém.

Uživatel nesmí mít pocit, že používá:

* samostatný tracker,
* samostatný kalendář,
* samostatný profil,
* samostatné statistiky,
* samostatný chatbot.

Každá obrazovka musí pracovat se stejnými objekty a stejným zdrojem pravdy.

Dnešní workout může být:

* vytvořen plánem,
* zobrazen v kalendáři,
* otevřen z notifikace,
* upraven přes AI,
* proveden v trackeru,
* uložen jako aktivita,
* vyhodnocen v Pokroku.

Právě tato návaznost je hlavním požadavkem celé informační architektury a budoucí implementace.
