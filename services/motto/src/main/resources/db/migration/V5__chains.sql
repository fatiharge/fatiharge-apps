-- The chain, which used to live only on the phone.
--
-- Moved because a streak that exists in one place is a streak that a reinstall
-- ends, and because the period report has to count marked days against tasks
-- that are recorded here anyway.
CREATE TABLE chains (
    device_id       uuid        PRIMARY KEY,
    started_on      date        NOT NULL,
    -- The month's make-up, spent at most once per calendar month. Nullable
    -- because most chains never need it.
    freeze_used_on  date,
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- One row per marked day rather than an array, so a day can carry what it was
-- marked from later without rewriting every chain.
CREATE TABLE chain_days (
    device_id  uuid        NOT NULL REFERENCES chains (device_id) ON DELETE CASCADE,
    day        date        NOT NULL,
    -- True when the day was covered by the make-up rather than actually marked.
    -- The streak counts both; the report should be able to tell them apart.
    made_up    boolean     NOT NULL DEFAULT false,
    marked_at  timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (device_id, day)
);
