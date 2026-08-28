package com.dafalabs.api.motto.game;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.game.dto.Leaderboard;
import com.dafalabs.api.motto.game.dto.ScoreSubmission;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * The week's scores.
 *
 * <p>One region for now, managed from here rather than from the app: splitting
 * by where somebody is turned out to be a decision nobody had made, and it is
 * recorded as v2 work.
 */
@Path("/v1/scores")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class ScoreResource {

  private final Scores scores;
  private final AuthenticatedDevice current;

  ScoreResource(Scores scores, AuthenticatedDevice current) {
    this.scores = scores;
    this.current = current;
  }

  @POST
  @Operation(operationId = "recordScore", summary = "Record a game and get the board")
  public Leaderboard record(ScoreSubmission submission) {
    return scores.record(current.id(), submission.points());
  }

  @GET
  @Operation(operationId = "leaderboard", summary = "This week's board")
  public Leaderboard board() {
    return scores.leaderboard(current.id());
  }
}
