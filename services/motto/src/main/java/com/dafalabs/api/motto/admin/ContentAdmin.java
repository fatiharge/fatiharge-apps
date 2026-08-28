package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import com.dafalabs.api.motto.report.ReportPiece;
import com.dafalabs.api.motto.report.ReportPieceRepository;
import com.dafalabs.api.motto.task.Task;
import com.dafalabs.api.motto.task.TaskRepository;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;

/**
 * Writing content into the tables that hold it.
 *
 * <p>Through here rather than through a migration: content is data, and data
 * that can only change by cutting a release is data nobody fixes. A typo in a
 * task should cost one request, not a deploy.
 *
 * <p>Addressed by the slot it fills rather than by id, so the same push can be
 * run twice and pushing one corrected line does not disturb the others.
 */
@ApplicationScoped
public class ContentAdmin {

  private final TaskRepository tasks;
  private final ReportPieceRepository pieces;

  ContentAdmin(TaskRepository tasks, ReportPieceRepository pieces) {
    this.tasks = tasks;
    this.pieces = pieces;
  }

  @Transactional
  public WriteSummary writeTasks(List<TaskWrite> incoming) {
    for (TaskWrite task : incoming) {
      tasks
          .inSlot(task.day(), task.archetypeId(), task.ordinal())
          .ifPresentOrElse(
              existing -> existing.rewrite(task.title(), task.detail(), task.placeholder()),
              () ->
                  tasks.persist(
                      Task.of(
                          task.day(),
                          task.archetypeId(),
                          task.ordinal(),
                          task.title(),
                          task.detail(),
                          task.placeholder())));
    }
    return new WriteSummary(incoming.size(), (int) tasks.unwritten());
  }

  @Transactional
  public WriteSummary writeReportPieces(List<ReportPieceWrite> incoming) {
    for (ReportPieceWrite piece : incoming) {
      pieces
          .inSlot(
              piece.kind(), piece.archetypeId(), piece.dimension(), piece.band(), piece.section())
          .ifPresentOrElse(
              existing -> existing.rewrite(piece.text(), piece.placeholder()),
              () ->
                  pieces.persist(
                      ReportPiece.of(
                          piece.kind(),
                          piece.archetypeId(),
                          piece.dimension(),
                          piece.band(),
                          piece.section(),
                          piece.text(),
                          piece.placeholder())));
    }
    return new WriteSummary(incoming.size(), (int) pieces.unwritten());
  }

  /** What is still a stand-in — the writing job, as a list. */
  @Transactional
  public Unwritten unwritten() {
    List<String> slots = new ArrayList<>();
    for (Task task : tasks.list("placeholder")) {
      slots.add("task %d/%s/%d".formatted(task.day(), task.archetypeId(), task.ordinal()));
    }
    for (ReportPiece piece : pieces.allUnwritten()) {
      slots.add(
          "report %s/%s/%s/%s/%s"
              .formatted(
                  piece.kind(),
                  piece.archetypeId(),
                  piece.dimension(),
                  piece.band(),
                  piece.section()));
    }
    return new Unwritten((int) tasks.unwritten(), (int) pieces.unwritten(), slots);
  }
}
