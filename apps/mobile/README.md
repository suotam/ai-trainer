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

Mobile-to-backend smoke flow (R0-07, `lib/app/backend_status/`):
`BackendHealthClient` boundary + HTTP adapter volá `GET /api/v1/health/live`
a `/ready` podle kanonického kontraktu v `packages/contracts`. Technický
stavový blok na úvodní obrazovce zobrazuje stavy: loading, success
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
│   ├── startup/          # technická úvodní obrazovka (R0)
│   └── theme/            # základní theme (není design system)
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
