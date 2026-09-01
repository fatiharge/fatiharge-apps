package com.dafalabs.api.auth.session;

/** What a completed sign-in hands back. */
public record SessionTokens(String accessToken, String refreshToken, long expiresInSeconds) {}
