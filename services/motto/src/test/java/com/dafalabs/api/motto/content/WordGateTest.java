package com.dafalabs.api.motto.content;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.dafalabs.api.motto.content.write.WordGate;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

/**
 * Guideline 1.4.1 reads the words, in whichever language they were submitted
 * in. A second language with only the first language's table would be a second
 * language that walks past the check.
 */
class WordGateTest {

  @Test
  @DisplayName("the Turkish table still catches Turkish stems through their suffixes")
  void catchesTurkishStems() {
    assertFalse(WordGate.objections("tr", "motto x", "Bu bir teşhistir.").isEmpty());
    assertFalse(WordGate.objections("tr", "motto x", "kişilik testi sonucun").isEmpty());
  }

  @Test
  @DisplayName("an English sentence is read against the English table")
  void catchesEnglishStems() {
    assertFalse(WordGate.objections("en", "motto x", "This is a diagnosis.").isEmpty());
    assertFalse(WordGate.objections("en", "motto x", "your personality test result").isEmpty());
    assertFalse(WordGate.objections("en", "motto x", "We analyse your answers.").isEmpty());
  }

  @Test
  @DisplayName("the two tables do not read each other's language")
  void tablesDoNotCross() {
    // The point of one table per language: a Turkish stem list has nothing to
    // say about "diagnosis", and running English copy through it would pass
    // every submission.
    assertTrue(WordGate.objections("tr", "motto x", "This is a diagnosis.").isEmpty());
    assertTrue(WordGate.objections("en", "motto x", "Bu bir teşhistir.").isEmpty());
  }

  @Test
  @DisplayName("saying it is not a diagnosis needs the word, in both languages")
  void deniersAreAllowed() {
    assertTrue(
        WordGate.objections("en", "support x", "This is not a diagnosis.").isEmpty());
    assertTrue(
        WordGate.objections("tr", "support x", "hiçbir cümle bir teşhis değil.").isEmpty());
  }

  @Test
  @DisplayName("a language with no table of its own is read against the fallback")
  void unknownLanguagesUseTheFallback() {
    List<String> found = WordGate.objections("de", "motto x", "Bu bir teşhistir.");
    assertEquals(1, found.size());
  }
}
