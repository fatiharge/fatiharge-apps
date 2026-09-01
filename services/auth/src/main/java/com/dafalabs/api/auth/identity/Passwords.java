package com.dafalabs.api.auth.identity;

import io.quarkus.elytron.security.common.BcryptUtil;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.util.Optional;
import java.util.UUID;

/** Sets and checks the one credential kind there is. */
@ApplicationScoped
public class Passwords {

  private final UserCredentialRepository credentials;
  private final Clock clock;

  Passwords(UserCredentialRepository credentials, Clock clock) {
    this.credentials = credentials;
    this.clock = clock;
  }

  /** Replaces an existing password rather than adding a second way in. */
  @Transactional
  public void set(User user, String password) {
    PasswordPolicy.check(password);
    String hash = BcryptUtil.bcryptHash(password);

    credentials
        .find(user.id(), CredentialType.PASSWORD)
        .ifPresentOrElse(
            existing -> existing.replaceSecret(hash, clock.instant()),
            () ->
                credentials.persist(
                    UserCredential.of(user, CredentialType.PASSWORD, hash, clock.instant())));
  }

  /**
   * False for someone who has no password at all, which is the ordinary case.
   * Answering differently would say which accounts administer something.
   */
  public boolean verify(UUID userId, String password) {
    Optional<UserCredential> credential = credentials.find(userId, CredentialType.PASSWORD);
    if (credential.isEmpty() || password == null) {
      return false;
    }
    return BcryptUtil.matches(password, credential.get().secretHash());
  }

  public boolean has(UUID userId) {
    return credentials.find(userId, CredentialType.PASSWORD).isPresent();
  }
}
