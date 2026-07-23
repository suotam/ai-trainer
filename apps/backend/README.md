# apps/backend

Samostatná Kotlin/Spring Boot aplikace jako modulární monolit (ADR-005, BAR-001).

Serverová databáze je PostgreSQL, schema vzniká výhradně Flyway migracemi
(ADR-006). Nesmí importovat mobilní kód ani sdílet interní doménové třídy
přes `packages/contracts` (RER-002, RER-005).

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

Lokální infrastruktura a migrace (R0-05):

- PostgreSQL běží lokálně přes root `compose.yaml` (development-only
  credentials, žádné produkční secrets),
- serverové schema vzniká výhradně Flyway migracemi z kanonického
  `database/migrations` (build je balí do classpath `db/migration`);
  migrace běží při startu aplikace a jsou append-only,
- readiness nově obsahuje checky `database` (SELECT 1 s timeoutem) a
  `migrations` (aplikovaný current + žádné pending) — aditivní klíče v
  `checks` mapě, veřejný kontrakt beze změny,
- testy používají skutečný PostgreSQL přes Testcontainers (žádná
  in-memory náhražka, QTR-004).

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

Vyžaduje JDK 25 a Docker (testy používají Testcontainers; lokální běh
vyžaduje PostgreSQL z root `compose.yaml`).

```bash
# v rootu repozitáře:
docker compose up -d     # lokální PostgreSQL (musí běžet před bootRun)

cd apps/backend
./gradlew build          # kompilace + testy (Testcontainers)
./gradlew test           # pouze testy
./gradlew bootRun        # lokální spuštění (port 8080, přepis přes SERVER_PORT);
                         # při startu proběhnou Flyway migrace

# v rootu repozitáře po skončení práce:
docker compose down      # zastavení databáze (volume zůstává)
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
- `AITRAINER_SERVICE_VERSION` – bezpečný release identifikátor (default `0.0.1-dev`),
- `DATABASE_URL` – JDBC URL (default `jdbc:postgresql://localhost:5432/aitrainer`),
- `DATABASE_USER` / `DATABASE_PASSWORD` – development defaults odpovídají
  lokálnímu Compose; produkce je vždy přepisuje,
- `DATABASE_CONNECT_TIMEOUT_MS` – bounded čekání na connection (default `5000`).

Žádná konfigurační hodnota nesmí obsahovat secrets (RER-011); produkční
konfigurace se do repozitáře necommituje.
