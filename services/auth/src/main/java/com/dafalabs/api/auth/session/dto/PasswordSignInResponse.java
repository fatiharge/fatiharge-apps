package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One shape for two outcomes, told apart by {@code status} rather than by which
 * fields happen to be null — a client that guessed from nullness would break the
 * first time an account gained a second factor.
 *
 * @param status {@code COMPLETE} or {@code SECOND_FACTOR_REQUIRED}
 * @param session present when {@code COMPLETE}
 * @param pendingToken present otherwise; proves the password step and names the
 *     challenge that finishes it
 */
public record PasswordSignInResponse(
    @Schema(required = true) String status,
    SessionResponse session,
    String pendingToken,
    String challengeId,
    long codeExpiresInSeconds) {}
