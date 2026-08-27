-- What happened, so that the questions the product asks can be answered.
--
-- One table, because the whole schema is eighteen event names and nobody is
-- going to join this to anything. A third-party analytics tool would cost money
-- above its free tier and would put this data somewhere we cannot query with
-- the rest.
CREATE TABLE events (
    id          bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id   uuid        NOT NULL,
    name        varchar(48) NOT NULL,
    -- Free-form, because half the events carry a number and half carry nothing,
    -- and a column per event would be a migration per question.
    properties  jsonb       NOT NULL DEFAULT '{}',
    -- When it happened on the phone, which is not when it arrived: events are
    -- queued offline and sent in batches.
    occurred_at timestamptz NOT NULL,
    received_at timestamptz NOT NULL DEFAULT now()
);

-- Every question starts with "how many devices did X" over a period.
CREATE INDEX events_name_occurred_at ON events (name, occurred_at);
CREATE INDEX events_device_id ON events (device_id);

-- The same event sent twice — a retry after a timeout that actually landed —
-- would inflate exactly the numbers this exists to measure.
ALTER TABLE events
    ADD COLUMN client_id uuid NOT NULL,
    ADD CONSTRAINT events_client_id_unique UNIQUE (client_id);
