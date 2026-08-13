# AI Trainer – R4 Prompt Versioning & AI Audit Contract (C26)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-prompt-audit-contract.md`
**Vlastník:** Backend + Security (rozšíření C14 vzoru)
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C26 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`)
**Navazuje na:** `docs/09-ai/r4-ai-gateway-contract.md` (C25), `docs/11-security/r2-audit-event-contract.md` (C14), `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-01, C28 (schema verze), C32 (eval — verze jako osa datasetu)
**Vlastněné pojmy nebo kontrakty:** prompt registry s verzemi, verzování v odpovědích, AI audit události a pravidla `PAA-001` až `PAA-015`

---

# 1. Purpose

Každý AI výstup musí být **dohledatelný k přesné verzi promptu, schématu a modelu** (R4P-008) a každá AI operace musí zanechat **auditní stopu bez citlivého obsahu** (R4P-009). Tento kontrakt definuje prompt registry a závaznou tabulku AI audit událostí (aditivní rozšíření C14 vzoru).

**Blocking pro `R4-01`** (spolu s C25).

# 2. Prompt registry

- Prompty žijí **v kódu backendu** jako verzované artefakty registru: stabilní identifikátor `{typ}-v{N}` (P0: `plan-proposal-v1`).
- **Vydaná verze se nikdy needituje** — změna znění = nová verze (`plan-proposal-v2`); stará verze zůstává v registru pro dohledatelnost.
- Prompt neobsahuje žádná uživatelská data — kontext se předává odděleně jako data (AGW-014); šablona + kontext se skládají až v provider adaptéru.
- Registr je jediný zdroj promptů — žádné inline prompty ve volajícím kódu.

# 3. Verzování v odpovědi

Každý úspěšný gateway výsledek (a následně AIProposal, C29) nese: **prompt verzi**, **schema verzi** (C28) a **model identifikátor** (skutečný model z odpovědi providera; u fake providera stabilní `fake-model`). Bez těchto polí je výsledek nevalidní.

# 4. AI audit události (závazná P0 tabulka, C14 vzor)

| Událost | Kdy | Povinná pole (bez PII/obsahu) |
|---|---|---|
| `AiProposalRequested` | přijetí požadavku gateway | account, request typ, prompt verze |
| `AiProposalGenerated` | úspěšná odpověď providera | account, request typ, prompt verze, model id, outcome SUCCESS |
| `AiProposalFailed` | typované selhání (timeout/provider/nevalidní výstup) | account, request typ, prompt verze, outcome REJECTED + druh selhání |

Rozhodnutí uživatele a provedení ChangeSetu auditují pozdější slices (C29/C30 doplní události aditivně).

# 5. Invarianty (`PAA`)

- **PAA-001 — Registr je jediný zdroj promptů.**
- **PAA-002 — Verze immutable.** Vydaný prompt se needituje; oprava = nová verze.
- **PAA-003 — Stabilní identifikátory** `{typ}-v{N}`; nikdy se nerecyklují.
- **PAA-004 — Prompt bez uživatelských dat.** Kontext je oddělený payload.
- **PAA-005 — Trojice verzí povinná.** Prompt + schema + model v každém úspěšném výsledku.
- **PAA-006 — Model id ze skutečné odpovědi** (fake provider: stabilní kód).
- **PAA-007 — Audit povinný** pro každou gateway operaci dle tabulky §4.
- **PAA-008 — Audit bez obsahu.** Nikdy prompt text, kontext, odpověď modelu, PII ani klíče.
- **PAA-009 — Audit v transakci operace** (C14 vzor, AEC).
- **PAA-010 — Selhání se audituje** vždy s druhem selhání; žádné tiché chyby.
- **PAA-011 — Log redakce.** Prompty/kontexty/odpovědi se nelogují na INFO+; chybové logy bez obsahu.
- **PAA-012 — Aditivní rozšiřování.** Nové události/typy se přidávají kontraktem (C29/C30), ne implementací.
- **PAA-013 — Dohledatelnost návrhu.** Z AIProposal lze určit přesné verze (C29 povinnost pole převezme).
- **PAA-014 — Eval osa.** Eval dataset (C32) referencuje prompt/schema verze.
- **PAA-015 — Evidence.** Testy: registr verzí, immutabilita (nová verze ≠ mutace), audit události vč. selhání, audit/log bez obsahu; flaky ≠ zelený důkaz.

# 6. Ready condition

C26 je Done vytvořením tohoto dokumentu a zápisem do doc mapy. Spolu s C25 činí **`R4-01` `READY`**.
