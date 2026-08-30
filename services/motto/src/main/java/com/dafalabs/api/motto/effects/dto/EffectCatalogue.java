package com.dafalabs.api.motto.effects.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Everything this app knows how to answer, and a version to cache it by.
 *
 * @param version a hash of the definitions, so a phone that already has them
 *     asks and is told nothing changed
 */
public record EffectCatalogue(
    @Schema(required = true) String version,
    @Schema(required = true) List<CodeEffects> codes) {}
