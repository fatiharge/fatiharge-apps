package com.dafalabs.api.motto.content;

import com.dafalabs.api.motto.content.dto.ArchetypeContent;
import com.dafalabs.api.motto.content.dto.Connector;
import com.dafalabs.api.motto.content.dto.ContentBundle;
import com.dafalabs.api.motto.content.dto.DailySkeleton;
import com.dafalabs.api.motto.content.dto.Fragment;
import com.dafalabs.api.motto.content.dto.MottoContent;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.dataformat.yaml.YAMLMapper;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.List;

/**
 * The words, read once at startup from the files the writers edit.
 *
 * <p>No tables and no seed migration, deliberately. The point of serving
 * content rather than shipping it inside the app is that a wording change does
 * not need a store release — and that is already true here, because the build
 * copies {@code content/} onto this service's classpath and a merge to main
 * deploys in minutes. Putting the same text in six tables would add a second
 * copy that can disagree with git, in exchange for the ability to edit copy by
 * hand in production, which is not something anyone should be able to do.
 *
 * <p>The version is a hash of the files themselves. Nothing to bump, nothing to
 * forget to bump.
 */
@ApplicationScoped
public class ContentCatalog {

  private static final String LANGUAGE = "tr";

  /// Order matters: the version is a hash over these, read in this sequence.
  private static final List<String> FILES =
      List.of(
          "content/archetypes.yaml",
          "content/mottos.yaml",
          "content/daily_skeletons.yaml",
          "content/fragments.yaml",
          "content/connectors.yaml");

  private ContentBundle bundle;

  @PostConstruct
  void load() {
    YAMLMapper yaml = new YAMLMapper();

    List<ArchetypeContent> archetypes = new ArrayList<>();
    for (JsonNode node : read(yaml, "content/archetypes.yaml").withArray("archetypes")) {
      JsonNode text = node.get(LANGUAGE);
      archetypes.add(
          new ArchetypeContent(
              node.get("id").asText(),
              text.get("name").asText(),
              text.get("summary").asText(),
              text.get("motto").asText()));
    }

    List<MottoContent> mottos = new ArrayList<>();
    for (JsonNode node : read(yaml, "content/mottos.yaml").withArray("mottos")) {
      JsonNode text = node.get(LANGUAGE);
      mottos.add(
          new MottoContent(
              node.get("id").asText(),
              node.get("archetype").asText(),
              text.get("motto").asText(),
              text.get("detail").asText(),
              text.get("reminder").asText()));
    }

    List<DailySkeleton> skeletons = new ArrayList<>();
    for (JsonNode node : read(yaml, "content/daily_skeletons.yaml").withArray("skeletons")) {
      JsonNode text = node.get(LANGUAGE);
      skeletons.add(
          new DailySkeleton(
              node.get("day").asInt(),
              text.get("title").asText(),
              text.get("body").asText(),
              text.get("action").asText()));
    }

    List<Fragment> fragments = new ArrayList<>();
    for (JsonNode node : read(yaml, "content/fragments.yaml").withArray("fragments")) {
      fragments.add(
          new Fragment(
              node.get("archetype").asText(),
              node.get("index").asInt(),
              node.get(LANGUAGE).asText()));
    }

    List<Connector> connectors = new ArrayList<>();
    for (JsonNode node : read(yaml, "content/connectors.yaml").withArray("connectors")) {
      connectors.add(new Connector(node.get("id").asText(), node.get(LANGUAGE).asText()));
    }

    bundle =
        new ContentBundle(version(), archetypes, mottos, skeletons, fragments, connectors);
  }

  public ContentBundle bundle() {
    return bundle;
  }

  public String version() {
    return bundle == null ? hashOfFiles() : bundle.version();
  }

  private JsonNode read(YAMLMapper yaml, String resource) {
    try (InputStream stream = open(resource)) {
      return yaml.readTree(stream);
    } catch (IOException unreadable) {
      throw new UncheckedIOException("could not read " + resource, unreadable);
    }
  }

  /// Derived rather than declared: a version someone has to remember to bump
  /// is a version that is wrong the first time somebody forgets.
  private String hashOfFiles() {
    try {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      for (String resource : FILES) {
        try (InputStream stream = open(resource)) {
          digest.update(stream.readAllBytes());
        }
      }
      return HexFormat.of().formatHex(digest.digest()).substring(0, 12);
    } catch (NoSuchAlgorithmException | IOException impossible) {
      throw new IllegalStateException(impossible);
    }
  }

  private InputStream open(String resource) {
    InputStream stream =
        Thread.currentThread().getContextClassLoader().getResourceAsStream(resource);
    if (stream == null) {
      throw new IllegalStateException(resource + " is not on the classpath");
    }
    return stream;
  }
}
