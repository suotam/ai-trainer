-- R6-04: tombstone příznak pro availability pravidla (C44 §2, DTS-001).
-- Aditivní rozšíření (SDM-002/015): smazání je evidovaný fakt s navýšenou
-- verzí, řádek se nikdy fyzicky nemaže (audit stopa nedotčena). P0 scope
-- je výhradně AVAILABILITY_RULE (SXC-011); rozšíření jen kontraktem.

ALTER TABLE synced_availability_rule
    ADD COLUMN deleted boolean NOT NULL DEFAULT false;
