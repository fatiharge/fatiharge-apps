package com.dafalabs.api.auth.otp;

import com.dafalabs.api.auth.identity.IdentityType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/**
 * One attempt to prove that whoever asked can read a particular address.
 *
 * <p>Holds no user. A code is asked for before there is an account, and creating
 * one for every address someone mistyped would fill the table with people who
 * never existed.
 */
@Entity
@Table(name = "otp_challenges")
public class OtpChallenge {

  @Id private UUID id;

  @Column(name = "tenant_id", nullable = false, updatable = false)
  private UUID tenantId;

  @Enumerated(EnumType.STRING)
  @Column(name = "identity_type", nullable = false, updatable = false)
  private IdentityType identityType;

  @Column(name = "identity_value", nullable = false, updatable = false)
  private String identityValue;

  @Column(name = "code_hash", nullable = false, updatable = false)
  private String codeHash;

  @Enumerated(EnumType.STRING)
  @Column(nullable = false)
  private OtpStatus status;

  @Column(nullable = false)
  private int attempts;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  @Column(name = "expires_at", nullable = false, updatable = false)
  private Instant expiresAt;

  @Column(name = "verified_at")
  private Instant verifiedAt;

  @Column(name = "consumed_at")
  private Instant consumedAt;

  protected OtpChallenge() {
    // for Hibernate
  }

  static OtpChallenge issue(
      UUID tenantId, IdentityType type, String value, String code, Instant now, Instant expiresAt) {
    OtpChallenge challenge = new OtpChallenge();
    challenge.id = UUID.randomUUID();
    challenge.tenantId = tenantId;
    challenge.identityType = type;
    challenge.identityValue = value;
    challenge.codeHash = OtpCodes.hash(challenge.id, code);
    challenge.status = OtpStatus.PENDING;
    challenge.attempts = 0;
    challenge.createdAt = now;
    challenge.expiresAt = expiresAt;
    return challenge;
  }

  /**
   * Returns whether the code was right, and records the attempt either way.
   *
   * <p>Expiry is checked here rather than by a sweeper: a row that nobody looks
   * at again does not need to be told it is dead, and a sweeper that falls
   * behind would let an expired code work.
   */
  boolean answer(String code, Instant now, int maxAttempts) {
    if (status != OtpStatus.PENDING) {
      return false;
    }
    if (now.isAfter(expiresAt)) {
      status = OtpStatus.EXPIRED;
      return false;
    }

    attempts++;
    if (OtpCodes.matches(id, code, codeHash)) {
      status = OtpStatus.VERIFIED;
      verifiedAt = now;
      return true;
    }

    // The cap is on this challenge, not on the address: blocking the address
    // would let anyone lock anyone else out by guessing badly on purpose.
    if (attempts >= maxAttempts) {
      status = OtpStatus.BLOCKED;
    }
    return false;
  }

  /**
   * Marks the challenge answered without checking the code.
   *
   * <p>The only caller is guarded by {@link OtpOverride}, whose accepting
   * implementation is not compiled into the packaged application. The method is
   * named so that a second caller would have to be written on purpose.
   */
  boolean acceptWithoutCheckingTheCode(Instant now) {
    if (status != OtpStatus.PENDING || now.isAfter(expiresAt)) {
      return false;
    }
    attempts++;
    status = OtpStatus.VERIFIED;
    verifiedAt = now;
    return true;
  }

  /** Spends a verified challenge. Verifying twice is fine; spending twice is not. */
  boolean consume(Instant now) {
    if (status != OtpStatus.VERIFIED) {
      return false;
    }
    status = OtpStatus.CONSUMED;
    consumedAt = now;
    return true;
  }

  public UUID id() {
    return id;
  }

  public UUID tenantId() {
    return tenantId;
  }

  public IdentityType identityType() {
    return identityType;
  }

  public String identityValue() {
    return identityValue;
  }

  public OtpStatus status() {
    return status;
  }

  public int attempts() {
    return attempts;
  }

  public Instant expiresAt() {
    return expiresAt;
  }
}
