package com.dafalabs.api.auth.session.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

public record RefreshRequest(@Schema(required = true) String refreshToken) {}
