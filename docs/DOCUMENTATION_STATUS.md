# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Účel dokumentu

Tento dokument je řídicí přehled skutečně existující dokumentace projektu AI Trainer.

Jeho cílem je:

- rozlišit existující a pouze plánované soubory,
- určit hlavní zdroj pravdy pro jednotlivá témata,
- zabránit vytváření duplicitních dokumentů,
- označit obsahové překryvy,
- identifikovat skutečné mezery,
- určit pořadí další tvorby dokumentace,
- sledovat připravenost dokumentace pro implementaci,
- usnadnit budoucímu coding agentovi výběr relevantního kontextu.

Tento dokument není náhradou jednotlivých specifikací. Obsahuje pouze jejich audit, stav a vztahy.

---

# 2. Metodika auditu

Každý existující dokument je posuzován podle následujících hledisek:

1. **Účel** – jakou otázku dokument řeší.
2. **Rozsah** – jaké oblasti skutečně pokrývá.
3. **Zdroj pravdy** – které pojmy nebo pravidla vlastní.
4. **Překryvy** – kde se obsah opakuje s jinými dokumenty.
5. **Mezery** – co je nutné doplnit před implementací.
6. **Stav** – zda je dokument pouze draft, nebo se blíží implementační připravenosti.
7. **Doporučení** – zda dokument ponechat, doplnit, rozdělit, sloučit nebo nepřidávat další obdobný soubor.

## 2.1 Stavové hodnoty auditu

- **FOUNDATION_READY** – vhodný jako stabilní základ; před implementací vyžaduje už jen konzistenční revizi.
- **SUBSTANTIAL_DRAFT** – velmi rozsáhlý a použitelný draft, ale zatím bez finálního cross-document auditu.
- **PARTIAL** – oblast je pokryta, ale chybí významná část.
- **NEEDS_CONSOLIDATION** – informace existují na více místech a mají být sjednoceny nebo odkázány.
- **PLANNED** – dokument zatím neexistuje a jeho potřeba byla potvrzena.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již dostatečně pokryt jinde.
- **REVIEW_REQUIRED** – existuje riziko rozporu nebo neaktuálnosti.

## 2.2 Důležité omezení

Všechny současné hlavní dokumenty mají formální stav `Draft`. Audit proto neoznačuje žádný dokument jako definitivně schválený nebo implementovaný.

---

# 3. Souhrn aktuálního stavu

Projekt již obsahuje rozsáhlý základ v následujících oblastech:

- produktová vize a principy,
- dlouhodobý produktový rozsah,
- uživatelské persony a scénáře,
- informační architektura,
- klíčová uživatelská flow,
- specifikace hlavních obrazovek,
- hlavní doménové modely,
- offline a synchronizační model,
- integrace,
- AI návrhy a bezpečné změny,
- identity a profil,
- doménové události.

Největší mezery nyní nejsou v dalším rozepisování vize nebo doménových entit. Největší mezery jsou v:

- sjednocení pravidel napříč doménami,
- stabilním slovníku,
- funkčních a nefunkčních požadavcích,
- technických rozhodnutích,
- backendové architektuře,
- mobilní architektuře,
- AI runtime architektuře,
- bezpečnosti a ochraně soukromí,
- fyzickém datovém modelu,
- API kontraktech,
- testovací strategii,
- infrastruktuře, release a provozu,
- implementačních instrukcích pro coding agenta.

## 3.1 Hlavní závěr auditu

Není vhodné pokračovat podle původního seznamu stovek předem pojmenovaných souborů.

Další soubory mají vznikat podle skutečných obsahových mezer. Jedno dobře navržené komplexní téma může zůstat v jednom dokumentu, dokud jeho velikost, vlastnictví nebo způsob použití nevyžadují rozdělení.

---

# 4. Audit kořenových dokumentů

## 4.1 `docs/README.md`

**Stav auditu:** `NEEDS_CONSOLIDATION`

### Účel

Hlavní mapa dokumentace, pravidla zdrojů pravdy a návrh struktury.

### Silné stránky

- definuje hierarchii autority dokumentů,
- stanovuje princip jednoho vlastníka významu,
- popisuje vztah dokumentace a implementace,
- vytváří společný rozcestník pro coding agenta,
- navrhuje budoucí tematické sekce.

### Problémy

- obsahuje příliš široký předběžný katalog stovek souborů,
- některé plánované soubory by duplikovaly existující obsah,
- míchá mapu dokumentace s produktovými a technickými principy,
- některé uváděné stavy nemusí odpovídat skutečnému repozitáři,
- obsahuje odhad 350–400 souborů, který není výsledkem auditu.

### Doporučení

Dokument ponechat, ale po dokončení tohoto auditu jej zkrátit a upravit tak, aby obsahoval:

- skutečnou strukturu,
- zdroje pravdy,
- pravidla práce s dokumentací,
- odkazy na `DOCUMENTATION_STATUS.md`,
- stručný přehled plánovaných sekcí bez závazného seznamu každého budoucího souboru.

Nemá znovu vysvětlovat celou produktovou vizi, offline model ani AI bezpečnost.

---

# 5. Audit `01-vision`

## 5.1 `docs/01-vision/vision.md`

**Stav auditu:** `FOUNDATION_READY`

### Vlastní témata

- vize produktu,
- poslání,
- dlouhodobý směr,
- definice toho, co AI Trainer je,
- definice toho, co AI Trainer není,
- hlavní filozofie,
- základní cíle produktu,
- odlišení od konkurence,
- zamýšlený pocit uživatele,
- definice dlouhodobého úspěchu.

### Překryvy

Částečně se překrývá s:

- `product-principles.md`,
- `product-scope.md`,
- úvodem `docs/README.md`.

Překryv je přijatelný pouze na úrovni stručného kontextu. Detailní pravidla mají zůstat v `product-principles.md` a konkrétní rozsah v `product-scope.md`.

### Chybí

- finální vlastník dokumentu,
- datum poslední revize,
- odkazy na navazující dokumenty,
- případné měřitelné dlouhodobé výsledky mají být řešeny jinde, ne přímo zde.

### Rozhodnutí o dalších souborech

Samostatné dokumenty:

- `long-term-product-vision.md`,
- `product-positioning.md`,
- `non-goals.md`

nyní **nejsou nutné jako samostatné soubory**, protože jejich základní obsah již `vision.md` obsahuje.

Nový soubor má vzniknout pouze tehdy, pokud pozdější produktová práce prokáže, že například positioning potřebuje samostatný obchodní a marketingový kontrakt.

---

## 5.2 `docs/01-vision/product-principles.md`

**Stav auditu:** `FOUNDATION_READY`

### Vlastní témata

- AI jako centrální koordinační vrstva,
- poslední slovo uživatele,
- vysvětlitelnost,
- společný multisportovní systém,
- živý plán,
- nepřepisování historie,
- minimalizace administrativy,
- rychlost nejčastějších úkolů,
- autorizované AI nástroje,
- bezpečnost před výkonem,
- datově založená personalizace,
- principy offline a dalších systémových vlastností.

### Překryvy

Principy se přirozeně opakují v jednotlivých doménových dokumentech jako konkrétní pravidla. To je správné, pokud doménový dokument na princip odkazuje a pouze jej konkretizuje.

### Chybí

- jednoznačné ID principů, například `PP-001`, které lze odkazovat z požadavků, ADR a testů,
- rozlišení principu a tvrdé invariance,
- formální pravidlo řešení konfliktu mezi principy.

### Doporučení

Dokument ponechat jako hlavní produktový zdroj pravdy. Nevytvářet další obecný soubor s obdobnými „zásadami produktu“.

---

# 6. Audit `02-product`

## 6.1 `docs/02-product/product-scope.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- dlouhodobý rozsah produktu,
- uživatelský účet a profil,
- sporty,
- cíle,
- tréninkové plány,
- kalendář,
- workout tracker,
- AI trenér,
- regenerace,
- statistiky,
- integrace a wearables,
- etapizace produktu,
- odložené nebo vyloučené funkce.

### Překryvy

Obsah se záměrně překrývá s doménovými dokumenty, ale má zůstat na úrovni produktového rozsahu. Doménové objekty a jejich stavové přechody vlastní `06-domain`.

### Chybí nebo vyžaduje doplnění

- stabilní identifikátory funkcí,
- úplná dohledatelnost mezi funkcemi, UX, doménou, API a testy,
- jasné rozlišení cílové verze, V1, beta a MVP,
- obchodní entitlementy,
- produktové limity a kvóty,
- samostatně dohledatelné funkční požadavky,
- samostatně dohledatelné nefunkční požadavky.

### Potvrzené nové dokumenty

- `docs/02-product/functional-requirements.md`
- `docs/02-product/non-functional-requirements.md`

`feature-catalog.md` zatím nemusí být samostatný dokument. Může vzniknout jako strojověji strukturovaný index funkčních požadavků, pokud se `functional-requirements.md` stane příliš rozsáhlým.

---

# 7. Audit `03-users`

## 7.1 `docs/03-users/user-personas.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- hlavní typy uživatelů,
- sportovní zkušenosti,
- motivace,
- potřeby,
- bariéry,
- technologické chování,
- příklady více sportů, omezení a rozdílných režimů.

### Překryvy

- `user-scenarios.md` používá persony v konkrétních situacích,
- `identity-and-profile-model.md` technicky modeluje profil,
- `product-scope.md` popisuje funkce pro tyto uživatele.

### Chybí

- přímé mapování person na funkční požadavky,
- ověření, zda všechny persony stále odpovídají cílovému produktu,
- explicitní sekundární persony pro trenéra, opatrovníka a accessibility pouze pokud budou skutečně podporované v cílovém rozsahu.

### Doporučení

Nevytvářet automaticky zvláštní soubory `coach-persona.md` nebo `accessibility-personas.md`. Nejprve doplnit existující soubor o chybějící persony. Rozdělit až tehdy, když rozsah přestane být přehledný.

---

## 7.2 `docs/03-users/user-scenarios.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- realistické end-to-end situace,
- onboarding,
- plánování,
- změna rozvrhu,
- únava a bolest,
- více sportů,
- offline použití,
- import dat,
- adaptace plánu,
- návrat po pauze.

### Překryvy

- `core-user-flows.md` převádí scénáře na UX tok,
- doménové dokumenty převádějí scénáře na stavové modely,
- budoucí acceptance tests budou ze scénářů odvozeny.

### Chybí

- stabilní ID scénářů,
- priorita scénáře,
- vazba na personu,
- vazba na požadavek,
- očekávaný výsledek,
- kritické bezpečnostní scénáře,
- explicitní negativní a hraniční scénáře.

### Doporučení

`jobs-to-be-done.md`, `multisport-user-model.md` a `returning-user-model.md` zatím nejsou potvrzené jako samostatné soubory. Jejich obsah lze nejprve doplnit do person a scénářů.

---

# 8. Audit `04-ux`

## 8.1 `docs/04-ux/information-architecture.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- hlavní části aplikace,
- navigační vztahy,
- informační hierarchie,
- vstupní body,
- vztah Today, Calendar, Plan, Progress, AI a Profile,
- globální přístupy a kontexty.

### Chybí

- finální mapování na konkrétní route names,
- pravidla deep linků,
- rozdíly podle přihlášení, role a aktivního profilu,
- kompletní stavy navigace při offline režimu,
- přístupnost navigace,
- vazba na budoucí desktop nebo watch klienty, pokud budou součástí cílové dokumentace.

### Doporučení

Samostatný `navigation-model.md` má vzniknout pouze jako technický UX kontrakt pro routes, deep links a navigační stav. Obecnou informační architekturu znovu neopakovat.

---

## 8.2 `docs/04-ux/core-user-flows.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- hlavní uživatelské toky,
- onboarding,
- vytvoření a úprava plánu,
- dnešní trénink,
- tracker,
- změny přes AI,
- únava a bolest,
- synchronizace a konflikt,
- integrace.

### Chybí

- jednotné identifikátory flow,
- explicitní preconditions a postconditions,
- alternativní a error paths u všech kritických flow,
- odkazy na obrazovky a funkční požadavky,
- jednoznačné acceptance criteria.

### Doporučení

Nevytvářet automaticky samostatný soubor pro každé flow. Kritická flow lze později rozdělit podle potřeby implementace, ale hlavní zdroj pravdy zůstane tento dokument.

---

## 8.3 `docs/04-ux/screen-specifications.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- účel hlavních obrazovek,
- vstupní body,
- zobrazovaná data,
- uživatelské akce,
- stavy,
- vazby mezi obrazovkami,
- AI a safety interakce.

### Chybí

- stabilní screen IDs,
- kompletní matice role × stav × oprávnění,
- finální prázdné, loading, offline a error stavy,
- přesné accessibility požadavky,
- propojení na design-system komponenty,
- analytické události obrazovek,
- explicitní acceptance criteria.

### Doporučení

Samostatné soubory `empty-states.md`, `loading-states.md`, `error-states.md` a `offline-states.md` zatím nevytvářet automaticky. Nejdříve vytvořit jednu společnou specifikaci `state-and-error-ux.md`, pokud se ukáže, že globální pravidla nelze přehledně doplnit sem.

---

# 9. Audit `06-domain`

## 9.1 `docs/06-domain/domain-overview.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- hlavní bounded contexts,
- agregáty,
- vztahy mezi doménami,
- základní vlastnictví dat,
- hlavní příkazy a události,
- architektonické hranice domény.

### Překryvy

Jednotlivé doménové modely přirozeně rozepisují stejné objekty. `domain-overview.md` má zůstat mapou a nesmí s nimi soutěžit o detailní definici.

### Chybí

- finální kontextová mapa,
- jasná matice vlastníků objektů,
- potvrzené transakční hranice,
- jednoznačné odkazy na invariance a glossary,
- konsolidovaný seznam otevřených rozhodnutí.

---

## 9.2 `sports-and-goals-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- SportDefinition a UserSport,
- vlastní a neznámé sporty,
- sportovní zkušenost,
- účastnické vzorce,
- cíle, priority, milníky a metriky,
- konflikty cílů,
- progres a životní cyklus cíle.

### Chybí před implementací

- finální kardinality,
- rozhodnutí, které části jsou referenční data,
- přesné validační kontrakty,
- fyzické datové mapování,
- API a permission pravidla.

---

## 9.3 `training-plan-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- TrainingPlan,
- TrainingPlanVersion,
- bloky, týdny a fáze,
- stavový model plánu,
- verzování,
- adaptace a aktivace,
- vztah plánu k cílům, workoutům a schedule.

### Chybí před implementací

- přesný planning algorithm contract,
- limity velikosti a horizontu plánu,
- fyzické schema,
- API příkazy a response modely,
- performance a concurrency pravidla.

---

## 9.4 `workout-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- WorkoutDefinition, Template a Instance,
- verze workoutu,
- cvičení, kroky, série a rest,
- různé modality,
- workout session,
- tracker data,
- úpravy a substituce.

### Chybí před implementací

- finální exercise/reference katalog,
- structured contracts jednotlivých step types,
- validace kombinací modality,
- local persistence schema,
- přesný session recovery protokol.

---

## 9.5 `scheduling-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- ScheduleEvent,
- pevnost a flexibilita,
- opakování,
- časová pásma,
- konflikty,
- reminder vazby,
- propojení plánovaných a skutečných aktivit.

### Chybí před implementací

- definitivní recurrence standard,
- DST testovací matice,
- scheduling engine policy,
- externí kalendářová synchronizace,
- fyzický model materializovaných výskytů.

---

## 9.6 `activity-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- skutečně provedená aktivita,
- ActivityRecord,
- ruční, workoutové a importované zdroje,
- párování s plánem,
- slučování a duplicity,
- opravy,
- zátěž, trasa a metriky,
- provenance.

### Chybí před implementací

- přesné canonical activity type mapping,
- algoritmus deduplikace,
- GPS datový formát,
- import pipeline kontrakt,
- retention a privacy pravidla trasy.

---

## 9.7 `recovery-and-limitations-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- check-in,
- readiness,
- únava, soreness, stres a spánek,
- bolest,
- omezení,
- safety flags,
- odborná doporučení,
- návrat k aktivitě,
- vliv na workout a plán.

### Chybí před implementací

- formalizované safety rules,
- red-flag escalation matice,
- medicínské hranice a wording,
- regionální právní kontrola,
- oddělení deterministických a AI rozhodnutí,
- přesná data classification.

---

## 9.8 `ai-and-change-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- AIConversation,
- intent a context,
- AIProposal,
- ChangeSet a ChangeOperation,
- potvrzení,
- validace,
- stale návrhy,
- částečné schválení,
- undo a kompenzace,
- autorizované nástroje na doménové úrovni.

### Chybí před implementací

- runtime AI orchestrace,
- provider abstraction,
- přesná tool schemas,
- prompt architecture,
- model selection,
- prompt injection ochrana,
- evaluation a observability,
- cost controls.

Tyto mezery patří do `09-ai`, nikoli do dalšího doménového modelu.

---

## 9.9 `metrics-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- MetricDefinition,
- MetricValue a MetricSeries,
- jednotky,
- provenance,
- agregace,
- baseline, trend a target,
- personal records,
- přepočty a verze výpočtu.

### Chybí před implementací

- počáteční katalog systémových metrik,
- přesné vzorce a jejich verze,
- time-series storage strategy,
- numerická precision policy,
- datové quality thresholds.

---

## 9.10 `integration-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- provider a connection,
- oprávnění,
- credential lifecycle,
- import/export jobs,
- external records,
- mapování, deduplikace a lineage,
- webhooks,
- reconciliation a health.

### Chybí před implementací

- ověřená capability matrix konkrétních providerů,
- právní a smluvní dostupnost API,
- provider-specific mapping,
- rate limits,
- certifikační požadavky,
- konkrétní OAuth flow.

---

## 9.11 `sync-and-offline-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- offline-first princip,
- lokální identifikátory,
- command queue,
- change feed,
- konflikty,
- tombstones,
- aktivní workout session,
- více zařízení,
- retry a idempotence,
- background sync,
- bezpečnost lokálních dat.

### Chybí před implementací

- konkrétní sync wire protocol,
- cursor a pagination kontrakt,
- lokální databázové schema,
- per-entity merge rules v implementační podobě,
- omezení background execution na Android/iOS,
- recovery a corruption test plan.

---

## 9.12 `identity-and-profile-model.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- Identity,
- AuthenticationIdentity,
- UserAccount,
- AthleteProfile,
- onboarding,
- osobní a sportovní profil,
- dostupnost, vybavení a preference,
- jednotky, locale a timezone,
- souhlasy,
- anonymní účet,
- více profilů,
- coach a guardian vztahy,
- export a smazání.

### Chybí před implementací

- výběr identity provideru,
- konkrétní authentication flows,
- session a token model,
- autorizace,
- právní rozhodnutí pro minors,
- konkrétní consent texty a jurisdikce,
- account merge implementace.

---

## 9.13 `domain-events.md`

**Stav auditu:** `SUBSTANTIAL_DRAFT`

### Vlastní témata

- rozdíl command/event/integration event/audit,
- event envelope,
- identifikátory a verze,
- correlation a causation,
- outbox a inbox,
- at-least-once delivery,
- ordering,
- retry, dead letter a replay,
- projekce,
- privacy a data classification,
- rozsáhlý event katalog.

### Chybí před implementací

- potvrzení, zda první backend bude eventy distribuovat nebo držet in-process,
- formát schématu,
- broker nebo interní transport,
- event contract registry,
- topic/partition strategy,
- přesné consumer mapování,
- retenční policy.

### Důležitý závěr

Samostatný backendový `event-architecture.md` bude potřeba, ale nesmí znovu definovat význam událostí. Má pouze rozhodnout technickou realizaci tohoto modelu.

---

# 10. Potvrzené duplicity a dokumenty, které nyní nevytvářet

Následující dokumenty nyní nevytvářet jako samostatné soubory, protože jejich obsah je již významně pokryt:

| Původně plánovaný soubor | Současný zdroj pravdy |
|---|---|
| `01-vision/long-term-product-vision.md` | `01-vision/vision.md` |
| `01-vision/non-goals.md` | `01-vision/vision.md` + `02-product/product-scope.md` |
| `01-vision/product-positioning.md` | zatím `01-vision/vision.md`; samostatně pouze při marketingové potřebě |
| `03-users/multisport-user-model.md` | `user-personas.md`, `user-scenarios.md`, `sports-and-goals-model.md` |
| `03-users/returning-user-model.md` | `user-scenarios.md`, `identity-and-profile-model.md` |
| `03-users/onboarding-personalization.md` | `identity-and-profile-model.md` + budoucí UX onboarding specifikace |
| `04-ux/screen-inventory.md` | `information-architecture.md` + `screen-specifications.md` |
| samostatný obecný `AI-responsibilities.md` | `product-principles.md` + `ai-and-change-model.md`; runtime detaily patří do `ai-architecture.md` |
| samostatný obecný `offline-principles.md` | `sync-and-offline-model.md` |
| samostatný obecný `event-catalog.md` | `domain-events.md` |

Toto rozhodnutí není trvalý zákaz. Samostatný soubor může později vzniknout, pokud bude mít jasného vlastníka, odlišný účel a praktické použití.

---

# 11. Potvrzené bezprostřední mezery

## 11.1 Doménová konsolidace

### `docs/06-domain/domain-invariants.md`

**Potřeba:** potvrzena.

Nemá znovu přepisovat všechny invariance z každého modelu. Má obsahovat:

- globální pravidla napříč doménami,
- prioritní pravidla,
- cross-aggregate invariance,
- bezpečnostní nepřekročitelné hranice,
- matici odkazu na detailní invariance v jednotlivých modelech,
- pravidla řešení konfliktů mezi doménami.

### `docs/06-domain/glossary.md`

**Potřeba:** potvrzena.

Má obsahovat:

- jeden kanonický název každého významného pojmu,
- krátkou definici,
- vlastnící dokument,
- povolené a zakázané synonymum,
- rozdíly mezi snadno zaměnitelnými pojmy.

Nemá znovu obsahovat celé doménové modely.

---

## 11.2 Produktové požadavky

### `docs/02-product/functional-requirements.md`

**Potřeba:** potvrzena.

Má převést produktový rozsah na číslované testovatelné požadavky.

### `docs/02-product/non-functional-requirements.md`

**Potřeba:** potvrzena.

Má definovat zejména:

- dostupnost,
- výkon,
- odezvu,
- offline schopnosti,
- spolehlivost,
- konzistenci,
- bezpečnost,
- soukromí,
- přístupnost,
- lokalizaci,
- škálovatelnost,
- battery a network limity,
- obnovu po chybě.

---

## 11.3 Technické architektury

Po uzavření domény a požadavků jsou potvrzeny minimálně tyto hlavní dokumenty:

- `docs/07-backend/backend-architecture.md`
- `docs/08-mobile/mobile-architecture.md`
- `docs/09-ai/ai-architecture.md`
- `docs/10-integrations/integration-architecture.md`
- `docs/11-security/security-architecture.md`
- `docs/12-data/data-architecture.md`

Každý má popisovat technickou realizaci a nesmí znovu definovat produktový nebo doménový význam.

---

# 12. Dokumenty potřebné před hlavní implementací

Níže je pracovní, auditovaný seznam kategorií dokumentů. Nejde o závazek, že každá odrážka musí být samostatný soubor. Při psaní se rozhodne podle velikosti a vlastnictví.

## 12.1 Produkt a UX

- funkční požadavky,
- nefunkční požadavky,
- prioritizace a release scope,
- navigační kontrakt,
- globální UX stavy a chyby,
- accessibility requirements,
- obsahová a bezpečnostní pravidla textů,
- design system.

## 12.2 Backend

- hlavní architektura,
- modulární hranice,
- application a domain execution model,
- persistence a transactions,
- event realizace,
- background jobs,
- scheduling a planning engines,
- sync service,
- AI orchestration,
- notifications,
- audit,
- error a idempotency model.

## 12.3 Mobile

- hlavní Flutter architektura,
- struktura modulů,
- state management,
- routing,
- local DB,
- repositories,
- offline queue a sync,
- active workout persistence,
- background execution,
- notifications,
- secure storage,
- GPS a health access,
- performance, battery a lifecycle.

## 12.4 AI

- runtime architektura,
- provider abstraction a výběr modelů,
- context builder,
- memory,
- prompt architecture,
- structured outputs,
- tool contracts,
- autorizace nástrojů,
- confirmation policy,
- safety a medical boundaries,
- prompt injection ochrana,
- observability, cost a evaluace.

## 12.5 Data a API

- logical a physical relational model,
- local data model,
- time-series data,
- blobs a GPS data,
- migrations,
- retention, export a deletion,
- API principles,
- auth a domain endpoints,
- sync protocol,
- error contract,
- pagination, filtering, idempotency a versioning,
- event schemas.

## 12.6 Security

- threat model,
- data classification,
- authentication,
- authorization,
- sessions a devices,
- encryption,
- secrets,
- integration security,
- health a location data,
- privacy, consent a GDPR,
- audit, incident response a deletion.

## 12.7 Delivery, quality a provoz

- ADR pro klíčové technologie,
- environments a local development,
- CI/CD,
- deployment,
- observability,
- test strategy,
- AI evaluation,
- security a load tests,
- release strategy,
- rollback,
- SLO a runbooks,
- implementation master plan,
- coding-agent instructions.

---

# 13. Doporučené pořadí další práce

## Fáze 1 – uzavření existující dokumentace

1. `docs/06-domain/domain-invariants.md`
2. `docs/06-domain/glossary.md`
3. aktualizace `docs/README.md` podle tohoto auditu
4. doplnění ID a metadata do základních dokumentů
5. cross-document consistency review domény

## Fáze 2 – požadavky

1. `docs/02-product/functional-requirements.md`
2. `docs/02-product/non-functional-requirements.md`
3. release scope a priority matrix
4. traceability matrix požadavek → UX → doména → test

## Fáze 3 – hlavní architektury

1. backend,
2. data,
3. mobile,
4. AI,
5. security,
6. integrations.

Pořadí backend a data se může iterativně střídat.

## Fáze 4 – konkrétní kontrakty

1. ADR technologických voleb,
2. databázové modely,
3. API,
4. sync protokol,
5. AI tools a structured outputs,
6. event schemas,
7. provider capabilities.

## Fáze 5 – UX a design implementační specifikace

1. navigace,
2. globální stavy,
3. accessibility,
4. design tokens,
5. komponenty,
6. klíčové obrazovky a interaction contracts.

## Fáze 6 – kvalita a provoz

1. test strategy,
2. acceptance criteria,
3. AI evaluation,
4. security testing,
5. DevOps,
6. release,
7. observability,
8. runbooks.

## Fáze 7 – implementační balíček pro Clauda

1. repository strategy,
2. implementation stages,
3. vertical slices,
4. Definition of Ready,
5. Definition of Done,
6. coding standards,
7. Claude instructions,
8. context-loading guide,
9. prompt templates,
10. change and documentation policy.

---

# 14. Pravidla pro další vytváření souborů

Nový dokument se vytvoří pouze tehdy, pokud platí alespoň jedna podmínka:

1. téma dosud nemá zdroj pravdy,
2. existující dokument je příliš obecný pro implementaci,
3. téma má jiného vlastníka nebo jiný životní cyklus,
4. obsah bude používán samostatně jako kontrakt,
5. rozdělení výrazně zlepší načítání kontextu coding agentem,
6. samostatný soubor je potřebný pro audit, test nebo provoz.

Nový dokument se nevytvoří pouze proto, že byl uveden v původním orientačním stromu.

Před vytvořením každého dalšího souboru je nutné zkontrolovat:

- existující zdroje pravdy,
- překryvy,
- vlastnictví pojmu,
- očekávané čtenáře,
- návaznosti,
- zda stačí doplnění existujícího dokumentu.

---

# 15. Doporučené metadata pro všechny dokumenty

Každý dokument má postupně získat:

```text
Verze:
Stav:
Soubor:
Vlastník:
Poslední aktualizace:
Navazuje na:
Navazující dokumenty:
Vlastněné pojmy:
```

Dále je vhodné používat stabilní identifikátory:

- `PP-xxx` pro produktové principy,
- `FR-xxx` pro funkční požadavky,
- `NFR-xxx` pro nefunkční požadavky,
- `INV-xxx` pro globální invariance,
- `SCN-xxx` pro scénáře,
- `FLOW-xxx` pro UX flow,
- `SCR-xxx` pro obrazovky,
- `ADR-xxx` pro rozhodnutí,
- `AC-xxx` pro acceptance criteria.

---

# 16. Rizika současné dokumentace

## 16.1 Duplicita pravidel

Stejný princip je často uveden ve vizi, produktových principech, doménovém přehledu a konkrétním modelu. Bez odkazů může později vzniknout rozpor.

**Náprava:** zavést ID, vlastníky a odkazy.

## 16.2 Velmi dlouhé dokumenty

Řada dokumentů je mimořádně rozsáhlá. To může komplikovat:

- lidské review,
- načítání do AI kontextu,
- nalezení konkrétního pravidla,
- udržování konzistence.

**Náprava:** nerozdělovat automaticky, ale vytvořit indexy a později oddělit pouze stabilní kontrakty nebo samostatně vlastněné části.

## 16.3 Vše je ve stavu Draft

Není jasné, co již bylo skutečně rozhodnuto a co je jen návrh.

**Náprava:** po každé tematické fázi provést review a změnit stav na `APPROVED` nebo `IMPLEMENTATION_READY`.

## 16.4 Otevřené otázky bez centrální evidence

Jednotlivé dokumenty obsahují mnoho otevřených otázek.

**Náprava:** vytvořit později centrální `docs/OPEN_DECISIONS.md` nebo převést skutečná rozhodnutí do ADR. Tento soubor má vzniknout až při prvním konsolidačním review.

## 16.5 Neověřené externí možnosti

Doménový model předpokládá široké integrace a wearables schopnosti, ale dostupnost API se může lišit.

**Náprava:** capability audit každého poskytovatele před finálním potvrzením funkcí.

## 16.6 Medicínská a právní rizika

Recovery, pain, health data a minors vyžadují odborné a právní ověření.

**Náprava:** označit příslušné části jako `EXPERT_REVIEW_REQUIRED`, dokud neproběhne odborná kontrola.

---

# 17. Připravenost jednotlivých oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Vize | vysoká | nevztahuje se přímo | konsistenční review |
| Produktové principy | vysoká | střední | přidat ID principů |
| Product scope | vysoká | nízká | funkční a nefunkční požadavky |
| Persony a scénáře | vysoká | střední | ID a traceability |
| UX architektura | vysoká | střední | routes, states, acceptance criteria |
| Design system | nízká | nízká | vytvořit hlavní design-system specifikaci |
| Doménový model | velmi vysoká | střední | invariance, glossary, consistency review |
| Backend | nízká | nízká | backend architecture |
| Mobile | nízká | nízká | mobile architecture |
| AI runtime | střední na doménové úrovni | nízká | AI architecture a tool contracts |
| Integrace | střední na obecné úrovni | nízká | capability matrix a provider specs |
| Security | nízká až střední | nízká | security architecture a threat model |
| Data | nízká | nízká | data architecture a physical models |
| API | nízká | nízká | API principles a contracts |
| Quality | nízká | nízká | quality strategy |
| DevOps | nízká | nízká | environment a deployment architecture |
| Release | nízká | nízká | release strategy |
| Operations | nízká | nízká | SLO a runbooks |
| Implementation guidance | nízká | nízká | až po dokončení architektur a kontraktů |

---

# 18. Odhad skutečného budoucího rozsahu

Audit nepotvrzuje potřebu 350–400 ručně psaných dokumentů.

Realističtější cílový rozsah je přibližně:

- **60–100 hlavních dokumentů**, pokud budou příbuzná témata rozumně seskupena,
- plus ADR, provider-specific kontrakty, schémata a runbooky vznikající podle skutečné potřeby.

Přesné číslo není cílem. Cílem je úplnost bez duplicit.

Dokumentace je úplná tehdy, když lze každé důležité produktové a technické rozhodnutí:

- najít,
- jednoznačně interpretovat,
- implementovat,
- otestovat,
- provozovat,
- bezpečně změnit.

---

# 19. Bezprostředně následující soubor

Po tomto auditu má následovat:

```text
docs/06-domain/domain-invariants.md
```

Jeho úkolem bude konsolidovat pouze globální a cross-domain invariance. Nebude kopírovat celé seznamy pravidel z jednotlivých doménových modelů.

Poté:

```text
docs/06-domain/glossary.md
```

A následně bude aktualizován:

```text
docs/README.md
```

podle skutečné, auditované struktury.

---

# 20. Závěr

Projekt již má mimořádně rozsáhlou produktovou, UX a doménovou základnu. Největší hodnotu nyní nepřinese další obecné rozepisování stejné vize, ale:

1. konsolidace pravidel,
2. stabilizace názvosloví,
3. převod rozsahu na testovatelné požadavky,
4. návrh konkrétních technických architektur,
5. tvorba verzovaných kontraktů,
6. definice bezpečnosti, kvality a provozu,
7. příprava přesných instrukcí pro implementaci.

Tento dokument se má aktualizovat po dokončení každé větší dokumentační fáze. Jeho seznam souborů a stavů musí vždy vycházet ze skutečného repozitáře, nikoli pouze z původního plánu.