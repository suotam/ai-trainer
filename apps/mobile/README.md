# apps/mobile

Samostatná Flutter aplikace pro Android a iOS (ADR-001).

Vlastní své lokální Drift/SQLite schema a jeho migrace (RER-007).
Nesmí importovat backendové interní moduly ani sdílet interní doménové
třídy přes `packages/contracts` (RER-002, RER-005).

Flutter projekt vznikne ve slice `R0-02 – Mobile Bootstrap` podle
`docs/08-mobile/mobile-architecture.md` a `docs/13-delivery/repository-strategy.md` §4.
