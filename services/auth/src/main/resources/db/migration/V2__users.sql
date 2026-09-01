-- An account, for the products that have one. A device (V1) is enough while
-- nothing is owned; a user appears when someone has to be recognised across
-- devices — someone a product keeps something for, someone who administers it.
--
-- Every row is scoped to a tenant. The tenant is an opaque id here on purpose:
-- who a tenant *is* — its name, its colours, its domain — belongs to the product
-- that sells to it, not to the service that authenticates its people. More than
-- one product authenticates here, and none of their vocabularies belong in this
-- schema. This service only needs to know that two tenants are different.
CREATE TABLE users (
    id          uuid        PRIMARY KEY,
    tenant_id   uuid        NOT NULL,
    role        varchar(16) NOT NULL,
    status      varchar(16) NOT NULL,
    -- Revocation, without storing a row per refresh token. The token carries the
    -- epoch it was issued under; refusing every token below the current value
    -- logs a person out of every device at once. Costs one integer and no extra
    -- query: the refresh path already reads this row to check status.
    token_epoch integer     NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE users
    ADD CONSTRAINT users_role_known   CHECK (role   IN ('USER', 'TENANT_ADMIN', 'STAFF')),
    ADD CONSTRAINT users_status_known CHECK (status IN ('ACTIVE', 'BLOCKED', 'DELETED'));

CREATE INDEX users_tenant_idx ON users (tenant_id);

-- Who someone is, as rows rather than columns. An email column on users could
-- hold one address and only ever that; a row per identity means a phone number
-- can be added later without touching the schema, and someone can hold both.
CREATE TABLE user_identities (
    id          uuid        PRIMARY KEY,
    user_id     uuid        NOT NULL REFERENCES users (id),
    -- Denormalised from users so the uniqueness below can be expressed at all.
    tenant_id   uuid        NOT NULL,
    type        varchar(16) NOT NULL,
    identity_value text     NOT NULL,
    -- Null until the identity is proven. An unverified identity can be held but
    -- never used to log in: that is what stops someone claiming another's email.
    verified_at timestamptz,
    created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE user_identities
    ADD CONSTRAINT user_identities_type_known CHECK (type IN ('EMAIL', 'PHONE'));

-- Scoped to the tenant, not global. The same person can hold an account in two
-- tenants with one address, and neither may learn that from the other's sign-up
-- failing.
CREATE UNIQUE INDEX user_identities_tenant_value_uq
    ON user_identities (tenant_id, type, identity_value);

CREATE INDEX user_identities_user_idx ON user_identities (user_id);

-- How someone proves the identity above. Separate from users because having a
-- password is optional: a fan signs in with a one-time code and has no row
-- here at all, while whoever administers a tenant is required to have one. A
-- nullable column
-- on users could not tell "no password" from "password not set yet".
CREATE TABLE user_credentials (
    id          uuid        PRIMARY KEY,
    user_id     uuid        NOT NULL REFERENCES users (id),
    type        varchar(16) NOT NULL,
    secret_hash text        NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE user_credentials
    ADD CONSTRAINT user_credentials_type_known CHECK (type IN ('PASSWORD'));

-- One credential of each kind per person. A second password is not a fallback,
-- it is a second way in that nobody audits.
CREATE UNIQUE INDEX user_credentials_user_type_uq
    ON user_credentials (user_id, type);
