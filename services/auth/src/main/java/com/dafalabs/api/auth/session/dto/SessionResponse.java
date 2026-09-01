package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record SessionResponse(
    @Schema(required = true) String accessToken,
    @Schema(required = true) String refreshToken,
    @Schema(required = true) long expiresInSeconds) {}
