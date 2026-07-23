# AI Trainer

Monorepo pro AI Trainer – mobilní tréninkovou aplikaci (Flutter) s backendem (Kotlin/Spring Boot).

Zdrojem pravdy pro strukturu repozitáře je `docs/13-delivery/repository-strategy.md`.
Aktuální stav dokumentace a kanonický další krok vlastní `docs/DOCUMENTATION_STATUS.md`.

## Struktura repozitáře

```text
ai-trainer/
├── apps/
│   ├── mobile/      # Flutter aplikace (Android + iOS)
│   └── backend/     # Kotlin/Spring Boot modulární monolit
├── packages/
│   └── contracts/   # explicitní mezisystémové kontrakty (OpenAPI)
├── tooling/
│   └── scripts/     # opakovatelné repository úlohy (smoke check)
└── docs/            # produktová, doménová a technická dokumentace
```

Adresáře `database/` (serverové migrace, seeds, fixtures) a `.github/` (CI workflows)
vzniknou spolu se slices `R0-05` a `R0-06`, které je skutečně potřebují.

## Lokální příkazy

Repository smoke check (ověří kanonickou strukturu a absenci build artefaktů
a zjevných secrets ve verzovaných souborech):

```bash
./tooling/scripts/repo-smoke-check.sh
```

Mobile aplikace (detail v `apps/mobile/README.md`):

```bash
cd apps/mobile
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter run
```

Backend (detail v `apps/backend/README.md`, vyžaduje JDK 25):

```bash
cd apps/backend
./gradlew build
./gradlew bootRun
```

## Pravidla práce

- Implementace postupuje po vertical slices podle `docs/13-delivery/r0-r1-vertical-slice-plan.md`.
- Pracovní protokol coding agenta určuje `docs/15-coding-agent/coding-agent-guide.md`.
- Ready/Done gates vlastní `docs/13-delivery/definition-of-ready-and-done.md`.
- Secrets, credentials, build artefakty ani lokální data se necommitují.
