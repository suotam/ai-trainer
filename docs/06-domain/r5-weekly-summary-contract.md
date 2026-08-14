# AI Trainer – R5 Weekly Summary & Progress Explanation Contract (C39)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r5-weekly-summary-contract.md`
**Vlastník:** Domain (metrics-model) + Mobile
**Kontraktní ID:** C39 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/r3-progress-statistics-contract.md` (C23 — jediný zdroj čísel), `docs/06-domain/r5-daily-checkin-contract.md` (C33), `docs/02-product/release-scope.md` (§9.2 týdenní shrnutí, základní vysvětlení progresu)
**Navazující dokumenty:** implementace R5-07, R5-08 (E2E)
**Vlastněné pojmy nebo kontrakty:** týdenní souhrn, základní vysvětlení progresu a pravidla `WKS-001` až `WKS-015`

---

# 1. Purpose

Týdenní souhrn je **deterministický read model** (C23 vzor): fakta posledních 7 dní + poctivé porovnání s předchozími 7 dny + **základní vysvětlení progresu jako typovaný stav** — žádná AI, žádná uložená čísla, žádné motivační výmysly.

**Blocking pro `R5-07`** (spolu s C40).

# 2. Obsah souhrnu

Okna: **aktuálních 7 dní** (končí dnes) a **předchozích 7 dní** (pro trend). Obsah:

1. **Tréninková fakta (výhradně C23):** plánováno / dokončeno / completion rate (C23 sémantika vč. „—" bez plánu), ruční aktivity počet + minuty.
2. **Check-in fakta (C33):** počet check-inů, průměrná energie/únava (1 desetina), dny s bolestí.
3. **Vysvětlení progresu — typovaný stav** z dokončených workoutů obou oken: `NO_DATA` (obě okna 0 dokončených), `IMPROVING` (aktuální > předchozí), `STEADY` (=), `SLOWING` (<). UI překládá opatrně a fakticky (bez soudů a slibů).

# 3. Invarianty (`WKS`)

- **WKS-001 — Deterministický read model.** Stejný stav DB + stejný den → identický souhrn; žádná persistence odvozenin (C23 vzor).
- **WKS-002 — Čísla výhradně z C23.** Souhrn nepočítá vlastní tréninková čísla; jen skládá `statisticsForPeriod` dvou oken.
- **WKS-003 — Trend jen z faktů** dle §2.3; žádné predikce, skóre ani „formuláře".
- **WKS-004 — Poctivé prázdné stavy.** Bez plánu „—" (PST vzor); bez check-inů se check-in sekce přizná jako prázdná; `NO_DATA` je validní vysvětlení.
- **WKS-005 — Opatrné formulace** (SFR-008 vzor): fakta a trend, žádná medicínská ani výkonnostní tvrzení.
- **WKS-006 — Offline vždy**; žádná AI (vysvětlení je deterministické mapování).
- **WKS-007 — Okna přesně** dle §2 (7+7 dní, konec dnes, lokální data); nikde jinde se nepřepočítávají.
- **WKS-008 — Souhrn nejedná.** Nic nemění; je to čtecí obrazovka.
- **WKS-009 — Bez PII navíc**; volné texty (check-in note) do souhrnu nepatří.
- **WKS-010 — Stabilní kódy stavů** vysvětlení (§2.3); UI překládá, doména ne.
- **WKS-011 — R1–R4 read modely beze změny**; souhrn je aditivní konzument.
- **WKS-012 — Rozšíření jen kontraktem.**
- **WKS-013 — Deterministické zaokrouhlení** (průměry 1 desetina, ADX-002 vzor).
- **WKS-014 — Budoucí AI vysvětlení = nový kontrakt**; C39 vysvětlení zůstává deterministický fallback.
- **WKS-015 — Evidence.** Testy: mapovací matice vysvětlení, determinismus, obě okna, prázdné stavy, widget obrazovky; flaky ≠ zelený důkaz.

# 4. Ready condition

C39 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C40 činí **`R5-07` `READY`**.
