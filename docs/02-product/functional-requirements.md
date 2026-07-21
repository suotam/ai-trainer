# AI Trainer – Functional Requirements

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/02-product/functional-requirements.md`  
**Vlastník:** Product Architecture  
**Poslední aktualizace:** 2026-07-21  
**Navazuje na:** `vision.md`, `product-principles.md`, `product-scope.md`, user scenarios, UX specifications a všechny doménové modely  
**Navazující dokumenty:** non-functional requirements, release scope, traceability matrix, API, architecture, acceptance criteria

---

# 1. Účel dokumentu

Tento dokument převádí cílový rozsah AI Traineru na jednoznačně identifikovatelné a testovatelné funkční požadavky.

Každý požadavek popisuje, **co musí systém umožnit nebo zajistit**. Neurčuje konkrétní technologii, databázi, framework ani implementační detail, pokud není daný detail součástí pozorovatelného produktového chování.

Dokument je hlavním produktovým registrem požadavků pro:

- UX,
- doménový model,
- backend,
- mobilní aplikaci,
- AI runtime,
- API,
- testování,
- roadmapu,
- implementační plán.

---

# 2. Pravidla funkčních požadavků

## 2.1 Identifikace

Každý požadavek má stabilní identifikátor `FR-xxx`.

Identifikátor se nesmí recyklovat pro jiný význam. Zrušený požadavek zůstane evidovaný jako deprecated nebo removed.

## 2.2 Priorita

- **CORE** – nutné pro základní hodnotu produktu.
- **IMPORTANT** – významná cílová schopnost, která může být etapizována.
- **ADVANCED** – pokročilá cílová schopnost.
- **FUTURE** – potvrzený dlouhodobý směr, nikoli závazek první verze.

Priorita neříká přesné release zařazení. To určí samostatná roadmapa a release-scope dokument.

## 2.3 Ověřitelnost

Požadavek je splněný pouze tehdy, pokud lze jeho chování ověřit:

- automatickým testem,
- integračním testem,
- UX acceptance testem,
- bezpečnostním testem,
- nebo explicitním odborným review.

## 2.4 Terminologie

Kanonické názvy pocházejí z `docs/06-domain/glossary.md`.

## 2.5 Autorita

Požadavek nesmí obejít:

- produktové principy,
- globální invariance,
- detailní doménová pravidla,
- bezpečnostní a právní omezení.

---

# 3. Účet, identita a přístup

## FR-001 – Vytvoření účtu

**Priorita:** CORE  
Systém musí umožnit uživateli vytvořit UserAccount pomocí podporované AuthenticationIdentity.

## FR-002 – Přihlášení

**Priorita:** CORE  
Systém musí umožnit ověřenému uživateli bezpečně se přihlásit a navázat autorizovanou session.

## FR-003 – Odhlášení

**Priorita:** CORE  
Uživatel musí mít možnost ukončit aktuální session.

## FR-004 – Správa aktivních sessions

**Priorita:** IMPORTANT  
Uživatel musí mít možnost zobrazit a ukončit své aktivní sessions na dalších zařízeních.

## FR-005 – Obnova přístupu

**Priorita:** CORE  
Systém musí poskytovat bezpečný podporovaný proces obnovy přístupu k účtu.

## FR-006 – Propojení autentizačních metod

**Priorita:** ADVANCED  
Uživatel musí mít možnost bezpečně připojit další podporovanou AuthenticationIdentity ke stejné Identity.

## FR-007 – Anonymní použití

**Priorita:** IMPORTANT  
Pokud bude anonymní režim v release scope povolen, uživatel musí mít možnost používat podporovanou podmnožinu funkcí bez plné registrace.

## FR-008 – Upgrade anonymního účtu

**Priorita:** IMPORTANT  
Systém musí převést anonymní účet na registrovaný bez ztráty podporovaných lokálních a synchronizovaných dat.

## FR-009 – Pozastavení a omezení účtu

**Priorita:** CORE  
Systém musí vynucovat stav účtu a zabránit zakázaným operacím u suspended, locked nebo deletion-pending účtu.

## FR-010 – Více zařízení

**Priorita:** CORE  
Uživatel musí mít možnost používat svůj účet na více podporovaných zařízeních při zachování konzistentních dat a oprávnění.

---

# 4. AthleteProfile a onboarding

## FR-011 – Vytvoření AthleteProfile

**Priorita:** CORE  
Systém musí vytvořit AthleteProfile osoby, pro kterou se plánuje a vyhodnocuje trénink.

## FR-012 – Postupný onboarding

**Priorita:** CORE  
Onboarding musí být možné dokončovat postupně bez povinného vyplnění všech nepovinných údajů v jednom průchodu.

## FR-013 – Přerušení a obnovení onboardingu

**Priorita:** CORE  
Uživatel musí mít možnost onboarding přerušit a pokračovat na stejném nebo jiném zařízení.

## FR-014 – Adaptivní onboarding

**Priorita:** IMPORTANT  
Systém musí přizpůsobit otázky známému sportovnímu kontextu a nevyžadovat nesouvisející údaje.

## FR-015 – Ruční úprava profilu

**Priorita:** CORE  
Uživatel musí mít možnost zobrazit a upravit podporované části AthleteProfile standardním rozhraním bez použití AI chatu.

## FR-016 – Profilová úplnost

**Priorita:** IMPORTANT  
Systém musí určit, zda je profil dostatečný pro konkrétní funkci, a vysvětlit chybějící potřebné údaje.

## FR-017 – Historie významných změn profilu

**Priorita:** IMPORTANT  
Významné změny profilu musí být dohledatelné pomocí AthleteProfileRevision nebo ekvivalentní historie.

## FR-018 – Nastavení jednotek

**Priorita:** CORE  
Uživatel musí mít možnost zvolit podporované jednotky zobrazení bez destruktivní změny kanonických dat.

## FR-019 – Jazyk a locale

**Priorita:** CORE  
Uživatel musí mít možnost používat podporovaný jazyk a locale formáty.

## FR-020 – Časové pásmo

**Priorita:** CORE  
Systém musí spravovat domovské a aktuální časové pásmo tak, aby plán, historie a notifikace zůstaly správně interpretovatelné.

## FR-021 – Preference AI komunikace

**Priorita:** IMPORTANT  
Uživatel musí mít možnost nastavit podporovaný styl, délku a míru proaktivity AI komunikace.

## FR-022 – Accessibility preference

**Priorita:** IMPORTANT  
Aplikace musí respektovat podporované accessibility preference a systémová accessibility nastavení.

## FR-023 – Více profilů

**Priorita:** FUTURE  
Architektura musí umožnit budoucí bezpečnou správu více AthleteProfile pod jedním oprávněným účtem.

---

# 5. Sportovní profil

## FR-024 – Přidání sportu

**Priorita:** CORE  
Uživatel musí mít možnost přidat jeden nebo více UserSport.

## FR-025 – Vlastní sport

**Priorita:** IMPORTANT  
Uživatel musí mít možnost zadat sport, který není v systémovém katalogu, bez ztráty schopnosti plánování na obecné úrovni.

## FR-026 – Sportovní zkušenost

**Priorita:** CORE  
Uživatel musí mít možnost zaznamenat historickou zkušenost a aktuální úroveň nebo kapacitu pro jednotlivé sporty.

## FR-027 – Pravidelnost a participation pattern

**Priorita:** CORE  
Uživatel musí mít možnost zaznamenat obvyklou pravidelnost, dny, sezónnost, soutěže a další ParticipationPattern.

## FR-028 – Priority sportů

**Priorita:** CORE  
Uživatel musí mít možnost určit relativní prioritu sportů a tuto prioritu později změnit.

## FR-029 – Pozastavení sportu

**Priorita:** IMPORTANT  
Uživatel musí mít možnost sport dočasně pozastavit bez smazání historických dat.

## FR-030 – Společný multisportovní kontext

**Priorita:** CORE  
Plánování a vyhodnocení musí zohledňovat všechny relevantní sporty jako jeden společný systém zátěže, nikoli izolované plány.

---

# 6. Cíle

## FR-031 – Vytvoření cíle

**Priorita:** CORE  
Uživatel musí mít možnost vytvořit Goal s typem, prioritou a podporovanými cílovými údaji.

## FR-032 – Typy cílů

**Priorita:** CORE  
Systém musí podporovat minimálně výkonové, silové, vytrvalostní, mobilitní, návykové, událostní a návratové cíle prostřednictvím rozšiřitelného modelu.

## FR-033 – Termín a milníky

**Priorita:** IMPORTANT  
Goal musí podle typu podporovat termín a Milestone.

## FR-034 – Metriky cíle

**Priorita:** CORE  
Goal musí být možné propojit s podporovanými MetricDefinition a cílovými hodnotami.

## FR-035 – Priority cílů

**Priorita:** CORE  
Uživatel musí mít možnost měnit prioritu cílů.

## FR-036 – Konflikty cílů

**Priorita:** IMPORTANT  
Systém musí detekovat významné konflikty mezi cíli a umožnit jejich vědomé řešení.

## FR-037 – Stav cíle

**Priorita:** CORE  
Goal musí podporovat životní cyklus minimálně draft, active, paused, completed, abandoned a archived podle doménového modelu.

## FR-038 – Progres cíle

**Priorita:** CORE  
Systém musí zobrazit doložitelný GoalProgress založený na relevantních aktivitách, metrikách a milnících.

## FR-039 – Vysvětlení progresu

**Priorita:** IMPORTANT  
Uživatel musí být schopen zjistit, z jakých dat a výpočtů je progres odvozen.

---

# 7. Dostupnost, prostředí a vybavení

## FR-040 – Typický týden

**Priorita:** CORE  
Uživatel musí mít možnost definovat TypicalWeekProfile a obvyklá časová okna.

## FR-041 – Jednorázová dostupnost

**Priorita:** CORE  
Uživatel musí mít možnost zadat jednorázovou změnu dostupnosti bez přepsání dlouhodobého vzorce.

## FR-042 – Pevná a flexibilní okna

**Priorita:** CORE  
Systém musí rozlišit pevná, preferovaná, možná a nedostupná časová okna.

## FR-043 – Tréninkové prostředí

**Priorita:** CORE  
Uživatel musí mít možnost spravovat TrainingEnvironment a jeho relevantní omezení.

## FR-044 – Vybavení

**Priorita:** CORE  
Uživatel musí mít možnost spravovat EquipmentProfile včetně dostupnosti podle místa nebo času.

## FR-045 – Dočasné prostředí a vybavení

**Priorita:** IMPORTANT  
Systém musí podporovat dočasné prostředí nebo vybavení s časovou platností, například při cestování.

## FR-046 – Tréninkové preference

**Priorita:** CORE  
Uživatel musí mít možnost zadat preference délky, času, stylu, variability a dalších podporovaných vlastností workoutu.

## FR-047 – Síla preference

**Priorita:** IMPORTANT  
Systém musí rozlišit tvrdé omezení od měkké preference a nesmí preference zaměnit za bezpečnostní pravidlo.

---

# 8. TrainingPlan

## FR-048 – Vytvoření návrhu plánu

**Priorita:** CORE  
Systém musí vytvořit návrh TrainingPlan z cílů, sportů, dostupnosti, vybavení, zkušenosti, omezení, preferencí a relevantní historie.

## FR-049 – Zobrazení vysvětlení plánu

**Priorita:** CORE  
Uživatel musí být schopen zjistit, proč je plán strukturován daným způsobem.

## FR-050 – Potvrzení aktivace plánu

**Priorita:** CORE  
Významný nový plán nebo zásadní nová verze musí být před aktivací potvrzena podle ConfirmationPolicy.

## FR-051 – Verze plánu

**Priorita:** CORE  
Každá významná změna aktivního TrainingPlan musí vytvořit dohledatelnou TrainingPlanVersion.

## FR-052 – Tréninkové bloky a týdny

**Priorita:** CORE  
TrainingPlan musí podporovat strukturu plánovacích období, TrainingBlock, TrainingWeek a jednotlivých plánovaných položek.

## FR-053 – Více typů položek plánu

**Priorita:** CORE  
Plán musí podporovat workouty, sportovní aktivity, regenerační jednotky, testy a odpočinek.

## FR-054 – Úprava plánu

**Priorita:** CORE  
Uživatel musí mít možnost navrhnout nebo provést podporovanou změnu plánu standardním rozhraním i prostřednictvím AI Proposal.

## FR-055 – Pozastavení a obnovení plánu

**Priorita:** CORE  
Uživatel musí mít možnost TrainingPlan pozastavit a bezpečně obnovit.

## FR-056 – Regenerace plánu

**Priorita:** IMPORTANT  
Systém musí umět připravit nový návrh zbývající části plánu při zásadní změně vstupů.

## FR-057 – Zachování historie plánu

**Priorita:** CORE  
Změna aktivního plánu nesmí odstranit historické verze ani změnit historickou skutečnost.

## FR-058 – Posouzení proveditelnosti

**Priorita:** CORE  
Před aktivací musí systém validovat časovou, bezpečnostní a základní objemovou proveditelnost plánu.

---

# 9. Kalendář a scheduling

## FR-059 – Interní sportovní kalendář

**Priorita:** CORE  
Aplikace musí zobrazovat ScheduleEvent v denním, týdenním a dalším podporovaném přehledu.

## FR-060 – Typy kalendářních událostí

**Priorita:** CORE  
Kalendář musí podporovat plánované workouty, tréninky, zápasy, závody, regenerační aktivity, odpočinek a další sportovně relevantní události.

## FR-061 – Pevnost události

**Priorita:** CORE  
ScheduleEvent musí rozlišovat pevnou a flexibilní událost.

## FR-062 – Vytvoření a úprava události

**Priorita:** CORE  
Uživatel musí mít možnost vytvořit a upravit podporovanou ScheduleEvent.

## FR-063 – Přesunutí události

**Priorita:** CORE  
Uživatel musí mít možnost přesunout podporovanou událost a zobrazit dopad na související plán.

## FR-064 – Opakované události

**Priorita:** CORE  
Systém musí podporovat opakování a změny jednoho výskytu, celé série nebo budoucí části série.

## FR-065 – Konflikty

**Priorita:** CORE  
Systém musí detekovat relevantní časové a tréninkové konflikty a umožnit jejich řešení.

## FR-066 – Zrušení a vynechání

**Priorita:** CORE  
Uživatel musí mít možnost událost zrušit nebo označit jako vynechanou bez smazání auditovatelné historie.

## FR-067 – Vztah plánu a kalendáře

**Priorita:** CORE  
ScheduleEvent vytvořená z plánu musí zachovat vazbu na správnou TrainingPlanVersion a WorkoutInstanceRevision.

## FR-068 – Správné časové pásmo a DST

**Priorita:** CORE  
Kalendář musí správně interpretovat absolutní i lokální čas při cestování a změnách letního času.

---

# 10. Workout definice a příprava

## FR-069 – Podpora různých workoutů

**Priorita:** CORE  
Systém musí podporovat workouty založené na sériích, opakováních, čase, vzdálenosti, intervalech, okruzích a kombinovaných krocích prostřednictvím rozšiřitelného modelu.

## FR-070 – Warm-up, hlavní část a cooldown

**Priorita:** CORE  
Workout musí umožnit strukturovat přípravu, hlavní část a závěr bez povinnosti používat vždy všechny části.

## FR-071 – WorkoutTemplate

**Priorita:** IMPORTANT  
Systém musí umožnit opakovaně používat WorkoutTemplate bez změny historie již materializovaných workoutů.

## FR-072 – WorkoutInstance

**Priorita:** CORE  
Pro konkrétní plánované provedení musí systém vytvořit WorkoutInstance s vlastní revizí.

## FR-073 – Úprava budoucího workoutu

**Priorita:** CORE  
Uživatel nebo autorizovaný návrh musí být schopen upravit budoucí WorkoutInstance při zachování historie revizí.

## FR-074 – Substituce cviku nebo kroku

**Priorita:** CORE  
Systém musí umožnit bezpečnou substituci podporovaného workout kroku a zobrazit důvod změny.

## FR-075 – Zkrácení workoutu

**Priorita:** CORE  
Uživatel musí mít možnost zkrátit workout před nebo během session a zachovat informaci o původní a provedené variantě.

## FR-076 – Připravenost pro zařízení

**Priorita:** ADVANCED  
Workout musí být možné převést do bezpečného, verzovaného kontraktu pro podporované watch nebo wearable klienty.

---

# 11. WorkoutSession a tracker

## FR-077 – Spuštění workoutu

**Priorita:** CORE  
Uživatel musí mít možnost spustit WorkoutSession z aktuální WorkoutInstanceRevision.

## FR-078 – Zobrazení kroků

**Priorita:** CORE  
Tracker musí zobrazovat aktuální a následující kroky s relevantními instrukcemi a cíli.

## FR-079 – Záznam výkonu

**Priorita:** CORE  
Uživatel musí mít možnost zapisovat podporované hodnoty, například série, opakování, váhu, čas, vzdálenost, tempo a subjektivní náročnost.

## FR-080 – Časovače

**Priorita:** CORE  
Tracker musí podporovat potřebné rest, interval a duration časovače a správně se obnovit po běžné změně lifecycle aplikace.

## FR-081 – Pauza a obnovení session

**Priorita:** CORE  
Uživatel musí mít možnost WorkoutSession pozastavit a obnovit.

## FR-082 – Vynechání kroku

**Priorita:** CORE  
Uživatel musí mít možnost vynechat krok nebo cvik s volitelným důvodem.

## FR-083 – Úprava během session

**Priorita:** CORE  
Uživatel musí mít možnost provést podporovanou substituci nebo změnu objemu během session bez změny původní WorkoutInstanceRevision.

## FR-084 – Dokončení session

**Priorita:** CORE  
Uživatel musí mít možnost session dokončit jako complete nebo partial a zadat podporovanou závěrečnou zpětnou vazbu.

## FR-085 – Opuštění session

**Priorita:** CORE  
Uživatel musí mít možnost session vědomě opustit bez nejasné ztráty již zaznamenaných dat.

## FR-086 – Obnova rozpracované session

**Priorita:** CORE  
Po pádu, restartu aplikace nebo zařízení musí být možné bezpečně obnovit poslední lokálně uložený konzistentní stav aktivní WorkoutSession.

## FR-087 – Vznik Activity z workoutu

**Priorita:** CORE  
Dokončená nebo částečně dokončená WorkoutSession musí vytvořit nebo aktualizovat odpovídající Activity bez duplikace.

---

# 12. Activity a historie

## FR-088 – Ruční vytvoření aktivity

**Priorita:** CORE  
Uživatel musí mít možnost ručně zaznamenat Activity bez existence plánovaného workoutu.

## FR-089 – Historie aktivit

**Priorita:** CORE  
Uživatel musí mít možnost procházet historii Activity a zobrazit relevantní detail.

## FR-090 – Vztah plánu a skutečnosti

**Priorita:** CORE  
Systém musí zobrazit rozdíl mezi plánovanou položkou a skutečně provedenou Activity.

## FR-091 – Oprava aktivity

**Priorita:** CORE  
Uživatel musí mít možnost opravit podporované údaje Activity při zachování auditovatelné historie opravy.

## FR-092 – Smazání nebo invalidace aktivity

**Priorita:** CORE  
Uživatel musí mít možnost odstranit nebo invalidovat Activity podle retention a audit pravidel.

## FR-093 – Párování aktivity

**Priorita:** IMPORTANT  
Systém musí být schopen navrhnout propojení Activity s plánovanou událostí nebo workoutem a umožnit uživateli návrh potvrdit nebo odmítnout.

## FR-094 – Deduplikace

**Priorita:** CORE  
Systém musí detekovat potenciálně duplicitní Activity z více zdrojů a nesmí je automaticky započítat vícekrát bez rozhodnutí podle doménových pravidel.

## FR-095 – Sloučení a oddělení aktivit

**Priorita:** ADVANCED  
Uživatel musí mít možnost v podporovaných situacích sloučit nebo znovu oddělit aktivity s přepočtem odvozených dat.

## FR-096 – GPS záznam

**Priorita:** ADVANCED  
Aplikace musí v cílové verzi umožnit podporovaný GPS záznam aktivity včetně pauzy, obnovení a bezpečného dokončení.

## FR-097 – Zobrazení trasy

**Priorita:** ADVANCED  
U podporované GPS Activity musí uživatel mít možnost zobrazit trasu při respektování privacy preference.

---

# 13. Recovery, check-in a omezení

## FR-098 – DailyCheckIn

**Priorita:** CORE  
Uživatel musí mít možnost rychle zaznamenat podporované subjektivní recovery údaje.

## FR-099 – Záznam spánku

**Priorita:** IMPORTANT  
Systém musí umožnit ručně nebo z autorizovaného zdroje zaznamenat podporované údaje o spánku.

## FR-100 – ReadinessAssessment

**Priorita:** CORE  
Systém musí vytvořit vysvětlitelné readiness posouzení z dostupných vstupů a uvést nejistotu při neúplných datech.

## FR-101 – PainReport

**Priorita:** CORE  
Uživatel musí mít možnost nahlásit bolest včetně relevantního místa, charakteru, intenzity, času a kontextu.

## FR-102 – Bezpečnostní reakce na bolest

**Priorita:** CORE  
Systém musí před pokračováním v rizikové aktivitě vyhodnotit PainReport deterministickými safety pravidly a podle výsledku doporučit, upravit nebo zablokovat akci.

## FR-103 – Limitation

**Priorita:** CORE  
Uživatel nebo jiný oprávněný aktér musí mít možnost vytvořit, aktualizovat a ukončit Limitation v povoleném scope.

## FR-104 – Aplikace aktivního omezení

**Priorita:** CORE  
Aktivní Limitation nebo SafetyRestriction musí ovlivnit návrhy a validaci relevantních workoutů a plánů.

## FR-105 – Odborné doporučení

**Priorita:** IMPORTANT  
Uživatel musí mít možnost zaznamenat ProfessionalRecommendation bez toho, aby AI měnila jeho význam.

## FR-106 – ReturnToActivityPlan

**Priorita:** ADVANCED  
Systém musí umožnit podporovaný fázový návrat k aktivitě při respektování aktivních omezení a odborných doporučení.

## FR-107 – Bez diagnostiky

**Priorita:** CORE  
AI Trainer nesmí prezentovat PainAssessment, ReadinessAssessment nebo jiné výstupy jako lékařskou diagnózu.

---

# 14. AI komunikace a návrhy

## FR-108 – AI konverzace

**Priorita:** CORE  
Uživatel musí mít možnost komunikovat s AI trenérem v kontextu svého oprávněného AthleteProfile.

## FR-109 – Kontextová odpověď

**Priorita:** CORE  
AI odpověď musí využívat pouze autorizovaný, relevantní a aktuální strukturovaný kontext.

## FR-110 – Přiznání nejistoty

**Priorita:** CORE  
Pokud chybí podstatná data nebo je interpretace nejistá, AI musí nejistotu uvést a případně si vyžádat doplnění.

## FR-111 – Standardní rozhraní jako alternativa

**Priorita:** CORE  
Každá základní produktová funkce musí být dostupná také bez nutnosti formulovat požadavek v AI chatu.

## FR-112 – AIProposal

**Priorita:** CORE  
AI nesmí přímo měnit doménová data; musí vytvořit strukturovaný AIProposal nebo jiný autorizovaný návrh.

## FR-113 – Zobrazení dopadu návrhu

**Priorita:** CORE  
Před schválením musí uživatel vidět, co se změní, proč, na základě jakých dat a s jakým očekávaným dopadem.

## FR-114 – Částečné schválení

**Priorita:** IMPORTANT  
U změny s více nezávislými operacemi musí být možné podle pravidel schválit pouze podporovanou část.

## FR-115 – Odmítnutí a úprava návrhu

**Priorita:** CORE  
Uživatel musí mít možnost AIProposal odmítnout nebo požádat o jeho úpravu.

## FR-116 – Detekce stale návrhu

**Priorita:** CORE  
Systém musí označit návrh jako stale, pokud se relevantní kontext změnil před jeho aplikací.

## FR-117 – Undo a kompenzace

**Priorita:** IMPORTANT  
U podporovaných změn musí systém nabídnout bezpečné vrácení nebo kompenzaci bez přepisování historie.

## FR-118 – Audit AI akce

**Priorita:** CORE  
Musí být dohledatelné, jaký autorizovaný AI návrh, potvrzení a ChangeSet vedly ke změně.

## FR-119 – Bezpečnostní odmítnutí

**Priorita:** CORE  
AI a tool vrstva musí odmítnout požadavek porušující oprávnění, invariance nebo safety pravidla a srozumitelně vysvětlit důvod.

---

# 15. Adaptace plánu

## FR-120 – Reakce na vynechaný workout

**Priorita:** CORE  
Systém musí umět posoudit dopad vynechaného workoutu a navrhnout žádnou změnu, přesun, náhradu nebo úpravu dalšího plánu.

## FR-121 – Reakce na únavu a readiness

**Priorita:** CORE  
Systém musí umět navrhnout přiměřenou změnu dnešního nebo budoucího plánu podle aktuálního recovery kontextu.

## FR-122 – Reakce na bolest nebo omezení

**Priorita:** CORE  
Systém musí okamžitě přehodnotit relevantní budoucí workouty při aktivaci významného PainReport, Limitation nebo SafetyRestriction.

## FR-123 – Reakce na změnu rozvrhu

**Priorita:** CORE  
Systém musí umožnit převést změnu dostupnosti na konkrétní návrh úprav plánu a kalendáře.

## FR-124 – Reakce na cestování

**Priorita:** IMPORTANT  
Systém musí umět navrhnout dočasnou adaptaci podle času, prostředí, vybavení a časového pásma cesty.

## FR-125 – Reakce na změnu cíle

**Priorita:** CORE  
Změna Goal musí spustit posouzení dopadu na aktivní TrainingPlan a případný nový návrh, nikoli skryté přepsání plánu.

## FR-126 – Konzervativní chování při nejistotě

**Priorita:** CORE  
Při významné nejistotě musí systém preferovat bezpečnější variantu nebo vyžádat doplnění před zásadním navýšením zátěže.

---

# 16. Metriky, progres a analýzy

## FR-127 – Záznam metrik

**Priorita:** CORE  
Systém musí ukládat MetricValue s definicí, jednotkou, časem a provenance.

## FR-128 – Importované a ruční metriky

**Priorita:** CORE  
Systém musí rozlišovat ručně zadané, importované a odvozené hodnoty.

## FR-129 – Agregace

**Priorita:** CORE  
Systém musí vypočítat podporované MetricAggregate z validních vstupů pomocí verzované metody.

## FR-130 – Trend a baseline

**Priorita:** IMPORTANT  
U podporovaných metrik musí systém zobrazit baseline a trend včetně dostatečnosti vstupních dat.

## FR-131 – Personal record

**Priorita:** IMPORTANT  
Systém musí detekovat a potvrdit PersonalRecord pouze z validních a neduplicitních dat.

## FR-132 – Přepočet po opravě

**Priorita:** CORE  
Oprava, invalidace, merge nebo deletion relevantního zdroje musí invalidovat a přepočítat závislé metriky.

## FR-133 – Praktické statistiky

**Priorita:** CORE  
Aplikace musí zobrazovat statistiky s jasným praktickým významem, například adherenci, objem, intenzitu, progres a vztah plánu ke skutečnosti.

## FR-134 – Vysvětlitelnost výpočtu

**Priorita:** IMPORTANT  
Uživatel musí být schopen zobrazit srozumitelné vysvětlení zdroje a významu podporované metriky.

---

# 17. Integrace a importy

## FR-135 – Připojení integrace

**Priorita:** IMPORTANT  
Uživatel musí mít možnost připojit podporovanou UserIntegrationConnection prostřednictvím bezpečného autorizačního flow.

## FR-136 – Volba oprávnění

**Priorita:** CORE  
Uživatel musí být informován o požadovaných oprávněních a účelu dat před jejich udělením.

## FR-137 – Odpojení integrace

**Priorita:** CORE  
Uživatel musí mít možnost integraci odpojit a zneplatnit budoucí přístup podle možností provideru.

## FR-138 – Import Activity a MetricValue

**Priorita:** IMPORTANT  
Systém musí normalizovat podporovaná externí data do interních objektů při zachování lineage.

## FR-139 – Historický backfill

**Priorita:** ADVANCED  
U podporovaných providerů musí být možné importovat povolenou historickou část dat bez nekontrolované duplikace.

## FR-140 – Reconciliation

**Priorita:** IMPORTANT  
Systém musí umět porovnat lokální stav s providerem a opravit detekované nesrovnalosti podle definované policy.

## FR-141 – Reautentizace

**Priorita:** IMPORTANT  
Při expiraci nebo odebrání oprávnění musí systém informovat uživatele a umožnit bezpečnou reautentizaci.

## FR-142 – Provider health

**Priorita:** IMPORTANT  
Systém musí zobrazit stav integrace a rozlišit synchronizováno, zpožděno, omezeno a chyba vyžadující zásah.

## FR-143 – Externí kalendář

**Priorita:** ADVANCED  
U podporovaných providerů musí uživatel mít možnost zvolit export ScheduleEvent a případný omezený import availability nebo busy intervalů.

## FR-144 – Minimalizace přístupu ke kalendáři

**Priorita:** CORE  
Systém nesmí číst více externích kalendářních dat, než je nutné pro uživatelem povolenou funkci.

---

# 18. Offline a synchronizace

## FR-145 – Offline zobrazení dnešního plánu

**Priorita:** CORE  
Uživatel musí mít bez internetu přístup k lokálně synchronizovanému dnešnímu plánu a relevantním detailům.

## FR-146 – Offline WorkoutSession

**Priorita:** CORE  
Uživatel musí mít možnost bez internetu spustit, zaznamenat a dokončit lokálně dostupnou WorkoutSession.

## FR-147 – Offline Activity

**Priorita:** CORE  
Uživatel musí mít možnost vytvořit podporovanou Activity bez internetu a později ji synchronizovat.

## FR-148 – Offline recovery a PainReport

**Priorita:** CORE  
Uživatel musí mít možnost offline zaznamenat DailyCheckIn a PainReport a aplikace musí použít lokálně dostupná safety pravidla.

## FR-149 – Fronta změn

**Priorita:** CORE  
Offline změny musí být uloženy v trvalé frontě a nesmí se ztratit při běžném restartu aplikace nebo zařízení.

## FR-150 – Automatická synchronizace

**Priorita:** CORE  
Po obnovení konektivity musí systém automaticky synchronizovat čekající změny podle retry a priority pravidel.

## FR-151 – Stav synchronizace

**Priorita:** CORE  
Uživatel musí vidět, zda jsou data lokální, čekající, synchronizovaná, blokovaná nebo v konfliktu.

## FR-152 – Idempotence

**Priorita:** CORE  
Opakované odeslání stejné změny nesmí vytvořit duplicitní doménový efekt.

## FR-153 – Konflikty

**Priorita:** CORE  
Systém musí automaticky sloučit bezpečně slučitelné změny a zobrazit uživateli konflikty vyžadující rozhodnutí.

## FR-154 – Tombstones a deletion sync

**Priorita:** CORE  
Smazání nebo invalidace musí být synchronizovány tak, aby se odstraněný objekt neobnovil ze starého zařízení.

## FR-155 – Full resync

**Priorita:** IMPORTANT  
Systém musí poskytovat bezpečný proces úplné obnovy lokálního stavu bez ztráty nepotvrzených lokálních změn.

## FR-156 – Revokované zařízení

**Priorita:** CORE  
Revokované zařízení nesmí po připojení pokračovat v autorizované synchronizaci.

---

# 19. Notifikace

## FR-157 – Workout reminder

**Priorita:** CORE  
Uživatel musí mít možnost povolit připomenutí plánovaného workoutu.

## FR-158 – AI proposal reminder

**Priorita:** IMPORTANT  
Systém může upozornit na významný čekající AIProposal podle notifikačních preferencí.

## FR-159 – Recovery a safety notifikace

**Priorita:** IMPORTANT  
Systém musí umět upozornit na relevantní recovery nebo safety stav bez zavádějícího zdravotního tvrzení.

## FR-160 – Týdenní shrnutí

**Priorita:** IMPORTANT  
Uživatel musí mít možnost dostávat srozumitelné týdenní shrnutí plánu, skutečnosti a progresu.

## FR-161 – Správa notifikací

**Priorita:** CORE  
Uživatel musí mít kontrolu nad typy, kanály, frekvencí a quiet hours notifikací.

## FR-162 – Aktuálnost reminderu

**Priorita:** CORE  
Systém nesmí odeslat zastaralý reminder pro zrušenou nebo přesunutou událost.

---

# 20. Privacy, souhlasy a data

## FR-163 – Zobrazení privacy preference

**Priorita:** CORE  
Uživatel musí mít možnost zobrazit a měnit podporované privacy preference.

## FR-164 – DataProcessingConsent

**Priorita:** CORE  
Systém musí auditovat udělení a odvolání souhlasu pro konkrétní účel a verzi.

## FR-165 – Odvolání souhlasu

**Priorita:** CORE  
Odvolání souhlasu musí zastavit příslušné budoucí zpracování a srozumitelně uvést dopad na funkce.

## FR-166 – Minimalizace AI dat

**Priorita:** CORE  
AI runtime musí obdržet pouze data potřebná pro autorizovaný účel a scope.

## FR-167 – Export dat

**Priorita:** CORE  
Uživatel musí mít možnost požádat o bezpečný export podporovaných osobních a sportovních dat ve srozumitelném a strojově čitelném formátu.

## FR-168 – Smazání účtu

**Priorita:** CORE  
Uživatel musí mít možnost požádat o smazání účtu, sledovat stav a být informován o případných retenčních výjimkách.

## FR-169 – Propagace smazání

**Priorita:** CORE  
Smazání musí být bezpečně promítnuto do backendu, projekcí, lokálních zařízení, integrací a relevantních eventových dat podle retention policy.

## FR-170 – GPS privacy

**Priorita:** CORE  
Uživatel musí mít kontrolu nad ukládáním a sdílením location-related dat a GPS tras.

---

# 21. Role, coach a managed profiles

## FR-171 – Coach invitation

**Priorita:** FUTURE  
Uživatel musí mít možnost přijmout nebo odmítnout pozvánku trenéra k definovanému AthleteProfile.

## FR-172 – CoachPermissionScope

**Priorita:** FUTURE  
Přístup trenéra musí být omezen explicitním scope a nesmí automaticky zahrnovat všechna citlivá data.

## FR-173 – Revokace trenéra

**Priorita:** FUTURE  
Sportovec musí mít možnost trenérský vztah ukončit s okamžitým zastavením budoucího přístupu.

## FR-174 – Trenérské návrhy

**Priorita:** FUTURE  
Trenér musí podle oprávnění vytvářet návrhy nebo přímé změny pouze v povoleném scope a s auditem.

## FR-175 – Guardian relationship

**Priorita:** FUTURE / EXPERT_REVIEW_REQUIRED  
Systém musí umožnit právně validní správu profilu nezletilého pouze podle schválené jurisdikční policy.

---

# 22. Audit, historie a vysvětlitelnost

## FR-176 – Audit významné změny

**Priorita:** CORE  
Každá významná změna musí být dohledatelná podle aktéra, času, zdroje, důvodu a výsledku.

## FR-177 – Historie verzí

**Priorita:** CORE  
Uživatel musí mít u podporovaných objektů možnost rozlišit současný stav od historických verzí a skutečně provedených událostí.

## FR-178 – Zdroj dat

**Priorita:** CORE  
U relevantních dat musí být možné určit provenance, například user, device, integration, coach, AI structured input nebo system derived.

## FR-179 – Oprava bez přepsání historie

**Priorita:** CORE  
Oprava musí vytvořit auditovatelnou novou skutečnost nebo revizi, nikoli neviditelně odstranit původní stav.

## FR-180 – Vysvětlení rozhodnutí

**Priorita:** CORE  
Uživatel musí být schopen zobrazit srozumitelné vysvětlení významného plánovacího, recovery nebo AI rozhodnutí.

---

# 23. Vyhledávání a obsluha dat

## FR-181 – Vyhledání aktivit

**Priorita:** IMPORTANT  
Uživatel musí mít možnost filtrovat a vyhledat Activity podle podporovaných kritérií.

## FR-182 – Filtrování kalendáře

**Priorita:** IMPORTANT  
Uživatel musí mít možnost filtrovat ScheduleEvent podle sportu, typu, stavu a období.

## FR-183 – Vyhledání workoutu a template

**Priorita:** IMPORTANT  
Uživatel musí mít možnost vyhledat podporované WorkoutTemplate a historické WorkoutInstance.

## FR-184 – Časově omezené dotazy

**Priorita:** CORE  
Historické přehledy a exporty musí respektovat explicitní časový rozsah a time-zone pravidla.

---

# 24. Produktové fallbacky

## FR-185 – Výpadek AI provideru

**Priorita:** CORE  
Při nedostupnosti AI provideru musí zůstat dostupné základní ne-AI funkce, lokální data, tracker a ruční ovládání.

## FR-186 – Výpadek integrace

**Priorita:** CORE  
Výpadek jednoho provideru nesmí znepřístupnit vlastní data a ostatní funkce aplikace.

## FR-187 – Neúplná data

**Priorita:** CORE  
Při neúplných datech musí systém použít podporovaný bezpečný fallback, požádat o doplnění nebo odmítnout nebezpečnou operaci.

## FR-188 – Neznámý sport nebo metrika

**Priorita:** IMPORTANT  
Systém musí zachovat uživatelská data a použít obecnou bezpečnou reprezentaci, pokud nezná plnou sportovní nebo metrickou sémantiku.

---

# 25. Traceability a acceptance

## FR-189 – Vazba požadavku na zdroje

**Priorita:** CORE  
Každý požadavek musí být před stavem `IMPLEMENTATION_READY` propojen minimálně s relevantním product scope, scénářem, UX flow a doménovým zdrojem pravdy.

## FR-190 – Vazba požadavku na test

**Priorita:** CORE  
Každý CORE a IMPORTANT požadavek musí mít před implementací nebo nejpozději současně s ní definované AcceptanceCriterion a testovací pokrytí.

## FR-191 – Vazba požadavku na release

**Priorita:** CORE  
Každý požadavek musí mít před zahájením implementace konkrétního release přiřazen stav: included, deferred, excluded nebo discovery required.

## FR-192 – Změnová kontrola požadavků

**Priorita:** CORE  
Významná změna požadavku musí aktualizovat navazující UX, doménu, API, architekturu, testy a dokumentační audit podle dopadu.

---

# 26. Požadavky vyžadující odborné review

Před označením za `IMPLEMENTATION_READY` vyžadují odborné review minimálně:

- `FR-102` bezpečnostní reakce na bolest,
- `FR-105` odborné doporučení,
- `FR-106` návrat k aktivitě,
- `FR-107` medicínské hranice,
- `FR-159` recovery a safety notifikace,
- `FR-164` až `FR-170` souhlasy, privacy, export, deletion a location data,
- `FR-175` nezletilí a guardian relationship.

---

# 27. Známé otevřené produktové otázky

- Které AuthenticationIdentity budou podporované v prvním release?
- Bude anonymní účet součástí první verze?
- Jaký minimální onboarding je nutný pro první plán?
- Které druhy Goal budou v první verzi plně měřitelné?
- Jaký maximální plánovací horizont bude podporovaný?
- Které workout modality budou v první verzi?
- Bude první Activity recording zahrnovat GPS?
- Které recovery vstupy budou CORE versus optional?
- Které AI změny lze po opt-in automatizovat?
- Které metriky budou mít systémové definice v prvním katalogu?
- Které integrace jsou technicky a smluvně dostupné?
- Bude coach mode součástí V1 nebo až post-V1?
- Budou nezletilí v prvním veřejném release podporováni?
- Jaké exportní formáty budou dostupné?
- Jak dlouho se budou uchovávat různé kategorie dat?

Tyto otázky mají být uzavřeny v release scope, ADR, security nebo provider-specific dokumentech. Nemají se řešit skrytým předpokladem v implementaci.

---

# 28. Kritéria připravenosti dokumentu

Dokument lze označit jako `IMPLEMENTATION_READY`, až když:

1. jsou požadavky zkontrolované proti `product-scope.md`,
2. jsou zkontrolované proti hlavním scénářům a UX,
3. jsou zkontrolované proti doménovým modelům a invariantám,
4. každý požadavek má potvrzenou prioritu,
5. každý požadavek má release disposition,
6. existuje traceability matrix,
7. CORE a IMPORTANT požadavky mají acceptance criteria,
8. medicínské a právní požadavky prošly odborným review,
9. neexistují dva požadavky se stejným nebo rozporným významem,
10. navazující NFR definují kvalitu provedení.

---

# 29. Závěr

Tento registr definuje cílové funkční schopnosti AI Traineru v testovatelné podobě.

Hlavní produktový tok pokrývá:

```text
Identity a AthleteProfile
    ↓
Sporty, cíle, dostupnost, vybavení a omezení
    ↓
TrainingPlan a ScheduleEvent
    ↓
WorkoutInstance a WorkoutSession
    ↓
Activity, MetricValue a GoalProgress
    ↓
Recovery, PainReport a adaptace
    ↓
AIProposal, potvrzení a ChangeSet
    ↓
Audit, synchronizace, privacy a vysvětlitelnost
```

Požadavky neurčují, že všechny funkce musí být implementovány současně. Release scope určí pořadí, ale nesmí měnit jejich význam nebo bezpečnostní hranice.