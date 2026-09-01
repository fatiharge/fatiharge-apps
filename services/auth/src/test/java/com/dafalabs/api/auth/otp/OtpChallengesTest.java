package com.dafalabs.api.auth.otp;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.auth.identity.IdentityType;
import com.dafalabs.api.core.error.CustomRuntimeException;
import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OtpChallengesTest {

  @Inject OtpChallenges otp;
  @Inject EntityManager entityManager;

  @Test
  @TestTransaction
  @DisplayName("a code is issued and answers its own challenge")
  void issuesAndAnswers() {
    IssuedChallenge issued = otp.issue(UUID.randomUUID(), IdentityType.EMAIL, "fan@example.com");

    assertEquals(300, issued.expiresInSeconds());
    assertTrue(otp.answer(issued.challengeId(), issued.codeForDelivery()));
  }

  @Test
  @TestTransaction
  @DisplayName("the code is not in the table it was written to")
  void theCodeIsNeverStored() {
    IssuedChallenge issued = otp.issue(UUID.randomUUID(), IdentityType.EMAIL, "fan@example.com");

    Object stored =
        entityManager
            .createNativeQuery("SELECT code_hash FROM otp_challenges WHERE id = :id")
            .setParameter("id", issued.challengeId())
            .getSingleResult();

    assertNotEquals(issued.codeForDelivery(), stored);
  }

  @Test
  @TestTransaction
  @DisplayName("the fourth request within the hour is refused")
  void hourlyLimitStopsIssuing() {
    UUID tenant = UUID.randomUUID();
    for (int i = 0; i < 3; i++) {
      otp.issue(tenant, IdentityType.EMAIL, "fan@example.com");
    }

    CustomRuntimeException refused =
        assertThrows(
            CustomRuntimeException.class,
            () -> otp.issue(tenant, IdentityType.EMAIL, "fan@example.com"));
    assertEquals(429, refused.status());
    assertEquals("otp_rate_limited", refused.code());
  }

  @Test
  @TestTransaction
  @DisplayName("one club's limit does not spend another club's")
  void limitsAreCountedPerTenant() {
    UUID bingol = UUID.randomUUID();
    UUID ankaragucu = UUID.randomUUID();
    for (int i = 0; i < 3; i++) {
      otp.issue(bingol, IdentityType.EMAIL, "fan@example.com");
    }

    // The same address, exhausted in one club, is untouched in the other.
    IssuedChallenge elsewhere = otp.issue(ankaragucu, IdentityType.EMAIL, "fan@example.com");
    assertTrue(otp.find(elsewhere.challengeId()).isPresent());
  }

  @Test
  @TestTransaction
  @DisplayName("however the address was typed, it spends the same limit")
  void limitsIgnoreCasing() {
    UUID tenant = UUID.randomUUID();
    otp.issue(tenant, IdentityType.EMAIL, "fan@example.com");
    otp.issue(tenant, IdentityType.EMAIL, "FAN@Example.com");
    otp.issue(tenant, IdentityType.EMAIL, " fan@example.com ");

    assertThrows(
        CustomRuntimeException.class, () -> otp.issue(tenant, IdentityType.EMAIL, "fan@example.com"));
  }

  @Test
  @TestTransaction
  @DisplayName("an unknown challenge answers no differently from a wrong code")
  void unknownChallengeIsIndistinguishable() {
    assertFalse(otp.answer(UUID.randomUUID(), "123456"));
  }
}
