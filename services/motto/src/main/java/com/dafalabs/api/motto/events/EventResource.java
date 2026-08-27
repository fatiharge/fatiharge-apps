package com.dafalabs.api.motto.events;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.events.dto.EventBatch;
import com.dafalabs.api.motto.events.dto.EventBatchResponse;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * Where the app reports what happened. First-party: eighteen names fit in one
 * table, and the answers stay beside everything they would be compared against.
 */
@Path("/v1/events")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class EventResource {

  private final Events events;
  private final AuthenticatedDevice current;

  EventResource(Events events, AuthenticatedDevice current) {
    this.events = events;
    this.current = current;
  }

  @POST
  @Operation(operationId = "recordEvents", summary = "Report what happened")
  public EventBatchResponse record(EventBatch batch) {
    Events.Stored stored = events.record(current.id(), batch.events());
    return new EventBatchResponse(stored.accepted(), stored.duplicates());
  }
}
