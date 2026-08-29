package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.ReportSectionRow;
import com.dafalabs.api.motto.scoring.Dimension;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * The content tables, filled.
 *
 * <p>Written over /admin/content, addressed by slot, so it overwrites whatever
 * the seed left in the same places rather than testing around it. A test that
 * asserted on seeded sentences would be a test that fails when somebody
 * corrects a typo.
 *
 * <p>The sections come from the section table rather than a list here: that
 * the report grows a sixth section without a code change is the property, and
 * a constant typed here would hide it.
 */
@ApplicationScoped
public class GivenContent {

  public static final String ARCHETYPE = "quiet_builder";

  private static final int DAYS = 14;
  private static final int PER_DAY = 3;
  private static final List<String> BANDS = List.of("low", "mid", "high");
  private final ContentAdmin content;
  private final ContentStore store;

  GivenContent(ContentAdmin content, ContentStore store) {
    this.content = content;
    this.store = store;
  }

  public List<Integer> sections() {
    return store.reportSections().stream().map(ReportSectionRow::section).toList();
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
    for (int section : sections()) {
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
