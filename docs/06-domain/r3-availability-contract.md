# AI Trainer – R3 Availability, Equipment and Constraints Contract (C19)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-availability-contract.md`
**Vlastník:** Domain (scheduling-model + recovery-and-limitations-model) + Mobile
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C19 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/scheduling-model.md` (§3.1), `docs/06-domain/recovery-and-limitaitons-model.md`, `docs/06-domain/r3-sports-profile-contract.md` (C17), `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** implementace R3-03, C20 (ruční plán čte dostupnost jako kontext), R4 kontrakty (AI čte dostupnost/vybavení/omezení)
**Vlastněné pojmy nebo kontrakty:** závazná P0 podmnožina dostupnosti a tréninkového kontextu pro R3 — typický týden (`AvailabilityRule` P0), vybavení (`EquipmentItem`), základní omezení (`BasicConstraint`) a pravidla `AVC-001` až `AVC-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

R3-03 dává uživateli možnost strukturovaně deklarovat **kdy může trénovat** (typický týden), **s čím** (vybavení/prostředí) a **co ho omezuje** (základní omezení). Jsou to vstupy ručního plánování (R3-04) a budoucího AI plánování (R4). Scheduling model definuje plný cílový tvar (`AvailabilityRule`, `AvailabilityException`, `RecurrenceSeries`); recovery model plný tvar omezení. Tento dokument vybírá **závaznou P0 podmnožinu** — deklarace bez vynucování a bez interpretace.

## 1.2 Owner a vztah ke zdrojům

**Domain (scheduling-model + recovery-and-limitations-model) + Mobile.** Plné modely vlastní příslušné dokumenty; C19 z nich vybírá P0. Rozpor se řeší úpravou C19.

## 1.3 Které slices blokuje

**Blocking pro `R3-03`** (spolu s C16 rozšířením o tabulky). Dostupnost jako informativní kontext čte C20/R3-04; vynucení dostupnosti proti plánu je otevřené R4 rozhodnutí (plán §12).

---

# 2. Scope

## 2.1 Co C19 řeší

- typický týden (§4), vybavení (§5), základní omezení (§6),
- stabilní kódy (§7), ownership/sync/attach vč. kolizních pravidel (§8),
- invarianty `AVC-001..015` (§9), testy (§10), Ready podmínku (§11).

## 2.2 Co C19 výslovně neřeší (non-goals R3)

- `AvailabilityException` (dočasné odchylky) a `RecurrenceSeries` (opakované události),
- konkrétní časová okna (od–do) — P0 pracuje s úrovní dostupnosti, budgetem minut a preferovanou částí dne,
- kapacitní validaci plánu proti dostupnosti (dostupnost je v R3 informativní vstup, plán §12),
- medicínskou interpretaci, diagnostiku či doporučení u omezení (recovery model odborná hranice; omezení je čistá uživatelská deklarace se safe prezentací),
- import vybavení, katalogovou správu poskytovatelů (gym chains apod.),
- AI čtení/doplňování (R4).

---

# 3. Základní principy

1. **Deklarace, ne vynucení** — R3 nic nevaliduje proti dostupnosti ani omezením; data jsou strukturovaný kontext.
2. **Pattern ≠ kalendář** (C17 ASP-006 analogicky) — typický týden není ScheduleEvent ani konkrétní termín.
3. **Bez interpretace omezení** — omezení je text + volitelné strukturované atributy; žádná diagnostika (`RSR-007`).
4. **Neúplnost je validní** — každá oblast může být prázdná; unknown ≠ zero.
5. **Offline a bez AI.**

---

# 4. Typický týden (AvailabilityRule P0)

Jedna deklarace na **den v týdnu** (`MON..SUN`) a vlastníka:

- **level** — `AVAILABLE`, `LIMITED`, `UNAVAILABLE`,
- volitelně: **budget minut** (kolik času obvykle mám), **preferovaná část dne** (`MORNING`, `AFTERNOON`, `EVENING`), **poznámka**.

Den bez deklarace = nevyjádřeno (unknown, ne `UNAVAILABLE`). Nejvýše **jedna deklarace na (vlastník, den)** — current-state editovatelná (verze +1, `SYNCED→DIRTY`); odstranění dne je dovolená operace (deklaraci lze vzít zpět — na rozdíl od faktů jde o current-state preferenci; zpětvzetí je DELETE řádku a je kryto outbox DELETE operací od C24).

# 5. Vybavení (EquipmentItem)

Položka vybavení/prostředí: **katalogový kód XOR custom název** (vzor C17 §5):

Minimální katalog (stabilní kódy): `GYM_ACCESS`, `BARBELL`, `DUMBBELLS`, `KETTLEBELL`, `RESISTANCE_BANDS`, `PULL_UP_BAR`, `BENCH`, `TREADMILL`, `STATIONARY_BIKE`, `BIKE`, `CLIMBING_WALL_ACCESS`, `POOL_ACCESS`, `YOGA_MAT`. Rozšíření katalogu je aditivní; kódy se nerecyklují.

Volitelně poznámka. **Status `ACTIVE`/`ARCHIVED`** — archivace je stavová změna (vybavení „už nemám"), ne mazání. Nejvýše jedna ne-`ARCHIVED` položka na (vlastník, katalogový kód); custom položky se rozlišují názvem.

# 6. Základní omezení (BasicConstraint)

Uživatelská deklarace omezení: **povinný title** (např. „bolavé koleno — bez hlubokých dřepů"), volitelně poznámka. **Status `ACTIVE`/`RESOLVED`** — vyřešení je stavová změna, ne mazání (historická interpretace; budoucí recovery model naváže). Bez závažnosti, body-area taxonomie a interpretace v P0. UI prezentuje omezení bezpečně (žádná doporučení).

---

# 7. Stabilní kódy

DB drží kódy; lokalizace je prezentační. Dny: `MON`,`TUE`,`WED`,`THU`,`FRI`,`SAT`,`SUN`. Level: `AVAILABLE`,`LIMITED`,`UNAVAILABLE`. Část dne: `MORNING`,`AFTERNOON`,`EVENING`. Equipment katalog dle §5. Statusy dle §5/§6.

---

# 8. Ownership, sync a attach

- Všechny tři entity jsou vlastnitelné aggregate roots (C16 §6) — born ownable and syncable, owner stamping při zápisu.
- **Attach (C15 rozšíření v tomto slice, R3M-006):**
  - **AvailabilityRule:** kolizní pravidlo (vzor C17 §8) — anonymní deklarace dne, pro který už účet deklaraci má, **zůstává anonymní** (nemaže se, nemutuje).
  - **EquipmentItem:** kolizní pravidlo — anonymní ne-`ARCHIVED` položka s katalogovým kódem, který už účet ne-`ARCHIVED` má, zůstává anonymní.
  - **BasicConstraint:** bezpodmínečný attach (žádné cross-owner unikátní invarianty).
- Push začíná s C24/R3-07 (`R3M-007`). Zpětvzetí availability deklarace (DELETE) se do registru promítne až v C24 — do té doby je čistě lokální.

---

# 9. Invarianty (`AVC`)

- **AVC-001 — Vlastnitelné roots.** Všechny tři entity mají owner/sync metadata od vzniku (C16).
- **AVC-002 — Stabilní kódy.** Dny/levely/části dne/katalog/statusy jsou stabilní kódy v DB; lokalizace prezentační.
- **AVC-003 — Jedna deklarace na den.** Nejvýše jedna availability deklarace na (vlastník, den).
- **AVC-004 — Chybějící den = unknown.** Den bez deklarace není `UNAVAILABLE`; nic se nedopočítává (`DAR-015`).
- **AVC-005 — Deklarace, ne vynucení.** R3 nevaliduje plán ani zápisy proti dostupnosti/omezením.
- **AVC-006 — Equipment bez duplicit.** Nejvýše jedna ne-`ARCHIVED` položka na (vlastník, katalogový kód); custom rozlišeny názvem.
- **AVC-007 — Archivace a vyřešení jsou stavy.** Equipment `ARCHIVED` a constraint `RESOLVED` jsou stavové změny, ne mazání.
- **AVC-008 — Zpětvzetí availability je legitimní.** Availability deklaraci lze odstranit (current-state preference); fakta se tím nemění.
- **AVC-009 — Bez interpretace.** Omezení je deklarace bez diagnostiky, závažnosti a doporučení (P0); prezentace je bezpečná.
- **AVC-010 — Anonymní parita + attach.** Attach dle §8; kolizní záznamy zůstávají anonymní, nikdy se nemažou ani nemutují.
- **AVC-011 — Editace current-state.** Úpravy zvyšují lokální verzi a přepínají `SYNCED→DIRTY`.
- **AVC-012 — Offline first.**
- **AVC-013 — Bez AI** (`RSR-005`); AI čtení je R4.
- **AVC-014 — Deterministické read modely.** Týden v pořadí `MON..SUN`; equipment a omezení řazeny status → název; poctivé empty stavy.
- **AVC-015 — Evidence.** Persistence/migrační/attach testy dle C16 §8; flaky ≠ zelený důkaz.

---

# 10. Testing requirements a evidence

1. Persistence testy nad skutečnou SQLite: upsert deklarace dne (AVC-003), zpětvzetí (AVC-008), equipment dup guard (AVC-006), archivace/vyřešení jako stav (AVC-007), řazení (AVC-014), validace kódů, restart-safe.
2. Sync-metadata testy: LOCAL_ONLY/DIRTY, owner stamping.
3. Attach testy: kolizní den a kolizní equipment zůstávají anonymní; constraint bezpodmínečně; nekolizní se připojí.
4. Migrační test v6→v7 od reálného stavu (řetěz v1→v7) + drift-check.
5. R1/R2 regression zelené.

---

# 11. Ready condition

## 11.1 Kdy je C19 Done

C19 je Done, právě když definuje P0 tři oblasti (§4–§6), kódy (§7), ownership/sync/attach vč. kolizí (§8), invarianty `AVC-001..015` (§9) a testy (§10), a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C19 je **Done**.

## 11.2 Co C19 odblokuje

Spolu s C16 (rozšíření o tři tabulky) činí **`R3-03 – Availability, Equipment and Basic Constraints` `READY`**.
