package com.dafalabs.api.motto.support;

import com.dafalabs.api.motto.support.dto.SupportCopy;
import io.quarkus.security.Authenticated;
import com.dafalabs.api.motto.content.ContentLocale;
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

/** What the support screens say, so a wrong answer needs no store release. */
@Path("/v1/support")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class SupportResource {

  private final SupportCatalog catalog;

  SupportResource(SupportCatalog catalog) {
    this.catalog = catalog;
  }

  @GET
  @Operation(operationId = "supportCopy", summary = "The support copy")
  @APIResponse(
      responseCode = "200",
      content = @Content(schema = @Schema(implementation = SupportCopy.class)))
  @APIResponse(responseCode = "304", description = "The version you hold is current")
  public Response copy(
      @HeaderParam("If-None-Match") String ifNoneMatch,
      @Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    SupportCopy copy = catalog.copy(ContentLocale.from(acceptLanguage));
    EntityTag tag = new EntityTag(copy.version());

    // Vary on both answers, or a proxy hands the Turkish copy to the next
    // English phone — a 304 updates the stored headers, so leaving it off
    // there is the same hole one round trip later.
    if (matches(ifNoneMatch, copy.version())) {
      return Response.notModified(tag).header("Vary", "Accept-Language").build();
    }
    return Response.ok(copy).tag(tag).header("Vary", "Accept-Language").build();
  }

  /// Quoted on the wire, and weakened by proxies.
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
