package com.dafalabs.api.motto.content.store;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import java.util.List;

/**
 * Every word, read from the tables that hold them.
 *
 * <p>One place. Half the content used to be rows and half was on the
 * classpath, so a task could be corrected with a request and a motto needed a
 * release. Adding the nineteenth archetype is now a write, and so is the
 * thirty-second.
 */
@ApplicationScoped
public class ContentStore {

  /// The only language so far. On every table from the start, because adding
  /// the column later is a migration of all of them.
  public static final String locale = "tr";

  private final EntityManager entities;

  ContentStore(EntityManager entities) {
    this.entities = entities;
  }

  @Transactional
  public List<ArchetypeRow> archetypes() {
    return query(
        "select a from ArchetypeRow a where a.locale = :l order by a.ordinal", ArchetypeRow.class);
  }

  @Transactional
  public List<RuleRow> rules() {
    return entities
        .createQuery("select r from RuleRow r order by r.archetypeId", RuleRow.class)
        .getResultList();
  }

  @Transactional
  public List<ItemRow> activeItems() {
    return entities
        .createQuery(
            """
            select i from ItemRow i
            where i.locale = :l
              and i.version = (select s.version from ItemSetRow s where s.active = true)
            order by i.ordinal
            """,
            ItemRow.class)
        .setParameter("l", locale)
        .getResultList();
  }

  @Transactional
  public int activeItemVersion() {
    return entities
        .createQuery("select s.version from ItemSetRow s where s.active = true", Integer.class)
        .getSingleResult();
  }

  @Transactional
  public List<MottoRow> mottos() {
    return query(
        "select m from MottoRow m where m.locale = :l order by m.archetypeId, m.ordinal",
        MottoRow.class);
  }

  @Transactional
  public List<SkeletonRow> skeletons() {
    return query("select s from SkeletonRow s where s.locale = :l order by s.day", SkeletonRow.class);
  }

  @Transactional
  public List<FragmentRow> fragments() {
    return query(
        "select f from FragmentRow f where f.locale = :l order by f.archetypeId, f.ordinal",
        FragmentRow.class);
  }

  @Transactional
  public List<ConnectorRow> connectors() {
    return query("select c from ConnectorRow c where c.locale = :l order by c.id", ConnectorRow.class);
  }

  @Transactional
  public List<ReportSectionRow> reportSections() {
    return query(
        "select r from ReportSectionRow r where r.locale = :l order by r.section",
        ReportSectionRow.class);
  }

  @Transactional
  public List<SupportRow> support() {
    return query(
        "select s from SupportRow s where s.locale = :l order by s.kind, s.ordinal", SupportRow.class);
  }

  private <T> List<T> query(String jpql, Class<T> type) {
    return entities.createQuery(jpql, type).setParameter("l", locale).getResultList();
  }
}
