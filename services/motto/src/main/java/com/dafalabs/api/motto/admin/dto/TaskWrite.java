package com.dafalabs.api.motto.admin.dto;

/** One task, addressed by the slot it fills. */
public record TaskWrite(
    int day, String archetypeId, int ordinal, String title, String detail, boolean placeholder) {}
