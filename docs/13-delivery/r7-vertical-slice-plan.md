# AI Trainer – R7 Personal Chat Trainer Vertical Slice Plan (Local-First, BYOK, Chat-Driven)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/13-delivery/r7-vertical-slice-plan.md`  
**Vlastník:** Delivery Architecture + Product  
**Navazuje na:** R6 Exit Review (`DOCUMENTATION_STATUS.md` §3), `docs/01-vision/vision.md`, `docs/06-domain/*` (C20/C21/C23 operace a read modely), R4/R5 AI pipeline (C25–C32, C36–C38), `docs/13-delivery/definition-of-ready-and-done.md`, `docs/14-quality/test-strategy.md`  
**Navazující dokumenty:** R7 detailní kontrakty (viz §7.1), ADR-013  
**Vlastněné pojmy nebo kontrakty:** pořadí implementace R7, slice boundaries R7, R7 blocking contract map, evidence gates R7, R7 Exit Review a pravidla `R7P-001` až `R7P-015`

---

# 1. Účel

Kanonický implementační plán pro **R7 – Personal Chat Trainer**: produktový pivot potvrzený vlastníkem produktu (2026-08-15). Cílová podoba: **osobní aplikace na jednom telefonu**, kde primárním rozhraním je **chat** — uživatel konverzačně popíše své sportovní vyžití, cíle a čas, asistent z toho postaví profil a tréninkový plán, tréninky žijí v kalendáři, uživatel je odklikává a vidí statistiky.

Dva architektonické pilíře pivotu:

1. **Local-first bez vlastního serveru** — celá aplikace běží na telefonu; AI volání jdou přímo na Anthropic API s **vlastním klíčem uživatele** (BYOK) uloženým v platformním secure storage. Backend zůstává v repu jako dormantní volitelná komponenta (multi-device budoucnost), ale žádný R7 flow na něm nezávisí.
2. **Chat je vstupní vrstva, ne nová doména** — základní zákon R4 trvá beze změny: **AI navrhuje, doména provádí**. Chat nikdy nezapisuje přímo; každá změna jde přes existující doménové operace (C20/C21, repos R3/R5) po explicitním potvrzení uživatele.

---

# 2. Delivery princip

- R7 se implementuje po slicech; kontrakt předchází implementaci; slice bez blokujících kontraktů je `NOT_READY`.
- **Žádný přepis domény** — R1–R6 doménové vrstvy (plány, workouty, sessions, check-iny, safety, statistiky, kalendářní operace) se znovupoužívají beze změny; R7 přidává vrstvy nad nimi.
- **Klíč uživatele je jeho majetek** — žije výhradně v platformním secure storage (C7 vzor), nikdy v Drift/SQLite, logu, záloze ani gitu; aplikace ho nikdy nezobrazuje celý.
- **Deterministické jádro trvá** — safety (C34), doporučení (C35), statistiky (C23) zůstávají deterministické; chat je nikdy neobchází ani nepřepisuje.
- **Bez sítě = plně funkční trénink** — chat a AI jsou volitelné online vrstvy; R1 flow nesmí degradovat.

---

# 3. Celkové pořadí

```text
R7-01  Local AI Provider and BYOK Key Management (ADR-013, přímé volání z telefonu) (mobile)
R7-02  Chat Conversation Model and UI (lokální persistence, poctivé stavy)         (mobile)
R7-03  Chat-Driven Profile Setup (extrakce → potvrzení → existující repos)         (mobile)
R7-04  Chat-Driven Planning and Adjustments (reuse C27–C30/C36–C38 pipeline)       (mobile)
R7-05  Calendar View, Quick Complete and Stats Surfacing                           (mobile)
R7-06  R7 Critical End-to-End Evidence and Exit Review                             (mobile)
```

Princip řazení: **nejdřív cesta k modelu (BYOK), pak konverzační nosič, pak schopnosti chatu od profilu k plánování, pak denní smyčka (kalendář → odkliknutí → statistiky), nakonec důkaz celku.**

---

# 4. R7 value statement

**Hlavní hodnota R7:** Vlastník aplikace vede v telefonu konverzaci: „hraju 2× týdně florbal, chci zhubnout a zesílit, mám čas po večerech" → asistent založí/aktualizuje profil (sporty, cíle, dostupnost) a navrhne týdenní plán → po potvrzení jsou tréninky v kalendáři → uživatel je odklikává (rychlé dokončení) → statistiky a týdenní souhrn ukazují skutečný průběh. To vše **bez vlastního serveru, bez PC — jen telefon a vlastní API klíč**.

---

# 5. Scope a non-goals

## 5.1 R7 P0 scope

BYOK správa klíče + přímý mobilní Anthropic adapter; chat konverzace (model, persistence, UI); chatem řízené nastavení profilu s potvrzováním; chatem řízený návrh a úprava plánu (existující pipeline); kalendářní pohled na týden/měsíc; rychlé dokončení tréninku; zpřístupnění statistik z denní smyčky; R7 E2E.

## 5.2 Non-goals R7

- multi-device, účty a serverová synchronizace (backend dormantní; R2/R6 mechanismy se nemažou, jen nejsou v P0 cestě),
- jiní AI provideři než Anthropic (multi-provider = případné budoucí rozšíření; „přihlášení OpenAI účtem" neexistuje jako veřejné API),
- hlasové rozhraní, proaktivní chat iniciativa, push notifikace ze serveru,
- streaming odpovědí (P0 = celé odpovědi; streaming je UX vylepšení, ne podmínka),
- systémový kalendář OS (P0 = kalendář v aplikaci; export do OS kalendáře je kandidát R8),
- export/import zálohy (kandidát R8 — do té doby jsou data na jednom zařízení bez zálohy, **vědomé riziko vlastníka**).

## 5.3 Vazba na beta gate R6

Pivot na osobní aplikaci mění význam beta gate: „živý provider smoke" je splacen (R6) a nahrazuje ho on-device evidence R7 s BYOK; „platformní notifikace" zůstává dluh C40 (mimo R7 P0); „emulátorová evidence" se stává **průběžnou on-device evidencí** — R7 se vyvíjí proti skutečnému zařízení.

---

# 6. Architektonické principy R7

- **ADR-013 (C46) ruší serverovou výhradu klíče pro osobní režim**: C25/AGW-003 („klíč jen na serveru") platil pro provoz s backendem; ADR-013 definuje osobní režim, kde je klíč uživatele v platformním secure storage a AI volání jdou přímo z telefonu. Bezpečnostní invarianty se **přenášejí, ne ruší**: klíč nikdy do DB/logů/záloh/gitu, timeouty povinné, selhání typovaná, obsahové limity trvají (C31).
- **Chat = orchestrátor akcí s potvrzením**: model vrací strukturované akce (stejný vzor jako C28/C37 — striktní validace, kanonizace, žádné opravy); akce se provádí výhradně existujícími operacemi po explicitním potvrzení v UI. Volný text modelu se nikdy neinterpretuje jako příkaz.
- **Konverzace je lokální artefakt** (APL-011 vzor): historie chatu žije v lokální DB, nikdy se nesynchronizuje a neposílá zpět do modelu víc, než definuje kontrakt (okno + minimalizovaný kontext C27 vzoru).
- **Kalendář a odkliknutí jsou read/write modely nad existující doménou**: kalendář čte workout instance (C16/C21), rychlé dokončení je legitimní zkrácená session (C22 completion pravidla — dokončení bez odcvičených kroků je poctivě evidované), statistiky zůstávají C23.
- **Dev pohodlí nesmí obejít bezpečnost**: žádný default klíč v kódu, žádný klíč v dart-define; jediná cesta = uživatelské zadání do secure storage.

---

# 7. Prerequisites

1. R0–R6 uzavřené (splněno; živý smoke splacen — prompty v2 ověřené proti reálnému modelu).
2. Existuje tento plán.
3. Pro každý slice existují blokující kontrakty (§7.1); do té doby `NOT_READY`.

## 7.1 R7 blocking contract map

Číslování navazuje na R6 (C41–C45):

| # | Kontrakt | Vlastník | Navrhovaná cesta | Před slicem | Minimum |
|---|---|---|---|---|---|
| C46 | ADR-013 – Local-first BYOK architecture | Architecture + Security | `docs/05-architecture/initial-architecture-decisions.md` (ADR-013) + `docs/08-mobile/r7-byok-provider-contract.md` | R7-01 | osobní režim, klíč výhradně secure storage, přímý Anthropic adapter na mobilu (timeout, typovaná selhání, limity C31), vztah k dormantnímu backendu, nikdy klíč do DB/logu/zálohy |
| C47 | Chat conversation model | Domain + Mobile | `docs/06-domain/r7-chat-conversation-contract.md` | R7-02 | lokální persistence konverzací a zpráv, role, stavy odpovědi (čeká/selhala/hotová — typované), okno kontextu do modelu, PII hranice (co se do modelu nikdy neposílá), žádný sync |
| C48 | Chat action protocol | Domain + Security + Mobile | `docs/06-domain/r7-chat-action-contract.md` | R7-03 | strukturované akce modelu (schema v1: upsert sport/cíl/dostupnost/omezení…), striktní dvojitá validace na klientu (C28 vzor), **každá akce vyžaduje explicitní potvrzení**, mapování na existující repos, žádná přímá SQL/DB cesta |
| C49 | Chat planning orchestration | Domain + Mobile | `docs/06-domain/r7-chat-planning-contract.md` | R7-04 | chat jako vstup do existující proposal pipeline (C27 kontext, C28/C37 schémata, C29 lifecycle, C30/C38 execution, C34 safety veto beze změny), prompt verze v registru (C26 vzor), konverzační potvrzení = C29 potvrzení |
| C50 | Calendar & quick-complete semantics | Domain + Product + Mobile | `docs/06-domain/r7-calendar-quickcomplete-contract.md` | R7-05 | kalendářní read model (týden/měsíc, stavy instancí), rychlé dokončení jako poctivá zkrácená session (vztah k C22 completion a C23 statistikám — žádné vymyšlené metriky), interakce s C21 move/cancel |

`R7-06` nový kontrakt nevyžaduje (E2E + Exit Review nad C46–C50).

---

# 8. Terminologická hranice

- **Chat** = konverzační rozhraní; **akce** = strukturovaný, validovaný a potvrzený krok, který chat předává doméně. Chat bez potvrzené akce nemění žádná data.
- **BYOK** = klíč vlastníka aplikace; není to secret aplikace ani serveru.
- **Rychlé dokončení** = evidence „trénink proběhl" bez krokového průchodu; není to totéž co plná session s výkony a nikdy se tak nevykazuje.

---

# 9. Slice detail

## 9.1 R7-01 – Local AI Provider and BYOK Key Management
**Výsledek:** Nastavení obsahuje správu klíče (zadání, maskované zobrazení, smazání; validace formátu; test spojení). Mobilní `AnthropicDirectProvider` implementuje existující AI port přímo proti api.anthropic.com (timeout, typovaná selhání, thinking-block parse — poučení ze smoke). Bez klíče = AI funkce poctivě vypnuté, vše ostatní funguje.
**Blocking:** C46. **Evidence:** unit testy adapteru (parse, selhání, limity), secure-storage marker testy (klíč nikdy v DB/logu), widget test správy klíče; on-device ruční ověření reálného volání.

## 9.2 R7-02 – Chat Conversation Model and UI
**Výsledek:** Chat obrazovka jako nový domov aplikace: konverzace persistované lokálně, zprávy uživatele/asistenta, typované stavy (odesílá se / selhalo s retry / hotovo), prázdný stav s nápovědou. Bez klíče chat vysvětlí, kde ho nastavit.
**Blocking:** C47. **Evidence:** model/persistence testy (okno kontextu, PII hranice), widget testy stavů.

## 9.3 R7-03 – Chat-Driven Profile Setup
**Výsledek:** „Hraju florbal 2× týdně a chci zhubnout" → model vrátí strukturované akce (upsert sportu, cíle, dostupnosti…) → UI je zobrazí jako potvrditelné karty → potvrzení provede existující repos → chat shrne výsledek. Odmítnutí akce je viditelný stav.
**Blocking:** C48. **Evidence:** validátor akcí (tvarová tabulka, odmítnuté payloady), potvrzovací flow testy, provedení přes repos (žádná paralelní cesta), eval-style fixtures akčního schématu.

## 9.4 R7-04 – Chat-Driven Planning and Adjustments
**Výsledek:** „Postav mi týden" / „dneska jsem rozlámaný, uber" v chatu → existující pipeline (kontext C27 → návrh C28/C37 → C29 lifecycle → provedení C30/C38 se safety vetem) → potvrzení v konverzaci → tréninky v kalendáři. AIProposal zůstává jediný nosič návrhu.
**Blocking:** C49. **Evidence:** orchestrace testy s fake providerem (návrh→potvrzení→provedení→kalendář), safety veto větev, nedostupná AI větev; on-device reálný průchod.

## 9.5 R7-05 – Calendar View, Quick Complete and Stats Surfacing
**Výsledek:** Kalendářní pohled (týden/měsíc) nad instancemi se stavy; z kalendáře start session **nebo rychlé odkliknutí** (poctivá zkrácená evidence dle C50); statistiky (C23) a týdenní souhrn (C39) dostupné z denní smyčky; dokončení se ihned propisuje.
**Blocking:** C50. **Evidence:** read model testy (hranice měsíce, TZ), quick-complete → statistiky konzistence, widget testy.

## 9.6 R7-06 – R7 Critical End-to-End Evidence and Exit Review
**Výsledek:** Automatizovaný důkaz hlavní hodnoty R7 + Exit Review.
**Blocking:** žádné nové. **Ready:** R7-01…05 Done.
**Evidence:** deterministický E2E s fake providerem: „prázdná aplikace → chat nastaví profil (potvrzené akce) → chat navrhne plán → potvrzení → kalendář → quick-complete i plná session → statistiky/souhrn odpovídají → vše bez sítě kromě AI volání"; on-device průchod téhož na skutečném telefonu s BYOK; Exit Review dle §13.

---

# 10. Cross-slice invariants

1. **AI navrhuje, doména provádí** — chat nikdy nemá přímou write cestu; jediná mutace = potvrzená akce přes existující operace.
2. **Klíč nikdy neopustí secure storage** (kromě TLS volání providera); nikdy v DB, logu, chybě, záloze, gitu.
3. **Deterministické jádro nedegraduje** — safety/doporučení/statistiky beze změny; chat je nepřepisuje.
4. **Bez klíče i bez sítě je aplikace plnohodnotný offline trenér** (R1–R6 lokální funkce).
5. **Konverzace a návrhy jsou device-local artefakty** — žádný sync, žádné odesílání historie chatu mimo definované kontextové okno.
6. **Žádné tiché akce** — každá změna dat z chatu je viditelně potvrzená a auditovatelná v UI (co se stalo a proč).
7. **Volný text ≠ příkaz** — jen validované strukturované akce; nevalidní výstup modelu je typované selhání bez opravy (SOV vzor).
8. **R1–R6 kritické E2E zůstávají zelené** (dormantní backend nezpůsobí regresi suite).
9. **Obsahové a nákladové limity** — kontextové okno a výstupní limity kontraktně dané; žádné nekonečné smyčky volání modelu, žádný auto-retry.
10. **Rychlé dokončení je poctivé** — nikdy nevytváří vymyšlené výkonové údaje; statistiky rozlišují zdroj.
11. **Jazyk konverzace: čeština** (UI l10n cs/en trvá).
12. Terminologická separace §8 se neporušuje.

---

# 11. Testovací a evidence strategie

- **Unit**: BYOK adapter (parse/selhání/limity), akční validátor (tvarová tabulka), kalendářní read model, quick-complete pravidla.
- **Widget**: chat stavy, potvrzovací karty, správa klíče, kalendář.
- **Kritická E2E (R7-06)**: deterministicky s fake providerem nad reálnou SQLite.
- **On-device evidence**: průběžně na skutečném zařízení (Pixel 9a) s reálným klíčem — nahrazuje emulátorový dluh pro osobní režim; nálezy se evidují a opravují v témže slice.
- **Eval vzor pro akce**: sdílené fixtures akčního schématu (C32 vzor) — zachycené reálné výstupy jako regres.

---

# 12. Řízené výjimky a otevřená rozhodnutí

- **Záloha dat** — do R8 bez zálohy (jedno zařízení); ztráta telefonu = ztráta dat. Vědomé riziko vlastníka, znovu evidované v Exit Review. Kandidát R8: export/import souboru.
- **Platformní notifikace** (C40 NTF-007) — trvá mimo R7 P0; reminder plán zůstává deterministický no-op.
- **Backend a sync** — dormantní (kód, testy a kontrakty zůstávají; CI je drží zelené); reaktivace = samostatné budoucí rozhodnutí.
- **Streaming, hlas, OS kalendář, multi-provider** — vědomě mimo P0 (§5.2).
- **Náklady na model** — hradí vlastník ze svého klíče; kontrakty drží limity, ne rozpočet.

---

# 13. R7 Exit Review

R7 je dokončeno pouze pokud (doloženo testy a on-device evidencí):

- klíč prokazatelně žije jen v secure storage (marker testy) a jeho správa funguje na zařízení,
- chat vede celý tok „profil → plán → kalendář → dokončení → statistiky" jen přes potvrzené akce a existující operace (E2E),
- nevalidní výstupy modelu jsou typovaně odmítnuté; safety veto drží i z chatu,
- bez klíče/bez sítě aplikace plně funguje jako offline trenér,
- kalendář a quick-complete konzistentní se statistikami (žádné vymyšlené metriky),
- R1–R6 kritické E2E zelené; R7 E2E deterministicky prochází; CI zelené,
- on-device průchod hlavního toku na skutečném zařízení s reálným klíčem proveden a nálezy uzavřeny,
- řízené výjimky (§12) znovu poctivě evidovány; žádný známý blocker ani critical defect.

---

# 14. Závazná pravidla R7

- **R7P-001 – Chat is an input layer.** Doména se nemění kvůli chatu; chat se přizpůsobuje doméně.
- **R7P-002 – Contract precedes implementation.**
- **R7P-003 – Confirmed actions only.** Žádná mutace bez explicitního potvrzení uživatele.
- **R7P-004 – Key stays in secure storage.** Nikdy DB/log/záloha/git/dart-define.
- **R7P-005 – Deterministic core stays.** Safety/statistiky/doporučení beze změny.
- **R7P-006 – Offline trainer never degrades.**
- **R7P-007 – Strict output validation.** C28 vzor pro každé schéma chatu; žádné opravy výstupu.
- **R7P-008 – Conversations are device-local.**
- **R7P-009 – No autonomous loops.** Jedno uživatelské zadání = ohraničená práce modelu; žádný auto-retry.
- **R7P-010 – Honest quick-complete.** Zkrácená evidence nikdy nepředstírá plnou session.
- **R7P-011 – R1–R6 stay green.** Dormantní ≠ rozbité.
- **R7P-012 – On-device evidence.** Vývoj proti skutečnému zařízení; nálezy se evidují.
- **R7P-013 – Cost-bounded requests.** Kontextové okno a limity kontraktně dané.
- **R7P-014 – Honest states everywhere.** Čekání/selhání/prázdno vždy typované a viditelné.
- **R7P-015 – Scope changes traceable.** Scope odvozen z vize vlastníka (2026-08-15) a R6 Exit Review.

---

# 15. Stav backlogu

R7 backlog (`R7-01` až `R7-06`) je **definovaný, ale žádný slice není `READY`** — všechny čekají na blokující kontrakty (§7.1: C46–C50). Implementace R7 nezačala.

První kanonický krok: vytvořit **C46 – ADR-013 + BYOK provider kontrakt** → tím se `R7-01` stane `READY`. Kontrakty se tvoří postupně před příslušnými slices, ne všechny najednou.
