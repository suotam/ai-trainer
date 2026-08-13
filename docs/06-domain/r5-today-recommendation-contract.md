# AI Trainer – R5 Today Recommendation Contract (C35)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/06-domain/r5-today-recommendation-contract.md`
**Vlastník:** Domain + Mobile
**Kontraktní ID:** C35 (dle `docs/13-delivery/r5-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/r5-safety-rules-contract.md` (C34), `docs/06-domain/r5-daily-checkin-contract.md` (C33), `docs/06-domain/r3-progress-statistics-contract.md` (C23 read model vzor), `docs/02-product/release-scope.md` (§9.2 Today doporučení)
**Navazující dokumenty:** implementace R5-03, C36 (AI kontext smí nést doporučení jako fakt), R5-08 (E2E)
**Vlastněné pojmy nebo kontrakty:** deterministické doporučení dne, P0 stavy doporučení a pravidla `TDR-001` až `TDR-015`

---

# 1. Purpose

Today doporučení je **deterministický read model dne**: kombinuje C34 safety assessment s dnešním plánem (R1 read model) do jedné poctivé věty s důvody. Nic nemění, nic nepočítá nad rámec C34 — **jediný zdroj signálů jsou C34 pravidla**; doporučení jen mapuje a přidává kontext plánu.

**Blocking pro `R5-03`.**

# 2. P0 stavy

Vstup: `SafetyAssessment` (C34) + počet dnešních naplánovaných workoutů (R1 read model).

| Safety stav | Plán | Doporučení |
|---|---|---|
| `INSUFFICIENT_INFORMATION` | — | `CHECK_IN_MISSING` — výzva vyplnit check-in (CTA), žádná implicitní rada |
| `DO_NOT_RECOMMEND_ACTIVITY` | — | `CONSIDER_REST` |
| `CAUTION` | — | `CONSIDER_LIGHTER_DAY` |
| `SAFE_WITH_CURRENT_INFORMATION` | > 0 workoutů | `TRAIN_AS_PLANNED` |
| `SAFE_WITH_CURRENT_INFORMATION` | 0 workoutů | `NOTHING_PLANNED` |

Důvody = C34 flags beze změny (se zdroji); doporučení žádné vlastní důvody nevyrábí.

# 3. Invarianty (`TDR`)

- **TDR-001 — Čistý deterministický read model.** Stejný vstup → identický výstup; žádná persistence, síť ani AI.
- **TDR-002 — Jediný zdroj signálů = C34.** Doporučení nemá vlastní pravidla nad check-inem; jen mapuje safety stav + kontext plánu dle §2.
- **TDR-003 — Konzervativní přednost.** Safety stav má přednost před plánem: STOP/CAUTION doporučení platí i s naplánovaným workoutem.
- **TDR-004 — Chybějící check-in = výzva, ne rada.** `CHECK_IN_MISSING` nedoporučuje trénovat ani odpočívat; CTA vede na check-in a nikdy nejedná automaticky.
- **TDR-005 — Doporučení nejedná.** Nemění plán, workouty ani check-in; rozhodnutí je vždy uživatele (vazba na RSR-005).
- **TDR-006 — Důvody viditelné a se zdrojem.** UI zobrazuje C34 flags (bolest s oblastí, omezení s titulem); žádná černá skříňka.
- **TDR-007 — Opatrná formulace.** Texty dle SFR-008 — žádná medicínská tvrzení, beta hranice trvá.
- **TDR-008 — Offline vždy.** Doporučení je plně dostupné bez sítě; žádný stav nevyžaduje AI.
- **TDR-009 — Poctivé selhání.** Nedostupný read model (výjimka podkladu) doporučení skryje — nikdy nevymýšlí stav ani neshodí Today.
- **TDR-010 — Stabilní kódy stavů** (§2); UI překládá, doména ne.
- **TDR-011 — R1 Today beze změny.** Seznam workoutů, empty i error stavy Today zůstávají nedotčené; doporučení je aditivní blok.
- **TDR-012 — Rozšíření jen kontraktem** (nový stav/vstup = revize C35).
- **TDR-013 — Žádné ukládané odvozeniny.** Vždy přepočet z aktuálních dat (C23 vzor).
- **TDR-014 — AI doporučení nepřepisuje.** Budoucí AI úprava (C36–C38) doporučení konzumuje, nikdy nemění jeho výpočet.
- **TDR-015 — Evidence.** Testy: mapovací matice §2, determinismus, widget stavy (výzva s CTA, odpočinek s důvody, trénink dle plánu) a nedotčené R1 Today testy; flaky ≠ zelený důkaz.

# 4. Ready condition

C35 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Činí **`R5-03` `READY`**.
