package com.dafalabs.api.motto.chain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

import com.dafalabs.api.motto.chain.dto.ChainHistory;
import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ChainHistoryTest {

  private static final LocalDate TODAY = LocalDate.of(2026, 3, 11);

  @Inject Chains chains;
  @InjectMock Clock clock;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    when(clock.instant()).thenReturn(TODAY.atStartOfDay(ZoneOffset.UTC).toInstant());
    when(clock.getZone()).thenReturn(ZoneOffset.UTC);
  }

  @Test
  @DisplayName("a device that has done nothing has no runs")
  void nothingYet() {
    assertTrue(chains.history(device).periods().isEmpty());
  }

  @Test
  @DisplayName("the days come back in order, which is what says which day they were")
  void daysAreOrdered() {
    chains.start(device, TODAY.minusDays(2));
    chains.mark(device, TODAY.minusDays(1), TODAY);
    chains.mark(device, TODAY.minusDays(2), TODAY);

    ChainHistory history = chains.history(device);

    assertEquals(1, history.periods().size());
    // The app reads the position as the day of the fourteen, so out of order
    // would hand somebody the wrong text for the day they are looking at.
    assertEquals(
        TODAY.minusDays(2), history.periods().getFirst().days().getFirst().day());
    assertEquals(2, history.periods().getFirst().days().size());
    assertTrue(history.periods().getFirst().current());
  }

  @Test
  @DisplayName("a finished run keeps its days under its own number")
  void finishedRunsStay() {
    chains.start(device, TODAY.minusDays(1));
    chains.mark(device, TODAY.minusDays(1), TODAY);
    chains.nextPeriod(device, null, TODAY);
    chains.mark(device, TODAY, TODAY);

    ChainHistory history = chains.history(device);

    assertEquals(2, history.periods().size());
    assertFalse(history.periods().getFirst().current());
    assertTrue(history.periods().getLast().current());
  }
}
