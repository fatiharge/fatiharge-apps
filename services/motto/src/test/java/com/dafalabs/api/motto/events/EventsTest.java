package com.dafalabs.api.motto.events;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.events.dto.EventEntry;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class EventsTest {

  @Inject Events events;

  private static EventEntry entry(String name, String clientId) {
    return new EventEntry(clientId, name, Instant.parse("2026-01-01T09:00:00Z"), Map.of());
  }

  @Test
  @DisplayName("a batch is stored once")
  void storesABatch() {
    var stored =
        events.record(
            UUID.randomUUID(),
            List.of(
                entry("share_complete", UUID.randomUUID().toString()),
                entry("result_view", UUID.randomUUID().toString())));

    assertEquals(2, stored.accepted());
    assertEquals(0, stored.duplicates());
  }

  @Test
  @DisplayName("the same event twice is counted once, and the rest still land")
  void ignoresADuplicateWithoutLosingTheBatch() {
    var device = UUID.randomUUID();
    var repeated = UUID.randomUUID().toString();
    events.record(device, List.of(entry("share_complete", repeated)));

    // A retry after a timeout that actually landed would otherwise inflate the
    // exact number this exists to measure.
    var stored =
        events.record(
            device,
            List.of(
                entry("share_complete", repeated),
                entry("result_view", UUID.randomUUID().toString())));

    assertEquals(1, stored.accepted());
    assertEquals(1, stored.duplicates());
  }

  @Test
  @DisplayName("an empty batch is refused rather than silently accepted")
  void refusesAnEmptyBatch() {
    var refused =
        assertThrows(
            CustomRuntimeException.class, () -> events.record(UUID.randomUUID(), List.of()));

    assertEquals("no_events", refused.code());
  }

  @Test
  @DisplayName("one request cannot be used to fill the table")
  void refusesAnOversizedBatch() {
    var entries = new ArrayList<EventEntry>();
    for (int i = 0; i <= Events.maxBatch; i++) {
      entries.add(entry("app_open", UUID.randomUUID().toString()));
    }

    var refused =
        assertThrows(
            CustomRuntimeException.class, () -> events.record(UUID.randomUUID(), entries));

    assertEquals("batch_too_large", refused.code());
  }

  @Test
  @DisplayName("a client id that is not a UUID is refused by its own code")
  void refusesAMalformedClientId() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () -> events.record(UUID.randomUUID(), List.of(entry("app_open", "nope"))));

    assertEquals("invalid_client_id", refused.code());
  }
}
