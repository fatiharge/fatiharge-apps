package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record SecondFactorRequest(
    @Schema(required = true) String pendingToken, @Schema(required = true) String code) {}
