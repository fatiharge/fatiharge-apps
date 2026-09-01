package com.dafalabs.api.auth.delivery;

import com.dafalabs.api.auth.identity.IdentityType;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.Clock;
import java.util.Map;
import java.util.UUID;

/**
 * Writes the message down and returns.
 *
 * <p>The only implementation there is. When a provider is chosen, it reads this
 * table; nothing that calls {@link MessageDelivery} changes.
 */
@ApplicationScoped
public class OutboxDelivery implements MessageDelivery {

  private final OutboxRepository outbox;
  private final ObjectMapper json;
  private final Clock clock;

  OutboxDelivery(OutboxRepository outbox, ObjectMapper json, Clock clock) {
    this.outbox = outbox;
    this.json = json;
    this.clock = clock;
  }

  /**
   * Joins the caller's transaction rather than starting its own: a code that was
   * never issued must not leave a message behind saying it was.
   */
  @Override
  public void deliver(
      UUID tenantId,
      IdentityType channel,
      String recipient,
      String template,
      Map<String, String> variables) {
    outbox.persist(
        OutboxMessage.pending(
            tenantId, channel, recipient, template, serialise(variables), clock.instant()));
  }

  private String serialise(Map<String, String> variables) {
    try {
      return json.writeValueAsString(variables);
    } catch (JsonProcessingException e) {
      throw new IllegalArgumentException("message variables must be serialisable", e);
    }
  }
}
