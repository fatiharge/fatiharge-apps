package com.dafalabs.api.auth.device;

import java.util.UUID;

/** A signed token and the identity it speaks for. */
public record IssuedToken(UUID deviceId, String token, long expiresInSeconds) {}
