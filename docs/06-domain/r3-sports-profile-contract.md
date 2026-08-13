# AI Trainer – R3 Structured Sports Profile Contract (C17)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-sports-profile-contract.md`
**Vlastník:** Domain (sports-and-goals-model) + Mobile
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C17 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sports-and-goals-model.md`, `docs/06-domain/identity-and-profile-model.md`, `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/12-data/data-architecture.md`, `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** implementace R3-01, C18 (cíle), C19 (dostupnost), C24 (sync extension)
**Vlastněné pojmy nebo kontrakty:** závazná P0 podmnožina sportovního profilu pro R3 — `UserSport`, participation pattern, minimální katalog sportů, custom sport, zkušenostní úroveň, role a priority sportu, lifecycle a pravidla `ASP-001` až `ASP-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

`sports-and-goals-model.md` popisuje plný cílový model sportů (capability profily, sezony, hierarchie, konflikty, AI interpretace). R3-01 potřebuje **závaznou, implementovatelnou P0 podmnožinu**: co přesně si uživatel zaznamená o svých sportech, jaké kódy jsou stabilní, jaký je lifecycle a co je výslovně mimo. Tento dokument je tou podmnožinou — vše ostatní z modelu zůstává platný budoucí směr, ale **není součástí R3**.

## 1.2 Owner a vztah ke zdrojům

**Domain (sports-and-goals-model) + Mobile.** Plný model vlastní `sports-and-goals-model.md`; C17 z něj vybírá a zpřesňuje P0 (dle jeho §11.4 „první verze"). Rozpor se řeší úpravou C17, ne tichou odchylkou. Strukturální/migrační pravidla vlastní C16; sync registr C24.

## 1.3 Které slices blokuje

**Blocking pro `R3-01 – Structured Sports Profile`** (spolu s C16). Kódy a lifecycle definované zde následně konzumují C18 (cíl↔sport), C19 (pattern vs. dostupnost) a C20 (plán↔sport).

---

# 2. Scope

## 2.1 Co C17 řeší

- aggregate `UserSport` vč. participation pattern (§4),
- minimální katalog sportů a custom sport (§5),
- stabilní kódy: role, priorita, zkušenost, intenzita, prostředí (§6),
- lifecycle a editovatelnost (§7),
- ownership, sync a attach chování (§8),
- invarianty `ASP-001..015` (§9), testy a evidence (§10), Ready podmínku (§11).

## 2.2 Co C17 výslovně neřeší (non-goals R3)

- sezony a fáze (`SportSeason`/`SportPhase`), priority by period,
- `SportCapabilityProfile`, `AnatomicalLoadProfile`, sport hierarchy/aliases/merging/specialization,
- vícedimenzionální zkušenost (`historicalExperience`/`currentCapacity`/…) — P0 má jednu hlavní úroveň + doplňky (§6.3),
- cíle (C18), dostupnost a konkrétní termíny (C19, scheduling),
- AI interpretace sportu/custom sportu (R4+, `RSR-005/006`),
- kompletní katalog sportů (obsahová práce mimo P0; katalog je rozšiřitelný).

---

# 3. Základní principy

1. **Sport uživatele není pouze název** (model §3.1) — UserSport nese vztah: roli, prioritu, zkušenost a pattern.
2. **Libovolný sportovec** (model §3.2) — custom sport je plnohodnotný first-class záznam.
3. **Neúplný profil je validní** (identity model §3.2) — žádný povinný „úplný profil"; chybějící údaj je `UNKNOWN`/prázdný, ne vymyšlený default (`DAR-015`).
4. **Current-state, ne fakta** — profil je editovatelný aktuální stav (na rozdíl od sessions/aktivit); úpravy nejsou přepis historie tréninků.
5. **Offline a bez AI** — vše funguje bez sítě a bez AI (`R3P-003/004`).

---

# 4. UserSport (kontraktně)

## 4.1 Aggregate

`UserSport` je vlastnitelný aggregate root (C16 §6). Obsahuje:

- **sport reference**: kód z minimálního katalogu (§5.1), **nebo** custom sport (§5.2),
- **role** (§6.1), **priorita** (§6.2), **zkušenostní úroveň** (§6.3),
- **participation pattern** (§4.2) — součást téhož aggregate,
- volitelně: datum poslední pravidelné aktivity, příznak návratu po pauze, poznámka,
- **status** (§7.1), client-generated stabilní ID, owner/sync metadata, časové značky.

## 4.2 Participation pattern (P0)

Souhrnný profil „jak sport obvykle provozuji" (model §12), v P0 jako součást UserSport:

- frekvence za týden (číslo, volitelné),
- typická délka v minutách (volitelné),
- typická intenzita (§6.4, volitelné),
- prostředí (§6.5, volitelné),
- pevné dny v týdnu — **informativní deklarace** (volitelné).

**Hranice (model §12.3):** konkrétní pravidelné termíny a dostupnost vlastní scheduling (C19); pattern je popis zvyku, ne kalendář a ne dostupnost.

---

# 5. Katalog sportů a custom sport

## 5.1 Minimální katalog (P0)

Stabilní kódy s kategorií (model §6); reprezentace katalogu (in-app statický seznam vs. tabulka) je implementační volba, kódy jsou kanonické:

| Kód | Kategorie |
|---|---|
| STRENGTH_TRAINING | STRENGTH |
| RUNNING | ENDURANCE |
| CYCLING | ENDURANCE |
| SWIMMING | WATER_SPORT |
| CLIMBING | CLIMBING |
| FOOTBALL | TEAM_SPORT |
| FLOORBALL | TEAM_SPORT |
| TENNIS | RACKET |
| MARTIAL_ARTS | COMBAT |
| YOGA | MIND_BODY |
| MOBILITY | MOBILITY |
| HIKING | OUTDOOR |
| ROWING | ENDURANCE |

Rozšíření katalogu je aditivní (nový kód); kódy se nikdy nemění ani nerecyklují.

## 5.2 Custom sport (P0 minimum dle modelu §13.2)

Uživatelský název (povinný), kategorie (z §6 množiny nebo `CUSTOM`), volitelně typická délka/intenzita a poznámka. Custom sport je rovnocenný katalogovému; AI doplnění profilu (model §13.4) je R4+.

---

# 6. Stabilní kódy

DB drží kódy; lokalizované texty jsou prezentační vrstva (`ASP-011`).

## 6.1 Role (model §9.3, P0 množina)

`PRIMARY`, `SECONDARY`, `SUPPORTING`, `RECREATIONAL`, `OCCASIONAL`, `SEASONAL`. (`PAUSED`/`HISTORICAL` z modelu jsou v P0 vyjádřeny **statusem** §7.1, ne rolí.)

## 6.2 Priorita (model §10)

`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, `BACKGROUND`. Priorita je oddělená od role.

## 6.3 Zkušenostní úroveň (model §11.2/§11.4)

`BEGINNER`, `NOVICE`, `INTERMEDIATE`, `ADVANCED`, `EXPERT`, `PROFESSIONAL`, `UNKNOWN` (default). Doplňky první verze: datum poslední pravidelné aktivity, příznak návratu po pauze.

## 6.4 Typická intenzita

`LOW`, `MODERATE`, `HIGH`, `VERY_HIGH`.

## 6.5 Prostředí

`INDOOR`, `OUTDOOR`, `MIXED`.

---

# 7. Lifecycle

## 7.1 Status

`ACTIVE` → `PAUSED` ↔ `ACTIVE`; `ACTIVE`/`PAUSED` → `ENDED`. `ENDED` záznam zůstává (historická interpretace); reaktivace = přechod zpět na `ACTIVE`.

## 7.2 Operace (P0)

- **create** — vytvoření vztahu ke sportu (katalog/custom),
- **edit** — úprava atributů current-state: zvýší lokální verzi, `SYNCED→DIRTY` (C2 vzor),
- **pause / resume / end** — stavové přechody; **hard delete není P0 operace** (žádné mazání záznamů).

---

# 8. Ownership, sync a attach

- UserSport se rodí s owner/sync metadaty; vlastníka razí zápis aktuálním lokálním vlastníkem (C16 §6.2).
- Anonymní uživatel má plnohodnotný profil; **attach k účtu pokrývá UserSport od R3-01** (C16 `R3M-006`, C15 rozšíření v témže slice).
- **Attach kolize (řízené pravidlo):** attach nesmí porušit ASP-003/ASP-004 účtu. Anonymní UserSport, jehož připojením by vznikl duplicitní ne-`ENDED` katalogový sport účtu nebo druhý `ACTIVE PRIMARY`, se **nepřipojí a zůstává anonymní** (deterministicky, idempotentně, bez mutace dat — výjimka z plného pokrytí C15, analogická seed exclusion LAM-006). Uživatel o data nepřichází; záznam se připojí při pozdějším attach, pokud kolize pomine.
- Push na server začíná až s C24/R3-07; do té doby sync-state poctivě eviduje `LOCAL_ONLY`/`DIRTY` (`R3M-007`).

---

# 9. Invarianty (`ASP`)

- **ASP-001 — Vlastnitelný root.** UserSport je aggregate root s owner/sync metadaty od vzniku (C16).
- **ASP-002 — Stabilní sport reference.** Katalogový kód, nebo custom sport s názvem; kódy se nemění ani nerecyklují.
- **ASP-003 — Jeden PRIMARY.** Vlastník má nejvýše jeden `ACTIVE` UserSport s rolí `PRIMARY`.
- **ASP-004 — Bez duplicit.** Nejvýše jeden ne-`ENDED` UserSport na týž katalogový kód a vlastníka; custom sporty se rozlišují názvem.
- **ASP-005 — Jedna hlavní zkušenost.** Zkušenost je jedna úroveň ze stabilní množiny (default `UNKNOWN`) + volitelné doplňky (§6.3); vícedimenzionální zkušenost je mimo P0.
- **ASP-006 — Pattern ≠ kalendář.** Participation pattern je součást UserSport a je popisný; termíny a dostupnost vlastní C19/scheduling.
- **ASP-007 — Editovatelný current-state.** Úprava zvyšuje lokální verzi a přepíná `SYNCED→DIRTY`; nikdy nemění historická tréninková fakta.
- **ASP-008 — Konec je stav, ne mazání.** `ENDED` zachovává záznam; hard delete není P0 operace.
- **ASP-009 — Anonymní parita.** Anonymní profil je plnohodnotný; attach pokrývá UserSport od R3-01. Kolizní záznamy (§8) zůstávají anonymní, nikdy se nemažou ani nemutují.
- **ASP-010 — Neúplnost je validní.** Chybějící údaj je `UNKNOWN`/prázdný, ne vymyšlený default (`DAR-015`); žádný povinný úplný profil.
- **ASP-011 — Kódy v DB, texty v prezentaci.** Perzistují se stabilní kódy; lokalizace je prezentační.
- **ASP-012 — Offline first.** Vytvoření i úprava fungují bez sítě.
- **ASP-013 — Bez AI.** Žádná C17 funkce nevyžaduje AI (`RSR-005`); AI interpretace je R4+.
- **ASP-014 — Deterministické read modely.** Přehled sportů má deterministické řazení (role, priorita, název) a poctivý empty stav.
- **ASP-015 — Evidence.** Persistence/migrační/restart/attach testy dle C16 §8; flaky ≠ zelený důkaz.

---

# 10. Testing requirements a evidence

1. Persistence testy nad skutečnou SQLite: create/edit/pause/end, restart-safe, deterministické řazení.
2. Invariantní testy: jeden PRIMARY (ASP-003), bez duplicit (ASP-004), status přechody (§7.1).
3. Sync-metadata testy: LOCAL_ONLY při vzniku, DIRTY po editaci pod účtem, owner stamping (anonymní vs. účet).
4. Attach test: anonymně vytvořený UserSport se po registraci připojí k účtu (C16 §8.4).
5. Migrační test v4→v5 od reálného v4 stavu (C16 §8.1) + drift-check.
6. R1/R2 regression zelené.

---

# 11. Ready condition

## 11.1 Kdy je C17 Done

C17 je Done, právě když definuje P0 aggregate (§4), katalog a custom sport (§5), stabilní kódy (§6), lifecycle (§7), ownership/sync/attach chování (§8), invarianty `ASP-001..015` (§9) a testovací požadavky (§10), a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C17 je **Done**.

## 11.2 Co C17 odblokuje

Spolu s C16 činí **`R3-01 – Structured Sports Profile` `READY`**. Implementace smí začít až po Ready kontrole a samostatném pokynu.
