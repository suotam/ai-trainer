# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 2.6  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-22  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Pravidla práce

Před vytvořením dokumentu nebo implementační změny se vždy:

1. načte aktuální stav GitHubu,
2. přečte `docs/README.md` a tento audit,
3. ověří související zdroje pravdy,
4. posoudí překryvy a duplicity,
5. ověří Ready stav backlog itemu,
6. provede změna a povinné kontroly,
7. změna skutečně commitne,
8. aktualizuje dokumentace a evidence podle dopadu.

Nový dokument vznikne pouze pro potvrzenou mezeru nebo samostatný kontrakt. Po dokončení startovního minima se již nemá vytvářet další obecná dokumentace místo implementace `R0-01`.

---

# 2. Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ; zbývá konsistenční nebo odborné review.
- **IMPLEMENTATION_READY** – potřebné kontrakty pro daný slice jsou dostupné.
- **SUBSTANTIAL_DRAFT** – rozsáhlý použitelný draft, zatím ne finálně schválený.
- **PARTIAL** – oblast je pokryta pouze částečně.
- **PLANNED** – dokument nebo kontrakt je potvrzený pro budoucí slice.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již vlastněn jiným zdrojem pravdy.
- **EXPERT_REVIEW_REQUIRED** – vyžaduje odborné ověření.

---

# 3. Současný souhrn

Projekt má obsahově pokryté:

- vizi, principy, product scope a release scope,
- persony, scénáře, informační architekturu, flow a obrazovky,
- hlavní doménové modely, události, invariance a glossary,
- `FR-001` až `FR-192` a `NFR-001` až `NFR-172`,
- backend, data, mobile, AI, security a integration architecture,
- repository strategy a `RER-001` až `RER-015`,
- počáteční ADR `ADR-001` až `ADR-010`,
- fyzický lokální datový model R1 a `PDR-001` až `PDR-015`,
- minimální R0 API kontrakt a `APR-001` až `APR-015`,
- test strategy a `QTR-001` až `QTR-015`,
- Definition of Ready and Done a `DRD-001` až `DRD-015`,
- R0/R1 vertical-slice plan a `VSP-001` až `VSP-015`,
- coding-agent/context-loading guide a `CAG-001` až `CAG-015`.

**Startovní dokumentační minimum pro R0 a R1 je dokončeno.**

`R0-01 – Repository Skeleton` je implementován: existuje kanonická root struktura (`apps/mobile`, `apps/backend`, `packages/contracts`, `tooling/scripts`), root `README.md`, `.editorconfig`, rozšířený `.gitignore` a repository smoke check `tooling/scripts/repo-smoke-check.sh`. Adresáře `database/`, `.github/` a `compose.yaml` vzniknou až se slices, které je skutečně potřebují (R0-05, R0-06).

`R0-02 – Mobile Bootstrap` je implementován: Flutter aplikace v `apps/mobile` s Riverpod composition rootem, GoRouter shellem, základním theme, lokalizací (en + cs), environment configuration boundary a technickou úvodní obrazovkou; `flutter analyze` a testy jsou zelené, Android build a spuštění na emulátoru ověřeno. Dřívější výjimka DRD-013 pro iOS build evidence byla uzavřena v R0-06: `flutter build ios --no-codesign` prošel na GitHub macOS runneru (mobile workflow, job `iOS build (no codesign)`).

`R0-03 – Backend Bootstrap` je implementován: Kotlin/Spring Boot aplikace v `apps/backend` (Gradle wrapper, JDK 25, Spring Boot 4.1) s bezpečnou konfigurací bez secrets, testovatelným `Clock` beanem, `X-Request-Id` infrastrukturou s MDC korelací logů a service name/version providerem; build a testy zelené, lokální start ověřen včetně kontroly logů (bez secrets a environment dumpu). Produktové moduly a health API vzniknou v navazujících slices.

`R0-04 – Contracts and Health API` je implementován: kanonický OpenAPI `packages/contracts/openapi/ai-trainer-api.yaml` (getLiveness, getReadiness, error envelope, X-Request-Id headers), backend implementuje `GET /api/v1/health/live` a `/ready` s `Cache-Control: no-store`, centralizovaným bezpečným error envelope a rozšiřitelným `ReadinessIndicator` portem (nyní pravdivě pouze `application` check; database/migrations checky doplní R0-05 bez změny veřejného kontraktu). Contract testy (swagger-parser nad kanonickým souborem), unit a integration testy včetně 503 failure path jsou zelené; runtime ověřeno lokálně přes curl. PostgreSQL readiness evidence (skutečná nedostupná databáze, Testcontainers) bude dokončena v R0-05.

`R0-05 – Local Infrastructure and Migrations` je implementován: root `compose.yaml` spouští lokální PostgreSQL 17 s development-only credentials a healthcheckem (host port přepsatelný přes `AITRAINER_POSTGRES_PORT`), kanonické serverové Flyway migrace žijí v `database/migrations` (build je balí do backend classpath — jedna kopie), minimální `V1__schema_baseline` bez produktových tabulek, readiness rozšířena o `database` a `migrations` checky přes existující `ReadinessIndicator` port (aditivní, kontrakt beze změny). Testy používají skutečný PostgreSQL přes Testcontainers včetně migration testu od prázdné databáze, nevalidního schema stavu (503 → recovery migrací → 200) a zastavené databáze (liveness 200, readiness 503). Compose runtime evidence ověřena lokálně včetně failure path. Lokální start backendu nově vyžaduje běžící PostgreSQL (Flyway při startu).

`R0-06 – CI and Repository Gates` je implementován: `.github/workflows/` obsahuje `repository` (smoke check, gitleaks secret scan nad plnou historií, Compose validace), `mobile` (Flutter 3.44.4: format/analyze/test/Android debug build + iOS no-codesign build na macOS runneru) a `backend` (Gradle wrapper validace, JDK 25, ktlint gate, build + čerstvý test run včetně OpenAPI contract a PostgreSQL/Flyway Testcontainers testů). Všechna workflow běží na PR i push do `main` s `contents: read`; lokální příkazy odpovídají CI. Backend ktlint gate (`./gradlew ktlintCheck`, ktlint-cli 1.8.0) je zapojen do `check`. První PR run: všech 6 jobs zelených.

Dalším kanonickým krokem není další obecný dokument, ale implementace:

```text
R0-07 – Mobile-to-Backend Smoke Flow
```

Kontrakty pro R2 až R5 vzniknou nejpozději před slicem, který je skutečně používá.

---

# 4. Hlavní zdroje pravdy

## 4.1 Řízení dokumentace

| Soubor | Stav | Úloha |
|---|---|---|
| `docs/README.md` | FOUNDATION_READY | Mapa dokumentace a pracovní pravidla. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Audit, mezery a kanonický další krok. |

## 4.2 Vision, product a UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání a odlišení. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Dlouhodobý rozsah. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Funkční požadavky. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Nefunkční požadavky. |
| `docs/02-product/release-scope.md` | IMPLEMENTATION_READY pro R0/R1 | R0–R5, priority a exit criteria. |
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end scénáře. |
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní flow. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace obrazovek. |

## 4.3 Domain

Dokumenty v `docs/06-domain/` vlastní identity/profile, sports/goals, training plan, workout, scheduling, activity, recovery/limitations, AI/change, metrics, integrations, sync/offline, events, invariance a glossary.

## 4.4 Architecture, contracts, data, quality and delivery

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/05-architecture/initial-architecture-decisions.md` | IMPLEMENTATION_READY pro R0/R1 | Technologie blokující R0/R1. |
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice. |
| `docs/07-backend/r0-api-contract.md` | IMPLEMENTATION_READY | R0 liveness, readiness a error envelope. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy. |
| `docs/12-data/r1-physical-data-model.md` | IMPLEMENTATION_READY | Lokální SQLite/Drift schema R1. |
| `docs/13-delivery/repository-strategy.md` | IMPLEMENTATION_READY | Monorepo layout a boundaries. |
| `docs/13-delivery/definition-of-ready-and-done.md` | IMPLEMENTATION_READY | Ready/Done gates. |
| `docs/13-delivery/r0-r1-vertical-slice-plan.md` | IMPLEMENTATION_READY | Pořadí R0/R1 slices a evidence gates. |
| `docs/14-quality/test-strategy.md` | IMPLEMENTATION_READY | Test levels, CI gates a evidence. |
| `docs/15-coding-agent/coding-agent-guide.md` | IMPLEMENTATION_READY | Context loading, pracovní cyklus, commit discipline a evidence. |

---

# 5. Dokončený krok – Coding Agent Guide

`docs/15-coding-agent/coding-agent-guide.md` definuje:

- povinné načtení aktuálního branch,
- vždy načítané a změnou podmíněné zdroje pravdy,
- context manifest,
- výběr backlog itemu podle VSP,
- Ready kontrolu,
- pracovní cyklus před, během a po změně,
- testovací a dokumentační povinnosti,
- commit discipline,
- strukturovaný formát evidence,
- postup při rozporu dokumentů,
- zakázané chování,
- pravidla `CAG-001` až `CAG-015`.

## 5.1 Praktický dopad

Coding agent již nemá začít neurčitým požadavkem na vytvoření aplikace. Musí vybrat konkrétní Ready backlog item, načíst jeho vlastnící kontext, provést nejmenší smysluplnou změnu, spustit relevantní kontroly a uvést pravdivou evidence summary.

## 5.2 Implementační start

První položka je:

```text
R0-01 – Repository Skeleton
```

Před zahájením se znovu načte aktuální `main` a ověří Ready checklist.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| obecný `stage-plan.md` | `release-scope.md` + `r0-r1-vertical-slice-plan.md` |
| samostatný `r0-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `r1-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `implementation-order.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `context-loading-guide.md` | `coding-agent-guide.md` |
| samostatný `commit-policy.md` | `coding-agent-guide.md` |
| samostatný `agent-evidence-template.md` | `coding-agent-guide.md` |
| samostatný `backlog-ready.md` | `definition-of-ready-and-done.md` |
| samostatný `pull-request-done.md` | `definition-of-ready-and-done.md` |
| samostatný `flaky-test-policy.md` | `test-strategy.md` |
| obecný `health-endpoints.md` | `r0-api-contract.md` |
| obecný `r1-local-database-overview.md` | `r1-physical-data-model.md` |
| obecný `offline-principles.md` | sync model + mobile architecture |

---

# 7. Stav hlavních fází

## Fáze 1 – hlavní architektury

Dokončeno obsahově: backend, data, mobile, AI, security a integrations.

## Fáze 2 – startovní implementační minimum

1. ✅ release scope,
2. ✅ repository strategy,
3. ✅ počáteční ADR,
4. ✅ fyzický datový model R1,
5. ✅ R0 API contract,
6. ✅ test strategy,
7. ✅ Definition of Ready and Done,
8. ✅ vertical-slice implementation plan,
9. ✅ coding-agent instructions a context-loading guide.

**Fáze 2 je dokončena.**

## Fáze 3 – implementace R0 a R1

```text
R0-01 Repository Skeleton ✅
R0-02 Mobile Bootstrap ✅ (iOS výjimka uzavřena v R0-06)
R0-03 Backend Bootstrap ✅
R0-04 Contracts and Health API ✅
R0-05 Local Infrastructure and Migrations ✅
R0-06 CI and Repository Gates ✅
R0-07 Mobile-to-Backend Smoke Flow
R1-01 až R1-08 podle vertical-slice planu
```

## Pozdější kontrakty

Identity/session a sync před R2, AI schemas před R4, provider contracts před první integrací a operations dokumentace před produkčním releasem.

---

# 8. Identifikátory

Používané řady zahrnují:

- `PP`, `FR`, `NFR`, `INV`,
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`,
- `RSR`, `RER`, `PDR`, `APR`, `QTR`, `DRD`, `VSP`, `CAG`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Release scope | vysoká | vysoká | řídit backlog podle VSP |
| Repository strategy | vysoká | vysoká | implementovat R0-01 |
| Initial ADR | vysoká | vysoká pro R0/R1 | ověřovat implementací |
| R0 API | vysoká | vysoká | implementovat R0-04 |
| R1 local data | vysoká | vysoká | implementovat R1-01 |
| Quality | vysoká | vysoká | implementovat CI a suites |
| Delivery workflow | vysoká | vysoká | používat Ready/Done a VSP |
| Coding agent | vysoká | vysoká | používat CAG protocol |

---

# 10. Další kanonický krok

```text
R0-07 – Mobile-to-Backend Smoke Flow
```

Před jeho implementací je nutné načíst aktuální GitHub, ověřit skutečnou strukturu repozitáře a provést Ready kontrolu podle `definition-of-ready-and-done.md` a `coding-agent-guide.md`.
