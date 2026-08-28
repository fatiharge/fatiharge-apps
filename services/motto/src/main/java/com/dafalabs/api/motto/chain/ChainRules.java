package com.dafalabs.api.motto.chain;

import java.time.LocalDate;
import java.util.Set;

/**
 * What a streak is, decided without a database.
 *
 * <p>Pure so the rules can be argued with in a test rather than on a phone that
 * has to wait a day to disagree.
 */
public abstract sealed class ChainRules permits ChainRules.None {

  private ChainRules() {}

  /**
   * Consecutive days ending today, or ending yesterday while today is still
   * open. A streak does not break at midnight; it breaks when a whole day goes
   * by unmarked.
   */
  /// A period is fourteen marked days. The same fourteen as the content
  /// cycle, the cooldown and everything else here: this is the length of the
  /// thing being sold.
  public static final int periodDays = 14;

  public static boolean periodDone(int markedInPeriod) {
    return markedInPeriod >= periodDays;
  }

  public static int streakOn(Set<LocalDate> marked, LocalDate today) {
    if (marked.isEmpty()) {
      return 0;
    }

    LocalDate cursor = marked.contains(today) ? today : today.minusDays(1);
    int length = 0;
    while (marked.contains(cursor)) {
      length++;
      cursor = cursor.minusDays(1);
    }
    return length;
  }

  /** Whole days missed before today. Today is not missed until it ends. */
  public static long missedBefore(Set<LocalDate> marked, LocalDate today) {
    return marked.stream()
        .max(LocalDate::compareTo)
        .map(last -> Math.max(0, today.toEpochDay() - last.toEpochDay() - 1))
        .orElse(0L);
  }

  public static boolean isBrokenOn(Set<LocalDate> marked, LocalDate today) {
    return missedBefore(marked, today) > 0;
  }

  /**
   * The make-up covers a single missed day. Two days gone is not a slip, and
   * covering it would make the streak mean nothing.
   */
  public static boolean canFreezeOn(
      Set<LocalDate> marked, LocalDate freezeUsedOn, LocalDate today) {
    return missedBefore(marked, today) == 1 && !freezeSpentIn(freezeUsedOn, today);
  }

  /** Calendar month, so the month it renews in is predictable. */
  public static boolean freezeSpentIn(LocalDate freezeUsedOn, LocalDate today) {
    return freezeUsedOn != null
        && freezeUsedOn.getYear() == today.getYear()
        && freezeUsedOn.getMonth() == today.getMonth();
  }

  /** Never instantiated; the sealed permit exists only to keep it that way. */
  static final class None extends ChainRules {}
}
