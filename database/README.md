# database

Serverová databázová vrstva (PostgreSQL + Flyway, ADR-006). Vlastní ji
backend/data boundary — mobilní Drift/SQLite schema a jeho migrace žijí
v `apps/mobile` a mají oddělený lifecycle (RER-007).

## migrations/

Kanonický zdroj pravdy serverových Flyway migrací (repository-strategy §7):

- verzované `V<n>__<popis>.sql`, append-only (RER-006) — použitá migrace
  se nikdy nepřepisuje, oprava vzniká novou migrací,
- čistá databáze musí dosáhnout validního stavu výhradně spuštěním migrací,
- automatické ORM schema generation je zakázáno (ADR-006),
- každá změna schématu musí mít migration test (QTR-005).

Backend build (`apps/backend`) balí tento adresář do classpath
(`db/migration`), takže Flyway čte vždy tuto jedinou kopii — viz
`apps/backend/build.gradle.kts`.

Adresáře `seeds/` a `fixtures/` vzniknou až se slicem, který je skutečně
potřebuje (repository-strategy §3 — žádné adresáře do zásoby).
