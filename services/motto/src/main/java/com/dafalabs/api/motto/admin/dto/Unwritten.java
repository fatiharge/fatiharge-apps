package com.dafalabs.api.motto.admin.dto;

import java.util.List;

/** What is still a stand-in, so the writing job is a request rather than a query. */
public record Unwritten(int tasks, int reportPieces, List<String> slots) {}
