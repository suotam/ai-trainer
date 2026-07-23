# apps/backend

Samostatná Kotlin/Spring Boot aplikace jako modulární monolit (ADR-005, BAR-001).

Serverová databáze je PostgreSQL, schema vzniká výhradně Flyway migracemi
(ADR-006, připojení vznikne v R0-05). Nesmí importovat mobilní kód ani sdílet
interní doménové třídy přes `packages/contracts` (RER-002, RER-005).

## Stav po R0-04

Bootstrap (R0-03) obsahuje Spring Boot application entry point, bezpečnou
konfiguraci (`application.yaml` — bez secrets), testovatelný `Clock` bean
(ADR-010), request-ID infrastrukturu (`X-Request-Id` + MDC korelace,
APR-007) a service name/version provider.

Health API (R0-04) implementuje kanonický kontrakt
`packages/contracts/openapi/ai-trainer-api.yaml`:

- `GET /api/v1/health/live` — liveness, nezávislá na externích závislostech,
- `GET /api/v1/health/ready` — readiness přes rozšiřitelný port
  `ReadinessIndicator` (nyní pouze `application` check; database/migrations
  checky přidá R0-05 bez změny veřejného kontraktu),
- centralizovaný bezpečný error envelope (`ApiErrorHandler`),
- `Cache-Control: no-store` na health odpovědích.

Produktové moduly (`modules/` dle backend-architecture §24) vzniknou až se
slices, které je potřebují.

## Struktura

```text
src/main/kotlin/com/aitrainer/backend/
├── AiTrainerBackendApplication.kt   # bootstrap, žádná business logika
├── configuration/                   # service info, Clock bean
├── health/
│   ├── application/                 # HealthQueryService, ReadinessIndicator port
│   └── transport/                   # controller + contract DTOs (nejsou doména)
└── infrastructure/
    └── http/                        # X-Request-Id filter, error envelope mapping
```

## Lokální příkazy

Vyžaduje JDK 25 (Gradle wrapper je součástí projektu).

```bash
cd apps/backend
./gradlew build          # kompilace + testy
./gradlew test           # pouze testy
./gradlew bootRun        # lokální spuštění (port 8080, přepis přes SERVER_PORT)
```

Ověření běžící instance:

```bash
curl -si http://localhost:8080/api/v1/health/live
curl -si http://localhost:8080/api/v1/health/ready
```

Contract testy (OpenAPI validace + shoda implementace) jsou součástí
`./gradlew test` a čtou kanonický soubor z `packages/contracts`.

## Konfigurace

- `SERVER_PORT` – HTTP port (default `8080`),
- `AITRAINER_SERVICE_VERSION` – bezpečný release identifikátor (default `0.0.1-dev`).

Žádná konfigurační hodnota nesmí obsahovat secrets (RER-011); produkční
konfigurace se do repozitáře necommituje.
