package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** The club is read from the challenge, so it is deliberately not a field here. */
public record CodeSignInRequest(
    @Schema(required = true) String challengeId, @Schema(required = true) String code) {}
