BEGIN;


CREATE TABLE &registry.releases (
    version           FLOAT        PRIMARY KEY,
    installed_at      TIMESTAMP_TZ NOT NULL DEFAULT current_timestamp,
    installer_name    TEXT         NOT NULL,
    installer_email   TEXT         NOT NULL
);

COMMENT ON TABLE  &registry.releases                 IS 'Sqitch registry releases.';
COMMENT ON COLUMN &registry.releases.version         IS 'Version of the Sqitch registry.';
COMMENT ON COLUMN &registry.releases.installed_at    IS 'Date the registry release was installed.';
COMMENT ON COLUMN &registry.releases.installer_name  IS 'Name of the user who installed the registry release.';
COMMENT ON COLUMN &registry.releases.installer_email IS 'Email address of the user who installed the registry release.';

-- Add the script_hash column to the changes table. Copy change_id for now.
ALTER TABLE &registry.changes ADD script_hash TEXT NULL;
UPDATE &registry.changes SET script_hash = change_id;
COMMENT ON COLUMN &registry.changes.script_hash IS 'Deploy script SHA-1 hash.';
ALTER TABLE &registry.changes ADD UNIQUE(script_hash);

COMMENT ON SCHEMA &registry IS 'Sqitch database deployment metadata v1.1.';

COMMIT;
