# AI Trainer – R2 Idempotency Contract (C11)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/12-data/r2-idempotency-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Backend Architecture
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C11 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sync-and-offline-model.md` (§21.1, §22), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/12-data/r2-server-data-model.md` (C6), `docs/12-data/data-architecture.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-05, C12 conflict/rejection, C15 local-to-account migration
**Vlastněné pojmy nebo kontrakty:** R2 replay protokol (IdempotencyRecord, `ALREADY_APPLIED`, stejný klíč s jiným payloadem, expirace) a pravidla `IDC-001` až `IDC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Domain (sync-and-offline-model) + Backend Architecture.** Offline vytvořená operace může být odeslána vícekrát (timeout, restart uprostřed push, retry po výpadku). Aby opakování **nikdy nevytvořilo duplicitu** a klient dostal deterministický výsledek, potřebuje R2 jediný kanonický replay protokol. Tímto je C11. R2-02 zavedl baseline (`idempotency_record` pro registraci účtu); C11 jej povyšuje na obecný R2 protokol pro sync operace.

C11 je **contract-only**: bez SQL, bez kódu; úložiště vlastní C6, transport C10/C4.

## 1.2 Které slices blokuje

- **Blocking pro `R2-05`** (spolu s C10, rozšířením C6 a sync částí C14).
- Garantován pro R2-07 (attach replay — C15 na C11 staví, plán §9.7).

---

# 2. Scope

## 2.1 Co C11 řeší

- **identitu operace** — idempotency key (§4),
- **IdempotencyRecord** — obsah a lifecycle (§5),
- **replay rozhodnutí** — `ALREADY_APPLIED`, stejný klíč s jiným payloadem, souběh (§6),
- **expirace záznamů** (§7),
- invarianty `IDC-001…IDC-015` (§8), hranice (§9), testing/evidence (§10–§11), Ready (§12).

## 2.2 Co C11 neřeší

- **generování klíče na klientu** — C2 (`LSM-008/009` — stabilní klíč vzniká s outbox položkou),
- **transport klíče** — C10 (sync push) a C4 (`Idempotency-Key` header registrace),
- **schéma tabulky** — C6 (§7.5 baseline + §8.5 rozšíření),
- **konflikt verzí entit** — C10 §10 / C12 (version conflict není replay),
- **retry policy/backoff** — mimo R2 (`SPC-015`).

---

# 3. Source of truth and precedence

1. **Doménový model** — `sync-and-offline-model §21.1/§22` (ALREADY_APPLIED, IdempotencyRecord, „rozdílný payload se stejným klíčem musí být odmítnut").
2. **Lokální klíč** — C2 (`LSM-008` stabilní klíč, `LSM-009` idempotentní enqueue).
3. **Bezpečnost** — `SAR-011` (bezpečný offline replay), `SAR-001` (default deny).
4. **Protokoly** — C10 (sync), C4 (auth API).

C11 vlastní **replay rozhodovací pravidla** a `IDC-*`.

---

# 4. Identita operace

- **Idempotency key je client-generated, stabilní a unikátní per logická operace** (C2 `LSM-008`): vzniká jednou s outbox položkou (resp. s registračním pokusem u C4) a **nemění se přes retry** — ani po restartu, ani po výpadku sítě.
- Klíč je **ne-secret technická hodnota**; nesmí být odvozen z hesla ani tokenu.
- Jeden klíč patří **právě jedné logické operaci** (`§22.3`); použití téhož klíče pro jinou operaci je chyba klienta a server ji odmítá (§6).
- Scope klíče je **účet** (server rozlišuje záznamy per account — cizí účet se stejným klíčem je nezávislá operace; žádný cross-account únik informace).

---

# 5. IdempotencyRecord (kontraktně, dle `§22.2`)

Server ukládá pro každou poprvé zpracovanou operaci:

- `idempotencyKey` + `accountId` (unikátní pár),
- `operationType` (registrace / sync operace typu dle C10 §5),
- **`requestHash`** — deterministický otisk payloadu pro detekci „stejný klíč, jiný payload" (bez citlivého obsahu; hesla se do hash nezahrnují — R2-02 vzor: otisk subjektu + ověření credentialu),
- `finalStatus` — konečný per-item výsledek (C10 §7),
- `resultReference` — technická reference výsledku (entity ID + serverVersion), aby replay vrátil **původní logický výsledek** (`§21.1`),
- `firstProcessedAt`, `expiresAt` (§7).

Záznam vzniká **atomicky ve stejné transakci** jako aplikace operace (§6) — nikdy nemůže existovat commitnutá změna bez záznamu ani záznam bez změny.

---

# 6. Replay rozhodnutí

Pro příchozí operaci s klíčem K účtu A:

1. **Záznam neexistuje** → operace se zpracuje (validace, ownership, verze — C8/C10) a v téže transakci se uloží IdempotencyRecord s výsledkem.
2. **Záznam existuje a `requestHash` souhlasí** → **`ALREADY_APPLIED`**: server nevykoná žádný vedlejší efekt a vrátí původní logický výsledek (`finalStatus` + `resultReference`). Replay odmítnuté operace vrací původní odmítnutí (replay nemění rozhodnutí).
3. **Záznam existuje a `requestHash` nesouhlasí** → **odmítnutí jako chyba klienta** (`§22.3`): sync per-item `VALIDATION_FAILED` s bezpečným důvodem, C4 registrace `INVALID_REQUEST`. Původní záznam se nemění.
4. **Souběh dvou requestů se stejným klíčem** → unikátní constraint (C6) zajistí, že commitne právě jeden; druhý se vyhodnotí jako replay (případ 2/3). Klient nikdy nedostane dvě rozdílná „SUCCESS" s různým efektem.

Idempotence pokrývá **celou operaci včetně auditu**: replay generuje audit „idempotent replay" (C14 §7), ne druhý „applied" záznam.

---

# 7. Expirace

- IdempotencyRecord má `expiresAt`; retenční okno je implementační konfigurace s bezpečným minimem pokrývajícím realistické offline období (řádově měsíce, ne hodiny).
- Po expiraci smí být záznam odstraněn; replay po expiraci se chová jako nová operace — bezpečnost zajišťují ownership + verze (C8/C10 §10), pro `CREATE_ENTITY` navíc existence entity se stejným client ID (opakované vytvoření existující vlastní entity je `ALREADY_APPLIED`-ekvivalent nebo `VERSION_CONFLICT`, nikdy duplicita — SDM-006).
- Expirace se nikdy nepoužije k obejití odmítnutí (rejected zůstává rejected na klientu, dokud jej neřeší C12/uživatel).

---

# 8. Idempotency invariants (`IDC`)

Nová řada. Doplňuje, neoslabuje `LSM-*`, `SPC-*`, `AAC-*`, `SDM-*`.

- **IDC-001 — Klíč je stabilní.** Idempotency key vzniká jednou s logickou operací a nemění se přes retry/restart (`LSM-008`).
- **IDC-002 — Jeden klíč, jedna operace.** Tentýž klíč nesmí označovat dvě logicky různé operace (`§22.3`).
- **IDC-003 — Scope per účet.** Replay rozhodnutí se vyhodnocuje v prostoru účtu; žádný cross-account únik ani kolize.
- **IDC-004 — Záznam atomicky s efektem.** IdempotencyRecord commitá ve stejné transakci jako aplikace operace; neexistuje efekt bez záznamu ani záznam bez efektu.
- **IDC-005 — Replay bez vedlejších efektů.** `ALREADY_APPLIED` nevykonává žádnou změnu a vrací původní logický výsledek (`§21.1`).
- **IDC-006 — Replay nemění rozhodnutí.** Replay odmítnuté operace vrací původní odmítnutí; replay úspěchu původní úspěch.
- **IDC-007 — Jiný payload = chyba.** Stejný klíč s jiným `requestHash` je odmítnut jako chyba klienta; původní záznam se nemění (`§22.3`).
- **IDC-008 — Souběh commitne jednou.** Souběžné requesty se stejným klíčem vedou k právě jednomu efektu (unikátní constraint jako poslední linie, SDM-004).
- **IDC-009 — Hash bez secrets.** `requestHash` neobsahuje ani neodvozuje hesla/tokeny (`DAR-010`; R2-02 vzor).
- **IDC-010 — Deterministický hash.** `requestHash` je deterministický nad kanonickou reprezentací payloadu — stejný payload dá stejný hash na každém zařízení.
- **IDC-011 — Výsledek je reprodukovatelný.** `resultReference` umožňuje vrátit původní výsledek bez opětovného výpočtu; klient podle něj bezpečně potvrdí outbox (SPC-005).
- **IDC-012 — Expirace neobchází bezpečnost.** Po expiraci záznamu chrání duplicitu ownership, verze a client-ID existence (SDM-006); duplicitní entita nevznikne.
- **IDC-013 — Replay se audituje.** Idempotentní replay generuje audit záznam dle C14 §7, ne druhý „applied".
- **IDC-014 — Idempotence není autorizace.** Platný klíč nenahrazuje session, ownership ani validaci — vyhodnocují se vždy (`AOC-004`, `SAR-011`).
- **IDC-015 — Jednotný protokol.** Registrace účtu (C4/R2-02) i sync operace (C10/R2-05) používají tentýž rozhodovací protokol §6; nové operace jej přebírají kontraktem, ne ad-hoc implementací.

---

# 9. Interaction with other contracts

- **C2:** vlastní vznik a stabilitu klíče na klientu; C11 serverové rozhodnutí.
- **C4:** registrace účtu — `Idempotency-Key` header; R2-02 implementace je baseline instancí protokolu §6 (řízená odchylka R2-02: replay registrace vydává novou session — session issuance není vedlejší efekt operace „vznik účtu", účet nevzniká dvakrát).
- **C6:** §7.5/§8.5 úložiště záznamů (unikátní pár klíč+účet, výsledkové sloupce, expirace).
- **C10:** transport klíče v push operaci a `ALREADY_APPLIED` v per-item výsledcích.
- **C12 (forward):** version conflict a rejection resolution — nejsou replay; C11 na ně jen odkazuje výsledkem.
- **C14:** audit idempotent replay (§7).
- **C15 (forward):** attach používá tentýž protokol pro opakovatelné připojení dat bez duplicit (plán §9.7).

---

# 10. Testing requirements (kontraktně)

Implementace R2-05 musí ověřit (`QTR-004`):

1. **Druhý push stejné operace → `ALREADY_APPLIED`**, žádná duplicita, původní výsledek (vč. stejného `resultReference`).
2. **Stejný klíč, jiný payload → odmítnuto**; serverový stav i původní záznam nezměněny.
3. **Souběh** — paralelní push téhož klíče commitne právě jednou (unikátní constraint test).
4. **Replay odmítnuté operace** vrací původní odmítnutí, nevykonává efekt.
5. **Atomicita** — selhání aplikace operace nezanechá IdempotencyRecord (rollback obou).
6. **Hash bez secrets** — inspekce uložených záznamů.
7. **Cross-account** — stejný klíč pod jiným účtem je nezávislá operace.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 11. Evidence gates

Implementace R2-05 musí doložit replay/duplicate/souběh/atomicity testy nad skutečným PostgreSQL a traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 12. Ready condition

C11 je Done, právě když definuje: identitu operace (§4), IdempotencyRecord (§5), replay rozhodnutí (§6), expiraci (§7), invarianty `IDC-001…IDC-015` (§8), hranice (§9), testing/evidence (§10–§11); je zapsán v doc mapě a status auditu; a neobsahuje SQL ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C11 je **Done**.

**Dopad na R2-05:** spolu s C10 zbývá pro `R2-05` rozšíření C6 o synced entity a sync část C14.

---

# 13. References

- `docs/06-domain/sync-and-offline-model.md` — `§21.1` ALREADY_APPLIED, `§22` IdempotencyRecord (`§22.3` jiný payload).
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-008/009`.
- `docs/07-backend/r2-sync-protocol-contract.md` — C10; per-item výsledky, `SPC-005/007/012`.
- `docs/07-backend/r2-auth-api-contract.md` — C4; `AAC-005`.
- `docs/12-data/r2-server-data-model.md` — C6; §7.5, §8.5, `SDM-004/006`.
- `docs/11-security/security-architecture.md` — `SAR-011` bezpečný replay.
- `docs/11-security/r2-audit-event-contract.md` — C14 §7.
- `docs/14-quality/test-strategy.md` — `QTR-004/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-014`.
