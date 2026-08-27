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
