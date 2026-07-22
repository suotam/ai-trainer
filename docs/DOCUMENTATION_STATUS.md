# AI Trainer – Documentation Status and Gap Analysis

**Verze:** 1.2  
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
- release scope a prioritizace,
- persony a scénáře,
- informační architektura, UX flow a obrazovky,
- hlavní doménové modely, události, invariance a glossary,
- funkční požadavky `FR-001` až `FR-192`,
- nefunkční požadavky `NFR-001` až `NFR-172`,
- backendová pravidla `BAR-001` až `BAR-015`,
- datová pravidla `DAR-001` až `DAR-015`,
- mobilní pravidla `MAR-001` až `MAR-015`,
- AI pravidla `AIR-001` až `AIR-015`,
- security pravidla `SAR-001` až `SAR-015`,
- integration pravidla `IAR-001` až `IAR-015`,
- release-scope pravidla `RSR-001` až `RSR-015`.

Hlavní architektonická vrstva je obsahově pokryta. Release scope nyní potvrzuje, že programování může začít po dokončení malého implementačního minima pro R0 a R1; není nutné předem dokončit všechny budoucí provider, AI a operations kontrakty.

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
| `docs/02-product/product-scope.md` | SUBSTANTIAL_DRAFT | Dlouhodobý rozsah a orientační etapy. |
| `docs/02-product/functional-requirements.md` | SUBSTANTIAL_DRAFT | `FR-001` až `FR-192`. |
| `docs/02-product/non-functional-requirements.md` | SUBSTANTIAL_DRAFT | `NFR-001` až `NFR-172`. |
| `docs/02-product/release-scope.md` | SUBSTANTIAL_DRAFT | R0–R5, P0–P3, beta baseline, exit criteria a `RSR-001` až `RSR-015`. |

## 4.3 Users and UX

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/03-users/user-personas.md` | SUBSTANTIAL_DRAFT | Cíloví uživatelé, potřeby a bariéry. |
| `docs/03-users/user-scenarios.md` | SUBSTANTIAL_DRAFT | End-to-end a hraniční scénáře. |
| `docs/04-ux/information-architecture.md` | SUBSTANTIAL_DRAFT | Informační hierarchie. |
| `docs/04-ux/core-user-flows.md` | SUBSTANTIAL_DRAFT | Hlavní uživatelské toky. |
| `docs/04-ux/screen-specifications.md` | SUBSTANTIAL_DRAFT | Funkční specifikace obrazovek. |

## 4.4 Domain

Doménová vrstva obsahuje vlastnící modely pro identity/profile, sports/goals, training plan, workout, scheduling, activity, recovery/limitations, AI/change, metrics, integrations, sync/offline, domain events, invariants a glossary. Obsahová připravenost je vysoká; zbývá consistency a odborné review.

## 4.5 Architecture

| Soubor | Stav | Zdroj pravdy pro |
|---|---|---|
| `docs/07-backend/backend-architecture.md` | SUBSTANTIAL_DRAFT | Backendové hranice a `BAR-001` až `BAR-015`. |
| `docs/12-data/data-architecture.md` | SUBSTANTIAL_DRAFT | Datové vrstvy a `DAR-001` až `DAR-015`. |
| `docs/08-mobile/mobile-architecture.md` | SUBSTANTIAL_DRAFT | Mobilní runtime a `MAR-001` až `MAR-015`. |
| `docs/09-ai/ai-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | AI runtime a `AIR-001` až `AIR-015`. |
| `docs/11-security/security-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Security boundaries a `SAR-001` až `SAR-015`. |
| `docs/10-integrations/integration-architecture.md` | SUBSTANTIAL_DRAFT / EXPERT_REVIEW_REQUIRED | Integrace a `IAR-001` až `IAR-015`. |

---

# 5. Dokončený krok – Release scope

`docs/02-product/release-scope.md` obsahuje:

- priority P0 až P3,
- R0 Technical Foundation,
- R1 Local Workout Slice,
- R2 Account and Sync Slice,
- R3 Profile and Manual Planning Slice,
- R4 AI Plan Proposal Slice,
- R5 Adaptive Daily Trainer Beta,
- exit criteria jednotlivých startovních slices,
- explicitně odložené funkce,
- end-to-end beta scénář,
- dokumentační minimum před programováním,
- change-control pravidla,
- pravidla `RSR-001` až `RSR-015`.

## 5.1 Praktický dopad

Před zahájením R0/R1 není nutné dokončit celý seznam budoucích kontraktů. Potřebujeme přibližně 8–12 základních dokumentů nebo rozhodovacích balíků, z nichž release scope je nyní hotový. Některé položky lze sloučit do jednoho souboru, takže skutečný počet se může snížit.

## 5.2 Co vyžaduje review

Před `IMPLEMENTATION_READY` je nutné:

- namapovat konkrétní FR a CRITICAL NFR na R0 a R1,
- potvrdit počáteční technologická ADR,
- schválit přesná acceptance criteria R1,
- potvrdit platformy a referenční zařízení,
- dokončit minimální datový a API boundary kontrakt,
- potvrdit testovací a release gates,
- převést R0 a R1 na implementační backlog.

---

# 6. Duplicitní soubory, které nyní nevytvářet

| Uvažovaný soubor | Současný zdroj pravdy |
|---|---|
| `mvp-overview.md` | `release-scope.md` |
| `roadmap-overview.md` | `product-scope.md` + `release-scope.md` |
| `stage-plan.md` | `release-scope.md`; detail patří do vertical-slice planu |
| `offline-principles.md` | sync model + mobile architecture |
| `event-catalog.md` | `domain-events.md` |
| `ai-responsibilities.md` | product principles + AI/change model + AI architecture |
| `modular-monolith-strategy.md` | backend architecture |
| `data-ownership.md` | data architecture |
| `flutter-project-structure.md` | zatím mobile architecture; konkretizuje repository strategy |
| `AI-provider-overview.md` | AI architecture; konkrétní volba patří do ADR |
| `authentication-overview.md` | security architecture; konkrétní volba patří do ADR |
| `integration-principles.md` | integration model + integration architecture |

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
2. ⏭️ repository strategy a projektová struktura,
3. počáteční ADR balík,
4. minimální fyzický datový model R1,
5. minimální API contract,
6. test strategy,
7. Definition of Ready a Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Po tomto balíku lze začít programovat R0 a R1.

## Fáze 3 – kontrakty pro pozdější slices

- sync protocol před R2,
- identity/session kontrakty před R2,
- AI context, prompt, tool a structured-output schemas před R4,
- threat model a authorization matrix před chráněnými produkčními flows,
- provider capability matrix a konkrétní integrační kontrakty před první integrací,
- operations a incident dokumentace před produkčním releasem.

---

# 8. Doporučené identifikátory

- `PP-xxx` – Product Principle
- `FR-xxx` – Functional Requirement
- `NFR-xxx` – Non-functional Requirement
- `INV-xxx` – Domain Invariant
- `BAR-xxx` – Backend Architecture Rule
- `DAR-xxx` – Data Architecture Rule
- `MAR-xxx` – Mobile Architecture Rule
- `AIR-xxx` – AI Architecture Rule
- `SAR-xxx` – Security Architecture Rule
- `IAR-xxx` – Integration Architecture Rule
- `RSR-xxx` – Release Scope Rule
- `SCN-xxx` – User Scenario
- `FLOW-xxx` – UX Flow
- `SCR-xxx` – Screen
- `ADR-xxx` – Architecture Decision Record
- `AC-xxx` – Acceptance Criterion
- `EVT-xxx` – Integration event contract

ID se nesmí recyklovat.

---

# 9. Připravenost oblastí

| Oblast | Obsahová připravenost | Implementační připravenost | Hlavní další krok |
|---|---:|---:|---|
| Vision | vysoká | nevztahuje se přímo | konzistenční review |
| Product requirements | vysoká | střední až vysoká | FR/NFR mapování a AC |
| Release scope | vysoká | střední | backlog a traceability R0/R1 |
| Users and UX | vysoká | střední | states, routes a accessibility |
| Domain | velmi vysoká | střední | consistency a odborné review |
| Backend | vysoká | střední | ADR, API a architecture tests |
| Data | vysoká | nízká až střední | physical schema R1 |
| Mobile | vysoká | nízká až střední | repository strategy, local schema a platform contracts |
| AI runtime | vysoká | nízká až střední | kontrakty před R4 |
| Security | vysoká | nízká až střední | threat model a matrices před produkčními flows |
| Integrations | vysoká | nízká až střední | kontrakty až před první integrací |
| Quality | nízká | nízká | test strategy |
| DevOps | nízká | nízká | environments a CI baseline |
| Operations | nízká | nízká | před produkčním releasem |
| Coding agent | nízká | nízká | implementační instrukce po startovních kontraktech |

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
docs/13-delivery/repository-strategy.md
```
