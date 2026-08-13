# AI Trainer – R5 DailyCheckIn Contract (C33)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r5-daily-checkin-contract.md`
**Vlastník:** Domain (recovery-and-limitations-model §5–§6) + Mobile + Data Architecture
**Kontraktní ID:** C33 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/recovery-and-limitaitons-model.md` (§5 DailyCheckIn, §6 typy, §7 únava, §9+ bolest), `docs/12-data/r3-mobile-schema-migration.md` (C16 vzor), `docs/06-domain/r3-sync-extension-contract.md` (C24 vzor), `docs/06-domain/r2-account-attach-contract.md` (C15), `docs/13-delivery/r5-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R5-01, C34 (safety rules čtou check-iny), C36 (agregáty do AI kontextu)
**Vlastněné pojmy nebo kontrakty:** P0 tvar `DailyCheckIn`, denní klíč a editace, persistence, sync rozšíření o `DAILY_CHECK_IN` a pravidla `DCI-001` až `DCI-015`

---

# 1. Purpose

DailyCheckIn je **strukturovaný subjektivní denní záznam stavu** — základní vstup adaptivního plánování (R5). P0 je vědomá podmnožina modelu §5: jeden záznam na den s jasně definovanými škálami; typy check-inů (§6), FatigueReport a plné pain workflow jsou budoucí kontrakty.

**Blocking pro `R5-01`.**

# 2. P0 tvar

| Pole | Typ | Pravidlo |
|---|---|---|
| `id` | client-generated ID | stabilní, nikdy se nerecykluje |
| `localDate` | `yyyy-MM-dd` | **denní klíč**: nejvýše jeden záznam na den a vlastníka |
| `energyLevel` | int 1–5 | povinné (1 = velmi nízká, 3 = běžná, 5 = velmi vysoká) |
| `fatigueLevel` | int 1–5 | povinné (1 = téměř žádná, 5 = velmi vysoká) |
| `sleepQuality` | int 1–5 | volitelné |
| `painLevel` | int 1–5 | volitelné; hlášení bolesti |
| `painAreaCode` | stabilní kód | povinné právě když je `painLevel` vyplněno (např. `SHOULDER`, `KNEE`, `BACK`, `ELBOW`, `WRIST`, `ANKLE`, `HIP`, `NECK`, `OTHER`) |
| `note` | text | volitelné; **výhradně lokální** — nikdy do sync payloadu ani AI kontextu (DCI-006) |

Sémantika škál je součást kontraktu (model §5.3) — hodnota bez významu je zakázaná.

# 3. Persistence a operace

- Nová tabulka `local_daily_check_ins` (mobilní schema bump dle C16): pole §2 + `createdAt`/`updatedAt`/`rowVersion` + owner/sync metadata (born ownable & syncable, R3M-004).
- **Denní klíč vynucuje repository v transakci** (ne DB unique index — kolidoval by s C15 attach přepisem vlastníka, vzor MPC-002): zápis pro den, kde už vlastník záznam má, je **update téhož záznamu** (`rowVersion+1`, `SYNCED → DIRTY`).
- Čtení: záznam pro den; historie řazená `localDate` sestupně, sekundárně `id` (deterministicky, APL-012 vzor).
- Žádné mazání v P0 — check-in je append-only denní historie (oprava = editace dne).

# 4. Sync a attach

- Nový sync typ **`DAILY_CHECK_IN`** (C24 vzor): bez serverového parenta, tabulka `synced_daily_check_in` (Flyway V6, C6 §8.4 kostra — JSONB payload neprůhledný), OpenAPI entityType rozšířen, pořadí v batchi za stávajícími typy.
- **Payload bez `note`** (DCI-006) a bez owner/sync metadat — jen pole §2 mimo note + `rowVersion`.
- **Attach s kolizním pravidlem denního klíče** (C15/C24 vzor): anonymní záznam dne, pro který už účet záznam má, **zůstává anonymní** (nikdy se nemaže ani nemerguje); ostatní se přepíší na účet.

# 5. Invarianty (`DCI`)

- **DCI-001 — Volitelnost.** Check-in není nikdy povinný pro žádnou funkci aplikace (model §5.4); chybějící check-in je validní typovaný stav.
- **DCI-002 — Denní klíč.** Nejvýše jeden záznam na den a vlastníka; opakovaný zápis dne = editace (§3), nikdy druhý záznam ani tichá ztráta.
- **DCI-003 — Definované škály.** Hodnoty výhradně 1–5 s významem dle §2; mimo rozsah = typované odmítnutí.
- **DCI-004 — Bolest strukturovaně.** `painLevel` vždy s `painAreaCode` ze stabilní množiny; volný text není nosič bolesti.
- **DCI-005 — Born ownable & syncable.** Owner stamping při zápisu, sync metadata od vzniku, attach v témže slice (R3M-004/006).
- **DCI-006 — Note nikdy neopouští zařízení.** Poznámka není v sync payloadu ani v AI kontextu (C36 ji zdědit nesmí); marker test povinný.
- **DCI-007 — Deterministické čtení** dle §3; poctivý empty stav.
- **DCI-008 — Žádné mazání v P0**; editace dne je jediná oprava.
- **DCI-009 — Sync přes existující mechanismus** (C10/C24) — žádný nový endpoint, žádná změna sémantiky; `DAILY_CHECK_IN` je aditivní typ.
- **DCI-010 — Attach kolize dle §4**; kolidující anonymní den se nikdy nemaže, nemerguje ani nepřepisuje účtu.
- **DCI-011 — Offline-first.** Zápis i čtení plně offline; síť jen existující push.
- **DCI-012 — Žádná PII navíc.** Check-in nenese jméno, polohu, zdravotní identifikátory ani volné texty mimo lokální `note`.
- **DCI-013 — Bez interpretace.** Persistence nehodnotí stav (žádné „dobrý/špatný den") — interpretace patří C34/C35.
- **DCI-014 — UI poctivě.** Dnešní check-in je editovatelný s viditelnými uloženými hodnotami; beta charakter subjektivních dat bez medicínských tvrzení (R5P-003).
- **DCI-015 — Evidence.** Testy: denní klíč (insert/edit/DIRTY), škály a pain vazba, attach kolize, migrace, sync payload bez note (marker), backend registr + řazení; flaky ≠ zelený důkaz.

# 6. Ready condition

C33 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-01` `READY`**.
