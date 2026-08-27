package com.dafalabs.api.motto.chain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class ChainRulesTest {

  private static LocalDate day(int of) {
    return LocalDate.of(2026, 3, of);
  }

  private static Set<LocalDate> marked(int... days) {
    return IntStream.of(days).mapToObj(ChainRulesTest::day).collect(Collectors.toSet());
  }

  @Test
  @DisplayName("an unmarked today does not end the streak")
  void anOpenTodayIsNotALoss() {
    assertEquals(3, ChainRules.streakOn(marked(1, 2, 3), day(4)));
  }

  @Test
  @DisplayName("a whole day gone does")
  void aWholeDayGoneEndsIt() {
    assertEquals(0, ChainRules.streakOn(marked(1, 2, 3), day(5)));
    assertTrue(ChainRules.isBrokenOn(marked(1, 2, 3), day(5)));
  }

  @Test
  @DisplayName("only the run ending now counts, not the longest one ever")
  void onlyTheCurrentRunCounts() {
    assertEquals(2, ChainRules.streakOn(marked(1, 2, 3, 8, 9), day(9)));
  }

  @Test
  @DisplayName("the make-up covers one missed day and not two")
  void theMakeUpCoversOneDay() {
    assertTrue(ChainRules.canFreezeOn(marked(1, 2), null, day(4)));
    assertFalse(ChainRules.canFreezeOn(marked(1, 2), null, day(5)));
  }

  @Test
  @DisplayName("the make-up is spent once a calendar month")
  void theMakeUpIsMonthly() {
    assertFalse(ChainRules.canFreezeOn(marked(1, 2), day(4), day(6)));
    assertTrue(ChainRules.freezeSpentIn(day(4), day(20)));
    assertFalse(ChainRules.freezeSpentIn(day(4), LocalDate.of(2026, 4, 1)));
  }

  @Test
  @DisplayName("a chain with nothing marked has no streak and is not broken")
  void anEmptyChainIsNotBroken() {
    assertEquals(0, ChainRules.streakOn(Set.of(), day(4)));
    assertFalse(ChainRules.isBrokenOn(Set.of(), day(4)));
  }
}
