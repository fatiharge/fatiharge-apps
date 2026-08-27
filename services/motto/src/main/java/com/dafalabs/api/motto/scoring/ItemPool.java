package com.dafalabs.api.motto.scoring;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** The questions, read once from the file the writers edit. */
@ApplicationScoped
public class ItemPool {

  private static final String RESOURCE = "content/items.yaml";

  private final Map<String, Item> byId = new LinkedHashMap<>();
  private int likertPoints;

  @PostConstruct
  void load() {
    try (InputStream stream = Thread.currentThread().getContextClassLoader()
        .getResourceAsStream(RESOURCE)) {
      if (stream == null) {
        throw new IllegalStateException(RESOURCE + " is not on the classpath");
      }
      JsonNode root = new YAMLMapper().readTree(stream);
      likertPoints = root.path("likert").asInt(5);

      for (JsonNode node : root.withArray("items")) {
        Item item =
            new Item(
                node.get("id").asText(),
                Dimension.of(node.get("dimension").asText()),
                node.path("reverse").asBoolean(false),
                node.get("tr").asText());
        byId.put(item.id(), item);
      }
    } catch (IOException unreadable) {
      throw new IllegalStateException("could not read " + RESOURCE, unreadable);
    }
  }

  public List<Item> all() {
    return List.copyOf(byId.values());
  }

  public Item byId(String id) {
    return byId.get(id);
  }

  /** 1..likertPoints is what an answer may be. */
  public int likertPoints() {
    return likertPoints;
  }
}
