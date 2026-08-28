-- The deep report grows a fifth section.
--
-- It had four, and the check written with them said so. Five dimensions were
-- always measured and only four were ever read back: agreeableness — the one
-- that decides whether somebody smooths things over or says the hard sentence
-- — had no section to appear in.
--
-- Widened rather than dropped: a section number outside the report's own range
-- is still a bug worth refusing at the table.
ALTER TABLE report_pieces
    DROP CONSTRAINT report_pieces_section_sane;

ALTER TABLE report_pieces
    ADD CONSTRAINT report_pieces_section_sane
    CHECK (section IS NULL OR section BETWEEN 1 AND 5);
