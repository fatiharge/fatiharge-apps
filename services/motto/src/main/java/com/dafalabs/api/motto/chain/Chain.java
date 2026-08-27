package com.dafalabs.api.motto.chain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "chains")
public class Chain {

  @Id
  @Column(name = "device_id", updatable = false)
  private UUID deviceId;

  @Column(name = "started_on", nullable = false, updatable = false)
  private LocalDate startedOn;

  @Column(name = "freeze_used_on")
  private LocalDate freezeUsedOn;

  protected Chain() {}

  static Chain startedBy(UUID deviceId, LocalDate today) {
    Chain chain = new Chain();
    chain.deviceId = deviceId;
    chain.startedOn = today;
    return chain;
  }

  public UUID deviceId() {
    return deviceId;
  }

  public LocalDate startedOn() {
    return startedOn;
  }

  public LocalDate freezeUsedOn() {
    return freezeUsedOn;
  }

  void spendFreeze(LocalDate today) {
    freezeUsedOn = today;
  }
}
