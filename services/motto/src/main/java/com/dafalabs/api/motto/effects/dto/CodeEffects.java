package com.dafalabs.api.motto.effects.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * One refusal and what it leads to.
 *
 * @param definition the effect list as the app reads it. Carried as text
 *     rather than typed here: it is a tree the transport has no opinion about,
 *     and typing it in the contract would put the same recursion in three
 *     generated clients for nothing
 */
public record CodeEffects(
    @Schema(required = true) String code, @Schema(required = true) String definition) {}
