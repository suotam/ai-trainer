# packages/contracts

Explicitní mezisystémové kontrakty – nikoli sdílený interní doménový model
(RER-005, ADR-007).

## Stav po R0-04

Kanonický OpenAPI zdroj pravdy veřejného HTTP API:

```text
openapi/ai-trainer-api.yaml
```

Pro R0 obsahuje pouze health endpointy (`GET /api/v1/health/live`,
`GET /api/v1/health/ready`), standardní error envelope a correlation
headers podle `docs/07-backend/r0-api-contract.md`.

## Validace a contract testy

Validace OpenAPI a shoda implementace s kontraktem se ověřují contract
testy v backendu (`apps/backend`, třída `OpenApiContractValidationTest`
přes swagger-parser + integration testy odpovědí):

```bash
cd ../../apps/backend
./gradlew test
```

Testy čtou kanonický soubor přímo z tohoto adresáře — neexistuje žádná
druhá udržovaná kopie schematu (test-strategy §8.2). Změna kontraktu
vyžaduje změnu tohoto souboru, implementace a contract testů ve stejném
change setu (APR-011, APR-015).
