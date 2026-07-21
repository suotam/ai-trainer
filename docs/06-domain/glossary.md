# AI Trainer – Domain Glossary

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/glossary.md`  
**Vlastník:** Domain Architecture  
**Poslední aktualizace:** 2026-07-21  
**Navazuje na:** všechny dokumenty v `docs/06-domain/`, `docs/06-domain/domain-invariants.md`  
**Navazující dokumenty:** produktové požadavky, UX, backend, mobile, AI, API, data, security a testing dokumentace

---

# 1. Účel dokumentu

Tento dokument definuje kanonické názvosloví aplikace AI Trainer.

Jeho cílem je zajistit, aby stejný pojem znamenal totéž v:

- produktové dokumentaci,
- UX specifikacích,
- doménovém modelu,
- backendu,
- mobilní aplikaci,
- databázi,
- API,
- AI nástrojích,
- událostech,
- analytice,
- testech.

Glossary nepopisuje celé modely, stavové přechody ani invariance. Každá položka obsahuje pouze:

- kanonický název,
- stručnou definici,
- vlastnící dokument,
- případná povolená nebo zakázaná synonyma,
- důležité rozlišení od souvisejících pojmů.

Při rozporu má detailní definice ve vlastnícím doménovém dokumentu přednost před stručnou definicí v glossary.

---

# 2. Pravidla názvosloví

## 2.1 Kanonické technické názvy

Technické názvy objektů se zapisují v angličtině a v `PascalCase`, například:

- `AthleteProfile`,
- `TrainingPlanVersion`,
- `WorkoutSession`,
- `AIProposal`.

Názvy příkazů a událostí se řídí dokumentem `domain-events.md`.

## 2.2 Uživatelské překlady

Uživatelské rozhraní může používat lokalizované názvy. Překlad však nesmí měnit význam technického pojmu.

Příklad:

- technický pojem: `WorkoutInstance`,
- český UI text: „dnešní trénink“,
- doménově však nejde obecně o `WorkoutTemplate` ani `Activity`.

## 2.3 Synonyma

- **Povolené synonymum** lze použít pouze v přirozeném uživatelském textu.
- **Zakázané synonymum** nesmí být použito jako název třídy, tabulky, endpointu nebo AI tool kontraktu.
- Pokud není synonymum uvedeno, používá se kanonický název.

## 2.4 Pojmy s nejvyšším rizikem záměny

Zvláštní pozornost vyžadují zejména:

- `UserAccount` × `AthleteProfile`,
- `UserSport` × `SportDefinition`,
- `TrainingPlan` × `TrainingPlanVersion`,
- `WorkoutTemplate` × `WorkoutInstance` × `WorkoutSession`,
- `ScheduleEvent` × `Activity`,
- `MetricDefinition` × `MetricValue`,
- `AIProposal` × `ChangeSet`,
- `DomainEvent` × `IntegrationEvent`,
- `AvailabilityWindow` × `BusyInterval`,
- `Limitation` × `PainReport` × `SafetyRestriction`.

---

# 3. Identity, account and profile

## 3.1 Identity

**Definice:** Interní jedinečná identita člověka nebo systémového aktéra, ke které lze připojit více autentizačních metod.  
**Vlastník:** `identity-and-profile-model.md`  
**Nezaměňovat s:** `AuthenticationIdentity`, `UserAccount`, `AthleteProfile`.

## 3.2 AuthenticationIdentity

**Definice:** Jeden konkrétní způsob přihlášení, například e-mail, Google, Apple nebo passkey, připojený k `Identity`.  
**Vlastník:** `identity-and-profile-model.md`  
**Zakázaná synonyma:** login account, user profile.

## 3.3 UserAccount

**Definice:** Produktový účet, který vlastní nastavení účtu, právní vztahy, role a vazby na profily.  
**Vlastník:** `identity-and-profile-model.md`  
**Povolené UI synonymum:** účet.  
**Nezaměňovat s:** sportovním profilem.

## 3.4 AthleteProfile

**Definice:** Sportovní profil osoby, pro kterou systém plánuje, personalizuje a vyhodnocuje trénink.  
**Vlastník:** `identity-and-profile-model.md`  
**Povolené UI synonymum:** sportovní profil.  
**Zakázané synonymum:** account.

## 3.5 ActiveProfileContext

**Definice:** Aktuálně zvolený `AthleteProfile` a role, ve které s ním přihlášený účet pracuje.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.6 AthleteProfileRevision

**Definice:** Neměnný záznam významné změny sportovního profilu.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.7 PersonalDetails

**Definice:** Základní osobní údaje relevantní pro produkt, oddělené od sportovních a autentizačních dat.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.8 BodyProfile

**Definice:** Aktuální a historické tělesné údaje relevantní pro plánování a metriky.  
**Vlastník:** `identity-and-profile-model.md`, hodnoty vlastní také `metrics-model.md`.

## 3.9 TrainingBackground

**Definice:** Souhrn obecné sportovní historie a předchozí zkušenosti uživatele.  
**Vlastník:** `identity-and-profile-model.md`  
**Nezaměňovat s:** aktuální zkušeností v konkrétním `UserSport`.

## 3.10 CurrentTrainingState

**Definice:** Aktuální režim, pravidelnost a kapacita uživatele před nebo během plánování.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.11 ProfileCompleteness

**Definice:** Kontextové hodnocení, zda profil obsahuje dostatek údajů pro konkrétní funkci.  
**Vlastník:** `identity-and-profile-model.md`  
**Zakázané zjednodušení:** jedno globální procento úplnosti.

## 3.12 ProfileAttributeSource

**Definice:** Původ profilového údaje, například uživatel, AI strukturování, import nebo trenér.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.13 OnboardingSession

**Definice:** Jedno obnovitelné absolvování onboardingového procesu pro konkrétní profil a verzi flow.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.14 OnboardingAnswer

**Definice:** Strukturovaná nebo původní odpověď uživatele během onboardingu.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.15 ProfileRole

**Definice:** Role konkrétního účtu vůči konkrétnímu sportovnímu profilu.  
**Vlastník:** `identity-and-profile-model.md`  
**Nezaměňovat s:** globální `UserRole`.

## 3.16 UserRole

**Definice:** Globální systémová role účtu, například athlete, coach nebo guardian.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.17 CoachAthleteRelationship

**Definice:** Explicitní, auditovatelný vztah mezi trenérem a sportovním profilem s omezeným scope oprávnění.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.18 GuardianRelationship

**Definice:** Spravující nebo právní vztah opatrovníka k profilu nezletilé nebo závislé osoby.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.19 ManagedProfile

**Definice:** Profil, který je spravován jiným účtem než samotným subjektem profilu.  
**Vlastník:** `identity-and-profile-model.md`.

## 3.20 AnonymousAccount

**Definice:** Dočasný produktový účet bez plně ověřené identity, s omezenými schopnostmi obnovy a synchronizace.  
**Vlastník:** `identity-and-profile-model.md`.

---

# 4. Sports and goals

## 4.1 SportDefinition

**Definice:** Systémová nebo uživatelsky vytvořená definice sportu jako referenčního typu.  
**Vlastník:** `sports-and-goals-model.md`  
**Nezaměňovat s:** sportem provozovaným konkrétním uživatelem.

## 4.2 UserSport

**Definice:** Vazba konkrétního `AthleteProfile` na sport včetně zkušenosti, priority, sezónnosti a účasti.  
**Vlastník:** `sports-and-goals-model.md`  
**Povolené UI synonymum:** můj sport.

## 4.3 CustomSport

**Definice:** Uživatelsky definovaný sport, který zatím nemá odpovídající systémovou `SportDefinition`.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.4 SportExperience

**Definice:** Zkušenost a schopnost uživatele v konkrétním sportu, včetně aktuálnosti zkušenosti.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.5 ParticipationPattern

**Definice:** Obvyklý způsob účasti uživatele na sportu, například počet tréninků, zápasy, sezónnost nebo nepravidelnost.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.6 Goal

**Definice:** Dlouhodobý nebo střednědobý zamýšlený výsledek, kterého chce sportovec dosáhnout.  
**Vlastník:** `sports-and-goals-model.md`  
**Nezaměňovat s:** jednotlivým workoutem, metrickým targetem nebo plánem.

## 4.7 GoalRevision

**Definice:** Historická revize významné změny cíle.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.8 GoalPriority

**Definice:** Relativní důležitost cíle při konfliktu s jinými cíli nebo omezenými zdroji.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.9 GoalMilestone

**Definice:** Významný mezikrok uvnitř cíle.  
**Vlastník:** `sports-and-goals-model.md`  
**Povolené UI synonymum:** milník.

## 4.10 GoalProgress

**Definice:** Odvozené vyhodnocení vývoje směrem k cíli podle schválených metrik a pravidel.  
**Vlastník:** `sports-and-goals-model.md`, vstupní hodnoty vlastní `metrics-model.md`.

## 4.11 GoalConflict

**Definice:** Detekovaný nesoulad mezi cíli, jejich termíny, požadovanou zátěží nebo dostupností.  
**Vlastník:** `sports-and-goals-model.md`.

## 4.12 MetricTarget

**Definice:** Cílová hodnota konkrétní metriky.  
**Vlastník:** `metrics-model.md`  
**Nezaměňovat s:** celým `Goal`.

---

# 5. Training planning

## 5.1 TrainingPlan

**Definice:** Dlouhodobý živý plán propojující cíle, sporty, omezení a časový horizont.  
**Vlastník:** `training-plan-model.md`  
**Nezaměňovat s:** konkrétní verzí plánu.

## 5.2 TrainingPlanVersion

**Definice:** Neměnná konkrétní podoba plánu v určitém okamžiku.  
**Vlastník:** `training-plan-model.md`.

## 5.3 ActiveTrainingPlanVersion

**Definice:** Právě platná verze `TrainingPlan`, podle které se vytvářejí nebo interpretují budoucí jednotky.  
**Vlastník:** `training-plan-model.md`.

## 5.4 TrainingBlock

**Definice:** Souvislá část plánu s konkrétním účelem, například rozvoj, specifická příprava nebo deload.  
**Vlastník:** `training-plan-model.md`.

## 5.5 TrainingWeek

**Definice:** Plánovací úsek reprezentující jeden týden v rámci konkrétní verze plánu.  
**Vlastník:** `training-plan-model.md`.

## 5.6 TrainingPhase

**Definice:** Významově širší období periodizace, které může obsahovat jeden nebo více bloků.  
**Vlastník:** `training-plan-model.md`.

## 5.7 Deload

**Definice:** Plánované období snížené tréninkové zátěže pro podporu regenerace nebo adaptace.  
**Vlastník:** `training-plan-model.md`.

## 5.8 PlanAdjustment

**Definice:** Navržená nebo provedená změna části aktivního tréninkového plánu.  
**Vlastník:** `training-plan-model.md`, AI návrh změny vlastní `ai-and-change-model.md`.

## 5.9 PlanRegeneration

**Definice:** Vytvoření nové významně přepracované verze plánu na základě změněných vstupů.  
**Vlastník:** `training-plan-model.md`.

## 5.10 PlanSnapshot

**Definice:** Zachycení relevantních vstupů a stavu použitých při vytvoření nebo aktivaci verze plánu.  
**Vlastník:** `training-plan-model.md`.

---

# 6. Workout structure and execution

## 6.1 Workout

**Definice:** Obecné zastřešující označení plánované tréninkové jednotky; v technickém kontextu musí být vždy upřesněno na template, definition, instance nebo session.  
**Vlastník:** `workout-model.md`  
**Pravidlo:** Nepoužívat jako nejednoznačný název entity.

## 6.2 WorkoutDefinition

**Definice:** Strukturovaná definice obsahu tréninkové jednotky nezávislá na konkrétním termínu provedení.  
**Vlastník:** `workout-model.md`.

## 6.3 WorkoutTemplate

**Definice:** Opakovaně použitelný vzor workoutu, ze kterého lze vytvořit konkrétní instance nebo definice.  
**Vlastník:** `workout-model.md`.

## 6.4 WorkoutInstance

**Definice:** Konkrétní plánovaná tréninková jednotka určená pro konkrétní profil a plánovací kontext.  
**Vlastník:** `workout-model.md`.

## 6.5 WorkoutInstanceRevision

**Definice:** Neměnná revize obsahu konkrétního `WorkoutInstance`.  
**Vlastník:** `workout-model.md`.

## 6.6 WorkoutSession

**Definice:** Probíhající nebo dokončené skutečné vykonávání konkrétního workoutu uživatelem.  
**Vlastník:** `workout-model.md`  
**Nezaměňovat s:** plánovanou `WorkoutInstance` ani finální `Activity`.

## 6.7 WorkoutStep

**Definice:** Jedna strukturovaná část workoutu, například warm-up, exercise, interval, rest nebo cooldown.  
**Vlastník:** `workout-model.md`.

## 6.8 ExerciseDefinition

**Definice:** Kanonická definice cviku nebo pohybového úkolu.  
**Vlastník:** `workout-model.md`.

## 6.9 ExercisePrescription

**Definice:** Konkrétní předepsání cviku v workoutu včetně objemu, intenzity, tempa, pauzy nebo dalších parametrů.  
**Vlastník:** `workout-model.md`.

## 6.10 SetPrescription

**Definice:** Plánované parametry jedné série.  
**Vlastník:** `workout-model.md`.

## 6.11 SetPerformance

**Definice:** Skutečně provedené hodnoty jedné série během `WorkoutSession`.  
**Vlastník:** `workout-model.md`.

## 6.12 ExerciseSubstitution

**Definice:** Nahrazení předepsaného cviku jiným cvikem při zachování evidované změny a důvodu.  
**Vlastník:** `workout-model.md`.

## 6.13 SessionRPE

**Definice:** Subjektivní hodnocení celkové náročnosti dokončené tréninkové session.  
**Vlastník:** `workout-model.md`, jako metrická hodnota také `metrics-model.md`.

## 6.14 WorkoutFeedback

**Definice:** Strukturované nebo textové hodnocení workoutu po nebo během jeho vykonávání.  
**Vlastník:** `workout-model.md`.

## 6.15 RecoveryCheckpoint

**Definice:** Lokálně uložený bod umožňující obnovit aktivní workout session po pádu aplikace nebo zařízení.  
**Vlastník:** `sync-and-offline-model.md`, session význam vlastní `workout-model.md`.

---

# 7. Scheduling and availability

## 7.1 ScheduleEvent

**Definice:** Interní kalendářní objekt reprezentující plánovanou, pevnou, flexibilní nebo informační událost.  
**Vlastník:** `scheduling-model.md`  
**Nezaměňovat s:** skutečně provedenou `Activity`.

## 7.2 ScheduleEventRevision

**Definice:** Historická revize změny termínu nebo dalších významných vlastností kalendářní události.  
**Vlastník:** `scheduling-model.md`.

## 7.3 EventGroup

**Definice:** Logická skupina souvisejících schedule událostí, například série nebo společná sportovní akce.  
**Vlastník:** `scheduling-model.md`.

## 7.4 RecurrenceRule

**Definice:** Pravidlo opakování kalendářní nebo dostupnostní položky.  
**Vlastník:** `scheduling-model.md`.

## 7.5 RecurrenceInstance

**Definice:** Konkrétní materializovaný výskyt opakované série.  
**Vlastník:** `scheduling-model.md`.

## 7.6 AvailabilityProfile

**Definice:** Obecný profil časových možností uživatele pro plánování.  
**Vlastník:** `identity-and-profile-model.md`, plánovací použití vlastní `scheduling-model.md`.

## 7.7 AvailabilityWindow

**Definice:** Časové okno, ve kterém je trénink preferovaný, možný, omezený nebo nemožný.  
**Vlastník:** `identity-and-profile-model.md` a `scheduling-model.md` podle kontextu.

## 7.8 BusyInterval

**Definice:** Časový interval obsazenosti, často importovaný z externího kalendáře, bez nutnosti znát jeho citlivý obsah.  
**Vlastník:** `scheduling-model.md`, import vlastní `integration-model.md`.

## 7.9 ScheduleConflict

**Definice:** Neslučitelnost mezi dvěma událostmi, dostupností, omezením nebo pravidlem plánu.  
**Vlastník:** `scheduling-model.md`.

## 7.10 FixedEvent

**Definice:** Schedule událost, jejíž termín nelze automaticky změnit bez explicitního rozhodnutí.  
**Vlastník:** `scheduling-model.md`.

## 7.11 FlexibleEvent

**Definice:** Schedule událost, jejíž termín lze v povolených mezích navrhovat nebo měnit.  
**Vlastník:** `scheduling-model.md`.

## 7.12 Reminder

**Definice:** Plánované uživatelské upozornění vztahující se k aktuálnímu stavu schedule nebo jiné doménové skutečnosti.  
**Vlastník:** `scheduling-model.md` a budoucí notification architektura.

---

# 8. Activities and actual history

## 8.1 Activity

**Definice:** Kanonický záznam skutečně provedené sportovní nebo tréninkové aktivity.  
**Vlastník:** `activity-model.md`  
**Povolené UI synonymum:** aktivita.  
**Zakázané synonymum:** workout, pokud jde pouze o plán.

## 8.2 ActivityRecord

**Definice:** Strukturovaný záznam dat tvořících aktivitu; v některých dokumentech technický detail `Activity`.  
**Vlastník:** `activity-model.md`.

## 8.3 ActivitySource

**Definice:** Původ aktivity, například workout session, ruční zadání, GPS záznam nebo externí provider.  
**Vlastník:** `activity-model.md`.

## 8.4 ActivityRevision

**Definice:** Neměnná revize opravy nebo významné změny aktivity.  
**Vlastník:** `activity-model.md`.

## 8.5 ActivityMatch

**Definice:** Vyhodnocená vazba skutečné aktivity na plánovaný workout nebo schedule událost.  
**Vlastník:** `activity-model.md`.

## 8.6 ActivityDuplicate

**Definice:** Aktivita nebo source record, který pravděpodobně reprezentuje stejnou skutečnou činnost jako jiný záznam.  
**Vlastník:** `activity-model.md` a `integration-model.md`.

## 8.7 CanonicalActivity

**Definice:** Záznam zvolený jako autoritativní reprezentace skutečné aktivity po deduplikaci nebo merge.  
**Vlastník:** `activity-model.md`.

## 8.8 ActivityGroup

**Definice:** Logické seskupení několika aktivit, které společně tvoří jednu sportovní událost nebo související celek.  
**Vlastník:** `activity-model.md`.

## 8.9 Route

**Definice:** Geografický průběh aktivity uložený jako citlivý location-related datový objekt.  
**Vlastník:** `activity-model.md` a budoucí data/security dokumentace.

## 8.10 ActivityLoad

**Definice:** Odvozené vyjádření celkové tréninkové zátěže konkrétní aktivity podle verzované metody.  
**Vlastník:** `activity-model.md`, výpočetní definici vlastní `metrics-model.md`.

## 8.11 BodyLoad

**Definice:** Odvozené rozdělení zatížení na tělesné oblasti nebo pohybové systémy.  
**Vlastník:** `activity-model.md`.

## 8.12 Provenance

**Definice:** Dohledatelný původ dat, transformací a rozhodnutí vedoucích k aktuální hodnotě nebo objektu.  
**Vlastník:** napříč doménami; základní pravidla `domain-invariants.md`.

---

# 9. Recovery, pain and limitations

## 9.1 DailyCheckIn

**Definice:** Krátký uživatelský záznam aktuálního subjektivního stavu, například únava, spánek, soreness nebo motivace.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.2 RecoveryState

**Definice:** Strukturovaný souhrn dostupných recovery vstupů v konkrétním čase.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.3 ReadinessAssessment

**Definice:** Časově omezené odvozené hodnocení připravenosti na trénink, nikoli diagnóza.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.4 RecoveryRecommendation

**Definice:** Doporučení týkající se odpočinku, intenzity nebo úpravy tréninku na základě recovery kontextu.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.5 FatigueReport

**Definice:** Uživatelsky nebo jinak zaznamenaná informace o aktuální únavě.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.6 MuscleSoreness

**Definice:** Subjektivní svalová citlivost nebo bolestivost typicky související s předchozí zátěží.  
**Vlastník:** `recovery-and-limitations-model.md`  
**Nezaměňovat s:** neobvyklou, ostrou nebo zraněním související bolestí.

## 9.7 PainReport

**Definice:** Záznam subjektivně vnímané bolesti včetně oblasti, intenzity, charakteru a kontextu.  
**Vlastník:** `recovery-and-limitations-model.md`  
**Pravidlo:** Není diagnózou.

## 9.8 PainAssessment

**Definice:** Strukturované bezpečnostní vyhodnocení hlášené bolesti podle deterministických a případně AI podporovaných pravidel.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.9 Limitation

**Definice:** Časově platné omezení sportu, pohybu, intenzity, objemu nebo tělesné oblasti.  
**Vlastník:** `recovery-and-limitations-model.md`  
**Nezaměňovat s:** jednorázovým `PainReport`.

## 9.10 SafetyFlag

**Definice:** Detekovaný signál, že situace vyžaduje zvýšenou opatrnost, blokaci nebo další posouzení.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.11 SafetyRestriction

**Definice:** Aktivní ochranné pravidlo blokující nebo omezující určitou akci.  
**Vlastník:** `recovery-and-limitations-model.md` a `domain-invariants.md`.

## 9.12 ProfessionalRecommendation

**Definice:** Doporučení kvalifikovaného odborníka zaznamenané s původem, platností a scope.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.13 ReturnToActivityPlan

**Definice:** Strukturovaný postupný návrat k aktivitě po pauze, omezení nebo odborném doporučení.  
**Vlastník:** `recovery-and-limitations-model.md`.

## 9.14 ManualSafetyOverride

**Definice:** Výslovně povolená výjimka z neabsolutního bezpečnostního pravidla s důvodem, oprávněním a auditem.  
**Vlastník:** `recovery-and-limitations-model.md`, globální hranice `domain-invariants.md`.

---

# 10. Metrics and progress

## 10.1 MetricDefinition

**Definice:** Kanonická definice měřené nebo odvozené veličiny, včetně jednotky, typu a významu.  
**Vlastník:** `metrics-model.md`.

## 10.2 MetricValue

**Definice:** Jedna hodnota konkrétní metriky v čase, se zdrojem, jednotkou a kvalitou.  
**Vlastník:** `metrics-model.md`.

## 10.3 MetricSeries

**Definice:** Časová nebo sekvenční řada hodnot stejné metriky.  
**Vlastník:** `metrics-model.md`.

## 10.4 MetricSample

**Definice:** Jeden vzorek uvnitř `MetricSeries`, typicky s přesným timestampem.  
**Vlastník:** `metrics-model.md`.

## 10.5 MetricAggregate

**Definice:** Odvozená agregovaná hodnota za interval nebo skupinu dat.  
**Vlastník:** `metrics-model.md`.

## 10.6 DerivedMetric

**Definice:** Metrika vypočtená z jiných hodnot podle verzované metody.  
**Vlastník:** `metrics-model.md`.

## 10.7 MetricBaseline

**Definice:** Referenční výchozí nebo obvyklá hodnota metriky pro konkrétní profil a kontext.  
**Vlastník:** `metrics-model.md`.

## 10.8 MetricTrend

**Definice:** Odvozený směr a charakter vývoje metriky v čase.  
**Vlastník:** `metrics-model.md`.

## 10.9 PersonalRecord

**Definice:** Potvrzený nejlepší výkon podle konkrétní MetricDefinition, scope a validačních pravidel.  
**Vlastník:** `metrics-model.md`  
**Povolené UI synonymum:** osobní rekord.

## 10.10 ProgressSnapshot

**Definice:** Neměnný souhrn relevantního progresu v konkrétním okamžiku.  
**Vlastník:** `metrics-model.md`.

## 10.11 Adherence

**Definice:** Odvozená míra souladu skutečně provedených aktivit s relevantní částí plánu.  
**Vlastník:** `metrics-model.md`  
**Pravidlo:** Nesmí trestat legitimní bezpečnostní úpravy bez kontextu.

## 10.12 CalculationVersion

**Definice:** Identifikátor konkrétní verze výpočetní metody použité pro odvozenou hodnotu.  
**Vlastník:** `metrics-model.md`.

## 10.13 DataQuality

**Definice:** Strukturované hodnocení úplnosti, důvěryhodnosti a použitelnosti dat.  
**Vlastník:** `metrics-model.md` a budoucí data architecture.

---

# 11. AI and controlled changes

## 11.1 AIConversation

**Definice:** Konverzační kontext mezi uživatelem a AI trenérem.  
**Vlastník:** `ai-and-change-model.md`.

## 11.2 AIMessage

**Definice:** Jedna uživatelská, AI nebo systémová zpráva v AIConversation.  
**Vlastník:** `ai-and-change-model.md`.

## 11.3 AIIntent

**Definice:** Strukturovaná interpretace uživatelského záměru relevantní pro další dotaz, vysvětlení nebo návrh akce.  
**Vlastník:** `ai-and-change-model.md`.

## 11.4 AIContext

**Definice:** Minimální autorizovaný strukturovaný kontext připravený pro konkrétní AI úlohu.  
**Vlastník:** `ai-and-change-model.md`, runtime realizace budoucí `ai-architecture.md`.

## 11.5 AIProposal

**Definice:** Strukturovaný návrh vytvořený AI, který ještě není provedenou doménovou změnou.  
**Vlastník:** `ai-and-change-model.md`  
**Zakázané synonymum:** change.

## 11.6 AIProposalRevision

**Definice:** Neměnná verze konkrétního AI návrhu.  
**Vlastník:** `ai-and-change-model.md`.

## 11.7 ChangeSet

**Definice:** Validovatelný soubor jedné nebo více konkrétních doménových operací připravených k potvrzení a aplikaci.  
**Vlastník:** `ai-and-change-model.md`  
**Nezaměňovat s:** textovým AI návrhem.

## 11.8 ChangeOperation

**Definice:** Jedna atomicky popsaná doménová operace uvnitř `ChangeSet`.  
**Vlastník:** `ai-and-change-model.md`.

## 11.9 ConfirmationPolicy

**Definice:** Pravidla určující, které změny lze provést automaticky, které vyžadují informování a které explicitní potvrzení.  
**Vlastník:** `ai-and-change-model.md`, budoucí detail `09-ai`.

## 11.10 StaleProposal

**Definice:** AIProposal, jehož výchozí kontext se od vytvoření změnil natolik, že jej nelze bezpečně aplikovat bez nové validace.  
**Vlastník:** `ai-and-change-model.md`.

## 11.11 ToolInvocation

**Definice:** Jedno autorizované nebo odmítnuté volání předem definovaného AI nástroje.  
**Vlastník:** `ai-and-change-model.md`, runtime detail budoucí AI architektura.

## 11.12 UndoPlan

**Definice:** Předem připravený bezpečný postup pro vrácení nebo kompenzaci změn.  
**Vlastník:** `ai-and-change-model.md`.

## 11.13 Compensation

**Definice:** Nová doménová operace napravující dopad dřívější změny bez přepisování historie.  
**Vlastník:** `ai-and-change-model.md` a `domain-events.md`.

## 11.14 AutomationPolicy

**Definice:** Uživatelsky a bezpečnostně omezené nastavení, které určuje povolený rozsah automatických nízkorizikových změn.  
**Vlastník:** `ai-and-change-model.md`.

---

# 12. Integrations

## 12.1 IntegrationProvider

**Definice:** Externí služba nebo platforma, se kterou může AI Trainer komunikovat.  
**Vlastník:** `integration-model.md`.

## 12.2 UserIntegration

**Definice:** Konkrétní propojení uživatelského účtu nebo profilu s providerem.  
**Vlastník:** `integration-model.md`.

## 12.3 IntegrationPermission

**Definice:** Explicitní oprávnění pro konkrétní scope dat nebo operací vůči providerovi.  
**Vlastník:** `integration-model.md`.

## 12.4 IntegrationCredential

**Definice:** Citlivý autentizační prostředek pro externí integraci, uložený mimo běžný doménový payload.  
**Vlastník:** `integration-model.md`, bezpečnost budoucí security dokumentace.

## 12.5 ExternalDataRecord

**Definice:** Normalizovatelný záznam přijatý z externího systému před vytvořením nebo aktualizací kanonického doménového objektu.  
**Vlastník:** `integration-model.md`.

## 12.6 PrimarySourceRecord

**Definice:** Externí nebo interní source record zvolený jako primární původ konkrétní části kanonických dat.  
**Vlastník:** `integration-model.md`.

## 12.7 ProviderMapping

**Definice:** Verzované mapování provider-specific hodnot na kanonické hodnoty AI Traineru.  
**Vlastník:** `integration-model.md`.

## 12.8 DataImportJob

**Definice:** Dlouhodobější proces importu jedné dávky nebo časového rozsahu externích dat.  
**Vlastník:** `integration-model.md`.

## 12.9 HistoricalBackfill

**Definice:** Import starších historických dat z provideru mimo běžnou průběžnou synchronizaci.  
**Vlastník:** `integration-model.md`.

## 12.10 Reconciliation

**Definice:** Proces porovnání interního a externího stavu za účelem detekce chybějících, změněných nebo konfliktních záznamů.  
**Vlastník:** `integration-model.md`.

## 12.11 IntegrationHealth

**Definice:** Aktuální provozní stav konkrétního propojení nebo provideru.  
**Vlastník:** `integration-model.md`.

## 12.12 WebhookEvent

**Definice:** Provider-specific oznámení přijaté přes webhook; není automaticky doménovou událostí.  
**Vlastník:** `integration-model.md` a `domain-events.md`.

---

# 13. Offline and synchronization

## 13.1 DeviceInstallation

**Definice:** Jedna instalace aplikace na konkrétním zařízení se samostatnou sync a bezpečnostní identitou.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.2 LocalEntity

**Definice:** Lokální reprezentace synchronizovaného nebo pouze lokálního doménového objektu.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.3 OfflineCommand

**Definice:** Uživatelský příkaz vytvořený bez potvrzení serverem a čekající na synchronizaci.  
**Vlastník:** `sync-and-offline-model.md`  
**Nezaměňovat s:** autoritativně potvrzenou doménovou událostí.

## 13.4 SyncOperation

**Definice:** Jedna technická synchronizační operace, například push commandu, pull změny nebo upload blobu.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.5 SyncBatch

**Definice:** Skupina synchronizačních operací zpracovávaná jako jeden přenosový nebo aplikační celek.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.6 SyncCursor

**Definice:** Neprůhledný ukazatel poslední bezpečně aplikované pozice ve change feedu.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.7 ChangeFeed

**Definice:** Serverový proud změn určený klientovi pro inkrementální synchronizaci.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.8 SyncConflict

**Definice:** Neslučitelnost dvou nebo více změn stejného logického objektu nebo pravidla.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.9 MergePolicy

**Definice:** Předem definované pravidlo, jak slučovat změny konkrétního typu entity nebo pole.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.10 Tombstone

**Definice:** Synchronizovatelný záznam odstranění objektu, který zabraňuje jeho nechtěnému obnovení ze starší kopie.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.11 EntityAlias

**Definice:** Vazba mezi dočasným nebo starým identifikátorem a autoritativním identifikátorem objektu.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.12 FullResync

**Definice:** Úplná obnova lokálního synchronizovaného stavu z autoritativního serveru.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.13 PendingUpload

**Definice:** Lokálně evidovaný soubor nebo blob čekající na bezpečné nahrání.  
**Vlastník:** `sync-and-offline-model.md`.

## 13.14 LocalPendingState

**Definice:** Stav změny, která je lokálně platná pro UX, ale ještě nebyla potvrzena serverem.  
**Vlastník:** `sync-and-offline-model.md`.

---

# 14. Events, commands and audit

## 14.1 Command

**Definice:** Záměr provést konkrétní doménovou operaci. Může být přijat, odmítnut nebo skončit bez změny.  
**Vlastník:** jednotlivé doménové modely a `domain-events.md`.

## 14.2 DomainEvent

**Definice:** Neměnná doménově významná skutečnost, která již nastala.  
**Vlastník:** `domain-events.md`.

## 14.3 IntegrationEvent

**Definice:** Stabilní verzovaný kontrakt určený komunikaci mezi moduly, službami nebo externími systémy.  
**Vlastník:** `domain-events.md`  
**Nezaměňovat s:** interní doménovou událostí.

## 14.4 TechnicalEvent

**Definice:** Událost popisující technický nebo provozní stav bez nutného doménového významu.  
**Vlastník:** `domain-events.md`.

## 14.5 ProcessEvent

**Definice:** Událost popisující stav dlouhodobého workflow, které nemusí vlastnit jeden běžný agregát.  
**Vlastník:** `domain-events.md`.

## 14.6 EventEnvelope

**Definice:** Společná obálka události obsahující identitu, typ, verzi, čas, agregát, kauzalitu, klasifikaci a payload.  
**Vlastník:** `domain-events.md`.

## 14.7 Aggregate

**Definice:** Konzistenční a transakční hranice doménového modelu s jedním kořenem.  
**Vlastník:** `domain-overview.md` a detailní doménové modely.

## 14.8 AggregateRoot

**Definice:** Jediný vstupní objekt, přes který se mění stav agregátu a chrání jeho invariance.  
**Vlastník:** `domain-overview.md`.

## 14.9 AggregateVersion

**Definice:** Monotónně rostoucí verze agregátu používaná pro pořadí, concurrency a detekci chybějících změn.  
**Vlastník:** `domain-events.md`.

## 14.10 CorrelationId

**Definice:** Identifikátor spojující všechny operace a události jednoho logického procesu.  
**Vlastník:** `domain-events.md`.

## 14.11 CausationId

**Definice:** Identifikátor bezprostřední příčiny konkrétní události.  
**Vlastník:** `domain-events.md`.

## 14.12 OutboxMessage

**Definice:** Transakčně uložená zpráva čekající na spolehlivé publikování události.  
**Vlastník:** `domain-events.md`.

## 14.13 InboxRecord

**Definice:** Záznam konzumenta dokazující, zda již konkrétní událost zpracoval.  
**Vlastník:** `domain-events.md`.

## 14.14 DeadLetterRecord

**Definice:** Záznam události, kterou konkrétní konzument nedokázal po povolených pokusech zpracovat.  
**Vlastník:** `domain-events.md`.

## 14.15 Replay

**Definice:** Opětovné zpracování dříve vzniklých událostí za řízených podmínek.  
**Vlastník:** `domain-events.md`.

## 14.16 Projection

**Definice:** Odvozený read model vytvářený z autoritativních změn nebo událostí.  
**Vlastník:** `domain-events.md` a budoucí backend architektura.

## 14.17 AuditRecord

**Definice:** Neměnný záznam dokazující, kdo, kdy, proč a jak změnil významný stav.  
**Vlastník:** `domain-events.md`, detail budoucí security/backend dokumentace.

## 14.18 IdempotencyKey

**Definice:** Stabilní klíč umožňující opakovat stejný požadavek bez zdvojení doménového efektu.  
**Vlastník:** `domain-events.md`, `sync-and-offline-model.md` a budoucí API architektura.

---

# 15. Privacy, consent and data lifecycle

## 15.1 DataProcessingConsent

**Definice:** Auditovatelný souhlas s konkrétním účelem, scope, kategoriemi dat a verzí právního textu.  
**Vlastník:** `identity-and-profile-model.md`.

## 15.2 LegalAcceptance

**Definice:** Záznam přijetí konkrétní verze právního dokumentu.  
**Vlastník:** `identity-and-profile-model.md`.

## 15.3 PrivacyPreference

**Definice:** Produktová volba uživatele týkající se použití, viditelnosti nebo sdílení dat.  
**Vlastník:** `identity-and-profile-model.md`  
**Nezaměňovat s:** právně relevantním souhlasem.

## 15.4 DataClassification

**Definice:** Klasifikace citlivosti a povoleného způsobu zpracování dat nebo události.  
**Vlastník:** `domain-events.md`, budoucí security architektura.

## 15.5 PersonalData

**Definice:** Data vztahující se k identifikované nebo identifikovatelné osobě.  
**Vlastník:** budoucí security/privacy dokumentace.

## 15.6 HealthRelatedData

**Definice:** Data související se zdravotním nebo fyzickým stavem, například bolest, omezení nebo některé recovery hodnoty.  
**Vlastník:** budoucí security dokumentace; doménový význam vlastní recovery a metrics model.

## 15.7 LocationData

**Definice:** Data umožňující určit nebo odvodit polohu osoby či průběh její trasy.  
**Vlastník:** budoucí security/data dokumentace.

## 15.8 DataExportRequest

**Definice:** Auditovaný požadavek na přípravu uživatelských dat v přenositelném formátu.  
**Vlastník:** `identity-and-profile-model.md`.

## 15.9 AccountDeletionRequest

**Definice:** Auditovaný požadavek na ukončení účtu a odpovídající odstranění nebo anonymizaci dat.  
**Vlastník:** `identity-and-profile-model.md`.

## 15.10 RetentionPolicy

**Definice:** Pravidla určující dobu a účel uchování konkrétní kategorie dat.  
**Vlastník:** budoucí security/data dokumentace.

## 15.11 TombstoneRetention

**Definice:** Doba, po kterou musí být zachován záznam smazání kvůli synchronizaci a zabránění obnovení dat.  
**Vlastník:** `sync-and-offline-model.md`, detail budoucí data/security dokumentace.

## 15.12 DataOwner

**Definice:** Účet, profil nebo organizace, jejichž doménový vztah určuje vlastnictví a oprávnění k datům.  
**Vlastník:** `identity-and-profile-model.md` a `domain-invariants.md`.

## 15.13 DataSubject

**Definice:** Osoba, ke které se osobní údaje vztahují; nemusí být totožná s účtem, který profil spravuje.  
**Vlastník:** `identity-and-profile-model.md` a budoucí privacy dokumentace.

---

# 16. Preferences, environment and equipment

## 16.1 TrainingPreference

**Definice:** Uživatelská preference týkající se stylu, délky, času, variability nebo formy tréninku.  
**Vlastník:** `identity-and-profile-model.md`  
**Pravidlo:** Preference není bezpečnostní omezení.

## 16.2 AvailabilityProfile

**Definice:** Obvyklý časový rámec, ve kterém lze plánovat trénink.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.3 TypicalWeekProfile

**Definice:** Strukturovaný popis obvyklého týdne uživatele.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.4 EquipmentProfile

**Definice:** Přehled vybavení, ke kterému má uživatel přístup, včetně místa a časové dostupnosti.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.5 EquipmentDefinition

**Definice:** Kanonická definice typu vybavení.  
**Vlastník:** `identity-and-profile-model.md`, použití ve workoutu vlastní `workout-model.md`.

## 16.6 EquipmentAvailability

**Definice:** Časový, místní nebo jiný kontext, ve kterém je vybavení skutečně dostupné.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.7 TrainingEnvironment

**Definice:** Prostředí tréninku včetně prostoru, vybavení, povrchu, hluku a dalších omezení.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.8 UnitPreference

**Definice:** Způsob vstupu a zobrazení jednotek uživateli; nemění kanonické interní hodnoty.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.9 LocalePreference

**Definice:** Nastavení jazyka, formátu data, čísel a lokalizačních fallbacků.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.10 TimeZonePreference

**Definice:** Výchozí časové pásmo a policy chování při cestování nebo změně lokace.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.11 AccessibilityPreference

**Definice:** Uživatelské nastavení podporující přístupnost aplikace nad rámec systémových nastavení zařízení.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.12 NotificationPreference

**Definice:** Produktová volba určující, jaké notifikace uživatel chce dostávat.  
**Vlastník:** `identity-and-profile-model.md`.

## 16.13 PlatformPermissionState

**Definice:** Skutečný stav oprávnění uděleného operačním systémem, například pro notifikace, polohu nebo health data.  
**Vlastník:** `identity-and-profile-model.md`, technický detail budoucí mobile architektura.

## 16.14 AIInteractionPreference

**Definice:** Preference stylu, délky, proaktivity a míry automatizace AI komunikace.  
**Vlastník:** `identity-and-profile-model.md`.

---

# 17. Cross-domain architecture terms

## 17.1 BoundedContext

**Definice:** Jasně ohraničená část domény s vlastním modelem, jazykem a odpovědností.  
**Vlastník:** `domain-overview.md`.

## 17.2 DomainService

**Definice:** Doménová logika, která přirozeně nepatří jednomu agregátu nebo value objectu.  
**Vlastník:** `domain-overview.md` a detailní modely.

## 17.3 ApplicationService

**Definice:** Orchestrace use case, autorizace, transakcí a volání doménových objektů bez vlastního doménového významu.  
**Vlastník:** budoucí backend architektura.

## 17.4 ValueObject

**Definice:** Neměnný objekt definovaný hodnotou, nikoli samostatnou identitou.  
**Vlastník:** `domain-overview.md`.

## 17.5 Entity

**Definice:** Doménový objekt s vlastní stabilní identitou a životním cyklem.  
**Vlastník:** `domain-overview.md`.

## 17.6 SourceOfTruth

**Definice:** Autoritativní objekt, dokument nebo systém, jehož stav má přednost při rozhodování o konkrétní skutečnosti.  
**Vlastník:** `domain-invariants.md`.

## 17.7 CanonicalModel

**Definice:** Interní provider- a platform-independent reprezentace doménových dat.  
**Vlastník:** `domain-overview.md`, integrace `integration-model.md`.

## 17.8 Revision

**Definice:** Neměnná verze obsahu jednoho logického objektu, která zachovává historii změn.  
**Vlastník:** napříč doménami, globální pravidla `domain-invariants.md`.

## 17.9 Snapshot

**Definice:** Neměnné zachycení relevantního stavu nebo vstupů v konkrétním okamžiku.  
**Vlastník:** podle konkrétní domény.

## 17.10 Invariant

**Definice:** Pravidlo, které musí zůstat pravdivé ve všech podporovaných stavech systému.  
**Vlastník:** `domain-invariants.md` a detailní doménové modely.

## 17.11 Policy

**Definice:** Konfigurovatelné nebo rozhodovací pravidlo, které může mít více platných variant, ale nesmí porušit invariance.  
**Vlastník:** podle domény.

## 17.12 RuleVersion

**Definice:** Identifikátor konkrétní verze pravidla použitého pro rozhodnutí nebo výpočet.  
**Vlastník:** podle domény, globální audit `domain-invariants.md`.

## 17.13 Confidence

**Definice:** Strukturované vyjádření míry jistoty odhadu, interpretace nebo odvozené hodnoty.  
**Vlastník:** podle domény  
**Pravidlo:** Confidence nesmí být prezentována jako objektivní pravděpodobnost bez kalibrace.

## 17.14 ReasonCode

**Definice:** Stabilní strukturovaný kód vysvětlující důvod změny, rozhodnutí, odmítnutí nebo chyby.  
**Vlastník:** `domain-events.md` a detailní domény.

## 17.15 ValidationResult

**Definice:** Strukturovaný výsledek validace obsahující úspěch, chyby, warnings a relevantní pravidla.  
**Vlastník:** budoucí backend/API architektura.

## 17.16 ConflictResolution

**Definice:** Proces výběru nebo vytvoření konzistentního výsledku z neslučitelných stavů či změn.  
**Vlastník:** `sync-and-offline-model.md`, `scheduling-model.md`, `sports-and-goals-model.md` podle typu konfliktu.

## 17.17 CanonicalUnit

**Definice:** Interní jednotka, ve které systém ukládá nebo zpracovává hodnotu nezávisle na uživatelském zobrazení.  
**Vlastník:** `metrics-model.md`.

## 17.18 AbsoluteTime

**Definice:** Jednoznačný okamžik nezávislý na lokálním časovém pásmu.  
**Vlastník:** `scheduling-model.md` a `domain-invariants.md`.

## 17.19 LocalDateTime

**Definice:** Lokální datum a čas, které musí být interpretovány společně s časovým pásmem nebo jinou časovou policy.  
**Vlastník:** `scheduling-model.md`.

## 17.20 DataLineage

**Definice:** Řetězec původu, transformací a výpočtů vedoucích k aktuálním datům.  
**Vlastník:** `integration-model.md`, `metrics-model.md` a budoucí data architecture.

---

# 18. Zakázané nejednoznačné názvy

Následující obecné názvy se nesmí používat jako samostatné doménové entity, tabulky nebo API resource bez upřesnění:

- `User` – použít `Identity`, `UserAccount` nebo `AthleteProfile` podle významu,
- `Profile` – použít `AthleteProfile`, `BodyProfile`, `EquipmentProfile` nebo jiný konkrétní typ,
- `Plan` – použít `TrainingPlan`, `TrainingPlanVersion`, `ReturnToActivityPlan` nebo jiný konkrétní typ,
- `Workout` – použít `WorkoutTemplate`, `WorkoutDefinition`, `WorkoutInstance` nebo `WorkoutSession`,
- `Event` – použít `ScheduleEvent`, `DomainEvent`, `IntegrationEvent` nebo jiný konkrétní typ,
- `ActivityEvent` – rozhodnout, zda jde o `Activity` nebo doménovou událost týkající se aktivity,
- `Metric` – použít `MetricDefinition`, `MetricValue`, `MetricSeries` nebo `MetricAggregate`,
- `Record` – použít konkrétní význam, například `ActivityRecord` nebo `AuditRecord`,
- `Change` – použít `AIProposal`, `ChangeSet`, `ChangeOperation`, revision nebo event,
- `SyncItem` – použít `OfflineCommand`, `SyncOperation`, `ChangeFeedEntry` nebo `PendingUpload`,
- `Integration` – použít `IntegrationProvider` nebo `UserIntegration`,
- `Restriction` – použít `Limitation`, `SafetyRestriction`, permission nebo policy podle významu,
- `Score` – použít konkrétní MetricDefinition, například readiness score, včetně verze výpočtu,
- `Status` – použít konkrétní enum vlastněný daným agregátem.

---

# 19. Kanonická rozlišení

## 19.1 Account versus profile

```text
Identity
  └── UserAccount
        └── AthleteProfile
```

- Identity odpovídá na otázku „kdo se autentizuje“.
- UserAccount odpovídá na otázku „jaký produktový účet vlastní nastavení a vztahy“.
- AthleteProfile odpovídá na otázku „pro koho se plánuje a vyhodnocuje trénink“.

## 19.2 Plan versus schedule versus reality

```text
TrainingPlanVersion
  └── WorkoutInstance
        └── ScheduleEvent
              └── WorkoutSession
                    └── Activity
```

- plán říká, co má být rozvíjeno,
- workout instance říká, co má uživatel provést,
- schedule event říká, kdy a v jakém kalendářním kontextu,
- workout session zachycuje živé vykonávání,
- activity zachycuje historickou skutečnost.

## 19.3 Template versus instance versus session

- `WorkoutTemplate` je opakovaně použitelný vzor,
- `WorkoutInstance` je konkrétní plánovaná jednotka,
- `WorkoutSession` je konkrétní vykonávání,
- `Activity` je kanonický historický výsledek.

## 19.4 Proposal versus change

- `AIProposal` je návrh,
- `ChangeSet` je konkrétní validovatelný plán operací,
- schválený `ChangeSet` může vytvořit doménové změny,
- `DomainEvent` potvrzuje, že změna skutečně nastala.

## 19.5 Pain versus limitation

- `PainReport` je pozorování nebo hlášení,
- `PainAssessment` je vyhodnocení,
- `SafetyFlag` je detekovaný signál rizika,
- `Limitation` je časově platné omezení,
- `SafetyRestriction` je aktivní blokující pravidlo.

## 19.6 Definition versus value

- `MetricDefinition` určuje význam metriky,
- `MetricValue` je jedna hodnota,
- `MetricSeries` je řada,
- `MetricAggregate` je odvozený souhrn.

## 19.7 Provider data versus canonical data

- `ExternalDataRecord` reprezentuje provider-specific vstup,
- mapping a validace jej převádějí do kanonického modelu,
- `Activity`, `MetricValue` nebo jiný doménový objekt je interní zdroj pravdy,
- provider zůstává zachován v provenance a lineage.

## 19.8 Domain event versus integration event

- DomainEvent popisuje interní doménovou skutečnost,
- IntegrationEvent je stabilní distribuovaný kontrakt,
- jedna doménová událost může vytvořit jednu nebo více integračních událostí,
- jejich schémata ani životní cyklus nemusí být totožné.

---

# 20. Vlastnictví pojmů podle dokumentů

| Dokument | Hlavní vlastněné pojmy |
|---|---|
| `domain-overview.md` | bounded contexts, aggregate, entity, value object, domain ownership |
| `sports-and-goals-model.md` | SportDefinition, UserSport, Goal, GoalMilestone, GoalProgress |
| `training-plan-model.md` | TrainingPlan, TrainingPlanVersion, TrainingBlock, TrainingWeek |
| `workout-model.md` | WorkoutTemplate, WorkoutInstance, WorkoutSession, ExercisePrescription |
| `scheduling-model.md` | ScheduleEvent, RecurrenceRule, ScheduleConflict |
| `activity-model.md` | Activity, ActivityMatch, ActivityRevision, Route, ActivityLoad |
| `recovery-and-limitations-model.md` | DailyCheckIn, ReadinessAssessment, PainReport, Limitation, SafetyRestriction |
| `ai-and-change-model.md` | AIConversation, AIProposal, ChangeSet, ToolInvocation, UndoPlan |
| `metrics-model.md` | MetricDefinition, MetricValue, MetricSeries, MetricAggregate, PersonalRecord |
| `integration-model.md` | IntegrationProvider, UserIntegration, ExternalDataRecord, Reconciliation |
| `sync-and-offline-model.md` | OfflineCommand, SyncOperation, ChangeFeed, SyncConflict, Tombstone |
| `identity-and-profile-model.md` | Identity, UserAccount, AthleteProfile, OnboardingSession, preferences, consent, roles |
| `domain-events.md` | Command, DomainEvent, IntegrationEvent, EventEnvelope, Outbox, Inbox, Replay |
| `domain-invariants.md` | globální priority, source-of-truth a cross-domain invariance |

---

# 21. Pravidla pro zavedení nového pojmu

Nový doménový pojem lze zavést pouze pokud:

1. má jasný a odlišný význam,
2. nelze jej přesně vyjádřit existujícím pojmem,
3. má určený vlastnící dokument nebo bounded context,
4. má definovaný vztah k existujícím objektům,
5. neporušuje globální invariance,
6. je doplněn do glossary,
7. podle potřeby je doplněn do domain overview, event katalogu, API a testů.

Nový pojem se nesmí zavést pouze kvůli:

- názvu obrazovky,
- databázové optimalizaci,
- názvu provideru,
- dočasné implementační zkratce,
- rozdílnému překladu,
- volnému textu v AI odpovědi.

---

# 22. Otevřené terminologické otázky

Před stavem `IMPLEMENTATION_READY` je nutné rozhodnout zejména:

- zda `WorkoutDefinition` a `WorkoutTemplate` zůstanou oba samostatné pojmy,
- zda se plánovaný workout vždy reprezentuje jako `WorkoutInstance`,
- zda `ActivityRecord` zůstane samostatný technický objekt nebo pouze detail `Activity`,
- zda `TrainingPhase` bude samostatná entita nebo klasifikace bloků,
- přesný kanonický název pro change feed položku,
- přesný kanonický název pro lokálně nepotvrzenou změnu,
- zda `RecoveryState` bude persistovaný snapshot nebo pouze read model,
- zda `ReadinessAssessment` bude jediný kanonický pojem namísto obecného readiness score,
- zda `EquipmentDefinition` patří do profile, workout nebo reference-data modulu,
- zda `DataOwner` a `DataSubject` budou explicitní doménové objekty nebo pouze bezpečnostní pojmy,
- přesné hranice mezi `NotificationPreference`, reminder policy a platform permission,
- zda `CoachAthleteRelationship` bude součástí první cílové verze,
- zda `ManagedProfile` bude implementován nebo pouze ponechán jako budoucí rozšíření.

Tato rozhodnutí se mají řešit v příslušných doménových review nebo ADR, nikoli svévolnou volbou v implementaci.

---

# 23. Kritéria dokončení glossary

Glossary lze označit jako `IMPLEMENTATION_READY`, pouze pokud:

1. všechny entity a value objects používané v API mají kanonický název,
2. všechny eventy používají stejné pojmy jako doménové modely,
3. backend a mobile nepoužívají konfliktní názvy,
4. AI tool schemas používají kanonické názvy,
5. databázové názvy lze jednoznačně mapovat na doménové pojmy,
6. neexistuje nevyřešená záměna `User`, `Profile`, `Workout`, `Event`, `Metric` nebo `Change`,
7. otevřené terminologické otázky mají rozhodnutí nebo jsou explicitně odložené,
8. glossary prošel cross-document review,
9. každý nový významný pojem má vlastníka,
10. zakázaná synonyma jsou kontrolována v code review a dokumentaci.

---

# 24. Závěr

Tento glossary uzavírá základní společný jazyk doménové vrstvy AI Traineru.

Jeho hlavní struktura je:

```text
Identity / UserAccount / AthleteProfile
    ↓
UserSport / Goal
    ↓
TrainingPlan / TrainingPlanVersion
    ↓
WorkoutTemplate / WorkoutInstance / ScheduleEvent
    ↓
WorkoutSession / Activity
    ↓
MetricValue / RecoveryState / GoalProgress
    ↓
AIProposal / ChangeSet / DomainEvent
```

Nejdůležitějším pravidlem je, že obecné uživatelské slovo nemusí být vhodným technickým názvem.

Například „trénink“ může v konverzaci znamenat:

- plánovaný workout,
- probíhající session,
- dokončenou aktivitu,
- týmovou událost,
- celý dlouhodobý plán.

Technická vrstva proto musí vždy použít konkrétní kanonický pojem.

Díky tomu mohou produkt, UX, backend, mobile, AI, API, data a testy pracovat se stejným významem bez skrytých překladů a neslučitelných modelů.