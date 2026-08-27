package com.dafalabs.api.motto.feedback;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.feedback.dto.FeedbackRequest;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * The only way anyone can say anything to us.
 *
 * <p>With no accounts and no support inbox, a complaint with nowhere to go goes
 * to the store review instead — and a one-star review cannot be answered with a
 * fix. First-party rather than a third-party form, so it costs nothing and the
 * answers sit beside everything they would be read against.
 */
@Path("/v1/feedback")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class FeedbackResource {

  private final Feedbacks feedbacks;
  private final AuthenticatedDevice current;

  FeedbackResource(Feedbacks feedbacks, AuthenticatedDevice current) {
    this.feedbacks = feedbacks;
    this.current = current;
  }

  @POST
  @Operation(operationId = "submitFeedback", summary = "Send feedback")
  public Response submit(FeedbackRequest request) {
    feedbacks.submit(current.id(), request);
    return Response.noContent().build();
  }
}
