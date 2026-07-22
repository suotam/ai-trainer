# AI Trainer – Integration Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/10-integrations/integration-architecture.md`  
**Vlastník:** Integration Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/functional-requirements.md`, `docs/02-product/non-functional-requirements.md`, `docs/06-domain/integration-model.md`, `docs/06-domain/activity-model.md`, `docs/06-domain/scheduling-model.md`, `docs/06-domain/metrics-model.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/domain-events.md`, `docs/06-domain/domain-invariants.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/11-security/security-architecture.md`, `docs/12-data/data-architecture.md`  
**Navazující dokumenty:** provider capability matrix, provider ADR, OAuth a credential contract, webhook contract, import/export API contract, canonical mapping schemas, provider certification checklist, integration test strategy, operational runbooks a provider-specific adapter specifications  
**Vlastněné pojmy nebo kontrakty:** integration runtime boundaries, adapter architecture, provider capability resolution, connection lifecycle, import/export pipelines, webhook and polling orchestration, canonical normalization boundary, idempotency and deduplication controls, retry and degradation model, integration observability a pravidla `IAR-001` až `IAR-015`

---

# 1. Účel

Tento dokument definuje technickou architekturu externích integrací aplikace AI Trainer.

Je zdrojem pravdy pro:

- hranici mezi interním systémem a externím providerem,
- členění integrační vrstvy a adapterů,
- runtime připojení uživatelského účtu,
- capability discovery a provider configuration,
- importní a exportní pipeline,
- webhook, polling a incremental sync orchestration,
- normalizaci externích dat do kanonických vstupů,
- idempotenci, deduplikaci, cursor management a replay,
- řízení retry, rate limitů, degradace a circuit breakerů,
- bezpečné zacházení s credentials v integračním runtime,
- observační model, audit a provozní health integrací,
- rollout, pozastavení a ukončení provider adapteru.

Dokument nevlastní:

- doménový význam `UserIntegration`, importovaných aktivit, metrik nebo kalendářových událostí,
- konkrétní fyzické tabulky,
- konkrétní veřejné API payloady,
- detailní OAuth parametry jednotlivých providerů,
- konkrétní SDK nebo knihovnu,
- právní základ zpracování a text souhlasů,
- konkrétní provider certifikační podmínky,
- detailní provozní runbook každého provideru.

Tyto oblasti vlastní doménové modely, data architecture, security architecture, navazující kontrakty a ADR.

---

# 2. Autorita a vztah k ostatním dokumentům

## 2.1 Rozdělení odpovědnosti

- `integration-model.md` vlastní doménový význam providerů, capabilities, connections, credentials, jobs, mappings, conflicts a retention.
- `backend-architecture.md` vlastní modulární hranice, application services, transactions, outbox, jobs a event processing.
- `data-architecture.md` vlastní autoritativní storage, historii, lineage, migrace, retenci a backup.
- `security-architecture.md` vlastní trust zones, credentials security, authorization, secret handling, webhook verification a auditní omezení.
- `sync-and-offline-model.md` vlastní význam mobilního offline sync a konfliktů mezi zařízeními.
- tento dokument vlastní technické provedení komunikace s externími providery.

## 2.2 Integrační architektura nesmí měnit doménu providerem

Provider-specific struktura, enum, lifecycle ani omezení nesmí proniknout do interního doménového modelu jako výchozí systémová autorita.

Provider adapter převádí externí reprezentaci na kanonický integrační vstup. Až následná doménová aplikační služba rozhodne, zda a jak se vstup projeví v interních agregátech.

## 2.3 Externí úspěch není interní úspěch

Úspěšná HTTP odpověď provideru neznamená automaticky:

- validní doménový výsledek,
- dokončený import,
- uložený export,
- potvrzenou deduplikaci,
- viditelnost změny uživateli.

Každá etapa musí mít vlastní stav a auditovatelný výsledek.

---

# 3. Architektonické cíle

Integrační vrstva musí:

- izolovat změny externích API,
- zachovat interní doménovou stabilitu,
- podporovat více providerů bez společného nejnižšího jmenovatele,
- být bezpečně vypnutelná per provider i per capability,
- umožnit replay bez duplicitního business efektu,
- zachovat provenance a původní provider payload nebo jeho bezpečný otisk podle retention policy,
- fungovat při částečné nedostupnosti provideru,
- respektovat provider rate limits a quotas,
- umožnit postupný rollout a rollback,
- poskytovat srozumitelný health stav pro uživatele i provoz,
- neblokovat základní použití AI Traineru při výpadku integrace.

---

# 4. Kontext a hlavní komponenty

Integrační runtime obsahuje minimálně:

1. **Integration Application Service**,
2. **Provider Registry**,
3. **Capability Resolver**,
4. **Connection Manager**,
5. **Credential Broker**,
6. **Provider Adapter**,
7. **Inbound Gateway**,
8. **Outbound Gateway**,
9. **Import Orchestrator**,
10. **Export Orchestrator**,
11. **Webhook Receiver**,
12. **Polling Scheduler**,
13. **Rate Limit Coordinator**,
14. **Canonical Mapper**,
15. **Validation and Normalization Pipeline**,
16. **Deduplication Service**,
17. **Cursor Store**,
18. **Integration Event Publisher**,
19. **Health and Observability Service**.

Tyto komponenty jsou logické odpovědnosti. Nemusí být samostatně deployované.

---

# 5. Provider Registry

Provider Registry je autoritativní technický registr podporovaných providerů a jejich verzovaných schopností.

Pro každého providera eviduje minimálně:

- stabilní provider code,
- adapter version,
- podporované platformy a regiony,
- autentizační mechanismus,
- podporované capabilities,
- směry synchronizace,
- webhook podporu,
- polling podporu,
- incremental cursor podporu,
- historický import,
- exportní možnosti,
- provider limity,
- certifikační stav,
- feature flag a rollout state,
- minimální bezpečnostní a privacy podmínky,
- provozní health status.

Provider Registry nesmí obsahovat uživatelské credentials.

---

# 6. Provider Adapter

## 6.1 Odpovědnost

Provider Adapter vlastní pouze překlad mezi externím API a interním integračním kontraktem.

Adapter může:

- volat provider API,
- ověřovat provider-specific odpověď,
- překládat provider enumy,
- převádět jednotky a časové formáty,
- zpracovat pagination a cursors,
- interpretovat provider-specific error codes,
- vytvářet kanonický inbound nebo outbound model.

Adapter nesmí:

- přímo zapisovat do doménových tabulek,
- rozhodovat o vlastnictví uživatelských dat,
- potvrdit doménový konflikt,
- obejít autorizaci nebo consent,
- měnit TrainingPlan, Activity, ScheduleEvent nebo MetricValue,
- obsahovat provider credentials v konfiguraci zdrojového kódu.

## 6.2 Verze adapteru

Každý adapter musí mít explicitní verzi nezávislou na interním release produktu.

Změna mapování, interpretace provider payloadu nebo chování pagination musí být auditovatelná podle adapter version.

## 6.3 Anti-corruption layer

Provider Adapter je anti-corruption layer. Provider-specific názvy nesmí mimo integrační modul pronikat jako interní business pojmy, pokud nejsou explicitně převzaty do kanonického glossary a doménového modelu.

---

# 7. Connection lifecycle

Technický lifecycle připojení zahrnuje:

1. inicializaci connection intent,
2. serverové ověření identity a oprávnění,
3. vytvoření bezpečného state a PKCE nebo ekvivalentní ochrany,
4. redirect nebo platformní authorization flow,
5. callback validation,
6. bezpečné uložení credentials,
7. capability discovery,
8. initial sync planning,
9. aktivaci connection,
10. průběžnou obnovu credentials,
11. pause, reauthorization nebo degradation,
12. disconnect a credential revocation.

Connection nesmí být označena jako `ACTIVE`, dokud nejsou:

- credentials bezpečně uloženy,
- požadované scopes ověřeny,
- provider account identity svázána se správným profilem,
- dokončena minimální validační operace,
- zapsán auditní záznam.

---

# 8. Credential Broker

Credential Broker je jediná aplikační hranice, přes kterou integrační runtime získává provider access token nebo jiný secret.

Musí:

- oddělit credentials od běžných integračních dat,
- vracet credential pouze autorizovanému adapter workflow,
- podporovat refresh, rotation a revocation,
- nikdy nevracet secret mobilnímu klientu,
- zabránit zapsání credentials do logů, traces a dead-letter payloadů,
- evidovat bezpečnostní metadata bez ukládání tokenu v auditním záznamu.

Provider Adapter nesmí credentials dlouhodobě cacheovat mimo schválenou krátkodobou bezpečnou vrstvu.

---

# 9. Import pipeline

## 9.1 Etapy

Import probíhá minimálně přes tyto etapy:

1. **Trigger** – webhook, polling, manual refresh nebo initial import,
2. **Authorization check** – connection, consent, scope a profile ownership,
3. **Fetch planning** – rozsah, cursor, time window a quota budget,
4. **Provider fetch** – volání adapteru,
5. **Raw envelope capture** – bezpečné metadata a podle policy původní payload,
6. **Schema validation**,
7. **Canonical mapping**,
8. **Unit and time normalization**,
9. **Semantic validation**,
10. **Deduplication and matching**,
11. **Domain command creation**,
12. **Transactional domain processing**,
13. **Cursor advancement**,
14. **Audit and observability**.

## 9.2 Cursor se posouvá až po bezpečném zpracování

Incremental cursor nesmí být potvrzen před úspěšným dokončením všech záznamů, které daný cursor pokrývá, nebo před jejich explicitním přesunutím do řízeného partial-failure stavu.

## 9.3 Partial batch failure

Jedna neplatná položka nesmí automaticky zahodit celý velký import, pokud provider kontrakt umožňuje bezpečné per-record zpracování.

Systém musí rozlišit:

- plně úspěšný batch,
- částečně úspěšný batch,
- retryable failure,
- permanent record failure,
- authorization failure,
- provider contract failure.

---

# 10. Export pipeline

Export probíhá přes:

1. autorizovaný interní požadavek,
2. ověření aktivní connection a capability,
3. vytvoření stabilního idempotency identity,
4. převod interního objektu do canonical outbound modelu,
5. provider-specific mapping,
6. provider write,
7. ověření výsledku,
8. uložení `ExternalResourceReference`,
9. audit a publikaci výsledku.

Export nesmí přímo používat proměnlivý UI text nebo lokální klientský stav jako autoritativní payload.

Při opakování stejného exportu musí systém použít stabilní interní identitu a provider reference tak, aby nevznikaly duplicity.

---

# 11. Webhook architecture

Webhook Receiver je veřejná nedůvěryhodná hranice.

Každý webhook musí projít:

- transportní ochranou,
- provider-specific signature nebo token verification, pokud ji provider podporuje,
- timestamp a replay kontrolou,
- velikostním limitem,
- syntaktickou validací,
- rate limitingem,
- deduplikací provider event identity,
- odděleným durable enqueue před business zpracováním.

Webhook acknowledgement nesmí čekat na kompletní doménové zpracování, pokud provider vyžaduje rychlou odpověď.

Příjem webhooku potvrzuje pouze bezpečné převzetí, nikoli dokončení importu.

---

# 12. Polling a scheduling

Polling Scheduler plánuje práci podle:

- capability,
- provider limitů,
- posledního úspěšného cursoru,
- webhook spolehlivosti,
- user activity,
- freshness cíle,
- prioritizace datového typu,
- aktuálního degradation stavu.

Polling musí obsahovat jitter a koordinaci, aby po restartu nebo výpadku nevznikla synchronizovaná špička.

Backfill a historical import mají nižší prioritu než běžný incremental sync a nesmí vyčerpat quota potřebnou pro aktuální uživatelská data.

---

# 13. Canonical mapping boundary

Každý externí payload se převádí nejprve do kanonického integračního modelu, nikoli přímo do doménového agregátu.

Kanonický model musí zachovat:

- provider identity,
- external resource identity,
- provider revision nebo update timestamp,
- source timezone,
- původní jednotku,
- přesnost a kvalitu hodnoty,
- mapping version,
- adapter version,
- import timestamp,
- dostupnou provenance.

Normalizace nesmí předstírat přesnost, kterou provider neposkytl.

Neznámá hodnota se nesmí automaticky mapovat na nejbližší známý enum bez explicitní fallback policy.

---

# 14. Deduplikace a identity

Deduplikace používá vrstvený přístup:

1. provider event identity,
2. provider resource identity,
3. connection identity,
4. revision nebo update identity,
5. canonical fingerprint,
6. doménové heuristiky pouze jako poslední vrstvu.

Heuristická shoda nesmí bez auditovatelného rozhodnutí destruktivně sloučit dva autoritativní záznamy.

Při nejistotě vzniká `IntegrationConflict` nebo návrh pro uživatelské rozhodnutí.

Idempotency identity musí být stabilní přes retry, restart jobu a opakované doručení webhooku.

---

# 15. Error model a retry

Chyby se klasifikují minimálně na:

- `TRANSIENT_NETWORK`,
- `PROVIDER_UNAVAILABLE`,
- `RATE_LIMITED`,
- `AUTH_EXPIRED`,
- `AUTH_REVOKED`,
- `INSUFFICIENT_SCOPE`,
- `INVALID_REQUEST`,
- `INVALID_PROVIDER_RESPONSE`,
- `MAPPING_UNSUPPORTED`,
- `DATA_VALIDATION_FAILED`,
- `PERMANENT_RESOURCE_ERROR`,
- `INTERNAL_PROCESSING_ERROR`.

Retry je povolen pouze pro chyby označené jako retryable.

Retry policy musí používat:

- omezený počet pokusů,
- exponential backoff,
- jitter,
- respektování `Retry-After`,
- stabilní idempotency identity,
- dead-letter nebo manual-review stav po vyčerpání pokusů.

Permanentně neplatný payload se nesmí opakovat neomezeně.

---

# 16. Rate limits, quotas a circuit breakers

Rate Limit Coordinator eviduje limity per:

- provider,
- credential nebo connection,
- endpoint nebo capability,
- časové okno,
- případně region nebo aplikaci.

Systém musí preferovat:

1. aktuální incremental sync,
2. user-triggered refresh,
3. kritické credential operace,
4. běžný export,
5. historical backfill.

Circuit breaker může dočasně omezit provider calls při vysoké chybovosti, ale nesmí zneplatnit lokálně dostupná data ani základní funkce produktu.

---

# 17. Degradation model

Health stav provideru nebo connection musí rozlišit minimálně:

- `HEALTHY`,
- `DEGRADED`,
- `RATE_LIMITED`,
- `REAUTHORIZATION_REQUIRED`,
- `PARTIALLY_SUPPORTED`,
- `SUSPENDED`,
- `UNAVAILABLE`,
- `DISCONNECTED`.

Uživatelské UI nesmí zobrazit pouze obecnou chybu, pokud systém bezpečně zná konkrétní požadovanou akci, například nové přihlášení nebo doplnění scope.

Degradace jedné capability nesmí automaticky vypnout ostatní funkční capabilities stejného provideru.

---

# 18. Eventy a transakční hranice

Integrační runtime publikuje interní události například pro:

- connection activated,
- connection reauthorization required,
- import completed,
- import partially completed,
- export completed,
- provider degraded,
- conflict detected,
- disconnect completed.

Event se publikuje přes schválený outbox mechanismus tam, kde doprovází autoritativní změnu stavu.

Externí provider event není automaticky doménový event. Nejprve musí projít validací, deduplikací a integračním zpracováním.

---

# 19. Bezpečnost a soukromí

Integrační runtime musí respektovat `security-architecture.md` a zejména:

- least privilege scopes,
- server-side authorization,
- oddělené secret storage,
- bezpečnou revokaci credentials,
- webhook verification,
- zákaz secrets v telemetry,
- data minimization,
- účelové omezení importovaných dat,
- audit citlivých connection a credential změn.

Provider payload nesmí být automaticky ukládán celý, pokud pro to neexistuje explicitní účel, retention policy a klasifikace.

Odpojení provideru musí zastavit budoucí import a export. Další zacházení s již importovanými daty se řídí doménovou disconnect a retention policy.

---

# 20. Observabilita

Minimální technické metriky:

- request rate per provider a capability,
- provider latency,
- error rate podle error class,
- rate-limit utilization,
- webhook acceptance a rejection,
- queue lag,
- import a export throughput,
- partial failure rate,
- retry count,
- dead-letter count,
- cursor age,
- credential refresh failures,
- connections requiring reauthorization,
- deduplication a conflict rate.

Logy a traces musí používat correlation identity bez ukládání tokenů nebo zakázaných citlivých payloadů.

Health dashboard musí oddělit:

- globální provider incident,
- regionální omezení,
- chybu konkrétní connection,
- neplatný jednotlivý záznam,
- interní processing incident.

---

# 21. Testovací strategie integrační architektury

Každý adapter musí mít minimálně:

- contract fixtures pro podporované provider responses,
- test neznámých a chybějících polí,
- pagination a cursor testy,
- unit a timezone mapping testy,
- idempotency a duplicate-delivery testy,
- retry a rate-limit testy,
- expired a revoked credential testy,
- webhook signature a replay testy,
- partial batch failure testy,
- backward compatibility test mapping verzí,
- sandbox nebo provider test-environment ověření, pokud existuje.

Produkční rollout nové integrace vyžaduje observabilitu, feature flag, omezenou kohortu a rollback nebo suspend mechanismus.

---

# 22. Provider onboarding a lifecycle

Nový provider nesmí být označen jako produkčně podporovaný bez:

1. capability matrix,
2. provider a security review,
3. schváleného autentizačního flow,
4. adapter contract tests,
5. mapping fixtures,
6. rate-limit a quota modelu,
7. data-use a retention posouzení,
8. observability dashboardu,
9. support a incident ownershipu,
10. rollback, suspend a disconnect postupu.

Při ukončení provideru musí systém řešit:

- zastavení nových připojení,
- komunikaci uživatelům,
- export nebo zachování dostupných interních dat,
- revokaci credentials,
- odstranění webhook subscriptions,
- doběhnutí nebo ukončení jobů,
- zachování auditní historie podle policy.

---

# 23. Závazná pravidla

## IAR-001 – Provider isolation

Provider-specific API, enum a lifecycle nesmí být přímou součástí interního doménového modelu.

## IAR-002 – Adapter write boundary

Provider Adapter nesmí přímo měnit doménové agregáty ani zapisovat do jejich autoritativních tabulek.

## IAR-003 – Server-controlled connection

Connection activation, scope ověření, credential storage a disconnect musí být řízeny autorizovaným serverovým workflow.

## IAR-004 – Credential broker

Provider credentials smí integrační runtime získat pouze přes schválenou bezpečnou credential boundary.

## IAR-005 – Canonical normalization

Externí payload musí před doménovým zpracováním projít verzovaným canonical mappingem, validací a normalizací.

## IAR-006 – Provenance preservation

Import musí zachovat provider identity, external identity, adapter a mapping version a dostupnou revision provenance.

## IAR-007 – Idempotent processing

Webhook, polling, import, export a retry musí používat stabilní identity tak, aby opakované doručení nevytvořilo duplicitní business efekt.

## IAR-008 – Safe cursor advancement

Incremental cursor se nesmí posunout za data, která nebyla bezpečně zpracována nebo explicitně evidována jako řízený partial failure.

## IAR-009 – Explicit error classification

Integrační chyba musí být klasifikována jako retryable, permanentní, authorization, provider-contract nebo internal processing chyba.

## IAR-010 – Rate-limit coordination

Provider calls musí respektovat centrálně koordinované limity, `Retry-After`, prioritu workflow a jitter.

## IAR-011 – Degraded independence

Výpadek provideru nebo capability nesmí blokovat základní interní funkce ani nesouvisející integrace.

## IAR-012 – Verified webhooks

Webhook musí před durable přijetím business práce projít dostupným signature, replay, size, rate-limit a deduplication ověřením.

## IAR-013 – Observable integration state

Provider, connection, job a cursor musí mít měřitelný a auditovatelný health stav bez ukládání secrets do telemetry.

## IAR-014 – Controlled rollout

Nový nebo zásadně změněný adapter musí být vydán přes feature flag, omezenou kohortu, observabilitu a možnost okamžitého suspend nebo rollback.

## IAR-015 – Provider exit safety

Ukončení, odpojení nebo revokace integrace musí zastavit budoucí přístup, bezpečně dokončit nebo ukončit joby a zachovat historii podle retention policy.

---

# 24. Co ještě vyžaduje rozhodnutí

Před stavem `IMPLEMENTATION_READY` je nutné:

- vytvořit provider capability matrix,
- přijmout ADR pro první integrační providery,
- definovat OAuth, PKCE, callback a credential contract,
- definovat kanonické inbound a outbound schemas,
- definovat webhook envelope a verification kontrakty,
- definovat import/export API a job status kontrakty,
- vytvořit mapování sportů, metrik, jednotek a kalendáře,
- určit storage a retention raw provider payloadů,
- stanovit per-provider rate-limit a quota policy,
- vytvořit adapter SDK nebo repository contract,
- vytvořit integration test strategy a provider fixtures,
- vytvořit operational dashboardy, alerty a runbooky,
- provést security, privacy a provider terms review,
- namapovat relevantní CORE FR a CRITICAL NFR na testy.

---

# 25. Doporučené navazující dokumenty

Doporučené pořadí:

1. provider capability matrix,
2. ADR prvních providerů a jejich pořadí,
3. OAuth a credential contract,
4. canonical integration schemas,
5. webhook contract,
6. import/export API a job contract,
7. provider adapter repository contract,
8. integration test strategy,
9. provider operational runbooks.

Samostatný obecný `integration-principles.md` se nyní nemá vytvářet, protože jeho obsah vlastní `integration-model.md` a tento dokument.
