package com.dafalabs.api.motto.game;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.entitlement.Entitlements;
import com.dafalabs.api.motto.game.dto.Leaderboard;
import com.dafalabs.api.motto.game.dto.LeaderboardEntry;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/** The game's scores, and what the week's best win. */
@ApplicationScoped
public class Scores {

  /// The top ten of a week get a deep report each.
  public static final int rewardedRanks = 10;

  /// What the game cannot plausibly produce. No replay validation beyond this:
  /// the prize is handed out once a week and is worth less than the work of
  /// proving a score — that decision is in the record.
  static final int impossiblePoints = 10_000;

  private final ScoreRepository scores;
  private final ScoreRewardRepository rewards;
  private final Entitlements entitlements;
  private final Clock clock;

  Scores(
      ScoreRepository scores,
      ScoreRewardRepository rewards,
      Entitlements entitlements,
      Clock clock) {
    this.scores = scores;
    this.rewards = rewards;
    this.entitlements = entitlements;
    this.clock = clock;
  }

  /** The Monday a moment belongs to. */
  public static LocalDate weekOf(LocalDate day) {
    return day.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
  }

  @Transactional
  public Leaderboard record(UUID deviceId, int points) {
    if (points < 0 || points > impossiblePoints) {
      throw new CustomRuntimeException(400, "impossible_score", "That is not a score.");
    }

    LocalDate week = currentWeek();
    scores.persist(Score.of(deviceId, points, week));
    return leaderboard(deviceId);
  }

  @Transactional
  public Leaderboard leaderboard(UUID deviceId) {
    LocalDate week = currentWeek();
    List<Score> best = scores.bestOfWeek(week, rewardedRanks);

    List<LeaderboardEntry> entries = new ArrayList<>();
    for (int index = 0; index < best.size(); index++) {
      Score score = best.get(index);
      entries.add(
          new LeaderboardEntry(
              index + 1, score.points(), score.deviceId().equals(deviceId)));
    }

    Score mine = scores.bestFor(deviceId, week);
    return new Leaderboard(week, entries, mine == null ? 0 : mine.points(), rewardedRanks);
  }

  /**
   * Hands the finished week's top ten their report.
   *
   * <p>Recorded per week and skipped when it is already there: a job that runs
   * twice — a redeploy, a retry — must not pay twice.
   *
   * @return how many were granted, zero when the week was already settled
   */
  @Transactional
  public int awardWeek(LocalDate week) {
    if (rewards.findById(week) != null) {
      return 0;
    }

    List<Score> winners = scores.bestOfWeek(week, rewardedRanks);
    for (Score winner : winners) {
      entitlements.grantPremium(winner.deviceId());
    }
    rewards.persist(ScoreReward.of(week, winners.size()));
    return winners.size();
  }

  private LocalDate currentWeek() {
    return weekOf(LocalDate.now(clock.withZone(ZoneOffset.UTC)));
  }
}
