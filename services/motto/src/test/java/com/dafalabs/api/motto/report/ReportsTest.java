package com.dafalabs.api.motto.report;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.entitlement.Entitlements;
import com.dafalabs.api.motto.report.dto.DimensionReading;
import com.dafalabs.api.motto.report.dto.ResultReport;
import com.dafalabs.api.motto.result.Result;
import com.dafalabs.api.motto.result.Results;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import com.dafalabs.api.motto.admin.GivenContent;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.EnumMap;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class ReportsTest {

  @Inject Reports reports;
  @Inject Results results;
  @Inject Entitlements entitlements;

  @Inject GivenContent content;

  private UUID device;

  @BeforeEach
  void setUp() {
    device = UUID.randomUUID();
    content.everything();
  }

  /// Moves the dimension the report's first section reads from, whichever
  /// that is: the section table decides, and a dimension named here would only
  /// agree with it by luck.
  @Transactional
  Result givenAResult(double score) {
    Map<Dimension, Double> scores = new EnumMap<>(Dimension.class);
    for (Dimension dimension : Dimension.values()) {
      scores.put(dimension, 0.5);
    }
    scores.put(content.firstSectionDimension(), score);
    return results.record(device, GivenContent.ARCHETYPE, new ProfileVector(scores));
  }

  @Test
  @DisplayName("a score reads as low, middling or high")
  void bandsSplitTheScale() {
    assertEquals("low", Reports.bandOf(0.1));
    assertEquals("mid", Reports.bandOf(0.5));
    assertEquals("high", Reports.bandOf(0.9));
  }

  @Test
  @DisplayName("the middle band is wide enough that most reports are not extreme")
  void theMiddleIsWide() {
    assertEquals("mid", Reports.bandOf(Reports.lowBelow + 0.01));
    assertEquals("mid", Reports.bandOf(Reports.highAbove - 0.01));
  }

  @Test
  @DisplayName("without paying there is a preview and nothing else")
  void lockedCarriesOnlyThePreview() {
    var result = givenAResult(0.9);

    var report = reports.forResult(device, result.id());

    // A locked report that ships its own body is one somebody reads in the
    // network tab.
    assertTrue(report.locked());
    assertFalse(report.preview().isEmpty());
    assertTrue(report.sections().isEmpty());
    assertNull(report.portrait());
    assertNull(report.limitation());
  }

  @Test
  @DisplayName("paying opens the sections")
  void premiumUnlocksIt() {
    var result = givenAResult(0.9);
    entitlements.grantPremium(device);

    var report = reports.forResult(device, result.id());

    assertFalse(report.locked());
    assertEquals(content.sections().size(), report.sections().size());
    assertNotNull(report.portrait());
    assertNotNull(report.limitation());
  }

  @Test
  @DisplayName("two profiles with one archetype do not read the same report")
  void theReadingFollowsTheProfile() {
    var low = givenAResult(0.1);
    var high = givenAResult(0.9);
    entitlements.grantPremium(device);

    var first = reports.forResult(device, low.id()).sections().get(0);
    var second = reports.forResult(device, high.id()).sections().get(0);

    // The difference is the thing being paid for.
    assertEquals(first.opening(), second.opening());
    assertFalse(first.reading().equals(second.reading()));
  }

  @Test
  @DisplayName("somebody else's result is not readable")
  void refusesAnotherDevicesResult() {
    var result = givenAResult(0.5);

    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () -> reports.forResult(UUID.randomUUID(), result.id()));

    assertEquals("no_such_result", refused.code());
  }

  @Test
  @DisplayName("the free report reads every dimension, and is never locked")
  void theFreeReportIsWhole() {
    Result result = givenAResult(0.9);
    ResultReport report = reports.readingFor(device, result.id());

    assertEquals(Dimension.values().length, report.readings().size());
    assertFalse(report.overview().isBlank());
    assertFalse(report.strength().isBlank());
    assertFalse(report.cost().isBlank());
    for (DimensionReading reading : report.readings()) {
      assertFalse(reading.text().isBlank(), reading.dimension() + " has no text");
    }
  }

  @Test
  @DisplayName("the free report follows the profile, not the archetype")
  void theFreeReportFollowsTheProfile() {
    Result low = givenAResult(0.1);
    Result high = givenAResult(0.9);

    assertEquals("low", bandFor(reports.readingFor(device, low.id())));
    assertEquals("high", bandFor(reports.readingFor(device, high.id())));
  }

  private String bandFor(ResultReport report) {
    String moved = content.firstSectionDimension().name();
    return report.readings().stream()
        .filter(reading -> reading.dimension().equals(moved))
        .findFirst()
        .orElseThrow()
        .band();
  }

  @Test
  @DisplayName("the free report is somebody else's to read only if it is theirs")
  void theFreeReportIsScopedToTheDevice() {
    Result result = givenAResult(0.5);
    assertThrows(
        CustomRuntimeException.class, () -> reports.readingFor(UUID.randomUUID(), result.id()));
  }
}
