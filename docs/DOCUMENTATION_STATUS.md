# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 0.8  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-22  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Pravidla práce

Před vytvořením nebo zásadní úpravou dokumentu se vždy:

1. zkontroluje aktuální stav GitHubu,
2. ověří související zdroje pravdy,
3. posoudí překryvy a duplicity,
4. vytvoří nebo upraví dokument,
5. změna commitne,
6. aktualizuje tento audit a případně `docs/README.md`.

Nový dokument vznikne pouze tehdy, pokud téma nemá zdroj pravdy, vyžaduje samostatný kontrakt, vlastníka, odborné review nebo výrazně zlepší práci lidí a coding agentů.

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

Projekt má rozsáhlý základ v oblastech:

- vize a produktové principy,
- cílový produktový rozsah,
- persony a scénáře,
- informační architektura, UX flow a obrazovky,
- všechny hlavní doménové modely,
- doménové události,
- globální invariance,
- kanonické názvosloví,
- funkční požadavky `FR-001` až `FR-192`,
- nefunkční požadavky `NFR-001` až `NFR-172`,
- backendová architektura a pravidla `BAR-001` až `BAR-015`,
- datová architektura a pravidla `DAR-001` až `DAR-015`,
- mobilní architektura a pravidla `MAR-001` až `MAR-015`.

Největší zbývající mezery:

- AI runtime architecture,
- security architecture,
- integration architecture,
- release scope a prioritizace,
- traceability požadavek → scénář → UX → doména → test,
- fyzický relační a lokální datový model,
- API, sync a event kontrakty,
- AI tool kontrakty,
- design system,
- kvalita, DevOps, release a provoz,
- implementační instrukce pro coding agenta.

---

# 4. Skutečně existující dokumenty

## 4.1 Kořen

| Soubor | Stav | Úloha |
|---|---|---|
| `docs/README.md` | FOUNDATION_READY | Stručná mapa, zdroje pravdy a pracovní pravidla. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Řídicí audit a gap analysis. |

## 4.2 Vision and product

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání, vize, odlišení, co produkt je a není. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Cílový rozsah a základní etapizace. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Testovatelné schopnosti `FR-001` až `FR-192`. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Kvalitativní požadavky `NFR-001` až `NFR-172`. |

## 4.3 Users and UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé, potřeby a bariéry. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end a hraniční scénáře. |
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní uživatelské toky. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace hlavních obrazovek. |

## 4.4 Domain

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/06-domain/domain-overview.md` | SUBSTANTIAL_DRAFT | Bounded contexts, agregáty a mapa domény. |
| `docs/06-domain/sports-and-goals-model.md` | SUBSTANTIAL_DRAFT | Sporty, zkušenost, cíle a progres. |
| `docs/06-domain/training-plan-model.md` | SUBSTANTIAL_DRAFT | TrainingPlan, verze, bloky a týdny. |
| `docs/06-domain/workout-model.md` | SUBSTANTIAL_DRAFT | Workout struktura, instance, revize a session. |
| `docs/06-domain/scheduling-model.md` | SUBSTANTIAL_DRAFT | ScheduleEvent, recurrence a konflikty. |
| `docs/06-domain/activity-model.md` | SUBSTANTIAL_DRAFT | Activity, provenance, opravy a deduplikace. |
| `docs/06-domain/recovery-and-limitations-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Recovery, bolest, omezení a safety. |
| `docs/06-domain/ai-and-change-model.md` | SUBSTANTIAL_DRAFT | AIProposal, ChangeSet, potvrzení a undo. |
| `docs/06-domain/metrics-model.md` | SUBSTANTIAL_DRAFT | Metriky, agregace, trendy a rekordy. |
| `docs/06-domain/integration-model.md` | SUBSTANTIAL_DRAFT | Provider connection, import/export a lineage. |
| `docs/06-domain/sync-and-offline-model.md` | SUBSTANTIAL_DRAFT | Offline-first, konflikty a multi-device sync. |
| `docs/06-domain/identity-and-profile-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Identity, profil, onboarding, souhlasy a vztahy. |
| `docs/06-domain/domain-events.md` | SUBSTANTIAL_DRAFT | Event envelope, katalog, outbox/inbox a replay. |
| `docs/06-domain/domain-invariants.md` | SUBSTANTIAL_DRAFT | Globální pravidla `INV-001` až `INV-100`. |
| `docs/06-domain/glossary.md` | SUBSTANTIAL_DRAFT | Kanonické názvosloví a vlastníci pojmů. |

## 4.5 Architecture

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Modulární monolit, vrstvy, moduly, transactions, events, jobs a boundaries. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy, ownership, autorita, historie, storage, migrace, retence a backup. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Flutter klient, feature boundaries, local DB, offline commands, sync, lifecycle, workout runtime a platform adapters. |

---

# 5. Dokončený krok – mobile architecture

`docs/08-mobile/mobile-architecture.md` obsahuje:

- Flutter jako společný Android/iOS klient,
- izolaci nativních adapterů,
- presentation, application, domain-facing, repository a data vrstvy,
- feature-first strukturu,
- dependency rules,
- oddělení persistentního, UI, runtime, navigation, sync a permission stavu,
- lokální databázi jako základ čtení,
- offline-first tok,
- OfflineCommand queue,
- sync engine a konflikty,
- průběžnou persistenci a recovery aktivní WorkoutSession,
- navigation a authentication boundaries,
- AI chat a Proposal review,
- notifications a background execution,
- app lifecycle,
- permissions,
- GPS, health platforms a wearables,
- secure storage,
- networking a error model,
- observability, performance, battery a storage policy,
- compatibility, migrations a testování,
- pravidla `MAR-001` až `MAR-015`.

## 5.1 Co ještě vyžaduje review

Před `IMPLEMENTATION_READY` je nutné:

- přijmout mobile ADR,
- vytvořit fyzický local data model,
- definovat sync protocol,
- definovat route a deep-link kontrakty,
- potvrdit lokální encryption a token storage,
- vytvořit active-workout persistence kontrakt,
- ověřit background, GPS a notification limity Android/iOS,
- namapovat CORE FR a CRITICAL NFR,
- definovat architecture, migration, process-death a offline testy.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| `long-term-product-vision.md` | `vision.md` |
| `non-goals.md` | `vision.md`, `product-scope.md` |
| `product-positioning.md` | `vision.md`, dokud nevznikne samostatná marketingová potřeba |
| `multisport-user-model.md` | persony, scénáře, sports model |
| `returning-user-model.md` | scénáře, identity/profile model |
| `screen-inventory.md` | information architecture, screen specifications |
| obecný `offline-principles.md` | sync-and-offline model + mobile architecture |
| obecný `event-catalog.md` | domain-events.md |
| obecný `ai-responsibilities.md` | product principles, AI/change model |
| samostatný `feature-catalog.md` | functional requirements, dokud nevznikne skutečná potřeba |
| samostatný `modular-monolith-strategy.md` | backend architecture |
| samostatný obecný `data-ownership.md` | data architecture |
| samostatný obecný `flutter-project-structure.md` | zatím mobile architecture; oddělit až při konkrétním repository kontraktu |

---

# 7. Bezprostředně následující fáze

Doporučené pořadí hlavních architektur:

1. ✅ `docs/07-backend/backend-architecture.md`
2. ✅ `docs/12-data/data-architecture.md`
3. ✅ `docs/08-mobile/mobile-architecture.md`
4. ⏭️ `docs/09-ai/ai-architecture.md`
5. `docs/11-security/security-architecture.md`
6. `docs/10-integrations/integration-architecture.md`

Release scope a traceability zůstávají potvrzené potřebné dokumenty, ale jejich detail bude dokončen společně s architekturami a acceptance strategií.

---

# 8. Následující pořadí práce

## Fáze 1 – hlavní architektury

1. ✅ backend architecture,
2. ✅ data architecture,
3. ✅ mobile architecture,
4. ⏭️ AI architecture,
5. security architecture,
6. integration architecture.

## Fáze 2 – konkrétní kontrakty

- ADR technologických voleb,
- fyzická databázová schémata,
- API,
- sync protocol,
- AI tool schemas,
- event schemas,
- provider capability matrix.

## Fáze 3 – product delivery kontrakty

- release scope a priority matrix,
- traceability matrix,
- acceptance criteria strategy,
- UX routes a globální stavy,
- design system.

## Fáze 4 – kvalita, delivery a provoz

- test strategy,
- AI evaluation,
- security a performance tests,
- DevOps,
- release,
- observability,
- SLO a runbooks.

## Fáze 5 – implementační balíček

- repository strategy,
- vertical slices,
- Definition of Ready a Done,
- coding standards,
- Claude instructions,
- context-loading guide,
- prompt templates,
- documentation change policy.

---

# 9. Doporučené identifikátory

- `PP-xxx` – Product Principle
- `FR-xxx` – Functional Requirement
- `NFR-xxx` – Non-functional Requirement
- `INV-xxx` – Domain Invariant
- `BAR-xxx` – Backend Architecture Rule
- `DAR-xxx` – Data Architecture Rule
- `MAR-xxx` – Mobile Architecture Rule
- `SCN-xxx` – User Scenario
- `FLOW-xxx` – UX Flow
- `SCR-xxx` – Screen
- `ADR-xxx` – Architecture Decision Record
- `AC-xxx` – Acceptance Criterion
- `EVT-xxx` – Integration event contract

ID se nesmí recyklovat.

---

# 10. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Vision | vysoká | nevztahuje se přímo | konzistenční review |
| Product requirements | vysoká | střední | release scope, traceability, AC |
| Users and UX | vysoká | střední | states, routes, accessibility |
| Domain | velmi vysoká | střední | consistency a odborné review |
| Backend | vysoká | střední | ADR, API a architecture tests |
| Data | vysoká | nízká až střední | physical schema, local model a ADR |
| Mobile | vysoká | nízká až střední | ADR, local schema, sync a platform contracts |
| AI runtime | střední doménově | nízká | AI architecture |
| Security | nízká až střední | nízká | security architecture |
| Integrations | střední obecně | nízká | integration architecture a capability audit |
| Quality | nízká | nízká | quality strategy |
| DevOps | nízká | nízká | environments a deployment architecture |
| Release | nízká | nízká | release strategy |
| Operations | nízká | nízká | SLO a runbooks |
| Claude implementation guide | nízká | nízká | až po architekturách a kontraktech |

---

# 11. Pracovní cyklus

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
docs/09-ai/ai-architecture.md
```