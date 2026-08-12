-- R2-04: athlete_profile + device_installation + vazba session→zařízení
-- podle C6 §8.1–§8.3 (append-only rozšíření V2, SDM-002/015).
-- Profil i instalace nesou client-generated ID, které server zachovává
-- (SDM-005); ownership nese account_id (SDM-008). Žádné fingerprinting
-- sloupce (C9 §8, security §9).

-- C6 §8.1: R2 baseline AthleteProfile — právě jeden SELF profil na účet.
CREATE TABLE athlete_profile (
    id uuid PRIMARY KEY,
    account_id uuid NOT NULL REFERENCES account (id),
    profile_type text NOT NULL CHECK (profile_type IN ('SELF')),
    status text NOT NULL CHECK (status IN ('ACTIVE')),
    display_name text NOT NULL CHECK (length(display_name) BETWEEN 1 AND 100),
    primary_sport text,
    experience_level text,
    units text,
    timezone text,
    locale text,
    created_at timestamptz NOT NULL,
    updated_at timestamptz NOT NULL,
    row_version bigint NOT NULL DEFAULT 1
);

CREATE UNIQUE INDEX athlete_profile_one_self
    ON athlete_profile (account_id)
    WHERE profile_type = 'SELF';

-- C6 §8.2: registrovaná instalace aplikace (C9). Přirozený klíč je pár
-- (account, installation) — jeden fyzický přístroj s více účty vede na
-- oddělené registrace (C9 §5).
CREATE TABLE device_installation (
    account_id uuid NOT NULL REFERENCES account (id),
    installation_id uuid NOT NULL,
    platform text NOT NULL CHECK (platform IN ('IOS', 'ANDROID')),
    app_version text NOT NULL,
    local_schema_version text NOT NULL,
    status text NOT NULL CHECK (status IN ('ACTIVE', 'REVOKED')),
    created_at timestamptz NOT NULL,
    last_seen_at timestamptz NOT NULL,
    last_sync_at timestamptz,
    row_version bigint NOT NULL DEFAULT 1,
    PRIMARY KEY (account_id, installation_id)
);

-- C6 §8.3: DeviceSession vazba — aditivní nullable FK; session vydané před
-- registrací zařízení zůstávají validní. Baseline sloupec device_ref (V2)
-- se nepřepisuje (append-only).
ALTER TABLE auth_session
    ADD COLUMN device_installation_id uuid;

ALTER TABLE auth_session
    ADD CONSTRAINT auth_session_device_installation_fk
    FOREIGN KEY (account_id, device_installation_id)
    REFERENCES device_installation (account_id, installation_id);
