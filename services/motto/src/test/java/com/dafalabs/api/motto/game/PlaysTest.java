package com.dafalabs.api.motto.game;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.game.dto.PlayCredits;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.LocalDate;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class PlaysTest {

  private static final LocalDate TODAY = LocalDate.of(2026, 3, 11);

  @Inject Plays plays;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
  }

  @Test
  @DisplayName("a day nobody has worked owes nothing")
  void nothingEarnedYet() {
    PlayCredits credits = plays.on(device, TODAY);

    assertEquals(0, credits.remaining());
    assertFalse(credits.dayMarked());
    assertFalse(credits.tasksDone());
  }

  @Test
  @DisplayName("marking the day is worth one, finishing the three is worth three")
  void theDayPaysForTurns() {
    plays.grant(device, TODAY, CreditReason.MARKED_DAY);
    assertEquals(1, plays.on(device, TODAY).remaining());

    plays.grant(device, TODAY, CreditReason.TASKS_DONE);
    PlayCredits credits = plays.on(device, TODAY);

    assertEquals(4, credits.remaining());
    assertTrue(credits.dayMarked());
    assertTrue(credits.tasksDone());
  }

  @Test
  @DisplayName("earning the same thing twice on one day earns it once")
  void grantingIsIdempotent() {
    plays.grant(device, TODAY, CreditReason.MARKED_DAY);
    plays.grant(device, TODAY, CreditReason.MARKED_DAY);

    // The offline queue sends a marked day more than once as a matter of
    // course, and a double tap sends the third task twice.
    assertEquals(1, plays.on(device, TODAY).earned());
  }

  @Test
  @DisplayName("spending takes one and refuses when there is none")
  void spendingIsCounted() {
    plays.grant(device, TODAY, CreditReason.MARKED_DAY);

    assertEquals(0, plays.spend(device, TODAY).remaining());

    CustomRuntimeException refused =
        assertThrows(CustomRuntimeException.class, () -> plays.spend(device, TODAY));
    assertEquals(409, refused.status());
    assertEquals("no_turns_left", refused.code());
  }

  @Test
  @DisplayName("turns do not carry over to the next day")
  void nothingCarriesOver() {
    plays.grant(device, TODAY, CreditReason.TASKS_DONE);

    // Today's work buys today's game. A balance somebody saved for a fortnight
    // says the opposite of what the game is for.
    assertEquals(3, plays.on(device, TODAY).remaining());
    assertEquals(0, plays.on(device, TODAY.plusDays(1)).remaining());
  }

  @Test
  @DisplayName("one device's turns are not another's")
  void turnsBelongToADevice() {
    plays.grant(device, TODAY, CreditReason.MARKED_DAY);

    assertEquals(0, plays.on(UUID.randomUUID(), TODAY).remaining());
  }
}
