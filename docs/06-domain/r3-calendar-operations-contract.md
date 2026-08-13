# AI Trainer – R3 Calendar Operations Contract (C21)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r3-calendar-operations-contract.md`
**Vlastník:** Domain (scheduling-model + workout-model) + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C21 (dle `docs/13-delivery/r3-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/r3-manual-plan-contract.md` (C20), `docs/06-domain/scheduling-model.md` (§6), `docs/06-domain/workout-model.md`, `docs/12-data/r1-physical-data-model.md`, `docs/12-data/r3-mobile-schema-migration.md` (C16), `docs/12-data/r2-local-to-account-migration-contract.md` (C15), `docs/13-delivery/r3-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`
**Navazující dokumenty:** implementace R3-05, C24 (sync extension — evidence a CANCELLED přenos), R5 kontrakty (adaptace dne čtou evidence)
**Vlastněné pojmy nebo kontrakty:** bezpečné kalendářní operace nad ručně plánovanými workouty — přesun, zrušení, nahrazení, append-only evidence změn (`CalendarChange`), stav `CANCELLED` a pravidla `CAL-001` až `CAL-015`

---

# 1. Purpose

## 1.1 Proč tento kontrakt existuje

R3-05 dává uživateli bezpečné operace nad plánovaným workoutem: **přesun** na jiný den, **zrušení** a **nahrazení** jiným workoutem — bez ztráty historie a bez dotyku dokončených výsledků. Scheduling model definuje stavové pojmy (`CANCELLED`, §6.8); tento dokument určuje závaznou P0 sémantiku operací, jejich guardy a **append-only evidenci změn**.

## 1.2 Owner a vztah ke zdrojům

**Domain (scheduling-model + workout-model) + Mobile.** R1 fyzický model instancí zůstává autoritativní; C21 přidává operace a evidenci, nemění fakta.

## 1.3 Které slices blokuje

**Blocking pro `R3-05`** (spolu s C16 rozšířením o evidence tabulku).

---

# 2. Scope

## 2.1 Co C21 řeší

- operace přesun/zrušení/nahrazení (§4), povolené stavy a guardy (§5),
- append-only evidenci změn (§6), chování kalendářních read modelů pro `CANCELLED` (§7),
- ownership/sync/attach (§8), invarianty `CAL-001..015` (§9), testy (§10), Ready podmínku (§11).

## 2.2 Co C21 výslovně neřeší (non-goals R3)

- **operace nad seed/demo instancemi** — P0 operace jsou scoped na `source_type = USER_PLAN` (řízené rozhodnutí: seed je demo obsah, ne uživatelský plán; zrušení demo workoutu není P0 potřeba),
- hromadné operace, přeplánování týdne, drag&drop,
- editaci obsahu instance (název/cviky) — nahrazení je kanonická cesta ke „změně obsahu",
- undo/redo (zrušení je vratné jen nahrazením/novým workoutem; evidence je jednosměrná),
- AI návrhy náhrad (R5 adaptace).

---

# 3. Základní principy

1. **Fakta jsou nedotknutelná** — operace jsou povoleny jen na budoucích/nezapočatých instancích; jakmile existuje session, instance je fakt a operace jsou typovaně odmítnuty (R3P-006).
2. **Append-only evidence** — každá operace zapíše záznam kdo/kdy/co (`CalendarChange`); žádné tiché přepsání (R3P-007).
3. **Zrušení je stav, ne mazání** — `CANCELLED` instance zůstává v DB s celou strukturou; mizí z kalendářních přehledů, ne z historie záměrů.
4. **Nahrazení = zrušení + nový workout** v jedné transakci, s evidencí vazby na náhradu.
5. **Offline a bez AI.**

---

# 4. Operace (kontraktně)

## 4.1 Přesun (`MOVED`)

Změní `scheduled_local_date` instance na cílový den (`YYYY-MM-DD`). Verze instance +1, `SYNCED→DIRTY`. Evidence nese původní i cílové datum. Přesun na stejné datum je idempotentní no-op (bez evidence).

## 4.2 Zrušení (`CANCELLED`)

Přepne status instance na **`CANCELLED`** (scheduling model §6.8; R1 fyzický model množinu statusů nevynucuje — kód je tímto kanonický). Struktura instance zůstává beze změny. Opakované zrušení je idempotentní no-op. Verze +1, `SYNCED→DIRTY` (stav se synchronizuje existujícím push).

## 4.3 Nahrazení (`REPLACED`)

V jedné transakci: (a) původní instance → `CANCELLED`, (b) vytvoření nové instance stejnou cestou jako C20 `addWorkout` (plná R1 struktura, tentýž plán), (c) evidence s referencí na náhradní instanci. Selhání = žádný částečný stav.

---

# 5. Povolené stavy a guardy

Operace jsou povoleny právě tehdy, když instance:

- má `source_type = USER_PLAN` (§2.2 řízené rozhodnutí),
- patří aktuálnímu lokálnímu vlastníkovi,
- **nemá žádnou session** (`started_session_id IS NULL` a neexistuje session řádek) a není `COMPLETED`/`PARTIALLY_COMPLETED`,
- pro přesun/nahrazení navíc není `CANCELLED` (zrušenou instanci nelze přesouvat; nahradit ji lze novým workoutem přes C20 `addWorkout`).

Porušení guardu je **typovaný výsledek**, nikdy tichý úspěch ani výjimka.

---

# 6. Append-only evidence (`CalendarChange`)

Nová tabulka evidence změn — **append-only fakta** (nikdy UPDATE/DELETE):

- reference na instanci, **typ změny** (`MOVED`/`CANCELLED`/`REPLACED`),
- pro `MOVED`: původní a cílové datum; pro `REPLACED`: reference na náhradní instanci,
- časová značka, owner/sync metadata (born ownable and syncable, C16 §6).

Evidence umožňuje historickou interpretaci plánu („co bylo v plánu původně") a je budoucím vstupem R5 adaptací.

---

# 7. Kalendářní read modely a `CANCELLED`

**Aditivní rozhodnutí C21:** kalendářní přehledy (Today, weekly range) **vylučují `CANCELLED` instance** — zrušený workout není dnešní plán. Jde o jedinou (aditivní, filtrovací) změnu R1 read modelu; detail podle ID zůstává dostupný (bezpečná read-only prezentace), editor plánu zrušené workouty zobrazuje se stavem. Historie dokončených workoutů se nemění vůbec.

---

# 8. Ownership, sync a attach

- Evidence razí vlastníka při zápisu; **attach bezpodmínečný** (append-only uživatelská fakta, žádné cross-owner invarianty).
- Instance změněné operacemi se synchronizují existujícím push (UPDATE s novým datem/statusem); evidence tabulka se do registru přidá v C24 (evidované rozhodnutí).

---

# 9. Invarianty (`CAL`)

- **CAL-001 — Jen USER_PLAN.** Operace jsou scoped na ručně plánované instance; seed/demo je v P0 read-only.
- **CAL-002 — Fakta nedotknutelná.** Instance se session nebo dokončená je pro operace typovaně odmítnuta; výsledky a historie se nemění byte-po-bytu.
- **CAL-003 — Append-only evidence.** Každá provedená operace zapíše CalendarChange; evidence se nikdy needituje ani nemaže.
- **CAL-004 — Zrušení je stav.** `CANCELLED` nechává strukturu instance beze změny; žádné mazání.
- **CAL-005 — Atomické nahrazení.** Zrušení originálu + vytvoření náhrady + evidence v jedné transakci.
- **CAL-006 — Idempotence.** Přesun na stejné datum a zrušení zrušené instance jsou no-op bez duplicitní evidence.
- **CAL-007 — Typované guardy.** Nevalidní cíl (datum, stav, vlastnictví, source) je typovaný výsledek, nikdy výjimka ani tichý úspěch.
- **CAL-008 — CANCELLED mimo kalendář.** Kalendářní přehledy zrušené instance vylučují; detail podle ID a editor plánu je zobrazují.
- **CAL-009 — Sync disciplína.** Operace zvyšují verzi instance a přepínají `SYNCED→DIRTY`; potvrzení vlastní existující R2 mechanismus.
- **CAL-010 — Evidence born ownable.** CalendarChange má owner/sync metadata od vzniku; attach bezpodmínečný.
- **CAL-011 — Náhrada je plnohodnotná.** Náhradní instance vzniká C20 cestou (READY/USER_PLAN, plná struktura) a podléhá týmž pravidlům.
- **CAL-012 — Deterministické read modely.** Evidence instance řazena časem; editor plánu řadí dle C20 (MPC-013) vč. zrušených se stavem.
- **CAL-013 — Offline first.**
- **CAL-014 — Bez AI.**
- **CAL-015 — Evidence testů.** Persistence/guard/immutability/attach testy dle C16 §8; flaky ≠ zelený důkaz.

---

# 10. Testing requirements a evidence

1. Persistence testy: move (datum + evidence + DIRTY), cancel (stav + evidence + idempotence), replace (atomicky: originál CANCELLED, náhrada plná struktura, evidence s referencí).
2. Guard testy: instance se session, dokončená, cizí, seed/DEMO a nevalidní datum — typovaně odmítnuto; data byte-po-bytu nedotčená.
3. Read model testy: CANCELLED mimo Today/range; v editoru plánu viditelná se stavem.
4. Attach test: evidence se připojuje bezpodmínečně.
5. Migrační test vN→vN+1 od reálného stavu (řetěz v1→v9) + drift-check; R1/R2 regression zelené.

---

# 11. Ready condition

## 11.1 Kdy je C21 Done

C21 je Done, právě když definuje operace (§4), guardy (§5), evidenci (§6), read model chování (§7), ownership/attach (§8), invarianty `CAL-001..015` (§9) a testy (§10), a je zapsán v `docs/README.md` a `DOCUMENTATION_STATUS.md`. Tyto podmínky jsou vytvořením dokumentu splněny; C21 je **Done**.

## 11.2 Co C21 odblokuje

Spolu s C16 (evidence tabulka) činí **`R3-05 – Calendar Operations: Move, Cancel, Replace` `READY`**.
