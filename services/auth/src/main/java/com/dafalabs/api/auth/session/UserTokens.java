package com.dafalabs.api.auth.session;

import com.dafalabs.api.auth.identity.User;
import com.dafalabs.api.core.error.CustomRuntimeException;
import io.smallrye.jwt.auth.principal.JWTParser;
import io.smallrye.jwt.auth.principal.ParseException;
import io.smallrye.jwt.build.Jwt;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Set;
import java.util.UUID;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.jwt.JsonWebToken;

/**
 * Signs and reads the tokens a signed-in person carries.
 *
 * <p>Every token names the club it was issued for. A service that trusts the
 * subject without reading that claim would let one club's token act in another,
 * and no amount of care at the call sites makes up for leaving it out.
 */
@ApplicationScoped
public class UserTokens {

  static final String CLUB = "club";
  static final String ROLE = "role";
  static final String EPOCH = "epoch";
  // Not "typ": that is a JOSE header name, and setting a claim by that name
  // rewrites the header the parser checks rather than adding a claim.
  static final String TYPE = "token_type";
  static final String CHALLENGE = "challenge";

  static final String ACCESS = "access";
  static final String REFRESH = "refresh";
  static final String PENDING = "pending";

  private final JWTParser parser;
  private final Clock clock;
  private final String issuer;
  private final Duration accessLifetime;
  private final Duration refreshLifetime;
  private final Duration pendingLifetime;

  UserTokens(
      JWTParser parser,
      Clock clock,
      @ConfigProperty(name = "mp.jwt.verify.issuer") String issuer,
      @ConfigProperty(name = "auth.session.access-lifetime") Duration accessLifetime,
      @ConfigProperty(name = "auth.session.refresh-lifetime") Duration refreshLifetime,
      @ConfigProperty(name = "auth.session.pending-lifetime") Duration pendingLifetime) {
    this.parser = parser;
    this.clock = clock;
    this.issuer = issuer;
    this.accessLifetime = accessLifetime;
    this.refreshLifetime = refreshLifetime;
    this.pendingLifetime = pendingLifetime;
  }

  public SessionTokens issue(User user) {
    Instant now = clock.instant();
    return new SessionTokens(
        sign(user, ACCESS, accessLifetime, now).groups(Set.of(user.role().name())).sign(),
        sign(user, REFRESH, refreshLifetime, now).sign(),
        accessLifetime.toSeconds());
  }

  /** Proves the password step happened, and nothing else. Carries no groups. */
  public String issuePending(User user, UUID challengeId) {
    Instant now = clock.instant();
    return sign(user, PENDING, pendingLifetime, now).claim(CHALLENGE, challengeId.toString()).sign();
  }

  public JsonWebToken readRefresh(String token) {
    return read(token, REFRESH);
  }

  public JsonWebToken readPending(String token) {
    return read(token, PENDING);
  }

  /**
   * A refresh token presented as an access token — or the other way round — is
   * refused. Without the check, the long-lived token would be accepted anywhere
   * the short-lived one is, and its whole reason for being separate is gone.
   */
  private JsonWebToken read(String token, String expectedType) {
    JsonWebToken jwt;
    try {
      jwt = parser.parse(token);
    } catch (ParseException e) {
      throw unauthorised();
    }
    if (!expectedType.equals(jwt.getClaim(TYPE))) {
      throw unauthorised();
    }
    return jwt;
  }

  private io.smallrye.jwt.build.JwtClaimsBuilder sign(
      User user, String type, Duration lifetime, Instant now) {
    return Jwt.issuer(issuer)
        .subject(user.id().toString())
        .claim(CLUB, user.tenantId().toString())
        .claim(ROLE, user.role().name())
        .claim(EPOCH, user.tokenEpoch())
        .claim(TYPE, type)
        .issuedAt(now)
        .expiresAt(now.plus(lifetime));
  }

  static CustomRuntimeException unauthorised() {
    // One message for every way a token can be wrong. Saying which way would
    // tell whoever is probing what to change.
    return new CustomRuntimeException(401, "invalid_token", "The token is not usable.");
  }
}
