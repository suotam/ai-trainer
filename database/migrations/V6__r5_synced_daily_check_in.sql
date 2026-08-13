-- R5-01: synced denní check-in (C33 §4). Append-only rozšíření V5
-- (SDM-002/015). Kostra přesně dle C6 §8.4 bez parent sloupce — payload
-- je neprůhledný JSONB bez lokální poznámky (DCI-006). Client-generated
-- ID zachováno (SDM-005), monotónní server_version (C10 §10). Bez
-- tombstone — DELETE je mimo P0 (SXC-011).

CREATE TABLE synced_daily_check_in (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE INDEX synced_daily_check_in_account_idx ON synced_daily_check_in (account_id);
