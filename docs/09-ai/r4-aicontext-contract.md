# AI Trainer – R4 AIContext & Request Classification Contract (C27)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-aicontext-contract.md`
**Vlastník:** Domain (ai-and-change-model §8–§10) + Security + Mobile
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C27 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/06-domain/ai-and-change-model.md` (§8 AIContext, §10 AIIntent), `docs/09-ai/r4-ai-gateway-contract.md` (C25), kontrakty C17–C23 (zdroje dat), `docs/11-security/security-architecture.md`, `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-02, C28 (schéma výstupu), C31 (safety)
**Vlastněné pojmy nebo kontrakty:** klasifikace AI požadavků, minimalizovaný autorizovaný AIContext pro `PLAN_PROPOSAL`, zakázaný obsah, determinismus a pravidla `ACX-001` až `ACX-015`

---

# 1. Purpose

AIContext je **jediný** obsah, který o uživateli odchází do modelu — proto podléhá nejpřísnější disciplíně: **účelová minimalizace, autorizace, žádné identifikátory, žádné secrets** (R4P-005). Tento kontrakt závazně definuje, co kontext pro `PLAN_PROPOSAL` obsahuje, co obsahovat nesmí a jak je stavěn deterministicky **na klientu** z lokálních R3 dat (plán §6 — server payloady nečte).

**Blocking pro `R4-02`.**

# 2. Klasifikace požadavků

P0 typ: **`PLAN_PROPOSAL`** (jediný). Každý typ má vlastní minimalizační pravidla; nový typ = aditivní rozšíření tohoto kontraktu (nikdy implementací).

# 3. Obsah kontextu `PLAN_PROPOSAL` (co SMÍ obsahovat)

Deterministický JSON stavěný z lokálních R3 dat aktuálního vlastníka:

- **sports** (jen `ACTIVE`/`PAUSED`, C17): katalogový kód nebo custom název, role, priorita, zkušenost, participation pattern (frekvence/délka/intenzita/prostředí, pevné dny),
- **goals** (jen `ACTIVE`, C18): title, typ, priorita, horizont, volitelný termín a **sport resolvovaný na kód/název** (nikdy ID),
- **typicalWeek** (C19): deklarované dny — den, level, budget minut, preferovaná část dne,
- **equipment** (jen `ACTIVE`, C19): kódy / custom názvy,
- **constraints** (jen `ACTIVE`, C19): titles (uživatelova vlastní slova o omezeních jsou účelově nezbytná),
- **statistics** (C23): agregáty za posledních 30 dní — planned/completed/manual counts + manual minuty; žádný detail historie,
- **requestType** identifikátor.

# 4. Zakázaný obsah (co NESMÍ obsahovat — ACX-004)

Account/e-mail/session/instalace identifikátory; tokeny a jakékoli secrets; **lokální entity ID** (kontext je by-value); owner ID (vč. `local-anonymous`); sync/verzovací metadata; **volné poznámky (`note`) všech entit** (mimo účel; mohou nést PII); detailní tréninková historie a výkonová data (P0 jen agregáty §3); data jiných vlastníků; cokoli mimo výčet §3.

# 5. Determinismus a meze

Stejný stav DB → **bajtově identická** serializace (stabilní pořadí polí i položek — přebírá deterministické řazení C17–C23 read modelů). Prázdný profil je validní kontext (prázdné seznamy + nulové agregáty — unknown ≠ vymyšleno). Seznamy jsou přirozeně malé; při překročení 50 položek na sekci se deterministicky ořezává podle řazení sekce (a ořez se v kontextu přizná polem `truncated`).

# 6. Invarianty (`ACX`)

- **ACX-001 — Účelová minimalizace.** Kontext obsahuje výhradně data nutná pro daný typ požadavku (§3); rozšíření = změna kontraktu.
- **ACX-002 — Staví klient.** Kontext vzniká lokálně z R3 dat aktuálního vlastníka; server ho nečte ani neobohacuje (AGW-014).
- **ACX-003 — By-value bez ID.** Žádné lokální/serverové identifikátory; reference se resolvují na kódy/názvy.
- **ACX-004 — Zakázaný obsah** dle §4; porušení je defekt bezpečnosti, ne stylistika.
- **ACX-005 — Žádné poznámky.** Volná `note` pole se nikdy nepřenášejí.
- **ACX-006 — Jen aktivní data.** ENDED/ARCHIVED/RESOLVED/ABANDONED/zrušené entity se nepřenášejí (výjimka: PAUSED sport — relevantní pro plánování).
- **ACX-007 — Agregáty místo historie.** Výkonová/tréninková historie výhradně jako C23 agregáty.
- **ACX-008 — Determinismus.** Stejný vstupní stav → identická serializace; testovatelné bajtovým porovnáním.
- **ACX-009 — Prázdný profil validní.** Žádné dopočítávání ani vymýšlení hodnot.
- **ACX-010 — Ohraničená velikost** s deterministickým, přiznaným ořezem (§5).
- **ACX-011 — Typ povinný.** Kontext nese `requestType`; neznámý typ je validační chyba.
- **ACX-012 — Autorizace kontextu.** Data výhradně aktuálního lokálního vlastníka (owner-scoped čtení).
- **ACX-013 — Data nejsou instrukce.** Kontext se předává modelu jako data (AGW-014); obranu rozvine C31.
- **ACX-014 — Bez sítě.** Builder je čistě lokální a synchronně testovatelný.
- **ACX-015 — Evidence.** Testy: determinismus (bajtové porovnání), zakázaný obsah (markery v notes/ID/owner se nesmí objevit), stavové filtry, resolvace sport linku, prázdný profil; flaky ≠ zelený důkaz.

# 7. Ready condition

C27 je Done vytvořením tohoto dokumentu a zápisem do doc mapy → **`R4-02` je `READY`**.
