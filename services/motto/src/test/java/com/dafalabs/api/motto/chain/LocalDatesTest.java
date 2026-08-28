package com.dafalabs.api.motto.chain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.dafalabs.api.core.error.CustomRuntimeException;
import java.time.LocalDate;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class LocalDatesTest {

  @Test
  @DisplayName("a plain day is read as one")
  void readsADay() {
    assertEquals(LocalDate.of(2026, 8, 28), LocalDates.parse("2026-08-28"));
  }

  @Test
  @DisplayName("an instant is refused rather than silently shifted")
  void refusesAnInstant() {
    // The generated client sent `toUtc().toIso8601String()` here, which the
    // server could not parse and which had already moved the day for anyone
    // east of UTC. Refusing it is what made that visible.
    assertEquals(
        "invalid_date",
        assertThrows(
                CustomRuntimeException.class,
                () -> LocalDates.parse("2026-08-27T21:00:00.000Z"))
            .code());
  }

  @Test
  @DisplayName("a missing date is its own answer")
  void refusesNothing() {
    assertEquals(
        "missing_date",
        assertThrows(CustomRuntimeException.class, () -> LocalDates.parse(null)).code());
    assertEquals(
        "missing_date",
        assertThrows(CustomRuntimeException.class, () -> LocalDates.parse("  ")).code());
  }
}
