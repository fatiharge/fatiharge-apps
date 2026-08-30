package com.dafalabs.api.motto.content;

import java.util.List;
import java.util.Set;

/**
 * Which language a request is asking for.
 *
 * <p>Read from `Accept-Language` and answered from a closed set. Anything else
 * gets Turkish: a phone set to a language nobody has written yet is better off
 * reading the language that exists than reading nothing.
 *
 * <p>Passed down as a parameter rather than injected. A request-scoped value
 * inside an application-scoped store is a value that is not there when a test
 * or a scheduled job asks, and this is asked for on every read.
 */
public final class ContentLocale {

  /// The one everything was written in, and the answer to any question this
  /// class cannot make sense of.
  public static final String fallback = "tr";

  public static final Set<String> supported = Set.of("tr", "en");

  private ContentLocale() {}

  /**
   * The best of what the client asked for.
   *
   * @param header the raw `Accept-Language`, which may be null, weighted, or
   *     name a country: `en-GB;q=0.9, tr;q=0.8` asks for English first
   */
  public static String from(String header) {
    if (header == null || header.isBlank()) {
      return fallback;
    }

    for (String candidate : ordered(header)) {
      String language = candidate.split("-")[0].toLowerCase();
      if (supported.contains(language)) {
        return language;
      }
    }
    return fallback;
  }

  /** Named, so a definition or a write can say which language it is in. */
  public static String named(String locale) {
    return locale != null && supported.contains(locale) ? locale : fallback;
  }

  /// Highest quality first. Ties keep the order they were written in, which is
  /// what the header already means.
  private static List<String> ordered(String header) {
    record Weighted(String tag, double weight, int position) {}

    List<Weighted> asked = new java.util.ArrayList<>();
    String[] parts = header.split(",");
    for (int i = 0; i < parts.length; i++) {
      String[] halves = parts[i].trim().split(";q=");
      if (halves[0].isBlank()) {
        continue;
      }
      double weight = 1;
      if (halves.length > 1) {
        try {
          weight = Double.parseDouble(halves[1].trim());
        } catch (NumberFormatException unreadable) {
          weight = 0;
        }
      }
      asked.add(new Weighted(halves[0].trim(), weight, i));
    }

    return asked.stream()
        .sorted(
            java.util.Comparator.comparingDouble(Weighted::weight)
                .reversed()
                .thenComparingInt(Weighted::position))
        .map(Weighted::tag)
        .toList();
  }
}
