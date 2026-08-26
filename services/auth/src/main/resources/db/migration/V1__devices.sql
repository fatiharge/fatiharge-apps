-- A device is the only identity a free user has: there is no account until
-- something is bought. The raw device identifier never arrives here — the app
-- sends a SHA-256 of it, which is what makes this table dull if it ever leaks.
CREATE TABLE devices (
    id          uuid        PRIMARY KEY,
    device_hash char(64)    NOT NULL UNIQUE,
    platform    varchar(16) NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

-- The API rejects these too. Enforcing them here as well means a bug in one
-- endpoint cannot quietly fill the column with something else.
ALTER TABLE devices
    ADD CONSTRAINT devices_device_hash_is_sha256 CHECK (device_hash ~ '^[0-9a-f]{64}$'),
    ADD CONSTRAINT devices_platform_known        CHECK (platform IN ('ios', 'android'));
