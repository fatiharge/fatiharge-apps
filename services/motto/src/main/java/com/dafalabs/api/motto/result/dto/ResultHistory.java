package com.dafalabs.api.motto.result.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record ResultHistory(@Schema(required = true) List<ResultSummary> results) {}
