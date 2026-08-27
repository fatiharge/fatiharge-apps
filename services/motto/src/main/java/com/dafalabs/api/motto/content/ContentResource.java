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
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;

/**
 * The whole content package, or nothing new.
 *
 * <p>The client assembles a day offline, so it needs every piece or none of
 * them; five endpoints that can half-succeed would give it a fourth state to
 * handle for no gain.
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
   */
  // The response type is declared because the method returns `Response` — it
  // has to, for the 304 — and the schema would otherwise come out empty, which
  // generates a client that hands the app a Map.
  @GET
  @Operation(operationId = "contentBundle", summary = "The content package")
  @APIResponse(
      responseCode = "200",
      content = @Content(schema = @Schema(implementation = ContentBundle.class)))
  @APIResponse(responseCode = "304", description = "The version you hold is current")
  public Response bundle(@HeaderParam("If-None-Match") String ifNoneMatch) {
    ContentBundle bundle = catalog.bundle();
    EntityTag tag = new EntityTag(bundle.version());

    // 304 rather than a body: this package is most of what the app downloads,
    // and it changes when someone edits a sentence — which is rarely.
    if (matches(ifNoneMatch, bundle.version())) {
      return Response.notModified(tag).build();
    }

    return Response.ok(bundle).tag(tag).build();
  }

  /// The header arrives quoted, and some clients send it weakly validated.
  /// Comparing the raw string would answer 200 to a client that is already up
  /// to date, every single time.
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
