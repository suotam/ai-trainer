# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 1.7  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-22  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Pravidla práce

Před vytvořením nebo zásadní úpravou dokumentu se vždy:

1. načte aktuální stav GitHubu,
2. ověří související zdroje pravdy,
3. posoudí překryvy a duplicity,
4. vytvoří nebo upraví dokument,
5. změna skutečně commitne,
6. aktualizuje tento audit a případně `docs/README.md`.

Nový dokument vznikne pouze tehdy, pokud téma nemá zdroj pravdy, vyžaduje samostatný kontrakt, vlastníka, odborné review nebo významně zlepší práci lidí a coding agentů.

---

# 2. Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ; zbývá konsistenční nebo odborné review.
- **SUBSTANTIAL_DRAFT** – rozsáhlý použitelný draft, zatím ne finálně schválený.
- **PARTIAL** – oblast je pokryta pouze částečně.
- **NEEDS_CONSOLIDATION** – obsah existuje, ale musí se sjednotit.
- **PLANNED** – potřeba dokumentu byla potvrzena.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již pokryt.
- **EXPERT_REVIEW_REQUIRED** – vyžaduje právní, medicínské nebo jiné odborné ověření.

Formální stav hlavních specifikací zůstává `Draft`, dokud neproběhne cross-document review.

---

# 3. Současný souhrn

Projekt má obsahově pokryté:

- vizi a produktové principy,
- dlouhodobý product scope,
- release scope a priority R0–R5,
- persony, scénáře, informační architekturu, flow a obrazovky,
- hlavní doménové modely, události, invariance a glossary,
- `FR-001` až `FR-192`,
- `NFR-001` až `NFR-172`,
- backend, data, mobile, AI, security a integration architecture,
- repository strategy a pravidla `RER-001` až `RER-015`,
- počáteční technologická rozhodnutí `ADR-001` až `ADR-010`,
- fyzický lokální datový model R1 a pravidla `PDR-001` až `PDR-015`,
- minimální R0 HTTP/OpenAPI kontrakt a pravidla `APR-001` až `APR-015`,
- test strategy, quality gates a pravidla `QTR-001` až `QTR-015`.

Hlavní architektonická fáze je dokončena. Programování R0 a R1 může začít po dokončení tří zbývajících delivery dokumentů; kontrakty pro pozdější AI, sync, provider a operations slices předem blokovat nemají.

---

# 4. Hlavní existující dokumenty

## 4.1 Řízení dokumentace

| Soubor | Stav | Úloha |
|---|---|---|
| `docs/README.md` | FOUNDATION_READY | Mapa zdrojů pravdy a pracovní pravidla. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Řídicí audit, mezery a pořadí práce. |

## 4.2 Vision and product

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání, vize a odlišení. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Dlouhodobý rozsah. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Funkční požadavky. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Nefunkční požadavky. |
| `docs/02-product/release-scope.md` | SUBSTANTIAL_DRAFT | R0–R5, P0–P3, exit criteria a `RSR-001` až `RSR-015`. |

## 4.3 Users and UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end a hraniční scénáře. |
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní flow. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace obrazovek. |

## 4.4 Domain

Doménová vrstva obsahuje vlastnící modely pro identity/profile, sports/goals, training plan, workout, scheduling, activity, recovery/limitations, AI/change, metrics, integrations, sync/offline, domain events, invariants a glossary. Obsahová připravenost je vysoká; zbývá consistency a odborné review.

## 4.5 Architecture, contracts, data, quality and delivery

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/05-architecture/initial-architecture-decisions.md` | SUBSTANTIAL_DRAFT | Technologie blokující R0/R1 a `ADR-001` až `ADR-010`. |
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice a `BAR-001` až `BAR-015`. |
| `docs/07-backend/r0-api-contract.md` | SUBSTANTIAL_DRAFT | R0 liveness, readiness, error envelope, compatibility a `APR-001` až `APR-015`. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy a `DAR-001` až `DAR-015`. |
| `docs/12-data/r1-physical-data-model.md` | SUBSTANTIAL_DRAFT | Lokální SQLite/Drift schema R1, transakce, migrace, recovery a `PDR-001` až `PDR-015`. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime a `MAR-001` až `MAR-015`. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime a `AIR-001` až `AIR-015`. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries a `SAR-001` až `SAR-015`. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace a `IAR-001` až `IAR-015`. |
| `docs/13-delivery/repository-strategy.md` | SUBSTANTIAL_DRAFT | Monorepo layout, boundaries, tests, migrations, tooling a `RER-001` až `RER-015`. |
| `docs/14-quality/test-strategy.md` | SUBSTANTIAL_DRAFT | Test levels, ownership, CI gates, critical paths, flaky policy, release evidence a `QTR-001` až `QTR-015`. |

---

# 5. Dokončený krok – Test strategy

`docs/14-quality/test-strategy.md` definuje:

- static, unit, widget, integration, contract, migration, architecture a end-to-end test levels,
- test ownership,
- R0 backend critical path,
- R1 offline workout critical path,
- skutečné SQLite a PostgreSQL integration testy,
- OpenAPI compatibility tests,
- mobile a server migration tests,
- CI pull-request, main a release-candidate gates,
- flaky-test quarantine policy,
- risk-based interpretaci coverage,
- test data a test-double pravidla,
- release evidence,
- security a reliability baseline,
- pravidla `QTR-001` až `QTR-015`.

## 5.1 Praktický dopad

R0 a R1 mají jednoznačně definované důkazy dokončení. Zelený build bez relevantních integration, contract a migration testů není dostatečný. Kritický R1 tok musí automatizovaně ověřit restart a recovery aktivní session a dokončení bez ztráty potvrzených dat.

## 5.2 Co ještě zbývá před programováním R0/R1

- Definition of Ready a Done,
- vertical-slice implementation plan,
- coding-agent instructions a context-loading guide.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| `mvp-overview.md` | `release-scope.md` |
| `roadmap-overview.md` | `product-scope.md` + `release-scope.md` |
| `stage-plan.md` | `release-scope.md`; detail patří do vertical-slice planu |
| obecný `monorepo-overview.md` | `repository-strategy.md` |
| obecný `flutter-project-structure.md` | mobile architecture + repository strategy |
| obecný `backend-project-structure.md` | backend architecture + repository strategy |
| obecný `test-folder-layout.md` | repository strategy + test strategy |
| samostatný `mobile-test-overview.md` | `test-strategy.md` |
| samostatný `backend-test-overview.md` | `test-strategy.md` |
| samostatný `flaky-test-policy.md` | `test-strategy.md` |
| samostatný `coverage-policy.md` | `test-strategy.md` |
| samostatný `contract-test-overview.md` | `test-strategy.md` + vlastnící kontrakt |
| samostatný `mobile-tech-stack.md` | initial architecture decisions |
| samostatný `backend-tech-stack.md` | initial architecture decisions |
| samostatný `database-choice.md` | initial architecture decisions |
| obecný `r1-local-database-overview.md` | `r1-physical-data-model.md` |
| obecný `health-endpoints.md` | `r0-api-contract.md` |
| obecný `error-envelope.md` | `r0-api-contract.md` |
| obecný `offline-principles.md` | sync model + mobile architecture |
| obecný `event-catalog.md` | `domain-events.md` |
| obecný `AI-provider-overview.md` | AI architecture; konkrétní volba patří do pozdějšího ADR |
| obecný `authentication-overview.md` | security architecture; konkrétní volba patří do pozdějšího ADR |

---

# 7. Stav hlavních fází

## Fáze 1 – hlavní architektury

Dokončeno obsahově: backend, data, mobile, AI, security a integrations.

## Fáze 2 – startovní implementační minimum

1. ✅ release scope,
2. ✅ repository strategy a projektová struktura,
3. ✅ počáteční ADR balík,
4. ✅ minimální fyzický datový model R1,
5. ✅ minimální API contract,
6. ✅ test strategy,
7. ⏭️ Definition of Ready a Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Po tomto balíku lze začít programovat R0 a R1.

## Fáze 3 – kontrakty pro pozdější slices

- sync protocol a identity/session kontrakty před R2,
- AI context, prompt, tool a structured-output schemas před R4,
- threat model a authorization matrix před chráněnými produkčními flows,
- provider capability matrix před první integrací,
- operations a incident dokumentace před produkčním releasem.

---

# 8. Doporučené identifikátory

Používané řady zahrnují:

- `PP`, `FR`, `NFR`, `INV`,
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`, `PDR`, `APR`, `QTR`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Product requirements | vysoká | střední až vysoká | FR/NFR mapování a AC |
| Release scope | vysoká | střední až vysoká | backlog a traceability R0/R1 |
| Repository strategy | vysoká | vysoká | skutečný R0 skeleton |
| Initial ADR | vysoká | vysoká pro R0/R1 | ověřit implementací |
| R1 local data | vysoká | vysoká | Drift implementace a tests |
| R0 API | vysoká | vysoká | OpenAPI a backend implementace |
| Quality | vysoká | vysoká pro R0/R1 baseline | implementovat CI gates a suites |
| Backend | vysoká | vysoká pro R0 základ | architecture a contract tests |
| Mobile | vysoká | vysoká pro R1 základ | repository a persistence implementace |
| DevOps | střední | střední až vysoká | environments a CI implementace |
| Delivery workflow | střední | nízká až střední | Definition of Ready and Done |
| Coding agent | nízká | nízká | instrukce po delivery kontraktech |

---

# 10. Pracovní cyklus

```text
zkontrolovat aktuální GitHub
    ↓
ověřit související zdroje pravdy
    ↓
vybrat skutečnou mezeru
    ↓
vytvořit nebo upravit dokument
    ↓
commitnout změnu
    ↓
aktualizovat DOCUMENTATION_STATUS.md a případně README
```

Další potvrzený dokument je:

```text
docs/13-delivery/definition-of-ready-and-done.md
```

Tento dokument má převést existující produktové, technické a testovací kontrakty na praktické vstupní a výstupní podmínky pro backlog item, pull request, R0 a R1 slice. Nemá duplikovat detailní test strategy ani acceptance criteria jednotlivých funkcí.
