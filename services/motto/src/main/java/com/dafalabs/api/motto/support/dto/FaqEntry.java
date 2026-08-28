package com.dafalabs.api.motto.support.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record FaqEntry(
    @Schema(required = true) String id,
    @Schema(required = true) String question,
    @Schema(required = true) String answer) {}
