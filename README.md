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
├── database/
│   └── migrations/  # kanonické serverové Flyway migrace (append-only)
├── tooling/
│   └── scripts/     # opakovatelné repository úlohy (smoke check)
├── docs/            # produktová, doménová a technická dokumentace
└── compose.yaml     # lokální PostgreSQL (development-only)
```

CI běží v GitHub Actions (`.github/workflows/`): `repository` (smoke
check, gitleaks secret scan, Compose validace), `mobile` (format,
analyze, testy, Android + iOS build) a `backend` (wrapper validace,
ktlint, build, testy s Testcontainers). Všechna workflow běží na pull
requestech i push do `main` a spouštějí stejné příkazy jako lokální
vývoj (viz README jednotlivých aplikací).

## Lokální příkazy

Repository smoke check (ověří kanonickou strukturu a absenci build artefaktů
a zjevných secrets ve verzovaných souborech):

```bash
./tooling/scripts/repo-smoke-check.sh
```

Celý lokální stack pro mobile-to-backend smoke flow (R0-07):

```bash
docker compose up -d                       # 1. PostgreSQL
(cd apps/backend && ./gradlew bootRun)     # 2. backend s Flyway migracemi
(cd apps/mobile && flutter run \
  --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8080)  # 3. Android emulátor
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

Lokální infrastruktura (PostgreSQL, vyžaduje Docker):

```bash
docker compose up -d     # start lokální databáze
docker compose down      # zastavení (volume zůstává zachován)
```

Pokud port 5432 drží jiný lokální projekt, použij
`AITRAINER_POSTGRES_PORT=5433 docker compose up -d` a backendu nastav
odpovídající `DATABASE_URL`.

Backend (detail v `apps/backend/README.md`, vyžaduje JDK 25 a běžící
PostgreSQL z Compose):

```bash
cd apps/backend
./gradlew build          # testy vyžadují Docker (Testcontainers)
./gradlew bootRun
```

## Pravidla práce

- Implementace postupuje po vertical slices podle `docs/13-delivery/r0-r1-vertical-slice-plan.md`.
- Pracovní protokol coding agenta určuje `docs/15-coding-agent/coding-agent-guide.md`.
- Ready/Done gates vlastní `docs/13-delivery/definition-of-ready-and-done.md`.
- Secrets, credentials, build artefakty ani lokální data se necommitují.
