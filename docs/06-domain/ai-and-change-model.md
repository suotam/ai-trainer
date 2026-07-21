# AI Trainer – AI and Change Model

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/ai-and-change-model.md`

---

# 1. Účel dokumentu

Tento dokument detailně definuje model AI konverzací, strukturovaných návrhů, nástrojů, změnových sad, potvrzování, auditu, částečného schválení a vracení změn v aplikaci AI Trainer.

Navazuje zejména na:

* `docs/01-vision/vision.md`,
* `docs/01-vision/product-principles.md`,
* `docs/02-product/product-scope.md`,
* `docs/03-users/user-scenarios.md`,
* `docs/04-ux/core-user-flows.md`,
* `docs/04-ux/information-architecture.md`,
* `docs/04-ux/screen-specifications.md`,
* `docs/06-domain/domain-overview.md`,
* `docs/06-domain/training-plan-model.md`,
* `docs/06-domain/workout-model.md`,
* `docs/06-domain/scheduling-model.md`,
* `docs/06-domain/sports-and-goals-model.md`,
* `docs/06-domain/activity-model.md`,
* `docs/06-domain/recovery-and-limitations-model.md`.

Dokument popisuje:

* AI konverzace,
* kontext AI,
* strukturované zprávy,
* návrhy změn,
* povolené nástroje,
* validační vrstvu,
* potvrzovací pravidla,
* automatické nízkorizikové akce,
* ChangeSet,
* ChangeOperation,
* částečné schválení,
* atomickou aplikaci změn,
* idempotenci,
* konflikty,
* zastaralé návrhy,
* audit,
* vracení změn,
* kompenzační změny,
* práci offline,
* bezpečnostní omezení,
* vztah AI ke zdroji pravdy.

Dokument zatím neurčuje:

* konkrétní LLM model,
* přesné systémové prompty,
* přesné JSON Schema jednotlivých nástrojů,
* konkrétní API endpointy,
* finální databázové tabulky,
* konkrétní frontendové komponenty,
* finální cenový a tokenový model.

---

# 2. Cíl modelu

Model musí umožnit, aby uživatel mohl přirozeným jazykem požádat například:

* „Vytvoř mi plán na další dva měsíce.“
* „Dnes jsem unavený, zkrať workout.“
* „Bolí mě pravý biceps, uprav dnešní trénink.“
* „O víkendu jedu na skály, přeorganizuj týden.“
* „Přesuň úterní workout na čtvrtek.“
* „Přidej mi každý pracovní den ranní mobilitu.“
* „Změň hlavní cíl z běhu na lezení.“
* „Vrať poslední změnu.“
* „Použij jen přesun workoutu, ale neodstraňuj středeční mobilitu.“

Aplikace musí z přirozeného jazyka vytvořit:

1. pochopený záměr,
2. strukturovaný návrh,
3. validované doménové operace,
4. přehled dopadů,
5. případné potvrzení,
6. bezpečně aplikovaný ChangeSet,
7. auditní historii,
8. možnost vrácení.

AI nesmí měnit data pouze tím, že v chatu tvrdí, že změnu provedla.

---

# 3. Základní principy

## 3.1 AI není zdroj pravdy

AI může:

* interpretovat,
* vysvětlovat,
* navrhovat,
* připravovat operace,
* vybírat mezi povolenými nástroji.

AI není autoritativní úložiště pro:

* cíle,
* sporty,
* workouty,
* aktivity,
* omezení,
* kalendář,
* plán,
* potvrzení,
* audit.

## 3.2 Textová odpověď a změna dat jsou oddělené

AI zpráva může říct:

> Navrhuji přesunout silový workout na čtvrtek a zrušit sobotní doplňkovou jednotku.

Skutečná změna vznikne až po:

* vytvoření AIProposal,
* validaci,
* potvrzení podle pravidel,
* vytvoření a aplikaci ChangeSet.

## 3.3 AI pracuje pouze přes povolené nástroje

AI nesmí přímo zapisovat do databáze.

Musí používat explicitně definované nástroje s:

* validovaným vstupem,
* oprávněními,
* rizikovou třídou,
* pravidly potvrzení,
* auditním záznamem.

## 3.4 Bezpečnostní a doménová pravidla mají přednost

AI návrh nesmí obejít:

* vlastnictví dat,
* aktivní omezení,
* SafetyDecision,
* odborné doporučení,
* blokující konflikt,
* verzi objektu,
* souhlas uživatele.

## 3.5 Významné změny musí být vysvětlitelné

Uživatel musí vidět:

* co se změní,
* proč,
* které objekty budou ovlivněny,
* co zůstane stejné,
* zda lze změnu vrátit.

## 3.6 Změny musí být vratné, pokud je to doménově možné

Vratnost nesmí znamenat přepis historické skutečnosti.

Vrácení změny upravuje stav systému novou auditovanou operací.

## 3.7 AI návrh má omezenou platnost

Pokud se mezitím změní relevantní data, návrh může být:

* zastaralý,
* neplatný,
* vyžadovat přepočet.

---

# 4. Hlavní doménové objekty

Oblast AI a změn obsahuje minimálně:

* AIConversation,
* AIMessage,
* AIMessageAttachment,
* AIContext,
* AIContextReference,
* AIIntent,
* AIClarificationRequest,
* AIProposal,
* AIProposalItem,
* AIProposalRevision,
* AIProposalDecision,
* AIToolDefinition,
* AIToolInvocation,
* ToolAuthorizationDecision,
* ToolValidationResult,
* ChangeSet,
* ChangeOperation,
* ChangeDependency,
* ChangeSetApproval,
* ChangeSetExecution,
* ChangeConflict,
* UndoPlan,
* UndoOperation,
* AuditRecord,
* AutomationPolicy,
* ConfirmationPolicy,
* IdempotencyKey.

---

# 5. AIConversation

## 5.1 Význam

AIConversation je logická konverzace mezi uživatelem a AI trenérem.

## 5.2 Vlastnosti

Obsahuje zejména:

* identifikátor,
* uživatele,
* název nebo téma,
* stav,
* typ,
* vytvoření,
* poslední aktivitu,
* aktivní kontext,
* související Proposal objekty,
* jazyk,
* retenční politiku.

## 5.3 Typy konverzací

* GENERAL_COACHING,
* ONBOARDING,
* WORKOUT_CONTEXT,
* DAY_CONTEXT,
* WEEK_CONTEXT,
* PLAN_CONTEXT,
* GOAL_CONTEXT,
* RECOVERY_CONTEXT,
* PAIN_CONTEXT,
* PROPOSAL_REVIEW,
* SUPPORT,
* CUSTOM.

## 5.4 Stav

* ACTIVE,
* ARCHIVED,
* CLOSED,
* DELETED,
* RETENTION_EXPIRED.

## 5.5 Jedna konverzace, více návrhů

Jedna konverzace může vytvořit více AIProposal.

Návrhy musí být samostatné objekty s vlastním stavem.

---

# 6. AIMessage

## 6.1 Význam

Jedna zpráva v AIConversation.

## 6.2 Role

* USER,
* ASSISTANT,
* SYSTEM_INTERNAL,
* TOOL,
* SAFETY,
* EVENT.

SYSTEM_INTERNAL se běžně nezobrazuje uživateli.

## 6.3 Obsah

AIMessage může obsahovat:

* text,
* strukturovaná data,
* přílohy,
* odkazy na objekty,
* náhled návrhu,
* doplňující otázku,
* technický stav.

## 6.4 Stav zprávy

* PENDING,
* STREAMING,
* COMPLETED,
* FAILED,
* CANCELLED,
* MODERATED,
* PARTIALLY_AVAILABLE.

## 6.5 Uložení

Musí být možné rozlišit:

* původní uživatelský text,
* zpracovanou strukturu,
* zobrazovaný text,
* technická metadata.

---

# 7. AIMessageAttachment

Může obsahovat:

* WorkoutCard,
* GoalCard,
* SchedulePreview,
* ChangePreview,
* ActivitySummary,
* RecoverySummary,
* ClarificationForm,
* SafetyNotice,
* ToolResultSummary.

Příloha je strukturovaná reprezentace, ne pouze renderovaný text.

---

# 8. AIContext

## 8.1 Význam

AIContext určuje, s jakými daty a v jakém rozsahu AI pracuje.

## 8.2 Obsah

* uživatel,
* časový kontext,
* aktivní objekt,
* povolené datové oblasti,
* citlivost,
* verze objektů,
* lokalita nebo časové pásmo podle potřeby,
* oprávnění,
* důvod zpracování.

## 8.3 Princip minimálního kontextu

AI má dostat pouze data nutná pro úkol.

Příklad:

Pro zkrácení dnešního workoutu nepotřebuje kompletní historii všech chatů ani celou zdravotní historii.

## 8.4 Kontext musí být explicitní

AI nesmí spoléhat na nejasný „aktuální objekt“ bez identifikátoru a verze.

---

# 9. AIContextReference

## 9.1 Význam

Odkaz na konkrétní doménový objekt použitý v konverzaci nebo návrhu.

## 9.2 Typy

* USER_PROFILE,
* USER_SPORT,
* GOAL,
* TRAINING_PLAN,
* PLAN_VERSION,
* TRAINING_WEEK,
* SCHEDULE_EVENT,
* WORKOUT_INSTANCE,
* WORKOUT_SESSION,
* ACTIVITY,
* DAILY_CHECK_IN,
* PAIN_REPORT,
* LIMITATION,
* AI_PROPOSAL,
* CHANGE_SET.

## 9.3 Vlastnosti

* typ objektu,
* identifikátor,
* verze,
* role v kontextu,
* čas načtení,
* citlivost,
* stav dostupnosti.

---

# 10. AIIntent

## 10.1 Význam

Strukturovaná interpretace toho, co uživatel požaduje.

## 10.2 Typy záměrů

* ASK_INFORMATION,
* EXPLAIN_PLAN,
* CREATE_PLAN,
* MODIFY_PLAN,
* CREATE_WORKOUT,
* MODIFY_WORKOUT,
* RESCHEDULE_EVENT,
* ADD_EVENT,
* CANCEL_EVENT,
* CREATE_GOAL,
* MODIFY_GOAL,
* REPORT_FATIGUE,
* REPORT_PAIN,
* ADAPT_FOR_RECOVERY,
* RECORD_ACTIVITY,
* REVIEW_PROGRESS,
* UNDO_CHANGE,
* MANAGE_PROFILE,
* CONNECT_INTEGRATION,
* UNKNOWN.

## 10.3 Vlastnosti

* typ,
* entity,
* časový rozsah,
* očekávaný výsledek,
* jistotu,
* chybějící data,
* rizikovou třídu.

## 10.4 Jeden vstup může obsahovat více záměrů

Příklad:

> O víkendu jedu lézt, přesuň páteční shyby a přidej pondělní mobilitu.

Obsahuje:

* ADD_EVENT,
* RESCHEDULE_EVENT,
* ADD_WORKOUT nebo ADD_EVENT.

---

# 11. AIClarificationRequest

## 11.1 Význam

Strukturovaná žádost o doplnění informace.

## 11.2 Použití

Pouze pokud bez informace nelze bezpečně nebo smysluplně pokračovat.

## 11.3 Obsah

* otázku,
* důvod,
* očekávaný datový typ,
* možnosti,
* povinnost,
* související intent.

## 11.4 Příklad

> Který víkend máš na mysli?

Nebo:

> Je bolest přítomná i v klidu?

---

# 12. AIProposal

## 12.1 Význam

AIProposal je strukturovaný návrh jedné logické změny nebo skupiny změn.

## 12.2 Obsah

* identifikátor,
* uživatele,
* typ,
* název,
* shrnutí,
* důvod,
* zdrojový intent,
* vstupní kontext,
* referenční verze,
* navržené položky,
* dopady,
* rizika,
* kompromisy,
* stav,
* platnost,
* potřebu potvrzení,
* vazbu na ChangeSet,
* vytvořeno kdy,
* vytvořeno jakým modelem nebo službou.

## 12.3 Proposal není ChangeSet

AIProposal popisuje produktový návrh.

ChangeSet popisuje konkrétní technicky a doménově validované změny.

Proposal může být převeden na ChangeSet až po validaci.

---

# 13. AIProposalType

Minimálně:

* TRAINING_PLAN_CREATION,
* TRAINING_PLAN_REVISION,
* WEEK_REORGANIZATION,
* WORKOUT_ADAPTATION,
* WORKOUT_REPLACEMENT,
* EVENT_RESCHEDULE,
* EVENT_CREATION,
* EVENT_CANCELLATION,
* GOAL_CREATION,
* GOAL_REVISION,
* RECOVERY_ADJUSTMENT,
* LIMITATION_CREATION,
* ACTIVITY_MATCH,
* DATA_CORRECTION,
* AUTOMATION_CHANGE,
* UNDO_PROPOSAL,
* CUSTOM.

---

# 14. AIProposalStatus

* DRAFT,
* NEEDS_CLARIFICATION,
* VALIDATING,
* READY_FOR_REVIEW,
* PARTIALLY_APPROVED,
* APPROVED,
* REJECTED,
* APPLYING,
* APPLIED,
* PARTIALLY_APPLIED,
* FAILED,
* STALE,
* EXPIRED,
* INVALID,
* REVERTED,
* SUPERSEDED.

## 14.1 STALE

Relevantní objekt se změnil od vytvoření návrhu.

## 14.2 SUPERSEDED

Návrh byl nahrazen novější verzí.

## 14.3 PARTIALLY_APPLIED

Pouze část schválených operací byla úspěšně aplikována.

Tento stav musí být řešen výjimečně a transparentně.

---

# 15. AIProposalItem

## 15.1 Význam

Jedna uživatelsky srozumitelná položka návrhu.

## 15.2 Příklady

* Přesuň Upper Body A z pátku na čtvrtek.
* Zruš sobotní accessory workout.
* Přidej pondělní regeneraci.
* Sniž počet sérií shybů ze čtyř na dvě.

## 15.3 Vlastnosti

* identifikátor,
* typ,
* cílový objekt,
* původní stav,
* navržený stav,
* důvod,
* závislosti,
* riziko,
* potvrzovací stav,
* mapování na ChangeOperation.

## 15.4 Samostatná schvalovatelnost

Položka musí uvádět, zda ji lze schválit samostatně.

Některé položky jsou závislé.

---

# 16. AIProposalRevision

## 16.1 Význam

Neměnná verze návrhu.

Vzniká při:

* doplnění údajů,
* úpravě uživatelem,
* přepočtu kvůli novým datům,
* změně části návrhu,
* znovuvalidaci.

## 16.2 Pravidlo

Schválení se vždy vztahuje ke konkrétní revizi návrhu.

---

# 17. AIProposalDecision

## 17.1 Význam

Rozhodnutí uživatele o návrhu nebo jeho části.

## 17.2 Typy

* APPROVE_ALL,
* APPROVE_SELECTED,
* REJECT_ALL,
* REJECT_SELECTED,
* REQUEST_CHANGES,
* DEFER,
* CANCEL.

## 17.3 Obsah

* uživatele,
* proposal revision,
* vybrané položky,
* čas,
* případný komentář,
* potvrzovací kontext.

---

# 18. AIToolDefinition

## 18.1 Význam

Definice jedné povolené akce, kterou může AI navrhnout nebo vyvolat.

## 18.2 Vlastnosti

* název,
* verze,
* popis,
* vstupní schéma,
* výstupní schéma,
* doménová služba,
* potřebná oprávnění,
* riziková třída,
* confirmation policy,
* idempotence,
* offline dostupnost,
* citlivá data,
* validační pravidla.

## 18.3 Příklady nástrojů

* get_today_context,
* get_week_schedule,
* get_workout_detail,
* draft_training_plan,
* propose_workout_shortening,
* propose_exercise_replacement,
* propose_event_reschedule,
* propose_week_reorganization,
* create_goal_draft,
* report_pain_structured,
* create_temporary_limitation_draft,
* validate_change_set,
* apply_change_set,
* revert_change_set.

## 18.4 Read tools a write tools

### Read tools

Pouze načítají data.

### Proposal tools

Vytvářejí návrh, ale nemění zdroj pravdy.

### Write tools

Aplikují schválené a validované změny.

AI nemá běžně volat write tool bez potvrzovací vrstvy.

---

# 19. ToolRiskLevel

* READ_ONLY,
* LOW,
* MEDIUM,
* HIGH,
* CRITICAL.

## 19.1 READ_ONLY

Například načtení dnešního plánu.

## 19.2 LOW

Například změna notifikace nebo přesun volitelného mikro-workoutu v povoleném okně.

## 19.3 MEDIUM

Změna jedné workout instance nebo jedné kalendářní události.

## 19.4 HIGH

Reorganizace týdne, změna cíle, vytvoření omezení.

## 19.5 CRITICAL

Akce dotýkající se blokujících bezpečnostních pravidel nebo citlivých oprávnění.

CRITICAL akce AI nesmí automaticky provést.

---

# 20. AIToolInvocation

## 20.1 Význam

Konkrétní pokus o použití nástroje.

## 20.2 Obsah

* tool definition,
* verze,
* vstup,
* kontext,
* uživatele,
* proposal,
* čas,
* stav,
* validační výsledek,
* autorizační výsledek,
* výstup,
* chyba,
* idempotency key,
* audit reference.

## 20.3 Stav

* CREATED,
* AUTHORIZING,
* VALIDATING,
* READY,
* EXECUTING,
* SUCCEEDED,
* FAILED,
* REJECTED,
* CANCELLED,
* DUPLICATE,
* EXPIRED.

---

# 21. ToolAuthorizationDecision

## 21.1 Význam

Rozhodnutí, zda je nástroj povolen v konkrétním kontextu.

## 21.2 Kontroly

* uživatel vlastní objekty,
* scope oprávnění,
* citlivá data,
* aktivní souhlas,
* role nástroje,
* confirmation policy,
* bezpečnostní blokace,
* stav účtu.

## 21.3 Výsledek

* ALLOW,
* ALLOW_AFTER_CONFIRMATION,
* DENY,
* REQUIRE_REAUTHENTICATION,
* REQUIRE_ADDITIONAL_CONSENT.

---

# 22. ToolValidationResult

## 22.1 Význam

Výsledek doménové a technické validace vstupu nebo návrhu.

## 22.2 Obsah

* validní ano/ne,
* chyby,
* varování,
* konflikty,
* automaticky opravitelné problémy,
* potřebné doplnění,
* verze validačních pravidel.

---

# 23. ConfirmationPolicy

## 23.1 Význam

Určuje, kdy se akce smí provést automaticky a kdy vyžaduje potvrzení.

## 23.2 Vstupy

* riziková třída,
* rozsah,
* počet objektů,
* typ dat,
* bezpečnost,
* vratnost,
* AutomationPreference,
* uživatelský záměr,
* explicitnost příkazu.

## 23.3 Typy potvrzení

* NONE,
* IMPLICIT_IN_CURRENT_ACTION,
* SINGLE_CONFIRMATION,
* DETAILED_REVIEW,
* REAUTHENTICATION,
* NOT_ALLOWED_AUTOMATICALLY.

## 23.4 IMPLICIT_IN_CURRENT_ACTION

Použitelné pouze tehdy, když uživatel explicitně zadal jednoduchý a jednoznačný příkaz.

Příklad:

> Přesuň dnešní mobilitu na 20:00.

Při absenci konfliktu může být potvrzení součástí stejné akce.

## 23.5 DETAILED_REVIEW

Nutné při změně více objektů nebo významném dopadu.

---

# 24. Akce, které obvykle nevyžadují potvrzení

Pouze za splnění pravidel:

* načtení dat,
* vysvětlení,
* výpočet náhledu,
* vytvoření konceptu,
* změna neinvazivní preference,
* odložení notifikace,
* drobný přesun flexibilní volitelné aktivity v předem povoleném okně.

---

# 25. Akce, které vyžadují potvrzení

Zejména:

* vytvoření aktivního plánu,
* změna více dnů,
* zrušení workoutu,
* přesun pevné události,
* změna hlavního cíle,
* vytvoření Limitation,
* výrazná změna zátěže,
* změna recurrence série,
* připojení integrace,
* práce s citlivými oprávněními,
* smazání nebo archivace významných dat.

---

# 26. Akce, které AI nesmí automaticky provést

* zrušení celého aktivního plánu,
* změna odborného omezení,
* odstranění bezpečnostní blokace,
* smazání historické Activity,
* změna cíle na bezpečnostně nevhodný,
* zvýšení zátěže navzdory blokujícímu SafetyDecision,
* smazání účtu,
* odvolání právního souhlasu bez explicitní akce uživatele.

---

# 27. AutomationPolicy

## 27.1 Význam

Uživatelské a systémové nastavení povolené automatizace.

## 27.2 Vlastnosti

* typ akce,
* maximální rozsah,
* povolené objekty,
* časové omezení,
* rizikový limit,
* vratnost,
* notifikace po provedení,
* stav.

## 27.3 Příklady

Uživatel může povolit:

* přesun flexibilních mikro-workoutů v rámci dne,
* automatické zrušení zastaralé notifikace,
* snížení volitelné accessory části při nedostatku času.

Nemůže povolit neomezenou automatickou změnu všech cílů a plánů bez kontroly.

---

# 28. ChangeSet

## 28.1 Význam

ChangeSet je skupina konkrétních doménových změn prováděných jako jedna logická akce.

## 28.2 Obsah

* identifikátor,
* uživatele,
* název,
* důvod,
* zdroj,
* stav,
* vytvoření,
* proposal,
* operace,
* závislosti,
* referenční verze,
* validační stav,
* schválení,
* execution,
* vratnost,
* audit.

## 28.3 Zdroj

* USER_DIRECT,
* AI_PROPOSAL,
* SYSTEM_RULE,
* AUTOMATION,
* IMPORT,
* ADMINISTRATIVE,
* UNDO.

## 28.4 ChangeSet je doménová transakce

Má zajistit, že skupina souvisejících změn nevytvoří nekonzistentní stav.

---

# 29. ChangeSetStatus

* DRAFT,
* VALIDATING,
* INVALID,
* READY_FOR_APPROVAL,
* PARTIALLY_APPROVED,
* APPROVED,
* EXECUTING,
* APPLIED,
* PARTIALLY_APPLIED,
* FAILED,
* REVERTING,
* REVERTED,
* NON_REVERSIBLE,
* STALE,
* CANCELLED.

---

# 30. ChangeOperation

## 30.1 Význam

Jedna atomická změna v ChangeSet.

## 30.2 Typy

* CREATE,
* UPDATE,
* MOVE,
* RESCHEDULE,
* CANCEL,
* SKIP,
* REPLACE,
* ARCHIVE,
* RESTORE,
* LINK,
* UNLINK,
* ACTIVATE,
* PAUSE,
* COMPLETE,
* CHANGE_STATUS,
* CUSTOM_COMMAND.

## 30.3 Vlastnosti

* identifikátor,
* pořadí,
* typ objektu,
* identifikátor objektu,
* očekávanou verzi,
* původní hodnotu,
* novou hodnotu,
* příkaz,
* závislosti,
* stav,
* vratnost,
* validační výsledek,
* výsledek aplikace.

## 30.4 Operace nesmí obsahovat neomezený patch bez schématu

Změna musí být typově validovatelná.

---

# 31. ChangeDependency

## 31.1 Význam

Závislost mezi operacemi.

## 31.2 Typy

* REQUIRES_SUCCESS,
* MUST_RUN_BEFORE,
* MUST_RUN_AFTER,
* MUTUALLY_EXCLUSIVE,
* COMPENSATES,
* OPTIONAL_DEPENDENCY.

## 31.3 Příklad

Přidání pondělní regenerace může záviset na úspěšném přesunu nedělního workoutu.

---

# 32. Atomická aplikace

## 32.1 Ideální chování

Všechny povinné operace ChangeSet:

* uspějí,
* nebo se žádná neprojeví.

## 32.2 Distribuované systémy

Pokud úplná databázová transakce není možná, použije se:

* saga,
* kompenzační operace,
* přesný stav každé operace,
* bezpečné obnovení.

## 32.3 Uživatel nesmí vidět falešné potvrzení

Aplikace nesmí oznámit úspěch, pokud část povinných změn selhala.

---

# 33. ChangeSetApproval

## 33.1 Význam

Schválení konkrétní verze ChangeSet.

## 33.2 Obsah

* uživatele,
* ChangeSet,
* verzi,
* schválené operace,
* odmítnuté operace,
* čas,
* typ potvrzení,
* platnost,
* reautentizaci podle potřeby.

## 33.3 Změna po schválení

Pokud se ChangeSet po schválení změní, schválení přestává platit.

---

# 34. Částečné schválení

## 34.1 Příklad

Návrh obsahuje:

1. přesun pátečního workoutu,
2. zrušení sobotního workoutu,
3. přidání pondělní regenerace.

Uživatel schválí pouze body 1 a 3.

## 34.2 Proces

1. označí se schválené položky,
2. vytvoří se nový finální ChangeSet nebo revize,
3. znovu se vyhodnotí závislosti,
4. znovu se validují konflikty,
5. zobrazí se aktualizovaný dopad,
6. změny se aplikují.

## 34.3 Nelze slepě odstranit odmítnutou operaci

Odmítnutí jedné položky může způsobit, že jiná položka přestane být validní.

---

# 35. ChangeSetExecution

## 35.1 Význam

Záznam jednoho pokusu o aplikaci ChangeSet.

## 35.2 Obsah

* execution id,
* začátek,
* konec,
* stav,
* operace,
* chyby,
* retry count,
* idempotency key,
* kompenzace,
* technický kontext.

## 35.3 Více pokusů

Jeden ChangeSet může mít více execution pokusů.

Výsledek musí zůstat idempotentní.

---

# 36. IdempotencyKey

## 36.1 Význam

Stabilní identifikátor příkazu nebo operace zabraňující duplicitnímu provedení.

## 36.2 Použití

* apply_change_set,
* create_event,
* create_workout,
* approve_proposal,
* revert_change_set,
* offline synchronizace.

## 36.3 Pravidlo

Opakované zpracování stejného klíče musí vrátit stejný logický výsledek nebo existující stav.

---

# 37. Optimistic concurrency

Každá operace měnící existující objekt musí uvést:

* očekávanou verzi,
* nebo jiný concurrency token.

Pokud se objekt změnil:

* operace se neaplikuje slepě,
* vznikne ChangeConflict nebo STALE stav,
* návrh se přepočítá.

---

# 38. ChangeConflict

## 38.1 Význam

Konflikt mezi navrženou změnou a aktuálním stavem.

## 38.2 Typy

* VERSION_MISMATCH,
* OBJECT_DELETED,
* OBJECT_COMPLETED,
* TIME_CONFLICT,
* SAFETY_CONFLICT,
* PERMISSION_CONFLICT,
* DEPENDENCY_CONFLICT,
* DUPLICATE_OPERATION,
* EXTERNAL_SYNC_CONFLICT,
* USER_EDIT_CONFLICT.

## 38.3 Výsledek

* automaticky přepočítat,
* nabídnout porovnání,
* vyžádat nové potvrzení,
* návrh zneplatnit,
* část změn zachovat.

---

# 39. Zastaralý návrh

AIProposal nebo ChangeSet se označí jako STALE, pokud:

* se změnil cílový workout,
* se změnil kalendář,
* vzniklo nové omezení,
* workout byl dokončen,
* změnila se verze plánu,
* změnil se cíl,
* uplynula platnost readiness assessmentu.

Stale návrh se nesmí automaticky aplikovat.

---

# 40. Revalidace návrhu

Revalidace musí:

1. načíst aktuální verze objektů,
2. znovu vyhodnotit pravidla,
3. znovu detekovat konflikty,
4. upravit dopady,
5. vytvořit novou ProposalRevision,
6. zrušit staré schválení.

---

# 41. AuditRecord

## 41.1 Význam

Neměnný záznam významné akce.

## 41.2 Obsah

* čas,
* uživatele,
* aktéra,
* zdroj,
* objekt,
* operaci,
* původní stav nebo bezpečný odkaz,
* nový stav nebo bezpečný odkaz,
* důvod,
* proposal,
* ChangeSet,
* potvrzení,
* výsledek,
* zařízení nebo službu,
* verzi pravidel.

## 41.3 Aktér

* USER,
* AI,
* SYSTEM,
* AUTOMATION,
* IMPORT,
* ADMINISTRATOR,
* EXTERNAL_PROVIDER.

---

# 42. Audit versus produktová historie

Audit může obsahovat technicky přesnější data.

Produktová historie musí být:

* srozumitelná,
* stručná,
* bezpečná,
* bez interního technického žargonu.

Příklad produktové historie:

> 21. července: Upper Body A přesunut z pátku na čtvrtek kvůli lezeckému víkendu.

---

# 43. UndoPlan

## 43.1 Význam

Strukturovaný plán, jak vrátit ChangeSet.

## 43.2 Obsah

* původní ChangeSet,
* vratné operace,
* nevratné operace,
* závislosti,
* aktuální konflikty,
* kompenzační operace,
* dopad,
* potřebu potvrzení.

## 43.3 Undo není smazání historie

Vrácení vytvoří nový ChangeSet typu UNDO nebo COMPENSATION.

---

# 44. UndoOperation

## 44.1 Typy

* RESTORE_PREVIOUS_VALUE,
* MOVE_BACK,
* RECREATE_CANCELLED_OBJECT,
* REACTIVATE,
* REMOVE_CREATED_OBJECT,
* UNLINK,
* COMPENSATE,
* MANUAL_REVIEW_REQUIRED.

## 44.2 Omezení

Dokončená Activity se nesmí odstranit jen proto, že se vrací plánovací změna.

---

# 45. Vratnost

Každá operace má vratnost:

* FULLY_REVERSIBLE,
* REVERSIBLE_WITH_CONDITIONS,
* COMPENSATABLE,
* NON_REVERSIBLE,
* UNKNOWN.

## 45.1 FULLY_REVERSIBLE

Například přesun budoucí flexibilní události, pokud nedošlo k dalším změnám.

## 45.2 COMPENSATABLE

Nelze obnovit přesně původní stav, ale lze vytvořit odpovídající náhradní změnu.

## 45.3 NON_REVERSIBLE

Například externí akce, kterou poskytovatel neumožňuje vrátit.

---

# 46. Vrácení změny s novějšími závislostmi

Příklad:

1. workout byl přesunut,
2. následně byl upraven,
3. uživatel chce vrátit původní přesun.

Systém musí:

* zjistit závislosti,
* nabídnout nový bezpečný termín,
* nebo vrácení odmítnout,
* nezničit novější úpravy.

---

# 47. Vracení části ChangeSet

Je možné pouze pokud:

* operace jsou oddělitelné,
* nejsou porušeny závislosti,
* výsledek projde validací.

Jinak se vytvoří kompenzační návrh.

---

# 48. AI vysvětlení návrhu

AI může generovat vysvětlení, ale strukturovaný základ musí pocházet z Proposal a validačních výsledků.

Vysvětlení musí rozlišit:

* fakta,
* odhad,
* doporučení,
* nejistotu,
* bezpečnostní pravidlo.

---

# 49. Zakázané AI formulace

AI nesmí tvrdit:

* „Hotovo“, pokud ChangeSet nebyl aplikován.
* „Bezpečně jsem odstranil bolestivý cvik“, pokud nebyla provedena validace.
* „Tvůj plán je aktualizovaný“, pokud návrh čeká na potvrzení.
* „Vrátil jsem změnu“, pokud UndoExecution selhal.

---

# 50. Stavová formulace

Doporučené rozlišení:

## Návrh

> Navrhuji přesunout workout na čtvrtek.

## Čeká na potvrzení

> Změna je připravená ke kontrole.

## Aplikuje se

> Změny se právě zapisují.

## Provedeno

> Workout byl přesunut na čtvrtek.

## Částečné selhání

> Dvě změny se provedly, jedna se nepodařila. Plán nebyl ponechán v nekonzistentním stavu.

---

# 51. AI a safety

AI nesmí:

* přepisovat SafetyDecision,
* deaktivovat aktivní omezení,
* zlehčovat varovné příznaky,
* vytvořit workout porušující blokující LimitationRule.

AI může:

* vysvětlit blokaci,
* navrhnout povolené alternativy,
* vyžádat doplnění,
* vytvořit návrh odborné konzultace.

---

# 52. AI a citlivá data

## 52.1 Minimalizace

Do AI kontextu se posílají jen potřebná data.

## 52.2 Příklad

Pro úpravu workoutu kvůli bicepsu:

* aktuální PainReport,
* aktivní omezení,
* dnešní workout,
* relevantní workout historie.

Ne:

* kompletní export účtu,
* všechny historické konverzace,
* nesouvisející osobní údaje.

## 52.3 Audit přístupu

Citlivé AI zpracování musí být dohledatelné podle právních a bezpečnostních požadavků.

---

# 53. Uchování AI konverzací

Musí být odděleno:

* produktové uchování zpráv,
* technické logy,
* audit změn,
* model execution metadata.

Uživatel může odstranit konverzaci, ale audit významné změny může zůstat podle retenčních pravidel.

---

# 54. AIModelExecution

## 54.1 Význam

Technický záznam jednoho modelového volání.

## 54.2 Obsah

* účel,
* model,
* verze promptu,
* čas,
* latence,
* stav,
* tokeny,
* náklady,
* bezpečnostní výsledek,
* korelační identifikátor.

## 54.3 Omezení

Nemusí uchovávat celý citlivý prompt, pokud to není nutné.

---

# 55. Model fallback

Při selhání modelu může systém:

* zopakovat volání,
* použít jiný model,
* přejít na deterministickou logiku,
* nabídnout ruční formulář,
* zachovat koncept,
* neprovést žádnou změnu.

---

# 56. Nedostupná AI

Při nedostupné AI musí dále fungovat:

* kalendář,
* tracker,
* ruční úpravy,
* bezpečnostní pravidla,
* aktivní omezení,
* validace,
* aplikace již schváleného ChangeSet, pokud nepotřebuje AI.

---

# 57. Offline režim

## 57.1 Dostupné offline

* zobrazení existující konverzace z cache,
* vytvoření uživatelského textového konceptu,
* ruční změny,
* deterministické zkrácení workoutu,
* aplikace některých lokálních nízkorizikových operací,
* fronta příkazů.

## 57.2 Nedostupné nebo omezené offline

* nový komplexní AI návrh,
* plánování vyžadující serverový model,
* práce s nesynchronizovaným globálním kontextem.

## 57.3 Offline zpráva

Uživatelský prompt může být uložen k pozdějšímu odeslání.

Nesmí být prezentován jako zpracovaný.

---

# 58. Offline ChangeSet

Lokální ruční ChangeSet musí mít:

* stabilní identifikátor,
* očekávané verze objektů,
* idempotency key,
* lokální audit,
* sync status.

Po synchronizaci může vzniknout konflikt.

---

# 59. Synchronizace návrhů

AIProposal vytvořený na jednom zařízení musí být dostupný na dalších zařízeních podle stavu.

Musí být synchronizovány:

* revize,
* rozhodnutí,
* schválení,
* ChangeSet,
* výsledek aplikace.

---

# 60. Konflikt schválení na více zařízeních

Příklad:

* na telefonu uživatel návrh schválí,
* na tabletu ho odmítne.

Pravidla:

* první platné rozhodnutí může uzamknout revizi,
* pozdější rozhodnutí uvidí aktuální stav,
* nesmí vzniknout dvojí aplikace,
* audit uchová oba pokusy.

---

# 61. Konflikt aplikace

Pokud se ChangeSet aplikuje současně dvakrát:

* idempotency key zabrání duplicitě,
* druhý pokus vrátí existující výsledek,
* nevzniknou dvojité workouty nebo události.

---

# 62. Časová platnost potvrzení

Schválení může expirovat, pokud:

* návrh čeká příliš dlouho,
* změnil se relevantní objekt,
* skončila platnost readiness assessmentu,
* nastala bezpečnostní změna.

---

# 63. Návrh plánu

Při vytvoření nového plánu musí AIProposal obsahovat:

* cíle,
* období,
* bloky,
* typický týden,
* workouty,
* pevné události,
* kompromisy,
* omezení,
* potřebné potvrzení.

Po schválení:

* vytvoří se TrainingPlan,
* TrainingPlanVersion,
* WorkoutInstance,
* ScheduleEvent,
* ChangeSet a audit.

---

# 64. Úprava dnešního workoutu

Tok:

1. uživatel zadá požadavek,
2. AIIntent rozpozná MODIFY_WORKOUT,
3. načte se aktuální workout a omezení,
4. vytvoří se AIProposal,
5. WorkoutValidation zkontroluje návrh,
6. podle rizika proběhne potvrzení,
7. aplikuje se ChangeSet,
8. vznikne WorkoutInstanceRevision.

---

# 65. Úprava kvůli bolesti

Tok:

1. zpráva uživatele,
2. strukturovaný PainReport,
3. PainAssessment,
4. SafetyDecision,
5. povolené alternativy,
6. AIProposal,
7. validace,
8. potvrzení,
9. ChangeSet.

AI nesmí přeskočit PainAssessment a rovnou generovat náhradu.

---

# 66. Reorganizace týdne

Proposal musí obsahovat:

* změny jednotlivých dnů,
* pevné události,
* konflikty,
* zátěž,
* hlavní účel týdne,
* přidané a zrušené workouty,
* dopad na další týden.

Obvykle vyžaduje DETAILED_REVIEW.

---

# 67. Změna hlavního cíle

Vyžaduje:

* explicitní záměr uživatele,
* GoalRevision nebo nový Goal,
* analýzu dopadu,
* novou TrainingPlanVersion nebo nový plán,
* detailní potvrzení.

AI nesmí změnu odvodit pouze z jedné nejasné věty bez potvrzení.

---

# 68. Vytvoření dočasného omezení

AI může vytvořit pouze návrh.

Aktivace omezení obvykle vyžaduje:

* potvrzení uživatele,
* dobu platnosti,
* rozsah,
* ovlivněné pohyby,
* možnost revize.

Bezpečnostní systém může vytvořit krátkodobou blokaci konkrétního workoutu podle pravidel, ale ne permanentní zdravotní záznam bez potvrzení.

---

# 69. Přímý uživatelský příkaz

Příklad:

> Přesuň dnešní workout na 20:00.

Pokud:

* objekt je jednoznačný,
* změna je povolená,
* nevznikne konflikt,
* termín je v povoleném okně,

může systém použít IMPLICIT_IN_CURRENT_ACTION.

Stále musí vzniknout:

* validace,
* ChangeSet,
* audit,
* jasné potvrzení výsledku.

---

# 70. Nejednoznačný příkaz

Příklad:

> Přesuň trénink na večer.

Pokud jsou dnes dva tréninky, AI musí:

* použít kontext, pokud je jednoznačný,
* jinak požádat o upřesnění.

Nesmí náhodně zvolit objekt.

---

# 71. Hromadné změny

Příklad:

> Posuň všechny ranní mobility o hodinu později.

Musí se určit rozsah:

* budoucí instance,
* recurrence série,
* časové období,
* historické výskyty se nemění.

Vyžaduje náhled počtu ovlivněných položek.

---

# 72. Částečné selhání

Pokud ChangeSet obsahuje volitelné operace, může být povolen stav PARTIALLY_APPLIED.

Uživatel musí vidět:

* co se provedlo,
* co selhalo,
* proč,
* jaký je výsledný stav,
* možnosti opravy.

Povinné závislé operace nesmí skončit v tichém částečném stavu.

---

# 73. Retry policy

Opakování je vhodné pro:

* dočasný síťový problém,
* databázový timeout,
* externí integraci.

Není vhodné bez změny pro:

* doménový konflikt,
* chybné oprávnění,
* zastaralou verzi,
* blokující SafetyDecision.

---

# 74. Kompenzační změny

Pokud externí operaci nelze atomicky vrátit:

* vytvoří se kompenzační operace,
* výsledek se označí,
* uživatel je informován.

Příklad:

* interní workout byl exportován do externího kalendáře,
* druhá část změny selhala,
* exportovaná událost se musí smazat nebo upravit samostatně.

---

# 75. Historie AI akcí

Musí být oddělena od běžného chatu.

Zobrazuje:

* datum,
* název návrhu,
* změněné objekty,
* rozhodnutí,
* výsledek,
* možnost detailu,
* možnost vrácení.

---

# 76. Náhled změn

Musí umět zobrazit:

* přidáno,
* odstraněno,
* změněno,
* přesunuto,
* zkráceno,
* nahrazeno,
* nezměněno.

Nesmí spoléhat pouze na barvu.

---

# 77. Vysvětlení dopadu

Proposal musí rozlišit:

* přímý dopad,
* odvozený dopad,
* možné riziko,
* nejistotu.

Příklad:

> Přesun silového workoutu na čtvrtek zachová dva dny před nedělním zápasem. Odhad zátěže je středně jistý, protože nemáme data o intenzitě pátečního fotbalu.

---

# 78. Uživatelská úprava návrhu

Uživatel může:

* změnit čas,
* odebrat položku,
* přidat podmínku,
* požádat o lehčí variantu,
* změnit rozsah.

Vznikne nová AIProposalRevision.

---

# 79. Proposal supersession

Pokud uživatel požádá:

> Udělej raději úplně jinou variantu.

Původní proposal se označí jako SUPERSEDED.

Nemá zůstat aktivně schvalovatelný.

---

# 80. Proposal expiration

Návrh může expirovat podle typu:

* úprava dnešního workoutu rychle,
* týdenní plán po několika dnech,
* dlouhodobý plán až po významné změně vstupů.

Přesná pravidla určí ConfirmationPolicy a ProposalValidityPolicy.

---

# 81. ProposalValidityPolicy

Může zohlednit:

* čas,
* objektové verze,
* readiness validUntil,
* stav kalendáře,
* nové omezení,
* aktivní session,
* dokončení cílové události.

---

# 82. Práce s chybou AI

Pokud AI vytvoří nevalidní strukturu:

* nástroj ji odmítne,
* zaznamená chybu,
* lze požádat model o opravu,
* uživatel nedostane falešný návrh,
* zdroj pravdy se nezmění.

---

# 83. Ochrana před prompt injection

AI nesmí důvěřovat textu z:

* externích kalendářů,
* importovaných poznámek,
* příloh,
* cizích dat,

jako systémovým instrukcím.

Externí obsah je datový vstup, nikoliv instrukční autorita.

---

# 84. Oprávnění mezi uživateli

Veškeré tool operace musí znovu ověřit vlastnictví.

Nestačí spoléhat na to, že model použil správný identifikátor.

---

# 85. Citlivé write tools

Nástroje pro:

* smazání,
* export,
* integrace,
* omezení,
* účet,
* souhlasy,

musí mít přísnější authorizační a potvrzovací pravidla.

---

# 86. AI a externí integrace

AI může navrhnout:

* připojit kalendář,
* importovat wearable data,
* změnit synchronizační rozsah.

Nemůže bez uživatelského souhlasu:

* připojit účet,
* rozšířit oprávnění,
* odesílat data externě,
* odpojit službu.

---

# 87. AI a notifikace

Nízkorizikové změny notifikací mohou být automatizované podle preference.

Příklad:

> Připomeň mi zítřejší workout o hodinu dřív.

Stále vzniká auditovaný ChangeSet.

---

# 88. AI a dokončené aktivity

AI nesmí přepisovat historickou skutečnost.

Může:

* navrhnout opravu,
* navrhnout změnu párování,
* přidat uživatelský komentář,
* přepočítat odvozené metriky.

---

# 89. AI a plánované aktivity v minulosti

Pokud je událost v minulosti:

* nemá být běžně přesouvána jako budoucí,
* může být označena jako skipped,
* může být spárována s Activity,
* může být auditovaně opravena.

---

# 90. Doménové služby

## 90.1 AIOrchestrationService

Řídí:

* kontext,
* model execution,
* nástroje,
* proposal lifecycle.

## 90.2 ProposalService

Spravuje:

* vytvoření,
* revize,
* stav,
* platnost,
* rozhodnutí.

## 90.3 ToolAuthorizationService

Ověřuje:

* oprávnění,
* souhlasy,
* risk policy.

## 90.4 ChangeValidationService

Kontroluje:

* doménová pravidla,
* konflikty,
* verze,
* safety,
* závislosti.

## 90.5 ChangeExecutionService

Aplikuje:

* ChangeSet,
* idempotenci,
* transakce,
* kompenzace.

## 90.6 UndoService

Vytváří:

* UndoPlan,
* kompenzační ChangeSet,
* validační kontrolu vratnosti.

## 90.7 AuditService

Ukládá neměnné auditní záznamy.

## 90.8 ConfirmationService

Vyhodnocuje a zaznamenává potvrzení.

---

# 91. Doménové události

Minimálně:

* AIConversationCreated
* AIMessageReceived
* AIMessageGenerated
* AIIntentDetected
* AIClarificationRequested
* AIProposalCreated
* AIProposalRevised
* AIProposalValidated
* AIProposalBecameStale
* AIProposalExpired
* AIProposalApproved
* AIProposalPartiallyApproved
* AIProposalRejected
* AIToolInvocationCreated
* AIToolInvocationAuthorized
* AIToolInvocationRejected
* AIToolInvocationSucceeded
* AIToolInvocationFailed
* ChangeSetCreated
* ChangeSetValidated
* ChangeSetApproved
* ChangeSetExecutionStarted
* ChangeOperationApplied
* ChangeSetApplied
* ChangeSetPartiallyApplied
* ChangeSetFailed
* ChangeConflictDetected
* UndoPlanCreated
* ChangeSetReverted
* CompensationApplied
* ManualOverrideRecorded
* AutomationPolicyChanged

---

# 92. Příkazy

Minimálně:

* CreateAIConversation
* AddUserMessage
* GenerateAIResponse
* DetectAIIntent
* RequestClarification
* CreateAIProposal
* ReviseAIProposal
* ValidateAIProposal
* ApproveAIProposal
* ApproveSelectedProposalItems
* RejectAIProposal
* ExecuteAITool
* CreateChangeSet
* ValidateChangeSet
* ApproveChangeSet
* ApplyChangeSet
* RetryChangeSetExecution
* CancelChangeSet
* DetectChangeConflict
* RevalidateStaleProposal
* CreateUndoPlan
* RevertChangeSet
* ApplyCompensation
* UpdateAutomationPolicy
* RecordManualOverride

---

# 93. Invariance – vlastnictví

* AIConversation patří právě jednomu uživateli.
* Proposal nesmí měnit objekt jiného uživatele.
* ChangeSet musí patřit stejnému uživateli jako všechny měněné objekty.
* Tool authorization musí ověřit vlastnictví při každé write operaci.

---

# 94. Invariance – AIProposal

* Proposal musí odkazovat na konkrétní vstupní kontext a verze.
* Schválený Proposal se nesmí neviditelně změnit.
* STALE Proposal se nesmí aplikovat bez revalidace.
* Proposal nesmí tvrdit, že změna byla provedena.
* Každá významná položka musí mít důvod a dopad.

---

# 95. Invariance – nástroje

* AI smí použít pouze registrovaný AIToolDefinition.
* Vstup musí projít schema validací.
* Write tool musí projít autorizací.
* Kritická akce nesmí být provedena bez potvrzení.
* Opakované volání se stejným idempotency key nesmí vytvořit duplicitu.

---

# 96. Invariance – ChangeSet

* Každá operace musí mít typ a cílový objekt.
* Změna existujícího objektu musí ověřit verzi.
* Povinné závislé operace musí být aplikovány konzistentně.
* ChangeSet nesmí obejít doménovou validaci.
* Aplikovaný ChangeSet se nesmí přepsat; další změna vytváří nový ChangeSet.

---

# 97. Invariance – potvrzení

* Potvrzení se vztahuje ke konkrétní revizi.
* Změna po potvrzení ruší jeho platnost.
* Částečné potvrzení vyžaduje novou validaci.
* Uživatel nesmí potvrdit cizí ChangeSet.
* Kritické potvrzení může vyžadovat reautentizaci.

---

# 98. Invariance – safety

* SafetyDecision má přednost před AI návrhem.
* AI nesmí vytvořit ChangeOperation porušující blokující LimitationRule.
* Bezpečnostní blokaci nelze odstranit běžným automation policy.
* Kritická safety změna musí mít audit a verzi pravidel.

---

# 99. Invariance – undo

* Undo nesmí smazat dokončenou historickou skutečnost.
* Vrácení musí být nový auditovaný ChangeSet.
* Nelze vrátit změnu přes nekompatibilní novější stav bez řešení konfliktu.
* NON_REVERSIBLE operace musí být před potvrzením jasně označena.

---

# 100. Invariance – audit

* AuditRecord je neměnný.
* Musí zaznamenat aktéra, čas, objekt a výsledek.
* Smazání konverzace nesmí automaticky odstranit povinný audit změny.
* Audit nesmí být běžně upravitelný AI.

---

# 101. Read modely

## 101.1 AIConversationView

Obsahuje:

* zprávy,
* aktivní kontext,
* rychlé návrhy,
* čekající Proposal.

## 101.2 AIProposalDetailView

Obsahuje:

* název,
* důvod,
* položky,
* dopad,
* rizika,
* stav,
* platnost,
* potvrzovací akce.

## 101.3 ChangePreviewView

Obsahuje:

* původní stav,
* nový stav,
* přidané,
* odebrané,
* přesunuté,
* nezměněné položky.

## 101.4 ChangeHistoryView

Obsahuje:

* ChangeSet,
* zdroj,
* výsledek,
* možnost vrácení.

## 101.5 UndoPreviewView

Obsahuje:

* co lze vrátit,
* co nelze,
* nové konflikty,
* výsledný stav.

## 101.6 ToolExecutionView

Interní nebo administrativní read model pro technickou diagnostiku.

---

# 102. Příklad – zkrácení workoutu

## Vstup

> Dnes mám jen patnáct minut.

## AIIntent

* MODIFY_WORKOUT,
* časový limit 15 minut.

## Proposal

* zachovat warm-up minimum,
* zachovat dva hlavní cviky,
* snížit série,
* odstranit accessory sekci.

## Validation

* workout zůstává bezpečný,
* zachovává hlavní účel.

## Confirmation

Jedna detailní obrazovka nebo explicitní příkaz podle policy.

## ChangeSet

* UPDATE WorkoutInstance revision,
* případně UPDATE ScheduleEvent duration.

---

# 103. Příklad – lezecký víkend

## Vstup

> Od pátku do neděle jedu na skály.

## Proposal items

1. vytvořit EventGroup,
2. přidat páteční cestování,
3. přidat sobotní a nedělní lezení,
4. přesunout páteční tahový workout,
5. zrušit sobotní accessory,
6. přidat pondělní regeneraci.

## Approval

Uživatel může odmítnout zrušení sobotní accessory.

Systém musí znovu validovat zbytek.

---

# 104. Příklad – bolest bicepsu

## Vstup

> Bolí mě pravý biceps při shybech.

## Proces

* vytvořit PainReport,
* SafetyAssessment,
* Proposal pro dočasné odstranění tahových cviků,
* návrh Limitation,
* potvrzení.

## Zakázané chování

AI nesmí pouze zavolat replace_exercise bez pain flow a safety validace.

---

# 105. Příklad – přímý přesun

## Vstup

> Přesuň dnešní mobilitu z 18:00 na 20:00.

## Podmínky

* jedna jednoznačná událost,
* flexibilní,
* bez konfliktu,
* nízké riziko.

## Výsledek

* validace,
* implicitní potvrzení,
* ChangeSet,
* audit,
* zpráva o provedení.

---

# 106. Příklad – zastaralý návrh

## Stav

Proposal navrhuje přesunout páteční workout.

Mezitím uživatel workout ručně přesunul na sobotu.

## Výsledek

* VERSION_MISMATCH,
* Proposal → STALE,
* nabídka přepočítat,
* staré potvrzení neplatí.

---

# 107. Příklad – vrácení změny

## Vstup

> Vrať poslední změnu týdne.

## Proces

1. identifikovat poslední vratný ChangeSet,
2. vytvořit UndoPlan,
3. ověřit novější závislosti,
4. zobrazit dopad,
5. potvrdit,
6. aplikovat kompenzační ChangeSet.

---

# 108. Příklad – částečné schválení

Proposal:

* přesunout workout,
* snížit objem,
* zrušit mobilitu.

Uživatel schválí první dvě položky.

Výsledek:

* vytvořit finální revizi,
* znovu spočítat zátěž,
* zachovat mobilitu,
* aplikovat nový ChangeSet.

---

# 109. Příklad – nedostupná AI

Uživatel chce zkrátit workout.

AI služba nefunguje.

Aplikace může nabídnout deterministické varianty:

* 10 minut,
* 15 minut,
* 20 minut.

Po výběru vznikne běžný ChangeSet bez AIProposal nebo se zdrojem SYSTEM_RULE.

---

# 110. Příklad – konfliktní pevná událost

AI navrhne přesun workoutu na čas fotbalového zápasu.

Scheduling validation vytvoří BLOCKING conflict.

Proposal se označí INVALID nebo se přepracuje.

Uživatel nesmí dostat možnost změnu slepě potvrdit.

---

# 111. Příklad – bezpečnostní blokace

Aktivní Limitation zakazuje běh.

Uživatel požádá:

> Přidej mi dnes intervalový běh.

AI může:

* vysvětlit konflikt,
* nabídnout povolenou alternativu,
* požádat o aktualizaci omezení.

Nesmí vytvořit aktivní běžecký workout.

---

# 112. Co musí být strukturované

Nesmí zůstat pouze jako text:

* intent,
* kontext,
* proposal,
* položky návrhu,
* cílové objekty,
* původní a nový stav,
* riziko,
* potvrzení,
* ChangeSet,
* operace,
* závislosti,
* validační stav,
* konflikt,
* audit,
* vratnost,
* undo.

Volný text může doplňovat:

* vysvětlení,
* uživatelský důvod,
* původní prompt,
* komentář k rozhodnutí.

---

# 113. Otevřené otázky

* Jak přesně oddělit AIProposal od ChangeSet v API?
* Jaký maximální počet položek smí obsahovat jeden Proposal?
* Kdy vytvořit nový Proposal a kdy novou ProposalRevision?
* Jak dlouho uchovávat AI zprávy?
* Která metadata model execution ukládat?
* Jak přesně definovat ToolRiskLevel?
* Které jednoduché příkazy mohou používat implicitní potvrzení?
* Jak reprezentovat diff složitých workout struktur?
* Jak zobrazovat závislosti při částečném schválení?
* Jak řešit atomickou změnu přes více mikroservis?
* Jaký saga pattern použít?
* Jak dlouho držet idempotency klíče?
* Jak řešit retry externích integrací?
* Jak verzovat tool schema?
* Jak zachovat kompatibilitu starých Proposal?
* Jak řešit Proposal vytvořený starší verzí aplikace?
* Jak přesně zjišťovat stale stav?
* Jak dlouho může potvrzení zůstat platné?
* Jaké akce vyžadují reautentizaci?
* Jak zobrazit částečné selhání jednoduše?
* Jaké operace budou plně vratné?
* Jak reprezentovat kompenzační změnu?
* Jak řešit několik navazujících undo?
* Jak zabránit kruhovým undo operacím?
* Jak řešit smazanou konverzaci s aktivním Proposal?
* Jaké citlivé údaje lze poslat modelu?
* Jak minimalizovat prompt injection z externích dat?
* Jak oddělit uživatelský text od systémových instrukcí?
* Jak testovat AI tool usage deterministicky?
* Jaký bude fallback bez AI?
* Jak řešit offline frontu uživatelských promptů?
* Jak zachovat správné pořadí změn z více zařízení?
* Jak funguje zamykání Proposal během potvrzení?
* Jak pracovat s hlasovým příkazem a jeho potvrzením?
* Jak řešit automatické změny a následnou notifikaci?
* Jak přesně auditovat modelové rozhodování bez ukládání chain-of-thought?
* Jak vysvětlit důvod návrhu bez odhalování interního uvažování modelu?
* Jak umožnit budoucím trenérům navrhovat stejné ChangeSet jako AI?
* Jak řešit administrativní opravy?
* Jak exportovat historii AI změn?
* Jak mazat AI data při zachování právně nutného auditu?

---

# 114. Navazující dokumenty

Na tento dokument musí navázat zejména:

```text
docs/06-domain/
├── metrics-model.md
├── integration-model.md
├── sync-and-offline-model.md
├── identity-and-profile-model.md
├── domain-events.md
├── domain-invariants.md
└── glossary.md
```

Dále:

```text
docs/05-ai/
├── ai-architecture.md
├── ai-tools.md
├── confirmation-policy.md
├── context-management.md
├── safety-rules.md
├── proposal-generation.md
├── structured-output-contracts.md
├── prompt-injection-protection.md
└── evaluation-strategy.md
```

A:

```text
docs/07-backend/
├── ai-orchestration-service.md
├── change-service.md
├── audit-service.md
├── tool-execution-service.md
├── idempotency.md
├── saga-and-compensation.md
└── api-contracts.md
```

A:

```text
docs/08-mobile/
├── ai-chat-architecture.md
├── proposal-review-ui.md
├── change-preview-ui.md
├── offline-ai-state.md
└── undo-ui.md
```

---

# 115. Kritéria správného modelu

Model je vhodný pouze tehdy, pokud umožní:

1. vést běžnou AI konverzaci,
2. připojit kontext workoutu nebo týdne,
3. rozpoznat strukturovaný záměr,
4. vyžádat pouze nutné doplnění,
5. vytvořit strukturovaný Proposal,
6. zobrazit konkrétní dopady,
7. validovat návrh,
8. zablokovat nebezpečnou změnu,
9. vyžádat potvrzení podle rizika,
10. provést jednoduchý explicitní příkaz,
11. částečně schválit návrh,
12. znovu validovat částečný výběr,
13. vytvořit ChangeSet,
14. aplikovat změny atomicky nebo kompenzačně,
15. zachovat idempotenci,
16. detekovat zastaralý návrh,
17. řešit konflikty verzí,
18. uchovat audit,
19. rozlišit text a skutečnou změnu,
20. vrátit změnu,
21. zachovat dokončenou historii,
22. pracovat s bezpečnostními omezeními,
23. minimalizovat citlivý kontext,
24. fungovat při nedostupné AI,
25. podporovat ruční fallback,
26. synchronizovat více zařízení,
27. zabránit dvojímu provedení,
28. chránit před prompt injection,
29. podporovat nové nástroje verzovaně,
30. vysvětlit uživateli, co se stalo.

---

# 116. Závěr

AI and Change model je spojovací vrstva mezi přirozenou komunikací a skutečným stavem aplikace.

Jeho základní tok je:

```text
Uživatelská zpráva
    ↓
AIIntent
    ↓
AIContext
    ↓
AIProposal
    ↓
AIToolInvocation
    ↓
Doménová validace
    ↓
ConfirmationPolicy
    ↓
ChangeSet
    ↓
ChangeOperation
    ↓
Aplikace změny
    ↓
AuditRecord
    ↓
Možnost Undo
```

Bezpečnostní tok je:

```text
AIProposal
    ↓
ToolAuthorizationDecision
    ↓
ToolValidationResult
    ↓
SafetyDecision / LimitationRule
    ↓
Povolit / Upravit / Odmítnout
```

Vratný tok je:

```text
Applied ChangeSet
    ↓
UndoPlan
    ↓
Validace aktuálního stavu
    ↓
Compensating ChangeSet
    ↓
Reverted nebo částečně kompenzovaný stav
```

Hlavním cílem je, aby uživatel mohl aplikaci ovládat přirozeným jazykem, aniž by AI obcházela běžná pravidla aplikace.

AI může být inteligentní a flexibilní.

Samotné změny však musí být:

* strukturované,
* validované,
* autorizované,
* potvrzené podle rizika,
* idempotentní,
* auditované,
* pokud možno vratné.

Díky tomu může uživatel napsat:

> Jedu o víkendu na skály, uprav mi podle toho celý týden, ale pondělní mobilitu nech.

A aplikace dokáže vytvořit konkrétní návrh, umožnit částečné schválení, bezpečně změnit kalendář a workouty, uchovat historii a případně celou změnu později vrátit.
