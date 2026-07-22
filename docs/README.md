# AI Trainer – Documentation Map

**Verze:** 1.9  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-07-22

---

# 1. Účel

Tato složka obsahuje produktovou, UX, doménovou, technickou, bezpečnostní, integrační, delivery, testovací a provozní dokumentaci AI Traineru.

Aktuální stav, mezery a kanonický další krok vlastní:

```text
docs/DOCUMENTATION_STATUS.md
```

Před dokumentační nebo implementační změnou je nutné načíst aktuální repozitář, tento README, audit a vlastnící zdroje pravdy.

---

# 2. Hierarchie zdrojů pravdy

Pokud si dokumenty odporují, platí toto pořadí:

1. právní a bezpečnostní pravidla,
2. produktové principy,
3. globální doménové invariance,
4. detailní vlastnící doménový model,
5. schválené ADR,
6. architektonický kontrakt,
7. API, event, sync nebo datový kontrakt,
8. release scope a acceptance criteria,
9. UX specifikace,
10. implementační doporučení a příklady.

Nižší vrstva může vyšší pravidlo zpřesnit, ale nesmí je obejít.

---

# 3. Hlavní zdroje pravdy

## 3.1 Vision and product

```text
docs/01-vision/vision.md
docs/01-vision/product-principles.md
docs/02-product/product-scope.md
docs/02-product/functional-requirements.md
docs/02-product/non-functional-requirements.md
docs/02-product/release-scope.md
```

`release-scope.md` vlastní R0 až R5, priority, scope boundaries a exit criteria.

## 3.2 Users and UX

```text
docs/03-users/user-personas.md
docs/03-users/user-scenarios.md
docs/04-ux/information-architecture.md
docs/04-ux/core-user-flows.md
docs/04-ux/screen-specifications.md
```

## 3.3 Domain

```text
docs/06-domain/domain-overview.md
docs/06-domain/sports-and-goals-model.md
docs/06-domain/training-plan-model.md
docs/06-domain/workout-model.md
docs/06-domain/scheduling-model.md
docs/06-domain/activity-model.md
docs/06-domain/recovery-and-limitations-model.md
docs/06-domain/ai-and-change-model.md
docs/06-domain/metrics-model.md
docs/06-domain/integration-model.md
docs/06-domain/sync-and-offline-model.md
docs/06-domain/identity-and-profile-model.md
docs/06-domain/domain-events.md
docs/06-domain/domain-invariants.md
docs/06-domain/glossary.md
```

## 3.4 Architecture and contracts

```text
docs/05-architecture/initial-architecture-decisions.md
docs/07-backend/backend-architecture.md
docs/07-backend/r0-api-contract.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/10-integrations/integration-architecture.md
docs/11-security/security-architecture.md
docs/12-data/data-architecture.md
docs/12-data/r1-physical-data-model.md
```

## 3.5 Delivery, quality and coding agent

```text
docs/13-delivery/repository-strategy.md
docs/13-delivery/definition-of-ready-and-done.md
docs/13-delivery/r0-r1-vertical-slice-plan.md
docs/14-quality/test-strategy.md
docs/15-coding-agent/coding-agent-guide.md
```

- `repository-strategy.md` vlastní monorepo layout, boundaries a `RER-001` až `RER-015`.
- `definition-of-ready-and-done.md` vlastní Ready/Done gates a `DRD-001` až `DRD-015`.
- `r0-r1-vertical-slice-plan.md` vlastní pořadí implementace a `VSP-001` až `VSP-015`.
- `test-strategy.md` vlastní test levels, quality gates a `QTR-001` až `QTR-015`.
- `coding-agent-guide.md` vlastní context-loading protocol, pracovní cyklus, commit discipline, evidence a `CAG-001` až `CAG-015`.

---

# 4. Implementační baseline

Startovní releases jsou:

```text
R0 – Technical Foundation
R1 – Local Workout Slice
```

Startovní dokumentační minimum je dokončeno:

1. ✅ release scope,
2. ✅ repository strategy,
3. ✅ počáteční ADR,
4. ✅ fyzický datový model R1,
5. ✅ R0 API contract,
6. ✅ test strategy,
7. ✅ Definition of Ready and Done,
8. ✅ R0/R1 vertical-slice implementation plan,
9. ✅ coding-agent instructions a context-loading guide.

Dalším kanonickým krokem je implementace:

```text
R0-01 – Repository Skeleton
```

---

# 5. R0/R1 implementation order

Kanonické pořadí vlastní `docs/13-delivery/r0-r1-vertical-slice-plan.md`.

## R0

```text
R0-01 Repository Skeleton
R0-02 Mobile Bootstrap
R0-03 Backend Bootstrap
R0-04 Contracts and Health API
R0-05 Local Infrastructure and Migrations
R0-06 CI and Repository Gates
R0-07 Mobile-to-Backend Smoke Flow
```

## R1

```text
R1-01 Local Workout Seed and Read Model
R1-02 Today and Workout Detail
R1-03 Start and Persist Session
R1-04 Record Workout Performance
R1-05 Restart and Recovery
R1-06 Complete Workout and History
R1-07 Feedback, States and Accessibility
R1-08 Critical End-to-End Evidence
```

R1 musí zůstat použitelné bez backendu, účtu, synchronizace, AI a externích providerů.

---

# 6. Coding-agent protocol

Před každou změnou musí agent:

1. načíst aktuální branch,
2. přečíst tento README a `DOCUMENTATION_STATUS.md`,
3. určit backlog item a release slice,
4. ověřit jeho Ready stav,
5. načíst vlastnící doménové, architektonické, kontraktní a testovací dokumenty,
6. respektovat vertical-slice plan a non-goals,
7. provést nejmenší smysluplnou změnu,
8. spustit relevantní testy a gates,
9. aktualizovat dokumentaci a evidence,
10. uvést commit pouze tehdy, pokud skutečně vznikl.

Detail vlastní `docs/15-coding-agent/coding-agent-guide.md`.

---

# 7. Delivery baseline

Backlog item smí vstoupit do implementace pouze pokud je `Ready`:

- má určený release slice a vlastníka,
- má jasný výsledek a non-goals,
- odkazuje na relevantní zdroje pravdy,
- má pozorovatelná acceptance criteria,
- má známé dependencies a test approach,
- nemá skryté technologické, datové nebo doménové rozhodnutí.

Pull request ani slice není `Done` bez:

- splněných acceptance criteria,
- relevantních testů a zelených gates,
- contract/migration evidence podle dopadu,
- aktuální dokumentace,
- vyřešených blocker a critical vad.

---

# 8. Quality baseline

Pro R0 a R1 platí zejména:

- povinné static checks,
- unit testy doménových pravidel,
- skutečné SQLite/Drift integration testy,
- PostgreSQL/Testcontainers integration testy,
- OpenAPI contract tests,
- migration a recovery tests,
- automatizovaný R1 offline restart/recovery critical path,
- flaky test není zelený důkaz.

---

# 9. R0 API baseline

R0 backend poskytuje pouze:

```text
GET /api/v1/health/live
GET /api/v1/health/ready
```

Workout, identity, sync, AI ani integration API do R0 nepatří.

---

# 10. Technology baseline

Pro R0 a R1 platí:

- Flutter a Dart,
- Riverpod,
- GoRouter,
- Drift nad SQLite,
- Kotlin a Spring Boot,
- PostgreSQL a Flyway,
- OpenAPI,
- Docker Compose,
- GitHub Actions,
- Flutter tests, Spring tests a Testcontainers.

---

# 11. Repository baseline

```text
ai-trainer/
├── apps/
│   ├── mobile/
│   └── backend/
├── packages/
│   └── contracts/
├── database/
├── tooling/
├── docs/
└── .github/
```

Mobile a backend jsou samostatné aplikace. Contracts nejsou společný interní doménový model. Serverové a mobilní migrace mají oddělený lifecycle.

---

# 12. Pravidla práce s dokumentací

- Jeden význam má jeden hlavní vlastnící dokument.
- Nový dokument vznikne pouze pro skutečnou mezeru nebo samostatný kontrakt.
- AI může interpretovat a navrhovat, ale není autoritou pro doménovou změnu.
- Kritické workout flow musí fungovat bez sítě.
- Implementace postupuje po spustitelných vertical slices.
- ID se nerecyklují.
- Po dokončení startovního minima se další obecná dokumentace nevytváří místo `R0-01`, pokud audit nepotvrdí novou blokující mezeru.

Používané řady zahrnují `PP`, `FR`, `NFR`, `INV`, `ADR`, `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`, `PDR`, `APR`, `QTR`, `DRD`, `VSP`, `CAG`, `SCN`, `FLOW`, `SCR`, `AC` a `EVT`.

---

# 13. Pracovní cyklus

```text
načíst aktuální GitHub
    ↓
přečíst README a DOCUMENTATION_STATUS
    ↓
vybrat Ready backlog item
    ↓
načíst vlastnící zdroje pravdy
    ↓
implementovat nejmenší smysluplnou změnu
    ↓
spustit povinné testy a gates
    ↓
zkontrolovat diff, secrets a dokumentační dopad
    ↓
commitnout skutečnou změnu
    ↓
uvést pravdivou evidence summary
```

---

# 14. Aktuální další krok

```text
R0-01 – Repository Skeleton
```

Před implementací se znovu načte aktuální `main`, ověří reálná struktura repozitáře a Ready stav podle delivery a coding-agent kontraktů.
