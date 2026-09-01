package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * That a code exists and how long it lasts — never the code. Returning it is
 * what let anyone take any account in the system this replaces.
 */
public record ChallengeResponse(
    @Schema(required = true) String challengeId, @Schema(required = true) long expiresInSeconds) {}
