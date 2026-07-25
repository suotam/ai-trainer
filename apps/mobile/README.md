# apps/mobile

Samostatná Flutter aplikace pro Android a iOS (ADR-001).

Vlastní své lokální Drift/SQLite schema a jeho migrace (RER-007, vznikne v R1).
Nesmí importovat backendové interní moduly ani sdílet interní doménové
třídy přes `packages/contracts` (RER-002, RER-005).

## Stav po R0-07

Bootstrap obsahuje composition root (`lib/main.dart`), Riverpod composition
(ADR-002), GoRouter shell s centralizovanými routes (ADR-003,
`lib/app/navigation/`), základní theme (`lib/app/theme/`), lokalizaci
(en + cs, `lib/l10n/`), environment configuration boundary
(`lib/app/configuration/app_environment.dart`) a technickou úvodní
obrazovku (`lib/app/startup/`). Produktové features (`lib/features/`)
vzniknou až v R1.

Lokální workout data (R1-01):

- Drift/SQLite schema verze 1 podle `docs/12-data/r1-physical-data-model.md`
  žije v `lib/core/database/` (tabulky, FK, CHECK a unique constraints,
  partial unique index pro jednu aktivní session, indexy),
- workout read model, mappery a deterministický verzovaný demo seed vlastní
  `lib/features/workouts/` (domain/data/application) — Drift typy nesmí
  opustit data vrstvu (PDR-008),
- generovaný Drift kód (`*.g.dart`) je commitovaný; po změně tabulek spusť
  `dart run build_runner build --delete-conflicting-outputs` (CI hlídá drift),
- persistence testy běží nad skutečnou in-memory SQLite
  (`test/features/workouts/`).

Start and persist session (R1-03, první write flow, `lib/features/workouts/`):

- **Start**: na detailu workoutu je tlačítko `Start workout`. Use case
  `StartWorkoutSession` (application, bez Flutter/backend závislosti)
  generuje stabilní session ID (injektovaný `IdGenerator`), používá
  injektovaný clock a deleguje **atomický** start na
  `DriftWorkoutSessionRepository`, který v jedné Drift transakci ověří
  instanci, zkontroluje invariant a vytvoří session, přepne instanci na
  `IN_PROGRESS` a uloží active-session pointer.
- **Právě jedna aktivní session**: transakce kontroluje globálně
  existující `ACTIVE`/`PAUSED` session; partial unique index
  `idx_one_active_session_per_instance` (schema z R1-01) je poslední linií
  ochrany. Výsledky: created / resumedExisting (stejný workout) /
  conflictWithAnotherSession (jiný workout) / workoutNotFound — nikdy raw
  persistence výjimka.
- **Recovery po restartu**: `activeSessionProvider` po bootstrapu najde
  aktivní session z lokální DB (stejné ID i start time), bez sítě a bez
  background pollingu. Žádná druhá session nevzniká.
- **UI stavy**: start button (idle/disabled+loading, guard proti dvojitému
  tapu), navigace na active session screen při created/resumed, bezpečný
  conflict stav s akcí „otevřít aktivní workout", not-found a error bez raw
  detailů. Active session screen zobrazuje název, „Session active", start
  timestamp a tracker výkonu (viz R1-04).
- Schema beze změny (zůstává verze 1) — session tabulka i indexy existují
  z R1-01. Žádný zápis výkonu, dokončení ani zrušení session (pozdější slices).

Record set performance (R1-04, tracker výkonu, `lib/features/workouts/`):

- **Inicializace performance řádků**: při otevření aktivní session se
  idempotentně vytvoří `StepPerformance`/`SetPerformance` řádky ze stabilního
  snapshotu (odloženo z R1-03). Jedna Drift transakce, klíčováno na
  `unique(session, step)` a `unique(step_performance, position)` — opakovaná
  inicializace (i po restartu) nevytvoří duplikáty ani nepřepíše actual data.
- **Zápis výkonu**: `RecordSetPerformance` (application) validuje vstup
  (záporné reps/váha odmítnuty ještě před persistencí) a deleguje na
  `DriftWorkoutPerformanceRepository`, který v transakci ověří existenci a
  aktivitu session, zapíše actual hodnoty, `row_version`, `updated_at` session
  a — u dokončení — status setu a `completed_at` (injektovaný clock). Typované
  výsledky saved / validationFailure / sessionNotActive / setNotFound — nikdy
  raw Drift výjimka do UI. Zápis je uživatelsky řízený (Save / Done), bez
  agresivního per-keystroke autosave a bez background sync.
- **Plán vs. výkon (PDR-003)**: planned reps/váha zůstávají v neměnném
  snapshotu `local_set_plans`; actual jen v performance tabulkách. Změna actual
  nikdy nepřepíše planned; chybějící actual se auto-nezoruje.
- **R1-04 nedokončuje session**: zapisuje pouze výkon setu — session zůstává
  `ACTIVE`, `completed_at` je null, instance zůstává `IN_PROGRESS`.
- **Tracker UI a recovery**: active session screen renderuje sekce a kroky
  v pořadí, planned hodnoty, actual inputy, completion marker a saving/saved/
  validation/error stavy (bez raw DB detailu). Actual i completion se obnoví
  po restartu; guard proti dvojitému paralelnímu save stejného setu.
- Schema beze změny (zůstává verze 1) — performance tabulky existují z R1-01.

Today a workout detail (R1-02, read-only, `lib/features/workouts/`):

- **Domov aplikace je Today** (`/today`); detail je `/workouts/:workoutId`.
  Technická R0 startup obrazovka (backend smoke flow) se přesunula na
  `/startup` — už není domov, ale zůstává dostupná.
- **Seed bootstrap**: `WorkoutBootstrap` (application use case) spustí
  idempotentní seed z R1-01 při prvním čtení Today read modelu. Read
  providery čekají na dokončení bootstrapu (`workoutBootstrapCompletedProvider`),
  takže Today se nezobrazí dřív, než je seed validní. Selhání vede do error
  stavu s explicitním Retry — žádný automatický retry loop. Widgety seed
  nevolají přímo.
- **Today** zobrazuje dnešní workouty z lokálního snapshotu bez sítě.
  Stavy: loading, data (karty s názvem/typem/délkou, tap → detail), empty
  (pravdivé „nic naplánováno", bez akcí pozdějších slices), error (bezpečná
  zpráva + Retry).
- **Workout detail** zobrazuje stabilní snapshot: sekce → kroky → plánované
  série v pořadí. Neplatné/neexistující ID → bezpečný not-found stav. Bez
  editace a bez startu session (pozdější slices). Chyby neobsahují interní
  detaily.
- Spuštění bez backendu: `flutter run` (bez potřeby `docker compose`/backendu).

Mobile-to-backend smoke flow (R0-07, `lib/app/backend_status/`):
`BackendHealthClient` boundary + HTTP adapter volá `GET /api/v1/health/live`
a `/ready` podle kanonického kontraktu v `packages/contracts`. Technický
stavový blok na `/startup` obrazovce zobrazuje stavy: loading, success
(dostupný a ready), not-ready (běží, nepřijímá provoz) a failure
(nedostupný/timeout/nevalidní odpověď) s explicitním Retry. Chyby nikdy
neobsahují interní detaily; žádný automatický retry loop.

## Struktura

```text
lib/
├── app/
│   ├── bootstrap/        # kořenový widget aplikace
│   ├── configuration/    # environment boundary (--dart-define, bez secrets)
│   ├── navigation/       # GoRouter a centralizované routes
│   ├── startup/          # technická obrazovka R0 (/startup, ne domov)
│   └── theme/            # základní theme (není design system)
├── core/
│   ├── database/         # Drift/SQLite schema, provider (R1-01)
│   └── time/             # testovatelný clock a dnešní datum
├── features/
│   └── workouts/         # domain / data / application / presentation
└── l10n/                 # ARB soubory; generated/ se negeneruje do Gitu
```

## Lokální příkazy

```bash
flutter pub get                                  # závislosti + generovaná lokalizace
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug                        # Android build
flutter build ios --debug --no-codesign          # iOS build (vyžaduje iOS platform SDK v Xcode)
flutter run                                      # spuštění na zařízení/emulátoru
```

Prostředí se volí přes `--dart-define=APP_ENVIRONMENT=development|test|staging|production`
(default `development`). Konfigurace nesmí obsahovat secrets (RER-011).

Backend base URL se předává přes `--dart-define=BACKEND_BASE_URL=<url>`
(default `http://10.0.2.2:8080` — host loopback z pohledu Android
emulátoru). Smoke flow proti lokálnímu backendu:

```bash
# Android emulátor (default):
flutter run --dart-define=APP_ENVIRONMENT=development \
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8080

# iOS simulátor:
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:8080

# fyzické zařízení (LAN IP host stroje):
flutter run --dart-define=BACKEND_BASE_URL=http://192.168.x.y:8080
```

Před spuštěním musí běžet lokální stack (viz root README):
`docker compose up -d` + backend `./gradlew bootRun`. Nevalidní URL
selže srozumitelnou chybou při startu.

Generovaná lokalizace (`lib/l10n/generated/`) není commitovaná; reprodukuje se
automaticky při `flutter pub get`/`flutter test`/build nebo ručně přes
`flutter gen-l10n` (RER-010).

CI (`.github/workflows/mobile.yml`) spouští stejné příkazy na Flutter 3.44.4:
format check, analyze, testy, Android debug build a iOS no-codesign build
na macOS runneru.

## Otevřené rozhodnutí

Application/bundle ID je zatím neutrální `com.aitrainer.ai_trainer_mobile`
(`--org com.aitrainer` z `flutter create`). Před první distribucí mimo lokální
vývoj musí být potvrzen vlastním rozhodnutím (ADR nebo release dokument).
