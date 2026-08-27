package com.dafalabs.api.auth.device.dto;

import org.eclipse.microprofile.openapi.annotations.media.Schema;

/** @param deviceId the subject of the token that was presented */
public record CurrentDeviceResponse(
    @Schema(required = true) String deviceId) {}
