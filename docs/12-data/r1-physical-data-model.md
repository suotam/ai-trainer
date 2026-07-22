# AI Trainer – R1 Physical Data Model

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/12-data/r1-physical-data-model.md`  
**Vlastník:** Data Architecture  
**Poslední aktualizace:** 2026-07-22  
**Navazuje na:** `docs/02-product/release-scope.md`, `docs/05-architecture/initial-architecture-decisions.md`, `docs/06-domain/workout-model.md`, `docs/08-mobile/mobile-architecture.md`, `docs/12-data/data-architecture.md`, `docs/13-delivery/repository-strategy.md`  
**Navazující dokumenty:** test strategy, vertical-slice implementation plan, Drift migrations, repository interfaces a pozdější sync protocol  
**Vlastněné pojmy nebo kontrakty:** lokální R1 SQLite schema, Drift tables, persistence mapping, constraints, transakční hranice, migrace, recovery a pravidla `PDR-001` až `PDR-015`

---

# 1. Účel

Tento dokument převádí `R1 – Local Workout Slice` na konkrétní lokální datový model pro SQLite a Drift.

R1 musí umožnit, aby uživatel na jednom zařízení:

1. otevřel dnešní workout,
2. zobrazil stabilní plánovaný obsah,
3. zahájil WorkoutSession,
4. průběžně zapisoval výkon,
5. aplikaci zavřel nebo ztratil síť,
6. session znovu obnovil,
7. workout dokončil,
8. zobrazil základní historii.

Tento dokument záměrně nenavrhuje:

- serverové PostgreSQL schema,
- multi-device sync,
- uživatelské účty,
- cloudové conflict resolution,
- AIProposal a ChangeSet persistence,
- externí integrace,
- kompletní exercise katalog,
- celý dlouhodobý analytický model.

Tyto oblasti vzniknou před slicem, který je skutečně potřebuje.

---

# 2. Technologický základ

Podle `ADR-004` používá mobilní klient:

- SQLite jako lokální databázi,
- Drift jako typovanou persistence vrstvu,
- verzované lokální migrace uvnitř `apps/mobile`,
- transakce pro všechny kritické změny workout session.

Persistence DTO nejsou doménové entity. Drift tabulky a row objekty patří do data vrstvy; doménové objekty vznikají přes explicitní mappers.

---

# 3. Rozsah R1 dat

R1 ukládá pouze objekty nutné pro lokální workout flow:

- `LocalWorkoutInstance`,
- `LocalWorkoutSection`,
- `LocalWorkoutStep`,
- `LocalSetPlan`,
- `LocalWorkoutSession`,
- `LocalStepPerformance`,
- `LocalSetPerformance`,
- `LocalWorkoutFeedback`,
- `LocalActivitySummary`,
- `LocalAppState`.

Samostatné WorkoutTemplate a WorkoutTemplateVersion se v R1 neukládají jako plný katalog. Každý WorkoutInstance obsahuje stabilní snapshot plánovaného obsahu, aby změna zdroje nemohla zpětně změnit již uložený workout.

---

# 4. Identifikátory a společná pole

Všechny hlavní tabulky používají textový stabilní identifikátor generovaný aplikací, předběžně UUID.

Společná pravidla:

- `id TEXT PRIMARY KEY NOT NULL`,
- časy se ukládají jako UTC epoch milliseconds nebo ISO-8601 UTC podle jedné konzistentní Drift konverze,
- lokální datum relevantní pro Today flow se ukládá odděleně jako `YYYY-MM-DD`,
- enum hodnoty se ukládají jako stabilní technické kódy,
- pořadí používá celé číslo začínající nulou,
- boolean hodnoty používají Drift boolean mapping,
- JSON se smí použít pouze pro malý verzovaný snapshot, nikoli jako náhrada všech relačních vazeb.

Každá tabulka, která se může měnit, obsahuje minimálně:

- `created_at`,
- `updated_at`,
- `row_version`.

`row_version` se při každé doménově významné změně zvyšuje a připravuje data na pozdější sync, ale R1 jej zatím nepoužívá pro cloudovou autorizaci.

---

# 5. `local_workout_instances`

Tabulka vlastní naplánovaný workout a jeho stabilní snapshot.

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | WorkoutInstance ID |
| `title` | TEXT | ne | zobrazovaný název |
| `description` | TEXT | ano | stručný popis |
| `purpose` | TEXT | ano | účel workoutu |
| `workout_type` | TEXT | ne | stabilní typový kód |
| `scheduled_local_date` | TEXT | ne | datum pro Today/history |
| `scheduled_start_at` | INTEGER | ano | plánovaný UTC čas |
| `time_zone_id` | TEXT | ano | původní timezone |
| `planned_duration_seconds` | INTEGER | ano | plánovaná délka |
| `status` | TEXT | ne | `READY`, `IN_PROGRESS`, `PAUSED`, `COMPLETED`, `PARTIALLY_COMPLETED`, `SKIPPED`, `CANCELLED` |
| `source_type` | TEXT | ne | pro R1 typicky `DEMO`, `SEED`, `USER` |
| `source_reference` | TEXT | ano | stabilní reference na fixture nebo budoucí zdroj |
| `revision_number` | INTEGER | ne | snapshot revize, výchozí 1 |
| `started_session_id` | TEXT | ano | aktivní nebo poslední session |
| `completed_at` | INTEGER | ano | skutečné dokončení |
| `created_at` | INTEGER | ne | auditní čas |
| `updated_at` | INTEGER | ne | auditní čas |
| `row_version` | INTEGER | ne | optimistická lokální verze |

Constraints:

- `scheduled_local_date` musí mít validní formát,
- `planned_duration_seconds >= 0`,
- `revision_number >= 1`,
- `row_version >= 1`,
- `completed_at` smí být vyplněno pouze pro dokončený nebo částečně dokončený stav,
- jedna instance smí mít nejvýše jednu session ve stavu `ACTIVE` nebo `PAUSED`.

Indexy:

- `(scheduled_local_date, status)`,
- `updated_at`,
- `started_session_id`.

---

# 6. `local_workout_sections`

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | section ID |
| `workout_instance_id` | TEXT FK | ne | vlastník |
| `position` | INTEGER | ne | pořadí |
| `title` | TEXT | ne | název |
| `section_type` | TEXT | ne | např. `WARM_UP`, `MAIN`, `COOLDOWN` |
| `purpose` | TEXT | ano | účel |
| `priority` | TEXT | ne | `REQUIRED`, `HIGH`, `NORMAL`, `OPTIONAL` |
| `is_optional` | INTEGER | ne | volitelnost |
| `planned_duration_seconds` | INTEGER | ano | plán |
| `created_at` | INTEGER | ne | auditní čas |
| `updated_at` | INTEGER | ne | auditní čas |

Constraints:

- FK používá `ON DELETE CASCADE`,
- `position >= 0`,
- unikátní `(workout_instance_id, position)`,
- `planned_duration_seconds >= 0`.

---

# 7. `local_workout_steps`

Tabulka ukládá obecný workout krok a dostatečný offline snapshot.

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | step ID |
| `section_id` | TEXT FK | ne | vlastník |
| `parent_step_id` | TEXT FK | ano | jednoduchá kompozice |
| `position` | INTEGER | ne | pořadí mezi sourozenci |
| `step_type` | TEXT | ne | `EXERCISE`, `DURATION`, `REST`, `MOBILITY_POSITION`, `INSTRUCTION`, `CUSTOM` |
| `title` | TEXT | ne | offline název |
| `instructions` | TEXT | ano | offline instrukce |
| `purpose` | TEXT | ano | účel |
| `priority` | TEXT | ne | priorita |
| `is_skippable` | INTEGER | ne | zda lze přeskočit |
| `prescription_type` | TEXT | ne | např. `SET_REP`, `DURATION`, `COMPLETION_ONLY` |
| `planned_duration_seconds` | INTEGER | ano | časový předpis |
| `planned_distance_meters` | REAL | ano | vzdálenostní předpis |
| `planned_repetitions` | INTEGER | ano | jednoduchý předpis mimo sety |
| `planned_weight_kg` | REAL | ano | jednoduchý předpis |
| `metadata_json` | TEXT | ano | verzovaná malá typová metadata |
| `created_at` | INTEGER | ne | auditní čas |
| `updated_at` | INTEGER | ne | auditní čas |

Constraints:

- FK na section používá `ON DELETE CASCADE`,
- `parent_step_id` musí patřit do stejné section,
- krok nesmí být vlastním parentem,
- R1 podporuje maximálně jednu úroveň vnoření,
- unikátní `(section_id, parent_step_id, position)`,
- číselné plánované hodnoty nesmí být záporné,
- povinná pole se validují podle `prescription_type` v mapperu a aplikační službě.

---

# 8. `local_set_plans`

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | plán série |
| `workout_step_id` | TEXT FK | ne | EXERCISE krok |
| `position` | INTEGER | ne | pořadí série |
| `planned_repetitions` | INTEGER | ano | cílová opakování |
| `minimum_repetitions` | INTEGER | ano | spodní mez |
| `maximum_repetitions` | INTEGER | ano | horní mez |
| `planned_weight_kg` | REAL | ano | cílová zátěž |
| `planned_duration_seconds` | INTEGER | ano | časová série |
| `rest_after_seconds` | INTEGER | ano | plánovaný odpočinek |
| `target_rpe` | REAL | ano | cílové RPE |

Constraints:

- FK `ON DELETE CASCADE`,
- unikátní `(workout_step_id, position)`,
- všechny číselné hodnoty jsou nezáporné,
- `minimum_repetitions <= maximum_repetitions`,
- `target_rpe` je v rozsahu 0 až 10.

---

# 9. `local_workout_sessions`

Tabulka je autoritativní pro aktivní lokální průběh workoutu.

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | WorkoutSession ID |
| `workout_instance_id` | TEXT FK | ne | prováděná instance |
| `instance_revision_number` | INTEGER | ne | snapshot revize při startu |
| `status` | TEXT | ne | `ACTIVE`, `PAUSED`, `COMPLETED`, `ABANDONED` |
| `started_at` | INTEGER | ne | skutečný start |
| `last_resumed_at` | INTEGER | ano | poslední pokračování |
| `paused_at` | INTEGER | ano | začátek pauzy |
| `completed_at` | INTEGER | ano | dokončení |
| `active_step_id` | TEXT | ano | poslední otevřený krok |
| `elapsed_active_seconds` | INTEGER | ne | odolný čas bez pauz |
| `notes` | TEXT | ano | poznámka k session |
| `created_at` | INTEGER | ne | auditní čas |
| `updated_at` | INTEGER | ne | auditní čas |
| `row_version` | INTEGER | ne | verze |

Constraints:

- FK na instance používá `ON DELETE RESTRICT`,
- `elapsed_active_seconds >= 0`,
- `completed_at` je povinné pouze při `COMPLETED`,
- partial unique index zajistí nejvýše jednu `ACTIVE` nebo `PAUSED` session pro jednu instance,
- session se po dokončení běžně nemaže.

---

# 10. `local_step_performances`

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | výkon kroku |
| `workout_session_id` | TEXT FK | ne | session |
| `workout_step_id` | TEXT FK | ne | plánovaný krok |
| `status` | TEXT | ne | `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`, `PARTIAL`, `SKIPPED` |
| `started_at` | INTEGER | ano | start kroku |
| `completed_at` | INTEGER | ano | dokončení |
| `actual_repetitions` | INTEGER | ano | jednoduchý výkon |
| `actual_duration_seconds` | INTEGER | ano | skutečný čas |
| `actual_distance_meters` | REAL | ano | skutečná vzdálenost |
| `actual_weight_kg` | REAL | ano | skutečná zátěž |
| `perceived_exertion` | REAL | ano | RPE |
| `notes` | TEXT | ano | poznámka |
| `updated_at` | INTEGER | ne | poslední lokální zápis |
| `row_version` | INTEGER | ne | verze |

Constraints:

- unikátní `(workout_session_id, workout_step_id)`,
- FKs používají `ON DELETE CASCADE` ze session a `ON DELETE RESTRICT` ze step,
- číselné hodnoty jsou nezáporné,
- RPE je 0 až 10.

---

# 11. `local_set_performances`

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | výkon série |
| `step_performance_id` | TEXT FK | ne | vlastník |
| `set_plan_id` | TEXT FK | ano | původní plán |
| `position` | INTEGER | ne | pořadí |
| `status` | TEXT | ne | `PLANNED`, `COMPLETED`, `SKIPPED`, `ADDED` |
| `actual_repetitions` | INTEGER | ano | výkon |
| `actual_weight_kg` | REAL | ano | výkon |
| `actual_duration_seconds` | INTEGER | ano | výkon |
| `actual_rpe` | REAL | ano | RPE |
| `completed_at` | INTEGER | ano | čas dokončení |
| `notes` | TEXT | ano | poznámka |
| `updated_at` | INTEGER | ne | poslední změna |
| `row_version` | INTEGER | ne | verze |

Constraints:

- FK na step performance `ON DELETE CASCADE`,
- unikátní `(step_performance_id, position)`,
- přidaná série má `set_plan_id = NULL` a status `ADDED`,
- číselné hodnoty jsou nezáporné,
- RPE je 0 až 10.

---

# 12. `local_workout_feedback`

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | feedback ID |
| `workout_session_id` | TEXT FK UNIQUE | ne | jedna zpětná vazba na session |
| `overall_effort` | REAL | ano | RPE 0–10 |
| `feeling` | TEXT | ano | stabilní kód pocitu |
| `pain_reported` | INTEGER | ne | pouze flag v R1 |
| `notes` | TEXT | ano | volný text |
| `created_at` | INTEGER | ne | čas |
| `updated_at` | INTEGER | ne | čas |

R1 neimplementuje plný medicínský PainReport model. Pokud uživatel označí bolest, aplikace pouze bezpečně zobrazí konzervativní upozornění a zachová flag; diagnostika ani AI adaptace nejsou součástí R1.

---

# 13. `local_activity_summaries`

Po dokončení session vznikne minimální historický záznam.

| Sloupec | Typ | Null | Význam |
|---|---|---:|---|
| `id` | TEXT PK | ne | Activity ID |
| `workout_instance_id` | TEXT FK | ne | zdroj |
| `workout_session_id` | TEXT FK UNIQUE | ne | zdrojová session |
| `title_snapshot` | TEXT | ne | historický název |
| `workout_type` | TEXT | ne | typ |
| `started_at` | INTEGER | ne | start |
| `completed_at` | INTEGER | ne | konec |
| `active_duration_seconds` | INTEGER | ne | čistý čas |
| `completed_step_count` | INTEGER | ne | základní statistika |
| `total_step_count` | INTEGER | ne | základní statistika |
| `overall_effort` | REAL | ano | feedback snapshot |
| `created_at` | INTEGER | ne | vytvoření |

ActivitySummary je v R1 read model pro historii, nikoli celý budoucí Activity agregát. Musí být rekonstruovatelný ze session a performance dat.

---

# 14. `local_app_state`

Jednoúčelová key-value tabulka smí uchovávat pouze technický lokální stav:

- poslední otevřený route intent,
- aktivní session ID,
- verzi seed dat,
- čas posledního úspěšného maintenance běhu.

Nesmí v ní být skrytý business model workoutu.

Schema:

- `key TEXT PRIMARY KEY`,
- `value TEXT NOT NULL`,
- `updated_at INTEGER NOT NULL`.

---

# 15. Transakční hranice

Následující operace jsou atomické:

## 15.1 Start session

V jedné transakci:

1. ověřit, že instance není dokončená nebo zrušená,
2. ověřit, že neexistuje jiná aktivní session,
3. vytvořit WorkoutSession,
4. vytvořit výchozí StepPerformance a SetPerformance řádky podle snapshotu,
5. změnit instance status na `IN_PROGRESS`,
6. uložit aktivní session ID.

## 15.2 Zápis výkonu

V jedné transakci:

1. aktualizovat performance hodnotu,
2. zvýšit `row_version`,
3. aktualizovat session `updated_at`,
4. případně změnit stav kroku.

UI oznámí úspěch až po commitnutí transakce.

## 15.3 Dokončení workoutu

V jedné transakci:

1. validovat podporovaný stav session,
2. dopočítat dokončení kroků,
3. uložit feedback,
4. nastavit session `COMPLETED`,
5. nastavit instance `COMPLETED` nebo `PARTIALLY_COMPLETED`,
6. vytvořit nebo obnovit ActivitySummary,
7. vyčistit technický active-session pointer.

Opakované dokončení stejné session musí být idempotentní.

---

# 16. Repository a mapping hranice

Data vrstva poskytuje minimálně:

- `WorkoutInstanceRepository`,
- `WorkoutSessionRepository`,
- `WorkoutHistoryRepository`,
- `R1SeedRepository`,
- `LocalDatabaseMaintenance`.

Repository rozhraní patří do application nebo domain boundary podle skutečné potřeby. Drift implementace patří do data/infrastructure vrstvy.

Mapper musí:

- převádět stabilní enum kódy,
- odmítnout neznámou nepodporovanou schema variantu,
- zachovat plánované a skutečné hodnoty odděleně,
- nevystavovat Drift companion nebo row typy presentation vrstvě,
- nevytvářet tiché defaulty, které mění doménový význam.

---

# 17. Seed a demo data

R1 může obsahovat deterministický demo workout.

Seed musí být:

- verzovaný přes `seed_version`,
- opakovatelný bez duplicit,
- identifikovaný stabilními ID,
- bez osobních nebo produkčních dat,
- oddělený od schema migrací.

Novější seed verze nesmí přepsat session nebo uživatelsky změněnou instanci. Může přidat nový demo obsah nebo aktualizovat pouze dosud nepoužitý systémový fixture.

---

# 18. Migrace

Počáteční schema version je `1`.

Každá další verze musí:

1. mít explicitní migration step,
2. být testována z předchozí podporované verze,
3. zachovat aktivní session,
4. zachovat všechny zaznamenané performance hodnoty,
5. ověřit foreign keys po migraci,
6. aktualizovat schema version až po úspěšném dokončení.

Zakázáno je:

- destruktivní `drop and recreate` v produkčním buildu,
- ruční editování staré vydané migrace,
- tiché smazání neznámých řádků,
- označení migrace za úspěšnou před dokončením celé transakce.

---

# 19. Recovery a integrita

Při startu aplikace se kontroluje:

- podporovaná schema version,
- výsledek SQLite foreign-key check v diagnostickém nebo testovacím režimu,
- existence session označené jako aktivní,
- konzistence active-session pointeru,
- instance ve stavu `IN_PROGRESS` bez session,
- session `COMPLETED` bez ActivitySummary.

Bezpečné automatické opravy mohou:

- obnovit technický pointer z jediné aktivní session,
- rekonstruovat ActivitySummary z dokončené session,
- odstranit osiřelý nebusiness cache záznam.

Automatická oprava nesmí:

- smazat výkon uživatele,
- odhadnout chybějící repetitions nebo weight,
- označit workout za dokončený bez potvrzených dat,
- přepsat více konfliktních aktivních sessions bez explicitního recovery flow.

Při neřešitelné integritní chybě aplikace zachová databázi, zobrazí bezpečný recovery stav a nabídne export diagnostických metadat bez citlivého payloadu.

---

# 20. Mazání a retence v R1

R1 nemá účet ani cloudovou retention policy.

Platí:

- odstranění neprovedené demo instance může cascade smazat její strukturu,
- instance s existující session se běžně nemaže; může být skryta nebo archivována,
- dokončená session a performance data se nemažou jako vedlejší efekt editace plánu,
- reset demo dat musí vyžadovat explicitní potvrzení a nesmí být zaměněn za běžnou migraci,
- uninstall aplikace je platformní odstranění lokálních dat a není aplikačním deletion workflow.

---

# 21. Minimální dotazy R1

Schema musí efektivně podporovat:

- workouty podle lokálního data,
- dnešní neukončené workouty,
- načtení celé struktury jedné instance,
- nalezení aktivní session,
- načtení session se všemi performance řádky,
- historii dokončených workouts se stránkováním,
- poslední výkon konkrétního step snapshotu, pokud bude použit pro jednoduché předvyplnění.

R1 nesmí zavádět denormalizované tabulky pouze kvůli hypotetické budoucí analytice.

---

# 22. Testovací minimum

Před implementačním označením schema musí existovat testy pro:

- vytvoření databáze od verze 1,
- všechny constraints a foreign keys,
- idempotentní seed,
- start session transakci,
- zápis setu po restartu repository,
- pause/resume,
- dokončení a idempotentní opakování,
- rekonstrukci ActivitySummary,
- recovery aktivní session,
- migraci alespoň na syntetické následující schema ve frameworkovém testu,
- query plan hlavních Today a history dotazů na realistickém R1 datasetu.

---

# 23. Pravidla fyzického modelu

## PDR-001

R1 používá lokální SQLite databázi přes Drift a není závislý na backendu.

## PDR-002

WorkoutInstance ukládá stabilní snapshot plánované struktury; nesmí být při zobrazení závislý pouze na externí šabloně.

## PDR-003

Plánované a skutečné hodnoty musí být uloženy odděleně.

## PDR-004

Uživatel smí dostat potvrzení zápisu až po úspěšném commitnutí lokální transakce.

## PDR-005

Pro jednu WorkoutInstance smí existovat nejvýše jedna aktivní nebo pozastavená WorkoutSession.

## PDR-006

Start, zápis výkonu a dokončení session mají explicitní atomické transakční hranice.

## PDR-007

Dokončení session musí být idempotentní a nesmí vytvořit duplicitní ActivitySummary.

## PDR-008

Drift řádky a persistence DTO nesmí pronikat do presentation vrstvy ani určovat doménový význam.

## PDR-009

Lokální migrace musí zachovat aktivní session a všechny potvrzené performance záznamy.

## PDR-010

Seed je verzovaný, idempotentní a nesmí přepsat uživatelská data.

## PDR-011

Historická session musí zůstat interpretovatelná z uloženého snapshotu i po změně katalogu nebo zdroje workoutu.

## PDR-012

Recovery nesmí odhadovat ani tiše přepisovat chybějící business hodnoty.

## PDR-013

JSON metadata musí být malá, verzovaná a typově validovaná; nesmí nahrazovat celý relační model.

## PDR-014

Schema nesmí předčasně implementovat cloudový sync, identity nebo AI persistence, ale nesmí jim ani znemožnit pozdější doplnění stabilních ID a row versions.

## PDR-015

Každá změna schématu vyžaduje migraci, migration test a aktualizaci tohoto dokumentu nebo navazujícího vlastnícího kontraktu.

---

# 24. Exit criteria

Dokument je připravený pro implementaci R1, pokud:

- názvy Drift tabulek a sloupců odpovídají tomuto kontraktu nebo je odchylka přijata změnou dokumentu,
- doménové enum kódy jsou sladěny s workout modelem a glossary,
- transakční hranice mají integrační testy,
- aktivní session přežije restart aplikace,
- potvrzený set ani dokončený workout se po pádu neztratí,
- schema migration test prokáže zachování kritických dat,
- R1 vertical-slice plan odkazuje na tento dokument.
