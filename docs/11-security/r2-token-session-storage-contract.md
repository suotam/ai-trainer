# AI Trainer – R2 Token/Session Storage Contract (C7)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/11-security/r2-token-session-storage-contract.md`
**Vlastník:** Security + Mobile
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C7 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/11-security/security-architecture.md`, `docs/08-mobile/mobile-architecture.md`, `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/12-data/r2-local-sync-metadata-contract.md` (C2), `docs/12-data/r2-mobile-schema-migration.md` (C1), `docs/06-domain/sync-and-offline-model.md`, `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-03 (mobile auth + secure session storage), C13 token/session revocation, C15 local-to-account migration, C9 device registration
**Vlastněné pojmy nebo kontrakty:** klasifikace a umístění session materiálu na mobilním klientu, secure storage boundary, restart/logout/revocation chování uloženého session materiálu a pravidla `TSS-001` až `TSS-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Security + Mobile.** R2-03 přinese přihlášení na mobilu a přihlašovací stav, který přežije restart. Aby session materiál (access/refresh credential) nikdy neskončil v běžné SQLite, preferences, logu ani backupu a aby restart, logout i revokace měly předem definované bezpečné chování, potřebuje mobilní klient jediný kanonický storage kontrakt. Tímto je C7.

C7 je **contract-only**: definuje klasifikaci, hranice a pravidla; **neimplementuje** žádný plugin, adaptér, UI flow ani konkrétní platformní API.

## 1.2 Vztah k C3/C4

C3 vlastní **lifecycle** session (created/active/refreshed/expired/terminated); C4 vlastní **HTTP transport** credentials. C7 vlastní **kde a jak session materiál žije na zařízení** mezi těmito dvěma světy (`ISC-013` — session materiál je SECRET; mobilní úložiště vlastní C7).

## 1.3 Které slices blokuje

- **Blocking pro `R2-03 – Mobile Auth and Secure Session Storage`** (`r2-vertical-slice-plan §9.3`).
- Referencován pozdějšími slices: revokační chování klienta (C13/R2-06), device credential (C9/R2-04), local-to-account migrace (C15/R2-07).

---

# 2. Scope

## 2.1 Co C7 řeší

- **klasifikaci session materiálu** na klientu (§4),
- **secure storage boundary** — přístupové rozhraní a vlastnictví zápisu (§5),
- **restart chování** — obnova přihlašovacího stavu, fallback při nedostupném/poškozeném úložišti (§6),
- **logout a revocation interakci** se skladovaným materiálem (§7),
- **offline chování** uložené session (§8),
- invarianty `TSS-001…TSS-015` (§9), hranice (§10), testing/evidence (§11–§12), Ready (§13).

## 2.2 Co C7 výslovně neřeší

- **session lifecycle sémantiku** — C3,
- **auth API tvar a transport credentials po síti** — C4,
- **serverové uložení session** — C6,
- **login/logout UI a stavovou orchestraci** — implementace R2-03,
- **revokační operační flow** (revoke jiných/všech session) — C13; C7 definuje jen chování uloženého materiálu po revokaci,
- **algoritmus připojení lokálních dat k účtu** — C15,
- **device registration a device credential lifecycle** — C9 (C7 platí i pro budoucí device credential, ale registraci nevlastní),
- **konkrétní balíček/plugin/platformní API** (Keychain/Keystore wrapper) — implementační volba za boundary (§5),
- **biometrickou ochranu a recent authentication** — mimo R2 baseline (`security-architecture §7.1` forward),
- **šifrování lokální workout databáze** — mimo C7 (data classification vlastní security/mobile architektura).

---

# 3. Source of truth and precedence

Pořadí vlastnictví (vyšší platí při konfliktu):

1. **Bezpečnost** — `security-architecture.md`: `SAR-006` (secrets mimo klienta/žádné plaintext), `SAR-007` (revokovatelné session), `SAR-012` (bezpečné logování), `§7.2` (tokeny), `§7.3` (offline session).
2. **Identity/session sémantika** — **C3** (`ISC-002/003/007/009/012/013`).
3. **Mobilní architektura** — `mobile-architecture.md` `§22` (secure storage a lokální ochrana), `MAR-015` (nahraditelné adaptery).
4. **Lokální data a outbox** — **C2** (`LSM-006/010/011`), **C1** (mobilní schema — session materiál do něj nepatří).
5. **R2 pořadí a scope** — `r2-vertical-slice-plan.md` (§7.1 mapa, §9.3 R2-03).

C7 vlastní **konkrétní R2 storage pravidla** a `TSS-*`; body 1–5 pouze promítá, nepředefinovává.

---

# 4. Klasifikace session materiálu (kontraktně)

| Hodnota | Klasifikace | Kanonické umístění | Poznámka |
|---|---|---|---|
| **Heslo** | SECRET, transient | **nikde** — nikdy se neukládá | existuje jen v paměti během login/registrace; odchází výhradně přes C4 transport |
| **Refresh credential** | SECRET, persistent | **výhradně platformní secure storage** | jediná dlouhodobá credential na zařízení (`security §7.2` bezpečné uložení) |
| **Access credential** | SECRET, short-lived | in-memory; případná perzistence **jen** secure storage | krátce žijící (C3 §5); ztráta při restartu je bezpečná — obnoví ji refresh |
| **Session/account technická reference** (sessionId, accountId, expirace) | technická, ne-secret | běžný lokální stav (např. `local_app_state`) | nesmí obsahovat žádný credential materiál (§9 `TSS-012`) |
| **Principal context cache** (typ/stav účtu) | technická, ne-secret | běžný lokální stav | server-authoritative — jen cache, ne zdroj oprávnění (`ISC-003`) |

**Zakázaná umístění pro SECRET hodnoty** (vždy, bez výjimky): Drift/SQLite databáze (C1 schema), shared preferences, běžné soubory, log, analytika, crash report, URL, clipboard, notifikace, nechráněný backup/export (`mobile-architecture §22`, `SAR-006/012`, `r2-vertical-slice-plan §10` bod 8).

---

# 5. Secure storage boundary

- Session materiál je přístupný **výhradně přes nahraditelné rozhraní** (port/adaptér, `MAR-015`); UI ani feature kód nepřistupuje k platformnímu úložišti přímo.
- **Jeden zapisující vlastník**: session materiál spravuje jediná auth session komponenta (composition root ji vlastní); ostatní vrstvy dostávají jen odvozený autentizační stav.
- Adaptér je v testech **nahraditelný fake** — testy nesmí vyžadovat reálný Keychain/Keystore (`QTR-003`).
- Konkrétní platformní mechanismus (Keychain, Keystore, jejich wrapper) je **implementační volba za boundary** — C7 ji nerozhoduje; volba nesmí oslabit pravidla §4.
- Boundary zveřejňuje **atomické operace** uložit/načíst/smazat session materiál; částečně zapsaný stav nesmí být čitelný jako platný.

---

# 6. Restart chování

- Po restartu aplikace se přihlašovací stav **obnovuje výhradně ze secure storage** (refresh credential + technické reference); obnova probíhá před rozhodnutím o chráněných operacích.
- **Anonymní stav je validní first-class výsledek** (`ISC-002`): chybějící session materiál znamená signed-out/anonymní režim, ne chybu — R1 offline tok funguje dál (`R2P-004`).
- **Nedostupné nebo poškozené secure storage** vede na **bezpečný signed-out fallback**: žádný pád, žádná ztráta lokálních workout dat, žádné tiché smazání outboxu; uživatel se může znovu přihlásit. Nekonzistentní zbytky session materiálu se bezpečně odstraní.
- Expirovaná access credential po restartu není chyba — obnoví ji refresh (C4 §7); expirovaná/neplatná refresh credential vede na signed-out stav se zachovanými lokálními daty.
- Restart **nikdy nevydává nové credentials sám o sobě** — vydává je jen server (C3 `ISC-003`).

---

# 7. Logout a revocation interakce

- **Logout** (C3 §6.2, C4 logout operace): klient odstraní **veškerý** session materiál ze secure storage i z paměti. Lokální workout data, historie, outbox a anonymní/local owner data **zůstávají** (`LSM-006`, `ISC-012`); odhlášení není smazání dat.
- Lokální odstranění materiálu proběhne **i když serverový logout selže nebo je offline** — lokální zneplatnění nesmí záviset na síti; serverová revokace se dokoná při nejbližší konektivitě (detail vlastní C13).
- **Po serverové revokaci** (`SESSION_REVOKED` z C4): uložený materiál **nesmí obnovit serverové oprávnění** (`ISC-009`, `security §7.3`); klient jej odstraní a přejde do bezpečného signed-out stavu; neodeslané změny zůstávají v srozumitelném recovery stavu (`LSM-010/011`), chráněné uploady se zastaví.
- Uložený session materiál **není důkaz platnosti** — platnost určuje výhradně server (`ISC-003/008`); storage je jen credential cache (§9 `TSS-011`).

---

# 8. Offline chování

- Platná lokální session smí zpřístupnit **dříve synchronizovaná data** podle platformního secure-storage kontraktu (`security §7.3`); síť není podmínkou čtení ani zápisu podporovaných lokálních operací (`R2P-004`).
- Po obnovení konektivity klient ověří pokračování session (session context / refresh dle C4), přijme revokace a změny oprávnění a při zamítnutí zastaví chráněné uploady (`security §7.3` kroky 1–4).
- Offline stav **neprodlužuje** platnost credentials a neobchází expiraci; rozhodnutí o platnosti zůstává serverové.

---

# 9. Storage invariants (`TSS`)

Nová řada. Doplňuje, neoslabuje `SAR-*`, `ISC-*`, `AAC-*`, `LSM-*`, `MSM-*`, `MAR-*`.

- **TSS-001 — Heslo se neukládá.** Heslo nikdy neperzistuje na zařízení (ani v secure storage); existuje jen transientně v paměti během auth operace.
- **TSS-002 — Refresh jen v secure storage.** Refresh credential žije výhradně v platformním secure storage; nikdy v Drift/SQLite, preferences, souboru ani jiném běžném úložišti.
- **TSS-003 — Access mimo běžné úložiště.** Access credential je default in-memory; případná perzistence výhradně secure storage. Ztráta access credential restartem je bezpečná.
- **TSS-004 — Žádný session materiál v logu.** Credential se neobjeví v logu, analytice, crash reportu, URL, clipboardu ani notifikaci (`SAR-012`).
- **TSS-005 — Boundary povinná.** Přístup k session materiálu jen přes nahraditelné rozhraní (`MAR-015`); žádný přímý přístup UI/feature kódu k platformnímu úložišti.
- **TSS-006 — Jeden zapisující vlastník.** Session materiál spravuje jediná auth session komponenta; ostatní vrstvy konzumují jen odvozený stav.
- **TSS-007 — Restart obnoví stav bezpečně.** Přihlašovací stav se po restartu obnovuje ze secure storage; chybějící materiál je validní anonymní stav (`ISC-002`), ne chyba.
- **TSS-008 — Fail-safe fallback.** Nedostupné/poškozené secure storage vede na bezpečný signed-out stav bez pádu a bez ztráty lokálních dat; nikdy na tiché smazání workout dat či outboxu.
- **TSS-009 — Logout čistí materiál, ne data.** Logout odstraní veškerý session materiál (i offline), lokální data a outbox zůstávají (`LSM-006`, `ISC-012`).
- **TSS-010 — Revokace není obnovitelná ze storage.** Uložený materiál po serverové revokaci neobnoví oprávnění (`ISC-009`); klient jej odstraní a zachová recovery stav neodeslaných změn (`LSM-010/011`).
- **TSS-011 — Storage není autorita.** Platnost session určuje server (`ISC-003/008`); uložený materiál je pouze credential cache.
- **TSS-012 — Technické reference bez credentialu.** SessionId/accountId/expirace jsou ne-secret technické hodnoty a nesmí obsahovat ani odvozovat credential materiál.
- **TSS-013 — Backup neexportuje secrets.** Session materiál neopouští zařízení mimo platformní ochranu; backup/export/screenshot/clipboard policy dle `mobile-architecture §22`.
- **TSS-014 — Terminologická separace.** Auth session storage ≠ WorkoutSession ≠ lokální aplikační session (`ISC-011`); C7 pojmy tyto koncepty neslévají.
- **TSS-015 — Mechanismus je za boundary.** C7 nerozhoduje konkrétní plugin/platformní API ani auth providera (C5); volba je implementační detail, který nesmí oslabit `TSS-001…014`.

---

# 10. Interaction with other contracts

- **C3 (identity & session):** vlastní lifecycle a sémantiku; C7 vlastní umístění materiálu na zařízení (`ISC-013`). Bez překryvu.
- **C4 (auth API):** vlastní transport po síti; C7 přebírá vydané credentials a vlastní jejich uložení; reakce na `SESSION_REVOKED`/`ACCESS_SESSION_EXPIRED` na úrovni storage (§7).
- **C1/C2 (mobilní schema, lokální metadata):** session materiál do Drift/SQLite **nepatří** (`TSS-002/003`); technické ne-secret reference smí žít v `local_app_state` (C1); logout/revokace nesmí smazat outbox (`LSM-006/010/011`).
- **C6 (server data model):** serverová strana session; C7 je klientská strana, bez překryvu.
- **C9 (device registration, forward):** budoucí device credential podléhá stejné klasifikaci §4; registraci vlastní C9.
- **C13 (revocation, forward):** operační revokační flow a úplné klientské chování; C7 vlastní jen chování uloženého materiálu (§7).
- **C15 (local-to-account migration, forward):** attach lokálních dat k účtu; C7 garantuje, že logout/login cyklus data neztratí (`TSS-009`).

**Forward reference (dosud nevytvořené kontrakty):** C8, C9, C10, C11, C12, C13, C15.

---

# 11. Testing requirements (kontraktně)

Implementace R2-03 musí ověřit (`test-strategy §5/§7`, `QTR-003`):

1. **No-secret-in-DB** — po login/refresh neobsahuje žádný soubor Drift/SQLite databáze ani preferences access/refresh credential ani heslo (kontrola nad skutečnou lokální DB).
2. **Restart-with-session** — po restartu se přihlašovací stav obnoví ze (fake) secure storage; anonymní start bez materiálu vede na signed-out stav a funkční R1 tok.
3. **Logout** — odstraní veškerý session materiál (i při offline/selhání serveru) a zachová lokální data a outbox.
4. **Revocation** — po `SESSION_REVOKED` se materiál odstraní, oprávnění se neobnoví, neodeslané změny zůstávají v recovery stavu.
5. **Fail-safe** — nedostupné/poškozené secure storage vede na bezpečný signed-out fallback bez pádu a bez ztráty dat.
6. **Log-redaction** — credentials se neobjeví v log výstupu klienta.
7. **Boundary** — testy běží s fake secure storage adaptérem (`MAR-015`), bez reálného Keychain/Keystore.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 12. Evidence gates

Implementace R2-03 (a spotřebitelské slices R2-06/R2-07) musí doložit: no-secret-in-DB důkaz; restart-with-session důkaz; logout/revocation důkaz včetně zachování lokálních dat; fail-safe fallback důkaz; log-redaction důkaz; traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done (`DRD-014`).

---

# 13. Ready condition

## 13.1 Kdy je C7 dokončen (Done)

C7 je Done, právě když definuje: klasifikaci session materiálu (§4), secure storage boundary (§5), restart chování (§6), logout/revocation interakci (§7), offline chování (§8), invarianty `TSS-001…TSS-015` (§9), hranice (§10), testing/evidence (§11–§12); je zapsán v doc mapě a status auditu; a neobsahuje plugin volbu, UI flow ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C7 je tedy **Done**.

## 13.2 Dopad na R2-03

`R2-03` má dle `r2-vertical-slice-plan §9.3` Ready podmínku: **R2-02 Done** (garantuje C4) **+ existence C7**. C7 nyní existuje a `R2-02` je implementován → **`R2-03` je `READY` (neimplementováno)**. `R2-04` až `R2-08` zůstávají `NOT_READY` (čekají na dokončení předchozích slices a kontrakty C8–C15).

## 13.3 Další kanonický krok

**Implementace `R2-03 – Mobile Auth and Secure Session Storage`** (mobilní produkční kód — smí začít až po samostatném pokynu), případně příprava kontraktů **C8 – Authorization/ownership** a **C9 – Device registration** pro `R2-04`. C7 tyto kroky **nevykonává**.

---

# 14. References

- `docs/13-delivery/r2-vertical-slice-plan.md` — C7 map (§7.1), R2-03 (§9.3), cross-slice invarianty (§10 body 8–9).
- `docs/11-security/security-architecture.md` — `§7.2` tokeny, `§7.3` offline session, `SAR-006/007/012`.
- `docs/08-mobile/mobile-architecture.md` — `§22` secure storage a lokální ochrana, `MAR-015` nahraditelné adaptery.
- `docs/07-backend/r2-identity-session-contract.md` — C3; `ISC-002/003/007/008/009/011/012/013`.
- `docs/07-backend/r2-auth-api-contract.md` — C4; credential transport (§6), error kódy (§9), `AAC-009/010`.
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-006/010/011`.
- `docs/12-data/r2-mobile-schema-migration.md` — C1; mobilní schema (session materiál mimo něj).
- `docs/06-domain/sync-and-offline-model.md` — offline garance `§3`.
- `docs/14-quality/test-strategy.md` — `QTR-003/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-007`, `DRD-014`.
