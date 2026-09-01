package com.dafalabs.api.auth.identity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/**
 * One way of naming a person: an address, a number.
 *
 * <p>A row rather than a column on {@link User}, so a second identity can be
 * added without a migration and one person can hold both.
 */
@Entity
@Table(name = "user_identities")
public class UserIdentity {

  @Id private UUID id;

  @Column(name = "user_id", nullable = false, updatable = false)
  private UUID userId;

  /** Copied from the user so uniqueness can be scoped to the tenant. */
  @Column(name = "tenant_id", nullable = false, updatable = false)
  private UUID tenantId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  private IdentityType type;

  @Column(name = "identity_value", nullable = false, updatable = false)
  private String value;

  @Column(name = "verified_at")
  private Instant verifiedAt;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  protected UserIdentity() {
    // for Hibernate
  }

  /**
   * Claimed, not proven. Until {@link #verify} the identity cannot be signed in
   * with — otherwise claiming someone else's address would be enough to take it.
   */
  public static UserIdentity claim(User user, IdentityType type, String value, Instant now) {
    UserIdentity identity = new UserIdentity();
    identity.id = UUID.randomUUID();
    identity.userId = user.id();
    identity.tenantId = user.tenantId();
    identity.type = type;
    identity.value = normalise(value);
    identity.createdAt = now;
    return identity;
  }

  /**
   * Compared and stored in one form. Without this the same address arrives as
   * two rows whenever someone capitalises it differently, and the uniqueness
   * index stops meaning anything.
   */
  static String normalise(String value) {
    return value == null ? null : value.trim().toLowerCase();
  }

  public void verify(Instant now) {
    verifiedAt = now;
  }

  public boolean isVerified() {
    return verifiedAt != null;
  }

  public UUID id() {
    return id;
  }

  public UUID userId() {
    return userId;
  }

  public UUID tenantId() {
    return tenantId;
  }

  public IdentityType type() {
    return type;
  }

  public String value() {
    return value;
  }

  public Instant verifiedAt() {
    return verifiedAt;
  }
}
