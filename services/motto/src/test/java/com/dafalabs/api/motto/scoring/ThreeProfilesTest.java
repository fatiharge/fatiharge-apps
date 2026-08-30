package com.dafalabs.api.motto.scoring;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.content.ContentCatalog;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.entitlement.Entitlements;
import com.dafalabs.api.motto.report.Reports;
import com.dafalabs.api.motto.report.dto.DeepReport;
import com.dafalabs.api.motto.report.dto.DimensionReading;
import com.dafalabs.api.motto.report.dto.ReportSection;
import com.dafalabs.api.motto.report.dto.ResultReport;
import com.dafalabs.api.motto.result.Result;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.task.TaskRepository;
import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Three people answer the twenty statements, and three different products come
 * out of the far end.
 *
 * <p>Every other test here checks one joint. This one walks the whole thing —
 * answers, score, archetype, the free report read against that profile, the
 * motto, the fourteen days — because the failure this catches is the one no
 * unit test can see: all three arriving at the same archetype, or at three
 * archetypes whose reports read identically.
 */
@QuarkusTest
class ThreeProfilesTest {

  @Inject Scoring scoring;
  @Inject ArchetypeRules rules;
  @Inject ArchetypeCatalog archetypes;
  @Inject ContentCatalog content;
  @Inject Results results;
  @Inject Reports reports;
  @Inject TaskRepository tasks;
  @Inject Entitlements entitlements;
  @Inject GivenContent given;

  @BeforeEach
  void seed() {
    given.everything();
  }

  /// 5 is "agree", 1 is "disagree". Reverse-keyed items are marked in the
  /// table, so these read as the person would answer them, not as points.
  private static Map<String, Integer> planner() {
    return answers(
        "e1", 2, "e2", 2, "e3", 4, "e4", 4,
        "a1", 4, "a2", 4, "a3", 3, "a4", 3,
        "c1", 5, "c2", 5, "c3", 1, "c4", 1,
        "n1", 2, "n2", 3, "n3", 4, "n4", 4,
        "o1", 3, "o2", 2, "o3", 4, "o4", 4);
  }

  private static Map<String, Integer> host() {
    return answers(
        "e1", 5, "e2", 5, "e3", 2, "e4", 1,
        "a1", 5, "a2", 5, "a3", 2, "a4", 2,
        "c1", 3, "c2", 3, "c3", 3, "c4", 3,
        "n1", 3, "n2", 3, "n3", 3, "n4", 3,
        "o1", 4, "o2", 3, "o3", 3, "o4", 3);
  }

  private static Map<String, Integer> restless() {
    return answers(
        "e1", 4, "e2", 4, "e3", 3, "e4", 2,
        "a1", 3, "a2", 3, "a3", 4, "a4", 4,
        "c1", 2, "c2", 2, "c3", 4, "c4", 4,
        "n1", 4, "n2", 5, "n3", 2, "n4", 2,
        "o1", 5, "o2", 5, "o3", 1, "o4", 1);
  }

  @Test
  @DisplayName("three different sets of answers become three different products")
  void threePeopleGetThreeProducts() {
    var one = walk("Planlayan", planner());
    var two = walk("Ev sahibi", host());
    var three = walk("Kıpır kıpır", restless());

    assertNotEquals(one, two);
    assertNotEquals(two, three);
    assertNotEquals(one, three);
  }

  /** One person, end to end, printed as they would read it. */
  private String walk(String who, Map<String, Integer> answers) {
    ProfileVector profile = scoring.score(answers);
    String id = rules.match(profile);
    Archetype archetype = archetypes.byId(id, "tr");
    UUID device = UUID.randomUUID();
    long resultId = resultFor(device, id, profile);
    ResultReport report = reports.readingFor(device, resultId, "tr");
    DeepReport locked = reports.forResult(device, resultId, "tr");
    DeepReport deep = unlocked(device, resultId);
    ContentBundle bundle = content.bundle("tr");

    StringBuilder out = new StringBuilder();
    out.append("\n=== %s → %s (%s)\n".formatted(who, archetype.name(), id));
    for (Dimension dimension : Dimension.values()) {
      out.append(
          "    %-18s %.2f  %s\n"
              .formatted(dimension.name().toLowerCase(), profile.at(dimension),
                  band(profile.at(dimension))));
    }
    out.append("    özet: %s\n".formatted(archetype.summary()));
    out.append("    motto: %s\n".formatted(archetype.motto()));
    for (DimensionReading reading : report.readings()) {
      out.append("    [%s %s] %s\n".formatted(reading.dimension(), reading.band(), reading.text()));
    }
    out.append("    güçlü yan: %s\n".formatted(report.strength()));
    out.append("    bedeli: %s\n".formatted(report.cost()));

    out.append("    kilitli önizleme: %s\n".formatted(locked.preview()));
    for (ReportSection section : deep.sections()) {
      out.append(
          "    derin %d · %s || %s || %s\n"
              .formatted(section.section(), section.opening(), section.reading(), section.fragment()));
    }
    out.append("    portre: %s\n".formatted(deep.portrait()));
    out.append("    kıyas: %s\n".formatted(deep.comparison()));
    out.append("    sınırlar: %s\n".formatted(deep.limitation()));

    bundle.mottos().stream()
        .filter(motto -> motto.archetypeId().equals(id))
        .forEach(motto -> out.append("    motto seçeneği: %s\n".formatted(motto.motto())));

    bundle.skeletons().stream()
        .filter(day -> day.day() <= 3)
        .forEach(
            day ->
                out.append(
                    "    gün %d · %s — %s %s\n"
                        .formatted(
                            day.day(),
                            day.title(),
                            day.body(),
                            fragment(bundle, id, day.day()))));

    for (int day = 1; day <= 3; day++) {
      for (var task : tasks.forDay("tr", day, id)) {
        out.append("    görev %d.%d %s — %s\n".formatted(day, task.ordinal(), task.title(), task.detail()));
      }
    }

    System.out.print(out);

    // Every archetype has to arrive with the pieces that make it a product,
    // not just a name: a summary that names a cost, five readings against this
    // profile, and its own fourteen days.
    assertTrue(archetype.summary().length() > 40, id + " has no summary worth reading");
    assertEquals(Dimension.values().length, report.readings().size());
    for (DimensionReading reading : report.readings()) {
      assertFalse(reading.text().isBlank(), id + " has no " + reading.dimension() + " reading");
    }
    assertEquals(
        14, bundle.fragments().stream().filter(f -> f.archetypeId().equals(id)).count());

    // The lock has to hold before paying and let go after, and the preview has
    // to be short enough that it is not the report.
    assertTrue(locked.locked());
    assertTrue(locked.sections().isEmpty());
    assertTrue(locked.preview().length() <= Reports.previewCharacters + 1);
    assertFalse(deep.locked());
    assertEquals(5, deep.sections().size());
    for (ReportSection section : deep.sections()) {
      assertFalse(section.opening().isBlank(), id + " section " + section.section());
      assertFalse(section.reading().isBlank(), id + " section " + section.section());
      assertFalse(section.fragment().isBlank(), id + " section " + section.section());
    }
    assertNotNull(deep.portrait());
    assertNotNull(deep.comparison());
    assertNotNull(deep.limitation());
    assertFalse(bundle.mottos().stream().noneMatch(m -> m.archetypeId().equals(id)));
    // Fourteen days of three things to do, or the chain has nothing in it.
    assertEquals(42, tasks.forArchetype("tr", id).size(), id + " is missing days");

    return id;
  }

  /// The same three names the report uses, so the walkthrough reads the way
  /// the reader's own report does.
  private static String band(double score) {
    if (score < 0.4) {
      return "düşük";
    }
    return score > 0.6 ? "yüksek" : "orta";
  }

  private static String fragment(ContentBundle bundle, String id, int day) {
    return bundle.fragments().stream()
        .filter(f -> f.archetypeId().equals(id) && f.index() == day)
        .findFirst()
        .map(f -> f.text())
        .orElse("");
  }

  @Transactional
  long resultFor(UUID device, String id, ProfileVector profile) {
    Result result = results.record(device, id, profile);
    return result.id();
  }

  /// Paying is the only difference between the two calls above and this one,
  /// so running both is what proves the lock is a lock and not a label.
  @Transactional
  DeepReport unlocked(UUID device, long resultId) {
    entitlements.grantPremium(device);
    return reports.forResult(device, resultId, "tr");
  }

  private static Map<String, Integer> answers(Object... pairs) {
    Map<String, Integer> answers = new LinkedHashMap<>();
    for (int i = 0; i < pairs.length; i += 2) {
      answers.put((String) pairs[i], (Integer) pairs[i + 1]);
    }
    return answers;
  }
}
