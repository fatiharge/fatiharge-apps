package com.dafalabs.api.motto.content.write;

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
 */
public final class WordGate {

  /// Stems, not whole words: Turkish suffixes walk straight past every one of
  /// these — "analizi", "değerlendirmen", "teşhisi".
  private static final Map<String, String> forbidden = new LinkedHashMap<>();

  static {
    forbidden.put("değerlendirme", "envanter temelli öneri");
    forbidden.put("analiz", "eğilim, örüntü");
    forbidden.put("teşhis", "eğilim, örüntü");
    forbidden.put("profil çıkarımı", "eğilim, örüntü");
    forbidden.put("kişilik testi", "kişilik envanteri");
    forbidden.put("test sonuc", "envanter temelli öneri");
    forbidden.put("tedavi", "sana iyi gelebilecek alışkanlık");
    forbidden.put("terapi", "sana iyi gelebilecek alışkanlık");
  }

  /// Saying "this is not a diagnosis" needs the word. Every exception is a
  /// denial; an assertion never belongs here.
  private static final List<String> allowed =
      List.of("bir teşhis, bir yetenek ölçümü", "hiçbir cümle bir teşhis değil");

  /// Turkish, because the dotted capital İ lowercases to i only under it.
  private static final Locale turkish = Locale.forLanguageTag("tr");

  private WordGate() {}

  /** What guideline 1.4.1 would object to, as sentences. Empty is the pass. */
  public static List<String> objections(String where, String... texts) {
    List<String> found = new ArrayList<>();
    for (String text : texts) {
      if (text == null) {
        continue;
      }
      String lowered = text.toLowerCase(turkish);
      for (String phrase : allowed) {
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
