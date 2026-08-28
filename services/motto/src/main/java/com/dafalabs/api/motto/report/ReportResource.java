package com.dafalabs.api.motto.report;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.report.dto.DeepReport;
import com.dafalabs.api.motto.report.dto.ResultReport;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.openapi.annotations.Operation;

/** The two reports on a result: the free reading, and the deep one behind it. */
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
  @Path("/{resultId}/summary")
  @Operation(operationId = "resultReport", summary = "The free report for a result")
  public ResultReport summaryFor(@PathParam("resultId") long resultId) {
    return reports.readingFor(current.id(), resultId);
  }

  @GET
  @Path("/{resultId}")
  @Operation(operationId = "deepReport", summary = "The deep report for a result")
  public DeepReport forResult(@PathParam("resultId") long resultId) {
    return reports.forResult(current.id(), resultId);
  }
}
