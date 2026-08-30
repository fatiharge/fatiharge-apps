package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class ContentLocaleTest {

  @Test
  @DisplayName("a phone that asks for nothing gets what everything was written in")
  void nothingAskedIsTurkish() {
    assertEquals("tr", ContentLocale.from(null));
    assertEquals("tr", ContentLocale.from("  "));
  }

  @Test
  @DisplayName("a country is still a language")
  void regionIsIgnored() {
    assertEquals("en", ContentLocale.from("en-GB"));
  }

  @Test
  @DisplayName("the one it wants most, not the one it names first")
  void weightsDecide() {
    // `de` first but wanted least; English beats Turkish here.
    assertEquals("en", ContentLocale.from("de;q=1.0, tr;q=0.5, en;q=0.9"));
  }

  @Test
  @DisplayName("a language nobody has written yet reads the one that exists")
  void unsupportedFallsBack() {
    // Empty is worse than foreign: somebody who set their phone to German is
    // better off reading Turkish than reading nothing at all.
    assertEquals("tr", ContentLocale.from("de-DE, fr;q=0.8"));
  }

  @Test
  @DisplayName("a malformed weight is not a preference")
  void unreadableWeightLoses() {
    assertEquals("tr", ContentLocale.from("en;q=abc, tr"));
  }

  @Test
  @DisplayName("a name is checked rather than trusted")
  void namedIsChecked() {
    assertEquals("en", ContentLocale.named("en"));
    assertEquals("tr", ContentLocale.named(null));
    assertEquals("tr", ContentLocale.named("klingon"));
  }
}
