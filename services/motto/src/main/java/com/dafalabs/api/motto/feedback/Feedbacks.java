package com.dafalabs.api.motto.feedback;

import com.dafalabs.api.core.error.CustomRuntimeException;
import com.dafalabs.api.motto.feedback.dto.FeedbackRequest;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.Map;
import java.util.UUID;

/** Stores what people tell us. */
@ApplicationScoped
public class Feedbacks {

  /// Long enough for a real report, short enough that the column is not a
  /// place to paste a log file.
  static final int maxMessage = 4000;

  static final int maxEmail = 320;

  private final FeedbackRepository repository;
  private final ObjectMapper json;

  Feedbacks(FeedbackRepository repository, ObjectMapper json) {
    this.repository = repository;
    this.json = json;
  }

  @Transactional
  public void submit(UUID deviceId, FeedbackRequest request) {
    String message = request.message() == null ? "" : request.message().strip();
    if (message.isEmpty()) {
      throw new CustomRuntimeException(400, "empty_feedback", "There is nothing to send.");
    }
    if (message.length() > maxMessage) {
      throw new CustomRuntimeException(
          400, "feedback_too_long", "At most %d characters.".formatted(maxMessage));
    }

    String email = normalise(request.email());

    repository.persist(
        Feedback.of(
            deviceId,
            request.kind().name().toLowerCase(java.util.Locale.ROOT),
            message,
            email,
            serialise(request.context())));
  }

  /// Blank is the same as absent. An empty string stored as an address is one
  /// nobody can reply to and everybody has to check for.
  private String normalise(String email) {
    if (email == null) {
      return null;
    }
    String trimmed = email.strip();
    if (trimmed.isEmpty()) {
      return null;
    }
    if (trimmed.length() > maxEmail || !trimmed.contains("@")) {
      throw new CustomRuntimeException(400, "invalid_email", "That is not an address.");
    }
    return trimmed;
  }

  private String serialise(Map<String, String> context) {
    try {
      return json.writeValueAsString(context == null ? Map.of() : context);
    } catch (JsonProcessingException impossible) {
      throw new IllegalStateException(impossible);
    }
  }
}
