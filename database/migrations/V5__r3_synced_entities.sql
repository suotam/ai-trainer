-- R3-07: synced R3 entity (C24 §3). Append-only rozšíření V4 (SDM-002/015).
-- Osm tabulek přesně dle C6 §8.4 kostry bez parent sloupce — R3 entity
-- nemají serverové parenty; device-local reference jsou součást
-- neprůhledného JSONB payloadu. Client-generated ID zachováno (SDM-005),
-- monotónní server_version (C10 §10). Bez tombstone — DELETE je mimo P0
-- (SXC-011).

CREATE TABLE synced_user_sport (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_goal (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_availability_rule (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_equipment_item (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_constraint (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_training_plan (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_calendar_change (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_activity (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);
