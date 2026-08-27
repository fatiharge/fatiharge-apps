-- The three things a day asks for, and what was done about them.
--
-- In tables rather than on the classpath like the rest of the content, for one
-- reason: which task a day gets is a decision someone will want to change
-- without a deploy, and completion is per-device state that has to live beside
-- it anyway.
CREATE TABLE tasks (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    day          integer     NOT NULL,
    archetype_id varchar(48) NOT NULL,
    -- 1, 2, 3 within the day. Which one is first is an editorial decision, so
    -- it is a column rather than the insert order.
    ordinal      integer     NOT NULL,
    title        text        NOT NULL,
    detail       text        NOT NULL,
    -- False takes a task out of rotation without deleting the completions that
    -- point at it.
    active       boolean     NOT NULL DEFAULT true,
    -- True while the text is the generated stand-in rather than something
    -- somebody wrote. Findable, so the writing job is a query.
    placeholder  boolean     NOT NULL DEFAULT false,

    CONSTRAINT tasks_day_sane CHECK (day BETWEEN 1 AND 14),
    CONSTRAINT tasks_ordinal_sane CHECK (ordinal BETWEEN 1 AND 3),
    CONSTRAINT tasks_slot_unique UNIQUE (day, archetype_id, ordinal)
);

CREATE TABLE task_completions (
    device_id    uuid        NOT NULL,
    task_id      bigint      NOT NULL REFERENCES tasks (id),
    -- The local day it was ticked on, so the period report counts days rather
    -- than timestamps in whatever zone the server happens to be in.
    day          date        NOT NULL,
    completed_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (device_id, task_id)
);

CREATE INDEX task_completions_device_day ON task_completions (device_id, day);
