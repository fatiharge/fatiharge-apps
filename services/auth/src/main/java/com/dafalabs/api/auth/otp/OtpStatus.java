package com.dafalabs.api.auth.otp;

/** Where a challenge is in its one short life. */
public enum OtpStatus {
  /** Issued, not yet proven. */
  PENDING,
  /** The right code arrived. Still has to be spent. */
  VERIFIED,
  /** Spent. A verified challenge buys exactly one thing, once. */
  CONSUMED,
  /** Too many wrong guesses. Dead even if the right code arrives next. */
  BLOCKED,
  EXPIRED
}
