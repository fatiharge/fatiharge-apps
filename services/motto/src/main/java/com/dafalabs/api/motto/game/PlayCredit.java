package com.dafalabs.api.motto.game;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.UUID;

/** One thing done on one day that paid for turns at the game. */
@Entity
@Table(name = "game_credits")
@IdClass(PlayCredit.Key.class)
public class PlayCredit {

  @Id
  @Column(name = "device_id", updatable = false)
  private UUID deviceId;

  @Id
  @Column(updatable = false)
  private LocalDate day;

  @Id
  @Enumerated(EnumType.STRING)
  @Column(updatable = false)
  private CreditReason reason;

  protected PlayCredit() {}

  static PlayCredit of(UUID deviceId, LocalDate day, CreditReason reason) {
    PlayCredit credit = new PlayCredit();
    credit.deviceId = deviceId;
    credit.day = day;
    credit.reason = reason;
    return credit;
  }

  public CreditReason reason() {
    return reason;
  }

  public record Key(UUID deviceId, LocalDate day, CreditReason reason) implements Serializable {
    public Key() {
      this(null, null, null);
    }
  }
}
