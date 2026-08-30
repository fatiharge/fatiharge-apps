-- What a refusal leads to, written down rather than coded.
--
-- The app already refuses things by name — `no_turns_left`, `day_too_old`. Up
-- to now what happened next was Dart: a sentence and a button, shipped in a
-- release. This is the same answer as a row, so the words and the way out of a
-- refusal are edited rather than deployed, and a code nobody has written for
-- yet is simply unknown rather than broken.
--
-- Held apart from the content bundle on purpose. Every app in this repo will
-- want this and none of them will want motto's mottos, so it leaves on its own
-- endpoint and can leave the repo the same way.

CREATE TABLE error_effects (
    code       varchar(64) NOT NULL,
    locale     varchar(8)  NOT NULL,

    -- The effect list, as the app reads it. Text rather than columns: it is a
    -- tree, nothing ever queries inside it, and its shape belongs to the
    -- client contract rather than to this table.
    definition text        NOT NULL,

    written_at timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (code, locale)
);
