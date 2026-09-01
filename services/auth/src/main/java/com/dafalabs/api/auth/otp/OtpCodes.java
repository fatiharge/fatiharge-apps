package com.dafalabs.api.auth.otp;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.UUID;

/** Generates the code and reduces it to the only form that gets stored. */
final class OtpCodes {

  private static final SecureRandom RANDOM = new SecureRandom();
  private static final int BOUND = 1_000_000;

  private OtpCodes() {}

  /**
   * Six digits, zero padded. {@link SecureRandom} rather than {@link
   * java.util.Random}: the second is seeded predictably enough that a code can
   * be computed rather than guessed.
   */
  static String generate() {
    return String.format("%06d", RANDOM.nextInt(BOUND));
  }

  /**
   * Salted with the challenge id, so the same code issued twice does not produce
   * the same row and a stolen table cannot be scanned for a known digest.
   */
  static String hash(UUID challengeId, String code) {
    try {
      MessageDigest sha256 = MessageDigest.getInstance("SHA-256");
      byte[] digest = sha256.digest((challengeId + ":" + code).getBytes(StandardCharsets.UTF_8));
      return HexFormat.of().formatHex(digest);
    } catch (NoSuchAlgorithmException e) {
      throw new IllegalStateException("SHA-256 is required by every JVM", e);
    }
  }

  /** Length-independent comparison, so timing does not leak how much matched. */
  static boolean matches(UUID challengeId, String code, String expectedHash) {
    return MessageDigest.isEqual(
        hash(challengeId, code).getBytes(StandardCharsets.UTF_8),
        expectedHash.getBytes(StandardCharsets.UTF_8));
  }
}
