# AI Trainer – R2 Device Registration Contract (C9)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/07-backend/r2-device-registration-contract.md`
**Vlastník:** Backend Architecture + Domain (sync-and-offline-model)
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C9 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/sync-and-offline-model.md` (§5 DeviceInstallation, §6 DeviceSession), `docs/11-security/security-architecture.md` (§9 session a device security), `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/11-security/r2-authorization-ownership-contract.md` (C8), `docs/12-data/r2-server-data-model.md` (C6), `docs/11-security/r2-token-session-storage-contract.md` (C7), `docs/11-security/r2-audit-event-contract.md` (C14), `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-04, OpenAPI rozšíření (device operace), C10 sync protocol, C13 revocation
**Vlastněné pojmy nebo kontrakty:** R2 registrace zařízení (DeviceInstallation na serveru, vazba účet–zařízení–auth session, re-registrace, odhlášení zařízení, minimalizace metadat) a pravidla `DRC-001` až `DRC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Backend Architecture + Domain (sync-and-offline-model).** R2-05 sync potřebuje vědět, **které zařízení** operace poslalo (checkpoint/cursor per zařízení, C10) a security architektura vyžaduje evidenci session/zařízení s možností revokace (`security §9`). R2-04 proto registruje zařízení vůči účtu. Aby registrace měla jednoznačnou sémantiku (identita instalace, idempotence, vazba na session, odhlášení, minimalizace metadat), potřebuje kanonický kontrakt. Tímto je C9.

C9 je **contract-only**: neimplementuje endpointy, DTO, migrace ani mobilní kód. Doménové pojmy `DeviceInstallation`/`DeviceSession` vlastní `sync-and-offline-model §5/§6`; C9 je promítá do R2 registračního kontraktu.

## 1.2 Které slices blokuje

- **Blocking pro `R2-04 – AthleteProfile and Device Registration`** (spolu s C8 a rozšířením C6).
- Referencován R2-05 (sync per zařízení) a R2-06 (revokace zařízení); jejich kontrakty (C10, C13) jsou samostatné.

---

# 2. Scope

## 2.1 Co C9 řeší

- **identitu instalace** na klientu a serveru (§4),
- **registrační operaci** a její idempotenci (§5),
- **vazbu účet–zařízení–auth session** (DeviceSession v R2, §6),
- **odhlášení zařízení** a interakci s revokací (§7),
- **minimalizaci device metadat** (§8),
- **stavový model zařízení v R2** (§9),
- invarianty `DRC-001…DRC-015` (§10), hranice (§11), testing/evidence (§12–§13), Ready (§14).

## 2.2 Co C9 výslovně neřeší

- **serverové schéma tabulek** — C6 (rozšíření o `device_installation`),
- **autorizaci registračních operací** — C8 (`device.manage`, ownership),
- **mobilní uložení installation ID / session materiálu** — C7 a C1 (technická ne-secret reference smí do `local_app_state`),
- **push notifikace a push token lifecycle** — mimo R2 (deferred provider, ADR §13),
- **pokročilou správu zařízení a trusted-device UX** — R2 non-goal (`release-scope §6.3`); R2 má jen registraci + odhlášení,
- **sync checkpoint/cursor per zařízení** — C10 (C9 dodává identitu zařízení, kterou C10 použije),
- **revokační flow „odhlásit jiné/všechna zařízení"** — C13 (R2-06); C9 pokrývá jen aktuální zařízení,
- **wearables a companion zařízení** — integrace R3+ (`integration-architecture`).

---

# 3. Source of truth and precedence

1. **Bezpečnost** — `security-architecture §9` (device identity je signál, ne důkaz uživatele; minimalizovaná metadata; žádný nezdokumentovaný fingerprinting) a `SAR-*`.
2. **Doménový model** — `sync-and-offline-model §5/§6` (DeviceInstallation/DeviceSession, jejich vlastnosti a stavy) — C9 nepředefinovává, zužuje na R2.
3. **Autorizace** — C8 (`AOC-015` — device nenahrazuje principal).
4. **Datový model** — C6 (server-vs-client ID politika §5).
5. **R2 pořadí** — `r2-vertical-slice-plan §7.1/§9.4`.

C9 vlastní **R2 registrační sémantiku** a `DRC-*`.

---

# 4. Identita instalace

- **Installation ID je client-generated** (C6 §5 politika): vzniká na zařízení při prvním spuštění, je **stabilní po celou životnost instalace** a po kompletní reinstalaci vzniká nový (`sync-model §5.4`). Server jej přijímá a zachovává (`SDM-005`); nikdy jej nepřečíslovává.
- Installation ID **nesmí** být odvozeno z reklamního identifikátoru ani sledovat uživatele mezi reinstalacemi (`§5.4`).
- Installation ID je **technická ne-secret reference** (C7 §4): smí žít v běžném lokálním stavu (`local_app_state`), neautorizuje nic samo o sobě (`AOC-015`) a nesmí se použít jako credential.
- Jedna instalace ↔ jeden installation ID; stejné fyzické zařízení po reinstalaci je **nová instalace**.

---

# 5. Registrační operace

- **Kdy:** registrace probíhá **po přihlášení** (vyžaduje platnou access session — C4 auth kontext; autorizace `device.manage` — C8). Anonymní zařízení se neregistruje — lokální R1 tok registraci nevyžaduje (`R2P-004`).
- **Co:** klient předá installation ID a minimální metadata (§8: platforma, verze aplikace, verze lokálního schématu). Server vytvoří/aktualizuje `device_installation` vázanou na principal účet (`AOC-005`).
- **Idempotence:** registrace je **idempotentní podle (account, installation ID)** — opakovaná registrace stejné instalace stejným účtem je upsert metadat (verze aplikace, last seen), ne duplicitní zařízení. Registrace je retry-safe bez idempotency key (přirozený klíč je installation ID).
- **Cizí installation ID:** installation ID registrované jiným účtem se pro nový účet považuje za **novou registraci vlastní instance** — v R2 baseline je vazba (account, installation) unikátní pár; jeden fyzický přístroj s postupně přihlášenými účty (`sync-model §77`) vede na oddělené registrace. Server nikdy neprozradí, že installation ID zná od jiného účtu (`AOC-007` analogie).
- **Kdy klient registruje:** po úspěšném login/registraci účtu a při změně metadat (upgrade aplikace/schématu); žádný background re-registrační loop.

---

# 6. Vazba účet–zařízení–auth session (DeviceSession v R2)

- Doménový pojem **DeviceSession** (`sync-model §6` — jedno přihlášení uživatele na instalaci) se v R2 realizuje **vazbou auth session na device_installation** — žádná samostatná serverová device-session tabulka „do zásoby" (`R2P-012`). C6 rozšíření k tomu doplní na `auth_session` referenci na zařízení (baseline sloupec z R2-02 byl připraven jako nullable).
- Vazba vzniká **při nebo po registraci zařízení**: auth session vydaná na registrovaném zařízení nese jeho referenci; session bez vazby (vydaná před registrací) zůstává platná — vazba je aditivní.
- Refresh rotace vazbu **zachovává**; nová session z loginu na stejném zařízení dostává vazbu znovu.
- Vazba je bezpečnostní **signál** pro evidenci a budoucí revokaci per zařízení (C13), nikdy autorizační důkaz (`security §9`, `AOC-015`).

---

# 7. Odhlášení zařízení

- **Odhlášení aktuálního zařízení = logout** (C4 `DELETE /auth/sessions/current` + lokální vyčištění dle C7 §7): revokuje auth session vázané na zařízení a lokálně odstraní session materiál. Installation ID **zůstává** (identita instalace přežívá odhlášení).
- Registrace zařízení se odhlášením **neodstraňuje** — přechází do neaktivního stavu (`last seen` stárne); explicitní odregistrace instalace je v R2 volitelná operace téhož principu (idempotentní, autorizovaná `device.manage`).
- **Neodeslané změny se odhlášením tiše neodstraňují** (`sync-model §6.3` výchozí bezpečné pravidlo, `LSM-006`); jejich osud řeší C7 §7 (lokální recovery stav) a C15 (attach).
- Revokace zařízení **jiného než aktuálního** („odhlásit všechna zařízení") je C13/R2-06 — mimo C9.

---

# 8. Minimalizace metadat

Server smí o zařízení evidovat **pouze** (`security §9` — žádný nezdokumentovaný fingerprinting):

- installation ID (§4),
- platformu (`sync-model §5.3`: IOS/ANDROID; ostatní forward),
- verzi aplikace,
- verzi lokálního datového schématu (pro sync kompatibilitu, C10),
- časy: vytvoření, poslední aktivita, poslední synchronizace (od R2-05),
- stav (§9).

**Zakázáno v R2:** hardware fingerprint, reklamní identifikátory, seznam senzorů, geolokace, jméno zařízení zadané výrobcem obsahující osobní údaje bez souhlasu. Push token reference (`§5.2`) až s notifikačním slicem (provider deferred).

---

# 9. Stavový model zařízení v R2

Ze stavů `sync-model §5.5` používá R2 baseline podmnožinu:

- **ACTIVE** — registrovaná instalace,
- **REVOKED** — instalace revokovaná bezpečnostním rozhodnutím (plné flow C13/R2-06; C6 stav drží už teď, aby R2-06 neměnil schéma),
- ostatní stavy (LOST/REPLACED/DELETED/UNKNOWN) jsou forward-scoped — přidávají se append-only, až je slice potřebuje.

Revokovaná instalace nesmí potvrdit nové serverové operace vázané na zařízení (návaznost `ISC-007`; enforcement C8/C13).

---

# 10. Device registration invariants (`DRC`)

Nová řada. Doplňuje, neoslabuje `SAR-*`, `ISC-*`, `AOC-*`, `SDM-*`, `TSS-*`, `LSM-*`.

- **DRC-001 — Client-generated installation ID.** Identita instalace vzniká na zařízení, je stabilní po životnost instalace a server ji zachovává (`SDM-005`, `sync-model §5.4`).
- **DRC-002 — Nová instalace = nové ID.** Kompletní reinstalace vytváří nový installation ID; ID nesleduje uživatele mezi reinstalacemi ani není odvozeno z reklamního identifikátoru.
- **DRC-003 — Installation ID není credential.** Je to ne-secret technická reference (C7 §4); samo o sobě nic neautorizuje (`AOC-015`) a nepatří do secure storage.
- **DRC-004 — Registrace jen přihlášená.** Registrace vyžaduje platnou access session a `device.manage` (C8); anonymní/R1 tok registraci nevyžaduje (`R2P-004`).
- **DRC-005 — Ownership z principalu.** Registrovaná instalace patří principal účtu (`AOC-005`); klientem dodaný owner se neakceptuje.
- **DRC-006 — Idempotentní registrace.** Opakovaná registrace stejné instalace stejným účtem je upsert, ne duplikát; přirozený klíč je (account, installation ID).
- **DRC-007 — Bez cross-account úniku.** Server neprozradí, že installation ID zná od jiného účtu; kolekce zařízení je filtrovaná principalem (`AOC-007/008`).
- **DRC-008 — DeviceSession = vazba, ne tabulka.** V R2 se DeviceSession realizuje referencí auth session → device_installation; samostatná infrastruktura vzniká až se slicem, který ji potřebuje (`R2P-012`).
- **DRC-009 — Vazba je signál.** Vazba session–zařízení slouží evidenci a revokaci; nikdy nenahrazuje principal ani ownership rozhodnutí (`security §9`, `AOC-015`).
- **DRC-010 — Odhlášení nemaže identitu ani data.** Logout revokuje session a čistí session materiál (C7 §7); installation ID i lokální data/outbox zůstávají (`LSM-006`); neodeslané změny se tiše neodstraňují (`sync-model §6.3`).
- **DRC-011 — Minimalizovaná metadata.** Eviduje se jen §8 výčet; žádný fingerprinting, reklamní ID ani senzorická data (`security §9`).
- **DRC-012 — Stavy append-only.** R2 používá ACTIVE/REVOKED; další stavy se přidávají append-only až s potřebným slicem (`SDM-015`).
- **DRC-013 — Revokovaná instalace nepotvrzuje.** Revokované zařízení nesmí potvrdit nové serverové operace vázané na zařízení (návaznost `ISC-007`; flow C13).
- **DRC-014 — Registrace se audituje.** Registrace/odregistrace zařízení generuje audit záznam dle C14 tvaru (principal, action, target = installation ID, outcome), bez citlivého payloadu.
- **DRC-015 — Žádný registrační loop.** Klient registruje po přihlášení a při změně metadat; žádný automatický background re-registrační/retry loop (konzistence s no-auto-retry pravidlem R0/R1).

---

# 11. Interaction with other contracts

- **C3 (identity/session):** session↔device vazba (C3 §4.4 device identity jako cíl vazby); C9 vlastní registraci, C3 session lifecycle.
- **C4 (auth API):** logout aktuální session; C9 na něm staví odhlášení zařízení (§7). Device API tvar doplní OpenAPI při implementaci R2-04 (analogicky auth operacím).
- **C6 (server data model):** tabulka `device_installation` + vazba na `auth_session` — schéma vlastní C6 (append-only rozšíření); C9 sémantiku.
- **C7 (token/session storage):** installation ID je ne-secret reference mimo secure storage; session materiál vlastní C7.
- **C8 (authorization/ownership):** autorizace `device.manage`, ownership účet–zařízení, enumeration-safe chování.
- **C10 (sync, forward):** sync používá installation ID pro checkpoint/cursor per zařízení; protokol vlastní C10.
- **C13 (revocation, forward):** revokace zařízení/všech session; C9 drží stav REVOKED, flow vlastní C13.
- **C14 (audit):** tvar audit záznamu; C9 určuje device události (registered/unregistered).

**Forward reference:** C10, C11, C12, C13, C15.

---

# 12. Testing requirements (kontraktně)

Implementace R2-04 musí ověřit (`test-strategy §7/§8`, `QTR-004`):

1. **Registrace po přihlášení** vytvoří zařízení vázané na principal účet; bez access session → 401 (C4), bez autorizace → default deny (C8).
2. **Idempotence** — opakovaná registrace stejné instalace nevytvoří druhé zařízení; metadata se aktualizují.
3. **Client ID zachování** — server installation ID nepřečíslovává (`SDM-005`).
4. **Cross-account** — účet B nevidí zařízení účtu A (kolekce filtrovaná, 404 na cizí ID); stejné installation ID pod druhým účtem je oddělená registrace bez úniku informace.
5. **Vazba session–zařízení** — auth session nese referenci registrovaného zařízení; refresh rotace vazbu zachová.
6. **Odhlášení** — logout revokuje session, installation ID i lokální data zůstávají (mobilní strana dle C7 testů).
7. **Metadata minimalizace** — persistuje se jen §8 výčet (schema constraint + review).
8. **Audit** — registrace generuje audit záznam bez citlivého payloadu.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 13. Evidence gates

Implementace R2-04 musí doložit: Testcontainers testy registrace/idempotence/cross-account; vazbu session–zařízení; audit; mobilní testy installation ID lifecycle (vznik, stabilita, reinstalace = nový) s fake hranicemi; traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 14. Ready condition

## 14.1 Kdy je C9 dokončen (Done)

C9 je Done, právě když definuje: identitu instalace (§4), registrační operaci a idempotenci (§5), vazbu účet–zařízení–session (§6), odhlášení (§7), minimalizaci metadat (§8), stavový model (§9), invarianty `DRC-001…DRC-015` (§10), hranice (§11), testing/evidence (§12–§13); je zapsán v doc mapě a status auditu; a neobsahuje endpointy, DTO, migrace ani produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C9 je tedy **Done**.

## 14.2 Dopad na R2-04

`R2-04` má blokující kontrakty **C8** (hotov), **C9** (hotov tímto dokumentem) a **rozšíření C6 o profil/device**. Jakmile existuje i rozšíření C6, je `R2-04` `READY`.

## 14.3 Další kanonický krok

**Append-only rozšíření C6** (`docs/12-data/r2-server-data-model.md` §8 — kontraktní sloupce `athlete_profile` a `device_installation` + vazba na `auth_session`). C9 je nevytváří.

---

# 15. References

- `docs/06-domain/sync-and-offline-model.md` — `§5` DeviceInstallation (vlastnosti, §5.4 identifikátor, §5.5 stavy), `§6` DeviceSession (§6.3 odhlášení), `§77` více účtů na zařízení.
- `docs/11-security/security-architecture.md` — `§9` session a device security (device = signál, minimalizovaná metadata).
- `docs/07-backend/r2-identity-session-contract.md` — C3; §4.4 device identity, `ISC-007/011`.
- `docs/07-backend/r2-auth-api-contract.md` — C4; logout, auth kontext.
- `docs/11-security/r2-authorization-ownership-contract.md` — C8; `AOC-005/007/008/015`, `device.manage`.
- `docs/12-data/r2-server-data-model.md` — C6; server-vs-client ID (§5), rozšíření §8.
- `docs/11-security/r2-token-session-storage-contract.md` — C7; ne-secret technické reference (§4), logout (§7).
- `docs/11-security/r2-audit-event-contract.md` — C14; tvar audit záznamu.
- `docs/12-data/r2-local-sync-metadata-contract.md` — C2; `LSM-006`.
- `docs/13-delivery/r2-vertical-slice-plan.md` — C9 map (§7.1), R2-04 (§9.4), `R2P-004/012`.
- `docs/14-quality/test-strategy.md` — `§7/§8`, `QTR-004/015`.
- `docs/13-delivery/definition-of-ready-and-done.md` — `DRD-014`.
