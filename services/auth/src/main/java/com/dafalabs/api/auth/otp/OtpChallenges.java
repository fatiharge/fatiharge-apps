package com.dafalabs.api.auth.otp;

import com.dafalabs.api.auth.identity.IdentityType;
import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.eclipse.microprofile.config.inject.ConfigProperty;

/** Issues one-time codes, and refuses to issue too many. */
@ApplicationScoped
public class OtpChallenges {

  private final OtpChallengeRepository challenges;
  private final Clock clock;
  private final Duration lifetime;
  private final int maxAttempts;
  private final long hourlyLimit;
  private final long dailyLimit;

  OtpChallenges(
      OtpChallengeRepository challenges,
      Clock clock,
      @ConfigProperty(name = "auth.otp.lifetime") Duration lifetime,
      @ConfigProperty(name = "auth.otp.max-attempts") int maxAttempts,
      @ConfigProperty(name = "auth.otp.hourly-limit") long hourlyLimit,
      @ConfigProperty(name = "auth.otp.daily-limit") long dailyLimit) {
    this.challenges = challenges;
    this.clock = clock;
    this.lifetime = lifetime;
    this.maxAttempts = maxAttempts;
    this.hourlyLimit = hourlyLimit;
    this.dailyLimit = dailyLimit;
  }

  /**
   * The limits are counted per identity within a tenant, not globally: one club's
   * traffic must not be able to lock another club's supporters out, and the same
   * address in two clubs is two different people as far as this service knows.
   */
  @Transactional
  public IssuedChallenge issue(UUID tenantId, IdentityType type, String value) {
    String identity = normalise(value);
    Instant now = clock.instant();
    refuseIfTooMany(tenantId, type, identity, now);

    String code = OtpCodes.generate();
    OtpChallenge challenge =
        OtpChallenge.issue(tenantId, type, identity, code, now, now.plus(lifetime));
    challenges.persist(challenge);

    return new IssuedChallenge(challenge.id(), code, lifetime.toSeconds());
  }

  /**
   * Answering wrong is not an error the caller gets to distinguish. A response
   * that separated "no such challenge" from "wrong code" would let someone learn
   * which addresses have been asked about.
   */
  @Transactional
  public boolean answer(UUID challengeId, String code) {
    return challenges
        .findByIdOptional(challengeId)
        .map(challenge -> challenge.answer(code, clock.instant(), maxAttempts))
        .orElse(false);
  }

  @Transactional
  public boolean consume(UUID challengeId) {
    return challenges
        .findByIdOptional(challengeId)
        .map(challenge -> challenge.consume(clock.instant()))
        .orElse(false);
  }

  public Optional<OtpChallenge> find(UUID challengeId) {
    return challenges.findByIdOptional(challengeId);
  }

  private void refuseIfTooMany(UUID tenantId, IdentityType type, String identity, Instant now) {
    long lastHour = challenges.issuedSince(tenantId, type, identity, now.minus(Duration.ofHours(1)));
    long lastDay = challenges.issuedSince(tenantId, type, identity, now.minus(Duration.ofDays(1)));

    if (lastHour >= hourlyLimit || lastDay >= dailyLimit) {
      throw new CustomRuntimeException(
          429, "otp_rate_limited", "Too many codes requested for this identity. Try again later.");
    }
  }

  /** The same form the identity is stored in, or the limits count two of one person. */
  private static String normalise(String value) {
    return value == null ? null : value.trim().toLowerCase();
  }
}
