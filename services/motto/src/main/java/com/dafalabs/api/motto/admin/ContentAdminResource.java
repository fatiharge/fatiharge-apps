package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import java.util.List;

/**
 * Content in, over HTTP.
 *
 * <p>Kept out of the published schema — see mp.openapi.scan.exclude.packages —
 * so the app's generated client has no idea these exist. The only caller is
 * scripts/push_content.py.
 */
@Path("/admin/content")
@AdminOnly
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ContentAdminResource {

  private final ContentAdmin content;

  ContentAdminResource(ContentAdmin content) {
    this.content = content;
  }

  @PUT
  @Path("/tasks")
  public WriteSummary tasks(List<TaskWrite> tasks) {
    return content.writeTasks(tasks);
  }

  @PUT
  @Path("/report-pieces")
  public WriteSummary reportPieces(List<ReportPieceWrite> pieces) {
    return content.writeReportPieces(pieces);
  }

  @GET
  @Path("/unwritten")
  public Unwritten unwritten() {
    return content.unwritten();
  }
}
