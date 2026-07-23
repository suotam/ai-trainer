# apps/backend

Samostatná Kotlin/Spring Boot aplikace jako modulární monolit (ADR-005).

Serverová databáze je PostgreSQL, schema vzniká výhradně Flyway migracemi
(ADR-006). Nesmí importovat mobilní kód ani sdílet interní doménové třídy
přes `packages/contracts` (RER-002, RER-005).

Spring Boot projekt vznikne ve slice `R0-03 – Backend Bootstrap` podle
`docs/07-backend/backend-architecture.md` a `docs/13-delivery/repository-strategy.md` §5.
