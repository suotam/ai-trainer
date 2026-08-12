-- R2-05: synced entity (C6 §8.4) + rozšíření idempotency_record (C6 §8.5).
-- Append-only rozšíření V3 (SDM-002/015). Každá synced entita nese
-- client-generated ID (server nepřečíslovává, SDM-005), account ownership
-- (SDM-008), monotónní server_version (C10 §10) a kanonický JSONB payload
-- bez serverové reinterpretace (C6 §8.4 P0 rozhodnutí). Bez tombstone —
-- delete je mimo R2-05 P0.

CREATE TABLE synced_workout_instance (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_workout_session (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    workout_instance_id uuid NOT NULL REFERENCES synced_workout_instance (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_step_performance (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    workout_session_id uuid NOT NULL REFERENCES synced_workout_session (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_set_performance (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    step_performance_id uuid NOT NULL REFERENCES synced_step_performance (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_workout_feedback (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    workout_session_id uuid NOT NULL REFERENCES synced_workout_session (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE TABLE synced_activity_summary (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    workout_session_id uuid NOT NULL REFERENCES synced_workout_session (id),
    server_version bigint NOT NULL DEFAULT 1,
    source_installation_id uuid,
    payload jsonb NOT NULL,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL
);

CREATE INDEX synced_workout_instance_account_idx ON synced_workout_instance (account_id);
CREATE INDEX synced_workout_session_account_idx ON synced_workout_session (account_id);
CREATE INDEX synced_step_performance_account_idx ON synced_step_performance (account_id);
CREATE INDEX synced_set_performance_account_idx ON synced_set_performance (account_id);
CREATE INDEX synced_workout_feedback_account_idx ON synced_workout_feedback (account_id);
CREATE INDEX synced_activity_summary_account_idx ON synced_activity_summary (account_id);

-- C6 §8.5: rozšíření idempotency_record pro obecný replay protokol (C11 §5).
-- Scope replay rozhodnutí je per účet (IDC-003): globální baseline PK na
-- klíči se v nové migraci nahrazuje složeným klíčem (account, key) —
-- append-only lifecycle je zachován (V2 se nepřepisuje, SDM-002); všechna
-- existující data account_id mají (registrace jej vždy ukládá), takže
-- zpřísnění na NOT NULL je bez backfillu bezpečné (SDM-011).
ALTER TABLE idempotency_record
    ADD COLUMN final_status text,
    ADD COLUMN result_reference text,
    ADD COLUMN expires_at timestamptz;

ALTER TABLE idempotency_record
    ALTER COLUMN account_id SET NOT NULL;

ALTER TABLE idempotency_record
    DROP CONSTRAINT idempotency_record_pkey;

ALTER TABLE idempotency_record
    ADD PRIMARY KEY (account_id, idempotency_key);
