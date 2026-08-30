-- A turn at the game is earned, not free.
--
-- The week's ten best scores win a deep report, and until now anybody could
-- play as often as they liked for as many chances at it. The game is meant to
-- be what the day's work pays for: marking the day is worth one turn, and
-- finishing all three of the day's things is worth three.
--
-- Held here rather than on the phone because the device identifier survives a
-- reinstall and preferences do not. Turns kept on the phone are turns anybody
-- can mint by clearing the app's data, and what they would be minting is
-- chances at something that costs money to give away.

CREATE TABLE game_credits (
    device_id uuid        NOT NULL,
    day       date        NOT NULL,
    -- What earned it. The number of turns hangs off this rather than being
    -- stored, so a row can only ever be worth what the rule says it is worth.
    reason    varchar(24) NOT NULL,
    earned_at timestamptz NOT NULL DEFAULT now(),

    -- Earning the same thing twice on one day is earning it once. The phone's
    -- offline queue sends a marked day more than once as a matter of course.
    PRIMARY KEY (device_id, day, reason)
);

-- Not carried over: a turn belongs to the day that paid for it. Somebody
-- coming back after a week away starts from what they do today, not from a
-- pile of turns they never used.
CREATE TABLE game_plays (
    id        bigint      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    device_id uuid        NOT NULL,
    day       date        NOT NULL,
    played_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX game_plays_device_day ON game_plays (device_id, day);
