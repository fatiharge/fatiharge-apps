package com.dafalabs.api.motto.entitlement;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.entitlement.dto.DeletionResponse;
import com.dafalabs.api.motto.chain.Chains;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.entitlement.dto.EntitlementResponse;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;
import org.eclipse.microprofile.openapi.annotations.Operation;

/** What the caller may do, and the way to be forgotten. */
@Path("/v1")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class EntitlementResource {

  private final Entitlements entitlements;
  private final Results results;
  private final Chains chains;
  private final AuthenticatedDevice current;

  EntitlementResource(
      Entitlements entitlements,
      Results results,
      Chains chains,
      AuthenticatedDevice current) {
    this.entitlements = entitlements;
    this.results = results;
    this.chains = chains;
    this.current = current;
  }

  @GET
  @Path("/entitlements")
  @Operation(operationId = "currentEntitlement", summary = "What this device may do now")
  public EntitlementResponse current() {
    EntitlementState state = entitlements.stateOf(current.id());
    return new EntitlementResponse(
        state.remainingUses(), state.cooldownUntil(), state.skipsLeft(), state.premium());
  }

  @DELETE
  @Path("/me")
  @Operation(operationId = "deleteMyData", summary = "Delete this device's data")
  public DeletionResponse deleteMyData() {
    entitlements.deleteDataKeepingCounter(current.id());
    results.deleteForDevice(current.id());
    chains.deleteForDevice(current.id());
    // Named rather than counted: the app shows this list on the confirmation
    // screen, and a number would not explain why the free uses did not return.
    return new DeletionResponse(
        List.of("results", "chain"), List.of("usage_counter"));
  }
}
