package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.admin.dto.Wiped;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import com.dafalabs.api.motto.content.ContentCatalog;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.write.ArchetypeWrite;
import com.dafalabs.api.motto.content.write.ConnectorWrite;
import com.dafalabs.api.motto.content.write.ContentWriter;
import com.dafalabs.api.motto.content.write.FragmentWrite;
import com.dafalabs.api.motto.content.write.ItemSetWrite;
import com.dafalabs.api.motto.content.write.MottoWrite;
import com.dafalabs.api.motto.content.write.SectionWrite;
import com.dafalabs.api.motto.content.write.SkeletonWrite;
import com.dafalabs.api.motto.content.write.SupportWrite;
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
 * <p>Every word the product says is written through here. There is no second
 * source: the repository holds no content files, so this is the door, and the
 * checks on the far side of it — guideline 1.4.1, an archetype that can still
 * be reached — are the only ones there are.
 *
 * <p>Kept out of the published schema — see mp.openapi.scan.exclude.packages —
 * so the app's generated client has no idea these exist.
 */
@Path("/admin/content")
@AdminOnly
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class ContentAdminResource {

  private final ContentAdmin content;
  private final ContentWriter writer;
  private final ContentCatalog catalog;
  private final DeviceReset reset;

  ContentAdminResource(
      ContentAdmin content, ContentWriter writer, ContentCatalog catalog, DeviceReset reset) {
    this.content = content;
    this.writer = writer;
    this.catalog = catalog;
    this.reset = reset;
  }

  /**
   * An archetype, words and position at once.
   *
   * <p>The nineteenth costs this request, fourteen fragments, its mottos and
   * its report pieces — and no Java at all. That is the whole point of the
   * tables: the thirty-second costs the same.
   */
  @PUT
  @Path("/archetypes")
  public WriteSummary archetypes(List<ArchetypeWrite> archetypes) {
    return written(writer.archetypes(archetypes));
  }

  @PUT
  @Path("/items")
  public WriteSummary items(ItemSetWrite set) {
    return written(writer.items(set));
  }

  @PUT
  @Path("/mottos")
  public WriteSummary mottos(List<MottoWrite> mottos) {
    return written(writer.mottos(mottos));
  }

  @PUT
  @Path("/skeletons")
  public WriteSummary skeletons(List<SkeletonWrite> skeletons) {
    return written(writer.skeletons(skeletons));
  }

  @PUT
  @Path("/fragments")
  public WriteSummary fragments(List<FragmentWrite> fragments) {
    return written(writer.fragments(fragments));
  }

  @PUT
  @Path("/connectors")
  public WriteSummary connectors(List<ConnectorWrite> connectors) {
    return written(writer.connectors(connectors));
  }

  @PUT
  @Path("/report-sections")
  public WriteSummary sections(List<SectionWrite> sections) {
    return written(writer.sections(sections));
  }

  @PUT
  @Path("/support")
  public WriteSummary support(List<SupportWrite> support) {
    return written(writer.support(support));
  }

  /// These tables have no unwritten count: a row exists or it does not, and
  /// what is missing is caught by the reader that asks for it.
  private static WriteSummary written(int rows) {
    return new WriteSummary(rows, 0);
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
   * The package a phone would receive, without being a phone.
   *
   * <p>The app's tests run the day assembler against real content, and this is
   * where the fixture they read comes from now that no file holds it.
   */
  @GET
  @Path("/bundle")
  public ContentBundle bundle() {
    return catalog.bundle();
  }

  /** Every sentence in the tables that guideline 1.4.1 would object to. */
  @GET
  @Path("/objections")
  public List<String> objections() {
    return content.objections();
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
