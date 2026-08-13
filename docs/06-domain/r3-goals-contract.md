# AI Trainer – R3 Goals and Priorities Contract (C18)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-goals-contract.md`
**Vlastník:** Domain (sports-and-goals-model) + Mobile
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C18 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sports-and-goals-model.md` (§18–§22), `docs/06-domain/r3-sports-profile-contract.md` (C17), `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/12-data/data-architecture.md`, `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** implementace R3-02, C19 (dostupnost), C23 (statistiky), C24 (sync extension)
**Vlastněné pojmy nebo kontrakty:** závazná P0 podmnožina cílů pro R3 — `Goal` aggregate, typy, priority, horizonty, status lifecycle, vazba na sport a pravidla `GLC-001` až `GLC-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

`sports-and-goals-model.md` popisuje plný cílový model (metriky, baseline, milníky, hierarchie, konflikty, feasibility, AI interpretace). R3-02 potřebuje **závaznou P0 podmnožinu**: co přesně je cíl v R3, jaké má stabilní kódy, lifecycle a co je výslovně mimo. Tento dokument je tou podmnožinou; vše ostatní z modelu zůstává platný budoucí směr.

## 1.2 Owner a vztah ke zdrojům

**Domain (sports-and-goals-model) + Mobile.** Plný model vlastní `sports-and-goals-model.md`; C18 z něj vybírá P0. Rozpor se řeší úpravou C18, ne tichou odchylkou. Strukturální/migrační pravidla vlastní C16; sportovní profil C17.

## 1.3 Které slices blokuje

**Blocking pro `R3-02 – Goals and Priorities`** (spolu s C16 rozšířením o tabulku cílů). Kódy a lifecycle následně konzumují C20 (plán↔cíl kontext), C23 (statistiky) a R4 kontrakty (AI čte cíle).

---

# 2. Scope

## 2.1 Co C18 řeší

- aggregate `Goal` (§4), stabilní kódy typů/priorit/horizontů/statusů (§5),
- status lifecycle a povolené přechody (§6),
- vazbu cíle na sport (§7),
- ownership, sync a attach chování (§8),
- invarianty `GLC-001..015` (§9), testy a evidence (§10), Ready podmínku (§11).

## 2.2 Co C18 výslovně neřeší (non-goals R3)

- strukturované metriky cíle (`GoalMetric`), baseline, targety s jednotkami, směr zlepšení — vyhodnocování pokroku vůči metrikám je mimo R3 P0 (statistiky R3-06 jsou completion-based),
- hierarchie a vztahy cílů (`GoalRelationship`), konflikty (`GoalConflict`), milníky, feasibility/capacity assessment, review workflow,
- stavy `DRAFT`, `REPLACED`, `EXPIRED` (návrhové/náhradové/expirační flow je mimo P0; target date je deklarace bez automatické expirace),
- event-based vazba na `SportEventType`/závody,
- AI interpretace a strukturace cílů (R4, `RSR-005/006`).

---

# 3. Základní principy

1. **Cíl není vždy jedno číslo** (model §3.3) — P0 cíl je strukturovaná deklarace (typ, priorita, horizont, volitelný popis/termín), ne povinná metrika.
2. **Všechny cíle nejsou stejně důležité** (model §3.4) — priorita je explicitní součást cíle.
3. **Priorita je deklarace, ne enforcement** — R3 nepočítá kapacitu ani konflikty; priorita řídí řazení a budoucí AI kontext.
4. **Historie se nemaže** — dokončené i opuštěné cíle zůstávají záznamem.
5. **Offline a bez AI.**

---

# 4. Goal (kontraktně)

`Goal` je vlastnitelný aggregate root (C16 §6). Obsahuje:

- **title** — povinný neprázdný uživatelský název cíle,
- **goalType** (§5.1), **priority** (§5.2), **horizon** (§5.3, default `OPEN_ENDED`),
- **status** (§5.4, nový cíl `ACTIVE`),
- volitelně: **vazba na sport** (§7), **target local date** (deklarativní termín, `YYYY-MM-DD`), **note**,
- client-generated stabilní ID, owner/sync metadata, `row_version`, časové značky.

Chybějící volitelná hodnota je prázdná/`null`, nikdy vymyšlený default (`DAR-015`).

---

# 5. Stabilní kódy

DB drží kódy; lokalizace je prezentační (GLC-002).

## 5.1 GoalType (model §19 — plná množina kódů, bez typové logiky v P0)

`PERFORMANCE`, `STRENGTH`, `ENDURANCE`, `HABIT`, `EVENT_PREPARATION`, `RETURN_TO_ACTIVITY`, `MAINTENANCE`, `QUALITATIVE`.

## 5.2 GoalPriority (model §21)

`PRIMARY`, `MAINTENANCE`, `DEFERRED`. Bez limitu počtu `PRIMARY` cílů (hierarchie/konflikty jsou mimo P0).

## 5.3 GoalHorizon (model §22)

`IMMEDIATE`, `SHORT_TERM`, `MEDIUM_TERM`, `LONG_TERM`, `OPEN_ENDED` (default).

## 5.4 GoalStatus (P0 podmnožina modelu §20)

`ACTIVE`, `PAUSED`, `COMPLETED`, `ABANDONED`.

---

# 6. Lifecycle

## 6.1 Přechody

`ACTIVE` ↔ `PAUSED`; `ACTIVE`/`PAUSED` → `COMPLETED`; `ACTIVE`/`PAUSED` → `ABANDONED`.

`COMPLETED` a `ABANDONED` jsou v P0 **terminální** (reaktivace/replacement flow je mimo P0 — nový záměr = nový cíl). Jiné přechody jsou typovaně odmítnuty.

## 6.2 Editace

Cíl je editovatelný current-state (verze +1, `SYNCED→DIRTY`) **jen v ne-terminálním stavu**; terminální cíl je immutable záznam. Mazání není P0 operace.

---

# 7. Vazba na sport

- Volitelná reference na `UserSport` **ID** (C17) — cíl může být obecný (bez sportu).
- Reference je **device-local**: zobrazení sportu se resolvuje podle ID bez owner filtru (vlastnictví cíle je nezávislé na vlastnictví sportu — relevantní po C15 attach kolizi, kdy sport může zůstat anonymní, zatímco cíl se připojí).
- UserSport se nikdy hard-nemaže (ASP-008), reference proto nemůže osiřet; `ENDED` sport vazbu nezneplatňuje (historická interpretace).

---

# 8. Ownership, sync a attach

- Goal se rodí s owner/sync metadaty; vlastníka razí zápis aktuálním lokálním vlastníkem (C16 §6.2).
- Anonymní uživatel má plnohodnotné cíle; **attach k účtu pokrývá cíle od R3-02 bezpodmínečně** (C16 `R3M-006`) — cíle nemají cross-owner unikátní invarianty, kolizní pravidlo C17 §8 se na ně nevztahuje.
- Push na server začíná až s C24/R3-07 (`R3M-007`).

---

# 9. Invarianty (`GLC`)

- **GLC-001 — Vlastnitelný root.** Goal je aggregate root s owner/sync metadaty od vzniku (C16).
- **GLC-002 — Stabilní kódy.** Typ/priorita/horizont/status jsou stabilní kódy v DB; lokalizace je prezentační; kódy se nemění ani nerecyklují.
- **GLC-003 — Povinný jen title.** Title je povinný neprázdný; vše ostatní volitelné; unknown ≠ zero (`DAR-015`).
- **GLC-004 — P0 lifecycle.** Povolené přechody dle §6.1; `COMPLETED`/`ABANDONED` jsou terminální; nevalidní přechod je typovaně odmítnut.
- **GLC-005 — Žádné mazání.** Cíl se nikdy nemaže; historie zůstává.
- **GLC-006 — Editace jen ne-terminálních.** Editace je current-state (verze +1, `SYNCED→DIRTY`); terminální cíl je immutable.
- **GLC-007 — Priorita bez enforcementu.** Priorita je deklarace pro řazení a budoucí kontext; R3 nepočítá kapacitu ani konflikty.
- **GLC-008 — Device-local sport link.** Vazba na sport je volitelná reference na UserSport ID resolvovaná bez owner filtru; vlastnictví cíle je nezávislé.
- **GLC-009 — Bez hierarchie.** Žádné vztahy, konflikty, milníky ani metriky v P0.
- **GLC-010 — Anonymní parita + bezpodmínečný attach.** Anonymní cíle jsou plnohodnotné a attachem se připojí vždy.
- **GLC-011 — Offline first.** Vytvoření, úprava i přechody fungují bez sítě.
- **GLC-012 — Bez AI.** Žádná C18 funkce nevyžaduje AI; interpretace cílů je R4.
- **GLC-013 — Deterministické read modely.** Řazení status (`ACTIVE`,`PAUSED`,`COMPLETED`,`ABANDONED`) → priorita (`PRIMARY`,`MAINTENANCE`,`DEFERRED`) → title; poctivý empty stav.
- **GLC-014 — Termín je deklarace.** Target date nevyvolává automatickou expiraci ani přechod stavu (P0).
- **GLC-015 — Evidence.** Persistence/migrační/attach/lifecycle testy dle C16 §8; flaky ≠ zelený důkaz.

---

# 10. Testing requirements a evidence

1. Persistence testy nad skutečnou SQLite: create/edit/lifecycle přechody vč. terminálních guardů, restart-safe, deterministické řazení, validace (prázdný title, neznámé kódy, nevalidní datum, neexistující sport link).
2. Sync-metadata testy: `LOCAL_ONLY` při vzniku, `DIRTY` po editaci pod účtem, owner stamping.
3. Attach test: anonymní cíle se připojí bezpodmínečně; cíl s vazbou na kolizí-anonymní sport se připojí a vazba zůstává čitelná.
4. Migrační test vN→vN+1 od reálného stavu (C16 §8.1) + drift-check.
5. R1/R2 regression zelené.

---

# 11. Ready condition

## 11.1 Kdy je C18 Done

C18 je Done, právě když definuje P0 aggregate (§4), stabilní kódy (§5), lifecycle (§6), sport link (§7), ownership/sync/attach (§8), invarianty `GLC-001..015` (§9) a testy (§10), a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C18 je **Done**.

## 11.2 Co C18 odblokuje

Spolu s C16 (rozšíření o tabulku cílů) činí **`R3-02 – Goals and Priorities` `READY`**.
