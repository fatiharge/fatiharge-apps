package com.dafalabs.api.auth.otp;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.auth.identity.IdentityType;
import java.time.Duration;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/** The rules a challenge enforces on its own, with time supplied rather than read. */
class OtpChallengeTest {

  private static final Instant NOW = Instant.parse("2026-09-01T10:00:00Z");
  private static final Instant EXPIRES = NOW.plus(Duration.ofMinutes(5));
  private static final String CODE = "123456";
  private static final int MAX_ATTEMPTS = 5;

  @Test
  @DisplayName("the right code verifies the challenge")
  void rightCodeVerifies() {
    OtpChallenge challenge = issued();

    assertTrue(challenge.answer(CODE, NOW, MAX_ATTEMPTS));
    assertEquals(OtpStatus.VERIFIED, challenge.status());
  }

  @Test
  @DisplayName("a wrong code is counted and leaves the challenge alive")
  void wrongCodeCounts() {
    OtpChallenge challenge = issued();

    assertFalse(challenge.answer("000000", NOW, MAX_ATTEMPTS));
    assertEquals(1, challenge.attempts());
    assertEquals(OtpStatus.PENDING, challenge.status());
  }

  @Test
  @DisplayName("the cap kills the challenge, and the right code no longer saves it")
  void tooManyAttemptsBlock() {
    OtpChallenge challenge = issued();

    for (int i = 0; i < MAX_ATTEMPTS; i++) {
      challenge.answer("000000", NOW, MAX_ATTEMPTS);
    }
    assertEquals(OtpStatus.BLOCKED, challenge.status());

    // Arriving with the right code afterwards is exactly what a guesser does.
    assertFalse(challenge.answer(CODE, NOW, MAX_ATTEMPTS));
  }

  @Test
  @DisplayName("an expired challenge refuses the right code")
  void expiredRefusesTheRightCode() {
    OtpChallenge challenge = issued();

    assertFalse(challenge.answer(CODE, EXPIRES.plusSeconds(1), MAX_ATTEMPTS));
    assertEquals(OtpStatus.EXPIRED, challenge.status());
  }

  @Test
  @DisplayName("a verified challenge is spent once")
  void consumingIsOnlyPossibleOnce() {
    OtpChallenge challenge = issued();
    challenge.answer(CODE, NOW, MAX_ATTEMPTS);

    assertTrue(challenge.consume(NOW));
    assertEquals(OtpStatus.CONSUMED, challenge.status());
    assertFalse(challenge.consume(NOW));
  }

  @Test
  @DisplayName("an unverified challenge cannot be spent")
  void consumingRequiresVerification() {
    assertFalse(issued().consume(NOW));
  }

  private static OtpChallenge issued() {
    return OtpChallenge.issue(
        UUID.randomUUID(), IdentityType.EMAIL, "fan@example.com", CODE, NOW, EXPIRES);
  }
}
