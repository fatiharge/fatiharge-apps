-- What people tell us, kept first-party.
--
-- With no accounts these screens are the only channel there is: a complaint
-- with nowhere to go goes to the store review instead, and a one-star review
-- cannot be replied to with a fix.
--
-- One table for every kind, including a rejected archetype. Which archetype
-- gets rejected, and how often, is the only correction signal the mapping
-- table has.
CREATE TABLE feedback (
    id         bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id  uuid        NOT NULL,
    kind       varchar(32) NOT NULL,
    message    text        NOT NULL,
    -- Optional on purpose: making it required collapses the submission rate,
    -- and most of what arrives here needs reading, not answering.
    email      varchar(320),
    -- App version, platform, OS version, current archetype. Free-form because
    -- what is worth attaching changes faster than a migration can follow.
    context    jsonb       NOT NULL DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX feedback_kind_created_at ON feedback (kind, created_at DESC);
