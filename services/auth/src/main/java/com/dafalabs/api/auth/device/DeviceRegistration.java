package com.dafalabs.api.auth.device;

import com.dafalabs.api.core.error.CustomRuntimeException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.time.Clock;
import java.time.Instant;
import java.util.Set;
import java.util.regex.Pattern;

/** Turns a device hash into an identity, creating one only the first time. */
@ApplicationScoped
public class DeviceRegistration {

  private static final Pattern SHA256_HEX = Pattern.compile("^[0-9a-f]{64}$");
  private static final Set<String> PLATFORMS = Set.of("ios", "android");

  private final DeviceRepository devices;
  private final TokenIssuer tokens;
  private final Clock clock;

  DeviceRegistration(DeviceRepository devices, TokenIssuer tokens, Clock clock) {
    this.devices = devices;
    this.tokens = tokens;
    this.clock = clock;
  }

  /**
   * Registering twice is the normal case, not an error: the app registers again
   * whenever its token expires, and a device that reinstalled the app arrives
   * with the same hash. Both get the identity they already had.
   */
  @Transactional
  public IssuedToken register(String deviceHash, String platform) {
    validate(deviceHash, platform);
    Instant now = clock.instant();

    Device device =
        devices
            .findByHash(deviceHash)
            .orElseGet(
                () -> {
                  Device fresh = Device.register(deviceHash, platform, now);
                  devices.persist(fresh);
                  return fresh;
                });

    return tokens.issue(device, now);
  }

  private void validate(String deviceHash, String platform) {
    if (deviceHash == null || !SHA256_HEX.matcher(deviceHash).matches()) {
      throw new CustomRuntimeException(
          400, "invalid_device_hash", "Cihaz kimliği beklenen biçimde değil.");
    }
    if (platform == null || !PLATFORMS.contains(platform)) {
      throw new CustomRuntimeException(400, "invalid_platform", "Platform tanınmıyor.");
    }
  }
}
