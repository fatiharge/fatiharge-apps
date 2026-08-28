-- What makes a report piece the same piece.
--
-- The seed could only insert what was missing, because there was nothing to
-- conflict on: half the columns are null on any given kind. Postgres 15 and up
-- can treat those nulls as equal, which is exactly the meaning wanted here —
-- two pieces with the same kind and the same empty slots are the same piece.
--
-- With this, writing a placeholder's real text into content/report.yaml
-- actually reaches the database on the next deploy.
ALTER TABLE report_pieces
    ADD CONSTRAINT report_pieces_identity
    UNIQUE NULLS NOT DISTINCT (kind, archetype_id, dimension, band, section);
