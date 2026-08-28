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
    return find(
            """
            kind = ?1
              and archetypeId is not distinct from ?2
              and dimension is not distinct from ?3
              and band is not distinct from ?4
              and section is not distinct from ?5
            """,
            kind,
            archetypeId,
            dimension,
            band,
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

  public Optional<ReportPiece> dimension(String dimension, String band) {
    return find("kind = 'dimension' and dimension = ?1 and band = ?2", dimension, band)
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
