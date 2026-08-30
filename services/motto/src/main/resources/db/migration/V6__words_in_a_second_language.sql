-- Two of the tables that hold words did not say which language they were in.
--
-- Every other content table has carried `locale` since the first migration,
-- for exactly this day. These two were written when there was one language and
-- no reason to imagine a second, and they are the only thing standing between
-- the app and an English reader.
--
-- Existing rows are Turkish, which is what they have always been. The English
-- ones arrive through the admin API rather than through here: a migration that
-- carries sentences is a migration nobody can correct without a deploy, and
-- the words are the part most likely to need correcting.

ALTER TABLE tasks ADD COLUMN locale varchar(8) NOT NULL DEFAULT 'tr';
ALTER TABLE tasks DROP CONSTRAINT tasks_slot_unique;
ALTER TABLE tasks ADD CONSTRAINT tasks_slot_unique
    UNIQUE (day, archetype_id, ordinal, locale);

ALTER TABLE report_pieces ADD COLUMN locale varchar(8) NOT NULL DEFAULT 'tr';
