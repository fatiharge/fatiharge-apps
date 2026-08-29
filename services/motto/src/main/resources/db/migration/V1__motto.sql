-- The motto schema, whole.
--
-- Fourteen migrations were squashed into this one before the product shipped.
-- Two of them carried the words themselves — fifteen hundred lines of INSERT —
-- and those lines were already wrong the week they landed, because the words
-- are edited in the database and nothing edits a migration back. What is left
-- here is structure, and structure only.
--
-- Which means: a database built from this file comes up empty. Schema from
-- migrations, content from a dump. Anything else puts the words in two places
-- and lets one of them go stale in silence, which is the arrangement this
-- squash exists to end.
--
-- The reasoning below is carried over from the migrations it replaces. It is
-- the only place some of it is written down.


-- ---------------------------------------------------------------- the device

-- What a device is still allowed to do. This is the one table that survives a
-- data deletion: without it, deleting and starting over would hand out the free
-- uses again, and the scarcity the product is built on would be a suggestion.
CREATE TABLE entitlements (
    device_id     uuid        PRIMARY KEY,
    used_count    integer     NOT NULL DEFAULT 0,
    last_claim_at timestamptz,
    -- Everyone starts with one cooldown skip. Redeeming an invite adds another,
    -- which is why this counts rather than flags.
    skips_left    integer     NOT NULL DEFAULT 1,
    purchased_at  timestamptz,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT entitlements_used_count_sane CHECK (used_count >= 0),
    CONSTRAINT entitlements_skips_left_sane CHECK (skips_left >= 0)
);


-- ------------------------------------------------------------- the instrument

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

-- Every motto that was claimed, with the profile that produced it.
--
-- The answers themselves are not stored. They are only useful as the vector
-- they collapse into, and keeping twenty raw responses per person buys nothing
-- that this row does not already carry.
CREATE TABLE results (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id    uuid        NOT NULL,
    archetype_id varchar(48) NOT NULL,
    -- The five dimensions, 0..1. A column each rather than jsonb: the deep
    -- report picks its sections by comparing these, and a query that has to
    -- unpack json to do it will be the slow one.
    openness           real NOT NULL,
    conscientiousness  real NOT NULL,
    extraversion       real NOT NULL,
    agreeableness      real NOT NULL,
    neuroticism        real NOT NULL,
    -- Which generation of the inventory measured it. Null on results taken
    -- before the pool was versioned.
    item_version integer,
    claimed_at   timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT results_dimensions_sane CHECK (
        openness BETWEEN 0 AND 1 AND conscientiousness BETWEEN 0 AND 1
        AND extraversion BETWEEN 0 AND 1 AND agreeableness BETWEEN 0 AND 1
        AND neuroticism BETWEEN 0 AND 1)
);

-- The archive reads one device's results newest first, and nothing else reads
-- this table at all.
CREATE INDEX results_device_claimed_at ON results (device_id, claimed_at DESC);


-- ----------------------------------------------------------------- the words

-- Every sentence a user reads is a row from here down.
--
-- Half of it used to be rows and half was read from the classpath, so
-- correcting a task cost a request and correcting a motto cost a release. The
-- rule now: if somebody writes it and might rewrite it, it is a row. The
-- exception is the app's own chrome — button labels, error lines — which
-- belongs to the widget that shows it.
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
-- point and sits further from its neighbours than the inventory can measure —
-- rules that used to be tests over a file and are now gates over a table,
-- because a table anyone can edit needs the check on the way in.
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

-- The hand-written joins between a day's body and its fragment. The moment
-- these become a template, every day reads like the same sentence with a
-- different ending, and that is what a horoscope is.
CREATE TABLE connectors (
    id     varchar(16) NOT NULL,
    locale varchar(8)  NOT NULL DEFAULT 'tr',
    text   text        NOT NULL,

    PRIMARY KEY (id, locale)
);

-- The three things a day asks for.
--
-- Which task a day gets is a decision someone will want to change without a
-- deploy, and completion is per-device state that has to live beside it anyway.
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

-- Which dimension each report section reads from. In a table because a sixth
-- section should be a row, not a constant in Java.
CREATE TABLE report_sections (
    section   integer     NOT NULL,
    locale    varchar(8)  NOT NULL DEFAULT 'tr',
    dimension varchar(24) NOT NULL,

    PRIMARY KEY (section, locale)
);

-- The deep report, in pieces.
--
-- Written as parts rather than long texts so the report is assembled against
-- the reader's profile: two people with the same archetype do not read the
-- same thing, and that difference is the whole reason it is worth paying for.
-- Eighteen essays would be cheaper to write and would read as eighteen essays.
CREATE TABLE report_pieces (
    id           bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    -- overview · portrait · dimension · reading · skeleton · fragment ·
    -- strength · cost · comparison · limitation
    kind         varchar(24) NOT NULL,
    -- Set on the per-archetype kinds; null on the rest.
    archetype_id varchar(48),
    -- Set on dimension and reading pieces: which of the five, and which band.
    dimension    varchar(24),
    band         varchar(8),
    -- Set on skeleton and fragment: which of the sections.
    section      integer,
    text         text        NOT NULL,
    placeholder  boolean     NOT NULL DEFAULT false,

    CONSTRAINT report_pieces_band_sane
        CHECK (band IS NULL OR band IN ('low', 'mid', 'high')),
    -- A section number outside the report's own range is a bug worth refusing
    -- at the table. Widen it when the report grows another one.
    CONSTRAINT report_pieces_section_sane
        CHECK (section IS NULL OR section BETWEEN 1 AND 5),
    -- What a write upserts on. Postgres treats nulls as equal here, which is
    -- the meaning wanted: half the columns are null on any given kind, and two
    -- pieces with the same kind and the same empty slots are the same piece.
    CONSTRAINT report_pieces_identity
        UNIQUE NULLS NOT DISTINCT (kind, archetype_id, dimension, band, section)
);

-- Assembly reads one kind at a time, filtered by archetype or dimension.
CREATE INDEX report_pieces_lookup
    ON report_pieces (kind, archetype_id, dimension, band, section);

-- Privacy, FAQ, method, deletion — everything the support screens read. Served
-- rather than shipped, because the answer that matters most, where somebody's
-- data is, has to be correctable in one request.
CREATE TABLE support_texts (
    kind    varchar(24) NOT NULL,
    key     varchar(48) NOT NULL,
    locale  varchar(8)  NOT NULL DEFAULT 'tr',
    heading text,
    body    text        NOT NULL,
    ordinal integer     NOT NULL,

    PRIMARY KEY (kind, key, locale)
);

-- Who changed which words, and what they said before. The repository used to
-- give this away for free; a table does not, and losing it was the real cost
-- of moving the words out.
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

CREATE INDEX content_revisions_entity
    ON content_revisions (entity, entity_key, written_at DESC);


-- ----------------------------------------------------------------- the chain

-- The chain, which used to live only on the phone.
--
-- Moved because a streak that exists in one place is a streak that a reinstall
-- ends, and because the period report has to count marked days against tasks
-- that are recorded here anyway.
--
-- A period is what ends: a run of fourteen marked days under one motto. Days
-- from a finished period keep their number rather than being deleted, because
-- its report has to stay readable after the next one starts.
CREATE TABLE chains (
    device_id       uuid        PRIMARY KEY,
    started_on      date        NOT NULL,
    -- The month's make-up, spent at most once per calendar month. Nullable
    -- because most chains never need it.
    freeze_used_on  date,
    period          smallint    NOT NULL DEFAULT 1,
    -- Which of the archetype's mottos this period is under. Null means the
    -- first, which is what every chain written before periods existed was.
    motto_id        varchar(24),
    created_at      timestamptz NOT NULL DEFAULT now()
);

-- One row per marked day rather than an array, so a day can carry what it was
-- marked from later without rewriting every chain.
CREATE TABLE chain_days (
    device_id  uuid        NOT NULL REFERENCES chains (device_id) ON DELETE CASCADE,
    day        date        NOT NULL,
    -- True when the day was covered by the make-up rather than actually marked.
    -- The streak counts both; the report should be able to tell them apart.
    made_up    boolean     NOT NULL DEFAULT false,
    period     smallint    NOT NULL DEFAULT 1,
    marked_at  timestamptz NOT NULL DEFAULT now(),

    PRIMARY KEY (device_id, day)
);

-- The report and the day count are both "this period, this device".
CREATE INDEX chain_days_period ON chain_days (device_id, period);

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


-- ------------------------------------------------------------------ the game

-- What the game came to.
--
-- One row per play rather than a best-score column: the leaderboard wants the
-- best in a week, and a column that only remembers the best forgets which week
-- it happened in.
CREATE TABLE scores (
    id        bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id uuid        NOT NULL,
    points    integer     NOT NULL,
    played_at timestamptz NOT NULL DEFAULT now(),
    -- The Monday of the week it belongs to, so the leaderboard is a lookup
    -- rather than a date range computed in three places.
    week      date        NOT NULL,

    CONSTRAINT scores_points_sane CHECK (points >= 0)
);

CREATE INDEX scores_week_points ON scores (week, points DESC);
CREATE INDEX scores_device ON scores (device_id);

-- Which weeks have already paid out, so a rerun of the job does not hand the
-- same ten people a second report each.
CREATE TABLE score_rewards (
    week        date        PRIMARY KEY,
    awarded     integer     NOT NULL,
    awarded_at  timestamptz NOT NULL DEFAULT now()
);


-- ------------------------------------------------------- what came back to us

-- What happened, so that the questions the product asks can be answered.
--
-- One table, because the whole schema is eighteen event names and nobody is
-- going to join this to anything. A third-party analytics tool would cost money
-- above its free tier and would put this data somewhere we cannot query with
-- the rest.
CREATE TABLE events (
    id          bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id   uuid        NOT NULL,
    name        varchar(48) NOT NULL,
    -- Free-form, because half the events carry a number and half carry nothing,
    -- and a column per event would be a migration per question.
    properties  jsonb       NOT NULL DEFAULT '{}',
    -- When it happened on the phone, which is not when it arrived: events are
    -- queued offline and sent in batches.
    occurred_at timestamptz NOT NULL,
    received_at timestamptz NOT NULL DEFAULT now(),
    -- The same event sent twice — a retry after a timeout that actually landed
    -- — would inflate exactly the numbers this exists to measure.
    client_id   uuid        NOT NULL,

    CONSTRAINT events_client_id_unique UNIQUE (client_id)
);

-- Every question starts with "how many devices did X" over a period.
CREATE INDEX events_name_occurred_at ON events (name, occurred_at);
CREATE INDEX events_device_id ON events (device_id);

-- What people tell us, kept first-party.
--
-- With no accounts these screens are the only channel there is: a complaint
-- with nowhere to go goes to the store review instead, and a one-star review
-- cannot be replied to with a fix.
--
-- One table for every kind, including a rejected archetype. Which archetype
-- gets rejected, and how often, is the only correction signal the rules table
-- has.
CREATE TABLE feedback (
    id         bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id  uuid        NOT NULL,
    kind       varchar(32) NOT NULL,
    message    text        NOT NULL,
    -- Optional on purpose: making it required collapses the submission rate,
    -- and most of what arrives here needs reading, not answering.
    email      varchar(320),
    -- App version, platform, OS version, current archetype. Free-form because
    -- what is worth attaching changes faster than a migration can follow.
    context    jsonb       NOT NULL DEFAULT '{}',
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX feedback_kind_created_at ON feedback (kind, created_at DESC);
