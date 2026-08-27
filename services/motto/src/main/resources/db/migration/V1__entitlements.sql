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
