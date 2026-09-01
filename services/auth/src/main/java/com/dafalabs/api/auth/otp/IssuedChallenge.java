package com.dafalabs.api.auth.otp;

import java.util.UUID;

/**
 * What the caller learns when a code is issued: that one exists, and how long it
 * lasts.
 *
 * <p>Not the code. The code goes to the outbox and to nowhere the caller can
 * reach — the system this replaces returned it in the response body, which let
 * anyone take any account by naming its address. Leaving it out of this record
 * makes repeating that a change to the type rather than an oversight.
 */
public record IssuedChallenge(UUID challengeId, long expiresInSeconds) {}
