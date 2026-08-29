package com.dafalabs.api.motto.content.write;

public record MottoWrite(
    String id, String archetypeId, String motto, String detail, String reminder, int ordinal) {}
