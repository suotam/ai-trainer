# apps/backend

Samostatná Kotlin/Spring Boot aplikace jako modulární monolit (ADR-005, BAR-001).

Serverová databáze je PostgreSQL, schema vzniká výhradně Flyway migracemi
(ADR-006, připojení vznikne v R0-05). Nesmí importovat mobilní kód ani sdílet
interní doménové třídy přes `packages/contracts` (RER-002, RER-005).

## Stav po R0-03

Bootstrap obsahuje Spring Boot application entry point
(`AiTrainerBackendApplication`), bezpečnou konfiguraci
(`application.yaml` — bez secrets, environment-specific hodnoty přes
environment proměnné), testovatelný `Clock` bean (ADR-010), request-ID
infrastrukturu (`X-Request-Id` validace/generování + MDC korelace logů,
APR-007) a bezpečný service name/version provider. Produktové moduly
(`modules/` dle backend-architecture §24) vzniknou až se slices, které je
potřebují; health API vznikne v R0-04.

## Struktura

```text
src/main/kotlin/com/aitrainer/backend/
├── AiTrainerBackendApplication.kt   # bootstrap, žádná business logika
├── configuration/                   # service info, Clock bean
└── infrastructure/
    └── http/                        # X-Request-Id filter a validace
```

## Lokální příkazy

Vyžaduje JDK 25 (Gradle wrapper je součástí projektu).

```bash
cd apps/backend
./gradlew build          # kompilace + testy
./gradlew test           # pouze testy
./gradlew bootRun        # lokální spuštění (port 8080, přepis přes SERVER_PORT)
```

Ověření běžící instance (health endpointy vzniknou až v R0-04; zatím lze
ověřit pouze proces a korelační header):

```bash
curl -si http://localhost:8080/ | grep X-Request-Id
```

## Konfigurace

- `SERVER_PORT` – HTTP port (default `8080`),
- `AITRAINER_SERVICE_VERSION` – bezpečný release identifikátor (default `0.0.1-dev`).

Žádná konfigurační hodnota nesmí obsahovat secrets (RER-011); produkční
konfigurace se do repozitáře necommituje.
