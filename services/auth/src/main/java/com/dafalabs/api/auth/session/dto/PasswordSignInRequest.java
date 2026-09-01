package com.dafalabs.api.auth.session.dto;

import com.dafalabs.api.auth.identity.IdentityType;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record PasswordSignInRequest(
    @Schema(required = true) IdentityType identityType,
    @Schema(required = true) String identity,
    @Schema(required = true) String password) {}
