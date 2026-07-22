# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 0.5  
**Stav:** Draft  
**Soubor:** `docs/DOCUMENTATION_STATUS.md`  
**Auditovaný branch:** `main`  
**Poslední aktualizace:** 2026-07-22  
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
- číslované funkční požadavky `FR-001` až `FR-192`,
- číslované nefunkční požadavky `NFR-001` až `NFR-172`.

Největší zbývající mezery:

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
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | Kvalitativní a provozní požadavky `NFR-001` až `NFR-172`. |

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

# 5. Dokončený krok – nefunkční požadavky

`docs/02-product/non-functional-requirements.md` obsahuje:

- stabilní identifikátory `NFR-001` až `NFR-172`,
- dostupnost a degradovaný režim,
- spolehlivost, idempotenci a odolnost,
- offline-first a lokální použitelnost,
- synchronizaci a konzistenci,
- mobilní a backendový výkon,
- AI latenci, fallback, validaci a cost controls,
- bezpečnost,
- privacy, consent, retention a deletion,
- accessibility,
- lokalizaci, timezone a jednotky,
- battery, GPS, síť a mobilní zdroje,
- škálovatelnost a backpressure,
- observabilitu a audit,
- zálohy, RPO, RTO a disaster recovery,
- maintainability, kompatibilitu a migrace,
- quality gates a release testy,
- uživatelskou srozumitelnost a důvěru.

## 5.1 Co ještě vyžaduje review

Před `IMPLEMENTATION_READY` je nutné:

- určit referenční device, OS, síť a dataset profily,
- potvrdit číselné latency, availability, RPO a RTO cíle,
- namapovat každý CRITICAL NFR na kontrolu a test,
- provést security a privacy review,
- provést medicínské review pain a safety wordingů,
- sladit AI cíle s model selection a cost policy,
- sladit performance cíle s cloud a mobile proof-of-concept měřením,
- převést quality gates do quality a release dokumentace.

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

# 7. Bezprostředně následující fáze

Produktové a doménové základy jsou nyní dostatečně podrobné pro návrh hlavních technických architektur.

Doporučené pořadí:

1. `docs/07-backend/backend-architecture.md`
2. `docs/12-data/data-architecture.md`
3. `docs/08-mobile/mobile-architecture.md`
4. `docs/09-ai/ai-architecture.md`
5. `docs/11-security/security-architecture.md`
6. `docs/10-integrations/integration-architecture.md`

Release scope a traceability zůstávají potvrzené potřebné dokumenty, ale jejich detail je účelné dokončit společně s architekturami a acceptance strategií, aby neobsahovaly pouze odhady technické náročnosti.

---

# 8. Následující pořadí práce

## Fáze 1 – hlavní architektury

1. ⏭️ backend architecture,
2. data architecture,
3. mobile architecture,
4. AI architecture,
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
| Product scope | vysoká | střední | release scope |
| Functional requirements | vysoká | střední | traceability a acceptance criteria |
| Non-functional requirements | vysoká | střední | architecture mapping a quality gates |
| Users | vysoká | střední | ID a traceability |
| UX | vysoká | střední | states, routes, accessibility |
| Domain | velmi vysoká | střední | consistency a odborné review |
| Backend | nízká | nízká | backend architecture |
| Data | nízká | nízká | data architecture |
| Mobile | nízká | nízká | mobile architecture |
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
aktualizovat DOCUMENTATION_STATUS.md
```

Další potvrzený dokument je:

```text
docs/07-backend/backend-architecture.md
```