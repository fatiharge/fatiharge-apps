package com.dafalabs.api.auth.device.dto;

/** @param deviceId the subject of the token that was presented */
public record CurrentDeviceResponse(String deviceId) {}
