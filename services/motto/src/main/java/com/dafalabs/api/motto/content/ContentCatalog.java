package com.dafalabs.api.motto.content;

import com.dafalabs.api.motto.content.dto.ArchetypeContent;
import com.dafalabs.api.motto.content.dto.Connector;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.dto.DailySkeleton;
import com.dafalabs.api.motto.content.dto.Fragment;
import com.dafalabs.api.motto.content.dto.MottoContent;
import com.dafalabs.api.motto.content.store.ArchetypeRow;
import com.dafalabs.api.motto.content.store.ConnectorRow;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.FragmentRow;
import com.dafalabs.api.motto.content.store.MottoRow;
import com.dafalabs.api.motto.content.store.SkeletonRow;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * The words, read from the tables the writers edit.
 *
 * <p>Read per request rather than cached: content changes while the service
 * runs, and a cache filled at startup is a screen showing yesterday's sentence
 * with no way to tell.
 *
 * <p>The version is a hash of what was read — see {@link ContentVersion}.
 */
@ApplicationScoped
public class ContentCatalog {

  private final ContentStore content;

  ContentCatalog(ContentStore content) {
    this.content = content;
  }

  /**
   * @param locale what the reader asked for; a language nobody has written yet
   *     is answered in the fallback rather than with an empty package
   */
  public ContentBundle bundle(String locale) {
    String spoken = spoken(locale);
    List<ArchetypeContent> archetypes = new ArrayList<>();
    for (ArchetypeRow row : content.archetypes(spoken)) {
      archetypes.add(
          new ArchetypeContent(row.id(), row.name(), row.summary(), row.motto()));
    }

    List<MottoContent> mottos = new ArrayList<>();
    for (MottoRow row : content.mottos(spoken)) {
      mottos.add(
          new MottoContent(
              row.id(), row.archetypeId(), row.motto(), row.detail(), row.reminder()));
    }

    List<DailySkeleton> skeletons = new ArrayList<>();
    for (SkeletonRow row : content.skeletons(spoken)) {
      skeletons.add(new DailySkeleton(row.day(), row.title(), row.body(), row.action()));
    }

    List<Fragment> fragments = new ArrayList<>();
    for (FragmentRow row : content.fragments(spoken)) {
      fragments.add(new Fragment(row.archetypeId(), row.ordinal(), row.text()));
    }

    List<Connector> connectors = new ArrayList<>();
    for (ConnectorRow row : content.connectors(spoken)) {
      connectors.add(new Connector(row.id(), row.text()));
    }

    return new ContentBundle(
        version(spoken, archetypes, mottos, skeletons, fragments, connectors),
        archetypes,
        mottos,
        skeletons,
        fragments,
        connectors);
  }

  /**
   * The language this package will actually be in.
   *
   * <p>All of it or none of it. Half a package in the reader's language and
   * half in Turkish is a day whose title and body disagree, and there is no
   * screen that survives that; a whole package in the wrong language at least
   * reads.
   */
  private String spoken(String locale) {
    String asked = ContentLocale.named(locale);
    return content.archetypes(asked).isEmpty() ? ContentLocale.fallback : asked;
  }

  /// Over the values rather than the row count: renaming an archetype has to
  /// change the version, and it does not move a single row. The language is in
  /// it too, so switching phone language is never answered with a 304.
  private static String version(
      String locale,
      List<ArchetypeContent> archetypes,
      List<MottoContent> mottos,
      List<DailySkeleton> skeletons,
      List<Fragment> fragments,
      List<Connector> connectors) {
    ContentVersion version = new ContentVersion().of(locale);
    archetypes.forEach(a -> version.of(a.id(), a.name(), a.summary(), a.motto()));
    mottos.forEach(
        m -> version.of(m.id(), m.archetypeId(), m.motto(), m.detail(), m.reminder()));
    skeletons.forEach(s -> version.of(s.title(), s.body(), s.action()).of(s.day()));
    fragments.forEach(f -> version.of(f.archetypeId(), f.text()).of(f.index()));
    connectors.forEach(c -> version.of(c.id(), c.text()));
    return version.toString();
  }
}
