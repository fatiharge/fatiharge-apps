-- Every word the product says now lives in the database.
--
-- Half of it already did — tasks and report pieces — and the other half was
-- read from the classpath, so correcting a motto meant cutting a release
-- while correcting a task did not. Two content regimes in one product, and a
-- push script that silently overwrote whichever copy disagreed.
--
-- The rule that follows: if somebody writes it and might rewrite it, it is a
-- row. The exception is the app's own chrome — button labels, error lines —
-- which belongs to the widget that shows it.
--
-- `locale` is on everything from the start. A second language is a column now
-- and a migration of every table later.

CREATE TABLE archetypes (
    id       varchar(48) NOT NULL,
    locale   varchar(8)  NOT NULL DEFAULT 'tr',
    name     text        NOT NULL,
    summary  text        NOT NULL,
    motto    text        NOT NULL,
    -- Presentation order, not identity: the gallery reads it, nothing else.
    ordinal  integer     NOT NULL,

    PRIMARY KEY (id, locale)
);

-- Where an archetype sits in the five-dimensional space a profile lands in.
--
-- Data rather than a file so that adding the nineteenth archetype is a write,
-- not a release. Refused on write unless the archetype still wins on its own
-- point — a rule that used to be a test and is now a gate, because a table
-- anyone can edit needs the check on the way in.
CREATE TABLE archetype_rules (
    archetype_id      varchar(48) PRIMARY KEY,
    -- The dimensions that define it; the rest count at background weight.
    defining          text[]      NOT NULL,
    openness          real        NOT NULL,
    conscientiousness real        NOT NULL,
    extraversion      real        NOT NULL,
    agreeableness     real        NOT NULL,
    neuroticism       real        NOT NULL,

    CONSTRAINT archetype_rules_range CHECK (
        openness BETWEEN 0 AND 1 AND conscientiousness BETWEEN 0 AND 1
        AND extraversion BETWEEN 0 AND 1 AND agreeableness BETWEEN 0 AND 1
        AND neuroticism BETWEEN 0 AND 1)
);

-- The inventory, versioned.
--
-- A result is a profile computed from a particular set of questions. Editing a
-- question without saying so would quietly make old results incomparable to
-- new ones, so an edit is a new version and every result records the version
-- it was measured with.
CREATE TABLE item_sets (
    version    integer     PRIMARY KEY,
    active     boolean     NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX item_sets_one_active ON item_sets (active) WHERE active;

CREATE TABLE items (
    id        varchar(16) NOT NULL,
    version   integer     NOT NULL REFERENCES item_sets (version),
    locale    varchar(8)  NOT NULL DEFAULT 'tr',
    dimension varchar(24) NOT NULL,
    -- Half the pool is reverse keyed, so agreeing with everything does not
    -- read as a person who agrees with everything.
    reverse   boolean     NOT NULL DEFAULT false,
    text      text        NOT NULL,
    ordinal   integer     NOT NULL,

    PRIMARY KEY (id, version, locale)
);

ALTER TABLE results ADD COLUMN item_version integer;

CREATE TABLE mottos (
    id           varchar(24) NOT NULL,
    locale       varchar(8)  NOT NULL DEFAULT 'tr',
    archetype_id varchar(48) NOT NULL,
    motto        text        NOT NULL,
    -- What it means and what it costs; shown on the motto's own screen.
    detail       text        NOT NULL,
    -- The line a notification carries.
    reminder     text        NOT NULL,
    ordinal      integer     NOT NULL,

    PRIMARY KEY (id, locale)
);

CREATE INDEX mottos_by_archetype ON mottos (archetype_id, locale, ordinal);

CREATE TABLE day_skeletons (
    day    integer    NOT NULL,
    locale varchar(8) NOT NULL DEFAULT 'tr',
    title  text       NOT NULL,
    body   text       NOT NULL,
    action text       NOT NULL,

    PRIMARY KEY (day, locale),
    CONSTRAINT day_skeletons_day_sane CHECK (day >= 1)
);

-- One per day per archetype: the only personal sentence in a day's text.
CREATE TABLE fragments (
    archetype_id varchar(48) NOT NULL,
    ordinal      integer     NOT NULL,
    locale       varchar(8)  NOT NULL DEFAULT 'tr',
    text         text        NOT NULL,

    PRIMARY KEY (archetype_id, ordinal, locale)
);

CREATE TABLE connectors (
    id     varchar(16) NOT NULL,
    locale varchar(8)  NOT NULL DEFAULT 'tr',
    text   text        NOT NULL,

    PRIMARY KEY (id, locale)
);

-- Which dimension each report section reads from. In a table because a sixth
-- section should be a row, not a constant in Java.
CREATE TABLE report_sections (
    section   integer     NOT NULL,
    locale    varchar(8)  NOT NULL DEFAULT 'tr',
    dimension varchar(24) NOT NULL,

    PRIMARY KEY (section, locale)
);

-- Privacy, FAQ, method, deletion — everything the support screens read.
CREATE TABLE support_texts (
    kind    varchar(24) NOT NULL,
    key     varchar(48) NOT NULL,
    locale  varchar(8)  NOT NULL DEFAULT 'tr',
    heading text,
    body    text        NOT NULL,
    ordinal integer     NOT NULL,

    PRIMARY KEY (kind, key, locale)
);

-- Who changed which words, and when. The repository used to give this away
-- for free; a table does not, and losing it was the real cost of the move.
CREATE TABLE content_revisions (
    id          bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity      varchar(32) NOT NULL,
    entity_key  text        NOT NULL,
    locale      varchar(8)  NOT NULL DEFAULT 'tr',
    -- Null on the first write of a row.
    was         jsonb,
    now         jsonb       NOT NULL,
    written_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX content_revisions_entity ON content_revisions (entity, entity_key, written_at DESC);
