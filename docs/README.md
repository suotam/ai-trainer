# AI Trainer – Documentation Map

**Verze:** 1.2  
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

`release-scope.md` vlastní skutečnou implementační baseline R0 až R5, priority P0 až P3, exit criteria a pravidla `RSR-001` až `RSR-015`.

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

Detailní model vlastní význam svých agregátů, entit, stavů a pravidel. `domain-invariants.md` vlastní globální invariance; `glossary.md` kanonické názvosloví a `domain-events.md` význam doménových událostí.

## 3.4 Architecture

```text
docs/07-backend/backend-architecture.md
docs/12-data/data-architecture.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/11-security/security-architecture.md
docs/10-integrations/integration-architecture.md
```

Architektonické řady pravidel jsou `BAR`, `DAR`, `MAR`, `AIR`, `SAR` a `IAR`.

## 3.5 Delivery

```text
docs/13-delivery/repository-strategy.md
```

`repository-strategy.md` vlastní monorepo layout, hranice mobile/backend/contracts, migrations ownership, test placement, tooling, generated-code policy a pravidla `RER-001` až `RER-015`.

---

# 4. Implementační baseline

První programování se řídí `release-scope.md`.

Startovní slices jsou:

```text
R0 – Technical Foundation
R1 – Local Workout Slice
```

R0 a R1 nesmí blokovat účet, cloudový sync, generativní AI, wearables ani externí kalendáře.

Startovní implementační minimum:

1. ✅ release scope,
2. ✅ repository strategy a projektová struktura,
3. ⏭️ počáteční ADR balík,
4. minimální fyzický datový model R1,
5. minimální API contract,
6. test strategy,
7. Definition of Ready a Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Detailní kontrakty pro R2 až R5 vznikají nejpozději před implementací slice, který je používá.

---

# 5. Repository baseline

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
- testy mají jednoznačné ownership,
- R1 je lokální a nevyžaduje backend,
- secrets a skutečná uživatelská data nepatří do repozitáře.

Detail vlastní `docs/13-delivery/repository-strategy.md`.

---

# 6. Pravidla práce s dokumentací

## 6.1 Jeden význam, jeden vlastník

Každý významný pojem nebo pravidlo má jeden hlavní vlastnící dokument. Ostatní dokumenty na něj odkazují a konkretizují pouze svůj kontext.

## 6.2 Nový soubor pouze pro skutečnou mezeru

Nový dokument vznikne pouze pokud téma dosud nemá zdroj pravdy, tvoří samostatný kontrakt nebo významně zlepší implementaci, audit, testování či provoz.

## 6.3 AI není zdroj pravdy

AI může interpretovat a navrhovat. Doménovou změnu provádí pouze autorizovaný a validovaný proces podle `AIProposal`, `ChangeSet`, potvrzovací policy a invariant.

## 6.4 Offline-first

Kritické workout flow musí fungovat bez sítě. R1 je záměrně lokální slice.

## 6.5 Vertical slice first

Implementace postupuje po spustitelných produktových slices. Dlouhé izolované budování technologických vrstev bez ověřitelného uživatelského flow není cílový postup.

---

# 7. Metadata a identifikátory

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
- `BAR`, `DAR`, `MAR`, `AIR`, `SAR`, `IAR`, `RSR`, `RER`,
- `SCN`, `FLOW`, `SCR`, `ADR`, `AC`, `EVT`.

ID se nerecyklují.

---

# 8. Pracovní cyklus

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

# 9. Aktuální další krok

Podle současného auditu následuje:

```text
docs/05-architecture/initial-architecture-decisions.md
```

Má obsahovat malý počáteční ADR balík pouze pro rozhodnutí blokující R0 a R1: backend, mobile state management a DI, lokální a serverovou databázi, contracts/code generation a CI/development environment.

---

# 10. Instrukce pro coding agenta

Před implementací změny musí agent:

1. načíst tento README a `DOCUMENTATION_STATUS.md`,
2. určit release slice a vlastnící doménu,
3. načíst relevantní invarianty a glossary,
4. načíst příslušný doménový model,
5. načíst FR, NFR a release scope,
6. načíst dotčené architektury, repository strategy a kontrakty,
7. ověřit ADR, acceptance criteria a Definition of Done,
8. až poté měnit kód.

Agent nesmí obcházet invariance, vytvářet paralelní repository strukturu bez rozhodnutí, sdílet interní model mezi mobilem a backendem, vložit secret do repozitáře ani označit práci za hotovou bez testů.

---

# 11. Závěr

`docs/README.md` určuje orientaci, `DOCUMENTATION_STATUS.md` aktuální stav, `release-scope.md` implementační baseline, `repository-strategy.md` fyzické hranice repozitáře a každý vlastnící dokument přesný význam své oblasti.