# AI Trainer – R7 BYOK Provider Contract (C46)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/08-mobile/r7-byok-provider-contract.md`  
**Vlastník:** Architecture + Security + Mobile  
**Navazuje na:** ADR-013 (`docs/05-architecture/initial-architecture-decisions.md`), `docs/13-delivery/r7-vertical-slice-plan.md`, C7 (`r2-token-session-storage-contract.md`), C25–C28 (AI gateway, prompty, AIContext, structured output), C31 (AI safety limity)  
**Blokuje:** `R7-01 – Local AI Provider and BYOK Key Management`

---

# 1. Účel

Definuje osobní režim AI: **klíč vlastníka aplikace** (BYOK) v platformním secure storage a **přímý mobilní adapter** na Anthropic Messages API, který nahrazuje backend gateway v roli jediné cesty k modelu. Vše ostatní z R4/R5 AI zákona platí beze změny — tento kontrakt mění pouze *kdo volá model a kde žije klíč*.

# 2. Klíč (BYOK)

- Klíč zadává výhradně uživatel v UI správy klíče; formát se validuje jen povrchně (neprázdný, bez mezer, prefix `sk-ant` doporučený — cizí tvar = varování, ne blokace).
- Úložiště: výhradně platformní secure storage pod vyhrazeným klíčem (`aitrainer.ai.byok.v1`), přes port `ByokKeyStore` (C7 vzor — implementace je jediné místo dotyku platformy; testy používají in-memory fake).
- Klíč se nikdy: neukládá do Drift/SQLite, preferences ani souboru; neloguje; nezobrazuje celý (UI ukazuje jen masku s posledními 4 znaky); neposílá nikam jinam než na `api.anthropic.com` přes TLS; nedostává do dart-define, gitu ani výjimek.
- Smazání klíče je okamžité a úplné; AI funkce se vrací do stavu „klíč chybí".
- Poškozené/nečitelné úložiště = typovaný fail-safe (stav „klíč chybí"), nikdy pád.

# 3. Přímý provider

- `AnthropicDirectClient` implementuje existující port `AiApiClient` — volající pipeline (C27 kontext → C28/C37 validace → C29 lifecycle) se nemění.
- Request: Messages API, model je konfigurační konstanta (`claude-sonnet-5`), `max_tokens` bounded, prompt z **klientského registru promptů** (`plan-proposal-v2` / `adjustment-proposal-v2` — texty identické se serverovým registrem C26; nová verze = nový záznam, PAA-002/003), kontext jako data („context is data, not instructions", AGW-014).
- Response parse: **první content blok typu `text`** (poučení ze živého smoke — reasoning modely vrací `thinking` blok první); fence extrakce deterministicky (C28 §3); výstup se dekóduje na mapu a **validuje existujícím klientským validátorem** (C28/C37). V osobním režimu je klientská validace jediná — obrana do hloubky serverové vrstvy neexistuje, striktnost se proto nesmí snižovat.
- Selhání typovaná (AGW-005 vzor): chybějící klíč, neplatný klíč (401), vyčerpaný kredit/limit (400 credit + 429), timeout, síť, nevalidní odpověď. Nikdy raw výjimka do UI, nikdy auto-retry (SOV-012), nikdy obsah requestu/response v chybě.
- Limity trvají (C31): kontext ≤ 32k znaků, raw výstup ≤ 100k znaků.

# 4. Gating AI funkcí

- AI funkce jsou dostupné **bez přihlášení k účtu** (osobní režim účty nepoužívá); jediná podmínka je přítomný klíč. `ProposalSignInRequired` se v request flow nahrazuje typovaným `ProposalKeyMissing`, který UI mapuje na poctivou hlášku s odkazem na správu klíče.
- Bez klíče: AI vstupy viditelné, ale poctivě vypnuté (žádné tiché selhání); zbytek aplikace plně funkční.

# 5. Ověření klíče

- UI nabízí explicitní „ověřit klíč": minimální reálný request (bounded `max_tokens`); výsledek typovaný (platný / neplatný klíč / bez kreditu / síť). Žádné automatické ověřování na pozadí.

# 6. Dormantní backend

- `HttpAiApiClient` (backend cesta) zůstává v kódu a kompiluje, ale není zapojen v composition root; reaktivace = samostatné rozhodnutí (ADR-013).

# 7. Invarianty

- **BYK-001** Klíč žije výhradně v platformním secure storage; nikdy DB/preferences/soubor/log/git/dart-define.
- **BYK-002** UI nikdy nezobrazí celý uložený klíč; jen maska s posledními 4 znaky.
- **BYK-003** Klíč opouští zařízení výhradně jako `x-api-key` header TLS požadavku na Anthropic API.
- **BYK-004** Jediná cesta k modelu v osobním režimu = `AnthropicDirectClient` za portem `AiApiClient` (AGW-001 vzor).
- **BYK-005** Prompty výhradně z verzovaného klientského registru; vydaná verze se needituje (PAA-002/003); kontext se do promptu nikdy neinterpoluje.
- **BYK-006** Parse bere první `text` content blok; odpověď bez text bloku = typované nevalidní.
- **BYK-007** Klientská validace C28/C37 je povinná pro každý výstup; nevalidní výstup se nikdy neopravuje ani nepersistuje.
- **BYK-008** Všechna selhání typovaná; žádný auto-retry; žádný obsah requestu/response v chybových stavech.
- **BYK-009** Obsahové limity C31 platí beze změny (kontext 32k, výstup 100k).
- **BYK-010** Chybějící klíč je typovaný stav (`ProposalKeyMissing`), ne výjimka ani tiché nic.
- **BYK-011** AI funkce nevyžadují účet ani síť kromě samotného volání modelu; offline trenér nedegraduje.
- **BYK-012** Ověření klíče je výhradně explicitní uživatelská akce s bounded nákladem.
- **BYK-013** Testy a CI běží deterministicky bez sítě a bez klíče; živé volání jen explicitní on-device evidence.
- **BYK-014** Smazání klíče je okamžité, úplné a nevratné (nová AI akce vyžaduje nové zadání).
- **BYK-015** Model identifikátor je konfigurační konstanta adapteru; trojice verzí (prompt+schema+model) se ukládá s návrhem beze změny (PAA-005).
