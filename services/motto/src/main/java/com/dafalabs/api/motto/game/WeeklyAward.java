package com.dafalabs.api.motto.game;

import io.quarkus.scheduler.Scheduled;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;
import org.jboss.logging.Logger;

/**
 * Pays out the week that just ended.
 *
 * <p>Runs early on Monday, after the week it settles is closed. Settling the
 * current week would hand the prize to whoever happened to be ahead on
 * Wednesday.
 */
@ApplicationScoped
public class WeeklyAward {

  private static final Logger LOG = Logger.getLogger(WeeklyAward.class);

  private final Scores scores;
  private final Clock clock;

  WeeklyAward(Scores scores, Clock clock) {
    this.scores = scores;
    this.clock = clock;
  }

  @Scheduled(cron = "0 15 3 ? * MON")
  void award() {
    LocalDate lastWeek =
        Scores.weekOf(LocalDate.now(clock.withZone(ZoneOffset.UTC))).minusWeeks(1);

    int granted = scores.awardWeek(lastWeek);
    // Zero is the normal answer on a rerun, and worth seeing either way: this
    // is the one job whose silence would go unnoticed for a week.
    LOG.infof("week %s: granted %d deep reports", lastWeek, granted);
  }
}
