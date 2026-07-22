# AI Trainer – Coding Agent Guide

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/15-coding-agent/coding-agent-guide.md`  
**Vlastník:** Delivery Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/README.md`, `docs/DOCUMENTATION_STATUS.md`, `docs/02-product/release-scope.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/13-delivery/repository-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`, `docs/13-delivery/r0-r1-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** issue templates, pull-request template, repository automation, CI workflows a implementační evidence  
**Vlastněné pojmy nebo kontrakty:** context-loading protocol, backlog-item selection, agent work cycle, change discipline, validation evidence, commit discipline a pravidla `CAG-001` až `CAG-015`

---

# 1. Účel

Tento dokument určuje, jak má coding agent pracovat v repozitáři AI Trainer tak, aby:

- nezačínal z neaktuálního nebo neúplného kontextu,
- neobcházel zdroje pravdy,
- nevytvářel duplicitní architekturu, kontrakty nebo dokumentaci,
- implementoval pouze `Ready` backlog item,
- respektoval pořadí R0/R1 vertical slices,
- dodával ověřitelnou změnu s testy a evidencí,
- nikdy netvrdil, že změna nebo commit existuje, pokud skutečně nevznikl.

Tento dokument neopakuje detailní produktový scope, architektury, test strategy ani Definition of Done. Určuje pracovní protokol, podle kterého se tyto zdroje používají.

---

# 2. Základní pravidlo

Agent nesmí začít úpravou kódu pouze z uživatelského zadání nebo názvu issue.

Před každou změnou musí:

1. načíst aktuální stav cílového branch,
2. přečíst `docs/README.md`,
3. přečíst `docs/DOCUMENTATION_STATUS.md`,
4. určit backlog item a release slice,
5. ověřit jeho `Ready` stav,
6. načíst vlastnící dokumenty dotčeného chování,
7. ověřit, že plánovaná změna není duplicitní,
8. až potom upravovat kód nebo dokumentaci.

---

# 3. Povinný context-loading protocol

## 3.1 Vždy načítané dokumenty

Pro každou implementační změnu se načtou minimálně:

```text
docs/README.md
docs/DOCUMENTATION_STATUS.md
docs/02-product/release-scope.md
docs/13-delivery/definition-of-ready-and-done.md
docs/13-delivery/r0-r1-vertical-slice-plan.md
docs/14-quality/test-strategy.md
```

Dále se načte `repository-strategy.md` a relevantní ADR vždy, když se mění struktura, technologie, dependency, build, tooling nebo boundaries.

## 3.2 Kontext podle typu změny

### Mobile

Načíst minimálně:

- `docs/08-mobile/mobile-architecture.md`,
- relevantní UX flow a screen specification,
- vlastnící doménový model,
- relevantní datový kontrakt,
- příslušná ADR.

### Backend

Načíst minimálně:

- `docs/07-backend/backend-architecture.md`,
- relevantní API contract,
- vlastnící doménový model a invariance,
- data architecture,
- security architecture podle dopadu.

### Data nebo migrace

Načíst minimálně:

- `docs/12-data/data-architecture.md`,
- vlastnící fyzický datový model,
- doménový model a invariance,
- migration a recovery části test strategy.

### API nebo contracts

Načíst minimálně:

- vlastnící API contract,
- backend architecture,
- security architecture,
- compatibility a contract-test pravidla.

### AI, security nebo integrations

Načíst příslušnou architekturu a odborné zdroje pravdy. Tyto oblasti nesmí být zavedeny do R0/R1 pouze „do zásoby“.

## 3.3 Context manifest

Před implementací má agent interně nebo v pracovním záznamu vytvořit krátký manifest:

```text
Backlog item:
Release slice:
Vlastnící oblast:
Načtené zdroje pravdy:
Acceptance criteria:
Relevantní invariance:
Relevantní test levels:
Non-goals:
Otevřená rozhodnutí:
```

Pokud je v `Otevřená rozhodnutí` blokující položka, implementace nezačne. Nejprve se upraví správný zdroj pravdy nebo ADR.

---

# 4. Výběr backlog itemu

Agent vybírá práci podle kanonického pořadí v `r0-r1-vertical-slice-plan.md`.

Výchozí další implementační položka po dokončení tohoto dokumentačního balíku je:

```text
R0-01 – Repository Skeleton
```

Agent nesmí přeskočit blokující dependency pouze proto, že pozdější úkol vypadá jednodušeji.

Paralelní práce je možná pouze tam, kde ji vertical-slice plan dovoluje a kde nevzniknou konkurenční změny stejného kontraktu nebo souboru.

---

# 5. Ready kontrola

Před první změnou musí agent ověřit minimálně:

- backlog item má jednoznačný výsledek,
- je určen release slice a vlastník,
- scope a non-goals jsou explicitní,
- acceptance criteria jsou pozorovatelná,
- všechny blokující kontrakty existují,
- dependencies jsou známé,
- test approach je známý,
- změna nevyžaduje skryté technologické nebo doménové rozhodnutí,
- nejsou zaváděny schopnosti pozdějších releases.

Pokud podmínky nejsou splněné, agent nesmí improvizovat zásadní rozhodnutí v implementaci.

---

# 6. Pracovní cyklus

## 6.1 Před změnou

1. načíst aktuální branch a relevantní soubory,
2. zkontrolovat existující implementaci a historii souvisejících změn,
3. určit nejmenší smysluplný scope,
4. určit soubory, kontrakty a testy, které budou změněny,
5. ověřit Ready stav.

## 6.2 Během změny

Agent musí:

- respektovat dependency direction,
- nevkládat business pravidla do transportu nebo persistence DTO,
- nevytvářet paralelní repository strukturu,
- nepřidávat abstrakce bez současné potřeby,
- zachovat offline-first pravidla R1,
- zachovat bezpečné logování,
- přidávat testy současně s chováním,
- udržovat změnu reviewovatelnou.

## 6.3 Po změně

Agent musí:

1. zkontrolovat diff a odstranit nesouvisející změny,
2. spustit relevantní format, static checks a testy,
3. spustit contract, migration, recovery nebo architecture testy podle dopadu,
4. zkontrolovat generated-code drift,
5. ověřit absenci secrets a citlivých dat,
6. aktualizovat dokumentaci a evidence,
7. teprve potom commitnout.

---

# 7. Zásady implementace

## 7.1 Nejmenší potřebná architektura

Agent nesmí vytvářet moduly, porty, providery, databázové tabulky ani API endpointy pro budoucí scope bez konkrétního aktuálního use case.

## 7.2 Jeden význam, jeden vlastník

Nový pojem nebo pravidlo se nepřidává do náhodného dokumentu nebo kódu. Nejprve se určí vlastnící dokument a doménová oblast.

## 7.3 Contracts nejsou interní doména

OpenAPI, persistence DTO, generated klienti a frameworkové modely nesmí být sdíleným interním doménovým modelem mezi mobilem a backendem.

## 7.4 Data a migrace

Schema změna musí mít:

- explicitní migraci,
- migration test,
- recovery nebo rollback úvahu podle rizika,
- aktualizovaný fyzický datový kontrakt, pokud se mění jeho význam.

## 7.5 Offline a restart

U R1 se změna dotýkající aktivní session považuje za neúplnou, pokud neověřuje chování po restartu a zachování potvrzených dat.

---

# 8. Testovací povinnosti

Agent vybírá nejnižší smysluplnou testovací úroveň podle `test-strategy.md`.

Minimálně platí:

- čisté pravidlo → unit test,
- Flutter UI chování → widget test,
- Drift repository nebo transakce → skutečný SQLite integration test,
- Spring a PostgreSQL chování → Spring/Testcontainers integration test,
- OpenAPI změna → contract test,
- schema změna → migration test,
- kritický uživatelský tok → omezený integration nebo end-to-end důkaz.

Agent nesmí:

- označit změnu za ověřenou bez spuštění relevantních testů,
- skrýt failing test vypnutím bez schválené quarantine policy,
- nahrazovat PostgreSQL in-memory databází tam, kde je PostgreSQL součástí rizika,
- tvrdit, že CI prošlo, pokud výsledek nebyl skutečně ověřen.

---

# 9. Dokumentační aktualizace

Dokumentace se aktualizuje, pokud změna mění:

- produktový scope nebo acceptance criteria,
- doménový význam nebo invarianci,
- architekturu nebo ADR,
- API, event, sync nebo datový kontrakt,
- repository strukturu,
- testovací nebo delivery pravidlo,
- implementační pořadí nebo dependency.

Běžný refaktoring bez změny kontraktu nemá vytvářet zbytečnou dokumentační změnu.

`DOCUMENTATION_STATUS.md` se aktualizuje při dokončení potvrzeného dokumentačního kroku nebo významné změně připravenosti oblasti.

---

# 10. Commit discipline

## 10.1 Před commitem

Musí být známé:

- skutečně změněné soubory,
- spuštěné testy a jejich výsledek,
- neprovedené kontroly a důvod,
- dokumentační dopad,
- případná známá omezení.

## 10.2 Commit obsah

Commit má:

- jeden hlavní účel,
- popisný imperativní message,
- žádné secrets, lokální IDE soubory ani build artefakty,
- pouze související změny.

## 10.3 Pravdivost

Agent smí uvést SHA pouze z odpovědi GitHubu nebo lokálního Git výstupu.

Pokud commit selže, agent musí říct, že selhal. Nesmí použít formulace, které naznačují dokončený commit.

---

# 11. Povinný formát evidence

Po dokončení změny agent uvede minimálně:

```text
Backlog item:
Release slice:
Výsledek:
Změněné oblasti:
Acceptance criteria:
Spuštěné kontroly:
Výsledek kontrol:
Neprovedené kontroly:
Dokumentace:
Commit SHA:
Známá omezení:
Další kanonický krok:
```

Prázdná položka se nevynechává, pokud je relevantní. Například u neprovedeného iOS buildu se uvede konkrétní důvod místo tvrzení, že je vše zelené.

---

# 12. Zakázané chování

Agent nesmí:

- pracovat ze starého snapshotu bez načtení aktuálního repozitáře,
- přeskočit `DOCUMENTATION_STATUS.md`,
- vytvořit duplicitu existujícího kontraktu,
- upravit více nesouvisejících slices v jednom kroku,
- přidat R2–R5 scope do R0/R1 bez změny release rozhodnutí,
- obejít doménovou invarianci kvůli jednodušší implementaci,
- ručně opravovat generated output bez opravy zdroje,
- commitnout secret nebo skutečná uživatelská data,
- tvrdit, že test, build, CI nebo commit proběhl bez důkazu,
- označit práci jako Done při známém blocker nebo critical defectu.

---

# 13. Postup při rozporu dokumentů

Pokud agent najde rozpor:

1. použije hierarchii zdrojů pravdy z `docs/README.md`,
2. nevybere si libovolně pohodlnější variantu,
3. zastaví dotčenou část implementace,
4. popíše konkrétní rozpor,
5. navrhne změnu vlastnického dokumentu nebo ADR,
6. po commitnutí rozhodnutí znovu načte aktuální stav.

---

# 14. Start implementace

Po dokončení a commitnutí tohoto dokumentu je startovní dokumentační minimum pro R0/R1 kompletní.

První implementační položka je:

```text
R0-01 – Repository Skeleton
```

Před jejím zahájením se znovu načte aktuální `main` a provede Ready kontrola. Tento dokument sám není důkazem, že R0-01 již začal nebo byl dokončen.

---

# 15. Závazná pravidla

- **CAG-001:** Agent před každou změnou načte aktuální stav cílového branch.
- **CAG-002:** Agent vždy načte `docs/README.md` a `docs/DOCUMENTATION_STATUS.md`.
- **CAG-003:** Implementace začne pouze pro identifikovaný a `Ready` backlog item.
- **CAG-004:** Agent načte vlastnící doménové, architektonické, kontraktní a testovací dokumenty podle dopadu změny.
- **CAG-005:** Blokující otevřené rozhodnutí se řeší ve zdroji pravdy nebo ADR, nikoli skrytě v kódu.
- **CAG-006:** Agent respektuje pořadí a dependencies z vertical-slice planu.
- **CAG-007:** Agent nezavádí odložený release scope pouze do zásoby.
- **CAG-008:** Každá změna má odpovídající testovací a evidenční plán.
- **CAG-009:** Schema a contract změny mají příslušné migration nebo contract testy.
- **CAG-010:** Agent aktualizuje dokumentaci pouze při skutečné změně vlastněného významu nebo kontraktu.
- **CAG-011:** Commit obsahuje jeden hlavní účel a pouze související změny.
- **CAG-012:** Agent nesmí tvrdit úspěch testu, CI, buildu nebo commitu bez skutečného důkazu.
- **CAG-013:** Po změně agent uvede strukturovanou evidence summary.
- **CAG-014:** Rozpor zdrojů pravdy se vyřeší před pokračováním dotčené implementace.
- **CAG-015:** Po dokončení startovního dokumentačního minima následuje `R0-01 – Repository Skeleton`, nikoli další obecná dokumentace bez potvrzené mezery.
