# AI Trainer – R3 Manual Training Plan and Internal Calendar Contract (C20)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-manual-plan-contract.md`
**Vlastník:** Domain (training-plan-model + scheduling-model) + Mobile
**Poslední aktualizace:** 2026-08-13
**Kontraktní ID:** C20 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/training-plan-model.md`, `docs/06-domain/scheduling-model.md`, `docs/06-domain/workout-model.md`, `docs/12-data/r1-physical-data-model.md`, `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/06-domain/r3-availability-contract.md` (C19), `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** implementace R3-04, C21 (kalendářní operace), C24 (sync extension), R4 kontrakty (AI navrhuje nad ručním plánem)
**Vlastněné pojmy nebo kontrakty:** závazná P0 podmnožina ručního plánování — `TrainingPlan` aggregate, ručně vytvořená workout instance (`USER_PLAN`), vztah plán→instance, interní kalendář jako existující R1 read modely, koexistence se seedem a pravidla `MPC-001` až `MPC-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

R3-04 je jádro hodnoty R3: uživatel poprvé **ručně vytvoří vlastní tréninkový plán**, jehož workouty se objeví v Today/kalendáři a jsou proveditelné celým existujícím R1 flow (start → zápis → dokončení → historie). `training-plan-model.md` popisuje plný cílový tvar (bloky, týdny, verze, adaptace); tento dokument vybírá **závaznou P0 podmnožinu** postavenou na klíčovém rozhodnutí: **ručně plánovaný workout JE existující `WorkoutInstance`** (R1 fyzický model) — žádná paralelní struktura, žádná konverze.

## 1.2 Owner a vztah ke zdrojům

**Domain (training-plan-model + scheduling-model) + Mobile.** Plné modely vlastní příslušné dokumenty; C20 z nich vybírá P0. R1 fyzický model instancí/sekcí/kroků/setů zůstává beze změny autoritativní (`PDR-*`).

## 1.3 Které slices blokuje

**Blocking pro `R3-04`** (spolu s C16 rozšířením o tabulku plánu a rozšířením C15 §4). Kalendářní operace nad instancemi vlastní **C21** (R3-05); C20 pokrývá pouze vytvoření.

---

# 2. Scope

## 2.1 Co C20 řeší

- `TrainingPlan` aggregate a lifecycle (§4),
- ručně vytvořenou workout instanci a její strukturu (§5),
- interní kalendář a koexistenci se seedem (§6),
- ownership, sync, attach vč. rozšíření C15 klasifikace (§7),
- invarianty `MPC-001..015` (§8), testy (§9), Ready podmínku (§10).

## 2.2 Co C20 výslovně neřeší (non-goals R3)

- bloky, týdny, fáze a verze plánu s diffem, adaptace plánu, `PlanGoalLink` nad rámec kontextu,
- **přesun/zrušení/nahrazení** plánovaného workoutu — vlastní **C21** (R3-05),
- editaci existující plánované instance (C21),
- opakované události (`RecurrenceSeries`), kapacitní validaci proti dostupnosti (C19 — dostupnost je informativní),
- šablony workoutů, knihovnu cviků, kopírování workoutů,
- AI generování (R4).

---

# 3. Základní principy

1. **Ručně plánovaný workout = WorkoutInstance.** Žádná nová paralelní entita; Today, detail, tracker, completion, historie i sync fungují beze změny.
2. **Plán je záměr, instance je konkrétní workout** (training-plan model §2, terminologie §8 R3 plánu).
3. **Seed koexistuje** — demo data zůstávají oddělená (source `DEMO`, anonymní, nesynchronizovaná); ruční instance mají source `USER_PLAN` a jsou uživatelská data od vzniku.
4. **R1 zůstává nedotčené** — žádná změna R1 write flows, read modelů ani fyzického modelu instancí.
5. **Offline a bez AI.**

---

# 4. TrainingPlan (kontraktně)

`TrainingPlan` je vlastnitelný aggregate root (C16 §6):

- **title** (povinný neprázdný), volitelně poznámka,
- **status**: `ACTIVE` / `ARCHIVED` — archivace je stavová změna, ne mazání; archivace **nemění ani nemaže** už vygenerované instance (plán je původ, instance žijí vlastním lifecycle),
- **nejvýše jeden `ACTIVE` plán na vlastníka** (P0) — vytvoření druhého je typovaně odmítnuto; reaktivace archivovaného kontroluje invariant znovu,
- editace title/poznámky je current-state (verze +1, `SYNCED→DIRTY`).

---

# 5. Ručně vytvořená workout instance

## 5.1 Vytvoření

Přidání workoutu do plánu vytvoří v jedné transakci plnohodnotnou R1 strukturu:

- **`local_workout_instances`** řádek: title, workout type (§5.2), `scheduled_local_date`, volitelný plánovaný čas trvání a popis; `status = READY` (proveditelný R1 flow), `source_type = USER_PLAN` (nový stabilní kód), `source_reference = <plan id>`, `revision_number = 1`, owner = aktuální lokální vlastník, `sync_state = LOCAL_ONLY`,
- **jedna MAIN sekce** + **exercise kroky** dle zadání uživatele (název cviku, počet setů, plánovaná opakování, volitelná váha) — každý krok `SET_REP` s vygenerovanými set plans; kroky i sety mají deterministické pozice,
- workout bez cviků je dovolen (deklarace záměru; tracker ho zobrazí prázdný a completion funguje).

## 5.2 Workout type (P0 kódy)

`STRENGTH`, `ENDURANCE`, `MOBILITY`, `TECHNIQUE`, `GENERAL`. Stabilní kódy; R1 fyzický model typ nevynucuje množinou — tato množina je kanonická pro ruční vytváření.

## 5.3 Sync poznámka

Instance se synchronizuje existujícím R2-05 push mechanismem (typ `WORKOUT_INSTANCE` je v registru). **Struktura snapshotu (sekce/kroky/sety) v R2 registru není** — shodné s dosavadním chováním; zda a jak se synchronizuje, rozhodne **C24** (otevřené rozhodnutí, eviduje se). Tabulka plánu se do registru přidá v C24.

---

# 6. Interní kalendář a koexistence

- **Interní kalendář = existující R1 read modely** (Today, workoutsForLocalDate, detail). Ruční instance se v nich objevují automaticky — read modely nejsou owner-filtrované (stejně jako seed) a filtrace podle vlastníka není P0 změna.
- Editor plánu má vlastní read model: workouty plánu seřazené podle data (deterministicky, MPC-013).
- Seed (source `DEMO`) a ruční instance (source `USER_PLAN`) koexistují bez interakce.

---

# 7. Ownership, sync a attach

- Plán i instance razí vlastníka při zápisu (C16 §6.2).
- **Rozšíření C15 §4 (v témže slice):** ručně vytvořená instance (`source_type = USER_PLAN`) je **uživatelská data od vzniku** — attach ji připojuje **i bez session** (dosavadní kritérium „má session/started_session_id" zůstává pro ostatní instance). Připojují se i její strukturální children transitivně (jsou bez owner sloupce, vlastněny přes instanci).
- **TrainingPlan attach kolize:** anonymní `ACTIVE` plán, pokud účet už `ACTIVE` plán má, **zůstává anonymní** (vzor C17 §8); jeho instance se přesto připojí (jsou uživatelská data; reference na plán je device-local, vzor GLC-008). Archivované plány se připojují vždy.

---

# 8. Invarianty (`MPC`)

- **MPC-001 — Instance je WorkoutInstance.** Ruční plánování nevytváří paralelní strukturu; používá R1 fyzický model beze změny.
- **MPC-002 — Jeden ACTIVE plán.** Nejvýše jeden `ACTIVE` TrainingPlan na vlastníka; konflikt je typovaný.
- **MPC-003 — Archivace je stav.** Plán se nikdy nemaže; archivace nemění vygenerované instance.
- **MPC-004 — Atomické vytvoření.** Instance + sekce + kroky + sety vznikají v jedné transakci; selhání = žádný částečný stav.
- **MPC-005 — USER_PLAN source.** Ruční instance má `source_type = USER_PLAN` a `source_reference = plan id`; kódy jsou stabilní.
- **MPC-006 — Proveditelnost R1 flow.** Ruční instance projde beze změny existujícím start → tracker → completion → historie flow.
- **MPC-007 — R1 beze změny.** Žádná změna R1 write flows, read modelů ani `PDR` invariantů.
- **MPC-008 — Seed koexistence.** Seed zůstává oddělený (DEMO, anonymní, nesynchronizovaný); ruční data ho nemění.
- **MPC-009 — Uživatelská data od vzniku.** USER_PLAN instance se attachem připojuje i bez session (rozšíření C15 §4).
- **MPC-010 — Plán attach kolize.** Anonymní ACTIVE plán při kolizi zůstává anonymní; jeho instance se připojí (device-local reference).
- **MPC-011 — Deklarativní vstupy.** Datum je `YYYY-MM-DD`; počty setů/opakování ≥ 1; váha volitelná (unknown ≠ zero); prázdný workout dovolen.
- **MPC-012 — Editace plánu current-state.** Title/poznámka plánu: verze +1, `SYNCED→DIRTY`; operace nad instancemi vlastní C21.
- **MPC-013 — Deterministické read modely.** Workouty plánu řazeny podle data, pak title; poctivý empty stav.
- **MPC-014 — Offline a bez AI.**
- **MPC-015 — Evidence.** Persistence/migrační/attach/R1-integrace testy dle C16 §8; flaky ≠ zelený důkaz.

---

# 9. Testing requirements a evidence

1. Persistence testy: create/conflict/archive/reactivate/rename plánu; atomická struktura instance (sekce/kroky/sety, pozice, owner stamping, `READY`/`USER_PLAN`/`LOCAL_ONLY`); validace vstupů.
2. **R1 integrační důkaz (klíčový):** ručně vytvořený workout je vidět v `workoutsForLocalDate` (Today read model) a projde celým R1 flow — start session, tracker init, zápis výkonu, completion, historie.
3. Attach testy: netknutá anonymní USER_PLAN instance se připojí; kolizní ACTIVE plán zůstává anonymní, jeho instance se připojí; seed nadále anonymní.
4. Migrační test vN→vN+1 od reálného stavu (řetěz v1→v8) + drift-check.
5. R1/R2 regression zelené.

---

# 10. Ready condition

## 10.1 Kdy je C20 Done

C20 je Done, právě když definuje TrainingPlan (§4), ruční instanci (§5), kalendář/koexistenci (§6), ownership/attach rozšíření (§7), invarianty `MPC-001..015` (§8) a testy (§9), a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C20 je **Done**.

## 10.2 Co C20 odblokuje

Spolu s C16 (tabulka plánu) a rozšířením C15 §4 činí **`R3-04 – Manual Training Plan and Internal Calendar` `READY`**.
