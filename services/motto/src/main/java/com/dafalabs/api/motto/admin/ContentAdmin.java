package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.admin.dto.Unwritten;
import com.dafalabs.api.motto.admin.dto.WriteSummary;
import com.dafalabs.api.motto.content.ContentLocale;
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
  public WriteSummary writeTasks(String locale, List<TaskWrite> incoming) {
    for (TaskWrite task : incoming) {
      tasks
          .inSlot(locale, task.day(), task.archetypeId(), task.ordinal())
          .ifPresentOrElse(
              existing -> existing.rewrite(task.title(), task.detail(), task.placeholder()),
              () ->
                  tasks.persist(
                      Task.of(
                          locale,
                          task.day(),
                          task.archetypeId(),
                          task.ordinal(),
                          task.title(),
                          task.detail(),
                          task.placeholder())));
    }
    return new WriteSummary(incoming.size(), (int) tasks.unwritten(locale));
  }

  @Transactional
  public WriteSummary writeReportPieces(String locale, List<ReportPieceWrite> incoming) {
    for (ReportPieceWrite piece : incoming) {
      pieces
          .inSlot(
              locale,
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
                          locale,
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
    return new WriteSummary(incoming.size(), (int) pieces.unwritten(locale));
  }

  /**
   * Guideline 1.4.1, run backwards over everything already in the tables.
   *
   * <p>The gate on {@link com.dafalabs.api.motto.content.write.ContentWriter}
   * only sees what comes through the API, and rows do get corrected at a psql
   * prompt. This is how that half gets looked at.
   */
  @Transactional
  public List<String> objections(String locale) {
    List<String> found = new ArrayList<>();
    store
        .archetypes(locale)
        .forEach(
            a ->
                found.addAll(
                    WordGate.objections(
                        locale,
                        "archetype " + a.id(), a.name(), a.summary(), a.motto())));
    store.activeItems(locale).forEach(i -> found.addAll(WordGate.objections(locale, "item " + i.id(), i.text())));
    store
        .mottos(locale)
        .forEach(
            m ->
                found.addAll(
                    WordGate.objections(
                        locale,
                        "motto " + m.id(), m.motto(), m.detail(), m.reminder())));
    store
        .skeletons(locale)
        .forEach(
            s ->
                found.addAll(
                    WordGate.objections(locale, "day " + s.day(), s.title(), s.body(), s.action())));
    store
        .fragments(locale)
        .forEach(
            f ->
                found.addAll(
                    WordGate.objections(
                        locale,
                        "fragment " + f.archetypeId() + "/" + f.ordinal(), f.text())));
    store
        .connectors(locale)
        .forEach(c -> found.addAll(WordGate.objections(locale, "connector " + c.id(), c.text())));
    store
        .support(locale)
        .forEach(
            s ->
                found.addAll(
                    WordGate.objections(
                        locale,
                        "support " + s.kind() + "/" + s.key(), s.heading(), s.body())));
    for (Task task : tasks.listAll(locale)) {
      found.addAll(
          WordGate.objections(
              locale,
              "task %s/%d/%d".formatted(task.archetypeId(), task.day(), task.ordinal()),
              task.title(),
              task.detail()));
    }
    for (ReportPiece piece : pieces.listAll(locale)) {
      found.addAll(
          WordGate.objections(
              locale,
              "report %s/%s".formatted(piece.kind(), piece.archetypeId()), piece.text()));
    }
    return found;
  }

  /** What is still a stand-in — the writing job, as a list. */
  @Transactional
  public Unwritten unwritten(String locale) {
    List<String> slots = new ArrayList<>();
    for (Task task : tasks.list("locale = ?1 and placeholder", locale)) {
      slots.add("task %d/%s/%d".formatted(task.day(), task.archetypeId(), task.ordinal()));
    }
    for (ReportPiece piece : pieces.allUnwritten(locale)) {
      slots.add(
          "report %s/%s/%s/%s/%s"
              .formatted(
                  piece.kind(),
                  piece.archetypeId(),
                  piece.dimension(),
                  piece.band(),
                  piece.section()));
    }
    return new Unwritten((int) tasks.unwritten(locale), (int) pieces.unwritten(locale), slots);
  }
}
