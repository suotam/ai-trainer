# AI Trainer – Documentation Map

**Verze:** 0.3  
**Stav:** Draft  
**Soubor:** `docs/README.md`  
**Poslední aktualizace:** 2026-07-21

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
6. API, event nebo datový kontrakt,
7. UX specifikace,
8. implementační doporučení,
9. příklady.

Nižší vrstva nesmí obejít vyšší.

---

# 3. Hlavní zdroje pravdy

## Vision and product

```text
docs/01-vision/vision.md
docs/01-vision/product-principles.md
docs/02-product/product-scope.md
docs/02-product/functional-requirements.md
```

- `vision.md` vlastní poslání, dlouhodobou vizi, odlišení a definici úspěchu.
- `product-principles.md` vlastní neměnné produktové zásady.
- `product-scope.md` vlastní cílový funkční rozsah a základní etapizaci.
- `functional-requirements.md` vlastní testovatelné cílové schopnosti `FR-001` až `FR-192`.

## Users and UX

```text
docs/03-users/user-personas.md
docs/03-users/user-scenarios.md
docs/04-ux/information-architecture.md
docs/04-ux/core-user-flows.md
docs/04-ux/screen-specifications.md
```

Tyto dokumenty vlastní potřeby uživatelů, scénáře, informační hierarchii, hlavní flow a funkční chování obrazovek.

## Domain

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
- `domain-invariants.md` vlastní globální a cross-domain pravidla.
- `glossary.md` vlastní kanonické názvosloví a zakázaná nejednoznačná synonyma.
- `domain-events.md` vlastní význam, obálku a katalog doménových událostí.

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

AI může interpretovat, navrhovat a vysvětlovat. Doménovou změnu však provádí pouze autorizovaný a validovaný systémový proces podle `AIProposal`, `ChangeSet`, potvrzovací policy a globálních invariant.

## 4.4 Historie se nepřepisuje

Opravy a změny musí zachovat původ, revize, audit a historickou interpretovatelnost.

## 4.5 Offline-first

Mobilní aplikace musí podporovat kritické každodenní použití i bez sítě. Detailní pravidla vlastní `sync-and-offline-model.md`.

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

# 6. Doporučená metadata

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
aktualizovat DOCUMENTATION_STATUS.md
```

---

# 8. Aktuální další krok

Podle současného auditu následuje:

```text
docs/02-product/non-functional-requirements.md
```

Poté budou následovat release scope, traceability a acceptance criteria před hlavními technickými architekturami.

Přesné pořadí se vždy řídí aktuální verzí `DOCUMENTATION_STATUS.md`.

---

# 9. Instrukce pro budoucího coding agenta

Před implementací změny musí agent:

1. načíst tento README,
2. načíst `DOCUMENTATION_STATUS.md`,
3. určit vlastnící doménu,
4. načíst `domain-invariants.md` a relevantní části `glossary.md`,
5. načíst příslušný doménový model,
6. načíst produktové požadavky, UX, API, data a security kontrakty,
7. ověřit ADR a acceptance criteria,
8. až poté měnit kód.

Agent nesmí:

- zavádět nový doménový pojem bez dokumentace,
- použít nejednoznačný technický název zakázaný glossary,
- měnit veřejný kontrakt bez aktualizace dokumentace,
- obcházet invarianty nebo bezpečnost,
- označit úkol za hotový bez testů a Definition of Done.

---

# 10. Závěr

Dokumentace se neřídí počtem souborů, ale úplností, dohledatelností a konzistencí.

Základní návaznost je:

```text
Vision
    ↓
Product scope and requirements
    ↓
User scenarios and UX
    ↓
Domain model, invariants and glossary
    ↓
Architecture and ADR
    ↓
API, data and event contracts
    ↓
Testing, delivery and operations
    ↓
Implementation plan
```

`docs/README.md` určuje orientaci, `DOCUMENTATION_STATUS.md` aktuální stav a každý vlastnící dokument přesný význam své oblasti.