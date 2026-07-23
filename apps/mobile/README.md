# apps/mobile

Samostatná Flutter aplikace pro Android a iOS (ADR-001).

Vlastní své lokální Drift/SQLite schema a jeho migrace (RER-007, vznikne v R1).
Nesmí importovat backendové interní moduly ani sdílet interní doménové
třídy přes `packages/contracts` (RER-002, RER-005).

## Stav po R0-02

Bootstrap obsahuje composition root (`lib/main.dart`), Riverpod composition
(ADR-002), GoRouter shell s centralizovanými routes (ADR-003,
`lib/app/navigation/`), základní theme (`lib/app/theme/`), lokalizaci
(en + cs, `lib/l10n/`), environment configuration boundary
(`lib/app/configuration/app_environment.dart`) a technickou úvodní
obrazovku (`lib/app/startup/`). Produktové features (`lib/features/`)
vzniknou až v R1.

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

Generovaná lokalizace (`lib/l10n/generated/`) není commitovaná; reprodukuje se
automaticky při `flutter pub get`/`flutter test`/build nebo ručně přes
`flutter gen-l10n` (RER-010).

## Otevřené rozhodnutí

Application/bundle ID je zatím neutrální `com.aitrainer.ai_trainer_mobile`
(`--org com.aitrainer` z `flutter create`). Před první distribucí mimo lokální
vývoj musí být potvrzen vlastním rozhodnutím (ADR nebo release dokument).
