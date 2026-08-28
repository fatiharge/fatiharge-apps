package com.dafalabs.api.motto.game;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "scores")
public class Score {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "device_id", nullable = false, updatable = false)
  private UUID deviceId;

  @Column(nullable = false, updatable = false)
  private int points;

  @Column(nullable = false, updatable = false)
  private LocalDate week;

  protected Score() {}

  static Score of(UUID deviceId, int points, LocalDate week) {
    Score score = new Score();
    score.deviceId = deviceId;
    score.points = points;
    score.week = week;
    return score;
  }

  public UUID deviceId() {
    return deviceId;
  }

  public int points() {
    return points;
  }
}
