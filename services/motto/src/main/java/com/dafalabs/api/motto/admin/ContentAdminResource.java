package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.motto.admin.dto.Wiped;
import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.QueryParam;
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
  private final DeviceReset reset;

  ContentAdminResource(ContentAdmin content, DeviceReset reset) {
    this.content = content;
    this.reset = reset;
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

  /**
   * Back to nobody having used it — content kept, every device forgotten.
   *
   * <p>Three things have to be true at once: the admin token is right, the
   * deployment turned resets on, and the caller spelled the confirmation out.
   * Production has neither of the first two, and the third is there so that a
   * half-remembered curl cannot empty a database by accident.
   */
  @DELETE
  @Path("/devices")
  public Wiped wipeDevices(@QueryParam("confirm") String confirm) {
    if (!reset.allowed()) {
      throw new CustomRuntimeException(404, "not_found", "Not found.");
    }
    if (!DeviceReset.CONFIRMATION.equals(confirm)) {
      throw new CustomRuntimeException(
          400, "confirm_required", "Pass ?confirm=" + DeviceReset.CONFIRMATION + " to mean it.");
    }
    return reset.wipe();
  }
}
