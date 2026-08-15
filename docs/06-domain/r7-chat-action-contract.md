# AI Trainer – R7 Chat Action Contract (C48)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r7-chat-action-contract.md`  
**Vlastník:** Domain + Security + Mobile  
**Navazuje na:** C47 (chat conversation), C46 (BYOK provider), C28 (structured output vzor), C17/C18/C19 (sporty/cíle/dostupnost — cílové domény akcí), `docs/13-delivery/r7-vertical-slice-plan.md`  
**Blokuje:** `R7-03 – Chat-Driven Profile Setup`

---

# 1. Účel

Definuje **akční protokol chatu**: jak model navrhuje strukturované změny profilu, jak se validují, potvrzují a provádí. Základní zákon trvá (R7P-001/003): **chat navrhuje, doména provádí** — každá akce vyžaduje explicitní potvrzení uživatele a provádí se výhradně existujícími repository operacemi (C17/C18/C19). Žádná přímá SQL/DB cesta, volný text nikdy není příkaz.

# 2. Tvar odpovědi modelu (chat-action-schema-v1)

- Prompt **`chat-v2`** (nahrazuje chat-v1 novým záznamem, PAA-002/003): model vrací **výhradně jeden JSON objekt** `{"reply": string (1–4000), "actions": [0–5 položek]?}`. `reply` je konverzační odpověď; `actions` návrhy změn — **jen když uživatel vyjádřil fakta či přání o svém profilu**.
- Extrakce deterministicky (C28 §3 fence vzor); nevalidní tvar = typované selhání celé odpovědi (retry) — **nikdy oprava, nikdy částečné přijetí** (SOV-005 vzor).

# 3. Akční tvary (P0 scope = profil)

Každá akce má `"action"` + přesná pole; neznámá pole se kanonizací zahazují; neznámý druh akce = nevalidní celek.

| Akce | Povinná pole | Volitelná pole | Mapování |
|---|---|---|---|
| `UPSERT_SPORT` | `sportCode` XOR `customName`; `role` ∈ PRIMARY/SECONDARY/SUPPORTING/RECREATIONAL/OCCASIONAL/SEASONAL; `priority` ∈ CRITICAL/HIGH/MEDIUM/LOW/BACKGROUND | `experienceLevel` ∈ BEGINNER/NOVICE/INTERMEDIATE/ADVANCED/EXPERT/PROFESSIONAL/UNKNOWN; `frequencyPerWeek` 0–21; `typicalDurationMinutes` 1–600; `environment` ∈ INDOOR/OUTDOOR/MIXED | `UserSportRepository.saveSport` — existující sport se resolvuje deterministicky shodou `sportCode`/`customName` (update), jinak create |
| `ADD_GOAL` | `title` (1–120); `goalType` ∈ PERFORMANCE/STRENGTH/ENDURANCE/HABIT/EVENT_PREPARATION/RETURN_TO_ACTIVITY/MAINTENANCE/QUALITATIVE; `priority` ∈ PRIMARY/MAINTENANCE/DEFERRED | `horizon` ∈ IMMEDIATE/SHORT_TERM/MEDIUM_TERM/LONG_TERM/OPEN_ENDED (default OPEN_ENDED); `targetLocalDate` ISO datum | `GoalRepository.saveGoal` (create) |
| `SET_AVAILABILITY` | `dayOfWeek` ∈ MON..SUN; `level` ∈ AVAILABLE/LIMITED/UNAVAILABLE | `budgetMinutes` 1–960; `preferredPartOfDay` ∈ MORNING/AFTERNOON/EVENING | `AvailabilityProfileRepository.upsertDay` |
| `ADD_CONSTRAINT` | `title` (1–120) | — | `AvailabilityProfileRepository.addConstraint` |

# 4. Lifecycle akce

- Validované akce se persistují k asistentské zprávě (schema **v15**, `local_chat_actions` — device-local, C47 vzor) ve stavu **`PROPOSED`**.
- Rozhodnutí je **per akce, výhradně explicitní tap**: potvrzení → provedení repository operací v témže kroku → `APPLIED`; odmítnutí → `REJECTED` (viditelný, trvalý stav). Selhání provedení (typovaný výsledek repa) → `FAILED` s důvodem; opakování jen explicitní akcí.
- Stavy akcí jsou konečné kromě `FAILED` (retry → nové provedení téhož záznamu). Žádné mazání — append-only evidence toho, co chat navrhl a co uživatel rozhodl.
- Provedená změna žije běžným lifecycle domény (owner stamping, DIRTY, sync) — z pohledu domény je nerozlišitelná od ručního zápisu stejného obsahu.

# 5. Invarianty

- **CHA-001** Každá mutace z chatu = potvrzená akce přes existující repos; žádná paralelní write cesta.
- **CHA-002** Volný text (reply) se nikdy neinterpretuje jako akce; akce jen z validovaného `actions` pole.
- **CHA-003** Dvojí role validace v jednom místě: striktní tvarová tabulka §3, kanonizace zahazuje neznámá pole, nevalidní celek se nikdy neopravuje ani částečně nepřijímá.
- **CHA-004** Nejvýše 5 akcí na odpověď; nadlimit = nevalidní celek.
- **CHA-005** Rozhodnutí je per akce a výhradně explicitní; žádné hromadné tiché potvrzení, žádný default.
- **CHA-006** PROPOSED akce nikdy nic nemění; efekt vzniká až potvrzením.
- **CHA-007** Provedení používá typované výsledky repos; selhání = `FAILED` s důvodem, bez auto-retry.
- **CHA-008** Akce jsou append-only evidence u zprávy (device-local, CHC-001); rozhodnutí je trvale viditelné.
- **CHA-009** UPSERT_SPORT resolvuje existující sport deterministicky (kód/název); nejednoznačnost není možná (unikátnost vlastní C17).
- **CHA-010** Prompt chat-v2 je nový immutable záznam registru; chat-v1 se needituje.
- **CHA-011** Enumy akcí jsou přesně domény C17/C18/C19 — akční vrstva nezavádí nové hodnoty ani defaulty nad rámec repos.
- **CHA-012** Po APPLIED se invalidují dotčené read modely — profil je okamžitě vidět v příslušných obrazovkách.
- **CHA-013** Nevalidní odpověď modelu (tvar/limit) = selhaná asistentská zpráva s explicitním retry (C47 CHC-005); konverzace se neztrácí.
- **CHA-014** Limity C31 platí (výstup ≤ 100k; reply ≤ 4000).
- **CHA-015** Migrace v15 je aditivní a zachovává všechna data (C1 vzor).
