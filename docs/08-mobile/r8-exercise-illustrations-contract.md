# AI Trainer – R8 Exercise Illustrations Contract (C54)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/08-mobile/r8-exercise-illustrations-contract.md`  
**Vlastník:** Product + Mobile  
**Poslední aktualizace:** 2026-08-16  
**Kontraktní ID:** C54 (dle `docs/13-delivery/r8-vertical-slice-plan.md §7.1`)  
**Navazuje na:** `docs/06-domain/r8-exercise-catalog-contract.md` (C51 — kódy), `docs/06-domain/r8-guided-session-contract.md` (C53 — průvodce), `docs/08-mobile/mobile-architecture.md`, `docs/13-delivery/r8-vertical-slice-plan.md` §6/§12  
**Navazující dokumenty:** implementace R8-04  
**Vlastněné pojmy nebo kontrakty:** schematická ilustrace cviku (archetyp pohybu, klíčové polohy postavy, nativní vykreslení), vazba na katalogový kód, fallback, revize vlastníkem, pravidla `EXI-001` až `EXI-010`

---

# 1. Purpose

Uživatel má u každého katalogového cviku vidět **co má dělat** (nález 4). C54 definuje **schematické ilustrace**: zjednodušená postava (stick figure) s **klíčovými polohami** pohybu, mezi kterými aplikace plynule interpoluje — offline, bez sítě, bez třetích stran a licenční nejistoty (R8P-009). Nejde o video ani fotografie skutečných osob (R8 §5.2); jde o pochopitelné schéma pohybu, které vlastník zreviduje na zařízení.

**Blocking pro `R8-04 – Exercise Illustrations`.**

# 2. Formát

- **Ilustrace = archetyp pohybu** (`ExercisePoseAnimation`): topologie postavy (segmenty mezi pojmenovanými body, hlava jako kruh, volitelné rekvizity — podlaha, hrazda/lišta, kruhy, stěna, lavice) + **2–4 klíčové polohy** (souřadnice bodů v normalizovaném prostoru 0..1) + způsob smyčky (ping-pong / cyklus) a doba jednoho cyklu.
- **Vykreslení nativně** (`CustomPainter`, lineární/eased interpolace mezi polohami) — žádný externí formát, žádný asset ke stažení, žádná závislost navíc; deterministické pro daný čas animace (`EXI-002`).
- **Mapování kód → archetyp** je explicitní tabulka (`exercise_illustrations.dart`): více katalogových cviků sdílí archetyp (např. `PULL_UP`/`CHIN_UP`/`NEGATIVE_PULL_UP` = archetyp shybu; varianty kliku = archetyp kliku), volitelně zrcadleno/orientováno (`EXI-003`). Archetyp je vždy autorský obsah repa (`EXI-005`).
- **Bez ilustrace** je poctivý stav: kód bez záznamu v tabulce nebo vlastní cvik → průvodce i detail zobrazí jen popis + cue (C51), žádný placeholder předstírající pohyb (`EXI-004`).

# 3. Kde se zobrazuje

- Průvodce (C53 karta): nad popisem provedení, animace běží jen když je session aktivní (ne v pauze — statická poloha), respektuje `MediaQuery.disableAnimations` (přístupnost: statická první poloha).
- Detail tréninku (C51 §10 UI): malý statický náhled první polohy u katalogového kroku.
- Ilustrace nikdy nenahrazuje text: popis a cue zůstávají vždy viditelné (`EXI-006`).

# 4. Rozsah a revize

- P0 pokrývá **všech 112 kódů C51** archetypem, nebo explicitní výjimkou v tabulce (`none`) — test úplnosti (`EXI-007`).
- **Revize vlastníkem na zařízení**: nálezy (nesrozumitelná/špatná poloha) se opravují úpravou klíčových poloh v témže slice; do uzavření R8 evidované (`EXI-008`).
- Výkon: vykreslení jednoduché vektorové postavy < 1 ms/frame; animace 1 ticker na kartu; žádné alokace assetů (`EXI-009`).

# 5. Invarianty

- **EXI-001** Ilustrace se váže výhradně na katalogový kód C51; vlastní cvik ilustraci nemá.
- **EXI-002** Formát = klíčové polohy postavy vykreslené nativně; deterministické; offline; bez závislostí.
- **EXI-003** Kód → archetyp je explicitní tabulka; archetypy jsou sdílené a autorské.
- **EXI-004** Bez ilustrace = poctivý stav (jen text), nikdy zavádějící placeholder.
- **EXI-005** Žádný stažený, licencovaný nebo cizí obsah; vše v repu.
- **EXI-006** Text (popis, cue) je vždy viditelný; ilustrace doplňuje.
- **EXI-007** Úplnost: každý kód má archetyp nebo explicitní `none`; test.
- **EXI-008** Revize vlastníkem na zařízení; nálezy se opravují úpravou poloh.
- **EXI-009** Výkonově nenáročné; animace stojí v pauze a při `disableAnimations`.
- **EXI-010** Evidence: test úplnosti mapování, test determinismu interpolace (poloha v čase t), rendering test karty s ilustrací i fallbacku, R1–R7 E2E zelené.

# 6. Ready podmínka

`R8-04` je `READY`, jakmile tento dokument existuje (verze 0.1). Definition of Done: §5 EXI-010 zelená, analyze čistý, `DOCUMENTATION_STATUS.md` aktualizován; on-device revize vlastníkem je součást R8 Exit Review.
