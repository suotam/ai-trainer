# AI Trainer – R3 Sync Extension Contract (C24)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r3-sync-extension-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Data Architecture + Backend
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C24 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/12-data/r2-idempotency-contract.md` (C11), `docs/12-data/r2-server-data-model.md` (C6 §8.4), `docs/11-security/r2-authorization-ownership-contract.md` (C8), `docs/12-data/r3-mobile-schema-migration.md` (C16), kontrakty C17–C23, `docs/13-delivery/r3-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R3-07, R3-08 (E2E evidence)
**Vlastněné pojmy nebo kontrakty:** aditivní rozšíření sync registru o R3 entity, jejich serverové úložiště, pořadí v batchi, vyřešení otevřených rozhodnutí C20 §5.3 / C19 §8 a pravidla `SXC-001` až `SXC-015`

---

# 1. Purpose

R3-07 zpřístupňuje všechny R3 entity existujícímu R2 push mechanismu — **bez jakékoli změny sémantiky C10/C11/C8** (plán §9.7). Entity vznikaly „born ownable and syncable" (C16), takže rozšíření je čistě aditivní: registr typů, serverové tabulky, mobilní collect.

**Blocking pro `R3-07`.**

# 2. Rozšíření registru (SXC-001/002)

Nové stabilní entity typy (aditivní rozšíření C10 §5.2 podmnožiny a OpenAPI enum):

| Typ | Lokální tabulka | Serverová tabulka | Parent |
|---|---|---|---|
| `USER_SPORT` | `local_user_sports` | `synced_user_sport` | — |
| `GOAL` | `local_goals` | `synced_goal` | — |
| `AVAILABILITY_RULE` | `local_availability_rules` | `synced_availability_rule` | — |
| `EQUIPMENT_ITEM` | `local_equipment_items` | `synced_equipment_item` | — |
| `CONSTRAINT_ITEM` | `local_constraints` | `synced_constraint` | — |
| `TRAINING_PLAN` | `local_training_plans` | `synced_training_plan` | — |
| `CALENDAR_CHANGE` | `local_calendar_changes` | `synced_calendar_change` | — |
| `MANUAL_ACTIVITY` | `local_activities` | `synced_activity` | — |

R3 entity **nemají serverové parenty** — device-local reference (sport/instance/plán) jsou součást neprůhledného payloadu (C6 §8.4); `DEPENDENCY_FAILED` se na ně nevztahuje. Pořadí v batchi: po R1 šestici, v pořadí tabulky výše (deterministické, bez závislostí).

# 3. Serverové úložiště (SXC-003)

Flyway `V5` — osm tabulek přesně dle C6 §8.4 kostry **bez parent sloupce**: `id uuid PK`, `account_id → account`, `server_version`, `source_installation_id`, `payload jsonb`, časy. Append-only rozšíření C6 §8 (SDM-002/015); server payload nereinterpretuje.

# 4. Vyřešená otevřená rozhodnutí

- **Struktura plán snapshotu (C20 §5.3):** sekce/kroky/set plans ručních workoutů se v R3 **nesynchronizují** — instance se přenáší jako dosud (top-level payload). Struktura je lokální; přenos má smysl až s pull/restore (mimo P0, evidováno). (SXC-010)
- **Zpětvzetí availability deklarace (C19 §8):** protokol zůstává `CREATE_ENTITY`/`UPDATE_ENTITY` — **DELETE se nepřenáší**. Lokální odstranění dne je platné pro UI (lokální DB je zdroj pravdy); serverová kopie může zůstat zastaralá do budoucího DELETE/pull rozšíření (vědomé, evidované omezení). (SXC-011)

# 5. Invarianty (`SXC`)

- **SXC-001 — Aditivní registr.** Nové typy se přidávají registrem (C10 SPC-013) + OpenAPI enum; sémantika operací, výsledků, idempotence a potvrzení po commitu se nemění.
- **SXC-002 — Stabilní kódy typů** dle §2; nikdy se nerecyklují.
- **SXC-003 — C6 kostra bez parentů**; payload neprůhledný; client-generated ID zachováno (SDM-005).
- **SXC-004 — Ownership beze změny.** Cizí entita = `PERMISSION_DENIED` + audit (C8/AOC-009); registrovaná instalace nutná (SPC-001).
- **SXC-005 — Idempotence beze změny.** `ALREADY_APPLIED` replay, stejný klíč + jiný payload odmítnut (C11).
- **SXC-006 — State-based payload.** Plný stav řádku v camelCase; mobilní collect řadí R3 typy za R1 šestici deterministicky.
- **SXC-007 — Potvrzení po commitu.** `SYNCED` + uložená server_version výhradně z odpovědi (SPC-005).
- **SXC-008 — Konflikt/rejection beze změny.** `VERSION_CONFLICT`→USER_REVIEW, rejection→BLOCKED (C12) platí i pro R3 typy.
- **SXC-009 — Audit beze změny vzoru** (C14 §7).
- **SXC-010 — Plán struktura lokální** (§4).
- **SXC-011 — DELETE mimo P0** (§4); žádná operace se nepředstírá.
- **SXC-012 — Žádný nový endpoint.** Výhradně existující `POST /api/v1/sync/push`.
- **SXC-013 — Migrace append-only** (V5, SDM-002).
- **SXC-014 — Attach ověřen E2E.** R3-07/08 ověří attach coverage (C15 vč. R3 rozšíření) společně s push.
- **SXC-015 — Evidence:** backend Testcontainers (R3 typ: success/replay/conflict/cizí účet), mobilní engine testy (collect+push+confirm R3 typů), OpenAPI contract testy; flaky ≠ zelený důkaz.

# 6. Ready condition

C24 je Done vytvořením tohoto dokumentu a zápisem do doc mapy → **`R3-07` je `READY`**.
