-- Every motto that was claimed, with the profile that produced it.
--
-- Until now `claim` scored the answers, returned an archetype and forgot both.
-- The report, the profile screen and the archive all read this table, and none
-- of them can be built from a number that was never written down.
--
-- The answers themselves are still not stored. They are only useful as the
-- vector they collapse into, and keeping twenty raw responses per person buys
-- nothing that this row does not already carry.
CREATE TABLE results (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id    uuid        NOT NULL,
    archetype_id varchar(48) NOT NULL,
    -- The five dimensions, 0..1. A column each rather than jsonb: the deep
    -- report picks its sections by comparing these, and a query that has to
    -- unpack json to do it will be the slow one.
    openness           real NOT NULL,
    conscientiousness  real NOT NULL,
    extraversion       real NOT NULL,
    agreeableness      real NOT NULL,
    neuroticism        real NOT NULL,
    claimed_at   timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT results_dimensions_sane CHECK (
        openness BETWEEN 0 AND 1 AND conscientiousness BETWEEN 0 AND 1
        AND extraversion BETWEEN 0 AND 1 AND agreeableness BETWEEN 0 AND 1
        AND neuroticism BETWEEN 0 AND 1
    )
);

-- The archive reads one device's results newest first, and nothing else reads
-- this table at all.
CREATE INDEX results_device_claimed_at ON results (device_id, claimed_at DESC);
