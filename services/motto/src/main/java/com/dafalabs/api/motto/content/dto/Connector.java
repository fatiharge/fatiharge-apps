package com.dafalabs.api.motto.content.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** The hand-written join between a body and a fragment. */
public record Connector(
    @Schema(required = true) String id,
    @Schema(required = true) String text) {}
