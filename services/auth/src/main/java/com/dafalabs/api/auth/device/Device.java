package com.dafalabs.api.auth.device;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

/**
 * One installation of one app on one phone.
 *
 * <p>The identifier is generated here rather than by the database so that a
 * device has an id before it has a row, and so that ids carry no ordering: a
 * sequential id would tell anyone holding one how many users exist.
 */
@Entity
@Table(name = "devices")
public class Device {

  @Id private UUID id;

  @Column(name = "device_hash", nullable = false, updatable = false)
  private String deviceHash;

  @Column(nullable = false)
  private String platform;

  @Column(name = "created_at", nullable = false, updatable = false)
  private Instant createdAt;

  protected Device() {
    // for Hibernate
  }

  public static Device register(String deviceHash, String platform, Instant now) {
    Device device = new Device();
    device.id = UUID.randomUUID();
    device.deviceHash = deviceHash;
    device.platform = platform;
    device.createdAt = now;
    return device;
  }

  public UUID id() {
    return id;
  }

  public String deviceHash() {
    return deviceHash;
  }

  public String platform() {
    return platform;
  }

  public Instant createdAt() {
    return createdAt;
  }
}
