package com.dafalabs.api.motto.effects;

import com.dafalabs.api.motto.content.ContentLocale;
import com.dafalabs.api.motto.effects.dto.EffectCatalogue;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.HeaderParam;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.EntityTag;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;

/**
 * What every refusal this app can give leads to.
 *
 * <p>Its own endpoint rather than a corner of the content bundle: every app in
 * this repo will want this and none of them will want motto's mottos. It can
 * leave on its own the way it arrived.
 */
@Path("/v1/effects")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class EffectResource {

  private final Effects effects;

  EffectResource(Effects effects) {
    this.effects = effects;
  }

  // Declared because the method returns `Response` for the 304, and the schema
  // would otherwise come out empty and generate a client returning a Map.
  @GET
  @Operation(operationId = "errorEffects", summary = "What each refusal leads to")
  @APIResponse(
      responseCode = "200",
      content = @Content(schema = @Schema(implementation = EffectCatalogue.class)))
  @APIResponse(responseCode = "304", description = "The version you hold is current")
  public Response catalogue(
      @HeaderParam("If-None-Match") String ifNoneMatch,
      @Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    EffectCatalogue catalogue = effects.catalogue(ContentLocale.from(acceptLanguage));
    EntityTag tag = new EntityTag(catalogue.version());

    // The definitions change when somebody edits a sentence and not otherwise,
    // so most of these requests are a phone asking and being told nothing has.
    // Vary on both answers, or a proxy hands the Turkish sentences to the next
    // English phone — a 304 updates the stored headers, so leaving it off
    // there is the same hole one round trip later.
    if (matches(ifNoneMatch, catalogue.version())) {
      return Response.notModified(tag).header("Vary", "Accept-Language").build();
    }
    return Response.ok(catalogue).tag(tag).header("Vary", "Accept-Language").build();
  }

  /// The header arrives quoted, and proxies weaken it. Comparing raw strings
  /// would answer 200 to a client that is already current.
  private boolean matches(String header, String version) {
    if (header == null) {
      return false;
    }
    for (String candidate : header.split(",")) {
      String trimmed = candidate.trim();
      if (trimmed.startsWith("W/")) {
        trimmed = trimmed.substring(2);
      }
      if (trimmed.replace("\"", "").equals(version)) {
        return true;
      }
    }
    return false;
  }
}
