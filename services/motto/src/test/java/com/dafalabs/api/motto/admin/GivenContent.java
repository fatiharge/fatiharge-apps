package com.dafalabs.api.motto.admin;

import com.dafalabs.api.motto.admin.dto.ReportPieceWrite;
import com.dafalabs.api.motto.admin.dto.TaskWrite;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.ReportSectionRow;
import com.dafalabs.api.motto.content.write.ArchetypeWrite;
import com.dafalabs.api.motto.content.write.ConnectorWrite;
import com.dafalabs.api.motto.content.write.ContentWriter;
import com.dafalabs.api.motto.content.write.FragmentWrite;
import com.dafalabs.api.motto.content.write.ItemSetWrite;
import com.dafalabs.api.motto.content.write.ItemWrite;
import com.dafalabs.api.motto.content.write.MottoWrite;
import com.dafalabs.api.motto.content.write.SectionWrite;
import com.dafalabs.api.motto.content.write.SkeletonWrite;
import com.dafalabs.api.motto.content.write.SupportWrite;
import com.dafalabs.api.motto.scoring.Dimension;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * A product's worth of content, written by the test that needs it.
 *
 * <p>The migrations carry no words — they build the schema and stop — so a
 * test database starts empty and fills itself from here. That is also the
 * honest arrangement: a test asserting on real sentences fails the day
 * somebody corrects a typo, and one built to a shape proves the engine works
 * for any number of archetypes, which is the property that has to hold.
 *
 * <p>Everything goes in through the same write path the admin API uses, gates
 * included. Content that could not be written for real is content this fixture
 * has no business inventing.
 */
@ApplicationScoped
public class GivenContent {

  public static final String ARCHETYPE = "t_full";

  /// Five corners far enough apart to survive the reachability gate, and far
  /// from the one ContentAdminResourceTest places its own archetype at.
  public static final Map<String, double[]> ARCHETYPES = new LinkedHashMap<>();

  static {
    // openness, conscientiousness, extraversion, agreeableness, neuroticism
    ARCHETYPES.put("t_full", new double[] {0.9, 0.9, 0.9, 0.9, 0.9});
    ARCHETYPES.put("t_spare", new double[] {0.1, 0.1, 0.1, 0.1, 0.1});
    ARCHETYPES.put("t_open", new double[] {0.9, 0.1, 0.9, 0.1, 0.9});
    ARCHETYPES.put("t_steady", new double[] {0.1, 0.9, 0.1, 0.9, 0.1});
    ARCHETYPES.put("t_middle", new double[] {0.5, 0.5, 0.5, 0.5, 0.5});
  }

  private static final int DAYS = 14;
  private static final int PER_DAY = 3;
  private static final int MOTTOS = 4;
  private static final List<String> BANDS = List.of("low", "mid", "high");

  private final ContentAdmin content;
  private final ContentWriter writer;
  private final ContentStore store;

  GivenContent(ContentAdmin content, ContentWriter writer, ContentStore store) {
    this.content = content;
    this.writer = writer;
    this.store = store;
  }

  /** Which dimension the report's first section reads from. */
  public Dimension firstSectionDimension() {
    return store.reportSections().stream()
        .min(java.util.Comparator.comparingInt(ReportSectionRow::section))
        .map(row -> Dimension.of(row.dimension()))
        .orElseThrow();
  }

  /** The second axis the report's first section crosses. */
  public Dimension secondSectionDimension() {
    return store.reportSections().stream()
        .min(java.util.Comparator.comparingInt(ReportSectionRow::section))
        .map(row -> Dimension.of(row.dimension2()))
        .orElseThrow();
  }

  public List<Integer> sections() {
    return store.reportSections().stream().map(ReportSectionRow::section).toList();
  }

  /** Everything: the words, the instrument, the days and the report. */
  public void everything() {
    sectionsFirst();
    archetypes();
    items();
    days();
    support();
    for (String archetype : ARCHETYPES.keySet()) {
      everythingFor(archetype);
    }
  }

  /// Before the archetypes, because the report pieces are written per section
  /// and there is nothing to write against until the sections exist.
  private void sectionsFirst() {
    List<SectionWrite> sections = new ArrayList<>();
    Dimension[] all = Dimension.values();
    for (int i = 0; i < all.length; i++) {
      // Crossed with the next one round, so the fixture exercises the paired
      // lookup rather than only the single-axis fallback.
      sections.add(new SectionWrite(i + 1, all[i].name(), all[(i + 1) % all.length].name()));
    }
    writer.sections(sections);
  }

  private void archetypes() {
    List<ArchetypeWrite> archetypes = new ArrayList<>();
    List<MottoWrite> mottos = new ArrayList<>();
    List<FragmentWrite> fragments = new ArrayList<>();
    int ordinal = 1;

    for (var entry : ARCHETYPES.entrySet()) {
      String id = entry.getKey();
      archetypes.add(
          new ArchetypeWrite(
              id,
              "Arketip " + id,
              "%s olan kişi böyle biri. Bedeli, bu metnin bir test için yazılmış olması."
                  .formatted(id),
              "%s mottosu".formatted(id),
              ordinal++,
              List.of("openness", "conscientiousness"),
              target(entry.getValue())));

      for (int index = 1; index <= MOTTOS; index++) {
        mottos.add(
            new MottoWrite(
                "%s_%d".formatted(id, index),
                id,
                "%s motto %d".formatted(id, index),
                "%s motto %d ne demek".formatted(id, index),
                "%s motto %d hatırlatması".formatted(id, index),
                index));
      }

      for (int day = 1; day <= DAYS; day++) {
        fragments.add(new FragmentWrite(id, day, "%s · gün %d parçası.".formatted(id, day)));
      }
    }

    writer.archetypes(archetypes);
    writer.mottos(mottos);
    writer.fragments(fragments);
  }

  private static Map<String, Double> target(double[] point) {
    Map<String, Double> target = new LinkedHashMap<>();
    Dimension[] dimensions = Dimension.values();
    for (int i = 0; i < dimensions.length; i++) {
      target.put(dimensions[i].name().toLowerCase(java.util.Locale.ROOT), point[i]);
    }
    return target;
  }

  /// The real item ids, because the scoring tests name them — c3 is the
  /// reverse-keyed one they check inversion with.
  private void items() {
    List<ItemWrite> items = new ArrayList<>();
    int ordinal = 1;
    for (Dimension dimension : Dimension.values()) {
      String letter = dimension.name().substring(0, 1).toLowerCase(java.util.Locale.ROOT);
      for (int index = 1; index <= 4; index++) {
        items.add(
            new ItemWrite(
                letter + index,
                dimension.name(),
                index > 2,
                "%s%d maddesi.".formatted(letter, index),
                ordinal++));
      }
    }
    writer.items(new ItemSetWrite(1, true, items));
  }

  private void days() {
    List<SkeletonWrite> skeletons = new ArrayList<>();
    for (int day = 1; day <= DAYS; day++) {
      skeletons.add(
          new SkeletonWrite(
              day, "Gün %d".formatted(day), "Gün %d gövdesi.".formatted(day),
              "Gün %d eylemi.".formatted(day)));
    }
    writer.skeletons(skeletons);

    List<ConnectorWrite> connectors = new ArrayList<>();
    for (int index = 1; index <= 5; index++) {
      connectors.add(new ConnectorWrite("c" + index, "bağlaç " + index));
    }
    writer.connectors(connectors);
  }

  /// Twelve questions is the floor the support test enforces, so the fixture
  /// has to clear it rather than the test lowering its bar.
  private void support() {
    List<SupportWrite> support = new ArrayList<>();
    List<String> asked =
        List.of(
            "lost_data", "delete_data", "not_me", "chain_broken", "no_account", "why_wait",
            "accuracy", "offline", "cost", "game", "share_card", "contact", "reminder_time");
    int ordinal = 1;
    for (String key : asked) {
      support.add(
          new SupportWrite("faq", key, "%s sorusu?".formatted(key), "%s cevabı.".formatted(key),
              ordinal++));
    }
    for (int index = 1; index <= 3; index++) {
      support.add(new SupportWrite("privacy", "privacy_" + index, null,
          "Gizlilik maddesi %d.".formatted(index), index));
    }
    support.add(new SupportWrite("deletion", "goes_1", "goes", "Giden şey.", 1));
    support.add(new SupportWrite("deletion", "stays_1", "stays", "Kalan şey.", 2));
    support.add(
        new SupportWrite("deletion", "counter_reason_1", "counter_reason", "Sayaç kalıyor.", 3));
    support.add(
        new SupportWrite("deletion", "answers_note_1", "answers_note", "Cevaplar saklanmıyor.", 4));
    writer.support(support);
  }

  /** The days and the report, for one archetype. */
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
        // The single-axis paragraph a section falls back to, and the nine it
        // prefers when it crosses a second.
        pieces.add(piece("dimension", null, dimension.name(), band, null));
        for (Dimension second : Dimension.values()) {
          for (String secondBand : BANDS) {
            pieces.add(
                piece(
                    "dimension", null, dimension.name(), band, second.name(), secondBand, null));
          }
        }
      }
    }
    for (String kind : List.of("overview", "strength", "cost", "portrait", "comparison")) {
      pieces.add(piece(kind, archetype, null, null, null));
    }
    content.writeReportPieces(pieces);
  }

  private static ReportPieceWrite piece(
      String kind, String archetype, String dimension, String band, Integer section) {
    return piece(kind, archetype, dimension, band, null, null, section);
  }

  private static ReportPieceWrite piece(
      String kind,
      String archetype,
      String dimension,
      String band,
      String dimension2,
      String band2,
      Integer section) {
    // The whole address, so two pieces that differ only in the axis they cross
    // do not come out saying the same thing.
    String slot =
        String.join(
            " ",
            List.of(
                kind,
                String.valueOf(archetype),
                String.valueOf(dimension),
                String.valueOf(band),
                String.valueOf(dimension2),
                String.valueOf(band2),
                String.valueOf(section)));
    return new ReportPieceWrite(
        kind, archetype, dimension, band, dimension2, band2, section, slot, false);
  }
}
