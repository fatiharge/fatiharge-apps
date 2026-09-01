package com.dafalabs.api.auth.identity;

/**
 * Deleting a row would take the audit trail with it, and the identity would
 * immediately be claimable by someone else. The row stays; this says what it
 * still counts for.
 */
public enum UserStatus {
  ACTIVE,
  BLOCKED,
  DELETED
}
