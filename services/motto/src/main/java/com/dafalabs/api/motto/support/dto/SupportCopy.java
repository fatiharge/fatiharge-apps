package com.dafalabs.api.motto.support.dto;

import java.util.List;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * Everything the support screens say.
 *
 * <p>Served rather than shipped, so a wrong answer — and the one that matters
 * is where somebody's data is — is corrected without a store release.
 */
public record SupportCopy(
    @Schema(required = true) String version,
    @Schema(required = true) List<String> privacy,
    @Schema(required = true) DeletionCopy deletion,
    @Schema(required = true) List<FaqEntry> faq,
    @Schema(required = true) String privacyPolicyUrl) {}
