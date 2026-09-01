package com.dafalabs.api.auth.session;

import java.util.UUID;

/**
 * The outcome of presenting a password: either a session, or half of one.
 *
 * <p>A supporter with a password is signed in. Anyone who runs a panel is not —
 * they get a code and a token proving they passed the first step.
 */
public record PasswordSignIn(
    SessionTokens tokens, String pendingToken, UUID challengeId, long codeExpiresInSeconds) {

  static PasswordSignIn complete(SessionTokens tokens) {
    return new PasswordSignIn(tokens, null, null, 0);
  }

  static PasswordSignIn secondFactorRequired(String pendingToken, UUID challengeId, long expiresIn) {
    return new PasswordSignIn(null, pendingToken, challengeId, expiresIn);
  }

  public boolean isComplete() {
    return tokens != null;
  }
}
