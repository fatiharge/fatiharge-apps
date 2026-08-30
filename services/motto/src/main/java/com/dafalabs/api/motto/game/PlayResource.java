package com.dafalabs.api.motto.game;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.chain.LocalDates;
import com.dafalabs.api.motto.game.dto.PlayCredits;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * Turns at the game.
 *
 * <p>The phone's local date is carried the way the chain carries it: a day is
 * only ever a local day, and turns belong to one.
 */
@Path("/v1/game/turns")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class PlayResource {

  private final Plays plays;
  private final AuthenticatedDevice current;

  PlayResource(Plays plays, AuthenticatedDevice current) {
    this.plays = plays;
    this.current = current;
  }

  @GET
  @Operation(operationId = "gameTurns", summary = "What today has paid for")
  public PlayCredits turns(@QueryParam("today") String today) {
    return plays.on(current.id(), LocalDates.parse(today));
  }

  @POST
  @Operation(operationId = "spendGameTurn", summary = "Spend a turn to start a game")
  public PlayCredits spend(@QueryParam("today") String today) {
    return plays.spend(current.id(), LocalDates.parse(today));
  }
}
