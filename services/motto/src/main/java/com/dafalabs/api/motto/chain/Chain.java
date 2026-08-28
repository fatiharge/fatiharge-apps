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

  @Column(name = "started_on", nullable = false)
  private LocalDate startedOn;

  @Column(name = "freeze_used_on")
  private LocalDate freezeUsedOn;

  /// Which run this is. One until somebody finishes fourteen days.
  @Column(nullable = false)
  private short period = 1;

  /// The motto this period is under; null means the archetype's first.
  @Column(name = "motto_id")
  private String mottoId;

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

  public short period() {
    return period;
  }

  public String mottoId() {
    return mottoId;
  }

  /// A finished period does not end the chain, it starts the next one: the
  /// days already marked keep their number and stay readable.
  void beginNextPeriod(LocalDate today, String motto) {
    period = (short) (period + 1);
    startedOn = today;
    mottoId = motto;
    freezeUsedOn = null;
  }
}
