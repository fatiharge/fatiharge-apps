package com.dafalabs.api.auth.identity;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class UserCredentialRepository implements PanacheRepositoryBase<UserCredential, UUID> {

  public Optional<UserCredential> find(UUID userId, CredentialType type) {
    return find("userId = ?1 and type = ?2", userId, type).firstResultOptional();
  }
}
