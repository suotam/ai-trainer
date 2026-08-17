# AI Trainer – R8 Exercise Catalog Contract (C51)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r8-exercise-catalog-contract.md`  
**Vlastník:** Domain (workout-model) + Product + Mobile  
**Poslední aktualizace:** 2026-08-16  
**Kontraktní ID:** C51 (dle `docs/13-delivery/r8-vertical-slice-plan.md §7.1`)  
**Navazuje na:** `docs/06-domain/workout-model.md`, `docs/12-data/r1-physical-data-model.md` (kroky `local_workout_steps`), `docs/06-domain/r3-sports-profile-contract.md` (C17 — vzor uzavřeného katalogu), `docs/06-domain/r3-availability-contract.md` (C19 — katalog vybavení), `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/13-delivery/r8-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** implementace R8-01, C52 (plán v2 — model vybírá z katalogu), C53 (průvodce — popis provedení v kroku), C54 (ilustrace — vazba na kód)  
**Vlastněné pojmy nebo kontrakty:** katalog cviků (`ExerciseCatalogEntry`), stabilní kódy cviků, kategorie, výchozí předpis, požadované vybavení, popis provedení a cue, vlastní cvik, vazba kroku workoutu na katalog, pravidla `EXC-001` až `EXC-014`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

Kroky workoutu jsou dnes volné texty (`local_workout_steps.title`, volitelné `instructions`). AI plány z R4/R7 generují cviky jen jako název + sady × opakování — uživatel neví, *co* má dělat (on-device nález 4). Bez stabilního slovníku cviků nelze (a) přimět model, aby nevymýšlel názvy a formy, (b) připojit popis provedení a ilustraci, (c) vést uživatele krok za krokem. C51 zavádí **uzavřený katalog cviků** jako doménový slovník — stejný vzor jako katalog sportů C17.

## 1.2 Owner a vztah ke zdrojům

**Domain (workout-model) + Product + Mobile.** `workout-model.md` popisuje kroky a předpisy obecně; C51 přidává slovník konkrétních cviků a jejich vazbu na krok. Rozsah katalogu (obsah) vlastní Product; kódy a pravidla Domain. Rozšíření katalogu je aditivní změna tohoto dokumentu (nový řádek §5), nikdy změna existujícího kódu.

## 1.3 Které slices blokuje

**Blocking pro `R8-01 – Exercise Catalog`.** Konzumují: C52 (schéma plánu v2 má `exerciseCode` jako enum katalogu), C53 (průvodce zobrazuje popis a cue), C54 (ilustrace se váže výhradně na kód).

---

# 2. Scope

## 2.1 Co C51 řeší

- entita `ExerciseCatalogEntry` a její atributy (§4),
- kanonický seznam kódů P0 s kategorií, výchozím předpisem a vybavením (§5),
- vlastní cvik mimo katalog (§6),
- vazba kroku workoutu na katalog — schéma v16 (§7),
- lokalizace názvů, popisů a cue (§8),
- invarianty `EXC-001..014` (§9), testy (§10), Ready podmínka (§11).

## 2.2 Co C51 výslovně neřeší

- schéma AI návrhu a prompt (C52),
- chování průvodce, časovače, zápis výkonů (C53),
- ilustrace — formát, assety, fallback (C54),
- kompletní encyklopedie cviků; P0 rozsah je cílený na profil vlastníka (lezení, síla bez posilovny — kruhy/TRX/hrazda/hangboard, mobilita, rozcvička, kompenzace) + malé jádro činkových a vytrvalostních položek; rozšiřování je aditivní,
- progrese/regrese cviků, náhrady, autoregulace zátěže,
- svalové zatížení jako výpočetní model (`AnatomicalLoadProfile` zůstává budoucí směr).

---

# 3. Základní principy

1. **Katalog je uzavřený, stabilní slovník** (C17 vzor): kódy se nikdy nemění ani nerecyklují; odstranění položky = deprecation flag, ne smazání (`EXC-002`).
2. **Katalog je in-app statická data**, offline, bez sítě, bez klíče — Dart konstanta + l10n; žádná DB tabulka (data se needituje uživatelem) (`EXC-003`).
3. **Popis provedení patří ke katalogu, ne k modelu** — model cvik *vybere*, aplikace k němu *ví*, jak se dělá (`EXC-006`).
4. **Vlastní cvik je first-class, ale poctivý** — mimo katalog s povinným popisem provedení, bez ilustrace (`EXC-008`).
5. **Krok workoutu zůstává nositelem předpisu** — katalog dává výchozí předpis a popis, konkrétní sady/časy/pauzy vždy určuje krok/set plan (`EXC-010`).
6. **Deterministické čtení** — vazba na kód, který katalog nezná, je typovaná chyba čtení (mapper vzor PDR), ne tichý default (`EXC-011`).

---

# 4. `ExerciseCatalogEntry`

| Atribut | Typ | Popis |
|---|---|---|
| `code` | stabilní kód (`UPPER_SNAKE`, 3–40 znaků) | primární identita; nikdy se nemění (§5) |
| `category` | enum `ExerciseCategory` (§4.1) | zařazení pro výběr a filtrování |
| `defaultPrescription` | enum `SET_REP` \| `DURATION` | výchozí způsob provedení; krok ho může přepsat (např. plank na čas i na opakování — výchozí `DURATION`) |
| `equipment` | množina `ExerciseEquipment` (§4.2) | co je nutné; prázdná = jen tělo |
| `primaryMuscles` | množina `MuscleGroup` (§4.3) | hlavní zatížení (informativní, pro UI a model) |
| `bilateral` | bool | `false` = provádí se na každou stranu zvlášť (průvodce C53 to připomene) |
| `deprecated` | bool (default `false`) | položka se nesmí nově navrhovat; existující kroky zůstávají čitelné |
| název, popis provedení, cue | l10n (cs/en) klíčované kódem | §8 |

## 4.1 `ExerciseCategory`

`WARM_UP` · `MOBILITY` · `STRENGTH_PUSH` · `STRENGTH_PULL` · `STRENGTH_LEGS` · `CORE` · `CLIMBING` · `ENDURANCE` · `RECOVERY`

## 4.2 `ExerciseEquipment`

Používá kódy katalogu vybavení C19 (`GYM_ACCESS`, `BARBELL`, `DUMBBELLS`, `KETTLEBELL`, `RESISTANCE_BANDS`, `PULL_UP_BAR`, `BENCH`, `TREADMILL`, `STATIONARY_BIKE`, `BIKE`, `CLIMBING_WALL_ACCESS`, `POOL_ACCESS`, `YOGA_MAT`) a **aditivně rozšiřuje C19 katalog** o kódy nutné pro P0 rozsah: `GYMNASTIC_RINGS`, `SUSPENSION_TRAINER`, `HANGBOARD`, `JUMP_ROPE`, `FOAM_ROLLER`, `STEP_BOX`, `ROWING_MACHINE`. Rozšíření C19 je aditivní řádek katalogu + l10n (C19 kódy se nemění); uživatel si je může označit v dostupnosti (C19 vzor).

## 4.3 `MuscleGroup`

`FINGERS_FOREARMS` · `SHOULDERS` · `CHEST` · `TRICEPS` · `BICEPS` · `UPPER_BACK` · `LATS` · `CORE` · `LOWER_BACK` · `GLUTES` · `QUADS` · `HAMSTRINGS` · `CALVES` · `HIPS` · `FEET_ANKLES` · `FULL_BODY` · `CARDIO`

---

# 5. Kanonický katalog P0

Formát: `code` — kategorie — výchozí předpis — vybavení — hlavní svaly. (`bilateral=false` označeno „(strany)".)

## 5.1 Rozcvička (`WARM_UP`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `JUMPING_JACKS` | DURATION | — | CARDIO, FULL_BODY |
| `HIGH_KNEES` | DURATION | — | CARDIO, HIPS |
| `BUTT_KICKS` | DURATION | — | CARDIO, HAMSTRINGS |
| `JUMP_ROPE` | DURATION | JUMP_ROPE | CARDIO, CALVES |
| `ARM_CIRCLES` | DURATION | — | SHOULDERS |
| `SHOULDER_DISLOCATES` | SET_REP | RESISTANCE_BANDS | SHOULDERS, UPPER_BACK |
| `BAND_PULL_APART` | SET_REP | RESISTANCE_BANDS | UPPER_BACK, SHOULDERS |
| `HIP_CIRCLES` | SET_REP | — | HIPS |
| `LEG_SWINGS_FRONT` (strany) | SET_REP | — | HIPS, HAMSTRINGS |
| `LEG_SWINGS_SIDE` (strany) | SET_REP | — | HIPS |
| `WRIST_CIRCLES` | DURATION | — | FINGERS_FOREARMS |
| `FINGER_FLEXOR_STRETCH` | DURATION | — | FINGERS_FOREARMS |
| `FINGER_EXTENSOR_BAND` | SET_REP | RESISTANCE_BANDS | FINGERS_FOREARMS |
| `SCAPULAR_PULL_UP` | SET_REP | PULL_UP_BAR | UPPER_BACK, LATS |
| `DEAD_HANG` | DURATION | PULL_UP_BAR | FINGERS_FOREARMS, SHOULDERS |
| `INCHWORM` | SET_REP | — | FULL_BODY, HAMSTRINGS |
| `EASY_TRAVERSE` | DURATION | CLIMBING_WALL_ACCESS | FULL_BODY, FINGERS_FOREARMS |

## 5.2 Mobilita (`MOBILITY`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `CAT_COW` | SET_REP | YOGA_MAT | LOWER_BACK, CORE |
| `THORACIC_ROTATION` (strany) | SET_REP | YOGA_MAT | UPPER_BACK |
| `WORLDS_GREATEST_STRETCH` (strany) | SET_REP | — | HIPS, UPPER_BACK |
| `DEEP_SQUAT_HOLD` | DURATION | — | HIPS, CALVES |
| `HIP_FLEXOR_STRETCH` (strany) | DURATION | YOGA_MAT | HIPS |
| `PIGEON_STRETCH` (strany) | DURATION | YOGA_MAT | GLUTES, HIPS |
| `HAMSTRING_STRETCH` (strany) | DURATION | — | HAMSTRINGS |
| `COUCH_STRETCH` (strany) | DURATION | — | QUADS, HIPS |
| `CHILD_POSE` | DURATION | YOGA_MAT | LOWER_BACK, LATS |
| `DOWNWARD_DOG` | DURATION | YOGA_MAT | HAMSTRINGS, CALVES, SHOULDERS |
| `COBRA` | DURATION | YOGA_MAT | CORE, LOWER_BACK |
| `ANKLE_CIRCLES` (strany) | SET_REP | — | FEET_ANKLES |
| `CALF_RAISE` | SET_REP | — | CALVES |
| `SINGLE_LEG_BALANCE` (strany) | DURATION | — | FEET_ANKLES, HIPS |
| `SHORT_FOOT` (strany) | SET_REP | — | FEET_ANKLES |
| `TOWEL_SCRUNCH` (strany) | SET_REP | — | FEET_ANKLES |
| `WRIST_FLEXOR_STRETCH` | DURATION | — | FINGERS_FOREARMS |
| `SHOULDER_CARS` (strany) | SET_REP | — | SHOULDERS |
| `HIP_CARS` (strany) | SET_REP | — | HIPS |

## 5.3 Síla — tlaky (`STRENGTH_PUSH`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `PUSH_UP` | SET_REP | — | CHEST, TRICEPS, SHOULDERS |
| `INCLINE_PUSH_UP` | SET_REP | — | CHEST, TRICEPS |
| `DIAMOND_PUSH_UP` | SET_REP | — | TRICEPS, CHEST |
| `PIKE_PUSH_UP` | SET_REP | — | SHOULDERS, TRICEPS |
| `RING_PUSH_UP` | SET_REP | GYMNASTIC_RINGS | CHEST, TRICEPS, CORE |
| `RING_DIP` | SET_REP | GYMNASTIC_RINGS | CHEST, TRICEPS, SHOULDERS |
| `RING_SUPPORT_HOLD` | DURATION | GYMNASTIC_RINGS | SHOULDERS, TRICEPS, CORE |
| `TRX_CHEST_PRESS` | SET_REP | SUSPENSION_TRAINER | CHEST, TRICEPS |
| `TRX_TRICEPS_EXTENSION` | SET_REP | SUSPENSION_TRAINER | TRICEPS |
| `DUMBBELL_BENCH_PRESS` | SET_REP | DUMBBELLS, BENCH | CHEST, TRICEPS |
| `OVERHEAD_PRESS` | SET_REP | DUMBBELLS | SHOULDERS, TRICEPS |
| `BENCH_PRESS` | SET_REP | BARBELL, BENCH | CHEST, TRICEPS |

## 5.4 Síla — tahy (`STRENGTH_PULL`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `PULL_UP` | SET_REP | PULL_UP_BAR | LATS, BICEPS, UPPER_BACK |
| `CHIN_UP` | SET_REP | PULL_UP_BAR | BICEPS, LATS |
| `NEGATIVE_PULL_UP` | SET_REP | PULL_UP_BAR | LATS, BICEPS |
| `RING_ROW` | SET_REP | GYMNASTIC_RINGS | UPPER_BACK, BICEPS |
| `TRX_ROW` | SET_REP | SUSPENSION_TRAINER | UPPER_BACK, BICEPS |
| `TRX_Y_RAISE` | SET_REP | SUSPENSION_TRAINER | SHOULDERS, UPPER_BACK |
| `FACE_PULL_BAND` | SET_REP | RESISTANCE_BANDS | UPPER_BACK, SHOULDERS |
| `EXTERNAL_ROTATION_BAND` (strany) | SET_REP | RESISTANCE_BANDS | SHOULDERS |
| `DUMBBELL_ROW` (strany) | SET_REP | DUMBBELLS | LATS, UPPER_BACK |
| `KETTLEBELL_SWING` | SET_REP | KETTLEBELL | GLUTES, HAMSTRINGS, CORE |
| `DEADLIFT` | SET_REP | BARBELL | HAMSTRINGS, GLUTES, LOWER_BACK |
| `ROMANIAN_DEADLIFT` | SET_REP | DUMBBELLS | HAMSTRINGS, GLUTES |

## 5.5 Síla — nohy (`STRENGTH_LEGS`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `BODYWEIGHT_SQUAT` | SET_REP | — | QUADS, GLUTES |
| `GOBLET_SQUAT` | SET_REP | KETTLEBELL | QUADS, GLUTES, CORE |
| `SPLIT_SQUAT` (strany) | SET_REP | — | QUADS, GLUTES |
| `BULGARIAN_SPLIT_SQUAT` (strany) | SET_REP | BENCH | QUADS, GLUTES |
| `REVERSE_LUNGE` (strany) | SET_REP | — | QUADS, GLUTES |
| `LATERAL_LUNGE` (strany) | SET_REP | — | HIPS, QUADS |
| `STEP_UP` (strany) | SET_REP | STEP_BOX | QUADS, GLUTES |
| `PISTOL_SQUAT_ASSISTED` (strany) | SET_REP | SUSPENSION_TRAINER | QUADS, GLUTES, FEET_ANKLES |
| `GLUTE_BRIDGE` | SET_REP | YOGA_MAT | GLUTES, HAMSTRINGS |
| `SINGLE_LEG_GLUTE_BRIDGE` (strany) | SET_REP | YOGA_MAT | GLUTES, HAMSTRINGS |
| `HIP_THRUST` | SET_REP | BENCH | GLUTES |
| `NORDIC_CURL_ASSISTED` | SET_REP | — | HAMSTRINGS |
| `BACK_SQUAT` | SET_REP | BARBELL | QUADS, GLUTES |
| `SINGLE_LEG_CALF_RAISE` (strany) | SET_REP | STEP_BOX | CALVES |

## 5.6 Střed těla (`CORE`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `PLANK` | DURATION | YOGA_MAT | CORE |
| `SIDE_PLANK` (strany) | DURATION | YOGA_MAT | CORE |
| `HOLLOW_HOLD` | DURATION | YOGA_MAT | CORE |
| `SUPERMAN_HOLD` | DURATION | YOGA_MAT | LOWER_BACK, GLUTES |
| `DEAD_BUG` | SET_REP | YOGA_MAT | CORE |
| `BIRD_DOG` (strany) | SET_REP | YOGA_MAT | CORE, LOWER_BACK |
| `HANGING_KNEE_RAISE` | SET_REP | PULL_UP_BAR | CORE, HIPS |
| `HANGING_LEG_RAISE` | SET_REP | PULL_UP_BAR | CORE, HIPS |
| `L_SIT` | DURATION | — | CORE, HIPS |
| `MOUNTAIN_CLIMBER` | DURATION | — | CORE, CARDIO |
| `RING_FALLOUT` | SET_REP | GYMNASTIC_RINGS | CORE, LATS |
| `TRX_PIKE` | SET_REP | SUSPENSION_TRAINER | CORE, SHOULDERS |

## 5.7 Lezecké (`CLIMBING`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `HANGBOARD_MAX_HANG` | DURATION | HANGBOARD | FINGERS_FOREARMS |
| `HANGBOARD_REPEATER` | DURATION | HANGBOARD | FINGERS_FOREARMS |
| `HANGBOARD_MIN_EDGE_HANG` | DURATION | HANGBOARD | FINGERS_FOREARMS |
| `LOCK_OFF_HOLD` (strany) | DURATION | PULL_UP_BAR | LATS, BICEPS, UPPER_BACK |
| `TUCK_FRONT_LEVER` | DURATION | PULL_UP_BAR | LATS, CORE |
| `RICE_BUCKET` | DURATION | — | FINGERS_FOREARMS |
| `WRIST_CURL` | SET_REP | DUMBBELLS | FINGERS_FOREARMS |
| `REVERSE_WRIST_CURL` | SET_REP | DUMBBELLS | FINGERS_FOREARMS |
| `BOULDER_PROBLEMS` | DURATION | CLIMBING_WALL_ACCESS | FULL_BODY, FINGERS_FOREARMS |
| `ROUTE_CLIMBING` | DURATION | CLIMBING_WALL_ACCESS | FULL_BODY |
| `ARC_TRAVERSE` | DURATION | CLIMBING_WALL_ACCESS | FINGERS_FOREARMS, FULL_BODY |
| `LIMIT_BOULDERING` | DURATION | CLIMBING_WALL_ACCESS | FULL_BODY, FINGERS_FOREARMS |
| `FOUR_BY_FOUR` | DURATION | CLIMBING_WALL_ACCESS | FULL_BODY, CARDIO |

## 5.8 Vytrvalost (`ENDURANCE`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `EASY_RUN` | DURATION | — | CARDIO |
| `TEMPO_RUN` | DURATION | — | CARDIO |
| `INTERVAL_RUN` | DURATION | — | CARDIO |
| `EASY_RIDE` | DURATION | BIKE | CARDIO |
| `STATIONARY_BIKE_STEADY` | DURATION | STATIONARY_BIKE | CARDIO |
| `ROWING_ERG` | DURATION | ROWING_MACHINE | CARDIO, UPPER_BACK |
| `BURPEE` | SET_REP | — | FULL_BODY, CARDIO |

## 5.9 Regenerace (`RECOVERY`)

| code | předpis | vybavení | svaly |
|---|---|---|---|
| `FOAM_ROLL_QUADS` | DURATION | FOAM_ROLLER | QUADS |
| `FOAM_ROLL_UPPER_BACK` | DURATION | FOAM_ROLLER | UPPER_BACK |
| `FOAM_ROLL_CALVES` | DURATION | FOAM_ROLLER | CALVES |
| `FOREARM_MASSAGE` | DURATION | — | FINGERS_FOREARMS |
| `BOX_BREATHING` | DURATION | — | — |
| `WALKING_COOLDOWN` | DURATION | — | CARDIO |

Celkem **105 položek**. Kódy z §5 jsou závazné; každá má název, popis provedení a cue v cs i en (§8). Rozšíření = nový řádek + l10n, nikdy změna kódu.

---

# 6. Vlastní cvik

- Krok bez `exerciseCode` je **vlastní cvik**: `title` povinný (1–120), `instructions` **povinné** (1–500) — bez popisu provedení vlastní cvik nevznikne z AI ani z ručního zadání (`EXC-008`).
- Vlastní cvik nemá kategorii, vybavení, svaly ani ilustraci; průvodce zobrazí název + popis.
- Vlastní cvik se **nikdy automaticky nemapuje** na katalog (žádné fuzzy párování názvů — deterministické jádro); uživatel může krok při ruční editaci nahradit katalogovým.
- Existující kroky z R1–R7 (seed, ruční, AI v1) jsou vlastní cviky s tolerancí: `instructions` mohou chybět (historická data, `EXC-009`) — průvodce ukáže „bez popisu provedení".

---

# 7. Vazba kroku workoutu na katalog (schéma v16)

- `local_workout_steps` dostává **nullable** sloupec `exercise_code TEXT` (aditivní migrace **v15 → v16**, C16 vzor; žádný backfill — historické kroky zůstávají vlastní cviky) (`EXC-004`).
- `exercise_code` je smysluplný jen pro `step_type IN ('EXERCISE','DURATION','MOBILITY_POSITION')`; pro `REST`/`INSTRUCTION`/`CUSTOM` je `NULL` (`EXC-005`).
- Read model `WorkoutStep` nese `exerciseCode: String?`; mapper odmítne kód, který katalog nezná (`UnsupportedPersistedValue`, `EXC-011`) — s výjimkou `deprecated` položek, které se čtou normálně.
- Struktura sync (R6, `SELECT *`/`insertRaw`) přenáší sloupec automaticky; starší payload bez klíče → `NULL` (aditivita zachována; backend dormantní).
- Zápis: ruční tvorba plánu (C20) a materializace AI návrhu (C52) plní `exercise_code` u katalogových kroků a **kopírují výchozí předpis katalogu**, pokud krok nespecifikuje jinak (`EXC-010`); `title` kroku = lokalizovaný název katalogu v jazyce zápisu (snapshot; katalog je zdroj pravdy pro zobrazení, `title` je záložní text pro historii a sync).

---

# 8. Lokalizace a texty

- Každý kód má v `app_cs.arb` i `app_en.arb`: `exerciseName` (název), `exerciseInstructions` (popis provedení, 1–3 věty: výchozí pozice → pohyb → návrat), `exerciseCue` (1–2 krátké „na co si dát pozor" — bezpečnost/technika); implementace `select`-vzorem jako `sportName` (`EXC-007`).
- Texty jsou obsah aplikace (Product), ne výstup modelu; model je nikdy nepřepisuje.
- Chybějící překlad kódu je porušení kontraktu (test úplnosti, §10).

---

# 9. Invarianty

- **EXC-001** Katalog je uzavřený seznam kódů; krok s `exercise_code` mimo katalog nevznikne (validace zápisu i schéma C52).
- **EXC-002** Kódy jsou stabilní: nikdy se nemění ani nerecyklují; odstranění = `deprecated`.
- **EXC-003** Katalog je in-app statická data (offline, bez sítě, bez klíče); není v DB.
- **EXC-004** Vazba je aditivní nullable sloupec (v16); historická data zůstávají čitelná beze změny.
- **EXC-005** `exercise_code` jen u typů kroků, které jsou cvikem; jinak `NULL`.
- **EXC-006** Popis provedení a cue patří ke katalogu (l10n), nikdy k modelu; model cvik pouze vybírá.
- **EXC-007** Každý kód má název, popis i cue v cs a en.
- **EXC-008** Vlastní cvik = krok bez kódu s povinným `title` a `instructions` (u nových zápisů); bez ilustrace.
- **EXC-009** Historické kroky bez kódu a bez `instructions` jsou tolerované vlastní cviky (poctivé „bez popisu").
- **EXC-010** Katalog dává výchozí předpis; konkrétní sady/časy/pauzy vždy určuje krok/set plan; předpis kroku může výchozí přepsat.
- **EXC-011** Neznámý persistovaný kód = typovaná chyba čtení, ne tichý default; `deprecated` kódy se čtou.
- **EXC-012** Žádné automatické párování volných názvů na katalog.
- **EXC-013** Rozšíření C19 katalogu vybavení (§4.2) je aditivní: nové kódy + l10n, existující beze změny.
- **EXC-014** Katalog nezavádí novou write cestu — plní se výhradně existujícími zápisy kroků (C20 ručně, C52 přes C30 provedení).

---

# 10. Testy a evidence (R8-01)

- Unit: unikátnost a formát kódů; každý kód má kategorii, předpis, cs+en název/popis/cue (úplnost); `equipment` jen známé kódy C19+rozšíření; `deprecated` položky nejsou nabízeny k novému výběru; mapper odmítne neznámý kód a přijme `deprecated`; historické řádky bez kódu se mapují na vlastní cvik.
- Migrace: v15→v16 aditivní, data zachována (C16 vzor testu od reálného schématu).
- Widget: detail tréninku zobrazuje u katalogového kroku název z katalogu + popis + cue; u vlastního cviku název + `instructions` (nebo „bez popisu").
- Ruční tvorba plánu: výběr z katalogu → krok s `exercise_code` a výchozím předpisem; vlastní cvik bez popisu je odmítnut.
- Struktura sync round-trip (existující R6 testy) prochází se sloupcem navíc.

---

# 11. Ready podmínka

`R8-01` je `READY`, jakmile tento dokument existuje (verze 0.1). Definition of Done: §10 evidence zelená, mobile suite zelená (R1–R7 E2E), analyze čistý, `DOCUMENTATION_STATUS.md` aktualizován.
