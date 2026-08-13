# AI Trainer – R4 AI Gateway Contract (C25)

**Verze:** 0.1
**Stav:** Draft
**Soubor:** `docs/09-ai/r4-ai-gateway-contract.md`
**Vlastník:** Architecture + Backend
**Poslední aktualizace:** 2026-08-14
**Kontraktní ID:** C25 (dle `docs/13-delivery/r4-vertical-slice-plan.md §7.1`); rozhodnutí providera je **ADR-012**
**Navazuje na:** `docs/05-architecture/initial-architecture-decisions.md` (ADR-012), `docs/09-ai/ai-architecture.md`, `docs/10-integrations/integration-architecture.md`, `docs/11-security/security-architecture.md`, `docs/07-backend/r2-auth-api-contract.md` (rate limiting vzor), `docs/13-delivery/r4-vertical-slice-plan.md`
**Navazující dokumenty:** implementace R4-01, C26 (prompt/audit), C28 (structured output), C31 (safety)
**Vlastněné pojmy nebo kontrakty:** server-side AI gateway hranice, `AiModelProvider` abstrakce, konfigurace providera a klíčů, fake provider pro testy a pravidla `AGW-001` až `AGW-015`

---

# 1. Purpose

Každé AI volání v produktu prochází **jedinou server-side hranicí** — AI gateway. Gateway izoluje provider (ADR-012: první provider Anthropic Claude, Messages API), drží klíče výhradně v runtime konfiguraci serveru a poskytuje deterministickou testovací cestu (fake provider). Klient nikdy nevolá provider přímo a nikdy nedrží klíče.

**Blocking pro `R4-01`** (spolu s C26).

# 2. Hranice a abstrakce

- **`AiModelProvider` port** (backend domain): vstup = verzovaný prompt + serializovaný kontext + požadované schéma (identifikátor, C28); výstup = typovaný výsledek — úspěch s raw strukturovaným textem odpovědi + identifikátor modelu, nebo typované selhání (`TIMEOUT`, `PROVIDER_ERROR`, `RATE_LIMITED_UPSTREAM`, `INVALID_RESPONSE`).
- **Implementace:** `AnthropicModelProvider` (aktivní jen s nakonfigurovaným klíčem) a `FakeModelProvider` (default bez klíče; deterministické fixtures) — volba přes konfiguraci `aitrainer.ai.provider`.
- **Gateway služba** (application): resolvuje prompt verzi (C26), volá provider s timeoutem, audituje (C26), vrací typovaný výsledek. Žádná doménová logika, žádné zápisy do domény.
- Parsování/validace strukturovaného výstupu vlastní **C28** — gateway vrací odpověď neinterpretovanou.

# 3. Konfigurace a klíče

`aitrainer.ai.provider` (`fake` default | `anthropic`), `aitrainer.ai.anthropic.api-key` (jen runtime env/secret), `aitrainer.ai.anthropic.model` (konfigurační hodnota), `aitrainer.ai.timeout` (default PT30S). Klíč se nikdy neloguje, neauditue, neobjevuje v chybových odpovědích ani v repozitáři.

# 4. Invarianty (`AGW`)

- **AGW-001 — Jediná hranice.** Všechna AI volání jdou přes gateway; klient komunikuje jen s vlastním backendem (R2 session).
- **AGW-002 — Provider za portem.** Volající kód závisí výhradně na `AiModelProvider`; výměna providera nemění volající kód (ADR-012).
- **AGW-003 — Klíče jen server-side runtime.** Nikdy na klientu, v repu, v logu, v auditech, v odpovědích.
- **AGW-004 — Fake provider default.** Bez konfigurace klíče běží fake; testy a CI výhradně fake/fixtures; živý provider není podmínkou žádného gate.
- **AGW-005 — Typovaná selhání.** Timeout/chyba providera je typovaný výsledek, nikdy raw výjimka do HTTP a nikdy předstíraný úspěch.
- **AGW-006 — Timeout povinný.** Každé volání má konfigurovaný timeout; žádný automatický retry loop v P0.
- **AGW-007 — Bez interpretace.** Gateway nevaliduje ani neinterpretuje obsah odpovědi (C28) a nezapisuje do domény (R4P-001).
- **AGW-008 — Auth povinná.** Gateway operace vyžadují platnou access session (R2); anonymní volání neexistuje.
- **AGW-009 — Rate limiting.** AI operace mají rate limiting baseline (R2 vzor) — vynucení na endpointu, který gateway používá (R4-03/C31).
- **AGW-010 — Verzování v odpovědi.** Výsledek nese prompt verzi, schema verzi a model identifikátor (C26).
- **AGW-011 — Audit bez obsahu.** Auditují se události, ne prompty/kontexty/odpovědi (C26).
- **AGW-012 — Konfigurace validovaná při startu.** `anthropic` bez klíče = start selže srozumitelně; `fake` nikdy nevyžaduje síť.
- **AGW-013 — Žádné streamování v P0.** Jednorázová odpověď; streaming je budoucí rozhodnutí.
- **AGW-014 — Kontext je payload.** Gateway zachází s kontextem jako s neprůhlednými daty — data nejsou instrukce (postoj k prompt injection rozvine C31).
- **AGW-015 — Evidence.** Testy: fake provider determinismus, typovaná selhání, konfigurace, žádný klíč v repo/logu; flaky ≠ zelený důkaz.

# 5. Ready condition

C25 je Done vytvořením ADR-012 + tohoto dokumentu a zápisem do doc mapy. Spolu s C26 činí **`R4-01` `READY`**.
