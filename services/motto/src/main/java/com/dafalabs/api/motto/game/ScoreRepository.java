package com.dafalabs.api.motto.game;

import io.quarkus.hibernate.orm.panache.PanacheRepository;
import io.quarkus.panache.common.Page;
import io.quarkus.panache.common.Sort;
import jakarta.enterprise.context.ApplicationScoped;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class ScoreRepository implements PanacheRepository<Score> {

  /// One row per device — a leaderboard where somebody holds three of the top
  /// ten places is a leaderboard nobody else plays.
  public List<Score> bestOfWeek(LocalDate week, int limit) {
    return getEntityManager()
        .createQuery(
            """
            select s from Score s
            where s.week = :week
              and s.points = (
                select max(b.points) from Score b
                where b.week = :week and b.deviceId = s.deviceId
              )
            order by s.points desc, s.id asc
            """,
            Score.class)
        .setParameter("week", week)
        .setMaxResults(limit * 4)
        .getResultList()
        .stream()
        .collect(
            java.util.stream.Collectors.toMap(
                Score::deviceId, score -> score, (first, second) -> first,
                java.util.LinkedHashMap::new))
        .values()
        .stream()
        .limit(limit)
        .toList();
  }

  public Score bestFor(UUID deviceId, LocalDate week) {
    return find("deviceId = ?1 and week = ?2", Sort.by("points", Sort.Direction.Descending),
            deviceId, week)
        .page(Page.ofSize(1))
        .firstResult();
  }
}
