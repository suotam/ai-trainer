# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 1.9  
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

Nový dokument vznikne pouze tehdy, pokud téma nemá zdroj pravdy, vyžaduje samostatný kontrakt nebo významně zlepší implementaci, audit, testování či provoz.

---

# 2. Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ; zbývá konsistenční nebo odborné review.
- **SUBSTANTIAL_DRAFT** – rozsáhlý použitelný draft, zatím ne finálně schválený.
- **PARTIAL** – oblast je pokryta pouze částečně.
- **PLANNED** – potřeba dokumentu byla potvrzena.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již pokryt.
- **EXPERT_REVIEW_REQUIRED** – vyžaduje právní, medicínské nebo jiné odborné ověření.

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
- R0/R1 vertical-slice implementation plan a `VSP-001` až `VSP-015`.

Před zahájením programování zbývá jediný potvrzený dokument: coding-agent/context-loading guide. Kontrakty pro R2 až R5 programování R0 a R1 neblokují.

---

# 4. Hlavní zdroje pravdy

## 4.1 Řízení dokumentace

| Soubor | Stav | Úloha |
|---|---|---|
| `docs/README.md` | FOUNDATION_READY | Mapa dokumentace a pracovní pravidla. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Audit, mezery a pořadí práce. |

## 4.2 Vision, product a UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání a odlišení. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Dlouhodobý rozsah. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Funkční požadavky. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Nefunkční požadavky. |
| `docs/02-product/release-scope.md` | SUBSTANTIAL_DRAFT | R0–R5, priority a exit criteria. |
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
| `docs/05-architecture/initial-architecture-decisions.md` | SUBSTANTIAL_DRAFT | Technologie blokující R0/R1. |
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice. |
| `docs/07-backend/r0-api-contract.md` | SUBSTANTIAL_DRAFT | R0 liveness, readiness a error envelope. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy. |
| `docs/12-data/r1-physical-data-model.md` | SUBSTANTIAL_DRAFT | Lokální SQLite/Drift schema R1. |
| `docs/13-delivery/repository-strategy.md` | SUBSTANTIAL_DRAFT | Monorepo layout a boundaries. |
| `docs/13-delivery/definition-of-ready-and-done.md` | SUBSTANTIAL_DRAFT | Ready/Done gates. |
| `docs/13-delivery/r0-r1-vertical-slice-plan.md` | SUBSTANTIAL_DRAFT | Pořadí R0/R1 slices, dependencies a evidence gates. |
| `docs/14-quality/test-strategy.md` | SUBSTANTIAL_DRAFT | Test levels, CI gates a release evidence. |

---

# 5. Dokončený krok – R0/R1 vertical-slice plan

`docs/13-delivery/r0-r1-vertical-slice-plan.md` definuje:

- sedm implementačních slices R0,
- osm implementačních slices R1,
- dependencies a povolenou paralelizaci,
- výsledné artefakty jednotlivých slices,
- evidence gates,
- R0 a R1 exit review,
- doporučené backlog označení `R0-01` až `R0-07` a `R1-01` až `R1-08`,
- change-control pravidla,
- pravidla `VSP-001` až `VSP-015`.

## 5.1 Praktický dopad

Implementace už nemá začít neurčitým „vytvořením aplikace“. Začíná repository skeletonem, pokračuje odděleným mobile/backend bootstrapem, kontraktem, infrastrukturou, CI a smoke flow. R1 následně postupuje od lokálních dat přes Today, session, výkon, recovery a completion až k automatizovanému offline end-to-end důkazu.

## 5.2 Co ještě zbývá před programováním R0/R1

- coding-agent instructions a context-loading guide.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| obecný `stage-plan.md` | `release-scope.md` + `r0-r1-vertical-slice-plan.md` |
| samostatný `r0-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `r1-plan.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `implementation-order.md` | `r0-r1-vertical-slice-plan.md` |
| samostatný `backlog-ready.md` | `definition-of-ready-and-done.md` |
| samostatný `pull-request-done.md` | `definition-of-ready-and-done.md` |
| samostatný `flaky-test-policy.md` | `test-strategy.md` |
| obecný `health-endpoints.md` | `r0-api-contract.md` |
| obecný `r1-local-database-overview.md` | `r1-physical-data-model.md` |
| obecný `offline-principles.md` | sync model + mobile architecture |
| obecný `AI-provider-overview.md` | AI architecture; konkrétní volba patří do pozdějšího ADR |

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
9. ⏭️ coding-agent instructions a context-loading guide.

Po posledním dokumentu lze začít implementovat `R0-01 – Repository Skeleton`.

## Fáze 3 – kontrakty pro pozdější slices

Vzniknou před slicem, který je používá: identity/session a sync před R2, AI schemas před R4, provider contracts před první integrací a operations dokumentace před produkčním releasem.

---

# 8. Identifikátory

Používané řady zahrnují:

- `PP`, `FR`, `NFR`, `INV`,
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`,
- `RSR`, `RER`, `PDR`, `APR`, `QTR`, `DRD`, `VSP`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Release scope | vysoká | vysoká | řídit backlog podle VSP |
| Repository strategy | vysoká | vysoká | implementovat R0-01 |
| Initial ADR | vysoká | vysoká | ověřovat implementací |
| R0 API | vysoká | vysoká | implementovat R0-04 |
| R1 local data | vysoká | vysoká | implementovat R1-01 |
| Quality | vysoká | vysoká | implementovat CI a suites |
| Delivery workflow | vysoká | vysoká | používat Ready/Done a VSP |
| Coding agent | nízká | nízká | vytvořit coding-agent guide |

---

# 10. Další potvrzený dokument

```text
docs/15-coding-agent/coding-agent-guide.md
```

Má určit povinné načítání kontextu, výběr backlog itemu, Ready kontrolu, pracovní postup, testy, dokumentační aktualizace, commit discipline a formát evidence. Nemá duplikovat architektury, test strategy ani vertical-slice plan.