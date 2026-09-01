package com.dafalabs.api.auth.identity;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.core.error.CustomRuntimeException;
import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class PasswordsTest {

  private static final Instant NOW = Instant.parse("2026-09-01T10:00:00Z");
  private static final String GOOD = "kartallar-yesil-beyaz";

  @Inject Passwords passwords;
  @Inject UserRepository users;
  @Inject UserCredentialRepository credentials;

  @Test
  @TestTransaction
  @DisplayName("a password set is a password that verifies")
  void setThenVerify() {
    User admin = admin();
    passwords.set(admin, GOOD);

    assertTrue(passwords.verify(admin.id(), GOOD));
    assertFalse(passwords.verify(admin.id(), GOOD + "x"));
  }

  @Test
  @TestTransaction
  @DisplayName("the password is not what gets stored")
  void theStoredValueIsAHash() {
    User admin = admin();
    passwords.set(admin, GOOD);

    String stored = credentials.find(admin.id(), CredentialType.PASSWORD).orElseThrow().secretHash();
    assertNotEquals(GOOD, stored);
    assertTrue(stored.startsWith("$2"), "expected a bcrypt hash, got: " + stored);
  }

  @Test
  @TestTransaction
  @DisplayName("the same password hashed twice gives two different hashes")
  void hashesAreSalted() {
    User first = admin();
    User second = admin();
    passwords.set(first, GOOD);
    passwords.set(second, GOOD);

    // Without a per-row salt, two people with one password share one hash, and
    // cracking it once cracks both.
    assertNotEquals(
        credentials.find(first.id(), CredentialType.PASSWORD).orElseThrow().secretHash(),
        credentials.find(second.id(), CredentialType.PASSWORD).orElseThrow().secretHash());
  }

  @Test
  @TestTransaction
  @DisplayName("setting again replaces rather than adds a second way in")
  void settingAgainReplaces() {
    User admin = admin();
    passwords.set(admin, GOOD);
    passwords.set(admin, "bingolspor-kartallari");

    assertFalse(passwords.verify(admin.id(), GOOD));
    assertTrue(passwords.verify(admin.id(), "bingolspor-kartallari"));
  }

  @Test
  @TestTransaction
  @DisplayName("someone with no password verifies nothing")
  void aFanWithoutAPasswordCannotBeVerified() {
    User fan = User.create(UUID.randomUUID(), Role.FAN, NOW);
    users.persist(fan);

    assertFalse(passwords.has(fan.id()));
    assertFalse(passwords.verify(fan.id(), GOOD));
    assertFalse(passwords.verify(fan.id(), ""));
  }

  @Test
  @TestTransaction
  @DisplayName("the six digits the old system allowed are refused")
  void shortPasswordsAreRefused() {
    CustomRuntimeException refused =
        assertThrows(CustomRuntimeException.class, () -> passwords.set(admin(), "123456"));

    assertEquals(422, refused.status());
    assertEquals("password_rejected", refused.code());
  }

  @Test
  @TestTransaction
  @DisplayName("an obvious password of the right length is still refused")
  void obviousPasswordsAreRefused() {
    assertThrows(CustomRuntimeException.class, () -> passwords.set(admin(), "password1234"));
  }

  private User admin() {
    User admin = User.create(UUID.randomUUID(), Role.CLUB_ADMIN, NOW);
    users.persist(admin);
    return admin;
  }
}
