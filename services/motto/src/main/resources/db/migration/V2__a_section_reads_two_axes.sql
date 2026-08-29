-- A section reads a pair of dimensions, not one.
--
-- The deep report promised that two people with the same archetype do not read
-- the same thing, and it was a third true: of the words a reader gets, only
-- the five band paragraphs moved with their profile. Everything else was the
-- archetype's, identical for everyone who landed on it.
--
-- One dimension per section is why. Somebody who finishes what they start and
-- somebody who finishes what they start while bracing for what could go wrong
-- do not decide the same way, and the report handed them the same paragraph.
--
-- So a section names a second dimension, and the paragraph it reads is chosen
-- by both bands. Three texts per section become nine, and the part of the
-- report that is actually about the reader stops being a third of it.
ALTER TABLE report_sections
    ADD COLUMN dimension_2 varchar(24);

-- Which pair a `dimension` piece answers for. Null on the pieces written
-- before this, which keep answering when a section names no second axis.
ALTER TABLE report_pieces
    ADD COLUMN dimension_2 varchar(24),
    ADD COLUMN band_2      varchar(8);

ALTER TABLE report_pieces
    DROP CONSTRAINT report_pieces_identity;

ALTER TABLE report_pieces
    ADD CONSTRAINT report_pieces_identity
    UNIQUE NULLS NOT DISTINCT
        (kind, archetype_id, dimension, band, dimension_2, band_2, section);

ALTER TABLE report_pieces
    ADD CONSTRAINT report_pieces_band_2_sane
        CHECK (band_2 IS NULL OR band_2 IN ('low', 'mid', 'high')),
    -- A second band without a second dimension is a row nothing can look up.
    ADD CONSTRAINT report_pieces_pair_complete
        CHECK ((dimension_2 IS NULL) = (band_2 IS NULL));

DROP INDEX report_pieces_lookup;

CREATE INDEX report_pieces_lookup
    ON report_pieces (kind, archetype_id, dimension, band, dimension_2, band_2, section);
