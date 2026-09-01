package com.dafalabs.api.auth.otp;

import java.util.UUID;

/**
 * A challenge and the code that answers it.
 *
 * <p>{@link #codeForDelivery()} goes to the channel carrying it and nowhere
 * else. It must never reach a response body: the system this replaces returned
 * the code to whoever asked for it, which let anyone take any account by naming
 * its address. The accessor is named the way it is so that putting it in a DTO
 * has to be a decision rather than an autocomplete.
 */
public record IssuedChallenge(UUID challengeId, String codeForDelivery, long expiresInSeconds) {}
