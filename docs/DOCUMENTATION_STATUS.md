# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 2.32  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-08-12  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Pravidla práce

Před vytvořením dokumentu nebo implementační změny se vždy:

1. načte aktuální stav GitHubu,
2. přečte `docs/README.md` a tento audit,
3. ověří související zdroje pravdy,
4. posoudí překryvy a duplicity,
5. ověří Ready stav backlog itemu,
6. provede změna a povinné kontroly,
7. změna skutečně commitne,
8. aktualizuje dokumentace a evidence podle dopadu.

Nový dokument vznikne pouze pro potvrzenou mezeru nebo samostatný kontrakt. Po dokončení startovního minima se již nemá vytvářet další obecná dokumentace místo implementace `R0-01`.

---

# 2. Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ; zbývá konsistenční nebo odborné review.
- **IMPLEMENTATION_READY** – potřebné kontrakty pro daný slice jsou dostupné.
- **SUBSTANTIAL_DRAFT** – rozsáhlý použitelný draft, zatím ne finálně schválený.
- **PARTIAL** – oblast je pokryta pouze částečně.
- **PLANNED** – dokument nebo kontrakt je potvrzený pro budoucí slice.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již vlastněn jiným zdrojem pravdy.
- **EXPERT_REVIEW_REQUIRED** – vyžaduje odborné ověření.

---

# 3. Současný souhrn

Projekt má obsahově pokryté:

- vizi, principy, product scope a release scope,
- persony, scénáře, informační architekturu, flow a obrazovky,
- hlavní doménové modely, události, invariance a glossary,
- `FR-001` až `FR-192` a `NFR-001` až `NFR-172`,
- backend, data, mobile, AI, security a integration architecture,
- repository strategy a `RER-001` až `RER-015`,
- ADR `ADR-001` až `ADR-011` (R0/R1 + R2 auth provider strategy `ADR-011`/C5),
- fyzický lokální datový model R1 a `PDR-001` až `PDR-015`,
- minimální R0 API kontrakt a `APR-001` až `APR-015`,
- test strategy a `QTR-001` až `QTR-015`,
- Definition of Ready and Done a `DRD-001` až `DRD-015`,
- R0/R1 vertical-slice plan a `VSP-001` až `VSP-015`,
- coding-agent/context-loading guide a `CAG-001` až `CAG-015`.

**Startovní dokumentační minimum pro R0 a R1 je dokončeno.**

`R0-01 – Repository Skeleton` je implementován: existuje kanonická root struktura (`apps/mobile`, `apps/backend`, `packages/contracts`, `tooling/scripts`), root `README.md`, `.editorconfig`, rozšířený `.gitignore` a repository smoke check `tooling/scripts/repo-smoke-check.sh`. Adresáře `database/`, `.github/` a `compose.yaml` vzniknou až se slices, které je skutečně potřebují (R0-05, R0-06).

`R0-02 – Mobile Bootstrap` je implementován: Flutter aplikace v `apps/mobile` s Riverpod composition rootem, GoRouter shellem, základním theme, lokalizací (en + cs), environment configuration boundary a technickou úvodní obrazovkou; `flutter analyze` a testy jsou zelené, Android build a spuštění na emulátoru ověřeno. Dřívější výjimka DRD-013 pro iOS build evidence byla uzavřena v R0-06: `flutter build ios --no-codesign` prošel na GitHub macOS runneru (mobile workflow, job `iOS build (no codesign)`).

`R0-03 – Backend Bootstrap` je implementován: Kotlin/Spring Boot aplikace v `apps/backend` (Gradle wrapper, JDK 25, Spring Boot 4.1) s bezpečnou konfigurací bez secrets, testovatelným `Clock` beanem, `X-Request-Id` infrastrukturou s MDC korelací logů a service name/version providerem; build a testy zelené, lokální start ověřen včetně kontroly logů (bez secrets a environment dumpu). Produktové moduly a health API vzniknou v navazujících slices.

`R0-04 – Contracts and Health API` je implementován: kanonický OpenAPI `packages/contracts/openapi/ai-trainer-api.yaml` (getLiveness, getReadiness, error envelope, X-Request-Id headers), backend implementuje `GET /api/v1/health/live` a `/ready` s `Cache-Control: no-store`, centralizovaným bezpečným error envelope a rozšiřitelným `ReadinessIndicator` portem (nyní pravdivě pouze `application` check; database/migrations checky doplní R0-05 bez změny veřejného kontraktu). Contract testy (swagger-parser nad kanonickým souborem), unit a integration testy včetně 503 failure path jsou zelené; runtime ověřeno lokálně přes curl. PostgreSQL readiness evidence (skutečná nedostupná databáze, Testcontainers) bude dokončena v R0-05.

`R0-05 – Local Infrastructure and Migrations` je implementován: root `compose.yaml` spouští lokální PostgreSQL 17 s development-only credentials a healthcheckem (host port přepsatelný přes `AITRAINER_POSTGRES_PORT`), kanonické serverové Flyway migrace žijí v `database/migrations` (build je balí do backend classpath — jedna kopie), minimální `V1__schema_baseline` bez produktových tabulek, readiness rozšířena o `database` a `migrations` checky přes existující `ReadinessIndicator` port (aditivní, kontrakt beze změny). Testy používají skutečný PostgreSQL přes Testcontainers včetně migration testu od prázdné databáze, nevalidního schema stavu (503 → recovery migrací → 200) a zastavené databáze (liveness 200, readiness 503). Compose runtime evidence ověřena lokálně včetně failure path. Lokální start backendu nově vyžaduje běžící PostgreSQL (Flyway při startu).

`R0-06 – CI and Repository Gates` je implementován: `.github/workflows/` obsahuje `repository` (smoke check, gitleaks secret scan nad plnou historií, Compose validace), `mobile` (Flutter 3.44.4: format/analyze/test/Android debug build + iOS no-codesign build na macOS runneru) a `backend` (Gradle wrapper validace, JDK 25, ktlint gate, build + čerstvý test run včetně OpenAPI contract a PostgreSQL/Flyway Testcontainers testů). Všechna workflow běží na PR i push do `main` s `contents: read`; lokální příkazy odpovídají CI. Backend ktlint gate (`./gradlew ktlintCheck`, ktlint-cli 1.8.0) je zapojen do `check`. První PR run: všech 6 jobs zelených.

`R0-07 – Mobile-to-Backend Smoke Flow` je implementován: mobilní `BackendHealthClient` boundary s HTTP adapterem volá health API podle kanonického OpenAPI (`live` + `ready`), backend base URL řídí environment boundary (`--dart-define=BACKEND_BASE_URL`, dev default `http://10.0.2.2:8080`), technický stavový blok na úvodní obrazovce má stavy loading/success/not-ready/failure s explicitním Retry (bez automatického retry loopu, bez interních detailů v chybách). Pokryto unit, provider a widget testy s fake clientem; runtime end-to-end ověřeno na Android emulátoru proti lokálnímu stacku (Compose PostgreSQL + backend): success, failure po zastavení backendu bez pádu aplikace, retry po obnově → success, korelační request ID v backend logu bez secrets. Backend beze změny.

## R0 Exit Review (2026-07-23)

R0 je uzavřeno. Kontrola podle VSP §11 a DoD §9 na merge commitu R0-06 a PR R0-07:

1. mobile i backend se reprodukovatelně sestaví lokálně i v CI (Android APK, iOS no-codesign na GitHub macOS runneru, Gradle build),
2. backend, PostgreSQL a Flyway se lokálně spustí přes `compose.yaml`; migrace od čisté databáze testovány přes Testcontainers,
3. health API odpovídá kanonickému OpenAPI (contract testy, integration testy success i failure path),
4. mobile-to-backend smoke flow funguje (runtime evidence R0-07 výše),
5. CI (repository, mobile, backend) prochází na čistém checkoutu; push runy na `main` zelené,
6. test a migration evidence existují (36 backend testů, 25 mobile testů, JUnit/CI záznamy),
7. žádný secret v repozitáři (gitleaks nad plnou historií v CI),
8. R1 není závislé na backendu (VSP §5 R1 lokální; smoke flow je technický, ne produktová závislost),
9. všechny dřívější řízené výjimky uzavřeny (iOS build evidence uzavřena v R0-06),
10. žádný známý blocker ani critical defect; otevřené neblokující položky: potvrzení `com.aitrainer.*` identifikátorů před distribucí, branch protection (admin úkon).

`R1-01 – Local Workout Seed and Read Model` je implementován: Drift/SQLite schema verze 1 přesně podle `r1-physical-data-model.md` (všech 10 tabulek, CHECK/FK/unique constraints, partial unique index jedné aktivní session, expression index pořadí kroků, `PRAGMA foreign_keys = ON`), deterministický verzovaný demo seed (`seed_version` v `local_app_state`, stabilní `demo-` ID, idempotentní, nepřepisuje uživatelsky změněné instance) a workout read model: doménové modely + mappery odmítající neznámé enum kódy, `WorkoutInstanceRepository` (today/týden/celý snapshot) a Riverpod composition. Poznámka k VSP: fyzický model záměrně nemá profile/plan tabulky — demo „plán" je sada naplánovaných demo instancí, profil v R1 persistence nemá. Ověřeno 17 novými persistence testy nad skutečnou SQLite (od prázdné DB, constraints, idempotence, snapshot bez sítě). Mobile CI hlídá drift generovaného Drift kódu.

`R1-02 – Today and Workout Detail` je implementován: první produktové read-only UI nad read modelem z R1-01. Today je nyní kanonický domov (`/today`), detail je `/workouts/:workoutId`; technická R0 startup obrazovka (backend smoke flow) se přesunula na `/startup` a zůstává dostupná. Application-level `WorkoutBootstrap` use case spouští idempotentní seed při prvním čtení Today; read providery čekají na dokončení bootstrapu, takže read model se nezobrazí dřív, než je seed validní. Today má stavy loading/data/empty/error (s explicitním Retry, bez automatického loopu), detail zobrazuje stabilní snapshot (sekce → kroky → série v pořadí) a bezpečný not-found pro neplatné ID. Read-only: bez startu session, editace, zápisu, historie. Ověřeno 22 novými provider/widget/integration testy (fake repository i skutečná SQLite) a runtime na Android emulátoru bez backendu (bootstrap, Today data, detail cviků, restart bez duplikace dat). Backend beze změny.

`R1-03 – Start and Persist Session` je implementován: první write flow. Use case `StartWorkoutSession` (application, bez Flutter/backend) generuje stabilní session ID (injektovaný `IdGenerator`), používá injektovaný clock a deleguje atomický start na `DriftWorkoutSessionRepository` — jedna Drift transakce: ověření instance, kontrola globálně aktivní/pozastavené session, vytvoření session (`ACTIVE`), přepnutí instance na `IN_PROGRESS`, uložení active-session pointeru. Právě jedna aktivní session je vynucena aplikačně v transakci, s partial unique indexem z R1-01 jako poslední linií ochrany. Typované výsledky created/resumedExisting/conflictWithAnotherSession/workoutNotFound — nikdy raw persistence výjimka. Recovery přes `activeSessionProvider` po restartu (stejné ID i start time, bez sítě/pollingu). UI: start button (guard proti dvojitému tapu), active session screen (read-only), navigace, conflict/not-found/error stavy. **Schema beze změny (zůstává verze 1)** — session tabulka a indexy existovaly z R1-01; migrace nebyla potřeba. Bez zápisu výkonu/dokončení/zrušení (pozdější slices). Ověřeno 23 novými testy (persistence nad skutečnou SQLite vč. reálného reopen/recovery a partial unique indexu, application/provider, widget s reálnou navigací) a runtime na Android emulátoru bez backendu (start → active session, force-stop restart → resumed na stejnou session „Started at 22:19", on-device DB dotaz: přesně 1 aktivní session). Řízené odchylky: (1) výchozí StepPerformance/SetPerformance řádky z fyzického modelu §15.1 kroku 4 jsou odloženy do R1-04 (Record Set Performance), aby R1-03 nezaváděl tracking scaffolding „do zásoby"; (2) invariant „právě jedna aktivní session" je aplikačně globální (přísnější než per-instance PDR-005), v souladu s conflict pravidly zadání. Backend beze změny.

`R1-04 – Record Set Performance` je implementován: první reálný tracker výkonu během aktivní session. Výchozí `StepPerformance`/`SetPerformance` řádky (odložené z R1-03) se inicializují idempotentně ze stabilního snapshotu v jedné Drift transakci — klíčováno na `unique(session, step)` a `unique(step_performance, position)`, takže opakovaná inicializace (i po restartu) nevytvoří duplikáty ani nepřepíše existující actual data. Write command `recordSetActuals`/`setSetCompletion` (data) ověří existenci a aktivitu session, validuje vstup, zapíše v transakci actual hodnoty + `row_version` + `updated_at` session, volitelně status setu a `completed_at` (injektovaný clock); typované výsledky saved/validationFailure/sessionNotActive/setNotFound — nikdy raw Drift výjimka do UI. Aplikační use case `RecordSetPerformance` odmítá záporné reps/váhu ještě před dotykem persistence (negativeReps/negativeWeight); DB CHECK constraint je poslední linie. **Striktní oddělení plán vs. výkon (PDR-003):** planned reps/váha zůstávají v neměnném snapshotu `local_set_plans`, actual jen v performance tabulkách; chybějící actual se nikdy auto-nezoruje. **R1-04 nedokončuje session** — zapisuje pouze výkon setu; session zůstává `ACTIVE`, `completed_at` je null, instance zůstává `IN_PROGRESS`, active-session pointer beze změny. Tracker UI na active session screen: identita workoutu/session, sekce a kroky v pořadí, planned hodnoty, actual inputy pro podporované typy, completion marker, saving/saved/validation/error stavy (bez raw DB detailu), obnovení po restartu; guard proti dvojitému paralelnímu save stejného setu. **Schema beze změny (zůstává verze 1)** — všechny performance tabulky existovaly z R1-01; migrace nebyla potřeba. Ověřeno novými testy (idempotentní inicializace, application use case, persistence nad skutečnou SQLite vč. reálného reopen/recovery a odmítnutí záporných hodnot constraintem, provider/controller vč. double-save guardu, widget) — mobile suite zelená (+113), backend beze změny (36/36). Runtime na Android emulátoru bez backendu: zadání actuals do 2 setů, dokončení setu, force-stop + restart → resume, actual i completion obnoveny, session stále ACTIVE; on-device DB agregát: 1 aktivní / 0 completed session, 2 step- a 6 set-performance řádků bez duplikátů, přesně 2 sety s actuals a 1 completed.

`R1-05 – Restart and Recovery` je implementován: robustní a explicitní recovery flow po restartu aplikace. Startup recovery gate (`app/startup/recovery_gate_screen.dart`) je kanonická initial route — po dokončení lokálního bootstrapu (otevření DB + idempotentní seed) spustí application use case `RecoverActiveSession` a teprve pak rozhodne o navigaci, takže se Today nikdy krátce nezobrazí před rozhodnutím. **Zdrojem pravdy o aktivní session je tabulka session (status `ACTIVE`/`PAUSED`), ne technický pointer** v `local_app_state` (`active_session_id`), který je jen cache (fyzický model §14/§19, PDR-012). Use case odvodí kanonický nebo konfliktní stav z počtu aktivních sessions, ověří snapshot vazbu (existenci instance), idempotentně doplní chybějící performance řádky (bezpečné: validní aktivní session + validní snapshot; existující actual data zůstávají) a **bezpečně rekonstruuje pointer z jediné aktivní session** v jedné transakci (§19 povolená oprava). Typované výsledky: `NoActiveSession` (→ Today), `ActiveSessionRecovered` / `ActiveSessionRecoveredAfterRepair` (→ stejný tracker se stejnými uloženými hodnotami), `MultipleActiveSessions` / `InconsistentActiveSession` (missingInstance | orphanPointer) / `UnrecoverableRecovery` (→ bezpečný fallback s Retry) — nikdy raw Drift/SQLite výjimka do UI. **Opravitelné vs. neopravitelné:** chybějící pointer při jediné validní aktivní session se bezpečně opraví; více konfliktních aktivních sessions, osiřelý pointer bez odvoditelné session a nekonzistentní snapshot vedou na explicitní bezpečný fallback bez destruktivního mazání (žádný agresivní self-healing, žádné odhadování business hodnot). **Recovery nedokončuje ani neruší session, negeneruje nové session ID, nemění start time, nevytváří druhou aktivní session a nevyžaduje backend.** Startup UI stavy: konečný loading (žádný nekonečný retry/loop), přechod na Today, automatické pokračování do trackeru, bezpečný fallback s explicitním Retry (obnoví i bootstrap). Deep link na validní session zůstává funkční; neplatný session ID končí bezpečným not-found. **Schema beze změny (zůstává verze 1)** — `local_app_state` i všechny session/performance tabulky existují z R1-01; migrace nebyla potřeba, generated kód beze změny. Ověřeno novými testy (rozhodovací matice application use case; persistence nad skutečnou SQLite vč. reálného reopen/recovery, idempotentní opravy pointeru, osiřelého pointeru, více aktivních sessions, rollbacku a zachování dat R1-01…R1-04; startup provider vč. Retry a absence paralelní opravy; widget/navigation gate vč. deep linku; end-to-end restart) — mobile suite zelená (+140), backend beze změny (36/36). Runtime na Android emulátoru bez backendu: start → zápis actualů → dokončení setu → force-stop → normální restart → automatická recovery přímo do stejného trackeru (stejný start time, actual i completion zachovány, session ACTIVE, žádný flash Today); controlled inconsistency: smazán jen technický pointer → restart → pointer bezpečně rekonstruován (recoveredAfterRepair), žádná ztráta dat; on-device DB agregát: 1 aktivní session, pointer odpovídá session, 2 step- a 6 set-performance řádků bez duplikátů napříč restarty.

`R1-06 – Complete Workout and History` je implementován: uzavření prvního kompletního workout flow. Application use case `CompleteWorkout` (bez Flutter/Drift/backend, injektovaný clock) deleguje na `DriftWorkoutCompletionRepository`, který provede **jednu atomickou transakci podle fyzického modelu §15.3**: validace stavu session, dopočet dokončení kroků z completion stavu setů, přepnutí session na `COMPLETED` + `completed_at`, přepnutí instance na `COMPLETED`/`PARTIALLY_COMPLETED` + `completed_at`, vytvoření `ActivitySummary` a vyčištění technického active-session pointeru (jen pokud ukazuje na tuto session). **Idempotence (PDR-007):** už dokončená session → `alreadyCompleted` no-op (původní `completed_at`, žádný duplicitní summary — vynuceno i DB unikátem `local_activity_summaries.workout_session_id`); selhání kroku vrátí celou transakci (rollback bez částečného stavu). **Completion nevyžaduje dokončení všech setů** (workout-model §39.2/§39.3): `COMPLETED` = vědomé uzavření, `PARTIALLY_COMPLETED` = jen část kroků dokončena. Planned snapshot i performance data se nikdy nemažou ani nepřepisují. Typované výsledky completed/alreadyCompleted/sessionNotFound/sessionNotCompletable/instanceNotFound/inconsistentState — nikdy raw Drift výjimka do UI (raw selhání zachytí controller → bezpečný error). **Historie** je read model rekonstruovatelný z `local_activity_summaries` (DAR-006): `WorkoutHistoryRepository` vrací dokončené workouty deterministicky (nejnovější první), read-only completed detail reusuje tracker read model (planned vs. actual, completion, bez inputů/akcí — jasně odlišený od aktivního trackeru; chybějící actual jako „–", ne nula). **Recovery po dokončení:** pointer je vyčištěn, takže R1-05 recovery vrací `NoActiveSession` a aplikace jde na Today — dokončený tracker se znovu neotevře a session se nereaktivuje. UI: `Complete workout` tlačítko s potvrzovacím dialogem (pravdivě uvádí počet dokončených setů; dialog data nemění, zápis až po potvrzení), ochrana proti dvojitému tapu, po úspěchu navigace do historie + invalidace active/recovery/Today/history providerů (bez restartu). History akce z Today. **Schema beze změny (zůstává verze 1)** — `local_activity_summaries`, session/instance `completed_at`/status existují z R1-01; migrace nebyla potřeba, generated kód beze změny. Ověřeno novými testy (application use case; persistence nad skutečnou SQLite: §15.3 efekty, instance COMPLETED vs PARTIALLY_COMPLETED, idempotence bez duplicit, rollback, recovery→NoActiveSession, history dotaz; provider/controller vč. double-tap guardu a history providerů; widget: Complete + confirm cancel/confirm, navigace, read-only detail; end-to-end §11.2 seed→start→zápis→restart→recovery→dokončení→historie) — mobile suite zelená (+167), backend beze změny (36/36). Runtime na Android emulátoru bez backendu: zápis actualu + dokončení setu → Complete → potvrzovací dialog („1 z 6 sérií") → odchod do historie; on-device DB: session COMPLETED + completed_at, instance PARTIALLY_COMPLETED + completed_at, pointer vyčištěn, 1 session, 1 summary, 6 performance řádků zachováno, actual reps=12; po force-stop + restartu aplikace jde na Today (ne tracker), read-only detail ukazuje stejné actual hodnoty. **R1-06 není poslední R1 slice** (následují R1-07, R1-08), proto se R1 Exit Review neprovádí a R1 se neuzavírá.

`R1-07 – Feedback, States and Accessibility` je implementován: hlavní R1 flow má základní uživatelskou dokončenost a neskrývá failure stavy. **Feedback** (subjektivní náročnost RPE 0–10, pocit, flag bolesti, volitelná poznámka) se zachytává v **bezpečném potvrzovacím dialogu dokončení** (screen-spec §3.9/§40) a ukládá **v existující atomické completion transakci** (§15.3 krok 3 — žádný nový use case/transakce): rozšířeny `WorkoutCompletionRepository.completeWorkout` a use case `CompleteWorkout` o volitelný `WorkoutFeedbackInput`; feedback řádek do `local_workout_feedback` a snapshot `overall_effort` do `ActivitySummary` (§13). Feedback je **volitelný/skippable** (workout-model §40.3): prázdný se neukládá, dialog vrací `null` při zrušení (žádný zápis). **Idempotence:** už dokončená session → feedback se nemění (jedna zpětná vazba na session, DB unique). Feeling používá stabilní kódy `GREAT/GOOD/OKAY/TIRED/ROUGH` (fyzický model §12 vyžaduje „stabilní kód pocitu", množinu nedefinuje — tato je kanonická pro R1). Feedback je **znovu načitelný** v read-only completed detailu (`WorkoutHistoryRepository.feedbackBySessionId` → `CompletedWorkoutDetail.feedback`); přeskočený feedback zobrazí bezpečnou informaci. **Bolest** je v R1 jen flag s konzervativním bezpečným upozorněním (§12 řádek 329) — žádná diagnostika ani AI. **Accessibility** (screen-spec §70): hlavní ovládací prvky mají čitelné sémantické labely (Complete workout, náročnost s hodnotou „Effort N of 10"), dialog přežije zvětšení textu (text scaling) bez pádu a bez skrytí akcí, ovládání bez psaní (chips/switch). **States**: loading/empty/error/recovery zůstávají explicitní (běžná chyba se neprezentuje jako úspěch — completion error je bezpečný stav, ne navigace). **Základní lokalizační struktura** rozšířena o feedback řetězce (EN/CS). **Schema beze změny (zůstává verze 1)** — `local_workout_feedback` i `overall_effort` existují z R1-01; migrace nebyla potřeba, generated kód beze změny. Ověřeno novými testy (feedback persistence nad skutečnou SQLite: uložení v transakci, snapshot, reload, idempotence, skip; provider: controller předává feedback; widget: feedback dialog capture/cancel/skip, pain upozornění, completed detail reload; accessibility: sémantické labely + text scaling) — mobile suite zelená (+181), backend beze změny (36/36). Runtime na Android emulátoru bez backendu: dokončení workoutu s feedbackem (náročnost 7, pocit Good) → History → read-only detail „Effort: 7/10, Feeling: Good"; on-device DB: 1 feedback řádek (effort 7.0, feeling GOOD, pain 0) + summary snapshot 7.0; po force-stop + restartu feedback stále načitelný v detailu. **R1-07 není poslední R1 slice** (následuje R1-08), proto se R1 Exit Review neprovádí a R1 se neuzavírá.

`R1-08 – Critical End-to-End Evidence` je implementován: existuje **automatizovaný důkaz hlavní hodnoty R1**. Nový test `apps/mobile/test/features/workouts/r1_critical_path_e2e_test.dart` prokazuje celý povinný scénář (VSP §19, test-strategy §11.2) v jednom deterministickém Flutter testu nad **skutečnou lokální SQLite persistence** (skutečné Drift repozitáře, bootstrap, recovery i completion; overridnuty jen technické hranice — DB, clock, ID). Scénář: 1. start s lokálními demo daty → Today, 2. otevření dnešního workoutu, 3. zahájení session, 4. zápis výkonu (Save), 5. „ukončení a znovuspuštění" (kompletní odmontování app vrstvy a její znovupostavení nad stejnou persistence — obnovená app čte výhradně z DB), 6. recovery aktivní session se stejným uloženým výkonem, 7. dokončení (feedback přeskočen), 8. workout v historii (+ přežití dalšího restartu), 9. bez backendu a sítě. Test je deterministický (fixní clock + verzovaný seed + stabilní ID + bounded pumpy místo `pumpAndSettle`, protože fokusovaný TextField má blikající kurzor = nekonečná animace). Žádná nová business funkcionalita, obrazovka, repository, use case ani schema změna — R1-08 jen přidává end-to-end důkaz. Ověřeno: mobile suite zelená (+182), backend beze změny (36/36). Runtime na Android emulátoru **v airplane mode** (offline, bez backendu): celý tok seed → today → start → zápis → force-stop restart → recovery → dokončení → historie proběhl offline; po dalším restartu historie obsahuje dokončený workout a recovery vede na Today; on-device DB: 1 completed session, 0 aktivních, 1 summary, pointer vyčištěn.

## R1 Exit Review

R1-08 je poslední R1 slice, proto je proveden R1 Exit Review (VSP §20). R1 je dokončen — všechna kritéria splněna:

- **hlavní flow funguje v airplane mode** — runtime E2E proveden v airplane mode (offline) od startu po historii; RSR-004 dodrženo.
- **aktivní session přežije restart** — R1-05 recovery + runtime restart evidence; automatizováno (QTR-008) v `session_recovery_persistence_test.dart` a v R1-08 e2e testu.
- **potvrzený výkon se neztrácí** — R1-04 persistence + R1-08 e2e (Save → restart → recovered '10').
- **completion je atomická a idempotentní** — R1-06 `DriftWorkoutCompletionRepository` (§15.3, jedna transakce, DB unique + alreadyCompleted); ověřeno (QTR-009) v `workout_completion_persistence_test.dart`.
- **historie obsahuje dokončený workout** — R1-06 history read model; ověřeno v persistence + e2e testu i runtime (přežití restartu).
- **běžné failure stavy jsou explicitní** — typované výsledky start/record/recovery/completion, bezpečné error/fallback stavy bez raw detailu (R1-03…R1-07), completion error se neprezentuje jako úspěch.
- **critical-path testy, migration tests a CI gates jsou zelené** — mobile +182, backend 36/36; schema zůstalo verze 1 přes celé R1, takže žádná destruktivní migrace nevznikla (drift-check čistý); poslední push-na-main CI běhy (repository, mobile, backend) zelené — viz PR/CI evidence R1-08.
- **nevznikla závislost na účtu, sync, AI ani externím provideru** — celé R1 běží lokálně bez backendu (RER-013).

**Řízené výjimky přecházející do R2:** `active_duration_seconds` v ActivitySummary je v R1 vždy 0 (aktivní čas se neinkrementuje — feature R2); feedback `feeling` má stabilní kódy zvolené v R1 (docs množinu nedefinuje) — případná kanonizace v R2; samostatná editace feedbacku/výkonu mimo completion flow je mimo R1; sync/backend workout API/AI jsou R2+. Žádná z výjimek neblokuje R1 exit criteria.

**Release 1 je uzavřen** (R1-08 mergnut, R1 Exit Review proveden).

**R2 – Account and Sync je naplánované, ale implementace nezačala.** Existuje kanonický R2 vertical-slice plán `docs/13-delivery/r2-vertical-slice-plan.md` (vlastní pořadí R2, blocking contract map, evidence gates, R2 Exit Review a pravidla `R2P-001` až `R2P-015`). Definovaný R2 backlog: `R2-01` Local Ownership and Sync Metadata Foundation, `R2-02` Backend Account and Authentication Baseline, `R2-03` Mobile Auth and Secure Session Storage, `R2-04` AthleteProfile and Device Registration, `R2-05` Ownership Authorization and First Sync (push), `R2-06` Conflict, Rejection and Session Revocation, `R2-07` Local-to-Account Data Migration, `R2-08` R2 Critical End-to-End Evidence and Exit Review.

**`R2-01` až `R2-05` jsou implementovány; kontrakty C12 a C13 existují → `R2-06` je `READY` (neimplementováno); `R2-07` zůstává `NOT_READY` (čeká na C15) a `R2-08` `NOT_READY`.**

`R2-01 – Local Ownership and Sync Metadata Foundation` je implementován: mobilní Drift schema **verze 2** s explicitní nedestruktivní migrací `v1 → v2` (C1 `MSM-*`), která zachová všechna R1 data i aktivní session — na vlastnitelných aggregate roots (`local_workout_instances`, `local_workout_sessions`, `local_activity_summaries`) přibyly sloupce `owner_id` a `sync_state` s bezpečným defaultem (backfill na `local-anonymous` / `LOCAL_ONLY`, `MSM-014`); vznikla restart-safe **outbox** tabulka `local_outbox` (`LocalChangeLog`/`OfflineCommand`, C2 §6/§7) se stabilním idempotency key a deterministickým `sequence`; ID lokálního/anonymního vlastníka je v `local_app_state`. Domain/data/application vrstva `features/sync/` (`LocalSyncMetadataRepository` + Drift implementace): `localOwnerId`, idempotentní `enqueue` (LSM-008/009), `pendingOperations` v deterministickém pořadí (LSM-012) — **bez sítě a bez odesílání** (non-goal). Ověřeno migračním testem od reálného v1 stavu (zachování dat + aktivní session + backfill + FK check), outbox restart testem a beze změny R1 offline toku; mobile suite zelená (**+188**), backend beze změny (36/36 — první běh selhal jen kvůli Docker-down, po startu Dockeru čistý). Runtime na Android emulátoru bez sítě: v2 schema živě (user_version=2), `local_outbox` + owner/sync defaulty na zařízení, R1 tok (recovery → Today) beze změny. Drift generovaný kód commitnutý, drift-check čistý. Řízená rozhodnutí: (1) owner/sync metadata na aggregate roots (child performance/feedback řádky vlastněny tranzitivně přes session; per-row sync doplní R2-05); (2) tabulkový `sync_state` CHECK je jen na fresh v2 schématu — SQLite `ALTER ADD COLUMN` nepřidává table-level CHECK na migrovaný stav (hodnoty jsou default-safe a app-kontrolované).

`R2-02 – Backend Account and Authentication Baseline` je implementován: serverová **Flyway migrace `V2__account_auth_baseline`** (append-only, C6 §7 — `identity`, `account`, `authentication_identity` s `UNIQUE(provider, provider_subject)`/INV-011, `auth_session`, `auth_refresh_credential` s partial unique indexem jedné ACTIVE refresh credential, `idempotency_record`, `audit_event`; žádné plaintext secrets — jen BCrypt/SHA-256 hashe, SDM-010) a **auth endpointy dle C4/OpenAPI** (`POST /auth/registrations` s povinným Idempotency-Key, `POST /auth/sessions`, `POST /auth/sessions/refresh`, `DELETE /auth/sessions/current`, `GET /auth/session`). Kanonické OpenAPI rozšířeno o Auth operace (AAC-014, contract testy aktualizovány). **ADR-011 varianta A:** backend je first-party session authority — neprůhledné 256bit tokeny, krátká access session (PT15M) + rotující refresh (P30D) s **detekcí replay** (použití rotované credential revokuje celou session), revokovatelnost, server-authoritative session context. Vrstvy `auth/domain|application|data|transport` (use cases `RegisterAccount`/`LoginWithPassword`/`RefreshAuthSession`/`LogoutCurrentSession` + `AccessSessionAuthenticator`, typované výsledky — nikdy raw výjimka do HTTP). **Idempotentní registrace** (AAC-005): retry se stejným klíčem a payloadem vrátí týž účet bez duplicit; jiný payload je odmítnut; duplicitní identita → 409 `DUPLICATE_LOGIN_IDENTITY`. **Bez account enumeration** (AAC-008): generický `INVALID_CREDENTIALS` + dummy-hash timing ekvalizace. **Rate limiting baseline** (SAR-013): in-memory fixed window per klient+operace, 429 `RATE_LIMITED` s `Retry-After`. **Audit dle C14 §6** (AEC-*): `AccountRegistered`, `LoginSucceeded/Failed`, `AuthSessionIssued/Refreshed/RefreshRejected/LoggedOut/Revoked` — append-oriented `audit_event`, zápis v transakci operace, korelace request ID, žádné secrets/PII. Stavy účtu vynucovány (ISC-010): `ACCOUNT_DISABLED`/`ACCOUNT_DELETED`; default deny na chráněných hranicích (`ACCESS_SESSION_EXPIRED`/`SESSION_REVOKED`). Ověřeno Testcontainers PostgreSQL testy (celý flow, refresh rotation + replay revokace, idempotence, security-negative, expirace access/refresh, stavy účtu, constraint testy V2, no-plaintext-secrets v DB, audit outcome, log-redaction s ListAppenderem, kanonický error envelope) + aktualizované migration testy od prázdné DB (V1→V2) a OpenAPI contract testy. Mobil beze změny; R1/R2-01 mobilní tok nezávisí na backendu (R2P-004). Řízená rozhodnutí: (1) bez plného Spring Security — chráněné hranice ověřuje `AccessSessionAuthenticator` (jen `spring-security-crypto` pro BCrypt), plný framework zváží R2-04/05 s ownership enforcement (C8); (2) refresh credential se přenáší výhradně v request body refresh operace (AAC-010); (3) in-memory rate limiter je vědomě lokální baseline — distribuovaný limiter až s produkčním deploymentem.

`R2-03 – Mobile Auth and Secure Session Storage` je implementován: mobilní feature `features/auth/` (domain/application/data/presentation) podle C4 a C7. **Secure storage boundary (C7 §5):** port `SecureSessionStorage` + platformní adaptér `FlutterSecureSessionStorage` (flutter_secure_storage — Keychain/Keystore) s jedním atomickým JSON zápisem; session materiál (access/refresh credential) nikdy v Drift/SQLite, preferences ani logu (TSS-002/003/004); testy běží s in-memory fake (TSS-005), UI čte jen odvozený ne-secret stav (TSS-012). **Jediný zapisující vlastník `AuthSessionManager`** (TSS-006, AsyncNotifier): restore po startu čte výhradně secure storage bez sítě — chybějící materiál je validní anonymní stav (TSS-007), poškozené úložiště vede na bezpečný signed-out fallback bez pádu a bez ztráty lokálních dat (TSS-008); sign-in/registrace přes `HttpAuthApiClient` dle C4 (kanonické error kódy → typované výsledky, refresh výhradně v request body/AAC-010, generické INVALID_CREDENTIALS/AAC-008); registrace drží idempotency key per e-mail a opakuje ho po výpadku sítě (AAC-005 — retry nevytvoří druhý účet); logout je local-first — materiál se odstraní i offline, serverová revokace je best-effort (TSS-009), lokální workout data a outbox zůstávají (LSM-006, ISC-012); `verifySession` = server-authoritative ověření + obnova access session refresh rotací; revokace/replay vede na bezpečné odhlášení bez ztráty dat (TSS-010), nedostupný server zachová lokální stav (offline session, security §7.3). **UI:** `/account` obrazovka (login/registrace toggle, typované chybové stavy vč. rate-limit a offline, double-tap guard, sémantické labely; přihlášený stav s technickým account ID, Check session a Sign out) + account akce na Today. **R1 offline tok beze změny** (R2P-004) — auth je volitelný vstup, žádný gate. Ověřeno 22 novými testy: manager unit/provider (restore/restart bez sítě, corrupt-storage fallback, idempotentní registrace po výpadku, offline logout — security-negative, verify: active/refreshed/revoked/offline), **no-secret-in-DB** test (reálná souborová SQLite + seed + auth flow → scan bytů souboru: žádné heslo/tokeny), widget testy account screen (login/registrace/chyby/restart-with-session/logout/revokace). Mobile suite zelená (**210 testů**), `flutter analyze` čistý; backend beze změny. Řízené výjimky/rozhodnutí: (1) runtime ověření na Android emulátoru nebylo na tomto stroji provedeno (chybí Android SDK/emulátor) — automatizovaná evidence je kompletní, emulátorová runtime evidence se doplní nejpozději v R2-08; (2) registrace je součástí R2-03 UI (bez ní nelze účet z aplikace vytvořit; C4 operaci vlastní a scope R2 P0 „vytvoření účtu" ji vyžaduje); (3) `verifySession` je explicitní akce uživatele — žádný automatický reconnect/refresh loop (konzistentní s R0/R1 no-auto-retry pravidlem).

`R2-04 – AthleteProfile and Device Registration` je implementován: serverová **Flyway migrace `V3__profile_device`** (append-only dle C6 §8.1–§8.3 — `athlete_profile` s client-generated ID a partial unique indexem jednoho SELF profilu na účet, `device_installation` s přirozeným klíčem (account, installation) a composite FK vazbou `auth_session → device_installation`; žádné fingerprinting sloupce). **Backend:** feature moduly `profile/` a `device/` (domain/application/data/transport) + sdílený `PrincipalResolver` (AOC-002 — principal výhradně z ověřené access session). Profil: `POST /profiles` (idempotentní podle client-generated profileId — SDM-005; druhý SELF profil → 409 `PROFILE_ALREADY_EXISTS`), `GET /profiles/current`, `GET /profiles/{id}` s **ownership enforcementem dle C8** — cizí i neexistující profil je shodně 404 `RESOURCE_NOT_FOUND` (AOC-007, stejný tvar odpovědi) a ownership violation se audituje (`AuthorizationDenied`/REJECTED/OWNERSHIP_MISMATCH, AOC-013). Zařízení dle C9: `PUT /devices/{installationId}` (idempotentní upsert per účet+instalace — DRC-006, aditivní vazba aktuální session na instalaci — C9 §6, audit `DeviceRegistered`, revokovaná instalace → 409 `DEVICE_REVOKED` bez tiché reaktivace), `GET /devices` (kolekce filtrovaná principalem — AOC-008; stejné installation ID pod druhým účtem je oddělená registrace bez úniku informace). OpenAPI rozšířeno o Profile/Device operace + contract testy. **Mobil:** installation ID jako ne-secret klíč v `local_app_state` (`DriftInstallationIdentityRepository` — vznik při prvním použití, stabilní přes restart, nová DB = nová instalace; DRC-001/002/003, bez mobilní schema migrace — key-value), `DeviceRegistrar` (registrace po přihlášení z AccountScreen, best-effort bez retry loopu — DRC-004/015, minimalizovaná metadata: platforma/verze aplikace/skutečná verze Drift schématu), `features/profile/` (HTTP klient create/current, `CreateProfileController` drží client-generated profileId přes retry po výpadku sítě — žádný duplikát) a profil sekce na AccountScreen (vytvoření/zobrazení, typované chyby, explicitní retry načtení). Ověřeno **13 novými backend testy** (Testcontainers: idempotence profilu i zařízení, jeden SELF profil, ownership-negative 404 nerozlišitelné + audit, kolekce filtrované, vazba session→zařízení, revokovaná instalace, V3 constraints vč. composite FK, migrace V1→V3 od prázdné DB) a **15 novými mobile testy** (installation ID lifecycle nad skutečnou SQLite, registrace po přihlášení/skip anonymní/offline, stabilita profileId přes retry, widget: registrace zařízení po loginu, vytvoření a zobrazení profilu). Backend suite **74/74**, mobile suite **225/225**, `flutter analyze` čistý. Řízené výjimky/rozhodnutí: (1) runtime ověření na Android emulátoru neproběhlo (chybí Android SDK na stroji) — doplní se nejpozději v R2-08; (2) R2 capability baseline (C8 §6) je implicitní — standardní aktivní účet má všechny baseline capabilities nad vlastními daty, samostatná capability služba vznikne až s kontraktem capability registry; (3) explicitní odregistrace zařízení (C9 §7 volitelná) odložena do C13/R2-06.

`R2-05 – Ownership Authorization and First Sync (push)` je implementován: serverová **Flyway migrace `V4__synced_entities`** (append-only dle C6 §8.4–§8.5 — šest `synced_*` tabulek s client-generated ID, `account_id` ownership, monotónní `server_version`, FK dle R1 hierarchie a kanonickým JSONB `payload` bez serverové reinterpretace /P0 rozhodnutí C6 §8.4/; `idempotency_record` rozšířen o `final_status`/`result_reference`/`expires_at` a složený PK (account, key) dle IDC-003). **Backend push endpoint `POST /api/v1/sync/push`** dle C10: vyžaduje platnou session a registrovanou instalaci (SPC-001), aplikuje batch v pořadí `sequence` (SPC-003), **každá položka ve vlastní transakci** — efekt + IdempotencyRecord + audit commitují atomicky (IDC-004); per-item ownership/validace/verze/idempotence (SPC-004, AOC-009): `SUCCESS`/`ALREADY_APPLIED` (replay vrací původní výsledek bez efektů, jiný payload se stejným klíčem odmítnut — IDC-005/006/007), `VERSION_CONFLICT` (optimistic concurrency přes `expectedServerVersion`, C10 §10), `VALIDATION_FAILED`, `PERMISSION_DENIED` (cizí entita/parent + audit `AuthorizationDenied`), `DEPENDENCY_FAILED` (chybějící parent); audit dle C14 §7 (`SyncOperationApplied/Rejected`, `SyncConflictDetected`, `IdempotentReplayReturned`); `last_sync_at` zařízení. OpenAPI rozšířeno o Sync operaci + contract testy. **Mobil:** schema **v3** (aditivní migrace v2→v3 — nová tabulka `local_synced_versions` pro potvrzené serverové verze), **owner/DIRTY stamping v R1 write flows** (start session razí vlastníka na session i instanci — start je uživatelská akce; zápis výkonu a dokončení přepínají SYNCED→DIRTY; anonymní hodnota je no-op), **vazba lokálního vlastníka na účet** při přihlášení a zpět na anonymní při odhlášení (`LocalOwnerBinding`; attach existujících anonymních dat zůstává C15/R2-07), **`SyncEngine`** (state-based sběr LOCAL_ONLY/DIRTY entit vlastněných účtem v pořadí R1 hierarchie, idempotentní outbox enqueue se stabilním klíčem `{typ}:{id}:{lokální revize}` — LSM-008, push přes `HttpSyncApiClient`, **potvrzení výhradně po serverovém commitu**: SYNCED + uložená server_version; konflikt → explicitní `CONFLICT`, odmítnutí → `BLOCKED`, síťové selhání → vše pending a replay se stejnými klíči — SPC-005/006/012) a **Sync now** akce na Account obrazovce s poctivými počty (žádný background loop — SPC-015). Ověřeno **8 novými backend testy** (Testcontainers: pořadí+client ID, `ALREADY_APPLIED` bez duplicity, jiný payload odmítnut, version conflict se zachovaným stavem, per-item ownership smíšené batch + audit, dependency chain 6 entit, nevalidní typ/zařízení, audit outcome) a **9 novými mobile testy** (SyncEngine nad skutečnou SQLite: offline-create→later-replay s potvrzením po commitu a pořadím instance→session, stabilní idempotency keys přes restart, explicitní VERSION_CONFLICT stav, anonymní skip; vazba vlastníka při sign-in/sign-out; aktualizované schema/migrační testy v3). Backend suite **83/83**, mobile suite **230/230**, `flutter analyze` čistý. Řízené výjimky/rozhodnutí: (1) IdempotencyRecord se ukládá jen pro commitnuté efekty — odmítnutí je bez vedlejšího efektu a vyhodnocuje se při retry deterministicky znovu (IDC-006 zachováno, zdůvodnění v `ProcessSyncPush`); (2) payload synced entit je v P0 JSONB (C6 §8.4 rozhodnutí, promoce sloupců se slicem, který je serverově čte); (3) demo/seed instance zůstávají anonymní a nesynchronizují se — instance se stává uživatelskou (a synchronizovatelnou) startem workoutu; (4) runtime ověření na Android emulátoru neproběhlo (chybí SDK) — doplní se nejpozději v R2-08.

**Vytvořené R2 kontrakty:** C1 – Mobile schema migration (`docs/12-data/r2-mobile-schema-migration.md`, Data Architecture, `MSM-001..015`), C2 – Local ownership & outbox (`docs/12-data/r2-local-sync-metadata-contract.md`, Domain / sync-and-offline-model, `LSM-001..015`), C3 – Identity & session (`docs/07-backend/r2-identity-session-contract.md`, Domain / identity-and-profile-model + Backend, `ISC-001..015`), C4 – Authentication API (`docs/07-backend/r2-auth-api-contract.md`, Backend Architecture, `AAC-001..015`), C5 – Auth provider ADR (**`ADR-011`** v `docs/05-architecture/initial-architecture-decisions.md`, Architecture), C6 – Server data model (`docs/12-data/r2-server-data-model.md`, Data Architecture, `SDM-001..015`) C7 – Token/session storage (`docs/11-security/r2-token-session-storage-contract.md`, Security + Mobile, `TSS-001..015`; klasifikace session materiálu, secure storage boundary, restart/logout/revocation chování) C8 – Authorization/ownership (`docs/11-security/r2-authorization-ownership-contract.md`, Security + Backend, `AOC-001..015`; principal z ověřené session, ownership check na každé hranici, R2 capability baseline, default deny, anti-IDOR 404, audit odmítnutí), C9 – Device registration (`docs/07-backend/r2-device-registration-contract.md`, Backend + Domain, `DRC-001..015`; client-generated installation ID, idempotentní registrace, vazba session→zařízení, minimalizovaná metadata) C10 – Sync protocol (`docs/07-backend/r2-sync-protocol-contract.md`, Domain / sync-and-offline-model + Backend, `SPC-001..015`; push operace z outbox položek, ORDERED_OPERATIONS batch dle `sequence`, per-item výsledky, potvrzení po serverovém commitu, optimistic concurrency přes `expectedServerVersion`; pull mimo P0), C11 – Idempotency (`docs/12-data/r2-idempotency-contract.md`, Domain + Backend, `IDC-001..015`; IdempotencyRecord per klíč+účet, `ALREADY_APPLIED` bez vedlejších efektů, jiný payload = chyba, atomicita záznamu s efektem, jednotný protokol pro registraci i sync) a C14 – Audit-event contract (`docs/11-security/r2-audit-event-contract.md`, Domain / domain-events + Security, `AEC-001..015`; **auth část i sync část Done** — v0.2 doplnila závaznou tabulku sync událostí `SyncOperationApplied/Rejected`, `SyncConflictDetected`, `AuthorizationDenied`, `IdempotentReplayReturned`). C6 bylo append-only rozšířeno o **§8.1–§8.3** (profil/device, R2-04; verze 0.2) a **§8.4–§8.5** (synced entity s client-generated ID, `server_version`, FK dle R1 hierarchie, bez tombstone v P0; rozšířený `idempotency_record`; verze 0.3). Vše contract-only. `R2-01` (blocking C1, C2), `R2-02` (blocking C3, C4, C5, C6, auth část C14), `R2-03` (blocking C7) i `R2-04` (blocking C8, C9, C6 §8.1–§8.3) jsou **implementovány** (viz výše). `R2-05` má Ready podmínku R2-04 Done + C10, C11, C6 §8.4–§8.5 a sync část C14 — **vše splněno → `R2-05` je `READY` (neimplementováno)**. Dále C12 – Conflict/rejection (`docs/07-backend/r2-conflict-rejection-contract.md`, Domain, `CRC-001..015`; baseline resolution jen jako explicitní uživatelské rozhodnutí — USE_LOCAL potvrzený re-push / CANCEL_LOCAL_CHANGE bez mazání dat, audit `SyncConflictResolved`) a C13 – Revocation (`docs/11-security/r2-revocation-contract.md`, Security + Backend, `RVC-001..015`; revoke-all sessions, revokace instalace vč. vázaných session, jednotná klientská reakce bez ztráty dat, audit `DeviceRevoked`). `R2-06` má Ready podmínku R2-05 Done + C12 + C13 — **vše splněno → `R2-06` je `READY` (neimplementováno)**. **Stále chybějící blokující kontrakty:** local-to-account migration (C15 → R2-07). Ten vznikne nejpozději před `R2-07`.

**Přesný další kanonický krok:** `R2-01` až `R2-05` jsou implementovány; C12 i C13 existují → **`R2-06` je `READY`**. Další krok je **implementace `R2-06 – Conflict, Rejection and Session Revocation`** (conflict/rejection UI s baseline resolution dle C12, revoke-all + revokace instalace dle C13, klientská reakce), případně poté příprava kontraktu **C15 – Local-to-account migration** pro `R2-07`. Implementace `R2-06` smí začít až po Ready kontrole a samostatném pokynu.

---

# 4. Hlavní zdroje pravdy

## 4.1 Řízení dokumentace

| Soubor | Stav | Úloha |
|---|---|---|
| `docs/README.md` | FOUNDATION_READY | Mapa dokumentace a pracovní pravidla. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Audit, mezery a kanonický další krok. |

## 4.2 Vision, product a UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání a odlišení. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Dlouhodobý rozsah. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Funkční požadavky. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Nefunkční požadavky. |
| `docs/02-product/release-scope.md` | IMPLEMENTATION_READY pro R0/R1 | R0–R5, priority a exit criteria. |
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end scénáře. |
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní flow. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace obrazovek. |

## 4.3 Domain

Dokumenty v `docs/06-domain/` vlastní identity/profile, sports/goals, training plan, workout, scheduling, activity, recovery/limitations, AI/change, metrics, integrations, sync/offline, events, invariance a glossary.

## 4.4 Architecture, contracts, data, quality and delivery

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/05-architecture/initial-architecture-decisions.md` | IMPLEMENTATION_READY pro R0/R1 | Technologie blokující R0/R1. |
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice. |
| `docs/07-backend/r0-api-contract.md` | IMPLEMENTATION_READY | R0 liveness, readiness a error envelope. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy. |
| `docs/12-data/r1-physical-data-model.md` | IMPLEMENTATION_READY | Lokální SQLite/Drift schema R1. |
| `docs/13-delivery/repository-strategy.md` | IMPLEMENTATION_READY | Monorepo layout a boundaries. |
| `docs/13-delivery/definition-of-ready-and-done.md` | IMPLEMENTATION_READY | Ready/Done gates. |
| `docs/13-delivery/r0-r1-vertical-slice-plan.md` | IMPLEMENTATION_READY | Pořadí R0/R1 slices a evidence gates. |
| `docs/14-quality/test-strategy.md` | IMPLEMENTATION_READY | Test levels, CI gates a evidence. |
| `docs/15-coding-agent/coding-agent-guide.md` | IMPLEMENTATION_READY | Context loading, pracovní cyklus, commit discipline a evidence. |

---

# 5. Dokončený krok – Coding Agent Guide

`docs/15-coding-agent/coding-agent-guide.md` definuje:

- povinné načtení aktuálního branch,
- vždy načítané a změnou podmíněné zdroje pravdy,
- context manifest,
- výběr backlog itemu podle VSP,
- Ready kontrolu,
- pracovní cyklus před, během a po změně,
- testovací a dokumentační povinnosti,
- commit discipline,
- strukturovaný formát evidence,
- postup při rozporu dokumentů,
- zakázané chování,
- pravidla `CAG-001` až `CAG-015`.

## 5.1 Praktický dopad

Coding agent již nemá začít neurčitým požadavkem na vytvoření aplikace. Musí vybrat konkrétní Ready backlog item, načíst jeho vlastnící kontext, provést nejmenší smysluplnou změnu, spustit relevantní kontroly a uvést pravdivou evidence summary.

## 5.2 Implementační start

První položka je:

```text
R0-01 – Repository Skeleton
```

Před zahájením se znovu načte aktuální `main` a ověří Ready checklist.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| obecný `stage-plan.md` | `release-scope.md` + `r0-r1-vertical-slice-plan.md` |
| samostatný `r0-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `r1-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `implementation-order.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `context-loading-guide.md` | `coding-agent-guide.md` |
| samostatný `commit-policy.md` | `coding-agent-guide.md` |
| samostatný `agent-evidence-template.md` | `coding-agent-guide.md` |
| samostatný `backlog-ready.md` | `definition-of-ready-and-done.md` |
| samostatný `pull-request-done.md` | `definition-of-ready-and-done.md` |
| samostatný `flaky-test-policy.md` | `test-strategy.md` |
| obecný `health-endpoints.md` | `r0-api-contract.md` |
| obecný `r1-local-database-overview.md` | `r1-physical-data-model.md` |
| obecný `offline-principles.md` | sync model + mobile architecture |

---

# 7. Stav hlavních fází

## Fáze 1 – hlavní architektury

Dokončeno obsahově: backend, data, mobile, AI, security a integrations.

## Fáze 2 – startovní implementační minimum

1. ✅ release scope,
2. ✅ repository strategy,
3. ✅ počáteční ADR,
4. ✅ fyzický datový model R1,
5. ✅ R0 API contract,
6. ✅ test strategy,
7. ✅ Definition of Ready and Done,
8. ✅ vertical-slice implementation plan,
9. ✅ coding-agent instructions a context-loading guide.

**Fáze 2 je dokončena.**

## Fáze 3 – implementace R0 a R1

```text
R0-01 Repository Skeleton ✅
R0-02 Mobile Bootstrap ✅ (iOS výjimka uzavřena v R0-06)
R0-03 Backend Bootstrap ✅
R0-04 Contracts and Health API ✅
R0-05 Local Infrastructure and Migrations ✅
R0-06 CI and Repository Gates ✅
R0-07 Mobile-to-Backend Smoke Flow ✅
R0 Exit Review ✅ (viz §3)
R1-01 Local Workout Seed and Read Model ✅
R1-02 Today and Workout Detail ✅
R1-03 Start and Persist Session ✅
R1-04 Record Set Performance ✅
R1-05 Restart and Recovery ✅
R1-06 Complete Workout and History ✅
R1-07 Feedback, States and Accessibility ✅
R1-08 Critical End-to-End Evidence ✅ (R1 Exit Review proveden)
R1-01 až R1-08 podle vertical-slice planu
```

## Pozdější kontrakty

Identity/session a sync před R2, AI schemas před R4, provider contracts před první integrací a operations dokumentace před produkčním releasem.

---

# 8. Identifikátory

Používané řady zahrnují:

- `PP`, `FR`, `NFR`, `INV`,
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`,
- `RSR`, `RER`, `PDR`, `APR`, `QTR`, `DRD`, `VSP`, `CAG`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Release scope | vysoká | vysoká | řídit backlog podle VSP |
| Repository strategy | vysoká | vysoká | implementovat R0-01 |
| Initial ADR | vysoká | vysoká pro R0/R1 | ověřovat implementací |
| R0 API | vysoká | vysoká | implementovat R0-04 |
| R1 local data | vysoká | vysoká | implementovat R1-01 |
| Quality | vysoká | vysoká | implementovat CI a suites |
| Delivery workflow | vysoká | vysoká | používat Ready/Done a VSP |
| Coding agent | vysoká | vysoká | používat CAG protocol |

---

# 10. Další kanonický krok

Celé R1 (`R1-01` až `R1-08`) je implementované, R1 Exit Review je proveden (viz §3) a Release 1 je uzavřen. Existuje R2 vertical-slice plán. **C1–C14 jsou kompletní** (vč. rozšíření C6 §8.1–§8.5 a obou částí C14); z kontraktní mapy zbývá jen C15. **`R2-01` až `R2-05` jsou implementovány**; **`R2-06` je `READY` (neimplementováno)**; `R2-07` (čeká na C15) a `R2-08` zůstávají `NOT_READY`. Další kanonický krok:

```text
R2-06 – Conflict, Rejection and Session Revocation  (implementace, dle C12/C13)
poté: C15 – Local-to-account migration  (docs/12-data/r2-local-to-account-migration-contract.md)  [pro R2-07]
```

Implementace `R2-06` smí začít až po samostatném pokynu; před ní je nutné načíst aktuální GitHub, ověřit skutečnou strukturu repozitáře a provést Ready kontrolu podle `r2-vertical-slice-plan.md`, `definition-of-ready-and-done.md` a `coding-agent-guide.md`.
