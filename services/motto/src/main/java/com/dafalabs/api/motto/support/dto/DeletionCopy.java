package com.dafalabs.api.motto.support.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param counterReason the one thing that survives. Said before the button,
 *     because finding it out afterwards is how a deletion screen becomes a
 *     review.
 */
public record DeletionCopy(
    @Schema(required = true) List<String> goes,
    @Schema(required = true) List<String> stays,
    @Schema(required = true) String counterReason,
    @Schema(required = true) String answersNote) {}
