# AI Trainer – R8 Plan Proposal Schema v2 Contract (C52)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/09-ai/r8-plan-schema-v2-contract.md`  
**Vlastník:** Domain + Mobile (AI)  
**Poslední aktualizace:** 2026-08-16  
**Kontraktní ID:** C52 (dle `docs/13-delivery/r8-vertical-slice-plan.md §7.1`)  
**Navazuje na:** `docs/09-ai/r4-structured-output-contract.md` (C28 — zákon validace, `SOV-*`), `docs/09-ai/r5-adjustment-schema-contract.md` (C37 — operace úprav), `docs/09-ai/r4-changeset-execution-contract.md` (C30 — provedení), `docs/09-ai/r5-adjustment-execution-contract.md` (C38), `docs/06-domain/r8-exercise-catalog-contract.md` (C51), `docs/06-domain/r3-manual-plan-contract.md` (C20), `docs/12-data/r1-physical-data-model.md` (sekce → kroky → set plany), `docs/08-mobile/r7-byok-provider-contract.md` (C46 — přímý adapter), `docs/06-domain/r7-chat-planning-contract.md` (C49)  
**Navazující dokumenty:** implementace R8-02, C53 (průvodce čte strukturu), C54 (ilustrace na kód)  
**Vlastněné pojmy nebo kontrakty:** `plan-proposal-schema-v2`, `adjustment-proposal-schema-v2`, tvar `workout v2` (sekce/kroky/sady/pauzy), structured outputs jako vynucení tvaru, prompty `plan-proposal-v3` / `adjustment-proposal-v3`, materializace v2 do fyzického modelu, koexistence s v1, pravidla `PS2-001` až `PS2-014`

---

# 1. Purpose

Schéma v1 (C28) popisuje cvik jen jako `title + sets + repetitions (+ weightKg)` v jediné implicitní sekci — vede k tréninkům, které nejsou proveditelné jako vedený trénink (on-device nález 4). C52 zavádí **`workout v2`**: sekce (rozcvička / hlavní část / vyklidnění), kroky nad **katalogem cviků C51** (nebo vlastní s povinným popisem), předpis **opakování nebo čas**, sady s pauzami a váhou — v přesné shodě s fyzickým modelem R1, který průvodce C53 čte. Tvar je **vynucen structured outputs** (poučení z chatu, nález 3c) a validován klientem (SOV-003 obrana do hloubky). Zákon C28 platí celý: deterministická validace, kanonizace, nevalidní celek se nikdy neopravuje ani částečně nepřijímá.

**Blocking pro `R8-02 – Plan Proposal v2`.**

---

# 2. Tvar `workout v2`

Kanonický JSON (povinná pole tučně):

```json
{
  "title": "string 1–120",
  "workoutType": "STRENGTH|ENDURANCE|MOBILITY|TECHNIQUE|GENERAL",
  "dayOffset": 0–27,                       // jen v plánu a v ADD (C37 tabulka trvá)
  "reason": "string 1–500",                // jen v plánu (v úpravě nese důvod operace)
  "plannedDurationMinutes": 1–600,         // volitelné
  "sections": [ 1–3 sekce ]
}
```

**Sekce:** `{ "sectionType": "WARM_UP|MAIN|COOLDOWN", "title": "string 1–120" (volitelné), "steps": [ 1–20 kroků ] }`
- každý `sectionType` nejvýše jednou; pořadí `WARM_UP` → `MAIN` → `COOLDOWN` (jiné pořadí = nevalidní); **`MAIN` povinný**;
- celkem nejvýše **30 kroků** na workout.

**Krok** — dva druhy podle `stepType`:

| `stepType` | Povinná pole | Volitelná pole | Zakázaná |
|---|---|---|---|
| `EXERCISE` | `exerciseCode` (kód katalogu C51, aktivní) **XOR** (`customTitle` 1–120 **+** `instructions` 1–500), `prescription` ∈ `SET_REP\|DURATION`, `sets` (1–20) | `note` 1–300 (krátký koučovací záměr kroku → `purpose`) | `durationSeconds` |
| `REST` | `durationSeconds` 5–600 | — | vše ostatní kromě `note` |

**Sada** (`sets[]`): `{ "repetitions": 1–100 (SET_REP), "durationSeconds": 1–3600 (DURATION), "weightKg": 0–500 (volitelné), "restAfterSeconds": 0–600 (volitelné) }` — u `SET_REP` má **každá** sada `repetitions` a nemá `durationSeconds`; u `DURATION` naopak. Nekonzistence = nevalidní krok = nevalidní celek.

**Vztah k předpisu katalogu (EXC-010):** model smí zvolit `prescription` odlišný od výchozího (např. plank na opakování); validátor to nekontroluje proti katalogu — kontroluje jen vnitřní konzistenci.

# 3. Schémata

## 3.1 `plan-proposal-schema-v2`

`{ "summary": 1–2000, "planTitle": 1–120, "workouts": [ 1–14 × workout v2 ] }` — jako C28 §2, workout nahrazen tvarem §2 (`exercises` v1 **neexistuje**; přítomnost `exercises` = neznámé pole → zahozeno; workout bez `sections` = nevalidní).

## 3.2 `adjustment-proposal-schema-v2`

C37 §3 beze změny (operace `MOVE|CANCEL|REPLACE|ADD`, `target` by-value, `reason` per operace, meze) — pouze `workout` v `REPLACE`/`ADD` je **workout v2 bez `reason`** (`ADD` s `dayOffset`, `REPLACE` bez).

## 3.3 Structured outputs (vynucení tvaru)

Přímý adapter (C46) posílá `output_config.format = { type: json_schema, schema }` s JSON schématem, které **zrcadlí §2–§3** v tom, co JSON Schema (podmnožina podporovaná API) vyjádří: `required`, `enum` (`workoutType`, `sectionType`, `stepType`, `prescription`, **`exerciseCode` = enum aktivních kódů C51**), `additionalProperties: false`, `anyOf` pro XOR katalog/vlastní a pro EXERCISE/REST. **Číselné meze, délky textů, pořadí sekcí, unikátnost typů sekcí, konzistenci sad s předpisem a strop 30 kroků** hlídá výhradně klientský validátor (SOV-003) — schéma je pojistka tvaru, validátor je zákon (`PS2-004`). `thinking: disabled` trvá (nález 3b).

# 4. Prompty

- **`plan-proposal-v3`** a **`adjustment-proposal-v3`** — nové immutable záznamy klientského registru (BYK-005/PAA vzor; v2 se needitují). Obsah: persona, kontext jako data, **literální tvar §2** s výčtem katalogových kódů (model vybírá z katalogu; vlastní cvik jen s popisem), zásady skladby (rozcvička 5–15 min, hlavní část, krátké vyklidnění; pauzy dle cíle; DURATION pro výdrže/mobilitu/kardio; respektovat vybavení a omezení z kontextu; nevymýšlet nedostupné vybavení), stropy §2, `summary`/`reason` povinné.
- Model volí kódy z katalogu podle **`equipment` uživatele v kontextu C27** (vybavení C19 vč. rozšíření C51 §4.2); cvik vyžadující nedostupné vybavení je porušení instrukce, ne schématu — hlídá se evalem, ne validátorem (`PS2-011`).

# 5. Materializace (provedení C30/C38)

Kanonický workout v2 → `PlannedWorkoutInput` se `sections` (`PlannedSectionInput{sectionType, title?, steps}`; `PlannedStepInput{stepType, exerciseCode?, customTitle?, instructions?, prescription, sets, note?, durationSeconds?}`; `PlannedSetInput{repetitions?, durationSeconds?, weightKg?, restAfterSeconds?}`) → repository zapíše **existující fyzický model** (C20 write cesta):
- sekce → `local_workout_sections` (`position` = pořadí, `section_type`, `title` = zadaný nebo lokalizovaný název typu, `priority REQUIRED`, `is_optional false`),
- EXERCISE krok → `local_workout_steps` (`step_type EXERCISE`, `exercise_code` / vlastní `title` + `instructions`, `prescription_type`, `purpose` = `note`, `title` = lokalizovaný název katalogu jako snapshot — C51 §7),
- REST krok → `local_workout_steps` (`step_type REST`, `prescription_type DURATION`, `planned_duration_seconds`, `title` = lokalizované „Pauza"),
- sady → `local_set_plans` (`planned_repetitions` / `planned_duration_seconds`, `planned_weight_kg`, `rest_after_seconds`).
- **Žádný dopočet, žádná oprava** (CSE-012): validní kanonický payload je vždy proveditelný (SOV-014); mapování `dayOffset` → datum vlastní C30 beze změny.
- v1 workouty (`exercises`, bez `sections`) se materializují dosavadní cestou (jedna sekce MAIN, SET_REP) — **koexistence** (§6).

# 6. Koexistence v1 / v2

- Nové návrhy vznikají výhradně ve v2 (`schemaVersion` = `*-schema-v2`, prompt `*-v3`); uložené `PROPOSED` návrhy v1 zůstávají čitelné, přijatelné i proveditelné dosavadní cestou (žádná migrace payloadů, APL vzor).
- Karta návrhu (AI obrazovka i chat, CHP-001) zobrazuje **v2 strukturu čitelně**: sekce → kroky (název katalogu / vlastní, předpis, počet sad, čas, pauzy); v1 dál jako dosud.
- Klientský validátor v1 zůstává pro čtení historických payloadů; nové výstupy modelu se validují **jen** v2 (typ podle `schemaVersion` požadavku).
- Server (backend dormantní, ADR-013): serverový validátor v2 se **nezavádí** — přímá cesta BYOK server neobsahuje; dvojí validace SOV-003 je nahrazena **structured outputs (API) + klientský validátor** (`PS2-005`). Reaktivace backendu = samostatné rozhodnutí vč. serverového zrcadla.

# 7. Invarianty (`PS2`)

- **PS2-001 — C28 zákon platí celý** (SOV-001..015): verzované schéma, kanonizace, neznámá pole zahozena, nevalidní celek bez opravy, bez auto-retry, čistá deterministická validace.
- **PS2-002 — Struktura 1:1 s fyzickým modelem.** Každé pole v2 má místo v sekcích/krocích/set planech; průvodce C53 nepotřebuje nic, co v2 nedává.
- **PS2-003 — Katalog uzavřený.** `exerciseCode` výhradně aktivní kód C51 (schéma enum + validátor); vlastní cvik jen s `instructions` (EXC-008).
- **PS2-004 — Schéma je pojistka, validátor zákon.** Meze, pořadí, unikátnost, konzistence sad hlídá validátor; nevalidní celek = `INVALID_OUTPUT`.
- **PS2-005 — Dvojí obrana v BYOK režimu** = structured outputs + klientský validátor; serverové zrcadlo je odloženo s dormantním backendem (evidováno).
- **PS2-006 — Prompty v3 immutable**, v2 se needitují (PAA-002/003).
- **PS2-007 — Meze:** workouts 1–14, sections 1–3 (MAIN povinný, každý typ jednou, pořadí pevné), steps 1–20/sekci a ≤ 30/workout, sets 1–20, texty a čísla dle §2.
- **PS2-008 — Konzistence sad s předpisem** (SET_REP ↔ `repetitions`, DURATION ↔ `durationSeconds`) — porušení = nevalidní.
- **PS2-009 — REST krok jen `durationSeconds` (+ `note`)**; nikdy sady ani kód.
- **PS2-010 — Materializace bez dopočtu** (CSE-012); validní = proveditelný (SOV-014).
- **PS2-011 — Vybavení a omezení respektuje prompt**, ne validátor; eval fixtures z reálných výstupů (C32 vzor, živá sonda) hlídají kvalitu.
- **PS2-012 — Koexistence:** v1 návrhy čitelné/proveditelné, v2 jediná cesta pro nové; karta návrhu umí obě.
- **PS2-013 — Bounded volání** (R7P-009/013): strukturovanější výstup ≠ víc volání; `max_tokens` bounded (4096 nemusí stačit pro 14 plných workoutů — adapter zvýší na **8192** pro plán v2 při `thinking: disabled`, stále bounded).
- **PS2-014 — Evidence:** validátor v2 (validní/nevalidní fixtures: XOR, pořadí sekcí, duplicitní typ, konzistence sad, REST tvar, meze, neznámá pole), schéma obsahuje enum katalogu, materializace do DB (sekce/kroky/set plany vč. REST a pauz), koexistence v1, karta návrhu v2, živá opt-in sonda plánu v2 s reálným modelem + eval fixture z jejího výstupu.

# 8. Ready condition

`R8-02` je `READY`, jakmile tento dokument existuje (verze 0.1). Definition of Done: §7 PS2-014 evidence zelená, R1–R7 kritické E2E zelené, analyze čistý, `DOCUMENTATION_STATUS.md` aktualizován.
