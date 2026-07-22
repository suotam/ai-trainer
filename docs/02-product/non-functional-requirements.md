# AI Trainer – Non-Functional Requirements

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/02-product/non-functional-requirements.md`  
**Vlastník:** Product Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `vision.md`, `product-principles.md`, `product-scope.md`, `functional-requirements.md`, `domain-invariants.md`, `sync-and-offline-model.md` a ostatní doménové modely  
**Navazující dokumenty:** technické architektury, security, data architecture, quality strategy, SLO, release scope, acceptance criteria a ADR

---

# 1. Účel dokumentu

Tento dokument definuje měřitelné kvalitativní požadavky aplikace AI Trainer.

Funkční požadavky určují, **co systém dělá**. Nefunkční požadavky určují, **jak kvalitně, bezpečně, spolehlivě a předvídatelně to musí dělat**.

Dokument je zdrojem pravdy pro:

- výkon,
- dostupnost,
- spolehlivost,
- offline schopnosti,
- konzistenci a obnovu,
- bezpečnost,
- soukromí,
- accessibility,
- lokalizaci,
- mobilní battery a network chování,
- škálovatelnost,
- observabilitu,
- zálohy a disaster recovery,
- AI kvalitu, latenci a fallback,
- provozní a release quality gates.

Nefunkční požadavek nesmí být považován za splněný pouze na základě subjektivního dojmu. Musí mít ověřovací metodu, metriku nebo formální review.

---

# 2. Pravidla registru

## 2.1 Identifikace

Každý požadavek má stabilní identifikátor `NFR-xxx`.

ID se nesmí recyklovat. Zrušený požadavek zůstává evidovaný jako deprecated nebo superseded.

## 2.2 Priorita

- **CRITICAL** – porušení může způsobit ztrátu dat, bezpečnostní incident, právní problém nebo nebezpečné chování.
- **CORE** – nezbytné pro použitelnou a důvěryhodnou první produkční verzi.
- **IMPORTANT** – významný cíl kvality, který může být zpřesněn podle release scope.
- **ADVANCED** – pokročilý provozní nebo škálovací cíl.

## 2.3 Typ cíle

- **HARD LIMIT** – nesmí být překročen.
- **SLO TARGET** – provozní cíl měřený v definovaném období.
- **DESIGN CONSTRAINT** – architektura musí vlastnost umožnit.
- **QUALITY GATE** – podmínka vydání.
- **REVIEW REQUIREMENT** – vyžaduje formální odborné posouzení.

## 2.4 Prostředí

Číselné cíle se vyhodnocují v definovaném referenčním prostředí. Technická dokumentace musí později určit:

- podporovaná zařízení,
- podporované OS verze,
- referenční síťové profily,
- velikosti testovacích dat,
- zatížení backendu,
- region deploymentu.

Bez definovaného testovacího profilu nelze číselný výsledek označit za definitivní.

## 2.5 Percentily

Latence se standardně hodnotí pomocí:

- p50,
- p95,
- p99,

nikoli pouze průměrem.

## 2.6 Autorita

Nefunkční požadavek nesmí oslabit:

- právní povinnost,
- bezpečnostní pravidlo,
- globální invariantu,
- ochranu citlivých dat,
- správnost doménového výsledku.

Rychlost nesmí mít přednost před správností nebo bezpečností.

---

# 3. Dostupnost a provozní kontinuita

## NFR-001 – Dostupnost základního backendu

**Priorita:** CORE  
**Typ:** SLO TARGET  
Produkční backendové funkce potřebné pro přihlášení, synchronizaci a běžné používání musí po stabilizaci služby dosahovat měsíční dostupnosti alespoň 99,9 %, vyjma předem oznámených údržbových oken.

## NFR-002 – Kritické safety služby

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Kritická bezpečnostní validace nesmí být závislá pouze na externím AI provideru. Při jeho nedostupnosti musí systém zachovat deterministické safety blokace a konzervativní fallback.

## NFR-003 – Degradovaný režim

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Výpadek jedné nepovinné služby, například AI chatu, analytiky nebo externí integrace, nesmí způsobit nedostupnost lokálního workout trackeru, historie nebo již synchronizovaného plánu.

## NFR-004 – Izolace externích providerů

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Výpadek jednoho integration provideru nesmí blokovat importy, synchronizaci nebo použití ostatních providerů.

## NFR-005 – Plánovaná údržba

**Priorita:** IMPORTANT  
**Typ:** SLO TARGET  
Plánované zásahy s dopadem na uživatele musí být minimalizovány, evidovány a komunikovány podle budoucí release a operations policy.

## NFR-006 – Health endpointy

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Každá produkční backendová služba nebo modul s vlastním deploymentem musí poskytovat technicky vhodný liveness a readiness signál bez zveřejnění citlivých dat.

## NFR-007 – Graceful shutdown

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Backendové procesy musí při řízeném ukončení dokončit nebo bezpečně vrátit rozpracované transakce, zastavit příjem nové práce a neponechat zprávy v nejednoznačném stavu.

## NFR-008 – Regionální výpadek

**Priorita:** ADVANCED  
**Typ:** DESIGN CONSTRAINT  
Architektura nesmí znemožnit budoucí obnovu služby v náhradním regionu bez změny doménových identifikátorů a veřejných kontraktů.

---

# 4. Spolehlivost a odolnost proti chybám

## NFR-009 – Žádná ztráta potvrzeného workout záznamu

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Po potvrzení lokálního zápisu výkonu, setu, kroku nebo dokončení WorkoutSession nesmí běžný pád aplikace, restart zařízení nebo ztráta sítě způsobit jeho tichou ztrátu.

## NFR-010 – Atomické kritické změny

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Kritická změna agregátu a její auditní nebo outbox reprezentace musí být uloženy atomicky v rámci podporované transakční hranice.

## NFR-011 – Idempotentní zápis

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Opakované doručení stejného podporovaného commandu, sync operation nebo eventu nesmí vytvořit duplicitní business efekt.

## NFR-012 – Retry bez duplicit

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Automatický retry dočasně neúspěšné operace musí používat stabilní idempotency identity a kontrolovaný backoff.

## NFR-013 – Detekce permanentní chyby

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Systém musí rozlišit dočasnou a permanentní chybu a nesmí permanentně neplatnou operaci opakovat neomezeně.

## NFR-014 – Odolnost projekcí

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Odvozený read model nebo projekce musí být rekonstruovatelná bez změny autoritativních historických dat.

## NFR-015 – Integrita referencí

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Systém nesmí potvrdit stav s neplatnou cross-profile referencí, neexistujícím vlastníkem nebo zakázanou vazbou mezi agregáty.

## NFR-016 – Kontrola datové korupce

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Lokální i serverová persistence musí umožnit detekovat nepodporovanou verzi schématu, neúplnou migraci nebo zjevně poškozený záznam a přejít do bezpečného recovery flow.

## NFR-017 – Chyba nesmí být prezentována jako úspěch

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
UI, API ani AI nesmí oznámit úspěšné provedení změny před autoritativním potvrzením odpovídajícího stavu.

## NFR-018 – Konzervativní fallback

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Při nejistotě, neúplných datech nebo selhání safety vyhodnocení musí systém preferovat bezpečnější a méně agresivní výsledek.

---

# 5. Offline-first a lokální použitelnost

## NFR-019 – Dostupnost kritických offline funkcí

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Bez sítě musí být po předchozí synchronizaci dostupné minimálně:

- dnešní plán,
- detail podporovaného WorkoutInstance,
- spuštění a vedení WorkoutSession,
- zápis výkonu,
- dokončení workoutu,
- ruční Activity,
- základní DailyCheckIn,
- PainReport,
- aktivní safety omezení,
- zobrazení stavu čekající synchronizace.

## NFR-020 – Offline start aplikace

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Aplikace se musí spustit a zpřístupnit lokální podporované funkce i při nedostupném DNS, API nebo identity provideru, pokud existuje platná lokální session a data.

## NFR-021 – Lokální potvrzení zápisu

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Uživatel smí dostat potvrzení offline zápisu až po úspěšném uložení do odolné lokální persistence.

## NFR-022 – Viditelný sync stav

**Priorita:** CORE  
**Typ:** QUALITY GATE  
UI musí rozlišit minimálně lokálně uložený, čekající, synchronizovaný, neúspěšný a konfliktní stav tam, kde je rozdíl pro uživatele podstatný.

## NFR-023 – Omezená offline AI

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Nedostupnost vzdáleného AI modelu nesmí zabránit ručnímu ovládání funkcí. Aplikace musí jasně odlišit, které AI schopnosti offline nejsou dostupné.

## NFR-024 – Offline safety

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Lokální klient musí znát a vynucovat poslední synchronizovaná aktivní safety omezení relevantní pro offline workout.

## NFR-025 – Offline horizont

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Architektura musí umožnit konfigurovat množství lokálně dostupné historie a budoucího plánu podle kapacity zařízení a produktové policy.

## NFR-026 – Dlouhý offline interval

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Po delším offline období musí systém zachovat všechny podporované lokální změny, detekovat možné stale podklady a provést kontrolovanou synchronizaci bez tiché ztráty dat.

## NFR-027 – Offline clock nejistota

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Server nesmí stavové pořadí nebo oprávnění odvozovat pouze z neověřeného klientského času.

## NFR-028 – Lokalizovaná chyba sítě

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Dočasný síťový problém nesmí být uživateli prezentován jako ztráta dat nebo neplatný účet, pokud systém tento závěr nemá autoritativně potvrzený.

---

# 6. Synchronizace a konzistence

## NFR-029 – Eventual consistency s viditelným stavem

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Pokud je část systému eventually consistent, uživatelské rozhraní musí rozlišit autoritativně uloženou změnu od ještě nedokončeného odvozeného výpočtu.

## NFR-030 – Deterministické merge

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Automatické merge pravidlo musí být deterministické, verzované a testovatelné pro stejnou dvojici vstupů a kontext.

## NFR-031 – Žádný tichý conflict overwrite

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Konflikt dvou neslučitelných uživatelských změn nesmí být tiše vyřešen pouhým posledním časovým zápisem, pokud vlastnící doména neurčuje takovou policy jako bezpečnou.

## NFR-032 – Sync convergence

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Po úspěšném zpracování všech pending operací a serverových změn musí všechna autorizovaná zařízení konvergovat ke stejnému autoritativnímu stavu s výjimkou explicitně lokálních preferencí.

## NFR-033 – Tombstone ochrana

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Smazaná nebo odvolaná data se nesmí znovu objevit pouze kvůli pozdnímu uploadu staršího zařízení.

## NFR-034 – Cursor monotonicita

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
ChangeFeed cursor se smí posunout pouze po úspěšném a odolném aplikování všech předchozích změn příslušného streamu.

## NFR-035 – Partial batch failure

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Sync batch musí mít jednoznačně definované chování při částečné chybě; klient nesmí neplatně označit celý batch za potvrzený.

## NFR-036 – Stale proposal detekce

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
AIProposal nebo ChangeSet založený na změněném relevantním kontextu musí být před aplikací označen jako stale nebo znovu validován.

## NFR-037 – Sync observability

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Musí být měřitelný počet pending, failed, retried a conflicted sync operací bez logování citlivého payloadu.

## NFR-038 – Full resync

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Systém musí podporovat bezpečný full resync nebo ekvivalentní rekonstrukci lokálního stavu bez duplikace business dat.

---

# 7. Výkon mobilní aplikace

## NFR-039 – Cold start

**Priorita:** CORE  
**Typ:** SLO TARGET  
Na referenčním podporovaném zařízení má p95 cold start do použitelného lokálního shellu trvat nejvýše 3 sekundy.

## NFR-040 – Warm start

**Priorita:** CORE  
**Typ:** SLO TARGET  
Na referenčním zařízení má p95 warm start do posledního bezpečného kontextu trvat nejvýše 1,5 sekundy.

## NFR-041 – Today z lokálních dat

**Priorita:** CORE  
**Typ:** SLO TARGET  
Při dostupných lokálních datech se musí hlavní Today obsah zobrazit v p95 do 500 ms od připravenosti UI shellu.

## NFR-042 – Odezva běžné lokální akce

**Priorita:** CORE  
**Typ:** SLO TARGET  
Běžná lokální interakce, například potvrzení setu, změna timeru nebo otevření detailu, musí poskytnout vizuální odezvu v p95 do 100 ms.

## NFR-043 – Lokální transakční zápis

**Priorita:** CORE  
**Typ:** SLO TARGET  
Zápis běžného workout výkonu do lokální persistence má na referenčním zařízení dokončit v p95 do 250 ms.

## NFR-044 – Plynulost UI

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Kritické obrazovky trackeru a scrollovatelné seznamy nesmí při běžném použití vykazovat opakované dlouhé frame blokace. Přesný frame-budget bude definován mobilní quality strategií podle obnovovací frekvence zařízení.

## NFR-045 – Dlouhé seznamy

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Historie, metriky a kalendář musí používat stránkování, virtualizaci nebo jiný mechanismus, který nevyžaduje načíst celý uživatelský dataset do paměti.

## NFR-046 – Paměť aktivního workoutu

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Aktivní WorkoutSession musí zůstat použitelná na minimálním podporovaném zařízení bez nekontrolovaného růstu paměti v průběhu běžně dlouhé session.

## NFR-047 – Background návrat

**Priorita:** CORE  
**Typ:** SLO TARGET  
Po návratu aplikace z krátkého backgroundu má být aktivní WorkoutSession obnovena v p95 do 1 sekundy, pokud OS proces nezrušil.

## NFR-048 – Velké lokální datasety

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
Mobilní testovací sada musí zahrnovat profil s nejméně několika lety aktivit a tisíci záznamů bez zásadní degradace běžného Today a workout flow.

---

# 8. Výkon backendu a API

## NFR-049 – Běžné read API

**Priorita:** CORE  
**Typ:** SLO TARGET  
Při nominálním zatížení musí jednoduché autorizované read endpointy bez externí AI závislosti dosahovat serverové p95 latence nejvýše 500 ms.

## NFR-050 – Běžné command API

**Priorita:** CORE  
**Typ:** SLO TARGET  
Běžné synchronní command endpointy bez dlouhého background zpracování musí dosahovat serverové p95 latence nejvýše 1 sekundu.

## NFR-051 – Sync delta

**Priorita:** CORE  
**Typ:** SLO TARGET  
Běžný inkrementální sync s malým počtem změn musí při nominálním zatížení dokončit serverovou část v p95 do 2 sekund.

## NFR-052 – Dlouhé operace

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Operace, které mohou překročit běžný request timeout, musí být modelovány jako sledovatelný job nebo workflow s idempotentním stavem.

## NFR-053 – Query limity

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Veřejné list endpointy musí používat omezenou velikost stránky a nesmí umožnit neomezený export přes běžný synchronní request.

## NFR-054 – N+1 ochrana

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Kritické query musí mít integrační nebo performance testy chránící před neomezeným růstem počtu databázových dotazů podle počtu položek.

## NFR-055 – Timeouty

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Každá externí síťová závislost musí mít konečný timeout a kontrolovanou retry policy.

## NFR-056 – Resource limits

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
API, importy a uploady musí mít dokumentované limity velikosti, počtu položek a frekvence, aby jeden klient nemohl vyčerpat sdílené prostředky.

---

# 9. AI latence, dostupnost a fallback

## NFR-057 – První viditelná AI odezva

**Priorita:** IMPORTANT  
**Typ:** SLO TARGET  
U podporované streamované AI odpovědi má při nominálním provider stavu dojít k první smysluplné viditelné odezvě v p95 do 5 sekund.

## NFR-058 – Jednoduchý AI návrh

**Priorita:** IMPORTANT  
**Typ:** SLO TARGET  
Jednoduchý AIProposal bez rozsáhlého plánovacího workflow má při nominálním stavu dokončit v p95 do 15 sekund nebo přejít do sledovatelného asynchronního stavu.

## NFR-059 – Dlouhé plánování

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Generování rozsáhlého plánu nesmí vyžadovat udržování mobilního foreground requestu. Musí být obnovitelné a stavově sledovatelné.

## NFR-060 – Provider timeout

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
AI orchestrace musí mít časový limit, cancellation a kontrolovaný fallback bez automatického opakování nevratných tool akcí.

## NFR-061 – AI provider výpadek

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Při výpadku AI provideru musí aplikace umožnit ruční použití základních funkcí a srozumitelně komunikovat omezení.

## NFR-062 – Modelová abstrakce

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Doménové a veřejné API kontrakty nesmí být závislé na proprietárním názvu konkrétního AI modelu.

## NFR-063 – Structured output validace

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
AI výstup určený k systémové akci musí projít syntaktickou, schema, autorizační, doménovou a safety validací před vytvořením nebo aplikací ChangeSet.

## NFR-064 – Žádná přímá databázová oprávnění AI

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Model nesmí mít přímý neomezený přístup k databázi, SQL ani libovolnému internímu mutation API.

## NFR-065 – AI confidence a nejistota

**Priorita:** CORE  
**Typ:** QUALITY GATE  
AI musí v podporovaných situacích rozlišit dostatečný kontext, nejistotu a potřebu doplňující otázky; nesmí si chybějící profilový fakt vymyslet.

## NFR-066 – Deterministická safety vrstva

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Kritická safety pravidla musí být vynucena nezávisle na formulaci promptu a generovaném textu modelu.

## NFR-067 – AI audit bez chain-of-thought

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Audit AI procesu nesmí ukládat soukromý chain-of-thought. Smí ukládat pouze schválené strukturované důvody, vstupní reference, model metadata a výsledky nástrojů podle privacy policy.

## NFR-068 – Prompt injection odolnost

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
AI tool workflow musí být testován proti prompt injection z uživatelského textu, importovaných dokumentů a externích dat; nedůvěryhodný obsah nesmí měnit systémová oprávnění.

## NFR-069 – AI cost observability

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Musí být měřitelné využití modelů, tokenů, tool invocation a odhad nákladů podle bezpečné agregace bez ukládání citlivého prompt payloadu do běžné analytiky.

## NFR-070 – AI rozpočtové limity

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
AI orchestrace musí podporovat limity délky kontextu, počtu tool kroků, retry a nákladů na jedno workflow.

---

# 10. Bezpečnost

## NFR-071 – Security by design

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Bezpečnostní kontroly musí být součástí návrhu identity, API, dat, AI, integrací, sync a mobilní persistence, nikoli pouze dodatečný perimeter.

## NFR-072 – Transport encryption

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Produkční komunikace obsahující autentizační, osobní nebo doménová data musí používat aktuálně bezpečný šifrovaný transport podle schválené security policy.

## NFR-073 – Encryption at rest

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Citlivá serverová a lokální data musí být šifrována v klidu přiměřeně klasifikaci, platformě a threat modelu.

## NFR-074 – Secrets mimo zdrojový kód

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Produkční secrets, privátní klíče a provider credentials nesmí být uloženy v repozitáři, klientském bundle ani logu.

## NFR-075 – Least privilege

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Uživatel, trenér, služba, integrace i AI tool musí mít pouze minimální oprávnění potřebná pro danou operaci.

## NFR-076 – Server-side authorization

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Každá chráněná backendová operace musí autorizaci ověřit serverově; klientský activeProfileId, role nebo skryté UI nejsou autorizační důkaz.

## NFR-077 – Reauthentication citlivých změn

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Security architektura musí umožnit vyžadovat recent authentication pro změnu přihlašovacích metod, export, smazání, převod vlastnictví a další citlivé operace.

## NFR-078 – Session revocation

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Odvolaná session nebo zařízení nesmí po přijetí revokace získávat nová chráněná data ani potvrzovat nové operace.

## NFR-079 – Brute-force ochrana

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Authentication a recovery endpointy musí mít ochranu proti automatizovanému hádání, enumeraci účtů a zneužití recovery procesu.

## NFR-080 – Bezpečné chybové odpovědi

**Priorita:** CORE  
**Typ:** HARD LIMIT  
Veřejná chyba nesmí odhalit secrets, interní stack trace, SQL, token nebo nepovolený detail cizího objektu.

## NFR-081 – Dependency vulnerability management

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Release pipeline musí kontrolovat známé zranitelnosti závislostí a blokovat release podle schválené severity policy.

## NFR-082 – Security event audit

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Přihlášení, recovery, změny autentizace, revokace zařízení, změny oprávnění a administrativní přístupy musí vytvářet odpovídající auditní záznamy.

## NFR-083 – Rate limiting

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Veřejné API a nákladné operace musí podporovat rate limiting a abuse protection bez blokování legitimního offline replay.

## NFR-084 – Security testing

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Před veřejným releasem musí být dokončeny automatizované security testy, threat-model review a manuální test kritických auth, authorization, sync a AI tool scénářů.

---

# 11. Soukromí, consent a právní kvalita

## NFR-085 – Data minimization

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Systém smí požadovat, ukládat a přenášet pouze data potřebná pro explicitně definovaný produktový, bezpečnostní nebo právní účel.

## NFR-086 – Purpose limitation

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Citlivá data nesmí být použita pro jiný účel než ten, pro který existuje právní základ a produktová policy.

## NFR-087 – Consent versioning

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Právně relevantní souhlas musí být dohledatelný podle účelu, verze, scope, času a stavu odvolání.

## NFR-088 – Okamžitý účinek odvolání

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Odvolání souhlasu musí zastavit budoucí zakázané zpracování v definovaném maximálním čase a invalidovat relevantní cache, joby a AI kontext.

## NFR-089 – Privacy defaults

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Výchozí viditelnost osobního profilu, aktivit, trasy a health-related dat musí být soukromá, pokud uživatel explicitně nezvolí jinak.

## NFR-090 – Export dat

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Uživatelský export musí být bezpečně dostupný, časově omezený, strojově čitelný a nesmí obsahovat access tokeny nebo secrets.

## NFR-091 – Smazání účtu

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Proces smazání musí pokrýt serverová data, projekce, integrace, credentials, zařízení a pozdní offline upload podle schválené retention policy.

## NFR-092 – Retenční klasifikace

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Každá významná datová kategorie musí mít vlastníka, účel, klasifikaci, retenční policy a pravidlo smazání nebo anonymizace.

## NFR-093 – Citlivá data mimo běžnou analytiku

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Běžná produktová analytika nesmí obsahovat text bolesti, přesnou zdravotní historii, celé AI konverzace, GPS trasu, autentizační údaje ani další zakázaná citlivá data.

## NFR-094 – Minor protection review

**Priorita:** CRITICAL  
**Typ:** REVIEW REQUIREMENT  
Funkce pro nezletilé nesmí být vydány bez právního a bezpečnostního review pro podporované jurisdikce.

## NFR-095 – Medical boundary review

**Priorita:** CRITICAL  
**Typ:** REVIEW REQUIREMENT  
Pain, limitation, recovery a odborné doporučení nesmí být označeny za implementation-ready bez medicínského a právního posouzení wordingů a escalation pravidel.

## NFR-096 – Přístup administrátora

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Administrativní přístup k osobním nebo citlivým datům musí být omezený, auditovaný, účelově zdůvodněný a časově přiměřený.

---

# 12. Accessibility

## NFR-097 – Platform accessibility

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Mobilní aplikace musí podporovat systémový screen reader, dynamickou velikost textu a základní platformní accessibility API na podporovaných OS.

## NFR-098 – Kontrast

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Text, interaktivní komponenty a významné grafické informace musí splnit cílovou úroveň WCAG definovanou v accessibility specifikaci; předběžným cílem je WCAG 2.2 AA.

## NFR-099 – Informace ne pouze barvou

**Priorita:** CORE  
**Typ:** HARD LIMIT  
Stav, chyba, safety warning ani výsledek grafu nesmí být komunikován pouze barvou.

## NFR-100 – Touch targets

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Primární interaktivní prvky musí splnit minimální platformní rozměry dotykového cíle, vyjma zdokumentovaných výjimek.

## NFR-101 – Dynamic text

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Kritické obrazovky musí zůstat použitelné při výrazně zvětšeném systémovém textu bez skrytí primárních akcí nebo dat.

## NFR-102 – Reduced motion

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
Aplikace musí respektovat systémovou preferenci omezeného pohybu a nepoužívat nepostradatelnou informaci pouze v animaci.

## NFR-103 – Focus order

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Screen-reader focus order musí odpovídat logickému pořadí obsahu a umožnit dokončit kritické flow.

## NFR-104 – Accessibility workout trackeru

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Workout tracker musí umožnit zaznamenat výkon, ovládat timer a dokončit session bez závislosti na přesných gestech nebo pouze vizuálním kontextu.

## NFR-105 – Accessibility testování

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Každý kritický flow musí mít automatizovanou accessibility kontrolu a manuální test alespoň s hlavními platformními assistive technologies před veřejným releasem.

---

# 13. Lokalizace, čas a jednotky

## NFR-106 – Oddělení textů od kódu

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Uživatelské texty musí být spravovatelné v lokalizační vrstvě a nesmí být nekontrolovaně rozptýlené v business logice.

## NFR-107 – Stabilní interní kódy

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Překlad nesmí měnit interní identifikátory, event type, enum kódy, jednotky ani význam API kontraktu.

## NFR-108 – Locale formáty

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Datum, čas, čísla a jednotky musí být zobrazeny podle aktivního locale a UnitPreference.

## NFR-109 – Kanonické jednotky

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Změna zobrazovací jednotky nesmí destruktivně měnit kanonickou uloženou hodnotu.

## NFR-110 – Timezone korektnost

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Scheduling, recurrence, notifikace a denní agregace musí být testovány přes změny timezone a daylight-saving času.

## NFR-111 – Absolutní historický čas

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Změna aktuálního timezone nesmí změnit absolutní okamžik historické události.

## NFR-112 – Překlad AI komunikace

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
AI komunikace má respektovat zvolený podporovaný jazyk, ale strukturované tool kontrakty a doménové kódy zůstávají jazykově nezávislé.

## NFR-113 – Fallback locale

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Chybějící překlad nesmí způsobit pád aplikace; musí být použit dokumentovaný fallback a chyba musí být pozorovatelná pro tým.

---

# 14. Battery, síť a mobilní zdroje

## NFR-114 – Žádný trvalý polling bez důvodu

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Mobilní klient nesmí používat nepřetržitý polling, wakelock nebo background location, pokud není aktivní funkce, která jej vyžaduje.

## NFR-115 – Background sync efektivita

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Background sync musí slučovat práci, používat platformní scheduler a respektovat omezení baterie, dat a OS.

## NFR-116 – Cellular policy

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
Velké uploady, historické backfill a media operace musí respektovat uživatelskou volbu mobilních dat a podporovat odklad na vhodnou síť.

## NFR-117 – GPS spotřeba

**Priorita:** CORE  
**Typ:** QUALITY GATE  
GPS recording musí používat přesnost a sampling přiměřené sportovnímu účelu a nesmí běžet po ukončení nebo zrušení ActivityRecording.

## NFR-118 – Timer bez permanentního běhu

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
RestTimer a workout čas musí být rekonstruovatelné z časových údajů a nesmí vyžadovat nepřetržitý high-frequency background proces.

## NFR-119 – Síťová komprese

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Velké podporované payloady a change feed musí používat vhodné stránkování, kompresi nebo binární přenos podle budoucí architektury.

## NFR-120 – Battery testy

**Priorita:** CORE  
**Typ:** QUALITY GATE  
GPS, dlouhý workout, background sync a push scénáře musí mít měřitelný battery test na referenčních zařízeních před veřejným releasem.

---

# 15. Škálovatelnost a kapacita

## NFR-121 – Horizontální škálování stateless částí

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Stateless backendové části nesmí používat lokální procesovou paměť jako jediný zdroj session nebo workflow stavu.

## NFR-122 – Izolace bulk workloadu

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Historický import, přepočty a exporty nesmí vyčerpat kapacitu kritických interaktivních a safety operací.

## NFR-123 – Backpressure

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Queue a background processing musí podporovat backpressure, limity concurrency a prioritní třídy práce.

## NFR-124 – Indexovatelný růst dat

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Datový model a query musí být testovány s realistickým růstem aktivit, metrik, eventů a sync změn na uživatele.

## NFR-125 – Tenant a profile izolace při škálování

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Partitioning, caching ani shard strategie nesmí oslabit izolaci AthleteProfile a oprávnění.

## NFR-126 – Capacity model

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Před veřejným releasem musí existovat kapacitní odhad pro uživatele, aktivitní zápisy, sync operace, AI requesty, storage a provider limity.

## NFR-127 – Load test kritických cest

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Login, Today read, workout completion, sync a běžný AI request musí mít load test podle release capacity modelu.

## NFR-128 – Graceful overload

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Při přetížení musí systém omezit nebo odložit bulk a nepovinné funkce dříve než kritické safety, sync potvrzení a aktivní workout operace.

---

# 16. Observabilita a auditovatelnost

## NFR-129 – Strukturované logy

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Produkční logy musí být strukturované, korelovatelné a nesmí standardně obsahovat citlivý payload.

## NFR-130 – Distributed tracing

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Kritické distribuované workflow musí podporovat correlation a trace context přes API, background jobs a eventy.

## NFR-131 – Metriky služby

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Musí být měřitelné minimálně request rate, error rate, latency, saturation, queue lag, sync failures, AI provider failures a database health.

## NFR-132 – Alerty

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Kritické SLO, safety event processing, auth failure spike, data pipeline failure a rostoucí dead-letter stav musí mít akční alert.

## NFR-133 – Žádné PII v telemetry defaults

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Standardní telemetry nesmí obsahovat celé jméno, e-mail, přesnou trasu, health text, token nebo AI prompt bez zvláštní bezpečné policy.

## NFR-134 – Auditní neměnnost

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Auditní záznam významné změny nesmí být běžnou doménovou editací přepsán nebo odstraněn mimo retenční a privacy proces.

## NFR-135 – Alert noise control

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Alerting musí podporovat deduplikaci, severity a potlačení symptomových alertů tak, aby kritický signál nebyl ztracen v šumu.

## NFR-136 – User-visible incident state

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
Dlouhodobější výpadek relevantní funkce má být uživateli komunikován srozumitelně bez interních technických detailů.

## NFR-137 – Reproducibility metadata

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Výpočet metrik, AI návrh a plánovací workflow musí evidovat verzi relevantní metodiky, modelu nebo pravidel potřebnou pro pozdější vysvětlení.

---

# 17. Zálohy, obnova a disaster recovery

## NFR-138 – Automatizované zálohy

**Priorita:** CRITICAL  
**Typ:** DESIGN CONSTRAINT  
Autoritativní produkční data musí mít automatizované zálohy podle schválené retention a encryption policy.

## NFR-139 – Ověření obnovy

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Záloha se nepovažuje za funkční bez pravidelně testované obnovy v izolovaném prostředí.

## NFR-140 – RPO

**Priorita:** CRITICAL  
**Typ:** SLO TARGET  
Cílový Recovery Point Objective pro autoritativní uživatelská data bude nejvýše 15 minut, pokud architektura později neschválí přísnější hodnotu.

## NFR-141 – RTO

**Priorita:** CORE  
**Typ:** SLO TARGET  
Cílový Recovery Time Objective pro základní produkční službu bude nejvýše 4 hodiny po závažném obnovitelném incidentu.

## NFR-142 – Konzistence po obnově

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Po obnově musí být ověřena konzistence databáze, outbox/inbox, event cursorů, credentials a projekcí před znovuotevřením zápisů.

## NFR-143 – Runbook obnovy

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Před produkčním releasem musí existovat aktualizovaný a otestovaný runbook obnovy databáze, storage a kritických credentials.

## NFR-144 – Ochrana záloh

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Zálohy musí mít minimálně stejnou klasifikaci a ochranu jako primární data a nesmí obcházet deletion a retention policy bez právního důvodu.

---

# 18. Maintainability, změny a kompatibilita

## NFR-145 – Modulární hranice

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Implementace musí respektovat vlastnící doménové hranice a nesmí vytvářet nekontrolovaný sdílený model, který umožní obcházet invariance.

## NFR-146 – Verzované veřejné kontrakty

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
API, event, sync a AI tool kontrakty musí být explicitní a verzovatelné.

## NFR-147 – Backward compatibility mobilního klienta

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Backend musí podporovat dokumentované kompatibilní okno mobilních verzí a nesmí bez řízené upgrade policy okamžitě rozbít starší podporovaný klient.

## NFR-148 – Databázové migrace

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Produkční migrace musí být verzované, auditované, testované na realistickém datasetu a mít rollback nebo forward-recovery strategii.

## NFR-149 – Lokální migrace

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Mobilní lokální schema migrace musí zachovat pending commands, aktivní WorkoutSession a nesynchronizovaná data.

## NFR-150 – Feature flags

**Priorita:** IMPORTANT  
**Typ:** DESIGN CONSTRAINT  
Rizikové nebo postupně vydávané funkce musí být možné řídit feature flagem, aniž by flag obcházel authorization nebo safety.

## NFR-151 – Konfigurační změny

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Environment-specific konfigurace nesmí vyžadovat změnu doménového kódu a secrets nesmí být součástí běžné konfigurace v repozitáři.

## NFR-152 – Dependency policy

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Nová závislost musí mít zdokumentovaný účel, licenci, maintenance stav a bezpečnostní posouzení přiměřené riziku.

## NFR-153 – Testovatelnost

**Priorita:** CORE  
**Typ:** DESIGN CONSTRAINT  
Čas, identita, externí provider, AI model a další nedeterministické závislosti musí být oddělitelné tak, aby kritická business pravidla bylo možné deterministicky testovat.

## NFR-154 – Documentation synchronization

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Změna veřejného kontraktu, invariance, kanonického pojmu nebo zásadního chování nesmí být dokončena bez aktualizace vlastnící dokumentace.

---

# 19. Testovatelnost a release quality gates

## NFR-155 – Automatizované testy kritických invariant

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Každá implementovatelná globální invariance musí mít automatizovaný test nebo explicitní zdůvodnění, proč vyžaduje jiný typ ověření.

## NFR-156 – Offline test matrix

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Release musí projít scénáři ztráty sítě před zápisem, během zápisu, po lokálním potvrzení, během sync a při návratu po dlouhé offline době.

## NFR-157 – Multi-device test matrix

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Musí být testovány souběžné změny alespoň dvou zařízení, conflict resolution, revokace zařízení a pozdní upload.

## NFR-158 – Crash recovery test

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Aktivní workout, lokální command queue a migrace musí být testovány při násilném ukončení procesu v kritických bodech.

## NFR-159 – Performance regression gate

**Priorita:** CORE  
**Typ:** QUALITY GATE  
CI nebo release pipeline musí sledovat definované performance benchmarky a blokovat významnou nezdůvodněnou regresi kritických cest.

## NFR-160 – Accessibility gate

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Kritický flow nesmí být vydán s neopraveným závažným accessibility problémem podle schválené severity policy.

## NFR-161 – AI evaluation gate

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Nový model, prompt nebo tool workflow nesmí být nasazen bez evaluace správnosti strukturovaného výstupu, safety, hallucination, injection a regresních scénářů.

## NFR-162 – Provider contract tests

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Každá externí integrace musí mít contract, sandbox nebo replay testy pro mapování, chyby, rate limit, revokaci a provider změny.

## NFR-163 – Security release gate

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Release nesmí obsahovat známou neakceptovanou kritickou zranitelnost v aplikaci, závislosti nebo konfiguraci.

## NFR-164 – Migration gate

**Priorita:** CRITICAL  
**Typ:** QUALITY GATE  
Serverová i mobilní migrace musí být před releasem otestována z každé podporované předchozí verze.

## NFR-165 – Rollback readiness

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Každý produkční release musí mít dokumentovanou rollback nebo forward-fix strategii pro kód, konfiguraci a databázové změny.

---

# 20. Uživatelská srozumitelnost a důvěra

## NFR-166 – Srozumitelná chyba

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Uživatelská chyba musí vysvětlit, co se nepodařilo, zda jsou data bezpečně uložená a jaký další krok je dostupný.

## NFR-167 – Vysvětlitelnost AI změny

**Priorita:** CORE  
**Typ:** QUALITY GATE  
AIProposal musí uživateli zobrazit, co se má změnit, proč, z jakého podporovaného kontextu návrh vychází a zda vyžaduje potvrzení.

## NFR-168 – Jasný autor stavu

**Priorita:** IMPORTANT  
**Typ:** QUALITY GATE  
U relevantní změny musí být možné rozlišit, zda ji vytvořil uživatel, trenér, AI, import nebo systémová automatizace.

## NFR-169 – Nepravdivá přesnost

**Priorita:** CRITICAL  
**Typ:** HARD LIMIT  
Systém nesmí zobrazovat odhad nebo neúplně podloženou metriku jako přesně naměřený fakt bez označení zdroje a jistoty.

## NFR-170 – Safety wording

**Priorita:** CRITICAL  
**Typ:** REVIEW REQUIREMENT  
Texty bolesti, omezení a odborné pomoci musí být odborně zkontrolované, konzervativní a nesmí představovat diagnózu.

## NFR-171 – Confirmation clarity

**Priorita:** CORE  
**Typ:** QUALITY GATE  
Potvrzovací dialog významné změny musí rozlišit návrh od provedeného stavu a zobrazit rozsah dopadu.

## NFR-172 – Žádné dark patterns

**Priorita:** CORE  
**Typ:** HARD LIMIT  
Consent, subscription, data sharing, account deletion a notification nastavení nesmí používat zavádějící nebo nátlakové dark patterns.

---

# 21. Quality attributes podle oblastí

## 21.1 Kritické atributy

Za kritické jsou považovány:

- neztracení workout a sync dat,
- izolace AthleteProfile,
- bezpečné AI tools,
- authorization,
- safety a pain handling,
- consent withdrawal,
- export a deletion,
- lokální recovery,
- audit významných změn.

## 21.2 Obchodovatelné atributy

V konkrétní release lze podle schváleného ADR nebo scope upravit například:

- číselný AI latency target,
- dostupnost pokročilých integrací,
- délku lokální historie,
- maximální podporovaný dataset,
- pokročilý multi-region cíl.

Nelze však obchodovat s:

- správností,
- izolací dat,
- právními zákazy,
- safety blokací,
- zachováním potvrzených lokálních dat.

---

# 22. Měření a odpovědnost

Každý NFR musí být před stavem `IMPLEMENTATION_READY` namapován alespoň na jedno z:

- automatizovaný test,
- benchmark,
- SLO dashboard,
- security control,
- privacy control,
- odborné review,
- release checklist,
- provozní runbook.

Budoucí traceability matrix musí obsahovat:

```text
NFR
    ↓
architecture control
    ↓
implementation component
    ↓
test or metric
    ↓
release gate / SLO
```

---

# 23. Otevřená rozhodnutí

Před finálním schválením je nutné potvrdit zejména:

- přesný podporovaný device a OS matrix,
- finální cold-start a API latency baselines,
- produkční availability SLO podle zvolené infrastruktury,
- RPO a RTO podle nákladů a release fáze,
- přesnou cílovou WCAG úroveň,
- podporované jazyky a locale,
- velikost realistického testovacího datasetu,
- mobilní battery budget,
- AI provider a modelové latency profily,
- AI cost budget,
- rozsah multi-region strategie,
- retenční období podle právního review,
- kompatibilní okno mobilních verzí,
- severity policy pro security, accessibility a performance gate.

Otevřené číselné cíle nesmí být tiše změněny implementací. Musí vzniknout aktualizace tohoto dokumentu nebo schválené ADR.

---

# 24. Kritéria připravenosti

Dokument může přejít na `IMPLEMENTATION_READY`, až když:

1. každý požadavek má vlastníka oblasti,
2. číselné cíle mají definovaný referenční profil,
3. CRITICAL požadavky jsou namapovány na kontrolu a test,
4. security a privacy požadavky prošly odborným review,
5. medical boundaries prošly odborným review,
6. mobilní performance a battery cíle jsou ověřeny proof-of-concept měřením,
7. backendové SLO jsou sladěny s cloud a cost architekturou,
8. AI cíle jsou sladěny s model selection a fallback policy,
9. release gates jsou součástí quality dokumentace,
10. rozpory s funkčními požadavky a invariantami jsou vyřešeny.

---

# 25. Závěr

Nefunkční požadavky určují minimální kvalitu, bez které AI Trainer není důvěryhodný produkt.

Nejdůležitější řetězec je:

```text
uživatelská akce
    ↓
rychlá lokální odezva
    ↓
odolný zápis
    ↓
bezpečná synchronizace
    ↓
autorizovaná serverová změna
    ↓
audit a observabilita
    ↓
obnovitelnost bez ztráty dat
```

AI workflow musí dodržet:

```text
kontext
    ↓
modelový výstup
    ↓
structured validation
    ↓
authorization
    ↓
domain and safety validation
    ↓
user confirmation podle policy
    ↓
ChangeSet
    ↓
auditovatelný business efekt
```

Produkt nesmí být považován za kvalitní pouze proto, že funguje v ideálním online scénáři. Musí zůstat bezpečný, vysvětlitelný a obnovitelný při výpadku sítě, restartu zařízení, duplicitním doručení, provider chybě, konfliktu více zařízení i neúplném AI kontextu.