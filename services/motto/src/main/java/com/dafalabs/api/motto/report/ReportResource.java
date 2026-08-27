package com.dafalabs.api.motto.report;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.report.dto.DeepReport;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/** The deep report, or the preview of one. */
@Path("/v1/reports")
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class ReportResource {

  private final Reports reports;
  private final AuthenticatedDevice current;

  ReportResource(Reports reports, AuthenticatedDevice current) {
    this.reports = reports;
    this.current = current;
  }

  @GET
  @Path("/{resultId}")
  @Operation(operationId = "deepReport", summary = "The deep report for a result")
  public DeepReport forResult(@PathParam("resultId") long resultId) {
    return reports.forResult(current.id(), resultId);
  }
}
