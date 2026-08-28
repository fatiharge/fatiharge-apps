package com.dafalabs.api.motto.game;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;

/// One row per week that has paid out. A rerun of the job finds it and stops,
/// rather than handing the same ten people a second report each.
@Entity
@Table(name = "score_rewards")
public class ScoreReward {

  @Id private LocalDate week;

  @Column(nullable = false)
  private int awarded;

  protected ScoreReward() {}

  static ScoreReward of(LocalDate week, int awarded) {
    ScoreReward reward = new ScoreReward();
    reward.week = week;
    reward.awarded = awarded;
    return reward;
  }

  public int awarded() {
    return awarded;
  }
}
