# AI Trainer – R7 Chat Conversation Contract (C47)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r7-chat-conversation-contract.md`  
**Vlastník:** Domain + Mobile  
**Navazuje na:** `docs/13-delivery/r7-vertical-slice-plan.md`, C46 (BYOK provider), C27 (AIContext minimalizace), C29 (AIProposal — APL-011 device-local vzor), C31 (limity), C1 (mobilní schema evoluce)  
**Blokuje:** `R7-02 – Chat Conversation Model and UI`

---

# 1. Účel

Definuje **konverzační nosič** chat-first rozhraní: lokální persistence konverzací a zpráv, typované stavy odpovědi, okno kontextu do modelu a PII hranici. R7-02 je výhradně konverzace — **chat v tomto slice nezapisuje žádná doménová data** (akce vlastní C48; volný text nikdy není příkaz, R7P-001/003).

# 2. Persistence (mobilní schema v14)

- Dvě nové Drift tabulky: `local_chat_conversations` (id, started_at, updated_at) a `local_chat_messages` (id, conversation_id FK, role, content, status, error_kind?, position, created_at).
- **Konverzace jsou device-local artefakt** (APL-011 vzor): žádný owner/sync sloupec, žádná synchronizace, žádný export mimo zařízení.
- Role: `USER` / `ASSISTANT`. Stavy zprávy: uživatelská vždy `SENT`; asistentská `PENDING` → `COMPLETED` / `FAILED` (+ typovaný `error_kind`).
- Zprávy jsou append-only v rámci konverzace, řazené `position`; opakování (retry) mění stav existující FAILED zprávy zpět na PENDING — nevzniká duplicitní řádek.
- **Jediná aktivní konverzace** (nejnovější); „nová konverzace" založí nový thread — starší zůstávají v DB (append-only), P0 bez UI seznamu historie.
- Migrace v13 → v14 je čistě aditivní (C1 vzor); žádná existující data se nemění.

# 3. Restart a poctivé stavy

- `PENDING` odpověď nepřežívá restart jako čekání: při otevření konverzace se osiřelé PENDING zprávy překlopí na `FAILED` (typovaný stav s možností explicitního retry) — žádné věčné „přemýšlí".
- UI stavy jsou typované a viditelné: odesílá se / selhalo (s důvodem a retry) / hotovo / prázdný stav s nápovědou / chybějící klíč s odkazem na správu klíče (C46 §4 vzor).

# 4. Okno kontextu do modelu

- Do modelu jde: **chat prompt z klientského registru** (`chat-v1`, immutable — PAA-002/003; persona osobního trenéra, poctivé hranice: žádné zdravotní rady, v R7-02 přizná, že data měnit neumí) + **minimalizovaný profilový kontext** (přesně C27 base payload — sporty, cíle, dostupnost, vybavení, omezení, agregované statistiky; žádná ID, žádné poznámky) předaný jako data + **okno konverzace**.
- Okno = posledních **20 zpráv** ve stavech SENT/COMPLETED (FAILED a PENDING se neposílají), v pořadí konverzace; celkový kontext drží limit C31 (32k znaků) — při překročení se okno zkracuje od nejstarších zpráv.
- **PII hranice:** mimo výše uvedené se do modelu neposílá nic — žádné e-maily, tokeny, lokální poznámky entit, DB obsah ani historie jiných konverzací. Text, který uživatel sám napíše do chatu, se odesílá doslovně (jeho rozhodnutí).

# 5. Volání modelu

- Jediná cesta = BYOK adapter (C46, BYK-004) novou chat metodou; klíč, timeouty, typovaná selhání a parse pravidla přebírá C46 beze změny (vč. thinking-block parse).
- Odpověď je volný text (bez schémat — akce až C48); prázdná odpověď = typované selhání; `max_tokens` bounded.
- Žádný auto-retry (R7P-009); jedno odeslání zprávy = nejvýše jedno volání modelu.

# 6. Invarianty

- **CHC-001** Konverzace a zprávy jsou device-local; nikdy sync, nikdy owner stamping.
- **CHC-002** Chat v R7-02 nemá žádnou write cestu k doménovým datům; volný text není příkaz.
- **CHC-003** Role výhradně USER/ASSISTANT; stavy výhradně SENT/PENDING/COMPLETED/FAILED s typovaným error_kind.
- **CHC-004** PENDING nepřežívá restart jako čekání — překlopení na FAILED s explicitním retry.
- **CHC-005** Retry je explicitní uživatelská akce nad existující FAILED zprávou; žádný auto-retry, žádné duplicitní řádky.
- **CHC-006** Okno do modelu = aktuální chat prompt + C27 base kontext + `today` (ISO datum) + posledních 20 SENT/COMPLETED zpráv; u asistentských zpráv s akcemi (C48) je za textem záznam rozhodnutí uživatele (druh + identifikace + APPLIED/REJECTED/FAILED) — model musí vidět, co už je hotové (on-device nález 3e: bez toho navrhoval tytéž akce znovu). Nic víc (PII hranice).
- **CHC-007** Kontext drží limity C31; zkracuje se deterministicky od nejstarších zpráv.
- **CHC-008** Prompt `chat-v1` žije v klientském registru; vydaná verze se needituje.
- **CHC-009** Bez klíče je chat poctivě vypnutý se srozumitelným odkazem na správu klíče; zbytek aplikace nedegraduje.
- **CHC-010** Všechna selhání typovaná (C46 kinds); nikdy raw výjimka ani obsah odpovědi v chybě.
- **CHC-011** Zprávy jsou append-only; jediná mutace je stavová (PENDING/COMPLETED/FAILED + obsah dokončené odpovědi).
- **CHC-012** Jediná aktivní konverzace; nová konverzace = nový thread, starší se nemažou.
- **CHC-013** Odpověď modelu se ukládá jak přišla (text) — žádné tiché úpravy.
- **CHC-014** Chat obrazovka nikdy neblokuje offline funkce aplikace (R7P-006).
- **CHC-015** Migrace v14 je aditivní a zachovává všechna data (C1 MSM vzor).
