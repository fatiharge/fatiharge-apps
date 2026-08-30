package com.dafalabs.api.motto.support;

import com.dafalabs.api.motto.content.ContentVersion;
import com.dafalabs.api.motto.content.ContentLocale;
import com.dafalabs.api.motto.content.store.ContentStore;
import com.dafalabs.api.motto.content.store.SupportRow;
import com.dafalabs.api.motto.support.dto.DeletionCopy;
import com.dafalabs.api.motto.support.dto.FaqEntry;
import com.dafalabs.api.motto.support.dto.SupportCopy;
import jakarta.enterprise.context.ApplicationScoped;
import java.util.ArrayList;
import java.util.List;
import org.eclipse.microprofile.config.inject.ConfigProperty;

/**
 * The support copy, read from the table the writers edit.
 *
 * <p>Same shape as the content package and for the same reason: one wrong
 * answer here — the one about where somebody's data is — has to be correctable
 * without a release, and now without a deploy either.
 *
 * <p>Rows carry {@code kind}; deletion rows carry their list name in
 * {@code heading}, which is how four differently shaped pieces of copy fit one
 * table instead of four.
 */
@ApplicationScoped
public class SupportCatalog {

  private static final String faq = "faq";
  private static final String privacy = "privacy";
  private static final String deletion = "deletion";

  private final ContentStore content;
  private final String privacyPolicyUrl;

  SupportCatalog(
      ContentStore content,
      @ConfigProperty(
              name = "motto.privacy-policy-url",
              defaultValue = "https://dafalabs.com/motto/privacy")
          String privacyPolicyUrl) {
    this.content = content;
    this.privacyPolicyUrl = privacyPolicyUrl;
  }

  /**
   * @param locale what the reader asked for; support nobody has translated yet
   *     is answered in the fallback, because a blank privacy screen is worse
   *     than one in the wrong language
   */
  public SupportCopy copy(String locale) {
    String asked = ContentLocale.named(locale);
    List<SupportRow> mine = content.support(asked);
    String spoken = mine.isEmpty() ? ContentLocale.fallback : asked;
    List<SupportRow> rows = mine.isEmpty() ? content.support(spoken) : mine;

    List<String> privacyLines = new ArrayList<>();
    List<String> goes = new ArrayList<>();
    List<String> stays = new ArrayList<>();
    String counterReason = "";
    String answersNote = "";
    List<FaqEntry> faqEntries = new ArrayList<>();

    for (SupportRow row : rows) {
      switch (row.kind()) {
        case privacy -> privacyLines.add(row.body());
        case faq -> faqEntries.add(new FaqEntry(row.key(), row.heading(), row.body()));
        case deletion -> {
          switch (row.heading()) {
            case "goes" -> goes.add(row.body());
            case "stays" -> stays.add(row.body());
            case "counter_reason" -> counterReason = row.body();
            default -> answersNote = row.body();
          }
        }
        default -> { }
      }
    }

    return new SupportCopy(
        version(spoken, rows),
        privacyLines,
        new DeletionCopy(goes, stays, counterReason, answersNote),
        faqEntries,
        privacyPolicyUrl);
  }

  /// The language is in the hash, so a phone that changes language is never
  /// answered with a 304 holding the old one.
  private static String version(String locale, List<SupportRow> rows) {
    ContentVersion version = new ContentVersion().of(locale);
    for (SupportRow row : rows) {
      version.of(row.kind(), row.key(), row.heading(), row.body());
    }
    return version.toString();
  }
}
