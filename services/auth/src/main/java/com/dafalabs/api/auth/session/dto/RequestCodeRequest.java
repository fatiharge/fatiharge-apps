package com.dafalabs.api.auth.session.dto;

import com.dafalabs.api.auth.identity.IdentityType;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

/**
 * @param identityType {@code EMAIL}. {@code PHONE} is part of the model but no
 *     channel carries it yet, and asking for one is refused rather than queued.
 * @param identity the address the code is sent to
 */
public record RequestCodeRequest(
    @Schema(required = true) IdentityType identityType, @Schema(required = true) String identity) {}
