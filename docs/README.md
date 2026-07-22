# AI Trainer – Documentation Map

**Verze:** 1.1  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-07-22

---

# 1. Účel

Tato složka obsahuje produktovou, UX, doménovou, technickou, bezpečnostní, integrační, testovací a provozní dokumentaci aplikace AI Trainer.

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

- `vision.md` vlastní poslání, dlouhodobou vizi a odlišení.
- `product-principles.md` vlastní neměnné zásady.
- `product-scope.md` vlastní dlouhodobý rozsah a orientační etapy.
- `functional-requirements.md` vlastní `FR-001` až `FR-192`.
- `non-functional-requirements.md` vlastní `NFR-001` až `NFR-172`.
- `release-scope.md` vlastní skutečnou implementační baseline R0 až R5, priority P0 až P3, exit criteria a pravidla `RSR-001` až `RSR-015`.

## 3.2 Users and UX

```text
docs/03-users/user-personas.md
docs/03-users/user-scenarios.md
docs/04-ux/information-architecture.md
docs/04-ux/core-user-flows.md
docs/04-ux/screen-specifications.md
```

Tyto dokumenty vlastní potřeby uživatelů, scénáře, informační hierarchii, hlavní flow a funkční chování obrazovek.

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

Detailní model vlastní význam svých agregátů, entit, stavů a pravidel. `domain-invariants.md` vlastní `INV-001` až `INV-100`; `glossary.md` kanonické názvosloví a `domain-events.md` význam doménových událostí.

## 3.4 Architecture

```text
docs/07-backend/backend-architecture.md
docs/12-data/data-architecture.md
docs/08-mobile/mobile-architecture.md
docs/09-ai/ai-architecture.md
docs/11-security/security-architecture.md
docs/10-integrations/integration-architecture.md
```

- backend vlastní `BAR-001` až `BAR-015`,
- data vlastní `DAR-001` až `DAR-015`,
- mobile vlastní `MAR-001` až `MAR-015`,
- AI vlastní `AIR-001` až `AIR-015`,
- security vlastní `SAR-001` až `SAR-015`,
- integrations vlastní `IAR-001` až `IAR-015`.

---

# 4. Implementační baseline

První programování se řídí `release-scope.md`.

Startovní slices jsou:

```text
R0 – Technical Foundation
R1 – Local Workout Slice
```

R0 a R1 nesmí blokovat účet, cloudový sync, generativní AI, wearables ani externí kalendáře.

Před zahájením programování je potřeba dokončit pouze startovní implementační minimum:

1. release scope,
2. repository strategy a projektovou strukturu,
3. počáteční ADR balík,
4. minimální fyzický datový model R1,
5. minimální API contract,
6. test strategy,
7. Definition of Ready a Done,
8. vertical-slice implementation plan,
9. coding-agent instructions a context-loading guide.

Detailní kontrakty pro R2 až R5 vznikají nejpozději před implementací slice, který je používá.

---

# 5. Pravidla práce s dokumentací

## 5.1 Jeden význam, jeden vlastník

Každý významný pojem nebo pravidlo má jeden hlavní vlastnící dokument. Ostatní dokumenty na něj odkazují a konkretizují pouze svůj kontext.

## 5.2 Nový soubor pouze pro skutečnou mezeru

Nový dokument vznikne pouze pokud:

- téma dosud nemá zdroj pravdy,
- existující dokument je příliš obecný pro implementaci,
- téma má jiného vlastníka nebo životní cyklus,
- obsah tvoří samostatný kontrakt,
- rozdělení významně zlepší práci lidí nebo coding agentů,
- soubor je nutný pro audit, test, provoz nebo provider integraci.

## 5.3 AI není zdroj pravdy

AI může interpretovat, navrhovat a vysvětlovat. Doménovou změnu provádí pouze autorizovaný a validovaný proces podle `AIProposal`, `ChangeSet`, potvrzovací policy a invariant.

## 5.4 Historie se nepřepisuje

Opravy a změny musí zachovat původ, revize, audit a historickou interpretovatelnost.

## 5.5 Offline-first

Kritické workout flow musí fungovat bez sítě. Detailní pravidla vlastní sync model, data architecture, mobile architecture, security architecture a release scope.

## 5.6 Vertical slice first

Implementace postupuje po spustitelných produktových slices. Dlouhé izolované budování technologických vrstev bez ověřitelného uživatelského flow není cílový postup.

---

# 6. Metadata a identifikátory

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

- `PP-xxx`, `FR-xxx`, `NFR-xxx`, `INV-xxx`,
- `BAR-xxx`, `DAR-xxx`, `MAR-xxx`, `AIR-xxx`, `SAR-xxx`, `IAR-xxx`, `RSR-xxx`,
- `SCN-xxx`, `FLOW-xxx`, `SCR-xxx`,
- `ADR-xxx`, `AC-xxx`, `EVT-xxx`.

ID se nerecyklují pro jiný význam.

---

# 7. Pracovní cyklus

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

# 8. Aktuální další krok

Podle současného auditu následuje:

```text
docs/13-delivery/repository-strategy.md
```

Tento dokument má konkretizovat skutečnou strukturu repozitáře, hranice mobilu, backendu, shared contracts, migrations, tests, tooling a dokumentace pro R0 a R1.

---

# 9. Instrukce pro coding agenta

Před implementací změny musí agent:

1. načíst tento README a `DOCUMENTATION_STATUS.md`,
2. určit release slice a vlastnící doménu,
3. načíst relevantní invarianty a glossary,
4. načíst příslušný doménový model,
5. načíst FR, NFR a release scope,
6. načíst dotčené architektury a kontrakty,
7. ověřit ADR, acceptance criteria a Definition of Done,
8. až poté měnit kód.

Agent nesmí:

- zavádět nový doménový pojem bez dokumentace,
- obcházet invariance, autorizaci nebo safety,
- umožnit AI přímý zápis mimo Proposal a ChangeSet flow,
- důvěřovat klientské roli nebo ownershipu bez serverového ověření,
- vložit secret do repozitáře, klienta nebo logu,
- implementovat odloženou P3 funkci bez změny release scope,
- označit úkol za hotový bez testů a Definition of Done.

---

# 10. Závěr

`docs/README.md` určuje orientaci, `DOCUMENTATION_STATUS.md` aktuální stav, `release-scope.md` skutečnou implementační baseline a každý vlastnící dokument přesný význam své oblasti.
