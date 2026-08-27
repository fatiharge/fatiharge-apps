package com.dafalabs.api.motto.entitlement;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/**
 * What one device is still allowed to do.
 *
 * <p>The row outlives the data it belongs to. Deleting everything else and
 * keeping this is the difference between a privacy feature and a way to get the
 * free uses back.
 */
@Entity
@Table(name = "entitlements")
public class Entitlement {

  @Id
  @Column(name = "device_id", updatable = false)
  private UUID deviceId;

  @Column(name = "used_count", nullable = false)
  private int usedCount;

  @Column(name = "last_claim_at")
  private Instant lastClaimAt;

  @Column(name = "skips_left", nullable = false)
  private int skipsLeft;

  @Column(name = "purchased_at")
  private Instant purchasedAt;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  protected Entitlement() {
    // for Hibernate
  }

  static Entitlement forDevice(UUID deviceId, int skipsAtStart, Instant now) {
    Entitlement fresh = new Entitlement();
    fresh.deviceId = deviceId;
    fresh.usedCount = 0;
    fresh.skipsLeft = skipsAtStart;
    fresh.createdAt = now;
    return fresh;
  }

  public UUID deviceId() {
    return deviceId;
  }

  public int usedCount() {
    return usedCount;
  }

  public Instant lastClaimAt() {
    return lastClaimAt;
  }

  public int skipsLeft() {
    return skipsLeft;
  }

  public boolean isPremium() {
    return purchasedAt != null;
  }

  void recordClaim(Instant now) {
    usedCount++;
    lastClaimAt = now;
  }

  void spendSkip() {
    if (skipsLeft <= 0) {
      throw new IllegalStateException("no skip to spend");
    }
    skipsLeft--;
  }
}
