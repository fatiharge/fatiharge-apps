package com.dafalabs.api.motto.feedback.dto;

import java.util.Map;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param kind what this is about
 * @param message what they wrote. For a rejected archetype, which of the three
 *     reasons they picked.
 * @param email optional, and it stays optional: requiring it collapses the
 *     submission rate, and most of what arrives here needs reading rather than
 *     answering.
 * @param context app version, platform, OS version, current archetype —
 *     attached by the app so nobody has to be asked "which version?"
 */
public record FeedbackRequest(
    @Schema(required = true) FeedbackKind kind,
    @Schema(required = true) String message,
    String email,
    Map<String, String> context) {}
