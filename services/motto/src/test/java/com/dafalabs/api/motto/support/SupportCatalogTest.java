package com.dafalabs.api.motto.support;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.support.dto.FaqEntry;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import java.util.List;
import java.util.stream.Collectors;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class SupportCatalogTest {

  @Inject SupportCatalog catalog;

  @Test
  @DisplayName("the copy carries everything the support screens show")
  void carriesEveryPiece() {
    var copy = catalog.copy();

    assertFalse(copy.privacy().isEmpty());
    assertFalse(copy.faq().isEmpty());
    assertFalse(copy.deletion().goes().isEmpty());
    assertFalse(copy.deletion().stays().isEmpty());
    assertFalse(copy.deletion().counterReason().isEmpty());
  }

  @Test
  @DisplayName("the questions people actually ask are all answered")
  void theHardQuestionsAreAnswered() {
    List<String> ids = catalog.copy().faq().stream().map(FaqEntry::id).toList();

    // Below twelve the complaints this exists to absorb start arriving as
    // store reviews instead.
    assertTrue(catalog.copy().faq().size() >= 12);
    assertTrue(ids.containsAll(List.of("lost_data", "delete_data", "not_me", "chain_broken")));
  }

  @Test
  @DisplayName("ids are unique, or a link would be ambiguous")
  void idsAreUnique() {
    var ids = catalog.copy().faq().stream().map(FaqEntry::id).collect(Collectors.toSet());

    assertEquals(catalog.copy().faq().size(), ids.size());
  }

  @Test
  @DisplayName("the version is derived, so nobody has to remember to bump it")
  void versionIsDerived() {
    assertEquals(12, catalog.copy().version().length());
  }

  @Test
  @DisplayName("the policy URL is the one the store listing gets")
  void carriesThePolicyUrl() {
    assertTrue(catalog.copy().privacyPolicyUrl().startsWith("https://"));
  }
}
