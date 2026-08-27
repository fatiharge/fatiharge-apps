package com.dafalabs.api.motto.chain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "chain_days")
@IdClass(ChainDay.Key.class)
public class ChainDay {

  @Id
  @Column(name = "device_id", updatable = false)
  private UUID deviceId;

  @Id
  @Column(updatable = false)
  private LocalDate day;

  /// True when the make-up covered the day rather than someone marking it. The
  /// streak counts both; the report should be able to tell them apart.
  @Column(name = "made_up", nullable = false, updatable = false)
  private boolean madeUp;

  protected ChainDay() {}

  static ChainDay of(UUID deviceId, LocalDate day, boolean madeUp) {
    ChainDay marked = new ChainDay();
    marked.deviceId = deviceId;
    marked.day = day;
    marked.madeUp = madeUp;
    return marked;
  }

  public LocalDate day() {
    return day;
  }

  public boolean madeUp() {
    return madeUp;
  }

  public record Key(UUID deviceId, LocalDate day) implements Serializable {
    public Key() {
      this(null, null);
    }
  }
}
