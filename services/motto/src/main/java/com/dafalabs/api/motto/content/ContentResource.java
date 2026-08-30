package com.dafalabs.api.motto.content;

import com.dafalabs.api.motto.content.dto.ContentBundle;
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
 * The whole content package, or nothing new. The client assembles a day
 * offline, so it needs every piece or none of them.
 */
@Path("/v1/content")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class ContentResource {

  private final ContentCatalog catalog;

  ContentResource(ContentCatalog catalog) {
    this.catalog = catalog;
  }

  /**
   * @param ifNoneMatch the version the client already holds
   * @param acceptLanguage the language the phone is set to
   */
  // Declared because the method returns `Response` for the 304, and the schema
  // would otherwise come out empty and generate a client returning a Map.
  @GET
  @Operation(operationId = "contentBundle", summary = "The content package")
  @APIResponse(
      responseCode = "200",
      content = @Content(schema = @Schema(implementation = ContentBundle.class)))
  @APIResponse(responseCode = "304", description = "The version you hold is current")
  public Response bundle(
      @HeaderParam("If-None-Match") String ifNoneMatch,
      @Parameter(hidden = true) @HeaderParam("Accept-Language") String acceptLanguage) {
    ContentBundle bundle = catalog.bundle(ContentLocale.from(acceptLanguage));
    EntityTag tag = new EntityTag(bundle.version());

    // Vary on both answers, or a proxy hands the Turkish package to the next
    // English phone — a 304 updates the stored headers, so leaving it off
    // there is the same hole one round trip later.
    if (matches(ifNoneMatch, bundle.version())) {
      return Response.notModified(tag).header("Vary", "Accept-Language").build();
    }

    return Response.ok(bundle).tag(tag).header("Vary", "Accept-Language").build();
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
