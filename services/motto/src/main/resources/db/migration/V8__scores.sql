-- What the game came to.
--
-- One row per play rather than a best-score column: the leaderboard wants the
-- best in a week, and a column that only remembers the best forgets which week
-- it happened in.
CREATE TABLE scores (
    id        bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id uuid        NOT NULL,
    points    integer     NOT NULL,
    played_at timestamptz NOT NULL DEFAULT now(),
    -- The Monday of the week it belongs to, so the leaderboard is a lookup
    -- rather than a date range computed in three places.
    week      date        NOT NULL,

    CONSTRAINT scores_points_sane CHECK (points >= 0)
);

CREATE INDEX scores_week_points ON scores (week, points DESC);
CREATE INDEX scores_device ON scores (device_id);

-- Which weeks have already paid out, so a rerun of the job does not hand the
-- same ten people a second report each.
CREATE TABLE score_rewards (
    week        date        PRIMARY KEY,
    awarded     integer     NOT NULL,
    awarded_at  timestamptz NOT NULL DEFAULT now()
);
