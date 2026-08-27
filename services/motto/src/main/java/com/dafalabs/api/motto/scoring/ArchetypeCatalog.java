package com.dafalabs.api.motto.scoring;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;

/** The words, read from the file the writers edit. */
@ApplicationScoped
public class ArchetypeCatalog {

  private static final String RESOURCE = "content/archetypes.yaml";
  private static final String LANGUAGE = "tr";

  private final Map<String, Archetype> byId = new LinkedHashMap<>();

  @PostConstruct
  void load() {
    try (InputStream stream = Thread.currentThread().getContextClassLoader()
        .getResourceAsStream(RESOURCE)) {
      if (stream == null) {
        throw new IllegalStateException(RESOURCE + " is not on the classpath");
      }
      for (JsonNode node : new YAMLMapper().readTree(stream).withArray("archetypes")) {
        JsonNode text = node.get(LANGUAGE);
        String id = node.get("id").asText();
        byId.put(
            id,
            new Archetype(
                id,
                text.get("name").asText(),
                text.get("summary").asText(),
                text.get("motto").asText()));
      }
    } catch (IOException unreadable) {
      throw new IllegalStateException("could not read " + RESOURCE, unreadable);
    }
  }

  public Archetype byId(String id) {
    Archetype archetype = byId.get(id);
    if (archetype == null) {
      // The rules and the words are separate files, and this is what it looks
      // like when they stop agreeing.
      throw new IllegalStateException("no text for archetype " + id);
    }
    return archetype;
  }

  public int size() {
    return byId.size();
  }
}
