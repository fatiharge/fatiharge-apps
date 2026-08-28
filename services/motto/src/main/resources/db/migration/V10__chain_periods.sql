-- The chain gets a second act.
--
-- Fourteen days was always the whole product — the content cycle, the cooldown
-- and the motto pool are all fourteen and four — but nothing ever ended, and
-- day fifteen quietly became day one again. A period is what ends: a run of
-- fourteen marked days under one motto.
--
-- A column rather than a second table, and the old days keep their number
-- rather than being deleted: the report for a finished period has to stay
-- readable after the next one starts.
ALTER TABLE chains
    ADD COLUMN period smallint NOT NULL DEFAULT 1,
    -- Which of the archetype's four mottos this period is under. Null means
    -- the first, which is what every chain written before this migration was.
    ADD COLUMN motto_id varchar(24);

ALTER TABLE chain_days
    ADD COLUMN period smallint NOT NULL DEFAULT 1;

-- The report and the day count are both "this period, this device".
CREATE INDEX chain_days_period ON chain_days (device_id, period);
