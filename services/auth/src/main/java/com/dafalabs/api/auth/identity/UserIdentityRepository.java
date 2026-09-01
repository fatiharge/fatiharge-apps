package com.dafalabs.api.auth.identity;

import io.quarkus.hibernate.orm.panache.PanacheRepositoryBase;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class UserIdentityRepository implements PanacheRepositoryBase<UserIdentity, UUID> {

  /**
   * The tenant is part of the lookup, never an afterthought applied later. A
   * query that found an identity first and checked the tenant afterwards would
   * be one forgotten line away from signing someone into another club.
   */
  public Optional<UserIdentity> find(UUID tenantId, IdentityType type, String value) {
    return find(
            "tenantId = ?1 and type = ?2 and value = ?3",
            tenantId,
            type,
            UserIdentity.normalise(value))
        .firstResultOptional();
  }
}
