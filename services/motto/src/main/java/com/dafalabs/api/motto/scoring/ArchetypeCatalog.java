package com.dafalabs.api.motto.scoring;

import com.dafalabs.api.motto.content.store.ArchetypeRow;
import com.dafalabs.api.motto.content.store.ContentStore;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * The words, read from the table the writers edit.
 *
 * <p>Read on every call rather than cached at startup: content changes while
 * the service is running now, and a cache filled once is a screen showing
 * yesterday's sentence with no way to tell.
 */
@ApplicationScoped
public class ArchetypeCatalog {

  private final ContentStore content;

  ArchetypeCatalog(ContentStore content) {
    this.content = content;
  }

  public Archetype byId(String id) {
    Archetype archetype = all().get(id);
    if (archetype == null) {
      // The rules and the words are separate tables, and this is what it looks
      // like when they stop agreeing.
      throw new IllegalStateException("no text for archetype " + id);
    }
    return archetype;
  }

  public Map<String, Archetype> all() {
    Map<String, Archetype> byId = new LinkedHashMap<>();
    for (ArchetypeRow row : content.archetypes()) {
      byId.put(row.id(), new Archetype(row.id(), row.name(), row.summary(), row.motto()));
    }
    return byId;
  }

  public List<Archetype> inOrder() {
    return List.copyOf(all().values());
  }

  public int size() {
    return content.archetypes().size();
  }
}
