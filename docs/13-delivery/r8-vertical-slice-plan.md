# AI Trainer – R8 Guided Workout Vertical Slice Plan (Katalog cviků, plán v2, průvodce tréninkem, ilustrace)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r8-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture + Product  
**Navazuje na:** R7 Exit Review a on-device nález 4 (`DOCUMENTATION_STATUS.md` §3), `docs/06-domain/workout-model.md`, `docs/12-data/r1-physical-data-model.md` (sekce → kroky → set plany), R4/R5 AI pipeline (C25–C32, C36–C38), R7 chat vrstva (C46–C50), `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R8 detailní kontrakty (viz §7.1)  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R8, slice boundaries R8, R8 blocking contract map, evidence gates R8, R8 Exit Review a pravidla `R8P-001` až `R8P-012`

---

# 1. Účel

Kanonický implementační plán pro **R8 – Guided Workout (Vedený trénink)**. Vychází z on-device nálezu 4 (2026-08-16): R7 doručil chat-first osobní aplikaci s AI plánováním, ale **vygenerované tréninky nejsou proveditelné jako vedený trénink** — cvik je jen `název + sady + opakování (+ váha)` v jediné sekci, bez popisu provedení, doby, pauz, rozcvičky a vyklidnění; tracker je plochý formulář sad bez krokového průvodce, časovačů a odpočtu pauz; katalog cviků neexistuje, takže cviky jsou volné texty modelu a nelze na ně navázat ilustrace.

Cílová podoba: uživatel v kalendáři zmáčkne **Spustit** a aplikace ho **vede krok za krokem** — aktuální cvik s popisem provedení a schematickou ilustrací, počítadlo sad, odpočet pauzy, časovač u časovaných kroků, další/předchozí, pauza/pokračovat, uplynulý čas — jako běžný workout tracker. AI plány to umožní jen tehdy, když model vrací **plnou strukturu** (sekce, kroky, sady s opakováními nebo časem, pauzy, popisy) postavenou na **uzavřeném katalogu cviků**.

---

# 2. Delivery princip

- R8 se implementuje po slicech; kontrakt předchází implementaci; slice bez blokujících kontraktů je `NOT_READY`.
- **Datový model workoutu se nepřepisuje** — R1 fyzický model (instance → sekce → kroky `EXERCISE/DURATION/REST/MOBILITY_POSITION/INSTRUCTION` → set plany s `plannedRepetitions/plannedDurationSeconds/restAfterSeconds/targetRpe`, `instructions` na kroku) je pro vedený trénink dostatečný; R8 ho **plní a čte**, případné rozšíření je výhradně aditivní (C16 vzor migrace).
- **AI navrhuje, doména provádí** trvá — plán v2 jde stejnou pipeline (C27 kontext → C28/C37 validace → C29 lifecycle → C30/C38 provedení, safety veto beze změny); mění se pouze **schéma návrhu** a jeho materializace do existujícího modelu.
- **Katalog je uzavřený seznam kódů** (C17 vzor sportů): model vybírá z katalogu; cokoli mimo katalog je vlastní cvik s povinným popisem provedení. Katalog je in-app statická data, offline, bez sítě.
- **Ilustrace jsou přibalené offline schéma**, ne stažené video: schematické SVG animace ke katalogovým cvikům, autorované v repu, vlastník je kontroluje na zařízení; žádná runtime závislost na síti ani třetí straně.
- **Bez klíče i bez sítě je průvodce plnohodnotný** — vede i ručně založené a seedové tréninky.

---

# 3. Celkové pořadí

```text
R8-01  Exercise Catalog (uzavřené kódy, popis provedení, vlastní cvik)              (mobile)
R8-02  Plan Proposal v2 (sekce, kroky, sady reps/čas, pauzy; structured outputs)    (mobile)
R8-03  Guided Session Player (krokový průvodce, časovače, odpočet pauz)              (mobile)
R8-04  Exercise Illustrations (schematické SVG animace offline)                       (mobile)
R8-05  R8 Critical End-to-End Evidence and Exit Review                               (mobile)
```

Princip řazení: **nejdřív slovník (katalog), pak aby model uměl vracet plnou strukturu nad ním, pak aby ji uživatel mohl projít, pak vizuál, nakonec důkaz celku.**

---

# 4. R8 value statement

**Hlavní hodnota R8:** Vlastník v chatu řekne „postav mi týden" → návrh obsahuje tréninky s rozcvičkou, hlavní částí a vyklidněním, každý krok je katalogový cvik s popisem provedení, sadami s opakováními nebo časem a pauzami → po přijetí je v kalendáři → **Spustit** ho vede krok za krokem s ilustrací, počítadlem sad a odpočtem pauz → dokončení zapíše skutečné výkony do statistik. Uživatel **vždy ví, co má dělat**.

---

# 5. Scope a non-goals

## 5.1 R8 P0 scope

Katalog cviků (kódy, názvy cs/en, popis provedení, svalové skupiny, vybavení, typ předpisu); plán v2 (schéma + prompt + validace + materializace do sekcí/kroků/set planů); úprava plánu v2 (ADD/REPLACE se stejnou strukturou); průvodce session (přehrávač kroků, časovače, odpočet, pauza/pokračovat, zápis výkonů zůstává); ilustrace katalogových cviků; R8 E2E.

## 5.2 Non-goals R8

- video / fotografie skutečných osob, stahovaný obsah, licencovaná databáze třetí strany (kandidát pozdějšího vylepšení vizuálu),
- hlasové vedení, hudba, zvuky mimo prostý signál konce odpočtu,
- výpočet progrese zátěže / autoregulace (RPE zápis zůstává, algoritmus mimo P0),
- wearables, HR, GPS,
- záloha export/import, platformní notifikace, streaming odpovědí, OS kalendář (trvají jako kandidáti R9).

---

# 6. Architektonické principy R8

- **Katalog = doménový slovník** (`sport_catalog` vzor): stabilní kódy nikdy nerecyklované; lokalizovaný název je prezentační vrstva; popis provedení a cue („co dělat, na co si dát pozor") jsou součást katalogu, ne modelu.
- **Model dostane katalog jako uzavřený enum ve schématu** (structured outputs, poučení z nálezu 3e) — vymyšlený kód nikdy nevznikne; pro cvik mimo katalog `customTitle` + povinné `instructions`.
- **Struktura návrhu ↔ fyzický model 1:1**: sekce (`WARM_UP/MAIN/COOLDOWN`), krok (typ, katalogový kód nebo vlastní, popis, předpis `SET_REP` nebo `DURATION`), sady (`repetitions` nebo `durationSeconds`, `weightKg`, `restAfterSeconds`). Žádné pole návrhu bez místa v modelu, žádné pole modelu, které by průvodce potřeboval a návrh nedával.
- **Průvodce je read/write model nad existující session** (C22 completion, `local_step_performances`/`local_set_performances`): krokování a časovače jsou UI stav + `activeStepId`/`elapsedActiveSeconds` session; zápis výkonů používá existující operace (`record_set_performance`), dokončení stejné pravidlo — žádná paralelní cesta.
- **Ilustrace navázané výhradně na katalogový kód**: vlastní cvik ilustraci nemá a průvodce to poctivě ukáže (popis místo obrázku).
- **Časovače jsou deterministické a obnovitelné**: odvozené z uložených časových značek session, ne z volatilního stavu — přerušení aplikace neztrácí průběh (R1-05 recovery zákon).

---

# 7. Prerequisites

1. R0–R7 uzavřené (splněno; on-device evidence trvá).
2. Existuje tento plán.
3. Pro každý slice existují blokující kontrakty (§7.1); do té doby `NOT_READY`.

## 7.1 R8 blocking contract map

Číslování navazuje na R7 (C46–C50):

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Minimum |
|---|---|---|---|---|---|
| C51 | Exercise catalog | Domain (workout-model) + Product | `docs/06-domain/r8-exercise-catalog-contract.md` | R8-01 | uzavřený seznam kódů (P0 rozsah pokrývá lezení/sílu bez posilovny/mobilitu/rozcvičku/kompenzaci — cca 60–80 položek), název cs/en, popis provedení + cue, svalové skupiny, vybavení, výchozí typ předpisu (reps/čas), vlastní cvik s povinným popisem, stabilita kódů, vazba na existující kroky (`metadataJson`/aditivní sloupec) |
| C52 | Plan proposal schema v2 | Domain + Mobile (AI) | `docs/09-ai/r8-plan-schema-v2-contract.md` | R8-02 | `plan-proposal-schema-v2` a `adjustment-proposal-schema-v2`: sekce, kroky (katalog XOR vlastní+popis), předpis reps/čas, sady, pauzy, váha, limity; structured outputs (JSON schéma = validátor); prompt v3 v registru (immutable); materializace do sekcí/kroků/set planů; koexistence s v1 daty; nevalidní = celek odmítnut (SOV vzor) |
| C53 | Guided session player | Domain (workout-model) + Mobile | `docs/06-domain/r8-guided-session-contract.md` | R8-03 | stavový model průvodce (aktuální krok/sada, běžící časovač, odpočet pauzy, pauza/pokračovat) nad existující session; obnova po přerušení; vztah k zápisu výkonů a dokončení (C22 pravidla, žádné vymyšlené hodnoty); přeskočení kroku jako poctivý stav; vedení i pro seed/ruční tréninky bez katalogu |
| C54 | Exercise illustrations | Product + Mobile | `docs/08-mobile/r8-exercise-illustrations-contract.md` | R8-04 | formát (schematické SVG s klíčovými polohami, offline asset per kód), vazba jen na katalogový kód, fallback bez ilustrace, velikost/výkon, autorská a licenční poctivost (vlastní schémata v repu), proces revize vlastníkem na zařízení |

`R8-05` nový kontrakt nevyžaduje (E2E + Exit Review nad C51–C54).

---

# 8. Terminologická hranice

- **Katalogový cvik** = položka C51 se stabilním kódem; **vlastní cvik** = krok s vlastním názvem a povinným popisem, bez ilustrace.
- **Předpis** = jak se krok provádí: `SET_REP` (sady × opakování) nebo `DURATION` (čas); pauza je atribut sady (`restAfterSeconds`) nebo samostatný krok `REST`.
- **Průvodce (player)** = krokový režim session; **tracker** = zápis výkonů (trvá uvnitř průvodce). Rychlé dokončení (C50) zůstává zkrácenou evidencí bez průvodce.

---

# 9. Slice detail

## 9.1 R8-01 – Exercise Catalog
**Výsledek:** In-app katalog cviků (kódy, názvy cs/en, popis provedení, cue, svalové skupiny, vybavení, výchozí předpis) jako doménový slovník; kroky workoutu umí nést vazbu na katalogový kód (aditivně); detail tréninku zobrazuje popis provedení u katalogových kroků; ruční tvorba plánu umí vybrat z katalogu.
**Blocking:** C51. **Evidence:** testy stability/unikátnosti kódů a úplnosti překladů, vazba krok→katalog v read modelu, widget detailu s popisem.

## 9.2 R8-02 – Plan Proposal v2
**Výsledek:** „Postav mi týden" vrátí návrh s rozcvičkou/hlavní částí/vyklidněním, kroky nad katalogem (nebo vlastní s popisem), sadami reps/čas, pauzami; vynuceno structured outputs; přijetí materializuje sekce/kroky/set plany do existujícího modelu; úprava plánu (ADD/REPLACE) používá tutéž strukturu. Karta návrhu v chatu i na AI obrazovce ukazuje strukturu čitelně.
**Blocking:** C52. **Evidence:** validátor v2 (tvarová tabulka, XOR katalog/vlastní, limity, nevalidní celek), materializace do DB (sekce/kroky/set plany vč. pauz a časů), koexistence v1 dat, eval fixtures z reálných výstupů (živá sonda), on-device reálný průchod.

## 9.3 R8-03 – Guided Session Player
**Výsledek:** **Spustit** otevře průvodce: aktuální krok (název, sekce, popis, předpis), počítadlo sad se zápisem skutečných hodnot, odpočet pauzy po sadě, časovač u `DURATION` kroků, další/předchozí/přeskočit, pauza/pokračovat, uplynulý čas; přerušení aplikace obnoví stav; dokončení = existující C22 pravidla se skutečnými výkony. Funguje i pro seed a ruční tréninky.
**Blocking:** C53. **Evidence:** stavový model testy (přechody, časovače deterministicky přes fake clock, obnova), zápis výkonů přes existující operace, widget průchod, R1 E2E zůstává zelená.

## 9.4 R8-04 – Exercise Illustrations
**Výsledek:** Ke každému katalogovému cviku schematická SVG animace (klíčové polohy) přibalená offline; zobrazená v průvodci a v detailu; vlastní cvik poctivě bez ilustrace; revize vlastníkem na zařízení (nálezy se opravují v témže slice).
**Blocking:** C54. **Evidence:** test úplnosti (každý kód má asset nebo explicitní výjimku), rendering test bez sítě, velikost balíčku v limitu, on-device vizuální revize.

## 9.5 R8-05 – R8 Critical End-to-End Evidence and Exit Review
**Výsledek:** Automatizovaný důkaz hlavní hodnoty R8 + Exit Review.
**Blocking:** žádné nové. **Ready:** R8-01…04 Done.
**Evidence:** deterministický E2E s fake providerem: „chat → plán v2 s plnou strukturou → přijetí → kalendář → Spustit → průvodce krok za krokem (sady, pauza, časovka, přeskočení) → dokončení se skutečnými výkony → statistiky/historie odpovídají"; on-device průchod s BYOK; Exit Review dle §13.

---

# 10. Cross-slice invariants

1. **AI navrhuje, doména provádí** — plán v2 jde stejnou pipeline s potvrzením; safety veto beze změny.
2. **Katalog je uzavřený a stabilní** — kódy se nikdy nemění ani nerecyklují; model nikdy nevytvoří neznámý kód (schéma), vlastní cvik má vždy popis.
3. **Model workoutu se nepřepisuje** — R1 fyzický model se plní a čte; rozšíření pouze aditivní migrací s testy.
4. **Průvodce nikdy nevymýšlí výkony** — zapisuje jen to, co uživatel zadal/odklikl; přeskočený krok je přeskočený.
5. **Obnovitelnost** — přerušení aplikace neztrácí průběh průvodce (R1-05 zákon).
6. **Offline plnohodnotný** — katalog, ilustrace i průvodce fungují bez sítě a bez klíče.
7. **Nevalidní výstup modelu = celek odmítnut** (SOV/CHA vzor), nikdy oprava ani částečné přijetí; typované selhání s retry.
8. **R1–R7 kritické E2E zelené**.
9. **Ilustrace jsou schematické, offline, autorované v repu** — žádná síť, žádná licenční nejistota.
10. **Bounded volání modelu** (R7P-009/013) trvá; strukturovanější výstup neznamená víc volání.
11. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

- **Unit**: katalog (stabilita, překlady, úplnost), validátor v2 (tvarová tabulka, limity, XOR), materializace návrhu → sekce/kroky/set plany, stavový model průvodce s fake clock (přechody, obnova).
- **Widget**: karta návrhu v2, detail s popisem, průvodce (kroky, sady, odpočet, pauza, přeskočení), ilustrace fallback.
- **Kritická E2E (R8-05)**: deterministicky s fake providerem nad reálnou SQLite.
- **Živé opt-in sondy** (`AITRAINER_LIVE_SMOKE=1`): plán v2 proti reálnému modelu; reálné výstupy jako eval fixtures (C32 vzor).
- **On-device evidence**: průběžně na Pixel 9a s reálným klíčem; vizuální revize ilustrací vlastníkem.

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Kvalita ilustrací** — schéma, ne video; vlastník revizí rozhodne, které cviky potřebují lepší vizuál (kandidát R9: doplnění z open-source zdrojů po licenční kontrole).
- **Rozsah katalogu P0** — cca 60–80 cviků cílených na vlastníkův profil (lezení, síla bez posilovny, mobilita, rozcvička, kompenzace); rozšiřování je aditivní.
- **Existující plány v1** — zůstávají čitelné a spustitelné v průvodci (kroky bez sekcí/pauz se vedou jako jsou); přegenerování je volba uživatele.
- **Záloha, notifikace, streaming, OS kalendář** — trvají jako kandidáti R9.

---

# 13. R8 Exit Review

R8 je dokončeno pouze pokud (doloženo testy a on-device evidencí):

- katalog cviků je uzavřený, stabilní a plně lokalizovaný; model nikdy nevrátí neznámý kód,
- AI plán v2 vrací plnou strukturu (sekce, kroky, sady reps/čas, pauzy, popisy), validace odmítá nevalidní celek, materializace naplní existující model,
- průvodce vede trénink krok za krokem s časovači a odpočty, obnovuje se po přerušení a zapisuje jen skutečné výkony,
- ilustrace existují pro každý katalogový cvik (nebo explicitní výjimka), fungují offline, prošly revizí vlastníka,
- R1–R7 kritické E2E zelené; R8 E2E deterministicky prochází; CI zelené,
- on-device průchod „chat → plán v2 → Spustit → průvodce → dokončení" s reálným klíčem proveden a nálezy uzavřeny,
- řízené výjimky (§12) znovu poctivě evidovány; žádný známý blocker ani critical defect.

---

# 14. Závazná pravidla R8

- **R8P-001 – Contract precedes implementation.**
- **R8P-002 – Catalog is closed and stable.** Kódy nikdy nemění ani nerecyklují; neznámý kód nevznikne.
- **R8P-003 – Workout model is filled, not rewritten.** Rozšíření jen aditivní migrací s testy.
- **R8P-004 – AI proposes, domain executes.** Plán v2 = táž pipeline, potvrzení, safety veto.
- **R8P-005 – Strict output validation.** Structured outputs + validátor; nevalidní celek odmítnut bez opravy.
- **R8P-006 – Player never invents performance.** Jen zadané/odkliknuté hodnoty; přeskočení je poctivý stav.
- **R8P-007 – Recoverable session.** Průběh průvodce přežije přerušení.
- **R8P-008 – Offline first.** Katalog, ilustrace, průvodce bez sítě a bez klíče.
- **R8P-009 – Illustrations are schematic, offline, repo-authored.**
- **R8P-010 – Bounded model calls.**
- **R8P-011 – R1–R7 stay green.**
- **R8P-012 – On-device evidence.** Vývoj a revize proti skutečnému zařízení; nálezy se evidují a opravují v témže slice.

---

# 15. Stav backlogu

R8 backlog (`R8-01` až `R8-05`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na blokující kontrakty (§7.1: C51–C54). Implementace R8 nezačala.

První kanonický krok: vytvořit **C51 – Exercise catalog kontrakt** → tím se `R8-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices, ne všechny najednou.
