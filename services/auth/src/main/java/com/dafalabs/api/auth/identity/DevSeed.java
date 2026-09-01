package com.dafalabs.api.auth.identity;

import io.quarkus.arc.profile.IfBuildProfile;
import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.util.UUID;

/**
 * One administrator, in development only.
 *
 * <p>Development starts on an empty database every time, and nothing here can
 * create the first administrator: signing in with a code produces an ordinary
 * user, and only an administrator can promote anyone. Without this, the first
 * step of every local session is hand-editing rows.
 *
 * <p>{@link IfBuildProfile} rather than a runtime flag: the class is not
 * compiled into the packaged application at all. Code that opens an account with
 * a known password is better absent from production than present and asking
 * whether it should run.
 */
@ApplicationScoped
@IfBuildProfile("dev")
public class DevSeed {

  /**
   * Fixed, and shared with the product that owns this tenant. This service does
   * not know what a tenant is called, so a random id here would leave the two
   * pointing at different tenants after every restart.
   */
  private static final UUID TENANT = UUID.fromString("11111111-1111-1111-1111-111111111111");

  private static final String IDENTITY = "admin@demo.test";
  private static final String PASSWORD = "demo-yonetici-parolasi";

  private final UserRepository users;
  private final UserIdentityRepository identities;
  private final Passwords passwords;
  private final Clock clock;

  DevSeed(
      UserRepository users,
      UserIdentityRepository identities,
      Passwords passwords,
      Clock clock) {
    this.users = users;
    this.identities = identities;
    this.passwords = passwords;
    this.clock = clock;
  }

  @Transactional
  void seed(@Observes StartupEvent event) {
    if (identities.find(TENANT, IdentityType.EMAIL, IDENTITY).isPresent()) {
      return;
    }

    User admin = User.create(TENANT, Role.TENANT_ADMIN, clock.instant());
    users.persist(admin);

    UserIdentity identity =
        UserIdentity.claim(admin, IdentityType.EMAIL, IDENTITY, clock.instant());
    // Verified outright: there is no inbox to prove in development, and an
    // unverified identity cannot be signed in with.
    identity.verify(clock.instant());
    identities.persist(identity);

    passwords.set(admin, PASSWORD);
  }
}
