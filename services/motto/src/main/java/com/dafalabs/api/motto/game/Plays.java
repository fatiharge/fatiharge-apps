package com.dafalabs.api.motto.game;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.game.dto.PlayCredits;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Turns at the game, and the only place they are counted.
 *
 * <p>A turn belongs to the day that paid for it. Nothing carries over: the
 * point is that today's work buys today's game, and a balance somebody has
 * been saving for a fortnight says the opposite.
 */
@ApplicationScoped
public class Plays {

  private final PlayCreditRepository credits;
  private final PlayRepository plays;

  Plays(PlayCreditRepository credits, PlayRepository plays) {
    this.credits = credits;
    this.plays = plays;
  }

  /**
   * Records that something worth turns was done.
   *
   * <p>Called from where the thing actually happened rather than from the app:
   * a client that can say "I earned three turns" is a client that will.
   */
  @Transactional
  public void grant(UUID deviceId, LocalDate day, CreditReason reason) {
    if (credits.findById(new PlayCredit.Key(deviceId, day, reason)) != null) {
      return;
    }
    credits.persist(PlayCredit.of(deviceId, day, reason));
  }

  @Transactional
  public PlayCredits on(UUID deviceId, LocalDate day) {
    List<PlayCredit> earned = credits.forDay(deviceId, day);
    int turns = earned.stream().mapToInt(credit -> credit.reason().turns()).sum();
    int spent = (int) plays.countForDay(deviceId, day);

    return new PlayCredits(
        Math.max(turns - spent, 0),
        turns,
        spent,
        earned.stream().anyMatch(credit -> credit.reason() == CreditReason.MARKED_DAY),
        earned.stream().anyMatch(credit -> credit.reason() == CreditReason.TASKS_DONE));
  }

  /**
   * Spends one, and refuses when there is none.
   *
   * <p>Spent before the game rather than after it: a turn only taken when a
   * score arrives is a turn somebody keeps by closing the app on a bad round.
   */
  @Transactional
  public PlayCredits spend(UUID deviceId, LocalDate day) {
    if (on(deviceId, day).remaining() <= 0) {
      throw new CustomRuntimeException(409, "no_turns_left", "There is no turn to spend.");
    }
    plays.persist(Play.of(deviceId, day));
    return on(deviceId, day);
  }
}
