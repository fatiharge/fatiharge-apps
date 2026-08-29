package com.dafalabs.api.motto.report;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.List;
import java.util.Optional;

@ApplicationScoped
public class ReportPieceRepository implements PanacheRepository<ReportPiece> {

  public Optional<ReportPiece> one(String kind, String archetypeId) {
    return find("kind = ?1 and archetypeId = ?2", kind, archetypeId).firstResultOptional();
  }

  /**
   * The slot a pushed piece addresses. Nulls are part of the address — half the
   * columns are unset on any given kind — so the comparison has to be
   * null-safe rather than equality.
   */
  public Optional<ReportPiece> inSlot(
      String kind, String archetypeId, String dimension, String band, Integer section) {
    return inSlot(kind, archetypeId, dimension, band, null, null, section);
  }

  public Optional<ReportPiece> inSlot(
      String kind,
      String archetypeId,
      String dimension,
      String band,
      String dimension2,
      String band2,
      Integer section) {
    return find(
            """
            kind = ?1
              and archetypeId is not distinct from ?2
              and dimension is not distinct from ?3
              and band is not distinct from ?4
              and dimension2 is not distinct from ?5
              and band2 is not distinct from ?6
              and section is not distinct from ?7
            """,
            kind,
            archetypeId,
            dimension,
            band,
            dimension2,
            band2,
            section)
        .firstResultOptional();
  }

  public long unwritten() {
    return count("placeholder");
  }

  public List<ReportPiece> allUnwritten() {
    return list("placeholder");
  }

  public Optional<ReportPiece> reading(String dimension, String band) {
    return find("kind = 'reading' and dimension = ?1 and band = ?2", dimension, band)
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
      String dimension, String band, String dimension2, String band2) {
    if (dimension2 != null) {
      Optional<ReportPiece> paired =
          find(
                  """
                  kind = 'dimension' and dimension = ?1 and band = ?2
                    and dimension2 = ?3 and band2 = ?4
                  """,
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
            "kind = 'dimension' and dimension = ?1 and band = ?2 and dimension2 is null",
            dimension,
            band)
        .firstResultOptional();
  }

  public List<ReportPiece> skeletons() {
    return list("kind = 'skeleton'", Sort.by("section"));
  }

  public List<ReportPiece> fragments(String archetypeId) {
    return list("kind = 'fragment' and archetypeId = ?1", Sort.by("section"), archetypeId);
  }

  public Optional<ReportPiece> limitation() {
    return find("kind = 'limitation'").firstResultOptional();
  }
}
