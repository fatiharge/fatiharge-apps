package com.dafalabs.api.motto.content.write;

/**
 * @param heading a question for FAQ rows, the list name for deletion rows,
 *     null for privacy lines
 */
public record SupportWrite(String kind, String key, String heading, String body, int ordinal) {}
