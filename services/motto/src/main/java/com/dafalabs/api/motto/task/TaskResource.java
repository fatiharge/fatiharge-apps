package com.dafalabs.api.motto.task;

import com.dafalabs.api.core.auth.AuthenticatedDevice;
import com.dafalabs.api.motto.chain.Chains;
import com.dafalabs.api.motto.task.dto.DailyTasks;
import com.dafalabs.api.motto.task.dto.PeriodReport;
import io.quarkus.security.Authenticated;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.time.LocalDate;
import org.eclipse.microprofile.openapi.annotations.Operation;

/**
 * The day's three tasks, and what fourteen of them came to.
 *
 * <p>Every call carries the phone's local date, for the same reason the chain
 * does: a day is a local day, and the server's is the wrong one for most of the
 * world for part of every day.
 */
@Path("/v1/tasks")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
@Authenticated
public class TaskResource {

  private final Tasks tasks;
  private final Chains chains;
  private final AuthenticatedDevice current;

  TaskResource(Tasks tasks, Chains chains, AuthenticatedDevice current) {
    this.tasks = tasks;
    this.chains = chains;
    this.current = current;
  }

  @GET
  @Operation(operationId = "dailyTasks", summary = "The three things today asks for")
  public DailyTasks today(@QueryParam("today") LocalDate today) {
    return tasks.forToday(current.id(), chains.state(current.id(), today));
  }

  @POST
  @Path("/{id}/complete")
  @Operation(operationId = "completeTask", summary = "Tick a task off")
  public Response complete(
      @PathParam("id") long id, @QueryParam("today") LocalDate today) {
    tasks.complete(current.id(), id, today);
    return Response.noContent().build();
  }

  @GET
  @Path("/report")
  @Operation(operationId = "periodReport", summary = "What the period came to")
  public PeriodReport report(@QueryParam("today") LocalDate today) {
    return tasks.report(current.id(), chains.state(current.id(), today));
  }
}
