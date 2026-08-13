# AI Trainer – R3 Profile and Manual Planning Vertical Slice Plan

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r3-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-08-13  
**Navazuje na:** `docs/02-product/release-scope.md` (§7), `docs/06-domain/identity-and-profile-model.md`, `docs/06-domain/sports-and-goals-model.md`, `docs/06-domain/training-plan-model.md`, `docs/06-domain/scheduling-model.md`, `docs/06-domain/workout-model.md`, `docs/06-domain/activity-model.md`, `docs/06-domain/metrics-model.md`, `docs/06-domain/sync-and-offline-model.md`, `docs/06-domain/domain-invariants.md`, `docs/12-data/data-architecture.md`, `docs/12-data/r1-physical-data-model.md`, `docs/12-data/r2-server-data-model.md` (C6), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/12-data/r2-idempotency-contract.md` (C11), `docs/11-security/r2-authorization-ownership-contract.md` (C8), `docs/13-delivery/definition-of-ready-and-done.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R3 detailní kontrakty (viz §7.1), mobilní schema migrace v4→v5+, rozšíření OpenAPI a serverového datového modelu, implementační pull requesty  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R3, slice boundaries R3, dependencies, R3 blocking contract map, evidence gates R3, R3 backlog decomposition, R3 Exit Review a pravidla `R3P-001` až `R3P-015`

---

# 1. Účel

Tento dokument je kanonický implementační plán pro celé **R3 – Profile and Manual Planning Slice**. Převádí hrubý scope z `release-scope.md §7` na implementovatelný vertikální plán: určuje hlavní hodnotu, hranice, kanonické pořadí slices `R3-01 …`, jejich závislosti, Definition of Ready, acceptance criteria, evidence gates, non-goals, blocking contract map a R3 Exit Review.

Dokument **nedefinuje** detailní tabulky, API ani UI formuláře. Pro každý slice pouze určuje, které detailní kontrakty musí vzniknout před jeho implementací, kdo je vlastní a kde budou žít (stejný princip jako `r2-vertical-slice-plan.md`).

Vztah k předchozím plánům: `r0-r1-vertical-slice-plan.md` vlastní R0/R1, `r2-vertical-slice-plan.md` vlastní R2. Tento dokument je jejich sourozenec pro R3 a nezavádí konkurenční zdroj pravdy pro R0–R2.

---

# 2. Delivery princip

- R3 se implementuje po slicech; každý slice má jeden ověřitelný výsledek a splněnou Definition of Ready.
- **Local-first zůstává invariantem** — všechny R3 plánovací operace (profil, cíle, dostupnost, plán, kalendářní operace, ruční aktivita) fungují offline; síť není podmínkou pro zápis podporované operace (`RSR-004` duchem platí i pro R3 zápisy). Serverový sync je následné potvrzení, ne podmínka.
- **Manual path first (`RSR-005`)** — celé R3 je záměrně bez AI. Vše, co R3 zavádí, musí být plně použitelné ručně; AI (R4) bude tato data pouze číst a navrhovat nad nimi.
- **Kontrakt předchází implementaci** — slice bez svých blokujících kontraktů je `NOT_READY`.
- Infrastruktura vzniká pouze v rozsahu potřebném pro aktuální nebo bezprostředně následující slice; žádné „API do zásoby".
- Backend se v R3 rozšiřuje minimálně: nové R3 entity se synchronizují existujícím R2 push protokolem (C10) s aditivním rozšířením registru entit a serverového úložiště (C6 §8.4 JSONB vzor). Nová serverová business logika nad R3 daty není P0.

---

# 3. Celkové pořadí

Kanonické pořadí (nejmenší bezpečný slice první; detail v §9):

```text
R3-01  Structured Sports Profile (sporty, zkušenost, participation patterns)   (mobile, local-first)
R3-02  Goals and Priorities                                                    (mobile, local-first)
R3-03  Availability, Equipment and Basic Constraints (typický týden)           (mobile, local-first)
R3-04  Manual Training Plan and Internal Calendar                              (mobile, local-first)
R3-05  Calendar Operations: Move, Cancel, Replace                              (mobile, local-first)
R3-06  Manual Activity and Basic Progress Statistics                           (mobile, local-first)
R3-07  R3 Sync Extension (nové entity přes existující push)                    (mobile + backend)
R3-08  R3 Critical End-to-End Evidence and Exit Review                         (mobile + backend)
```

Princip řazení:

1. Nejdřív **strukturovaný profil** (R3-01 až R3-03) — sporty/zkušenost, cíle a dostupnost/vybavení/omezení jsou vstupy, ze kterých plán vychází (a které bude v R4 číst AI). Jsou to tři samostatné, po sobě jdoucí datové slices s vlastním UI.
2. Poté **jádro hodnoty**: ruční plán a interní kalendář (R3-04) — uživatel poprvé vytváří vlastní plánované workouty místo demo seedu.
3. Poté **bezpečné kalendářní operace** (R3-05) — přesun/zrušení/nahrazení bez ztráty historie.
4. Poté **ruční aktivita a základní statistiky** (R3-06) — skutečnost mimo plán a čtení progresu.
5. **Sync rozšíření** (R3-07) je samostatný krok na konci datové části — všechny nové R3 entity vznikají od začátku s owner/sync metadaty (R2-01 vzor) a plní outbox; R3-07 „jen" aditivně rozšíří registr entit, serverové úložiště a tím je zpřístupní existujícímu R2 push flow.
6. **Kritická E2E evidence + Exit Review** (R3-08) uzavírá R3.

---

# 4. R3 value statement

**Hlavní hodnota R3:** Uživatel si vytvoří strukturovaný multisportovní profil (sporty, zkušenost, participation patterns), cíle s prioritami a dostupnost/vybavení/omezení, a nad nimi **ručně** vytvoří a spravuje vlastní tréninkový plán v interním kalendáři — včetně přesunu, zrušení a nahrazení workoutu a záznamu ruční aktivity — **celé offline, bez AI a bez ztráty historie**; jeho R3 data se následně bezpečně a idempotentně synchronizují existujícím R2 mechanismem.

Hodnota je dosažena, až když: (a) profil, cíle a dostupnost lze vytvořit a upravit offline a přežijí restart, (b) ručně vytvořený plán generuje workout instance viditelné v Today/kalendáři a proveditelné celým R1 flow, (c) přesun/zrušení/nahrazení nikdy nezničí historii ani dokončené výsledky, (d) ruční aktivita je zaznamenatelná a viditelná ve statistikách, (e) statistiky jsou deterministicky rekonstruovatelné z existujících dat a (f) R1 offline tok i R2 auth/sync tok stále fungují.

---

# 5. Scope a non-goals

## 5.1 R3 P0 scope (dle `release-scope §7.2`)

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
- základní progres a completion statistiky,
- synchronizace nových R3 entit existujícím push mechanismem,
- kritická end-to-end evidence a R3 Exit Review.

## 5.2 Non-goals R3

- generativní AI, AI návrhy plánu, AIProposal/ChangeSet (R4),
- DailyCheckIn, adaptivní denní doporučení, únava/bolest workflow (R5),
- sezony a fáze sezony, hierarchie a konflikty cílů nad rámec priorit (sports-and-goals-model je širší než R3 P0 — R3 bere jen P0 podmnožinu),
- RecurrenceSeries a opakující se události nad rámec „typického týdne" dostupnosti,
- externí kalendáře, wearables, import aktivit (P2/P3),
- pokročilé/prediktivní metriky, uživatelsky definované metriky (metrics-model P0 podmnožina: completion a základní progres),
- pull sync / obnova dat na novém zařízení (zůstává mimo P0 jako v R2 — viz §12),
- více AthleteProfile, trenérské role, sdílení plánů, marketplace,
- serverová validace/interpretace obsahu R3 payloadů nad rámec vlastnictví a idempotence (server R3 data ukládá, nečte — C6 §8.4 vzor).

---

# 6. Architektonické principy R3

- **Local-first (`sync-and-offline-model §3`)**: lokální DB je runtime zdroj UI pro všechna R3 data; vše zapisovatelné offline; pending změny jdou přes existující outbox.
- **Nové entity se rodí vlastnitelné a synchronizovatelné**: každá nová R3 aggregate root tabulka má od vzniku `owner_id` + `sync_state` a zápisy plní outbox (vzor R2-01/R2-05). Anonymní uživatel plánuje stejně plnohodnotně — data se připojí k účtu existujícím C15 attach mechanismem (rozšířeným o R3 entity).
- **Plán vs. skutečnost (`activity-model §4.1`, `DAR-003`)**: skutečnost (session, performance, aktivita) nikdy nepřepisuje plán a plán nikdy nepřepisuje skutečnost. Kalendářní operace mění **budoucí plánované** instance; dokončené/probíhající instance a jejich výsledky jsou nedotknutelná fakta.
- **Append-only historie**: přesun/zrušení/nahrazení workoutu je evidovaná změna (kdo/kdy/co), ne tichý UPDATE bez stopy; historická interpretace zůstává možná.
- **Deterministické statistiky (`metrics-model §3`)**: základní progres/completion statistiky jsou read model deterministicky odvozený z existujících summaries/aktivit — žádné uložené agregáty, které mohou divergovat, žádná falešná přesnost.
- **Seed vs. uživatelský plán**: R1 demo seed zůstává oddělený (nesynchronizuje se, C15/LAM-006). Ručně vytvořený plán a jeho instance jsou uživatelská data se standardním sync chováním. Uživatelský plán a seed mohou koexistovat; Today/kalendář čtou obojí jednotně.
- **Sync beze změny protokolu**: R3-07 nesmí měnit sémantiku C10/C11 (ORDERED_OPERATIONS, per-item výsledky, idempotence, potvrzení po commitu) — pouze aditivně rozšiřuje množinu entit a serverové tabulky podle C6 §8.4 vzoru (relační kostra + JSONB payload).
- **Ownership beze změny**: serverové vynucení vlastnictví (C8) platí pro nové entity identicky; žádná nová autorizační logika.
- **Terminologická separace (scheduling/activity model)**: `TrainingPlan` (záměr) ≠ `WorkoutInstance` (plánovaný konkrétní workout) ≠ `WorkoutSession` (provedení) ≠ `Activity` (skutečnost, i mimo plán) ≠ availability („kdy můžu") — kontrakty ani kód je nesmí slučovat.

---

# 7. Prerequisites

Před implementací kteréhokoli R3 slice platí:

1. R0–R2 jsou uzavřené a mergnuté (splněno; R2 Exit Review proveden — otevřená řízená výjimka emulátorové runtime evidence R2 se přenáší, viz §12).
2. Existuje tento vertical-slice plán.
3. Pro každý slice existují jeho **blocking detailní kontrakty** (§7.1). Dokud neexistují, je slice `NOT_READY`.

## 7.1 R3 blocking contract map

Číslování navazuje na R2 (C1–C15). Tento plán kontrakty **nevytváří** — určuje vlastníka, navrhovanou cestu, pořadí a minimum. Přesná jména a případné sloučení určí owning tým při autorizaci.

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Blocking | Minimum |
|---|---|---|---|---|---|---|
| C16 | Mobile schema migration contract (R3, v4→v5+) | Data Architecture | `docs/12-data/r3-mobile-schema-migration.md` | R3-01 (rozšiřováno před každým slicem s novou tabulkou) | ano | verzování, nedestruktivní aditivní migrace, owner/sync sloupce na nových roots od vzniku, migrační testy od reálného v4 |
| C17 | Structured sports profile contract (sporty, zkušenost, participation patterns) | Domain (sports-and-goals-model) | `docs/06-domain/r3-sports-profile-contract.md` | R3-01 | ano | P0 podmnožina sports-and-goals-model: vztah uživatele ke sportu, úroveň zkušenosti, participation pattern; stabilní kódy; editovatelnost a historie |
| C18 | Goals and priorities contract | Domain (sports-and-goals-model) | `docs/06-domain/r3-goals-contract.md` | R3-02 | ano | typ cíle (měřitelný/kvalitativní), priorita, vazba na sport, stavový lifecycle (aktivní/dosažený/opuštěný), bez hierarchie a konfliktů (non-goal) |
| C19 | Availability, equipment and constraints contract (typický týden) | Domain (scheduling-model) | `docs/06-domain/r3-availability-contract.md` | R3-03 | ano | AvailabilityRule P0 podmnožina (typický týden), vybavení/prostředí, základní omezení jako deklarace (bez medicínské interpretace), stabilní kódy |
| C20 | Manual training plan and internal calendar contract | Domain (training-plan-model + scheduling-model) | `docs/06-domain/r3-manual-plan-contract.md` | R3-04 | ano | TrainingPlan aggregate (P0: jeden aktivní uživatelský plán), vztah plán→WorkoutInstance, generování instancí do interního kalendáře, koexistence se seedem, vztah k Today/týdennímu přehledu (R1 read modely) |
| C21 | Calendar operations contract (move/cancel/replace) | Domain (scheduling-model + workout-model) | `docs/06-domain/r3-calendar-operations-contract.md` | R3-05 | ano | přesun/zrušení/nahrazení: povolené stavy (jen budoucí/nezapočaté instance), append-only evidence změny, zákaz dotknout se dokončených výsledků, idempotence operací |
| C22 | Manual activity contract | Domain (activity-model) | `docs/06-domain/r3-manual-activity-contract.md` | R3-06 | ano | Activity P0 podmnožina: ruční záznam (sport, čas/trvání, poznámka, volitelná vazba na instanci), MANUAL zdroj, bez importů; vztah k history/statistikám bez dvojího započtení |
| C23 | Progress and completion statistics contract | Domain (metrics-model) | `docs/06-domain/r3-progress-statistics-contract.md` | R3-06 | ano | deterministický read model: completion rate, počty/objem za období, zdroj = summaries + aktivity; žádné uložené agregáty; prázdná data = poctivý empty stav |
| C24 | R3 sync extension contract (registr entit + server úložiště) | Domain (sync-and-offline-model) + Data Architecture + Backend | `docs/12-data/r3-sync-extension-contract.md` | R3-07 | ano | aditivní rozšíření C10 registru o R3 entity, pořadí v hierarchii, C6 §8.4 JSONB tabulky, rozšíření C15 attach o R3 entity, žádná změna sémantiky C10/C11 |

---

# 8. Doménová a terminologická hranice

R3 kontrakty a kód musí důsledně odlišit (zdroj: training-plan-model, scheduling-model, activity-model, glossary):

- **AthleteProfile** — pro koho se plánuje; R3 jej rozšiřuje o strukturovaný sportovní obsah (sporty, zkušenost, patterns). Není to účet ani identita (R2 hranice platí).
- **Goal** — cíl s prioritou; vstup plánování, ne plán sám.
- **AvailabilityRule (typický týden)** — kdy uživatel může trénovat; deklarace dostupnosti, ne kalendářní událost.
- **TrainingPlan** — dlouhodobý strukturovaný záměr; v R3 vždy ručně vytvořený a spravovaný.
- **WorkoutInstance** — konkrétní plánovaný workout v interním kalendáři (existuje od R1); R3 je začne vytvářet z uživatelského plánu, ne jen ze seedu.
- **WorkoutSession / performance / feedback / ActivitySummary** — provedení a výsledky (R1); R3 je nemění.
- **Activity (ruční)** — zaznamenaná skutečnost, která nemusí mít plánovaný protějšek; MANUAL zdroj, dohledatelný původ.
- **Statistiky** — odvozený read model; ne nová doménová fakta.

**Kolizní pravidlo:** „plán" bez kvalifikace znamená TrainingPlan; plánovaný konkrétní trénink se vždy nazývá workout instance. Žádný R3 dokument nesmí použít „aktivita" pro workout session ani naopak.

---

# 9. Detail každého slice

Formát: Výsledek / Scope / Non-goals / Blocking kontrakty / Ready / Acceptance a evidence gate.

## 9.1 R3-01 – Structured Sports Profile

**Výsledek:** Uživatel (i anonymní) si offline vytvoří a upraví strukturovaný sportovní profil: sporty, vztah k nim, úroveň zkušenosti a participation patterns; vše přežije restart a je připraveno k syncu.

**Scope:** nové lokální tabulky dle C16 (owner/sync metadata od vzniku, outbox zápisy); domain/data/application vrstva profilového obsahu dle C17; UI pro zadání a úpravu (vč. empty/edit stavů); editace zachovává historii dle C17.

**Non-goals:** cíle, dostupnost, plán; serverový přenos (přijde v R3-07); sezony.

**Blocking kontrakty:** C16 (základ), C17.

**Ready:** `NOT_READY`, dokud neexistují C16 a C17. (První R3 slice — nezávisí na dokončení jiného R3 slice.)

**Acceptance / evidence gate:** persistence testy nad skutečnou SQLite (vytvoření/úprava/restart); migrační test od reálného v4; outbox enqueue test; R1/R2 suites beze změny zelené.

## 9.2 R3-02 – Goals and Priorities

**Výsledek:** Uživatel si offline vytvoří cíle (měřitelné i kvalitativní) s prioritami a vazbou na sport; cíle mají explicitní lifecycle.

**Scope:** tabulky dle C16 rozšíření; goal domain/data/application dle C18; UI seznamu a editace cílů; lifecycle přechody (aktivní → dosažený/opuštěný) bez mazání historie.

**Non-goals:** hierarchie/konflikty cílů, milníky, AI interpretace cílů, vyhodnocování pokroku vůči cíli (statistiky jsou R3-06 a jsou completion-based).

**Blocking kontrakty:** C18 (+ C16 rozšíření).

**Ready:** `NOT_READY`, dokud není R3-01 Done a neexistuje C18.

**Acceptance / evidence gate:** persistence + lifecycle testy; priorita ovlivňuje deterministické řazení; restart-safe; suites zelené.

## 9.3 R3-03 – Availability, Equipment and Basic Constraints

**Výsledek:** Uživatel offline zadá typický týden (dostupnost), vybavení/prostředí a základní omezení — strukturované vstupy pro ruční (a budoucí AI) plánování.

**Scope:** tabulky dle C16 rozšíření; availability/equipment/constraints dle C19; UI typického týdne a seznamů; omezení jako deklarace bez interpretace (bezpečná prezentace, žádná diagnostika).

**Non-goals:** AvailabilityException, RecurrenceSeries, kapacitní validace plánu proti dostupnosti (v R3 je dostupnost informativní vstup; vynucení je R4+ rozhodnutí).

**Blocking kontrakty:** C19 (+ C16 rozšíření).

**Ready:** `NOT_READY`, dokud není R3-02 Done a neexistuje C19.

**Acceptance / evidence gate:** persistence testy; deterministická reprezentace typického týdne; restart-safe; suites zelené.

## 9.4 R3-04 – Manual Training Plan and Internal Calendar

**Výsledek:** Uživatel ručně vytvoří vlastní tréninkový plán, který generuje workout instance do interního kalendáře — viditelné v Today/týdenním přehledu a proveditelné celým existujícím R1 flow (start → zápis → dokončení → historie).

**Scope:** TrainingPlan aggregate + generování instancí dle C20; UI vytvoření/úpravy plánu a přiřazení workoutů na dny; interní kalendář = existující R1 read modely (Today, týdenní přehled) čtoucí seed i uživatelské instance jednotně; uživatelské instance procházejí R1 session/completion flow beze změny.

**Non-goals:** bloky/týdny/fáze plánu nad P0 minimum, verze plánu s diffem, adaptace, editace šablon workoutů nad rámec C20 minima.

**Blocking kontrakty:** C20 (+ C16 rozšíření).

**Ready:** `NOT_READY`, dokud není R3-03 Done a neexistuje C20. (Profil/cíle/dostupnost existují jako kontext, plán na nich v R3 nezávisí algoritmicky — ale pořadí drží uživatelský příběh a připravuje R4.)

**Acceptance / evidence gate:** e2e-style test: vytvoření plánu → instance v Today → R1 start/complete flow nad uživatelskou instancí → historie; koexistence se seedem; restart-safe; suites zelené.

## 9.5 R3-05 – Calendar Operations: Move, Cancel, Replace

**Výsledek:** Uživatel bezpečně přesune, zruší nebo nahradí plánovaný workout — s evidovanou změnou, bez dotyku dokončených výsledků a bez ztráty historie.

**Scope:** operace dle C21 (povolené jen na budoucích/nezapočatých instancích); append-only evidence změn; UI akcí v kalendáři/detailu; typované chybové stavy (started/completed instance → bezpečné odmítnutí).

**Non-goals:** hromadné operace, drag&drop UX polish, přeplánování celého týdne, AI náhrady.

**Blocking kontrakty:** C21 (+ C16 rozšíření, pokud evidence změn vyžaduje tabulku).

**Ready:** `NOT_READY`, dokud není R3-04 Done a neexistuje C21.

**Acceptance / evidence gate:** operace na budoucí instanci projde a je evidovaná; operace na dokončené/probíhající instanci je typovaně odmítnuta; historie a výsledky nedotčeny (byte-po-bytu); idempotentní opakování; restart-safe; suites zelené.

## 9.6 R3-06 – Manual Activity and Basic Progress Statistics

**Výsledek:** Uživatel zaznamená ruční aktivitu (skutečnost mimo plán) a vidí základní progres/completion statistiky deterministicky odvozené ze svých dat.

**Scope:** Activity (MANUAL) dle C22 vč. volitelné vazby na instanci bez dvojího započtení; UI záznamu aktivity; statistiky dle C23 (completion rate, počty/objem za období) jako čistý read model nad summaries + aktivitami; poctivé empty stavy.

**Non-goals:** importy, wearables, pokročilé metriky, grafy nad P0 minimum, cíl-specifické vyhodnocení.

**Blocking kontrakty:** C22, C23 (+ C16 rozšíření).

**Ready:** `NOT_READY`, dokud není R3-05 Done a neexistují C22 a C23.

**Acceptance / evidence gate:** aktivita zaznamenaná offline přežije restart a objeví se ve statistikách; statistiky jsou rekonstruovatelné (stejný vstup → stejný výstup) a nedvojí započtení vázané aktivity; suites zelené.

## 9.7 R3-07 – R3 Sync Extension

**Výsledek:** Všechny nové R3 entity se synchronizují na server existujícím R2 push mechanismem — idempotentně, s ownership autorizací, bez změny sync sémantiky; attach anonymních dat (C15) pokrývá i R3 entity.

**Scope:** aditivní rozšíření registru entit a hierarchického pořadí dle C24 (mobil: collect/enqueue R3 roots; backend: `synced_*` tabulky dle C6 §8.4 vzoru + registr typů); rozšíření C15 attach o R3 tabulky; audit beze změny vzoru (C14); OpenAPI beze změny operace (payload je typovaný registrem).

**Non-goals:** pull sync, serverové čtení/validace R3 payloadů, nové endpointy, změny konflikt/rejection sémantiky.

**Blocking kontrakty:** C24. (C10/C11/C8/C14/C15 jsou garantovány uzavřeným R2.)

**Ready:** `NOT_READY`, dokud není R3-06 Done a neexistuje C24.

**Acceptance / evidence gate:** offline vytvořená R3 data → push → SYNCED pod client-generated ID; idempotentní replay bez duplicit; ownership negativní test na R3 entitě; attach test (anonymní R3 data → účet); konflikt na R3 entitě má explicitní stav; suites (mobile + backend Testcontainers) zelené.

## 9.8 R3-08 – R3 Critical End-to-End Evidence and Exit Review

**Výsledek:** Existuje automatizovaný důkaz hlavní hodnoty R3 a proveden R3 Exit Review.

**Scope:** deterministický kritický E2E test (viz §11) a doložení R3 Exit Review (§13) s odkazy na testy, CI runy a manuální ověření.

**Non-goals:** nové business funkce.

**Blocking kontrakty:** žádné nové — konzumuje výstupy R3-01…R3-07.

**Ready:** `NOT_READY`, dokud nejsou R3-01…R3-07 Done.

**Acceptance / evidence gate:** deterministický E2E test; flaky výsledek není zelený důkaz; R3 Exit Review kritéria splněna.

---

# 10. Cross-slice invariants

Platí po celé R3 (porušení blokuje merge):

1. **R1 offline kritický tok funguje v airplane mode** kdykoli v průběhu R3.
2. **R2 kritický tok (auth → attach → push → konflikt → revokace) zůstává zelený** — R3 nesmí rozbít sync ani auth.
3. Lokální DB je runtime zdroj UI; síť není podmínkou pro žádnou R3 zápisovou operaci.
4. Nové R3 aggregate roots mají owner/sync metadata a outbox chování od svého vzniku.
5. **Skutečnost nepřepisuje plán a plán nepřepisuje skutečnost**; dokončené a probíhající instance a jejich výsledky jsou nedotknutelné.
6. Kalendářní operace jsou append-only evidované změny; žádné tiché mazání.
7. Statistiky jsou deterministické read modely bez uložených agregátů.
8. Seed/demo data zůstávají oddělená od uživatelských (nesynchronizují se).
9. Žádná R3 funkce nevyžaduje AI, konkrétního providera ani síť (`RSR-005`, `RSR-010`).
10. Mobilní schema migrace jsou aditivní a nedestruktivní, testované od reálného předchozího stavu.
11. Sync sémantika C10/C11 (idempotence, per-item výsledky, potvrzení po commitu) se nemění.
12. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

Pro každý slice (dle `test-strategy.md`):

- **Unit tests** — doménové lifecycle přechody (goal, plan, kalendářní operace), validace, mapování.
- **Mobile SQLite/Drift integration tests** — migrace od reálného v4+, persistence, restart recovery, outbox enqueue nových entit.
- **Backend Testcontainers tests** (jen R3-07) — nové synced tabulky, ownership, idempotence, konflikt na R3 entitě.
- **Restart/recovery tests** — R3 data i pending operace přežijí restart.
- **Statistics determinism tests** — stejný vstup → stejný výstup; žádné dvojí započtení.
- **Immutability tests** — kalendářní operace nesmí změnit dokončené výsledky (byte-po-bytu).
- **Runtime evidence** — dle možností prostředí; emulátorový dluh viz §12.

**Kritická cross-slice E2E (R3-08):** profil + cíle + dostupnost → ruční plán → instance v Today → R1 provedení uživatelské instance → přesun/zrušení jiné instance s evidencí → ruční aktivita → statistiky → sync všech R3 dat pod účet (vč. attach z anonymního stavu) → replay bez duplicit. Deterministický, nad skutečnou SQLite; flaky ≠ zelený.

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Emulátorová runtime evidence (přeneseno z R2):** na vývojovém stroji chybí Android SDK; on-device ověření R2 i R3 flow zůstává otevřený dluh s definovaným postupem (R2 Exit Review). R3 jej nezvětšuje o nic principiálně nového, ale R3-08 jej musí znovu poctivě evidovat.
- **Pull sync / obnova na novém zařízení** zůstává mimo P0 i v R3 — data tečou jen nahoru. Kandidát na samostatný slice v R4/R5 plánu (před AI má nové zařízení prázdný lokální stav). Eviduje se jako vědomé omezení hodnoty.
- **Vynucení dostupnosti proti plánu** — v R3 je dostupnost informativní vstup; zda plán/AI smí porušit dostupnost řeší až R4 kontrakty.
- **Katalog sportů** — R3 nepotřebuje kompletní katalog; C17 určí minimální množinu + vlastní sport (custom). Kompletní katalog je obsahová práce mimo P0.
- **Výjimky přenesené z R1/R2** (aktivní čas = 0, kanonizace `feeling` kódů, promoce JSONB sloupců, distribuovaný rate limiter, capability registry) nejsou R3 blocker.

---

# 13. R3 Exit Review

R3 je dokončeno pouze pokud (doloženo konkrétními testy, CI runy a manuálním ověřením):

- strukturovaný profil, cíle a dostupnost/vybavení/omezení lze vytvořit a upravit offline a přežijí restart,
- ručně vytvořený plán generuje instance viditelné v Today/kalendáři a proveditelné R1 flow,
- přesun/zrušení/nahrazení funguje jen na budoucích instancích, je evidované a nedotýká se výsledků,
- ruční aktivita je zaznamenatelná a správně započtená ve statistikách,
- statistiky jsou deterministické a rekonstruovatelné,
- všechny nové R3 entity se idempotentně synchronizují pod účtem s ownership vynucením,
- attach anonymních dat pokrývá R3 entity,
- **R1 offline kritický tok i R2 kritický tok zůstávají funkční**,
- žádné secrets v lokální DB/logu (beze změny R2 záruk),
- CI (repository, mobile, backend) zelené a kritická R3 E2E evidence deterministicky prochází,
- žádný známý blocker ani critical defect,
- emulátorový dluh je poctivě evidován (nezvětšen bez důvodu).

---

# 14. Závazná pravidla R3

- **R3P-001 – Vertical slice first.** R3 se implementuje po slicech s jedním ověřitelným výsledkem.
- **R3P-002 – Contract precedes implementation.** Slice bez svých blokujících kontraktů je `NOT_READY`.
- **R3P-003 – Local-first writes.** Každá R3 zápisová operace funguje offline; sync je následné potvrzení.
- **R3P-004 – Manual path only.** Žádná R3 funkce nesmí vyžadovat AI; R3 data jsou vstupem pro R4, ne naopak.
- **R3P-005 – R1/R2 stay green.** R1 offline tok a R2 auth/sync tok musí zůstat funkční po celou dobu R3.
- **R3P-006 – Facts are immutable.** Dokončené/probíhající instance, sessions, výkony a summaries se R3 operacemi nemění.
- **R3P-007 – Append-only calendar changes.** Přesun/zrušení/nahrazení je evidovaná změna, ne tiché přepsání.
- **R3P-008 – Born ownable and syncable.** Nové aggregate roots mají owner/sync metadata a outbox chování od vzniku.
- **R3P-009 – Non-destructive migrations.** Mobilní schema migrace jsou aditivní, testované od reálného předchozího stavu.
- **R3P-010 – Deterministic statistics.** Statistiky jsou rekonstruovatelné read modely; žádné uložené agregáty, žádná falešná přesnost.
- **R3P-011 – No double counting.** Aktivita vázaná na instanci se ve statistikách nezapočítává dvakrát.
- **R3P-012 – Sync semantics unchanged.** R3 sync je aditivní rozšíření registru; sémantika C10/C11/C8 se nemění.
- **R3P-013 – Seed stays separate.** Demo seed se nestává uživatelským datem a nesynchronizuje se.
- **R3P-014 – Honest evidence.** Testy skutečně běží; flaky výsledek není zelený důkaz; výjimky se evidují.
- **R3P-015 – Scope changes are traceable.** Rozšíření P0 scope vyžaduje analýzu dle `release-scope §13` a commit v tomto dokumentu.

---

# 15. Stav backlogu

R3 backlog (`R3-01` až `R3-08`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na své blokující detailní kontrakty (§7.1: C16–C24). Implementace R3 nezačala.

První kanonický krok: vytvořit **C16 (R3 mobile schema migration)** a **C17 (structured sports profile)** → tím se `R3-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices, ne všechny najednou.
