# AI Trainer – R2 Token/Session Revocation Contract (C13)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/11-security/r2-revocation-contract.md`
**Vlastník:** Security + Backend Architecture
**Poslední aktualizace:** 2026-08-12
**Kontraktní ID:** C13 (dle `docs/13-delivery/r2-vertical-slice-plan.md §7.1`; mapa připouští „součást C3/C7" — samostatný dokument je zvolen pro jasné vlastnictví operačního flow)
**Navazuje na:** `docs/11-security/security-architecture.md` (§7.2/§7.3, §9), `docs/07-backend/r2-identity-session-contract.md` (C3), `docs/07-backend/r2-auth-api-contract.md` (C4), `docs/11-security/r2-token-session-storage-contract.md` (C7), `docs/07-backend/r2-device-registration-contract.md` (C9), `docs/07-backend/r2-sync-protocol-contract.md` (C10), `docs/11-security/r2-audit-event-contract.md` (C14), `docs/12-data/r2-server-data-model.md` (C6), `docs/13-delivery/r2-vertical-slice-plan.md`, `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`
**Navazující dokumenty:** implementace R2-06, OpenAPI rozšíření (revoke operace)
**Vlastněné pojmy nebo kontrakty:** R2 revokační operace (globální revokace session účtu, revokace instalace), klientské chování po revokaci a pravidla `RVC-001` až `RVC-015`

---

# 1. Purpose

## 1.1 Owner a proč existuje

**Security + Backend Architecture.** Revokační *sémantika* existuje od R2-02 (C3 `ISC-006/007/009`: revokovaná session nepotvrzuje; refresh-replay revokuje session; logout ukončuje aktuální session) a klientská reakce od R2-03 (C7 §7 + `verifySession` → bezpečné odhlášení bez ztráty dat). Chybí **operační flow**: jak uživatel revokuje *ostatní* přístupy — všechny session účtu a konkrétní zařízení — a co přesně pak platí. Tímto kontraktem je C13.

C13 je **contract-only**: bez controllerů, DTO, migrací a UI implementace.

## 1.2 Které slices blokuje

- **Blocking pro `R2-06 – Conflict, Rejection and Session Revocation`** (spolu s C12).

---

# 2. Scope

## 2.1 Co C13 řeší

- **revokační operace R2** (§4): globální revokace session účtu, revokace instalace,
- **serverové důsledky** revokace (§5),
- **klientské chování po revokaci** (§6),
- **audit** (§7),
- invarianty `RVC-001…RVC-015` (§8), hranice (§9), testing/evidence (§10–§11), Ready (§12).

## 2.2 Co C13 výslovně neřeší

- **logout aktuální session** — C4 (existuje od R2-02),
- **automatickou revokaci při refresh-replay** — C4 §7/R2-02 (existuje),
- **sémantiku „revokovaná session nepotvrzuje"** — C3 (`ISC-007/009`),
- **mobilní úložiště a čištění session materiálu** — C7 (C13 na ně jen navazuje),
- **správu zařízení UX nad rámec baseline** (trusted devices, přejmenování, seznam session s metadaty) — R2 non-goal (`release-scope §6.3`),
- **step-up/recent authentication** pro citlivé operace — forward (`security §9`); R2 baseline chrání revokační operace platnou access session,
- **smazání účtu, ztracené zařízení flow** (`sync-model §78/§126`) — R3+.

---

# 3. Source of truth and precedence

1. **Bezpečnost** — `security-architecture §7.2` (individuální i globální revokace povinná), `§7.3` (offline session neobnoví oprávnění), `§9` (evidence session/zařízení, ukončení přístupu po revokaci), `SAR-007`.
2. **Identity/session sémantika** — C3 (`ISC-006/007/009/010`).
3. **Klientské úložiště** — C7 (`TSS-009/010/011`).
4. **R2 pořadí** — `r2-vertical-slice-plan §9.6`.

C13 vlastní **revokační operační flow R2** a `RVC-*`.

---

# 4. Revokační operace R2

Obě operace vyžadují **platnou access session** (C4 auth kontext) a operují výhradně nad daty principala (C8):

| Operace | Kanonická cesta (kontraktně) | Význam |
|---|---|---|
| **Revoke all sessions** | `DELETE /api/v1/auth/sessions` | globální revokace: ukončí **všechny** auth session účtu včetně aktuální (`security §7.2` globální revokace; „odhlásit všude") |
| **Revoke installation** | `DELETE /api/v1/devices/{installationId}` | revokuje registrovanou instalaci principala (stav `REVOKED`, C9 §9) a **všechny auth session na ni vázané** (C6 §8.3 vazba) |

- Obě operace jsou **idempotentní** (opakování nad již revokovaným stavem je no-op úspěch — analogie C4 logout).
- Revokace cizí instalace je enumeration-safe 404 (`AOC-007`).
- Přesný HTTP tvar vlastní OpenAPI při implementaci (analogie C4).

---

# 5. Serverové důsledky

- Revokovaná session **nepotvrdí žádnou další operaci** (`ISC-007`): access → `SESSION_REVOKED`, refresh → `SESSION_REVOKED` (mechanismus existuje z R2-02; C13 jej jen rozšiřuje na hromadné zneplatnění).
- Revokovaná instalace: registrace je `REVOKED` a **nesmí být tiše reaktivována** upsertem (DRC-013, vynuceno od R2-04 `DEVICE_REVOKED`); **sync push z ní je odmítnut** (C10 §9 — batch od neaktivní instalace = `INVALID_REQUEST`).
- Revokace **nemaže žádná data**: serverová synced data účtu, profily ani audit se nemění; ruší se výhradně oprávnění (session/instalace).
- Revoke-all zneplatní i session, kterou byla operace zavolána — odpověď operace je poslední autorizovaná akce této session.

---

# 6. Klientské chování po revokaci

Navazuje na C7 §7 a R2-03 implementaci (`verifySession` → `signedOutRevoked`):

- Klient se o revokaci dozví **při nejbližším serverovém kontaktu** (`SESSION_REVOKED` z libovolné chráněné operace — verify, refresh, sync push, profil/device API). Žádný push kanál se v R2 nezavádí.
- Reakce je jednotná: **odstranit session materiál, přejít do signed-out stavu, zachovat lokální data i outbox** (`TSS-009/010`, `LSM-010/011`); neodeslané změny zůstávají v recovery stavu a po novém přihlášení jsou znovu synchronizovatelné.
- **Offline platnost se neobnovuje**: platná lokální session smí dál číst dříve synchronizovaná/lokální data, ale žádná offline logika nesmí revokaci obejít ani „vydržet" (`ISC-009`, `security §7.3`).
- Revokace **nepřerušuje aktivní lokální WorkoutSession** (`R2P-008`) — trénink pokračuje offline; blokovaný je jen serverový přenos.
- UI po revokaci ukazuje bezpečnou zprávu (existující `accountVerifyRevoked` vzor R2-03) bez interního detailu.

---

# 7. Audit

Používá existující C14 §6 událost **`AuthSessionRevoked`**:

- revoke-all: jeden záznam per revokovaná session (policy `REVOKE_ALL`),
- revoke instalace: `AuthSessionRevoked` per vázanou session (policy `DEVICE_REVOKED`) + **`DeviceRevoked`** záznam pro instalaci (append-only doplněk C14 tímto kontraktem; tvar dle C14 §5, target = installation ID),
- bez citlivého payloadu (AEC-003/004).

---

# 8. Revocation invariants (`RVC`)

Nová řada. Doplňuje, neoslabuje `ISC-*`, `TSS-*`, `DRC-*`, `AAC-*`, `SAR-*`.

- **RVC-001 — Globální revokace existuje.** Uživatel může jednou operací revokovat všechny session svého účtu (`security §7.2`); individuální ukončení aktuální session vlastní C4 logout.
- **RVC-002 — Revokace instalace existuje.** Registrovanou instalaci lze revokovat; revokace zneplatní i všechny session na ni vázané.
- **RVC-003 — Jen vlastní přístupy.** Revokační operace operují výhradně nad session/instalacemi principala (C8); cizí instalace je enumeration-safe 404.
- **RVC-004 — Idempotentní.** Opakovaná revokace již revokovaného je no-op úspěch; žádná chyba, žádný nový efekt.
- **RVC-005 — Revokace ruší jen oprávnění.** Serverová data, profily, audit ani lokální data klienta se revokací nemažou.
- **RVC-006 — Revokovaná session nepotvrzuje.** Po revokaci žádná operace session neprojde (`ISC-007`); platí i pro session, která revoke-all zavolala.
- **RVC-007 — Revokovaná instalace nepushuje.** Sync batch ani re-registrace z revokované instalace neprojdou bez explicitního obnovení (DRC-013; obnovení je mimo R2).
- **RVC-008 — Klient reaguje jednotně.** Každý `SESSION_REVOKED` vede na: smazat materiál, signed-out, zachovat lokální data i outbox (`TSS-009/010`).
- **RVC-009 — Offline neobchází revokaci.** Žádná offline logika neobnoví serverové oprávnění po revokaci (`ISC-009`).
- **RVC-010 — Aktivní workout pokračuje.** Revokace nepřeruší ani nepřepíše aktivní lokální WorkoutSession (`R2P-008`).
- **RVC-011 — Neodeslané změny přežijí.** Outbox/pending změny se revokací nemažou a po novém přihlášení jsou synchronizovatelné (`LSM-010/011`; attach sémantiku vlastní C15).
- **RVC-012 — Vše se audituje.** Každá revokovaná session i instalace generuje audit záznam dle §7, bez citlivého payloadu.
- **RVC-013 — Bez push kanálu do zásoby.** R2 nedoručuje revokaci proaktivně; detekce je při serverovém kontaktu (`R2P-012`).
- **RVC-014 — Server je autorita.** Revokační stav drží výhradně server (C6); klientský stav je jen odvozená reakce (`ISC-003`, `TSS-011`).
- **RVC-015 — Bez správy zařízení do zásoby.** R2 baseline = revoke-all + revoke instalace; trusted-device UX, přejmenování a session metadata vzniknou až vlastním kontraktem.

---

# 9. Interaction with other contracts

- **C3/C4:** sémantika revokace a logout/refresh-replay mechanismy (existují z R2-02); C13 doplňuje hromadné operace.
- **C7:** klientské čištění materiálu a fail-safe chování; C13 určuje, kdy nastává.
- **C9:** stav `REVOKED` instalace a zákaz tiché reaktivace; C13 vlastní operaci, která jej nastavuje.
- **C10:** odmítnutí push z revokované instalace/session; C13 důvod, C10 transportní projev.
- **C14:** `AuthSessionRevoked` (§6) + append-only doplněk `DeviceRevoked` (§7).
- **C15 (forward):** osud neodeslaných změn po novém přihlášení jiným/stejným účtem.

---

# 10. Testing requirements (kontraktně)

Implementace R2-06 musí ověřit (`test-strategy §7/§8`, `QTR-004`):

1. **Revoke-all** — všechny session účtu (včetně volající) přestanou autorizovat access i refresh (`SESSION_REVOKED`); cizí účet nedotčen.
2. **Revoke instalace** — instalace `REVOKED`, vázané session revokované, sync push i re-registrace odmítnuty; cizí instalace = 404.
3. **Idempotence** — opakovaná revokace je no-op úspěch.
4. **Data přežijí** — serverová synced data i lokální data/outbox beze změny; po novém přihlášení lze pushovat.
5. **Klient** — po `SESSION_REVOKED` z libovolné operace: materiál smazán, signed-out, lokální data čitelná, aktivní workout nepřerušen (mobilní testy s fake hranicemi).
6. **Audit** — záznamy per session + per instalace, bez citlivého payloadu.
7. **Security-negative** — revokovaný refresh nelze použít; revokovaná instalace nepushuje.

Flaky výsledek není zelený důkaz (`QTR`, `DRD`).

---

# 11. Evidence gates

Implementace R2-06 musí doložit: Testcontainers revoke-all/revoke-installation testy vč. security-negative, mobilní reaction testy, audit důkaz, traceable evidence na commit + CI run (`QTR-015`, `DRD-014`). Chybějící povinný důkaz → slice není Done.

---

# 12. Ready condition

C13 je Done, právě když definuje: revokační operace (§4), serverové důsledky (§5), klientské chování (§6), audit (§7), invarianty `RVC-001…RVC-015` (§8), hranice (§9), testing/evidence (§10–§11); je zapsán v doc mapě a status auditu; a neobsahuje produkční kód. Tyto podmínky jsou vytvořením tohoto dokumentu a aktualizací doc mapy **splněny**; C13 je **Done**.

**Dopad na R2-06:** `R2-06` vyžaduje R2-05 Done (splněno) + C12 + C13 — **vše splněno → `R2-06` je `READY` (neimplementováno)**. `R2-07` zůstává `NOT_READY` (čeká na R2-05/06 postup a C15), `R2-08` `NOT_READY`.

**Další kanonický krok:** **implementace `R2-06`** (samostatné rozhodnutí), případně příprava **C15 – Local-to-account migration** pro `R2-07`.

---

# 13. References

- `docs/11-security/security-architecture.md` — `§7.2` revokace, `§7.3` offline session, `§9` session/device security, `SAR-007`.
- `docs/07-backend/r2-identity-session-contract.md` — C3; `ISC-006/007/009/010`.
- `docs/07-backend/r2-auth-api-contract.md` — C4; logout, `SESSION_REVOKED`.
- `docs/11-security/r2-token-session-storage-contract.md` — C7; `TSS-009/010/011`.
- `docs/07-backend/r2-device-registration-contract.md` — C9; `DRC-013`, stav REVOKED.
- `docs/07-backend/r2-sync-protocol-contract.md` — C10; §9 device gate.
- `docs/11-security/r2-audit-event-contract.md` — C14; `AuthSessionRevoked`, tvar záznamu.
- `docs/12-data/r2-server-data-model.md` — C6; auth_session/device_installation stavy, vazba §8.3.
- `docs/13-delivery/r2-vertical-slice-plan.md` — §9.6 R2-06, `R2P-008/012`.
- `docs/14-quality/test-strategy.md`, `docs/13-delivery/definition-of-ready-and-done.md`.
