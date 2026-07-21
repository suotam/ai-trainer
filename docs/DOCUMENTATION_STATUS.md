# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 0.2  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-21  
**Účel:** Evidovat skutečný stav dokumentace, překryvy, mezery a doporučené pořadí další práce.

---

# 1. Účel dokumentu

Tento dokument je řídicí přehled skutečně existující dokumentace projektu AI Trainer.

Jeho cílem je:

- rozlišit existující a pouze plánované soubory,
- určit hlavní zdroj pravdy pro jednotlivá témata,
- zabránit vytváření duplicitních dokumentů,
- identifikovat skutečné mezery,
- sledovat připravenost oblastí pro implementaci,
- určit další dokument podle aktuálního stavu repozitáře,
- usnadnit budoucímu coding agentovi výběr kontextu.

Tento dokument se musí aktualizovat po dokončení každé významné dokumentační části.

---

# 2. Pravidla auditu

Každý dokument je posuzován podle:

1. účelu,
2. vlastněných pojmů a pravidel,
3. překryvů,
4. mezer,
5. připravenosti pro implementaci,
6. návazností,
7. potřeby samostatného souboru.

## 2.1 Stavové hodnoty

- **FOUNDATION_READY** – stabilní základ, zbývá konsistenční nebo odborné review.
- **SUBSTANTIAL_DRAFT** – rozsáhlý použitelný draft, zatím ne finálně schválený.
- **PARTIAL** – oblast je pokryta pouze částečně.
- **NEEDS_CONSOLIDATION** – informace existují, ale je nutné je sjednotit nebo odstranit duplicity.
- **PLANNED** – potřeba samostatného dokumentu byla potvrzena.
- **NOT_NEEDED_AS_SEPARATE_FILE** – obsah je již dostatečně pokryt.
- **EXPERT_REVIEW_REQUIRED** – vyžaduje právní, medicínské nebo jiné odborné ověření.

Formální stav současných specifikací zůstává `Draft`, dokud neproběhne cross-document review.

---

# 3. Současný souhrn

Projekt má velmi rozsáhlý základ v oblastech:

- vize a produktové principy,
- produktový rozsah,
- uživatelské persony a scénáře,
- informační architektura a hlavní UX flow,
- specifikace hlavních obrazovek,
- doménový přehled,
- sporty a cíle,
- plány,
- workouty,
- scheduling,
- aktivity,
- recovery a omezení,
- AI návrhy a bezpečné změny,
- metriky,
- integrace,
- offline a synchronizace,
- identity a profil,
- doménové události,
- globální a cross-domain invariance.

Největší zbývající mezery jsou:

- kanonický slovník,
- testovatelné funkční a nefunkční požadavky,
- technické architektury,
- bezpečnost a právní konkretizace,
- fyzický datový model,
- API a sync kontrakty,
- AI runtime a tool kontrakty,
- design system,
- kvalita, DevOps, release a provoz,
- implementační instrukce pro coding agenta.

---

# 4. Skutečně existující dokumenty

## 4.1 Kořen dokumentace

| Soubor | Stav auditu | Úloha |
|---|---|---|
| `docs/README.md` | NEEDS_CONSOLIDATION | Mapa dokumentace; po glossary bude zkrácena a sladěna s auditem. |
| `docs/DOCUMENTATION_STATUS.md` | FOUNDATION_READY | Řídicí stav a gap analysis. |

## 4.2 Vision

| Soubor | Stav auditu | Zdroj pravdy pro |
|---|---|---|
| `docs/01-vision/vision.md` | FOUNDATION_READY | Poslání, dlouhodobá vize, co produkt je a není, odlišení a definice úspěchu. |
| `docs/01-vision/product-principles.md` | FOUNDATION_READY | Neměnné produktové principy, kontrola uživatele, vysvětlitelnost, bezpečnost, společný multisportovní systém. |

## 4.3 Product

| Soubor | Stav auditu | Zdroj pravdy pro |
|---|---|---|
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Cílový rozsah produktu a základní etapizace. |

## 4.4 Users

| Soubor | Stav auditu | Zdroj pravdy pro |
|---|---|---|
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cílové typy uživatelů, potřeby, motivace a bariéry. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end případy použití a hraniční situace. |

## 4.5 UX

| Soubor | Stav auditu | Zdroj pravdy pro |
|---|---|---|
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie a hlavní části aplikace. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní uživatelské toky. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace hlavních mobilních obrazovek. |

## 4.6 Domain

| Soubor | Stav auditu | Zdroj pravdy pro |
|---|---|---|
| `docs/06-domain/domain-overview.md` | SUBSTANTIAL_DRAFT | Bounded contexts, agregáty a mapa domény. |
| `docs/06-domain/sports-and-goals-model.md` | SUBSTANTIAL_DRAFT | Sporty, zkušenost, cíle, priority a progres. |
| `docs/06-domain/training-plan-model.md` | SUBSTANTIAL_DRAFT | TrainingPlan, verze, bloky, týdny a adaptace. |
| `docs/06-domain/workout-model.md` | SUBSTANTIAL_DRAFT | Workout struktura, instance, revize a session. |
| `docs/06-domain/scheduling-model.md` | SUBSTANTIAL_DRAFT | Kalendářní události, flexibilita, recurrence a konflikty. |
| `docs/06-domain/activity-model.md` | SUBSTANTIAL_DRAFT | Skutečné aktivity, provenance, import, opravy a deduplikace. |
| `docs/06-domain/recovery-and-limitations-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Check-in, readiness, bolest, omezení a safety dopady. |
| `docs/06-domain/ai-and-change-model.md` | SUBSTANTIAL_DRAFT | AIProposal, ChangeSet, potvrzení, stale stav a undo. |
| `docs/06-domain/metrics-model.md` | SUBSTANTIAL_DRAFT | Metriky, série, agregace, trendy, rekordy a výpočetní verze. |
| `docs/06-domain/integration-model.md` | SUBSTANTIAL_DRAFT | Provider connections, import/export, lineage, webhooks a reconciliation. |
| `docs/06-domain/sync-and-offline-model.md` | SUBSTANTIAL_DRAFT | Offline-first, command queue, konflikty, tombstones a multi-device sync. |
| `docs/06-domain/identity-and-profile-model.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Identity, účet, profil, onboarding, preference, souhlasy a vztahy. |
| `docs/06-domain/domain-events.md` | SUBSTANTIAL_DRAFT | Event envelope, katalog, outbox/inbox, retry, replay a projekce. |
| `docs/06-domain/domain-invariants.md` | SUBSTANTIAL_DRAFT | Globální priority, cross-domain konzistence a registr `INV-001` až `INV-100`. |

---

# 5. Výsledek auditu duplicit

Následující soubory nyní nevytvářet jako samostatné dokumenty:

| Původně uvažovaný soubor | Důvod | Současný zdroj pravdy |
|---|---|---|
| `01-vision/long-term-product-vision.md` | Dlouhodobá vize již existuje. | `vision.md` |
| `01-vision/non-goals.md` | Co produkt není a co je mimo scope již existuje. | `vision.md`, `product-scope.md` |
| `01-vision/product-positioning.md` | Základní odlišení je popsáno; samostatně pouze při marketingové potřebě. | `vision.md` |
| `03-users/multisport-user-model.md` | Obsah je v personách, scénářích a doméně sportů. | persony, scénáře, sports model |
| `03-users/returning-user-model.md` | Návrat je scénář a část profilu, nikoli samostatná doména. | scenarios, identity/profile model |
| `04-ux/screen-inventory.md` | Seznam a detail obrazovek již existují. | information architecture, screen specifications |
| obecný `offline-principles.md` | Offline pravidla jsou detailně pokryta. | sync-and-offline model |
| obecný `event-catalog.md` | Katalog je součástí domain events. | domain-events.md |
| obecný `ai-responsibilities.md` | Produktová a doménová odpovědnost je již definována. | product principles, AI/change model |

Nový samostatný soubor vznikne pouze s jasně odlišným účelem, vlastníkem a praktickým použitím.

---

# 6. Dokončený krok – globální invariance

`docs/06-domain/domain-invariants.md` byl vytvořen a obsahuje:

- stabilní identifikátory `INV-001` až `INV-100`,
- pořadí globálních priorit,
- pravidla vlastnictví a izolace dat,
- historii, verze a opravy,
- čas a schedule,
- vztah plán–workout–activity,
- recovery a safety pravidla,
- metriky,
- AI a ChangeSet,
- souhlasy a citlivá data,
- integrace,
- offline a multi-device synchronizaci,
- eventy a audit,
- mazání, export a retenci,
- notifikace a automatizace,
- konflikt resolution hierarchy,
- povinné testovací skupiny.

## 6.1 Potřebná budoucí review

Před stavem `IMPLEMENTATION_READY` dokument vyžaduje:

- cross-check proti všem detailním doménovým modelům,
- bezpečnostní review,
- medicínské review pravidel bolesti a omezení,
- právní review souhlasů a nezletilých,
- mapování invariant na testy, API a architektury.

---

# 7. Bezprostředně následující dokument

Další dokument je:

```text
docs/06-domain/glossary.md
```

Jeho úkolem bude:

- definovat kanonické pojmy,
- určit vlastnící dokument každého pojmu,
- rozlišit snadno zaměnitelné objekty,
- určit povolená a zakázaná synonyma,
- sjednotit názvy mezi produktem, UX, doménou, API, backendem, mobilem a AI.

Nebude opakovat celé modely nebo jejich invariance.

---

# 8. Následující pořadí práce

## Fáze 1 – uzavření doménového základu

1. ✅ `docs/DOCUMENTATION_STATUS.md`
2. ✅ `docs/06-domain/domain-invariants.md`
3. ⏭️ `docs/06-domain/glossary.md`
4. aktualizace a zkrácení `docs/README.md`
5. cross-document domain consistency review
6. doplnění metadat, ID a odkazů do základních dokumentů

## Fáze 2 – testovatelné požadavky

1. `docs/02-product/functional-requirements.md`
2. `docs/02-product/non-functional-requirements.md`
3. release scope a priority matrix
4. traceability matrix požadavek → scénář → flow → doména → test

## Fáze 3 – hlavní technické architektury

1. backend architecture,
2. data architecture,
3. mobile architecture,
4. AI architecture,
5. security architecture,
6. integration architecture.

## Fáze 4 – konkrétní kontrakty

- ADR technologických voleb,
- relační a lokální schema,
- API,
- sync protokol,
- AI tool schemas a structured outputs,
- event schemas,
- provider capability matrix.

## Fáze 5 – UX a design

- navigační technický kontrakt,
- globální loading/error/offline/conflict UX,
- accessibility,
- design tokens,
- komponenty,
- kritické interaction contracts.

## Fáze 6 – kvalita, delivery a provoz

- test strategy,
- acceptance criteria,
- AI evaluation,
- security testing,
- DevOps,
- release,
- observability,
- SLO a runbooks.

## Fáze 7 – implementační balíček pro Clauda

- repository strategy,
- vertical slices,
- Definition of Ready,
- Definition of Done,
- coding standards,
- Claude instructions,
- context-loading guide,
- prompt templates,
- documentation and change policy.

---

# 9. Potvrzené hlavní budoucí dokumenty

Následující dokumenty mají potvrzenou samostatnou potřebu:

## Product

- `docs/02-product/functional-requirements.md`
- `docs/02-product/non-functional-requirements.md`

## Domain

- `docs/06-domain/glossary.md`

## Architecture

- `docs/07-backend/backend-architecture.md`
- `docs/08-mobile/mobile-architecture.md`
- `docs/09-ai/ai-architecture.md`
- `docs/10-integrations/integration-architecture.md`
- `docs/11-security/security-architecture.md`
- `docs/12-data/data-architecture.md`

Další soubory budou určeny až uvnitř těchto architektur podle skutečných hranic a kontraktů.

---

# 10. Pravidla další tvorby souborů

Nový dokument vznikne pouze tehdy, pokud:

1. téma nemá zdroj pravdy,
2. existující dokument je příliš obecný pro implementaci,
3. téma má jiného vlastníka nebo životní cyklus,
4. obsah bude samostatný kontrakt,
5. rozdělení významně zlepší načítání AI kontextu,
6. samostatný soubor je nutný pro audit, test, provoz nebo provider integraci.

Před vytvořením souboru se vždy zkontroluje aktuální GitHub repository, tento dokument a související zdroje pravdy.

---

# 11. Doporučené identifikátory

- `PP-xxx` – Product Principle
- `FR-xxx` – Functional Requirement
- `NFR-xxx` – Non-functional Requirement
- `INV-xxx` – Domain Invariant
- `SCN-xxx` – User Scenario
- `FLOW-xxx` – UX Flow
- `SCR-xxx` – Screen
- `ADR-xxx` – Architecture Decision Record
- `AC-xxx` – Acceptance Criterion
- `EVT-xxx` – Integration event contract, pokud bude potřebný katalogový identifikátor

ID se nesmí recyklovat pro jiný význam.

---

# 12. Rizika a povinná opatření

## Duplicity

**Riziko:** Stejná pravidla existují ve více dlouhých dokumentech.

**Opatření:** glossary, ID, vlastníci a cross-references.

## Délka dokumentů

**Riziko:** Obtížné review a načítání do AI kontextu.

**Opatření:** indexy a oddělení pouze skutečných kontraktů; ne mechanické štěpení.

## Vše ve stavu Draft

**Riziko:** Není jasné, co je rozhodnutí.

**Opatření:** po tematických fázích review na `APPROVED` nebo `IMPLEMENTATION_READY`.

## Otevřené otázky

**Riziko:** Rozptýlené decision backlogy.

**Opatření:** po glossary vytvořit pouze v případě potřeby `docs/OPEN_DECISIONS.md` a převádět rozhodnutí do ADR.

## Integrace

**Riziko:** Doménová možnost neznamená dostupné provider API.

**Opatření:** capability audit a oficiální provider dokumentace.

## Medicína a právo

**Riziko:** Pain, health data, souhlasy a minors vyžadují odborné potvrzení.

**Opatření:** explicitní `EXPERT_REVIEW_REQUIRED` a zákaz označit oblast za implementation-ready bez review.

---

# 13. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Vision | vysoká | nevztahuje se přímo | konzistenční review |
| Product principles | vysoká | střední | přidat ID principů |
| Product scope | vysoká | nízká | FR a NFR |
| Users | vysoká | střední | ID a traceability |
| UX | vysoká | střední | states, routes, acceptance criteria |
| Design system | nízká | nízká | hlavní design-system dokument |
| Domain models | velmi vysoká | střední | glossary a consistency review |
| Domain invariants | vysoká | střední | odborné review a test mapping |
| Backend | nízká | nízká | backend architecture |
| Mobile | nízká | nízká | mobile architecture |
| AI runtime | střední doménově | nízká | AI architecture a tools |
| Integrations | střední obecně | nízká | capability matrix a provider specs |
| Security | nízká až střední | nízká | security architecture a threat model |
| Data | nízká | nízká | data architecture |
| API | nízká | nízká | API principles a contracts |
| Quality | nízká | nízká | quality strategy |
| DevOps | nízká | nízká | environments a deployment architecture |
| Release | nízká | nízká | release strategy |
| Operations | nízká | nízká | SLO a runbooks |
| Claude implementation guide | nízká | nízká | až po architekturách a kontraktech |

---

# 14. Odhad rozsahu

Audit nepotvrzuje potřebu 350–400 ručně psaných dokumentů.

Realistický cíl je přibližně:

- 60–100 hlavních dokumentů,
- plus ADR,
- provider-specific kontrakty,
- strojová schémata,
- runbooky a checklisty podle skutečné potřeby.

Cílem není konkrétní počet. Dokumentace je úplná, když lze každé důležité rozhodnutí najít, implementovat, otestovat, provozovat a bezpečně změnit.

---

# 15. Závěr

Doménová vrstva nyní obsahuje jak detailní modely, tak společný registr globálních invariant. Další hodnotu přinese stabilizace názvosloví v `glossary.md`, nikoli další obecný doménový model.

Pracovní cyklus zůstává:

```text
zkontrolovat aktuální GitHub
    ↓
vybrat skutečnou mezeru podle auditu
    ↓
porovnat související zdroje pravdy
    ↓
vytvořit nebo upravit dokument
    ↓
commitnout změnu
    ↓
aktualizovat DOCUMENTATION_STATUS.md
    ↓
pokračovat dalším potvrzeným krokem
```
