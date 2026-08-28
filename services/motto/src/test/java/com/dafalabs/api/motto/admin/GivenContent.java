package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.scoring.Dimension;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * The content tables, filled.
 *
 * <p>Content is pushed over /admin/content rather than seeded by a migration,
 * so a test database starts with none of it. Tests that need content write
 * their own — which is the honest arrangement anyway: a test passing on rows a
 * migration happened to insert is testing the migration.
 */
@ApplicationScoped
public class GivenContent {

  public static final String ARCHETYPE = "quiet_builder";

  private static final int DAYS = 14;
  private static final int PER_DAY = 3;
  private static final List<String> BANDS = List.of("low", "mid", "high");
  private static final List<Integer> SECTIONS = List.of(1, 2, 3, 4);

  private final ContentAdmin content;

  GivenContent(ContentAdmin content) {
    this.content = content;
  }

  /** Every slot the assembly can reach, for one archetype. */
  public void everything() {
    everythingFor(ARCHETYPE);
  }

  public void everythingFor(String archetype) {
    List<TaskWrite> tasks = new ArrayList<>();
    for (int day = 1; day <= DAYS; day++) {
      for (int ordinal = 1; ordinal <= PER_DAY; ordinal++) {
        tasks.add(
            new TaskWrite(
                day,
                archetype,
                ordinal,
                "gün %d · %d".formatted(day, ordinal),
                "gün %d · %d ayrıntı".formatted(day, ordinal),
                false));
      }
    }
    content.writeTasks(tasks);

    List<ReportPieceWrite> pieces = new ArrayList<>();
    pieces.add(piece("limitation", null, null, null, null));
    for (int section : SECTIONS) {
      pieces.add(piece("skeleton", null, null, null, section));
      pieces.add(piece("fragment", archetype, null, null, section));
    }
    for (Dimension dimension : Dimension.values()) {
      for (String band : BANDS) {
        pieces.add(piece("reading", null, dimension.name(), band, null));
        pieces.add(piece("dimension", null, dimension.name(), band, null));
      }
    }
    for (String kind : List.of("overview", "strength", "cost", "portrait", "comparison")) {
      pieces.add(piece(kind, archetype, null, null, null));
    }
    content.writeReportPieces(pieces);
  }

  private static ReportPieceWrite piece(
      String kind, String archetype, String dimension, String band, Integer section) {
    String slot =
        String.join(
            " ",
            List.of(kind, String.valueOf(archetype), String.valueOf(dimension),
                String.valueOf(band), String.valueOf(section)));
    return new ReportPieceWrite(kind, archetype, dimension, band, section, slot, false);
  }
}
