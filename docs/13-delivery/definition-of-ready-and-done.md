# AI Trainer – Definition of Ready and Done

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/definition-of-ready-and-done.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/07-backend/r0-api-contract.md`, `docs/12-data/r1-physical-data-model.md`, `docs/13-delivery/repository-strategy.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** vertical-slice implementation plan, coding-agent instructions, pull-request template, issue templates, CI workflows a release evidence  
**Vlastněné pojmy nebo kontrakty:** Definition of Ready, Definition of Done, backlog-item readiness, pull-request completion, slice completion, evidence requirements, exception policy a pravidla `DRD-001` až `DRD-015`

---

# 1. Účel

Tento dokument určuje praktické podmínky, za kterých:

- lze backlog item převzít do implementace,
- lze otevřít a dokončit pull request,
- lze označit R0 nebo R1 slice za dokončený,
- lze tvrdit, že změna odpovídá dokumentaci a má dostatečné důkazy.

Definition of Ready a Definition of Done nejsou náhradou za:

- produktové acceptance criteria,
- konkrétní test cases,
- architektonické kontrakty,
- bezpečnostní pravidla,
- release-scope exit criteria.

Jejich úkolem je propojit tyto zdroje pravdy do opakovatelného delivery procesu.

---

# 2. Úrovně posouzení

Projekt rozlišuje čtyři úrovně:

1. **Backlog Item Ready** – položka může vstoupit do implementace.
2. **Pull Request Done** – konkrétní změna je připravená ke sloučení.
3. **Feature or Vertical Slice Done** – spustitelný uživatelský tok je dokončený.
4. **Release Slice Done** – R0 nebo R1 splnil své release exit criteria.

Splnění nižší úrovně automaticky neznamená splnění vyšší úrovně.

---

# 3. Obecné principy

## 3.1 Evidence místo tvrzení

Stav `Done` musí být doložitelný například:

- automatizovanými testy,
- CI výsledkem,
- contract nebo migration testem,
- reprodukovatelným manuálním ověřením,
- aktualizovanou dokumentací,
- explicitním odborným review tam, kde je vyžadováno.

Samotné tvrzení autora změny není dostatečný důkaz.

## 3.2 Nejmenší smysluplný scope

Backlog item má být dostatečně malý, aby:

- měl jeden hlavní účel,
- šel reviewovat bez rozsáhlého kontextového přepínání,
- měl jasné acceptance criteria,
- měl omezený počet vlastnících dokumentů,
- šel dokončit bez skrytého zavádění odložených funkcí.

## 3.3 Žádné skryté rozhodnutí

Položka není Ready, pokud vyžaduje dosud nepřijaté rozhodnutí o:

- technologii,
- doménovém významu,
- API nebo datovém kontraktu,
- bezpečnostním modelu,
- ownershipu,
- release scope.

Takové rozhodnutí musí být nejprve doplněno do správného zdroje pravdy nebo ADR.

## 3.4 Kritické riziko nelze odložit bez rozhodnutí

Známá chyba nebo riziko může zůstat otevřené pouze pokud:

- je explicitně evidované,
- má vlastníka,
- má dopad a prioritu,
- neporušuje kritický invariant ani bezpečnostní pravidlo,
- neohrožuje exit criteria daného slice.

---

# 4. Definition of Ready pro backlog item

Backlog item je **Ready**, pouze pokud splňuje všechny relevantní podmínky níže.

## 4.1 Identita a účel

Položka má:

- jednoznačný název,
- popis očekávaného výsledku,
- určený release slice (`R0`, `R1` nebo pozdější),
- určenou vlastnící oblast nebo feature,
- uvedený důvod, proč je práce potřebná nyní.

## 4.2 Scope

Je výslovně uvedeno:

- co je součástí položky,
- co součástí není,
- zda se mění mobile, backend, contracts, database, tooling nebo dokumentace,
- zda změna vyžaduje migraci,
- zda změna ovlivní veřejný kontrakt nebo uložená data.

## 4.3 Zdroj pravdy

Položka odkazuje na relevantní:

- release scope,
- FR a NFR,
- doménové invariance,
- vlastnící doménový model,
- UX flow nebo screen specification,
- ADR,
- architekturu,
- API nebo datový kontrakt,
- test strategy.

Odkazy nemusí být dlouhý seznam. Musí však pokrýt pravidla, která implementace skutečně používá.

## 4.4 Acceptance criteria

Položka má pozorovatelná a ověřitelná acceptance criteria.

Každé kritérium musí být možné ověřit:

- automatizovaným testem,
- contract nebo migration testem,
- nebo přesně popsaným manuálním postupem, pokud automatizace není přiměřená.

Nevhodné kritérium:

> Implementovat správně workout.

Vhodnější kritérium:

> Po restartu aplikace lze pokračovat v aktivní WorkoutSession bez ztráty potvrzených set performances.

## 4.5 Závislosti

Jsou známé:

- technické prerequisites,
- datové nebo contract dependencies,
- blokující dokumenty,
- pořadí vůči ostatním backlog items,
- případná nutnost platformního zařízení nebo externí služby.

Nejasná kritická závislost znamená, že položka není Ready.

## 4.6 Test approach

Položka určuje minimálně:

- které testovací úrovně jsou relevantní,
- který critical path může ovlivnit,
- zda vyžaduje migration, recovery, contract nebo architecture test,
- jaký důkaz bude požadován v pull requestu.

Konkrétní test cases mohou být doplněny během implementace, ale základní ověřovací strategie musí být známá předem.

## 4.7 Bezpečnost, privacy a data

Pokud se položka dotýká citlivých dat, autentizace, autorizace, logování nebo externího vstupu, musí být známé:

- datová klasifikace,
- ownership a authorization boundary,
- bezpečné logování,
- validační hranice,
- retention nebo deletion dopad,
- případná potřeba security review.

## 4.8 Design a UX

UI položka je Ready, pokud je jasné:

- které screen nebo flow mění,
- jaké má loading, empty, error a recovery stavy,
- jaké má accessibility požadavky,
- jak se chová offline,
- co se stane po restartu aplikace, pokud ukládá průběžný stav.

## 4.9 Odhadnutelnost

Položka nemusí mít přesný časový odhad, ale tým nebo coding agent musí být schopný popsat:

- hlavní implementační části,
- největší rizika,
- očekávané změněné oblasti,
- důvod, proč položka není příliš velká.

Pokud to nelze, položka má být rozdělena nebo doplněna.

---

# 5. Backlog Item Ready checklist

Před zahájením implementace musí být odpověď `ano` na všechny relevantní body:

- [ ] Je určen release slice a vlastník?
- [ ] Je jasný očekávaný uživatelský nebo technický výsledek?
- [ ] Je scope dostatečně malý a jsou popsány non-goals?
- [ ] Jsou načtené a uvedené relevantní zdroje pravdy?
- [ ] Nechybí ADR, API, datové nebo doménové rozhodnutí?
- [ ] Jsou acceptance criteria pozorovatelná a testovatelná?
- [ ] Jsou známé blokující závislosti?
- [ ] Je známý test approach a požadované evidence?
- [ ] Jsou pokryta data, security, offline a recovery rizika?
- [ ] Lze položku implementovat bez zavedení odloženého scope?

Pokud je některá relevantní odpověď `ne`, položka není Ready.

---

# 6. Definition of Done pro pull request

Pull request je **Done**, pouze pokud splňuje všechny relevantní podmínky.

## 6.1 Scope a čitelnost

- změna odpovídá deklarovanému účelu,
- neobsahuje nesouvisející refaktoring bez vysvětlení,
- nepřidává paralelní architektonickou nebo repository strukturu,
- commit nebo PR popis vysvětluje význam změny,
- review lze provést z dostupného kontextu.

## 6.2 Implementační správnost

- implementace odpovídá acceptance criteria,
- neobchází doménové invariance,
- respektuje dependency direction,
- transportní DTO nejsou doménové entity,
- persistence model není zdrojem doménového významu,
- framework nebo provider SDK neproniká do zakázaných vrstev.

## 6.3 Testy

- relevantní nové testy jsou přidány,
- existující relevantní testy jsou aktualizovány,
- všechny povinné CI gates jsou zelené,
- nebyl ignorován failing test bez schválené quarantine policy,
- změna schema má migration test,
- změna kontraktu má contract test,
- změna critical path má odpovídající integration nebo end-to-end důkaz.

## 6.4 Data a migrace

Pokud se mění uložená data:

- migrace je verzovaná a reprodukovatelná,
- existující data nejsou tiše ztracena,
- rollback nebo forward-recovery chování je známé,
- lokální a serverové schema lifecycle nejsou smíchány,
- testy používají skutečný relevantní engine.

## 6.5 API a contracts

Pokud se mění veřejný kontrakt:

- source-of-truth schema je změněno jako první nebo ve stejné změně,
- implementace kontraktu odpovídá,
- compatibility dopad je vyhodnocen,
- generated output je reprodukovatelný,
- breaking změna má odpovídající verzi nebo explicitní rozhodnutí.

## 6.6 Security a privacy

- nejsou commitnuté secrets,
- logy neobsahují citlivá data bez oprávněného důvodu,
- klientská data nejsou považována za autorizaci,
- vstupy jsou validované na správné hranici,
- chyby neodhalují interní stack traces, SQL nebo credentials,
- dependency nebo configuration změna prošla odpovídajícím review.

## 6.7 Dokumentace

Dokumentace je aktualizovaná, pokud změna:

- mění kontrakt,
- zavádí nový pojem,
- mění release scope,
- mění ADR nebo technologické rozhodnutí,
- mění repository strukturu,
- mění testovací či provozní očekávání,
- činí existující dokument nepravdivým.

Komentář v kódu není náhradou za změnu vlastnického dokumentu.

## 6.8 Provozní a vývojářská použitelnost

- změnu lze spustit zdokumentovaným příkazem,
- lokální a CI cesta používají kompatibilní build kroky,
- chyba konfigurace selže srozumitelně,
- nové environment proměnné mají bezpečný příklad a popis,
- build artefakty a lokální data nejsou commitnuté.

## 6.9 Review

- alespoň jeden odpovídající review proces proběhl podle citlivosti změny,
- připomínky jsou vyřešené nebo explicitně evidované,
- odborné review je provedeno, pokud jej zdroj pravdy vyžaduje,
- autor netvrdí `Done`, pokud chybí známý povinný důkaz.

---

# 7. Pull Request Done checklist

- [ ] Scope odpovídá backlog itemu a non-goals.
- [ ] Acceptance criteria jsou splněna.
- [ ] Architektura, invariance a contracts jsou dodrženy.
- [ ] Relevantní testy existují a povinné CI gates prošly.
- [ ] Contract, migration, recovery a critical-path testy jsou doplněny podle dopadu.
- [ ] Nejsou přítomné secrets ani citlivé údaje v logu nebo fixtures.
- [ ] Dokumentace a generated sources jsou aktuální.
- [ ] Změna je reprodukovatelně spustitelná.
- [ ] Review připomínky jsou vyřešené.
- [ ] Zbývající známá rizika jsou explicitně evidována a neblokují slice.

---

# 8. Definition of Done pro feature nebo vertical slice

Feature nebo vertical slice je Done, pokud:

- poskytuje skutečně spustitelné end-to-end chování,
- jednotlivé vrstvy nejsou hotové pouze izolovaně,
- hlavní happy path funguje,
- relevantní error, empty, offline a recovery stavy fungují,
- data zůstávají konzistentní po restartu a opakované operaci,
- relevantní contract a migration testy jsou zelené,
- existuje omezený end-to-end nebo integrační critical-path důkaz,
- dokumentace a backlog stav odpovídají skutečnosti,
- nejsou otevřené blocker nebo critical vady.

Feature není Done pouze proto, že:

- UI je nakreslené bez persistence,
- databáze existuje bez použitelného flow,
- endpoint vrací odpověď bez contract testu,
- happy path funguje pouze v debuggeru,
- autor provedl jednorázový manuální test bez reprodukovatelného důkazu.

---

# 9. R0 Definition of Done

`R0 – Technical Foundation` je Done pouze pokud platí všechna release-scope exit criteria a minimálně:

## 9.1 Repository a build

- monorepo struktura odpovídá repository strategy,
- mobilní aplikace se spustí na podporovaném Android prostředí,
- iOS build je ověřen na dostupném podporovaném macOS prostředí,
- backend se sestaví a spustí,
- lokální infrastruktura se spustí přes `compose.yaml`,
- vývojové příkazy jsou zdokumentované a opakovatelné.

## 9.2 Backend a API

- Flyway vytvoří schema od prázdné PostgreSQL databáze,
- `GET /api/v1/health/live` odpovídá R0 API contract,
- `GET /api/v1/health/ready` rozlišuje ready a not-ready stav,
- error envelope a `X-Request-Id` odpovídají kontraktu,
- OpenAPI je validní a contract tests jsou zelené.

## 9.3 CI a kvalita

- mobile format/analyze/test/build gates jsou aktivní,
- backend format/static/test/build gates jsou aktivní,
- OpenAPI validation a secret scanning jsou aktivní,
- PostgreSQL integration test používá Testcontainers,
- main branch nemá ignorovaný známý failing critical test.

## 9.4 Evidence

R0 evidence obsahuje minimálně:

- úspěšný CI run,
- příkazy pro lokální spuštění,
- výsledek R0 API integration testů,
- důkaz migrace od prázdné databáze,
- známá omezení a deferred decisions.

---

# 10. R1 Definition of Done

`R1 – Local Workout Slice` je Done pouze pokud platí release-scope exit criteria a minimálně:

## 10.1 Uživatelský tok

Uživatel může na jednom zařízení:

1. otevřít Today přehled,
2. otevřít demo workout,
3. zahájit WorkoutSession,
4. zapsat skutečný výkon,
5. přerušit nebo restartovat aplikaci,
6. obnovit aktivní session,
7. dokončit workout,
8. zobrazit dokončený historický záznam.

## 10.2 Persistence a recovery

- workout snapshot je stabilní,
- potvrzené set performances přežijí restart,
- start session je atomický,
- dokončení je atomické a idempotentní,
- ActivitySummary nevznikne v nekonzistentním mezistavu,
- foreign keys a unique constraints jsou aktivní,
- databázová migrace má test od podporované předchozí verze.

## 10.3 UX stavy

- loading, empty a error stav jsou řešeny,
- recovery aktivní session je uživateli zřejmé,
- opakované stisknutí dokončení nevytvoří duplicitní historii,
- aplikace nevyžaduje síť ani backend pro kritický flow,
- accessibility minimum je ověřeno pro hlavní obrazovky.

## 10.4 Test evidence

- unit testy pokrývají klíčové stavové přechody,
- Drift integration testy ověřují transakce a constraints,
- widget testy ověřují hlavní interakce,
- integration/end-to-end test ověřuje start, zápis, restart, recovery a dokončení,
- flaky critical-path test není akceptován jako zelený důkaz.

## 10.5 Scope discipline

R1 nesmí být podmíněn:

- registrací,
- backendovým workout API,
- cloudovým sync,
- generativní AI,
- externím kalendářem,
- wearable integrací.

---

# 11. Výjimky

Výjimka z Ready nebo Done pravidla je přípustná pouze pokud:

- je konkrétní,
- má zdůvodnění,
- má vlastníka,
- má datum nebo podmínku odstranění,
- neporušuje bezpečnost, kritický invariant ani data-integrity pravidlo,
- je viditelná v backlogu nebo PR evidence.

Výjimka nesmí být použita k tomu, aby se opakovaně obcházely chybějící testy, dokumentace nebo review.

---

# 12. Vztah k bugům a technickému dluhu

## 12.1 Blokující vady

Položka nebo slice není Done, pokud existuje známá vada, která:

- způsobuje ztrátu potvrzených dat,
- porušuje doménový invariant,
- obchází autorizaci,
- odhaluje secret nebo citlivé údaje,
- znemožňuje hlavní R0 nebo R1 critical path,
- způsobuje nereprodukovatelný build nebo migraci.

## 12.2 Neblokující dluh

Menší technický dluh může být odložen, pokud:

- chování je správné a doložené,
- dluh má samostatný backlog item,
- nepředstavuje skryté bezpečnostní nebo datové riziko,
- jeho odložení nezpůsobí paralelní architekturu.

---

# 13. Automatizace delivery pravidel

Co lze rozumně automatizovat, má být postupně automatizováno:

- PR checklist,
- required CI checks,
- OpenAPI validation,
- migration testy,
- secret scanning,
- formatting a static analysis,
- generated-code drift,
- architecture boundary checks,
- odkazy na issue nebo acceptance criteria.

Automatizace nepřebírá odpovědnost za doménové, UX nebo odborné review.

---

# 14. Pravidla DRD

## DRD-001

Položka nesmí vstoupit do implementace bez určeného release slice, ownershipu a pozorovatelného výsledku.

## DRD-002

Položka není Ready, pokud vyžaduje chybějící doménové, architektonické, API nebo datové rozhodnutí.

## DRD-003

Acceptance criteria musí být testovatelná nebo mít přesný reprodukovatelný manuální důkaz.

## DRD-004

Každá položka musí znát relevantní testovací úrovně a požadované evidence před zahájením implementace.

## DRD-005

Pull request není Done, pokud relevantní povinné CI gates nejsou zelené.

## DRD-006

Změna veřejného kontraktu není Done bez aktualizace source-of-truth schema a contract testu.

## DRD-007

Změna schématu není Done bez verzované migrace a odpovídajícího migration testu.

## DRD-008

Změna critical path není Done bez integračního nebo end-to-end důkazu odpovídajícího riziku.

## DRD-009

Dokumentace musí být aktualizována ve stejné změně, pokud by jinak existující zdroj pravdy přestal být pravdivý.

## DRD-010

Známý blocker nebo critical defect znemožňuje označení feature nebo release slice jako Done.

## DRD-011

R0 není Done bez reprodukovatelného mobile a backend buildu, validního OpenAPI, migrace od prázdné PostgreSQL a funkčních health endpointů.

## DRD-012

R1 není Done bez offline startu, průběžného zápisu, restart recovery a idempotentního dokončení workoutu.

## DRD-013

Výjimka musí být explicitní, vlastněná, časově nebo podmínkou omezená a nesmí porušit kritické pravidlo.

## DRD-014

Autor ani coding agent nesmí tvrdit `Done`, pokud chybí známý povinný důkaz.

## DRD-015

Definition of Ready and Done se mění pouze spolu s kontrolou release scope, test strategy a dotčených kontraktů.

---

# 15. Exit criteria dokumentu

Dokument je dostatečný pro startovní implementační minimum, pokud:

- backlog item lze jednoznačně posoudit jako Ready nebo Not Ready,
- pull request lze jednoznačně posoudit jako Done nebo Not Done,
- R0 a R1 mají konkrétní completion gates,
- test strategy zůstává zdrojem pravdy pro testovací úrovně,
- release scope zůstává zdrojem pravdy pro rozsah,
- konkrétní acceptance criteria zůstávají u vlastnící funkce nebo slice,
- výjimky jsou dohledatelné a nelze je použít k tichému obcházení pravidel.
