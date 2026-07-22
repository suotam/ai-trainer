# AI Trainer – R0 API Contract

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/07-backend/r0-api-contract.md`  
**Vlastník:** Backend Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/02-product/non-functional-requirements.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/07-backend/backend-architecture.md`, `docs/11-security/security-architecture.md`, `docs/13-delivery/repository-strategy.md`  
**Navazující dokumenty:** OpenAPI source file, test strategy, environment configuration, deployment health checks, R2 identity/session contract a budoucí versioned product API  
**Vlastněné pojmy nebo kontrakty:** R0 HTTP boundary, liveness, readiness, standard error envelope, correlation metadata, media types, compatibility policy a pravidla `APR-001` až `APR-015`

---

# 1. Účel

Tento dokument definuje minimální HTTP a OpenAPI kontrakt potřebný pro `R0 – Technical Foundation`.

R0 má prokázat, že:

- backend lze spustit lokálně a v CI,
- proces umí oznámit vlastní liveness,
- aplikace umí oznámit readiness vůči povinným závislostem,
- HTTP chyby mají konzistentní bezpečný formát,
- kontrakt je explicitní, verzovaný a testovatelný,
- provozní endpointy neodhalují secrets ani citlivé interní detaily.

Tento dokument záměrně nedefinuje:

- workout API,
- účet, přihlášení, session ani autorizaci,
- synchronizační endpointy,
- AI endpointy,
- integrační webhooky,
- administrativní API,
- produkční monitoring nebo deployment topologii.

Tyto kontrakty vzniknou nejpozději před slicem, který je skutečně používá.

---

# 2. Contract source of truth

Kanonický strojově čitelný HTTP kontrakt bude uložen v:

```text
packages/contracts/openapi/ai-trainer-api.yaml
```

Pro R0 může soubor obsahovat pouze endpointy popsané v tomto dokumentu.

Platí:

- OpenAPI je zdrojem transportního kontraktu, nikoli doménového významu,
- implementace musí odpovídat schválenému OpenAPI,
- změna endpointu nebo schema vyžaduje změnu kontraktu a contract testu,
- generated klient nebo DTO se nesmí ručně opravovat bez změny zdroje či generátoru,
- interní Spring Actuator endpoint není náhradou veřejného R0 kontraktu.

---

# 3. Základní HTTP pravidla

## 3.1 Base path

Versioned aplikační API používá prefix:

```text
/api/v1
```

R0 endpointy:

```text
GET /api/v1/health/live
GET /api/v1/health/ready
```

## 3.2 Transport

- produkční a sdílená prostředí musí používat HTTPS,
- lokální development může používat HTTP,
- klient nesmí předpokládat konkrétní hostname ani port,
- reverse proxy nebo gateway nesmí měnit význam status codes a response body.

## 3.3 Media type

Úspěšné i chybové JSON odpovědi používají:

```text
Content-Type: application/json
```

Klient může poslat:

```text
Accept: application/json
```

R0 nemá request body endpointy.

## 3.4 Encoding a čas

- text je UTF-8,
- timestamp je RFC 3339 v UTC,
- příklad: `2026-07-22T09:15:30Z`,
- klientský čas není autoritou pro serverový stav.

---

# 4. Correlation a request metadata

## 4.1 Request ID

Klient nebo infrastruktura může poslat:

```text
X-Request-Id: <opaque-value>
```

Server:

- hodnotu přijme pouze pokud splní délkovou a znakovou validaci,
- jinak vytvoří vlastní neprůhledný identifikátor,
- vrátí výsledný identifikátor v `X-Request-Id`,
- použije jej pro korelaci logu a error envelope,
- nesmí do něj zakódovat e-mail, user ID, token ani jiná citlivá data.

Maximální podporovaná délka je 128 znaků.

## 4.2 Server version

Health response může obsahovat bezpečný release identifikátor, například semantic version nebo krátký build identifier. Nesmí obsahovat cestu souborového systému, branch secret, plný environment dump ani credentials.

---

# 5. Liveness endpoint

## 5.1 Request

```http
GET /api/v1/health/live
```

Endpoint nevyžaduje autentizaci.

## 5.2 Význam

Liveness odpovídá pouze na otázku:

> Je backendový proces spuštěný a schopný obsloužit základní HTTP request?

Liveness nesmí selhat pouze proto, že je dočasně nedostupná databáze nebo jiná externí závislost. Takový stav patří do readiness.

## 5.3 Úspěšná odpověď

Status:

```text
200 OK
```

Body:

```json
{
  "status": "UP",
  "service": "ai-trainer-backend",
  "timestamp": "2026-07-22T09:15:30Z",
  "version": "0.1.0"
}
```

Pole:

| Pole | Povinné | Význam |
|---|---:|---|
| `status` | ano | pro R0 vždy `UP` při odpovědi 200 |
| `service` | ano | stabilní technický název služby |
| `timestamp` | ano | serverový UTC čas vytvoření odpovědi |
| `version` | ano | bezpečný release nebo build identifier |

## 5.4 Failure behavior

Pokud proces není schopen obsloužit endpoint, nemusí vzniknout validní HTTP odpověď. Infrastruktura jej považuje za unhealthy podle connection failure, timeoutu nebo non-2xx výsledku.

---

# 6. Readiness endpoint

## 6.1 Request

```http
GET /api/v1/health/ready
```

Endpoint nevyžaduje autentizaci.

## 6.2 Význam

Readiness odpovídá na otázku:

> Je instance připravená přijímat aplikační provoz ve svém aktuálním prostředí?

Pro R0 musí readiness ověřit minimálně:

- dokončený application bootstrap,
- dostupnost PostgreSQL, pokud je databáze v daném prostředí povinná,
- úspěšné ověření Flyway schema stavu,
- další závislost pouze pokud je pro dané prostředí skutečně povinná.

R1 lokální workout flow není na backend readiness závislé.

## 6.3 Ready response

Status:

```text
200 OK
```

Body:

```json
{
  "status": "READY",
  "service": "ai-trainer-backend",
  "timestamp": "2026-07-22T09:15:30Z",
  "version": "0.1.0",
  "checks": {
    "application": "UP",
    "database": "UP",
    "migrations": "UP"
  }
}
```

## 6.4 Not-ready response

Status:

```text
503 Service Unavailable
```

Body používá standardní error envelope:

```json
{
  "code": "SERVICE_NOT_READY",
  "message": "Service is not ready to accept traffic.",
  "requestId": "01J3EXAMPLE8R0REQUESTID",
  "timestamp": "2026-07-22T09:15:30Z"
}
```

Readiness response nesmí vracet:

- connection string,
- hostname interní databáze,
- SQL chybu,
- stack trace,
- username,
- secret,
- interní síťovou topologii.

Detail důvodu patří pouze do redigovaných interních logů a observability.

---

# 7. Standard error envelope

Všechny versioned JSON endpointy používají společný základ:

```json
{
  "code": "STABLE_MACHINE_CODE",
  "message": "Safe human-readable message.",
  "requestId": "01J3EXAMPLE8R0REQUESTID",
  "timestamp": "2026-07-22T09:15:30Z",
  "details": []
}
```

## 7.1 Pole

| Pole | Povinné | Pravidlo |
|---|---:|---|
| `code` | ano | stabilní machine-readable kód v `UPPER_SNAKE_CASE` |
| `message` | ano | bezpečná obecná zpráva bez interních detailů |
| `requestId` | ano | korelační ID odpovídající response headeru |
| `timestamp` | ano | UTC RFC 3339 |
| `details` | ne | strukturované bezpečné detaily pouze pokud je kontrakt definuje |

## 7.2 R0 error codes

| HTTP status | `code` | Použití |
|---:|---|---|
| 400 | `INVALID_REQUEST` | syntakticky neplatný request |
| 404 | `RESOURCE_NOT_FOUND` | neexistující versioned route nebo resource |
| 405 | `METHOD_NOT_ALLOWED` | nepodporovaná HTTP metoda |
| 406 | `NOT_ACCEPTABLE` | nepodporovaný response media type |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | nepodporovaný request media type |
| 429 | `RATE_LIMITED` | ochranné omezení provozu |
| 500 | `INTERNAL_ERROR` | neočekávaná interní chyba |
| 503 | `SERVICE_NOT_READY` | instance není připravená přijímat provoz |

## 7.3 Bezpečnost chyb

Error response nesmí obsahovat:

- stack trace,
- název interní třídy nebo balíku,
- SQL nebo ORM exception text,
- secret nebo token,
- celé request body,
- osobní nebo zdravotní údaje,
- interní filesystem path,
- provider response payload bez redakce.

---

# 8. Status code pravidla

- úspěšný liveness a readiness používají `200`,
- not-ready používá `503`,
- neočekávaná chyba používá `500`,
- endpoint nesmí vracet `200` s chybovým stavem ukrytým pouze v body,
- redirect není součástí R0 API,
- `404` nesmí prozrazovat, zda existuje chráněný objekt v budoucím API,
- status code musí odpovídat OpenAPI kontraktu.

---

# 9. Cache a retry

Health odpovědi používají:

```text
Cache-Control: no-store
```

Klienti a infrastruktura:

- mohou health request opakovat,
- nesmí očekávat side effect,
- mají používat timeout a bounded retry,
- nesmí vytvářet neomezenou retry smyčku,
- mají respektovat `Retry-After`, pokud jej server u 429 nebo 503 poskytne.

Health endpointy jsou bezpečné a idempotentní.

---

# 10. Authentication a exposure

R0 health endpointy jsou bez autentizace, protože slouží lokálnímu prostředí, CI a infrastrukturním probes.

To neznamená, že:

- všechny budoucí endpointy budou veřejné,
- interní Actuator endpointy musí být veřejně dostupné,
- health endpoint smí zveřejňovat detailní dependency informace,
- veřejný přístup obchází rate limiting nebo network policy.

Před produkčním releasem se exposure policy znovu ověří v threat modelu a deployment kontraktu.

---

# 11. Versioning a compatibility

## 11.1 Path version

První veřejný namespace je `/api/v1`.

Breaking změna zahrnuje například:

- odebrání endpointu nebo povinného pole,
- změnu významu existujícího pole,
- zpřísnění povolené hodnoty bez kompatibilního okna,
- změnu status code významu,
- změnu pole z optional na required pro response consumer.

Breaking změna vyžaduje nový major API namespace nebo explicitně schválenou kompatibilní migrační strategii.

## 11.2 Additive změny

Přidání optional response pole může být kompatibilní, pokud:

- klienty mají ignorovat neznámá pole,
- pole nemění význam existujících hodnot,
- contract testy potvrzují kompatibilitu.

## 11.3 R0 stabilita

R0 kontrakt je malý, ale nesmí se měnit tiše. Změna vyžaduje:

1. aktualizaci tohoto dokumentu nebo navazujícího API kontraktu,
2. aktualizaci OpenAPI,
3. aktualizaci contract testů,
4. review dopadu na CI, Compose a deployment probes.

---

# 12. OpenAPI minimální obsah

R0 OpenAPI musí obsahovat minimálně:

- metadata API,
- server placeholders bez produkčních secrets,
- tag `Health`,
- operace `getLiveness` a `getReadiness`,
- schemas `LivenessResponse`, `ReadinessResponse`, `ErrorResponse`,
- response headers pro `X-Request-Id`,
- status codes 200, 500 a 503 podle endpointu,
- examples bez skutečných interních údajů.

Operation IDs musí být stabilní a unikátní.

---

# 13. Implementační hranice

## 13.1 Controller

HTTP controller:

- mapuje transport,
- nastavuje status a headers,
- volá application health query,
- mapuje výsledek na contract DTO,
- neobsahuje SQL ani infrastrukturní credentials.

## 13.2 Health application service

Application service:

- skládá bezpečný readiness výsledek,
- používá explicitní dependency health ports,
- aplikuje timeouty,
- nerozhoduje podle raw exception textu vraceného klientovi.

## 13.3 Infrastructure adapters

Database a migration checks jsou adapters. Jejich interní diagnostika může být logována pouze podle redaction policy.

Spring Actuator může být implementační mechanismus nebo interní zdroj signálu, ale veřejná odpověď musí odpovídat tomuto kontraktu.

---

# 14. Testovací minimum R0

Musí existovat automatizované testy pro:

- `GET /api/v1/health/live` vrací 200 a validní schema,
- liveness nezávisí na dostupnosti PostgreSQL,
- readiness vrací 200 při dostupné povinné databázi a validních migracích,
- readiness vrací 503 při nedostupné povinné databázi,
- response obsahuje `X-Request-Id`,
- neplatné vstupní request ID je bezpečně nahrazeno,
- error response odpovídá schema,
- stack trace a secret se nikdy neobjeví v HTTP response,
- OpenAPI a implementace nemají contract drift,
- endpointy neprovádějí zápis ani jiný side effect.

Testy readiness používají skutečnou PostgreSQL přes Testcontainers podle `ADR-010`.

---

# 15. R0 exit criteria

API část R0 je dokončená pouze pokud:

- kanonický OpenAPI soubor existuje v `packages/contracts`,
- backend implementuje oba health endpointy,
- lokální Compose umožní ověřit ready i not-ready stav,
- contract a integration testy procházejí,
- CI kontroluje OpenAPI a backend testy,
- response neobsahují citlivé interní detaily,
- README backendu popisuje lokální spuštění a ověření endpointů,
- dokumentace a implementace jsou ve shodě.

---

# 16. Závazná pravidla

## APR-001 – Explicitní kontrakt

Každý R0 HTTP endpoint musí existovat v kanonickém OpenAPI před označením implementace za hotovou.

## APR-002 – Versioned namespace

Aplikační HTTP endpointy používají `/api/v1`; interní framework endpoint není veřejný aplikační kontrakt.

## APR-003 – Oddělená liveness a readiness

Liveness nesmí selhávat pouze kvůli externí závislosti; readiness musí ověřit všechny povinné runtime závislosti prostředí.

## APR-004 – Bezpečný health payload

Health response nesmí zveřejnit secrets, interní adresy, connection strings, stack traces ani raw dependency exceptions.

## APR-005 – Standardní error envelope

Každá JSON chyba versioned API musí používat standardní `code`, `message`, `requestId` a `timestamp`.

## APR-006 – Stabilní machine code

Error `code` je stabilní kontrakt a nesmí být nahrazen interním názvem exception.

## APR-007 – Korelace

Každá response musí obsahovat validní `X-Request-Id`; stejná hodnota se použije v error envelope a bezpečných korelačních logách.

## APR-008 – Správné status codes

API nesmí maskovat chybu odpovědí `200`; status code musí odpovídat skutečnému výsledku a OpenAPI.

## APR-009 – No-store health

Health responses musí být necacheovatelné pomocí `Cache-Control: no-store`.

## APR-010 – Idempotentní probes

Health endpointy nesmí měnit stav a musí být bezpečné pro opakované volání.

## APR-011 – Contract compatibility

Breaking změna vyžaduje nový major namespace nebo schválenou migrační strategii; změna nesmí být provedena tiše.

## APR-012 – Transport není doména

Controller a OpenAPI DTO nesmí vlastnit doménový význam ani nahrazovat application a domain validaci.

## APR-013 – Reálný dependency test

Readiness databáze musí být ověřována integračním testem proti PostgreSQL, nikoli pouze in-memory náhražkou.

## APR-014 – Žádný předčasný product API

R0 API nesmí obsahovat workout, identity, sync, AI ani integration endpointy pouze do zásoby.

## APR-015 – Dokumentace, contract a implementace ve shodě

R0 API nelze označit za dokončené, pokud se tento dokument, OpenAPI, implementace a contract testy rozcházejí.

---

# 17. Další navazující práce

Po tomto dokumentu následuje zejména:

1. test strategy a release gates,
2. Definition of Ready a Definition of Done,
3. vertical-slice implementation plan pro R0 a R1,
4. coding-agent instructions a context-loading guide.

Před R2 vznikne samostatný identity/session a sync API kontrakt. Tento dokument se nemá rozšiřovat na kompletní cílové API.