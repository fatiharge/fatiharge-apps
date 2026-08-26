package com.dafalabs.api.auth.device.dto;

/**
 * @param deviceHash SHA-256 of the identifier the app keeps in the Keychain or
 *     in {@code Settings.Secure.ANDROID_ID}. The raw identifier stays on the
 *     phone; hashing it there is what keeps it off this server entirely.
 * @param platform {@code ios} or {@code android}
 */
public record RegisterDeviceRequest(String deviceHash, String platform) {}
