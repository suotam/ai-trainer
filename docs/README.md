# AI Trainer – Documentation Map

**Verze:** 1.5  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-07-22

---

# 1. Účel

Tato složka obsahuje produktovou, UX, doménovou, technickou, bezpečnostní, integrační, delivery, testovací a provozní dokumentaci aplikace AI Trainer.

Aktuální stav, mezery a pořadí práce vlastní:

```text
docs/DOCUMENTATION_STATUS.md
```

Před vytvořením nového dokumentu je nutné zkontrolovat skutečný stav repozitáře, související zdroje pravdy a audit, aby nevznikaly duplicity.

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

`release-scope.md` vlastní implementační baseline R0 až R5, priority P0 až P3, exit criteria a pravidla `RSR-001` až `RSR-015`.

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
docs/12-data/data-architecture.md
docs/12-data/r1-physical-data-model.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/11-security/security-architecture.md
docs/10-integrations/integration-architecture.md
```

- `initial-architecture-decisions.md` vlastní `ADR-001` až `ADR-010` pro technologie blokující R0 a R1.
- `r0-api-contract.md` vlastní R0 liveness, readiness, error envelope, versioning, correlation a pravidla `APR-001` až `APR-015`.
- `r1-physical-data-model.md` vlastní lokální SQLite/Drift schema, transakce, migrace, recovery a pravidla `PDR-001` až `PDR-015`.
- Architektonické řady pravidel jsou `BAR`, `DAR`, `MAR`, `AIR`, `SAR` a `IAR`.

## 3.5 Delivery

```text
docs/13-delivery/repository-strategy.md
```

`repository-strategy.md` vlastní monorepo layout, hranice mobile/backend/contracts, migrations ownership, test placement, tooling, generated-code policy a pravidla `RER-001` až `RER-015`.

---

# 4. Implementační baseline

Startovní slices jsou:

```text
R0 – Technical Foundation
R1 – Local Workout Slice
```

R0 a R1 nesmí blokovat účet, cloudový sync, generativní AI, wearables ani externí kalendáře.

Startovní implementační minimum:

1. ✅ release scope,
2. ✅ repository strategy a projektová struktura,
3. ✅ počáteční ADR balík,
4. ✅ minimální fyzický datový model R1,
5. ✅ minimální API contract,
6. ⏭️ test strategy,
7. Definition of Ready a Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Detailní kontrakty pro R2 až R5 vznikají nejpozději před implementací slice, který je používá.

---

# 5. R0 API baseline

R0 backend poskytuje pouze:

```text
GET /api/v1/health/live
GET /api/v1/health/ready
```

Platí zejména:

- kanonický HTTP kontrakt je OpenAPI v `packages/contracts`,
- liveness neověřuje externí dependency,
- readiness ověřuje povinné dependency prostředí,
- každá response má `X-Request-Id`,
- chyby používají standardní bezpečný error envelope,
- health odpovědi jsou `no-store` a bez side effects,
- interní Actuator endpoint není veřejný aplikační kontrakt,
- workout, identity, sync, AI ani integration API do R0 nepatří.

Detail vlastní `docs/07-backend/r0-api-contract.md`.

---

# 6. Přijatá technologická baseline R0/R1

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

Detail vlastní `docs/05-architecture/initial-architecture-decisions.md`.

---

# 7. R1 persistence baseline

R1 používá lokální Drift/SQLite schema pro:

- workout instances a stabilní snapshots,
- sections, steps a set plans,
- aktivní WorkoutSession,
- step a set performances,
- workout feedback,
- rekonstruovatelný ActivitySummary,
- lokální migrations a recovery.

Start, zápis výkonu a dokončení workoutu jsou explicitní atomické transakce. Potvrzený výkon se nesmí ztratit po restartu aplikace.

Detail vlastní `docs/12-data/r1-physical-data-model.md`.

---

# 8. Repository baseline

Výchozí top-level struktura je:

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

Platí zejména:

- mobile a backend jsou samostatné aplikace,
- mobile je feature-first,
- backend respektuje modulární boundaries,
- contracts nejsou sdílený interní doménový model,
- serverové a mobilní migrace mají odlišný lifecycle,
- R1 je lokální a nevyžaduje backend,
- secrets a skutečná uživatelská data nepatří do repozitáře.

Detail vlastní `docs/13-delivery/repository-strategy.md`.

---

# 9. Pravidla práce s dokumentací

- Jeden význam má jeden hlavní vlastnící dokument.
- Nový dokument vznikne pouze pro skutečnou mezeru nebo samostatný kontrakt.
- AI může interpretovat a navrhovat, ale není autoritou pro doménovou změnu.
- Kritické workout flow musí fungovat bez sítě.
- Implementace postupuje po spustitelných vertikálních slices.

---

# 10. Metadata a identifikátory

Každý nový nebo revidovaný dokument má obsahovat:

```text
Verze:
Stav:
Soubor:
Vlastník:
Poslední aktualizace:
Navazuje na:
Navazující dokumenty:
Vlastněné pojmy nebo kontrakty:
```

Používané identifikátory zahrnují:

- `PP`, `FR`, `NFR`, `INV`,
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`, `PDR`, `APR`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nerecyklují.

---

# 11. Pracovní cyklus

```text
zkontrolovat aktuální GitHub
    ↓
přečíst DOCUMENTATION_STATUS.md
    ↓
vybrat skutečnou mezeru
    ↓
porovnat související zdroje pravdy
    ↓
vytvořit nebo upravit dokument
    ↓
commitnout změnu
    ↓
aktualizovat DOCUMENTATION_STATUS.md a případně README
```

---

# 12. Aktuální další krok

Podle současného auditu následuje:

```text
docs/14-quality/test-strategy.md
```

Má definovat testovací pyramid, ownership, R0/R1 critical paths, contract a migration tests, CI gates, flaky-test policy, coverage interpretaci a release evidence. Nemá duplikovat konkrétní test cases již vlastněné jednotlivými kontrakty.

---

# 13. Instrukce pro coding agenta

Před implementací změny musí agent:

1. načíst tento README a `DOCUMENTATION_STATUS.md`,
2. určit release slice a vlastnící doménu,
3. načíst relevantní invarianty a glossary,
4. načíst příslušný doménový model,
5. načíst FR, NFR a release scope,
6. načíst dotčená ADR, architektury, repository strategy a kontrakty,
7. ověřit acceptance criteria a Definition of Done,
8. až poté měnit kód.

Agent nesmí obcházet invariance, vytvářet paralelní repository strukturu bez rozhodnutí, sdílet interní model mezi mobilem a backendem, vložit secret do repozitáře ani označit práci za hotovou bez testů.