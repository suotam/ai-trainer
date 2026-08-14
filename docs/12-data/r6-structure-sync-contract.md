# AI Trainer – R6 Workout Structure Sync Contract (C43)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r6-structure-sync-contract.md`
**Vlastník:** Data Architecture + Backend + Mobile
**Kontraktní ID:** C43 (dle `docs/13-delivery/r6-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/r3-sync-extension-contract.md` (C24 — SXC-010 dluh), `docs/07-backend/r6-pull-sync-contract.md` (C41), `docs/06-domain/r6-pull-merge-contract.md` (C42), `docs/12-data/r1-physical-data-model.md`, `docs/12-data/r2-server-data-model.md` (C6 §8.4)
**Navazující dokumenty:** implementace R6-03, C44 (tombstony), C45 (restore — historie)
**Vlastněné pojmy nebo kontrakty:** struktura v instance payloadu, rekonstrukce při pull, rozšíření pull scope o závislé typy a pravidla `WSS-001` až `WSS-015`

---

# 1. Purpose

Splacení **SXC-010**: ruční/AI workout je plnohodnotná R1 struktura (sekce → kroky → set plány) — bez ní je obnova instance tichá lež. Struktura cestuje **uvnitř instance payloadu** (žádné nové serverové tabulky, C6 §8.4 kostra trvá) a pull ji deterministicky rekonstruuje. Zároveň se pull scope rozšiřuje o typy závislé na instancích (`MANUAL_ACTIVITY`, `CALENDAR_CHANGE`).

**Blocking pro `R6-03`.**

# 2. Tvar payloadu

- `WORKOUT_INSTANCE` payload se rozšiřuje o pole **`structure`**: `{ sections: [ …řádky sekcí…, každá se `steps: [ …řádky kroků…, každý se `setPlans: [ …řádky set plánů… ] ] ] }`.
- Děti cestují jako **syrové sloupcové mapy** (přesné `row.data` lokální DB, deterministicky řazené dle `position`, sekundárně `id`) — aplikace je triviální inverz bez field-driftu; parent FK sloupce jsou v mapách obsažené a při rekonstrukci se používají beze změny (client-generated ID se zachovávají, SDM-005).
- Server payload dál nevykládá (C6 §8.4) — `structure` je pro něj neprůhledná část JSONB.

# 3. Rekonstrukce při pull

- Root instance se řídí **C42 merge maticí beze změny** (SYNCED/DIRTY/verze pravidla platí na celé instanci vč. struktury).
- Při aplikaci instance (INSERT i UPDATE) se struktura **rekonstruuje celá**: smazat lokální sekce instance (kaskáda odstraní kroky/sety) a vložit ze `structure` — state-based, deterministické, idempotentní.
- Chybějící `structure` v payloadu (data pushnutá před C43) = instance bez struktury — **poctivý stav**, žádné dopočítávání; re-push z původního zařízení strukturu doplní.
- Pull scope se rozšiřuje o `WORKOUT_INSTANCE`, `MANUAL_ACTIVITY`, `CALENDAR_CHANGE` (v tomto pořadí za plochými typy — FK prerekvizity); R1 historie (sessions/performances/feedback/summaries) vlastní C45.

# 4. Invarianty (`WSS`)

- **WSS-001 — Struktura uvnitř instance payloadu**; žádné nové serverové tabulky ani sync typy.
- **WSS-002 — Syrové sloupcové mapy** (§2) — aplikace je inverz serializace; žádná interpretace, přejmenovávání ani dopočty.
- **WSS-003 — C42 matice platí na root** — struktura nikdy nepřepíše instanci v LOCAL_ONLY/DIRTY stavu.
- **WSS-004 — Rekonstrukce celá a atomická** (§3) v transakci batch; žádná částečná struktura.
- **WSS-005 — Deterministické řazení** dětí (position, id) v serializaci i rekonstrukci.
- **WSS-006 — Client ID se zachovávají** (SDM-005) — sekce/kroky/sety mají po obnově identická ID.
- **WSS-007 — Idempotence**: opakovaná aplikace téže verze = no-op (root no-op ⇒ struktura se nedotýká).
- **WSS-008 — Chybějící struktura je poctivý stav** (§3) — nikdy syntetická MAIN sekce ani dopočet.
- **WSS-009 — Obnovený workout drží R1 flow** — start session/performance vrstva funguje nad rekonstruovanou strukturou beze změny.
- **WSS-010 — Závislé typy po prerekvizitách** (pořadí §3); selhání FK zůstává typovaný skip (PMS-009).
- **WSS-011 — Push sémantika beze změny** — struktura jen rozšiřuje payload; outbox/idempotence/verze nedotčené.
- **WSS-012 — Bez PII navíc** — struktura nese jen existující R1 pole (instructions/poznámky kroků jsou už dnes lokální doménová data téhož uživatele).
- **WSS-013 — SXC-010 splacen** tímto kontraktem; C24 dluh se v evidenci uzavírá (zbývá DELETE — C44).
- **WSS-014 — Rozšíření jen kontraktem** (další children typy, historie — C45).
- **WSS-015 — Evidence.** Testy: push payload se strukturou (řazení, přesné mapy), round-trip na druhou DB s byte-ekvivalentní strukturou, R1 flow na obnoveném workoutu, aktivity+kalendářní změny po instancích, idempotence, chybějící struktura poctivě; flaky ≠ zelený důkaz.

# 5. Ready condition

C43 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R6-03` `READY`**.
