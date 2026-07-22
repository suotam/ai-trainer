# AI Trainer – Documentation Map

**Verze:** 0.6  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-07-22

---

# 1. Účel

Tato složka obsahuje produktovou, UX, doménovou, technickou, bezpečnostní, testovací a provozní dokumentaci aplikace AI Trainer.

Tento soubor je stručný rozcestník. Aktuální stav, mezery a pořadí další práce jsou vedeny v:

```text
docs/DOCUMENTATION_STATUS.md
```

Před vytvořením nového dokumentu je nutné zkontrolovat skutečný stav repozitáře a audit, aby nevznikaly duplicity.

---

# 2. Hierarchie zdrojů pravdy

Pokud si dokumenty odporují, platí toto pořadí:

1. právní a bezpečnostní pravidla,
2. produktové principy,
3. globální doménové invariance,
4. detailní vlastnící doménový model,
5. schválené ADR,
6. architektonický kontrakt,
7. API, event nebo datový kontrakt,
8. UX specifikace,
9. implementační doporučení,
10. příklady.

Nižší vrstva nesmí obejít vyšší.

---

# 3. Hlavní zdroje pravdy

## 3.1 Vision and product

```text
docs/01-vision/vision.md
docs/01-vision/product-principles.md
docs/02-product/product-scope.md
docs/02-product/functional-requirements.md
docs/02-product/non-functional-requirements.md
```

- `vision.md` vlastní poslání, dlouhodobou vizi a odlišení produktu.
- `product-principles.md` vlastní neměnné produktové zásady.
- `product-scope.md` vlastní cílový rozsah a základní etapizaci.
- `functional-requirements.md` vlastní `FR-001` až `FR-192`.
- `non-functional-requirements.md` vlastní `NFR-001` až `NFR-172`.

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

- `domain-overview.md` je mapa bounded contexts a vlastnictví.
- Detailní model vlastní význam svých agregátů, entit a stavů.
- `domain-invariants.md` vlastní `INV-001` až `INV-100`.
- `glossary.md` vlastní kanonické názvosloví.
- `domain-events.md` vlastní význam a katalog doménových událostí.

## 3.4 Architecture

```text
docs/07-backend/backend-architecture.md
docs/12-data/data-architecture.md
```

- `backend-architecture.md` vlastní backendový styl, moduly, vrstvy, transakce, event processing a pravidla `BAR-001` až `BAR-015`.
- `data-architecture.md` vlastní datové vrstvy, ownership, autoritu, historii, storage, migrace, retenci, backup a pravidla `DAR-001` až `DAR-015`.

---

# 4. Pravidla práce s dokumentací

## 4.1 Jeden význam, jeden vlastník

Každý významný pojem nebo pravidlo musí mít jeden hlavní vlastnící dokument. Ostatní dokumenty na něj odkazují a konkretizují pouze svůj kontext.

## 4.2 Nový soubor pouze pro skutečnou mezeru

Nový dokument vznikne pouze pokud:

- téma dosud nemá zdroj pravdy,
- existující dokument je příliš obecný pro implementaci,
- téma má jiného vlastníka nebo životní cyklus,
- obsah tvoří samostatný kontrakt,
- rozdělení významně zlepší práci lidí nebo coding agentů,
- soubor je nutný pro audit, test, provoz nebo provider integraci.

Původní orientační seznam stovek souborů není závazný.

## 4.3 AI není zdroj pravdy

AI může interpretovat, navrhovat a vysvětlovat. Doménovou změnu provádí pouze autorizovaný a validovaný systémový proces podle `AIProposal`, `ChangeSet`, potvrzovací policy a globálních invariant.

## 4.4 Historie se nepřepisuje

Opravy a změny musí zachovat původ, revize, audit a historickou interpretovatelnost.

## 4.5 Offline-first

Mobilní aplikace musí podporovat kritické každodenní použití i bez sítě. Detailní pravidla vlastní `sync-and-offline-model.md`, měřitelné cíle NFR a datové vrstvy `data-architecture.md`.

---

# 5. Dokumentační stavy

Používané stavy:

- `OUTLINE`,
- `DRAFT`,
- `REVIEW_REQUIRED`,
- `APPROVED`,
- `IMPLEMENTATION_READY`,
- `IMPLEMENTED`,
- `NEEDS_UPDATE`,
- `SUPERSEDED`,
- `ARCHIVED`.

Současné hlavní specifikace jsou převážně `Draft`. Stav auditu je veden odděleně v `DOCUMENTATION_STATUS.md`.

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

Doporučené identifikátory:

- `PP-xxx` – Product Principle,
- `FR-xxx` – Functional Requirement,
- `NFR-xxx` – Non-functional Requirement,
- `INV-xxx` – Domain Invariant,
- `BAR-xxx` – Backend Architecture Rule,
- `DAR-xxx` – Data Architecture Rule,
- `SCN-xxx` – User Scenario,
- `FLOW-xxx` – UX Flow,
- `SCR-xxx` – Screen,
- `ADR-xxx` – Architecture Decision Record,
- `AC-xxx` – Acceptance Criterion.

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
docs/08-mobile/mobile-architecture.md
```

Poté:

```text
docs/09-ai/ai-architecture.md
docs/11-security/security-architecture.md
docs/10-integrations/integration-architecture.md
```

Přesné pořadí se vždy řídí aktuální verzí `DOCUMENTATION_STATUS.md`.

---

# 9. Instrukce pro budoucího coding agenta

Před implementací změny musí agent:

1. načíst tento README,
2. načíst `DOCUMENTATION_STATUS.md`,
3. určit vlastnící doménu,
4. načíst `domain-invariants.md` a relevantní části `glossary.md`,
5. načíst příslušný doménový model,
6. načíst FR a NFR,
7. načíst backend, data, mobile, AI, security a integration architekturu podle dopadu,
8. načíst API, sync, event a storage kontrakty,
9. ověřit ADR a acceptance criteria,
10. až poté měnit kód.

Agent nesmí:

- zavádět nový doménový pojem bez dokumentace,
- použít nejednoznačný technický název zakázaný glossary,
- měnit veřejný kontrakt bez aktualizace dokumentace,
- obcházet invarianty nebo bezpečnost,
- ignorovat CRITICAL NFR,
- označit úkol za hotový bez testů a Definition of Done.

---

# 10. Závěr

Dokumentace se neřídí počtem souborů, ale úplností, dohledatelností a konzistencí.

```text
Vision
    ↓
Product scope, FR and NFR
    ↓
User scenarios and UX
    ↓
Domain model, invariants and glossary
    ↓
Backend and data architecture
    ↓
Mobile, AI, security and integration architecture
    ↓
API, sync, event and physical data contracts
    ↓
Testing, delivery and operations
    ↓
Implementation plan
```

`docs/README.md` určuje orientaci, `DOCUMENTATION_STATUS.md` aktuální stav a každý vlastnící dokument přesný význam své oblasti.