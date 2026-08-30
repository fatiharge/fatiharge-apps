package com.dafalabs.api.motto.game;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.util.UUID;

/** One turn spent. */
@Entity
@Table(name = "game_plays")
public class Play {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @Column(name = "device_id", nullable = false, updatable = false)
  private UUID deviceId;

  @Column(nullable = false, updatable = false)
  private LocalDate day;

  protected Play() {}

  static Play of(UUID deviceId, LocalDate day) {
    Play play = new Play();
    play.deviceId = deviceId;
    play.day = day;
    return play;
  }
}
