package com.dafalabs.api.motto.content.write;

import com.dafalabs.api.motto.content.ContentLocale;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * The App Review 1.4.1 word table, on the way in.
 *
 * <p>It used to be a script over the files. The files are gone, so the check
 * moved to the only door the words come through: guideline 1.4.1 reads a
 * health claim off the words used rather than off what was meant, and a
 * sentence typed into an admin request is as visible to a reviewer as one that
 * was committed.
 *
 * <p>One table per language. A reviewer reads the English submission in
 * English, and a Turkish stem list has nothing to say about the word
 * "diagnosis" — a second language with no gate of its own would be a second
 * language that walks past the check.
 */
public final class WordGate {

  /// Stems, not whole words: Turkish suffixes walk straight past every one of
  /// these — "analizi", "değerlendirmen", "teşhisi".
  private static final Map<String, String> turkishForbidden = new LinkedHashMap<>();

  static {
    turkishForbidden.put("değerlendirme", "envanter temelli öneri");
    turkishForbidden.put("analiz", "eğilim, örüntü");
    turkishForbidden.put("teşhis", "eğilim, örüntü");
    turkishForbidden.put("profil çıkarımı", "eğilim, örüntü");
    turkishForbidden.put("kişilik testi", "kişilik envanteri");
    turkishForbidden.put("test sonuc", "envanter temelli öneri");
    turkishForbidden.put("tedavi", "sana iyi gelebilecek alışkanlık");
    turkishForbidden.put("terapi", "sana iyi gelebilecek alışkanlık");
  }

  /// Stems again: "diagnosing", "assessed", "analysing" all start here.
  private static final Map<String, String> englishForbidden = new LinkedHashMap<>();

  static {
    englishForbidden.put("diagnos", "tendency, pattern");
    englishForbidden.put("assess", "inventory-based suggestion");
    englishForbidden.put("analys", "tendency, pattern");
    englishForbidden.put("analyz", "tendency, pattern");
    englishForbidden.put("evaluat", "inventory-based suggestion");
    englishForbidden.put("personality test", "personality inventory");
    englishForbidden.put("test result", "inventory-based suggestion");
    englishForbidden.put("treatment", "a habit that may suit you");
    englishForbidden.put("therapy", "a habit that may suit you");
    englishForbidden.put("disorder", "tendency, pattern");
    englishForbidden.put("symptom", "tendency, pattern");
  }

  /// Saying "this is not a diagnosis" needs the word. Every exception is a
  /// denial; an assertion never belongs here.
  private static final Map<String, List<String>> allowed =
      Map.of(
          "tr",
          List.of("bir teşhis, bir yetenek ölçümü", "hiçbir cümle bir teşhis değil"),
          "en",
          List.of("not a diagnosis", "no sentence here is a diagnosis"));

  /// Turkish, because the dotted capital İ lowercases to i only under it.
  private static final Locale turkish = Locale.forLanguageTag("tr");

  private WordGate() {}

  /** What guideline 1.4.1 would object to, as sentences. Empty is the pass. */
  public static List<String> objections(String locale, String where, String... texts) {
    String language = ContentLocale.named(locale);
    Map<String, String> forbidden =
        "en".equals(language) ? englishForbidden : turkishForbidden;
    Locale casing = "en".equals(language) ? Locale.ENGLISH : turkish;

    List<String> found = new ArrayList<>();
    for (String text : texts) {
      if (text == null) {
        continue;
      }
      String lowered = text.toLowerCase(casing);
      for (String phrase : allowed.getOrDefault(language, List.of())) {
        lowered = lowered.replace(phrase, "");
      }
      for (Map.Entry<String, String> entry : forbidden.entrySet()) {
        if (lowered.contains(entry.getKey())) {
          found.add(
              "%s: \"%s\" — use %s".formatted(where, entry.getKey(), entry.getValue()));
        }
      }
    }
    return found;
  }
}
