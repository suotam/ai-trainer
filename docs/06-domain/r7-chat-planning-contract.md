# AI Trainer – R7 Chat Planning Orchestration Contract (C49)

**Verze:** 0.1  
**Stav:** Draft  
**Soubor:** `docs/06-domain/r7-chat-planning-contract.md`  
**Vlastník:** Domain + Mobile  
**Navazuje na:** C48 (chat action protocol), C27 (AIContext), C28/C37 (schémata návrhů), C29 (AIProposal lifecycle), C30/C38 (execution + safety veto), C34 (safety), `docs/13-delivery/r7-vertical-slice-plan.md`  
**Blokuje:** `R7-04 – Chat-Driven Planning and Adjustments`

---

# 1. Účel

Napojuje chat na **existující plánovací pipeline** — „postav mi týden" / „dneska jsem rozlámaný, uber" v konverzaci. Chat je výhradně vstupní vrstva (R7P-001): **AIProposal zůstává jediný nosič návrhu** (C29), klientská validace (C28/C37), potvrzení uživatele a provedení C30/C38 se safety vetem platí beze změny. Žádná nová plánovací cesta nevzniká.

# 2. REQUEST akce (rozšíření chat-action-schema-v1)

- Prompt **chat-v3** (nový immutable záznam, PAA-002/003) přidává dva druhy akcí bez polí: `{"action":"REQUEST_PLAN"}` a `{"action":"REQUEST_ADJUSTMENT"}` — model je emituje, když atlet žádá návrh plánu, resp. úpravu dne/týdne.
- **Nejvýše jedna REQUEST akce na odpověď** (bounded práce, R7P-009/013); víc = nevalidní celek (CHA-003 vzor). Kombinace s profilovými akcemi C48 je dovolena.
- REQUEST akce **není mutace** — spouští existující pipeline žádosti o návrh (C27 kontext → BYOK volání → C28/C37 validace → C29 `PROPOSED`), tedy totéž, co tlačítko na AI obrazovce. Provádí se v témže uživatelském kroku bez dalšího potvrzení; jedno uživatelské zadání ⇒ nejvýše 2 volání modelu (chat + pipeline).

# 3. Lifecycle a zobrazení v konverzaci

- Výsledek pipeline se váže k akci: úspěch → akce `APPLIED` s `proposalId` v payloadu; typované selhání (bez klíče/nedostupné/nevalidní výstup) → akce `FAILED` s důvodem a explicitním retry (CHA-007).
- Konverzace zobrazuje návrh **kartou návrhu** čtenou z C29 úložiště (jediný zdroj pravdy): summary, workouty s důvody / operace s dopady, stav. **Potvrzení/odmítnutí v chatu = C29 rozhodnutí** — táž akce jako na AI obrazovce (potvrzení spouští C30/C38 provedení vč. safety veta v témže kroku; EXECUTION_FAILED nabízí explicitní nový pokus).
- Stav návrhu je trvale viditelný v konverzaci i na AI obrazovce (jeden artefakt, dvě okna — žádná duplikace).

# 4. Invarianty

- **CHP-001** AIProposal je jediný nosič návrhu; chat nikdy nedrží vlastní kopii obsahu návrhu.
- **CHP-002** Nejvýše jedna REQUEST akce na odpověď; nadlimit = nevalidní celek.
- **CHP-003** REQUEST spouští výhradně existující pipeline (C27–C29); žádný nový kontext ani schéma.
- **CHP-004** Mutace vzniká výhradně C29 potvrzením návrhu; provedení výhradně C30/C38 (safety veto beze změny, i z chatu).
- **CHP-005** Selhání pipeline je typovaný stav akce s explicitním retry; žádný auto-retry.
- **CHP-006** Jedno uživatelské zadání ⇒ nejvýše 2 volání modelu.
- **CHP-007** Rozhodnutí o návrhu v chatu a na AI obrazovce jsou táž operace nad týmž artefaktem.
- **CHP-008** Prompt chat-v3 je nový immutable záznam; chat-v2 se needituje.
- **CHP-009** Karta návrhu čte výhradně C29 read model; stavy (PROPOSED/…/EXECUTION_FAILED) se zobrazují poctivě.
- **CHP-010** Deterministické testy: chat i pipeline s fake klienty; živé volání jen on-device evidence (BYK-013).
