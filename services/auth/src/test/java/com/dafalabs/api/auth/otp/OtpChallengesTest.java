package com.dafalabs.api.auth.otp;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.auth.delivery.OutboxMessage;
import com.dafalabs.api.auth.delivery.OutboxRepository;
import com.dafalabs.api.auth.identity.IdentityType;
import com.dafalabs.api.core.error.CustomRuntimeException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class OtpChallengesTest {

  @Inject OtpChallenges otp;
  @Inject OutboxRepository outbox;
  @Inject EntityManager entityManager;
  @Inject ObjectMapper json;

  @Test
  @TestTransaction
  @DisplayName("the code reaches the outbox and answers its own challenge")
  void issuesThroughTheOutbox() {
    UUID tenant = UUID.randomUUID();
    IssuedChallenge issued = otp.issue(tenant, IdentityType.EMAIL, "fan@example.com");

    assertEquals(300, issued.expiresInSeconds());
    assertTrue(otp.answer(issued.challengeId(), codeSentTo(tenant, "fan@example.com")));
  }

  @Test
  @TestTransaction
  @DisplayName("the message is addressed to the right person for the right tenant")
  void theOutboxRowCarriesItsTenant() {
    UUID tenant = UUID.randomUUID();
    otp.issue(tenant, IdentityType.EMAIL, "fan@example.com");

    OutboxMessage message = onlyMessage(tenant, "fan@example.com");
    assertEquals(tenant, message.tenantId());
    assertEquals(IdentityType.EMAIL, message.channel());
    assertEquals(OtpChallenges.CODE_TEMPLATE, message.template());
  }

  @Test
  @TestTransaction
  @DisplayName("the code is not in the challenge table it was written to")
  void theCodeIsNeverStoredAlongsideItsChallenge() {
    UUID tenant = UUID.randomUUID();
    IssuedChallenge issued = otp.issue(tenant, IdentityType.EMAIL, "fan@example.com");

    Object stored =
        entityManager
            .createNativeQuery("SELECT code_hash FROM otp_challenges WHERE id = :id")
            .setParameter("id", issued.challengeId())
            .getSingleResult();

    assertNotEquals(codeSentTo(tenant, "fan@example.com"), stored);
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
  @DisplayName("one tenant's limit does not spend another tenant's")
  void limitsAreCountedPerTenant() {
    UUID firstTenant = UUID.randomUUID();
    UUID secondTenant = UUID.randomUUID();
    for (int i = 0; i < 3; i++) {
      otp.issue(firstTenant, IdentityType.EMAIL, "fan@example.com");
    }

    // The same address, exhausted in one tenant, is untouched in the other.
    IssuedChallenge elsewhere = otp.issue(secondTenant, IdentityType.EMAIL, "fan@example.com");
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
        CustomRuntimeException.class,
        () -> otp.issue(tenant, IdentityType.EMAIL, "fan@example.com"));
  }

  @Test
  @TestTransaction
  @DisplayName("an unknown challenge answers no differently from a wrong code")
  void unknownChallengeIsIndistinguishable() {
    assertFalse(otp.answer(UUID.randomUUID(), "123456"));
  }

  private String codeSentTo(UUID tenantId, String recipient) {
    try {
      Map<?, ?> variables = json.readValue(onlyMessage(tenantId, recipient).variables(), Map.class);
      return (String) variables.get("code");
    } catch (Exception e) {
      throw new IllegalStateException(e);
    }
  }

  private OutboxMessage onlyMessage(UUID tenantId, String recipient) {
    List<OutboxMessage> messages = outbox.to(tenantId, recipient);
    assertEquals(1, messages.size(), "expected exactly one message for " + recipient);
    return messages.get(0);
  }
}
