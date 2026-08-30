package com.dafalabs.api.motto.report;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.Optional;

@ApplicationScoped
public class ReportPieceRepository implements PanacheRepository<ReportPiece> {

  public Optional<ReportPiece> one(String locale, String kind, String archetypeId) {
    return find("locale = ?1 and kind = ?2 and archetypeId = ?3", locale, kind, archetypeId)
        .firstResultOptional();
  }

  /**
   * The slot a pushed piece addresses. Nulls are part of the address — half the
   * columns are unset on any given kind — so the comparison has to be
   * null-safe rather than equality.
   */
  public Optional<ReportPiece> inSlot(
      String locale,
      String kind,
      String archetypeId,
      String dimension,
      String band,
      Integer section) {
    return inSlot(locale, kind, archetypeId, dimension, band, null, null, section);
  }

  public Optional<ReportPiece> inSlot(
      String locale,
      String kind,
      String archetypeId,
      String dimension,
      String band,
      String dimension2,
      String band2,
      Integer section) {
    return find(
            """
            locale = ?1
              and kind = ?2
              and archetypeId is not distinct from ?3
              and dimension is not distinct from ?4
              and band is not distinct from ?5
              and dimension2 is not distinct from ?6
              and band2 is not distinct from ?7
              and section is not distinct from ?8
            """,
            locale,
            kind,
            archetypeId,
            dimension,
            band,
            dimension2,
            band2,
            section)
        .firstResultOptional();
  }

  public long unwritten(String locale) {
    return count("locale = ?1 and placeholder", locale);
  }

  public List<ReportPiece> allUnwritten(String locale) {
    return list("locale = ?1 and placeholder", locale);
  }

  public List<ReportPiece> listAll(String locale) {
    return list("locale = ?1", locale);
  }

  public Optional<ReportPiece> reading(String locale, String dimension, String band) {
    return find(
            "locale = ?1 and kind = 'reading' and dimension = ?2 and band = ?3",
            locale,
            dimension,
            band)
        .firstResultOptional();
  }

  /**
   * The paragraph a section reads for this reader.
   *
   * <p>Asked for the pair first and the single axis after: a section that
   * names a second dimension has nine paragraphs to choose between, and one
   * that does not still has three. The fallback is what keeps a half-written
   * section readable rather than blank.
   */
  public Optional<ReportPiece> dimension(
      String locale, String dimension, String band, String dimension2, String band2) {
    if (dimension2 != null) {
      Optional<ReportPiece> paired =
          find(
                  """
                  locale = ?1 and kind = 'dimension' and dimension = ?2 and band = ?3
                    and dimension2 = ?4 and band2 = ?5
                  """,
                  locale,
                  dimension,
                  band,
                  dimension2,
                  band2)
              .firstResultOptional();
      if (paired.isPresent()) {
        return paired;
      }
    }
    return find(
            """
            locale = ?1 and kind = 'dimension' and dimension = ?2 and band = ?3
              and dimension2 is null
            """,
            locale,
            dimension,
            band)
        .firstResultOptional();
  }

  public List<ReportPiece> skeletons(String locale) {
    return list("locale = ?1 and kind = 'skeleton'", Sort.by("section"), locale);
  }

  public List<ReportPiece> fragments(String locale, String archetypeId) {
    return list(
        "locale = ?1 and kind = 'fragment' and archetypeId = ?2",
        Sort.by("section"),
        locale,
        archetypeId);
  }

  public Optional<ReportPiece> limitation(String locale) {
    return find("locale = ?1 and kind = 'limitation'", locale).firstResultOptional();
  }
}
