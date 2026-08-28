package com.dafalabs.api.motto.admin.dto;

import java.util.Map;

/** What the reset removed, per table, so the caller can see it happened. */
public record Wiped(Map<String, Integer> rows) {}
