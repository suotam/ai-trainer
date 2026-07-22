# AI Trainer – Security Architecture

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/11-security/security-architecture.md`  
**Vlastník:** Security Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/01-vision/product-principles.md`, `docs/02-product/non-functional-requirements.md`, `docs/06-domain/domain-invariants.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/recovery-and-limitations-model.md`, `docs/06-domain/ai-and-change-model.md`, `docs/06-domain/integration-model.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/07-backend/backend-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/09-ai/ai-architecture.md`, `docs/12-data/data-architecture.md`  
**Navazující dokumenty:** threat model, identity provider ADR, authorization model, data-classification matrix, secrets policy, API security contract, mobile secure-storage contract, incident-response plan, security test strategy a privacy/legal review  
**Vlastněné pojmy nebo kontrakty:** security boundaries, trust zones, authentication architecture, authorization enforcement, session and device security, cryptographic boundaries, secrets management, secure logging, abuse protection, vulnerability management, security audit a pravidla `SAR-001` až `SAR-015`

---

# 1. Účel

Tento dokument definuje bezpečnostní architekturu aplikace AI Trainer napříč mobilním klientem, backendem, databázemi, synchronizací, AI runtime a externími integracemi.

Je zdrojem pravdy pro:

- bezpečnostní hranice a trust zones,
- autentizaci uživatelů, zařízení a služeb,
- serverovou autorizaci a least privilege,
- správu session, tokenů a revokací,
- ochranu citlivých dat při přenosu, uložení a zpracování,
- správu secrets a kryptografických klíčů,
- bezpečné zacházení s lokálními daty a offline režimem,
- bezpečnost AI contextu, tools a potvrzovaných změn,
- bezpečnost integrací a provider credentials,
- audit bezpečnostních událostí,
- rate limiting a abuse protection,
- vulnerability management a bezpečnostní release gates,
- minimální připravenost na incidenty.

Dokument nevlastní:

- produktový význam osobních, zdravotních nebo tréninkových dat,
- právní základ zpracování, text souhlasů a jurisdikční rozhodnutí,
- konkrétní API payloady,
- fyzické databázové tabulky,
- konkrétní identity provider nebo kryptografickou knihovnu,
- detailní cloudovou topologii,
- konkrétní implementaci AI promptů a tool schemas.

Tyto volby patří do navazujících kontraktů a ADR. Bezpečnostní architektura určuje omezení, která tyto dokumenty nesmí oslabit.

---

# 2. Autorita a vztah k ostatním dokumentům

## 2.1 Hierarchie

Bezpečnostní pravidlo nesmí obejít:

1. právní povinnost,
2. produktové principy,
3. globální doménovou invariantu,
4. omezení vlastnícího doménového modelu,
5. CRITICAL NFR.

Nižší technický dokument může pravidlo zpřesnit, ale ne oslabit.

## 2.2 Rozdělení odpovědnosti

- `non-functional-requirements.md` vlastní měřitelné cíle, zejména `NFR-071` až `NFR-096`.
- `identity-and-profile-model.md` vlastní význam identity, profilu, vztahů, rolí a souhlasů.
- `data-architecture.md` vlastní datové vrstvy, autoritu, historii, retenci, backup a storage boundaries.
- `mobile-architecture.md` vlastní klientský runtime, local DB, offline command queue a platform adapters.
- `ai-architecture.md` vlastní AI orchestration, context, model gateway, tool registry, proposal flow a evaluaci.
- `integration-model.md` a budoucí integration architecture vlastní provider connections, importy a exporty.
- tento dokument vlastní bezpečnostní vynucení napříč těmito oblastmi.

## 2.3 Security není pouze perimeter

Bezpečnost není jedna backendová vrstva ani sada middleware. Musí být součástí:

- identity flow,
- command a query authorization,
- datového ownershipu,
- lokální persistence,
- synchronizačního protokolu,
- AI context buildingu,
- tool execution,
- integrací,
- observability,
- release pipeline.

---

# 3. Security cíle

Architektura musí chránit zejména:

- důvěrnost osobních, zdravotně citlivých, lokalizačních a autentizačních dat,
- integritu tréninkových plánů, workoutů, aktivit, omezení a AI návrhů,
- správné oddělení uživatelů, profilů, trenérů a administrativních rolí,
- dostupnost základních funkcí bez závislosti na externím AI nebo integration provideru,
- dohledatelnost citlivých změn a bezpečnostních událostí,
- možnost revokovat session, zařízení, integraci nebo kompromitované credentials,
- konzervativní chování při nejistotě nebo neúplném bezpečnostním kontextu.

Bezpečnostní cíl není absolutní eliminace rizika. Cílem je známé riziko, explicitní rozhodnutí, vrstvená obrana, omezení dopadu a obnovitelnost.

---

# 4. Chráněná aktiva

## 4.1 Identity a access aktiva

- účty a jejich stabilní identity,
- přihlašovací metody,
- session a refresh credentials,
- recovery mechanismy,
- device registrations,
- role, grants, relationship permissions a administrativní oprávnění.

## 4.2 Citlivá uživatelská data

- profilové údaje,
- bolest, omezení, recovery a další health-related údaje,
- AI konverzace a vytvořený kontext,
- GPS a přesná lokalizační data,
- soukromé aktivity a workout historie,
- exporty a smazání účtu,
- údaje o nezletilých, pokud budou podporováni.

## 4.3 Integritní aktiva

- TrainingPlan a jeho verze,
- WorkoutDefinition, WorkoutInstance a WorkoutSession,
- Activity a jejich provenance,
- aktivní safety omezení,
- AIProposal, ChangeSet, potvrzení a undo historie,
- audit, outbox, inbox a synchronizační metadata.

## 4.4 Technická aktiva

- secrets, privátní klíče a signing keys,
- provider credentials,
- databázové účty,
- CI/CD credentials,
- observability a incident data,
- backupy a export artefakty.

---

# 5. Trust zones a bezpečnostní hranice

## 5.1 Nedůvěryhodné prostředí mobilního klienta

Mobilní zařízení je uživatelsky kontrolované prostředí. Klient může být:

- kompromitovaný,
- rootnutý nebo jailbreaknutý,
- instrumentovaný,
- provozovaný se změněným časem,
- s upravenou lokální databází,
- s odchycenou nebo opakovanou komunikací.

Klient proto nesmí být autoritou pro:

- identitu volajícího,
- vlastnictví objektu,
- roli nebo vztahové oprávnění,
- serverovou business autorizaci,
- definitivní potvrzení synchronizace,
- administrativní oprávnění,
- bezpečné uložení serverových secrets.

Klient smí lokálně vynucovat UX a offline safety omezení, ale server musí chráněnou operaci znovu ověřit.

## 5.2 Veřejná síťová hranice

Veškerý provoz z mobilu, webu, webhooků a externích providerů přichází z nedůvěryhodné sítě. Každý vstup musí projít:

1. transportní ochranou,
2. autentizací, pokud je požadována,
3. syntaktickou a velikostní validací,
4. rate limitingem nebo abuse controls,
5. autorizací,
6. doménovou validací,
7. bezpečným auditováním výsledku.

## 5.3 Backendová aplikační zóna

Interní modulární monolit není automaticky důvěryhodný celek. Modul musí respektovat ownership a nesmí obcházet autorizované aplikační služby jiného modulu přímým zápisem do jeho dat.

## 5.4 Datová zóna

Databáze, object storage, cache, queue, backup a analytické úložiště mají odlišnou citlivost a účel. Přístup je udělován per workload a nesmí být sdílen jedním univerzálním produkčním účtem.

## 5.5 AI provider zóna

Externí model provider je samostatná trust zone. Data odeslaná providerovi musí být:

- explicitně vybraná autorizovaným Context Builderem,
- minimalizovaná,
- kompatibilní s provider data-use a retention policy,
- zbavená secrets a nepotřebných identifikátorů,
- auditovatelná na úrovni metadata a účelu bez ukládání chain-of-thought.

## 5.6 Integration provider zóna

Externí sportovní, zdravotní, kalendářové nebo jiné integrace jsou nedůvěryhodný vstup i externí správce credentials. Importovaná data musí být validována, označena provenance a oddělena od interní autority.

---

# 6. Data classification

Každá významná datová kategorie musí být později zařazena do schválené klasifikační matice. Minimální úrovně jsou:

| Třída | Příklady | Minimální zacházení |
|---|---|---|
| PUBLIC | veřejné produktové texty | integrita a dostupnost |
| INTERNAL | interní konfigurace bez secrets | omezený interní přístup |
| CONFIDENTIAL | soukromé workouty, profil, historie | šifrování, authorization, minimální logování |
| SENSITIVE | bolest, omezení, GPS, AI kontext, recovery údaje | silná minimalizace, zvláštní access review, zákaz běžné analytiky |
| SECRET | tokeny, hesla, privátní klíče, provider credentials | secrets manager, rotace, nikdy do logu nebo klientského bundle |

Klasifikace musí řídit:

- přístup,
- šifrování,
- logování,
- retenci,
- backup,
- export,
- analytiku,
- incident severity.

Privacy a právní review mohou zavést přísnější kategorie nebo pravidla.

---

# 7. Authentication architecture

## 7.1 Uživatel

Konkrétní identity provider a podporované přihlašovací metody budou zvoleny ADR. Architektura musí podporovat:

- bezpečné vytvoření a propojení identity,
- odolnost proti enumeraci účtů,
- ochranu login a recovery flow proti brute force,
- ověřené vlastnictví recovery kanálu,
- recent authentication pro citlivé operace,
- odvolání session a zařízení,
- audit změn přihlašovacích metod.

## 7.2 Tokeny

Access credential musí být:

- krátkodobý,
- scope-limited,
- ověřitelný serverem,
- nepoužitelný jako dlouhodobé recovery tajemství,
- chráněný před uložením do logu, analytiky, URL nebo crash reportu.

Refresh nebo ekvivalentní dlouhodobá credential musí mít:

- bezpečné uložení,
- rotaci nebo ekvivalentní replay ochranu,
- vazbu na session nebo zařízení,
- možnost jednotlivé i globální revokace,
- detekci zjevného opakovaného použití kompromitovaného tokenu.

## 7.3 Offline session

Platná lokální session může zpřístupnit dříve synchronizovaná data podle platformního secure-storage kontraktu. Nesmí ale sama obnovit serverové oprávnění po revokaci.

Po obnovení konektivity musí klient:

1. ověřit možnost pokračovat v session,
2. přijmout revokace a změny oprávnění,
3. zastavit chráněné uploady při zamítnutí,
4. zachovat lokální data v bezpečném recovery stavu místo jejich tichého zahození.

## 7.4 Služby a workload identity

Backendové joby, integrační workery a CI/CD musí používat samostatné workload identities. Sdílené statické credentials jsou přechodná výjimka, která vyžaduje vlastníka, expiry a plán odstranění.

---

# 8. Authorization architecture

## 8.1 Server je autorita

Každá chráněná operace musí na serveru ověřit minimálně:

- autentizovanou principal identity,
- cílový profil nebo resource owner,
- požadovanou capability,
- aktivní vztah a jeho scope, pokud operuje trenér nebo jiná osoba,
- stav resource a relevantní doménové invarianty,
- případnou potřebu recent authentication nebo explicitního potvrzení.

`activeProfileId`, role z klienta, skryté tlačítko ani podepsaný objekt bez serverového ownership checku nejsou autorizační důkaz.

## 8.2 Capability-oriented policy

Autorizace se má vyjadřovat schopností, například:

- `profile.read`,
- `workout.write`,
- `plan.propose_change`,
- `plan.apply_change`,
- `recovery.read_sensitive`,
- `integration.manage`,
- `account.export`,
- `account.delete`,
- `admin.support_access`.

Konkrétní registry schopností a jejich mapování na role budou samostatným kontraktem. Role nesmí být rozptýlené jako neřízené string checks v controllerech.

## 8.3 Objektová a vztahová autorizace

Policy musí bránit IDOR/BOLA třídě chyb. Každý přístup k objektu musí být omezen tenantem nebo vlastníkem a podle potřeby vztahem mezi uživatelem, profilem, trenérem a sdíleným zdrojem.

## 8.4 Administrativní přístup

Administrativní přístup k citlivým datům musí být:

- výslovně oddělený od běžné produktové role,
- omezený konkrétní capability,
- časově a účelově přiměřený,
- auditovaný,
- pokud možno just-in-time,
- pravidelně revidovaný.

Impersonation nebo support access nesmí být implementován jako znalost uživatelského hesla nebo univerzální bypass.

## 8.5 Default deny

Neznámá capability, chybějící policy context, neplatný vztah nebo selhání autorizační služby musí vést k zamítnutí, nikoli k implicitnímu povolení.

---

# 9. Session a device security

Systém musí evidovat session tak, aby bylo možné:

- zobrazit uživateli relevantní aktivní session nebo zařízení,
- revokovat jednu session, zařízení nebo všechny session,
- svázat security event s principal a session identitou,
- rozlišit očekávanou rotaci od podezřelého replay,
- ukončit další získávání chráněných dat po revokaci.

Device identity je bezpečnostní signál, nikoli samostatný důkaz uživatele. Device metadata musí být minimalizovaná a nesmí se stát nezdokumentovaným fingerprintingem.

Citlivé operace, zejména změna přihlašovacích metod, export, smazání účtu, změna vlastnictví nebo správa integrations, musí podporovat step-up nebo recent authentication.

---

# 10. Kryptografie a ochrana dat

## 10.1 Transport

Produkční přenos autentizačních, osobních a doménových dat musí používat aktuálně bezpečný šifrovaný transport. Nešifrovaný downgrade, neplatný certifikát nebo neověřený webhook endpoint musí být odmítnut.

Konkrétní protokoly, minimální verze a certificate policy patří do deployment/security standardu.

## 10.2 Data at rest

Citlivá serverová data musí využívat platformní nebo aplikační šifrování přiměřené klasifikaci a threat modelu. Lokální data musí využívat platformní secure storage pro secrets a schválený mechanismus ochrany citlivé databáze nebo jejích polí.

Šifrování nesmí nahrazovat authorization, retenci nebo minimalizaci.

## 10.3 Hesla

Pokud systém někdy zpracovává hesla přímo, musí být uložena pouze pomocí schváleného password hashing algoritmu s individuální solí a konfigurovanou work factor. Reverzibilní šifrování hesel je zakázáno.

Preferované je delegovat primární autentizaci schválenému identity provideru, pokud ADR neprokáže jiný přístup.

## 10.4 Kryptografické klíče

Klíče musí mít:

- explicitního vlastníka a účel,
- oddělení prostředí,
- omezený přístup,
- rotaci,
- revokační nebo náhradní postup,
- audit použití tam, kde je to technicky možné.

Vlastní kryptografické algoritmy nebo protokoly jsou zakázány bez odborného review.

---

# 11. Secrets management

Produkční secrets nesmí být:

- v Git repozitáři,
- v mobilním nebo webovém bundle,
- v běžném konfiguračním souboru distribuovaném vývojářům,
- v logu, trace, analytice, screenshotu nebo test fixture,
- sdílené mezi prostředími bez explicitního schválení.

Secrets musí být získávány za běhu z řízeného secrets systému nebo bezpečného workload identity mechanismu.

Každý secret musí mít:

- účel,
- vlastníka,
- scope,
- prostředí,
- datum vytvoření nebo poslední rotace,
- rotační a revokační postup.

Detekce secretu v repozitáři musí vést k okamžité revokaci a rotaci; pouhé odstranění z posledního commitu nestačí.

---

# 12. Mobile a offline security

## 12.1 Lokální úložiště

- autentizační credentials patří pouze do platformního secure storage,
- citlivé doménové hodnoty nesmí být ukládány do nechráněných preferences,
- logy a crash reporty nesmí obsahovat tokeny ani plné citlivé payloady,
- lokální databáze musí podporovat bezpečné smazání účtu nebo oddělení profilů,
- backup chování mobilní aplikace musí být explicitně nakonfigurováno podle klasifikace dat.

## 12.2 Offline command queue

Offline command není důvěryhodný proto, že vznikl v oficiální aplikaci. Při synchronizaci musí server znovu ověřit:

- principal a session stav,
- resource ownership,
- capability,
- idempotency identity,
- schema verzi,
- doménové invarianty,
- konflikt a aktuální bezpečnostní omezení.

Revokovaná session nesmí potvrdit nové serverové operace. Klient však musí zachovat uživateli srozumitelný recovery stav neodeslaných lokálních změn.

## 12.3 Screenshoty, clipboard a notifikace

Citlivé údaje nesmí být bezdůvodně zobrazovány v lock-screen notifikacích, clipboardu nebo app-switcher preview. Konkrétní omezení musí být stanovena per screen a datová klasifikace.

## 12.4 Root a jailbreak

Detekce rootu nebo jailbreaku může být pouze doplňkový risk signal. Nesmí být jedinou bezpečnostní kontrolou ani vytvářet falešný pocit důvěry v nedetekované zařízení.

---

# 13. API a backend security

Každý veřejný endpoint musí mít explicitně definováno:

- zda je public nebo authenticated,
- požadovanou capability,
- resource ownership policy,
- input a output schema,
- maximální velikost a paging limity,
- rate-limit třídu,
- idempotency chování pro zápisy,
- audit category,
- chybovou policy,
- ochranu citlivých polí.

Backend musí používat parametrizované databázové operace nebo bezpečný ORM/query mechanismus. Dynamicky skládané příkazy, cesty a šablony musí mít kontextově správné escapování a allowlisty.

Mass assignment musí být zabráněn explicitním command mappingem. API nesmí bindovat neověřený payload přímo na persistence entity.

Veřejné chyby nesmí odhalit stack trace, SQL, secrets, tokeny, interní hostnames ani existenci nepovoleného cizího objektu.

Health a diagnostics endpointy nesmí zveřejňovat konfiguraci, credentials nebo citlivé dependency detaily.

---

# 14. AI security

AI model není trusted principal ani autorizační autorita.

## 14.1 Kontext

Context Builder smí načíst pouze data, která:

- jsou povolena principal authorization,
- odpovídají účelu requestu,
- jsou minimalizována,
- splňují consent a provider policy,
- neobsahují secrets nebo nepotřebné interní identifikátory.

Retrieval výsledek ani obsah integrace nesmí automaticky rozšířit oprávnění modelu.

## 14.2 Prompt injection

Veškerý externí nebo uživatelský text je nedůvěryhodný obsah, nikoli systémová instrukce. Prompt assembly musí oddělovat:

- systémové instrukce,
- autorizovaný kontext,
- uživatelský požadavek,
- obsah dokumentů a providerů,
- tool výsledky.

Prompt injection obrana musí být vrstvená a nesmí spoléhat pouze na textové upozornění modelu.

## 14.3 Tools

Tool call musí projít deterministickou vrstvou, která ověří:

- existenci a povolení toolu,
- principal capability,
- resource ownership,
- argument schema,
- risk class,
- potvrzovací policy,
- doménovou validaci,
- idempotency a audit.

Model nesmí obdržet raw provider credentials ani univerzální backendový token.

## 14.4 Změny dat

Generovaný text, AIProposal a skutečná doménová změna jsou oddělené kroky. AI nesmí zapisovat přímo do persistence mimo autorizovaný Proposal a ChangeSet flow.

Safety-critical rozhodnutí nesmí záviset pouze na nedeterministickém modelu. Při neúplném kontextu nebo selhání guardrail se použije konzervativní fallback.

## 14.5 Citlivá metadata

Do observability se nesmí ukládat chain-of-thought. Prompt, completion a celé konverzace se nesmí plošně logovat; případné diagnostické vzorkování vyžaduje redakci, účel, omezenou retenci a access control.

---

# 15. Integration security

Každá provider connection musí mít:

- explicitního vlastníka,
- omezený scope,
- oddělené credentials,
- známý auth a refresh lifecycle,
- revokační postup,
- audit připojení, odpojení a změny scope,
- bezpečné webhook verification pravidlo, pokud webhooky používá.

Provider access a refresh tokeny musí být ukládány jako `SECRET`. Mobilní klient je nesmí získat, pokud flow nevyžaduje platformní token přímo určený pro klienta a ADR to výslovně schválí.

Importovaný obsah je nedůvěryhodný. Musí projít schema validation, size limits, provenance označením, deduplikací a doménovou validací.

Odpojení integrace musí zastavit budoucí přístupy a naplánovat revokaci credentials. Význam dříve importovaných dat a jejich retenci určuje integration model, data architecture a privacy policy.

---

# 16. Logging, audit a observability

## 16.1 Bezpečné technické logy

Logy musí být strukturované a nesmí obsahovat:

- access nebo refresh tokeny,
- hesla, recovery secrets a provider credentials,
- celé authorization hlavičky,
- plné pain nebo health-related texty,
- celé AI konverzace,
- přesnou GPS trasu,
- celé exporty nebo import payloady.

Korelace se má provádět pomocí bezpečných technických identifikátorů, nikoli kopírováním citlivého obsahu.

## 16.2 Security audit

Audit musí zachytit minimálně:

- úspěšné a neúspěšné přihlášení v přiměřené granularitě,
- recovery a změny autentizace,
- vytvoření, rotaci a revokaci session,
- změny rolí, vztahů a capabilities,
- citlivé exporty a mazání,
- připojení a odpojení integrací,
- administrativní a support access,
- vysoce rizikové AI tool operace,
- významné změny security konfigurace.

Auditní záznam musí obsahovat principal, action, target, outcome, čas, correlation identity a relevantní policy decision. Nesmí obsahovat secret ani nadbytečný citlivý payload.

## 16.3 Ochrana auditu

Audit musí být append-oriented, přístupově oddělený a chráněný před běžnou produktovou editací. Retenci a případnou neměnnost určí data a operations kontrakty.

---

# 17. Abuse protection

Veřejné, autentizační, recovery, AI a nákladné endpointy musí být zařazeny do rate-limit tříd.

Ochrany mohou kombinovat:

- principal limit,
- session nebo device limit,
- IP a network signal,
- endpoint cost,
- provider quota,
- concurrency limit,
- cooldown,
- bezpečné challenge nebo step-up flow.

Rate limiting nesmí porušit legitimní idempotentní offline replay. Synchronizační protokol proto musí rozlišit dávkový replay od neomezeného opakování škodlivé operace.

Chybová odpověď nesmí pomáhat enumeraci účtů nebo objektů více, než je nutné pro použitelnost.

---

# 18. Supply-chain a vulnerability management

Release pipeline musí postupně zahrnout:

- dependency vulnerability scanning,
- secret scanning,
- statickou analýzu,
- kontrolu licencí podle budoucí policy,
- ochranu build provenance a artefaktů,
- podepisování nebo ověřitelnou integritu release artefaktů podle platformy,
- pravidelnou aktualizaci runtime a závislostí.

Výjimka ze security gate musí mít:

- konkrétní zranitelnost,
- dopad na AI Trainer,
- kompenzační kontrolu,
- vlastníka,
- datum expirace,
- plán opravy.

Produkční build nesmí používat debug credentials, test endpoints nebo vypnuté bezpečnostní validace.

---

# 19. Security testing

Před veřejným releasem musí existovat automatizované a manuální testy minimálně pro:

- login, logout, recovery a session revocation,
- cross-user a cross-profile authorization,
- trainer relationship scope,
- IDOR/BOLA scénáře,
- offline replay po revokaci,
- export a smazání účtu,
- integration credential lifecycle,
- webhook authenticity a replay,
- AI prompt injection a tool authorization,
- secure logging a redakci,
- rate limiting a account enumeration,
- dependency a secret scanning.

Security testy musí mapovat relevantní `NFR`, `INV`, architektonická pravidla a budoucí threat scenarios.

Penetrační nebo nezávislé odborné review je povinný release gate pro oblasti označené threat modelem jako kritické a před funkcemi pro nezletilé, zdravotně citlivé workflow nebo vysoce rizikové AI tools.

---

# 20. Incident readiness

Před produkčním provozem musí být definováno:

- kdo přijímá security alert,
- jak se incident klasifikuje,
- jak se revokují session, keys a provider credentials,
- jak se izoluje postižená integrace nebo feature,
- jak se uchovají důkazy bez dalšího úniku dat,
- jak se obnovuje služba,
- jak se provádí právní a uživatelská komunikace,
- jak se evidují nápravná opatření.

Architektura musí umožnit feature disable nebo kill switch pro rizikové integrace a AI tools bez odstavení základního workout trackeru a historie.

Konkrétní časy reakce a eskalační matice patří do incident-response a operations dokumentace.

---

# 21. Threat-model proces

Samostatný threat model musí před implementation-ready stavem pokrýt minimálně:

- identity a account recovery,
- cross-profile a trainer access,
- mobilní token a local-data compromise,
- offline command replay a sync konflikty,
- administrativní přístup,
- export a deletion flow,
- integration OAuth a webhooky,
- AI context leakage,
- prompt injection a tool abuse,
- secrets a CI/CD supply chain,
- backup a observability data.

Threat model musí pro každou významnou hrozbu evidovat:

- chráněné aktivum,
- trust boundary,
- attack path,
- předpoklady,
- existující kontrolu,
- residual risk,
- vlastníka a stav mitigace.

Tento dokument není náhradou threat modelu; definuje architektonický rámec, který threat model ověří a zpřesní.

---

# 22. Security architecture rules

## SAR-001 – Default deny

Chybějící, neznámý nebo neověřitelný autorizační kontext musí vést k zamítnutí chráněné operace.

## SAR-002 – Server-side authorization

Každá chráněná backendová operace musí serverově ověřit principal, capability, ownership nebo vztahový scope a relevantní stav zdroje.

## SAR-003 – Nedůvěryhodný klient

Mobilní nebo webový klient nesmí být autoritou pro identitu, roli, ownership, definitivní synchronizaci ani administrativní oprávnění.

## SAR-004 – Least privilege

Uživatel, trenér, administrátor, služba, integrace i AI tool musí mít pouze minimální oprávnění potřebná pro daný účel a čas.

## SAR-005 – Citlivá data podle klasifikace

Přístup, šifrování, logování, retence, backup, export a analytika musí vycházet ze schválené klasifikace dat.

## SAR-006 – Secrets mimo kód a klienta

Produkční secrets, privátní klíče a provider credentials nesmí být v repozitáři, klientském bundle, logu ani neřízené konfiguraci.

## SAR-007 – Revokovatelné session a credentials

Session, zařízení, integrační credentials a kryptografické klíče musí mít definovaný revokační nebo náhradní postup.

## SAR-008 – Reauthentication citlivých operací

Změna přihlašovacích metod, export, smazání, převod vlastnictví a další citlivé operace musí podporovat recent authentication nebo odpovídající step-up kontrolu.

## SAR-009 – Validace na každé trust boundary

Vstup z klienta, integrace, webhooku, AI modelu nebo externího provideru musí být považován za nedůvěryhodný a validován před doménovým účinkem.

## SAR-010 – AI bez přímé autority

AI model nesmí získat univerzální credential, rozšířit vlastní oprávnění ani zapisovat mimo autorizovaný Tool Gateway, Proposal a ChangeSet flow.

## SAR-011 – Bezpečný offline replay

Každý synchronizovaný offline command musí znovu projít autentizací nebo session kontrolou, autorizací, schema validací, idempotency a doménovými invariantami.

## SAR-012 – Bezpečné logování

Log, trace, analytika, audit ani crash report nesmí obsahovat secrets nebo nadbytečný citlivý payload; bezpečnostní události přesto musí být dohledatelné.

## SAR-013 – Vrstvená abuse protection

Authentication, recovery, veřejné API, AI a nákladné operace musí mít přiměřený rate limiting, anti-enumeration a abuse controls.

## SAR-014 – Security release gate

Release nesmí obejít kritickou známou zranitelnost, neprovedené threat review nebo chybějící test kritického authorization, sync nebo AI tool scénáře bez časově omezené schválené výjimky.

## SAR-015 – Konzervativní selhání

Selhání security policy, neúplný context nebo nejistota v safety-critical flow musí vést k bezpečnějšímu stavu, nikoli k implicitnímu povolení.

---

# 23. Rozhodnutí, která patří do ADR

Před implementací musí být přijata nebo naplánována ADR minimálně pro:

- identity provider a podporované login metody,
- session a token model,
- authorization policy engine nebo interní mechanismus,
- secure storage a ochranu mobilní lokální databáze,
- secrets a key management,
- transport a certificate policy,
- security audit storage,
- dependency a secret scanning toolchain,
- webhook signing a replay protection,
- provider credential storage,
- administrativní a support access.

ADR nesmí pouze vybrat technologii; musí popsat threat assumptions, alternativy, dopad, migraci a rollback.

---

# 24. Implementation-ready checklist

Security oblast není `IMPLEMENTATION_READY`, dokud nejsou splněny alespoň tyto body:

- [ ] existuje schválený threat model,
- [ ] existuje data-classification matrix,
- [ ] jsou přijata identity a session ADR,
- [ ] existuje capability a authorization matrix,
- [ ] je definován mobile secure-storage kontrakt,
- [ ] je definována secrets a key-management policy,
- [ ] API kontrakty obsahují auth, capability, rate-limit a audit metadata,
- [ ] sync kontrakt řeší revokaci, replay a idempotency,
- [ ] AI tool registry obsahuje risk class, capability a confirmation policy,
- [ ] integration kontrakty řeší credential lifecycle a webhook verification,
- [ ] logging a telemetry mají schválená redaction pravidla,
- [ ] existují security testy pro kritické flow,
- [ ] existuje vulnerability exception proces,
- [ ] existuje incident-response minimum,
- [ ] proběhlo privacy, právní a medicínské review relevantních částí.

---

# 25. Otevřené otázky

- Který identity provider a které login metody budou podporovány v první verzi?
- Budou podporovány trenérské vztahy již v prvním release?
- Jaké přesné health-related kategorie budou ukládány a jak budou právně klasifikovány?
- Jak bude chráněna lokální databáze na Androidu a iOS?
- Které AI providery splní požadavky na data use, retenci a region?
- Jaké tools budou v první verzi oprávněny měnit data?
- Které integrace budou používat OAuth, webhooky nebo lokální platformní data?
- Jak dlouho budou uchovávány security audit events?
- Jak bude řešen support access bez univerzálního administrátorského bypassu?
- Jaké severity prahy budou blokovat release?

---

# 26. Závěr

Bezpečnost AI Traineru stojí na několika společných hranicích:

```text
nedůvěryhodný klient a externí obsah
        ↓
autentizace a validace
        ↓
serverová capability + ownership autorizace
        ↓
doménové invarianty a potvrzovací policy
        ↓
autoritativní změna, audit a bezpečná synchronizace
```

AI, mobilní offline režim ani externí integrace nesmí tuto cestu obejít. Konkrétní technologie budou zvoleny ADR, ale pravidla `SAR-001` až `SAR-015` jsou závazná pro navazující kontrakty a implementaci.