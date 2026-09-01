package com.dafalabs.api.auth.identity;

import com.dafalabs.api.core.error.CustomRuntimeException;
import java.util.Set;

/**
 * What a password has to be before it is accepted.
 *
 * <p>The system this replaces required exactly six digits — a million
 * possibilities, and the same strength as the one-time code that guarded it.
 * Whoever administers a tenant can reach everyone in it, so the rule
 * here is length rather than composition: length is the only property that
 * reliably costs an attacker anything, and composition rules mostly cost the
 * person choosing.
 */
final class PasswordPolicy {

  private static final int MIN_LENGTH = 12;
  private static final int MAX_LENGTH = 256;

  /** Not a substitute for a breach list. It only catches the laziest choices. */
  private static final Set<String> OBVIOUS =
      Set.of("password1234", "123456789012", "qwertyuiopas", "aaaaaaaaaaaa");

  private PasswordPolicy() {}

  static void check(String password) {
    if (password == null || password.length() < MIN_LENGTH) {
      throw refuse("Password must be at least " + MIN_LENGTH + " characters.");
    }
    // Bounded because BCrypt hashes the whole input and a caller can otherwise
    // make the server do arbitrary work by sending a very long one.
    if (password.length() > MAX_LENGTH) {
      throw refuse("Password must be at most " + MAX_LENGTH + " characters.");
    }
    if (OBVIOUS.contains(password.toLowerCase())) {
      throw refuse("Password is too easy to guess.");
    }
  }

  private static CustomRuntimeException refuse(String message) {
    return new CustomRuntimeException(422, "password_rejected", message);
  }
}
