# AI Trainer – R5 Local Notifications Baseline Contract (C40)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/08-mobile/r5-notifications-contract.md`
**Vlastník:** Mobile + Product
**Kontraktní ID:** C40 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/08-mobile/mobile-architecture.md`, `docs/06-domain/r5-daily-checkin-contract.md` (C33), `docs/02-product/release-scope.md` (§9.2 základní notifikace), `docs/13-delivery/r5-vertical-slice-plan.md` (§12 emulátorový dluh)
**Navazující dokumenty:** implementace R5-07, splacení platformního dluhu (adapter + on-device evidence)
**Vlastněné pojmy nebo kontrakty:** lokální připomínky, reminder plán, notifikační port a pravidla `NTF-001` až `NTF-015`

---

# 1. Purpose

P0 notifikace jsou **lokální opt-in připomínky** dvou věcí: denní check-in a dnešní naplánovaný workout. Připomínka **nikdy nejedná** — je to navigační pobídka, žádná doménová změna. Architektura odděluje **deterministický reminder plán** (čistá logika, plně testovatelná) od **platformního doručení** (port; adapter a on-device evidence patří do přiznaného platformního/emulátorového dluhu — bez Android SDK na stroji nelze doručení poctivě doložit).

**Blocking pro `R5-07`** (spolu s C39).

# 2. P0 scope

- **Nastavení (opt-in, default vypnuto):** dva přepínače — připomínka check-inu a připomínka dnešního workoutu; P0 časy jsou fixní defaulty (`08:00` check-in, `17:00` workout); vlastní časy = budoucí rozšíření kontraktem. Persistence v lokálním app state (device-local — notifikace jsou vlastnost zařízení, ne účtu).
- **Deterministický denní reminder plán:** čistá funkce (nastavení + dnešní stav → seznam připomínek): check-in připomínka jen když dnes check-in není; workout připomínka jen když dnes existuje neproběhlý naplánovaný workout; vypnuté = nikdy.
- **Port `NotificationGate`:** jediná cesta k platformě (`applyPlan`); P0 implementace je vědomě no-op hranice — registrace platformního pluginu, kanály, permission flow a doručení jsou **platformní dluh** s dokumentovaným postupem splacení (adapter + on-device evidence při splácení emulátorového dluhu).

# 3. Invarianty (`NTF`)

- **NTF-001 — Připomínka nikdy nejedná.** Tap = navigace (check-in / Today); žádná doménová změna, žádné tiché potvrzení čehokoli (R5P-013).
- **NTF-002 — Opt-in.** Default vypnuto; zapnutí je explicitní akce uživatele; vypnutí okamžitě ruší plán.
- **NTF-003 — Deterministický plán** dle §2; stejný vstup → identický plán; plně testováno bez platformy.
- **NTF-004 — Relevance:** check-in připomínka se neplánuje, když dnes check-in existuje; workout připomínka bez dnešního neproběhlého workoutu neexistuje.
- **NTF-005 — Bez obsahu navíc.** Texty připomínek jsou generické (žádná jména workoutů s PII riziky, žádné poznámky, žádné AI výstupy).
- **NTF-006 — Jediná cesta k platformě = port** `NotificationGate`; logika nikdy nevolá platformu přímo.
- **NTF-007 — Platformní dluh přiznaný.** No-op hranice v P0; adapter + permission flow + on-device evidence = dokumentovaný dluh (plán §12), ne tiché „hotovo".
- **NTF-008 — Device-local nastavení**; nesynchronizuje se (žádný nový sync typ).
- **NTF-009 — Žádné server push** v P0 (release scope §11).
- **NTF-010 — Selhání gate je tiché a bezpečné** — aplikace funguje plně bez notifikací; žádná chyba UI kvůli platformě.
- **NTF-011 — Fixní P0 časy** dle §2; změna = revize kontraktu.
- **NTF-012 — Bez background jobů v P0**; plán se přepočítává při změně nastavení a otevření aplikace (poctivá hranice, dokud není platformní adapter).
- **NTF-013 — Žádná telemetrie obsahu.**
- **NTF-014 — Rozšíření jen kontraktem** (vlastní časy, další typy, push).
- **NTF-015 — Evidence.** Testy: matice plánu (opt-in/relevance), persistence přepínačů, aplikace plánu přes port (fake gate), widget nastavení; platformní doručení výhradně jako přiznaný dluh; flaky ≠ zelený důkaz.

# 4. Ready condition

C40 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C39 činí **`R5-07` `READY`**.
