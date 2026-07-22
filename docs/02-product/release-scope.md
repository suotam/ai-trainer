# AI Trainer – Release Scope and Priority Matrix

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/02-product/release-scope.md`  
**Vlastník:** Product Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `vision.md`, `product-principles.md`, `product-scope.md`, `functional-requirements.md`, `non-functional-requirements.md`, user scenarios, UX specifications, domain models a hlavní architektury  
**Navazující dokumenty:** traceability matrix, acceptance criteria, vertical-slice plan, API a sync kontrakty, test strategy, release strategy a implementation guide  
**Vlastněné pojmy nebo kontrakty:** release baseline, MVP boundary, release priority, scope gate, deferred scope, exit criteria a pravidla `RSR-001` až `RSR-015`

---

# 1. Účel

Tento dokument určuje, **co se bude skutečně implementovat jako první**, v jakém pořadí a co naopak nesmí blokovat zahájení vývoje.

`product-scope.md` popisuje dlouhodobý produkt a orientační etapy. Tento dokument z něj vytváří konkrétní delivery rozhodnutí pro první programovatelný celek.

Cílem je:

- zabránit tomu, aby se první verze pokoušela implementovat celou vizi,
- vytvořit malý, ale end-to-end použitelný produktový řez,
- umožnit začít programovat dříve, než budou dokončeny všechny budoucí kontrakty,
- oddělit blokující rozhodnutí od dokumentace, která může vznikat souběžně,
- definovat ověřitelný okamžik, kdy první slice považujeme za dokončený.

---

# 2. Release strategie

Vývoj začne vertikálními slices. Každý slice musí obsahovat pouze tolik mobilní, backendové, datové a testovací práce, kolik je nutné pro skutečně spustitelné chování.

Pořadí je:

1. **R0 – Technical Foundation**
2. **R1 – Local Workout Slice**
3. **R2 – Account and Sync Slice**
4. **R3 – Profile and Manual Planning Slice**
5. **R4 – AI Plan Proposal Slice**
6. **R5 – Adaptive Daily Trainer Beta**

R0 a R1 tvoří minimální balík, po jehož zdokumentování lze začít programovat. R2 až R5 se zpřesňují průběžně před zahájením příslušného slice.

---

# 3. Priority

## P0 – Blocking baseline

Musí být hotové pro první relevantní release nebo slice. Bez P0 není jeho hlavní hodnota splněna.

## P1 – Required soon

Není nutné pro první technické spuštění, ale je nutné před uzavřením beta baseline.

## P2 – Valuable extension

Významná schopnost, která může následovat po ověření hlavního flow.

## P3 – Deferred

Potvrzený dlouhodobý směr, který nesmí komplikovat první implementaci.

Priorita v tomto dokumentu je release rozhodnutí. Nemění obecnou prioritu `CORE`, `IMPORTANT`, `ADVANCED` nebo `FUTURE` ve funkčních požadavcích.

---

# 4. R0 – Technical Foundation

## 4.1 Cíl

Vytvořit reprodukovatelný technický základ, na kterém lze bezpečně stavět produktové slices.

## 4.2 P0 scope

- Flutter projekt pro Android a iOS,
- backendový projekt jako modulární monolit,
- PostgreSQL a lokální vývojové prostředí,
- základní konfigurace prostředí,
- lokální databáze mobilní aplikace,
- health/readiness endpoint,
- první mobilní API klient,
- CI pro build, lint a testy,
- jednotné formátování a statická analýza,
- testovací struktura,
- bezpečné zacházení se secrets,
- základní logování bez citlivých payloadů,
- minimální repository a coding-agent instrukce.

## 4.3 Exit criteria

- aplikace se spustí na podporovaném Android zařízení nebo emulátoru,
- iOS build je technicky sestavitelný v podporovaném prostředí,
- backend se spustí lokálně,
- mobilní klient načte testovací odpověď backendu,
- databázová migrace projde na čisté databázi,
- CI projde na čistém checkoutu,
- žádný produkční secret není v repozitáři.

---

# 5. R1 – Local Workout Slice

## 5.1 Hlavní hodnota

Uživatel na jednom zařízení otevře dnešní plán, spustí workout, zapíše výkon a dokončí jej i bez sítě.

Tento slice záměrně nepoužívá účet, vzdálenou synchronizaci ani generativní AI.

## 5.2 P0 scope

- lokální demo AthleteProfile,
- jeden aktivní demo TrainingPlan,
- Today obrazovka,
- týdenní přehled plánovaných workoutů,
- detail WorkoutInstance,
- spuštění WorkoutSession,
- podporovaný silový workout,
- záznam setů, opakování, váhy, času a poznámky podle typu kroku,
- označení kroku jako dokončeného nebo vynechaného,
- lokální odolné ukládání průběhu,
- obnovení aktivní session po restartu aplikace,
- dokončení workoutu,
- subjektivní hodnocení náročnosti a pocitu,
- základní lokální historie,
- viditelný stav lokálního uložení,
- základní accessibility a lokalizační struktura.

## 5.3 P1 scope

- mobilita a časový workout,
- timer odpočinku,
- základní editace plánované hodnoty během workoutu,
- jednoduchý completion přehled,
- základní empty, loading, error a recovery stavy.

## 5.4 Explicitně mimo R1

- registrace a přihlášení,
- cloudová synchronizace,
- AI chat,
- AI generování plánu,
- wearables,
- GPS tracker,
- externí kalendáře,
- push notifikace,
- trenérské role,
- sociální funkce,
- pokročilé statistiky.

## 5.5 Exit criteria

- celý hlavní flow funguje v airplane mode,
- potvrzený zápis přežije pád nebo restart aplikace,
- aktivní workout lze bezpečně obnovit,
- dokončený workout se zobrazí v historii,
- běžné chyby nejsou prezentovány jako úspěch,
- kritické flow má automatické testy,
- nevzniká závislost na konkrétním budoucím AI nebo integration provideru.

---

# 6. R2 – Account and Sync Slice

## 6.1 Hlavní hodnota

Uživatel se přihlásí a jeho podporovaná data se bezpečně synchronizují mezi lokálním klientem a serverem.

## 6.2 P0 scope

- vytvoření účtu nebo schválená alternativní authentication baseline,
- přihlášení a odhlášení,
- bezpečná session a refresh strategie,
- vytvoření základního AthleteProfile,
- registrace zařízení,
- synchronizace profilu, kalendáře, workoutů a session výsledků,
- pending operation queue,
- idempotentní replay,
- serverová ownership autorizace,
- základní conflict a rejection flow,
- revokace session,
- audit kritických auth a sync událostí.

## 6.3 Odložené části

- více AthleteProfile pod jedním účtem,
- trenér a sportovec,
- týmové role,
- pokročilá správa aktivních zařízení,
- složité collaborative konflikty.

---

# 7. R3 – Profile and Manual Planning Slice

## 7.1 Hlavní hodnota

Uživatel vytvoří strukturovaný multisportovní profil, cíle a ručně spravovatelný plán bez závislosti na AI.

## 7.2 P0 scope

- sporty a zkušenost,
- participation patterns,
- cíle a jejich priority,
- dostupnost a typický týden,
- vybavení a prostředí,
- základní omezení,
- ruční vytvoření a úprava plánu,
- interní kalendář,
- přesun, zrušení a nahrazení workoutu,
- ruční aktivita,
- základní progres a completion statistiky.

---

# 8. R4 – AI Plan Proposal Slice

## 8.1 Hlavní hodnota

AI vytvoří vysvětlitelný strukturovaný návrh plánu, ale doménová změna nastane pouze po validaci a potvrzení.

## 8.2 P0 scope

- AI request classification,
- autorizovaný a minimalizovaný AIContext,
- verzovaný prompt,
- provider abstraction,
- structured output schema,
- deterministická validace návrhu,
- AIProposal,
- zobrazení důvodů a dopadů,
- uživatelské potvrzení,
- ChangeSet execution boundary,
- audit výsledku,
- bezpečný fallback při selhání modelu,
- základní eval dataset a release gate.

## 8.3 Zakázané zkratky

- AI nesmí přímo zapisovat do doménových tabulek,
- textová odpověď nesmí být vydávána za uloženou změnu,
- model nesmí rozhodovat o autorizaci,
- nevalidní strukturovaný výstup se nesmí automaticky provést.

---

# 9. R5 – Adaptive Daily Trainer Beta

## 9.1 Hlavní hodnota

Uživatel dostává praktický denní přehled a může bezpečně reagovat na únavu, změnu programu nebo omezení.

## 9.2 P0 scope

- DailyCheckIn,
- hlášení únavy a bolesti,
- deterministické safety omezení,
- návrh úpravy dne nebo týdne,
- potvrditelný ChangeSet,
- Today doporučení,
- základní notifikace,
- týdenní shrnutí,
- základní vysvětlení progresu.

## 9.3 Odborná hranice

Pain, limitation a recovery workflow nesmí být označeno jako produkčně připravené bez požadovaného medicínského a právního review.

---

# 10. Scope první beta baseline

První externě testovatelná beta zahrnuje R0 až R5, ale nemusí obsahovat všechny P1 položky.

Beta musí prokázat tento end-to-end scénář:

1. uživatel se přihlásí,
2. vyplní základní multisportovní profil a cíl,
3. získá AI návrh plánu,
4. návrh zkontroluje a potvrdí,
5. plán se zobrazí v Today a kalendáři,
6. workout lze provést offline,
7. výsledek se později synchronizuje,
8. uživatel oznámí změnu nebo únavu,
9. AI vytvoří nový potvrditelný návrh,
10. systém zachová historii, vysvětlení a možnost bezpečné obnovy.

---

# 11. Funkce odložené za první beta baseline

Minimálně P2 nebo P3 jsou:

- Apple Health a Health Connect,
- Garmin, Strava a další wearable integrace,
- externí kalendáře,
- GPS tracking,
- trenérské a týmové role,
- sociální feed a veřejné profily,
- pokročilé prediktivní metriky,
- automatické vzdálené zásahy bez potvrzení,
- marketplace plánů,
- desktopový nebo webový plnohodnotný klient,
- podpora nezletilých bez dokončeného právního modelu,
- zdravotnická diagnostika nebo léčebná doporučení.

Tyto schopnosti nesmí předčasně ovlivnit R0 a R1 jinak než zachováním rozumných extension points.

---

# 12. Dokumentační minimum před zahájením programování

Programování R0 a R1 může začít po dokončení následujícího minimálního balíku:

1. tento release scope,
2. repository strategy a projektová struktura,
3. vybraná počáteční ADR,
4. minimální fyzický lokální a serverový datový model pro R1,
5. minimální API contract pro health a budoucí sync boundary,
6. test strategy,
7. Definition of Ready a Definition of Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Kompletní provider, AI, operations a incident dokumentace není podmínkou zahájení R0/R1. Musí však být dokončena před slicem, který ji používá.

---

# 13. Změnová pravidla

Každé rozšíření P0 scope musí uvést:

- konkrétní uživatelskou hodnotu,
- dotčené FR a NFR,
- dopad na doménu a architekturu,
- nové acceptance criteria,
- dopad na termín a rizika,
- položku, která bude případně odstraněna nebo odložena.

Bez této analýzy se nový požadavek za P0 nepovažuje.

---

# 14. Závazná pravidla

## RSR-001 – Vertical slice first

Implementace postupuje po spustitelných vertikálních slices, nikoli po dlouhých izolovaných technologických vrstvách.

## RSR-002 – R0 a R1 jsou startovní baseline

První programování se zaměří na R0 a R1; účet, AI a integrace nesmí jejich dokončení blokovat.

## RSR-003 – P0 musí mít exit criteria

Položka P0 je dokončená pouze s ověřitelnými exit criteria a odpovídajícími testy.

## RSR-004 – Offline workout je základní hodnota

R1 nesmí záviset na síti pro spuštění, průběh, zápis ani dokončení podporovaného workoutu.

## RSR-005 – Manual path remains available

Základní profil, plán a workout workflow nesmí být dostupné pouze přes AI.

## RSR-006 – AI proposes, domain executes

AI vytváří návrhy; autorizovanou doménovou změnu provádí validovaný ChangeSet proces.

## RSR-007 – Scope does not override safety

Release scope nesmí oslabit právní povinnost, security architekturu, doménovou invariantu ani CRITICAL NFR.

## RSR-008 – Deferred means not implemented

P3 položky nesmí být skrytě implementovány v prvních slices bez explicitní změny tohoto dokumentu.

## RSR-009 – Extension points are bounded

Budoucí rozšiřitelnost nesmí vést k abstrakcím bez aktuálního případu použití.

## RSR-010 – Provider independence

R0 až R3 nesmí vyžadovat konkrétní AI, wearable nebo calendar provider.

## RSR-011 – Data history is preserved

Release zkratka nesmí odstranit provenance, revize nebo audit tam, kde je požaduje doménový model.

## RSR-012 – Rejection is visible

Odmítnutý sync, AI návrh nebo doménová změna nesmí být prezentována jako úspěch.

## RSR-013 – Slice-specific contracts

Detailní kontrakt musí být dokončen nejpozději před implementací slice, který ho používá.

## RSR-014 – Beta is end-to-end

První beta musí prokázat celý cyklus profil → plán → workout → výsledek → adaptace, nikoli pouze izolované obrazovky.

## RSR-015 – Scope changes are traceable

Každá změna release baseline musí být commitnutá, zdůvodněná a později dohledatelná v traceability matrix.

---

# 15. Review před Implementation Ready

Před označením dokumentu jako `IMPLEMENTATION_READY` je nutné:

- namapovat konkrétní FR a CRITICAL NFR na R0 až R5,
- potvrdit technologická ADR pro R0,
- schválit přesná acceptance criteria R1,
- potvrdit podporované platformy a referenční zařízení,
- potvrdit minimální datový a sync kontrakt,
- dokončit threat review startovní baseline,
- potvrdit testovací a release gates,
- převést R0 a R1 na konkrétní implementační backlog.
