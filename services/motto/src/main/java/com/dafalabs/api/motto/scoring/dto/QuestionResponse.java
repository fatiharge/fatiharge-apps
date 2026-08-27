package com.dafalabs.api.motto.scoring.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param likertPoints how many points the scale has; the app draws that many
 * @param questions in the order they should be asked
 */
public record QuestionResponse(
    @Schema(required = true) int likertPoints,
    @Schema(required = true) List<Question> questions) {

  /**
   * @param id what an answer refers to
   * @param text what the person reads
   */
  public record Question(
      @Schema(required = true) String id,
      @Schema(required = true) String text) {}
}
