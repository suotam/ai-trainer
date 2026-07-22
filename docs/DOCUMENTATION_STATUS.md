# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 1.3  
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
- repository strategy a pravidla `RER-001` až `RER-015`.

Hlavní architektonická fáze je dokončena. Programování R0 a R1 může začít po dokončení malého startovního implementačního minima; není nutné předem dokončit všechny kontrakty pro pozdější AI, sync, provider a operations slices.

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

## 4.5 Architecture and delivery

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice a `BAR-001` až `BAR-015`. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy a `DAR-001` až `DAR-015`. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime a `MAR-001` až `MAR-015`. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime a `AIR-001` až `AIR-015`. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries a `SAR-001` až `SAR-015`. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace a `IAR-001` až `IAR-015`. |
| `docs/13-delivery/repository-strategy.md` | SUBSTANTIAL_DRAFT | Monorepo layout, boundaries, tests, migrations, tooling a `RER-001` až `RER-015`. |

---

# 5. Dokončený krok – Repository strategy

`docs/13-delivery/repository-strategy.md` definuje:

- monorepo jako výchozí repository model,
- top-level strukturu `apps`, `packages`, `database`, `tooling` a `docs`,
- oddělení mobile, backendu a explicitních contracts,
- feature-first strukturu mobilu,
- modulární backend boundaries,
- ownership serverových a lokálních migrací,
- umístění unit, integration, contract a end-to-end testů,
- dependency direction a zákaz cycles,
- generated-code policy,
- configuration a secrets boundaries,
- R0 a R1 repository exit criteria,
- pravidla `RER-001` až `RER-015`.

## 5.1 Co ještě vyžaduje rozhodnutí

Před `IMPLEMENTATION_READY` pro R0/R1 je nutné přijmout zejména:

- ADR pro backendový jazyk a framework,
- ADR pro mobilní state management a dependency injection,
- ADR pro lokální mobilní databázi,
- ADR pro serverovou databázi a migrace,
- ADR pro contracts a code generation,
- ADR pro CI a development environment,
- minimální test strategy.

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
| obecný `test-folder-layout.md` | repository strategy; podrobnosti patří do test strategy |
| obecný `offline-principles.md` | sync model + mobile architecture |
| obecný `event-catalog.md` | `domain-events.md` |
| obecný `AI-provider-overview.md` | AI architecture; konkrétní volba patří do ADR |
| obecný `authentication-overview.md` | security architecture; konkrétní volba patří do ADR |
| obecný `integration-principles.md` | integration model + integration architecture |

---

# 7. Stav hlavních fází

## Fáze 1 – hlavní architektury

Dokončeno obsahově:

1. backend,
2. data,
3. mobile,
4. AI,
5. security,
6. integrations.

## Fáze 2 – startovní implementační minimum

Doporučené pořadí:

1. ✅ release scope,
2. ✅ repository strategy a projektová struktura,
3. ⏭️ počáteční ADR balík,
4. minimální fyzický datový model R1,
5. minimální API contract,
6. test strategy,
7. Definition of Ready a Done,
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
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Vision | vysoká | nevztahuje se přímo | konzistenční review |
| Product requirements | vysoká | střední až vysoká | FR/NFR mapování a AC |
| Release scope | vysoká | střední | backlog a traceability R0/R1 |
| Repository strategy | vysoká | střední | ADR a skutečný R0 skeleton |
| Users and UX | vysoká | střední | states, routes a accessibility |
| Domain | velmi vysoká | střední | consistency a odborné review |
| Backend | vysoká | střední | ADR, API a architecture tests |
| Data | vysoká | nízká až střední | physical schema R1 |
| Mobile | vysoká | střední | ADR, local schema a platform contracts |
| AI runtime | vysoká | nízká až střední | kontrakty před R4 |
| Security | vysoká | nízká až střední | threat model před produkčními flows |
| Integrations | vysoká | nízká až střední | kontrakty před první integrací |
| Quality | nízká | nízká | test strategy |
| DevOps | nízká | nízká | ADR, environments a CI baseline |
| Coding agent | nízká | nízká | instrukce po startovních kontraktech |

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
docs/05-architecture/initial-architecture-decisions.md
```

Tento dokument má vytvořit malý počáteční ADR balík pouze pro technologická rozhodnutí, která skutečně blokují R0 a R1.