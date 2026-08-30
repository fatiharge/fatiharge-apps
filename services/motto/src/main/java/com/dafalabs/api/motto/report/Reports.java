package com.dafalabs.api.motto.report;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.content.ContentLocale;
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

  /// The axes each section reads, from the table. Fixed per reader — a report
  /// whose sections move around is one nobody can be told how to read — but
  /// not fixed per release: a sixth section is a row, and so is the day a
  /// section starts crossing a second axis.
  private record Axes(Dimension first, Dimension second) {}

  private Map<Integer, Axes> sectionAxes() {
    Map<Integer, Axes> bySection = new HashMap<>();
    // Structure rather than words: which axes a section reads is the same
    // report in every language, so this one read stays at the fallback and
    // a translator has one less table to keep in step.
    for (ReportSectionRow row : content.reportSections(ContentLocale.fallback)) {
      bySection.put(
          row.section(),
          new Axes(
              Dimension.of(row.dimension()),
              row.dimension2() == null ? null : Dimension.of(row.dimension2())));
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
  public ResultReport readingFor(UUID deviceId, long resultId, String locale) {
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
              pieces.reading(locale, dimension.name(), band).map(ReportPiece::text).orElse("")));
    }

    return new ResultReport(
        result.id(),
        archetype,
        pieces.one(locale, "overview", archetype).map(ReportPiece::text).orElse(""),
        readings,
        pieces.one(locale, "strength", archetype).map(ReportPiece::text).orElse(""),
        pieces.one(locale, "cost", archetype).map(ReportPiece::text).orElse(""));
  }

  private Result mine(UUID deviceId, long resultId) {
    return results.forDevice(deviceId).stream()
        .filter(candidate -> candidate.id() == resultId)
        .findFirst()
        .orElseThrow(
            () -> new CustomRuntimeException(404, "no_such_result", "That result does not exist."));
  }

  @Transactional
  public DeepReport forResult(UUID deviceId, long resultId, String locale) {
    Result result = mine(deviceId, resultId);

    String archetype = result.archetypeId();
    List<ReportSection> sections = assemble(result, archetype, locale);
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
        pieces.one(locale, "portrait", archetype).map(ReportPiece::text).orElse(null),
        pieces.one(locale, "comparison", archetype).map(ReportPiece::text).orElse(null),
        pieces.limitation(locale).map(ReportPiece::text).orElse(null));
  }

  private List<ReportSection> assemble(Result result, String archetype, String locale) {
    Map<Dimension, Double> profile = result.profile();
    Map<Integer, Axes> sectionAxes = sectionAxes();
    Map<Integer, String> fragments = new HashMap<>();
    for (ReportPiece fragment : pieces.fragments(locale, archetype)) {
      fragments.put(fragment.section(), fragment.text());
    }

    List<ReportSection> sections = new ArrayList<>();
    for (ReportPiece skeleton : pieces.skeletons(locale)) {
      int number = skeleton.section();
      Axes axes = sectionAxes.getOrDefault(number, new Axes(Dimension.OPENNESS, null));
      String band = bandOf(profile.getOrDefault(axes.first(), 0.5));
      String second =
          axes.second() == null ? null : bandOf(profile.getOrDefault(axes.second(), 0.5));

      sections.add(
          new ReportSection(
              number,
              skeleton.text(),
              pieces
                  .dimension(
                      locale,
                      axes.first().name(),
                      band,
                      axes.second() == null ? null : axes.second().name(),
                      second)
                  .map(ReportPiece::text)
                  .orElse(""),
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
