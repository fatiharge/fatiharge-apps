-- A one-time code, and everything needed to refuse the next one.
--
-- Deliberately not tied to a user: a code is asked for before there is an
-- account, and tying the two would mean creating a user for every address
-- someone typed by mistake.
CREATE TABLE otp_challenges (
    id             uuid        PRIMARY KEY,
    tenant_id      uuid        NOT NULL,
    identity_type  varchar(16) NOT NULL,
    identity_value text        NOT NULL,
    -- The code itself is never stored. A leaked table is then a list of
    -- addresses rather than a list of ways in — for the few minutes the rows
    -- are alive. It is not protection against cracking: six digits fall to any
    -- offline attack whatever the hash. What actually defends the code is the
    -- lifetime, the attempt cap and the rate limit below.
    code_hash      char(64)    NOT NULL,
    status         varchar(16) NOT NULL,
    attempts       integer     NOT NULL DEFAULT 0,
    created_at     timestamptz NOT NULL DEFAULT now(),
    expires_at     timestamptz NOT NULL,
    verified_at    timestamptz,
    consumed_at    timestamptz
);

ALTER TABLE otp_challenges
    ADD CONSTRAINT otp_challenges_identity_type_known
        CHECK (identity_type IN ('EMAIL', 'PHONE')),
    ADD CONSTRAINT otp_challenges_status_known
        CHECK (status IN ('PENDING', 'VERIFIED', 'CONSUMED', 'BLOCKED', 'EXPIRED'));

-- Counting recent challenges for one identity is the rate limit, so that count
-- is the only query this table is asked for often. Ordering by created_at is
-- part of the index rather than a sort afterwards.
CREATE INDEX otp_challenges_identity_recent_idx
    ON otp_challenges (tenant_id, identity_type, identity_value, created_at DESC);
