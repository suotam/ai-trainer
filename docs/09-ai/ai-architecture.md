# AI Trainer – AI Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/09-ai/ai-architecture.md`  
**Vlastník:** AI Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/01-vision/product-principles.md`, `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/06-domain/ai-and-change-model.md`, `docs/06-domain/recovery-and-limitations-model.md`, `docs/06-domain/domain-invariants.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/data-architecture.md`  
**Navazující dokumenty:** model-selection ADR, provider abstraction, prompt architecture, context builder, structured output contracts, AI tool contracts, confirmation policy, AI safety, prompt-injection protection, cost policy, evaluation strategy, AI observability, security architecture  
**Vlastněné kontrakty:** AI runtime vrstvy, orchestrace modelových volání, sestavení kontextu, provider abstraction, strukturované výstupy, tool execution boundary, bezpečnostní brány, fallbacky, nákladové řízení a AI observabilita

---

# 1. Účel dokumentu

Tento dokument definuje cílovou runtime architekturu AI vrstvy aplikace AI Trainer.

Doménový význam `AIConversation`, `AIProposal`, `ChangeSet`, `ChangeOperation`, `ConfirmationPolicy` a souvisejících objektů vlastní `docs/06-domain/ai-and-change-model.md`. Tento dokument neurčuje nový doménový význam. Určuje, jak backend a mobilní klient bezpečně používají jazykové a další AI modely k:

- porozumění přirozenému jazyku,
- přípravě strukturovaných návrhů,
- vysvětlování plánu a dat,
- personalizaci komunikace,
- výběru povolených nástrojů,
- tvorbě návrhů workoutů a plánů,
- práci s recovery kontextem,
- bezpečnému degradovanému provozu.

AI vrstva nesmí být autoritativním zdrojem doménových dat ani alternativní business vrstvou.

Dokument neurčuje konkrétního poskytovatele, model, SDK ani cenu. Tyto volby musí být potvrzeny v ADR a pravidelně přehodnocovány.

---

# 2. Základní architektonické cíle

AI architektura musí:

1. zachovat `INV-001` až `INV-100`,
2. nikdy neposkytnout modelu přímý zápis do databáze,
3. oddělit generovaný text od skutečné doménové změny,
4. používat pouze verzované a autorizované nástroje,
5. minimalizovat citlivý kontext,
6. umožnit změnu poskytovatele nebo modelu bez změny domény,
7. poskytovat strukturované a validovatelné výstupy,
8. mít deterministické guardrails mimo LLM,
9. podporovat fallback při výpadku nebo nízké kvalitě modelu,
10. auditovat modelové rozhodovací artefakty bez ukládání soukromého chain-of-thought,
11. řídit latenci, tokeny a náklady,
12. umožnit offline fungování kritických ne-AI funkcí,
13. podporovat průběžnou evaluaci kvality a bezpečnosti,
14. zabránit cross-profile a cross-tenant úniku kontextu,
15. být implementovatelná po postupných vertikálních řezech.

---

# 3. Hlavní runtime tok

```text
User input / system trigger
        ↓
Request classification
        ↓
Authorization and consent pre-check
        ↓
Context plan
        ↓
Context Builder
        ↓
Prompt / instruction assembly
        ↓
Model Gateway
        ↓
Structured response and optional tool requests
        ↓
Schema validation
        ↓
Policy and safety validation
        ↓
AIProposal or informational response
        ↓
ConfirmationPolicy
        ↓
ChangeSet application through application services
        ↓
Audit, events and user-visible result
```

Modelové volání není samo o sobě doménovou změnou.

---

# 4. Logické komponenty

## 4.1 AI Entry Point

Přijímá autorizovaný aplikační požadavek, například:

- novou zprávu v AIConversation,
- žádost o úpravu workoutu,
- žádost o vysvětlení plánu,
- plánovací workflow,
- systémově povolený proaktivní návrh.

Entry point ověřuje:

- actor a active AthleteProfile,
- oprávnění,
- účel,
- consent,
- rate a abuse limity,
- požadovaný AI capability.

## 4.2 Request Classifier

Určuje zejména:

- informační dotaz,
- návrh změny,
- plánování,
- workout adaptaci,
- recovery dotaz,
- pain nebo safety kontext,
- podporu nebo nesouvisející dotaz,
- potřebu upřesnění.

Klasifikace může používat kombinaci:

- deterministických pravidel,
- malého modelu,
- hlavního modelu se strukturovaným výstupem.

Klasifikátor nesmí sám provádět změny.

## 4.3 Context Planner

Rozhoduje, které kategorie kontextu jsou pro konkrétní účel potřeba.

Příklady kategorií:

- základní AthleteProfile,
- aktivní sporty a cíle,
- dnešní schedule,
- aktivní TrainingPlanVersion,
- konkrétní WorkoutInstanceRevision,
- nedávné Activity,
- agregované metriky,
- readiness summary,
- aktivní Limitation a SafetyRestriction,
- relevantní preference,
- předchozí konverzační souhrn.

Context Planner nesmí automaticky načíst celý profil nebo historii.

## 4.4 Context Builder

Načítá data pouze přes autorizované query porty.

Každý kontextový blok musí mít:

- typ,
- zdroj,
- owner,
- timestamp,
- verzi nebo revision,
- datovou klasifikaci,
- účel použití,
- případnou confidence,
- maximální stáří.

Builder vytváří strukturovaný `AIContext`, nikoli neřízený textový dump databáze.

## 4.5 Prompt Assembler

Skládá:

- system instructions,
- capability instructions,
- safety instructions,
- user preference pro komunikaci,
- lokalizaci,
- strukturovaný kontext,
- definice dostupných nástrojů,
- očekávané output schema.

Prompty musí být:

- verzované,
- testovatelné,
- dohledatelné,
- oddělené podle capability,
- bez tajných tokenů a interních credentials.

## 4.6 Model Gateway

Jediná podporovaná hranice pro volání AI providerů.

Gateway odpovídá za:

- provider abstraction,
- výběr modelu podle policy,
- timeout,
- retry pouze pro bezpečné chyby,
- streaming,
- usage metadata,
- cost estimation,
- circuit breaker,
- fallback,
- normalizaci provider chyb,
- bezpečnou telemetry.

Doménové moduly ani mobilní klient nesmí volat provider SDK přímo.

## 4.7 Structured Output Validator

Každý strojově použitelný výstup musí projít:

1. syntaktickou validací,
2. JSON nebo ekvivalentní schema validací,
3. enum a unit validací,
4. referenční validací,
5. doménovou validací,
6. security a authorization validací,
7. stale-context kontrolou.

Nevalidní výstup se nesmí „opravit“ tichým přímým zápisem. Lze:

- provést omezený repair attempt,
- požádat model o nový strukturovaný výstup,
- vyžádat upřesnění,
- přejít do bezpečného fallbacku.

## 4.8 Tool Registry

Obsahuje verzované definice povolených nástrojů.

Každý nástroj má:

- stabilní tool code,
- verzi,
- účel,
- input schema,
- output schema,
- owner module,
- required permissions,
- data classification,
- risk class,
- confirmation requirement,
- idempotency policy,
- timeout,
- audit policy.

Nástroj není generický přístup k databázi ani obecné `execute_sql`, `patch_entity` nebo `call_api`.

## 4.9 Tool Authorization Gateway

Před každým nástrojem znovu ověřuje:

- actor,
- AthleteProfile scope,
- oprávnění,
- consent,
- rizikovou třídu,
- objektové verze,
- safety restrictions,
- rate limits.

Autorizace nesmí být založena pouze na tom, že model nástroj vybral.

## 4.10 Proposal Builder

Převádí validovaný modelový návrh na doménový `AIProposal`.

Proposal musí odkazovat na:

- použitý kontext a jeho verze,
- navrhované operace,
- dotčené objekty,
- důvody,
- rizika,
- možnost vrácení,
- dobu platnosti,
- požadované potvrzení.

## 4.11 Change Execution Boundary

AIProposal a schválení se převádějí na `ChangeSet`.

Aplikace změn probíhá pouze přes běžné application services a aggregate metody.

AI runtime:

- neotevírá vlastní business transakci mimo aplikační vrstvu,
- nezapisuje přímo do repository,
- neobchází optimistic concurrency,
- neobchází outbox a audit.

## 4.12 Response Composer

Vytváří uživatelskou odpověď z:

- modelového textu,
- validovaného Proposal,
- výsledku ChangeSet,
- strukturovaných chyb,
- fallback zpráv.

Nikdy nesmí tvrdit, že změna byla provedena, pokud neexistuje potvrzený úspěšný výsledek application service.

---

# 5. Provider abstraction

## 5.1 Princip

Interní capability nesmí být pojmenovány podle konkrétního poskytovatele.

Příklady interních capability:

- conversational_reasoning,
- structured_intent_detection,
- proposal_generation,
- plan_drafting,
- summarization,
- safety_classification,
- embedding_generation.

## 5.2 Provider Adapter

Adapter mapuje interní request na konkrétní provider API a zpět.

Musí izolovat:

- formát zpráv,
- tool-calling protokol,
- streaming události,
- token usage,
- finish reasons,
- safety metadata,
- provider-specific errors.

## 5.3 Model Policy

Model se vybírá podle:

- capability,
- rizika,
- požadované kvality,
- latency budgetu,
- context size,
- jazyka,
- dostupnosti,
- ceny,
- jurisdikční nebo datové policy.

Výběr modelu nesmí být rozptýlen po business kódu.

## 5.4 Fallback chain

Fallback může být:

1. stejný model opakovaně pouze při bezpečné transient chybě,
2. jiný kompatibilní model,
3. omezený deterministický výsledek,
4. odložení neurgentní operace,
5. uživatelské sdělení, že AI funkce je dočasně nedostupná.

Fallback nesmí snížit safety nebo confirmation požadavky.

---

# 6. Kontext a minimalizace dat

## 6.1 Context scopes

Podporované scopes mohou zahrnovat:

- PROFILE_SUMMARY,
- TODAY,
- WEEK,
- ACTIVE_PLAN,
- WORKOUT,
- GOAL,
- RECOVERY,
- PAIN,
- ACTIVITY_HISTORY,
- PROPOSAL_REVIEW.

Každý scope má vlastní maximální rozsah, freshness a datovou klasifikaci.

## 6.2 Citlivý kontext

Health-related, location-related a jiný citlivý kontext se použije pouze pokud:

- je relevantní pro explicitní účel,
- existuje oprávnění a consent,
- provider a regionální policy použití dovoluje,
- data byla minimalizována.

## 6.3 Kontextové snapshoty

Proposal musí být navázán na snapshot nebo sadu referencí s verzemi.

Při změně relevantního objektu se Proposal označí jako:

- STALE,
- REVALIDATION_REQUIRED,
- INVALID.

## 6.4 Retrieval

Vektorové vyhledávání nebo embeddings lze použít pro:

- relevantní konverzační souhrny,
- znalostní obsah,
- uživatelské poznámky podle consentu.

Nesmí být použito jako náhrada přesných query pro aktuální doménový stav.

## 6.5 Conversation memory

Paměť se dělí na:

- autoritativní strukturovaný profil,
- krátkodobou historii konverzace,
- verzovaný souhrn konverzace,
- explicitně povolené dlouhodobé preference.

Volný modelový souhrn nesmí přepsat autoritativní profilový údaj.

---

# 7. Prompt architecture

## 7.1 Typy promptů

- global system policy,
- capability prompt,
- safety prompt,
- output-schema instructions,
- tool instructions,
- localization and style instructions,
- repair prompt,
- evaluation prompt mimo produkční rozhodovací tok.

## 7.2 Verze

Každé produkční volání eviduje:

- prompt family,
- prompt version,
- model policy version,
- tool registry version,
- context builder version,
- safety policy version.

## 7.3 Prompt injection

Uživatelský, provider a importovaný obsah se považuje za nedůvěryhodná data.

Nesmí měnit:

- system policy,
- tool permissions,
- confirmation policy,
- datový scope,
- bezpečnostní pravidla.

Externí text musí být jasně oddělen od instrukcí.

## 7.4 Chain-of-thought

Systém nesmí vyžadovat ani ukládat soukromý chain-of-thought.

Pro audit a vysvětlení se ukládají pouze:

- strukturované reason codes,
- stručné uživatelské vysvětlení,
- použité reference,
- validační výsledky,
- tool invocations,
- finální rozhodovací metadata.

---

# 8. Tool calling a změny

## 8.1 Třídy nástrojů

- READ_ONLY,
- PROPOSAL_ONLY,
- LOW_RISK_WRITE,
- MATERIAL_WRITE,
- SAFETY_SENSITIVE,
- ADMINISTRATIVE_RESTRICTED.

## 8.2 Příklady read-only tools

- get_today_context,
- get_active_plan_summary,
- get_workout_detail,
- get_goal_progress,
- get_recovery_summary,
- get_active_limitations.

## 8.3 Příklady proposal tools

- propose_reschedule_workout,
- propose_shorten_workout,
- propose_plan_adjustment,
- propose_goal_change,
- propose_workout_substitution.

## 8.4 Zakázané nástroje

- arbitrary_sql,
- arbitrary_http,
- write_any_entity,
- disable_safety,
- modify_consent_without_user,
- reveal_secret,
- access_other_profile.

## 8.5 Tool loop limity

Každý request má limity:

- maximální počet modelových kol,
- maximální počet tool invocations,
- maximální wall-clock čas,
- token budget,
- cost budget,
- ochranu proti cyklu.

Překročení vede k bezpečnému ukončení nebo upřesnění.

---

# 9. Safety architecture

## 9.1 Deterministická bezpečnost

Kritická pravidla musí být mimo LLM:

- aktivní SafetyRestriction,
- zakázané operace,
- permission scope,
- consent,
- objektové verze,
- hard training constraints,
- medical escalation rules definované odborně.

## 9.2 Pain a medical boundaries

AI nesmí:

- diagnostikovat,
- nahrazovat zdravotníka,
- ignorovat red flags,
- doporučit překonání aktivní SafetyRestriction,
- prezentovat nejistý zdravotní závěr jako fakt.

Pain workflow může používat LLM pro srozumitelnou komunikaci, ale klasifikace vedoucí k blokaci nebo eskalaci musí mít odborně schválenou deterministickou policy.

## 9.3 Safety response modes

- NORMAL,
- CAUTION,
- RESTRICTED,
- BLOCKED,
- ESCALATE_TO_PROFESSIONAL,
- EMERGENCY_GUIDANCE_REQUIRED podle právně a odborně schválené policy.

## 9.4 User override

Uživatel nemůže přes AI chat obejít nepřekročitelnou safety hranici.

Povolený manual override musí být:

- explicitní,
- autorizovaný,
- auditovaný,
- doménově podporovaný,
- srozumitelně vysvětlený.

---

# 10. Streaming a mobilní klient

## 10.1 Streaming response

Mobilní klient může dostávat:

- text delta,
- status event,
- tool progress summary,
- proposal-ready event,
- completion event,
- structured error.

Interní chain-of-thought ani raw provider events se klientovi neposílají.

## 10.2 Přerušení spojení

Konverzační request musí mít stabilní requestId.

Po přerušení klient může:

- obnovit stream,
- načíst dokončený výsledek,
- zjistit stav,
- bezpečně zopakovat idempotentní submit.

## 10.3 Offline stav

Bez sítě:

- AI chat může být nedostupný nebo omezený,
- kritické workout, activity, check-in a safety funkce musí zůstat dostupné podle mobilní architektury,
- uživatelský požadavek lze uložit jako draft, nikoli předstírat provedení AI operace.

---

# 11. Latence, kapacita a náklady

## 11.1 Latency budget

Každá capability má samostatný budget pro:

- context build,
- provider queue,
- time-to-first-token,
- full completion,
- validation,
- tool execution.

Přesná čísla potvrdí NFR review a měření.

## 11.2 Token budget

Budget se řídí podle:

- capability,
- rizika,
- uživatelského entitlementu,
- kontextové potřeby,
- modelu.

Kontext se nesmí nekontrolovaně zvětšovat s délkou historie.

## 11.3 Cost controls

Minimálně:

- per-request estimate,
- per-account a per-capability limity,
- budget alerts,
- model routing,
- caching pouze bezpečných stabilních artefaktů,
- ochrana proti retry stormu,
- ochrana proti abuse.

## 11.4 Caching

Lze cacheovat například:

- stabilní prompt fragmenty,
- neosobní znalostní obsah,
- bezpečné modelové klasifikace podle policy.

Nesmí se cacheovat napříč uživateli citlivý personalizovaný výstup bez silné izolace a jasného účelu.

---

# 12. Observabilita a audit

Každé volání má evidovat bezpečná metadata:

- requestId,
- conversationId,
- actor a profile scope v pseudonymizované podobě podle policy,
- capability,
- model policy a provider,
- prompt version,
- context categories,
- tool definitions version,
- token usage,
- latency,
- retry a fallback,
- validation result,
- safety result,
- proposalId nebo ChangeSetId,
- error category.

Běžné logy nesmí obsahovat celý citlivý prompt nebo response.

Auditní záznam doménové změny je oddělen od technické AI telemetry.

---

# 13. Evaluace

## 13.1 Typy evaluace

- schema validity,
- tool selection accuracy,
- proposal correctness,
- domain-rule compliance,
- safety compliance,
- hallucination rate,
- context relevance,
- explanation quality,
- multilingual quality,
- latency a cost,
- regression testing.

## 13.2 Golden scenarios

Musí pokrývat minimálně:

- vytvoření plánu,
- přesun workoutu,
- zkrácení workoutu při únavě,
- pain report,
- aktivní limitation,
- konfliktní cíle,
- stale proposal,
- partial approval,
- undo,
- offline a provider outage,
- prompt injection,
- cross-profile access attempt.

## 13.3 Release gate

Nový model, prompt nebo tool version nesmí být nasazen bez:

- automatických evals,
- bezpečnostních scénářů,
- schema contract testů,
- porovnání latency a cost,
- schválené rollout policy,
- možnosti rollbacku.

## 13.4 Produkční feedback

Uživatelská zpětná vazba může označit:

- nepřesné pochopení,
- nevhodný návrh,
- příliš dlouhou odpověď,
- nevysvětlenou změnu,
- safety concern.

Feedback nesmí automaticky měnit safety policy nebo doménové pravidlo.

---

# 14. Data retention a privacy

Musí být odděleno:

- obsah AIMessage,
- konverzační souhrn,
- provider request metadata,
- AIProposal,
- ChangeSet,
- audit,
- telemetry.

Každá kategorie má vlastní:

- účel,
- klasifikaci,
- retention,
- export,
- deletion behavior,
- access policy.

Providerovi se nesmí předávat více dat, než je nutné pro konkrétní capability.

Provider data-retention a training policy musí být potvrzena security a legal review před produkčním použitím.

---

# 15. Error model a fallback UX

Chyby se normalizují například na:

- AI_UNAVAILABLE,
- AI_TIMEOUT,
- RATE_LIMITED,
- CONTEXT_UNAVAILABLE,
- OUTPUT_INVALID,
- TOOL_NOT_AUTHORIZED,
- PROPOSAL_STALE,
- SAFETY_BLOCKED,
- CONSENT_REQUIRED,
- COST_LIMIT_REACHED,
- PROVIDER_POLICY_BLOCKED.

Uživatel musí dostat:

- srozumitelnou zprávu,
- informaci, zda byla změna provedena,
- bezpečný další krok,
- možnost retry pouze pokud je bezpečná.

---

# 16. Testovací strategie

## 16.1 Unit testy

- context planning,
- prompt assembly,
- schema validation,
- policy evaluation,
- model routing,
- cost calculation,
- error mapping.

## 16.2 Contract testy

- provider adapters,
- structured outputs,
- tool schemas,
- streaming protocol,
- proposal mapping.

## 16.3 Integration testy

- AI request až AIProposal,
- schválení až ChangeSet,
- stale-context detection,
- tool authorization,
- fallback chain,
- audit metadata.

## 16.4 Adversarial testy

- prompt injection,
- data exfiltration,
- role confusion,
- tool escalation,
- hidden instructions v importovaném obsahu,
- cross-profile access,
- infinite tool loop,
- unsafe pain guidance.

---

# 17. Deployment a rollout

AI runtime může být součástí modulárního backendu, ale musí mít jasnou interní hranici.

Samostatná služba je oprávněná pouze pokud vznikne:

- odlišný scaling profil,
- potřeba izolace secrets nebo citlivých dat,
- samostatná provozní odpovědnost,
- vysoká worker zátěž,
- měřitelný důvod podle backend architecture.

Rollout nového modelu nebo promptu používá:

- feature flag,
- capability routing,
- canary nebo omezenou kohortu,
- shadow evaluation, pokud je bezpečná,
- rychlý rollback.

---

# 18. Doporučená struktura AI modulu

```text
ai/
├── application/
│   ├── conversations/
│   ├── requests/
│   ├── proposals/
│   └── evaluations/
├── domain/
│   └── references-to-ai-change-domain/
├── context/
│   ├── planning/
│   ├── builders/
│   └── redaction/
├── prompts/
│   ├── registry/
│   └── versions/
├── tools/
│   ├── registry/
│   ├── authorization/
│   └── adapters/
├── providers/
│   ├── gateway/
│   └── adapters/
├── validation/
├── safety/
├── telemetry/
└── tests/
```

Konkrétní jazyková struktura bude upravena podle backendového stacku v ADR.

---

# 19. Architektonická pravidla

## AIR-001 – AI není zdroj pravdy

Modelový výstup nesmí být autoritativním stavem domény.

## AIR-002 – Žádný přímý zápis

AI provider ani orchestrace nesmí přímo zapisovat do databáze nebo interního repository.

## AIR-003 – Strukturované změny

Každá doménová změna navržená AI musí být reprezentována validovaným AIProposal a ChangeSet.

## AIR-004 – Provider isolation

Doménové a aplikační moduly nesmí záviset na konkrétním provider SDK.

## AIR-005 – Minimální kontext

Do modelu se předává pouze kontext nutný pro autorizovaný účel.

## AIR-006 – Verzované prompty a nástroje

Produkční prompt, tool a output schema musí mít dohledatelnou verzi.

## AIR-007 – Deterministické guardrails

Kritická authorization, consent, safety a domain pravidla se vynucují mimo LLM.

## AIR-008 – Stale protection

AIProposal musí být navázán na verze relevantního kontextu a před aplikací znovu validován.

## AIR-009 – Pravdivý execution status

Uživatelská odpověď nesmí tvrdit provedení změny bez potvrzeného výsledku aplikační vrstvy.

## AIR-010 – Bez chain-of-thought persistence

Soukromý chain-of-thought se nevyžaduje, neukládá a nepublikuje.

## AIR-011 – Bezpečný fallback

Fallback nesmí snížit safety, permission nebo confirmation požadavky.

## AIR-012 – Omezené tool loops

Každý AI request musí mít limity kol, nástrojů, času, tokenů a ceny.

## AIR-013 – Izolace profilů

AIContext, cache, telemetry a tool execution musí zachovat AthleteProfile a tenant isolation.

## AIR-014 – Evaluace před rolloutem

Nová model, prompt nebo tool verze musí projít definovanými evals a rollback gate.

## AIR-015 – Nezávislost kritických funkcí

Výpadek AI nesmí znemožnit základní offline workout, activity, check-in a safety funkce.

---

# 20. Rozhodnutí vyžadující ADR

Před implementací je nutné rozhodnout minimálně:

1. první AI provider a smluvní data policy,
2. provider SDK versus vlastní HTTP adapter,
3. modely pro jednotlivé capability,
4. formát structured outputs,
5. streaming transport,
6. prompt registry a verzování,
7. tool registry implementaci,
8. embeddings a vector storage, pokud budou použity,
9. conversation storage a summarization,
10. AI secrets management,
11. cost limits a entitlement policy,
12. eval framework,
13. telemetry a redaction,
14. provider fallback strategii,
15. regionální routing citlivých dat.

---

# 21. Co ještě vyžaduje samostatný kontrakt

Před `IMPLEMENTATION_READY` musí vzniknout minimálně:

- model-selection ADR,
- provider abstraction contract,
- AIContext schema,
- prompt architecture a registry,
- structured output schemas,
- AI tool catalog a jednotlivá tool schemas,
- tool authorization matrix,
- ConfirmationPolicy contract,
- safety a medical boundaries,
- prompt-injection threat model,
- conversation-memory policy,
- token a cost policy,
- AI observability specification,
- AI evaluation strategy,
- streaming API contract.

---

# 22. Kritéria implementační připravenosti

Dokument může být označen jako `IMPLEMENTATION_READY`, až když:

1. jsou přijata klíčová AI ADR,
2. jsou verzovaná všechna počáteční tool a output schemas,
3. je definovaný Context Builder a data classification,
4. existuje confirmation a authorization matrix,
5. safety pravidla prošla odborným review,
6. security architecture řeší prompt injection, secrets a provider data use,
7. jsou potvrzeny latency a cost budgety,
8. existuje eval dataset pro CORE scénáře,
9. je definován rollout a rollback,
10. existují contract, adversarial a end-to-end testy,
11. je namapována architektura na CORE FR a CRITICAL NFR,
12. fallback zachovává základní produkt bez AI.

---

# 23. Závěr

AI vrstva AI Traineru je řízený návrhový a komunikační systém, nikoli druhá databáze ani nekontrolovaný agent.

Základní bezpečný tok je:

```text
User intent
    ↓
Authorized minimal context
    ↓
Versioned prompt and model policy
    ↓
Structured output / tool request
    ↓
Schema, domain, security and safety validation
    ↓
AIProposal
    ↓
ConfirmationPolicy
    ↓
ChangeSet through normal application services
    ↓
Audit and truthful user-visible result
```

Tato architektura umožňuje využít AI jako centrální uživatelskou vrstvu a zároveň zachovat deterministické vlastnictví dat, bezpečnost, vysvětlitelnost, vratnost změn a možnost měnit modely bez přepisování produktu.