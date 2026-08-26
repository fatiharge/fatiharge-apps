package com.dafalabs.api.auth.device.dto;

/**
 * @param deviceId what every other service will see as the token subject
 * @param token the bearer token, signed here and verified locally elsewhere
 * @param expiresInSeconds when to register again — there is no refresh flow
 */
public record DeviceTokenResponse(String deviceId, String token, long expiresInSeconds) {}
