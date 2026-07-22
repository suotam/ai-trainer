# AI Trainer

Monorepo pro AI Trainer – mobilní tréninkovou aplikaci (Flutter) s backendem (Kotlin/Spring Boot).

Zdrojem pravdy pro strukturu repozitáře je `docs/13-delivery/repository-strategy.md`.
Aktuální stav dokumentace a kanonický další krok vlastní `docs/DOCUMENTATION_STATUS.md`.

## Struktura repozitáře

```text
ai-trainer/
├── apps/
│   ├── mobile/      # Flutter aplikace (Android + iOS), vznikne v R0-02
│   └── backend/     # Kotlin/Spring Boot modulární monolit, vznikne v R0-03
├── packages/
│   └── contracts/   # explicitní mezisystémové kontrakty (OpenAPI), vznikne v R0-04
├── tooling/
│   └── scripts/     # opakovatelné repository úlohy (smoke check)
└── docs/            # produktová, doménová a technická dokumentace
```

Adresáře `database/` (serverové migrace, seeds, fixtures) a `.github/` (CI workflows)
vzniknou spolu se slices `R0-05` a `R0-06`, které je skutečně potřebují.

## Lokální příkazy

Repository smoke check (ověří kanonickou strukturu a absenci build artefaktů
a zjevných secrets ve verzovaných souborech):

```bash
./tooling/scripts/repo-smoke-check.sh
```

Build, test a spouštěcí příkazy pro mobile a backend budou doplněny spolu
s jejich bootstrapem (`R0-02`, `R0-03`).

## Pravidla práce

- Implementace postupuje po vertical slices podle `docs/13-delivery/r0-r1-vertical-slice-plan.md`.
- Pracovní protokol coding agenta určuje `docs/15-coding-agent/coding-agent-guide.md`.
- Ready/Done gates vlastní `docs/13-delivery/definition-of-ready-and-done.md`.
- Secrets, credentials, build artefakty ani lokální data se necommitují.
