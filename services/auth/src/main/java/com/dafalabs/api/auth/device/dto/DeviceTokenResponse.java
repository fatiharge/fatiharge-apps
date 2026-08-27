package com.dafalabs.api.auth.device.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param deviceId what every other service will see as the token subject
 * @param token the bearer token, signed here and verified locally elsewhere
 * @param expiresInSeconds when to register again — there is no refresh flow
 */
public record DeviceTokenResponse(
    @Schema(required = true) String deviceId,
    @Schema(required = true) String token,
    @Schema(required = true) long expiresInSeconds) {}
