# AI Trainer – R6 Device Restore Contract (C45)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r6-restore-contract.md`
**Vlastník:** Domain (sync-and-offline-model) + Mobile
**Kontraktní ID:** C45 (dle `docs/13-delivery/r6-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/07-backend/r6-pull-sync-contract.md` (C41), `docs/06-domain/r6-pull-merge-contract.md` (C42), `docs/12-data/r6-structure-sync-contract.md` (C43), `docs/06-domain/r6-delete-sync-contract.md` (C44), `docs/06-domain/r2-account-attach-contract.md` (C15), `docs/02-product/release-scope.md` (§10 krok 10)
**Navazující dokumenty:** implementace R6-05, R6-06 (E2E + Exit Review)
**Vlastněné pojmy nebo kontrakty:** restore flow, rozšíření pull scope o R1 historii, attach interakce, poctivé hranice obnovy a pravidla `DRS-001` až `DRS-015`

---

# 1. Purpose

Restore je **orchestrace existujících mechanismů, ne import** (R6P-007): čistá instalace + přihlášení + explicitní akce → plný pull (prázdné kurzory) přes C41/C42/C43/C44. Naplňuje beta baseline **krok 10 — bezpečnou obnovu**: uživatel dostane zpět svou doménovou pravdu včetně struktury workoutů a historie, smazané zůstane smazané, a celý proces je přerušitelný a idempotentní.

**Blocking pro `R6-05`.**

# 2. Scope obnovy

- **Pull scope se rozšiřuje o R1 historii** (C42 PMS-007 revize): `WORKOUT_SESSION` → `STEP_PERFORMANCE` → `SET_PERFORMANCE` → `WORKOUT_FEEDBACK` → `ACTIVITY_SUMMARY` — v tomto pořadí za instancemi (FK prerekvizity; performance kroky referencují strukturu z C43). Tím pull pokrývá **všech 15 registrových typů**.
- Children bez vlastních owner/sync sloupců (perform./feedback — tranzitivní vlastnictví přes session) se aplikují bez owner metadat; owned typy dle C42 matice beze změny.
- **Co se neobnovuje (poctivá hranice):** AI návrhy (APL-011 — device-local artefakt), nastavení připomínek (NTF-008 — vlastnost zařízení), pull kurzory a outbox (lokální fakty), `startedSessionId` instance (aktivní session je device fact — recovery gate na novém zařízení nikdy nic nekřísí). UI hranici přiznává.

# 3. Flow a interakce

- **Spouštění:** explicitní akce přihlášeného uživatele z Account obrazovky („Obnovit data ze serveru"); žádný automatický běh (PMS-012). Tatáž akce slouží i jako běžný manuální pull (restore = první pull, mechanismus je týž).
- **Přerušitelnost:** dána C42 (kurzor per batch po aplikaci) — přerušený restore se opakuje idempotentně; typované stavy (běží / dokončeno s počty applied+konflikty / anonymní / nedostupné).
- **Attach interakce (C15 beze změny):** anonymní data nového zařízení se při přihlášení attachnou a restore je **nikdy nemaže ani nepřepisuje** (C42 chrání ne-SYNCED stavy). Přiznaný důsledek: uživatel může po obnově vidět **dva ACTIVE plány** (lokální + serverový) — systém degraduje bezpečně (read modely je zobrazí, AI execution typovaně odmítne nejednoznačnost) a **řešení je uživatelova archivace** (C20); nikdy tichý výběr ani mazání.
- Po dokončení se invalidují read modely (Today, plány, check-iny, historie, souhrn).

# 4. Invarianty (`DRS`)

- **DRS-001 — Restore = orchestrace** C41–C44; žádný paralelní datový kanál ani speciální endpoint.
- **DRS-002 — Explicitní a jen přihlášený**; anonymní stav typovaný.
- **DRS-003 — Idempotentní a přerušitelný** (C42 kurzory); opakování bezpečné, žádná duplicita.
- **DRS-004 — Úplnost dle §2**: všech 15 typů vč. struktury (C43) a historie; tombstonované řádky se neobnovují (DTS-006).
- **DRS-005 — Lokální data nového zařízení přežijí** (§3) — restore nikdy nemaže ani nepřepisuje ne-SYNCED lokální pravdu.
- **DRS-006 — Kolize ACTIVE plánů přiznaná** (§3): bezpečná degradace + uživatelské řešení; nikdy tichá volba.
- **DRS-007 — Poctivé hranice obnovy** (§2) přiznané v UI textu.
- **DRS-008 — Pořadí typů dle §2**; FK selhání = typovaný dependency skip (PMS-009), viditelný v počtech.
- **DRS-009 — Typované stavy flow** (§3); žádný auto-retry, žádné tiché „hotovo" při částečném výsledku.
- **DRS-010 — Historie je read-only pravda**: obnovené sessions/performances se aplikují jak byly (žádné dopočty, aktivní session se nekřísí).
- **DRS-011 — Owner = přihlášený účet** pro owned typy; children tranzitivně (C2).
- **DRS-012 — Read modely po dokončení konzistentní** (invalidace §3); R1–R5 obrazovky fungují nad obnovenými daty beze změny.
- **DRS-013 — Bez PII navíc a bez logů payloadů** (PMS-013).
- **DRS-014 — Rozšíření jen kontraktem.**
- **DRS-015 — Evidence.** Testy: plná obnova na prázdné DB (všech 15 typů vč. struktury a historie, dokončený workout viditelný v historii), idempotence druhého běhu, přerušení uprostřed + dokončení, tombstone se neobnoví, koexistence attachnutých lokálních dat, typované stavy; flaky ≠ zelený důkaz.

# 5. Ready condition

C45 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R6-05` `READY`**.
