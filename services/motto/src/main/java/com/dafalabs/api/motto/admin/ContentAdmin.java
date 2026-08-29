package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.write.WordGate;
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
  private final ContentStore store;

  ContentAdmin(TaskRepository tasks, ReportPieceRepository pieces, ContentStore store) {
    this.tasks = tasks;
    this.pieces = pieces;
    this.store = store;
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
              piece.kind(),
              piece.archetypeId(),
              piece.dimension(),
              piece.band(),
              piece.dimension2(),
              piece.band2(),
              piece.section())
          .ifPresentOrElse(
              existing -> existing.rewrite(piece.text(), piece.placeholder()),
              () ->
                  pieces.persist(
                      ReportPiece.of(
                          piece.kind(),
                          piece.archetypeId(),
                          piece.dimension(),
                          piece.band(),
                          piece.dimension2(),
                          piece.band2(),
                          piece.section(),
                          piece.text(),
                          piece.placeholder())));
    }
    return new WriteSummary(incoming.size(), (int) pieces.unwritten());
  }

  /**
   * Guideline 1.4.1, run backwards over everything already in the tables.
   *
   * <p>The gate on {@link com.dafalabs.api.motto.content.write.ContentWriter}
   * only sees what comes through the API, and rows do get corrected at a psql
   * prompt. This is how that half gets looked at.
   */
  @Transactional
  public List<String> objections() {
    List<String> found = new ArrayList<>();
    store
        .archetypes()
        .forEach(
            a ->
                found.addAll(
                    WordGate.objections(
                        "archetype " + a.id(), a.name(), a.summary(), a.motto())));
    store.activeItems().forEach(i -> found.addAll(WordGate.objections("item " + i.id(), i.text())));
    store
        .mottos()
        .forEach(
            m ->
                found.addAll(
                    WordGate.objections(
                        "motto " + m.id(), m.motto(), m.detail(), m.reminder())));
    store
        .skeletons()
        .forEach(
            s ->
                found.addAll(
                    WordGate.objections("day " + s.day(), s.title(), s.body(), s.action())));
    store
        .fragments()
        .forEach(
            f ->
                found.addAll(
                    WordGate.objections(
                        "fragment " + f.archetypeId() + "/" + f.ordinal(), f.text())));
    store
        .connectors()
        .forEach(c -> found.addAll(WordGate.objections("connector " + c.id(), c.text())));
    store
        .support()
        .forEach(
            s ->
                found.addAll(
                    WordGate.objections(
                        "support " + s.kind() + "/" + s.key(), s.heading(), s.body())));
    for (Task task : tasks.listAll()) {
      found.addAll(
          WordGate.objections(
              "task %s/%d/%d".formatted(task.archetypeId(), task.day(), task.ordinal()),
              task.title(),
              task.detail()));
    }
    for (ReportPiece piece : pieces.listAll()) {
      found.addAll(
          WordGate.objections(
              "report %s/%s".formatted(piece.kind(), piece.archetypeId()), piece.text()));
    }
    return found;
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
