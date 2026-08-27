package com.dafalabs.api.motto.content.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Everything the app needs to build a day, in one response.
 *
 * <p>One package rather than five endpoints: the client assembles a day
 * offline, so it needs all of it or none of it, and five requests that can
 * half-succeed give it a fourth state to handle for no gain.
 *
 * @param version changes when any content file changes. The client sends it
 *     back and gets a 304 when there is nothing new.
 */
public record ContentBundle(
    @Schema(required = true) String version,
    @Schema(required = true) List<ArchetypeContent> archetypes,
    @Schema(required = true) List<MottoContent> mottos,
    @Schema(required = true) List<DailySkeleton> skeletons,
    @Schema(required = true) List<Fragment> fragments,
    @Schema(required = true) List<Connector> connectors) {}
