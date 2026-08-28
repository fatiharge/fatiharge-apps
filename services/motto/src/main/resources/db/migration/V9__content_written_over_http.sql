-- Content stops arriving as a migration.
--
-- Tasks and report pieces used to be seeded by two generated repeatable
-- migrations — hundreds of INSERT lines, committed. That made a typo in one
-- sentence a release, and put the words in the schema history rather than in
-- the tables where they belong. They are pushed over /admin/content now, by
-- scripts/push_content.py, from content/.
--
-- Two consequences worth stating: a database this migration reaches for the
-- first time has no content in it until somebody pushes, and the rows already
-- written by the old seeds are left exactly where they are.
--
-- The constraint is what the push upserts on. Postgres 15 and up can treat
-- nulls as equal, which is the meaning wanted here: half the columns are null
-- on any given kind, and two pieces with the same kind and the same empty
-- slots are the same piece.
ALTER TABLE report_pieces
    ADD CONSTRAINT report_pieces_identity
    UNIQUE NULLS NOT DISTINCT (kind, archetype_id, dimension, band, section);
