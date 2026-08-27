package com.dafalabs.api.motto.report.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param locked true when this device has not paid for it. The preview is what
 *     someone sees before buying, and it is the only thing they see.
 * @param sections empty while locked
 */
public record DeepReport(
    @Schema(required = true) long resultId,
    @Schema(required = true) String archetypeId,
    @Schema(required = true) boolean locked,
    @Schema(required = true) String preview,
    @Schema(required = true) List<ReportSection> sections,
    String portrait,
    String comparison,
    String limitation) {}
