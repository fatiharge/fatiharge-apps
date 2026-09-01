package com.dafalabs.api.auth.identity;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import io.quarkus.test.TestTransaction;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.persistence.PersistenceException;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class UserIdentityTest {

  private static final Instant NOW = Instant.parse("2026-09-01T10:00:00Z");

  @Inject UserRepository users;
  @Inject UserIdentityRepository identities;
  @Inject UserCredentialRepository credentials;

  @Test
  @TestTransaction
  @DisplayName("the same address belongs to two tenants at once")
  void oneAddressCanExistInEveryTenant() {
    UUID bingol = UUID.randomUUID();
    UUID ankaragucu = UUID.randomUUID();

    claim(bingol, "fan@example.com");
    claim(ankaragucu, "fan@example.com");

    // Supporting two clubs is ordinary, and neither club may learn of the other
    // from a sign-up that failed.
    assertTrue(identities.find(bingol, IdentityType.EMAIL, "fan@example.com").isPresent());
    assertTrue(identities.find(ankaragucu, IdentityType.EMAIL, "fan@example.com").isPresent());
  }

  @Test
  @TestTransaction
  @DisplayName("the same address twice inside one tenant is refused")
  void oneAddressIsUniqueWithinATenant() {
    UUID bingol = UUID.randomUUID();
    claim(bingol, "fan@example.com");

    assertThrows(
        PersistenceException.class,
        () -> {
          claim(bingol, "fan@example.com");
          identities.flush();
        });
  }

  @Test
  @TestTransaction
  @DisplayName("a lookup in one tenant cannot see another tenant's identity")
  void lookupIsScopedToTheTenant() {
    UUID bingol = UUID.randomUUID();
    claim(bingol, "fan@example.com");

    Optional<UserIdentity> elsewhere =
        identities.find(UUID.randomUUID(), IdentityType.EMAIL, "fan@example.com");

    assertTrue(elsewhere.isEmpty());
  }

  @Test
  @TestTransaction
  @DisplayName("an address is stored in one form however it was typed")
  void addressesAreNormalised() {
    UUID bingol = UUID.randomUUID();
    claim(bingol, "  Fan@Example.COM ");

    // Found by the form nobody typed, because both were reduced to it.
    assertTrue(identities.find(bingol, IdentityType.EMAIL, "fan@example.com").isPresent());
  }

  @Test
  @TestTransaction
  @DisplayName("a claimed identity is not a verified one")
  void claimingDoesNotVerify() {
    UUID bingol = UUID.randomUUID();
    UserIdentity identity = claim(bingol, "fan@example.com");

    assertFalse(identity.isVerified());

    identity.verify(NOW);
    assertTrue(identity.isVerified());
  }

  @Test
  @TestTransaction
  @DisplayName("a fan has no credential, a club admin has one")
  void credentialsAreOptional() {
    UUID bingol = UUID.randomUUID();

    User fan = User.create(bingol, Role.FAN, NOW);
    User admin = User.create(bingol, Role.CLUB_ADMIN, NOW);
    users.persist(fan);
    users.persist(admin);
    credentials.persist(UserCredential.of(admin, CredentialType.PASSWORD, "hash", NOW));

    assertTrue(credentials.find(fan.id(), CredentialType.PASSWORD).isEmpty());
    assertTrue(credentials.find(admin.id(), CredentialType.PASSWORD).isPresent());
  }

  @Test
  @TestTransaction
  @DisplayName("blocking someone invalidates the tokens already in their hands")
  void blockingRevokesIssuedTokens() {
    User user = User.create(UUID.randomUUID(), Role.FAN, NOW);
    users.persist(user);
    assertEquals(0, user.tokenEpoch());
    assertTrue(user.canSignIn());

    user.block();

    // Every refresh token in the wild carries epoch 0 and is now behind.
    assertEquals(1, user.tokenEpoch());
    assertFalse(user.canSignIn());
  }

  private UserIdentity claim(UUID tenantId, String address) {
    User user = User.create(tenantId, Role.FAN, NOW);
    users.persist(user);
    UserIdentity identity = UserIdentity.claim(user, IdentityType.EMAIL, address, NOW);
    identities.persist(identity);
    return identity;
  }
}
