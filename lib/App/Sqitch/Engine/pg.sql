BEGIN;

SET client_min_messages = warning;
CREATE SCHEMA :"sqitch_schema";

COMMENT ON SCHEMA :"sqitch_schema" IS 'Sqitch database deployment metadata v1.0.';

CREATE TABLE :"sqitch_schema".tags (
    tag_id     SERIAL      PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    applied_by TEXT        NOT NULL DEFAULT current_user
);

COMMENT ON TABLE :"sqitch_schema".tags
IS 'Lists the tags currently applied to the database.';
COMMENT ON COLUMN :"sqitch_schema".tags.applied_at IS 'Date the tag was applied to the database.';
COMMENT ON COLUMN :"sqitch_schema".tags.applied_by IS 'Name of the role that applied the tag.';

CREATE TABLE :"sqitch_schema".tag_names (
    tag_name TEXT    PRIMARY KEY,
    tag_id   INTEGER NOT NULL REFERENCES :"sqitch_schema".tags(tag_id)
                              ON DELETE CASCADE
);

COMMENT ON TABLE :"sqitch_schema".tag_names
IS 'Lists the names of tags currently applied to the database.';
COMMENT ON COLUMN :"sqitch_schema".tag_names.tag_name IS 'Unique tag name.';
COMMENT ON COLUMN :"sqitch_schema".tag_names.tag_id   IS 'Tag ID.';

CREATE TABLE :"sqitch_schema".steps (
    step        TEXT        NOT NULL,
    tag_id      INTEGER     NOT NULL REFERENCES :"sqitch_schema".tags(tag_id),
    deployed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deployed_by TEXT        NOT NULL DEFAULT current_user,
    requires    TEXT[]      NOT NULL DEFAULT '{}',
    conflicts   TEXT[]      NOT NULL DEFAULT '{}',
    PRIMARY KEY (step, tag_id)
);

COMMENT ON TABLE :"sqitch_schema".steps
IS 'Lists the steps currently deployed to the database.';
COMMENT ON COLUMN :"sqitch_schema".steps.step        IS 'Name of a deployed step.';
COMMENT ON COLUMN :"sqitch_schema".steps.tag_id      IS 'ID of the associated tag.';
COMMENT ON COLUMN :"sqitch_schema".steps.requires    IS 'Array of the names of prerequisite steps.';
COMMENT ON COLUMN :"sqitch_schema".steps.conflicts   IS 'Array of the names of conflicting steps.';
COMMENT ON COLUMN :"sqitch_schema".steps.deployed_at IS 'Date the step was deployed.';
COMMENT ON COLUMN :"sqitch_schema".steps.deployed_by IS 'Name of the role that deployed the step';

CREATE TABLE :"sqitch_schema".history (
    action    TEXT        NOT NULL CHECK (action IN ('deploy', 'revert')),
    step      TEXT        NOT NULL,
    tags      TEXT[]      NOT NULL,
    requires  TEXT[]      NOT NULL,
    conflicts TEXT[]      NOT NULL,
    taken_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    taken_by  TEXT        NOT NULL DEFAULT current_user,
    PRIMARY KEY (action, step, tags, taken_at)
);

COMMENT ON TABLE :"sqitch_schema".history
IS 'History of step deployments and reversions.';
COMMENT ON COLUMN :"sqitch_schema".history.step      IS 'Name of a deployed step.';
COMMENT ON COLUMN :"sqitch_schema".history.tags      IS 'Array of tags associated with the step.';
COMMENT ON COLUMN :"sqitch_schema".history.requires  IS 'Array of the names of prerequisite steps.';
COMMENT ON COLUMN :"sqitch_schema".history.conflicts IS 'Array of the names of conflicting steps.';
COMMENT ON COLUMN :"sqitch_schema".history.taken_at  IS 'Date the step was deployed.';
COMMENT ON COLUMN :"sqitch_schema".history.taken_by  IS 'Name of the role that deployed the step';

COMMIT;
