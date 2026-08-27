package com.dafalabs.api.motto.events;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.events.dto.EventEntry;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/** Stores what the app reports, once each. */
@ApplicationScoped
public class Events {

  /// Long enough for a phone that was offline for a while, short enough that a
  /// single request cannot be used to fill the table.
  static final int maxBatch = 100;

  private final EventRepository repository;
  private final ObjectMapper json;

  Events(EventRepository repository, ObjectMapper json) {
    this.repository = repository;
    this.json = json;
  }

  /**
   * @return how many were stored and how many had been seen before
   */
  @Transactional
  public Stored record(UUID deviceId, List<EventEntry> entries) {
    if (entries == null || entries.isEmpty()) {
      throw new CustomRuntimeException(400, "no_events", "The batch is empty.");
    }
    if (entries.size() > maxBatch) {
      throw new CustomRuntimeException(
          400, "batch_too_large", "At most %d events per request.".formatted(maxBatch));
    }

    int accepted = 0;
    int duplicates = 0;

    for (EventEntry entry : entries) {
      UUID clientId = parse(entry.clientId());

      // Checked rather than caught: a constraint violation would roll the whole
      // batch back, and one duplicate should not lose the ninety-nine events
      // that arrived with it.
      if (repository.count("clientId", clientId) > 0) {
        duplicates++;
        continue;
      }

      repository.persist(
          Event.of(
              deviceId,
              entry.name(),
              serialise(entry.properties()),
              entry.occurredAt(),
              clientId));
      accepted++;
    }

    return new Stored(accepted, duplicates);
  }

  private UUID parse(String clientId) {
    try {
      return UUID.fromString(clientId);
    } catch (IllegalArgumentException | NullPointerException malformed) {
      throw new CustomRuntimeException(
          400, "invalid_client_id", "clientId must be a UUID.");
    }
  }

  private String serialise(Map<String, String> properties) {
    try {
      return json.writeValueAsString(properties == null ? Map.of() : properties);
    } catch (JsonProcessingException impossible) {
      throw new IllegalStateException(impossible);
    }
  }

  public record Stored(int accepted, int duplicates) {}
}
