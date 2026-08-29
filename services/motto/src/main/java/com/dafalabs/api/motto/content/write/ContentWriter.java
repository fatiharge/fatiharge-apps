package com.dafalabs.api.motto.content.write;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.scoring.ArchetypeRules;
import com.dafalabs.api.motto.scoring.Dimension;
import com.dafalabs.api.motto.scoring.ProfileVector;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

/**
 * Every word, on the way in.
 *
 * <p>Native upserts rather than entities: writing content is "this row, in
 * this slot, whatever was there before", which is one {@code ON CONFLICT} and
 * no Hibernate at all. The entities in {@code store} stay on the read side,
 * where objects are what the callers want.
 *
 * <p>Three things happen to every write. The words go past guideline 1.4.1;
 * the previous row is copied into {@code content_revisions}, because moving
 * out of the repository is what cost us the history and a table is what buys
 * it back; and, for rules, the whole set is re-checked so nothing lands that
 * makes an archetype unreachable.
 */
@ApplicationScoped
public class ContentWriter {

  private final EntityManager entities;
  private final ContentStore store;
  private final ObjectMapper json;

  ContentWriter(EntityManager entities, ContentStore store, ObjectMapper json) {
    this.entities = entities;
    this.store = store;
    this.json = json;
  }

  @Transactional
  public int archetypes(List<ArchetypeWrite> incoming) {
    for (ArchetypeWrite a : incoming) {
      gate("archetype " + a.id(), a.name(), a.summary(), a.motto());
      Map<Dimension, Double> target = targetOf(a);

      revise(
          "archetype",
          a.id(),
          "(SELECT to_jsonb(x) FROM archetypes x WHERE x.id = :id AND x.locale = :locale)",
          Map.of("id", a.id()),
          a);
      run(
          """
          INSERT INTO archetypes (id, locale, name, summary, motto, ordinal)
          VALUES (:id, :locale, :name, :summary, :motto, :ordinal)
          ON CONFLICT (id, locale) DO UPDATE
            SET name = :name, summary = :summary, motto = :motto, ordinal = :ordinal
          """,
          Map.of(
              "id", a.id(),
              "name", a.name(),
              "summary", a.summary(),
              "motto", a.motto(),
              "ordinal", a.ordinal()));
      run(
          """
          INSERT INTO archetype_rules (archetype_id, defining, openness, conscientiousness,
                                       extraversion, agreeableness, neuroticism)
          VALUES (:id, cast(:defining as text[]), :o, :c, :e, :a, :n)
          ON CONFLICT (archetype_id) DO UPDATE
            SET defining = cast(:defining as text[]), openness = :o, conscientiousness = :c,
                extraversion = :e, agreeableness = :a, neuroticism = :n
          """,
          Map.of(
              "id", a.id(),
              "defining", array(a.defining()),
              "o", target.get(Dimension.OPENNESS),
              "c", target.get(Dimension.CONSCIENTIOUSNESS),
              "e", target.get(Dimension.EXTRAVERSION),
              "a", target.get(Dimension.AGREEABLENESS),
              "n", target.get(Dimension.NEUROTICISM)));
    }

    // The rules just written are rows, not managed objects; anything the
    // session already holds would answer the reachability check from before.
    entities.clear();
    everyArchetypeStillReachable();
    return incoming.size();
  }

  /**
   * Refuses a set where some archetype cannot be reached in practice.
   *
   * <p>Two ways it happens. One archetype's point can sit inside another's
   * weighted pull, and then nobody is ever told they are it. Or two points can
   * sit so close that the difference is below what the inventory can measure —
   * four items on a five-point scale move a dimension by 1/16 at a time, so
   * two targets nearer than a couple of those steps are the same result told
   * two ways.
   *
   * <p>Nothing else in the product would report either one. It used to be a
   * test over a file; the file is gone, so it is a gate over the table.
   */
  private void everyArchetypeStillReachable() {
    List<ArchetypeRules.Rule> rules = new ArrayList<>();
    for (var row : store.rules()) {
      rules.add(ArchetypeRules.ruleOf(row.archetypeId(), row.defining(), row.target()));
    }

    for (ArchetypeRules.Rule rule : rules) {
      String winner = ArchetypeRules.nearest(new ProfileVector(rule.target()), rules);
      if (!rule.id().equals(winner)) {
        throw new CustomRuntimeException(
            400,
            "archetype_unreachable",
            "%s cannot be reached: %s wins at its own point. Move one of the two."
                .formatted(rule.id(), winner));
      }
    }

    for (int i = 0; i < rules.size(); i++) {
      for (int j = i + 1; j < rules.size(); j++) {
        double apart = apart(rules.get(i), rules.get(j));
        if (apart < minimumSeparation) {
          throw new CustomRuntimeException(
              400,
              "archetype_unreachable",
              "%s and %s are %.3f apart, closer than the inventory can tell (%.2f)."
                  .formatted(rules.get(i).id(), rules.get(j).id(), apart, minimumSeparation));
        }
      }
    }
  }

  /// About two steps of the finest thing the inventory can measure. The
  /// eighteen written so far sit at least 0.39 apart, so this is a floor and
  /// not a ceiling on how many there can be.
  private static final double minimumSeparation = 0.15;

  private static double apart(ArchetypeRules.Rule one, ArchetypeRules.Rule other) {
    double sum = 0;
    for (Dimension dimension : Dimension.values()) {
      double gap =
          one.target().getOrDefault(dimension, 0.5)
              - other.target().getOrDefault(dimension, 0.5);
      sum += gap * gap;
    }
    return Math.sqrt(sum);
  }

  @Transactional
  public int items(ItemSetWrite set) {
    for (ItemWrite item : set.items()) {
      gate("item " + item.id(), item.text());
      Dimension.of(item.dimension());
    }

    run(
        "INSERT INTO item_sets (version) VALUES (:v) ON CONFLICT (version) DO NOTHING",
        Map.of("v", set.version()));

    for (ItemWrite item : set.items()) {
      revise(
          "item",
          set.version() + "/" + item.id(),
          """
          (SELECT to_jsonb(x) FROM items x
            WHERE x.id = :id AND x.version = :v AND x.locale = :locale)
          """,
          Map.of("id", item.id(), "v", set.version()),
          item);
      run(
          """
          INSERT INTO items (id, version, locale, dimension, reverse, text, ordinal)
          VALUES (:id, :v, :locale, :dimension, :reverse, :text, :ordinal)
          ON CONFLICT (id, version, locale) DO UPDATE
            SET dimension = :dimension, reverse = :reverse, text = :text, ordinal = :ordinal
          """,
          Map.of(
              "id", item.id(),
              "v", set.version(),
              "dimension", item.dimension().toUpperCase(java.util.Locale.ROOT),
              "reverse", item.reverse(),
              "text", item.text(),
              "ordinal", item.ordinal()));
    }

    if (set.activate()) {
      // One active set, enforced by a partial unique index, so the old one has
      // to stand down in the same statement pair as the new one stands up.
      run("UPDATE item_sets SET active = false WHERE active", Map.of());
      run("UPDATE item_sets SET active = true WHERE version = :v", Map.of("v", set.version()));
    }
    return set.items().size();
  }

  @Transactional
  public int mottos(List<MottoWrite> incoming) {
    for (MottoWrite m : incoming) {
      gate("motto " + m.id(), m.motto(), m.detail(), m.reminder());
      revise(
          "motto",
          m.id(),
          "(SELECT to_jsonb(x) FROM mottos x WHERE x.id = :id AND x.locale = :locale)",
          Map.of("id", m.id()),
          m);
      run(
          """
          INSERT INTO mottos (id, locale, archetype_id, motto, detail, reminder, ordinal)
          VALUES (:id, :locale, :archetype, :motto, :detail, :reminder, :ordinal)
          ON CONFLICT (id, locale) DO UPDATE
            SET archetype_id = :archetype, motto = :motto, detail = :detail,
                reminder = :reminder, ordinal = :ordinal
          """,
          Map.of(
              "id", m.id(),
              "archetype", m.archetypeId(),
              "motto", m.motto(),
              "detail", m.detail(),
              "reminder", m.reminder(),
              "ordinal", m.ordinal()));
    }
    return incoming.size();
  }

  @Transactional
  public int skeletons(List<SkeletonWrite> incoming) {
    for (SkeletonWrite s : incoming) {
      gate("day " + s.day(), s.title(), s.body(), s.action());
      revise(
          "skeleton",
          String.valueOf(s.day()),
          "(SELECT to_jsonb(x) FROM day_skeletons x WHERE x.day = :day AND x.locale = :locale)",
          Map.of("day", s.day()),
          s);
      run(
          """
          INSERT INTO day_skeletons (day, locale, title, body, action)
          VALUES (:day, :locale, :title, :body, :action)
          ON CONFLICT (day, locale) DO UPDATE
            SET title = :title, body = :body, action = :action
          """,
          Map.of(
              "day", s.day(),
              "title", s.title(),
              "body", s.body(),
              "action", s.action()));
    }
    return incoming.size();
  }

  @Transactional
  public int fragments(List<FragmentWrite> incoming) {
    for (FragmentWrite f : incoming) {
      gate("fragment " + f.archetypeId() + "/" + f.ordinal(), f.text());
      revise(
          "fragment",
          f.archetypeId() + "/" + f.ordinal(),
          """
          (SELECT to_jsonb(x) FROM fragments x
            WHERE x.archetype_id = :archetype AND x.ordinal = :ordinal AND x.locale = :locale)
          """,
          Map.of("archetype", f.archetypeId(), "ordinal", f.ordinal()),
          f);
      run(
          """
          INSERT INTO fragments (archetype_id, ordinal, locale, text)
          VALUES (:archetype, :ordinal, :locale, :text)
          ON CONFLICT (archetype_id, ordinal, locale) DO UPDATE SET text = :text
          """,
          Map.of("archetype", f.archetypeId(), "ordinal", f.ordinal(), "text", f.text()));
    }
    return incoming.size();
  }

  @Transactional
  public int connectors(List<ConnectorWrite> incoming) {
    for (ConnectorWrite c : incoming) {
      gate("connector " + c.id(), c.text());
      revise(
          "connector",
          c.id(),
          "(SELECT to_jsonb(x) FROM connectors x WHERE x.id = :id AND x.locale = :locale)",
          Map.of("id", c.id()),
          c);
      run(
          """
          INSERT INTO connectors (id, locale, text) VALUES (:id, :locale, :text)
          ON CONFLICT (id, locale) DO UPDATE SET text = :text
          """,
          Map.of("id", c.id(), "text", c.text()));
    }
    return incoming.size();
  }

  @Transactional
  public int sections(List<SectionWrite> incoming) {
    for (SectionWrite s : incoming) {
      Dimension.of(s.dimension());
      if (s.dimension2() != null) {
        Dimension.of(s.dimension2());
      }
      revise(
          "section",
          String.valueOf(s.section()),
          """
          (SELECT to_jsonb(x) FROM report_sections x
            WHERE x.section = :section AND x.locale = :locale)
          """,
          Map.of("section", s.section()),
          s);
      Query query =
          entities
              .createNativeQuery(
                  """
                  INSERT INTO report_sections (section, locale, dimension, dimension_2)
                  VALUES (:section, :locale, :dimension, :second)
                  ON CONFLICT (section, locale) DO UPDATE
                    SET dimension = :dimension, dimension_2 = :second
                  """)
              .setParameter("section", s.section())
              .setParameter("locale", ContentStore.locale)
              .setParameter("dimension", s.dimension().toUpperCase(java.util.Locale.ROOT))
              // Spelled out rather than run through the helper: a section that
              // reads one axis has no second, and Map.of has no null.
              .setParameter(
                  "second",
                  s.dimension2() == null
                      ? null
                      : s.dimension2().toUpperCase(java.util.Locale.ROOT));
      query.executeUpdate();
    }
    return incoming.size();
  }

  @Transactional
  public int support(List<SupportWrite> incoming) {
    for (SupportWrite s : incoming) {
      gate("support " + s.kind() + "/" + s.key(), s.heading(), s.body());
      revise(
          "support",
          s.kind() + "/" + s.key(),
          """
          (SELECT to_jsonb(x) FROM support_texts x
            WHERE x.kind = :kind AND x.key = :key AND x.locale = :locale)
          """,
          Map.of("kind", s.kind(), "key", s.key()),
          s);
      Query query =
          entities
              .createNativeQuery(
                  """
                  INSERT INTO support_texts (kind, key, locale, heading, body, ordinal)
                  VALUES (:kind, :key, :locale, :heading, :body, :ordinal)
                  ON CONFLICT (kind, key, locale) DO UPDATE
                    SET heading = :heading, body = :body, ordinal = :ordinal
                  """)
              .setParameter("kind", s.kind())
              .setParameter("key", s.key())
              .setParameter("locale", ContentStore.locale)
              // Spelled out rather than run through the helper below: a
              // privacy line has no heading, and Map.of has no null.
              .setParameter("heading", s.heading())
              .setParameter("body", s.body())
              .setParameter("ordinal", s.ordinal());
      query.executeUpdate();
    }
    return incoming.size();
  }

  private void gate(String where, String... texts) {
    List<String> objections = WordGate.objections(where, texts);
    if (!objections.isEmpty()) {
      throw new CustomRuntimeException(400, "forbidden_words", String.join("; ", objections));
    }
  }

  private static Map<Dimension, Double> targetOf(ArchetypeWrite a) {
    Map<Dimension, Double> target = new EnumMap<>(Dimension.class);
    a.target().forEach((name, value) -> target.put(Dimension.of(name), value));
    for (Dimension dimension : Dimension.values()) {
      Double value = target.get(dimension);
      if (value == null || value < 0 || value > 1) {
        throw new CustomRuntimeException(
            400,
            "target_incomplete",
            "%s needs a %s between 0 and 1".formatted(a.id(), dimension.name().toLowerCase(
                java.util.Locale.ROOT)));
      }
    }
    return target;
  }

  private static String array(List<String> defining) {
    defining.forEach(Dimension::of);
    return "{" + String.join(",", defining) + "}";
  }

  private void revise(
      String entity, String key, String snapshot, Map<String, Object> binds, Object now) {
    Query query =
        entities.createNativeQuery(
            """
            INSERT INTO content_revisions (entity, entity_key, locale, was, now)
            VALUES (:entity, :key, :locale, %s, cast(:now as jsonb))
            """
                .formatted(snapshot));
    binds.forEach(query::setParameter);
    query
        .setParameter("entity", entity)
        .setParameter("key", key)
        .setParameter("locale", ContentStore.locale)
        .setParameter("now", asJson(now))
        .executeUpdate();
  }

  private void run(String sql, Map<String, Object> binds) {
    Query query = entities.createNativeQuery(sql);
    binds.forEach(query::setParameter);
    // Named on the statement or not bound at all: Hibernate rejects a
    // parameter the SQL never mentions.
    if (sql.contains(":locale")) {
      query.setParameter("locale", ContentStore.locale);
    }
    query.executeUpdate();
  }

  private String asJson(Object value) {
    try {
      return json.writeValueAsString(value);
    } catch (JsonProcessingException impossible) {
      throw new IllegalStateException(impossible);
    }
  }
}
