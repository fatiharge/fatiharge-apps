package com.dafalabs.api.motto.feedback;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.feedback.dto.FeedbackKind;
import com.dafalabs.api.motto.feedback.dto.FeedbackRequest;
import io.quarkus.test.junit.QuarkusTest;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

@QuarkusTest
class FeedbacksTest {

  @Inject Feedbacks feedbacks;
  @Inject FeedbackRepository repository;

  @Transactional
  Feedback lastFor(UUID device) {
    return repository.find("deviceId", device).firstResult();
  }

  @Test
  @DisplayName("what someone wrote is stored against their device")
  void storesASubmission() {
    var device = UUID.randomUUID();

    feedbacks.submit(
        device,
        new FeedbackRequest(
            FeedbackKind.BUG, "Sorular yüklenmedi.", "a@b.com", Map.of("platform", "android")));

    var stored = lastFor(device);
    assertEquals("bug", stored.kind());
    assertEquals("Sorular yüklenmedi.", stored.message());
    assertEquals("a@b.com", stored.email());
  }

  @Test
  @DisplayName("a rejected archetype arrives here too, as its own kind")
  void storesARejection() {
    var device = UUID.randomUUID();

    feedbacks.submit(
        device,
        new FeedbackRequest(
            FeedbackKind.ARCHETYPE_REJECTED,
            "Hiç bana benzemiyor",
            null,
            Map.of("archetypeId", "quiet_builder")));

    // Which archetype gets rejected, and how often, is the only correction
    // signal the mapping table has.
    assertEquals("archetype_rejected", lastFor(device).kind());
  }

  @Test
  @DisplayName("no address is fine, and neither is a blank one")
  void emailStaysOptional() {
    var device = UUID.randomUUID();

    // Requiring it collapses the submission rate, and a blank string stored as
    // an address is one nobody can reply to and everybody has to check for.
    feedbacks.submit(device, new FeedbackRequest(FeedbackKind.OTHER, "Teşekkürler", "  ", null));

    assertNull(lastFor(device).email());
  }

  @Test
  @DisplayName("an address that is not one is refused")
  void refusesAMalformedEmail() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                feedbacks.submit(
                    UUID.randomUUID(),
                    new FeedbackRequest(FeedbackKind.BUG, "bir şey", "not-an-address", null)));

    assertEquals("invalid_email", refused.code());
  }

  @Test
  @DisplayName("an empty message is refused rather than stored as noise")
  void refusesAnEmptyMessage() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                feedbacks.submit(
                    UUID.randomUUID(),
                    new FeedbackRequest(FeedbackKind.SUGGESTION, "   ", null, null)));

    assertEquals("empty_feedback", refused.code());
  }

  @Test
  @DisplayName("the column is not a place to paste a log file")
  void refusesAnOversizedMessage() {
    var refused =
        assertThrows(
            CustomRuntimeException.class,
            () ->
                feedbacks.submit(
                    UUID.randomUUID(),
                    new FeedbackRequest(
                        FeedbackKind.BUG, "x".repeat(Feedbacks.maxMessage + 1), null, null)));

    assertEquals("feedback_too_long", refused.code());
  }
}
