package com.dafalabs.api.core.auth;

import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.RequestScoped;
import java.util.UUID;
import org.eclipse.microprofile.jwt.JsonWebToken;

/**
 * The device the current request speaks for.
 *
 * <p>Every service verifies the token itself, against the public key, without
 * asking the auth service anything: a login is the only request auth ever
 * receives. This bean exists so that no service parses claims by hand and so
 * that a missing subject fails the same way everywhere.
 */
@RequestScoped
public class AuthenticatedDevice {

  private final JsonWebToken token;

  AuthenticatedDevice(JsonWebToken token) {
    this.token = token;
  }

  public UUID id() {
    String subject = token.getSubject();
    if (subject == null || subject.isBlank()) {
      throw new CustomRuntimeException(
          401, "unauthenticated", "The token carries no subject.");
    }
    try {
      return UUID.fromString(subject);
    } catch (IllegalArgumentException malformed) {
      // A well-signed token with a subject we did not issue. Treat it as no
      // token at all rather than a server fault: the caller is the problem.
      throw new CustomRuntimeException(
          401, "unauthenticated", "The token subject is not a device id.", malformed);
    }
  }
}
