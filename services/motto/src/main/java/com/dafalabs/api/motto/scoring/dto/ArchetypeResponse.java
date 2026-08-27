package com.dafalabs.api.motto.scoring.dto;

/** @param confident false when the answers were too few to separate the eight */
public record ArchetypeResponse(
    String id, String name, String summary, String motto, boolean confident) {}
