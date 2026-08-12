-- R2-02: serverová account/auth/session baseline podle C6 (r2-server-data-model.md §7).
-- Append-only rozšíření V1 (SDM-002); schema vzniká výhradně migracemi (SDM-001).
-- Žádné plaintext secrets — credential a token sloupce nesou pouze hash (SDM-010, DAR-010).
-- Server-only entity (identity, account, auth_session, audit) mají server-assigned ID (C6 §5).

-- C6 §7.2: interní identita, na kterou míří jeden nebo více způsobů přihlášení.
CREATE TABLE identity (
    id uuid PRIMARY KEY,
    status text NOT NULL CHECK (status IN (
        'ACTIVE', 'UNVERIFIED', 'SUSPENDED', 'LOCKED',
        'DELETION_PENDING', 'DELETED', 'MERGED', 'COMPROMISED'
    )),
    created_at timestamptz NOT NULL,
    last_verified_at timestamptz
);

-- C6 §7.1: produktový účet — vlastník dat; R2 baseline typy ANONYMOUS/STANDARD.
CREATE TABLE account (
    id uuid PRIMARY KEY,
    identity_id uuid NOT NULL UNIQUE REFERENCES identity (id),
    status text NOT NULL CHECK (status IN (
        'ACTIVE', 'ONBOARDING', 'LIMITED', 'SUSPENDED',
        'LOCKED', 'DELETION_PENDING', 'DELETED'
    )),
    account_type text NOT NULL CHECK (account_type IN ('ANONYMOUS', 'STANDARD')),
    region text,
    language text,
    timezone text,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    row_version bigint NOT NULL DEFAULT 1
);

-- C6 §7.3: konkrétní způsob přihlášení; UNIQUE(provider, provider_subject) nese INV-011 (SDM-009).
CREATE TABLE authentication_identity (
    id uuid PRIMARY KEY,
    identity_id uuid NOT NULL REFERENCES identity (id),
    provider text NOT NULL CHECK (provider IN (
        'EMAIL_PASSWORD', 'MAGIC_LINK', 'GOOGLE', 'APPLE', 'MICROSOFT',
        'PASSKEY', 'PHONE', 'ANONYMOUS', 'ENTERPRISE', 'CUSTOM'
    )),
    provider_subject text NOT NULL,
    credential_hash text,
    verified boolean NOT NULL DEFAULT false,
    is_primary boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL,
    last_used_at timestamptz,
    UNIQUE (provider, provider_subject)
);

-- C6 §7.4: serverem vydávaná a revokovatelná aplikační session (ADR-011 varianta A).
-- device_ref je nullable — device tabulka a vazba vzniknou v R2-04 (C9).
CREATE TABLE auth_session (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    status text NOT NULL CHECK (status IN ('ACTIVE', 'REVOKED')),
    device_ref text,
    access_token_hash text NOT NULL UNIQUE,
    access_expires_at timestamptz NOT NULL,
    refresh_expires_at timestamptz NOT NULL,
    issued_at timestamptz NOT NULL,
    revoked_at timestamptz,
    row_version bigint NOT NULL DEFAULT 1,
    CHECK (status = 'ACTIVE' OR revoked_at IS NOT NULL)
);

-- Refresh metadata s rotací a detekcí replay (C6 §7.4, security §7.2):
-- právě jedna ACTIVE refresh credential na session; použití ROTATED/REVOKED
-- hashe je detekovatelný replay.
CREATE TABLE auth_refresh_credential (
    id uuid PRIMARY KEY,
    session_id uuid NOT NULL REFERENCES auth_session (id),
    token_hash text NOT NULL UNIQUE,
    status text NOT NULL CHECK (status IN ('ACTIVE', 'ROTATED', 'REVOKED')),
    created_at timestamptz NOT NULL,
    rotated_at timestamptz
);

CREATE UNIQUE INDEX auth_refresh_credential_one_active
    ON auth_refresh_credential (session_id)
    WHERE status = 'ACTIVE';

-- C6 §7.5: úložiště idempotency záznamů pro account-creating operace (AAC-005).
-- Detailní replay sémantiku vlastní C11; baseline drží klíč, otisk requestu a výsledek.
CREATE TABLE idempotency_record (
    idempotency_key text PRIMARY KEY,
    operation text NOT NULL,
    request_hash text NOT NULL,
    account_id uuid REFERENCES account (id),
    created_at timestamptz NOT NULL
);

-- C14 §5: append-oriented audit záznam — principal/action/target/outcome/čas/
-- correlation/policyDecision, bez citlivého payloadu (AEC-002, AEC-003).
CREATE TABLE audit_event (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    occurred_at timestamptz NOT NULL,
    action text NOT NULL,
    outcome text NOT NULL CHECK (outcome IN ('SUCCESS', 'FAILURE', 'REJECTED', 'CONFLICT')),
    principal_account_id uuid REFERENCES account (id),
    principal_session_id uuid REFERENCES auth_session (id),
    target text,
    correlation_id text,
    policy_decision text
);

CREATE INDEX auth_session_account_idx ON auth_session (account_id);
CREATE INDEX auth_refresh_credential_session_idx ON auth_refresh_credential (session_id);
CREATE INDEX audit_event_occurred_at_idx ON audit_event (occurred_at);
