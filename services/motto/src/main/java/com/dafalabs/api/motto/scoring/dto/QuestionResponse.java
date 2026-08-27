package com.dafalabs.api.motto.scoring.dto;

import java.util.List;

/**
 * @param likertPoints how many points the scale has; the app draws that many
 * @param questions in the order they should be asked
 */
public record QuestionResponse(int likertPoints, List<Question> questions) {

  /**
   * @param id what an answer refers to
   * @param text what the person reads
   */
  public record Question(String id, String text) {}
}
