package com.dafalabs.api.motto.support;

import com.dafalabs.api.motto.support.dto.DeletionCopy;
import com.dafalabs.api.motto.support.dto.FaqEntry;
import com.dafalabs.api.motto.support.dto.SupportCopy;
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
import org.eclipse.microprofile.config.inject.ConfigProperty;

/**
 * The support copy, read once at startup from the file the writers edit.
 *
 * <p>Same shape as the content package and for the same reason: no tables, and
 * a version that is a hash of the file so there is nothing to remember to bump.
 */
@ApplicationScoped
public class SupportCatalog {

  private static final String RESOURCE = "content/support.yaml";
  private static final String LANGUAGE = "tr";

  private final String privacyPolicyUrl;

  private SupportCopy copy;

  SupportCatalog(
      @ConfigProperty(
              name = "motto.privacy-policy-url",
              defaultValue = "https://dafalabs.com/motto/privacy")
          String privacyPolicyUrl) {
    this.privacyPolicyUrl = privacyPolicyUrl;
  }

  @PostConstruct
  void load() {
    JsonNode root = read();

    List<String> privacy = new ArrayList<>();
    for (JsonNode line : root.get("privacy").get(LANGUAGE)) {
      privacy.add(line.asText());
    }

    JsonNode deletion = root.get("deletion").get(LANGUAGE);
    DeletionCopy deletionCopy =
        new DeletionCopy(
            texts(deletion.get("goes")),
            texts(deletion.get("stays")),
            deletion.get("counter_reason").asText(),
            deletion.get("answers_note").asText());

    List<FaqEntry> faq = new ArrayList<>();
    for (JsonNode entry : root.withArray("faq")) {
      JsonNode text = entry.get(LANGUAGE);
      faq.add(
          new FaqEntry(
              entry.get("id").asText(),
              text.get("question").asText(),
              text.get("answer").asText()));
    }

    copy = new SupportCopy(version(), privacy, deletionCopy, faq, privacyPolicyUrl);
  }

  public SupportCopy copy() {
    return copy;
  }

  private static List<String> texts(JsonNode array) {
    List<String> values = new ArrayList<>();
    for (JsonNode node : array) {
      values.add(node.asText());
    }
    return values;
  }

  private JsonNode read() {
    try (InputStream stream = open()) {
      return new YAMLMapper().readTree(stream);
    } catch (IOException unreadable) {
      throw new UncheckedIOException("could not read " + RESOURCE, unreadable);
    }
  }

  private String version() {
    try (InputStream stream = open()) {
      MessageDigest digest = MessageDigest.getInstance("SHA-256");
      digest.update(stream.readAllBytes());
      return HexFormat.of().formatHex(digest.digest()).substring(0, 12);
    } catch (NoSuchAlgorithmException | IOException impossible) {
      throw new IllegalStateException(impossible);
    }
  }

  private InputStream open() {
    InputStream stream =
        Thread.currentThread().getContextClassLoader().getResourceAsStream(RESOURCE);
    if (stream == null) {
      throw new IllegalStateException(RESOURCE + " is not on the classpath");
    }
    return stream;
  }
}
