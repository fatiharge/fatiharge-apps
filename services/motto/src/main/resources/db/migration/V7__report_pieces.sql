-- The deep report, in pieces.
--
-- Written as parts rather than eight long texts so the report is assembled
-- against the reader's profile: two people with the same archetype do not read
-- the same thing, and that difference is the whole reason it is worth paying
-- for. Eight essays would be cheaper to write and would read as eight essays.
CREATE TABLE report_pieces (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- portrait · dimension · skeleton · fragment · comparison · limitation
    kind         varchar(24) NOT NULL,
    -- Set on portrait, fragment and comparison; null on the rest.
    archetype_id varchar(48),
    -- Set on dimension pieces: which of the five, and which band of it.
    dimension    varchar(24),
    band         varchar(8),
    -- Set on skeleton and fragment: which of the four sections.
    section      integer,
    text         text        NOT NULL,
    placeholder  boolean     NOT NULL DEFAULT false,

    CONSTRAINT report_pieces_band_sane
        CHECK (band IS NULL OR band IN ('low', 'mid', 'high')),
    CONSTRAINT report_pieces_section_sane
        CHECK (section IS NULL OR section BETWEEN 1 AND 4)
);

-- Assembly reads one kind at a time, filtered by archetype or dimension.
CREATE INDEX report_pieces_lookup
    ON report_pieces (kind, archetype_id, dimension, band, section);
