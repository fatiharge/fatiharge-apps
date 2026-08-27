package com.dafalabs.api.motto.result;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.result.dto.ProfileScores;
import com.dafalabs.api.motto.result.dto.ResultHistory;
import com.dafalabs.api.motto.result.dto.ResultSummary;
import com.dafalabs.api.motto.scoring.Archetype;
import com.dafalabs.api.motto.scoring.ArchetypeCatalog;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.dto.ArchetypeResponse;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;
import java.util.Map;
import org.eclipse.microprofile.openapi.annotations.Operation;

/** Everything this device has been told about itself. */
@Path("/v1/me/results")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class ResultResource {

  private final Results results;
  private final ArchetypeCatalog catalog;
  private final AuthenticatedDevice current;

  ResultResource(Results results, ArchetypeCatalog catalog, AuthenticatedDevice current) {
    this.results = results;
    this.catalog = catalog;
    this.current = current;
  }

  @GET
  @Operation(operationId = "resultHistory", summary = "Past results, newest first")
  public ResultHistory history() {
    List<ResultSummary> summaries =
        results.forDevice(current.id()).stream().map(this::summarise).toList();
    return new ResultHistory(summaries);
  }

  private ResultSummary summarise(Result result) {
    Archetype archetype = catalog.byId(result.archetypeId());
    Map<Dimension, Double> profile = result.profile();

    return new ResultSummary(
        result.id(),
        new ArchetypeResponse(
            archetype.id(), archetype.name(), archetype.summary(), archetype.motto(), true),
        new ProfileScores(
            profile.get(Dimension.OPENNESS),
            profile.get(Dimension.CONSCIENTIOUSNESS),
            profile.get(Dimension.EXTRAVERSION),
            profile.get(Dimension.AGREEABLENESS),
            profile.get(Dimension.NEUROTICISM)),
        result.claimedAt());
  }
}
