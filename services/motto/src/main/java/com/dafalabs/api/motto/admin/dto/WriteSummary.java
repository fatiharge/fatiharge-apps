package com.dafalabs.api.motto.admin.dto;

/** What a push did, so the tooling can print it rather than guess. */
public record WriteSummary(int written, int placeholders) {}
