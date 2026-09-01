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
 * Someone a product recognises across devices.
 *
 * <p>Scoped to a tenant, and the tenant is an opaque id: this service knows that
 * two tenants differ, not who they are. A tenant's name and colours belong to
 * the product that sells to it.
 */
@Entity
@Table(name = "users")
public class User {

  @Id private UUID id;

  @Column(name = "tenant_id", nullable = false, updatable = false)
  private UUID tenantId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private Role role;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private UserStatus status;

  @Column(name = "token_epoch", nullable = false)
  private int tokenEpoch;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  protected User() {
    // for Hibernate
  }

  public static User create(UUID tenantId, Role role, Instant now) {
    User user = new User();
    user.id = UUID.randomUUID();
    user.tenantId = tenantId;
    user.role = role;
    user.status = UserStatus.ACTIVE;
    user.tokenEpoch = 0;
    user.createdAt = now;
    return user;
  }

  /**
   * Invalidates every token already issued to this person, on every device.
   *
   * <p>This is the whole revocation mechanism. A refresh token carries the epoch
   * it was issued under and is refused once it falls behind, so signing someone
   * out everywhere is an increment rather than a hunt through stored tokens.
   */
  public void revokeIssuedTokens() {
    tokenEpoch++;
  }

  public void block() {
    status = UserStatus.BLOCKED;
    revokeIssuedTokens();
  }

  public boolean canSignIn() {
    return status == UserStatus.ACTIVE;
  }

  public UUID id() {
    return id;
  }

  public UUID tenantId() {
    return tenantId;
  }

  public Role role() {
    return role;
  }

  public UserStatus status() {
    return status;
  }

  public int tokenEpoch() {
    return tokenEpoch;
  }

  public Instant createdAt() {
    return createdAt;
  }
}
