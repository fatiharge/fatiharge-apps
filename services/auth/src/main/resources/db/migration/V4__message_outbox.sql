-- Messages this service wants sent, written down instead of sent.
--
-- There is no provider yet — no mail relay, no SMS account — and picking one is
-- a decision with a cost attached (see the architecture notes on the sender
-- domain). Writing the row now means the flows that need a code are complete
-- and testable, and connecting a channel later is a reader over this table
-- rather than a change to every caller.
--
-- It is also the right shape once a provider exists: sending inside the
-- transaction that issued the code would either hold the transaction open for
-- the length of an SMTP call, or send a code for a transaction that then rolled
-- back.
CREATE TABLE message_outbox (
    id         uuid        PRIMARY KEY,
    tenant_id  uuid        NOT NULL,
    channel    varchar(16) NOT NULL,
    recipient  text        NOT NULL,
    template   varchar(64) NOT NULL,
    -- JSON, but text: nothing queries inside it. jsonb would buy indexing that
    -- no reader of this table wants.
    variables  text        NOT NULL,
    status     varchar(16) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    sent_at    timestamptz
);

ALTER TABLE message_outbox
    ADD CONSTRAINT message_outbox_channel_known CHECK (channel IN ('EMAIL', 'PHONE')),
    ADD CONSTRAINT message_outbox_status_known  CHECK (status  IN ('PENDING', 'SENT', 'FAILED'));

-- The only question a sender will ask: what is still waiting, oldest first.
CREATE INDEX message_outbox_pending_idx
    ON message_outbox (created_at)
    WHERE status = 'PENDING';
