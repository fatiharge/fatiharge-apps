package com.dafalabs.api.motto.report;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.ReportSectionRow;
import com.dafalabs.api.motto.entitlement.Entitlements;
import com.dafalabs.api.motto.report.dto.DeepReport;
import com.dafalabs.api.motto.report.dto.DimensionReading;
import com.dafalabs.api.motto.report.dto.ReportSection;
import com.dafalabs.api.motto.report.dto.ResultReport;
import com.dafalabs.api.motto.result.Result;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.scoring.Dimension;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Assembles a report against the profile that produced it.
 *
 * <p>Which dimension text a section carries depends on where this reader lands
 * on it, so two people with the same archetype read different reports. That
 * difference is the thing being paid for; eighteen fixed essays would read as
 * eighteen fixed essays.
 */
@ApplicationScoped
public class Reports {

  /// Below this a dimension reads as low, above it as high, and between the
  /// two as neither. Wide on purpose: a band that most profiles fall outside
  /// of makes every report sound extreme.
  static final double lowBelow = 0.4;
  static final double highAbove = 0.6;

  /// What someone sees before paying. Enough to know what they would get,
  /// short enough that it is not the report.
  public static final int previewCharacters = 220;

  private final ReportPieceRepository pieces;
  private final Results results;
  private final Entitlements entitlements;
  private final ContentStore content;

  Reports(
      ReportPieceRepository pieces,
      Results results,
      Entitlements entitlements,
      ContentStore content) {
    this.pieces = pieces;
    this.results = results;
    this.entitlements = entitlements;
    this.content = content;
  }

  /// Which dimension each section reads from, from the table. Fixed per
  /// reader — a report whose sections move around is one nobody can be told
  /// how to read — but not fixed per release: a sixth section is a row.
  private Map<Integer, Dimension> sectionDimension() {
    Map<Integer, Dimension> bySection = new HashMap<>();
    for (ReportSectionRow row : content.reportSections()) {
      bySection.put(row.section(), Dimension.of(row.dimension()));
    }
    return bySection;
  }

  static String bandOf(double score) {
    if (score < lowBelow) {
      return "low";
    }
    return score > highAbove ? "high" : "mid";
  }

  /**
   * The free report: all five dimensions, read where this profile lands on
   * them, wrapped in what the archetype gives and what it costs.
   *
   * <p>Deliberately whole. A free report that stops mid-sentence to ask for
   * money teaches people that the paid one is the same text with the rest
   * attached, which is not what the deep report is.
   */
  @Transactional
  public ResultReport readingFor(UUID deviceId, long resultId) {
    Result result = mine(deviceId, resultId);
    String archetype = result.archetypeId();
    Map<Dimension, Double> profile = result.profile();

    List<DimensionReading> readings = new ArrayList<>();
    for (Dimension dimension : Dimension.values()) {
      double score = profile.getOrDefault(dimension, 0.5);
      String band = bandOf(score);
      readings.add(
          new DimensionReading(
              dimension.name(),
              band,
              score,
              pieces.reading(dimension.name(), band).map(ReportPiece::text).orElse("")));
    }

    return new ResultReport(
        result.id(),
        archetype,
        pieces.one("overview", archetype).map(ReportPiece::text).orElse(""),
        readings,
        pieces.one("strength", archetype).map(ReportPiece::text).orElse(""),
        pieces.one("cost", archetype).map(ReportPiece::text).orElse(""));
  }

  private Result mine(UUID deviceId, long resultId) {
    return results.forDevice(deviceId).stream()
        .filter(candidate -> candidate.id() == resultId)
        .findFirst()
        .orElseThrow(
            () -> new CustomRuntimeException(404, "no_such_result", "That result does not exist."));
  }

  @Transactional
  public DeepReport forResult(UUID deviceId, long resultId) {
    Result result = mine(deviceId, resultId);

    String archetype = result.archetypeId();
    List<ReportSection> sections = assemble(result, archetype);
    String preview = previewOf(sections);

    if (!entitlements.stateOf(deviceId).premium()) {
      // The preview and nothing else. A locked report that ships its own body
      // is a locked report somebody reads in the network tab.
      return new DeepReport(resultId, archetype, true, preview, List.of(), null, null, null);
    }

    return new DeepReport(
        resultId,
        archetype,
        false,
        preview,
        sections,
        pieces.one("portrait", archetype).map(ReportPiece::text).orElse(null),
        pieces.one("comparison", archetype).map(ReportPiece::text).orElse(null),
        pieces.limitation().map(ReportPiece::text).orElse(null));
  }

  private List<ReportSection> assemble(Result result, String archetype) {
    Map<Dimension, Double> profile = result.profile();
    Map<Integer, Dimension> sectionDimension = sectionDimension();
    Map<Integer, String> fragments = new HashMap<>();
    for (ReportPiece fragment : pieces.fragments(archetype)) {
      fragments.put(fragment.section(), fragment.text());
    }

    List<ReportSection> sections = new ArrayList<>();
    for (ReportPiece skeleton : pieces.skeletons()) {
      int number = skeleton.section();
      Dimension dimension = sectionDimension.getOrDefault(number, Dimension.OPENNESS);
      String band = bandOf(profile.getOrDefault(dimension, 0.5));

      sections.add(
          new ReportSection(
              number,
              skeleton.text(),
              pieces.dimension(dimension.name(), band).map(ReportPiece::text).orElse(""),
              fragments.getOrDefault(number, "")));
    }
    return sections;
  }

  private String previewOf(List<ReportSection> sections) {
    if (sections.isEmpty()) {
      return "";
    }
    String opening = sections.get(0).opening() + " " + sections.get(0).reading();
    return opening.length() <= previewCharacters
        ? opening
        : opening.substring(0, previewCharacters).trim() + "…";
  }
}
