package com.dafalabs.api.motto.content;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * A short hash of whatever was just read.
 *
 * <p>Derived rather than stored, so a row corrected by hand at a psql prompt
 * reaches phones exactly like one written through the admin API. A counter
 * somebody has to remember to bump would not.
 */
public final class ContentVersion {

  private final MessageDigest digest;

  public ContentVersion() {
    try {
      digest = MessageDigest.getInstance("SHA-256");
    } catch (NoSuchAlgorithmException impossible) {
      throw new IllegalStateException(impossible);
    }
  }

  /// The separator matters: without it "ab" + "c" hashes the same as "a" + "bc".
  public ContentVersion of(String... values) {
    for (String value : values) {
      digest.update((value == null ? "" : value).getBytes(StandardCharsets.UTF_8));
      digest.update((byte) 0);
    }
    return this;
  }

  public ContentVersion of(int value) {
    return of(String.valueOf(value));
  }

  @Override
  public String toString() {
    return HexFormat.of().formatHex(digest.digest()).substring(0, 12);
  }
}
