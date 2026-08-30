package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.content.ContentLocale;
import com.dafalabs.api.motto.entitlement.EntitlementState;
import com.dafalabs.api.motto.entitlement.Entitlements;
import com.dafalabs.api.motto.entitlement.dto.EntitlementResponse;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.scoring.dto.AnswerSubmission;
import com.dafalabs.api.motto.scoring.dto.ArchetypeResponse;
import com.dafalabs.api.motto.scoring.dto.ResultResponse;
import io.quarkus.security.Authenticated;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

/** Where a set of answers becomes a motto, and costs one of the free uses. */
@Path("/v1/mottos")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class MottoResource {

  private final Scoring scoring;
  private final ArchetypeRules rules;
  private final ArchetypeCatalog catalog;
  private final Entitlements entitlements;
  private final Results results;
  private final AuthenticatedDevice current;

  MottoResource(
      Scoring scoring,
      ArchetypeRules rules,
      ArchetypeCatalog catalog,
      Entitlements entitlements,
      Results results,
      AuthenticatedDevice current) {
    this.scoring = scoring;
    this.rules = rules;
    this.catalog = catalog;
    this.entitlements = entitlements;
    this.results = results;
    this.current = current;
  }

  /**
   * Scoring and spending are one transaction on purpose. Split into two calls,
   * the gap between them is a result that was produced and never paid for, and
   * someone will find it.
   *
   * <p>The use is spent first, so that a refusal costs nothing and never leaves
   * a result behind.
   */
  @POST
  @Path("/claim")
  @Transactional
  @Operation(operationId = "claimMotto", summary = "Spend a use and get a motto")
  public ResultResponse claim(
      AnswerSubmission submission, @Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    ProfileVector profile = scoring.score(submission.answers());

    EntitlementState left = entitlements.spendUse(current.id(), submission.spendSkip());
    Archetype archetype = catalog.byId(rules.match(profile), ContentLocale.from(acceptLanguage));

    // In the same transaction as the spend: a result that was returned but not
    // recorded is a use that cannot be shown again.
    var stored = results.record(current.id(), archetype.id(), profile);

    return new ResultResponse(
        stored.id(),
        new ArchetypeResponse(
            archetype.id(), archetype.name(), archetype.summary(), archetype.motto(), true),
        new EntitlementResponse(
            left.remainingUses(), left.cooldownUntil(), left.skipsLeft(), left.premium()));
  }
}
