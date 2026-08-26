package com.dafalabs.api.auth.device;

import io.smallrye.jwt.build.Jwt;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.Duration;
import java.time.Instant;
import org.eclipse.microprofile.config.inject.ConfigProperty;

/**
 * Signs the token every other service verifies.
 *
 * <p>The subject is the device id rather than the hash: services need something
 * to attribute rows to, and none of them has any use for the hash itself.
 */
@ApplicationScoped
public class TokenIssuer {

  private final Duration lifetime;
  private final String issuer;

  TokenIssuer(
      @ConfigProperty(name = "auth.token.lifetime") Duration lifetime,
      @ConfigProperty(name = "mp.jwt.verify.issuer") String issuer) {
    this.lifetime = lifetime;
    this.issuer = issuer;
  }

  public IssuedToken issue(Device device, Instant now) {
    Instant expiresAt = now.plus(lifetime);
    String token =
        Jwt.issuer(issuer)
            .subject(device.id().toString())
            .claim("platform", device.platform())
            .issuedAt(now)
            .expiresAt(expiresAt)
            .sign();

    return new IssuedToken(device.id(), token, lifetime.toSeconds());
  }
}
