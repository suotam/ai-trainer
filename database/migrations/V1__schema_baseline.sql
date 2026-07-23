-- R0-05: minimální technický baseline serverového schématu.
-- Slouží pouze k ověření, že Flyway lifecycle funguje, že čistá databáze
-- vznikne výhradně migracemi (ADR-006, DAR-011) a že readiness umí
-- rozpoznat validní schema stav. Žádné produktové tabulky do R0 nepatří
-- (VSP §8 non-goals) — ty vzniknou vlastními migracemi v pozdějších slices.

CREATE TABLE schema_baseline (
    id integer PRIMARY KEY CHECK (id = 1),
    baseline_version text NOT NULL,
    applied_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO schema_baseline (id, baseline_version)
VALUES (1, 'r0');
