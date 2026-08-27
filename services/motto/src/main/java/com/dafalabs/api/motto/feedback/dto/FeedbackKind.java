package com.dafalabs.api.motto.feedback.dto;

/**
 * What a piece of feedback is about.
 *
 * <p>A closed set rather than free text, because the only thing anyone will do
 * with this is read one kind at a time — and because {@link #ARCHETYPE_REJECTED}
 * is not a complaint, it is the correction signal for the mapping table.
 */
public enum FeedbackKind {
  BUG,
  SUGGESTION,
  CONTENT,
  ARCHETYPE_REJECTED,
  OTHER
}
