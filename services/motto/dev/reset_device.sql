-- Puts a device back to its first launch. Stage only.
--
-- The usage counter is deliberately the one thing `DELETE /v1/me` keeps, so
-- there is no way to walk the flow twice from inside the app. That is correct
-- in production and useless while testing, which is what this file is for.
--
--   cd /srv/motto-stage
--   docker compose exec -T db psql -U motto -d motto < reset_device.sql
--
-- Resets every device by default, because on stage that is what is wanted. To
-- reset one, put its id in and uncomment the WHERE clauses.
--
--   \set device '00000000-0000-0000-0000-000000000000'

BEGIN;

DELETE FROM task_completions;  -- WHERE device_id = :'device';
DELETE FROM chain_days;        -- WHERE device_id = :'device';
DELETE FROM chains;            -- WHERE device_id = :'device';
DELETE FROM results;           -- WHERE device_id = :'device';
DELETE FROM scores;            -- WHERE device_id = :'device';
DELETE FROM entitlements;      -- WHERE device_id = :'device';

COMMIT;

-- The row is created again on the next request, with the free uses back and
-- no cooldown.
SELECT 'reset' AS state, count(*) AS entitlements_left FROM entitlements;
