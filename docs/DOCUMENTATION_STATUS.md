# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 0.4  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-21  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Pravidla práce

Tento dokument se aktualizuje po každé významné dokumentační změně.

Před vytvořením nového souboru se vždy:

1. zkontroluje aktuální GitHub,
2. ověří související zdroje pravdy,
3. posoudí překryvy,
4. vytvoří nebo upraví dokument,
5. změna commitne,
6. aktualizuje tento stav.

Nový dokument vznikne pouze tehdy, pokud téma nemá zdroj pravdy, vyžaduje samostatný kontrakt, vlastníka, review nebo významně zlepší načítání kontextu.

---

# 2. Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ, zbývá konsistenční nebo odborné review.
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
- číslované funkční požadavky `FR-001` až `FR-192`.

Největší zbývající mezery:

- nefunkční požadavky,
- release scope a prioritizace,
- traceability požadavek → scénář → UX → doména → test,
- technické architektury,
- bezpečnostní a právní konkretizace,
- fyzický datový model,
- API, sync a event kontrakty,
- AI runtime a tool kontrakty,
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

## 4.2 Vision

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání, vize, odlišení, co produkt je a není. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy. |

## 4.3 Product

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Cílový rozsah a základní etapizace. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | Testovatelné cílové schopnosti `FR-001` až `FR-192`. |

## 4.4 Users

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé, potřeby a bariéry. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end a hraniční scénáře. |

## 4.5 UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní uživatelské toky. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace hlavních obrazovek. |

## 4.6 Domain

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `domain-overview.md` | SUBSTANTIAL_DRAFT | Bounded contexts, agregáty a mapa domény. |
| `sports-and-goals-model.md` | SUBSTANTIAL_DRAFT | Sporty, zkušenost, cíle a progres. |
| `training-plan-model.md` | SUBSTANTIAL_DRAFT | TrainingPlan, verze, bloky a týdny. |
| `workout-model.md` | SUBSTANTIAL_DRAFT | Workout struktura, instance, revize a session. |
| `scheduling-model.md` | SUBSTANTIAL_DRAFT | ScheduleEvent, recurrence a konflikty. |
| `activity-model.md` | SUBSTANTIAL_DRAFT | Activity, provenance, opravy a deduplikace. |
| `recovery-and-limitations-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Recovery, bolest, omezení a safety. |
| `ai-and-change-model.md` | SUBSTANTIAL_DRAFT | AIProposal, ChangeSet, potvrzení a undo. |
| `metrics-model.md` | SUBSTANTIAL_DRAFT | Metriky, agregace, trendy a rekordy. |
| `integration-model.md` | SUBSTANTIAL_DRAFT | Provider connection, import/export a lineage. |
| `sync-and-offline-model.md` | SUBSTANTIAL_DRAFT | Offline-first, konflikty a multi-device sync. |
| `identity-and-profile-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Identity, profil, onboarding, souhlasy a vztahy. |
| `domain-events.md` | SUBSTANTIAL_DRAFT | Event envelope, katalog, outbox/inbox a replay. |
| `domain-invariants.md` | SUBSTANTIAL_DRAFT | `INV-001` až `INV-100`. |
| `glossary.md` | SUBSTANTIAL_DRAFT | Kanonické názvosloví a vlastníci pojmů. |

---

# 5. Dokončený krok – funkční požadavky

`docs/02-product/functional-requirements.md` obsahuje:

- stabilní identifikátory `FR-001` až `FR-192`,
- priority CORE, IMPORTANT, ADVANCED a FUTURE,
- účet, profil a onboarding,
- sporty, cíle, dostupnost a vybavení,
- plán, kalendář, workout a tracker,
- Activity, recovery, pain a limitations,
- AI návrhy a adaptace,
- metriky a progres,
- integrace,
- offline a synchronizaci,
- notifikace,
- privacy, export a smazání,
- budoucí coach a guardian funkce,
- audit a fallbacky,
- traceability a readiness pravidla.

## 5.1 Co ještě vyžaduje review

Před `IMPLEMENTATION_READY` je nutné:

- ověřit úplnost proti celému `product-scope.md`,
- namapovat FR na scénáře, UX a doménu,
- přiřadit release disposition,
- vytvořit AcceptanceCriterion pro CORE a IMPORTANT,
- provést medicínské a právní review označených požadavků,
- ověřit, že žádné dva FR nemají konfliktní význam.

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
| obecný `offline-principles.md` | sync-and-offline model |
| obecný `event-catalog.md` | domain-events.md |
| obecný `ai-responsibilities.md` | product principles, AI/change model |
| samostatný `feature-catalog.md` | zatím functional requirements; rozdělit jen při skutečné potřebě |

---

# 7. Bezprostředně následující dokument

```text
docs/02-product/non-functional-requirements.md
```

Má zavést stabilní identifikátory `NFR-xxx` a měřitelné požadavky pro:

- dostupnost a spolehlivost,
- výkon a odezvu,
- offline fungování,
- konzistenci, idempotenci a obnovu,
- bezpečnost a privacy,
- data retention a deletion,
- accessibility a localization,
- mobilní battery, storage a network limity,
- škálovatelnost,
- observabilitu,
- portability a maintainability,
- provider a AI fallbacky.

---

# 8. Následující pořadí práce

## Fáze 1 – požadavky

1. ✅ `functional-requirements.md`
2. ⏭️ `non-functional-requirements.md`
3. release scope a priority matrix
4. traceability matrix
5. acceptance criteria strategy

## Fáze 2 – hlavní architektury

1. backend architecture,
2. data architecture,
3. mobile architecture,
4. AI architecture,
5. security architecture,
6. integration architecture.

## Fáze 3 – konkrétní kontrakty

- ADR technologických voleb,
- fyzická databázová schémata,
- API,
- sync protocol,
- AI tool schemas,
- event schemas,
- provider capability matrix.

## Fáze 4 – UX a design

- routes a deep links,
- globální loading/error/offline/conflict stavy,
- accessibility,
- design tokens a komponenty,
- kritické interaction contracts.

## Fáze 5 – kvalita, delivery a provoz

- test strategy,
- AI evaluation,
- security a performance tests,
- DevOps,
- release,
- observability,
- SLO a runbooks.

## Fáze 6 – implementační balíček

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
- `SCN-xxx` – User Scenario
- `FLOW-xxx` – UX Flow
- `SCR-xxx` – Screen
- `ADR-xxx` – Architecture Decision Record
- `AC-xxx` – Acceptance Criterion
- `EVT-xxx` – Integration event contract

ID se nesmí recyklovat.

---

# 10. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Další krok |
|---|---:|---:|---|
| Vision | vysoká | nevztahuje se přímo | review |
| Product principles | vysoká | střední | ID principů |
| Product scope | vysoká | střední | NFR, release scope |
| Functional requirements | vysoká | střední | traceability, AC, review |
| Users | vysoká | střední | ID a traceability |
| UX | vysoká | střední | routes, states, AC |
| Domain | velmi vysoká | střední | consistency a expert review |
| Backend | nízká | nízká | backend architecture |
| Mobile | nízká | nízká | mobile architecture |
| AI runtime | střední doménově | nízká | AI architecture a tools |
| Integrations | střední obecně | nízká | capability matrix |
| Security | nízká až střední | nízká | architecture a threat model |
| Data | nízká | nízká | data architecture |
| API | nízká | nízká | API principles a contracts |
| Quality | nízká | nízká | quality strategy |
| DevOps/Release/Operations | nízká | nízká | až po architekturách |
| Claude implementation guide | nízká | nízká | až po kontraktech |

---

# 11. Závěr

Produktový rozsah je nyní převeden do stabilního registru funkčních požadavků. Dalším krokem je definovat měřitelné kvalitativní vlastnosti systému v `non-functional-requirements.md`.

Cílem není maximální počet dokumentů, ale úplnost bez duplicit a jednoznačná dohledatelnost od vize přes požadavek až k implementaci a testu.