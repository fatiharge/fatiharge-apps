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
 * How someone proves an identity they hold.
 *
 * <p>Optional by design: a fan signs in with a one-time code and never has a row
 * here, while a club employee is required to have one. That difference cannot be
 * expressed by a nullable column on {@link User}, which could not tell "no
 * password" from "password not set yet".
 */
@Entity
@Table(name = "user_credentials")
public class UserCredential {

  @Id private UUID id;

  @Column(name = "user_id", nullable = false, updatable = false)
  private UUID userId;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false, updatable = false)
  private CredentialType type;

  /** Never the secret itself. Hashing belongs to the caller, not to this row. */
  @Column(name = "secret_hash", nullable = false)
  private String secretHash;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @Column(name = "updated_at", nullable = false)
  private Instant updatedAt;

  protected UserCredential() {
    // for Hibernate
  }

  public static UserCredential of(User user, CredentialType type, String secretHash, Instant now) {
    UserCredential credential = new UserCredential();
    credential.id = UUID.randomUUID();
    credential.userId = user.id();
    credential.type = type;
    credential.secretHash = secretHash;
    credential.createdAt = now;
    credential.updatedAt = now;
    return credential;
  }

  public void replaceSecret(String secretHash, Instant now) {
    this.secretHash = secretHash;
    this.updatedAt = now;
  }

  public UUID id() {
    return id;
  }

  public UUID userId() {
    return userId;
  }

  public CredentialType type() {
    return type;
  }

  public String secretHash() {
    return secretHash;
  }

  public Instant updatedAt() {
    return updatedAt;
  }
}
