package com.dafalabs.api.motto.chain;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.chain.dto.ChainState;
import com.dafalabs.api.motto.chain.dto.MarkDayRequest;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import java.time.LocalDate;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * The chain lives here now, not on the phone.
 *
 * <p>Every call carries the phone's local date. The server's UTC date is the
 * wrong day for most of the world for part of every day, and a streak is only
 * ever measured in local days.
 */
@Path("/v1/chain")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class ChainResource {

  private final Chains chains;
  private final AuthenticatedDevice current;

  ChainResource(Chains chains, AuthenticatedDevice current) {
    this.chains = chains;
    this.current = current;
  }

  @GET
  @Operation(operationId = "currentChain", summary = "The chain as it stands")
  public ChainState current(@QueryParam("today") LocalDate today) {
    return chains.state(current.id(), today);
  }

  @POST
  @Path("/start")
  @Operation(operationId = "startChain", summary = "Start the chain and mark today")
  public ChainState start(MarkDayRequest request) {
    return chains.start(current.id(), request.day());
  }

  @POST
  @Path("/days")
  @Operation(operationId = "markChainDay", summary = "Mark a day")
  public ChainState mark(MarkDayRequest request) {
    return chains.mark(current.id(), request.day(), request.todayOrDay());
  }

  @POST
  @Path("/freeze")
  @Operation(operationId = "spendChainFreeze", summary = "Spend the month's make-up")
  public ChainState freeze(MarkDayRequest request) {
    return chains.freeze(current.id(), request.day());
  }
}
